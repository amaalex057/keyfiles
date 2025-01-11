#!/bin/bash

# Define the URL for the public git repo where the SSH keys ar stored
GIT_REPO_URL="https://api.github.com/repos/amaalex057/keyfiles/contents/.keys"

# Define the file containing the authorized keys
authorized_keys_file="$HOME/.ssh/authorized_keys"

# Ensure the authorized_keys file exists
touch "$authorized_keys_file"
chmod 600 "$authorized_keys_file"

# Fetch the list of SSH key files from the GitHub repository
key_urls=$(curl -s "$GIT_REPO_URL" | jq -r '.[] | select(.name | endswith(".pub")) | .download_url')

# Iterate through the list of key URLs
for key_url in $key_urls; do
    key_name=$(basename "$key_url")
    key_path="$ssh_dir/$key_name"

    # Check if the key file already exists
    if [ -f "$key_path" ]; then
        echo "Key file $key_name already exists in $ssh_dir. Skipping."
    else
        echo "Downloading key $key_name to $key_path."
        # Download the key and save it to the SSH directory
        curl -s "$key_url" -o "$key_path"
        chmod 600 "$key_path"
    fi

done

# Notify user of completion
echo "All keys have been downloaded to $ssh_dir."
