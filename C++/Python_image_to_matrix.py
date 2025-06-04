import cv2
import numpy as np

# Ruta de la imagen de entrada y el archivo de salida
input_image_path = "imagen_gris.jpg"
output_txt_path = "pixeles.txt"

# Cargar la imagen en escala de grises
imagen = cv2.imread(input_image_path, cv2.IMREAD_GRAYSCALE)

if imagen is None:
    print("Error: No se pudo cargar la imagen.")
else:
    # Guardar los valores de píxeles en el archivo .txt
    with open(output_txt_path, "w") as f:
        for fila in imagen:
            linea = ' '.join(str(pixel) for pixel in fila)
            f.write(linea + '\n')

    print(f"Valores de la imagen guardados en: {output_txt_path}")
