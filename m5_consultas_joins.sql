-- Módulo 5 - Pre-entrega: Consultas con JOINs para el proyecto
-- Proyecto: Ventas_Tech_DB
-- Motor: Microsoft SQL Server
-- Archivo de consultas: no crea, elimina ni modifica tablas.

USE Ventas_Tech_DB;
GO

/* =========================================================
   CONSULTA 1: Vista base del proyecto (INNER JOIN)
   Propósito: combinar las ventas con los datos del cliente
   y del producto para preparar una fuente para Power BI.
   ========================================================= */
SELECT
    v.fecha_venta AS fecha,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS ciudad_cliente,
    p.id_producto,
    p.nombre_producto,
    p.id_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM dbo.ventas AS v
INNER JOIN dbo.clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN dbo.productos AS p
    ON v.id_producto = p.id_producto
ORDER BY v.fecha_venta, v.id_venta;
GO
-- Hallazgo: el resultado permite analizar la facturación por fecha, cliente, ciudad,
-- producto y categoría identificada por id_categoria.


/* =========================================================
   CONSULTA 2: Clientes sin ventas (LEFT JOIN)
   Propósito: encontrar clientes registrados sin compras para
   que el área de CRM pueda evaluar acciones de contacto.
   ========================================================= */
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM dbo.clientes AS c
LEFT JOIN dbo.ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.nombre;
GO
-- Hallazgo: la cantidad de filas devuelta indica cuántos clientes no registran compras.
-- CRM puede priorizar esos casos para una acción de seguimiento.


/* =========================================================
   CONSULTA 3: Productos sin ventas (LEFT JOIN)
   Propósito: detectar productos del catálogo que no aparecen
   en ventas, para que el área de Producto revise su movimiento.
   ========================================================= */
SELECT
    p.nombre_producto,
    p.id_categoria AS categoria,
    p.precio
FROM dbo.productos AS p
LEFT JOIN dbo.ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto;
GO
-- Hallazgo: la cantidad de filas devuelta indica cuántos productos no tuvieron ventas.
-- El área de Producto puede revisar su promoción, disponibilidad o permanencia en catálogo.


/* =========================================================
   CONSULTA 4: Consolidado por origen de ejemplo (UNION ALL)
   Propósito: separar las ventas en dos períodos para practicar
   UNION ALL. Los rótulos son etiquetas de ejemplo, no canales
   reales registrados en la base de datos.
   ========================================================= */
SELECT
    consolidado.canal,
    SUM(consolidado.total) AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Periodo 1' AS canal
    FROM dbo.ventas
    WHERE fecha_venta < '2024-03-11'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Periodo 2' AS canal
    FROM dbo.ventas
    WHERE fecha_venta >= '2024-03-11'
) AS consolidado
GROUP BY consolidado.canal
ORDER BY consolidado.canal;
GO
-- Hallazgo: compará los importes devueltos para identificar qué período concentró
-- mayor facturación. Los nombres Periodo 1 y Periodo 2 son etiquetas ilustrativas.
