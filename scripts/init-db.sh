#!/bin/bash
set -e

# Start SQL Server in background
/opt/mssql/bin/sqlservr &

echo "Waiting for SQL Server to be available..."

RETRIES=30
until /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P 'WexAdmin1!' -Q "SELECT 1;" -C &> /dev/null
do
  let RETRIES-=1
  echo "SQL Server not ready yet... retrying"
  sleep 3
  if [ $RETRIES -le 0 ]; then
    echo "SQL Server did not become available in time. Exiting."
    exit 1
  fi
done

echo "SQL Server is available. Running init.sql..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P 'WexAdmin1!' -i /init.sql -C
wait