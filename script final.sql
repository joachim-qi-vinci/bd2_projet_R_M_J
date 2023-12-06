DROP SCHEMA IF EXISTS projet CASCADE;

CREATE SCHEMA projet;
CREATE TYPE projet.semestre_de_stage AS ENUM ('Q1', 'Q2');
CREATE TYPE projet.etat_offre AS ENUM ('non-validée', 'validée', 'annulée', 'attribuée');
CREATE TYPE projet.etat_candidature AS ENUM ('en attente', 'acceptée', 'refusée', 'annulée');


CREATE TABLE projet.etudiants
(
    id_etudiant SERIAL PRIMARY KEY NOT NULL,
    nom VARCHAR(40) NOT NULL
        CHECK (nom != ''),
    prenom VARCHAR(40) NOT NULL
        CHECK (prenom != ''),
    mail VARCHAR(50) NOT NULL
        CHECK (mail SIMILAR TO '[a-z]+\.[a-z]+@student\.vinci\.be'),
    semestre_stage projet.semestre_de_stage NOT NULL ,
    mdp VARCHAR(100) NOT NULL,
    nbr_candidatures_en_attente INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT nom_prenom UNIQUE (nom, prenom)
);

CREATE TABLE projet.mots_cles
(
    id_mot_cle SERIAL PRIMARY KEY NOT NULL,
    intitule VARCHAR(50) NOT NULL CHECK (intitule <> '') UNIQUE
);

CREATE TABLE projet.entreprises
(
    id_entreprise CHAR(3) PRIMARY KEY NOT NULL
        CHECK ( id_entreprise SIMILAR TO '[A-Z]{3}'),
    nom VARCHAR(40) NOT NULL
        CHECK (nom <> ''),
    adresse VARCHAR(100) NOT NULL
        CHECK (adresse <> ''),
    mail VARCHAR(60) NOT NULL,
    CHECK ( mail SIMILAR TO '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9]+'),
    mpd VARCHAR(100) NOT NULL,
    CONSTRAINT entreprise_adresse_mail UNIQUE (nom, adresse, mail)
);

CREATE TABLE projet.offres_stage
(
    id_offre_stage SERIAL PRIMARY KEY NOT NULL,
    entreprise CHAR(3) REFERENCES projet.entreprises(id_entreprise) NOT NULL,
    code_offre_stage VARCHAR(5) NOT NULL UNIQUE
        CHECK ( code_offre_stage SIMILAR TO '[A-Z]{3}[0-9]')
    ,
    description VARCHAR(200) NOT NULL CHECK (description <> ''),
    semestre_offre projet.semestre_de_stage NOT NULL,
    etat projet.etat_offre NOT NULL DEFAULT 'non-validée'
);

CREATE TABLE projet.candidatures
(
    etudiant    INTEGER REFERENCES projet.etudiants (id_etudiant) NOT NULL,
    offre_stage INTEGER REFERENCES projet.offres_stage(id_offre_stage) NOT NULL,
    motivation VARCHAR(200) NOT NULL,
    etat projet.etat_candidature NOT NULL DEFAULT 'en attente',
    PRIMARY KEY (etudiant, offre_stage)
);

CREATE TABLE projet.mots_cles_offre_stage
(
    offre_stage INTEGER REFERENCES projet.offres_stage (id_offre_stage) NOT NULL,
    mot_cle     INTEGER REFERENCES projet.mots_cles (id_mot_cle) NOT NULL,
    PRIMARY KEY (offre_stage, mot_cle)
);

--INSERT INTO ETUDIANTS
INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES ('De', 'Jean', 'j.d@student.vinci.be', 'Q2', '$2a$10$L9iqDEW6HAFBKCyCxngue.sIFy.oFybUfYeOIyVhrxZtI/F9OyD7C');
INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES ('Du', 'Marc', 'm.d@student.vinci.be', 'Q1', '$2a$10$L9iqDEW6HAFBKCyCxngue.sIFy.oFybUfYeOIyVhrxZtI/F9OyD7C');

