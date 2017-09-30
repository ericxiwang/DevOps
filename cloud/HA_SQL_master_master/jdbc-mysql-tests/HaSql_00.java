import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.SQLException;

public class HaSql_00 {
	public static void main(String[] args) {
		try {
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			System.out.println("Driver loaded");
		} catch (Exception ex) {
		}

		Connection conn = null;
		try {
			String url = "jdbc:mysql://10.9.51.210:3306/cornerstone?"
					+ "user=cornerstone&password=Lipton305!&useSSL=false";

			conn = DriverManager.getConnection(url);

			// Getting driver and database info
			DatabaseMetaData meta = conn.getMetaData();
			System.out.println("Product name: " + meta.getDatabaseProductName());
			System.out.println("Product version: " + meta.getDatabaseProductVersion());
			System.out.println("Driver name: " + meta.getDriverName());
			System.out.println("Driver version: " + meta.getDriverVersion());
			System.out.println("JDBC major version: " + meta.getJDBCMajorVersion());
			System.out.println("JDBC minor version: " + meta.getJDBCMinorVersion());

		} catch (SQLException ex) {
			// handle any errors
			System.out.println("SQLException: " + ex.getMessage());
			System.out.println("SQLState: " + ex.getSQLState());
			System.out.println("VendorError: " + ex.getErrorCode());
		}
	}
}