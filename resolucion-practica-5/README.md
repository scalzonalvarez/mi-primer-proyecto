# Entrega práctica 5 — MLOps con MLflow

- **Nombre:** Sofía Calzon Alvarez
- **student_id:** sofia
- **Escala:** small

## Mis runs

Tabla de la sección 5 del notebook 03:

| run | modelo | features | class_weight | umbral | hiperparametros | train_pr_auc | pr_auc | accuracy | precision | recall | f1 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| max_depth=3 | gradient_boosting | completas | balanced | 0.2 | learning_rate=0.1, max_depth=3 | 0.602 | 0.586 | 0.604 | 0.2 | 0.941 | 0.33 |
| v9 | gradient_boosting | completas | balanced | 0.2 | learning_rate=0.1, max_depth=3 | 0.602 | 0.586 | 0.604 | 0.2 | 0.941 | 0.33 |
| max_depth=5 | gradient_boosting | completas | balanced | 0.2 | learning_rate=0.1, max_depth=5 | 0.614 | 0.579 | 0.599 | 0.198 | 0.939 | 0.327 |
| max_depth=sin_limite | gradient_boosting | completas | balanced | 0.2 | learning_rate=0.1, max_depth=sin_limite | 0.62 | 0.578 | 0.636 | 0.213 | 0.927 | 0.346 |
| max_depth=8 | gradient_boosting | completas | balanced | 0.2 | learning_rate=0.1, max_depth=8 | 0.617 | 0.577 | 0.634 | 0.211 | 0.92 | 0.343 |
| v4 | gradient_boosting | completas | balanced | 0.2 | learning_rate=0.3, max_depth=5 | 0.63 | 0.575 | 0.625 | 0.208 | 0.93 | 0.34 |
| max_depth=8 | random_forest | completas | balanced | 0.2 | n_estimators=200, max_depth=8 | 0.632 | 0.553 | 0.522 | 0.174 | 0.961 | 0.295 |
| v6 | logistic_regression | completas | ninguno | 0.2 | C=1.0 | 0.531 | 0.545 | 0.863 | 0.402 | 0.647 | 0.496 |
| v5 | logistic_regression | completas | ninguno | 0.2 | C=1.0 | 0.531 | 0.545 | 0.863 | 0.402 | 0.647 | 0.496 |
| v7 | logistic_regression | completas | balanced | 0.2 | C=1.0 | 0.527 | 0.54 | 0.509 | 0.168 | 0.941 | 0.285 |
| max_depth=5 | random_forest | completas | balanced | 0.2 | n_estimators=200, max_depth=5 | 0.556 | 0.537 | 0.314 | 0.13 | 0.985 | 0.23 |
| v5 | random_forest | completas | balanced | 0.2 | n_estimators=200, max_depth=5 | 0.556 | 0.537 | 0.314 | 0.13 | 0.985 | 0.23 |
| v4 | random_forest | completas | balanced | 0.5 | n_estimators=200, max_depth=5 | 0.556 | 0.537 | 0.778 | 0.295 | 0.819 | 0.434 |
| v8 | random_forest | completas | balanced | 0.2 | n_estimators=200, max_depth=sin_limite | 1.0 | 0.535 | 0.866 | 0.409 | 0.655 | 0.503 |
| max_depth=sin_limite | random_forest | completas | balanced | 0.2 | n_estimators=200, max_depth=sin_limite | 1.0 | 0.535 | 0.866 | 0.409 | 0.655 | 0.503 |

**Run registrado:** `max_depth=3` (gradient boosting, completas, balanced, umbral 0.2, learning_rate 0.1, max_depth 3), run_id `4598a851b29943cd9f8c23e77f81cfea`, como `workspace.bigdata_sofia.fraud_model` versión 1, alias `champion`.

## Datos y tracking

**1.** train 35.654 filas (11,05% contracargos), test 7.129 (10,38%) y nuevas 7.165 (11,05%). Se separa por fecha porque se entrena con el pasado y se predice el futuro; al azar el modelo vería datos posteriores y el test daría mejor de lo real.

