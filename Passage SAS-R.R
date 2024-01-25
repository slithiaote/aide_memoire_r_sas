###########################################################################################################
#                                         Passage de SAS vers R                                           #
###########################################################################################################

# Pour manipuler les dates
#try(utils::install.packages("lubridate"))
library(lubridate)

# A FAIRE : ajouter xtabs avec matrix pour singer la proc tabulate
# Numéroter les parties pour les correspondances
# Conventions de nommage ???
# Parler de length !!!
# proc tabulate !!! https://ardata-fr.github.io/flextable-book/crosstabs.html
# Empiler la base Données et la base servant aux jointures avec les colonnes manquantes
# first. Tail by
# Fonctions à mentionner : tapply, by



# Création de la base R
a <- "Identifiant|Sexe_red|CSP|Niveau|Date_naissance|Date_entree|Duree|Note_Contenu|Note_Formateur|Note_Moyens|Note_Accompagnement|Note_Materiel|poids_sondage
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
765|1|4|Non qualifie|26/12/1995|17/04/2020|160|13|10|12|18|10|45.9"

# On récupère déjà l'identifiant de l'utilisateur
user <- Sys.getenv("USERNAME")
# Chemin d'accès au bureau de l'utilisateur
chemin <- file.path("C:/Users", user, "Desktop")
fichier <- file.path(chemin, "Passage SAS à R.csv")
# On copie ce fichier texte sur le bureau de l'utilisateur
writeLines(a, con = fichier)

# On va importer ce fichier texte en base R (dataframe)
# ?read.csv pour la documentation et le sens des paramètres
?read.csv
# On importe la base de données dans R
# on importe par défaut les colonnes en texte
donnees <- read.csv(file.path(chemin, "Passage SAS à R.csv"), sep = "|", header = TRUE, na.strings = "",
                    colClasses = rep("character",length(data)))

# On suprime le fichier texte importé du bureau de l'utilisateur
file.remove(fichier)

# On vérifie que la base importée est bien un data.frame
is.data.frame(donnees)


# Extraire les noms des variables de la base
# R est sensible à la casse, il est pertinent d'harmoniser les noms des variables en minuscule
nomCol <- tolower(colnames(donnees))
# Renommer les colonnes de la base
colnames(donnees) <- tolower(colnames(donnees))

# On importe toutes les variables en caractère
# On convertit certaines variables en format 'numeric'
enNumerique <- c("duree", "note_contenu", "note_formateur", "note_moyens", "note_accompagnement", "note_materiel")
donnees[, enNumerique] <- lapply(donnees[, enNumerique], as.integer)
donnees$poids_sondage <- as.numeric(donnees$poids_sondage)

# Format des colonnes
sapply(donnees, class)

# Ne sélectionner que les variables numériques de la base
donnees[, sapply(donnees, is.numeric), drop = FALSE]

# On récupère les variables dont le nom débute par le mot "date"
varDates <- names(donnees)[grepl("date", tolower(names(donnees)))]
# On remplace / par - dans les dates
donnees[, varDates] <- lapply(donnees[, varDates], function(x) gsub("/", "-", x))
# On exprime les dates en format Date
donnees[, varDates] <- lapply(donnees[, varDates], lubridate::dmy)



# Affichage de l'année
annee <- lubridate::year(Sys.Date())
sprintf("Année : %04d", annee)
print(paste0("Année : ", annee))
annee_1 <- annee - 1
paste0("Année passée: ", annee_1)

# Construction des instructions if / else
# Construction incorrecte ! Le else doit être sur la même ligne que le {
if (annee >= 2023) {
  print("Nous sommes en 2023 ou après")
}else {
  print("Nous sommes en 2022 ou avant")
}
# Construction correcte ! Le else doit être sur la même ligne que le {
if (annee >= 2023) {
  print("Nous sommes en 2023 ou après")
} else {
  print("Nous sommes en 2022 ou avant")
}


######################################################## Informations sur la base de données ######################################

# Extraire les 10 premières lignes de la base
View(donnees[1:10, ])
head(donnees)

