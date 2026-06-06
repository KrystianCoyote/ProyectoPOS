"""# 🛒 Sistema de Punto de Venta - Proyecto POS

¡Bienvenido a Proyecto POS! Este repositorio contiene un sistema de punto de venta inteligente, multiplataforma y desacoplado, diseñado para automatizar las operaciones comerciales de negocios locales como cafeterías, tiendas de snacks, pequeños restaurantes de comida rápida y comercios minoristas.

---

## 🏗️ Arquitectura del Sistema

El ecosistema está fragmentado en dos componentes de software independientes que se comunican de manera segura a través de servicios Web:

1. PosApi (Backend): Desarrollado en .NET 8 (C# Core Web API). Implementa control global de excepciones con middlewares dedicados (ErrorHandlingMiddleware), middleware de registro de auditoría (RequestLoggingMiddleware) y Entity Framework Core para interactuar de forma óptima con la base de datos MySQL.
2. PosApp (Frontend): Una aplicación cliente responsiva, fluida y con un diseño intuitivo desarrollada con Flutter (Dart). El código base está listo para compilarse nativamente en dispositivos móviles (Android, iOS) y sistemas de escritorio (Windows, Linux, macOS).

---

## ✨ Características Principales

* Autenticación y Gestión de Roles: Control de accesos seguro para los roles de 'Administrador' y 'Cajero'.
* Control de Inventario y Variantes Complejas:
  - Categorización dinámica del catálogo de productos en tiempo real.
  - Gestión de artículos estándar con control de Stock y soporte para códigos de barras.
  - Soporte especializado para productos con variantes de tamaños (Chico, Mediano, Grande), permitiendo manejar dinámicamente precios escalados (ej. cafés, atoles y bebidas).
* Módulo de Caja Dinámico (Punto de Venta): Interfaz optimizada con escaneo de código de barras, adición rápida, cálculo instantáneo de totales, procesamiento del monto recibido, cálculo automático de cambio y persistencia transaccional.
* Cortes de Caja e Historial: Rastreo exhaustivo de ventas ligadas al cajero en turno, proporcionando herramientas analíticas para cierres y auditoría de transacciones.
* Automatización de Tickets y Reportes: Generación de comprobantes en formato PDF y arquitectura modular adaptada para la comunicación y salida directa hacia impresoras térmicas mediante conexión Bluetooth.

---

## 🗄️ Modelo de Datos (MySQL)

La base de datos utiliza el motor relacional MySQL configurado bajo el esquema utf8mb4_general_ci. Las entidades núcleo del sistema son:

* Usuarios: Registra la información de identidad, credenciales protegidas (PasswordHash), inicios de sesión rápidos (UsuarioLogin), estado lógico (Activo) y rol asignado.
* Categorias: Clasificaciones maestras para la segmentación del catálogo.
* Productos: Centraliza los metadatos de los artículos, códigos de barra, niveles de stock, imágenes asociadas (FotoUrl) y la matriz de precios variables según el tamaño si la bandera UsaTamanos está activa.
* Ventas: Cabecera de la transacción comercial que consolida marcas de tiempo, totales vendidos, montos abonados por el cliente, cambios calculados y el operador responsable.
* DetallesVenta: Entidad relacional e histórica que almacena cantidades exactas y los precios unitarios de congelación en el momento de la venta.

---

## 🚀 Instalación y Configuración

### 1. Base de Datos (MySQL)
Antes de arrancar los entornos de desarrollo, prepara tu servidor relacional local:

1. Modifica los privilegios de autenticación si requieres compatibilidad con los conectores nativos de .NET:
   ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Krystian.89';
   FLUSH PRIVILEGES;

2. Ejecuta el script SQL de inicialización incluido en el proyecto. Este creará las estructuras relacionales de 'posdb' e inyectará los catálogos base (Bebidas calientes, Atole, Comida, Postres) y los usuarios semilla de prueba.

### 2. Despliegue del Servidor (PosApi)
1. Desde tu terminal, desplázate a la carpeta del backend: cd PosApi/
2. Abre y edita el archivo de configuración appsettings.json y configura tu cadena de conexión:
   "ConnectionStrings": {
     "DefaultConnection": "Server=localhost;Database=posdb;Uid=root;Pwd=Krystian.89;"
   }
3. Restaura las dependencias de NuGet y levanta el servidor web de desarrollo:
   dotnet restore
   dotnet run

### 3. Configuración de la Aplicación Cliente (PosApp)
1. Accede al directorio raíz de la aplicación Flutter (donde reside el archivo pubspec.yaml).
2. Configura la dirección IP local o URL pública de tu API de .NET modificando el archivo de entorno global lib/config/api_config.dart.
3. Descarga e instala los paquetes requeridos por el proyecto:
   flutter pub get
4. Ejecuta la aplicación mediante el comando:
   flutter run

---

## 👥 Credenciales de Acceso Base (Semilla)

El script SQL aprovisiona automáticamente los siguientes accesos rápidos para la pantalla de Login:

* Administrador Principal:
  - Usuario: 1
  - Contraseña: 1
  - Rol: Administrador

* Operador de Caja:
  - Usuario: 2
  - Contraseña: 2
  - Rol: Cajero

* Desarrollador / Administrador:
  - Usuario: Krys
  - Contraseña: Krys
  - Rol: Administrador

---

## 🛠️ Tecnologías y Herramientas Utilizadas

* Capa de Datos: MySQL Server 8.x, Entity Framework Core ORM.
* Capa de Servidor (API): .NET 8, C# (ASP.NET Core Web API), Middlewares de logging y excepciones.
* Capa de Cliente (Multiplataforma): Flutter Framework, Dart Language.
* Componentes Incorporados: Generación de tickets en formato PDF, Integración Bluetooth para periféricos físicos, Escaneo de códigos ópticos por hardware de cámara.
"""
