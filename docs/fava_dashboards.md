# [Fava Dashboards](https://github.com/andreasgerstmayr/fava-dashboards/tree/main)

## Installation

```bash
pip install git+https://github.com/andreasgerstmayr/fava-dashboards.git
```

Enable this plugin in Fava by adding the following lines to your ledger:

```beancount
2010-01-01 custom "fava-extension" "fava_dashboards"
```

Then you'll need to [create a `dashboards.yaml`](#configuration) file where your ledger lives.

## [Configuration](https://github.com/andreasgerstmayr/fava-dashboards/tree/main?tab=readme-ov-file#configuration)
The plugin looks by default for a `dashboards.yaml` file in the directory of the Beancount ledger (e.g. if you run `fava personal.beancount`, the `dashboards.yaml` file should be in the same directory as `personal.beancount`).

The configuration file can contain multiple dashboards, and a dashboard contains one or more panels.
A panel has a relative width (e.g. `50%` for 2 columns, or `33.3%` for 3 column layouts) and a absolute height.

The `queries` field contains one or multiple queries.
The Beancount query must be stored in the `bql` field of the respective query.
It can contain Jinja template syntax to access the `panel` and `ledger` variables described below (example: use `{{ledger.ccy}}` to access the first configured operating currency).
The query results can be accessed via `panel.queries[i].result`, where `i` is the index of the query in the `queries` field.
Note: Additionally to the Beancount query, Fava's filter bar further filters the available entries of the ledger.

Common code for utility functions can be defined in the dashboards configuration file, either inline in `utils.inline` or in an external file defined in `utils.path`.

### Start your configuration

It's best to tweak the example than to start from scratch. Get the example by:
```bash
cd $(mktemp -d)
git clone https://github.com/andreasgerstmayr/fava-dashboards
cd fava-dashboards/example
fava example.beancount
```

### Dashboard prototypes

#### Vertical bars 

##### One serie graphs
###### Vertical bars with one serie using year
```yaml
  - title: Net Year Profit 💰
    width: 50%
    link: /beancount/income_statement/
    queries:
    - bql: |
        SELECT year, sum(position) AS value
        WHERE
            account ~ '^Expenses:' OR
            account ~ '^Income:'
        GROUP BY year

      link: /beancount/balance_sheet/?time={time}
    type: echarts
    script: |
      const currencyFormatter = utils.currencyFormatter(ledger.ccy);
      const years = utils.iterateYears(ledger.dateFirst, ledger.dateLast)
      const amounts = {};

      // the beancount query only returns periods where there was at least one matching transaction, therefore we group by period
      for (let row of panel.queries[0].result) {
        amounts[`${row.year}`] = -row.value[ledger.ccy];
      }

      return {
        tooltip: {
          trigger: "axis",
          valueFormatter: currencyFormatter,
        },
        xAxis: {
          data: years,
        },
        yAxis: {
          axisLabel: {
            formatter: currencyFormatter,
          },
        },
        series: [
          {
            type: "bar",
            data: years.map((year) => amounts[year]),
            color: utils.green,
          },
        ],
      };
```
###### Vertical bars using one serie using quarters


```yaml
  - title: Net Quarter Profit 💰
    width: 50%
    link: /beancount/income_statement/
    queries:
    - bql: |
        SELECT quarter(date) as quarter, sum(position) AS value
        WHERE
            account ~ '^Expenses:' OR
            account ~ '^Income:'
        GROUP BY quarter

      link: /beancount/balance_sheet/?time={time}
    type: echarts
    script: |
      const currencyFormatter = utils.currencyFormatter(ledger.ccy);
      const quarters = utils.iterateQuarters(ledger.dateFirst, ledger.dateLast).map((q) => `${q.year}-${q.quarter}`);
      const amounts = {};

      // the beancount query only returns periods where there was at least one matching transaction, therefore we group by period
      for (let row of panel.queries[0].result) {
        amounts[`${row.quarter}`] = -row.value[ledger.ccy];
      }

      return {
        tooltip: {
          trigger: "axis",
          valueFormatter: currencyFormatter,
        },
        xAxis: {
          data: quarters,
        },
        yAxis: {
          axisLabel: {
            formatter: currencyFormatter,
          },
        },
        series: [
          {
            type: "bar",
            data: quarters.map((quarter) => amounts[quarter]),
          },
        ],
      };
```

