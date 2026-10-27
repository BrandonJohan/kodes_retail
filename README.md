# KoDes Retail Relational Database

A Database course (AOL) group project that rebuilds the **KoDes Retail** gift-store data from a single flat CSV into a **normalized relational database** in **MySQL 8.0**.

---

## Overview

KoDes Retail stored all of its sales data in one flat CSV file. This caused redundancy, inconsistent values, and made reporting difficult. This project:

- Cleans the raw CSV data
- Designs a normalized schema (ERD → DDL)
- Loads the cleaned data into MySQL
- Answers business scenarios with SQL queries
- Automates inventory updates with triggers and a stored procedure

## Tech Stack

- **Database:** MySQL 8.0
- **Tool:** MySQL Workbench
- **Data cleaning:** Python (Jupyter Notebook)

## Repository Structure

```
.
├── README.md
├── ERD/                  # Entity Relationship Diagram
├── cleaning.ipynb        # Data cleaning notebook (CSV -> clean CSV)
├── schema.sql            # DDL: database + table creation
├── queries.sql           # DML: 5 business-scenario queries
├── advanced.sql          # Triggers + stored procedure + test script
└── backup/               # Database backup (.sql dump)
```

> Adjust file/folder names above to match the actual repo.

## Deliverables

| Phase | File | Description |
|-------|------|-------------|
| 1 | ERD | Entity Relationship Diagram of the normalized design |
| 2 | `schema.sql` | DDL for all tables, keys, and constraints |
| 3 | `queries.sql` | 5 DML scenarios answering business questions |
| 4 | `advanced.sql` | Triggers and stored procedure |
| 5 | Notion docs | Full documentation of the project |
| 6 | Backup file | Full database dump for restoring |

## Advanced Features (`advanced.sql`)

| Object | Type | Purpose |
|--------|------|---------|
| `trg_UpdateInventory_AfterInsert` | Trigger | Reduces product inventory automatically when a sale is recorded |
| `trg_RestoreInventory_AfterCancel` | Trigger | Restores inventory when a sale is cancelled/returned |
| `GetCustomerInvoiceHistory(CustomerID)` | Stored procedure | Returns every invoice of a customer with its date and total value |

The script ends with a test section (`CALL` + a transaction with `ROLLBACK`) so the logic can be verified without changing real data.

## How to Run

1. **Install** MySQL 8.0 and MySQL Workbench.
2. **Create the schema:** open and run `schema.sql`.
3. **Load the data:** import the cleaned CSV data into the tables (Workbench → Table Data Import Wizard), or restore the backup in step 6 instead.
4. **Run the queries:** execute `queries.sql` to see the 5 scenario results.
5. **Add advanced objects:** run `advanced.sql` to create the triggers and the stored procedure.
6. **(Optional) Restore from backup:**
   ```bash
   mysql -u root -p < backup/<backup-file>.sql
   ```
7. **Test the procedure:**
   ```sql
   CALL GetCustomerInvoiceHistory(1);
   ```

## Documentation

Detailed explanations of the design decisions, ERD, queries, and advanced.sql are in the Notion page:

👉 **https://app.notion.com/p/Dokumentasi-AOL-Database-Kelompok-6-3ff02e2bdc67806d8177c273b8daa008?source=copy_link**

## Team
- Brandon Johan
- Nicholas Arthur Kusumo
- Juan Kahan Vinste

## Course Info

- **Course:** Database Technology
- **Assignment:** Assessment of Learning (AOL) Group Project
- **University:** Binus University
