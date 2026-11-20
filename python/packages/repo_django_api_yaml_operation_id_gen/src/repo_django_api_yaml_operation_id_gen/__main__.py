import os
import sys
import yaml

BUILD_DIR = os.path.join("api_codegen", "_build")


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

            # Считаем относительный путь от BUILD_DIR для генерации operation_id
            rel_path = os.path.relpath(build_file_path, BUILD_DIR)
            clean_path, _ = os.path.splitext(rel_path)

            with open(build_file_path, "r", encoding="utf-8") as f:
                raw_content = f.read()
                f.seek(0)
                build_data = yaml.safe_load(f) or {}

            updated_endpoints = []

            # Формируем operation_id на основе структуры папок в _build
            operation_id = f"api_{clean_path.replace(os.sep, '_').lower()}"

            for endpoint in build_data.get("endpoints", []):
                new_endpoint = {}

                # Переносим все существующие поля без изменений
                for key, value in endpoint.items():
                    new_endpoint[key] = value

                # Добавляем или обновляем operation_id
                new_endpoint["operation_id"] = operation_id

                updated_endpoints.append(new_endpoint)

            new_yaml_content = yaml.dump(
                {"endpoints": updated_endpoints},
                Dumper=CleanYamlDumper,
                indent=2,
                sort_keys=False,
                allow_unicode=True,
                default_flow_style=False,
            )

            # Перезаписываем файл на месте только при изменениях
            if raw_content != new_yaml_content:
                with open(build_file_path, "w", encoding="utf-8") as f:
                    f.write(new_yaml_content)
                print(f"UPDATED: {build_file_path}")


if __name__ == "__main__":
    main()
