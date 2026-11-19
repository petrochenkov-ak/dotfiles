import os
import yaml
import sys
from pathlib import Path

URLS_TEMPLATE = """from django.urls import path
{imports_block}

urlpatterns = [
{url_patterns}
]
"""

VIEW_FILE_TEMPLATE = """from django.views.generic import View
{imports_block}

class {view_name}(View):
{methods_block}
"""

METHOD_TEMPLATE = """    def {method}(self, request, *args, **kwargs):
        return JsonResponse({{"status": "stub", "message": "Hello from {view_name} ({method_upper})"}})"""

                                  
LIST_VIEW_TEMPLATE = """from django.views.generic import ListView
from django.http import JsonResponse
from {model_module} import {model_name}
from {serializer_module} import {serializer_name}

class {view_name}(ListView):
    model = {model_name}
    serializer_class = {serializer_name}

    def get(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.serializer_class(queryset, many=True)
        return JsonResponse(serializer.data, safe=False)"""

DETAIL_VIEW_TEMPLATE = """from django.views.generic import DetailView
from django.http import JsonResponse
from {model_module} import {model_name}
from {serializer_module} import {serializer_name}

class {view_name}(DetailView):
    model = {model_name}
    serializer_class = {serializer_name}
    lookup_fields = {lookup_fields}

    def get(self, request, *args, **kwargs):
        self.object = self.get_object()
        serializer = self.serializer_class(self.object)
        return JsonResponse(serializer.data)"""

CREATE_VIEW_TEMPLATE = """from django.views.generic import CreateView
from django.http import JsonResponse
from {model_module} import {model_name}
from {serializer_module} import {serializer_name}

class {view_name}(CreateView):
    model = {model_name}
    serializer_class = {serializer_name}

    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.POST)
        if serializer.is_valid():
            instance = serializer.save()
            return JsonResponse(serializer.data, status=201)
        return JsonResponse(serializer.errors, status=400)"""

UPDATE_VIEW_TEMPLATE = """from django.views.generic import UpdateView
from django.http import JsonResponse
from {model_module} import {model_name}
from {serializer_module} import {serializer_name}

class {view_name}(UpdateView):
    model = {model_name}
    serializer_class = {serializer_name}
    lookup_fields = {lookup_fields}

    def put(self, request, *args, **kwargs):
        self.object = self.get_object()
        serializer = self.serializer_class(self.object, data=request.POST)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data)
        return JsonResponse(serializer.errors, status=400)"""

DELETE_VIEW_TEMPLATE = """from django.views.generic import DeleteView
from django.http import JsonResponse
from {model_module} import {model_name}

class {view_name}(DeleteView):
    model = {model_name}
    lookup_fields = {lookup_fields}

    def delete(self, request, *args, **kwargs):
        self.object = self.get_object()
        self.object.delete()
        return JsonResponse({{"message": "Object deleted successfully"}}, status=204)"""


