<%-- 
    buscar.jsp

    Propósito:
    - Buscar un usuario por correo y, según la acción solicitada, permitir:
      ver los datos (buscar), preparar edición (editar) o preparar eliminación (eliminar).

    Qué debes saber (para principiantes):
    - Parámetros importantes recibidos por request:
        * accion: indica el modo de la página ("buscar" por defecto, "editar", "eliminar").
        * correo: correo que se busca (formulario).
        * eliminado, actualizado, error: parámetros de respuesta (para mostrar mensajes).
    - Variables importantes dentro del JSP:
        * correoBusqueda: el correo a buscar (viene del formulario).
        * mensaje / tipoMensaje: texto y estilo (Bootstrap) para mostrar alertas al usuario.
    - Sesión:
        * Cuando se encuentra el usuario, se almacenan atributos en session para
          que confirmar.jsp los lea (usuario_nombre, usuario_correo, usuario_clave, usuario_tipo).
    - Flujo resumido:
        1) Mostrar formulario para ingresar correo.
        2) Al enviar (POST) se consulta la tabla usuarios por ese correo.
        3) Si se encuentra:
           - Si accion=editar: redirige a agregarUsuario.jsp con los datos para editar.
           - Si accion=buscar o accion=eliminar: guarda datos en session y redirige a confirmar.jsp.
        4) Si no se encuentra, mostrar un mensaje de advertencia.
    - Notas prácticas:
        * El campo correo debe venir en formato válido (type="email" en el formulario).
        * El manejo de la BD se hace con datos.Conexion.getConnection().
        * En producción conviene usar prepared statements (ya usados aquí) y logging adecuado.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="datos.Conexion"%>
<%@page import="java.net.URLEncoder"%>

