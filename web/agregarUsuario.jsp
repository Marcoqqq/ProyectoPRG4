<%-- 
    agregarUsuario.jsp
    Propósito: formulario para registrar o editar un usuario. Valida datos, verifica correo duplicado
    y guarda temporalmente los datos en la sesión antes de redirigir a confirmar.jsp.

    Variables / conceptos importantes:
    - source: indica el origen/modo. "editar" = estamos editando, otro valor = registro nuevo.
    - isEditMode: booleano derivado de source.
    - paso: controla el flujo. "validar" se usa cuando se envía el formulario (POST).
    - session: se usa para almacenar temporalmente datos antes de confirmar (confirmar.jsp).
    - Conexion.getConnection(): método de la clase datos.Conexion para obtener la conexión a la BD.
    - originalCorreo: en edición, contiene el correo previo del usuario para permitir no marcarlo como duplicado.

    Flujo resumido:
    1) GET: muestra el formulario (posible prellenado si vienen parámetros).
    2) POST con paso=validar: valida campos, valida contraseñas y longitudes,
    verifica que el correo no exista en la BD (salvo si es el mismo en modo editar).
    3) Si todo es válido, guarda los datos en session y redirige a confirmar.jsp.
    4) Si hay errores, muestra mensaje y vuelve a mostrar el formulario con los valores.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="datos.Conexion"%>

