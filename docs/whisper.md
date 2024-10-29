
# [Installation](https://pypi.org/project/openai-whisper/)

# Usage

## Extend the whisper with your custom words

There many solutions:

- Tweak the prompt
- Train your own model
- Postprocess the result to match your desired output

### [Tweak the prompt](https://github.com/openai/whisper/discussions/355)

You can use the `--initial-prompt` to add a list of words you want to be detected. For example with python:

```python
model = whisper.load_model("base")
result = model.transcribe("audio.mp3", initial_prompt='Tensorflow pytorch' )
```

Then the model is more keen to detect those keywords

### [Train your own model](https://huggingface.co/blog/fine-tune-whisper)

Follow [this tutorial](https://huggingface.co/blog/fine-tune-whisper)


# Web interfaces
- [Whishper](https://github.com/pluja/whishper?tab=readme-ov-file)
- [Whisper-WebUI](https://github.com/jhj0517/Whisper-WebUI?tab=readme-ov-file)

# Command line tools
- [faster-whisper](https://github.com/SYSTRAN/faster-whisper?tab=readme-ov-file)
- [whisper-ctranslate2](https://github.com/Softcatala/whisper-ctranslate2)
- [whisperX](https://github.com/m-bain/whisperX)
- [whisper-diarization](https://github.com/MahmoudAshraf97/whisper-diarization)
- [wscribe](https://github.com/geekodour/wscribe)
# References
- [Pypi](https://pypi.org/project/openai-whisper/)
