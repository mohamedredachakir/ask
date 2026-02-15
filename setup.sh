#!/bin/bash
set -e

echo "Starting setup..." > setup.log

# Build and start containers
echo "Building and starting containers..." >> setup.log
docker-compose up -d --build >> setup.log 2>&1

echo "Waiting for containers to be ready..." >> setup.log
sleep 10

# Initialize Laravel project inside the container
echo "Initializing Laravel project..." >> setup.log
# We use 'composer create-project' inside the container. 
# Since the directory is mounted, files will appear on host.
# We set --prefer-dist to speed up.
docker-compose exec -T app composer create-project laravel/laravel . --prefer-dist >> setup.log 2>&1

# Fix permissions
echo "Fixing permissions..." >> setup.log
docker-compose exec -T app chown -R laravel:laravel . >> setup.log 2>&1

# Setup .env file if not exists (create-project does it usually)
if [ ! -f src/.env ]; then
    echo "Creating .env file..." >> setup.log
    cp src/.env.example src/.env
    docker-compose exec -T app php artisan key:generate >> setup.log 2>&1
fi

# Set database config in .env (if needed to match docker-compose)
# Docker compose says: DB: my_db, User: reddcs, Pass: reddcs, Host: postgres
# Default laravel .env might have different values.
# We'll use sed to update them.
echo "Configuring database..." >> setup.log
if [ -f src/.env ]; then
  sed -i 's/DB_HOST=127.0.0.1/DB_HOST=postgres/' src/.env
  sed -i 's/DB_DATABASE=laravel/DB_DATABASE=my_db/' src/.env
  sed -i 's/DB_USERNAME=root/DB_USERNAME=reddcs/' src/.env
  sed -i 's/DB_PASSWORD=/DB_PASSWORD=reddcs/' src/.env
fi

# Run migrations
echo "Running migrations..." >> setup.log
docker-compose exec -T app php artisan migrate --force >> setup.log 2>&1

echo "Setup complete!" >> setup.log
