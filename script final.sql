DROP SCHEMA IF EXISTS projet CASCADE;

CREATE SCHEMA projet;
CREATE TYPE projet.semestre_de_stage AS ENUM ('Q1', 'Q2');
CREATE TYPE projet.etat_offre AS ENUM ('non-validée', 'validée', 'annulée', 'attribuée');
CREATE TYPE projet.etat_candidature AS ENUM ('en attente', 'acceptée', 'refusée', 'annulée');


CREATE TABLE projet.etudiants
(
    id_etudiant SERIAL PRIMARY KEY NOT NULL,
    nom VARCHAR(40) NOT NULL
        CHECK (nom <> ''),
    prenom VARCHAR(40) NOT NULL
        CHECK (prenom <> ''),
    mail VARCHAR(50) NOT NULL
        CHECK (mail SIMILAR TO '[a-z]+\.[a-z]+@student\.vinci\.be'),
    semestre_stage projet.semestre_de_stage NOT NULL ,
    mdp VARCHAR(20) NOT NULL,
    nbr_candidatures_en_attente INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE projet.mots_cles
(
    id_mot_cle SERIAL PRIMARY KEY NOT NULL,
    intitule VARCHAR(15) NOT NULL CHECK (intitule <> '')
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
    mpd VARCHAR(20) NOT NULL
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
INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES ('De', 'Jean', 'j.d@student.vinci.be', 'Q2', '1234');
INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES ('Du', 'Marc', 'm.d@student.vinci.be', 'Q1', '1234');

--INSERT INTO MOTS-CLES
INSERT INTO projet.mots_cles(intitule) VALUES ('Java');
INSERT INTO projet.mots_cles(intitule) VALUES ('Web');
INSERT INTO projet.mots_cles(intitule) VALUES ('Python');

--INSERT INTO ENTREPRISES
INSERT INTO projet.entreprises VALUES ('VIN','Vinci', 'rue Leonard De Vinci', 'vinci@vinci.be', '1234');
INSERT INTO projet.entreprises VALUES ('ULB', 'ULB', 'rue université libre', 'ulb@ulb.com', '1234');

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
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (1, 4, 'jean adore leonard');
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (1, 3, 'Chinese Gang');


--APP PROFESSEUR 1.

CREATE OR REPLACE FUNCTION projet.triggerAjoutEtudiant() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(SELECT * FROM projet.etudiants e
              WHERE e.nom = NEW.nom AND e.prenom = NEW.prenom )
    THEN RAISE 'Etudiant déjà encodé';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_ajout_etudiant BEFORE INSERT ON projet.etudiants
    FOR EACH ROW EXECUTE PROCEDURE projet.triggerAjoutEtudiant();

CREATE OR REPLACE FUNCTION projet.encoderEtudiant(nom_etudiant VARCHAR(40), prenom_etudiant VARCHAR(40), mail_etudiant VARCHAR(50),
                                                  semestre_stage projet.semestre_de_stage,mdp_etudiant VARCHAR(20)) RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES (nom_etudiant, prenom_etudiant, mail_etudiant, semestre_stage, mdp_etudiant);
END;
$$ LANGUAGE plpgsql;


--APP PROFESSEUR 2.

CREATE OR REPLACE FUNCTION projet.triggerAjoutEntreprise() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(SELECT * FROM projet.entreprises et
              WHERE et.nom = NEW.nom AND et.mail = NEW.mail AND et.adresse = NEW.adresse )
    THEN RAISE 'Entreprise déjà encodée';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_ajout_entreprise BEFORE INSERT ON projet.entreprises
    FOR EACH ROW EXECUTE PROCEDURE projet.triggerAjoutEntreprise();

CREATE OR REPLACE FUNCTION projet.encoderEntreprise(nom_entreprise VARCHAR(40), adresse_entreprise VARCHAR(100), mail_entreprise VARCHAR(60),
                                                    identifiant_entreprise CHAR(3), mdp_entreprise VARCHAR(20)) RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO projet.entreprises(id_entreprise, nom, adresse, mail, mpd)
    VALUES (identifiant_entreprise, nom_entreprise, adresse_entreprise, mail_entreprise, mdp_entreprise);
END;
$$ LANGUAGE plpgsql;

--APP PROFESSEUR 3.
CREATE OR REPLACE FUNCTION projet.triggerAjoiutMotCle() RETURNS TRIGGER AS $$
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
    FOR EACH ROW EXECUTE PROCEDURE projet.triggerAjoutMotCle();


-- APP PROFESSEUR 4.
CREATE VIEW offreNonValidee AS
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
SELECT os.code_offre_stage AS code_offre_de_stage, e.nom AS entreprise, et.nom, et.prenom
FROM projet.offres_stage os, projet.entreprises e, projet.etudiants et, projet.candidatures c
WHERE e.id_entreprise = os.entreprise AND c.offre_stage = os.id_offre_stage AND c.etudiant = et.id_etudiant
  AND os.etat = 'attribuée'
ORDER BY et.id_etudiant;



--APP ÉTUDIANT 1.

CREATE OR REPLACE VIEW projet.voirOffresValideesSemestre AS
SELECT  et.id_etudiant, os.code_offre_stage, os.entreprise,os.semestre, en.nom, en.adresse, os.description,string_agg(mc.intitule,',' )AS mots_cles
FROM projet.offres_stage os,projet.entreprises en,projet.mots_cles mc,projet.mots_cles_offre_stage mcos,projet.etudiants et
WHERE et.semestre_stage = os.semestre_offre
  AND os.etat = 'validée'
  AND os.entreprise=en.id_entreprise
  AND mcos.offre_stage=os.id_offre_stage
  AND mcos.mot_cle=mc.id_mot_cle
group by os.description, en.adresse, en.nom, os.entreprise, os.code_offre_stage, et.id_etudiant;


--APP ÉTUDIANT 2.

CREATE OR REPLACE VIEW projet.voirOffresParMotsCles AS
SELECT  et.id_etudiant, os.code_offre_stage, os.entreprise, en.nom, en.adresse, os.description,string_agg(mc.intitule,',' )AS mots_cles, mc.intitule
FROM projet.offres_stage os,projet.entreprises en,projet.mots_cles mc,projet.mots_cles_offre_stage mcos,projet.etudiants et
WHERE et.semestre_stage = os.semestre_offre
  AND os.etat = 'validée'
  AND os.entreprise=en.id_entreprise
  AND mcos.offre_stage=os.id_offre_stage
  AND mcos.mot_cle=mc.id_mot_cle
GROUP BY os.description, en.adresse, en.nom, os.entreprise, os.code_offre_stage, et.id_etudiant,mc.intitule;




--APP ÉTUDIANT 3.
--Poser sa candidature. Pour cela, il doit donner le code de l’offre de stage et donner ses
--motivations sous format textuel. Il ne peut poser de candidature s’il a déjà une
--candidature acceptée, s’il a déjà posé sa candidature pour cette offre, si l’offre n’est
--pas dans l’état validée ou si l’offre ne correspond pas au bon semestre.


CREATE OR REPLACE FUNCTION projet.triggerPoserCandidature() RETURNS TRIGGER AS $$
DECLARE
    etudiant_semestre semestre_de_stage;
    offre_semestre semestre_de_stage;
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
    FOR EACH ROW EXECUTE PROCEDURE projet.triggerAjouterMotCleOffreDeStage();

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

CREATE TRIGGER trigger_verifier_offre_de_stage BEFORE UPDATE ON projet.offres_stage
    FOR EACH ROW EXECUTE PROCEDURE projet.annulerOffreDeStage();

CREATE OR REPLACE FUNCTION projet.annulerOffreStage(code_offre INTEGER, code VARCHAR(5)) RETURNS VOID AS $$
DECLARE
BEGIN
    UPDATE projet.offres_stage os SET etat='annulée' WHERE os.code_offre_stage = code;
    --UPDATE projet.candidatures SET etat = 'refusée' WHERE offre_stage = code_offre AND etat != 'acceptée';
END;
$$ LANGUAGE plpgsql;

SELECT projet.annulerOffreStage('6', 'SAM2');