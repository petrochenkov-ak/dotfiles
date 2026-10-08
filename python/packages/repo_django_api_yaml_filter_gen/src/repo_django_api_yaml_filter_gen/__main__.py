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


def find_package_for_filter(filter_name: str, src_file_path: str) -> str:
    check_packages_dir()
    base_name = filter_name[:-6] if filter_name.lower().endswith("filter") else filter_name
    file_name = f"{camel_to_snake(base_name)}_filter.py"

    found_packages = []
    for pkg in os.listdir(PACKAGES_DIR):
        if os.path.exists(os.path.join(PACKAGES_DIR, pkg, "src", pkg, "filters", file_name)):
            found_packages.append(pkg)
    if len(found_packages) > 1:
        print(f"[ERROR] Source file: {src_file_path}\nAmbiguous filter '{filter_name}'. Found in: {found_packages}", file=sys.stderr)
        sys.exit(1)
    if not found_packages:
        print(f"[ERROR] Source file: {src_file_path}\nFilter '{filter_name}' (expected file: {file_name}) NOT FOUND", file=sys.stderr)
        sys.exit(1)
    return found_packages[0]


def find_package_for_model_filter_optional(model_name: str) -> str:
    if not os.path.exists(PACKAGES_DIR):
        return None
    file_name = f"{camel_to_snake(model_name)}_filter.py"
    for pkg in os.listdir(PACKAGES_DIR):
        if os.path.exists(os.path.join(PACKAGES_DIR, pkg, "src", pkg, "filters", file_name)):
            return pkg
    return None


def parse_existing_path(val: str, default_submodule: str):
    """
    Разбирает пути фильтра:
    - 'pkg.filters.FilterName' -> pkg, 'filters', FilterName
    - 'pkg.FilterName'         -> pkg, default_submodule, FilterName
    """
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
                f.seek(0)
                build_data = yaml.safe_load(f) or {}

            updated_endpoints = []

            for endpoint in build_data.get("endpoints", []):
                new_endpoint = {}

                # 1. Сначала копируем все поля один в один
                for key, value in endpoint.items():
                    new_endpoint[key] = value

                # 2. Обрабатываем фильтр, только если в оригинале указан полный путь (есть точка)
                filter_val = endpoint.get("filter")
                if filter_val and isinstance(filter_val, str) and "." in filter_val:
                    pkg, submodule, filter_name = parse_existing_path(filter_val, "filters")
                    if not pkg:
                        pkg = find_package_for_filter(filter_name, build_file_path)
                    new_endpoint["filter"] = f"{pkg}.filters.{filter_name}"

                # 3. Автопоиск фильтра по модели: только если поля 'filter' вообще не было в оригинале,
                # но у модели при этом указан полный путь (есть точка)
                elif "filter" not in endpoint:
                    model_val = endpoint.get("model")
                    if model_val and isinstance(model_val, str) and "." in model_val:
                        _, _, model_name = parse_existing_path(model_val, "models")
                        filter_pkg = find_package_for_model_filter_optional(model_name)
                        if filter_pkg:
                            new_endpoint["filter"] = f"{filter_pkg}.filters.{model_name}Filter"

                updated_endpoints.append(new_endpoint)

            new_yaml_content = yaml.dump(
                {"endpoints": updated_endpoints},
                Dumper=CleanYamlDumper,
                indent=2,
                sort_keys=False,
                allow_unicode=True,
                default_flow_style=False,
            )

            # Перезаписываем файл только при наличии изменений
            if raw_content != new_yaml_content:
                with open(build_file_path, "w", encoding="utf-8") as f:
                    f.write(new_yaml_content)
                print(f"UPDATED FILTER: {build_file_path}")


if __name__ == "__main__":
    main()
