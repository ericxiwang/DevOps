import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * Getting a server name from the active connection. Testing a failover partner.
 * 
 * INFO: Capture TCP traffic tcpdump -A -i eth0 port 3306 > data.log
 * 
 * Virtual IP address: 10.9.51.210
 * 
 * IP1: 10.9.51.70 IP2: 10.9.51.72
 *
 * A failover happens when connection-related errors occur for an underlying,
 * active connection. The connection errors are, by default, propagated to the client,
 * which has to handle them by recreating the working objects and restarting the processes.
 *
 * A connection using failover support works just like a standard connection:
 * the client does not experience any disruptions in the failover process.
 * This means the client can rely on the same connection instance even if two
 * successive statements might be executed on two different physical hosts.
 * However, this does not mean the client does not have to deal with the exception
 * that triggered the server switch.
 *
 *
 */

public class HaSql_02 {

	public static void main(String[] args) {

		/**
		 * Virtual IP connection sting myUrl =
		 * "jdbc:mysql://10.9.51.210:3306/cornerstone?" +
		 * "user=cornerstone&password=Lipton305!&useSSL=false";
		 */
		
		// Failover partners
		String myUrl = "jdbc:mysql://10.9.51.70:3306,10.9.51.72:3306/?" +
				"user=cornerstone&password=Lipton305!&useSSL=false";

		// Number of repeated SELECT calls
		final int CALLS = 20;

		// Delay interval in msec, used for INSERT data
		final int DELAY = 1000;

		// JDBC oblects
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		try {
			// CONNECT
			conn = DriverManager.getConnection(myUrl);

			// REPEAT GETTING THE ACTIVE SERVER
			for (int i = 0; i < CALLS; i++) {
				stmt = conn.createStatement();
				rs = stmt.executeQuery("SELECT NOW(), @@hostname, @@server_id");
				rs.next();
				System.out.format("%-24s %8s\n", rs.getTimestamp(1), rs.getString(2));
				Thread.sleep(DELAY);
			}

			// CLOSE CONNECTION
			stmt.close();

		} catch (Exception e) {
			System.err.println("General problem");
			System.err.println(e.getMessage());
		}
	}
}
