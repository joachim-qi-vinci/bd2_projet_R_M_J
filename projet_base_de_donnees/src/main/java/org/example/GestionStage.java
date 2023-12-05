package org.example;

import org.example.utils.BCrypt;

import java.sql.*;
import java.util.Scanner;

public class GestionStage {

    Connection conn = null;
     private PreparedStatement encoderEtudiantStatement;
     private PreparedStatement encoderEntrepriseStatement;
     private PreparedStatement encoderMotCleStatement;
     private PreparedStatement voirOffreNonValideStatement;
     private PreparedStatement validerOffreDeStageStatement ;
     private PreparedStatement voirOffreValidesStatement;

     private PreparedStatement voirSansStagesStatement;
     private PreparedStatement voirStagesAttribuesStatement ;
     private static MonScanner scannerTest = new MonScanner("test.txt");
     private static MonScanner scannerTest2 = new MonScanner("test2.txt");
     private static MonScanner scannerTest3 = new MonScanner("test3.txt");
     private static MonScanner scannerTest4 = new MonScanner("test4.txt");




    public GestionStage() {

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }
        String url = "jdbc:postgresql://localhost:5432/postgres";

        try {
            this.conn = DriverManager.getConnection(url, "joachime", "1234");
            System.out.println("Vous êtes connecté");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
        try {
            encoderEtudiantStatement = conn.prepareStatement("SELECT projet.encoderEtudiant(?, ?, ?, ?, ?)");
            encoderEntrepriseStatement = conn.prepareStatement("SELECT projet.encoderEntreprise(?, ?, ?, ?, ?)");
            encoderMotCleStatement = conn.prepareStatement("SELECT projet.encoderMotCle(?)");
            voirOffreNonValideStatement = conn.prepareStatement("SELECT * FROM projet.offreNonValidee");
            validerOffreDeStageStatement = conn.prepareStatement("SELECT projet.validerOffreDeStage(?)");
            voirOffreValidesStatement = conn.prepareStatement("SELECT * FROM projet.offresValidees");
            voirSansStagesStatement = conn.prepareStatement("SELECT * FROM projet.etudiantsSansStage");
            voirStagesAttribuesStatement = conn.prepareStatement("SELECT * FROM projet.offresStagesAttribuees ");
        }catch (SQLException e){
            e.printStackTrace();
        }
    }

    public void run() {


        Scanner scanner = new Scanner(System.in);
        Scanner scanner1 = new Scanner(System.in);
        String sel = BCrypt.gensalt();

        int choix = -1;
        while ((choix >= 0 && choix <= 8) || choix == -1) {
            System.out.println("Choissiez l'action à effectuer");
            System.out.println("1 : Encoder un nouvel étudiant");
            System.out.println("2 : Encoder une nouvelle entreprise");
            System.out.println("3 : Encoder un mot-clé");
            System.out.println("4 : Voir les offres de stage non-validées");
            System.out.println("5 : Valider une offre de stage");
            System.out.println("6 : Voir les offres de stage validées");
            System.out.println("7 : Voir les étudiants qui n'ont pas de stage");
            System.out.println("8 : Voir les offres de stage attribuées");
            System.out.println("0 : Quitter l'application");
            System.out.println("Entrez un nombre entre 0 et 8 : ");
            choix = scanner.nextInt();

            switch (choix) {
                case 0:
                    System.exit(0);
                case 1:
                    System.out.println("Encoder un nouvel étudiant");

                    System.out.println("Entrez le nom : ");
                    String nom = scannerTest.nextLine();
                    System.out.println("Entrez le prénom : ");
                    String prenom = scannerTest.nextLine();
                    System.out.println("Entrez l'adresse mail : ");
                    String mail = scannerTest.nextLine();
                    System.out.println("Entrez le semestre de stage : ");
                    String semestre_stage = scannerTest.nextLine();
                    System.out.println("Entrez le mot de passe : ");
                    String mdp = scannerTest.nextLine();
                    String hashedMdp = BCrypt.hashpw(mdp, sel);

                    encoderEtudiant(nom, prenom, mail, semestre_stage, hashedMdp);
                    System.out.println("Etudiant ajouté");
                    break;

                case 2:
                    System.out.println("Encoder une nouvelle entreprise");
                    System.out.println("Entrez le nom d'entreprise :");
                    String nom_en = scanner1.nextLine();
                    System.out.println("Entrez l'adresse de l'entreprise : ");
                    String adresse = scanner1.nextLine();
                    System.out.println("Entrez l'adresse mail de l'entreprise: ");
                    String mail_en = scanner1.nextLine();
                    System.out.println("Entrez un identifiant de 3 lettre pour l'entreprise : ");
                    String id_entreprise = scanner1.nextLine();
                    System.out.println("Entrez le mot de passe : ");
                    String mdp_en = scanner1.nextLine();
                    String hashedMdp_en = BCrypt.hashpw(mdp_en, sel);
                    if (encoderEntreprise(nom_en, adresse, mail_en, id_entreprise, hashedMdp_en)){
                        System.out.println("Entreprise ajoutée");
                    }else{
                        System.out.println("Echec de l'ajout");
                    }

                    break;
                case 3:
                    System.out.println("Encoder un mot-clé");
                    System.out.println("Entrez l'intitulé du mot-clé : ");
                    String intitule = scannerTest3.nextLine();
                    //String intitule = scanner1.nextLine();
                    encoderMotCle(intitule);
                    System.out.println("Mot clé ajouté");
                    break;
                case 4:
                    System.out.println("Voir les offres de stage non-validées");
                    offreNonValidee();
                    System.out.println(" ");
                    break;
                case 5:
                    System.out.println("Valider une offre de stage");
                    System.out.println("Entrez le code d'offre de stage: ");
                    String code = scannerTest4.nextLine();
                    validerOffreDeStage(code);
                    System.out.println("Offre de stage validée");
                    break;
                case 6:
                    System.out.println("Voir les offres de stage validées");
                    offreValidee();
                    System.out.println(" ");
                    break;
                case 7:
                    System.out.println("Voir les étudiants qui n'ont pas de stage");
                    sansStage();
                    System.out.println(" ");
                    break;
                case 8:
                    System.out.println("Voir les offres de stage attribuées");
                    offreAttribuee();
                    System.out.println(" ");
                    break;
            }
        }
        throw new IllegalArgumentException("Le choix que vous avez demandé n'est pas disponible, veuillez choisir un chiffre entre 1 et 8");

    }