# Statistiques descriptives
summary(donnees)
str(donnees)

# Nombre de lignes et de colonnes dans la base
dim(donnees) ; dim(donnees)[1] ; dim(donnees)[2]
dim(donnees) ; nrow(donnees) ; ncol(donnees)
sprintf("Nombre de lignes : %d | Nombre de colonnes : %d", dim(donnees)[1], dim(donnees)[2])

# On renomme la variable sexe_red en sexe
donnees$sexe <- donnees$sexe_red
# Suppression de la variable sexe_red (renommée)
donnees$sexe_red <- NULL

# Formater les modalités des valeurs
sexef <- c("1" = "Homme", "2" = "Femme")
cspf <- c("1" = "Cadre", "2" = "Profession intermédiaire", "3" = "Employé", "4" = "Ouvrier", "5" = "Retraité")

# Utiliser les formats
donnees$sexef <- donnees$sexef[donnees$sexe]

# On exprime CSP et sexe en formaté
donnees$cspf <- cspf[donnees$csp]
donnees$sexef <- sexef[donnees$sexe]
# Ventilation de la variable
table(donnees$cspf) ; table(donnees$sexef)
# Si on ne veut pas utiliser les donnees$ à chaque appel de fonction ????

# Ajouter, transformer, supprimer, sélectionner, conserver des colonnes
var <- c("identifiant", "sexe", "note_contenu", "sexef")
donnees2 <- donnees[, var]
dim(donnees2) ; names(donnees2)

# Variables commençant par le mot note
donnees_notes <- donnees[, names(donnees)[substr(names(donnees), 1, 4) == "note"]]


# Sélection de lignes respectant une certaine condition
femmes <- donnees[donnees$sexef == "Femme", ]
femmes <- subset(donnees, sexef == "Femme")
femmes <- donnees[donnees$sexef == "Femme", ]
femmes <- subset(donnees, sexef == "Femme")

# Création de colonne
femmes$note2 <- femmes$note_contenu / 20 * 5
# Suppression de colonnes
femmes$sexe <- NULL
# Selection de colonnes
femmes <- femmes[, c("identifiant", "note_contenu", "note2", "sexef")]

# Création de variables conditions : if else if => ifelse ou case_when en R
donnees$civilite <- ifelse(donnees$sexe == "2", "Mme", ifelse(donnees$sexe == "1", "M", "Inconnu"))
# Autre solution
donnees$civilite <- "Inconnu"
donnees$civilite[donnees$sexe == "1"] <- "M"
donnees$civilite[donnees$sexe == "2"] <- "Mme"


# Âge à l'entrée dans le dispositif
donnees$age <- floor(lubridate::time_length(difftime(donnees$date_entree, donnees$date_naissance), "years"))
# Affectation rapide
donnees$agef[donnees$age < 26]                     <- "1. De 15 à 25 ans"
# 26 <= donnees$age < 50 ne fonctionne pas, il faut passer en 2 étapes
donnees$agef[26 <= donnees$age & donnees$age < 50] <- "2. De 26 à 49 ans"
donnees$agef[donnees$age >= 50]                    <- "3. 50 ans ou plus"
# Autre solution
agef <- cut(donnees$age, 
            breaks = c(0, 25, 49, Inf),
            right = TRUE,
            labels = c("1. De 15 à 25 ans", "2. De 26 à 49 ans", "3. 50 ans ou plus"), 
            ordered_result = TRUE)

# Manipuler les dates
sixmois <- 365.25/2
# La durée du contrat est-elle supérieure à 6 mois ?
donnees$duree_Sup_6_mois <- ifelse(donnees$duree >= sixmois, 1, 0)
# Date de sortie du dispositif
donnees$date_sortie <- donnees$date_entree + lubridate::days(donnees$duree)

# La date de sortie est après le 31 décembre de l'année
apres_31_decembre <- ifelse(donnees$date_sortie > as.Date(paste0(annee,"-12-31")), 1, 0)
with(donnees, sum(apres_31_decembre * poids_sondage, na.rm = TRUE) / sum(poids_sondage, na.rm = TRUE)) * 100