--INSERT INTO MOTS-CLES
INSERT INTO projet.mots_cles(intitule) VALUES ('Java');
INSERT INTO projet.mots_cles(intitule) VALUES ('Web');
INSERT INTO projet.mots_cles(intitule) VALUES ('Python');

--INSERT INTO ENTREPRISES
INSERT INTO projet.entreprises VALUES ('VIN','Vinci', 'rue Leonard De Vinci', 'vinci@vinci.be', '$2a$10$L9iqDEW6HAFBKCyCxngue.sIFy.oFybUfYeOIyVhrxZtI/F9OyD7C');
INSERT INTO projet.entreprises VALUES ('ULB', 'ULB', 'rue université libre', 'ulb@ulb.com', '$2a$10$L9iqDEW6HAFBKCyCxngue.sIFy.oFybUfYeOIyVhrxZtI/F9OyD7C');

--INSERT INTO OFFRE_STAGE
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre, etat) VALUES ('VIN', 'VIN1', 'stage SAP', 'Q2','validée');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('VIN', 'VIN2', 'stage BI', 'Q2');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('VIN', 'VIN3', 'stage Unity','Q2');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre, etat) VALUES ('VIN','VIN4','stage IA','Q2', 'validée');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre, etat) VALUES ('VIN', 'VIN5', 'stage mobile', 'Q1', 'validée');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre, etat) VALUES ('ULB', 'ULB1', 'stage javascript', 'Q1','validée');

--INSERT INTO MOTS-CLES-OFFRES-STAGES
INSERT INTO projet.mots_cles_offre_stage(offre_stage, mot_cle) VALUES (3,1);
INSERT INTO projet.mots_cles_offre_stage(offre_stage, mot_cle) VALUES (5,1);

--INSERT INTO CANDIDATURES
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation, etat) VALUES (1, 4, 'jean adore leonard','acceptée');
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation, etat) VALUES (1, 3, 'Chinese Gang', 'en attente');


--APP PROFESSEUR 1.
CREATE OR REPLACE FUNCTION projet.encoderEtudiant(nom_etudiant VARCHAR(40), prenom_etudiant VARCHAR(40), mail_etudiant VARCHAR(50),
                                                  semestre projet.semestre_de_stage,mdp_etudiant VARCHAR(100)) RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES (nom_etudiant, prenom_etudiant, mail_etudiant, semestre, mdp_etudiant);
END;
$$ LANGUAGE plpgsql;

--APP PROFESSEUR 2.

CREATE OR REPLACE FUNCTION projet.encoderEntreprise(nom_entreprise VARCHAR(40), adresse_entreprise VARCHAR(100), mail_entreprise VARCHAR(60),
                                                    identifiant_entreprise CHAR(3), mdp_entreprise VARCHAR(100)) RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO projet.entreprises(id_entreprise, nom, adresse, mail, mpd)
    VALUES (identifiant_entreprise, nom_entreprise, adresse_entreprise, mail_entreprise, mdp_entreprise);
END;
$$ LANGUAGE plpgsql;

--APP PROFESSEUR 3.

CREATE OR REPLACE FUNCTION projet.encoderMotCle(intituleParam VARCHAR(15)) RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO projet.mots_cles(intitule) VALUES (intituleParam);
END;
$$ LANGUAGE plpgsql;


-- APP PROFESSEUR 4.
CREATE VIEW projet.offreNonValidee AS
SELECT os.id_offre_stage, os.code_offre_stage AS code_de_stage, os.semestre_offre AS semestre, e.nom AS entreprise, os.description
FROM projet.offres_stage os, projet.entreprises e
WHERE os.entreprise = e.id_entreprise AND os.etat = 'non-validée'
ORDER BY semestre_offre, e.id_entreprise;

--APP PROFESSEUR 5.

