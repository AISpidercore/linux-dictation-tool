#!/bin/bash

# Function to check for root privileges
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Please enter your sudo password.";
        exit 1;
    fi
}

# Function to check the OS
check_os() {
    if [[ -n "$(cat /etc/os-release | grep 'ID=ubuntu')" ]] || \
       [[ -n "$(cat /etc/os-release | grep 'ID=debian')" ]] || \
       [[ -n "$(cat /etc/os-release | grep 'ID=linuxmint')" ]]; then
        echo "OS check passed."
    else
        echo "This script is meant for Ubuntu, Debian, or Mint."
        exit 1;
    fi
}

# Function to install dependencies
install_dependencies() {
    echo "Installing dependencies..."
    apt-get update
    apt-get install -y git build-essential cmake ffmpeg wget xdotool
    echo "Dependencies installed."
}

# Function to clone or navigate to whisper.cpp
setup_whisper() {
    if [ ! -d "whisper.cpp" ]; then
        echo "Cloning whisper.cpp..."
        git clone https://github.com/ggerganov/whisper.cpp
    else
        echo "Navigating to existing whisper.cpp directory."
    fi
    cd whisper.cpp
}

# Function to build whisper.cpp
build_whisper() {
    echo "Building whisper.cpp..."
    mkdir build && cd build
    cmake ..
    make
    echo "whisper.cpp built successfully."
}

# Function to download models
download_models() {
    echo "Downloading models..."
    wget https://huggingface.co/whisper/large-en/raw/main/small.en
    wget https://huggingface.co/whisper/large-en/raw/main/base.en
    echo "Models downloaded."
}

# Function to create voicebot directory
setup_voicebot_directory() {
    echo "Creating voicebot directory..."
    mkdir -p ~/voicebot
}

# Function to copy the dictation script
copy_dictation_script() {
    echo "Copying dictation script..."
    cp ~/path/to/your/dictation_script.sh ~/voicebot/dictation_script.sh
}

# Function to create desktop launcher
create_desktop_launcher() {
    echo "Creating desktop launcher..."
    username=$(whoami)
    echo "[Desktop Entry]" > /home/$username/Desktop/VoiceBot.desktop
    echo "Type=Application" >> /home/$username/Desktop/VoiceBot.desktop
    echo "Name=VoiceBot" >> /home/$username/Desktop/VoiceBot.desktop
    echo "Exec=~/voicebot/dictation_script.sh" >> /home/$username/Desktop/VoiceBot.desktop
    echo "Terminal=false" >> /home/$username/Desktop/VoiceBot.desktop
    chmod +x /home/$username/Desktop/VoiceBot.desktop
}

# Main script execution
check_root
check_os
install_dependencies
setup_whisper
build_whisper
download_models
setup_voicebot_directory
copy_dictation_script
create_desktop_launcher

echo "Installation completed successfully!"