#!/bin/bash
# CONFIGURATION


# PostgreSQL
PG_HOST="localhost"
PG_PORT="5432"
PG_DB="mypgdb"
PG_USER="nisha"
PG_PASS="nisha123"
PG_TABLE="public.users"

# MySQL
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_DB="mydb"
MYSQL_USER="mysql"
MYSQL_PASS="mysql123"

# Backup directory
BACKUP_DIR="/var/backups/db"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="db_backup_${TIMESTAMP}.tar.gz"

# Azure Storage
AZ_ACCOUNT="mystorageacctnisha"
AZ_CONTAINER="db-backups"
AZ_KEY=$Azure_Key

# CREATE BACKUP DIR

mkdir -p "$BACKUP_DIR" || { echo "[ERROR] Cannot create backup directory. Exiting."; exit 1; }


# POSTGRES BACKUP (users table only)

echo "[INFO] Starting PostgreSQL backup..."
PGPASSWORD="$PG_PASS" pg_dump -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$PG_DB" -t "$PG_TABLE" \
    > "$BACKUP_DIR/postgres_users_${TIMESTAMP}.sql"

if [[ $? -ne 0 ]]; then
    echo "[ERROR] PostgreSQL backup failed!"
    exit 1
fi
echo "[INFO] PostgreSQL backup completed."

# MYSQL BACKUP

echo "[INFO] Starting MySQL backup..."
mysqldump -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" "$MYSQL_DB" \
    > "$BACKUP_DIR/mysql_${TIMESTAMP}.sql"

if [[ $? -ne 0 ]]; then
    echo "[ERROR] MySQL backup failed!"
    exit 1
fi
echo "[INFO] MySQL backup completed."


# COMPRESS BACKUPS

echo "[INFO] Compressing backups..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$BACKUP_DIR" \
    "postgres_users_${TIMESTAMP}.sql" "mysql_${TIMESTAMP}.sql"

if [[ $? -ne 0 ]]; then
    echo "[ERROR] Compression failed!"
    exit 1
fi

# Remove raw SQL files
rm -f "$BACKUP_DIR/postgres_users_${TIMESTAMP}.sql" "$BACKUP_DIR/mysql_${TIMESTAMP}.sql"
echo "[INFO] Backup compressed: $BACKUP_DIR/$BACKUP_FILE"


# UPLOAD TO AZURE

echo "[INFO] Uploading to Azure Blob Storage..."
az storage blob upload \
    --account-name "$AZ_ACCOUNT" \
    --account-key "$AZ_KEY" \
    --container-name "$AZ_CONTAINER" \
    --file "$BACKUP_DIR/$BACKUP_FILE" \
    --name "$BACKUP_FILE"

if [[ $? -ne 0 ]]; then
    echo "[ERROR] Azure upload failed"
    exit 1
fi

echo "[INFO] Azure upload completed"
