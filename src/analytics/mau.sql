
WITH tb_daily AS(
    
    SELECT DISTINCT
        substr(DtCriacao, 0, 11) AS DtDia,
        IdCliente

    FROM transacoes
    ORDER BY DtDia 
    
),

tb_distinct_day AS(

    SELECT DISTINCT DtDia AS dtRef 

    FROM tb_daily

)

SELECT t1.dtRef, count(distinct IdCliente) AS MAU

FROM tb_distinct_day AS t1

LEFT JOIN tb_daily AS t2
On t2.DtDia <= t1.dtRef
AND julianday(t1.dtRef) - julianday(t2.DtDia) < 28
GROUP BY t1.dtRef

order BY t1.dtRef asc