import argparse
import importlib
import re
import sys
import tempfile
from pathlib import Path
import yaml

from django.conf import settings
import dj_database_url

DATABASE_URL = "postgres://postgres:@127.0.0.1:5433/codegen_local"

if not settings.configured:
    settings.configure(
        INSTALLED_APPS=[
            "django.contrib.contenttypes",
            "rest_framework",
        ],
        DATABASES={
            "default": dj_database_url.config(
                default=DATABASE_URL,
                conn_max_age=600,
                ssl_require=False
            )
        },
    )

import django
django.setup()

from datamodel_code_generator import generate, InputFileType
from drf_yasg import openapi
from drf_yasg.errors import SwaggerGenerationError
from drf_yasg.inspectors import InlineSerializerInspector, swagger_settings
from rest_framework import serializers


def to_pascal_case(snake_str: str) -> str:
    return "".join(x.capitalize() for x in snake_str.lower().split("_"))


def generate_model_schema_dict(model_class, class_name: str, app_label: str) -> tuple[dict, list[str]]:
    if not getattr(model_class._meta, "app_label", None):
        model_class._meta.app_label = app_label

    serializer_class = type(
        f"{class_name}Serializer",
        (serializers.ModelSerializer,),
        {"Meta": type("Meta", (), {"model": model_class, "fields": "__all__"})}
    )

    class DummyComponents:
        def __init__(self): self.schemas = {}
        def with_scope(self, name): return self
        def get_security_requirements(self, *args, **kwargs): return []

    components = DummyComponents()
    inspector = InlineSerializerInspector(
        view=None, path=None, method=None, components=components,
        field_inspectors=swagger_settings.DEFAULT_FIELD_INSPECTORS, request=None,
    )

    serializer_instance = serializer_class()
    required_fields = [name for name, f in serializer_instance.fields.items() if f.required]

    schema_object = inspector.field_to_swagger_object(
        serializer_instance, swagger_object_type=openapi.Schema, use_references=False,
        schema_cls=openapi.Schema, definitions=components.schemas, attribute_cleaner=None,
    )

    properties = {}
    for field_name, field_schema in schema_object.properties.items():
        field_dict = (
            field_schema.as_odict() if hasattr(field_schema, "as_odict")
            else getattr(field_schema, "to_odict", lambda: field_schema)()
        )

        if isinstance(field_dict, dict):
            for key in ("title", "description", "minimum", "maximum", "maxLength", "minLength"):
                field_dict.pop(key, None)

        properties[field_name] = field_dict

    return properties, required_fields


def inspect_model_fields(schema: str, table: str, class_name: str) -> tuple[dict, list[str]]:
    module_name = f"{schema}.models.{table}"
    module = importlib.import_module(module_name)
    model_class = getattr(module, class_name, None)
    if model_class and hasattr(model_class, "_meta"):
        return generate_model_schema_dict(model_class, class_name, app_label=schema)

    return {"id": {"type": "integer"}}, ["id"]


def normalize_code_structure(code: str) -> str:
    code = re.sub(r"#.*$", "", code, flags=re.MULTILINE)
    code = code.replace('"', "'")
    code = re.sub(r",\s*(?=\n|\)|\]|\})", "", code)
    return re.sub(r"\s+", "", code)


def run_generator(yaml_path: Path, output_path: Path, class_suffix: str, cwd_absolute: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    is_new = not output_path.exists()

    with tempfile.NamedTemporaryFile(suffix=".py", delete=False) as tmp_out:
        tmp_path = Path(tmp_out.name)

    try:
        generate(
            input_=yaml_path, input_file_type=InputFileType.OpenAPI, output=tmp_path,
            output_model_type="pydantic_v2.BaseModel", class_name_suffix=class_suffix,
            disable_timestamp=True, strip_default_none=True, use_standard_collections=True,
        )

        raw_code = tmp_path.read_text(encoding="utf-8")
        clean_code = re.sub(r"^\s*from\s+__future__\s+import\s+annotations\s*$", "", raw_code, flags=re.MULTILINE)
        clean_code = re.sub(r"^\s*#.*$", "", clean_code, flags=re.MULTILINE)
        clean_code = re.sub(r"(?<=\s)#.*$", "", clean_code, flags=re.MULTILINE)
        clean_code = re.sub(r"\n\s*\n", "\n\n", clean_code).strip() + "\n"

        if is_new or normalize_code_structure(output_path.read_text(encoding="utf-8")) != normalize_code_structure(clean_code):
            output_path.write_text(clean_code, encoding="utf-8")
            status = "NEW" if is_new else "UPDATED"
            print(f"{status}: {output_path.resolve().relative_to(cwd_absolute)}")
    finally:
        tmp_path.unlink(missing_ok=True)


def process_package(package_root_path: Path):
    models_schema_name = package_root_path.name
    base_schema_name = models_schema_name.replace("_models_gen", "")
    target_schema_gen = f"{base_schema_name}_schemas_gen"
    parent_dir = package_root_path.parent

    src_models_dir = parent_dir / models_schema_name / "src"
    src_schemas_dir = parent_dir / target_schema_gen / "src"

    for src_dir in (src_models_dir, src_schemas_dir):
        if src_dir.exists():
            abs_path = str(src_dir.resolve())
            if abs_path not in sys.path:
                sys.path.insert(0, abs_path)

    models_dirs_to_check = [
        (models_schema_name, parent_dir / models_schema_name / "src" / models_schema_name / "models"),
        (target_schema_gen, parent_dir / target_schema_gen / "src" / target_schema_gen / "models"),
    ]

    schemas_output_dir = parent_dir / target_schema_gen / "src" / target_schema_gen / "schemas"
    cwd_absolute = Path.cwd().resolve()

    models_to_process = []
    for schema_import_name, models_dir in models_dirs_to_check:
        if models_dir.exists():
            for table_file in models_dir.glob("*.py"):
                if table_file.name == "__init__.py":
                    continue
                models_to_process.append((schema_import_name, table_file))

    if not models_to_process:
        print(f"No models found for schema {models_schema_name} in source directories.")
        return

    with tempfile.NamedTemporaryFile(suffix=".yaml", delete=False) as tmp_yaml:
        yaml_path = Path(tmp_yaml.name)

    try:
        for schema_import_name, table_file in models_to_process:
            table = table_file.stem
            class_name = to_pascal_case(table)
            properties, required_fields = inspect_model_fields(schema_import_name, table, class_name)

            yaml_data = {
                "openapi": "3.0.0",
                "info": {"version": "1.0.0"},
                "id": f"urn:uuid:static-schema-{base_schema_name}-{table}",
                "paths": {},
                "components": {
                    "schemas": {
                        class_name: {
                            "type": "object",
                            "properties": properties,
                            "required": required_fields,
                        }
                    }
                },
            }

            yaml_path.write_text(yaml.dump(yaml_data, sort_keys=False), encoding="utf-8")
            run_generator(yaml_path, schemas_output_dir / f"{table}_schema.py", "Schema", cwd_absolute)
    finally:
        yaml_path.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("package_dir", type=str)
    process_package(Path(parser.parse_args().package_dir))


if __name__ == "__main__":
    main()
