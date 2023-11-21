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

CREATE TABLE projet.mots_cles
(
    id_mot_cle SERIAL PRIMARY KEY NOT NULL,
    intitule VARCHAR(15) NOT NULL CHECK (intitule <> '')
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

--INSERT INTO ENTREPRISES
INSERT INTO projet.entreprises VALUES ('APP','Apple', 'Siège Social d''Apple', 'apple@icloud.be', '1234');
INSERT INTO projet.entreprises VALUES ('SAM','Samsung', 'Siège Social de Samsung', 'samsung@outlook.com', '1234');
INSERT INTO projet.entreprises VALUES ('MIC', 'Microsoft', 'Siège Social de Microsoft', 'microsoft@outlook.com', '1234');
INSERT INTO projet.entreprises VALUES ('HUA', 'HUAWEI', 'Siège Social d''Huawei', 'huawei@chinasupremacy.com', '1234');
INSERT INTO projet.entreprises VALUES ('SON', 'SONY', 'Siège Social de Sony', 'sony@gmail.com', '1234');

--INSERT INTO OFFRE_STAGE
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('APP', 'APP1', 'Petit stage sympathique chez Apple', 'Q1');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('APP', 'APP2', 'Petit stage sympathique chez Apple', 'Q2');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('MIC', 'MIC1', 'Petit stage sympathique chez Microsoft','Q1');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('HUA','HUA1','Gros stage de haut niveau chez les chinois','Q1');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre) VALUES ('SAM', 'SAM1', 'Petit stage sympathique chez Samsung', 'Q2');
INSERT INTO projet.offres_stage(entreprise, code_offre_stage, description, semestre_offre, etat) VALUES ('SAM', 'SAM2', 'gros stage pas sympathique chez Samsung', 'Q2','validée');

-- UPDATE OFFRE_STAGE

UPDATE projet.offres_stage SET etat = 'validée' WHERE id_offre_stage = 4;
UPDATE projet.offres_stage SET etat = 'attribuée' WHERE id_offre_stage = 4;


--INSERT INTO ETUDIANTS
INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES ('Qi', 'Joachim', 'joachim.qi@student.vinci.be', 'Q1', '1234');
INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES ('Margjini', 'Mario', 'mario.margjini@student.vinci.be', 'Q1', '1234');
INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES ('Salle', 'Robin', 'robin.salle@student.vinci.be', 'Q2', '1234');

--INSERT INTO CANDIDATURES
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (1, 4, 'Chinese Gang');
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (1, 3, 'Chinese Gang');
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (1, 2, 'Chinese Gang');
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (3, 3, '420Bedave');
INSERT INTO projet.candidatures(etudiant, offre_stage, motivation) VALUES (2, 2, 'Albanian Mafia');

--INSERT INTO MOTS-CLES
INSERT INTO projet.mots_cles(intitule) VALUES ('Web');
INSERT INTO projet.mots_cles(intitule) VALUES ('SQL');
INSERT INTO projet.mots_cles(intitule) VALUES ('JS');
INSERT INTO projet.mots_cles(intitule) VALUES ('BD');
INSERT INTO projet.mots_cles(intitule) VALUES ('CONCEPTION');
--INSTERT INTO MOTS-CLES-OFFRES-STAGES
INSERT INTO projet.mots_cles_offre_stage(offre_stage, mot_cle) VALUES (6,1);
INSERT INTO projet.mots_cles_offre_stage(offre_stage, mot_cle) VALUES (6,2);

--APP PROFESSEUR 1.
--Encoder un étudiant : le professeur devra encoder son nom, son prénom, son adresse
--mail (se terminant par @student.vinci.be) et le semestre pendant lequel il fera son
--stage (Q1 ou Q2). Il choisira également un mot de passe pour l’étudiant. Ce mot de
--passe sera communiqué à l’étudiant par mail.

CREATE OR REPLACE FUNCTION projet.trigger() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(SELECT * FROM projet.etudiants e
              WHERE e.nom = NEW.nom AND e.prenom = NEW.prenom )
    THEN RAISE 'Etudiant déjà encodé';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_ajout_etudiant BEFORE INSERT ON projet.etudiants
    FOR EACH ROW EXECUTE PROCEDURE projet.trigger();

