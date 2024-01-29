donnees <- data.frame(
Identifiant = c("173", "173", "173", "173", "174", "175", "198", "198", "198", "168", "211", "278", "347", "112", "112", "112", "087", "087", "099", "099", "099", "187", "187", "689", "765", "765", "765"),
Sexe_red = c("2", "2", "2", "2", "1", "1", "2", "2", "2", "1", "2", "1", "2", "1", "1", "1", "1", "1", "1", "1", "1", "2", "2", "1", "1", "1", "1"),
CSP = c("1", "1", "1", "1", "1", "1", "4", "4", "4", "2", "3", "5", "5", "3", "3", "3", "3", "3", "3", "3", "3", "2", "2", "1", "4", "4", "4"),
Niveau = c("Qualifie", "qualifie", "qualifie", "Non Qualifie", "qualifie", "qualifie", "Non qualifie", "Qualifie", "Qualifie", "Qualifie", "Non qualifie", "Qualifie", "Qualifie", "Non qualifie", 
           "Non qualifie", "qualifie", "Non qualifie", "Non qualifie", "qualifie", "qualifie", "qualifie", "qualifie", "qualifie", NA, "Non qualifie", "Non qualifie", "Non qualifie"),
Date_naissance = c("17/06/1998", "17/06/1998", "17/06/1998", "17/06/1998", "08/12/1984", "16/09/1989", "17/03/1987", "17/03/1987", "17/03/1987", "30/07/2002", NA, "10/08/1948", 
                   "13/09/1955", "13/09/2001", "13/09/2001", "13/09/2001", NA, NA, "06/06/1998", "06/06/1998", "06/06/1998", "05/12/1986", "05/12/1986", "01/12/2000", "26/12/1995", "26/12/1995", "26/12/1995"),
Date_entree = c("01/01/2021", "01/01/2022", "06/01/2022", "02/01/2023", "17/08/2021", "21/12/2022", "28/07/2022", "17/11/2022", "21/02/2023", "04/09/2019", "17/12/2021", "07/06/2018", NA, "02/03/2022", "01/03/2021", "01/12/2023", NA, 
                 "31/10/2020", "01/03/2021", "01/03/2022", "01/03/2023", "01/01/2022", "01/01/2023", "06/11/2017", "17/04/2020", "17/04/2020", "17/04/2020"),
Duree = c("308", "365", "185", "365", "183", "730", "30", "164", "365", "365", "135", "365", "180", "212", "365", "365", "365", "365", "364", "364", "364", "364", "364", "123", "160", "160", "160"),
Note_Contenu = c("12", "6", "8", "14", "17", "5", "10", "11", "9", "18", "16", "14", "12", "3", "7", NA, NA, NA, "12", "12", "12", "10", "10", "9", "13", "13", "13"),
Note_Formateur = c("6", NA, "10", "15", "18", "5", "10", "7", "20", "11", "16", "10", "5", "10", "13", NA, NA, NA, "11", "11", "11", "10", "10", "7", "10", "10", "10"),
Note_Moyens = c("17", "12", "11", "15", "20", "8", "10", "6", "3", "20", "15", "6", "7", "11", "8", NA, NA, NA, "10", "10", "10", "10", "10", "8", "12", "12", "12"),
Note_Accompagnement = c("4", "7", "1", "10", "15", "4", "16", "14", "4", "13", "12", "8", "11", "9", "19", NA, NA, NA, "12", "12", "12", "10", "10", "13", "18", "18", "18"),
Note_Materiel = c("19", "14", "9", "8", "12", "9", "8", "13", "17", "15", "9", "12", "12", "8", "2", NA, NA, NA, "13", "13", "13", "10", "10", "16", "10", "10", "10"),
poids_sondage = c("117.1", "98.3", "214.6", "84.7", "65.9", "148.2", "89.6", "100.3", "49.3", "148.2", "86.4", "99.2", "105.6", "123.1", "137.4", "187.6", "87.3", "87.3", "169.3", "169.3", "169.3", "169.3", "234.1", "189.3", "45.9", "45.9", "45.9"))

library(tidyverse)
donnees <- tibble::as_tibble(donnees)

# Extraire les noms des variables de la base
# R est sensible à la casse, il est pertinent d'harmoniser les noms des variables en minuscule
# Tidyverse : rename_with(): Rename variables with a function donnees %>% rename_with(toupper)
donnees <- donnees %>% dplyr::rename_with(tolower)

# Extraire les 10 premières lignes de la base
# Tidyverse : slice(): Choose rows by position
donnees %>% slice(1:10)
slice(donnees, 1:10)
# Extraire les 10 dernières lignes de la base
donnees %>% slice((n()-10):n())

# On renomme la variable sexe_red en sexe
# Tidyverse : rename(): Rename variables by name
donnees <- donnees %>% rename(sexe = sexe_red)

# Selection de colonnes
# Tidyverse : pull(): Pull out a single variable
# Sélection d'une unique variable
# Par position
donnees %>% pull(1)
# Par nom
donnees %>% pull(identifiant)
var <- "identifiant"
donnees %>% pull(var)

# Trier les colonnes (noms de variables) de la base
# Tidyverse : relocate(): Change column order
# Mettre les variables identifiant, date_entree et date_sortie au début de la base
colTri <- c("identifiant", "date_entree", "date_sortie")
donnees <- donnees %>% relocate(colTri)
# Mettre la variable poids_sondage au début de la base
donnees <- donnees %>% relocate(poids_sondage)
# Mettre la variable poids_sondage à la fin de la base
donnees <- donnees %>% relocate(poids_sondage, .after = last_col())


# Identifiants uniques
# Tidyverse : distinct(): Select distinct/unique rows
donnees %>% distinct(identifiant)
# Premier élement
donnees %>% distinct(identifiant, .keep_all = TRUE)