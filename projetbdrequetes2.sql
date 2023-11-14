DROP SCHEMA IF EXISTS projet CASCADE;

CREATE SCHEMA projet;
CREATE TYPE projet.semestre_de_stage AS ENUM ('Q1', 'Q2');
CREATE TYPE projet.etat_offre AS ENUM ('non-validée', 'validée', 'annulée', 'attribuée');
CREATE TYPE projet.etat_candidature AS ENUM ('en attente', 'acceptée', 'refusée', 'annulée');


CREATE TABLE projet.etudiants
(
    matricule_etudiant SERIAL PRIMARY KEY NOT NULL,
    nom VARCHAR(40) NOT NULL,
    prenom VARCHAR(40) NOT NULL,
    mail VARCHAR(50) NOT NULL
        CHECK (mail SIMILAR TO '[a-z]+\.[a-z]+@student\.vinci\.be'),
    semestre_stage projet.semestre_de_stage NOT NULL
        CHECK (etudiants.semestre_stage IN ('Q1', 'Q2')),
    mdp VARCHAR(20) NOT NULL,
    nbr_candidatures_en_attente INTEGER NOT NULL DEFAULT 0
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
    etat etat_offre NOT NULL DEFAULT 'non-validée'
);

CREATE TABLE projet.candidatures
(
    etudiant    INTEGER REFERENCES projet.etudiants (matricule_etudiant) NOT NULL,
    offre_stage INTEGER REFERENCES projet.offres_stage(id_offre_stage) NOT NULL,
    motivation VARCHAR(200) NOT NULL,
    etat etat_candidature NOT NULL DEFAULT 'en attente',
    PRIMARY KEY (etudiant, offre_stage)
);

CREATE TABLE projet.mots_cles_offre_stage
(
    offre_stage INTEGER REFERENCES projet.offres_stage (id_offre_stage) NOT NULL,
    mot_cle     INTEGER REFERENCES projet.mots_cles (id_mot_cle) NOT NULL,
    PRIMARY KEY (offre_stage, mot_cle)
);

--INSERT INTO MOTS-CLES
INSERT INTO projet.mots_cles(intitule) VALUES ('Web');
INSERT INTO projet.mots_cles(intitule) VALUES ('SQL');
INSERT INTO projet.mots_cles(intitule) VALUES ('JS');
INSERT INTO projet.mots_cles(intitule) VALUES ('BD');
INSERT INTO projet.mots_cles(intitule) VALUES ('CONCEPTION');

--INSERT INTO ENTREPRISES
INSERT INTO projet.entreprises VALUES ('APP','Apple', 'Siège Social d''Apple', 'apple@icloud.be', '1234');
INSERT INTO projet.entreprises VALUES ('SAM','Samsung', 'Siège Social de Samsung', 'samsung@outlook.com', '1234');
INSERT INTO projet.entreprises VALUES ('MIC', 'Microsoft', 'Siège Social de Microsoft', 'microsoft@outlook.com', '1234');
INSERT INTO projet.entreprises VALUES ('HUA', 'HUAWEI', 'Siège Social d''Huawei', 'huawei@chinaSupremacy.com', '1234');
INSERT INTO projet.entreprises VALUES ('SON', 'SONY', 'Siège Social de Sony', 'sony@gmail.com', '1234');

--INSERT INTO OFFRE_STAGE
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('APP', 'APP1', 'Petit stage sympathique chez Apple', 'Q1');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('APP', 'APP2', 'Petit stage sympathique chez Apple', 'Q2');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('MIC', 'MIC1', 'Petit stage sympathique chez Microsoft','Q1');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('HUA','HUA1','Gros stage de haut niveau chez les chinois','Q1');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('SAM', 'SAM1', 'Petit stage sympathique chez Samsung', 'Q2');

--INSERT INTO ETUDIANTS
INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES ('Qi', 'Joachim', 'joachim.qi@student.vinci.be', 'Q1', '1234');
INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES ('Margjini', 'Mario', 'mario.margjini@student.vinci.be', 'Q1', '1234');
INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES ('Salle', 'Robin', 'robin.salle@student.vinci.be', 'Q2', '1234');

--INSERT INTO CANDIDATURES
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (1, 4, 'Chinese Gang');
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (3, 3, '420Bedave');
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (2, 2, 'Albanian Mafia');


-- L’encodage échouera si le mot clé est déjà présent
CREATE OR REPLACE FUNCTION projet.trigger() RETURNS TRIGGER AS $$
BEGIN
    -- Vérifier si le mot-clé existe déjà
    IF EXISTS(SELECT * FROM projet.mots_cles mc
              WHERE mc.intitule = NEW.intitule) THEN
        -- Lever une exception si le mot-clé existe déjà
        RAISE EXCEPTION 'Ce mot-clé existe déjà';
    END IF;

    -- Si le mot-clé n'existe pas, l'insertion est autorisée
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_mot_cle BEFORE INSERT ON projet.mots_cles
    FOR EACH ROW EXECUTE FUNCTION projet.trigger();



-- APP PROFESSEUR 4.

SELECT os.id_offre_stage, os.code_offre_stage AS code_de_stage, os.semestre_offre AS semestre, e.nom AS entreprise, os.description
FROM projet.offres_stage os, projet.entreprises e
WHERE os.entreprise = e.id_entreprise AND os.etat = 'non-validée'
ORDER BY semestre_offre, e.id_entreprise;

--APP PROFESSEUR 6.
--Voir les offres de stage dans l’état « validée ». Même affichage qu’au point 4.

SELECT os.id_offre_stage, os.code_offre_stage AS code_de_stage, os.semestre_offre AS semestre, e.nom AS entreprise, os.description
FROM projet.offres_stage os, projet.entreprises e
WHERE os.entreprise = e.id_entreprise AND os.etat = 'validée'
ORDER BY semestre_offre, e.id_entreprise;

--APP PROFESSEUR 7.
--Voir les étudiants qui n’ont pas de stage (pas de candidature à l’état « acceptée »).
--Pour chaque étudiant, on affichera son nom, son prénom, son email, le semestre où il
--fera son stage et le nombre de ses candidatures en attente.

SELECT et.nom, et.prenom, et.mail, et.semestre_stage, COUNT(c.*)
FROM projet.etudiants et, projet.candidatures c
WHERE et.matricule_etudiant = c.etudiant AND c.etat != 'acceptée'
GROUP BY et.nom, et.prenom, et.mail, et.semestre_stage;
