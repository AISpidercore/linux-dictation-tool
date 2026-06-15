#!/bin/bash

# Linux Dictation Tool
# A fully offline voice-to-text dictation tool using whisper.cpp

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
WHISPER_DIR="${PARENT_DIR}/whisper.cpp"
VOICEBOT_DIR="${HOME}/.voicebot"
MODEL_DIR="${VOICEBOT_DIR}/models"
AUDIO_FILE="${VOICEBOT_DIR}/audio_temp.wav"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Function to check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_deps=()
    
    for cmd in ffmpeg xdotool; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Install with: sudo apt install -y ${missing_deps[*]}"
        exit 1
    fi
    
    log_info "All dependencies satisfied."
}

# Function to initialize voicebot directory
init_voicebot_dir() {
    log_info "Initializing voicebot directory..."
    mkdir -p "$MODEL_DIR"
}

# Function to record audio using system audio input
record_audio() {
    log_info "Recording audio (speak now)... Press Ctrl+C to stop"
    
    arecord -f cd -t wav -d 10 "$AUDIO_FILE" 2>/dev/null || true
    
    if [ ! -f "$AUDIO_FILE" ]; then
        log_error "Failed to record audio"
        exit 1
    fi
    
    log_info "Audio recorded successfully"
}

# Function to convert audio to correct format
convert_audio() {
    local input_file="$1"
    local output_file="$2"
    
    ffmpeg -y -i "$input_file" -ar 16000 -ac 1 -c:a pcm_s16le "$output_file" >/dev/null 2>&1
    
    if [ ! -f "$output_file" ]; then
        log_error "Failed to convert audio"
        exit 1
    fi
}

# Function to transcribe audio using whisper.cpp
transcribe_audio() {
    log_info "Transcribing audio..."
    
    if [ ! -d "$WHISPER_DIR" ]; then
        log_error "whisper.cpp not found at $WHISPER_DIR"
        log_info "Please run setup.sh first"
        exit 1
    fi
    
    # Determine which model to use
    local model_file=""
    if [ -f "$WHISPER_DIR/models/ggml-small.en.bin" ]; then
        model_file="$WHISPER_DIR/models/ggml-small.en.bin"
    elif [ -f "$WHISPER_DIR/models/ggml-base.en.bin" ]; then
        model_file="$WHISPER_DIR/models/ggml-base.en.bin"
    else
        log_error "No model found. Please run setup.sh first"
        exit 1
    fi
    
    # Run whisper transcription
    local result=$( "$WHISPER_DIR/build/bin/main" -m "$model_file" -f "$1" 2>/dev/null | grep -oP '(?<=]  ).*' | head -1)
    
    if [ -z "$result" ]; then
        log_error "Transcription failed"
        exit 1
    fi
    
    echo "$result"
}

# Function to type out the transcribed text
type_text() {
    local text="$1"
    log_info "Typing text: $text"
    
    # Use xdotool to type the text
    xdotool type "$text"
    
    log_info "Text typed successfully"
}

# Function to cleanup temporary files
cleanup() {
    if [ -f "$AUDIO_FILE" ]; then
        rm -f "$AUDIO_FILE"
    fi
    if [ -f "/tmp/audio_converted.wav" ]; then
        rm -f "/tmp/audio_converted.wav"
    fi
}

# Main execution
main() {
    check_dependencies
    init_voicebot_dir
    
    log_info "Starting dictation tool..."
    record_audio
    
    # Convert audio to correct format
    convert_audio "$AUDIO_FILE" "/tmp/audio_converted.wav"
    
    local transcribed_text=$(transcribe_audio "/tmp/audio_converted.wav")
    type_text "$transcribed_text"
    
    cleanup
    
    log_info "Dictation complete!"
}

# Trap to cleanup on exit
trap cleanup EXIT

# Run main function
main
