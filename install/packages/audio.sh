#!/bin/bash
# Deadcode - Audio System Installation
# Installs pulseaudio and audio utilities

install_audio() {
    header "Installing audio system"
    install_from_list "${DEADCODE_PATH}/packages/audio.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_audio
fi
