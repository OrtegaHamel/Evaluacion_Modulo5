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
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    cantidad_inventario INT NOT NULL DEFAULT 0 CHECK (cantidad_inventario >= 0)
);

-- Tabla Transacciones
CREATE TABLE transacciones (
    id_transaccion INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('compra', 'venta') NOT NULL,
    fecha DATETIME NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor) ON DELETE CASCADE
);


-- CONSULTAS BÁSICAS

-- Recupera todos los productos disponibles en el inventario.
SELECT * FROM productos WHERE cantidad_inventario > 0;
