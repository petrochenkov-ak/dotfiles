"""
AI Instructions:
1. DO NOT add any comments inside the code or functions.
2. DO NOT generate any docstrings for functions, classes, or methods. Keep only this module-level docstring.
3. All code, explanations, and messages must be strictly in English
4. Keep all log, error, and console output print messages as short and concise as possible.
"""

import hashlib
import os
from pathlib import Path

import yaml
from django.apps import apps
from django.conf import settings
from django.utils.text import camel_case_to_spaces

if not settings.configured:
    settings.configure(
        INSTALLED_APPS=[
            "django.contrib.contenttypes",
            "github_sync_gists",
        ],
        DATABASES={"default": {"ENGINE": "django.db.backends.dummy"}},
        SECRET_KEY="SECRET_KEY",
    )
    import django

    django.setup()

from ninja.orm import create_schema

BASE_DIR = Path.cwd()
CONTRACTS_DIR = (
    BASE_DIR
    / "python/packages/github_sync_gists_contracts/github_sync_gists_contracts"
)
GENERATED_SPECS_DIR = CONTRACTS_DIR / "generated_specs"


def get_content_hash(content: str) -> str:
    return hashlib.md5(content.encode("utf-8")).hexdigest()


def main():
    GENERATED_SPECS_DIR.mkdir(parents=True, exist_ok=True)
    expected_yaml_files = set()

    app_config = apps.get_app_config("github_sync_gists")
    models = app_config.get_models()

    for model_class in models:
        class_name = model_class.__name__

        if "tsv" in class_name.lower():
            continue

        file_name = camel_case_to_spaces(class_name).replace(" ", "_")
        yaml_name = f"{file_name}.yaml"
        yaml_path = GENERATED_SPECS_DIR / yaml_name
        expected_yaml_files.add(yaml_name)

        try:
            pydantic_schema = create_schema(model_class, name=class_name)
            schema_dict = pydantic_schema.model_json_schema()

            schema_dict.pop("title", None)
            schema_dict.pop("description", None)

            properties = schema_dict.get("properties", {})
            for field_props in properties.values():
                if isinstance(field_props, dict):
                    field_props.pop("title", None)
                    field_props.pop("description", None)
                    field_props.pop("default", None)

            if "id" in properties:
                properties["id"] = {
                    "type": "integer",
                }
                if "id" not in schema_dict.setdefault("required", []):
                    schema_dict["required"].insert(0, "id")

            new_yaml_content = yaml.dump(
                schema_dict, allow_unicode=True, sort_keys=False
            )

            is_yaml_changed = True
            is_new_file = not yaml_path.exists()

            if not is_new_file:
                with open(yaml_path, "r", encoding="utf-8") as f:
                    if get_content_hash(f.read()) == get_content_hash(
                        new_yaml_content
                    ):
                        is_yaml_changed = False

            if is_yaml_changed:
                with open(yaml_path, "w", encoding="utf-8") as f:
                    f.write(new_yaml_content)

                status = "NEW" if is_new_file else "UPDATE"
                print(f"{status} {yaml_path}")

        except Exception as e:
            print(f"Error {class_name}: {e}")

    for existing_yaml in GENERATED_SPECS_DIR.glob("*.yaml"):
        if existing_yaml.name not in expected_yaml_files:
            print(f"DELETED {existing_yaml}")
            existing_yaml.unlink()


if __name__ == "__main__":
    main()