<%
    // Leer la acción solicitada (puede venir por GET o por el campo oculto en POST)
    String accion = request.getParameter("accion");

    // Título de la página según la acción (para mostrar en el HTML)
    String pageTitle = "Buscar Usuario";
    if ("editar".equals(accion)) {
        pageTitle = "Editar Usuario";
    }
    if ("eliminar".equals(accion)) {
        pageTitle = "Eliminar Usuario";
    }

    // Mensajes para el usuario (pueden venir por parámetros en la URL tras redirecciones)
    String mensaje = "";
    String tipoMensaje = "danger";

    String eliminadoParam = request.getParameter("eliminado");
    if ("exitoso".equals(eliminadoParam)) {
        mensaje = "Usuario eliminado correctamente.";
        tipoMensaje = "success";
    }

    // Mensaje cuando una edición fue exitosa (se redirige a esta página con actualizado=exitoso)
    String actualizadoParam = request.getParameter("actualizado");
    if ("exitoso".equals(actualizadoParam)) {
        mensaje = "Usuario actualizado correctamente.";
        tipoMensaje = "success";
    }

    // Mensajes de error genéricos (por ejemplo: no encontrado)
    String errorParam = request.getParameter("error");
    if ("noencontrado".equals(errorParam)) {
        mensaje = "Error: La operación falló porque el usuario no fue encontrado.";
        tipoMensaje = "warning";
    }

    // Valor que aparece en el input del formulario (se conserva tras submit para mejor UX)
    String correoBusqueda = request.getParameter("correo") != null ? request.getParameter("correo") : "";

    // Si el método es POST, procesamos la búsqueda
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Releer la acción enviada desde el campo oculto del formulario POST
        accion = request.getParameter("accion");

        // Validación simple: el usuario debe escribir un correo
        if (correoBusqueda.trim().isEmpty()) {
            mensaje = "Por favor, ingrese un correo para buscar.";
            tipoMensaje = "warning";
        } else {
            // Consulta a la base de datos para buscar por correo
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                conn = Conexion.getConnection();
                ps = conn.prepareStatement("SELECT * FROM usuarios WHERE correo = ?");
                ps.setString(1, correoBusqueda);
                rs = ps.executeQuery();

                if (rs.next()) {
                    // Si encontramos el usuario...
                    if ("editar".equals(accion)) {
                        // Preparar URL para abrir el formulario de edición (agregarUsuario.jsp)
                        // Se pasan los valores por query string para precargar el formulario.
                        // URLEncoder.encode evita problemas con caracteres especiales.
                        String url = String.format("agregarUsuario.jsp?nombre=%s&correo=%s&clave=%s&tipo=%s&source=editar",
                                URLEncoder.encode(rs.getString("nombre"), "UTF-8"),
                                URLEncoder.encode(rs.getString("correo"), "UTF-8"),
                                URLEncoder.encode(rs.getString("clave"), "UTF-8"),
                                URLEncoder.encode(rs.getString("tipo"), "UTF-8")
                        );
                        // Redirigir a la página de edición con los datos cargados
                        response.sendRedirect(url);
                        return;
                    } else {
                        // Para 'buscar' o 'eliminar' guardamos los datos en sesión
                        // para que confirmar.jsp muestre la información y permita confirmar.
                        session.setAttribute("source", accion); // "buscar" o "eliminar"
                        session.setAttribute("usuario_nombre", rs.getString("nombre"));
                        session.setAttribute("usuario_correo", rs.getString("correo"));
                        session.setAttribute("usuario_clave", rs.getString("clave"));
                        session.setAttribute("usuario_tipo", rs.getString("tipo"));

                        // Ir a la página intermedia de confirmación
                        response.sendRedirect("confirmar.jsp");
                        return;
                    }
                } else {
                    // Si no existe el usuario con ese correo, informar al usuario
                    mensaje = "No se encontró ningún usuario con el correo: " + correoBusqueda;
                    tipoMensaje = "warning";
                }
            } catch (SQLException e) {
                // En producción se recomienda usar un logger en lugar de printStackTrace
                mensaje = "Error en la base de datos: " + e.getMessage();
                tipoMensaje = "danger";
                e.printStackTrace();
            } finally {
                // Siempre cerrar ResultSet, PreparedStatement y la conexión para evitar fugas
                if (rs != null) try {
                    rs.close();
                } catch (SQLException e) {
                }
                if (ps != null) try {
                    ps.close();
                } catch (SQLException e) {
                }
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
        <title><%= pageTitle%></title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f0f2f5;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }
            .search-container {
                background: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                max-width: 450px;
                width: 100%;
                padding: 40px;
            }
            .search-title {
                text-align: center;
                margin-bottom: 30px;
                color: #333;
                font-weight: 600;
            }
            .btn-buscar {
                background-color: #0d6efd;
                border: none;
                color: white;
                padding: 12px;
                font-weight: 500;
            }
            .btn-cancelar {
                background-color: #6c757d;
                border: none;
                color: white;
                padding: 12px;
                font-weight: 500;
            }
            label {
                font-weight: 500;
                color: #555;
                margin-bottom: 8px;
            }
        </style>
    </head>
    <body>
        <div class="search-container">
            <h2 class="search-title"><%= pageTitle%> por Correo</h2>

            <%-- Mostrar mensajes (éxito/advertencia/error) si existen --%>
            <% if (!mensaje.isEmpty()) {%>
            <div class="alert alert-<%= tipoMensaje%> alert-dismissible fade show" role="alert">
                <%= mensaje%>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% }%>

            <%-- Formulario: el campo oculto 'accion' preserva el modo (buscar/editar/eliminar) --%>
            <form method="POST">
                <input type="hidden" name="accion" value="<%= accion%>">
                <div class="mb-3">
                    <label for="correo" class="form-label">Correo</label>
                    <input type="email" class="form-control" id="correo" name="correo" placeholder="Ingrese el correo a buscar" value="<%= correoBusqueda%>" required>
                </div>
                <div class="d-grid gap-3 mt-4">
                    <button type="submit" class="btn btn-buscar">Buscar</button>
                    <button type="button" class="btn btn-cancelar" onclick="location.href = 'index.jsp'">Cancelar</button>
                </div>
            </form>
        </div>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
