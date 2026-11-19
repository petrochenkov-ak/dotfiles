import os
import sys
import yaml

SRC_DIR = os.path.join("api_codegen", "src")
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

def get_name(val: str) -> str:
    """Возвращает последнюю часть пути (после точки)."""
    return val.split(".")[-1] if val else ""

def should_update_field(src_val: str, build_val: str) -> bool:
    """Определяет, нужно ли переносить значение из src в build."""
    if not src_val:
        return False

    src_str = str(src_val)
    build_str = str(build_val) if build_val else ""

    # Если в build точек больше — не трогаем
    if build_str.count(".") > src_str.count("."):
        return False

    if "." in src_str:
        return src_str != build_str

    return src_str != get_name(build_str)

def main():
    if not os.path.exists(SRC_DIR):
        print(f"[ERROR] Source directory '{SRC_DIR}' not found.", file=sys.stderr)
        sys.exit(1)

    for root, _, files in os.walk(SRC_DIR):
        for file in files:
            if not (file.endswith(".yaml") or file.endswith(".yml")):
                continue

            src_path = os.path.join(root, file)
            rel_path = os.path.relpath(src_path, SRC_DIR)
            build_path = os.path.normpath(os.path.join(BUILD_DIR, rel_path))

            with open(src_path, "r", encoding="utf-8") as f:
                src_data = yaml.safe_load(f) or {}

            if os.path.exists(build_path):
                with open(build_path, "r", encoding="utf-8") as f:
                    raw_build_content = f.read()
                    base_data = yaml.safe_load(raw_build_content) or {}
            else:
                base_data = src_data
                raw_build_content = ""

            if "endpoints" not in src_data or "endpoints" not in base_data:
                continue

            # Список для логирования изменений в текущем файле
            file_changes = []

            for i, src_ep in enumerate(src_data["endpoints"]):
                if i >= len(base_data["endpoints"]):
                    break

                build_ep = base_data["endpoints"][i]

                for key in ["model", "response_model", "filter"]:
                    src_val = src_ep.get(key)
                    build_val = build_ep.get(key, "")

                    if should_update_field(src_val, build_val):
                        build_ep[key] = src_val
                        # Добавляем строку изменения в формате YAML
                        file_changes.append(f'  {key}: "{src_val}"')

            # Генерация нового контента
            new_yaml = yaml.dump(
                base_data,
                Dumper=CleanYamlDumper,
                indent=2,
                sort_keys=False,
                allow_unicode=True,
                default_flow_style=False,
            )

            # Записываем и выводим лог, если файл новый или были изменения
            is_new = not os.path.exists(build_path)
            if is_new or (file_changes and new_yaml != raw_build_content):
                os.makedirs(os.path.dirname(build_path), exist_ok=True)
                with open(build_path, "w", encoding="utf-8") as f:
                    f.write(new_yaml)

                # Построчный вывод результатов
                if is_new:
                    print(f"NEW: {build_path}")
                else:
                    print(f"UPDATED: {build_path}")
                    for change in file_changes:
                        print(change)

if __name__ == "__main__":
    main()
