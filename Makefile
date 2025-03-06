.DEFAULT_GOAL := docs

.PHONY: install
install:
	# Until https://github.com/pdm-project/setup-pdm/issues/69  is solved
	pdm self add "dep-logic>=0.4.11"

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

	pdm run mkdocs serve # --strict

	@echo ""

.PHONY: format
format:
	@echo "----------------------"
	@echo "- Running formatters -"
	@echo "----------------------"

	@bash .scripts/footer.sh

	@echo ""

.PHONY: build-docs
build-docs:
	@echo "--------------------------"
	@echo "- Building documentation -"
	@echo "--------------------------"

  # I need to disable --strict this until we fix all the errors shown (too much work)
	# 2024-10-29 issues are fixed but I'd rather not stop the future newsletters for this
	# So I think I should not enable the --strict.
	pdm run mkdocs build

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
