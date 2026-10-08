import re
import sys
import yaml
from pathlib import Path

# Configuration constants
YAML_DIR = Path("api_codegen/_build")
TARGET_DIR = Path("python/packages/gen_django_views/src/gen_django_views/views")

# Template for Django Ninja Router WITHOUT filters
NINJA_TEMPLATE = '''from typing import List
from ninja import Router
from {model_module} import {model_name}
from {schema_module} import {schema_name}

router = Router()

@router.get("{ninja_url}", response=List[{schema_name}])
def {operation_id}(request, {function_params}):
    return {model_name}.objects.filter({lookup_field_assignments})
'''

# Template for Django Ninja Router WITH filters
NINJA_TEMPLATE_WITH_FILTER = '''from typing import List
from ninja import Router, Query
from {model_module} import {model_name}
from {schema_module} import {schema_name}
from {filter_module} import {filter_name}

router = Router()

@router.get("{ninja_url}", response=List[{schema_name}])
def {operation_id}(
    request,
    {function_params},
    filters: {filter_name} = Query(...)
):
    queryset = {model_name}.objects.filter({lookup_field_assignments})
    return filters.filter(queryset)
'''

def convert_url_to_ninja(url):
    """
    Convert URL path: clean slashes and preserve clean {param} format.
    Django Ninja handles types via function annotations, not URL paths.
    """
    clean_url = url.strip("/")
    # Теперь мы просто оставляем параметры в исходном виде {param}
    return f"/{clean_url}"

def parse_url_params(url):
    """Extract all parameter names inside curly braces {param_id} from URL."""
    return re.findall(r'\{([^}]+)\}', url)

def split_module_and_class(full_path):
    """
    Split a string like 'billing.models.Invoice'
    into module ('billing.models') and class name ('Invoice').
    """
    parts = full_path.split('.')
    class_name = parts[-1]
    module_name = '.'.join(parts[:-1])
    return module_name, class_name

def find_yaml_files(root_dir: Path):
    """Recursively search for all *list.yaml and *list.yml files in the directory."""
    return list(root_dir.rglob("*list.yaml")) + list(root_dir.rglob("*list.yml"))

def main():
    # Validation 1: Verify source directory exists
    if not YAML_DIR.exists():
        print(f"Critical error: Source directory '{YAML_DIR}' does not exist.", file=sys.stderr)
        sys.exit(1)

    # Recursively find files across the entire directory structure
    yaml_files = find_yaml_files(YAML_DIR)
    if not yaml_files:
        print(f"Critical error: No *list.yaml or *list.yml files discovered in '{YAML_DIR}' or its subdirectories.", file=sys.stderr)
        sys.exit(1)

    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    generated_files = set()
    total_processed_endpoints = 0

    # 1. Generate and update endpoint files
    for yaml_path in yaml_files:
        with open(yaml_path, 'r', encoding='utf-8') as f:
            try:
                content = f.read()
                data = yaml.safe_load(content)
            except Exception as e:
                # Fail fast on YAML syntax error
                print(f"Critical error: YAML syntax breakdown in file '{yaml_path}'. Details: {e}", file=sys.stderr)
                sys.exit(1)

            # Fail fast if file is empty or lacks 'endpoints' root key
            if not data or 'endpoints' not in data:
                print(f"Critical error: Validation failed for file '{yaml_path}'. Reason: Missing required root key 'endpoints' or file is completely empty.", file=sys.stderr)
                sys.exit(1)

            valid_endpoints_in_file = 0
            for endpoint in data['endpoints']:
                method = endpoint.get('method')
                operation_id = endpoint.get('operation_id')

                if method != 'GET':
                    continue

                # Fail fast if operation_id doesn't match criteria
                if not operation_id or not operation_id.endswith('_list'):
                    print(f"Critical error: Invalid operation_id mapping in file '{yaml_path}'. Found operation_id='{operation_id}', but it must end with '_list'.", file=sys.stderr)
                    sys.exit(1)

                valid_endpoints_in_file += 1
                file_name = f"{operation_id}.py"
                file_path = TARGET_DIR / file_name
                generated_files.add(file_name)
                total_processed_endpoints += 1

                # Parse module paths for correct import lines
                model_mod, model_cls = split_module_and_class(endpoint['model'])
                schema_mod, schema_cls = split_module_and_class(endpoint['response_model'])

                # Format the URL route and types for Django Ninja
                ninja_url = convert_url_to_ninja(endpoint['url'])
                url_params = parse_url_params(endpoint['url'])

                # Generate the function arguments signature
                func_params_list = []
                for p in url_params:
                    p_type = "int" if "id" in p.lower() else "str"
                    func_params_list.append(f"{p}: {p_type}")
                function_params = ", ".join(func_params_list)

                # Generate assignments inside the Django ORM .filter() method
                lookup_assignments = ", ".join([f"{p}={p}" for p in url_params])

                # Check if filter key exists in YAML configuration
                filter_path = endpoint.get('filter')

                if filter_path:
                    filter_mod, filter_cls = split_module_and_class(filter_path)
                    new_code = NINJA_TEMPLATE_WITH_FILTER.format(
                        model_module=model_mod,
                        model_name=model_cls,
                        schema_module=schema_mod,
                        schema_name=schema_cls,
                        filter_module=filter_mod,
                        filter_name=filter_cls,
                        ninja_url=ninja_url,
                        operation_id=operation_id,
                        function_params=function_params,
                        lookup_field_assignments=lookup_assignments
                    )
                else:
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

            # Fail fast if file has 'endpoints' block, but zero valid GET _list structures
            if valid_endpoints_in_file == 0:
                print(f"Critical error: No valid target endpoints resolved within file '{yaml_path}'. Expected at least one endpoint matching criteria (GET + operation_id ending with '_list').", file=sys.stderr)
                sys.exit(1)

    # Validation 2: Ensure at least one view was processed/generated successfully overall
    if total_processed_endpoints == 0:
        print(f"Critical error: Execution halted. No valid endpoints with '_list' operation_id found across any discovered YAML configurations.", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
