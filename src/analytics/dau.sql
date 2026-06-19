-- DAU - DAILY ACTIVE USERS

SELECT  substr(DtCriacao, 0, 11) AS DTdia,
        count (DISTINCT idCliente) AS DAU
FROM transacoes
GROUP BY 1
ORDER BY DtDia


