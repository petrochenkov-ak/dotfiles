"""
Module for generating root pyproject.toml with git dependencies.
"""

import sys
from pathlib import Path


def generate_repo_toml(packages_dir: Path, root_toml_path: Path) -> None:
    if not packages_dir.exists() or not packages_dir.is_dir():
        print(f"Error: {packages_dir} not found.", file=sys.stderr)
        sys.exit(1)

    package_names: list[str] = []

    for pkg in packages_dir.iterdir():
        if not pkg.is_dir() or pkg.name == "__pycache__":
            continue

        package_names.append(pkg.name)

    repo_url = "git+ssh://git@://github.com"
    git_deps: list[str] = []

    for name in sorted(package_names):
        git_deps.append(
            f'    "{name} @ {repo_url}#subdirectory=python/packages/{name}",\n'
        )

    root_deps_str = "".join(git_deps)
    root_toml_content = f"""[project]
name = "project-sources"
version = "0.0.0"
dependencies = [
{root_deps_str}]
"""
    # Создаем родительские директории для pyproject.toml, если их нет
    root_toml_path.parent.mkdir(parents=True, exist_ok=True)
    root_toml_path.write_text(root_toml_content, encoding="utf-8")


def main():
    packages_dir = Path("./python/packages")
    root_toml_path = Path("./python/pyproject.toml")
    generate_repo_toml(packages_dir, root_toml_path)


if __name__ == "__main__":
    main()
