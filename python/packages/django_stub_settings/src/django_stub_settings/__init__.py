import os
from pathlib import Path

BASE_DIR = Path(os.getcwd()).resolve()
PACKAGES_DIR = BASE_DIR / "packages"

SECRET_KEY = "fake-mypy-key"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

INSTALLED_APPS = []

if PACKAGES_DIR.is_dir():
    for outer_dir in PACKAGES_DIR.iterdir():
        if not outer_dir.is_dir() or outer_dir.name.startswith("."):
            continue

        inner_dir = outer_dir / outer_dir.name

        if inner_dir.is_dir() and (inner_dir / "__init__.py").exists():
            app_path = f"packages.{outer_dir.name}.{inner_dir.name}"
            INSTALLED_APPS.append(app_path)
