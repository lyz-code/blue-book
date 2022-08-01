---
title: Virtual assistant
date: 20210204
author: Lyz
---

[Virtual assistant](https://en.wikipedia.org/wiki/Virtual_assistant) is
a software agent that can perform tasks or services for an individual based on
commands or questions.

Of the open source solutions [kalliope](https://kalliope-project.github.io/) is
the one I've liked most. I've also looked at
[mycroft](https://github.com/MycroftAI/mycroft-core) but it seems less oriented
to self hosted solutions, although [it's
possible](https://mycroft-ai.gitbook.io/docs/about-mycroft-ai/faq). Mycroft has
a bigger community behind though.

To interact with it I may start with the [android
app](https://play.google.com/store/apps/details?id=kalliope.project), but then
I'll probably install a Raspberry pi zero with [Pirate
Audio](https://shop.pimoroni.com/collections/pirate-audio) and an [akaso
external mic](https://www.akasotech.com/externalmic) in the kitchen to speed up
the [grocy](grocy_management.md) inventory management.

# STT

The only self hosted Speech-To-Text (STT) solution available now is
[CMUSphinx](https://kalliope-project.github.io/kalliope/settings/stt/CMUSphinx/),
which is based on [pocketsphinx](https://github.com/cmusphinx/pocketsphinx) that
has 2.8k stars but last update was on 28th of March of 2020.

The CMUSphinx documentation suggest you to use
[Vosk](https://alphacephei.com/vosk/) based on
[vosk-api](https://github.com/alphacep/vosk-api) with 1.2k stars and last
updated 2 days ago. There is an [open
issue](https://github.com/kalliope-project/kalliope/issues/606) to support it in
kalliope, with already a [french
proposal](https://github.com/veka-server/kalliope-vosk).

That led me to the [issue to support
DeepSpeech](https://github.com/kalliope-project/kalliope/issues/513), [Mozilla's
STT solution](https://github.com/mozilla/DeepSpeech), that has 16.5k stars and
updated 3 days ago, so it would be the way to go in my opinion if the existent
one fails. Right now there is no support, but
[this](https://github.com/mozilla/DeepSpeech-examples/blob/r0.9/mic_vad_streaming/)
would be the place to start. For spanish, based on [the mozilla discourse
thread](https://discourse.mozilla.org/t/links-to-pretrained-models/62688)
I arrived to
[DeepSpeech-Polyglot](https://gitlab.com/Jaco-Assistant/deepspeech-polyglot)
that has taken many datasets such as [Common
Voice](https://commonvoice.mozilla.org/en/datasets) one and generated the
[models](https://drive.google.com/drive/folders/1-3UgQBtzEf8QcH2qc8TJHkUqCBp5BBmO?usp=sharing).
