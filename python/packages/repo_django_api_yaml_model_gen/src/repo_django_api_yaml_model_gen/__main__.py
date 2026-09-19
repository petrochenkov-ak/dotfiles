import os
import sys
import yaml

BUILD_DIR = os.path.join("api_codegen", "_build")
PACKAGES_DIR = os.path.join("python", "packages")


class CleanYamlDumper(yaml.SafeDumper):
    def increase_indent(self, flow=False, indentless=False):
        return super().increase_indent(flow, indentless=False)

    def represent_mapping(self, tag, mapping, flow_style=None):
        value = []
        node = yaml.nodes.MappingNode(tag, value, flow_style=flow_style)
        if self.alias_key is not None:
            self.represented_objects[self.alias_key] = node
        for item_key, item_value in mapping.items():
            node_key = self.represent_data(item_key)
            if isinstance(node_key, yaml.nodes.ScalarNode) and node_key.tag == 'tag:yaml.org,2002:str':
                node_key.style = None
            node_value = self.represent_data(item_value)
            if isinstance(node_value, yaml.nodes.ScalarNode) and node_value.tag == 'tag:yaml.org,2002:str':
                node_value.style = '"'
            value.append((node_key, node_value))
        node.value = value
        return node


def camel_to_snake(name: str) -> str:
    res = []
    for i, char in enumerate(name):
        if char.isupper() and i > 0:
            if name[i - 1].islower() or (i + 1 < len(name) and name[i + 1].islower()):
                res.append('_')
        res.append(char.lower())
    return "".join(res)


def check_packages_dir():
    if not os.path.exists(PACKAGES_DIR):
        print(f"[ERROR] Packages directory '{PACKAGES_DIR}' not found.", file=sys.stderr)
        sys.exit(1)


def find_package_for_model(model_name: str, src_file_path: str) -> str:
    check_packages_dir()
    file_name = f"{camel_to_snake(model_name)}.py"
    found_packages = []
    for pkg in os.listdir(PACKAGES_DIR):
        if os.path.exists(os.path.join(PACKAGES_DIR, pkg, "src", pkg, "models", file_name)):
            found_packages.append(pkg)
    if len(found_packages) > 1:
        print(f"[ERROR] Source file: {src_file_path}\nAmbiguous model '{model_name}'. Found in: {found_packages}", file=sys.stderr)
        sys.exit(1)
    if not found_packages:
        print(f"[ERROR] Source file: {src_file_path}\nModel '{model_name}' NOT FOUND", file=sys.stderr)
        sys.exit(1)
    return found_packages[0]


def parse_existing_path(val: str, default_submodule: str):
    parts = val.split(".")
    if len(parts) == 3:
        return parts[0], parts[1], parts[2]
    elif len(parts) == 2:
        pkg, name = parts
        return pkg, default_submodule, name
    return None, None, val


def main():
    if not os.path.exists(BUILD_DIR):
        print(f"[ERROR] Build directory '{BUILD_DIR}' does not exist.", file=sys.stderr)
        sys.exit(1)

    for root, _, files in os.walk(BUILD_DIR):
        for file in files:
            if not (file.endswith(".yaml") or file.endswith(".yml")):
                continue
            build_file_path = os.path.join(root, file)

            with open(build_file_path, "r", encoding="utf-8") as f:
                raw_content = f.read()
                build_data = yaml.safe_load(raw_content) or {}

            updated_endpoints = []
            changes = []

            for endpoint in build_data.get("endpoints", []):
                new_endpoint = endpoint.copy()
                model_val = endpoint.get("model")

                if model_val and isinstance(model_val, str):
                    # Проверяем структуру пути модели
                    pkg, submodule, model_name = parse_existing_path(model_val, "models")

                    # Если пакета нет (строка была без точек или неполная), ищем его
                    if not pkg:
                        try:
                            pkg = find_package_for_model(model_name, build_file_path)
                        except SystemExit:
                            # Если модель вообще не найдена в find_package_for_model,
                            # мы упадем внутри этой функции с её ошибкой.
                            raise

                    new_model_path = f"{pkg}.models.{model_name}"

                    # Формируем итоговый физический путь к файлу Python
                    snake_model_file = f"{camel_to_snake(model_name)}.py"
                    expected_path = os.path.join(
                        PACKAGES_DIR, pkg, "src", pkg, "models", snake_model_file
                    )

                    # Проверяем существование файла по итоговой модели
                    if not os.path.exists(expected_path):
                        print(f"ERROR: {build_file_path}", file=sys.stderr)
                        print(f'model: "{new_model_path}"', file=sys.stderr)
                        print(f"{expected_path} not exists", file=sys.stderr)
                        sys.exit(1)

                    if model_val != new_model_path:
                        new_endpoint["model"] = new_model_path
                        changes.append({"old": model_val, "new": new_model_path})

                updated_endpoints.append(new_endpoint)

            if not changes:
                continue

            new_yaml_content = yaml.dump(
                {"endpoints": updated_endpoints},
                Dumper=CleanYamlDumper,
                indent=2,
                sort_keys=False,
                allow_unicode=True,
                default_flow_style=False,
            )

            if raw_content != new_yaml_content:
                print(f"UPDATED model: {build_file_path}")
                for chg in changes:
                    print(f'model: "{chg["old"]}"')
                    print(f'model: "{chg["new"]}"')

                with open(build_file_path, "w", encoding="utf-8") as f:
                    f.write(new_yaml_content)


if __name__ == "__main__":
    main()
