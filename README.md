# ACP-Etudiants-Affectations
Étude des données d'affectation d'étudiants à l'aide d'une Analyse en Composantes Principales (ACP) réalisée en langage R.

# Fonctionnalités
- Analyse des données des étudiants à l'aide de l'ACP afin d'identifier les composantes principales influençant les affectations.
- Visualisation des résultats sous forme de graphiques pour une meilleure interprétation des données.

# Structure du projet
- CODE ACP.R : Script principal en R pour effectuer l'ACP sur les données.
- Hachage Matricule.py : Script Python utilisé pour le hachage des matricules des étudiants afin d'assurer la confidentialité des données.
- LISTE_AFFECTATION.xlsx : Fichier Excel contenant les données d'affectation des étudiants.
- PV_2CP_2022.xlsx : Fichier Excel contenant les notes des étudiants dans plusieurs modules.

# Prérequis
- Langage R.
- Les packages : FactoMineR, factoextra, readxl, dplyr & ggplot2.

# Note
- Le script Python a été utilisé pour hacher les matricules des étudiants, garantissant ainsi la protection des données et la confidentialité.
- Concernant le code R, il est nécessaire de placer les fichiers Excel dans le répertoire indiqué par `getwd()` au début du script. Si vos fichiers se trouvent dans un autre emplacement, vous devrez décommenter la ligne `#setwd("chemin absolu")` et y indiquer le chemin absolu du répertoire contenant les fichiers Excel.
