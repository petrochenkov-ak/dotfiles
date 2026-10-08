"""
Module for generating pyproject.toml for individual subpackages.
"""

import sys
from pathlib import Path


def generate_package_toml(package_dir: Path) -> None:
    if not package_dir.is_dir():
        print(f"Error: {package_dir} is not a directory.", file=sys.stderr)
        return

    req_file = package_dir / "requirements.txt"
    deps: list[str] = []

    if req_file.exists():
        with open(req_file, "r") as f:
            deps = [
                line.strip()
                for line in f
                if line.strip() and not line.strip().startswith(("#", "-"))
            ]

    deps_str = "".join([f'    "{d}",\n' for d in deps])
    toml_content = f"""[build-system]
requires = ["setuptools>=61.0.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "{package_dir.name}"
version = "0.1.0"
requires-python = ">=3.10"
dependencies = [
{deps_str}]

[tool.setuptools]
package-dir = {{"" = "src"}}

[tool.setuptools.packages.find]
where = ["src"]
"""
    (package_dir / "pyproject.toml").write_text(toml_content)


def main():
    if len(sys.argv) < 2:
        print("Usage: python django_pyproject_gen.py <package_dir>", file=sys.stderr)
        sys.exit(1)

    package_dir = Path(sys.argv[1])
    generate_package_toml(package_dir)


if __name__ == "__main__":
    main()
