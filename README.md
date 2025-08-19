### Database Backup Script

Ensure daily backups for PostgreSQL and MySQL databases, compress them, and upload to Azure Blob Storage.

Features

- Backs up a specific table in PostgreSQL (permissions issues)
- Backs up an entire MySQL database.
- Adds a timestamp to backup files for versioning.
- Compresses backups into a single .tar.gz file.
- Uploads backups to Azure Blob Storage automatically.
- scheduled to run daily using cron

Validation:

Postgres:

Create a test data base table

```
sudo -i -u postgres
psql
CREATE DATABASE test_mypgdb;
```

to take the backup run this command

```
PGPASSWORD="nisha123" psql -U nisha -h localhost -d test_mypgdb -f /tmp/users_backup.sql
```

verify the backup

```
PGPASSWORD="nisha123" psql -U nisha -h localhost -d test_mypgdb
```

Once you are in the db verify:

test_mypgdb=> \dt
SELECT \* FROM users;

![alt text](https://github.com/Nishanc07/backup_db/blob/main/public/Screenshot%202025-08-19%20at%2014.59.39.png)

Mysql:

After creating a test db run this command to take db

```
mysql -u mysql -p'mysql123' -h localhost test_mydb < /tmp/mysql_backup.sql
```

verify the same

```
mysql -u mysql -p'mysql123' -h localhost -D test_mydb
```

SHOW TABLES;
SELECT \* FROM users;

![alt text](https://github.com/Nishanc07/backup_db/blob/main/public/Screenshot%202025-08-19%20at%2015.02.04.png)

![alt text](https://github.com/Nishanc07/backup_db/blob/main/public/Screenshot%202025-08-19%20at%2015.07.31.png)
