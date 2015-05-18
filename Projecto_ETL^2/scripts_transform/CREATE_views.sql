-- VIEW ERROS GERADOS POR CADA SCREEN EXECUTADO NA ITERAÇÃO ANTERIOR
CREATE OR REPLACE VIEW view_screens_ultima_iteracao AS
SELECT screen_name AS "Nome do screen",
       source_table_name AS "Nome da fonte",
       scr.SCREEN_TYPE AS "Tipo de screen",
       CASE WHEN t1.total IS NULL THEN 0 ELSE t1.total END AS "Erros encontrados",
       CASE WHEN t2.screen_key IS NULL THEN 'não' ELSE 'SIM' END AS "Foi executado"
FROM t_tel_screen scr JOIN t_tel_source source ON scr.screen_source_key=source.source_key
                      LEFT JOIN (SELECT screen_key, COUNT(*) AS total
                                 FROM t_tel_error
                                 WHERE iteration_key=(SELECT MAX(iteration_key) FROM t_tel_iteration)
                                 GROUP BY screen_key) t1 ON scr.screen_key=t1.screen_key
                      LEFT JOIN (SELECT screen_key
                                 FROM t_tel_schedule
                                 WHERE iteration_key=(SELECT MAX(iteration_key) FROM t_tel_iteration)
                                 ) t2 ON scr.screen_key=t2.screen_key;