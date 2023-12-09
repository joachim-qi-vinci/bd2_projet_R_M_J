import java.sql.SQLException;

public class Main {
    public static void main(String[] args) throws SQLException {
        ApplicationEntreprise applicationEntreprise = new ApplicationEntreprise();
        applicationEntreprise.seConnecter();
    }
}
