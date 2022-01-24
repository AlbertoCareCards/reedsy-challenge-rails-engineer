#!/bin/sh

echo "1. --- Waiting for PostgreSQL to be available on 5432 ..."
while ! nc -z db 5432; do
    sleep 0.1
done

echo "2. --- Create database, run migration, load fixtures in database"
bundle install
./bin/rails db:create
./bin/rails db:migrate
./bin/rails db:seed

echo "3. --- Machine Ready to run :)"

bundle exec rails server -b 0.0.0.0
