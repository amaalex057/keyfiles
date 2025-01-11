#!/bin/bash

GIT_REPO_URL="https://raw.githubusercontent.com/amaalex057/keyfiles/"

# Define the file containing the authorized keys
authorized_keys_file="$HOME/.ssh/authorized_keys"

# Ensure the authorized_keys file exists
touch "$authorized_keys_file"
chmod 600 "$authorized_keys_file"

# Fetch the list of keys from the GitHub repository
key_files=$(curl -s "$GIT_REPO_URL" | jq -r '.[].download_url')

# Iterate through the list of keys
for key_url in $key_files; do
    key_name=$(basename "$key_url")
    
    # Check if the key already exists in the authorized_keys file
    if grep -q "$(curl -s "$key_url")" "$authorized_keys_file"; then
        echo "Key $key_name already exists in $authorized_keys_file. Skipping."
    else
        echo "Adding key $key_name to $authorized_keys_file."
        # Download the key and append it to authorized_keys
        curl -s "$key_url" >> "$authorized_keys_file"
    fi

done

# Ensure proper permissions on the authorized_keys file
chmod 600 "$authorized_keys_file"

# Notify user of completion
echo "All keys have been processed."
