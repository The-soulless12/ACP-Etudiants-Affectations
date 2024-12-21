library(FactoMineR)
library(factoextra)

getwd()
#setwd("chemin absolu")

# Lecture des fichiers excel
library(readxl)
pv_data <- read_excel("PV_2CP_2022.xlsx")

# Dans la liste affectation se trouve 4 différents sheet
sheet1 <- read_excel("LISTE_AFFECTATION.xlsx",sheet=1)
sheet2 <- read_excel("LISTE_AFFECTATION.xlsx",sheet=2)
sheet3 <- read_excel("LISTE_AFFECTATION.xlsx",sheet=3)
sheet4 <- read_excel("LISTE_AFFECTATION.xlsx",sheet=4)

# Création d'une seule liste d'affectation en réalisant une fusion
library(dplyr)
affectation_data <- bind_rows(sheet1, sheet2, sheet3, sheet4)

# Traitement de pv_data et retrait des colonnes non concernées par l'étude
pv_data <- pv_data %>%
  select(-c("Groupe_S1", "SFSD", "ARCH2", "UEF5", "ANAL3", "ALG3", "UEF6", "ELEF2", 
            "PRST1", "UEM2", "ANG2", "UET3", "ECON", "UED2", "Ne_S1", "Rang_S1", 
            "Moy_S1", "Moy_rachatS1", "Crd_S1", "Groupe_S2", "Ne_S2", "Rang_S2",
            "Moy_S2",	"Moy_rachatS2",	"Crd_S2",	"Rang_annuel", "Moy_annuelle",
            "Moy_rachat",	"Crd_annuel",	"Decision_jury",
            "UEF7", "UEM3", "UEM4", "UET4", "UEF8"))

# Fusion des notes avec les affectations selon la colonne Matricule
data <- left_join(pv_data, affectation_data, by = "Matricule")

# Traitements des étudiants sans affectations
colSums(is.na(data))
data <- data[!is.na(data$Affectation), ]

# Détection des valeurs aberrantes
numeric_data <- data %>% select(-c(Matricule, Affectation)) %>% select(where(is.numeric))
outliers <- apply(numeric_data, 2, function(x) {
  quantiles <- quantile(x, c(0.25, 0.75), na.rm = TRUE)
  IQR <- diff(quantiles)
  lower_bound <- quantiles[1] - 1.5 * IQR
  upper_bound <- quantiles[2] + 1.5 * IQR
  x < lower_bound | x > upper_bound
})
outliers_data <- data[apply(outliers, 1, any), ] # Nous gardons les outliers dans un tableau séparé
data <- data[!apply(outliers, 1, any), ]

# La colonne Matricule ne nous sert plus à rien car nous allons étiquetter chaque étudiant par sa spécialité
data_old <- data
data <- data %>%
  select(-Matricule)

# Nous pouvons à présent faire notre ACP 
ACP <- PCA(data %>% select(-Affectation), scale.unit = TRUE, graph = FALSE)

# Les valeurs propres + Inerties 
val_propres <- ACP$eig
print(val_propres)
fviz_screeplot(ACP, addlabels = TRUE, ylim = c(0, 50))

# Projection des individus selon un code couleur
p <- fviz_pca_ind(ACP, 
             geom.ind = "point", 
             col.ind = data$Affectation,
             palette = c("purple", "pink", "brown", "cyan"),
             legend.title = "Affectation"
)
print(p)

# Contributions des individus pour les 5 premiers axes
fviz_contrib(ACP, choice = "ind", axes = 1, top = 10)
fviz_contrib(ACP, choice = "ind", axes = 2, top = 10)
fviz_contrib(ACP, choice = "ind", axes = 3, top = 10)
fviz_contrib(ACP, choice = "ind", axes = 4, top = 10)
fviz_contrib(ACP, choice = "ind", axes = 5, top = 10)

# Projections des variables 
fviz_pca_var(ACP, 
             col.var = "black", 
             axes = c(1, 2), 
             addlabels = TRUE, 
             legend.title = "Variables"
)

# Contributions des variables pour les 5 premiers axes
fviz_contrib(ACP, choice = "var", axes = 1, top = 10)
fviz_contrib(ACP, choice = "var", axes = 2, top = 10)
fviz_contrib(ACP, choice = "var", axes = 3, top = 10)
fviz_contrib(ACP, choice = "var", axes = 4, top = 10)
fviz_contrib(ACP, choice = "var", axes = 5, top = 10)

ACP$var$coord # Les contributions des variables sur les 5 axes dans un tableau

# GESTION DES OUTLIERS
affectation_colors <- c("2SL" = "pink", "2SQ" = "brown", "2ST" = "cyan", "2SD" = "purple")
for (i in 1:nrow(outliers_data)) {
  current_outlier <- outliers_data[i, ] %>% select(-Affectation)
  coord_outlier <- predict(ACP, newdata = current_outlier)$coord
  coord_outlier <- coord_outlier[1, 1:2]
  
  outlier_affectation <- outliers_data$Affectation[i]
  outlier_color <- affectation_colors[outlier_affectation]
  p <- p + annotate("point", x = coord_outlier[1], y = coord_outlier[2], 
                    color = outlier_color, size = 4) +
    annotate("text", x = coord_outlier[1], y = coord_outlier[2], 
             label = paste("Outlier", i), vjust = -1, color = outlier_color)
}
print(p)