**2.** 89,6%, sin detectar ningún contracargo. El PR-AUC mide qué tan bien se ordenan los positivos y no se infla con los negativos, que son la gran mayoría.

**3.** Parámetros: model_type, feature_set, C, class_weight, threshold, data_table y data_version. Métricas: test_pr_auc 0,339, roc_auc 0,794, accuracy 0,896, precision 0,493, recall 0,045, f1 0,082, alertas 67 y train_pr_auc 0,341. Artefactos: matriz de confusión y el modelo con su firma. El experimento agrupa runs; un run es un entrenamiento.

**4.** 46 parámetros y métricas de train (accuracy 0,91, f1 0,887, log_loss 0,229, precision 0,901, recall 0,91, roc_auc 0,899, score 0,91). No registra métricas de test, el PR-AUC, el umbral ni la versión de los datos.

**5.** Sí, dieron iguales (PR-AUC 0,5099). Hay que fijar datos, código, semilla y entorno.

**6.** Falló la validación del esquema ("Failed to enforce schema") y no predijo. La firma define qué columnas y tipos recibe el modelo y qué devuelve.

## Tus experimentos

**7.** Gradient boosting, completas, balanced, umbral 0,2, learning_rate 0,1, max_depth 3: PR-AUC 0,586. Con solo_regla dio 0,17, mejoró 0,416.

**8.** Logística: 0,339 con básicas y 0,545 con completas. Bosque: 0,336 básicas, 0,504 cliente, 0,537 completas. Las más importantes fueron amount, payment_channel y hour.

**9.** Boosting (0,586), después bosque (0,553) y logística (0,545). Los árboles cortan por una variable y después por otra, así captan combinaciones; la logística suma efectos por separado.

**10.** Precision bajó de 0,402 a 0,168, recall subió de 0,647 a 0,941 y hubo muchas más alertas. El PR-AUC casi no cambió (0,545 a 0,540).

**11.** Bajó la precision (0,295 a 0,13), subió el recall (0,819 a 0,985) y aumentaron las alertas. El PR-AUC usa todos los umbrales, el F1 uno solo.

**12.** max_depth. El mejor fue 3 en boosting (0,586). En el bosque sin límite train dio 1,0 y test 0,535: sobreajuste.

## Comparar y elegir

**13.** No. Por PR-AUC ganó max_depth=3 (accuracy 0,604) y por accuracy 01_repro_a (0,909, recall 0,207). La accuracy premia alertar poco porque casi todo es negativo.

**14.** Los bosques sin límite de profundidad. Indica sobreajuste: memorizan el train.

**15.** Permite filtrar y ordenar desde código y automatizarlo.

```python
"tags.student_id = 'sofia' AND params.model_type = 'random_forest' AND metrics.test_pr_auc > 0.55"
```

**16.** Cuesta más el contracargo no detectado, aunque las alertas falsas gastan tiempo del equipo. Ordenaría por score y pondría el umbral para que salgan solo las N alertas que pueden revisar.

## Registro, uso y monitoreo

**17.** Sí: workspace.bigdata_sofia.fraud_model, versión 1, alias champion. Con el alias se cambia de modelo moviendo el alias, sin tocar el código que lo usa.

**18.** 7.165 puntuadas, 3.410 alertas (47,6%). Se auditan con transaction_id, score, alerta, threshold, model_name, model_version, run_id y scored_at. El umbral es una decisión de negocio y se cambia sin reentrenar.

**19.** Sí: 0,579 contra 0,586. Con la campaña las alertas pasaron de 47,6% a 65,4%. El drift es el cambio en los datos de entrada; se ve en las distribuciones de variables y scores antes de que lleguen las etiquetas.

## Cierre

**20.** Datos en el 00, entrenamiento y tracking en 01 y 02, comparación en 03, registro, scoring y monitoreo en 04. Faltaría automatizar el scoring con un job, alertas de drift y un pipeline de reentrenamiento.
