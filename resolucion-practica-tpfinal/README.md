# TP Final Big Data y MLOps

Sofía Calzon Alvarez
Variante 2, Opción A: arquitectura medallion en Databricks

## Objetivo

Armar un pipeline bronze, silver y gold en Databricks con datos de vinos, y ver que caracteristicas tienen los vinos de mejor calidad.

## Contenido de la carpeta

- README.md: este documento
- pipeline/ingesta/01_bronze.sql: ingesta (capa bronze)
- pipeline/etl/02_silver.sql y 03_gold.sql: transformaciones y controles de calidad (silver y gold)
- pipeline/pipeline_config.json: configuracion del pipeline
- consultas/verificacion.sql: consultas para revisar los resultados
- evidencia/: capturas de la ejecucion

## Datos

Use el dataset Wine Quality del repositorio UCI (https://archive.ics.uci.edu/dataset/186/wine+quality). Son dos csv separados por ";", uno de vinos tintos (1599 filas) y otro de blancos (4898 filas). Cada fila es un vino, con 11 medidas quimicas y un puntaje de calidad de 0 a 10.

Columnas: fixed acidity, volatile acidity, citric acid, residual sugar, chlorides, free sulfur dioxide, total sulfur dioxide, density, pH, sulphates, alcohol y quality. Todas son numericas.

Lo elegi porque es publico, no tiene datos sensibles y viene en dos archivos que hay que unir.

## Pipeline

Esta todo en un solo pipeline de Databricks, dividido en ingesta y ETL:

- Ingesta (pipeline/ingesta/01_bronze.sql): wine_bronze lee los csv del volume y los guarda como texto, junto con el nombre del archivo de origen. Es una streaming table, asi que si se agregan archivos nuevos solo procesa esos.
- ETL (pipeline/etl/02_silver.sql): wine_silver pasa las columnas a numeros, agrega el tipo de vino (red/white, sacado del nombre del archivo) y una banda de calidad: baja (5 o menos), media (6) y alta (7 o mas).
- ETL (pipeline/etl/03_gold.sql): wine_gold_perfil_calidad tiene los promedios de cada variable por tipo y banda, y wine_gold_distribucion la cantidad de vinos por puntaje.

Granularidad de las tablas: en bronze y silver cada fila es un vino. En wine_gold_perfil_calidad cada fila es un tipo y una banda de calidad (6 filas), y en wine_gold_distribucion cada fila es un tipo y un puntaje (13 filas). Como el dataset no tiene id, no hay clave primaria. Las tablas se relacionan porque cada una lee de la anterior.

Orden de ejecucion: no lo configure a mano. Databricks lo arma solo a partir de las dependencias: primero bronze, despues silver y al final las dos de gold. Los mismos parametros que use en la interfaz estan en pipeline_config.json.

En silver agregue controles de calidad (expectations). Se descartan las filas con calidad fuera de 0-10, alcohol vacio, pH fuera de 0-14, densidad fuera de 0.9-1.1 o tipo desconocido. Si el azucar residual es mayor a 50 solo se registra como aviso, no se descarta la fila.

En bronze cargue todo como texto para que un dato mal formado no corte la carga, y el esquema lo puse a mano porque los nombres de las columnas originales tienen espacios.

## Como correrlo

1. Crear el esquema y el volume:
   ```sql
   CREATE SCHEMA IF NOT EXISTS workspace.tp_final_wine;
   CREATE VOLUME IF NOT EXISTS workspace.tp_final_wine.raw;
   ```
2. Subir los dos csv al volume raw.
3. Crear un ETL pipeline con los tres archivos sql, catalogo workspace, esquema tp_final_wine, y en configuration agregar source_path = /Volumes/workspace/tp_final_wine/raw/
4. Correr el pipeline y despues las consultas de consultas/verificacion.sql

## Resultados

El pipeline corrio completo sin errores (capturas en la carpeta evidencia). Bronze y silver quedaron con 6497 filas, no se descarto ninguna. De los 6 controles pasaron 5. El de azucar marco 1 vino con mas de 50, pero quedo en la tabla porque esa regla solo avisa.

Perfil por calidad:

| Tipo | Calidad | Vinos | Alcohol | Acidez volatil | Sulfatos | Azucar residual |
|---|---|---|---|---|---|---|
| red | baja | 744 | 9.93 | 0.590 | 0.619 | 2.54 |
| red | media | 638 | 10.63 | 0.497 | 0.675 | 2.48 |
| red | alta | 217 | 11.52 | 0.406 | 0.743 | 2.71 |
| white | baja | 1640 | 9.85 | 0.310 | 0.482 | 7.05 |
| white | media | 2198 | 10.58 | 0.261 | 0.491 | 6.44 |
| white | alta | 1060 | 11.42 | 0.265 | 0.500 | 5.26 |

Conclusiones:
- Lo que mas cambia entre calidades es el alcohol, que sube alrededor de 1.5 puntos de baja a alta en los dos tipos.
- En los tintos, ademas, cuanto mejor es el vino menor es la acidez volatil y mayor la cantidad de sulfatos.
- En los blancos de calidad alta hay menos azucar residual y menos densidad, lo que tiene sentido porque tienen mas alcohol.
- La mayoria de los vinos tiene puntaje 5 o 6 (82% de los tintos y 75% de los blancos). Hay muy pocos en los extremos, por ejemplo solo 5 blancos con puntaje 9.

## Evidencia

Capturas en la carpeta evidencia:

- 00_pipeline_grafo.png: grafo del pipeline (auto loader, bronze, silver y las dos tablas gold)
- 01_pipeline_tablas.png: ejecucion del pipeline con las 4 tablas completas y el resultado de las expectations
- 02_filas_por_capa.png y 03_filas_por_tipo.png: conteos de bronze y silver
- 04_perfil_calidad_1.png y 04_perfil_calidad_2.png: tabla wine_gold_perfil_calidad
- 05_distribucion.png: tabla wine_gold_distribucion
- 06_expectations.png: detalle de los controles de calidad sacado del event log

## Limitaciones

El puntaje de calidad es subjetivo (lo ponen catadores) y esta muy concentrado en 5 y 6. Ademas hay filas repetidas, y como no hay un id por vino no se puede saber si son el mismo vino o dos distintos con los mismos valores.

## Fuentes

- Wine Quality, UCI Machine Learning Repository: https://archive.ics.uci.edu/dataset/186/wine+quality

