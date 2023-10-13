/*********************************************************************************************************/
/*                                         Passage de SAS vers R                                         */
/*********************************************************************************************************/

/* A FAIRE :
- Transformer la durée en mois et en année
- merge, append base, set
- expand.grid et cross join
- macro pour stock à la fin de l'année
- substr à manipuler !!! */

/* Proc print
   Test ligne par ligne
   Autres fonctions de manipulation de chaînes de caractères
*/


/* Création d'une base de données SAS d'exemple */
/* Données fictives sur des formations */

data Donnees;
  infile cards dsd dlm='|';
  format Identifiant $3. Sexe_red 1. CSP $1. Niveau $30. Date_naissance ddmmyy10. Date_entree ddmmyy10. Duree Note_Contenu Note_Formateur Note_Moyens
         Note_Accompagnement Note_Materiel poids_sondage;
  input Identifiant $ Sexe_red CSP $ Niveau $ Date_naissance :ddmmyy10. Date_entree :ddmmyy10. Duree Note_Contenu Note_Formateur Note_Moyens
        Note_Accompagnement Note_Materiel poids_sondage;
  cards;
  173|2|1|Qualifie|17/06/1998|01/01/2021|308|12|6|17|4|19|117.1
  173|2|1|qualifie|17/06/1998|01/01/2022|365|6||12|7|14|98.3
  173|2|1|qualifie|17/06/1998|06/01/2022|185|8|10|11|1|9|214.6
  173|2|1|Qualifie|17/06/1998|02/01/2023|365|14|15|15|10|8|84.7
  174|1|1|qualifie|08/12/1984|17/08/2021|183|17|18|20|15|12|65.9
  175|1|1|qualifie|16/09/1989|21/12/2022|730|5|5|8|4|9|148.2
  198|2|4|Non qualifie|17/03/1987|28/07/2022|30|10|10|10|16|8|89.6
  198|2|4|Qualifie|17/03/1987|17/11/2022|164|11|7|6|14|13|100.3
  198|2|4|Qualifie|17/03/1987|21/02/2023|365|9|20|3|4|17|49.3
  168|1|2|Qualifie|30/07/2002|04/09/2019|365|18|11|20|13|15|148.2
  211|2|3|Non qualifie||17/12/2021|135|16|16|15|12|9|86.4
  278|1|5|Qualifie|10/08/1948|07/06/2018|365|14|10|6|8|12|99.2
  347|2|5|Qualifie|13/09/1955||180|12|5|7|11|12|105.6
  112|1|3|Non qualifie|13/09/2001|02/03/2022|212|3|10|11|9|8|123.1
  112|1|3|Non qualifie|13/09/2001|01/03/2021|365|7|13|8|19|2|137.4
  112|1|3|Non qualifie|13/09/2001|01/12/2023|365||||||187.6
  087|1|3|Non qualifie|||365||||||87.3
  087|1|3|Non qualifie||31/10/2020|365||||||87.3
  099|1|3|qualifie|06/06/1998|01/03/2021|364|12|11|10|12|13|169.3
  099|1|3|qualifie|06/06/1998|01/03/2022|364|12|11|10|12|13|169.3
  099|1|3|qualifie|06/06/1998|01/03/2023|364|12|11|10|12|13|169.3
  187|2|2|qualifie|05/12/1986|01/01/2022|364|10|10|10|10|10|169.3
  187|2|2|qualifie|05/12/1986|01/01/2023|364|10|10|10|10|10|234.1
  689|1|1||01/12/2000|06/11/2017|123|9|7|8|13|16|189.3
  765|1|4|Non qualifie|26/12/1995|17/04/2020|160|13|10|12|18|10|45.9
  765|1|4|Non qualifie|26/12/1995|17/04/2020|160|13|10|12|18|10|45.9
  765|1|4|Non qualifie|26/12/1995|17/04/2020|160|13|10|12|18|10|45.9
  ;
run;


/* Chemin du bureau de l'utilisateur */
/* On vide la log */
dm "log; clear; ";
/* On récupère déjà l'identifiant de l'utilisateur */
%let user = &sysuserid;
/* Chemin proprement dit */
%let bureau = C:\Users\&user.\Desktop;
libname bur "&bureau.";


/* Affichage de l'année */
%let an = %sysfunc(year(%sysfunc(today())));
/* & (esperluette) indique à SAS qu'il doit remplacer an par sa valeur définie par le %let */
%put Année : &an.;
/* Autre possibilité */
data _null_;call symput('annee', strip(year(today())));run;
%put Année (autre méthode) : &annee.;
/* Année passée */
%put Année passée : %eval(&an. - 1);


