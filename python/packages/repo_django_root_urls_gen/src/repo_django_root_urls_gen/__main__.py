import os
from pathlib import Path

def main():
    root_dir = Path(os.getcwd())
    packages_dir = root_dir / "python/packages"
    output_file = root_dir / "python/packages/django_root_urls_gen/src/django_root_urls_gen/urls.py"

    if not packages_dir.exists():
        print(f"Error: Packages directory not found -> {packages_dir.resolve()}")
        return

    import_lines = []
    router_lines = []

    # Сканируем все папки пакетов, имя которых заканчивается на _views
    for pkg in sorted(packages_dir.iterdir()):
        if not pkg.is_dir() or not pkg.name.endswith("_views"):
            continue

        # Путь к исходному коду внутри пакета: src/{package_name}/views
        views_dir = pkg / "src" / pkg.name / "views"
        if not views_dir.exists():
            continue

        # Находим все python-файлы (исключая __init__.py)
        modules = sorted([
            f.stem for f in views_dir.glob("*.py")
            if f.is_file() and f.name != "__init__.py"
        ])

        for module in modules:
            # Создаем уникальный алиас для роутера, чтобы избежать конфликтов имен
            router_alias = f"{pkg.name}_{module}_router"
            import_lines.append(f"from {pkg.name}.views.{module} import router as {router_alias}")
            router_lines.append(f'api.add_router("", {router_alias})')

    if not import_lines:
        print(f"Warning: No *_views packages or view modules found in {packages_dir}")
        return

    # Подготовка блоков для шаблона
    imports_block = "\n".join(import_lines)
    routers_block = "\n".join(router_lines)

    # Шаблон файла urls.py со всеми импортами наверху
    new_content = f"""# Automatically generated file. Do not edit manually.
import logging
from django.http import JsonResponse
from django.urls import path
from ninja import NinjaAPI
from ninja.errors import HttpError

{imports_block}

api = NinjaAPI()
logger = logging.getLogger(__name__)

{routers_block}

urlpatterns = [
    path("", api.urls),
]
    """
    if not output_file.exists():
        status = "NEW file"
    else:
        with open(output_file, "r", encoding="utf-8") as f:
            old_content = f.read()
        status = "UPDATED file" if old_content != new_content else "NO CHANGES"

    # Запись и вывод лога только при наличии изменений
    if status != "NO CHANGES":
        output_file.parent.mkdir(parents=True, exist_ok=True)
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"[{status}] {output_file.resolve()}")

if __name__ == "__main__":
    main()


"""
api = NinjaAPI()

@api.exception_handler(HttpError)
def custom_http_error_handler(request, exc):
    if exc.status_code == 500:
        logger.error(f"HTTP 500 Error: {{exc.message}}", exc_info=exc)

    return JsonResponse(
        {{"error": exc.message, "status": exc.status_code}},
        status=exc.status_code
    )

@api.exception_handler(Exception)
def global_exception_handler(request, exc):
    logger.error("Internal Server Error occurred", exc_info=exc)

    return JsonResponse(
        {{"error": "Internal Server Error", "status": 500}},
        status=500
    )

{routers_block}
"""
