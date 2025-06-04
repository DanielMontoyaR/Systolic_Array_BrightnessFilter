import numpy as np
from PIL import Image

# Leer archivo y convertir a matriz de enteros
with open("ordered_result.txt", "r") as file:
    matrix = [list(map(int, line.strip().split())) for line in file]

# Convertir a numpy array y guardar imagen
final_output_array = np.array(matrix, dtype=np.uint8)
final_output_image = Image.fromarray(final_output_array, mode='L')
final_output_image.save("PruebaResultado.jpeg")

print("Imagen generada exitosamente.")

def contar_items(cadena):
    # Elimina espacios extras y divide la cadena por espacios
    items = cadena.strip().split()
    return len(items)

#Prueba porque el largo de las líneas del txt se veían de tamaño disparejo
#texto = "0 246 156 63 59 53 58 62 73 83 97 103 100 99 101 102 100 93 115 126 125 98 87 105 108 116 113 91 80 83 84 86 81 79 84 103 125 136 152 161 154 140 123 108 101 106 112 121 124 121 113 100 88 81 83 93 72 51 60 57 64 75 72 66 80 81 79 75 77 81 89 96 96 97 97 97 96 94 91 88 89 85 87 88 88 82 70 65 56 49 45 43 40 39 48 61 67 62 67 85 106 114 110 103 99 92 85 82 81 81 80 80 89 88 85 79 71 64 59 57 48 39 36 36 41 43 47 61 100 117 124 124 119 122 133 131 93 71 79 98 100 109 115 100 75 79 64 118 239 0"
#print(contar_items(texto))