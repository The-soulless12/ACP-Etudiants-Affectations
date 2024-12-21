import pandas as pd
import hashlib

pv_data = pd.read_excel("./PV_2CP_2022_depart.xlsx")
sheets = pd.read_excel("./LISTE_AFFECTATION_depart.xlsx", sheet_name=None)

def hash_column(df, column_name):
    df[column_name] = df[column_name].apply(lambda x: hashlib.sha256(str(x).encode()).hexdigest())
    return df

# Hachage de la colonne Matricule 
pv_data = hash_column(pv_data, 'Matricule')
for sheet_name, sheet_data in sheets.items():
    sheet_data = sheet_data[['Matricule', 'Affectation']]
    sheets[sheet_name] = hash_column(sheet_data, 'Matricule')

# Sauvegarde des nouveaux fichiers
pv_data.to_excel("PV_2CP_2022.xlsx", index=False)
with pd.ExcelWriter("LISTE_AFFECTATION.xlsx") as writer:
    for sheet_name, sheet_data in sheets.items():
        sheet_data.to_excel(writer, sheet_name=sheet_name, index=False)

print("Les fichiers ont été sauvegardés avec les matricules hachés.")