/***************************************************** Informations sur la base de données *****************************************************/

/* Extraire les x premières lignes de la base (10 par défaut) */
%let x = 10;
proc print data = Donnees (firstobs = 1 obs = &x.);run;
/* Ou alors */
data Lignes&x.;set Donnees (firstobs = 1 obs = &x.);proc print;run;

/* On renomme la variable sexe_red en sexe */
data Donnees;
  set Donnees (rename = (sexe_red = sexe));
run;

/* Nombre de lignes et de colonnes dans la base */
/* Nombre de lignes */
proc sql;select count(*) as Nb_Lignes from Donnees;quit;
/* Liste des variables de la base dans la base Var */
proc contents data = Donnees out = Var noprint;run;
/* Nombre de colonnes */
proc sql;select count(*) as Nb_Colonnes from Var;run;
/* Liste des variables par ordre d'apparition dans la base */
proc sql;select name into :nom_col separated by " " from Var order by varnum;run;
/* On affiche les noms des variables */
%put Liste des variables : &nom_col.;
/* On supprime la base Var temporaire */
proc datasets lib = Work nolist;delete Var;run;


/* Manipuler des lignes et des colonnes */
/* Formater les modalités des valeurs */
proc format;
  value sexef
  1 = "Homme"
  2 = "Femme";

  value agef
  low-<26 = "1. De 15 à 25 ans"
  26<-<50 = "2. De 26 à 49 ans"
  50-high = "3. 50 ans ou plus";

  value $ cspf
  '1' = "Cadre"
  '2' = "Profession intermédiaire"
  '3' = "Employé"
  '4' = "Ouvrier"
  '5' = "Retraité";
run;

/* Utiliser les formats */
data Donnees;
  set Donnees;
  /* Exprimer dans le format sexef (Hommes / Femmes) */
  Sexef = put(Sexe, sexef.);
run;

/* Ajouter, transformer, supprimer, sélectionner, conserver des colonnes */
data Femmes;
  /* Sélection de colonnes */
  set Donnees (keep = identifiant Sexe note_contenu Sexef);
  /* Sélection de lignes respectant une certaine condition */
  if Sexef = "Femme";
  /* Création de colonne */
  note2 = note_contenu / 20 * 5;
  /* Suppression de colonnes */
  drop Sexe;
  /* Selection de colonnes */
  keep identifiant note_contenu note2 Sexef;
run;

/* Variables commençant par le mot note */
proc contents data = Donnees out = Var noprint;run;
proc sql;select name into :var_notes separated by " " from Var where substr(upcase(name), 1, 4) = "NOTE" order by varnum;run;
proc datasets lib = Work nolist;delete Var;run;
data Donnees_Notes;set Donnees (keep = &var_notes.);run;

/* Création de variables conditions : if else if => ifelse ou case_when en R */
data Donnees;set Donnees;
  /* 1ère solution */
  format Civilite $20.;
  if      Sexe = 2 then Civilite = "Mme";
  else if Sexe = 1 then Civilite = "Mr";
  else                  Civilite = "Inconnu";
  /* 2e solution */
  format Civilite2 $20.;
  select;
    when      (Sexe = 2) Civilite2 = "Femme";
    when      (Sexe = 1) Civilite2 = "Homme";
    otherwise            Civilite2 = "Inconnu";
  end;
  /* 3e solution (do - end) */
  if      Sexe = 2 then do;
    Civilite = "Mme";Civilite2 = "Femme";
  end;
  else if Sexe = 1 then do;
    Civilite = "Mr";Civilite2 = "Homme";
  end;
  else do;
    Civilite = "Inconnu";Civilite2 = "Inconnu";
  end;
run;

/* Manipuler les dates */
%let sixmois = %sysevalf(365.25/2); /* On utilise %sysevalf et non %eval pour des calculs avec des macro-variables non entières */
%put sixmois : &sixmois.;
data Donnees;
  set Donnees;
  /* Âge à l'entrée dans le dispositif */
  Age = intck('year', date_naissance, date_entree);
  /* Âge formaté */
  Agef = put(Age, agef.);
  /* Date de sortie du dispositif : ajout de la durée à la date d'entrée */
  format date_sortie ddmmyy10.;
  date_sortie = intnx('day', date_entree, duree);  
  /* Deux manières de créer une indicatrice 0/1 */
  /* La date de sortie est après le 31 décembre de l'année */
  if date_sortie > "31dec&an."d then apres_31_decembre = 1;else apres_31_decembre = 0;
  /* Ou alors */
  apres_31_decembre = (date_sortie > "31dec&an."d);
  /* La durée du contrat est-elle supérieure à 6 mois ? */
  Duree_Sup_6_mois = (Duree >= &sixmois.);
  /* Deux manières de créer une date */
  format Decembre_31_&an._a Decembre_31_&an._b ddmmyy10.;
  Decembre_31_&an._a = "31dec&an."d;
  Decembre_31_&an._b = mdy(12, 31, &an.); /* mdy pour month, day, year (pas d'autre alternative, ymd par exemple n'existe pas) */
  /* Date 6 mois après la sortie */
  format Date_6mois ddmmyy10.;
  Date_6mois = intnx('month', date_sortie, 6);
