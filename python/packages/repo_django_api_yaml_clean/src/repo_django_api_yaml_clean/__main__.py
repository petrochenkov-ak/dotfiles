import os
import sys

SRC_DIR = os.path.join("api_codegen", "src")
BUILD_DIR = os.path.join("api_codegen", "_build")


def main():
    expected_build_files = set()

    # 1. Собираем пути к файлам, которые ДОЛЖНЫ существовать в build
    if os.path.exists(SRC_DIR):
        for root, _, files in os.walk(SRC_DIR):
            for file in files:
                if not (file.endswith(".yaml") or file.endswith(".yml")):
                    continue
                src_file_path = os.path.join(root, file)
                rel_path = os.path.relpath(src_file_path, SRC_DIR)
                build_file_path = os.path.normpath(os.path.join(BUILD_DIR, rel_path))
                expected_build_files.add(build_file_path)

    if not os.path.exists(BUILD_DIR):
        return

    # 2. Удаляем файлы-сироты
    for root, _, files in os.walk(BUILD_DIR):
        for file in files:
            build_file_path = os.path.normpath(os.path.join(root, file))
            if build_file_path not in expected_build_files:
                try:
                    os.remove(build_file_path)
                    print(f"DELETED FILE: {build_file_path}")
                except Exception as e:
                    print(f"[ERROR] Failed to delete file {build_file_path}: {e}", file=sys.stderr)

    # 3. Удаляем пустые директории (идем снизу вверх, чтобы вложенность не мешала)
    for root, dirs, files in os.walk(BUILD_DIR, topdown=False):
        for dirname in dirs:
            dir_path = os.path.join(root, dirname)
            try:
                # Проверяем, пуста ли папка (нет ни файлов, ни других папок)
                if not os.listdir(dir_path):
                    os.rmdir(dir_path)
                    print(f"DELETED DIR:  {dir_path}")
            except Exception as e:
                print(f"[ERROR] Failed to delete directory {dir_path}: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