# Date 6 mois après la sortie
donnees$date_6mois <- donnees$date_sortie + lubridate::month(6)

# Mettre un 0 devant un nombre
# Obtenir le mois et la date
donnees$mois <- lubridate::month(donnees$date_entree)
donnees$annee <- lubridate::year(donnees$date_entree)
# Mettre le numéro du mois sur 2 positions (avec un 0 devant si le mois <= 9)
donnees$mois <- sprintf("%02d", donnees$mois)

# On souhaite rééxprimer les notes sur 100 et non sur 20
notes <- c("note_contenu", "note_formateur", "note_moyens", "note_accompagnement", "note_materiel")
donnees[, notes] <- donnees[, notes] / 20 * 100




#################################################### Manipuler des chaînes de caractères ##############################################

# Manipuler les chaînes de caractères
# Première lettre en majuscule
donnees$niveauMaj = toupper(donnees$niveau)
# Le mot qualifie n'a pas d'accent : on le corrige
donnees$niveau <- gsub("Qualifie", "Qualifié", donnees$niveau)

# En majuscule
donnees$csp_maj <- toupper(donnees$cspf)
# En minuscule
donnees$csp_maj <- tolower(donnees$cspf)
# 1ère lettre en majuscule, autres lettres en minuscule
donnees$niveau <- paste0(toupper(substr(donnees$niveau, 1, 1)), tolower(substr(donnees$niveau, 2, length(donnees$niveau))))
# Nombre de caractères dans une chaîne de caractères
donnees$taille_id <- nchar(donnees$identifiant)

# Manipuler des chaînes de caractères => R = gsub, grepl etc.
texte  <- "              Ce   Texte   mériterait   d être   corrigé                  "
texte1 <- "Je m'appelle"
texte2 <- "R"
# Enlever les blancs au début et à la fin de la chaîne de caractère
# "\\s+" est une expression régulière indiquant 1 ou plusieurs espaces successifs
# Le gsub remplace 1 ou plusieurs espaces successifs par un seul espace
# trimws enlève les espaces au début et à la fin d'une chaîne de caractère 
texte <- gsub("\\s+", " ", trimws(texte))
# Concaténer des chaînes de caractères
paste(texte1, texte2, sep = " ")
paste0(texte1, texte2)


# Extraire les 2e, 3e et 4e caractères de Concatener
# 2 correspond à la position du 1er caractère à récupérer, 5 la position du dernier caractère
extrait <- substr(concatener, 2, 5)

# Transformer plusieurs caractères différents
chaine <- "éèêëàâçîô"
chartr("éèêëàâçîô", "eeeeaacio", chaine)


# Transformer le format de variables
# Transformer la variable sexe en numérique
donnees$sexe_numerique <- as.numeric(donnees$sexe)
donnees$sexe_numerique
# Transformer la variable sexe_numerique en caractère
donnees$sexe_caractere <- as.character(donnees$sexe_numerique)
donnees$sexe_caractere

# Arrondir une valeur numérique
# Arrondi à l'entier le plus proche
poids_arrondi_0 <- round(donnees$poids, 0)
# Arrondi à 1 chiffre après la virgule
poids_arrondi_1 <- round(donnees$poids, 1)
# Arrondi à 2 chiffre après la virgule
poids_arrondi_2 <- round(donnees$poids, 2)
# Arrondi à l'entier inférieur
poids_inf <- floor(donnees$poids)
# Arrondi à l'entier inférieur
poids_inf <- ceiling(donnees$poids)



############################################################ Gestion ligne par ligne #####################################################

# Numéro de l'observation : 2 manières différentes
donnees$num_observation <- row.names(donnees)
donnees$num_observation <- seq(1 : nrow(donnees))

# Numéro du contrat de chaque individu, contrat trié par date de survenue
donnees <- donnees[order(donnees$identifiant, donnees$date_entre, na.last = FALSE), ]
donnees$a <- 1
donnees$numero_contrat <- ave(donnees$a, donnees$identifiant, FUN = cumsum)
# Pour trier les colonnes
tri <- c("identifiant", "date_entree", "numero_contrat", "num_observation")
donnees <- donnees[, c(tri, colnames(donnees)[! colnames(donnees) %in% tri])]

