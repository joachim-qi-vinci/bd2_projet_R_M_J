DROP SCHEMA IF EXISTS projet CASCADE;
DROP TYPE IF EXISTS semestre_de_stage;
DROP TYPE IF EXISTS etat_offre;
DROP TYPE IF EXISTS etat_candidature;

CREATE SCHEMA projet;
CREATE TYPE semestre_de_stage AS ENUM ('Q1', 'Q2');
CREATE TYPE etat_offre AS ENUM ('non-validée', 'validée', 'annulée', 'attribuée');
CREATE TYPE etat_candidature AS ENUM ('en attente', 'acceptée', 'refusée', 'annulée');


CREATE TABLE projet.etudiants
(
    matricule_etudiant SERIAL PRIMARY KEY NOT NULL,
    nom VARCHAR(40) NOT NULL,
    prenom VARCHAR(40) NOT NULL,
    mail VARCHAR(50) NOT NULL
        CHECK ( mail SIMILAR TO '[a-z].[a-z]@student.vinci.be'),
    semestre_stage semestre_de_stage NOT NULL
        CHECK (etudiants.semestre_stage IN ('Q1', 'Q2')),
    mdp VARCHAR(20) NOT NULL,
    nbr_candidatures_en_attente INTEGER NOT NULL
);

CREATE TABLE projet.entreprises
(
    id_entreprise CHAR(3) PRIMARY KEY NOT NULL
        CHECK ( id_entreprise SIMILAR TO '[A-Z]{3}'),
    nom VARCHAR(40) NOT NULL,
    adresse VARCHAR(100) NOT NULL,
    mail VARCHAR(60) NOT NULL,
    mpd VARCHAR(20) NOT NULL
);

CREATE TABLE projet.mots_cles
(
    id_mot_cle SERIAL PRIMARY KEY NOT NULL,
    intitule VARCHAR(15) NOT NULL
);

CREATE TABLE projet.offres_stage
(
    id_offre_stage SERIAL PRIMARY KEY NOT NULL,
    entreprise CHAR(3) REFERENCES projet.entreprises(id_entreprise) NOT NULL,
    code_offre_stage VARCHAR(5) NOT NULL
        CHECK ( code_offre_stage SIMILAR TO '[A-Z]{3}[0-9]')
    ,
    description VARCHAR(200) NOT NULL,
    semestre_offre semestre_de_stage NOT NULL
        CHECK (semestre_offre IN ('Q1', 'Q2')),
    etat etat_offre NOT NULL
);

CREATE TABLE projet.candidatures
(
    etudiant    INTEGER REFERENCES projet.etudiants (matricule_etudiant) NOT NULL,
    offre_stage INTEGER REFERENCES projet.offres_stage(id_offre_stage) NOT NULL,
    motivation VARCHAR(200) NOT NULL,
    etat etat_candidature NOT NULL,
    PRIMARY KEY (etudiant, offre_stage)
);

CREATE TABLE projet.mots_cles_offre_stage
(
    offre_stage INTEGER REFERENCES projet.offres_stage (id_offre_stage) NOT NULL,
    mot_cle     INTEGER REFERENCES projet.mots_cles (id_mot_cle) NOT NULL,
    PRIMARY KEY (offre_stage, mot_cle)
);
