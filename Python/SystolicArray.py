"""
Systolic Array represented by PE

PE11 PE12 PE13 PE14 PE15
PE21 PE22 PE23 PE24 PE25
PE31 PE32 PE33 PE34 PE35
PE41 PE42 PE43 PE44 PE45
PE51 PE52 PE53 PE54 PE55

Systolic Array represented by Threads

TH1 TH2 TH3 TH4 TH5
TH6 TH7 TH8 TH9 TH10
TH11 TH12 TH13 TH14 TH15
TH16 TH17 TH18 TH19 TH20
TH21 TH22 TH23 TH24 TH25



This code defines a Systolic Array class that simulates a 5x5 systolic array for matrix multiplication.
For a Gaussian blur operation, it initializes the array with a Gaussian kernel and processes an image with padding.
We use explicitly 25 PEs (Processing Elements) to perform the convolution operation on the image.
We use PE with weight stationary and input data streaming.
We will use a structural approach to implement the systolic array, where each PE will perform a multiplication and accumulate the results.
Then we will sum the results to get the final output.
And will use a ReLU activation function to ensure non-negative outputs.
"""

import numpy as np
import threading
import time
from time import sleep
import sympy as sp
from sympy import symbols, Matrix
from sympy import symbols
from PIL import Image
import numpy as np 
import os


# Cargar imagen JPEG en escala de grises
imagen = Image.open("C:/Users/Daniel/Desktop/Arqui 2 Arreglo Sistolico Desenfoque Gaussiano/Python/imagen.jpeg").convert("L")
# Convertir a array numpy
Imagen = np.array(imagen).tolist()

MATRIZ_SIZE = 5

Imagen_ = [
    [100, 120, 110, 105, 90],
    [115, 130, 125, 110, 95],
    [105, 140, 150, 120, 100],
    [95, 125, 130, 115, 85],
    [80, 110, 105,  90, 70],

]

