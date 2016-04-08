DECLARE @tablename nvarchar(100)

DECLARE curs CURSOR FOR SELECT name FROM sys.tables WHERE name like 'ACW%'
OPEN curs
FETCH NEXT FROM curs into @tablename
WHILE @@FETCH_STATUS = 0
BEGIN
SELECT DISTINCT c.name as cname,
    t.name  as tname
        FROM sys.columns c 
        LEFT OUTER JOIN sys.types as t ON c.user_type_id=t.user_type_id
        where object_id=OBJECT_ID(@tablename)
FETCH NEXT FROM curs into @tablename
END
CLOSE curs DEALLOCATE curs