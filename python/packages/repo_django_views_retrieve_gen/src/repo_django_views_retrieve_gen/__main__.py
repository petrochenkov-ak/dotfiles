import re
import sys
import yaml
from pathlib import Path

# Configuration constants
YAML_DIR = Path("api_codegen/_build")
TARGET_DIR = Path("python/packages/gen_django_views/src/gen_django_views/views")

# Template for Django Ninja Router
NINJA_TEMPLATE = '''from ninja import Router
from {model_module} import {model_name}
from {schema_module} import {schema_name}

router = Router()

@router.get("{ninja_url}", response={schema_name})
def {operation_id}(request, {function_params}):
    return {model_name}.objects.get({lookup_field_assignments})
'''

def convert_url_to_ninja(url):
    """
    Convert URL path: clean slashes and preserve clean {param} format.
    Django Ninja handles types via function annotations, not URL paths.
    """
    clean_url = url.strip("/")
    # Возвращаем путь с оригинальными {param}, убирая лишнюю логику типизации в URL
    return f"/{clean_url}"

def parse_url_params(url):
    """Extract all parameter names inside curly braces {param_id} from URL."""
    return re.findall(r'\{([^}]+)\}', url)

def split_module_and_class(full_path, yaml_path, endpoint_id, field_name):
    """
    Split a string like 'billing.models.Invoice'
    into module ('billing.models') and class name ('Invoice').
    """
    if not full_path or '.' not in full_path:
        sys.exit(
            f"Critical error in file '{yaml_path}' (endpoint: '{endpoint_id}'):\n"
            f"Field '{field_name}' must be a full dot-separated path, got: '{full_path}'"
        )
    parts = full_path.split('.')
    class_name = parts[-1]
    module_name = '.'.join(parts[:-1])
    return module_name, class_name

def find_yaml_files(root_dir: Path):
    """Recursively search for all .yaml and .yml files in the directory."""
    return list(root_dir.rglob("*.yaml")) + list(root_dir.rglob("*.yml"))

def main():
    # Validation 1: Verify source directory exists
    if not YAML_DIR.exists():
        sys.exit(f"Critical error: Directory {YAML_DIR} not found.")

    # Recursively find files across the entire directory structure
    yaml_files = find_yaml_files(YAML_DIR)
    if not yaml_files:
        sys.exit(f"Critical error: No .yaml or .yml files found in {YAML_DIR} or its subdirectories.")

    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    total_processed_endpoints = 0

    # 1. Generate and update endpoint files
    for yaml_path in yaml_files:
        try:
            with open(yaml_path, 'r', encoding='utf-8') as f:
                # Read content before the '---' separator
                content = f.read().split('---')[0]
                data = yaml.safe_load(content)
        except Exception as e:
            sys.exit(f"Critical error: Failed to parse YAML file '{yaml_path}'. Reason: {e}")

        if not data or 'endpoints' not in data:
            continue

        for endpoint in data['endpoints']:
            if endpoint.get('method') != 'GET':
                continue

            operation_id = endpoint.get('operation_id')
            # Filter: processing only endpoints where operation_id ends with '_retrieve'
            if not operation_id or not operation_id.endswith('_retrieve'):
                continue

            # Проверка наличия обязательных полей в эндпоинте
            required_fields = ['model', 'response_model', 'url']
            for field in required_fields:
                if field not in endpoint or not endpoint[field]:
                    sys.exit(
                        f"Critical error in file '{yaml_path}':\n"
                        f"Endpoint with operation_id '{operation_id}' is missing required field: '{field}'"
                    )

            file_name = f"{operation_id}.py"
            file_path = TARGET_DIR / file_name
            total_processed_endpoints += 1

            # Parse module paths for correct import lines
            model_mod, model_cls = split_module_and_class(endpoint['model'], yaml_path, operation_id, 'model')
            schema_mod, schema_cls = split_module_and_class(endpoint['response_model'], yaml_path, operation_id, 'response_model')

            # Format the URL route and types for Django Ninja
            ninja_url = convert_url_to_ninja(endpoint['url'])
            url_params = parse_url_params(endpoint['url'])

            # Generate the function arguments signature
            func_params_list = []
            for p in url_params:
                p_type = "int" if "id" in p.lower() else "str"
                func_params_list.append(f"{p}: {p_type}")
            function_params = ", ".join(func_params_list)

            # Generate assignments inside the Django ORM .get() method
            lookup_assignments = ", ".join([f"{p}={p}" for p in url_params])

            # Compile template into final python code
            new_code = NINJA_TEMPLATE.format(
                model_module=model_mod,
                model_name=model_cls,
                schema_module=schema_mod,
                schema_name=schema_cls,
                ninja_url=ninja_url,
                operation_id=operation_id,
                function_params=function_params,
                lookup_field_assignments=lookup_assignments
            )

            # Check file updates and write logs
            if not file_path.exists():
                file_path.write_text(new_code, encoding='utf-8')
                print(f"NEW: {file_path}")
            else:
                current_code = file_path.read_text(encoding='utf-8')
                if current_code != new_code:
                    file_path.write_text(new_code, encoding='utf-8')
                    print(f"UPDATED: {file_path}")

    # Validation 2: Ensure at least one view was processed/generated successfully
    if total_processed_endpoints == 0:
        files_list = "\n".join([f" - {str(f)}" for f in yaml_files])
        sys.exit(
            f"Critical error: No valid endpoints with '_retrieve' operation_id found across all files.\n"
            f"Scanned files:\n{files_list}"
        )

if __name__ == "__main__":
    main()