CREATE OR REPLACE FUNCTION projet.encoderEtudiant(nom_etudiant VARCHAR(40), prenom_etudiant VARCHAR(40), mail_etudiant VARCHAR(50),
                                                  semestre_stage projet.semestre_de_stage,mdp_etudiant VARCHAR(20)) RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO projet.etudiants(nom, prenom, mail, semestre_stage, mdp) VALUES (nom_etudiant, prenom_etudiant, mail_etudiant, semestre_stage, mdp_etudiant);
END;
$$ LANGUAGE plpgsql;


--APP PROFESSEUR 2.
--Encoder une entreprise : le professeur devra encoder le nom de l’entreprise, son
--adresse (une seule chaîne de caractère) et son adresse mail. Il choisira pour l’entreprise
--un identifiant composé de 3 lettres majuscules (par exemple « VIN » pour l’entreprise
--Vinci). Il choisira également un mot de passe pour l’entreprise. Ce mot de passe sera
--communiqué à l’entreprise par mail.

CREATE OR REPLACE FUNCTION projet.trigger1() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(SELECT * FROM projet.entreprises et
              WHERE et.nom = NEW.nom AND et.mail = NEW.mail AND et.adresse = NEW.adresse )
    THEN RAISE 'Entreprise déjà encodée';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_ajout_entreprise BEFORE INSERT ON projet.entreprises
    FOR EACH ROW EXECUTE PROCEDURE projet.trigger1();

CREATE OR REPLACE FUNCTION projet.encoderEntreprise(nom_entreprise VARCHAR(40), adresse_entreprise VARCHAR(100), mail_entreprise VARCHAR(60),
                                                    identifiant_entreprise CHAR(3), mdp_entreprise VARCHAR(20)) RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO projet.entreprises(id_entreprise, nom, adresse, mail, mpd)
    VALUES (identifiant_entreprise, nom_entreprise, adresse_entreprise, mail_entreprise, mdp_entreprise);
END;
$$ LANGUAGE plpgsql;

--APP PROFESSEUR 3.
CREATE OR REPLACE FUNCTION projet.trigger2() RETURNS TRIGGER AS $$
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
    FOR EACH ROW EXECUTE PROCEDURE projet.trigger2();


-- APP PROFESSEUR 4.

SELECT os.id_offre_stage, os.code_offre_stage AS code_de_stage, os.semestre_offre AS semestre, e.nom AS entreprise, os.description
FROM projet.offres_stage os, projet.entreprises e
WHERE os.entreprise = e.id_entreprise AND os.etat = 'non-validée'
ORDER BY semestre_offre, e.id_entreprise;

--APP PROFESSEUR 5.

CREATE OR REPLACE FUNCTION projet.trigger3() RETURNS TRIGGER AS $$
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
    FOR EACH ROW EXECUTE PROCEDURE projet.trigger3();

CREATE OR REPLACE FUNCTION projet.validerOffreDeStage(code_offre VARCHAR(5)) RETURNS VOID AS $$
DECLARE
BEGIN

    UPDATE projet.offres_stage  SET etat='validée' WHERE code_offre_stage = code_offre;
END;
$$ LANGUAGE plpgsql;

--UPDATE OFFRE DE STAGE
UPDATE projet.offres_stage SET etat = 'attribuée' WHERE code_offre_stage = 'HUA1';
--UPDATE projet.offres_stage SET etat = 'validée' WHERE code_offre_stage = 'HUA1';


--APP PROFESSEUR 6.

CREATE VIEW projet.offres_validees AS
SELECT os.id_offre_stage, os.code_offre_stage AS code_de_stage, os.semestre_offre AS semestre, e.nom AS entreprise, os.description
FROM projet.offres_stage os, projet.entreprises e
WHERE os.entreprise = e.id_entreprise AND os.etat = 'validée'
ORDER BY semestre_offre, e.id_entreprise;

SELECT projet.offres_validees.* FROM projet.offres_validees;

--APP PROFESSEUR 7.

SELECT et.nom, et.prenom, et.mail, et.semestre_stage, et.nbr_candidatures_en_attente
FROM projet.etudiants et
WHERE et.id_etudiant NOT IN (SELECT c.etudiant
                             FROM projet.candidatures c
                             WHERE et.id_etudiant = c.etudiant AND c.etat = 'acceptée');

