import sys
import yaml
import re
from pathlib import Path

# Configuration constants
YAML_DIR = Path("api_codegen/_build")
TARGET_DIR = Path("python/packages/gen_django_views/src/gen_django_views/views")

def find_yaml_files(root_dir: Path):
    """Recursively search for all .yaml and .yml files in the directory."""
    return list(root_dir.rglob("*.yaml")) + list(root_dir.rglob("*.yml"))

def main():
    # Validation 1: Verify source directory with YAML files exists
    if not YAML_DIR.exists():
        raise FileNotFoundError(f"Critical error: Directory {YAML_DIR} not found.")

    yaml_files = find_yaml_files(YAML_DIR)
    if not yaml_files:
        raise FileNotFoundError(f"Critical error: No .yaml/.yml files found in {YAML_DIR}.")

    # Validation 2: Verify target views directory exists
    if not TARGET_DIR.exists():
        raise FileNotFoundError(f"Critical error: Target directory {TARGET_DIR} does not exist.")

    valid_operation_ids = set()

    # Collect all active operation_ids from all YAML files
    for yaml_path in yaml_files:
        with open(yaml_path, 'r', encoding='utf-8') as f:
            try:
                content = f.read().split('---')[0]
                data = yaml.safe_load(content)
            except Exception as e:
                print(f"Error reading {yaml_path}: {e}", file=sys.stderr)
                continue

            if not data or 'endpoints' not in data:
                continue

            for endpoint in data['endpoints']:
                # Only consider GET endpoints, matching the main generator logic
                if endpoint.get('method') == 'GET':
                    operation_id = endpoint.get('operation_id')
                    if operation_id:
                        valid_operation_ids.add(f"{operation_id}.py")

    # Validation 3: Ensure at least some valid endpoints were discovered
    if not valid_operation_ids:
        raise RuntimeError(f"Critical error: No valid GET endpoints found in the YAML files.")

    deleted_count = 0

    # Remove files that are not present in the valid_operation_ids set
    for existing_file in TARGET_DIR.glob("*.py"):
        # Skip __init__.py files
        if existing_file.name == "__init__.py":
            continue

        if existing_file.name not in valid_operation_ids:
            existing_file.unlink()
            print(f"DELETED: {existing_file}")
            deleted_count += 1

if __name__ == "__main__":
    main()
