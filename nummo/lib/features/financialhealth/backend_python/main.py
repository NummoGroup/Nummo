from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

import numpy as np

from tensorflow.keras.models import load_model
from sklearn.preprocessing import StandardScaler

app = FastAPI()

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permitir todas las orígenes (localhost, 10.0.2.2, etc.)
    allow_credentials=True,
    allow_methods=["*"],  # Permitir todos los métodos (GET, POST, OPTIONS, etc.)
    allow_headers=["*"],  # Permitir todos los headers
)

# CARGAR MODELO
model = load_model("modelo_salud.keras")

# SCALER MANUAL
# usamos los mismos datos del entrenamiento
datos = np.array([

    [5000, 2000, 1500, 1],
    [4500, 2500, 1200, 2],
    [4000, 3500, 300, 6],
    [3000, 2900, 100, 8],
    [2500, 2400, 50, 9],
    [6000, 2800, 2000, 1]

])

scaler = StandardScaler()
scaler.fit(datos)

# MODELO DE DATOS
class Usuario(BaseModel):
    ingresos: float
    gastos: float
    ahorro: float
    compras_impulsivas: float

# ENDPOINT
@app.post("/predecir")
def predecir(usuario: Usuario):

    entrada = np.array([[
        usuario.ingresos,
        usuario.gastos,
        usuario.ahorro,
        usuario.compras_impulsivas
    ]])

    entrada = scaler.transform(entrada)

    prediccion = model.predict(entrada)

    porcentaje = float(prediccion[0][0] * 100)

    return {
        "salud_financiera": round(porcentaje, 2)
    }