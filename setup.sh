#!/bin/bash

# Linux Dictation Tool - Setup Script
# Fully offline voice-to-text dictation for Linux using whisper.cpp

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for output
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Function to check for root privileges (not required, but warned if needed)
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_warn "Some commands may require sudo. You will be prompted for your password if needed."
    fi
}

# Function to check the OS
check_os() {
    log_step "Checking operating system..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint)
                log_info "Detected: $NAME"
                ;;
            fedora)
                log_info "Detected: $NAME"
                ;;
            arch)
                log_info "Detected: $NAME"
                ;;
            *)
                log_error "Unsupported OS: $NAME"
                log_info "This tool is designed for Ubuntu, Debian, Mint, Fedora, or Arch Linux"
                exit 1
                ;;
        esac
    else
        log_error "Cannot determine OS"
        exit 1
    fi
}

# Function to install dependencies
install_dependencies() {
    log_step "Installing dependencies..."
    
    if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]] || [[ "$ID" == "linuxmint" ]]; then
        log_info "Using apt package manager"
        sudo apt-get update
        sudo apt-get install -y git build-essential cmake ffmpeg wget xdotool pulseaudio-utils alsa-utils
    elif [[ "$ID" == "fedora" ]]; then
        log_info "Using dnf package manager"
        sudo dnf install -y git gcc g++ cmake ffmpeg wget xdotool pulseaudio-utils alsa-utils
    elif [[ "$ID" == "arch" ]]; then
        log_info "Using pacman package manager"
        sudo pacman -Syu --noconfirm git base-devel cmake ffmpeg wget xdotool pulseaudio
    fi
    
    log_info "Dependencies installed successfully"
}

# Function to clone or navigate to whisper.cpp
setup_whisper() {
    log_step "Setting up whisper.cpp..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local whisper_dir="$script_dir/whisper.cpp"
    
    if [ ! -d "$whisper_dir" ]; then
        log_info "Cloning whisper.cpp repository..."
        cd "$script_dir"
        git clone https://github.com/ggerganov/whisper.cpp.git
        log_info "whisper.cpp cloned successfully"
    else
        log_info "whisper.cpp already exists"
    fi
    
    cd "$whisper_dir"
}

# Function to build whisper.cpp
build_whisper() {
    log_step "Building whisper.cpp..."
    
    if [ ! -d "build" ]; then
        mkdir build
    fi
    
    cd build
    
    if [ ! -f "CMakeCache.txt" ]; then
        cmake ..
    fi
    
    make -j$(nproc)
    log_info "whisper.cpp built successfully"
}

# Function to download models
download_models() {
    log_step "Downloading whisper models..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local model_dir="$script_dir/whisper.cpp/models"
    
    mkdir -p "$model_dir"
    cd "$model_dir"
    
    # Download small model if not present
    if [ ! -f "ggml-small.en.bin" ]; then
        log_info "Downloading small.en model (~500MB)..."
        wget -q --show-progress https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin -O ggml-small.en.bin
        log_info "small.en model downloaded"
    else
        log_info "small.en model already exists"
    fi
    
    # Download base model if not present
    if [ ! -f "ggml-base.en.bin" ]; then
        log_info "Downloading base.en model (~140MB)..."
        wget -q --show-progress https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin -O ggml-base.en.bin
        log_info "base.en model downloaded"
    else
        log_info "base.en model already exists"
    fi
}

# Function to make dictation script executable
make_scripts_executable() {
    log_step "Making scripts executable..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    chmod +x "$script_dir/scripts/dictation_tool.sh" 2>/dev/null || true
    
    log_info "Scripts are now executable"
}

# Function to create symlink for easy access
create_symlink() {
    log_step "Creating command shortcut..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local symlink_path="/usr/local/bin/dictation-tool"
    
    if [ -L "$symlink_path" ] || [ -f "$symlink_path" ]; then
        sudo rm "$symlink_path"
    fi
    
    sudo ln -s "$script_dir/scripts/dictation_tool.sh" "$symlink_path"
    
    log_info "Created command: dictation-tool"
}

# Function to create desktop launcher
create_desktop_launcher() {
    log_step "Creating desktop launcher..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local desktop_file="$HOME/.local/share/applications/dictation-tool.desktop"
    
    mkdir -p "$HOME/.local/share/applications"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Type=Application
Name=Linux Dictation Tool
Comment=Offline voice-to-text dictation
Exec=$script_dir/scripts/dictation_tool.sh
Icon=audio-input-microphone
Categories=Accessibility;Utility;
Terminal=true
EOF
    
    chmod +x "$desktop_file"
    log_info "Desktop launcher created at ~/.local/share/applications/dictation-tool.desktop"
}

# Function to display post-installation instructions
post_install_info() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    log_info "Quick Start:"
    echo "  Run the dictation tool with:"
    echo "    dictation-tool"
    echo ""
    log_info "Or run the script directly:"
    echo "    $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/dictation_tool.sh"
    echo ""
    log_info "For more information, visit: https://www.aispidercore.com"
    echo ""
}

# Main script execution
main() {
    log_info "Starting Linux Dictation Tool setup..."
    echo ""
    
    check_root
    check_os
    install_dependencies
    setup_whisper
    build_whisper
    download_models
    make_scripts_executable
    create_symlink
    create_desktop_launcher
    
    post_install_info
}

# Run main function
main "$@"