    public boolean encoderEtudiant(String nom, String prenom, String mail, String semestre_stage, String mdp) {
        try {

            encoderEtudiantStatement.setString(1, nom);
            encoderEtudiantStatement.setString(2, prenom);
            encoderEtudiantStatement.setString(3, mail);
            encoderEtudiantStatement.setObject(4, semestre_stage, java.sql.Types.OTHER);

            encoderEtudiantStatement.setString(5, mdp);
            boolean success = encoderEtudiantStatement.execute();

            return success;
        } catch (SQLException se) {
            se.printStackTrace();
        }
        return false;
    }

    public boolean encoderEntreprise(String nom, String adresse, String mail, String id_entreprise, String mdp) {
        try {
            encoderEntrepriseStatement.setString(1, nom);
            encoderEntrepriseStatement.setString(2, adresse);
            encoderEntrepriseStatement.setString(3, mail);
            encoderEntrepriseStatement.setString(4, id_entreprise);
            encoderEntrepriseStatement.setString(5, mdp);

            boolean success = encoderEntrepriseStatement.execute();

            return success;
        } catch (SQLException se) {
            se.printStackTrace();
            return false;
        }
    }

    public boolean encoderMotCle(String intituleParam){
        try {

            encoderMotCleStatement.setString(1, intituleParam);

            boolean success = encoderMotCleStatement.execute();

            return success;
        } catch (SQLException se) {
            se.printStackTrace();
            return false;
        }
    }

    public void offreNonValidee(){
        try (ResultSet rs = voirOffreNonValideStatement.executeQuery()) {
                while(rs.next()) {
                    String str = rs.getString(1) + " " + rs.getString(2) + " " + rs.getString(3) + " " + rs.getString(4) + " " + rs.getString(5);
                    System.out.println("Offre n°" + str);
                }
        } catch (SQLException se) {
            se.printStackTrace();
        }
    }

    public boolean validerOffreDeStage(String code_offre){
        try {

            validerOffreDeStageStatement.setString(1, code_offre);

            boolean success = validerOffreDeStageStatement.execute();

            return success;
        } catch (SQLException se) {
            se.printStackTrace();
            return false;
        }
    }

    public void offreValidee(){
        try (ResultSet rs = voirOffreValidesStatement.executeQuery()){
                while(rs.next()) {
                    String str = rs.getString(1) + " " + rs.getString(2) + " " + rs.getString(3) + " " + rs.getString(4) + " " + rs.getString(5);
                    System.out.println("Offre n°" + str);
                }
        } catch (SQLException se) {
            se.printStackTrace();
        }
    }

    public void sansStage(){
        try (ResultSet rs = voirSansStagesStatement.executeQuery()){
            while(rs.next()) {
                    String str = rs.getString(1) + " " + rs.getString(2) + " " + rs.getString(3) + " " + rs.getString(4) + " " + rs.getString(5) ;
                    System.out.println(str);

                }
        } catch (SQLException se) {
            se.printStackTrace();
        }
    }

    public void offreAttribuee(){
        try (ResultSet rs = voirStagesAttribuesStatement.executeQuery()){
                while(rs.next()) {
                    String str = rs.getString(1) + " " + rs.getString(2) + " " + rs.getString(3) + " " + rs.getString(4);
                    System.out.println("Offre : " + str);
                }
        } catch (SQLException se) {
            se.printStackTrace();
        }
    }
}


