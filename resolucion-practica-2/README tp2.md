# Clase 02: Pipeline incremental Bronze, Silver y Gold

Nombre: Sofia Calzon Alvarez

student_id: sofia

Job: bigdata_&lt;sofia&gt;_silver_gold

URL del Job: https://dbc-e8e992bb-3c4b.cloud.databricks.com/jobs/525533998050112/tasks?o=7474644080037432

Esquema: workspace.bigdata_sofia

Aclaración: mi segundo lote incremental quedó con el nombre batch_004 (corrí el generador una vez de más). Lo que la consigna pide para batch_003 lo hice con batch_004.

## 1. DAG del Job

![DAG del Job](images/dag_job.png)

| Tarea | Notebook | Qué hace |
|---|---|---|
| ingest_bronze | 01_ingest_bronze_incremental | Carga los CSV nuevos con COPY INTO y crea la vista bronze_transactions_all |
| build_silver | 02_build_silver | Tipa, deduplica y valida. Las válidas entran con MERGE y las inválidas van a cuarentena |
| build_gold | 03_build_gold | Reconstruye las tres tablas Gold desde Silver |
| validate | 04_validate_pipeline | Corre los controles y guarda la corrida en pipeline_run_audit |

## 2. Resultados de las ejecuciones

| | Primera ejecución | Segunda ejecución |
|---|---|---|
| Run ID | 856259581929005 | 637421263032362 |
| Lote | batch_002 | batch_002 |
| Filas en Silver | 50.149 | 50.149 |
| Filas en cuarentena | 53 | 53 |
| Filas en Gold | 598 | 598 |
| Monto en Gold | $50.286.183,33 | $50.286.183,33 |
| idempotence_compared | false | true |

La segunda ejecución dio exactamente lo mismo que la primera, así que reprocesar el lote no duplica nada. Después corrí el Job con batch_004 (run 422751774892965) y Silver quedó con 50.549 filas y la cuarentena con 57.

En batch_002 hubo 200 transacciones aceptadas y 2 rechazadas.

## 3. COPY INTO y MERGE

COPY INTO evita cargar dos veces el mismo archivo, porque guarda registro de los archivos que ya procesó. MERGE evita duplicar la misma transacción: compara por transaction_id, inserta las nuevas y actualiza las que llegan corregidas. Sin MERGE tendríamos duplicados y no se aplicarían las correcciones, y sin COPY INTO cada corrida volvería a leer todos los archivos.

## 4. Grano de las tablas Gold

| Tabla | Una fila por |
|---|---|
| gold_daily_sales | día, país, categoría y canal de pago |
| gold_customer_risk | cliente |
| gold_batch_summary | lote |

Como gold_daily_sales no tiene una fila por día, para calcular tasas hay que sumar numeradores y denominadores en vez de promediar.

## 5. Visualizaciones

### Consigna 1: ¿Qué día tuvo el mayor monto y fue también el de más transacciones?

![C1](images/c1_evolucion_temporal.png)

El 1/3/2026 tuvo el mayor monto ($7.310.840,77) y también la mayor cantidad de transacciones (7.236), así que los dos máximos coinciden. El ticket promedio de ese día ($1.010,34) es casi igual al del período ($1.000,54), por lo que el pico se explica por la cantidad de compras y no porque fueran más caras.

### Consigna 2: ¿Qué canal tiene la mayor tasa de fraude?

![C2](images/c2_canal_fraude.png)

Transfer tiene la mayor tasa (13,91%), contra 12,97% de wallet y 12,54% de card. La conclusión se sostiene porque los tres canales tienen casi el mismo volumen (alrededor de 16.800 transacciones cada uno) y la diferencia es significativa (p de 0,01 aprox).

### Consigna 3: ¿Qué combinación de país y categoría genera más monto? ¿Hay una categoría dominante?

![C3](images/c3_pais_categoria.png)

Elegí un mapa de calor porque permite comparar países y categorías al mismo tiempo. La combinación con más monto es Brasil y home ($2.371.688,08). No hay una categoría dominante: home lidera en BR, UY y CL, y books en AR y MX, siempre con solo un 22 o 23% del monto del país.

### Consigna 4: ¿El lote nuevo tiene una calidad distinta al inicial?

![C4](images/c4_calidad_lotes.png)

| Lote | Total | Rechazadas | % rechazo |
|---|---|---|---|
| initial | 49.999 | 51 | 0,10% |
| batch_002 | 202 | 2 | 0,99% |
| batch_004 | 203 | 2 | 0,99% |

En proporción, el lote nuevo rechaza unas 10 veces más que el inicial (test de Fisher, p = 0,02), así que tiene peor calidad. La limitación es que esa tasa sale de solo 2 rechazos sobre unas 200 filas, entonces es poco precisa. Si comparáramos cantidades absolutas (51 contra 2) llegaríamos a la conclusión contraria.

## 6. Preguntas de análisis y comprensión

### Análisis de las tablas

**1. Filas físicas por lote en Bronze**

```sql
SELECT source_batch_id, count(*) FROM bronze_transactions_incremental GROUP BY 1 ORDER BY 1;
```

batch_002 tiene 204 filas y batch_004 también 204. Son más que aceptadas más rechazadas porque en Silver se descartan duplicados y versiones viejas de una misma transacción.

**2. Aceptadas, rechazadas y reconciliación**

```sql
SELECT g.source_batch_id, s.n AS silver, g.accepted_transactions, q.n AS cuarentena, g.rejected_transactions
FROM gold_batch_summary g
LEFT JOIN (SELECT source_batch_id, count(*) n FROM silver_transactions GROUP BY 1) s USING (source_batch_id)
LEFT JOIN (SELECT source_batch_id, count(*) n FROM silver_transactions_quarantine GROUP BY 1) q USING (source_batch_id);
```

