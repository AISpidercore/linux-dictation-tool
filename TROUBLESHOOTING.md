# Troubleshooting Guide - Linux Dictation Tool

## Common Issues and Solutions

### Installation Issues

#### "Git not found" or "Build tools not found"
**Problem**: Essential build tools are missing
**Solution**:
```bash
# Ubuntu/Debian
sudo apt-get install -y git build-essential cmake

# Fedora
sudo dnf install -y git gcc g++ cmake

# Arch
sudo pacman -S git base-devel cmake
```

#### Setup script fails with permission error
**Problem**: Cannot execute setup script
**Solution**:
```bash
chmod +x setup.sh
bash setup.sh
```

#### FFmpeg installation fails
**Problem**: ffmpeg package not found
**Solution**:
```bash
# Ubuntu/Debian
sudo apt-get install -y ffmpeg

# Fedora
sudo dnf install -y ffmpeg

# Arch
sudo pacman -S ffmpeg
```

---

### Audio Recording Issues

#### "No audio input detected"
**Problem**: Microphone not recognized
**Solution**:
1. Check system audio settings
2. List available recording devices:
   ```bash
   pactl list sources
   ```
3. Verify microphone is selected as default input
4. Test with ffmpeg directly:
   ```bash
   ffmpeg -f pulse -i default -t 5 test.wav
   ```
5. Check if microphone is muted in system tray

#### Recording produces silence
**Problem**: Audio recorded but no sound captured
**Solution**:
1. Check input levels: `pavucontrol`
2. Ensure microphone is not muted
3. Try different input device:
   ```bash
   pactl list sources short
   # Note the device ID and modify dictation_tool.sh
   ```
4. Test microphone with other applications (Audacity, Sound Recorder)

#### "Permission denied" when accessing audio
**Problem**: User lacks audio permissions
**Solution**:
```bash
# Add user to audio group
sudo usermod -a -G audio $USER

# Apply new group (logout and login required)
# Or use:
newgrp audio
```

#### ffmpeg "pulse" module not available
**Problem**: PulseAudio support missing
**Solution**:
```bash
# Ubuntu/Debian
sudo apt-get install -y libpulse0 pulseaudio-utils

# Fedora
sudo dnf install -y pulseaudio pulseaudio-libs

# Arch
sudo pacman -S pulseaudio
```

---

### Transcription Issues

#### "Models not found" or "No AI model available"
**Problem**: Whisper models missing or not downloaded
**Solution**:
```bash
# Create models directory
mkdir -p models
cd models

# Download small model (recommended)
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin -O small.en.bin

# Or base model (faster, less accurate)
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin -O base.en.bin
```

#### Transcription very slow (takes several minutes)
**Problem**: Low-end CPU or insufficient RAM
**Solution**:
1. Close unnecessary applications
2. Use smaller model (base.en instead of small.en)
3. Reduce audio duration to 5-10 seconds
4. Monitor resources: `htop`
5. Consider installing on faster machine

#### Transcription is inaccurate or gibberish
**Problem**: Poor audio quality or wrong model
**Solution**:
1. Ensure using small.en model (better accuracy)
2. Speak clearly and slowly
3. Reduce background noise
4. Keep recordings shorter (under 10 seconds)
5. Use a better quality microphone
6. Test with a different audio file

#### "whisper.cpp not found" error
**Problem**: Whisper not built or in wrong location
**Solution**:
```bash
# Rebuild whisper.cpp
cd whisper.cpp
mkdir -p build
cd build
cmake ..
make -j$(nproc)
cd ../..

# Verify build succeeded
ls -la whisper.cpp/build/bin/main
```

---

### Runtime Issues

#### "Command not found: dictation-tool"
**Problem**: Symlink not created or in wrong PATH
**Solution**:
```bash
# Create symlink
sudo ln -s $(pwd)/scripts/dictation_tool.sh /usr/local/bin/dictation-tool

# Or run script directly
./scripts/dictation_tool.sh
```

#### Tool crashes immediately
**Problem**: Missing dependencies or configuration error
**Solution**:
1. Run with error output:
   ```bash
   bash -x scripts/dictation_tool.sh
   ```
2. Check all dependencies installed
3. Verify paths in script are correct
4. Check disk space: `df -h`

#### Text not appearing in active window
**Problem**: xdotool not working or window focus issue
**Solution**:
```bash
# Install xdotool
sudo apt-get install -y xdotool

# Verify xdotool works
xdotool getactivewindow

# Ensure window is focused before running tool
# Some applications (Chrome, Firefox) may block text injection
```

#### Tool stops responding or hangs
**Problem**: Infinite loop or blocked process
**Solution**:
1. Press Ctrl+C to stop
2. Check for running ffmpeg processes: `ps aux | grep ffmpeg`
3. Kill any stuck processes: `killall ffmpeg`
4. Check disk space and memory: `df -h && free -h`

---

### Desktop Launcher Issues

#### Launcher doesn't appear in applications menu
**Problem**: Desktop file not created or invalid
**Solution**:
```bash
# Verify file exists and is valid
cat ~/.local/share/applications/dictation-tool.desktop

# Make executable
chmod +x ~/.local/share/applications/dictation-tool.desktop

# Refresh application cache
update-desktop-database ~/.local/share/applications/
```

#### Launcher opens but doesn't work
**Problem**: Script path not absolute or permissions issue
**Solution**:
1. Edit the .desktop file:
   ```bash
   nano ~/.local/share/applications/dictation-tool.desktop
   ```
2. Ensure `Exec=` has the full absolute path
3. Verify the script is executable: `chmod +x scripts/dictation_tool.sh`

---

### Performance Optimization

#### Improve Speed
1. Use multi-threaded build:
   ```bash
   cd whisper.cpp/build
   make -j$(nproc)
   ```
2. Use base.en model instead of small.en
3. Close background applications
4. Ensure you have at least 4GB free RAM
5. Use SSD if available

#### Reduce Memory Usage
1. Use smaller model (base.en)
2. Keep audio recordings short
3. Close other applications
4. Monitor: `htop`

---

### Still Having Issues?

If the above solutions don't work:

1. **Check GitHub Issues**: https://github.com/AISpidercore/linux-dictation-tool/issues
2. **Provide Debug Output**:
   ```bash
   bash -x scripts/dictation_tool.sh 2>&1 | tee debug.log
   ```
3. **System Information**:
   ```bash
   uname -a
   ffmpeg -version
   ls -la models/
   ```
4. **Contact**: https://www.aispidercore.com

## FAQ

**Q: Does this work offline?**
A: Yes, completely offline after installation. No internet needed.

**Q: Is my audio saved?**
A: No, audio is automatically deleted after transcription.

**Q: Which languages are supported?**
A: Primarily English. Multi-language models available.

**Q: Can I use GPU acceleration?**
A: Currently CPU-only, but GPU support is planned.

**Q: What about accuracy?**
A: Similar to OpenAI's Whisper model - very good for clear speech.
