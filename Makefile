.DEFAULT_GOAL := docs

.PHONY: install
install:
	pdm install

.PHONY: update
update:
	@echo "-------------------------"
	@echo "- Updating dependencies -"
	@echo "-------------------------"

	pdm update --no-sync
	pdm sync --clean

	@echo "\a"

.PHONY: clean
clean:
	@echo "---------------------------"
	@echo "- Cleaning unwanted files -"
	@echo "---------------------------"

	rm -rf `find . -name __pycache__`
	rm -f `find . -type f -name '*.py[co]' `
	rm -f `find . -type f -name '*.rej' `
	rm -rf `find . -type d -name '*.egg-info' `
	rm -f `find . -type f -name '*~' `
	rm -f `find . -type f -name '.*~' `
	rm -rf .cache
	rm -rf .pytest_cache
	rm -rf .mypy_cache
	rm -rf htmlcov
	rm -f .coverage
	rm -f .coverage.*
	rm -rf build
	rm -rf dist
	rm -f src/*.c pydantic/*.so
	rm -rf site
	rm -rf docs/_build
	rm -rf docs/.changelog.md docs/.version.md docs/.tmp_schema_mappings.html
	rm -rf codecov.sh
	rm -rf coverage.xml

	@echo ""

.PHONY: docs
docs:
	@echo "-------------------------"
	@echo "- Serving documentation -"
	@echo "-------------------------"

	pdm run mkdocs serve

	@echo ""

.PHONY: build-docs
build-docs:
	@echo "--------------------------"
	@echo "- Building documentation -"
	@echo "--------------------------"

	pdm run mkdocs build --strict

	@echo "\a"

# We can't build --strict because the newsletters are not yet added to the git index,
# and the --strict fails.
.PHONY: build-newsletters
build-newsletters:
	@echo "--------------------------"
	@echo "- Building newsletters -"
	@echo "--------------------------"

	pdm run mkdocs build

	@echo ""
