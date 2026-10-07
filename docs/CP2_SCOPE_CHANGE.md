# Cambio docente de alcance de CP2

Fuente: anuncio de Ivar compartido por el usuario en esta conversación el 2026-10-07. La fecha de entrega y presentación indicada es martes 3 de noviembre de 2026. No se dispone de un enlace público; se conserva aquí su contenido operativo sin inventar condiciones adicionales.

## Requisitos comunicados

Ya no deben preocuparse por estos puntos core: HSQLDB/H2, crear datos de prueba al levantar la aplicación, Swagger y job de coverage. Persistencia relacional y documentación/coverage ya estaban cubiertos o pedidos en CP1.

Queda un único punto core pendiente: separar perfiles de pruebas unitarias y end-to-end.

Se agregan dos requisitos: visualización de datos de usuario mediante gráficos en el frontend, y un feature adicional que debe planificarse, implementarse y presentarse. Los ejemplos del docente incluyen análisis/ajuste de estrategias, notificaciones al frontend y órdenes de compra asíncronas con un bus; también puede agregarse al scraping o consumo del backend. Son ejemplos, no una obligación de usar un broker externo.

La presentación debe explicar el valor de producto, justificar decisiones técnicas, mostrar una demo y luego profundizar en código y funcionamiento. La duración de presentación aún no fue comunicada.

## Interpretación adoptada

Se conserva el alcance funcional del mercado: estrategias, cotizaciones, trading, portfolio, historial y ranking. El mensaje retira puntos core, no declara eliminadas esas funcionalidades. Se conserva la ingeniería ya entregada en CP1 y se evita rehacerla solo para CP2.

La planificación propone órdenes condicionadas por precio como feature adicional, apoyadas en Oban/PostgreSQL, además de gráficos del portfolio. El mínimo frontend se adelanta de CP3 a CP2. Antes de implementar las órdenes, TASK-059 debe especificar y desafiar sus reglas de producto. Ver ADR-0017 y CHECKPOINTS.md.
