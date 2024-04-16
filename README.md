# Taler Services Installation Guide

## Prerequisites
Before you begin, make sure you have the following installed on your system:

- **Docker**: You need Docker installed to create containers for each service. [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: Docker Compose is required to manage the multi-container setup. [Install Docker Compose](https://docs.docker.com/compose/install/)

## Setup

### Step 1: Clone the Repository
Clone this repository to your local machine. This repository contains all necessary Dockerfiles, scripts, and configuration files.

```bash
git clone https://yourrepository.com/taler-services.git
cd taler-services
```

### Step 2: Prepare the Scripts and HTML Files
Ensure that the installation scripts (`install_taler_merchant.sh` and `install_taler_exchange.sh`) and the `index.html` file for the Index Server are present in the project directory. Update these files as necessary to suit your configuration needs.

### Step 3: Build the Docker Images
Use Docker Compose to build the Docker images for each service:

```bash
docker-compose build
```

This command reads the `docker-compose.yml` file in your project directory and builds Docker images for the merchant, exchange, APK server, and index server.

### Step 4: Start the Services
Once the images are built, start the services using Docker Compose:

```bash
docker-compose up
```

This command starts all services defined in `docker-compose.yml`. You can add `-d` to run them in the background:

```bash
docker-compose up -d
```

### Step 5: Verify the Services
Ensure that all services are running correctly:

- **Merchant Backend**: Navigate to http://localhost:8888/ to access the Taler Merchant backend.
- **Exchange Service**: Navigate to http://localhost:8889/ to access the Taler Exchange service.
- **APK Download Server**: Navigate to http://localhost:8080/taler-wallet.apk to download the Taler Wallet APK.
- **Index Server**: Navigate to http://localhost:8090/ to view the index page linking to all services.

## Additional Configuration
Depending on your setup, you may need to configure network settings or adjust port numbers in the `docker-compose.yml` file to match your environment's requirements. Ensure all URLs and paths referenced in the Dockerfiles and scripts accurately reflect your directory structure and network configuration.

## Troubleshooting
If you encounter issues with starting the services, check the Docker container logs for any errors:

```bash
docker logs <container_name>
```
