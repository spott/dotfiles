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

#socket=$(find /tmp -type f -name 'mykitty*' -exec realpath {} \;)
socket=$(/etc/profiles/per-user/spott/bin/find /tmp/ -type s -name 'mykitty*' -exec realpath {} \;)

/Users/spott/Applications/Home\ Manager\ Apps/kitty.app/Contents/MacOS/kitten @ launch --cwd ~/code/$1 --to unix:"$socket" --type os-window
