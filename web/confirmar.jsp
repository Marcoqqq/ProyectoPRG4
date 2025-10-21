<%-- 
    confirmar.jsp

    Propósito general:
    - Página intermedia para "confirmar" acciones sobre usuarios: registro, edición,
      visualización (buscar) y eliminación.
    - Muestra los datos recopilados (desde sesión) y presenta botones para
      confirmar, cancelar o regresar según el modo.

    Variables / cosas importantes (rápido):
    - session.getAttribute("source"):
        -> Indica el modo actual: "register", "editar", "buscar", "eliminar".
        -> Se establece en páginas previas (ej.: agregarUsuario.jsp o buscar.jsp).
    - Atributos temporales en sesión (usados según modo):
        -> temp_nombre, temp_correo, temp_clave, temp_tipo (registro/edición)
        -> original_correo (edición: correo anterior del usuario)
        -> usuario_nombre, usuario_correo, usuario_clave, usuario_tipo (modo buscar/eliminar)
    - request.getParameter("accion"):
        -> Valor enviado por los botones del formulario para decidir la acción
          (confirmar, cancelar, regresar, eliminar_confirmado, menu, etc.)
    - Conexion.getConnection():
        -> Método utilitario para obtener conexión a la base de datos.

    Flujo resumido:
    1) Se lee el modo desde session ("source") y se cargan los datos apropiados desde sesión.
    2) Si faltan datos esenciales (ej.: nombre), redirige al menú principal.
    3) Según el modo y el parámetro "accion" se realizan operaciones:
       - register: insertar nuevo usuario en BD al confirmar.
       - editar: actualizar todos los campos (nombre, correo, clave, tipo) usando original_correo.
       - buscar: solo navegación (regresar o volver al menú).
       - eliminar: borrar el usuario al confirmar.
    4) Después de cada operación la sesión se limpia de los atributos temporales y se redirige.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="datos.Conexion"%>
