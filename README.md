# Pharmaceutical Inventory Management DB

**What:** Normalized relational schema + seed data + showcase queries for typical pharmacy ops (top movers, low stock, supplier activity).  
**Status:** Course project (CSC 675/775) organized for quick review.

## Highlights
- Conceptual + logical design, normalization, constraints, and indexing plan
- Example analytics queries (CTEs, window functions)
- Reproducible setup (schema + seed scripts; Docker optional)

```markdown
## Structure
- `/sql` — schema, seed data, procedures/views
- `/docs` — ERD/EER diagrams
- `/course` — original milestone materials

## Quickstart (MySQL)
```bash
# start MySQL (if you added docker-compose.yml)
docker compose up -d

# load schema, seed, then procedures/views
mysql -h 127.0.0.1 -P 3306 -u root -proot < sql/schema.sql
mysql -h 127.0.0.1 -P 3306 -u root -proot pharmadb < sql/seed_data.sql
mysql -h 127.0.0.1 -P 3306 -u root -proot pharmadb < sql/procedures_and_views.sql
```
