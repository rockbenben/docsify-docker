# Docsify Server Docker

This project provides a pre-built Dockerized environment for Docsify, leveraging the official `docsify-cli` to serve your markdown documentation as an elegant website. The `rockben/docsify-server` image is automatically built with the latest version of `docsify-cli`.

## Features

- 📝 Effortless documentation: Write your docs in Markdown and let Docsify serve them with style.
- 🐳 Docker-powered: Pull the image and you're ready to go, no additional installation required.
- 🔄 Auto-update: The Docker image is built automatically from the official `docsify-cli`, keeping your environment up-to-date.

## Getting Started

### Prerequisites

Before you start, ensure you have Docker installed on your machine.

### Running the Docsify Server

1. **Pull the Docker Image**:

   Pull the `rockben/docsify-server` image from Docker Hub:

   ```sh
   docker pull rockben/docsify-server
   ```

2. **Organize Your Documentation**:

   Place your markdown files in a local directory, e.g., `./docs`.

3. **Start the Docsify Server**:

   Use `docker-compose` to start the server. Create a `docker-compose.yml` with the following content:

   ```yaml
   version: "3.8"

   services:
     docsify:
       container_name: docsify-server
       image: rockben/docsify-server
       volumes:
         - ./docs:/docs
       ports:
         - "8080:3000"
       restart: unless-stopped
   ```

   Run the container using:

   ```sh
   docker-compose up -d
   ```

4. **Access Your Site**:

   Your documentation site is now available at `http://localhost:8080`.
