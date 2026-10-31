USE CATALOG workspace;
USE SCHEMA tp_final_wine;

-- filas por capa
SELECT 'bronze' AS capa, COUNT(*) AS filas FROM wine_bronze
UNION ALL SELECT 'silver', COUNT(*) FROM wine_silver;

SELECT wine_type, COUNT(*) AS filas FROM wine_silver GROUP BY wine_type;

SELECT * FROM wine_gold_perfil_calidad
ORDER BY wine_type, CASE quality_band WHEN 'baja' THEN 1 WHEN 'media' THEN 2 ELSE 3 END;

SELECT * FROM wine_gold_distribucion ORDER BY wine_type, quality;

-- expectations
SELECT details:flow_progress.data_quality.expectations AS expectations
FROM event_log(TABLE(wine_silver))
WHERE event_type = 'flow_progress'
  AND details:flow_progress.data_quality IS NOT NULL
ORDER BY timestamp DESC
LIMIT 5;