# 2e contrat de l'individu (et rien si l'individu n'a qu'un seul contrat
deuxieme_contrat <- donnees[donnees$numero_contrat == 2, ]

# Créer une base avec les seuls premiers contrats, et une base avec les seuls derniers contrats
donnees <- donnees[order(donnees$identifiant, donnees$date_entre, na.last = FALSE), ]
premier_contrat <- donnees[!duplicated(donnees$identifiant, fromLast = FALSE), ]
dernier_contrat <- donnees[!duplicated(donnees$identifiant, fromLast = TRUE), ]
ni_prem_ni_der  <- donnees[! (!duplicated(donnees$identifiant, fromLast = FALSE) | !duplicated(donnees$identifiant, fromLast = TRUE)), ]

# Le premier contrat, le dernier contrat, ni le premier ni le dernier contrat de chaque individu ...
donnees <- donnees[order(donnees$identifiant, donnees$date_entre, na.last = FALSE), ]
donnees$premier_contrat <- ifelse(!duplicated(donnees$identifiant, fromLast = FALSE), 1, 0)
donnees$dernier_contrat <- ifelse(!duplicated(donnees$identifiant, fromLast = TRUE), 1, 0)
donnees$ni_prem_ni_der  <- ifelse(! c(!duplicated(donnees$identifiant, fromLast = FALSE) |
                                        !duplicated(donnees$identifiant, fromLast = TRUE)), 1, 0)


# La date de fin du contrat précédent
donnees <- donnees[order(donnees$identifiant, donnees$date_entre, na.last = FALSE), ]
# Il n'existe pas de fonction lag dans le R de base (à notre connaissance)
# Il faut soit utiliser un package, soit utiliser cette astuce
donnees$date_sortie_1 <- c(as.Date(NA), donnees$date_sortie[ 1:(length(donnees$date_sortie) - 1)])
donnees$date_sortie_1[!duplicated(donnees$identifiant, fromLast = FALSE)] <- as.Date(NA)


# Personnes qui ont suivi à la fois une formation qualifiée et une formation non qualifiée
# À FAIRE !!!!!
# https://stackoverflow.com/questions/49669862/how-to-group-by-in-base-r
#proc sql;
#create table Qualif_Non_Qualif as
#select *
#  from Donnees
#group by identifiant
#having sum((Niveau = "Non qualifie")) >= 1 and sum((Niveau = "Non qualifie")) >= 1;
#quit;
# A FAIRE !!!!!!!!!!!!!!!!!!!!!!!!!
qualif_non_qualif <- subset(aggregate(dep_delay ~ day + month, donnees, 
                            function(x) cbind(count=length(x), avg_delay=mean(x, na.rm = TRUE)),
                            na.action = NULL), 
                            dep_delay[,1] > 1000)


# Transposer une base
# Etablissement d'un tableau croisé comptant les occurences
# as.data.frame.matrix est nécessaire, car le résultat de xtabs est un array
nb <- as.data.frame.matrix(xtabs( ~ cspf + sexef, data = donnees))
nb_transpose <- as.data.frame(t(nb))



############################################################# Les valeurs manquantes ######################################################

# Repérer les valeurs manquantes
donnees$missing <- ifelse(is.na(donnees$age) | is.na(donnees$niveau), 1, 0)
ageManquant <- donnes[donnees$age == NA,  ] # Faux
ageManquant <- donnes[is.na(donnees$age), ] # Correct

# Incidence des valeurs manquantes
mean(donnees$note_formateur)
mean(donnees$note_formateur, na.rm = TRUE)

# INCIDENCE DES VALEURS MANQUANTES DANS UN TRI




################################################################### Les tris ###########################################################

