# Usage Guide - Linux Dictation Tool

## Quick Start

After installation, you can run the dictation tool in several ways:

### Method 1: Using the Command (Recommended)
```bash
dictation-tool
```

### Method 2: Using the Script Directly
```bash
./scripts/dictation_tool.sh
```

### Method 3: Using the Desktop Launcher
Click the "Linux Dictation Tool" icon in your applications menu.

## How to Use

1. **Run the tool** using one of the methods above
2. **Speak clearly** when prompted - you have up to 10 seconds
3. **Stop speaking** or press Ctrl+C to finish recording
4. **Wait for transcription** - the tool will process your audio
5. **Text appears** in your active window automatically

## Features

### Offline Processing
- All speech-to-text processing happens on your machine
- No cloud connectivity required
- Your audio is never sent anywhere
- Completely private and secure

### Multiple Models
The tool comes with different accuracy levels:
- **small.en** (500MB) - Good accuracy, faster
- **base.en** (140MB) - Basic accuracy, very fast

The tool automatically uses whichever model is available, prioritizing small.en for better accuracy.

### Customizable Audio Recording
Edit `scripts/dictation_tool.sh` to adjust:
- Recording duration (default: 10 seconds)
- Audio quality settings
- Input device selection

## Advanced Usage

### Select Alternative Audio Device

List available audio devices:
```bash
pactl list sources short
```

Modify the recording line in `dictation_tool.sh`:
```bash
ffmpeg -f pulse -i <device_id> -t 10 -q:a 9 -acodec libmp3lame "$AUDIO_FILE"
```

### Using Different Whisper Models

Download additional models:
```bash
cd models
# Base model (140MB)
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin -O base.en.bin

# Small model (500MB)
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin -O small.en.bin

# Medium model (1.5GB)
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en.bin -O medium.en.bin
```

### Adjusting Recording Length

Edit `scripts/dictation_tool.sh` and change the `-t 10` parameter:
```bash
ffmpeg -f pulse -i default -t 30 -q:a 9 -acodec libmp3lame "$AUDIO_FILE"
```
This example changes recording time to 30 seconds.

## Tips & Tricks

### For Best Results
- Speak clearly and at normal volume
- Minimize background noise
- Use a good quality microphone
- Keep recordings under 30 seconds for faster processing
- Avoid heavy accents or mumbling

### Keyboard Shortcuts
- **Ctrl+C** - Stop recording/cancel
- **Enter** - Type the transcribed text (if using interactive mode)

### Batch Processing

To transcribe multiple audio files:
```bash
for file in *.wav; do
    /path/to/whisper.cpp/build/bin/main -m models/small.en.bin -f "$file"
done
```

## Performance Notes

### Processing Speed
- **small.en model**: ~5-10 seconds per 10 seconds of audio (depends on CPU)
- **base.en model**: ~2-3 seconds per 10 seconds of audio (faster, less accurate)
- Actual speed depends on your CPU. Multi-core processors are much faster.

### Memory Usage
- **Typical**: 500MB - 1GB RAM during processing
- **Peak**: Can use up to 2GB for longer audio files
- Ensure you have adequate RAM available

## Troubleshooting

### "Permission denied" when running
```bash
chmod +x scripts/dictation_tool.sh
chmod +x setup.sh
```

### Tool seems slow
- Check CPU usage: `top` or `htop`
- Try the smaller base.en model
- Close unnecessary applications to free RAM
- Use an SSD for faster processing

### Transcription is inaccurate
- Ensure you're using the small.en model (better accuracy)
- Speak more clearly and slowly
- Reduce background noise
- Keep recordings under 10 seconds for best results

### Audio not being recorded
- Check microphone: `pactl list sources`
- Test recording manually: `ffmpeg -f pulse -i default -t 5 test.wav`
- Verify audio input in system settings

## Configuration Files

Edit `scripts/dictation_tool.sh` to customize:
- `AUDIO_FILE` - Temporary audio file location
- Recording parameters in `record_audio()` function
- Model selection in `transcribe_audio()` function
- Text input method in `type_text()` function

## For More Help

- GitHub Issues: https://github.com/AISpidercore/linux-dictation-tool/issues
- Website: https://www.aispidercore.com
- Whisper.cpp: https://github.com/ggerganov/whisper.cpp
