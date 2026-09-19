import argparse
import sys
from pathlib import Path

# --- Инициализация Django с PostgreSQL ---
from django.conf import settings
import dj_database_url

if not settings.configured:
    # Хардкод URL для подключения к базе данных
    DATABASE_URL = "postgres://postgres:@127.0.0.1:5433/codegen_local"

    settings.configure(
        INSTALLED_APPS=[
            "django.contrib.contenttypes",
            "rest_framework",
        ],
        DATABASES={
            # Автоматически парсит строку подключения в формат Django
            "default": dj_database_url.config(
                default=DATABASE_URL,
                conn_max_age=600,
                ssl_require=False
            )
        },
    )

import django
django.setup()
# ---------------------------------------------------------


def snake_to_pascal(text: str) -> str:
    """Конвертирует snake_case в PascalCase для имени класса модели."""
    return "".join(word.capitalize() for word in text.split("_"))


def generate_serializer_template(models_package: str, table_name: str, table_pascal: str) -> str:
    """Формирует шаблон ModelSerializer на основе имени таблицы."""
    return f"""from rest_framework import serializers

from {models_package}.models.{table_name} import {table_pascal}


class {table_pascal}Serializer(serializers.ModelSerializer):
    class Meta:
        model = {table_pascal}
        fields = "__all__"
"""


def process_package(package_root: Path, cwd_absolute: Path):
    package_name = package_root.name

    # Проверяем, что запуск происходит из пакета моделей
    if not package_name.endswith("_models_gen"):
        print(f"Error: Expected a package ending with '_models_gen', got '{package_name}'.", file=sys.stderr)
        sys.exit(1)

    base_name = package_name.replace("_models_gen", "")
    target_pkg_name = f"{base_name}_serializers_gen"

    # Директория с моделями: xxx_models_gen/src/xxx_models_gen/models/
    models_dir = package_root / "src" / package_name / "models"
    if not models_dir.is_dir():
        print(f"Error: Models directory not found at '{models_dir.relative_to(cwd_absolute)}'.", file=sys.stderr)
        sys.exit(1)

    # Находим все файлы таблиц, игнорируя служебные файлы вроде __init__.py
    model_files = [f for f in models_dir.glob("*.py") if not f.name.startswith("_")]

    if not model_files:
        print(f"No model files found in {models_dir.relative_to(cwd_absolute)}")
        return

    # Путь назначения: xxx_serializers_gen/src/xxx_serializers_gen/serializers/
    target_pkg_src = package_root.parent / target_pkg_name / "src" / target_pkg_name
    serializers_dir = target_pkg_src / "serializers"
    serializers_dir.mkdir(parents=True, exist_ok=True)

    # Инициализируем __init__.py файлы для валидности python-пакетов
    (target_pkg_src / "__init__.py").touch(exist_ok=True)
    (serializers_dir / "__init__.py").touch(exist_ok=True)

    for model_file in model_files:
        table_name = model_file.stem  # Например: 'user_profile'
        table_pascal = snake_to_pascal(table_name)  # Например: 'UserProfile'

        serializer_file = serializers_dir / f"{table_name}_serializer.py"
        new_code = generate_serializer_template(package_name, table_name, table_pascal)

        is_new = not serializer_file.exists()

        # Перезаписываем файл, только если он новый или код изменился (простая проверка строк)
        if is_new or serializer_file.read_text(encoding="utf-8") != new_code:
            serializer_file.write_text(new_code, encoding="utf-8")
            status = "NEW" if is_new else "UPDATED"
            print(f"{status}: {serializer_file.resolve().relative_to(cwd_absolute)}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("package_dir", type=str, help="Путь к директории пакета xxx_models_gen")
    args = parser.parse_args()

    package_root = Path(args.package_dir).resolve()
    if not package_root.exists():
        print(f"Error: Path '{args.package_dir}' does not exist.", file=sys.stderr)
        sys.exit(1)

    process_package(package_root, Path.cwd().resolve())


if __name__ == "__main__":
    main()
