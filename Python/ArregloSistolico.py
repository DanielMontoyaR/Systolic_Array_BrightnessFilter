from PIL import Image
import numpy as np 
import os


# Cargar imagen JPEG en escala de grises
imagen = Image.open("C:/Users/Daniel/Desktop/Arqui 2 Arreglo Sistolico Desenfoque Gaussiano/Python/imagen.jpeg").convert("L")
# Convertir a array numpy
pixeles = np.array(imagen).tolist()

kernel = [
    [1, 4, 6, 4, 1],
    [4, 16, 24, 16, 4],
    [6, 24, 36, 24, 6],
    [4, 16, 24, 16, 4],
    [1, 4, 6, 4, 1]
]
Divisor = 256
#Padding = tamaño de fila del kernel/2 = 5/2 = 2

"""
Imagen = [
    [100, 120, 110, 105, 90],
    [115, 130, 125, 110, 95],
    [105, 140, 150, 120, 100],
    [95, 125, 130, 115, 85],
    [80, 110, 105,  90, 70],
]

#Imagen original 5x5 → Imagen con padding 9x9

ImagenPadding2 = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 100, 120, 110, 105, 90, 0, 0],
    [0, 0, 115, 130, 125, 110, 95, 0, 0],
    [0, 0, 105, 140, 150, 120, 100, 0, 0],
    [0, 0, 95, 125, 130, 115, 85, 0, 0],
    [0, 0, 80, 110, 105,  90, 70, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
]


print("Imagen original:")
for fila in Imagen:
    print(fila)
"""



def agregar_padding(imagen, padding=2):
    filas = len(imagen)
    columnas = len(imagen[0])
    nueva_fila = [0] * (columnas + 2 * padding)
    imagen_padding = []

    # Agregar filas de ceros arriba
    for _ in range(padding):
        imagen_padding.append(nueva_fila[:])

    # Agregar ceros a los lados de cada fila original
    for fila in imagen:
        imagen_padding.append([0] * padding + fila + [0] * padding)

    # Agregar filas de ceros abajo
    for _ in range(padding):
        imagen_padding.append(nueva_fila[:])

    return imagen_padding

    # Ejemplo de uso:
    #ImagenPadding = agregar_padding(Imagen, 2)

def convolucion(kernel, imagen, divisor):
    # Obtener dimensiones de la imagen y el kernel
    filas_imagen = len(imagen)
    columnas_imagen = len(imagen[0])
    filas_kernel = len(kernel)
    columnas_kernel = len(kernel[0])

    # Calcular el tamaño de la imagen resultante
    filas_resultado = filas_imagen - filas_kernel + 1
    columnas_resultado = columnas_imagen - columnas_kernel + 1

    # Inicializar la imagen resultante
    resultado = [[0 for _ in range(columnas_resultado)] for _ in range(filas_resultado)]



    # Realizar la convolución
    for i in range(filas_resultado):
        for j in range(columnas_resultado):
            suma = 0
            for k in range(filas_kernel):
                for l in range(columnas_kernel):
                    suma += imagen[i + k][j + l] * kernel[k][l]
            resultado[i][j] = suma // divisor
            

    print("\nKernel:")
    for fila in kernel:
        print(fila)



    return resultado



ImagenPadding = agregar_padding(pixeles, 2)


# Imprimir contenido
print("Imagen Original:")
print(pixeles)


print("\nImagen con padding:")
print(ImagenPadding)
#for fila in ImagenPadding:
#    print(fila)




# Llamar a la función de convolución
resultado = convolucion(kernel, ImagenPadding, Divisor)

print("\nImagen resultante:")
print(resultado)


resultado_array = np.array(resultado, dtype=np.uint8)
# Guardar la imagen resultante como JPEG
resultado_imagen = Image.fromarray(resultado_array,mode='L')
resultado_imagen.save("C:/Users/Daniel/Desktop/Arqui 2 Arreglo Sistolico Desenfoque Gaussiano/Python/imagen_resultante.jpeg")
# Imprimir el resultado
print("Imagen guardada como 'imagen_resultante.jpeg'")


#for fila in resultado:
#    print(fila)