--APP PROFESSEUR 8.

CREATE VIEW projet.offres_stages_attribuees AS
SELECT os.code_offre_stage AS code_offre_de_stage, e.nom AS entreprise, et.nom, et.prenom
FROM projet.offres_stage os, projet.entreprises e, projet.etudiants et, projet.candidatures c
WHERE e.id_entreprise = os.entreprise AND c.offre_stage = os.id_offre_stage AND c.etudiant = et.id_etudiant
  AND os.etat = 'attribuée'
ORDER BY et.id_etudiant;



--APP ÉTUDIANT 1.
--Voir toutes les offres de stage dans l’état « validée » correspondant au semestre où
--l’étudiant fera son stage. Pour une offre de stage, on affichera son code, le nom de
--l’entreprise, son adresse, sa description et les mots-clés (séparés par des virgules sur
--une même ligne).
CREATE OR REPLACE VIEW projet.voir_offres_validees_semestre AS
SELECT  et.id_etudiant, os.code_offre_stage, os.entreprise, en.nom, en.adresse, os.description,string_agg(mc.intitule,',' )AS mots_cles
FROM projet.offres_stage os,projet.entreprises en,projet.mots_cles mc,projet.mots_cles_offre_stage mcos,projet.etudiants et
WHERE et.semestre_stage = os.semestre_offre
AND os.etat = 'validée'
AND os.entreprise=en.id_entreprise
AND mcos.offre_stage=os.id_offre_stage
AND mcos.mot_cle=mc.id_mot_cle
group by os.description, en.adresse, en.nom, os.entreprise, os.code_offre_stage, et.id_etudiant;

SELECT * FROM projet.voir_offres_validees_semestre;

--APP ÉTUDIANT 2.
--Recherche d’une offre de stage par mot clé. Cette recherche n’affichera que les offres
--de stages validées et correspondant au semestre où l’étudiant fera son stage. Les
--offres de stage seront affichées comme au point précédent.

CREATE OR REPLACE FUNCTION projet.voir_offres_validees_mot_cle(mot_cle_proced INTEGER) RETURNS SETOF RECORD AS $$

DECLARE
BEGIN
    SELECT  et.id_etudiant, os.code_offre_stage, os.entreprise, en.nom, en.adresse, os.description,string_agg(mc.intitule,',' )AS mots_cles
    FROM projet.offres_stage os,projet.entreprises en,projet.mots_cles mc,projet.mots_cles_offre_stage mcos,projet.etudiants et
    WHERE et.semestre_stage = os.semestre_offre
    AND os.etat = 'validée'
    AND os.entreprise=en.id_entreprise
    AND mcos.offre_stage=os.id_offre_stage
    AND mcos.mot_cle=mc.id_mot_cle
    AND mc.id_mot_cle = mot_cle_proced
    GROUP BY os.description, en.adresse, en.nom, os.entreprise, os.code_offre_stage, et.id_etudiant;
END ;
$$ language plpgsql;

SELECT 
/*
ORDER BY et.matricule_etudiant;
>>>>>>> 3743c337ec94887072c15f084df3c80cd92fea6e

 */


--APP ENTREPRISE 1.
/*Encoder une offre de stage. Pour cela, l’entreprise devra encoder une description et le
semestre. Chaque offre de stage recevra automatiquement un code qui sera la
concaténation de l’identifiant de l’entreprise et d’un numéro. Par exemple, le premier
stage de l’entreprise Vinci aura le code « VIN1 », le deuxième « VIN2 », le dixième «
VIN10 », … Cette fonctionnalité échouera si l’entreprise a déjà une offre de stage
attribuée durant ce semestre.*/

CREATE OR REPLACE FUNCTION projet.trigger_insert_offre_de_stage() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(SELECT * FROM projet.offres_stage o
              WHERE o.semestre_offre = NEW.semestre_offre AND o.entreprise = NEW.entreprise and o.etat = 'attribuée')
    THEN RAISE 'L’entreprise a déjà une offre de stage attribuée durant ce semestre';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_insert_offre_de_stage BEFORE INSERT ON projet.offres_stage
    FOR EACH ROW EXECUTE PROCEDURE projet.trigger_insert_offre_de_stage();

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

SELECT projet.offres_stages_attribuees.* FROM projet.offres_stages_attribuees;

