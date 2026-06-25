WITH tb_freq_valor AS (
    
    SELECT idCliente, count (DISTINCT substr(DtCriacao,0,11)) AS qtdeFrequencia,
        SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPos,
        SUM(abs(QtdePontos)) AS qtdePontosAbs

    FROM transacoes

    WHERE DtCriacao < '2025-10-01' AND DtCriacao>= date('2025-10-01', '-28 days')

    GROUP BY 1

    ORDER BY qtdeFrequencia desc
),


tb_cluster AS (
    SELECT *,
        CASE 
            WHEN qtdeFrequencia <= 10 and qtdePontosPos > 1500 THEN '01 - Hypers'
            WHEN qtdeFrequencia > 10 AND  qtdePontosPos>=1500 THEN '02 - Eficientes'
            WHEN qtdeFrequencia <=10 AND qtdePontosPos>=750 THEN '03 - Indecisos'
            WHEN qtdeFrequencia >10  AND qtdePontosPos>=750 THEN '04 - Esforçados'
            WHEN qtdeFrequencia <5 THEN '05 - Lurker'
            WHEN qtdeFrequencia <=10 THEN '06 - Preguiçosos'
            WHEN qtdeFrequencia >10 THEN '07 - Potencial'
        END AS cluster

    FROM tb_freq_valor
)

SELECT * 
FROM tb_cluster
