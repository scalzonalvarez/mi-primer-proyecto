# Entrega práctica 3 — Bases de datos NoSQL

- **Nombre:** Sofía Calzón Álvarez
- **student_id:** sofia
- **Escala:** small

## CAP y PACELC

**1.** En CP, `C` respondió `ERROR: no disponible`; en AP devolvió `100`, un valor viejo. CP sacrifica disponibilidad y AP sacrifica consistencia.

**2.** Las tres réplicas quedaron en **50**. Se perdió la escritura `saldo=80`.

**3.** p99 de **9,6 ms con `W=1`** y **55,6 ms con `W=3`**. Esperando más réplicas se gana consistencia a cambio de latencia.

**4.** El lado **`ABC`**, porque tiene mayoría (3 de 5) y llega al quórum; `DE` no.

## Clave-valor

**5.** Fue **~2.848.333 veces más rápido** (0,0002 ms vs. 636 ms). Redis usa memoria para responder en O(1) sin leer disco.

**6.** Porque el valor es opaco para la base y no hay índice por país. Ventaja: GET por clave muy rápido y fácil de distribuir. Desventaja: no se puede consultar por el contenido del valor.

**7.** Se movió el **79,6 %** con `hash mod N` y el **21,2 %** con hashing consistente. El segundo mueve sólo las claves de un tramo del anillo, no casi todas.

## Documental

**8.** Relacional: **11 filas**; documental: **1 documento**. Quedaron embebidos el perfil, las estadísticas y las transacciones con su producto.

**9.** Completó con `null` los campos faltantes, uniendo todos los campos en un esquema. Es flexible porque cada documento puede tener campos distintos sin definir un esquema antes.

**10.** El más grande pesa **5,2 KB**. Si crece sin límite puede superar los 16 MB de MongoDB y cada lectura o escritura se vuelve más pesada.

**11.** Resuelve bien las consultas por entidad (un cliente con todo su historial). Le cuestan las consultas analíticas que cruzan muchos documentos.

## Grafos

**12.** **5.000** nodos `Customer`, **2.362** nodos `Device` y **5.600** aristas `USES`.

**13.** **3 joins** para 2 saltos y **5 joins** para 4. Neo4j sigue punteros directos entre nodos en vez de hacer un join por cada salto.

**14.** Convergió en **23 iteraciones**. El componente más grande tiene **62 nodos**.

**15.** El **74,5 %** de las aristas. Es difícil porque cortar aristas entre máquinas convierte cada salto en un viaje por la red.

## Vectorial

**16.** Representa el comportamiento de compra del cliente (categorías, medios de pago, montos). La similitud coseno mide qué tan parecidos son dos perfiles según el ángulo entre sus vectores.

**17.** **31,9 %** de marcados entre los vecinos, contra una tasa base de **15,0 %**. Sirve para encontrar clientes que se comportan como un sospechoso.

**18.** Recall de **0,864** escaneando el **6,09 %** de los vectores. ANN gana velocidad pero puede perder algunos vecinos reales.

## Columnar

**19.** CSV **50,3 MB**, JSON **121,6 MB**, Parquet **5,3 MB**. Leyó sólo `amount` (`ReadSchema: struct<amount:decimal(12,2)>`). Se pueden saltear **7 de 8** archivos.

**20.** Es bueno para analítica porque lee sólo las columnas necesarias, comprime mejor y saltea bloques. Para modificar una fila hay que reescribir archivos enteros, porque sus valores están repartidos entre columnas.
