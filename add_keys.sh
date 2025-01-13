#!/bin/bash

modify_authorized_keys() {
    mkdir -p ~/.ssh

    EXISTS=$(grep generated-by-azure ~/.ssh/authorized_keys | wc -l)

    if [[ $EXISTS = 0 ]]; then
    tee -a ~/.ssh/authorized_keys << EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCeB3WHNRdq3KRTjX88pQ1ieMQbf5SC+77K+ZAWQYja9sThojm11s1PZEU1QGvT2MGpochKSRvOiR7gRlsCBLCeuayOCJYo00FOYY1NmNYmz5JTxyyHQSATNDTEvw7MLImRBVS0qnKmtqfhTfBFVtSneqgusPrxLgYVpcVoFj9ezG+ml1st/yY+rfS/AvaxD1tmuE1E4mVTe7qcPQRzEmWuI7OJ4SCOOltwKgP8xanZp0Dd8vLXCPSXGCxJxdgg6zgY0Irc0GLoN6gKg/3l+wfsr+gP8FOrBSTHjkUC24VUk5+SUC7BjuUzfTjm5+oL4JgUQR5mCm9sqKNcxeuvhmUmH2ZHrRHxp2+uWD1wfUEsH/H1t1mVHYk5crgEKYqJ1U5v3b/aQOffNXK61ylDdfbkLu/pRK+SmknUbYrdQl0phoQpQwo7t4FuD6bJCtHL7DYJPQoaOv8Pmq5TP3vh++CDaGCIFcGtvXz66vdshH2Ew/z9mA7XzyBr+/95t3S1ozM= generated-by-azure
EOF
    chmod 600 ~/.ssh/authorized_keys
    fi

    sed -i.bak "s/#PubkeyAuthentication .*$/PubkeyAuthentication yes/" /etc/ssh/sshd_config

    systemctl restart ssh
}


download_all_pub_keys() {
    apt install jq -y
    
    # Define the URL for the public git repo where the SSH keys ar stored
    GIT_REPO_URL="https://api.github.com/repos/amaalex057/keyfiles/contents/.keys"

    # Define the SSH directory
    ssh_dir="$HOME/.ssh"

    # Ensure the SSH directory exists
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

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
    echo "All keys have been downloaded to ${ssh_dir}."
}

modify_authorized_keys
download_all_pub_keys