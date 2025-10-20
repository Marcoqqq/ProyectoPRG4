<%-- 
    index.jsp
    Propósito: Menú principal de la aplicación. Verifica sesión, permite cerrar sesión
    y muestra opciones para gestionar usuarios.

    Variables / cosas importantes (explicadas brevemente):
    - session.getAttribute("usuarioNombre"):
        -> Valor: nombre del usuario guardado al hacer login.
        -> Si es null: el usuario no está autenticado y se redirige a login.jsp.
    - request.getParameter("accion"):
        -> Se usa para acciones sencillas desde la URL (ej.: ?accion=salir).
    - mensaje / tipoMensaje:
        -> Texto y tipo (bootstrap) para mostrar alertas en la UI.
    - registroParam:
        -> Parámetro opcional para indicar estados (ej.: ?registro=exitoso).
    
    Flujo resumido:
    1) Se comprueba que exista una sesión con "usuarioNombre". Si no, se redirige a login.jsp.
    2) Si llega ?accion=salir se invalida la sesión (logout) y se vuelve a login.jsp.
    3) Se prepara un mensaje si viene registro=exitoso.
    4) Se muestra la interfaz con botones que redirigen a otras páginas (agregar, buscar, editar, eliminar).
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1) Verificar sesión: si no hay usuario logueado, obligar a login.
    // session.getAttribute("usuarioNombre") debe establecerse en el proceso de login.
    if (session.getAttribute("usuarioNombre") == null) {
        // Redirigir al formulario de login y detener ejecución de esta página
        response.sendRedirect("login.jsp");
        return;
    }

    // 2) Leer acción enviada por parámetro (ejemplo: index.jsp?accion=salir)
    String accion = request.getParameter("accion");
    if ("salir".equals(accion)) {
        // session.invalidate(): borra todos los datos de la sesión (logout)
        session.invalidate();
        response.sendRedirect("login.jsp");
        return;
    }

    // 3) Preparar mensajes para la vista (por ejemplo, después de registrar un usuario)
    // mensaje: texto que se mostrará; tipoMensaje: clase Bootstrap (success, danger, warning...)
    String mensaje = "";
    String tipoMensaje = "success";
    String registroParam = request.getParameter("registro");
    if ("exitoso".equals(registroParam)) {
        // Si la página se abre con ?registro=exitoso mostramos un aviso de éxito
        mensaje = "Usuario registrado correctamente.";
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Menú Principal</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
        <style>
            /* Estilos visuales simples para centrar y dar estilo al menú */
            body {
                background-color: #f5f5f5;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .menu-container {
                background: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                padding: 40px;
                max-width: 400px;
                width: 100%;
            }
            .menu-title {
                text-align: center;
                margin-bottom: 30px;
                color: #333;
                font-weight: 600;
            }
            .menu-btn {
                width: 100%;
                padding: 15px;
                margin-bottom: 15px;
                border: 2px solid #e0e0e0;
                background-color: white;
                color: #333;
                font-weight: 500;
                border-radius: 8px;
                transition: all 0.3s;
                text-align: center;
            }
            .menu-btn:hover {
                background-color: #4a90e2;
                color: white;
                border-color: #4a90e2;
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(74, 144, 226, 0.3);
            }
        </style>
    </head>
    <body>
        <div class="menu-container">
            <h2 class="menu-title">Menu Principal</h2>

            <!-- Mostrar el nombre del usuario en la sesión -->
            <p class="text-center mb-4 text-muted">
                Bienvenido <%= session.getAttribute("usuarioNombre")%>
            </p>

            <%-- Si hay un mensaje (por ejemplo registro exitoso), mostrar alerta Bootstrap --%>
            <% if (!mensaje.isEmpty()) {%>
            <div class="alert alert-<%= tipoMensaje%> alert-dismissible fade show" role="alert">
                <%= mensaje%>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% }%>

            <!--
                Botones del menú:
                - Nuevo -> agregarUsuario.jsp (registro)
                - Buscar -> buscar.jsp?accion=buscar (buscar por correo/nombre)
                - Editar -> buscar.jsp?accion=editar (buscar y editar)
                - Eliminar -> buscar.jsp?accion=eliminar (buscar y eliminar)
                - Listado -> sin enlace (poner la ruta si existe)
                - Salir -> recarga esta página con accion=salir para invalidar sesión
            -->
            <button type="button" class="btn menu-btn" onclick="location.href = 'agregarUsuario.jsp'">Nuevo</button>
            <button type="button" class="btn menu-btn" onclick="location.href = 'buscar.jsp?accion=buscar'">Buscar</button>
            <button type="button" class="btn menu-btn" onclick="location.href = 'buscar.jsp?accion=editar'">Editar</button>
            <button type="button" class="btn menu-btn" onclick="location.href = 'buscar.jsp?accion=eliminar'">Eliminar</button>

            <!--
                Nota: "Listado" no tiene destino en el código original.
                Si tienes una página para listar usuarios añade la URL dentro de location.href.
            -->
            <button type="button" class="btn menu-btn" onclick="/* completar: location.href='listado.jsp' */">Listado</button>

            <!-- Salir: al hacer click navega a index.jsp?accion=salir y esto detona session.invalidate() arriba -->
            <button type="button" class="btn menu-btn" onclick="location.href = 'index.jsp?accion=salir'">Salir</button>
        </div>

        <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
