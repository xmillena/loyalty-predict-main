-- ciclo de vida do usuário
-- Regra de segmentação de clientes baseada em:
-- Idade (tempo desde o primeiro contato)
-- Recência (dias desde a última compra/interação)
-- Recência anterior (dias desde a penúltima compra/interação)
--  curioso: idade < 7
--  fiel: recência < 7 e recência anterior < 15
--  turista: 7 <= recência <= 14
--  desencantado: 14 <= recência <= 28
--  churn: recência > 28
--  reconquistado: recência < 7 e 14 <= recência anterior <= 28
--  reborn: recência < 7 e recência anterior > 28

WITH tb_daily AS(
    SELECT DISTINCT IdCliente, substr(DtCriacao,0,11) AS dtDia
    FROM transacoes
    WHERE DtCriacao < '{date}'
),


tb_idade AS(
SELECT IdCliente,
       --min(dtDia) AS dtPrimTransacao,
       CAST(max(julianday('{date}') - julianday(dtDia)) as int) AS qtdDiasPrimTransacao,
       CAST(min(julianday('{date}') - julianday(dtDia)) as int) AS qtdDiasUltmTransacao
FROM tb_daily
GROUP BY IdCliente
),

tb_rn AS(

--window function

SELECT *,
        row_number() OVER (PARTITION BY IdCliente ORDER BY dtDia desc) AS rnDia
FROM tb_daily
),


tb_penultima_ativacao as(
-- penultima transacao
select * , cast(julianday('{date}') - julianday(dtDia) as int) as qtdeDiasPenultimaAtivacao
FROM tb_rn
where rnDia = 2

),

tb_life_cycle as (
    select t1.*, t2.qtdeDiasPenultimaAtivacao,
        case 
            WHEN qtdDiasPrimTransacao <= 7 THEN '01 - Curioso'
            WHEN qtdDiasUltmTransacao <= 7 AND qtdeDiasPenultimaAtivacao - qtdDiasUltmTransacao <= 14 THEN '02 - Regular'
            WHEN qtdDiasUltmTransacao BETWEEN 8 AND 14 THEN '03 - Turista'
            WHEN qtdDiasUltmTransacao BETWEEN 15 AND 28 THEN '04 - Desencantada'
            WHEN qtdDiasUltmTransacao > 28 THEN '05 - Churn'
            WHEN qtdDiasUltmTransacao <= 7 AND qtdeDiasPenultimaAtivacao - qtdDiasUltmTransacao BETWEEN 15 and 28 THEN '02 - Reincidente'
            WHEN qtdDiasUltmTransacao <= 7 AND qtdeDiasPenultimaAtivacao - qtdDiasUltmTransacao >28 THEN '02 - Reborn'
        END AS descLifeCycle

    from tb_idade as t1
    LEFT JOIN tb_penultima_ativacao as t2
    on t1.idCliente = t2.idCliente

)

SELECT date('{date}', '-1 day') AS dtRef, *
FROM tb_life_cycle 
