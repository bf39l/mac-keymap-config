#!/bin/bash

# path: $HOME/.config/karabiner/cycle_profile.sh
# chmod +x cycle_profile.sh

# Fail immediately if any command fails
set -e

# Set PATH to include necessary directories
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin"

# Get current profile
current_profile=$(karabiner_cli --show-current-profile-name)

# Get all profiles
profiles=($(karabiner_cli --list-profile-names))

# Find current profile index
for i in "${!profiles[@]}"; do
    if [[ "${profiles[$i]}" == "$current_profile" ]]; then
        current_index=$i
        break
    fi
done

# Get next index (wrap around if at end)
next_index=$(( (current_index + 1) % ${#profiles[@]} ))
next_profile="${profiles[$next_index]}"

# Switch to next profile
karabiner_cli --select-profile "$next_profile"

# Notify user with sound
osascript -e "display notification \"$next_profile\" with title \"Karabiner\" subtitle \"Profile Switch\" sound name \"Purr\""
