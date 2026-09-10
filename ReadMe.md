Architecture:
Database-First (All of business in sql)

Database:
There is some indexes for better performance on searching queries

Concurrency:
The ROWVERSION  is SqlServer feature for concurrency problems; Also iv added serialize isolation for trx and retrying  

Delete strategy:
IsActive = true; It was requested; Also i can implement it by history tables and i preffere it

Transactions:
Using sql transaction

Performance considerations:
Indexing on Active records, Using Cache, ...

Trade-offs:
Implementing CQRS, Using microservices, ...
