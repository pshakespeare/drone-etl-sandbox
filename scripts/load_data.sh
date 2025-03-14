#!/bin/bash

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
while ! pg_isready -h postgres -p 5432 -U drone_user -d drone_db
do
  sleep 2
done

# Load the sample data
echo "Loading sample data..."
PGPASSWORD=drone_password psql -h postgres -p 5432 -U drone_user -d drone_db -f /app/scripts/load_sample_data.sql

echo "Sample data loaded successfully!" 