##### Many series graphs
###### Vertical bars showing the evolution of one query over the months

```yaml
  - title: Net Year Profit Distribution 💰
    width: 50%
    link: /beancount/income_statement/
    queries:
    - bql: |
        SELECT year, month, sum(position) AS value
        WHERE
            account ~ '^Expenses:' OR
            account ~ '^Income:'
        GROUP BY year, month
      link: /beancount/balance_sheet/?time={time}
    type: echarts
    script: |
      const currencyFormatter = utils.currencyFormatter(ledger.ccy);
      const years = utils.iterateYears(ledger.dateFirst, ledger.dateLast);
      const amounts = {};

      for (let row of panel.queries[0].result) {
        if (!amounts[row.year]) {
          amounts[row.year] = {};
        }
        amounts[row.year][row.month] = -row.value[ledger.ccy];
      }

      return {
        tooltip: {
          valueFormatter: currencyFormatter,
        },
        legend: {
          top: "bottom",
        },
        xAxis: {
          data: ['0','1','2','3','4','5','6','7','8','9','10','11','12'],
        },
        yAxis: {
          axisLabel: {
            formatter: currencyFormatter,
          },
        },
        series: years.map((year) => ({
          type: "bar",
          name: year,
          data: Object.values(amounts[year]),
          label: {
            show: false,
            formatter: (params) => currencyFormatter(params.value),
          },
        })),
      };
```

### Configuration reference
**HTML, echarts and d3-sankey panels:**
The `script` field must contain valid JavaScript code.
It must return a valid configuration depending on the panel `type`.
The following variables and functions are available:
* `ext`: the Fava [`ExtensionContext`](https://github.com/beancount/fava/blob/main/frontend/src/extensions.ts)
* `ext.api.get("query", {bql: "SELECT ..."}`: executes the specified BQL query
* `panel`: the current (augmented) panel definition. The results of the BQL queries can be accessed with `panel.queries[i].result`.
* `ledger.dateFirst`: first date in the current date filter
* `ledger.dateLast`: last date in the current date filter
* `ledger.operatingCurrencies`: configured operating currencies of the ledger
* `ledger.ccy`: shortcut for the first configured operating currency of the ledger
* `ledger.accounts`: declared accounts of the ledger
* `ledger.commodities`: declared commodities of the ledger
* `helpers.urlFor(url)`: add current Fava filter parameters to url
* `utils`: the return value of the `utils` code of the dashboard configuration

**Jinja2 panels:**
The `template` field must contain valid Jinja2 template code.
The following variables are available:
* `panel`: see above
* `ledger`: see above
* `favaledger`: a reference to the `FavaLedger` object

#### Common Panel Properties
* `title`: title of the panel. Default: unset
* `width`: width of the panel. Default: 100%
* `height`: height of the panel. Default: 400px
* `link`: optional link target of the panel header.
* `queries`: a list of dicts with a `bql` attribute.
* `type`: panel type. Must be one of `html`, `echarts`, `d3_sankey` or `jinja2`.

#### HTML panel
The `script` code of HTML panels must return valid HTML.
The HTML code will be rendered in the panel.

#### ECharts panel
The `script` code of [Apache ECharts](https://echarts.apache.org) panels must return valid [Apache ECharts](https://echarts.apache.org) chart options.
Please take a look at the [ECharts examples](https://echarts.apache.org/examples) to get familiar with the available chart types and options.

#### d3-sankey panel
The `script` code of d3-sankey panels must return valid d3-sankey chart options.
Please take a look at the example dashboard configuration [dashboards.yaml](example/dashboards.yaml).

#### Jinja2 panel
The `template` field of Jinja2 panels must contain valid Jinja2 template code.
The rendered template will be shown in the panel.

# Debugging

Add `console.log` strings in the javascript code to debug it.
# References

- [Code](https://github.com/andreasgerstmayr/fava-dashboards/tree/main?tab=readme-ov-file#configuration)
- [Article](https://www.andreasgerstmayr.at/2023/03/12/dashboards-with-beancount-and-fava.html)

## examples

- [Fava Portfolio returns](https://github.com/andreasgerstmayr/fava-portfolio-returns)
- [Fava investor](https://github.com/andreasgerstmayr/fava-portfolio-returns)


[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
