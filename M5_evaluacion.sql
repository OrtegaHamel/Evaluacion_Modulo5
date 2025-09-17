-- CREACIÓN DE LA BASE DE DATOS Y TABLAS
DROP DATABASE IF EXISTS empresa_ventas_db;

-- Creación de la base de datos
CREATE DATABASE empresa_ventas_db;
USE empresa_ventas_db;

-- Tabla Proveedores
CREATE TABLE proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    email VARCHAR(100) UNIQUE
);

-- Tabla Productos
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0), -- Restricción para precio positivo
    cantidad_inventario INT NOT NULL DEFAULT 0 CHECK (cantidad_inventario >= 0) -- Restricción para cantidad no negativa
);

-- Tabla Transacciones
CREATE TABLE transacciones (
    id_transaccion INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('compra', 'venta') NOT NULL,
    fecha DATETIME NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0), -- Restricción para cantidad positiva
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    -- Si se elimina un producto, se eliminan sus transacciones
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE, 
    -- Si se elimina un proveedor, se eliminan sus transacciones
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor) ON DELETE CASCADE 
);


-- CONSULTAS BÁSICAS

-- Recupera todos los productos disponibles en el inventario.
SELECT * FROM productos WHERE cantidad_inventario > 0;

-- Recupera todos los proveedores que suministran productos específicos.
SELECT p.nombre, p.direccion, p.telefono, p.email
FROM proveedores p
JOIN transacciones t ON p.id_proveedor = t.id_proveedor
JOIN productos pr ON t.id_producto = pr.id_producto
WHERE pr.nombre = 'Nombre del Producto';

-- Consulta las transacciones realizadas en una fecha específica.
SELECT * FROM transacciones
WHERE DATE(fecha) = '2025-09-15';

-- Total de productos vendidos
SELECT id_producto, SUM(cantidad) AS total_vendido
FROM transacciones
WHERE tipo = 'venta'
GROUP BY id_producto;

-- Valor total de compras
SELECT SUM(p.precio * t.cantidad) AS valor_total_compras
FROM transacciones t
JOIN productos p ON t.id_producto = p.id_producto
WHERE t.tipo = 'compra';


-- MANIPULACIÓN DE DATOS (DML)

-- Insertar datos en las tablas productos, proveedores y transacciones.

-- Insertar un proveedor
INSERT INTO proveedores (nombre, direccion, telefono, email)
VALUES ('Proveedor 1', 'Calle 123', '123456789', 'proveedor1@email.com');

-- Insertar un producto
INSERT INTO productos (nombre, descripcion, precio, cantidad_inventario)
VALUES ('Producto X', 'Descripción del Producto X', 1500.00, 50);

-- Insertar una transacción
INSERT INTO transacciones (tipo, fecha, cantidad, id_producto, id_proveedor)
VALUES ('compra', NOW(), 10, 1, 1);

-- Actualiza la cantidad de inventario de un producto después de una venta 
UPDATE productos
SET cantidad_inventario = cantidad_inventario - 5
WHERE id_producto = 1;

-- Elimina un producto de la base de datos si ya no está disponible
DELETE FROM productos
WHERE id_producto = 1 AND cantidad_inventario = 0; -- La restricción ON DELETE CASCADE eliminará las transacciones asociadas


-- TRANSACCIONES SQL

-- Realizar una transacción para registrar una compra de productos.
BEGIN TRANSACTION;

-- Actualizar inventario
UPDATE productos
SET cantidad_inventario = cantidad_inventario + 10
WHERE id_producto = 1;

-- Registrar transacción
INSERT INTO transacciones (tipo, fecha, cantidad, id_producto, id_proveedor)
VALUES ('compra', NOW(), 10, 1, 1);

COMMIT;

-- Manejar errores en una transacción
BEGIN TRANSACTION;

UPDATE productos SET cantidad_inventario = cantidad_inventario + 10 WHERE id_producto = 1;
-- Si ocurre un error, se revierten los cambios
ROLLBACK;

-- Utilizar el modo AUTOCOMMIT para manejar operaciones individuales
SET AUTOCOMMIT = 0; -- Desactivar el modo AUTOCOMMIT
UPDATE productos SET cantidad_inventario = cantidad_inventario + 10 WHERE id_producto = 1;
-- Si ocurre un error, se revierten los cambios
ROLLBACK;
SET AUTOCOMMIT = 1; -- Activar el modo AUTOCOMMIT


-- CONSULTAS COMPLEJAS

-- Realizar una consulta que recupere el total de ventas de un producto durante el mes anterior.
SELECT p.nombre, SUM(t.cantidad) AS total_vendido
FROM productos p
JOIN transacciones t ON p.id_producto = t.id_producto
WHERE t.tipo = 'venta'
AND MONTH(t.fecha) = MONTH(CURRENT_DATE()) - 1
AND YEAR(t.fecha) = YEAR(CURRENT_DATE())
GROUP BY p.nombre;

-- Utilizar JOINs para obtener información relacionada entre las tablas
-- Información de productos y sus proveedores
SELECT p.nombre AS producto, pr.nombre AS proveedor, t.fecha, t.cantidad
FROM transacciones t
JOIN productos p ON t.id_producto = p.id_producto
JOIN proveedores pr ON t.id_proveedor = pr.id_proveedor;

-- Implementa una consulta con subconsultas (subqueries) 
--para obtener productos que no se han vendido durante un período determinado
SELECT p.nombre
FROM productos p
WHERE p.id_producto NOT IN (
    SELECT DISTINCT id_producto
    FROM transacciones
    WHERE tipo = 'venta'
    AND fecha BETWEEN '2025-09-01' AND '2025-09-31'
);

