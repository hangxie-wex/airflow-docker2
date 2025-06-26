# Start from the official Airflow image
FROM apache/airflow:latest-python3.11

# Switch to root user to install system dependencies
USER root

# Install FreeTDS and unixODBC development files for pyodbc
# Combine apt-get updates and installs to a single layer for efficiency
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    freetds-dev \
    libkrb5-dev \
    unixodbc-dev && \
    rm -rf /var/lib/apt/lists/*

# Install the Microsoft ODBC Driver for SQL Server
# This is tailored for Debian. Airflow official images are typically Debian-based.
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 && \
    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> /etc/bash.bashrc # Use system-wide bashrc for PATH

# Switch back to the Airflow user BEFORE installing Python packages
# This adheres to Airflow's recommended practice for installing dependencies.
USER airflow
RUN rm -rf /home/airflow/.local/lib/python3.11/site-packages/airflow/example_dags
# Install the Airflow MSSQL provider and Python ODBC driver (pyodbc)
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt