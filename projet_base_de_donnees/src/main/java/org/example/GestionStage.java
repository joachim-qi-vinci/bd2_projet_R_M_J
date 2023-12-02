package org.example;

import org.postgresql.util.PSQLException;

import java.sql.*;
import java.util.Scanner;

public class GestionStage {

    Connection conn=null;
    public GestionStage(){

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }
        String url="jdbc:postgresql://localhost:5432/postgres";

        try {
            this.conn= DriverManager.getConnection(url,"joachim","1234");
            System.out.println("Vous êtes connecté");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
    }

    public void run() {


        Scanner scanner = new Scanner(System.in);
        int choix = -1;
        while ((choix > 0 && choix <= 8) || choix == -1 ) {
            System.out.println("Choissiez l'action à effectuer");
            System.out.println("1 : Encoder un nouvel étudiant");
            System.out.println("2 : Encoder une nouvelle entreprise");
            System.out.println("3 : Encoder un mot-clé");
            System.out.println("4 : Voir les offres de stage non-validées");
            System.out.println("5 : Valider une offre de stage");
            System.out.println("6 : Voir les offres de stage validées");
            System.out.println("7 : Voir les étudiants qui n'ont pas de stage");
            System.out.println("8 : Voir les offres de stage attribuées");
            System.out.println("Entrez un nombre entre 1 et 8 : ");
            choix = scanner.nextInt();

            switch (choix) {
                case 1:
                    System.out.println("Encoder un nouvel étudiant");
                    Scanner scanner1 = new Scanner(System.in);
                    System.out.println("Entrez le nom : ");
                    String nom = scanner1.nextLine();
                    System.out.println("Entrez le prénom : ");
                    String prenom = scanner1.nextLine();
                    System.out.println("Entrez l'adresse mail : ");
                    String mail = scanner1.nextLine();
                    System.out.println("Entrez le semestre de stage : ");
                    String semestre_stage = scanner1.nextLine();
                    System.out.println("Entrez le mot de passe : ");
                    String mdp = scanner1.nextLine();
                    encoderEtudiant(nom, prenom, mail, semestre_stage, mdp);
                    if (encoderEtudiant(nom, prenom, mail, semestre_stage, mdp)){
                        System.out.println("Etudiant ajouté");
                    }else{
                        System.out.println("Échec de l'ajout");
                    }

                    break;
                case 2:
                    System.out.println("Encoder une nouvelle entreprise");
                    break;
                case 3:
                    System.out.println("Encoder un mot-clé");
                    break;
                case 4:
                    System.out.println("Voir les offres de stage non-validées");
                    break;
                case 5:
                    System.out.println("Valider une offre de stage");
                    break;
                case 6:
                    System.out.println("Voir les offres de stage validées");
                    break;
                case 7:
                    System.out.println("Voir les étudiants qui n'ont pas de stage");
                    break;
                case 8:
                    System.out.println("Voir les offres de stage attribuées");
                    break;
            }
        }
        throw new IllegalArgumentException("Le choix que vous avez demandé n'est pas disponible, veuillez choisir un chiffre entre 1 et 8");

    }

    public boolean encoderEtudiant(String nom, String prenom, String mail, String semestre_stage, String mdp){

        try {
            PreparedStatement ps = conn.prepareStatement("SELECT projet.encoderEtudiant(?, ?, ?, ?, ?)");
            ps.setString(1,nom);
            ps.setString(2,prenom);
            ps.setString(3,mail);
            ps.setObject(4, semestre_stage, java.sql.Types.OTHER);

            ps.setString(5,mdp);
            boolean success = ps.execute();

            if (success) {
                System.out.println("L'insertion a réussi.");
                return true;
            } else {
                System.out.println("L'insertion a échoué.");
                return false;
            }
        } catch (SQLException se) {
            se.printStackTrace();
        }

        return false;
    }
}
