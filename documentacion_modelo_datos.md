

# Documentación del Modelo de Datos para el Sistema de Ventas e Inventario

## Introducción
Este documento describe el proceso de creación del modelo de datos para un sistema de gestión de inventario y transacciones de ventas. El objetivo es organizar la información de productos, proveedores y transacciones de manera estructurada, eficiente y normalizada.

---

## Proceso de Creación del Modelo de Datos

### 1. Análisis de Requisitos
Se identificaron las siguientes necesidades:
- Gestionar un inventario de productos.
- Registrar información de proveedores.
- Realizar transacciones de compra y venta.
- Consultar datos de manera eficiente.

### 2. Diseño del Modelo Entidad-Relación (ER)

#### Entidades Identificadas:
- **Productos**: Representa los artículos disponibles en el inventario.
- **Proveedores**: Almacena información de los proveedores.
- **Transacciones**: Registra las operaciones de compra y venta.

#### Relaciones:
- **Productos – Transacciones**: Un producto puede estar en muchas transacciones (1:N).
- **Proveedores – Transacciones**: Un proveedor puede estar en muchas transacciones (1:N).
- **Productos – Proveedores**: Relación indirecta (M:N) a través de la tabla Transacciones.

### 3. Traducción al Modelo Relacional

#### Tablas Creadas:
- **Productos**: `id_producto`, `nombre`, `descripción`, `precio`, `cantidad_inventario`.
- **Proveedores**: `id_proveedor`, `nombre`, `dirección`, `teléfono`, `email`.
- **Transacciones**: `id_transacción`, `tipo`, `fecha`, `cantidad`, `id_producto`, `id_proveedor`.

#### Claves Primarias y Foráneas:
- Cada tabla tiene una clave primaria (`id_producto`, `id_proveedor`, `id_transacción`).
- `Transacciones` tiene claves foráneas (`id_producto`, `id_proveedor`) que referencian a `Productos` y `Proveedores`.

---

## Decisiones de Diseño

### 1. Tipos de Datos
- **`INT AUTO_INCREMENT`**: Para claves primarias autoincrementales.
- **`VARCHAR`**: Para cadenas de texto de longitud variable.
- **`TEXT`**: Para descripciones largas.
- **`DECIMAL(10, 2)`**: Para precios con precisión de dos decimales.
- **`ENUM('compra', 'venta')`**: Para limitar los valores del tipo de transacción.
- **`DATETIME`**: Para registrar fechas y horas de las transacciones.

### 2. Restricciones
- **`NOT NULL`**: Campos obligatorios.
- **`CHECK`**: Validar que el precio y la cantidad de inventario sean valores positivos.
- **`UNIQUE`**: El email del proveedor debe ser único.
- **`FOREIGN KEY`**: Garantizar integridad referencial.
- **`ON DELETE CASCADE`**: Eliminar transacciones asociadas si se elimina un producto o proveedor.

### 3. Normalización

#### Primera Forma Normal (1NF):
- Cada tabla tiene una clave primaria.
- No hay grupos repetidos.

#### Segunda Forma Normal (2NF):
- Todos los atributos no clave dependen de la clave primaria.

#### Tercera Forma Normal (3NF):
- No hay dependencias transitivas entre atributos no clave.

#### Impacto de la Normalización:
- **Reducción de redundancias**: Cada dato se almacena en un solo lugar.
- **Integridad de datos**: Las restricciones evitan inconsistencias.
- **Flexibilidad**: Facilita la actualización y consulta de datos.

---

## Ejemplos de Consultas SQL

### 1. Recuperar todos los productos disponibles
```sql
SELECT * FROM productos WHERE cantidad_inventario > 0;
```
- **Explicación**: Selecciona todos los productos con inventario mayor que cero.

### 2. Recuperar proveedores de un producto específico
```sql
SELECT p.nombre, p.direccion, p.telefono, p.email
FROM proveedores p
JOIN transacciones t ON p.id_proveedor = t.id_proveedor
JOIN productos pr ON t.id_producto = pr.id_producto
WHERE pr.nombre = 'Nombre del Producto';
```
- **Explicación**: Usa `JOIN` para conectar las tablas y filtrar por el nombre del producto.

### 3. Consultar transacciones en una fecha específica
```sql
SELECT * FROM transacciones
WHERE DATE(fecha) = '2025-09-15';
```
- **Explicación**: Filtra transacciones por fecha, usando `DATE()` para comparar solo la parte de la fecha.

### 4. Total de productos vendidos
```sql
SELECT id_producto, SUM(cantidad) AS total_vendido
FROM transacciones
WHERE tipo = 'venta'
GROUP BY id_producto;
```
- **Explicación**: Agrupa transacciones de venta por producto y calcula la suma de cantidades.

### 5. Valor total de compras
```sql
SELECT SUM(p.precio * t.cantidad) AS valor_total_compras
FROM transacciones t
JOIN productos p ON t.id_producto = p.id_producto
WHERE t.tipo = 'compra';
```
- **Explicación**: Calcula el valor total de compras multiplicando precio por cantidad y sumando.

### 6. Transacción para registrar una compra
```sql
BEGIN TRANSACTION;

-- Actualizar inventario
UPDATE productos
SET cantidad_inventario = cantidad_inventario + 10
WHERE id_producto = 1;

-- Registrar transacción
INSERT INTO transacciones (tipo, fecha, cantidad, id_producto, id_proveedor)
VALUES ('compra', NOW(), 10, 1, 1);

COMMIT;
```
- **Explicación**: Usa una transacción para asegurar que ambas operaciones (actualizar inventario y registrar transacción) se realicen de forma atómica.

---