Imagen_ = [#Es de 20x20
    
    [1 , 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
    [21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40],
    [41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60],
    [61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75 ,76 ,77 ,78 ,79 ,80],
    [81 ,82 ,83 ,84 ,85 ,86 ,87 ,88 ,89 ,90 ,91 ,92 ,93 ,94 ,95 ,96 ,97 ,98 ,99 ,100],
    [101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120],
    [121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140],
    [141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160],
    [161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180],
    [181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200],
    [201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220],
    [221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240],
    [241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260],
    [261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280],
    [281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300],
    [301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320],
    [321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340],
    [341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 360],
    [361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380],
    [381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400]

    
]

Imagen_ = [#Es de 15x15
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
    [16, 17, 18, 19 , 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
    [31,32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45],
    [46,47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60],
    [61,62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75],
    [76,77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90],
    [91,92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105],
    [106,107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120],
    [121,122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135],
    [136,137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150],
    [151,152,153 ,154 ,155 ,156 ,157 ,158 ,159 ,160 ,161 ,162 ,163 ,164 ,165],
    [166 ,167 ,168 ,169 ,170 ,171 ,172 ,173 ,174 ,175 ,176 ,177 ,178 ,179 ,180],
    [181 ,182 ,183 ,184 ,185 ,186 ,187 ,188 ,189 ,190 ,191 ,192 ,193 ,194 ,195],
    [196 ,197 ,198 ,199 ,200 ,201 ,202 ,203 ,204 ,205 ,206 ,207 ,208 ,209 ,210],
    [211,212,213,214,215,216,217,218,219,220,221,222,223,224,225]

]

Imagen = [#Es de 10x10
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    [11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
    [21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
    [31, 32, 33, 34, 35, 36, 37, 38, 39, 40],
    [41, 42, 43, 44, 45, 46, 47, 48, 49, 50],
    [51, 52, 53, 54, 55, 56, 57, 58, 59 ,60],
    [61 ,62 ,63 ,64 ,65 ,66 ,67 ,68 ,69 ,70],
    [71 ,72 ,73 ,74 ,75 ,76 ,77 ,78 ,79 ,80],
    [81 ,82 ,83 ,84 ,85 ,86 ,87 ,88 ,89 ,90],
    [91 ,92 ,93 ,94 ,95 ,96 ,97 ,98 ,99 ,100]]

pesos = [
    [1, 0, 0, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 0, 1, 0, 0],
    [0, 0, 0, 1, 0],
    [0, 0, 0, 0, 1]
]

pesos_prueba = [
    [1, 4, 6, 4, 1],
    [4, 16, 24, 16, 4],
    [6, 24, 36, 24, 6],
    [4, 16, 24, 16, 4],
    [1, 4, 6, 4, 1]
]

div = 1

"""
Imagen = [[2, 4],
          [6, 8]]
#Imagen = []

kernel = [
    [1, 2],
    [2, 4]
]

# Crear una lista de listas de símbolos (5x5)
Imagen = [
    [symbols(f'B{i+1}{j+1}') for j in range(2)]
    for i in range(2)
]

kernel = [
    [symbols(f'A{i+1}{j+1}') for j in range(MATRIZ_SIZE)]
    for i in range(MATRIZ_SIZE)
]

# Mostrar la matriz
for row in Imagen:
    print(row)
    print()

# Mostrar la matriz
for row in kernel:
    print(row)
    print()
"""


# Here we define the PE class, which represents a Processing Element structure in the systolic array.
class PE:
    def __init__(self, PE_name, kernel_value, PE_right=None, PE_left=None, 
                 PE_below=None, PE_above=None):
        self.PE_name = PE_name
        self.kernel_value = kernel_value
        self.above_data = None
        self.adjacent_data = 0
        self.PE_right = PE_right
        self.PE_left = PE_left
        self.PE_above = PE_above
        self.PE_below = PE_below
        self.array_result = []
        self.lock = threading.Lock()
        self.data_available = threading.Condition(self.lock)
        self.ready_for_data = threading.Condition(self.lock)
        self.processing_done = True  # Inicialmente listo para recibir datos

    def above_data_input(self, above_data):
        with self.lock:
            # Esperar hasta que el PE termine de procesar los datos anteriores
            while not self.processing_done:
                self.ready_for_data.wait()
            
            #print(f"{self.PE_name} received data from above: {above_data}")
            self.above_data = above_data
            self.processing_done = False
            self.data_available.notify_all()

    def left_data_input(self, left_data):
        with self.lock:
            self.adjacent_data = left_data

    def process_all_data(self):
        #print(f"{self.PE_name} started processing.")
        while True:
            with self.lock:
                # Esperar hasta que haya datos para procesar
                while self.above_data is None:
                    self.data_available.wait()
                
                if self.above_data == -1:  # Señal de terminación
                    if self.PE_below:
                        self.PE_below.above_data_input(-1)
                    break
                
                #print(f"{self.PE_name} processing data: {self.above_data}")
                
                # Procesamiento de datos
                partial_result = self.above_data * self.kernel_value

                # Pasar datos a los PEs vecinos
                if self.PE_below:
                    self.PE_below.above_data_input(self.above_data)
                
                if self.PE_right:
                    self.PE_right.left_data_input(partial_result + self.adjacent_data)
                else:
                    final_result = (partial_result + self.adjacent_data) // div
                    final_result = max(0, min(final_result, 255))#ReLU
                    self.array_result.insert(0,final_result)

                # Resetear estado para nuevos datos
                self.above_data = None
                self.adjacent_data = 0
                self.processing_done = True
                self.ready_for_data.notify_all()


# Create a 25 PE Objects for the 5x5 systolic array (initializing with None)
PE_objects = [[None for _ in range(MATRIZ_SIZE)] for _ in range(MATRIZ_SIZE)]

threads = [[],[],[],[],[]]
for i in range(MATRIZ_SIZE):
    for j in range(MATRIZ_SIZE):
        # Create a thread for each Processing Element (PE)
        threads[i].append(threading.Thread())
        threads[i][j].name = f"PE{i+1}{j+1}"


# Initialize PE_object with kernel values and their names.
for i in range(MATRIZ_SIZE):
    for j in range(MATRIZ_SIZE):
        # Initialize each PE with its kernel value and a placeholder for new data
        PE_objects[i][j] = PE(f"PE{i+1}{j+1}", pesos[i][j], None, None)
        print(f"Initialized {PE_objects[i][j].PE_name} with kernel value {PE_objects[i][j].kernel_value}")


for i in range(MATRIZ_SIZE):
    for j in range(MATRIZ_SIZE):
        #print(j)
        if j < MATRIZ_SIZE-1:
            PE_objects[i][j].PE_right = PE_objects[i][j+1]  # Set the adjacent PE to the right
        if i < MATRIZ_SIZE-1:
            PE_objects[i][j].PE_below = PE_objects[i+1][j]  # Set the PE below
        if i > 0:
            PE_objects[i][j].PE_above = PE_objects[i-1][j] #Set the PE above
        if j > 0:
            PE_objects[i][j].PE_left = PE_objects[i][j-1] # Set the PE to the left

print("Systolic Array PE Objects:")
for i in range(MATRIZ_SIZE):
    for j in range(MATRIZ_SIZE):
        # Print object names for verification
        print(PE_objects[i][j].PE_name, end=' ')
    print()


print("\nSystolic Array adjacency:")
for i in range(MATRIZ_SIZE):
    for j in range(MATRIZ_SIZE):
        # Print adjacency information for verification
        right = PE_objects[i][j].PE_right.PE_name if PE_objects[i][j].PE_right else "None"
        left = PE_objects[i][j].PE_left.PE_name if PE_objects[i][j].PE_left else "None"
        below = PE_objects[i][j].PE_below.PE_name if PE_objects[i][j].PE_below else "None"
        above = PE_objects[i][j].PE_above.PE_name if PE_objects[i][j].PE_above else "None"
        print(f"{PE_objects[i][j].PE_name} -> Right: {right}, Below: {below}, Above: {above}, Left: {left}")

def start_systolic_Array(Image_input):
    # Start the threads for each PE
    for i in range(MATRIZ_SIZE):
        for j in range(MATRIZ_SIZE):
            threads[i][j] = threading.Thread(target=PE_objects[i][j].process_all_data)
            threads[i][j].start()
            sleep(0.1)  # Small delay to ensure threads start in order

    index = 0
    #print("Image input" , Image_input)
    #print("Image input" , Image_input[0])

    
    # Load Image Padding data into the first row of PEs
    for i in range(len(Image_input)):
        for j in range(len(Image_input[0])):
            print(j)
            #print(f"Sending data to {PE_objects[0][index].PE_name}: {Image_input[i][j]}")
            PE_objects[0][index].above_data_input(Image_input[j][i])
            index += 1
            if index == MATRIZ_SIZE:
                index = 0
            sleep(0.00001)

    #sleep(1)
    # Signal termination to all PEs
    for j in range(MATRIZ_SIZE):
        print(f"Sending termination signal to {PE_objects[0][j].PE_name}")
        PE_objects[0][j].above_data_input(-1)  # Send termination signal to the first row

    # Wait for all threads to finish
    for i in range(MATRIZ_SIZE):
        for j in range(MATRIZ_SIZE):
            threads[i][j].join()
    print("Systolic Array processing completed.")


start_systolic_Array(Imagen)




def order_output(bloques, original_shape):
    altura, ancho = original_shape
    # Unir todos los bloques en un solo vector plano
    flat_output = [valor for bloque in bloques for valor in bloque]
    
    # Verificar que el tamaño coincida
    if len(flat_output) != altura * ancho:
        raise ValueError("El número total de elementos no coincide con la imagen original.")
    
    # Reorganizar en matriz 2D
    salida_2D = [flat_output[i:i+ancho] for i in range(0, len(flat_output), ancho)]

    #Con la salida 2D de tipo matriz creada. Se ajustan los bits si la imagen es más grande que el arreglo

    if (len(salida_2D)<= MATRIZ_SIZE):
        print("No jump pattern needed, returning the result as is.")
        return salida_2D
    
    jump_pattern = len(salida_2D)//MATRIZ_SIZE # Así obtenemos el patrón de salto cuando la matriz de entrada es mayor que 5x5
    print("Jump Pattern:", jump_pattern)
    ordered_result = []

    range_of_loops = int(len(salida_2D[0])/5)
    print("Range of Loops:", range_of_loops)

    for loop_times in range(range_of_loops):
        for i in range(0, len(salida_2D)):
            for j in range(loop_times, len(salida_2D[0]), jump_pattern):
                ordered_result.append(salida_2D[i][j])

        #print("Value of i is" , i)

    print("Ordered Result Length:", len(ordered_result))

    # Convertir la lista ordenada en una matriz 2D con las mismas dimensiones que la imagen original
    ordered_result = [ordered_result[i:i+len(salida_2D[0])] for i in range(0, len(ordered_result), len(salida_2D[0]))]
    print("Ordered Result Shape:", len(ordered_result), "x", len(ordered_result[0]))
    # Asegurarse de que la matriz ordenada tenga el mismo número de filas que la imagen original

    return ordered_result


results = []
for i in range(MATRIZ_SIZE):
    result = PE_objects[i][MATRIZ_SIZE-1].array_result
    results.append(result)  # Asegurar que cada bloque tenga el mismo tamaño

results = [fila[::-1] for fila in results]


ordered_result = order_output(results, (len(Imagen), len(Imagen[0])))
"""print("\nFinal Output Image:")
for row in ordered_result:
    print(row)"""


print("\n Are the matrices equal?")
if ordered_result == Imagen:
    print("Yes, the matrices are equal.")
else:
    print("No, the matrices are not equal.")


final_output_array = np.array(ordered_result, dtype=np.uint8)
# Guardar la imagen resultante como JPEG
final_output_image = Image.fromarray(final_output_array,mode='L')
final_output_image.save("C:/Users/Daniel/Desktop/Arqui 2 Arreglo Sistolico Desenfoque Gaussiano/Python/PruebaResultado.jpeg")
# Imprimir el resultado
print("Imagen guardada como 'PruebaResultado.jpeg'")


input_array = np.array(Imagen, dtype=np.uint8)
# Guardar la imagen resultante como JPEG
input_image = Image.fromarray(input_array,mode='L')
input_image.save("C:/Users/Daniel/Desktop/Arqui 2 Arreglo Sistolico Desenfoque Gaussiano/Python/PruebaEntrada.jpeg")
# Imprimir el resultado
print("Imagen de entrada guardada como 'PruebaEntrada.jpeg'")