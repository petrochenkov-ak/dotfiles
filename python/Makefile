all:
	find packages -type d -mindepth 1 -maxdepth 1 -exec python3.14 packages/python_package_pyproject_gen/src/python_package_pyproject_gen {} \;
	find packages -maxdepth 2 -name "pyproject.toml" -print0 | grep -z -v "__pycache__" | xargs -0 -I '{}' sh -c 'python3.14 -m pip install --break-system-packages --no-build-isolation -e "$$(dirname "{}")"'
