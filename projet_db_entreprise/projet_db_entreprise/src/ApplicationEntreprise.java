<<<<<<< HEAD
import java.io.Reader;
import java.sql.*;
import java.util.Enumeration;
import java.util.Scanner;
import utils.BCrypt;
public class ApplicationEntreprise {

    private Scanner scanner = new Scanner(System.in);
    private String id_entreprise;
    private PreparedStatement encoderOffreDeStageStatement;
    private PreparedStatement seConnecterStatement;
    private PreparedStatement voirMotsclesDisponiblesStatement;
    private PreparedStatement ajouterMotCleStatement;
    private PreparedStatement voirOffresDeStageStatement;
    private PreparedStatement selectionnerEtudiantPourOffreStageStatement;
    private PreparedStatement annulerOffreDeStageStatement;
    private PreparedStatement voirCandidaturesOffreStatement;

    public ApplicationEntreprise() {

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url = "jdbc:postgresql://172.24.2.6:5432/dbjoachimqi";
        Connection conn = null;

        try {
            conn = DriverManager.getConnection(url,"robinsalle" , "");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }

        // prepared statement
        try {
            encoderOffreDeStageStatement = conn.prepareStatement("SELECT projet.encoderOffreDeStage(?, ?, ?);");
            seConnecterStatement = conn.prepareStatement("SELECT e.id_entreprise, e.mdp FROM projet.entreprises e WHERE e.id_entreprise = ?;");
            voirMotsclesDisponiblesStatement = conn.prepareStatement("SELECT *" + "FROM projet.voirMotsCles;");
            ajouterMotCleStatement = conn.prepareStatement("SELECT projet.ajouterUnMotCleOffreDeStage(?, ?, ?);");
            voirOffresDeStageStatement = conn.prepareStatement("SELECT *" + "FROM projet.mesOffres WHERE entreprise = ?;");
            selectionnerEtudiantPourOffreStageStatement = conn.prepareStatement("SELECT projet.selectionnerEtudiantPourUneOffreDeStage(?, ?, ?);");
            annulerOffreDeStageStatement = conn.prepareStatement("SELECT projet.annulerOffreStage(?, ?);");
            voirCandidaturesOffreStatement = conn.prepareStatement("SELECT * " + "FROM projet.voirLesCandidaturesOffre(?, ?) " + "t(etat projet.etat_candidature, nom VARCHAR(40), prenom VARCHAR(40), mail VARCHAR(50), motivation VARCHAR(200))");

        } catch (SQLException se) {
            System.out.println("erreur avec un preparedStatement");
            se.printStackTrace();
            System.exit(1);
        }
    }

    public void seConnecter() throws SQLException {
        String salt = BCrypt.gensalt();
        System.out.println("Connectez-vous à l'application avec votre identifiant et votre mot de passe");
        System.out.print("Identifiant: ");
        String identifiant = scanner.nextLine();
        System.out.print("Mot de passe: ");
        String motDePasse = scanner.nextLine();
        seConnecterStatement.setString(1, identifiant);
        try(ResultSet rs = seConnecterStatement.executeQuery()) {
            while (rs.next()) {
                if (BCrypt.checkpw(motDePasse, rs.getString(2)) == false) {
                    System.out.println();
                    System.out.println("Votre mot de passe est incorrect !");
                    System.out.println();
                    seConnecter();
                }
                System.out.println();
                System.out.println("Bienvenue dans l'application de l'entreprise " + identifiant);
                System.out.println();
                id_entreprise = identifiant;
                start();
            }
            System.out.println();
            System.out.println("Votre identifiant est incorrect !!");
            System.out.println();
            seConnecter();
        }
    }



