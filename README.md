# 🛒 Sistema de Punto de Venta - Proyecto POS

¡Bienvenido a Proyecto POS! Este es un ecosistema de punto de venta moderno, multiplataforma y desacoplado, diseñado para automatizar las operaciones comerciales de negocios locales como cafeterías, tiendas de snacks, pequeños restaurantes de comida rápida y comercios minoristas.

---

## 🏗️ Arquitectura del Sistema

El proyecto se compone de dos capas independientes que se comunican a través de servicios Web:

1. PosApi (Backend): Desarrollado en .NET 8 (C# Core Web API). Implementa control global de excepciones con un middleware dedicado (ErrorHandlingMiddleware), middleware de registro de peticiones (RequestLoggingMiddleware) y Entity Framework Core para la persistencia y mapeo con la base de datos MySQL.
2. PosApp (Frontend): Aplicación cliente fluida, moderna y responsiva construida en Flutter (Dart). Está diseñada para compilarse nativamente de forma multiplataforma cubriendo entornos móviles (Android, iOS) y sistemas de escritorio (Windows, Linux, macOS).

---

## ✨ Características Principales

* 🔒 Autenticación y Control de Roles: Validación segura de inicios de sesión con flujos de trabajo específicos para los roles de 'Administrador' y 'Cajero'.
* 📦 Catálogos Avanzados y Manejo de Variantes:
  - Clasificación y administración dinámica de categorías en tiempo real.
  - Control de artículos estándar con manejo de Stock y soporte nativo para códigos de barras.
  - Soporte especializado para productos con variantes de tamaños (Chico, Mediano, Grande), permitiendo configurar dinámicamente precios escalados (ideal para la venta de cafés, atoles y bebidas preparadas).
* 💻 Módulo de Caja Dinámico (Punto de Venta): Terminal de caja optimizada para agilizar transacciones mediante escaneo de códigos de barra, adición rápida, cálculo de totales, registro de efectivo recibido, cálculo automático de cambio y guardado transaccional.
* 📊 Cortes de Caja e Historial: Registro minucioso de transacciones ligadas al usuario activo en caja para auditorías, cierres de turno y desgloses financieros.
* 🖨️ Servicios de Tickets y Reportes: Generación automática de comprobantes de venta en formato PDF y compatibilidad para impresión directa hacia impresoras térmicas mediante conexión Bluetooth.

---

## 🚀 Requisitos previos e Instalación

### 1. Configuración Manual de la Base de Datos (MySQL)
Por razones de seguridad, el script de inicialización SQL no se incluye de manera pública en este repositorio. Antes de lanzar la aplicación, deberás configurar tu servidor de MySQL local de la siguiente manera:

1. Asegúrate de crear una base de datos relacional llamada exactamente 'posdb' utilizando codificación UTF-8:
   CREATE DATABASE posdb CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

2. El esquema requiere la creación manual de las siguientes tablas relacionales:
   - Usuarios: Para gestionar identidades, roles ('Administrador' y 'Cajero'), estados activos e inicios de sesión rápidos.
   - Categorias: Clasificaciones para la segmentación de productos.
   - Productos: Metadatos de artículos, stocks, códigos de barras opcionales y la matriz de precios escalados por tamaño (PrecioChico, PrecioMediano, PrecioGrande) bajo la bandera lógica 'UsaTamanos'.
   - Ventas y DetallesVenta: Entidades maestra-detalle para consolidar marcas de tiempo, totales, montos recibidos, cambios calculados e histórico de productos vendidos.

3. Asegúrate de dar de alta al menos un usuario administrador inicial directamente en la tabla de 'Usuarios' para poder superar la pantalla de Login del sistema.

### 2. Despliegue del Servidor (PosApi)
1. Desde tu terminal de comandos, accede al directorio del backend:
   cd PosApi/
2. Abre el archivo de configuración 'appsettings.json' (y 'appsettings.Development.json') y actualiza la cadena de conexión 'DefaultConnection' insertando el usuario, contraseña y puerto correspondientes a tu servidor MySQL local.
3. Restaura las dependencias de NuGet y levanta los servicios de la Web API ejecutando:
   dotnet restore
   dotnet run
4. Los endpoints de comunicación quedarán expuestos localmente. Los puertos asignados de escucha HTTP/HTTPS se pueden verificar dentro de 'Properties/launchSettings.json'.

### 3. Configuración de la Aplicación Cliente (PosApp)
1. Abre tu entorno de desarrollo en el directorio raíz del proyecto de Flutter (donde se ubica el archivo 'pubspec.yaml').
2. Vincula la aplicación cliente con tu servidor de .NET editando el archivo 'lib/config/api_config.dart', estableciendo la dirección IP local o URL de dominio donde esté corriendo tu PosApi.
3. Descarga los paquetes y plugins necesarios declarados en el manifiesto:
   flutter pub get
4. Ejecuta o compila la aplicación en tu dispositivo objetivo mediante el comando:
   flutter run

---

## 🛠️ Stack Tecnológico Utilizado

* Capa de Datos: MySQL Server / MariaDB, Entity Framework Core ORM.
* Lógica de Servidor (API): .NET 8, C# (ASP.NET Core Web API), Middlewares personalizados para Logging y Excepciones.
* Capa de Cliente (Multiplataforma): Flutter Framework, Dart Language.
* Componentes Especializados: Generación de reportes PDF nativos, Integración Bluetooth para periféricos físicos de impresión y Escaneo óptico por hardware de cámara.
