# Clase 1 · Ingesta y capa Bronze

**Alumno:** sofia · **Escala:** small · **Notebook:** `01_ingesta_bronze.ipynb`

Tablas Bronze creadas: `bronze_customers` (5.000), `bronze_products` (500), `bronze_transactions` (50.011), `bronze_events` (200.000).

## 1. Observaciones sobre formatos

- **CSV/JSON:** no traen tipos. El CSV lee todo como `string`; con `inferSchema` Spark recorre los datos de nuevo (más lento) y aun así `amount` queda como texto porque hay valores no numéricos. El JSON infiere tipos y estructuras anidadas (`context`).
- **Parquet:** guarda el esquema físico en el archivo (`product_id: long`, `price: decimal(12,2)`), no hay que inferir nada y se leen solo las columnas necesarias.
- **Delta:** es Parquet + un log de transacciones. Suma historial de versiones (`DESCRIBE HISTORY`), metadatos y estadísticas de la tabla (`DESCRIBE DETAIL`) que el optimizador usa en el plan.

## 2. Las 5 V en este caso

- **Volumen:** 200.000 eventos y 50.011 transacciones.
- **Velocidad:** los eventos y transacciones tienen timestamp y llegan continuamente.
- **Variedad:** cuatro formatos distintos (CSV, Parquet, JSON anidado).
- **Veracidad:** hay IDs de transacción duplicados (50.011 filas) e importes inválidos en `amount`.
- **Valor:** con los datos limpios se puede analizar ventas por cliente/producto y detectar fraude (`is_fraud`).
