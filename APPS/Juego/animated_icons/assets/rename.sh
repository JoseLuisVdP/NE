#!/bin/bash

# Carpeta actual
DIR="./"

for dir in "$DIR"*/
do
    # Bucle for para renombrar archivos
    for file in "$dir"*
    do
            # Obtener solo el nombre del archivo sin la ruta
            filename=$(basename "$file")

            # Extraer la parte del nombre de archivo antes del primer guion bajo
	    prefix=$(echo "$filename" | sed 's/.*\([0-9]\{5\}\).*/\1/')
	    extension="${filename##*.}"
	    echo "$extension"
            # Renombrar el archivo
            nuevo_nombre="name_$prefix.$extension"
            mv "$file" "$dir$nuevo_nombre"
            echo "Renombrando $filename a $nuevo_nombre"
    done
done
