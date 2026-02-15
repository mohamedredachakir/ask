#!/bin/bash
echo "Verifying migration..." > migrate.log
docker-compose exec -T app php artisan config:clear >> migrate.log 2>&1
docker-compose exec -T app php artisan migrate --force >> migrate.log 2>&1
echo "Migration complete." >> migrate.log