def main():
    pwd = os.getcwd()
    package_root = os.path.join(pwd, "python", "packages", "django_endpoints", "src", "django_endpoints")
    openapi_paths_dir = os.path.join("openapi", "paths")
    urls_path = os.path.join(package_root, "urls.py")
    views_root = os.path.join(package_root, "views")

    paths = {}

    # <-- Добавлено: чтение всех .yml файлов из директории openapi/paths/
    if not os.path.exists(openapi_paths_dir):
        print(f"[ERROR] OpenAPI paths directory not found at: {openapi_paths_dir}")
        sys.exit(1)

    for root, _, files in os.walk(openapi_paths_dir):
        for file in files:
            if file.endswith('.yml') or file.endswith('.yaml'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        spec_part = yaml.safe_load(f)
                        if spec_part and isinstance(spec_part, dict):
                            part_paths = spec_part.get("paths", {})
                            if part_paths and isinstance(part_paths, dict):
                                paths.update(part_paths)
                            else:
                                print(f"[WARNING] No valid 'paths' found in {file_path}. Skipping.")
                        else:
                            print(f"[WARNING] Invalid structure in {file_path}. Skipping.")
                except Exception as e:
                    print(f"[ERROR] Failed to parse YAML file {file_path}: {e}")
                    sys.exit(1)
    # <-- Конец добавления

    if not paths:
        print("[ERROR] No 'paths' found in any of the OpenAPI path files.")
        sys.exit(1)

                                                     
    operation_ids_registry = set()

    views_map = {}
    imports_sections = []
    patterns_sections = []
    seen_paths = set()
    generated_files = set()

    for url_path, methods in paths.items():
        if not methods or not isinstance(methods, dict):
            continue

        for method, method_data in methods.items():
            method = method.lower()
            if method not in ["get", "post", "put", "delete", "patch"]:
                continue

            operation_id = method_data.get("operationId")
            if not operation_id:
                print(f"[ERROR] Missing 'operationId' for path '{url_path}' and method '{method}'.")
                sys.exit(1)

                                                  
            if operation_id in operation_ids_registry:
                print(f"[ERROR] Duplicate operationId: {operation_id}")
                sys.exit(1)

            operation_ids_registry.add(operation_id)

            file_name = operation_id.lower()
            view_name = "".join(word.capitalize() for word in operation_id.split("_")) + "View"

                                                        
            django_model = method_data.get("x-django-model")
            django_serializer = method_data.get("x-django-serializer")
            django_lookup_fields = method_data.get("x-django-lookup-fields", ["pk"])

                                               
            param_types = {}
            for param in method_data.get("parameters", []):
                if param.get("in") == "path":
                    p_name = param.get("name")
                    p_type = param.get("schema", {}).get("type", "string")
                    django_type = "int" if p_type in ["int", "integer"] else "str"
                    param_types[p_name] = django_type

            django_path = url_path.lstrip("/")
            for p_name, d_type in param_types.items():
                target_str = f"{{{p_name}}}"
                if target_str not in django_path:
                    print(f"[ERROR] Parameter '{p_name}' defined in options but not found in path '{url_path}'.")
                    sys.exit(1)
                django_path = django_path.replace(target_str, f"<{d_type}:{p_name}>")

                         
            if file_name not in views_map:
                views_map[file_name] = {}
            if view_name not in views_map[file_name]:
                views_map[file_name][view_name] = {
                    "methods": [],
                    "django_model": django_model,
                    "django_serializer": django_serializer,
                    "django_lookup_fields": django_lookup_fields,
                    "url_path": django_path,
                    "operation_id": operation_id
                }

            if method not in views_map[file_name][view_name]["methods"]:
                views_map[file_name][view_name]["methods"].append(method)

                                               
            full_import_path = f"from django_endpoints.views.{file_name} import {view_name}"
            if full_import_path not in imports_sections:
                imports_sections.append(full_import_path)

            if django_path not in seen_paths:
                patterns_sections.append(f"    path('{django_path}', {view_name}.as_view(), name='{operation_id}'),")
                seen_paths.add(django_path)

            generated_files.add(f"{file_name}.py")

    if not views_map:
        print("[ERROR] No valid Django endpoints could be parsed from the schema.")
        sys.exit(1)

    has_changes = False

    # Удаление старых файлов
    if os.path.exists(views_root):
        for item in os.listdir(views_root):
            if item.endswith(".py") and item != "__init__.py":
                if item not in generated_files:
                    os.remove(os.path.join(views_root, item))
                    print(f"[DELETE] view: django_endpoints/views/{item}")
                    has_changes = True

                                   
    for file_name, classes in sorted(views_map.items()):
        view_file_path = os.path.join(views_root, f"{file_name}.py")
        relative_view_path = os.path.relpath(view_file_path, pwd)

        file_classes_code = []
        for view_name, view_data in sorted(classes.items()):
            methods = view_data["methods"]
            django_model = view_data["django_model"]
            django_serializer = view_data["django_serializer"]
            django_lookup_fields = view_data["django_lookup_fields"]

                                                                   
            if not django_model and not django_serializer:
                print(f"[ERROR] Missing both 'x-django-model' and 'x-django-serializer' for operationId '{view_data['operation_id']}'. Both are required for Django views.")
                sys.exit(1)
            elif not django_model:
                print(f"[ERROR] Missing 'x-django-model' for operationId '{view_data['operation_id']}'. This parameter is required for Django views.")
                sys.exit(1)
            elif not django_serializer:
                print(f"[ERROR] Missing 'x-django-serializer' for operationId '{view_data['operation_id']}'. This parameter is required for Django views.")
                sys.exit(1)

                                                                       
            view_template = LIST_VIEW_TEMPLATE                         
            if "get" in methods:
                                                                                                
                if "{" in view_data["url_path"]:                                                          
                    view_template = DETAIL_VIEW_TEMPLATE
                else:
                    view_template = LIST_VIEW_TEMPLATE
            elif "post" in methods:
                view_template = CREATE_VIEW_TEMPLATE
            elif "put" in methods or "patch" in methods:
                view_template = UPDATE_VIEW_TEMPLATE
            elif "delete" in methods:
                view_template = DELETE_VIEW_TEMPLATE

                                                      
            model_parts = django_model.split('.')
            model_module = '.'.join(model_parts[:-1]) if '.' in django_model else 'models'
            model_name = model_parts[-1] if '.' in django_model else django_model

            serializer_parts = django_serializer.split('.')
            serializer_module = '.'.join(serializer_parts[:-1]) if '.' in django_serializer else 'serializers'
            serializer_name = serializer_parts[-1] if '.' in django_serializer else django_serializer

                                     
            view_code = view_template.format(
                view_name=view_name,
                model_module=model_module,
                model_name=model_name,
                serializer_module=serializer_module,
                serializer_name=serializer_name,
                lookup_fields=django_lookup_fields
            )
            file_classes_code.append(view_code)

        final_view_code = "\n\n".join(file_classes_code).strip() + "\n"

        is_changed = True
        if os.path.exists(view_file_path):
            with open(view_file_path, "r", encoding="utf-8") as f:
                if f.read() == final_view_code:
                    is_changed = False

        if is_changed:
            action = "[UPDATE]" if os.path.exists(view_file_path) else "[NEW]"
            with open(view_file_path, "w", encoding="utf-8") as f:
                f.write(final_view_code)
            print(f"{action} view: {relative_view_path}")
            has_changes = True

                    
    imports_sections.sort()
    final_urls_code = URLS_TEMPLATE.format(
        imports_block="\n".join(imports_sections).strip(),
        url_patterns="\n".join(patterns_sections).rstrip()
    )

    relative_urls_path = os.path.relpath(urls_path, pwd)
    is_urls_changed = True
    if os.path.exists(urls_path):
        with open(urls_path, "r", encoding="utf-8") as f:
            if f.read() == final_urls_code:
                is_urls_changed = False

    if is_urls_changed:
        with open(urls_path, "w", encoding="utf-8") as f:
            f.write(final_urls_code)
        print(f"[UPDATE] urls: {relative_urls_path}")
        has_changes = True

    if not has_changes:
        print("[OK] No changes detected.")


if __name__ == "__main__":
    main()
