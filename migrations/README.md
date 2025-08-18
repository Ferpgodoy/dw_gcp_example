# Migrations

This folder contains SQL migration scripts for the project. Each file should be named in an ordered fashion, for example:

```
0001_create_table_users.sql
0002_add_index_to_orders.sql
...
```

## Execution Flow

Migrations are managed by the Python script located at:

```
include/python_scripts/execute_migrations.py
```

The script performs the following steps:

1. Reads all `.sql` files in the `migrations` folder.
2. Compares the file names with the `control.executed_migrations` table in BigQuery to determine which migrations have already been applied.

   * If the `control.executed_migrations` table does not exist, it is created automatically.
3. Executes the scripts that have not yet been applied.
4. Updates the `control.executed_migrations` table with the executed migrations.

### Table `control.executed_migrations`

This table keeps track of which migrations have been applied. Its columns are:

| Column           | Type      | Description                   |
| ---------------- | --------- | ----------------------------- |
| `file_name`      | STRING    | Name of the executed SQL file |
| `execution_time` | TIMESTAMP | Timestamp of execution        |

## GitHub Actions Integration

The migration script is invoked in the CI/CD workflows located in `.github/workflows/`:

* `deploy-prd.yml`
* `deploy-stage.yml`

Example execution in a workflow:

```yaml
- name: Run migrations
  run: |
    python include/python_scripts/execute_migrations.py
```

This ensures that migrations are automatically applied during the deployment process.