initial 49.948 aceptadas y 51 rechazadas, batch_002 200 y 2, batch_004 201 y 2. Todo coincide con gold_batch_summary.

**3. Motivos de rechazo**

```sql
SELECT source_batch_id, quality_reason, count(*) FROM silver_transactions_quarantine GROUP BY 1, 2 ORDER BY 1, 2;
```

Cada lote nuevo tiene un INVALID_AMOUNT y un UNKNOWN_CUSTOMER, que son justo los casos que mete el generador. El lote inicial tiene 51 INVALID_AMOUNT.

**4. Transacción 42**

```sql
SELECT source_batch_id, amount, updated_at FROM bronze_transactions_all WHERE transaction_id = '42';
SELECT source_batch_id, amount, updated_at FROM silver_transactions WHERE transaction_id = 42;
```

| Capa | Lote | amount | updated_at |
|---|---|---|---|
| Bronze | initial | 600.11 | 2026-03-06 02:07 |
| Bronze | batch_002 | 1999.99 | 2026-03-10 02:00 |
| Bronze | batch_004 | 1999.99 | 2026-03-12 02:00 |
| Silver | batch_004 | 1999.99 | 2026-03-12 02:00 |

En Bronze hay 3 versiones y en Silver quedó la que tiene el updated_at más reciente.

**5. Una fila por transaction_id**

```sql
SELECT count(*), count(DISTINCT transaction_id) FROM silver_transactions;
```

Da 50.549 en las dos columnas, o sea que no hay duplicados. Si la deduplicación hubiera fallado, el primer número sería mayor.

**6. Tasa de rechazo por lote**

```sql
SELECT source_batch_id, rejected_transactions / (accepted_transactions + rejected_transactions) AS tasa
FROM gold_batch_summary;
```

initial 0,10%, batch_002 0,99% y batch_004 0,99%. No sirve comparar solo cantidades absolutas porque los lotes tienen tamaños muy distintos.

**7. Día de mayor monto y de más transacciones**

```sql
SELECT sale_date, sum(total_amount) monto, sum(transaction_count) tx
FROM gold_daily_sales GROUP BY 1 ORDER BY monto DESC;
```

El 1/3/2026 es el máximo en las dos métricas ($7.310.840,77 y 7.236 transacciones), así que coinciden.

**8. Tasa de fraude por canal**

```sql
SELECT payment_channel, sum(fraud_transactions) / sum(transaction_count) AS tasa
FROM gold_daily_sales GROUP BY 1 ORDER BY 2 DESC;
```

Transfer 13,91%, wallet 12,97% y card 12,54%. No hay que promediar fraud_rate porque cada fila tiene un denominador distinto, y el promedio simple le da el mismo peso a un grupo de 3 transacciones que a uno de 300.

**9. País y categoría**

```sql
SELECT country, category, sum(total_amount) monto FROM gold_daily_sales GROUP BY 1, 2 ORDER BY monto DESC;
```

La combinación con más monto es BR y home ($2,37 millones). Líder en cada país: home en BR, UY y CL, books en AR y MX.

**10. Auditoría de la reejecución**

```sql
SELECT * FROM pipeline_run_audit ORDER BY recorded_at LIMIT 2;
```

silver_rows, quarantine_rows, gold_rows y gold_total_amount son iguales en las dos filas. La columna idempotence_compared en true muestra que se hizo la comparación.

### Interpretación del código

**11.** COPY INTO (01_ingest_bronze_incremental) carga solo los archivos nuevos. Para eso usa el registro de archivos ya cargados que guarda la tabla destino, identificados por su ruta.

**12.** UNION ALL conserva todo lo que llegó, porque Bronze es la capa cruda y tiene que quedar como registro. Los duplicados de negocio se resuelven en Silver, donde los datos ya están tipados y está la regla de versión por updated_at.

**13.** El Bronze inicial no tiene esas columnas, entonces se le agregan para que el esquema sea igual al de los lotes nuevos, y event_ts funciona como versión original. Por eso la corrección de la 42 tiene un updated_at posterior y es la que queda.

**14.** try_cast devuelve NULL en vez de hacer fallar todo el Job. Después ese registro se detecta como INVALID_AMOUNT y va a cuarentena (quality_rules.py).

**15.** Solo se asigna la primera regla que se cumple. Por eso el orden importa: define qué motivo se informa, y conviene poner primero las reglas más básicas.

**16.** _record_key es el transaction_id, o un hash SHA-256 de la fila cuando el id no es numérico. Con row_number se queda la versión más reciente de cada clave. El hash sirve para que los registros sin id válido no terminen todos agrupados en uno solo (02_build_silver).

**17.** WHEN MATCHED AND s.updated_at > t.updated_at actualiza la fila si llega una versión más nueva. WHEN NOT MATCHED inserta las transacciones que todavía no existen.

**18.** Gold se reconstruye entera porque es simple y siempre queda igual a Silver, aunque tiene la desventaja de recalcular todo en cada corrida. Silver usa MERGE porque es incremental y más eficiente, pero necesita una clave y una regla para saber qué versión es la vigente.

**19.** COPY INTO encuentra solo los archivos nuevos mirando la carpeta. expected_batch_id se usa únicamente en los controles de las tareas 1 y 4, para verificar que el lote llegó bien.

**20.** Si build_silver falla, build_gold y validate no se ejecutan (quedan como Upstream failed). Gold mantiene la versión anterior, no se registra una corrida incompleta y se puede volver a correr sin problema.