CREATE OR REPLACE FUNCTION projet.triggerUpdateOffre() RETURNS TRIGGER AS $$
BEGIN
    -- Vérifier si l'offre de stage est à l'état "non validée"
    IF (NEW.etat = 'validée' AND OLD.etat != 'non-validée') THEN
        RAISE 'L''offre ne peut plus etre validée';
    END IF;
    -- Vérifier si l'offre est validée avant de l'attribuer
    IF (NEW.etat = 'attribuée' AND OLD.etat != 'validée') THEN
        RAISE 'L''offre ne peut pas etre attribuée';
    END IF;
    -- Si l'offre est annulée on ne peut plus rien faire
    IF (OLD.etat = 'annulée') THEN
        RAISE 'Cette offre est annulée';
    END IF;
    -- Si l'offre est attribuée on ne peut plus rien faire
    IF (OLD.etat = 'attribuée') THEN
        RAISE 'Cette offre est déjà attribuée';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_valider_offre_stage BEFORE UPDATE ON projet.offres_stage
    FOR EACH ROW EXECUTE PROCEDURE projet.triggerUpdateOffre();

CREATE OR REPLACE FUNCTION projet.validerOffreDeStage(code_offre VARCHAR(5)) RETURNS VOID AS $$
DECLARE
BEGIN

    UPDATE projet.offres_stage  SET etat='validée' WHERE code_offre_stage = code_offre;
END;
$$ LANGUAGE plpgsql;


--APP PROFESSEUR 6.

CREATE VIEW projet.offresValidees AS
SELECT os.id_offre_stage, os.code_offre_stage AS code_de_stage, os.semestre_offre AS semestre, e.nom AS entreprise, os.description
FROM projet.offres_stage os, projet.entreprises e
WHERE os.entreprise = e.id_entreprise AND os.etat = 'validée'
ORDER BY semestre_offre, e.id_entreprise;


--APP PROFESSEUR 7.
CREATE VIEW projet.etudiantsSansStage AS
SELECT et.nom, et.prenom, et.mail, et.semestre_stage, et.nbr_candidatures_en_attente
FROM projet.etudiants et
WHERE et.id_etudiant NOT IN (SELECT c.etudiant
                             FROM projet.candidatures c
                             WHERE et.id_etudiant = c.etudiant AND c.etat = 'acceptée');

--APP PROFESSEUR 8.
CREATE VIEW projet.offresStagesAttribuees AS
SELECT
    os.code_offre_stage,
    os.entreprise,
    e.nom AS nom_etudiant,
    e.prenom AS prenom_etudiant
FROM
    projet.offres_stage os
        JOIN
    projet.candidatures ca ON os.id_offre_stage = ca.offre_stage
        JOIN
    projet.etudiants e ON ca.etudiant = e.id_etudiant;

WITH candidatures_en_attente AS (
    SELECT os.id_offre_stage, COUNT(c.etudiant) AS nb_candidatures_attente
    FROM projet.offres_stage os LEFT OUTER JOIN projet.candidatures c on os.id_offre_stage = c.offre_stage
        AND c.offre_stage = os.id_offre_stage
        AND c.etat = 'en attente'
    GROUP BY os.id_offre_stage)

SELECT * FROM projet.offres_stage os WHERE os.etat = 'attribuée';

--APP ÉTUDIANT 1.

CREATE OR REPLACE VIEW projet.voirOffresValideesSemestre AS
SELECT  et.id_etudiant, os.code_offre_stage, os.entreprise,os.semestre_offre, en.nom, en.adresse, os.description, string_agg(mc.intitule,',' ) AS mots_cles
FROM projet.etudiants et, projet.entreprises en, projet.offres_stage os LEFT OUTER JOIN projet.mots_cles_offre_stage mcos ON mcos.offre_stage=os.id_offre_stage LEFT OUTER JOIN projet.mots_cles mc ON mcos.mot_cle=mc.id_mot_cle
WHERE et.semestre_stage = os.semestre_offre
  AND os.etat = 'validée'
  AND os.entreprise=en.id_entreprise
GROUP BY et.id_etudiant,os.code_offre_stage, os.entreprise,os.semestre_offre,en.nom, en.adresse, os.description;


--APP ÉTUDIANT 2.

