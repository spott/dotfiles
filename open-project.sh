#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Project
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Placeholder" }

# Documentation:
# @raycast.description Opens a new kitty window for a project
# @raycast.author Andrew Spott

/Users/spott/Applications/Home\ Manager\ Apps/kitty.app/Contents/MacOS/kitten @ launch --title BookmarkLLM --cwd ~/code/$1 --to unix:/tmp/mykitty-19971 --type os-window