run;
/* Ventilation pondérée (cf. infra) */
proc freq data = Donnees;tables apres_31_decembre;weight poids_sondage;run;

/* Mettre un 0 devant un nombre */
data Zero_devant;set Donnees (keep = date_entree);
  /* Obtenir le mois et la date */
  Mois = month(date_entree);
  Annee = year(date_entree);
  /* Mettre le mois sur 2 positions (avec un 0 devant si le mois <= 9) : format prédéfini z2. */
  Mois_a = put(Mois, z2.);
  drop Mois;
  rename Mois_a = Mois;
run;

/* On souhaite rééxprimer toutes les notes sur 100 et non sur 20 */
%let notes = Note_Contenu   Note_Formateur Note_Moyens     Note_Accompagnement     Note_Materiel;
/* On supprime les doubles blancs entre les variables */
%let notes = %sysfunc(compbl(&notes.));
%put &notes;
/* 1ère solution : avec les array */
data Sur100_1;
  set Donnees;
  array variables (*) &notes.;
  do increment = 1 to dim(variables);
    variables[increment] = variables[increment] / 20 * 100;
  end; 
  drop increment;
run;
/* 2e solution : avec une macro */
data Sur100_2;
  set Donnees;
  %macro Sur100;
    %do i = 1 %to %sysfunc(countw(&notes.));
	  %let note = %scan(&notes., &i.);
	  &note. = &note. / 20 * 100;
	%end;
  %mend Sur100;
  %Sur5;
run;
/* 3e solution : l'équivalent des list-comprehension de Python en SAS */
data Sur100_3;
  set Donnees;
  %macro List_comprehension;
    %do i = 1 %to %sysfunc(countw(&notes.));
      %let j = %scan(&notes., &i.);
	    &j. = &j. / 20 * 100
	%end;);;
  %mend List_comprehension;
  %List_comprehension;
run;



/********************************************************** Manipuler des chaînes de caractères ***************************************************/

/* Fonction tranwrd (translate word) => R = grepl, upcase, lowcase, length */
data Donnees;
  set Donnees;
  /* Première lettre en majuscule */
  Niveau = propcase(Niveau);
  /* On transforme une chaîne de caractères en une autre (Qualifie en Qualifié) */
  Niveau = tranwrd(Niveau, "Qualifie", "Qualifié");
  /* On exprime la CSP en texte dans une variable CSPF avec le format */
  format CSPF $100.;
  CSPF = put(CSP, $cspf.);
  /* En majuscule */
  CSP_majuscule = upcase(CSPF);
  /* En minuscule */
  CSP_minuscule = lowcase(CSPF);
  /* Nombre de caractères dans une chaîne de caractères => nchar en R */
  taille_id = length(identifiant);
run;

/* Manipuler des chaînes de caractères => R = gsub, grepl etc. */
data Exemple_chaines;
  Texte = "              Ce   Texte   mériterait   d être   corrigé                  ";
  Texte1 = "Je m'appelle";
  Texte2 = "SAS";
run;
data Exemple_chaines;set Exemple_chaines;
  /* Enlever les blancs au début et à la fin de la chaîne de caractère */
  Enlever_Blancs_Initiaux = strip(Texte);
  /* Enlever les doubles blancs dans la chaîne de caractères */
  Enlever_Blancs_Entre = compbl(Enlever_Blancs_Initiaux);
  /* Enlever doubles blancs */
  /* REVOIR !!!!! */
  Enlever_Doubles_Blancs = compress(Texte, "  ", "t");
  /* Trois méthodes pour concaténer des chaînes de caractères */
  Concatener  = Texte1||" "||Texte2;
  Concatener2 = Texte1!!" "!!Texte2;
  Concatener3 = catx(" ", Texte1, Texte2);
  /* Extraire les 2e, 3e et 4e caractères de Concatener */
  /* 2 correspond à la position du 1er caractère à récupérer, 3 le nombre total de caractères à partir du point de départ */
  extrait = substr(Concatener, 2, 3);
  /* Transformer plusieurs caractères différents */
  chaine = "éèêëàâçîô";
  /* On transforme le é en e, le â en a, le î en i, ... */
  chaine_sans_accent = translate(chaine, "eeeeaacio", "éèêëàâçîô");