CREATE OR REPLACE VIEW projet.voirOffresParMotsCles AS
SELECT  et.id_etudiant,os.semestre_offre, os.code_offre_stage, os.entreprise, en.nom, en.adresse, os.description,string_agg(mc.intitule,',' )AS mots_cles, mc.intitule
FROM projet.entreprises en,projet.etudiants et,projet.offres_stage os LEFT OUTER JOIN projet.mots_cles_offre_stage mcos ON mcos.offre_stage=os.id_offre_stage LEFT OUTER JOIN projet.mots_cles mc ON mcos.mot_cle=mc.id_mot_cle
WHERE et.semestre_stage = os.semestre_offre
  AND os.etat = 'validée'
  AND os.entreprise=en.id_entreprise
GROUP BY et.id_etudiant, os.semestre_offre, os.code_offre_stage, os.entreprise, en.nom, en.adresse, os.description, mc.intitule;


SELECT o.code_offre_stage,o.entreprise,o.semestre_offre,o.nom,o.adresse,o.description,o.mots_cles FROM projet.voirOffresParMotsCles o WHERE o.id_etudiant=2 AND o.intitule = 'Java';

--APP ÉTUDIANT 3.
--Poser sa candidature. Pour cela, il doit donner le code de l’offre de stage et donner ses
--motivations sous format textuel. Il ne peut poser de candidature s’il a déjà une
--candidature acceptée, s’il a déjà posé sa candidature pour cette offre, si l’offre n’est
--pas dans l’état validée ou si l’offre ne correspond pas au bon semestre.


CREATE OR REPLACE FUNCTION projet.triggerPoserCandidature() RETURNS TRIGGER AS $$
DECLARE
    etudiant_semestre projet.semestre_de_stage;
    offre_semestre projet.semestre_de_stage;
BEGIN
    IF EXISTS(SELECT ca.etudiant --, ca.offre_stage, ca.motivation, ca.etat, ca.etudiant, ca.offre_stage,
              FROM projet.candidatures ca
              WHERE ca.etudiant = NEW.etudiant
                AND ca.etat = 'acceptée')
    THEN RAISE 'cet étudiant a déjà une offre validée';
    END IF;
    IF NOT EXISTS (SELECT os.id_offre_stage
                   FROM projet.offres_stage os
                   WHERE os.id_offre_stage = NEW.offre_stage
                     AND os.etat='validée')
    THEN RAISE 'cet offre de stage n''a pas été validée';
    END IF;
    SELECT et.semestre_stage
    FROM projet.etudiants et
    WHERE et.id_etudiant=NEW.etudiant
    INTO etudiant_semestre;
    SELECT os.semestre_offre
    FROM projet.offres_stage os
    WHERE os.id_offre_stage = NEW.offre_stage
    INTO offre_semestre;
    IF (etudiant_semestre!=offre_semestre)
    THEN RAISE 'les semestres ne correspondent pas';
    END IF;

END
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggerPoserCandidature BEFORE INSERT ON projet.candidatures
    FOR EACH ROW EXECUTE PROCEDURE projet.triggerPoserCandidature();

CREATE OR REPLACE function projet.poserCandidature(etudiantP INTEGER, code_offre varchar(5),motivationP varchar(200))
    RETURNS VOID AS $$
DECLARE
    id_offre INTEGER;
BEGIN

    SELECT os.id_offre_stage
    FROM projet.offres_stage os
    WHERE os.code_offre_stage = code_offre
    INTO id_offre;
    INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (etudiantP,id_offre,motivationP);

END ;
$$ LANGUAGE plpgsql;

--SELECT projet.poserCandidature(1, 'ULB4', 'coucou c est greg');
-- APP ETUDIANT 4.

CREATE VIEW projet.mesCandidatures AS
SELECT ca.etudiant, os.code_offre_stage, en.nom, ca.etat
FROM projet.offres_stage os, projet.entreprises en, projet.candidatures ca
WHERE os.entreprise = en.id_entreprise AND ca.offre_stage = os.id_offre_stage;



--APP ETUDIANT 5.
--Annuler une candidature en précisant le code de l’offre de stage. Les candidatures ne
--peuvent être annulées que si elles sont « en attente »

CREATE OR REPLACE FUNCTION projet.triggerAnnulerCandidature() RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.etat !='en attente')
    THEN RAISE 'la candidature doit être en attente pourpouvoir être annulée';
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_annuler_candidature BEFORE UPDATE ON projet.candidatures
    FOR EACH ROW EXECUTE PROCEDURE projet.triggerAnnulerCandidature();