    public void start() throws SQLException {
        String choix = "10";
        while (choix != "0") {
            System.out.println("MENU:");
            //System.out.println();
            System.out.println("     1) Encoder une offre de stage");
            System.out.println("     2) Voir les mots-clés disponibles pour décrire une offre de stage");
            System.out.println("     3) Ajouter un mot-clé pour une offre de stage");
            System.out.println("     4) Voir mes offres de stage");
            System.out.println("     5) Sélectionner un étudiant pour une offre de stage");
            System.out.println("     6) Annuler une offre de stage");
            System.out.println("     7) Voir les candidatures pour une offre de stage");
            System.out.println("     8) Se déconnecter");

            System.out.print("Votre choix (0 pour quitter l'application): ");
            choix = scanner.nextLine();

            switch (choix) {
                case "1":
                    System.out.println();
                    encoderUneOffreDeStage();
                    break;
                case "2":
                    System.out.println();
                    voirLesMotsClesDisponiblesPourUneOffreDeStage();
                    break;
                case "3":
                    System.out.println();
                    ajouterUnMotClePourUneOffreDeStage();
                    break;
                case "4":
                    System.out.println();
                    voirMesOffresDeStages();
                    break;
                case "5":
                    System.out.println();
                    selectionnerUnEtudiantPourUneOffreDeStage();
                    break;
                case "6":
                    System.out.println();
                    annulerUneOffreDeStage();
                    break;
                case "7":
                    System.out.println();
                    voirLesCandidaturesPourUneOffreDeStage();
                    break;
                case "8":
                    System.out.println();
                    seDeconnecter();
                    break;
                default: System.exit(0);
            }
        }
    }

    public void encoderUneOffreDeStage() throws SQLException {
        System.out.println("Création de l'offre de stage");
        System.out.println("Description: ");
        String description = scanner.nextLine();

        System.out.println("Semestre:");
        String semestre = scanner.nextLine();

        try {
            encoderOffreDeStageStatement.setString(1, id_entreprise);
            encoderOffreDeStageStatement.setString(2, description);
            encoderOffreDeStageStatement.setObject(3, semestre, java.sql.Types.OTHER);
            encoderOffreDeStageStatement.execute();
            System.out.println();
            System.out.println("L'offre de stage a bien été créé !");
            System.out.println();
        } catch (SQLException e){
            System.out.println();
            System.out.println(e.getMessage());
            System.out.println();
        }
    }

    public void voirLesMotsClesDisponiblesPourUneOffreDeStage() throws SQLException {
        System.out.println("Les mots-clés disponibles pour une offre de stage: ");
        try(ResultSet rs = voirMotsclesDisponiblesStatement.executeQuery()) {
            while (rs.next()) {
                System.out.println(rs.getRow() + ") " + rs.getString(1));
            }
        }
        System.out.println();
    }

    public void ajouterUnMotClePourUneOffreDeStage() throws SQLException {
        System.out.println("Ajout d'un mot-clé: ");
        System.out.print("Le code de l'offre de stage: ");
        String code = scanner.nextLine();
        System.out.print("Le mot-clé a ajouté: ");
        String motCle = scanner.nextLine();

        try {
            ajouterMotCleStatement.setString(1, code);
            ajouterMotCleStatement.setString(2, motCle);
            ajouterMotCleStatement.setString(3, id_entreprise);
            ajouterMotCleStatement.execute();
            System.out.println();
            System.out.println("Le mot-clé a bien été ajouté !");
            System.out.println();
        } catch (SQLException e){
            System.out.println();
            System.out.println(e.getMessage());
            System.out.println();
        }
    }

