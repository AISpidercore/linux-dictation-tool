#!/bin/bash

# Toggle dictation mode safely

# Check if the dictation process is running
if pgrep -x "dictation_process_name" > /dev/null; then
    # If it is running, kill the process
    killall dictation_process_name
    echo "Dictation stopped."
else
    # If not running, start the process
    dictation_process_name &
    echo "Dictation started."
fi