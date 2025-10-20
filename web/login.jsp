<%-- 
    login.jsp

    Propósito:
    - Permitir que un usuario existente inicie sesión (login).
    - Verifica correo y contraseña contra la tabla 'usuarios' en la base de datos.
    - Si las credenciales son correctas guarda datos básicos en la sesión y redirige al menú (index.jsp).

    Variables / cosas importantes (explicadas brevemente):
    - request.getParameter("correo"), request.getParameter("clave")
        -> Valores enviados por el formulario (email y contraseña).
    - mensaje / tipoMensaje
        -> Texto y tipo (Bootstrap) para mostrar alertas al usuario en la interfaz.
    - Conexion.getConnection()
        -> Método utilitario para obtener una conexión JDBC a la base de datos.
    - session.setAttribute(...)
        -> Se usan para guardar información del usuario en la sesión tras login exitoso:
           usuarioId, usuarioNombre, usuarioCorreo.
    - Seguridad importante:
        -> En este ejemplo las contraseñas se comparan en texto plano. En producción NUNCA
           almacenes ni compares contraseñas en texto plano: debes usar hashing (bcrypt/argon2)
           y comparar hashes. También considera usar HTTPS y medidas contra ataques de fuerza bruta.
    
    Flujo resumido:
    1) Si el método HTTP es POST se toman correo y clave del formulario.
    2) Se valida que no estén vacíos; si faltan, se muestra un aviso.
    3) Si están presentes, se consulta la tabla 'usuarios' buscando coincidencia correo+clave.
    4) Si se encuentra una fila -> login exitoso: se guardan datos en sesión y se redirige a index.jsp.
    5) Si no se encuentra -> se muestra mensaje de credenciales incorrectas.
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="datos.Conexion"%>

<%
    // mensaje: texto a mostrar en pantalla (vacío si no hay mensaje)
    // tipoMensaje: clase Bootstrap para el estilo de la alerta (warning, danger, success...)
    String mensaje = "";
    String tipoMensaje = "";

    // Procesar el formulario solo si es una petición POST
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Valores enviados por el formulario
        String correo = request.getParameter("correo");
        String clave = request.getParameter("clave");

        // Validación básica: no permitir campos vacíos
        if (correo == null || clave == null || correo.trim().isEmpty() || clave.trim().isEmpty()) {
            mensaje = "Por favor complete todos los campos";
            tipoMensaje = "warning";
        } else {
            Connection conn = null;
            try {
                // Obtener conexión a la base de datos (Conexion.getConnection() encapsula la configuración)
                conn = Conexion.getConnection();

                // Consulta preparada para evitar inyección SQL
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT * FROM usuarios WHERE correo = ? AND clave = ?");
                ps.setString(1, correo);
                ps.setString(2, clave);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    // LOGIN EXITOSO:
                    // Guardar datos mínimos del usuario en la sesión para identificarlo en otras páginas
                    session.setAttribute("usuarioId", rs.getInt("id"));
                    session.setAttribute("usuarioNombre", rs.getString("nombre"));
                    session.setAttribute("usuarioCorreo", rs.getString("correo"));

                    // Redirigir al menú principal
                    response.sendRedirect("index.jsp");
                    return;
                } else {
                    // Credenciales incorrectas: no existe combinación correo+clave
                    mensaje = "Usuario o contraseña incorrectos";
                    tipoMensaje = "danger";
                }

                // Cerrar recursos relacionados con la consulta
                rs.close();
                ps.close();

            } catch (SQLException e) {
                // Mostrar un mensaje genérico al usuario y registrar detalle en consola
                mensaje = "Error al conectar con la base de datos: " + e.getMessage();
                tipoMensaje = "danger";
                e.printStackTrace();
            } finally {
                // Liberar la conexión (si existe) usando el helper de la clase Conexion
                Conexion.closeConnection(conn);
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Iniciar Sesión</title>
        <!-- Bootstrap 5 CSS -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f0f2f5;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .login-container {
                background: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                max-width: 400px;
                width: 100%;
                padding: 40px;
            }

            .login-title {
                text-align: center;
                margin-bottom: 30px;
                color: #333;
                font-weight: 600;
            }

            .form-control:focus {
                border-color: #4a90e2;
                box-shadow: 0 0 0 0.2rem rgba(74, 144, 226, 0.25);
            }

            .btn-login {
                background-color: #4a90e2;
                border: none;
                color: white;
                padding: 12px;
                font-weight: 500;
                transition: background-color 0.2s;
            }

            .btn-login:hover {
                background-color: #357abd;
                color: white;
            }

            .alert {
                border-radius: 5px;
                margin-bottom: 20px;
            }
        </style>
    </head>
    <body>
        <div class="login-container">
            <h2 class="login-title">Iniciar Sesión</h2>

            <%-- Mostrar alerta si hay mensaje --%>
            <% if (!mensaje.isEmpty()) {%>
            <div class="alert alert-<%= tipoMensaje%> alert-dismissible fade show" role="alert">
                <%= mensaje%>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% }%>

            <form method="POST">
                <div class="mb-3">
                    <label for="correo" class="form-label">Correo Electrónico</label>
                    <input type="email" class="form-control" id="correo" name="correo" 
                           placeholder="correo@ejemplo.com" required>
                </div>

                <div class="mb-4">
                    <label for="clave" class="form-label">Contraseña</label>
                    <input type="password" class="form-control" id="clave" name="clave" 
                           placeholder="Ingrese su contraseña" required>
                </div>

                <button type="submit" class="btn btn-login w-100">
                    Iniciar Sesión
                </button>
            </form>
        </div>

        <!-- Bootstrap 5 JS -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
    </body>
</html>