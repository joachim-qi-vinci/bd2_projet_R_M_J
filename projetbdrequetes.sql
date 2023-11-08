DROP SCHEMA IF EXISTS projet CASCADE;
CREATE SCHEMA projet;


/*CREATE TYPE semestre_de_stage AS ENUM ('Q1', 'Q2');
CREATE TYPE etat_offre AS ENUM ('non-validée', 'validée', 'annulée', 'attribuée');
CREATE TYPE etat_candidature AS ENUM ('en attente', 'acceptée', 'refusée', 'annulée');
*/
CREATE TABLE projet.etudiants (
                                  matricule_etudiant SERIAL PRIMARY KEY,
                                  nom VARCHAR(40),
                                  prenom VARCHAR(30),
                                  mail VARCHAR(50),
                                  semestre_stage semestre_de_stage,
                                  mdp varchar(20),
                                  nbr_candidatures_en_attente INTEGER
);

CREATE TABLE projet.entreprises (
                                    id_entreprise CHAR(3) PRIMARY KEY,
                                    nom VARCHAR(40),
                                    adresse VARCHAR(100),
                                    mail VARCHAR(60),
                                    mpd VARCHAR(20)
);

CREATE TABLE projet.mots_cles (
                                  id_mot_cle SERIAL PRIMARY KEY,
                                  intitule VARCHAR(15)
);

CREATE TABLE projet.offres_stage (
    id_offre_stage SERIAL PRIMARY KEY,
    entreprise CHAR(3) REFERENCES projet.entreprises(id_entreprise),
    code_offre_stage VARCHAR(5),
    description VARCHAR(200),
    semestre semestre_de_stage,
    etat etat_offre
);

CREATE TABLE projet.candidatures
(
    etudiant    INTEGER REFERENCES projet.etudiants (matricule_etudiant),
    offre_stage INTEGER REFERENCES projet.offres_stage(id_offre_stage),
    motivation VARCHAR(200),
    etat etat_candidature,
    PRIMARY KEY (etudiant, offre_stage)
);

CREATE TABLE mots_cles_offre_stage (
    offre_stage INTEGER REFERENCES projet.offres_stage(id_offre_stage),
    mot_cle INTEGER REFERENCES projet.mots_cles(id_mot_cle),
    PRIMARY KEY (offre_stage, mot_cle)
);