This might be common knowledge, some might even consider it trivial, but I just learned this today: 
**you can have as many where clauses in a Linq query as you like.**

For example:
```csharp
from c in db.Customers
where c.County == "Berkshire"
where c.Capacity > 12
where c.Radius < 20
select c
```
This is valid, compiles and works as expected.

For me coming from classic SQL, this was counter intuitive as SQL only allows one.

Keeping in mind that the Linq syntax is just a chain of individual expressions (filters, projections, ...) that are translated into SQL at some point, it makes sense. Linq-to-SQL or the Entity Framework just collects all where clauses and AND's them together.

I think, the above code looks much cleaner than this:
```csharp
from c in db.Customers
where c.County == "Berkshire" &&
c.Capacity > 12 &&
c.Radius < 20
select c
```
It's a small improvement but I'm happy I discovered this today.