CREATE OR REPLACE FUNCTION projet.annulerCandidature(etudiantP INTEGER,offreP INTEGER) RETURNS void AS $$
BEGIN
    UPDATE projet.candidatures ca SET etat='annulée' WHERE ca.etudiant = etudiantP AND ca.offre_stage=offreP;
END
$$ LANGUAGE plpgsql;

--APP ENTREPRISE 1.

CREATE OR REPLACE FUNCTION projet.triggerInsertOffreDeStage() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(SELECT * FROM projet.offres_stage o
              WHERE o.semestre_offre = NEW.semestre_offre AND o.entreprise = NEW.entreprise and o.etat = 'attribuée')
    THEN RAISE 'L’entreprise a déjà une offre de stage attribuée durant ce semestre';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_insert_offre_de_stage BEFORE INSERT ON projet.offres_stage
    FOR EACH ROW EXECUTE PROCEDURE projet.triggerInsertOffreDeStage();


CREATE OR REPLACE FUNCTION projet.encoderOffreDeStage(id_entreprise CHAR(3), description_offre VARCHAR(200), semestre projet.semestre_de_stage) RETURNS VOID AS $$
DECLARE
    nbrStage INTEGER;
BEGIN
    SELECT COUNT(os.id_offre_stage)
    FROM projet.offres_stage os
    WHERE os.entreprise = id_entreprise INTO nbrStage;
    INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES (id_entreprise, id_entreprise || nbrStage + 1, description_offre, semestre);
END;
$$ LANGUAGE plpgsql;


--APP entreprise 2.

CREATE VIEW projet.voirMotsCles AS
SELECT DISTINCT mc.intitule
FROM projet.mots_cles mc;


--APP entreprise 3.

CREATE OR REPLACE FUNCTION projet.triggerAjouterMotCleOffre() RETURNS TRIGGER AS $$
BEGIN
    IF ((SELECT COUNT(mcos.mot_cle)
         FROM projet.mots_cles_offre_stage mcos
         WHERE mcos.offre_stage = NEW.offre_stage) = 3) THEN RAISE 'Une offre de stage peut avoir au maximum 3 mots-clés';
    END IF;

    IF(NOT EXISTS(SELECT mc.id_mot_cle
                  FROM projet.mots_cles mc
                  WHERE mc.id_mot_cle = NEW.mot_cle)) THEN RAISE 'Ce mot clé n''existe pas';
    END IF;

    IF(EXISTS(SELECT os.id_offre_stage
              FROM projet.offres_stage os
              WHERE os.id_offre_stage = NEW.offre_stage AND (os.etat = 'attribuée' OR os.etat = 'annulée'))) THEN RAISE 'L''offre de stage est déjà attribuée ou annulée';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_insert_mot_cle_offre_de_stage BEFORE INSERT ON projet.mots_cles_offre_stage
    FOR EACH ROW EXECUTE PROCEDURE projet.triggerAjouterMotCleOffre();

CREATE OR REPLACE FUNCTION projet.ajouterUnMotCleOffreDeStage(offre_stage VARCHAR(5), mot_cle VARCHAR(15), id_entreprise CHAR(3)) RETURNS VOID AS $$
DECLARE
    id_offre_de_stage INTEGER;
    id_mot_cle INTEGER;
BEGIN
    SELECT os.id_offre_stage
    FROM projet.offres_stage os
    WHERE os.code_offre_stage = offre_stage INTO id_offre_de_stage;

    IF id_offre_de_stage IS NULL THEN RAISE 'Il n y a aucune offre de stage associée à ce code';
    END IF;

    SELECT mc.id_mot_cle
    FROM projet.mots_cles mc
    WHERE mc.intitule = mot_cle INTO id_mot_cle;

    IF(NOT EXISTS(SELECT os.id_offre_stage
                  FROM projet.offres_stage os
                  WHERE os.id_offre_stage = id_offre_de_stage AND os.entreprise = id_entreprise)) THEN RAISE 'Ce n''est pas une offre de stage de l''entreprise';
    END IF;

    INSERT INTO projet.mots_cles_offre_stage VALUES (id_offre_de_stage, id_mot_cle);