run;
proc print data = Exemple_chaines;run;

/* Transformer le format d'une variable */
/* put et input */
data Donnees;
  set Donnees;
  /* Transformer la variable Sexe en caractère => R = as.character() */
  Sexe_car = put(Sexe, $1.);
  /* Transformer la variable Sexe_car en numérique => R = as.numeric() */
  Sexe_num = input(Sexe_car, 1.);
run;

/* Arrondir une valeur numérique */
data Arrondis;set Donnees (keep = Poids);
  /* Arrondi à l'entier le plus proche */
  poids_arrondi_0 = round(poids, 0.0);
  /* Arrondi à 1 chiffre après la virgule */
  poids_arrondi_1 = round(poids, 0.1);
  /* Arrondi à 2 chiffre après la virgule */
  poids_arrondi_2 = round(poids, 0.2);
  /* Arrondi à l'entier inférieur */
  poids_inf = floor(poids);
  /* Arrondi à l'entier inférieur */
  poids_inf = ceil(poids);  
run;



/**************************************************************** Gestion ligne par ligne ****************************************************************/

/* Numéro de l'observation */
data Donnees;set Donnees;
  Num_observation = _n_;
run;
/* Autre solution */
proc sql noprint;select count(*) into :nbLignes from Donnees;quit;
data numLigne;do Num_observation = 1 to &nbLignes.;output;end;run;
/* Le merge "simple" (sans by) va seulement concaténer les deux bases l'une à côté de l'autre */
data Donnees;
  merge Donnees numLigne;
run;


/* Numéro du contrat de chaque individu, contrat trié par date de survenue */
proc sort data = Donnees;by identifiant date_entree;run;
data Donnees;set Donnees;
  by identifiant date_entree;
  retain numero_contrat 0;
  if first.identifiant then numero_contrat = 1;
  else numero_contrat = numero_contrat + 1;
run;
/* Pour trier les colonnes */
data Donnees;retain identifiant date_entree numero_contrat Num_observation;set Donnees;run;

/* 2e contrat de l'individu (et rien si l'individu a fait 1 seul contrat */
data Deuxieme_Contrat;set Donnees;if numero_contrat = 2;run;
data Deuxieme_Contrat;set Donnees (where = (numero_contrat = 2));run;

/* Le premier contrat, le dernier contrat, ni le premier ni le dernier contrat de chaque individu ... */
proc sort data = Donnees;by identifiant date_entree;run;
data Donnees;set Donnees;
  by identifiant date_entree;
  Premier_Contrat = (first.identifiant = 1);
  Dernier_Contrat = (last.identifiant = 1);
  Ni_Prem_Ni_Der  = (first.identifiant = 0 and last.identifiant = 0);
  Doublon         = (first.identifiant = 0 or first.identifiant = 0)
run;

/* Créer une base avec les seuls premiers contrats, et une base avec les seuls derniers contrats */
proc sort data = Donnees;by identifiant date_entree;run;
data Premier_Contrat Dernier_Contrat;
  set Donnees;
  by identifiant date_entree;
  if first.identifiant then output Premier_Contrat;
  if last.identifiant then output Dernier_Contrat;
run;


/* La date de fin du contrat précédent */
proc sort data = Donnees;by identifiant date_entree;run;
data DonneesBon;set Donnees;
  by identifiant date_entree;  
  format Date_fin_1 ddmmyy10.;
  Date_fin_1 = lag(Date_sortie);
  if first.identifiant then Date_fin_1 = .;
run;


/* ATTENTION au lag DANS UNE CONDITION IF (cf. document) */
proc sort data = Donnees;by identifiant date_entree;run;
data Lag_Bon;set Donnees (keep = identifiant date_entree date_sortie);
  format date_sortie_1 lag_faux lag_bon ddmmyy10.;
  /* Erreur */
  if date_entree = lag(date_sortie) + 1 then lag_faux = lag(date_sortie) + 1;
  /* Bonne écriture */
  date_sortie_1 = lag(date_sortie);
  if date_entree = date_sortie_1 + 1 then lag_bon = date_sortie_1 + 1;
run;

