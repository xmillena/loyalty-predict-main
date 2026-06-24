

WITH tb_daily AS (
    SELECT DISTINCT IdCliente, substr(DtCriacao,0,11) AS dtDia

    FROM transacoes
),

tb_idade_base AS(
    SELECT 
        IdCliente, 
        --min(DtDia) AS dtPrimTransaco,
        cast(max(julianday('now') - julianday(dtDia)) AS int) AS qtdDiasPrimTransacao,
        
        --max(DtDia) AS dtUltimaTransaco,
        cast(min(julianday('now') - julianday(dtDia)) AS int) AS qtdDiasUltimaTransacao

    FROM tb_daily
    GROUP BY IdCliente
),

tb_rn AS (
    SELECT *,
            row_number() OVER(PARTITION BY IdCliente ORDER BY dtDia DESC) AS rn
    FROM tb_daily
),

tb_penultima_ativacao AS (
    SELECT *, cast(julianday('now') - julianday(dtDia) AS int) AS qtdiasPenultimaTransacao
    FROM tb_rn
    WHERE rn = 2
),

tb_life_cycle AS (

    SELECT t1.*, 
            t2.qtdiasPenultimaTransacao,
            CASE
                WHEN t1.qtdDiasPrimTransacao <=  7 THEN '01 - Curioso'
                WHEN t1.qtdDiasUltimaTransacao <= 7 AND t2.qtdiasPenultimaTransacao - t1.qtdDiasUltimaTransacao < 15 THEN '02 - Ativo'
                WHEN t1.qtdDiasUltimaTransacao BETWEEN 8 AND 14 THEN '03 - Inativo'
                WHEN t1.qtdDiasUltimaTransacao BETWEEN 15 AND 28 THEN '04 - Dormindo'
                WHEN t1.qtdDiasUltimaTransacao > 28 THEN '05 - Churn'
                WHEN t1.qtdDiasUltimaTransacao <= 7 AND t2.qtdiasPenultimaTransacao - t1.qtdDiasUltimaTransacao BETWEEN 15 AND 28 THEN '02 - Reativado'
                WHEN t1.qtdDiasUltimaTransacao <= 7 AND t2.qtdiasPenultimaTransacao - t1.qtdDiasUltimaTransacao > 28 THEN '02 - Renascido'
            END AS clienteLifeCycle

    FROM tb_idade_base as t1
    LEFT JOIN tb_penultima_ativacao as t2 ON t1.IdCliente = t2.IdCliente
)

select clienteLifeCycle, count(*)
from tb_life_cycle group by clienteLifeCycle