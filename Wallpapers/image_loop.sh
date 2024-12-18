#!/bin/bash

# Carpeta que contiene las imágenes
CARPETA="/home/elcabris/Wallpapers"

while true; do
    # Escoge una imagen aleatoria de la carpeta
    IMAGEN=$(find "$CARPETA" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

    # Configura el fondo de pantalla
    feh --bg-scale "$IMAGEN"

    # Espera un tiempo antes de cambiar de nuevo (en segundos)
    sleep 300 # Cambia cada 5 minutos
done