/* Personnes qui ont suivi à la fois une formation qualifiée et une formation non qualifiée */
proc sql;
  create table Qualif_Non_Qualif as
  select *
  from Donnees
  group by identifiant
  having sum((Niveau = "Non qualifie")) >= 1 and sum((Niveau = "Non qualifie")) >= 1;
quit;


/* Transposer une base */
proc freq data = Donnees;table Sexef * cspf / out = Nb;run;
proc sort data = Nb;by cspf Sexef;run;
proc print data = Nb;run;
proc transpose data = Nb out = transpose;by cspf;var count;id Sexef;run;
data transpose;set transpose (drop = _name_ _label_);run;
proc print data = transpose;run;



/******************************************************************* Les valeurs manquantes ************************************************************/

/* Repérer les valeurs manquantes */
data Missing;set Donnees;
  /* 1ère solution */
  if missing(age) or missing(Niveau) then missing1 = 1;else missing1 = 0;
  if age = . or Niveau = '' then missing2 = 1;else missing2 = 0;
  keep Age Niveau Missing1 Missing2;
run;

/* Incidence des valeurs manquantes : 1er cas */
/* En SAS, les valeurs manquantes sont des nombres négatifs faibles */
data Valeur_Manquante;set Donnees;
  Jeune_Correct   = (15 <= Age <= 25);
  Jeune_Incorrect = (Age <= 25);
run;
/* Lorsque Age est manquant (missing), Jeune_Correct vaut 0 mais Jeune_Incorrect vaut 1 */
/* En effet, pour SAS, un Age manquant est une valeur inférieure à 0, donc bien inférieure à 25.
   Donc la variable Jeune_Incorrect vaut bien 1 pour les âges inconnus */
proc print data = Valeur_Manquante (keep = Age Jeune_Correct Jeune_Incorrect where = (missing(Age)));run;




/******************************************************************* Les tris ************************************************************************/

/* Trier la base par ligne (individu et date de début de la formation) par ordre décroissant : 2 possibilités */
proc sort data = Donnees;by Identifiant Date_entree;run;
proc sql;create table Donnes as select * from Donnees order by Identifiant, Date_entree;quit;
/* Idem par ordre croissant d'identifiant et ordre décroissant de date d'entrée */
proc sort data = Donnees;by Identifiant Date_entree descending;run;
proc sql;create table Donnes as select * from Donnees order by Identifiant, desc Date_entree;quit;



/* Trier la base par colonne (noms de variables) */
/* On met identifiant date_entree et date_sortie au début de la base */
%let colTri = identifiant date_entree date_sortie;
data Donnees;
  retain &colTri.;
  set Donnees;
run;
/* Autre solution */
proc sql;
  create table Donnees as
  /* On remplace les blancs entre les mots par des virgules pour la proc SQL */
  /* Dans la proc SQL, les variables doivent être séparées par des virgules */
  select %sysfunc(tranwrd(&colTri., %str( ), %str(, ))), * from Donnees;
quit;


/* Incidence des valeurs manquantes dans les tris : 2e cas */
/* Les valeurs manquantes sont situées en premier dans un tri par ordre croissant ... */
proc sort data = Donnees;by identifiant date_entree;run;proc print;run;
/* ... et en dernier selon un tri par ordre décroissant */
proc sort data = Donnees;by identifiant descending date_entree;run;proc print;run;
/* En effet, les valeurs manquantes sont considérées comme des valeurs négatives */



/******************************************************************* Les doublons ********************************************************************/

/* Repérage et éliminiation des doublons */

/* Repérage des doublons */

/* On récupère déjà la dernière variable de la base (on en aura besoin plus loin) */
proc contents data = Donnees out = Var noprint;run;
proc sql noprint;select name into :derniere_var from Var where varnum = (select max(varnum) from Var);quit;
/* 1ère méthode */
proc sort data = Donnees;by &nom_col.;run;
data Doublons;set Donnees;by &nom_col.;
  if first.&derniere_var. = 0 or last.&derniere_var. = 0;
run;

/* 2e méthode */
/* On remplace les blancs entre les mots par des virgules pour la proc sql */
/* Dans la proc SQL, les variables doivent être séparées par des virgules */
%let nom_col_sql = %sysfunc(tranwrd(&nom_col., %str( ), %str(, )));
/* On groupe par toutes les colonnes, et si on aboutit à strictement plus qu'une ligne, c'est un doublon */
proc sql;create table Doublons as select * from Donnees group by &nom_col_sql. having count(*) > 1;quit;


/* Suppression des doublons */
/* 1ère méthode */
proc sort data = Donnees nodupkey;by &nom_col.;run;

