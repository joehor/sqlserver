create table #pivot ( item varchar(10), idMes int, mes char(3), val int )
insert into #pivot
      select 'A',  1, 'JAN', 23
union select 'A',  1, 'JAN', 34
union select 'A',  2, 'FEV', 21
union select 'A',  3, 'MAR', 45
union select 'A',  4, 'ABR', 19

union select 'B',  1, 'JAN', 14
union select 'B',  5, 'MAI', 36
union select 'B',  7, 'JUL', 22
union select 'B', 10,'SET', 33

union select 'C',  3, 'MAR', 25
union select 'C',  6, 'JUN', 21

union select 'D',  1, 'JAN', 85
union select 'D', 10, 'OUT', 14
union select 'D', 11, 'NOV', 15
union select 'D', 12, 'DEZ', 35
union select 'D', 12, 'DEZ', 25

--> exemplo colunas fixas ...
select * from 
(
  select item, mes, val from #pivot
) src
pivot
(
  sum(val) 
  for mes in ([JAN],[FEV],[MAR],[ABR],[MAI],[JUN],[JUL],[AGO],[SET],[OUT],[NOV],[DEZ])
) piv
--< exemplo colunas fixas ...

set nocount off
--> exemplo colunas dinamicas ...
DECLARE @DynamicPivotQuery AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)
--Get distinct values of the PIVOT Column 
SELECT @ColumnName= ISNULL(@ColumnName + ',','') + QUOTENAME(mes)
FROM (SELECT DISTINCT idMes, mes FROM #pivot) AS campos
ORDER BY idMes

--Prepare the PIVOT query using the dynamic 
SET @DynamicPivotQuery = 
  N'SELECT item, ' + @ColumnName + ' 
    FROM (SELECT item, mes, val from #pivot) pvt
    PIVOT(SUM(val) 
          FOR mes IN (' + @ColumnName + ')) AS PVTTable'
--Execute the Dynamic Pivot Query
--PRINT @DynamicPivotQuery
EXEC sp_executesql @DynamicPivotQuery
--< exemplo colunas dinamicas ...

drop table #pivot

/*
SELECT item, [JAN],[FEV],[MAR],[ABR],[MAI],[JUN],[JUL],[OUT],[SET],[NOV],[DEZ] 
    FROM #pivot x
    PIVOT(SUM(val) 
          FOR mes IN ([JAN],[FEV],[MAR],[ABR],[MAI],[JUN],[JUL],[OUT],[SET],[NOV],[DEZ])) AS PVTTable

SELECT item, [JAN],[FEV],[MAR],[ABR],[MAI],[JUN],[JUL],[OUT],[SET],[NOV],[DEZ] 
    FROM (select item, mes, val from #pivot) x
    PIVOT(SUM(val) 
          FOR mes IN ([JAN],[FEV],[MAR],[ABR],[MAI],[JUN],[JUL],[OUT],[SET],[NOV],[DEZ])) AS PVTTable
*/