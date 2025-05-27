# Usage

## Marked true

If you are a forms admin you can mark the answers which can be used to for example state that those have been checked and are not trolls, the user can then edit the answers through the magic link but it's not very probable that it becomes a trollo

## Send edit email

If you want the users to receive an email with the magic link so that they can edit their answers you need to add a "Short text" field of type "Email" and then in the Options you need to enable the setting to send the users the magic link

## Extract the results through API

Each form at the bottom of the Options tab has a section of API endpoints, once enabled you can extract them with curl:

```bash
BASE_URL=https://forms.komun.org
form_id=478
curl -sqH "Authorization: Bearer ${JWT_TOKEN}" "${BASE_URL}/api/form/${form_id}/answers"
```

That will give you an answer similar to:

```json
{
  "answers": [
    {
      "created": "2025-04-25T15:05:02.384121",
      "data": {
        "radio-group-1712945984567": "Hitzaldia--Charla--Xerrada",
        "radio-group-1713092876455": "55",
        "radio-group-1713373271313": "Castellano_1",
        "radio-group-1713382758036": "Si_1",
        "radio-group-1744968040362-0": "d8b35c755d9d41e2a844a344ae2494d6",
        "text-1712945594310": "Historia de la criptograf\u00eda",
        "text-1712945631444": "",
        "text-1712945663611": "user",
        "text-1712947404812": "user@sindominio.net",
        "text-1744967213162-0": "Divulgativa",
        "text-1744967571620-0": "Ninguno",
        "textarea-1712945646944": "Aproximaci\u00f3n hist\u00f3rica a la criptograf\u00eda, desde la Antig\u00fcedad a d\u00eda de hoy",
        "textarea-1712945755946": "",
        "textarea-1712945806547": "HDMI",
        "textarea-1712945865865": "Privacidad, criptograf\u00eda, matem\u00e1ticas, historia",
        "textarea-1713380502724": ""
      },
      "form": 478,
      "id": 36148,
      "marked": false
    }
  ],
  "meta": {}
}
```

As you can see the fields have weird names, to get the details of each field you can do the same request but to `${BASE_URL}/api/form/${form_id}` instead of `${BASE_URL}/api/form/${form_id}/answers`

```json
{
  "form": {
    "created": "2025-04-25T11:45:43.633038",
    "introduction_md": "# Call4Nodes Hackmeeting 2025",
    "slug": "call4nodes-hackmeeting-2025-cas",
    "structure": [
      {
        "className": "form-control",
        "label": "T\u00edtulo",
        "name": "text-1712945594310",
        "required": true,
        "subtype": "text",
        "type": "text"
      },
      {
        "className": "form-control",
        "label": "Descripci\u00f3n",
        "name": "textarea-1712945646944",
        "required": true,
        "type": "textarea"
      },
      ...
```