/* 2e méthode, avec first. et last. (cf. infra) */
/* On récupère déjà la dernière variable de la base (on en aura besoin plus loin) */
proc contents data = Donnees out = Var noprint;run;
proc sql noprint;select name into :derniere_var from Var where varnum = (select max(varnum) from Var);quit;
proc sql noprint;select name into :nom_col separated by " " from Var order by varnum;quit;
%put Dernière variable de la base : &derniere_var.;
%put &nom_col.;
proc sort data = Donnees;by &nom_col.;run;
data Donnees;set Donnees;by &nom_col.;if first.&derniere_var.;run;



/**************************************************************** Les jointures de bases ****************************************************************/

/* Les jointures */
/* On suppose que l'on dispose d'une base supplémentaire avec les diplômes des personnes */
data Diplome;
  infile cards dsd dlm='|';
  format Identifiant $3. Diplome $50.;
  input Identifiant $ Diplome $;
  cards;
  173|Bac
  168|Bep-Cap
  112|Bep-Cap
  087|Bac+2
  689|Bac+2
  765|Pas de diplôme
  112|Bac
  999|Bac
  554|Bep-Cap
  ;
run;
data Jointure;set Donnees (keep = Identifiant Sexe Age);run;

/* 1. Inner join : les seuls identifiants communs aux deux bases */
/* Le tri préalable des bases de données à joindre par la variable de jointure est nécessaire avec la stratégie merge */
proc sort data = Diplome;by identifiant;run;
proc sort data = Jointure;by identifiant;run;
data Inner_Join1;
  merge Jointure (in = a) Diplome (in = b);
  by identifiant;
  if a and b;
run;
/* Le tri préalable des bases de données à joindre n'est pas nécessaire avec la jointure SQL */
proc sql;
  create table Inner_Join2 as
  select * from Jointure a inner join Diplome b on a.identifiant = b.identifiant
  order by a.identifiant;
quit;
proc print data = Inner_Join1;run;
proc sql;select count(*) from Inner_Join1;quit;

/* 2. Left join : les identifiants de la base de gauche */
/* Le tri préalable des bases de données à joindre par la variable de jointure est nécessaire avec la stratégie merge */
proc sort data = Diplome;by identifiant;run;
proc sort data = Jointure;by identifiant;run;
data Left_Join1;
  merge Jointure (in = a) Diplome (in = b);
  by identifiant;
  if a;
run;
/* Le tri préalable des bases de données à joindre n'est pas nécessaire avec la jointure SQL */
proc sql;
  create table Left_Join2 as
  select * from Jointure a left join Diplome b on a.identifiant = b.identifiant
  order by a.identifiant;
quit;
proc print data = Left_Join1;run;
proc sql;select count(*) from Left_Join1;quit;

/* 3. Full join : les identifiants des deux bases */
/* Le tri préalable des bases de données à joindre par la variable de jointure est nécessaire avec la stratégie merge */
proc sort data = Diplome;by identifiant;run;
proc sort data = Jointure;by identifiant;run;
data Full_Join1;
  merge Jointure (in = a) Diplome (in = b);
  by identifiant;
  if a or b;
run;
/* Le tri préalable des bases de données à joindre n'est pas nécessaire avec la jointure SQL */
proc sql;
  create table Full_Join2 as
  select coalesce(a.identifiant, b.identifiant) as Identifiant, * from Jointure a full outer join Diplome b on a.identifiant = b.identifiant
  order by calculated identifiant;
quit;
proc print data = Full_Join1;run;
proc sql;select count(*) from Full_Join1;quit;

/* 4. Cross join : toutes les combinaisons possibles de CSP, sexe et Diplome */
proc sql;
  select *
  from (select distinct CSPF from Donnees) cross join (select distinct Sexef from Donnees) cross join (select distinct Diplome from Diplome)
  order by CSPF, Sexef, Diplome;
quit;




/**************************************************************** Statistiques descriptives ****************************************************************/

/* Moyenne de chaque note */
%let notes = Note_Contenu Note_Formateur Note_Moyens Note_Accompagnement Note_Materiel;
proc means data = Donnees mean;var &notes.;run;
/* Somme, moyenne, médiane, minimum, maximum, nombre de données */ 
proc means data = Donnees sum mean median min max n;var &notes.;run;
/* Notes pondérées (poids de sondage) */
proc means data = Donnees sum mean median min max n;var &notes.;weight poids_sondage;run;

/* Tableaux de fréquence : proc freq */
proc freq data = Donnees;
  tables Sexe CSP / missing;
  format Sexe sexef. CSP $cspf.;
  /*weight poids_sondage;*/
