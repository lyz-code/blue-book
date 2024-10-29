Renfe hay veces que tarda mucho tiempo en sacar los billetes y es un peñazo tener que meterte continuamente para ver si ya han salido, así que lo he automatizado.

# Instalación
## Script
Si quieres utilizarlo tendrás que al menos toquetear las siguientes líneas:

- Donde se definen los correos (`@example.org`)
- Las fechas del viaje: Busca el string `1727992800000` y puedes crear el tuyo con un comando como: `echo $(date -d "2024-10-04" +%s)000`
- La configuración del apprise (`mailtos`)
- El texto a meter en el origen (`#origin`) y el destino (`#destination`)
- El mes en el que quieres viajar (`octubre2024`)

Puede que en algún momento tenga ganas de hacerlo un poco más usable.

```python
import time
import logging
import traceback
from typing import List
import apprise
from playwright.sync_api import sync_playwright


class LogfmtFormatter(logging.Formatter):
    """Custom formatter to output logs in logfmt style."""

    def format(self, record: logging.LogRecord) -> str:
        log_message = (
            f"level={record.levelname.lower()} "
            f"logger={record.name} "
            f'msg="{record.getMessage()}"'
        )
        return log_message


def setup_logging() -> None:
    """Configure logging to use logfmt format."""
    # Create a console handler
    console_handler = logging.StreamHandler()

    # Create a LogfmtFormatter instance
    logfmt_formatter = LogfmtFormatter()

    # Set the formatter for the handler
    console_handler.setFormatter(logfmt_formatter)

    # Get the root logger and set the level
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)
    logger.addHandler(console_handler)


def send_email(
    title: str, body: str, recipients: List[str] = ["admin@example.org"]
) -> None:
    """
    Sends an email notification using Apprise if the specified text is not found.
    """
    apobj = apprise.Apprise()
    apobj.add(
        "mailtos://{user}:{password}@{domain}:587?smtp={smtp_server}&to={','.join(recipients)}"
    )
    apobj.notify(
        body=body,
        title=title,
    )
    log.info("Email notification sent")


def check_if_trenes() -> None:
    """
    Main function to automate browser interactions and check for specific text.
    """
    log.info("Arrancando el navegador")
    pw = sync_playwright().start()
    chrome = pw.chromium.launch(headless=True)
    context = chrome.new_context(viewport={"width": 1920, "height": 1080})
    page = context.new_page()

    log.info("Navigating to https://www.renfe.com/es/es")
    page.goto("https://www.renfe.com/es/es")
    page.click("#onetrust-reject-all-handler")
    page.click("#origin")
    page.fill("#origin", "Almudena")
    page.click("#awesomplete_list_1_item_0")

    page.click("#destination")
    page.fill("#destination", "Vigo")
    page.click("#awesomplete_list_2_item_0")
    page.evaluate("document.getElementById('first-input').click()")

    while True:
        months = page.locator(
            "div.lightpick__month-title span.rf-daterange-alternative__month-label"
        ).all_text_contents()
        if months[0] == "octubre2024":
            break

        page.click("button.lightpick__next-action")

    # Para sacar otras fechas  usa echo $(date -d "2024-10-04" +%s)000
    page.locator('div.lightpick__day[data-time="1727992800000"]').click()
    page.locator('div.lightpick__day[data-time="1728165600000"]').click()
    page.click("button.lightpick__apply-action-sub")
    page.evaluate("window.scrollTo(0, 0);")
    page.locator('button[title="Buscar billete"]').click()
    page.locator("div#trayectoiSinTren p").wait_for(state="visible")

    time.sleep(1)
    no_hay_trenes = page.locator(
        "div", has_text="No hay trenes para los criterios seleccionados"
    ).all_text_contents()

    if len(no_hay_trenes) != 5:
        send_email(
            title="Puede que haya trenes para vigo",
            body="Corred insensatos!",
            recipients=["user1@example.org", "user2@example.org"],
        )
        log.warning("Puede que haya trenes")
    else:
        log.info("Sigue sin haber trenes")


def main():
    setup_logging()
    global log
    log = logging.getLogger(__name__)
    try:
        check_if_trenes()
    except Exception as error:
        error_message = "".join(
            traceback.format_exception(None, error, error.__traceback__)
        )
        send_email(title="[ERROR] Corriendo el script de renfe", body=error_message)
        raise error


if __name__ == "__main__":
    main()
```

## Cron

Crea un virtualenv e instala las dependencias

```bash
cd renfe
virtualenv .env
pip install apprise playwright
```

Instala los navegadores

```bash
playwright install chromium
```

Crea el script para el cron (`renfe.sh`)

```bash
#!/bin/bash

source /home/lyz/renfe/.env/bin/activate

systemd-cat -t renfe python3 /home/lyz/renfe/renfe.py

deactivate
```

Y edita el cron:

```cron
13 */6 * * * /bin/bash /home/lyz/renfe/renfe.sh
```

Esto lo correrá cada 6 horas

## Monitorización 

Para asegurarnos de que todo está funcionando bien puedes usar las siguientes alertas de [loki](loki.md)

```yaml
groups: 
  - name: cronjobs
    rules:
      - alert: RenfeCronDidntRun
        expr: |
          (count_over_time({job="systemd-journal", syslog_identifier="renfe"} |= `Sigue sin haber trenes` [24h]) or on() vector(0)) == 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "El checkeo de los trenes de renfe no ha terminado en las últimas 24h en {{ $labels.hostname}}"
      - alert: RenfeCronError
        expr: |
          count(rate({job="systemd-journal", syslog_identifier="renfe"} | logfmt | level != `info` [5m])) or vector(0)
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "Se han detectado errores en los logs del script {{ $labels.hostname}}"

```