END;
$$ LANGUAGE plpgsql;



--APP ENTREPRISE 4.

CREATE VIEW projet.mesOffres AS
WITH candidatures_en_attente AS (
    SELECT os.id_offre_stage ,COUNT(c.etudiant) AS nb_candidatures_attente
    FROM projet.offres_stage os LEFT OUTER JOIN projet.candidatures c on os.id_offre_stage = c.offre_stage
        AND c.offre_stage = os.id_offre_stage
        AND c.etat = 'en attente'
    GROUP BY os.id_offre_stage)
SELECT os.entreprise, os.code_offre_stage, os.description, os.semestre_offre, os.etat,cea.nb_candidatures_attente ,COALESCE(e.nom,'non-attribuée') AS attribuée_a
FROM   candidatures_en_attente cea, projet.offres_stage os
                                        LEFT OUTER JOIN projet.candidatures ca ON os.id_offre_stage = ca.offre_stage AND ca.etat = 'acceptée'
                                        LEFT OUTER JOIN projet.etudiants e ON ca.etudiant = e.id_etudiant
WHERE cea.id_offre_stage = os.id_offre_stage;


--APPLICATION ENTREPRISE 5
/*
 Voir les candidatures pour une de ses offres de stages en donnant son code. Pour
chaque candidature, on affichera son état, le nom, prénom, adresse mail et les
motivations de l’étudiant. Si le code ne correspond pas à une offre de l’entreprise ou
qu’il n’y a pas de candidature pour cette offre, le message suivant sera affiché “Il n'y a
pas de candidatures pour cette offre ou vous n'avez pas d'offre ayant ce code”.
 */


CREATE OR REPLACE FUNCTION projet.voirLesCandidaturesOffre(offre_stage_param VARCHAR(5),id_entreprise_param CHAR(3)) RETURNS SETOF RECORD AS $$
DECLARE
    id_offre INTEGER;
BEGIN
    -- Gestion des cas particuliers
    SELECT os.id_offre_stage
    FROM projet.offres_stage os
    WHERE os.code_offre_stage = offre_stage_param INTO id_offre;

    IF id_offre IS NULL OR (offre_stage_param, id_entreprise_param) NOT IN (
        SELECT DISTINCT os.code_offre_stage, os.entreprise
        FROM projet.offres_stage os
        WHERE os.entreprise = id_entreprise_param)
    THEN
        RAISE 'Il n''y a pas de candidatures pour cette offre ou vous n''avez pas d''offre ayant ce code';
    END IF;

    -- Sélection des candidatures
    RETURN QUERY
        SELECT ca.etat, e.nom, e.prenom, e.mail, ca.motivation
        FROM projet.candidatures ca
                 LEFT JOIN projet.etudiants e ON ca.etudiant = e.id_etudiant
        WHERE ca.offre_stage = id_offre;
END;
$$ LANGUAGE plpgsql;


--APP ENTREPRISE 6
/*
 6. Sélectionner un étudiant pour une de ses offres de stage. Pour cela, l’entreprise devra
donner le code de l’offre et l’adresse mail de l’étudiant. L’opération échouera si l’offre
de stage n’est pas une offre de l’entreprise, si l’offre n’est pas dans l’état « validée »
ou que la candidature n’est pas dans l’état « en attente ». L’état de l’offre passera à
« attribuée ». La candidature de l’étudiant passera à l’état « acceptée ». Les autres
candidatures en attente de cet étudiant passeront à l’état « annulée ». Les autres
candidatures en attente d’étudiants pour cette offre passeront à « refusée ». Si
l’entreprise avait d’autres offres de stage non annulées durant ce semestre, l’état de
celles-ci doit passer à « annulée » et toutes les candidatures en attente de ces offres
passeront à « refusée »
 */

CREATE OR REPLACE FUNCTION projet.trigger_refuser_candidature_en_attente() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.etat = 'annulée' AND OLD.etat != 'annulée') THEN UPDATE projet.candidatures c SET etat = 'refusée' WHERE c.etat = 'en attente' AND NEW.id_offre_stage = c.offre_stage;
    END IF;

    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_refuser_candidature_en_attente AFTER UPDATE ON projet.offres_stage
    FOR EACH ROW EXECUTE PROCEDURE projet.trigger_refuser_candidature_en_attente();