run;
/* Tableau de contingence : proc freq */
proc freq data = Donnees;
  tables Sexe * CSP / missing;
  format Sexe sexef. CSP $cspf.;
  *weight poids_sondage;
run;
/* Tableau de contingence (tableau croisé) avec sans les proportions lignes, colonnes et totales */
proc freq data = Donnees;
  tables CSP * Sexe  / missing nofreq norow nocol;
  format Sexe sexef. CSP $cspf.;
  *weight poids_sondage;
run;

/* Moyenne des notes par individu */
%let notes = Note_Contenu Note_Formateur Note_Moyens Note_Accompagnement Note_Materiel;
data Donnees;
  set Donnees;
  /* 1ère solution */
  Note_moyenne    = mean(of &notes.);
  /* 2e solution */
  Note_moyenne2   = sum(of &notes.) / %sysfunc(countw(&notes.));
  /* 3e solution : l'équivalent des list-comprehension de Python en SAS */
  %macro List_comprehension;
    Note_moyenne3 = mean(of %do i = 1 %to %sysfunc(countw(&notes.));
	                      %let j = %scan(&notes., &i.);
						  &j.
						 %end;);;
  %mend List_comprehension;
  %List_comprehension;
run;
/* Note moyenne (moyenne des moyennes), non pondérée et pondérée */
proc means data = Donnees mean;var Note_moyenne;run;
proc means data = Donnees mean;var Note_moyenne;weight poids_sondage;run;

/* La note donnée est-elle supérieure à la moyenne ? */
/* On crée une macro-variable SAS à partir de la valeur de la moyenne */
proc sql noprint;select mean(Note_moyenne) into :moyenne from Donnees;quit;
data Donnees;set Donnees;
  Note_Superieure_Moyenne = (Note_moyenne > &moyenne.);
run;
proc freq data = Donnees;tables Note_Superieure_Moyenne;weight poids_sondage;run;

/* Déciles et quartiles de la note moyenne */
/* Par la proc means */
proc means data = Donnees StackODSOutput Min P10 P20 P30 P40 Median P60 P70 Q3 P80 P90 Max Q1 Median Q3;
  var Note_moyenne;
  ods output summary = Deciles_proc_means;
run;
/* Par la proc univariate */
proc univariate data = Donnees;
  var Note_moyenne;
  output out = Deciles_proc_univariate pctlpts=00 to 100 by 10 25 50 75 PCTLPRE=_; 
run;

/* Tableaux de résultats */
/* Note moyenne par croisement de CSP (en ligne) et de Sexe x Niveau (en colonne) */
proc tabulate data = Donnees;
  class cspf sexef Niveau;
  var note_moyenne;
  table (cspf all = "Ensemble"), (sexef * Niveau) * (note_moyenne) * mean;
run;
/* CSP et sexe en ligne */
proc tabulate data = Donnees;
  class cspf sexef Niveau;
  var note_moyenne;
  table (cspf * sexef all = "Ensemble"), (Niveau) * (note_moyenne) * mean;
run;




/**************************************************************** Macros SAS ****************************************************************/

/* On recherche toutes les valeurs de CSP différentes et on les met dans une variable.
   On appelle la proc SQL :
   - utilisation du quit et non run à la fin
   - on récupère toutes les valeurs différentes de CSP, séparés par un espace (separated by)
   - s'il y a un espace dans les noms, on le remplace par _ 
   - on les met dans la macro-variable liste_csp
   - on trier la liste par valeur de CSP */
/* On crée une variable de CSP formaté sans les accents et les espaces */
data Donnees;set Donnees;
  /* SAS ne pourra pas créer des bases de données avec des noms accentués */
  /* On supprime dans le nom les lettres accentués. On le fait avec la fonction Translate */
  CSPF2 = tranwrd(strip(CSPF), " ", "_");
  CSPF2 = translate(CSPF2, "eeeeaacio", "éèêëàâçîô");
run;

