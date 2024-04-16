#!/bin/bash

# Ensure the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Add the Taler repository to the system
echo "Setting up the Taler repository..."
echo 'deb [signed-by=/etc/apt/keyrings/taler-systems.gpg] https://deb.taler.net/apt/debian bookworm main' > /etc/apt/sources.list.d/taler.list

# Download and add the Taler Systems SA public package signing key
echo "Importing the Taler Systems SA public package signing key..."
wget -O /etc/apt/keyrings/taler-systems.gpg https://taler.net/taler-systems.gpg

# Update the package list
echo "Updating package lists..."
apt update

# Install the Taler merchant package
echo "Installing the Taler merchant backend..."
apt install -y taler-merchant

# Note: Further configuration needed for integrating with HTTP servers and databases.
echo "Installation complete. Please configure the web server and database as needed."