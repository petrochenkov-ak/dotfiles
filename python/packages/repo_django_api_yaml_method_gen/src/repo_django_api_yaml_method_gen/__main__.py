import os
import sys
import yaml

BUILD_DIR = os.path.join("api_codegen", "_build")

METHOD_MAP = {
    "retrieve.yaml": "GET", "retrieve.yml": "GET",
    "delete.yaml": "DELETE", "delete.yml": "DELETE",
    "update.yaml": "POST", "update.yml": "POST",
}


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
                build_data = yaml.safe_load(f) or {}

            # Если в файле нет эндпоинтов, нам нечего обрабатывать
            if "endpoints" not in build_data or not isinstance(build_data["endpoints"], list):
                continue

            f_lower = file.lower()
            if f_lower.endswith("_list.yaml") or f_lower.endswith("_list.yml"):
                expected_method = "GET"
            else:
                expected_method = METHOD_MAP.get(f_lower, "GET")

            has_changes = False

            # Модифицируем существующую структуру на месте
            for endpoint in build_data["endpoints"]:
                if not isinstance(endpoint, dict):
                    continue

                # Проверяем, изменился ли метод на самом деле
                if endpoint.get("method") != expected_method:
                    endpoint["method"] = expected_method
                    has_changes = True

            # Перезаписываем файл ТОЛЬКО если были реальные изменения в данных
            if has_changes:
                new_yaml_content = yaml.dump(
                    build_data,  # Сохраняем весь объект целиком, а не только endpoints
                    Dumper=CleanYamlDumper,
                    indent=2,
                    sort_keys=False,
                    allow_unicode=True,
                    default_flow_style=False,
                )
                with open(build_file_path, "w", encoding="utf-8") as f:
                    f.write(new_yaml_content)
                print(f"UPDATED METHOD: {build_file_path}")


if __name__ == "__main__":
    main()