    public void voirMesOffresDeStages() throws SQLException {
        System.out.println("Mes offres de stage: ");
        voirOffresDeStageStatement.setString(1, id_entreprise);
        try(ResultSet rs = voirOffresDeStageStatement.executeQuery()) {
            while(rs.next()) {
                System.out.println(rs.getRow() + ") " + rs.getString(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getString(4) + " | " + rs.getString(5) + " | " + rs.getInt(6) + " | " + rs.getString(7));
            }
        }
        System.out.println();
    }

    public void selectionnerUnEtudiantPourUneOffreDeStage() throws SQLException {
        System.out.println("Sélection d'un étudiant pour une offre de stage: ");
        System.out.print("Code de l'offre de stage à attribuer: ");
        String code = scanner.nextLine();
        System.out.print("Adresse email de l'étudiant accepté: ");
        String emailEtudiant = scanner.nextLine();

        try {
            selectionnerEtudiantPourOffreStageStatement.setString(1, code);
            selectionnerEtudiantPourOffreStageStatement.setString(2, emailEtudiant);
            selectionnerEtudiantPourOffreStageStatement.setString(3, id_entreprise);
            selectionnerEtudiantPourOffreStageStatement.execute();
            System.out.println();
            System.out.println("L'étudiant a bien été selectionné !");
            System.out.println();
        } catch (SQLException e){
            System.out.println();
            System.out.println(e.getMessage());
            System.out.println();
        }
    }

    public void annulerUneOffreDeStage() throws SQLException {
        System.out.println("Annulation d'une offre de stage: ");
        System.out.print("Code de l'offre de stage a annulée: ");
        String code = scanner.nextLine();

        try {
            annulerOffreDeStageStatement.setString(1, code);
            annulerOffreDeStageStatement.setString(2, id_entreprise);
            annulerOffreDeStageStatement.execute();
            System.out.println();
            System.out.println("L'offre a bien été annulée !");
        } catch (SQLException e){
            System.out.println();
            System.out.println(e.getMessage());
            System.out.println();
        }
    }

    public void voirLesCandidaturesPourUneOffreDeStage() throws SQLException {
        System.out.print("Le code de l'offre de stage: ");
        String code = scanner.nextLine();
        voirCandidaturesOffreStatement.setString(1, code);
        voirCandidaturesOffreStatement.setString(2, id_entreprise);

        try(ResultSet rs = voirCandidaturesOffreStatement.executeQuery()) {
            System.out.println();
            System.out.println("Les candidatures pour cette offre de stage: ");
            while (rs.next()) {
                System.out.println(rs.getRow() + ") " + rs.getString(1) + " " + rs.getString(2) + " " + rs.getString(3) + " " + rs.getString(4) + " " + rs.getString(5));
            }
            System.out.println();
        } catch (SQLException e){
            System.out.println();
            System.out.println(e.getMessage());
            System.out.println();
        }
    }

    public void seDeconnecter() throws SQLException {
        System.out.println();
        seConnecter();
    }
}

=======
import java.io.Reader;
import java.sql.*;
import java.util.Enumeration;
import java.util.Scanner;
import utils.BCrypt;
public class ApplicationEntreprise {

    private Scanner scanner = new Scanner(System.in);
    private String id_entreprise;
    private PreparedStatement encoderOffreDeStageStatement;
    private PreparedStatement seConnecterStatement;
    private PreparedStatement voirMotsclesDisponiblesStatement;
    private PreparedStatement ajouterMotCleStatement;
    private PreparedStatement voirOffresDeStageStatement;
    private PreparedStatement selectionnerEtudiantPourOffreStageStatement;
    private PreparedStatement annulerOffreDeStageStatement;
    private PreparedStatement voirCandidaturesOffreStatement;

    public ApplicationEntreprise() {

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url = "jdbc:postgresql://172.24.2.6:5432/dbjoachimqi";
        Connection conn = null;

        try {
            conn = DriverManager.getConnection(url,"robinsalle" , "");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }

        // prepared statement
        try {
            encoderOffreDeStageStatement = conn.prepareStatement("SELECT projet.encoderOffreDeStage(?, ?, ?);");
            seConnecterStatement = conn.prepareStatement("SELECT e.id_entreprise, e.mdp FROM projet.entreprises e WHERE e.id_entreprise = ?;");
            voirMotsclesDisponiblesStatement = conn.prepareStatement("SELECT *" + "FROM projet.voirMotsCles;");
            ajouterMotCleStatement = conn.prepareStatement("SELECT projet.ajouterUnMotCleOffreDeStage(?, ?, ?);");
            voirOffresDeStageStatement = conn.prepareStatement("SELECT *" + "FROM projet.mesOffres WHERE entreprise = ?;");
            selectionnerEtudiantPourOffreStageStatement = conn.prepareStatement("SELECT projet.selectionnerEtudiantPourUneOffreDeStage(?, ?, ?);");
            annulerOffreDeStageStatement = conn.prepareStatement("SELECT projet.annulerOffreStage(?, ?);");
            voirCandidaturesOffreStatement = conn.prepareStatement("SELECT * " + "FROM projet.voirLesCandidaturesOffre(?, ?) " + "t(etat projet.etat_candidature, nom VARCHAR(40), prenom VARCHAR(40), mail VARCHAR(50), motivation VARCHAR(200))");

        } catch (SQLException se) {
            System.out.println("erreur avec un preparedStatement");
            se.printStackTrace();
            System.exit(1);
        }
    }

