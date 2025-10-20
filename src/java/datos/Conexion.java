package datos;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * NO NECESITAS CREAR LA BASE DE DATOS LEER ESTE DOCUMENTO
 *
 * Clase de utilidad para manejar la conexión con la base de datos MySQL.
 *
 * - Esta clase centraliza la configuración y creación de la base de datos y la
 * tabla (si no existen), y proporciona métodos para obtener y cerrar
 * conexiones. - Constantes: definen dónde está la base de datos (host, puerto,
 * nombre, usuario, pass). - inicializarBaseDeDatos(): crea la base de datos y
 * la tabla 'usuarios' la primera vez. - getConnection(): llama a la
 * inicialización (si hace falta) y devuelve una Connection. -
 * closeConnection(): cierra una conexión sin lanzar excepción al llamante.
 *
 * Uso típico: try (Connection conn = Conexion.getConnection()) { // usar la
 * conexión } catch (SQLException e) { // manejar error }
 */
public class Conexion {

    // --- Configuración de la base de datos ---
    // Cambiar aquí si el nombre, usuario o contraseña son diferentes en tu entorno.
    private static final String DB_NAME = "usuariosproyecto";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";
    private static final String DB_HOST = "localhost";
    private static final String DB_PORT = "3306";
    // URL completa que se usará para conectar a la base de datos especificada
    private static final String URL = "jdbc:mysql://" + DB_HOST + ":" + DB_PORT
            + "/" + DB_NAME
            + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    // Bandera para ejecutar la inicialización una sola vez por ejecución de la aplicación
    private static boolean initialized = false;

    /**
     * Inicializa la base de datos y la tabla si no existen. Paso a paso: 1) Se
     * conecta al servidor MySQL sin seleccionar una base de datos y crea la BD
     * si hace falta. 2) Luego se conecta a la BD creada y crea la tabla
     * 'usuarios' si no existe.
     *
     * Nota: este método captura excepciones internas y las imprime en consola.
     * La idea es preparar el entorno automático para un proyecto pequeño/local.
     */
    private static void inicializarBaseDeDatos() {
        // Si ya se inicializó, salir rápidamente
        if (initialized) {
            return;
        }

        try {
            // Aseguramos que el driver de MySQL esté disponible
            Class.forName("com.mysql.cj.jdbc.Driver");

            // 1) Conexión al servidor sin especificar base de datos
            String urlSinDB = "jdbc:mysql://" + DB_HOST + ":" + DB_PORT
                    + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

            Connection connSinDB = DriverManager.getConnection(urlSinDB, DB_USER, DB_PASS);
            java.sql.Statement stmtDB = connSinDB.createStatement();

            // 2) Crear la base de datos si no existe (con collate/charset adecuados)
            String createDB = "CREATE DATABASE IF NOT EXISTS " + DB_NAME
                    + " CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
            stmtDB.executeUpdate(createDB);
            System.out.println("Base de datos verificada/creada: " + DB_NAME);

            // Cerrar recursos temporales
            stmtDB.close();
            connSinDB.close();

            // 3) Conectarse ahora a la base de datos específica para crear la tabla
            Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASS);
            java.sql.Statement stmt = conn.createStatement();

            // 4) Crear la tabla 'usuarios' si no existe
            String createTableUsuarios
                    = "CREATE TABLE IF NOT EXISTS usuarios ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "nombre VARCHAR(100) NOT NULL, "
                    + "correo VARCHAR(100) NOT NULL, "
                    + "clave VARCHAR(255) NOT NULL, "
                    + "tipo ENUM('usuario', 'asistente', 'administrador') DEFAULT 'usuario', "
                    + "UNIQUE KEY unique_correo (correo)"
                    + ")";

            stmt.executeUpdate(createTableUsuarios);
            System.out.println("Tabla 'usuarios' verificada/creada");

            // Cerrar recursos
            stmt.close();
            conn.close();

            // Marcar que la inicialización ya se realizó para no repetirla
            initialized = true;
            System.out.println("Inicialización completada exitosamente");

        } catch (Exception e) {
            // Si ocurre cualquier error aquí, lo registramos en consola.
            // En aplicaciones más grandes conviene usar un logger y manejar errores más finamente.
            System.err.println("Error al inicializar base de datos: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Obtiene una conexión a la base de datos usuariosproyecto. Este método se
     * encarga de: - Ejecutar la inicialización la primera vez (crear BD/tabla
     * si hace falta) - Cargar el driver y devolver una Connection válida
     *
     * @return Connection objeto de conexión
     * @throws SQLException si hay error al conectar
     */
    public static Connection getConnection() throws SQLException {
        try {
            // Asegurarse de que la BD/tabla existan (solo la primera vez)
            inicializarBaseDeDatos();

            // Cargar el driver de MySQL (seguridad para entornos donde no se cargó automáticamente)
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Devolver la conexión a la BD definida en URL
            return DriverManager.getConnection(URL, DB_USER, DB_PASS);
        } catch (ClassNotFoundException e) {
            // Convertimos la excepción de driver en SQLException para el llamante
            throw new SQLException("Driver de MySQL no encontrado", e);
        }
    }

    /**
     * Cierra una conexión de forma segura. Llamar a este método en finally o
     * cuando se quiera liberar la conexión.
     *
     * @param conn la conexión a cerrar (puede ser null)
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                // Imprimimos el error pero no lanzamos excepción (evita romper flujo de negocio)
                System.err.println("Error al cerrar conexión: " + e.getMessage());
            }
        }
    }

    /**
     * Método de prueba opcional: intenta abrir y cerrar una conexión para
     * verificar que la configuración es correcta.
     *
     * @return true si la conexión se pudo abrir correctamente
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("Error al probar conexión: " + e.getMessage());
            return false;
        }
    }
}
