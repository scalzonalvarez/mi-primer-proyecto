CREATE OR REFRESH STREAMING TABLE wine_bronze
AS SELECT
  *,
  _metadata.file_path   AS _source_file,
  current_timestamp()   AS _ingested_at
FROM STREAM read_files(
  '${source_path}',
  format => 'csv',
  header => true,
  sep    => ';',
  schema => 'fixed_acidity STRING, volatile_acidity STRING, citric_acid STRING,
             residual_sugar STRING, chlorides STRING, free_sulfur_dioxide STRING,
             total_sulfur_dioxide STRING, density STRING, ph STRING,
             sulphates STRING, alcohol STRING, quality STRING'
);
