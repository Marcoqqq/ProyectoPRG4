<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="datos.Conexion"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lista de Usuarios</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        :root { --celeste: #17a2b8; }
        .btn-editar, .btn-menu {
            background-color: var(--celeste);
            color: white; border: none; border-radius: 25px; padding: 6px 15px;
            font-weight: 500; box-shadow: 0 3px 5px rgba(0, 0, 0, 0.15);
            transition: all 0.3s ease;
        }
        .btn-editar:hover, .btn-menu:hover { background-color: #138496; transform: scale(1.05); box-shadow: 0 4px 8px rgba(0,0,0,0.2);}
        .card-header { background-color: var(--celeste); color: white; border-radius: 15px 15px 0 0;}
        .card { border-radius: 15px; }
        .table { border-radius: 10px; overflow: hidden; }
    </style>
</head>
<body>
<div class="container mt-5">
    <div class="card shadow-lg">
        <div class="card-header text-center">
            <h3 class="mb-0">Lista de Usuarios</h3>
        </div>
        <div class="card-body">
            <table class="table table-striped table-hover align-middle text-center">
                <thead class="table-dark">
                <tr>
                    <th>#</th>
                    <th>Nombre</th>
                    <th>Correo</th>
                    <th>Tipo de usuario</th>
                </tr>
                </thead>
                <tbody>
                <%
                    try {
                        Connection con = Conexion.getConnection();
                        PreparedStatement ps = con.prepareStatement("SELECT * FROM usuarios");
                        ResultSet rs = ps.executeQuery();
                        int contador = 1;
                        while (rs.next()) {
                            int id = rs.getInt("id");
                %>
                <tr onclick="window.location.href='agregarUsuario.jsp?id=<%= id %>&source=lista'" style="cursor:pointer;">
                    <th scope="row"><%= contador++ %></th>
                    <td><%= rs.getString("nombre") %></td>
                    <td><%= rs.getString("correo") %></td>
                    <td><%= rs.getString("tipo") %></td>
                </tr>
                <%
                        }
                        con.close();
                    } catch (Exception e) {
                %>
                <tr>
                    <td colspan="5" class="text-danger">Error al cargar los datos: <%= e.getMessage() %></td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <div class="text-center mt-4">
                <a href="index.jsp" class="btn-menu">Volver al menú</a>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