    public void seConnecter() throws SQLException {
        String salt = BCrypt.gensalt();
        System.out.println("Connectez-vous à l'application avec votre identifiant et votre mot de passe");
        System.out.print("Identifiant: ");
        String identifiant = scanner.nextLine();
        System.out.print("Mot de passe: ");
        String motDePasse = scanner.nextLine();
        seConnecterStatement.setString(1, identifiant);
        try(ResultSet rs = seConnecterStatement.executeQuery()) {
            while (rs.next()) {
                if (BCrypt.checkpw(motDePasse, rs.getString(2)) == false) {
                    System.out.println();
                    System.out.println("Votre mot de passe est incorrect !");
                    System.out.println();
                    seConnecter();
                }
                System.out.println();
                System.out.println("Bienvenue dans l'application de l'entreprise " + identifiant);
                System.out.println();
                id_entreprise = identifiant;
                start();
            }
            System.out.println();
            System.out.println("Votre identifiant est incorrect !!");
            System.out.println();
            seConnecter();
        }
    }



    public void start() throws SQLException {
        String choix = "10";
        while (choix != "0") {
            System.out.println("MENU:");
            //System.out.println();
            System.out.println("     1) Encoder une offre de stage");
            System.out.println("     2) Voir les mots-clés disponibles pour décrire une offre de stage");
            System.out.println("     3) Ajouter un mot-clé pour une offre de stage");
            System.out.println("     4) Voir mes offres de stage");
            System.out.println("     5) Sélectionner un étudiant pour une offre de stage");
            System.out.println("     6) Annuler une offre de stage");
            System.out.println("     7) Voir les candidatures pour une offre de stage");
            System.out.println("     8) Se déconnecter");

            System.out.print("Votre choix (0 pour quitter l'application): ");
            choix = scanner.nextLine();

            switch (choix) {
                case "1":
                    System.out.println();
                    encoderUneOffreDeStage();
                    break;
                case "2":
                    System.out.println();
                    voirLesMotsClesDisponiblesPourUneOffreDeStage();
                    break;
                case "3":
                    System.out.println();
                    ajouterUnMotClePourUneOffreDeStage();
                    break;
                case "4":
                    System.out.println();
                    voirMesOffresDeStages();
                    break;
                case "5":
                    System.out.println();
                    selectionnerUnEtudiantPourUneOffreDeStage();
                    break;
                case "6":
                    System.out.println();
                    annulerUneOffreDeStage();
                    break;
                case "7":
                    System.out.println();
                    voirLesCandidaturesPourUneOffreDeStage();
                    break;
                case "8":
                    System.out.println();
                    seDeconnecter();
                    break;
                default: System.exit(0);
            }
        }
    }

    public void encoderUneOffreDeStage() throws SQLException {
        System.out.println("Création de l'offre de stage");
        System.out.println("Description: ");
        String description = scanner.nextLine();

        System.out.println("Semestre:");
        String semestre = scanner.nextLine();

        try {
            encoderOffreDeStageStatement.setString(1, id_entreprise);
            encoderOffreDeStageStatement.setString(2, description);
            encoderOffreDeStageStatement.setObject(3, semestre, java.sql.Types.OTHER);
            encoderOffreDeStageStatement.execute();
            System.out.println();
            System.out.println("L'offre de stage a bien été créé !");
            System.out.println();
        } catch (SQLException e){
            System.out.println();
            System.out.println(e.getMessage());
            System.out.println();
        }
    }