<%
// ======= Lectura del modo (source) desde la sesión =======
    String source = (String) session.getAttribute("source");
    boolean isRegisterMode = "register".equals(source);
    boolean isSearchMode = "buscar".equals(source);
    boolean isEditMode = "editar".equals(source);
    boolean isDeleteMode = "eliminar".equals(source);
    boolean isListaMode = "lista".equals(source);

    // Variables que mostrarán los datos del usuario en la vista
    String nombre = "", correo = "", clave = "", tipo = "", original_correo = "";
    String pageTitle = "", labelClave = "";

    // Cargar datos desde sesión dependiendo del modo
    if (isRegisterMode || isEditMode) {
        // En registro/edición los datos vienen como "temp_*" (temporales)
        nombre = (String) session.getAttribute("temp_nombre");
        correo = (String) session.getAttribute("temp_correo");
        clave = (String) session.getAttribute("temp_clave");
        tipo = (String) session.getAttribute("temp_tipo");

        if (isEditMode) {
            pageTitle = "Confirmar Edición";
            original_correo = (String) session.getAttribute("original_correo"); // correo previo
            labelClave = "Nueva Clave";
        } else {
            pageTitle = "Confirmar Registro";
            labelClave = "Clave";
        }
    } else {
        // En búsqueda/eliminar los datos se guardaron como "usuario_*" al cargar el usuario
        nombre = (String) session.getAttribute("usuario_nombre");
        correo = (String) session.getAttribute("usuario_correo");
        clave = (String) session.getAttribute("usuario_clave");
        tipo = (String) session.getAttribute("usuario_tipo");

        if (isSearchMode) {
            pageTitle = "Datos del Usuario";
        }
        if (isDeleteMode) {
            pageTitle = "¿Eliminar este Usuario?";
        }
        labelClave = "Clave Registrada";
    }

    // Si no hay un nombre válido, no procede; volvemos al menú principal
    if (nombre == null || nombre.isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Acción enviada por los formularios (confirmar, cancelar, eliminar_confirmado, etc.)
    String accion = request.getParameter("accion");

    // ============ MODO REGISTRO ============
    if (isRegisterMode) {
        if ("confirmar".equals(accion)) {
            // Insertar el nuevo usuario en la base de datos
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                conn = Conexion.getConnection();
                ps = conn.prepareStatement(
                        "INSERT INTO usuarios (nombre, correo, clave, tipo) VALUES (?, ?, ?, ?)");
                ps.setString(1, nombre);
                ps.setString(2, correo);
                ps.setString(3, clave);
                ps.setString(4, tipo);
                ps.executeUpdate();

                // Limpiar atributos temporales y volver al índice con mensaje de éxito
                session.removeAttribute("source");
                session.removeAttribute("temp_nombre");
                session.removeAttribute("temp_correo");
                session.removeAttribute("temp_clave");
                session.removeAttribute("temp_tipo");

                response.sendRedirect("index.jsp?registro=exitoso");
                return;
            } catch (SQLException e) {
                // Si el error es duplicado de correo (código MySQL 1062), redirigir para corregir
                if (e.getErrorCode() == 1062) {
                    response.sendRedirect("agregarUsuario.jsp?error="
                            + java.net.URLEncoder.encode("El correo ya está registrado.", "UTF-8"));
                    return;
                }
                // Para otros errores se imprime el stack (en desarrollo). En producción usar logger.
                e.printStackTrace();
            } finally {
                if (ps != null) try {
                    ps.close();
                } catch (SQLException e) {
                }
                Conexion.closeConnection(conn);
            }
        }
        if ("cancelar".equals(accion)) {
            // Volver al formulario de registro con los datos cargados para corregir
            String url = String.format(
                    "agregarUsuario.jsp?nombre=%s&correo=%s&clave=%s&confirmarClave=%s&tipo=%s",
                    java.net.URLEncoder.encode(nombre, "UTF-8"),
                    java.net.URLEncoder.encode(correo, "UTF-8"),
                    java.net.URLEncoder.encode(clave, "UTF-8"),
                    java.net.URLEncoder.encode(clave, "UTF-8"),
                    java.net.URLEncoder.encode(tipo, "UTF-8"));
            response.sendRedirect(url);
            return;
        }
    }

    // ============ MODO EDICIÓN ============
    if (isEditMode) {
        if ("confirmar".equals(accion)) {
            // Actualizar todos los campos del usuario identificado por original_correo
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                conn = Conexion.getConnection();
                ps = conn.prepareStatement(
                        "UPDATE usuarios SET nombre = ?, correo = ?, clave = ?, tipo = ? WHERE correo = ?");
                ps.setString(1, nombre);
                ps.setString(2, correo);  // nuevo correo (puede ser igual)
                ps.setString(3, clave);
                ps.setString(4, tipo);
                ps.setString(5, original_correo);  // buscar por correo original

                int rowsAffected = ps.executeUpdate();

                // Limpiar atributos temporales de edición
                session.removeAttribute("source");
                session.removeAttribute("temp_nombre");
                session.removeAttribute("temp_correo");
                session.removeAttribute("temp_clave");
                session.removeAttribute("temp_tipo");
                session.removeAttribute("original_correo");

                // Redirigir según si se actualizó algún registro
                if (rowsAffected > 0) {
                    response.sendRedirect("buscar.jsp?accion=editar&actualizado=exitoso");
                } else {
                    response.sendRedirect("buscar.jsp?accion=editar&error=noencontrado");
                }
                return;
            } catch (SQLException e) {
                // En caso de error (p. ej. correo duplicado) se muestra stack en consola
                e.printStackTrace();
            } finally {
                if (ps != null) try {
                    ps.close();
                } catch (SQLException e) {
                }
                Conexion.closeConnection(conn);
            }
        }
        if ("cancelar".equals(accion)) {
            // Volver al formulario de edición (agregarUsuario.jsp) con los datos actuales para corregir
            String url = String.format(
                    "agregarUsuario.jsp?nombre=%s&correo=%s&clave=%s&tipo=%s&source=editar",
                    java.net.URLEncoder.encode(nombre, "UTF-8"),
                    java.net.URLEncoder.encode(correo, "UTF-8"),
                    java.net.URLEncoder.encode(clave, "UTF-8"),
                    java.net.URLEncoder.encode(tipo, "UTF-8"));
            response.sendRedirect(url);
            return;
        }
    }

    // ============ MODO BUSCAR ============
    if (isSearchMode) {
        // Botones: regresar -> vuelve a la búsqueda; menu -> vuelve al índice
        if ("regresar".equals(accion) || "menu".equals(accion)) {
            // Limpiar atributos de usuario temporal en sesión
            session.removeAttribute("source");
            session.removeAttribute("usuario_nombre");
            session.removeAttribute("usuario_correo");
            session.removeAttribute("usuario_clave");
            session.removeAttribute("usuario_tipo");

            if ("regresar".equals(accion)) {
                response.sendRedirect("buscar.jsp?accion=" + source);
            }
            if ("menu".equals(accion)) {
                response.sendRedirect("index.jsp");
            }
            return;
        }
    }

    // ============ MODO ELIMINAR ============
    if (isDeleteMode) {
        if ("eliminar_confirmado".equals(accion)) {
            // Borrar el usuario identificado por correo
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                conn = Conexion.getConnection();
                ps = conn.prepareStatement("DELETE FROM usuarios WHERE correo = ?");
                ps.setString(1, correo);
                int rowsAffected = ps.executeUpdate();

                // Limpiar atributos temporales relacionados
                session.removeAttribute("source");
                session.removeAttribute("usuario_nombre");
                session.removeAttribute("usuario_correo");
                session.removeAttribute("usuario_clave");
                session.removeAttribute("usuario_tipo");

                if (rowsAffected > 0) {
                    response.sendRedirect("buscar.jsp?accion=eliminar&eliminado=exitoso");
                } else {
                    response.sendRedirect("buscar.jsp?accion=eliminar&error=noencontrado");
                }
                return;
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (ps != null) try {
                    ps.close();
                } catch (SQLException e) {
                }
                Conexion.closeConnection(conn);
            }
        }
        if ("regresar".equals(accion)) {
            // Volver a la pantalla de búsqueda en modo eliminar
            session.removeAttribute("source");
            session.removeAttribute("usuario_nombre");
            session.removeAttribute("usuario_correo");
            session.removeAttribute("usuario_clave");
            session.removeAttribute("usuario_tipo");
            response.sendRedirect("buscar.jsp?accion=eliminar");
            return;
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
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <style>
            .btn-eliminar {
                background-color: #dc3545;
                border: none;
                color: white;
                padding: 12px;
                font-weight: 500;
            }
            .btn-regresar {
                background-color: #6c757d;
                border: none;
                color: white;
                padding: 12px;
                font-weight: 500;
            }
            .btn-confirmar {
                background-color: #28a745;
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
            .btn-primary {
                background-color: #0d6efd;
                border: none;
            }
            .btn-secondary {
                background-color: #6c757d;
                border: none;
            }
            body {
                background-color: #f0f2f5;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }
            .confirmar-container {
                background: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                max-width: 500px;
                width: 100%;
                padding: 40px;
            }
            .confirmar-title {
                text-align: center;
                margin-bottom: 30px;
                color: #333;
                font-weight: 600;
            }
            .info-box {
                background-color: #f8f9fa;
                border: 1px solid #dee2e6;
                border-radius: 8px;
                padding: 15px;
                margin-bottom: 15px;
            }
            .info-label {
                font-weight: 600;
                color: #495057;
                margin-bottom: 5px;
            }
            .info-value {
                color: #212529;
                font-size: 1.05rem;
                word-break: break-all;
            }
            .toggle-password-icon {
                cursor: pointer;
                color: #6c757d;
            }
        </style>
    </head>
    <body>
        <div class="confirmar-container">
            <h2 class="confirmar-title"><%= pageTitle%></h2>

            <%-- Si estamos editando y el correo cambió, mostrar nota informativa --%>
            <% if (isEditMode && original_correo != null && !original_correo.equals(correo)) {%>
            <div class="alert alert-info">
                <strong>Nota:</strong> El correo será cambiado de <strong><%= original_correo%></strong> a <strong><%= correo%></strong>
            </div>
            <% }%>

            <div class="info-box">
                <div class="info-label">Nombre:</div>
                <div class="info-value"><%= nombre%></div>
            </div>
            <div class="info-box">
                <div class="info-label">Correo:</div>
                <div class="info-value"><%= correo%></div>
            </div>

            <%-- Mostrar la clave de forma oculta por defecto; se puede mostrar con el ojo --%>
            <% if (!isDeleteMode) {%>
            <div class="info-box d-flex justify-content-between align-items-center">
                <div>
                    <div class="info-label"><%= labelClave%>:</div>
                    <div class="info-value" id="passwordDisplay" data-password="<%= clave%>">
                        <%= "●".repeat(clave.length())%>
                    </div>
                </div>
                <i class="bi bi-eye-slash fs-4 toggle-password-icon" id="toggleIcon"></i>
            </div>
            <% }%>

            <div class="info-box">
                <div class="info-label">Tipo:</div>
                <div class="info-value" style="text-transform: capitalize;"><%= tipo%></div>
            </div>

            <div class="row mt-4">
                <%-- Botones cambian según el modo --%>
                <% if (isRegisterMode || isEditMode) {%>
                <div class="col-md-6 mb-2">
                    <form method="POST" class="d-grid">
                        <input type="hidden" name="accion" value="confirmar">
                        <button type="submit" class="btn btn-confirmar"><%= isEditMode ? "Guardar Cambios" : "Confirmar y Guardar"%></button>
                    </form>
                </div>
                <div class="col-md-6 mb-2">
                    <form method="POST" class="d-grid">
                        <input type="hidden" name="accion" value="cancelar">
                        <button type="submit" class="btn btn-cancelar">Cancelar y Corregir</button>
                    </form>
                </div>
                <% } else if (isSearchMode) { %>
                <div class="col-md-6 mb-2">
                    <form method="POST" class="d-grid">
                        <input type="hidden" name="accion" value="regresar">
                        <button type="submit" class="btn btn-primary">Regresar</button>
                    </form>
                </div>
                <div class="col-md-6 mb-2">
                    <form method="POST" class="d-grid">
                        <input type="hidden" name="accion" value="menu">
                        <button type="submit" class="btn btn-secondary">Menú</button>
                    </form>
                </div>
                <% } else if (isDeleteMode) { %>
                <div class="col-md-6 mb-2">
                    <form method="POST" class="d-grid">
                        <input type="hidden" name="accion" value="eliminar_confirmado">
                        <button type="submit" class="btn btn-eliminar">Eliminar</button>
                    </form>
                </div>
                <div class="col-md-6 mb-2">
                    <form method="POST" class="d-grid">
                        <input type="hidden" name="accion" value="regresar">
                        <button type="submit" class="btn btn-regresar">Regresar</button>
                    </form>
                </div>
                <% }%>
            </div>
        </div>

        <script>
            // Pequeña utilidad para alternar visualización de la contraseña:
            // - El texto real se guarda en data-password del div #passwordDisplay.
            // - Por defecto se muestran puntos; al hacer click en el icono se revela u oculta.
            const toggleIcon = document.getElementById('toggleIcon');
            if (toggleIcon) {
                toggleIcon.addEventListener('click', function () {
                    const passwordDisplay = document.getElementById('passwordDisplay');
                    const realPassword = passwordDisplay.dataset.password;
                    const isHidden = passwordDisplay.textContent.includes('●');
                    if (isHidden) {
                        passwordDisplay.textContent = realPassword; // mostrar contraseña real
                        this.classList.replace('bi-eye-slash', 'bi-eye');
                    } else {
                        passwordDisplay.textContent = '●'.repeat(realPassword.length); // ocultar
                        this.classList.replace('bi-eye', 'bi-eye-slash');
                    }
                });
            }
        </script>
    </body>
</html>