CREATE OR REPLACE FUNCTION projet.selectionnerEtudiantPourUneOffreDeStage(code_offre_stage_atribuee VARCHAR(5), adresse_email_etudiant VARCHAR(50), entreprise_app CHAR(3)) RETURNS VOID AS $$
DECLARE
    offre_attribuee RECORD;
    candidature_acceptee RECORD;
    etudiant_accepte RECORD;
BEGIN
    SELECT os.*
    FROM projet.offres_stage os
    WHERE os.code_offre_stage = code_offre_stage_atribuee INTO offre_attribuee;

    SELECT e.*
    FROM projet.etudiants e
    WHERE e.mail = adresse_email_etudiant INTO etudiant_accepte;

    SELECT c.*
    FROM projet.candidatures c
    WHERE c.offre_stage = offre_attribuee.id_offre_stage AND c.etudiant = etudiant_accepte.id_etudiant INTO candidature_acceptee;

    IF (offre_attribuee IS NULL) THEN RAISE 'Ce code ne correspond à aucune offre de stage';
    END IF;

    IF(offre_attribuee.entreprise != entreprise_app) THEN RAISE 'L''offre n''est pas une offre de l''entreprise';
    END IF;

    IF(offre_attribuee.etat != 'validée') THEN RAISE 'L''offre n''est pas dans l''état validée';
    END IF;

    IF(candidature_acceptee.etat != 'en attente') THEN RAISE 'La candidature n''est pas dans l''état en attente';
    END IF;

    -- change l'état de l'offre en attribuée
    UPDATE projet.offres_stage os SET etat='attribuée' WHERE os.code_offre_stage = offre_attribuee.code_offre_stage;
    -- change l'état de la candidature de l'étudiant en acceptée
    UPDATE projet.candidatures c SET etat='acceptée' WHERE c.etudiant = etudiant_accepte.id_etudiant AND c.offre_stage = offre_attribuee.id_offre_stage;
    -- change l'état de toutes les autres candidatures de l'étudiant en annulée
    UPDATE projet.candidatures c SET etat='annulée' WHERE c.etudiant = etudiant_accepte.id_etudiant AND c.etat = 'en attente';
    --change l'état de toutes les candidatures des autres étudiants pour cette offre de stage en refusée
    UPDATE projet.candidatures c SET etat='refusée' WHERE c.offre_stage = offre_attribuee.id_offre_stage AND c.etat = 'en attente';
    --
    UPDATE projet.offres_stage os SET etat='annulée' WHERE os.entreprise = entreprise_app AND os.etat != 'annulée' and os.semestre_offre = offre_attribuee.semestre_offre AND os.id_offre_stage != offre_attribuee.id_offre_stage;
END;
$$ LANGUAGE plpgsql;


--APP ENTREPRISE 7
/*Annuler une offre de stage en donnant son code. Cette opération ne pourra être
réalisée que si l’offre appartient bien à l’entreprise et si elle n’est pas encore attribuée,
ni annulée. Toutes les candidatures en attente de cette offre passeront à « refusée ».
 */

CREATE OR REPLACE FUNCTION projet.annulerOffreDeStage() RETURNS TRIGGER AS $$
BEGIN
    -- Si l'offre est annulée on ne peut plus rien faire
    IF (OLD.etat = 'annulée') THEN
        RAISE 'Cette offre est annulée';
    END IF;
    -- Si l'offre est attribuée on ne peut plus rien faire
    IF (OLD.etat = 'attribuée') THEN
        RAISE 'Cette offre est déjà attribuée';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verifierOffreDeStage BEFORE UPDATE ON projet.offres_stage
    FOR EACH ROW EXECUTE PROCEDURE projet.annulerOffreDeStage();


CREATE OR REPLACE FUNCTION projet.annulerOffreStage(code_offre VARCHAR(5), entrepriseAPP CHAR(3)) RETURNS VOID AS $$
DECLARE
    id_offre INTEGER;
