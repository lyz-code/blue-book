# [Install](https://github.com/RocketChat/Rocket.Chat.Electron/releases)

- Download the latest [deb package](https://github.com/RocketChat/Rocket.Chat.Electron/releases)
- `sudo dpkg -i file.deb`

# API

The API docs are a bit weird, you need to go to [endpoints](https://developer.rocket.chat/reference/api/rest-api/endpoints) and find the one you need. Your best bet though is to open the browser network console and see which requests they are doing and then to find them in the docs.


# [Integrations](https://docs.rocket.chat/use-rocket.chat/workspace-administration/integrations)

Rocket.Chat supports webhooks to integrate tools and services you like into the platform. Webhooks are simple event notifications via HTTP POST. This way, any webhook application can post a message to a Rocket.Chat instance and much more.

With scripts, you can point any webhook to Rocket.Chat and process the requests to print customized messages, define the username and avatar of the user of the messages and change the channel for sending messages, or you can cancel the request to prevent undesired messages.

Available integrations:

- Incoming Webhook: Let an external service send a request to Rocket.Chat to be processed.
- Outgoing Webhook: Let Rocket.Chat trigger and optionally send a request to an external service and process the response.

By default, a webhook is designed to post messages only. The message is part of a JSON structure, which has the same format as that of a .

## [Incoming webhook script](https://docs.rocket.chat/use-rocket.chat/workspace-administration/integrations#incoming-webhook-script)

To create a new incoming webhook:

- Navigate to Administration > Workspace > Integrations.
- Click +New at the top right corner.
- Switch to the Incoming tab.
- Turn on the Enabled toggle.
- Name: Enter a name for your webhook. The name is optional; however, providing a name to manage your integrations easily is advisable.
- Post to Channel: Select the channel (or user) where you prefer to receive the alerts. It is possible to override messages.
- Post as: Choose the username that this integration posts as. The user must already exist.
- Alias: Optionally enter a nickname that appears before the username in messages.
- Avatar URL: Enter a link to an image as the avatar URL if you have one. The avatar URL overrides the default avatar.
- Emoji: Enter an emoji optionally to use the emoji as the avatar. [Check the emoji cheat sheet](https://github.com/ikatyang/emoji-cheat-sheet/blob/master/README.md#computer)
- Turn on the Script Enabled toggle.
- Paste your script inside the Script field (check below for a sample script)
- Save the integration.
- Use the generated Webhook URL to post messages to Rocket.Chat.

The Rocket.Chat integration script should be written in ES2015 / ECMAScript 6. The script requires a global class named Script, which is instantiated only once during the first execution and kept in memory. This class contains a method called `process_incoming_request`, which is called by your server each time it receives a new request. The `process_incoming_request` method takes an object as a parameter with the request property and returns an object with a content property containing a valid Rocket.Chat message, or an object with an error property, which is returned as the response to the request in JSON format with a Code 400 status.

A valid Rocket.Chat message must contain a text field that serves as the body of the message. If you redirect the message to a channel other than the one indicated by the webhook token, you can specify a channel field that accepts room id or, if prefixed with "#" or "@", channel name or user, respectively.

You can use the console methods to log information to help debug your script. More information about the console can be found [here](https://developer.mozilla.org/en-US/docs/Web/API/Console/log).
. To view the logs, navigate to Administration > Workspace > View Logs.

```
/* exported Script */
/* globals console, _, s */

/** Global Helpers
 *
 * console - A normal console instance
 * _       - An underscore instance
 * s       - An underscore string instance
 */

class Script {
  /**
   * @params {object} request
   */
  process_incoming_request({ request }) {
    // request.url.hash
    // request.url.search
    // request.url.query
    // request.url.pathname
    // request.url.path
    // request.url_raw
    // request.url_params
    // request.headers
    // request.user._id
    // request.user.name
    // request.user.username
    // request.content_raw
    // request.content

    // console is a global helper to improve debug
    console.log(request.content);

    return {
      content:{
        text: request.content.text,
        icon_emoji: request.content.icon_emoji,
        channel: request.content.channel,
        // "attachments": [{
        //   "color": "#FF0000",
        //   "author_name": "Rocket.Cat",
        //   "author_link": "https://open.rocket.chat/direct/rocket.cat",
        //   "author_icon": "https://open.rocket.chat/avatar/rocket.cat.jpg",
        //   "title": "Rocket.Chat",
        //   "title_link": "https://rocket.chat",
        //   "text": "Rocket.Chat, the best open source chat",
        //   "fields": [{
        //     "title": "Priority",
        //     "value": "High",
        //     "short": false
        //   }],
        //   "image_url": "https://rocket.chat/images/mockup.png",
        //   "thumb_url": "https://rocket.chat/images/mockup.png"
        // }]
       }
    };

    // return {
    //   error: {
    //     success: false,
    //     message: 'Error example'
    //   }
    // };
  }
}
```

To test if your integration works, use curl to make a POST request to the generated webhook URL.

```bash
curl -X POST \
  -H 'Content-Type: application/json' \
  --data '{
      "icon_emoji": ":smirk:",
      "text": "Example message"
  }' \
  https://your-webhook-url
```

If you want to send the message to another channel or user use the `channel` argument with `@user` or `#channel`. Keep in mind that the user of the integration needs to be part of those channels if they are private.

```bash
curl -X POST \
  -H 'Content-Type: application/json' \
  --data '{
      "icon_emoji": ":smirk:",
      "channel": "#notifications",
      "text": "Example message"
  }' \
  https://your-webhook-url
```

If you want to do more complex things uncomment the part of the attachments.

