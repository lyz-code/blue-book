
# [Installation](https://github.com/Uberi/speech_recognition?tab=readme-ov-file)

To use with openai whisper:

```bash
sudo apt-get install portaudio19-dev python-all-dev python3-all-dev
pip install 'SpeechRecognition[whisper-api,audio]'
```

#  Usage
## [Microphone recognition](https://github.com/Uberi/speech_recognition/blob/master/examples/microphone_recognition.py)

```python 
#!/usr/bin/env python3

# NOTE: this example requires PyAudio because it uses the Microphone class

import speech_recognition as sr

# obtain audio from the microphone
r = sr.Recognizer()
with sr.Microphone() as source:
    print("Say something!")
    audio = r.listen(source)
#
# recognize speech using whisper
try:
    print("Whisper thinks you said " + r.recognize_whisper(audio, language="spanish"))
except sr.UnknownValueError:
    print("Whisper could not understand audio")
except sr.RequestError as e:
    print(f"Could not request results from Whisper; {e}")
```

## Recognition from streamlit audiorecorder 

```python
audio = audiorecorder().from_wav("audio.wav")
audio_data = io.BytesIO()
audio.export(audio_data, format="wav")
audio_data.seek(0)  # Go back to the start of the BytesIO object

# Use speech_recognition to recognize the audio
recognizer = sr.Recognizer()

# Load the BytesIO stream as an AudioFile object
with sr.AudioFile(audio_data) as source:
    recognizer.adjust_for_ambient_noise(source)
    audio = recognizer.record(source)
    text = recognizer.recognize_whisper(audio)
```

## Add the initial prompt to the whisper recognition

```python
text = recognizer.recognize_whisper(audio, initial_prompt="your desired words")
```

# References
- [Source](https://github.com/Uberi/speech_recognition?tab=readme-ov-file)
- [Real Python introduction](https://realpython.com/python-speech-recognition/)