    public void voirLesMotsClesDisponiblesPourUneOffreDeStage() throws SQLException {
        System.out.println("Les mots-clés disponibles pour une offre de stage: ");
        try(ResultSet rs = voirMotsclesDisponiblesStatement.executeQuery()) {
            while (rs.next()) {
                System.out.println(rs.getRow() + ") " + rs.getString(1));
            }
        }
        System.out.println();
    }

    public void ajouterUnMotClePourUneOffreDeStage() throws SQLException {
        System.out.println("Ajout d'un mot-clé: ");
        System.out.print("Le code de l'offre de stage: ");
        String code = scanner.nextLine();
        System.out.print("Le mot-clé a ajouté: ");
        String motCle = scanner.nextLine();

        try {
            ajouterMotCleStatement.setString(1, code);
            ajouterMotCleStatement.setString(2, motCle);
            ajouterMotCleStatement.setString(3, id_entreprise);
            ajouterMotCleStatement.execute();
            System.out.println();
            System.out.println("Le mot-clé a bien été ajouté !");
            System.out.println();
        } catch (SQLException e){
            System.out.println();
            System.out.println(e.getMessage());
            System.out.println();
        }
    }

    public void voirMesOffresDeStages() throws SQLException {
        System.out.println("Mes offres de stage: ");
        voirOffresDeStageStatement.setString(1, id_entreprise);
        try(ResultSet rs = voirOffresDeStageStatement.executeQuery()) {
            while(rs.next()) {
                System.out.println(rs.getRow() + ") " + rs.getString(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getString(4) + " | " + rs.getString(5) + " | " + rs.getInt(6) + " | " + rs.getString(7));
            }
        }
        System.out.println();
    }

    public void selectionnerUnEtudiantPourUneOffreDeStage() throws SQLException {
        System.out.println("Sélection d'un étudiant pour une offre de stage: ");
        System.out.print("Code de l'offre de stage à attribuer: ");
        String code = scanner.nextLine();
        System.out.print("Adresse email de l'étudiant accepté: ");
        String emailEtudiant = scanner.nextLine();

        try {
            selectionnerEtudiantPourOffreStageStatement.setString(1, code);
            selectionnerEtudiantPourOffreStageStatement.setString(2, emailEtudiant);
            selectionnerEtudiantPourOffreStageStatement.setString(3, id_entreprise);
            selectionnerEtudiantPourOffreStageStatement.execute();
            System.out.println();
            System.out.println("L'étudiant a bien été selectionné !");
            System.out.println();
        } catch (SQLException e){
            System.out.println();
            System.out.println(e.getMessage());
            System.out.println();
        }
    }

    public void annulerUneOffreDeStage() throws SQLException {
        System.out.println("Annulation d'une offre de stage: ");
        System.out.print("Code de l'offre de stage a annulée: ");
        String code = scanner.nextLine();

        try {
            annulerOffreDeStageStatement.setString(1, code);
            annulerOffreDeStageStatement.setString(2, id_entreprise);
            annulerOffreDeStageStatement.execute();
            System.out.println();
            System.out.println("L'offre a bien été annulée !");
        } catch (SQLException e){
            System.out.println();
            System.out.println(e.getMessage());
            System.out.println();
        }
    }

    public void voirLesCandidaturesPourUneOffreDeStage() throws SQLException {
        System.out.print("Le code de l'offre de stage: ");
        String code = scanner.nextLine();
        voirCandidaturesOffreStatement.setString(1, code);
        voirCandidaturesOffreStatement.setString(2, id_entreprise);

        try(ResultSet rs = voirCandidaturesOffreStatement.executeQuery()) {
            System.out.println();
            System.out.println("Les candidatures pour cette offre de stage: ");
            while (rs.next()) {
                System.out.println(rs.getRow() + ") " + rs.getString(1) + " " + rs.getString(2) + " " + rs.getString(3) + " " + rs.getString(4) + " " + rs.getString(5));
            }
            System.out.println();
        } catch (SQLException e){
            System.out.println();
            System.out.println(e.getMessage());
            System.out.println();
        }
    }

    public void seDeconnecter() throws SQLException {
        System.out.println();
        seConnecter();
    }
}

>>>>>>> f13751bdac06fe3f53b96a8e715573b113e602b5