<%
    // --- Lógica de la Página ---

    // 1. Determinar el modo y los títulos
    // 'source' indica si venimos de una acción de editar o registro nuevo.
    String source = request.getParameter("source");
    boolean isEditMode = "editar".equals(source);
    String pageTitle = isEditMode ? "Editar Usuario" : "Registro de Usuario";
    String buttonText = "Siguiente";

    // 2. Declarar variables para los datos del formulario
    // Se usan para rellenar el formulario si ocurre un error y para procesar la inserción/edición.
    String nombre = "", correo = "", clave = "", confirmarClave = "", tipo = "", originalCorreo = "";
    String mensaje = "", tipoMensaje = "danger";
    
    // 3. Distinguir entre el envío del formulario (POST) y la carga inicial (GET)
    // 'paso' sirve para indicar que el formulario fue enviado y debe validarse.
    String paso = request.getParameter("paso");
    
    if ("validar".equals(paso) && "POST".equalsIgnoreCase(request.getMethod())) {
        // **PROCESANDO FORMULARIO ENVIADO**
        // Tomamos los valores enviados por el formulario
        nombre = request.getParameter("nombre");
        correo = request.getParameter("correo");
        clave = request.getParameter("clave");
        confirmarClave = request.getParameter("confirmarClave");
        tipo = request.getParameter("tipo");
        source = request.getParameter("source");
        isEditMode = "editar".equals(source);
        originalCorreo = request.getParameter("correo_original");

        // --- Lógica de Validación ---
        // Validaciones básicas: campos obligatorios, coincidencia de contraseñas, longitud mínima.
        boolean valido = true;
        if (nombre == null || nombre.trim().isEmpty() || correo == null || correo.trim().isEmpty() ||
            clave == null || clave.trim().isEmpty() || confirmarClave == null || confirmarClave.trim().isEmpty() ||
            tipo == null || tipo.trim().isEmpty()) {
            mensaje = "Por favor complete todos los campos";
            tipoMensaje = "warning";
            valido = false;
        } else if (!clave.equals(confirmarClave)) {
            mensaje = "Las contraseñas no coinciden";
            tipoMensaje = "danger";
            valido = false;
        } else if (clave.length() < 4) {
            mensaje = "La contraseña debe tener al menos 4 caracteres";
            tipoMensaje = "warning";
            valido = false;
        }

        // Validación de correo duplicado en la base de datos
        if (valido) {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                conn = Conexion.getConnection();
                
                if (isEditMode) {
                    // En modo edición: si el correo fue cambiado, verificar duplicados.
                    if (!correo.equals(originalCorreo)) {
                        ps = conn.prepareStatement("SELECT COUNT(*) FROM usuarios WHERE correo = ?");
                        ps.setString(1, correo);
                        rs = ps.executeQuery();
                        if (rs.next() && rs.getInt(1) > 0) {
                            // Ya existe otro usuario con ese correo
                            mensaje = "El correo electrónico ya está registrado"; 
                            tipoMensaje = "danger"; 
                            valido = false;
                        }
                    }
                } else {
                    // En registro nuevo: verificar que no exista ese correo
                    ps = conn.prepareStatement("SELECT COUNT(*) FROM usuarios WHERE correo = ?");
                    ps.setString(1, correo);
                    rs = ps.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
                        mensaje = "El correo electrónico ya está registrado"; 
                        tipoMensaje = "danger"; 
                        valido = false;
                    }
                }
            } catch (SQLException e) {
                // En caso de error de BD, informar mensaje genérico y marcar como no válido.
                mensaje = "Error al verificar el correo: " + e.getMessage(); 
                valido = false;
                e.printStackTrace();
            } finally {
                // Cerrar recursos para evitar fugas de conexión
                if(rs != null) try { rs.close(); } catch (SQLException e) {}
                if(ps != null) try { ps.close(); } catch (SQLException e) {}
                Conexion.closeConnection(conn);
            }
        }
        
        if (valido) {
            // Si todo es válido, guardamos temporalmente los datos en la sesión
            // y redirigimos a confirmar.jsp, donde se puede revisar antes de guardar definitivamente.
            session.setAttribute("source", isEditMode ? "editar" : "register");
            session.setAttribute("temp_nombre", nombre);
            session.setAttribute("temp_correo", correo);
            session.setAttribute("temp_clave", clave);
            session.setAttribute("temp_tipo", tipo);
            if (isEditMode && originalCorreo != null && !originalCorreo.trim().isEmpty()) {
                session.setAttribute("original_correo", originalCorreo);
            }
            
            response.sendRedirect("confirmar.jsp");
            return;
        }

    } else {
        // **CARGA INICIAL DE LA PÁGINA (GET)**
        // Si venimos con parámetros (por ejemplo desde buscar.jsp para editar), prellenamos.
        mensaje = request.getParameter("error") != null ? request.getParameter("error") : "";
        nombre = request.getParameter("nombre") != null ? request.getParameter("nombre") : "";
        correo = request.getParameter("correo") != null ? request.getParameter("correo") : "";
        clave = request.getParameter("clave") != null ? request.getParameter("clave") : "";
        confirmarClave = clave;
        tipo = request.getParameter("tipo") != null ? request.getParameter("tipo") : "";
        originalCorreo = isEditMode ? correo : "";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %></title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background-color: #f0f2f5; min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }
        .registro-container { background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); max-width: 500px; width: 100%; padding: 40px; }
        .registro-title { text-align: center; margin-bottom: 30px; color: #333; font-weight: 600; }
        .btn-guardar { background-color: #28a745; border: none; color: white; padding: 12px; font-weight: 500; }
        .btn-cancelar { background-color: #6c757d; border: none; color: white; padding: 12px; font-weight: 500; }
        label { font-weight: 500; color: #555; margin-bottom: 8px; }
        .input-group-text { cursor: pointer; }
    </style>
</head>
<body>
    <div class="registro-container">
        <h2 class="registro-title"><%= pageTitle %></h2>
        
        <% if (!mensaje.isEmpty()) { %>
            <!-- Mostrar alert con el mensaje de error o advertencia -->
            <div class="alert alert-<%= tipoMensaje %> alert-dismissible fade show" role="alert">
                <%= mensaje %><button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        <form method="POST" action="agregarUsuario.jsp">
            <!-- 'paso' indica al servidor que valide los datos -->
            <input type="hidden" name="paso" value="validar">
            <input type="hidden" name="source" value="<%= source != null ? source : "" %>">
            <!-- correo_original se usa en modo editar para comparar si el usuario cambió su correo -->
            <input type="hidden" name="correo_original" value="<%= originalCorreo %>">
            
            <div class="mb-3">
                <label for="nombre" class="form-label">Nombre</label>
                <!-- value rellena el campo si hubo un error y necesitamos re-mostrar los datos -->
                <input type="text" class="form-control" id="nombre" name="nombre" placeholder="Ingrese el nombre" value="<%= nombre %>" required>
            </div>
            <div class="mb-3">
                <label for="correo" class="form-label">Correo</label>
                <input type="email" class="form-control" id="correo" name="correo" placeholder="correo@ejemplo.com" value="<%= correo %>" required>
            </div>
            <div class="mb-3">
                <label for="clave" class="form-label">Clave</label>
                <div class="input-group">
                    <input type="password" class="form-control" id="clave" name="clave" placeholder="Ingrese la contraseña" value="<%= clave %>" required>
                    <span class="input-group-text" onclick="togglePassword('clave', 'toggleIconClave')"><i class="bi bi-eye-slash" id="toggleIconClave"></i></span>
                </div>
            </div>
            <div class="mb-3">
                <label for="confirmarClave" class="form-label">Confirmar Clave</label>
                <div class="input-group">
                    <input type="password" class="form-control" id="confirmarClave" name="confirmarClave" placeholder="Confirme la contraseña" value="<%= confirmarClave %>" required>
                    <span class="input-group-text" onclick="togglePassword('confirmarClave', 'toggleIconConfirmar')"><i class="bi bi-eye-slash" id="toggleIconConfirmar"></i></span>
                </div>
            </div>
            <div class="mb-4">
                <label for="tipo" class="form-label">Tipo de Usuario</label>
                <select class="form-select" id="tipo" name="tipo" required>
                    <option value="">Seleccione un tipo</option>
                    <option value="usuario" <%= "usuario".equals(tipo) ? "selected" : "" %>>Usuario</option>
                    <option value="asistente" <%= "asistente".equals(tipo) ? "selected" : "" %>>Asistente</option>
                    <option value="administrador" <%= "administrador".equals(tipo) ? "selected" : "" %>>Administrador</option>
                </select>
            </div>
            <div class="row">
                <div class="col-md-6 mb-2">
                    <!-- Enviar para validar y luego confirmar -->
                    <button type="submit" class="btn btn-guardar w-100"><%= buttonText %></button>
                </div>
                <div class="col-md-6 mb-2">
                    <!-- Cancelar regresa al índice o a la pantalla de edición -->
                    <button type="button" class="btn btn-cancelar w-100" onclick="location.href='<%= isEditMode ? "buscar.jsp?accion=editar" : "index.jsp" %>'">Cancelar</button>
                </div>
            </div>
        </form>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
    <script>
        // Pequeña utilidad para mostrar/ocultar la contraseña en los campos
        function togglePassword(fieldId, iconId) {
            const passwordField = document.getElementById(fieldId);
            const toggleIcon = document.getElementById(iconId);
            const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordField.setAttribute('type', type);
            toggleIcon.className = type === 'password' ? 'bi bi-eye-slash' : 'bi bi-eye';
        }
    </script>
</body>
</html>