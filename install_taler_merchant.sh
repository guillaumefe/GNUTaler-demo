#!/bin/bash

# Ensure the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Gather all necessary information upfront
echo "Please provide all necessary information for setting up the Taler Merchant Backend."

read -p "Enter your domain name: " domain_name
read -p "Enter your email address for SSL certificate notifications: " ssl_email
read -p "Enter the database name: " db_name
read -p "Enter the database user: " db_user
read -s -p "Enter the database password: " db_password
echo
read -s -p "Confirm the database password: " db_password_confirm
echo

if [ "$db_password" != "$db_password_confirm" ]; then
    echo "Passwords do not match. Script exiting."
    exit 1
fi

# Add the Taler repository to the system
echo "Setting up the Taler repository..."
echo 'deb [signed-by=/etc/apt/keyrings/taler-systems.gpg] https://deb.taler.net/apt/debian bookworm main' > /etc/apt/sources.list.d/taler.list

# Create the directory for the keyring if it doesn't exist
mkdir -p /etc/apt/keyrings

# Download and add the Taler Systems SA public package signing key
echo "Importing the Taler Systems SA public package signing key..."
wget -O /etc/apt/keyrings/taler-systems.gpg https://taler.net/taler-systems.gpg

# Update the package list
echo "Updating package lists..."
apt update

# Install the Taler merchant package, Nginx, PostgreSQL, and Certbot
echo "Installing the Taler merchant backend and necessary components..."
apt install -y taler-merchant nginx postgresql python3-certbot-nginx

# Configure PostgreSQL
echo "Configuring the PostgreSQL database..."
sudo -u postgres psql -c "CREATE DATABASE $db_name;"
sudo -u postgres psql -c "CREATE USER $db_user WITH PASSWORD '$db_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"

# Configure Nginx
echo "Configuring Nginx..."
cat > /etc/nginx/sites-available/$domain_name << EOF
server {
    listen 80;
    server_name $domain_name;

    location / {
        proxy_pass http://localhost:8888; # Adjust the port if Taler is listening on a different one
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/
systemctl restart nginx

# Obtain and configure SSL certificate automatically
echo "Setting up HTTPS with Let's Encrypt..."
certbot --nginx -d $domain_name --non-interactive --agree-tos --email $ssl_email --redirect

echo "Installation and configuration complete. Your Taler Merchant Backend is now secured with HTTPS."
