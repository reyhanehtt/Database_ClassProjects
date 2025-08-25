# Library Database Project (OLTP + ETL + Data Warehouse)

This is a small end-to-end project for a library system.  
It has three parts:

- **Database (OLTP)** – the normalized relational schema of the library.
- **ETL** – a metadata-driven sync from a source Postgres DB to a target Postgres DB.
- **Data_Warehouse (DW)** – a history-keeping schema that lets you “time-travel”.

Everything is plain SQL and one Python script.

---

## Folder overview

Database_ClassProjects/
├─ Database/
│ ├─ schema.sql
│ └─ erd_oltp.pdf (ERD diagram you added)
├─ ETL/
│ └─ ETL.py (or etl.py if you renamed it)
└─ Data_Warehouse/
├─ schema.sql
└─ erd_dw.pdf (ERD diagram you added)


### Database/
- **`schema.sql`**: PostgreSQL DDL for the OLTP (normalized) schema.
- **`erd_oltp.pdf`**: the ERD for the OLTP model.

Main ideas:
- `BOOK` stores book metadata (by ISBN/edition).
- `BOOK_INSTANCE` stores physical copies of a book.
- `MEMBER` stores library members.
- `BORROWS` stores the loan history.
- Many-to-many tables handle writers, translators, languages, and genres.

### ETL/
- **`ETL.py`**: A metadata-driven pipeline (PostgreSQL → PostgreSQL).  
  It reads tables, columns, PKs, and FKs from `information_schema` (no hard-coded table names).
  It builds a DAG of dependencies and does:
  1) **DELETE** (children → parents)  
  2) **INSERT/UPDATE** (parents → children)
