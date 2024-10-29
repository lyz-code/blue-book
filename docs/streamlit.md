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

# Reference

- [Source](https://github.com/streamlit/streamlit)
- [Docs](https://docs.streamlit.io/)
- [Component list](https://docs.streamlit.io/develop/api-reference)
- [Gallery of applications](https://streamlit.io/gallery)
