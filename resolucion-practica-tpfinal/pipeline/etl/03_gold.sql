CREATE OR REFRESH MATERIALIZED VIEW wine_gold_perfil_calidad
AS SELECT
  wine_type,
  quality_band,
  COUNT(*)                          AS n_vinos,
  ROUND(AVG(alcohol), 2)            AS alcohol_prom,
  ROUND(AVG(volatile_acidity), 3)   AS acidez_volatil_prom,
  ROUND(AVG(sulphates), 3)          AS sulfatos_prom,
  ROUND(AVG(residual_sugar), 2)     AS azucar_residual_prom,
  ROUND(AVG(density), 4)            AS densidad_prom
FROM wine_silver
GROUP BY wine_type, quality_band;

CREATE OR REFRESH MATERIALIZED VIEW wine_gold_distribucion
AS SELECT
  wine_type,
  quality,
  COUNT(*) AS n_vinos,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY wine_type), 1) AS pct_del_tipo
FROM wine_silver
GROUP BY wine_type, quality;
