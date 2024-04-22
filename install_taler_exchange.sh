#!/bin/bash

# Ensure the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Gather all necessary information upfront
echo "Please provide all necessary information for setting up the Taler Exchange."

read -p "Enter the domain name for the exchange: " domain_name
read -p "Enter your email address for SSL certificate notifications: " ssl_email

# Add the Taler repository to the system
echo "Setting up the Taler repository for the exchange..."
echo 'deb [signed-by=/etc/apt/keyrings/taler-exchange.gpg] https://deb.taler.net/apt/debian bookworm main' > /etc/apt/sources.list.d/taler-exchange.list

# Create the directory for the keyring if it doesn't exist
mkdir -p /etc/apt/keyrings

# Download and add the Taler Systems SA public package signing key
echo "Importing the Taler Systems SA public package signing key..."
wget -O /etc/apt/keyrings/taler-exchange.gpg https://taler.net/taler-systems.gpg

# Update the package list
echo "Updating package lists..."
apt update

# Install the Taler exchange package
echo "Installing the Taler exchange..."
apt install -y taler-exchange

# Configure PostgreSQL for Taler Exchange
echo "Configuring PostgreSQL for Taler Exchange..."
sudo -u postgres createuser -d taler-exchange
sudo -u postgres createdb talerexchange -O taler-exchange

# Initialize the exchange database schema
echo "Initializing the exchange database schema..."
taler-exchangedbinit

# Install Certbot for Let's Encrypt SSL certificates
echo "Installing Certbot for Let's Encrypt SSL certificates..."
apt install -y python3-certbot-nginx

# Obtain and configure SSL certificate automatically
echo "Setting up HTTPS with Let's Encrypt..."
certbot --nginx -d $domain_name --non-interactive --agree-tos --email $ssl_email --redirect

echo "Installation and configuration complete for the Taler Exchange."