/* Boucles et macros en SAS */
/* Les boucles ne peuvent être utilisées que dans le cadre de macros */
/* Ouverture de la macro */
%macro Boucles(base = Donnees, var = CSPF2);
  /* Les modalités de la variable */
  proc sql noprint;select distinct &var. into :liste separated by " " from &base. order by &var.;quit;
  /* On affiche la liste de ces modalités */
  %put &liste.;
  /* %let permet à SAS d'affecter une valeur à une variable en dehors d'une manipulation de base de données */
  /* %sysfunc indique à SAS qu'il doit utiliser la fonction countw dans le cadre d'une macro (pas important) */
  /* countw est une fonction qui compte le nombre de mots (séparés par un espace) d'une chaîne de caractères => on compte le nombre de CSP différentes */
  %let nb = %sysfunc(countw(&liste.));
  %put Nombre de modalités différentes : &nb.;
  /* On itère pour chaque CSP différente ... */
  %do i = 1 %to &nb.;
    /* %scan : donne le i-ème mot de &liste. (les mots sont séparés par un espace) : on récupère donc la CSP numéro i */
    %let j = %scan(&liste., &i.);
	%put Variable : &j.;
	/* On crée une base avec seulement les individus de la CSP correspondante */
	data &var.;set Donnees;if &var. = "&j.";run;
  %end;
/* Fermeture de la macro */
%mend Boucles;
/* Lancement de la macro */
%Boucles(base = Donnees, var = CSPF2);


/* Itérer sur toutes les années et les trimestres d'une certaine plage */
%macro iteration(debut, fin);
  %global liste_an;
  %let liste_an = ;
  %do i = &debut. %to &fin.;
    %let liste_an = &liste_an.&i.-;
  %end;
  *%let liste_an = %substr(&liste_an., 1, %eval(%length(&liste_an.) - 1));
%mend iteration;
%iteration(debut = 2000, fin = %sysfunc(year(%sysfunc(today()))));
%put &liste_an.;
%let liste_trim = 1 2 3 4;
%let liste_niv = max min;
/* Supposons que nous ayons des noms de fichier suffixés par AXXXX_TY_NZ, avec X l'année, Y le trimestre et
   Z max ou min. Par exemple, A2010_T2_NMax */
/* Pour obtenir l'ensemble de ces noms de 2010 à cette année */
%macro noms_fichiers(base = temp);
  %global res;
  %let res = ;
  %do j = 1 %to %sysfunc(countw(&liste_an., "-"));
    %let y = %scan(&liste_an., &j., "-"); /* année */
    %do i = 1 %to 4;
      %let t = %scan(&liste_trim, &i.); /* trimestre */
      %do g = 1 %to 2;
        %let n = %scan(&liste_niv., &g.); /* niveau */
		%let res = &res. &base._&y._t&t._n&n.;
	  %end;
	%end;
  %end;
%mend noms_fichiers;
%noms_fichiers(base = base);
%put &res.;


/* On va créer une base par année d'entrée */
proc sql noprint;select year(min(date_entree)), year(max(date_entree)) into :an_min, :an_max from Donnees;quit;
%macro Base_par_mois(debut, fin);
  /* %local impose que an n'est pas de signification hors de la macro */
  %local an;
  /* %global impose que nom_bases peut être utilisé en dehors de la macro */
  %global nom_bases;
  /* On initalise la création de la macri-variable nom_bases */
  %let nom_bases = ;
  /* On itère entre &debut. et &fin. */
  %do an = &debut. %to &fin.;
    data Entree_&an.;
	  set Donnees;
	  if year(date_entree) = &an.;
	run;
	/* On ajoute à la macro-variable le nom de la base */
	%let nom_bases = &nom_bases. Entree_&an.;
  %end;
%mend Base_par_mois;
%Base_par_mois(debut = &an_min., fin = &an_max.);
%put &nom_bases.;

/* On va désormais empiler toutes les bases (concaténation par colonne) */
/* L'instruction set utilisée de cette façon permet cet empilement */
data Donnees_concatene;
  set &nom_bases.;
run;





/**************************************************************** Fin du programme SAS ****************************************************************/

/* Supprimer toutes les bases de la mémoire vive (la work) => rm(list = ls()) */
proc datasets lib = work nolist kill;run;



/* Quelques points de vigilance en SAS (à ne connaître que si on est amené à modifier le programme SAS, pas utiles sinon) */
/* Double guillemets pour les macro-variables */
%let a = Bonjour;
%put '&a.'; /* Incorrect */
%put "&a."; /* Correct */

/* Macro-variable définie avec un statut global avant son appel dans le cadre d'un statut local */
%macro test;%let an = 2022;%mend test;
%test;
/* 1. Erreur car an n'est défini que dans le cas d'un environnement local */ 
%put &an.;
/* 2. Défini auparavant dans un environnement local, elle change de valeur à l'appel de la fonction */
%let an = 2023;
%put Année : &an.;
%test;
%put Année après la macro : &an.;
/* 3. Problème corrigé, en imposant la variable à local dans la macro */
%macro test2;
  %local an;
  %let an = 2022;
%mend test2;
%let an = 2023;
%put Année : &an.;
%test2;
%put Année après la macro : &an.;