# Trier la base par ligne (individu et date de début de la formation) par ordre croissant
# L'option na.last = FALSE (resp. TRUE) indique que les valeurs manquantes doivent figurer à la fin (resp. au début) du tri, que le tri
# soit croissant ou décroissant
donnees <- donnees[order(donnees$identifiant, donnees$date_entree, na.last = FALSE), ]
# Tri par ordre croissant de identifiant et décroissant de date_entree (- avant le nom de la variable)
donnees <- donnees[order(donnees$identifiant, -donnees$date_entree, na.last = FALSE), ]


# Trier la base par colonne (noms de variables)
# On met identifiant date_entree et date_sortie au début
colTri <- c("identifiant", "date_entree", "date_sortie")
donnees[, c(colTri, colnames(donnees)[! colnames(donnees) %in% colTri])]

# Incidence des valeurs manquantes dans les tris
# Les valeurs manquantes sont situées en dernier dans un tri par ordre croissant ou décroissant (car par défaut l'option na.last = TRUE) ...
donnees <- donnees[order(donnees$identifiant, donnees$date_entree), ]
# Pour mimer le tri SAS, il faut écrire :
donnees <- donnees[order(donnees$identifiant, donnees$date_entree, na.last = FALSE), ]



###################################################### Les doublons ########################################################

# Repérage et éliminiation des doublons
# Repérage
doublons <- donnees[duplicated(donnees), ]

# On supprime les doublons
donnees <- donnees[! duplicated(donnees), ]

# Autre solution (solution first. de SAS)
donnees <- donnees[order(colnames(donnees), na.last = FALSE), ]
donnees <- donnees[!duplicated(donnees[, colnames(donnees)], fromLast = TRUE), ] 




########################################################## Les jointures de bases ##########################################################

# Les jointures
# On suppose que l'on dispose d'une base supplémentaire avec les diplômes des personnes
diplome <- data.frame(identifiant_i = c("173", "168", "112", "087", "689", "765", "112", "999", "554"),
                      diplome = c("Bac", "Bep-Cap", "Bep-Cap", "Bac+2", "Bac+2", "Pas de diplôme", "Bac", "Bac", "Bep-Cap"),
                      age_dip = c(22, 27, 18, 23, 21, 15, 21, 18, 20)
)
jointure <- donnees[, c("identifiant", "sexe", "age")]

# 1. Inner join : les seuls identifiants communs aux deux bases
innerJoin <- merge(jointure, diplome, by.x = "identifiant", by.y = "identifiant_i")
dim(innerJoin)

# 2. Left join : les identifiants de la base de gauche
leftJoin <- merge(jointure, diplome, by.x = "identifiant", by.y = "identifiant_i", all.x = TRUE)
dim(leftJoin)

# 3. Full join : les identifiants des deux bases
fullJoin <- merge(jointure, diplome, by.x = "identifiant", by.y = "identifiant_i", all = TRUE)
dim(fullJoin)

# 4. Cross join : toutes les combinaisons possibles de CSP, sexe et Diplome
crossJoin <- unique(expand.grid(donnees$cspf, donnees$sexef, diplome$diplome))
colnames(crossJoin) <- c("cspf", "sexef", "diplome")
crossJoin

# 5. Jointures avec des inégalités
# A FAIRE !!!!
#lessRows <- which(df1$col1 < df2$col2)
#df3 <- merge(df1, df2)[lessRows, ]
#https://stackoverflow.com/questions/32893022/join-two-datasets-based-on-an-inequality-condition


# 6. Empiler des bases dont les variables sont différentes
# Lorsque les variables ne correspondent pas, on les crée avec des valeurs manquantes, via setdiff
empilement <- rbind(
  data.frame(c(donnees, sapply(setdiff(names(diplome), names(donnees)), function(x) NA))),
  data.frame(c(diplome, sapply(setdiff(names(donnees), names(diplome)), function(x) NA)))
)


# Autres fonctions utiles

