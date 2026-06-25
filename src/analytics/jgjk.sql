SELECT name
FROM sqlite_master
WHERE type = 'table';

SELECT
    dtRef,
    clienteLifeCycle,
    COUNT(*)
FROM life_cycle
GROUP BY dtRef, clienteLifeCycle
ORDER BY dtRef, clienteLifeCycle;