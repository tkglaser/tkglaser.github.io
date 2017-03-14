---
layout: post
title:  "SQL Server Migration from 2008 R2 to 2008"
date:   2012-03-07
permalink: /sql-server-migration-from-2008-r2-to/
---
I've seen this today:

**System.Data.SqlClient.SqlError: The database was backed up on a server running version 10.50.1600. That version is incompatible with this server, which is running version 10.00.2573. Either restore the database on a server that supports the backup, or use a backup that is compatible with this server. (Microsoft.SqlServer.Smo)**


I was trying to restore a backup taken from SQL Server 2008 R2 into SQL Server 2008. It seems that the backup files are not backward compatible, which makes sense as the newer server probably has more functionality.

After some googling, I found the workaround: SQL Publishing Wizard. It comes as a standard component and is located at

c:\Program Files (x86)\Microsoft SQL Server\90\Tools\Publishing\1.4\

It generates a script that contains all DDL and SQL statements to create the database from scratch. You have a choice of having the DDL only, SQL only or both.

Saved me a lot of work.