# Concaténation des identifiants
c(jointure$identifiant, diplome$identifiant_i)
union(jointure$identifiant, diplome$identifiant_i)
# Identifiants uniques des 2 bases
unique(c(jointure$identifiant, diplome$identifiant_i))
# Identifiants communs des 2 bases
intersect(jointure$identifiant, diplome$identifiant_i)
# Identifiants dans jointure mais pas diplome
setdiff(jointure$identifiant, diplome$identifiant_i)
# Identifiants dans diplome mais pas jointure
setdiff(diplome$identifiant_i, jointure$identifiant)


############################################################# Statistiques descriptives ################################################

# Moyenne de chaque note
notes <- tolower(c("Note_Contenu", "Note_Formateur", "Note_Moyens", "Note_Accompagnement", "Note_Materiel"))
lapply(donnees[, notes], mean, na.rm = TRUE)
sapply(donnees[, notes], mean, na.rm = TRUE)
sapply(donnees[, notes], function(x) c("Somme" = sum(x, na.rm = TRUE), "Moyenne" = mean(x, na.rm = TRUE),
                                       "Médiane" = median(x, na.rm = TRUE), "Max" = max(x, na.rm = TRUE),
                                       "Min" = min(x, na.rm = TRUE)))
# Avec la pondération
with(donnees, sapply(donnees[, notes], function(x) weighted.mean(x, poids_sondage, na.rm = TRUE)))


# Tableaux de contingence (proc freq)
table(donnees$sexef, useNA = "always")
prop.table(table(donnees$sexef, useNA = "always")) * 100
prop.table(table(donnees$cspf, useNA = "always")) * 100
# Proportion par case
prop.table(table(donnees$cspf, donnees$sexef, useNA = "always")) * 100

# Proportion par ligne
prop.table(table(donnees$cspf, donnees$sexef, useNA = "always"), margin = 1) * 100
# Proportion par colonne
prop.table(table(donnees$cspf, donnees$sexef, useNA = "always"), margin = 2) * 100
# Pour avoir les sommes lignes et colonnes
addmargins(prop.table(table(donnees$cspf, donnees$sexef, useNA = "always"), margin = 2) * 100)

# Avec un poids : le plus simple est d'utiliser un package cette fois
# svytable du package survey ???
library(survey)
donnees <- donnees[! is.na(donnees$poids_sondage), ]
a <- survey::svydesign(id = ~1, weights = ~poids_sondage, data = donnees)
survey::svytable(poids_sondage ~ sexef + cspf, design = a)


# Autre possibilité pour avoir la même présentation que la proc freq de SAS
# Utiliser le package gmodels
library(gmodels)
gmodels::CrossTable(donnees$cspf, donnees$sexef)
# Cette méthode ne permet pas de pondérer, apparemment

library(flextable)
flextable::proc_freq(donnees, "cspf", "sexef")
flextable::proc_freq(donnees, "cspf", "sexef", weight = "poids_sondage")



# Moyenne des notes par individu
notes <- tolower(c("Note_Contenu", "Note_Formateur", "Note_Moyens", "Note_Accompagnement", "Note_Materiel"))
# apply permet d'appliquer une fonctions aux lignes (1) ou colonne (2) d'un data.frame
donnees$note_moyenne <- apply(donnees[, notes], 1, mean, na.rm = TRUE)
donnees$note_moyenne <- rowMeans(donnees[, notes])
# utilisation du drop = FALSE étrange
# En fait, l'affectation par [] a pour option par défaut drop = TRUE. Ce qui implique que si l'affectation renvoie un data.frame de
# 1 seule colonne, l'objet sera transformé en un vecteur, et rowSums ne marchera pas 
donnees$note_moyennepond <- rowSums(donnees[, notes] * donnees$poids_sondage) / rowSums(donnees[, c("poids_sondage"), drop = FALSE])
donnees$note_moyennepond <- apply(donnees[, notes], 2, function(x) weighted.mean* donnees$poids_sondage) / rowSums(donnees[, c("poids_sondage"), drop = FALSE])


# Somme pondérée et non pondérée avec des conditions (ici pour les seules femmes)
with(subset(donnees, sexef == "Femme"), sum(note_moyenne * poids_sondage, na.rm = TRUE) / sum(poids_sondage, na.rm = TRUE))
with(subset(donnees, sexef == "Femme"), mean(note_moyenne, na.rm = TRUE))


