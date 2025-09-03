# Pharmaceutical Inventory Management DB

**What:** Normalized relational schema + seed data + showcase queries for typical pharmacy ops (top movers, low stock, supplier activity).  
**Status:** Course project (CSC 675/775) organized for quick review.

## Highlights
- Conceptual + logical design, normalization, constraints, and indexing plan
- Example analytics queries (CTEs, window functions)
- Reproducible setup (schema + seed scripts; Docker optional)

## Quickstart
```bash
# If using Docker (optional; see /sql for scripts)
docker compose up -d
psql -h localhost -U postgres -d pharma -f sql/01_schema.sql
psql -h localhost -U postgres -d pharma -f sql/02_seed.sql
psql -h localhost -U postgres -d pharma -f sql/03_queries_examples.sql
```
