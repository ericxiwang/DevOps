import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * CRUD functions.
 * INSERT multiple rows.
 * 
 * Capture TCP traffic:
 * tcpdump -A -i eth0 port 3306
 * 
 * Virtual IP address: 10.9.51.210
 * 
 * IP1: 10.9.51.70
 * IP2: 10.9.51.72
 *
 */

public class HaSql_01 {

	public static void main(String[] args) {

		String query, myUrl, tableName;
		Statement stmt = null;

		// Number of repeated INSERT calls
		final int RECORDS = 60;

		// Delay interval in msec, used for INSERT data
		final int DELAY = 1000;

		tableName = "bulk01";

		myUrl = "jdbc:mysql://10.9.51.210:3306/cornerstone?" 
				+ "user=cornerstone&password=Lipton305!&useSSL=false";

		try {
			// CONNECT
			Connection conn = null;
			conn = DriverManager.getConnection(myUrl);

			// GET SERVER INFO
			stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery("SELECT @@hostname, @@server_id");
			rs.next();
			System.out.println("Connection established: " + rs.getString(1));

			// DROP TABLE IF EXISTS
			stmt = conn.createStatement();
			query = "DROP TABLE IF EXISTS " + tableName;
			stmt.executeUpdate(query);

			// CREATE TABLE
			query = "CREATE TABLE " + tableName
					+ " (ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, c1 VARCHAR(32))";
			stmt.executeUpdate(query);

			// INSERT DATA
			System.out.print("Loading data");
			for (int i = 0; i < RECORDS; i++) {
				query = "INSERT INTO bulk01 (c1) VALUES (" + i + ")";
				stmt.executeUpdate(query);
				try {
					System.out.print(".");
					Thread.sleep(DELAY);
				} catch (InterruptedException ex) {
					Thread.currentThread().interrupt();
				}
			}
			System.out.println();

			// FETCH/READ DATA
			query = "SELECT ts, c1 FROM " + tableName;
			stmt = conn.createStatement();

			rs = stmt.executeQuery(query);
			while (rs.next()) {
				System.out.format("%-24s %8s\n", rs.getTimestamp("ts"), rs.getString("c1"));
			}

			// DROP TABLE
			query = "DROP TABLE " + tableName;
			stmt.executeUpdate(query);

			// CLOSE CONNECTION
			stmt.close();

			try {
				if (null != conn) {
					conn.close();
					System.out.println("Connection closed");
				}
			} catch (Exception e) {
				System.err.println(e.getMessage());
			}

		} catch (Exception e) {
			System.err.println("General problem");
			System.err.println(e.getMessage());
		}
	}
}
