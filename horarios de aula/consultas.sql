--Quantidade de horas por professor
SELECT
    P.name AS nome_professor,
    SUM(TIME_TO_SEC(TIMEDIFF(CS.end_time, CS.start_time)) / 3600) AS horas_comprometidas
FROM
    PROFESSOR P
JOIN
    CLASS_SCHEDULE CS ON P.id = CS.professor_id
GROUP BY
    P.id, P.name
ORDER BY
    horas_comprometidas DESC;

--Salas com Horários Ocupados

SELECT
    R.id AS sala_id,
    R.name AS nome_sala,
    CS.day_of_week AS dia_da_semana,
    CS.start_time AS hora_inicio,
    CS.end_time AS hora_fim,
    C.code AS codigo_turma
FROM
    ROOM R
LEFT JOIN
    CLASS_SCHEDULE CS ON R.id = CS.room_id
LEFT JOIN
    CLASS C ON CS.class_id = C.id
ORDER BY
    R.id, CS.day_of_week, CS.start_time;
Observação: A utilização de LEFT JOIN é crucial para listar todas as salas, mesmo aquelas que não têm nenhuma aula agendada.


-- Salas Livres e Ocupadas (por Blocos de Horários)

WITH horarios_possiveis AS (
    SELECT '08:00:00' AS start_time, '09:00:00' AS end_time UNION ALL
    SELECT '09:00:00','10:00:00' UNION ALL
    SELECT '10:00:00','11:00:00' UNION ALL
    SELECT '11:00:00','12:00:00'
)
SELECT
    R.id AS sala_id,
    HP.start_time,
    HP.end_time,
    CASE 
        WHEN CS.id IS NULL THEN 'LIVRE'
        ELSE 'OCUPADA'
    END AS status_sala
FROM
    ROOM R
CROSS JOIN
    horarios_possiveis HP
LEFT JOIN
    CLASS_SCHEDULE CS ON CS.room_id = R.id AND (
        (HP.start_time >= CS.start_time AND HP.start_time < CS.end_time) OR
        (HP.end_time > CS.start_time AND HP.end_time <= CS.end_time) OR
        (HP.start_time <= CS.start_time AND HP.end_time >= CS.end_time)
    )
ORDER BY
    R.id, HP.start_time;