# Note moyenne (non pondérée et pondérée)
mean(donnees$note_moyenne, na.rm = TRUE)
sum(donnees$note_moyenne * donnees$poids_sondage, na.rm = TRUE) / sum(donnees$poids_sondage, na.rm = TRUE)

# La note donnée est-elle supérieure à la moyenne ?
donnees$note_superieure_moyenne <- ifelse(donnees$note_moyenne >= mean(donnees$note_moyenne, na.rm = TRUE), 1, 0)
table(donnees$note_superieure_moyenne)
prop.table(table(donnees$note_superieure_moyenne)) * 100

# Déciles et quartiles de la note moyenne
quantile(donnees$note_moyenne, probs = c(seq(0, 1, 0.1), 0.25, 0.75), na.rm = TRUE)

# Tableaux de résultats
aggregate(note_moyenne ~ cspf + sexef, data = donnees, FUN = mean, na.rm = TRUE)
aggregate(note_moyenne ~ cspf + sexef + niveau, data = donnees, FUN = mean, na.rm = TRUE)

# Proc tabulate en R
# À REVOIR
xtabs(aggregate(note_moyenne ~ cspf + sexef + niveau, data = donnees, FUN = mean, na.rm = TRUE))
xtabs(aggregate(note_moyenne ~ cspf + sexef + niveau, data = donnees, FUN = median, na.rm = TRUE))
xtabs(aggregate(note_moyenne ~ cspf + sexef + niveau, data = donnees, FUN = function(x) return(c(mean(x), median(x), max(x), n(x))), na.rm = TRUE))



########################################################## Equivalent des macros SAS ######################################################

# Base par CSP
for (i in unique(donnees$cspf)) {
  # Met en minuscule et enlève les accents
  nomBase <- tolower(chartr("éèêëàâçîô", "eeeeaacio", i))
  # EXPLIQUER ASSIGN
  # METTRE UNE PARTIE DESSUS
  assign(nomBase, donnees[donnees$cspf == i, ])
}

# Itérer sur toutes les années et les trimestres d'une certaine plage
debut <- 2000
fin <- annee
# EXPLIQUER
res <- unlist(lapply(debut:fin, function(x) lapply(c("max", "min"), function(y)  sprintf("base_%4d_t%d_n%s", x, 1:4, y))))

# On va créer une base par année d'entrée
anMin <- min(lubridate::year(donnees$date_entree), na.rm = TRUE)
anMax <- max(lubridate::year(donnees$date_entree), na.rm = TRUE)
for (i in anMin:anMax) {
  # assign permet de faire passer une chaîne de caractères en variable R
  assign(paste("entree", i, sep = "_"), donnees[lubridate::year(donnees$date_entree) == i, ])
}
# On va désormais empiler toutes les bases (concaténation par colonne)
# do.call applique la fonction rbind à l'ensemble des bases issues du lapply
# get permet de faire le chemin inverse de assign
donnees_concatene <- do.call(rbind, lapply(paste("entree", anMin:anMax, sep = "_"), get))



# Autres transcriptions de fonctions SAS vers R

# Mesurer la durée d'exécution d'un programme
system.time(donnees <- donnees[order(donnees$identifiant, donnees$date_entree, na.last = FALSE), ])
# En SAS : include("chemin")
# En R : source("chemin", encoding = "utf-8", echo = TRUE, max.deparse.length = 1e3)

# Pour modifier le comportement na.rm = TRUE
# On peut redéfinir les fonctions sum et mean pour que l'option na.rm soit TRUE par défaut
#mean <- function(x, ..., na.rm = TRUE) {
#  base::mean(x, ..., na.rm = na.rm)
#}
#sum <- function(x, ..., na.rm = TRUE) {
#  base::sum(x, ..., na.rm = na.rm)
#}



###################################################### Fin du programme R ###########################################################

# Supprimer toutes les bases et tous les objets de la mémoire vive
rm(list = ls())