BEGIN
    SELECT os.id_offre_stage FROM projet.offres_stage os WHERE os.code_offre_stage = code_offre AND os.entreprise = entrepriseAPP INTO id_offre;
    IF(id_offre IS NULL) THEN RAISE 'Ce n''est pas une offre de l''entreprise';
    END IF;
    UPDATE projet.offres_stage os SET etat='annulée' WHERE os.id_offre_stage = id_offre;

END;
$$ LANGUAGE plpgsql;


 --create user
--CREATE USER joachim WITH PASSWORD '1234';
--CREATE USER etudiant WITH PASSWORD '4321';


-- CREATE USER
--CREATE USER joachime WITH PASSWORD '1234';
--CREATE USER etudiant WITH PASSWORD '4321';
/*
GRANT CONNECT ON DATABASE dbjoachimqi TO mariomargjini, robinsalle;
GRANT USAGE ON SCHEMA projet TO mariomargjini, robinsalle;
GRANT SELECT ON projet.offres_stage, projet.mots_cles, projet.mots_cles_offre_stage, projet.candidatures, projet.etudiants, projet.entreprises, projet.offreNonValidee, projet.offresValidees, projet.etudiantsSansStage, projet.offresStagesAttribuees TO joachime;
GRANT UPDATE ON projet.offres_stage, projet.candidatures TO joachime;
GRANT INSERT ON projet.offres_stage, projet.mots_cles_offre_stage, projet.entreprises, projet.mots_cles TO joachime;
GRANT SELECT, UPDATE ON SEQUENCE projet.offres_stage_id_offre_stage_seq, projet.mots_cles_id_mot_cle_seq TO joachime;
GRANT SELECT, UPDATE ON SEQUENCE projet.etudiants_id_etudiant_seq TO joachime;
GRANT INSERT ON TABLE projet.etudiants TO joachime;

 */



--grant for joachim(entreprise)
GRANT CONNECT ON DATABASE postgres TO joachim;
GRANT USAGE ON SCHEMA projet TO joachim;
GRANT SELECT ON projet.offres_stage, projet.mots_cles, projet.mots_cles_offre_stage, projet.candidatures, projet.etudiants, projet.entreprises, projet.voirMotsCles, projet.mesOffres TO joachim;
GRANT UPDATE ON projet.offres_stage, projet.candidatures TO joachim;
GRANT INSERT ON projet.offres_stage, projet.mots_cles_offre_stage TO joachim;
GRANT SELECT, UPDATE ON SEQUENCE projet.offres_stage_id_offre_stage_seq TO joachim;
GRANT SELECT, UPDATE ON SEQUENCE projet.etudiants_id_etudiant_seq TO joachim;


--GRANT CONNECT & USAGE ON DATABASE & SCHEMA
GRANT CONNECT ON DATABASE postgres TO mariomargjini, robinsalle;
GRANT USAGE ON SCHEMA projet TO mariomargjini, robinsalle;

--GRANT ETUDIANT (MARIO)
GRANT SELECT ON projet.etudiants, projet.entreprises, projet.offres_stage, projet.mots_cles_offre_stage, projet.mots_cles, projet.candidatures, projet.voirOffresValideesSemestre, projet.voirOffresParMotsCles, projet.mesCandidatures TO mariomargjini;
GRANT UPDATE ON projet.candidatures TO mariomargjini;
GRANT INSERT ON projet.candidatures TO mariomargjini;

--GRANT ENTREPRISE (ROBIN)
GRANT SELECT ON projet.offres_stage, projet.mots_cles, projet.mots_cles_offre_stage, projet.candidatures, projet.etudiants, projet.entreprises, projet.voirMotsCles, projet.mesOffres TO robinsalle;
GRANT UPDATE ON projet.offres_stage, projet.candidatures TO robinsalle;
GRANT INSERT ON projet.offres_stage, projet.mots_cles_offre_stage TO robinsalle;
GRANT SELECT, UPDATE ON SEQUENCE projet.offres_stage_id_offre_stage_seq, projet.etudiants_id_etudiant_seq TO robinsalle;


