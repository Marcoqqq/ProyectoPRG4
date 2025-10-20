# 🔐 Sistema de Gestión de Usuarios - JSP & MySQL

Sistema web de gestión de usuarios con autenticación y CRUD completo desarrollado en JSP y MySQL.

## 🚀 Características

- ✅ Sistema de login con validación de credenciales
- ✅ Registro de nuevos usuarios
- ✅ Búsqueda de usuarios por correo
- ✅ Edición completa de datos (nombre, correo, clave, tipo)
- ✅ Eliminación de usuarios con confirmación
- ✅ Validaciones de formularios
- ✅ Interfaz responsive con Bootstrap 5

## 🛠️ Tecnologías

- Java 8+
- JSP (JavaServer Pages)
- MySQL 5.7+
- Bootstrap 5.3.2
- Apache Tomcat 8.5+

## 📋 Requisitos Previos

- **JDK 8 o superior** - [Descargar](https://www.oracle.com/java/technologies/downloads/)
- **NetBeans IDE** - [Descargar](https://netbeans.apache.org/download/index.html)
- **MySQL Server** - [Descargar](https://dev.mysql.com/downloads/mysql/)
- **Apache Tomcat** (se puede instalar desde NetBeans)

## ⚙️ Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/sistema-usuarios-jsp.git
```

O descarga el ZIP y extrae el proyecto.

### 2. Abrir en NetBeans

1. Abre **NetBeans IDE**
2. Ve a **File** → **Open Project**
3. Selecciona la carpeta del proyecto
4. Haz clic en **Open Project**

### 3. Configurar Conexión a MySQL

**⚠️ IMPORTANTE:** Abre el archivo `src/datos/Conexion.java` y cambia estas líneas con tus credenciales de MySQL:

```java
private static final String URL = "jdbc:mysql://localhost:3306/sistema_usuarios";
private static final String USER = "root";              // ← Cambia esto
private static final String PASSWORD = "tu_contraseña"; // ← Cambia esto
```

Reemplaza:
- `root` con tu **usuario de MySQL**
- `tu_contraseña` con tu **contraseña de MySQL**

**💡 Nota:** La base de datos `sistema_usuarios` y la tabla `usuarios` **se crean automáticamente** la primera vez que ejecutes el proyecto. Solo necesitas cambiar el usuario y contraseña.

### 4. Ejecutar el Proyecto

1. **Clic derecho** en el proyecto → **Clean and Build**
2. **Clic derecho** en el proyecto → **Run** (o presiona **F6**)
3. Se abrirá el navegador automáticamente

## 🔐 Credenciales de Acceso

Usa estas credenciales para hacer login:

- **Correo:** `1234@gmail.com`
- **Clave:** `1234`

## 📁 Estructura del Proyecto

```
sistema-usuarios-jsp/
├── web/                        # Archivos JSP
│   ├── WEB-INF/lib/           # Librerías (MySQL Connector)
│   ├── login.jsp              # Página de login
│   ├── index.jsp              # Menú principal
│   ├── agregarUsuario.jsp     # Formulario registro/edición
│   ├── buscar.jsp             # Búsqueda de usuarios
│   └── confirmar.jsp          # Confirmación de operaciones
│
└── src/
    └── datos/
        └── Conexion.java      # ⚠️ CAMBIAR CREDENCIALES AQUÍ
```

## 📖 Cómo Usar

### Registrar Usuario
1. Login → **Nuevo**
2. Completa el formulario
3. Clic en **Siguiente** → **Confirmar y Guardar**

### Buscar Usuario
1. Login → **Buscar**
2. Ingresa el correo
3. Clic en **Buscar**

### Editar Usuario
1. Login → **Editar**
2. Ingresa el correo
3. Modifica los datos
4. Clic en **Siguiente** → **Guardar Cambios**

### Eliminar Usuario
1. Login → **Eliminar**
2. Ingresa el correo
3. Clic en **Buscar** → **Eliminar**

## 🚨 Solución de Problemas

### Error: "Cannot connect to database"
- Verifica que MySQL esté corriendo
- Revisa el usuario y contraseña en `Conexion.java`
- Verifica que el puerto sea 3306

### Error: "Port 8080 already in use"
- Cambia el puerto en NetBeans: **Tools** → **Servers** → **Connection** → **HTTP Port**

### Error: "Cannot find MySQL driver"
- Clic derecho en el proyecto → **Clean and Build**
- Verifica que `mysql-connector-java.jar` esté en `web/WEB-INF/lib/`

## 📝 Notas

- ✅ La base de datos y tabla se crean automáticamente
- ✅ Solo necesitas cambiar usuario y contraseña de MySQL
- ✅ El proyecto incluye todas las librerías necesarias
- ⚠️ Las contraseñas deben tener mínimo 4 caracteres
- ⚠️ Los correos son únicos en el sistema

## 👨‍💻 Autor

Carlos Emanuel Medina Flores 
ig: carrrlxs_

