# Mobile Keyboards for Privacy-Conscious Users

Finding the right mobile keyboard that balances functionality, privacy, and usability can be challenging. This guide explores the best open-source and privacy-focused keyboard options available for Android devices.

## Quick Recommendations

- **For Gboard users transitioning**: HeliBoard
- **For advanced features and AI**: FUTO Keyboard
- **For unique input method**: Thumb-Key
- **For future consideration**: FlorisBoard (when stable)

## FUTO Keyboard ⭐ Recommended

FUTO represents the cutting edge of privacy-focused keyboard technology, incorporating AI features while maintaining offline functionality.

### What Makes FUTO Special

FUTO stands out with **transformer-based predictions** using llama.cpp and **integrated voice input** powered by whisper.cpp. Unlike other keyboards that require proprietary libraries, FUTO includes swipe/glide typing by default.

The keyboard is currently in pre-alpha, so expect some bugs and missing features. However, the privacy-preserving approach and innovative AI integration make it worth trying.

### Key Features

**Smart Text Prediction**

- Uses pre-trained transformer models for intelligent autocorrect
- Personal language model that learns from your typing (locally only)
- Currently optimized for English, with other languages in development
- Spanish support is still limited

**Privacy-First Design**

- All AI processing happens on-device
- Your data never leaves your phone
- FUTO doesn't view or store any typing data
- Internet access only for updates and crash reporting (planned to be removed)

**Customization Options**

- Multilingual typing support
- Custom keyboard layouts
- Swipe typing works well out of the box

### Current Limitations

- Pre-alpha software with occasional bugs
- Limited language support beyond English
- Uses a custom "Source First" license (not traditional open source)
- Screen movement issues when using swipe typing

### Licensing Concerns

FUTO uses a custom license rather than traditional open source licenses like GPL. While the source code is available, the licensing terms are more restrictive than typical open source projects. The team promises to adopt proper open source licensing eventually, but this transition hasn't happened yet.

**Resources**

- [Official Website](https://keyboard.futo.org/)
- [Documentation](https://docs.keyboard.futo.org/)
- [Source Code](https://gitlab.futo.org/alex/voiceinput)
- [Privacy Analysis](https://privseclaw.info/posts/futokeyboard/)

### Not there yet

- The futo voice has a weird bug at least in spanish that sometimes adds at the end of the transcription phrases like: Subscribe! or Chau or Thanks for watching my video!. This is kind of annoying and scary `(¬º-°)¬`

## HeliBoard - The Reliable Choice

HeliBoard serves as an excellent middle ground, especially for users transitioning from Gboard.

### Why Choose HeliBoard

- **Active development**: Fork of OpenBoard with regular updates
- **No network access**: Completely offline operation
- **User-friendly**: Much simpler than AnySoftKeyboard
- **Gboard-like experience**: Familiar interface for Google Keyboard users

### Trade-offs

The main limitation is glide typing, which requires a closed-source library. This compromises the fully open source nature but provides the swipe functionality many users expect.

**Resources**

- [GitHub Repository](https://github.com/Helium314/HeliBoard)

## Thumb-Key - The Innovative Alternative

For users willing to try something completely different, Thumb-Key offers a unique approach to mobile typing.

### The Thumb-Key Concept

Instead of traditional QWERTY, Thumb-Key uses a **3x3 grid layout** with swipe gestures for less common letters. This design prioritizes:

- Large, predictable key positions
- Muscle memory development
- Eyes staying on the text area
- Fast typing speeds once mastered

### Best For

- Users open to learning new input methods
- Those who prefer larger touch targets
- Privacy enthusiasts who want to avoid predictive text entirely
- People who find traditional keyboards cramped

The keyboard is highly configurable and focuses on accuracy through key positioning rather than AI predictions.

**Resources**

- [GitHub Repository](https://github.com/dessalines/thumb-key)

## FlorisBoard - Future Potential

FlorisBoard shows promise but isn't ready for daily use yet.

### Current Status

- Early beta development
- Planned integration with GrapheneOS
- Missing key features like suggestions and glide typing
- Limited documentation available

### Worth Watching

While not currently recommended for primary use, FlorisBoard could become a strong contender once it reaches stability.

**Resources**

- [GitHub Repository](https://github.com/florisboard/florisboard)
- [Official Website](https://florisboard.org/)

## Alternative Approaches

### Unexpected Keyboard

A minimalist keyboard with a unique layout approach.

**Resources**

- [GitHub Repository](https://github.com/Julow/Unexpected-Keyboard)

### Using Proprietary Keyboards with Restrictions

On privacy-focused ROMs like GrapheneOS and DivestOS, you can use proprietary keyboards while blocking internet access. However, this approach has limitations due to inter-process communication between apps.

**Note**: This method isn't foolproof, as apps can still potentially communicate through IPC mechanisms.

## My Current Setup

After testing various options:

1. **Primary choice**: FUTO Keyboard with swipe enabled
2. **Backup plan**: Try FUTO voice input for longer texts when privacy features improve
3. **Alternative**: Thumb-Key if FUTO doesn't work out

The main issue encountered is screen movement during swipe typing, which may be device-specific.

## References and Further Reading

- [Privacy Guides Discussion on Android Keyboards](https://discuss.privacyguides.net/t/recommend-open-source-android-keyboards/17808/36)
- [FUTO Keyboard Community Discussion](https://discuss.privacyguides.net/t/futo-keyboard/18896)
- [GrapheneOS IPC Communication Issue](https://github.com/GrapheneOS/os-issue-tracker/issues/2810)

