CREATE OR REFRESH STREAMING TABLE wine_silver (
  CONSTRAINT quality_valida      EXPECT (quality BETWEEN 0 AND 10)            ON VIOLATION DROP ROW,
  CONSTRAINT alcohol_no_nulo     EXPECT (alcohol IS NOT NULL)                 ON VIOLATION DROP ROW,
  CONSTRAINT ph_valido           EXPECT (ph BETWEEN 0 AND 14)                 ON VIOLATION DROP ROW,
  CONSTRAINT densidad_valida     EXPECT (density BETWEEN 0.9 AND 1.1)         ON VIOLATION DROP ROW,
  CONSTRAINT tipo_conocido       EXPECT (wine_type IN ('red', 'white'))       ON VIOLATION DROP ROW,
  CONSTRAINT azucar_razonable    EXPECT (residual_sugar < 50)
)
AS SELECT
  CASE
    WHEN _source_file LIKE '%red%'   THEN 'red'
    WHEN _source_file LIKE '%white%' THEN 'white'
  END                                          AS wine_type,
  CAST(fixed_acidity        AS DOUBLE)         AS fixed_acidity,
  CAST(volatile_acidity     AS DOUBLE)         AS volatile_acidity,
  CAST(citric_acid          AS DOUBLE)         AS citric_acid,
  CAST(residual_sugar       AS DOUBLE)         AS residual_sugar,
  CAST(chlorides            AS DOUBLE)         AS chlorides,
  CAST(free_sulfur_dioxide  AS DOUBLE)         AS free_sulfur_dioxide,
  CAST(total_sulfur_dioxide AS DOUBLE)         AS total_sulfur_dioxide,
  CAST(density              AS DOUBLE)         AS density,
  CAST(ph                   AS DOUBLE)         AS ph,
  CAST(sulphates            AS DOUBLE)         AS sulphates,
  CAST(alcohol              AS DOUBLE)         AS alcohol,
  CAST(quality              AS INT)            AS quality,
  CASE
    WHEN CAST(quality AS INT) <= 5 THEN 'baja'
    WHEN CAST(quality AS INT) =  6 THEN 'media'
    ELSE                                'alta'
  END                                          AS quality_band,
  _source_file,
  _ingested_at
FROM STREAM(wine_bronze);
