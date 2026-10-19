# Entrega práctica 4 — Streaming

- **Nombre:** Sofía Calzon Alvarez
- **student_id:** sofia
- **Escala:** small

## Log y offsets

**1.** En la cola quedaron 2 mensajes y en el log 5 (offset = 3). La cola borra al leer; el log conserva los mensajes y cada consumidor avanza su offset.

**2.** Antifraude leyó 180 y reportes 0. No lo afectó: cada uno tiene su propio checkpoint y leer no vacía el log.

**3.** Es la posición hasta donde leyó el consumidor (acá, la versión de la tabla). Se guarda en el checkpoint de cada consulta; al final ambos quedaron en offset 6.

**4.** El replay leyó 280 mensajes. Kappa reprocesa con un único pipeline de streaming leyendo el log desde el inicio; Lambda mantiene una capa batch y otra streaming con la lógica duplicada.

## Ingesta y enriquecimiento

**5.** Bronze procesó 60, 120, 40, 40 y 20 filas; al reejecutar, 0. Lo evita el checkpoint de Auto Loader.

**6.** `INVALID_AMOUNT` (20) y `UNKNOWN_CUSTOMER` (20), en `stream_002`. Bronze guarda el texto original para no perder datos y poder reprocesar si cambian las reglas.

**7.** Agregó `country` y `category`. Es un join stream-tabla.

## Tiempo y ventanas

**8.** Event time es cuándo ocurrió el evento; processing time, cuándo llega. `late_ok` ocurrió a las 12:03 pero llegó en la llegada 2, y se contó igual en la ventana [12:00, 12:05).

**9.** 11:54, 11:58, 12:16, 12:17 y 12:35. Se calcula como máximo event time − 10 minutos.

**10.** En la llegada 3 (4 ventanas). Antes el watermark no había superado el fin de ninguna ventana.

**11.** `late_bad` (12:02) se descartó (20 eventos) porque llegó con el watermark en 12:16 y su ventana ya estaba cerrada. `late_ok` llegó con el watermark en 11:54, dentro del margen.

**12.** Tumbling: ventanas fijas sin solaparse (ventas cada 5 min). Hopping: ventanas solapadas (monto de los últimos 10 min cada 5, para fraude). Session: se cierran tras inactividad del cliente (sesiones de compra).

**13.** Update la emitió dos veces: 40 / 6000.00 (llegada 1) y 60 / 8400.00 (llegada 2). Append la emitió una vez: 60 / 8400.00 (llegada 3). Update tiene menos latencia pero emite valores repetidos; append da un único valor final, con más demora.

**14.** Se gana latencia y menos estado en memoria; se pierden más eventos tardíos (se descartaría todo lo que llegue más de 1 minuto atrasado).

## Garantías y fallas

**15.** 220 sin deduplicar y 200 deduplicando. El productor reintenta si no recibe confirmación (at-least-once).

**16.** Con el mismo checkpoint quedaron 200 (exactly-once). Al perderlo, 400 (at-least-once).

**17.** El `MERGE` no inserta eventos que ya existen, así que quedaron 200 en ambas ejecuciones. Idempotente: aplicarla varias veces da el mismo resultado que una.

## CDC

**18.** 13 eventos: 6 insert, 3 update_preimage, 3 update_postimage y 1 delete. Un UPDATE guarda la fila antes y después del cambio.

**19.** Sí, quedó igual a la original. El log guarda la historia: el cliente 2 pasó por UY, CL y BR, y el cliente 3 existió y fue borrado.

## Cierre

**20.** Spark: si ya se usa un Lakehouse; misma API para batch y streaming. Flink: si se necesita latencia muy baja; gran manejo de estado y event time. Kafka Streams: si los datos ya están en Kafka; es una librería, no requiere cluster aparte.
