<<<<<<< HEAD
import java.sql.*;
import java.util.Scanner;
import utils.BCrypt;

public class AppEtudiant {

    private Scanner scanner = new Scanner(System.in);
    private Scanner input = new Scanner(System.in);
    private int id_etudiant;
    private String prenom;

    private String semestre;

    private PreparedStatement seConnecterStatement;
    private PreparedStatement voirOffresValideesSemestreStatement;
    private PreparedStatement voirOffresParMotsClesStatement;
    private PreparedStatement poserCandidatureStatement;
    private PreparedStatement mesCandidaturesStatement;
    private PreparedStatement annulerCandidatureStatement;
    public AppEtudiant(){
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url = "jdbc:postgresql://172.24.2.6:5432/dbjoachimqi";
        Connection conn = null;

        try {
            conn = DriverManager.getConnection(url,"mariomargjini" , "DJAQ3LSVE");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
        try {
            seConnecterStatement = conn.prepareStatement("SELECT e.* FROM projet.etudiants e WHERE e.mail = ?;");
            voirOffresValideesSemestreStatement= conn.prepareStatement("SELECT o.code_offre_stage,o.entreprise,o.nom,o.adresse,o.description,o.mots_cles FROM projet.voirOffresValideesSemestre o WHERE o.id_etudiant=?;");
            voirOffresParMotsClesStatement = conn.prepareStatement("SELECT o.code_offre_stage,o.entreprise,o.semestre_offre,o.nom,o.adresse,o.description,o.mots_cles FROM projet.voirOffresParMotsCles o WHERE o.id_etudiant=? AND o.intitule = ?;");
            poserCandidatureStatement = conn.prepareStatement("SELECT projet.poserCandidature(?,?,?);");
            mesCandidaturesStatement = conn.prepareStatement("SELECT c.code_offre_stage, c.nom, c.etat FROM projet.mesCandidatures c WHERE c.etudiant = ?;");
            annulerCandidatureStatement = conn.prepareStatement("SELECT projet.annulerCandidature(?,?);");
        } catch (SQLException e) {
            System.out.println("erreur avec un preparedstatement");
            e.printStackTrace();
            System.out.println(e.getMessage());

        }
    }
    public void seConnecter() throws SQLException {
        System.out.println("Veuillez vous connecter afin d'utiliser l'application etudiant ");
        System.out.println("Entrez votre email");
        String email = scanner.nextLine();
        System.out.println("Entrez votre mot de passe");
        String mdp = scanner.nextLine();
        seConnecterStatement.setString(1,email);
        try(ResultSet rs = seConnecterStatement.executeQuery();) {


            while(rs.next()){
                if (!BCrypt.checkpw(mdp,rs.getString(6))) {
                    System.out.println();
                    System.out.println("Votre email ou votre mot de passe est incorrect.");
                    System.out.println();
                    seConnecter();
                } else {
                    id_etudiant = rs.getInt(1);
                    prenom = rs.getString(3);
                    semestre = rs.getString(5);
                    System.out.println();
                    System.out.println("Bienvenue dans l'application etudiant "+ prenom);
                    System.out.println();
                    start();
                }
            }

        } catch (SQLException e) {
            System.out.println("Erreur lors de la connection.");
            e.printStackTrace();

        }
    }

    public void start() throws SQLException {
        int choix = -1;
        while ((choix >= -1 && choix <=5)) {
            System.out.println("Choissiez l'action à effectuer");
            System.out.println("1 : Voir les offres de stage validées auquelles vous pouvez postuler");
            System.out.println("2 : Voir les offres de stage validées auquelles vous pouvez postuler et les filtrer en fonction d'un mot clé");
            System.out.println("3 : poser une candidature");
            System.out.println("4 : voir les candidatures que vous avez posé");
            System.out.println("5 : annuler une candidature");
            System.out.println("0 : Se deconnecter");
            System.out.println("autre : arreter l'application");
            choix = input.nextInt();

            switch (choix) {
                case 0:
                    seDeconecter();
                case 1:
                    voirOffresValideesSemestre();
                    break;
                case 2:
                    voirOffresParMotsCles();
                    break;
                case 3:
                    poserCandidature();
                    break;
                case 4:
                    mesCandidatures();
                    break;
                case 5:
                    annulerCandidature();
                    break;
            }
        }

    }
    public void seDeconecter() throws SQLException {
        prenom = null;
        id_etudiant = 0;
        System.out.println("vous avez été déconnecté avec succès.");
        seConnecter();
    }
    public void voirOffresValideesSemestre() {
        System.out.println("Les offres pour lequelles vous pouvez postuler sont :");
        try{
            voirOffresValideesSemestreStatement.setInt(1,  id_etudiant);
            ResultSet rs = voirOffresValideesSemestreStatement.executeQuery();
            while (rs.next()) {
                String str = rs.getString(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getString(4) + " | " + rs.getString(5) + " | " + rs.getString(6);
                System.out.println(str);
            }
            rs.close();

        }catch (SQLException se){
            se.printStackTrace();
        }
            System.out.println();
    }
    public void voirOffresParMotsCles(){
        System.out.println("Entrez le mot clé pour lequel vous recherchez une offre de stage.");
        String motCle = scanner.nextLine();
        System.out.println("Les offres pour lequelles vous pouvez postuler sont :");
        try{
            voirOffresParMotsClesStatement.setInt(1,id_etudiant);
            voirOffresParMotsClesStatement.setString(2,motCle);
            ResultSet rs = voirOffresParMotsClesStatement.executeQuery();
            while (rs.next()) {
                String str = rs.getString(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getString(4) + " | " + rs.getString(5) + " | " + rs.getString(6) + " | " + rs.getString(7);
                System.out.println( str);
            }
            rs.close();
        }catch (SQLException se){
            se.printStackTrace();
        }
        System.out.println();
    }
    public void poserCandidature(){
        System.out.println("Candidature pour offre de stage de stage.");
        System.out.println("Entrez le code de l'offre.");
        String codeOffre = scanner.nextLine();
        System.out.println("Entrez vos motivations.");
        String motivations = scanner.nextLine();
        boolean resultat;
        try {
            poserCandidatureStatement.setInt(1,id_etudiant);
            poserCandidatureStatement.setString(2,codeOffre);
            poserCandidatureStatement.setString(3,motivations);
            resultat = poserCandidatureStatement.execute();
            if (resultat){
                System.out.println("Votre candidature a été enregistrée avec succès !");
            }else {
                System.out.println("Il y a eu une erreur dans l'ajout de votre candidature.");
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }
    public void mesCandidatures(){
        System.out.println("Voici la liste des candidatures que vous avez posé :");
        try {
            mesCandidaturesStatement.setInt(1,id_etudiant);
            ResultSet rs = mesCandidaturesStatement.executeQuery();
            while (rs.next()){
                String str = rs.getString(1) + " | " + rs.getString(2) + " | " + rs.getString(3);
                System.out.println(str);
            }
            rs.close();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }

    }
    public void annulerCandidature(){
        System.out.println("Annuler une candidature.");
        System.out.println("Entrez le code de l'offre pour laquelle vous souhaitez annuler une candidature que vous avez posé.");
        String offre = scanner.nextLine();
        boolean resultat;
        try {
            annulerCandidatureStatement.setInt(1,id_etudiant);
            annulerCandidatureStatement.setString(2,offre);
            resultat = annulerCandidatureStatement.execute();
            if (resultat){
                System.out.println("Votre candidature a été annulée avec succès !");
            }else {
                System.out.println("Il y a eu une erreur avec l'annulation de votre candidature.");
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }

    }

}
=======
import java.sql.*;
import java.util.Scanner;
import utils.BCrypt;

public class AppEtudiant {

    private Scanner scanner = new Scanner(System.in);
    private Scanner input = new Scanner(System.in);
    private int id_etudiant;
    private String prenom;

    private String semestre;

    private PreparedStatement seConnecterStatement;
    private PreparedStatement voirOffresValideesSemestreStatement;
    private PreparedStatement voirOffresParMotsClesStatement;
    private PreparedStatement poserCandidatureStatement;
    private PreparedStatement mesCandidaturesStatement;
    private PreparedStatement annulerCandidatureStatement;
    public AppEtudiant(){
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url = "jdbc:postgresql://172.24.2.6:5432/dbjoachimqi";
        Connection conn = null;

        try {
            conn = DriverManager.getConnection(url,"mariomargjini" , "DJAQ3LSVE");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
        try {
            seConnecterStatement = conn.prepareStatement("SELECT e.* FROM projet.etudiants e WHERE e.mail = ?;");
            voirOffresValideesSemestreStatement= conn.prepareStatement("SELECT o.code_offre_stage,o.entreprise,o.nom,o.adresse,o.description,o.mots_cles FROM projet.voirOffresValideesSemestre o WHERE o.id_etudiant=?;");
            voirOffresParMotsClesStatement = conn.prepareStatement("SELECT o.code_offre_stage,o.entreprise,o.semestre_offre,o.nom,o.adresse,o.description,o.mots_cles FROM projet.voirOffresParMotsCles o WHERE o.id_etudiant=? AND o.intitule = ?;");
            poserCandidatureStatement = conn.prepareStatement("SELECT projet.poserCandidature(?,?,?);");
            mesCandidaturesStatement = conn.prepareStatement("SELECT c.code_offre_stage, c.nom, c.etat FROM projet.mesCandidatures c WHERE c.etudiant = ?;");
            annulerCandidatureStatement = conn.prepareStatement("SELECT projet.annulerCandidature(?,?);");
        } catch (SQLException e) {
            System.out.println("erreur avec un preparedstatement");
            e.printStackTrace();
            System.out.println(e.getMessage());

        }
    }
    public void seConnecter() throws SQLException {
        System.out.println("Veuillez vous connecter afin d'utiliser l'application etudiant ");
        System.out.println("Entrez votre email");
        String email = scanner.nextLine();
        System.out.println("Entrez votre mot de passe");
        String mdp = scanner.nextLine();
        seConnecterStatement.setString(1,email);
        try(ResultSet rs = seConnecterStatement.executeQuery();) {


            while(rs.next()){
                if (!BCrypt.checkpw(mdp,rs.getString(6))) {
                    System.out.println();
                    System.out.println("Votre email ou votre mot de passe est incorrect.");
                    System.out.println();
                    seConnecter();
                } else {
                    id_etudiant = rs.getInt(1);
                    prenom = rs.getString(3);
                    semestre = rs.getString(5);
                    System.out.println();
                    System.out.println("Bienvenue dans l'application etudiant "+ prenom);
                    System.out.println();
                    start();
                }
            }

        } catch (SQLException e) {
            System.out.println("Erreur lors de la connection.");
            e.printStackTrace();

        }
    }

    public void start() throws SQLException {
        int choix = -1;
        while ((choix >= -1 && choix <=5)) {
            System.out.println("Choissiez l'action à effectuer");
            System.out.println("1 : Voir les offres de stage validées auquelles vous pouvez postuler");
            System.out.println("2 : Voir les offres de stage validées auquelles vous pouvez postuler et les filtrer en fonction d'un mot clé");
            System.out.println("3 : poser une candidature");
            System.out.println("4 : voir les candidatures que vous avez posé");
            System.out.println("5 : annuler une candidature");
            System.out.println("0 : Se deconnecter");
            System.out.println("autre : arreter l'application");
            choix = input.nextInt();

            switch (choix) {
                case 0:
                    seDeconecter();
                case 1:
                    voirOffresValideesSemestre();
                    break;
                case 2:
                    voirOffresParMotsCles();
                    break;
                case 3:
                    poserCandidature();
                    break;
                case 4:
                    mesCandidatures();
                    break;
                case 5:
                    annulerCandidature();
                    break;
            }
        }

    }
    public void seDeconecter() throws SQLException {
        prenom = null;
        id_etudiant = 0;
        System.out.println("vous avez été déconnecté avec succès.");
        seConnecter();
    }
    public void voirOffresValideesSemestre() {
        System.out.println("Les offres pour lequelles vous pouvez postuler sont :");
        try{
            voirOffresValideesSemestreStatement.setInt(1,  id_etudiant);
            ResultSet rs = voirOffresValideesSemestreStatement.executeQuery();
            while (rs.next()) {
                String str = rs.getString(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getString(4) + " | " + rs.getString(5) + " | " + rs.getString(6);
                System.out.println(str);
            }
            rs.close();

        }catch (SQLException se){
            se.printStackTrace();
        }
            System.out.println();
    }
    public void voirOffresParMotsCles(){
        System.out.println("Entrez le mot clé pour lequel vous recherchez une offre de stage.");
        String motCle = scanner.nextLine();
        System.out.println("Les offres pour lequelles vous pouvez postuler sont :");
        try{
            voirOffresParMotsClesStatement.setInt(1,id_etudiant);
            voirOffresParMotsClesStatement.setString(2,motCle);
            ResultSet rs = voirOffresParMotsClesStatement.executeQuery();
            while (rs.next()) {
                String str = rs.getString(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getString(4) + " | " + rs.getString(5) + " | " + rs.getString(6) + " | " + rs.getString(7);
                System.out.println( str);
            }
            rs.close();
        }catch (SQLException se){
            se.printStackTrace();
        }
        System.out.println();
    }
    public void poserCandidature(){
        System.out.println("Candidature pour offre de stage de stage.");
        System.out.println("Entrez le code de l'offre.");
        String codeOffre = scanner.nextLine();
        System.out.println("Entrez vos motivations.");
        String motivations = scanner.nextLine();
        boolean resultat;
        try {
            poserCandidatureStatement.setInt(1,id_etudiant);
            poserCandidatureStatement.setString(2,codeOffre);
            poserCandidatureStatement.setString(3,motivations);
            resultat = poserCandidatureStatement.execute();
            if (resultat){
                System.out.println("Votre candidature a été enregistrée avec succès !");
            }else {
                System.out.println("Il y a eu une erreur dans l'ajout de votre candidature.");
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }
    public void mesCandidatures(){
        System.out.println("Voici la liste des candidatures que vous avez posé :");
        try {
            mesCandidaturesStatement.setInt(1,id_etudiant);
            ResultSet rs = mesCandidaturesStatement.executeQuery();
            while (rs.next()){
                String str = rs.getString(1) + " | " + rs.getString(2) + " | " + rs.getString(3);
                System.out.println(str);
            }
            rs.close();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }

    }
    public void annulerCandidature(){
        System.out.println("Annuler une candidature.");
        System.out.println("Entrez le code de l'offre pour laquelle vous souhaitez annuler une candidature que vous avez posé.");
        String offre = scanner.nextLine();
        boolean resultat;
        try {
            annulerCandidatureStatement.setInt(1,id_etudiant);
            annulerCandidatureStatement.setString(2,offre);
            resultat = annulerCandidatureStatement.execute();
            if (resultat){
                System.out.println("Votre candidature a été annulée avec succès !");
            }else {
                System.out.println("Il y a eu une erreur avec l'annulation de votre candidature.");
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }

    }

}
>>>>>>> f13751bdac06fe3f53b96a8e715573b113e602b5
