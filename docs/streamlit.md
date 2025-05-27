[Streamlit](https://github.com/streamlit/streamlit) is a powerful python library for creating interactive web apps.

Features:

- **Simple and Pythonic:** Write beautiful, easy-to-read code.
- **Fast, interactive prototyping:** Let others interact with your data and provide feedback quickly.
- **Live editing:** See your app update instantly as you edit your script.
- **Open-source and free:** Join a vibrant community and contribute to Streamlit's future.

# [Installation](https://github.com/streamlit/streamlit)

Open a terminal and run:

```bash
$ pip install streamlit
$ streamlit hello
```

If this opens the _Streamlit Hello_ app in your browser, you're all set! If not, head over to [their docs](https://docs.streamlit.io/get-started) for specific installs.

The app features a bunch of examples of what you can do with Streamlit. Jump to the [quickstart](#quickstart) section to understand how that all works.

# Usage

## A little example

Create a new file `streamlit_app.py` with the following code:

```python
import streamlit as st
x = st.slider("Select a value")
st.write(x, "squared is", x * x)
```

Now run it to open the app!

```
$ streamlit run streamlit_app.py
```

## Record audio from the microphone

There are many components that are able to do this:

- [streamlit-audiorecorder](https://github.com/theevann/streamlit-audiorecorder)
- [audio-recorder-streamlit](https://github.com/Joooohan/audio-recorder-streamlit)
- [streamlit-mic-recorder](https://github.com/B4PT0R/streamlit-mic-recorder)

I like the first one the most because it has a clean interface and is maintained. I'd use the second if you wanted to automatically stop recording once there is a silence.

### [streamlit-audiorecorder](https://github.com/theevann/streamlit-audiorecorder)

#### Installation

```bash
pip install streamlit-audiorecorder
```

This package uses ffmpeg, so it should be installed for this audiorecorder to work properly.

#### Usage

```python
import streamlit as st
from audiorecorder import audiorecorder

st.title("Audio Recorder")
audio = audiorecorder("Click to record", "Click to stop recording")

if len(audio) > 0:
    # To play audio in frontend:
    st.audio(audio.export().read())

    # To save audio to a file, use pydub export method:
    audio.export("audio.wav", format="wav")

    # To get audio properties, use pydub AudioSegment properties:
    st.write(f"Frame rate: {audio.frame_rate}, Frame width: {audio.frame_width}, Duration: {audio.duration_seconds} seconds")

```

Where the signature of the `audiorecorder` object is:

```python
audiorecorder(start_prompt="Start recording", stop_prompt="Stop recording", pause_prompt="", show_visualizer=True, key=None):
```

- The prompt parameters are self-explanatory.
- The optional `key`` parameter is used internally by Streamlit to properly distinguish multiple audiorecorders on the page.
- The `show_visualizer`` parameter is a boolean that determines whether to show live audio visualization while recording. If set to `False``, the text "recording" is displayed. It is used only when all prompts are empty strings.

## Show a spinner while the data is loading

```python
# Title and description
st.title("Title")

with st.spinner("Loading data..."):
    data = long_process()
st.markdown('content shown once the data is loaded')
```

# [Deploy](https://docs.streamlit.io/deploy/tutorials/docker)

Here's an example `Dockerfile` that you can add to the root of your directory

```dockerfile
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  software-properties-common \
  && rm -rf /var/lib/apt/lists/*

COPY . .

RUN pip3 install -r requirements.txt

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
```

While you debug you may want to replace the `COPY . .` to:

```dockerfile
COPY requirements.txt .

RUN pip3 install -r requirements.txt

COPY app.py .
```

So that the build iterations are faster.

You can build it with `docker build -t streamlit .`, then test it with `docker run -p 8501:8501 streamlit`

Once you know it's working you can create a docker compose

```yaml
services:
  streamlit:
    image: hm2025_nodos
    container_name: my_app
    env_file:
      - .env
    ports:
      - "8501:8501"
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:8501/_stcore/health"]
      interval: 30s
      timeout: 10s
      retries: 5
```

If you use [swag]() from linuxserver you can expose the service with the next nginx configuration:

```nginx
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name my_app.*;

    include /config/nginx/ssl.conf;

    client_max_body_size 0;

    location / {
        # enable the next two lines for http auth
        #auth_basic "Restricted";
        #auth_basic_user_file /config/nginx/.htpasswd;

        # enable the next two lines for ldap auth
        #auth_request /auth;
        #error_page 401 =200 /login;

        include /config/nginx/proxy.conf;
        resolver 127.0.0.11 valid=30s;
        set $upstream_streamlit my_container_name;
        proxy_pass http://$upstream_streamlit:8501;
    }
}
```

And if you save your `docker-compose.yaml` file into `/srv/streamlit` you can use the following systemd service to automatically start it on boot.

```ini
[Unit]
Description=my_app
Requires=docker.service
After=docker.service

[Service]
Restart=always
User=root
Group=docker
WorkingDirectory=/srv/streamlit
# Shutdown container (if running) when unit is started
TimeoutStartSec=100
RestartSec=2s
# Start container when unit is started
ExecStart=/usr/bin/docker compose -f docker-compose.yaml up
# Stop container when unit is stopped
ExecStop=/usr/bin/docker compose -f docker-compose.yaml down

[Install]
WantedBy=multi-user.target
```

# Reference

- [Source](https://github.com/streamlit/streamlit)
- [Docs](https://docs.streamlit.io/)
- [Component list](https://docs.streamlit.io/develop/api-reference)
- [Gallery of applications](https://streamlit.io/gallery)
