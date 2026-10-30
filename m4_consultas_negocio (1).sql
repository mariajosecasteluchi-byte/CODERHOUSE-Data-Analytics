-- =========================================================
-- Modulo 4: Consultas SQL de negocio
-- Titulo: Extrayendo metricas clave con SQL
-- Base de datos: Ventas_Tech_DB
-- Motor: SQL Server
-- Proyecto: RetailPro / TechStore
-- =========================================================

USE Ventas_Tech_DB;
GO

-- =========================================================
-- CONSULTA 1: Resumen ejecutivo mensual
-- Calcula total facturado, cantidad de pedidos y ticket promedio
-- agrupados por mes. El total de cada venta es cantidad * precio_unitario.
-- =========================================================

SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO

-- =========================================================
-- CONSULTA 2: Ranking de los 5 productos con mayor facturacion
-- Muestra unidades vendidas y total generado por producto.
-- =========================================================

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO

-- =========================================================
-- CONSULTA 3: Clientes recurrentes
-- Muestra clientes con mas de un pedido, cantidad de pedidos
-- y total gastado.
-- =========================================================

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC;
GO

-- =========================================================
-- CONSULTA 4: Facturacion por producto comparada con el promedio
-- Primero se calcula el total facturado por producto.
-- Luego se calcula el promedio de esos totales y se clasifica cada producto.
-- =========================================================

WITH facturacion_por_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
),
promedio_facturacion AS (
    SELECT
        AVG(total_facturado * 1.0) AS promedio_por_producto
    FROM facturacion_por_producto
)
SELECT
    f.id_producto,
    f.total_facturado,
    p.promedio_por_producto,
    CASE
        WHEN f.total_facturado > p.promedio_por_producto THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM facturacion_por_producto AS f
CROSS JOIN promedio_facturacion AS p
ORDER BY f.total_facturado DESC;
GO

-- =========================================================
-- HALLAZGOS DEL ANALISIS
-- Estos hallazgos corresponden a los 10 registros cargados en M3.
-- =========================================================
-- 1. Marzo de 2024 concentra todas las ventas registradas en la base de datos.
-- 2. El producto 1 es el de mayor facturacion total, con 3 unidades vendidas
--    y un total facturado de 3600.00.
-- 3. Los clientes 1, 2, 3, 4 y 5 tienen 2 pedidos cada uno; por eso,
--    los cinco cumplen el criterio de clientes recurrentes.
