[Camelot](https://camelot-py.readthedocs.io/en/master/) is a Python library that can help you extract tables from PDFs

```python
import camelot

tables = camelot.read_pdf('foo.pdf')

tables
<TableList n=1>

tables.export('foo.csv', f='csv', compress=True) # json, excel, html, markdown, sqlite

tables[0]
<Table shape=(7, 7)>

tables[0].parsing_report
{
    'accuracy': 99.02,
    'whitespace': 12.24,
    'order': 1,
    'page': 1
}

tables[0].to_csv('foo.csv') # to_json, to_excel, to_html, to_markdown, to_sqlite

tables[0].df # get a pandas DataFrame!
```

# [Installation](https://camelot-py.readthedocs.io/en/master/user/install.html#install)

To install Camelot from PyPI using pip, please include the extra cv requirement as shown:

$ pip install "camelot-py[base]"

It requires Ghostscript to be able to use the `lattice` mode. Which is better than using `tabular-py` that requires java to be installed.

# Usage

## [Process background lines](https://camelot-py.readthedocs.io/en/master/user/advanced.html#process-background-lines)

To detect line segments, Lattice needs the lines that make the table to be in the foreground. 
To process background lines, you can pass process_background=True.

tables = camelot.read_pdf('background_lines.pdf', process_background=True)

tables[1].df
# References
- [Docs](https://camelot-py.readthedocs.io/en/master/index.html)
