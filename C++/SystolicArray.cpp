#include <iostream>
#include <vector>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <algorithm>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>

using namespace std;

int MATRIZ_SIZE = 4;
int STEPPING = 0;

int kernel[4][4]={
    {2, 0, 0, 0},
    {0, 2, 0, 0},
    {0, 0, 2, 0},
    {0, 0, 0, 2}
};


class PE{

    public:
        std::string PE_name;
        int kernel_value;
        int above_data = -2; //No data yet
        int adjacent_data = 0;
        PE* PE_right = nullptr;
        PE* PE_left = nullptr;
        PE* PE_above = nullptr;
        PE* PE_below = nullptr;
        std::vector<int> array_result;

        PE(std::string name, int kernel_val, PE* right = nullptr, PE* left = nullptr, PE* below = nullptr, PE* above = nullptr) : 
        PE_name(name),
        kernel_value(kernel_val),
        PE_right(right),
        PE_left(left),
        PE_below(below),
        PE_above(above){}


        void above_data_input(int data){
            std::unique_lock<std::mutex> lock(mtx);
            while(!processing_done){
                ready_for_data.wait(lock);
            }
            above_data = data;
            processing_done = false;
            data_available.notify_all();
        }

        void left_data_input(int data) {
            std::unique_lock<std::mutex> lock(mtx);
            adjacent_data = data;
        }

        void process_all_data(){
            while (true)
            {
                std::unique_lock<std::mutex> lock(mtx);
                while(above_data == -2){
                    data_available.wait(lock);
                }

                if(above_data == -1){ //Termination signal
                    if (PE_below){
                        PE_below->above_data_input(-1);
                    }
                    break;
                }
                int partial_result = above_data * kernel_value;

                if(PE_below){
                    PE_below->above_data_input(above_data);
                }
                if(PE_right){
                    PE_right->left_data_input(partial_result + adjacent_data);
                }
                else { //If there are no PEs on the right we are the last PE of the array. So we calculate the final result
                    int final_result = (partial_result + adjacent_data);
                    final_result = std::max(0, std::min(final_result, 255)); // We compare the pixel in case its bigger than 255 ReLU.
                    array_result.insert(array_result.begin(),final_result);
                }

                above_data = -2; //Reset to wait status
                adjacent_data = 0;
                processing_done = true;
                ready_for_data.notify_all();

            }
            
        }



    private:
        std::mutex mtx;
        std::condition_variable data_available;
        std::condition_variable ready_for_data;
        bool processing_done = true;

};

template <size_t FILAS, size_t COLS>
std::vector<std::vector<int>> convertirAMatrizVector(int (&matriz)[FILAS][COLS]) {
    cout << FILAS << " COLS: " <<COLS << endl;

    std::vector<std::vector<int>> resultado;
    for (size_t i = 0; i < FILAS; ++i) {
        std::vector<int> fila;
        for (size_t j = 0; j < COLS; ++j) {
            fila.push_back(matriz[i][j]);
        }
        resultado.push_back(fila);
    }
    return resultado;
}


void start_systolic_Array(
    const std::vector<std::vector<int>>& Image_input,
    std::vector<std::vector<PE*>>& PE_objects,
    std::vector<std::vector<std::thread>>& threads) 
    {
    
        cout << "Entrando"<<endl;

        // Iniciar los hilos de cada PE
        for (int i = 0; i < MATRIZ_SIZE; ++i) {
            for (int j = 0; j < MATRIZ_SIZE; ++j) {
                //std::cout << "Creando hilo PE[" << i << "][" << j << "]" << std::endl;
                threads[i][j] = std::thread(&PE::process_all_data, PE_objects[i][j]);
                //std::cout << "Hilo creado PE[" << i << "][" << j << "]" << std::endl;
                std::this_thread::sleep_for(std::chrono::milliseconds(100)); // sleep(0.1)
            }
        }

        int index = 0;
        cout << "Paso por acá"<<endl;

        cout << "MIS DIMENSIONES SON" << to_string(Image_input.size()) << "X" <<  to_string(Image_input[0].size());
        // Cargar datos de imagen en la primera fila de PEs
        for (int i = 0; i < Image_input.size(); ++i) {
            for (int j = 0; j < Image_input[0].size(); ++j) {
                // En Python: PE_objects[0][index].above_data_input(Image_input[j][i])
                // Nota: aquí se invierte j <-> i por cómo accede Python en la transpuesta
                cout << j << ", ";
                PE_objects[0][index]->above_data_input(Image_input[j][i]);
                index++;
                if(STEPPING){
                    std::cout <<endl<< "Enviando Dato: " << Image_input[j][i] << endl;
                    std::cout << "Registros de Estado: " << endl;
                    for(int x = 0; x<MATRIZ_SIZE; x++){
                        for(int y = 0; y<MATRIZ_SIZE; y++){
                            std::cout << PE_objects[x][y]->PE_name << " ---> "
                            << "Kernel: " << PE_objects[x][y]->kernel_value
                            << "    Above Data: " << PE_objects[x][y]->above_data
                            << "    Adjacent Data: " << PE_objects[x][y]->adjacent_data << "\n \n";
                        }
                    }
                    std::cout << "Presiona Enter para continuar...";
                    std::cin.get();  // Espera hasta que el usuario presione Enter
                }
                if (index == MATRIZ_SIZE)
                    index = 0;

                std::this_thread::sleep_for(std::chrono::microseconds(10)); // sleep(0.00001)
            }
        }

        // Enviar señal de finalización a los PEs de la primera fila
        for (int j = 0; j < MATRIZ_SIZE; ++j) {
            //std::cout << "Sending termination signal to " << PE_objects[0][j]->PE_name << std::endl;
            PE_objects[0][j]->above_data_input(-1);
        }

        // Esperar que todos los hilos terminen
        for (int i = 0; i < MATRIZ_SIZE; ++i) {
            for (int j = 0; j < MATRIZ_SIZE; ++j) {
                //cout << "here" <<endl;
                if (threads[i][j].joinable())
                    threads[i][j].join();
            }
        }

        std::cout << "Systolic Array processing completed." << std::endl;
}

std::vector<std::vector<int>> order_output(
    const std::vector<std::vector<int>>& bloques,
    std::pair<int, int> original_shape,
    int MATRIZ_SIZE
) {
    int altura = original_shape.first;
    int ancho = original_shape.second;

    // Unir todos los bloques en un vector plano
    std::vector<int> flat_output;
    for (const auto& bloque : bloques) {
        flat_output.insert(flat_output.end(), bloque.begin(), bloque.end());
    }

    // Verificar que el tamaño coincida
    if (flat_output.size() != altura * ancho) {
        throw std::runtime_error("El número total de elementos no coincide con la imagen original.");
    }

    // Reorganizar en matriz 2D
    std::vector<std::vector<int>> salida_2D;
    for (int i = 0; i < altura; ++i) {
        std::vector<int> fila(flat_output.begin() + i * ancho, flat_output.begin() + (i + 1) * ancho);
        salida_2D.push_back(fila);
    }

    // Si no se requiere "jump pattern"
    if (salida_2D.size() <= MATRIZ_SIZE) {
        std::cout << "No jump pattern needed, returning the result as is.\n";
        return salida_2D;
    }

    int jump_pattern = salida_2D.size() / MATRIZ_SIZE;
    std::cout << "Jump Pattern: " << jump_pattern << std::endl;

    int range_of_loops = salida_2D[0].size() / MATRIZ_SIZE;
    std::cout << "Range of Loops: " << range_of_loops << std::endl;

    std::vector<int> ordered_result;

    for (int loop_times = 0; loop_times < range_of_loops; ++loop_times) {
        for (int i = 0; i < salida_2D.size(); ++i) {
            for (int j = loop_times; j < salida_2D[0].size(); j += jump_pattern) {
                ordered_result.push_back(salida_2D[i][j]);
            }
        }
    }

    std::cout << "Ordered Result Length: " << ordered_result.size() << std::endl;

    // Reconstruir como matriz 2D
    std::vector<std::vector<int>> final_result;
    for (size_t i = 0; i < ordered_result.size(); i += ancho) {
        std::vector<int> fila(ordered_result.begin() + i, ordered_result.begin() + std::min(i + ancho, ordered_result.size()));
        final_result.push_back(fila);
    }

    std::cout << "Ordered Result Shape: " << final_result.size() << " x " << final_result[0].size() << std::endl;

    return final_result;
}

void print_matrix(const std::vector<std::vector<int>>& matrix) {
    for (const auto& row : matrix) {
        for (const auto& val : row) {
            std::cout << val << " ";
        }
        std::cout << std::endl;
    }
}


void save_matrix_to_txt(const std::vector<std::vector<int>>& matrix, const std::string& filename){
    std::ofstream outfile(filename);

    if (!outfile.is_open()) {
        std::cerr << "Error al abrir el archivo para escribir.\n";
        return;
    }

    for (const auto& row : matrix) {
        for (size_t i = 0; i < row.size(); ++i) {
            outfile << row[i];
            if (i < row.size() - 1) {
                outfile << " ";
            }
        }
        outfile << "\n";
    }

    outfile.close();
}


std::vector<std::vector<int>> load_image_from_txt(const std::string& filepath) {
    std::vector<std::vector<int>> matrix;
    std::ifstream infile(filepath);
    
    if (!infile.is_open()) {
        std::cerr << "No se pudo abrir el archivo: " << filepath << std::endl;
        return matrix;
    }

    std::string line;
    while (std::getline(infile, line)) {
        std::stringstream ss(line);
        std::vector<int> row;
        int value;
        while (ss >> value) {
            row.push_back(value);
        }
        if (!row.empty()) {
            matrix.push_back(row);
        }
    }

    infile.close();
    return matrix;
}


int main(){
    std::cout << "Inciar programa";
    //std::cout << "Presiona Enter para continuar...";
    //std::cin.get();  // Espera hasta que el usuario presione Enter
    //Create pointer matrix to PE
    std::vector<std::vector<PE*>> PE_objects(MATRIZ_SIZE, std::vector<PE*>(MATRIZ_SIZE, nullptr));
    std::vector<std::vector<std::thread>> threads(MATRIZ_SIZE);
    for (int i = 0; i < MATRIZ_SIZE; ++i) {
        threads[i].resize(MATRIZ_SIZE);  // Esto no llama constructores porque .resize() sí lo permite con tipo no constructible por defecto
    }



    //Init each PE
    for(int i = 0; i < MATRIZ_SIZE; ++i){
        for(int j = 0; j<MATRIZ_SIZE; ++j){
            
            std::string name = "PE" + std::to_string(i+1) + std::to_string(j+1);
            PE_objects[i][j] = new PE(name, kernel[i][j]);
            std::cout << "Initialized " << PE_objects[i][j]->PE_name
                      << " with kernel value " << PE_objects[i][j]->kernel_value << std::endl;
        }
    }
    // PE connections
    for(int i = 0; i < MATRIZ_SIZE; ++i){
        for(int j = 0; j < MATRIZ_SIZE; ++j){
            if(j < MATRIZ_SIZE -1)
                PE_objects[i][j]->PE_right = PE_objects[i][j+1];
            if(j > 0)
                PE_objects[i][j]->PE_left = PE_objects[i][j-1];
            if(i < MATRIZ_SIZE - 1)
                PE_objects[i][j]->PE_below = PE_objects[i + 1][j];
            if(i > 0)
                PE_objects[i][j]->PE_above = PE_objects[i-1][j];
        }
    }



    // Verificación visual
    std::cout << "Systolic Array PE Objects:\n";
    for (int i = 0; i < MATRIZ_SIZE; ++i) {
        for (int j = 0; j < MATRIZ_SIZE; ++j) {
            std::cout << PE_objects[i][j]->PE_name << " ";
        }
        std::cout << std::endl;
    }


    std::cout << "\nSystolic Array adjacency:\n";
    for (int i = 0; i < MATRIZ_SIZE; ++i) {
        for (int j = 0; j < MATRIZ_SIZE; ++j) {
            auto pe = PE_objects[i][j];
            std::string right = pe->PE_right ? pe->PE_right->PE_name : "None";
            std::string left = pe->PE_left ? pe->PE_left->PE_name : "None";
            std::string above = pe->PE_above ? pe->PE_above->PE_name : "None";
            std::string below = pe->PE_below ? pe->PE_below->PE_name : "None";
            std::cout << pe->PE_name << " -> Right: " << right
                      << ", Below: " << below
                      << ", Above: " << above
                      << ", Left: " << left << std::endl;
        }
    }

    std::vector<std::vector<int>> Image_input = load_image_from_txt("prueba8x8.txt");

 
   
    start_systolic_Array(Image_input, PE_objects, threads);

    std::vector<std::vector<int>> results;

    for (int i = 0; i < MATRIZ_SIZE; ++i) {
        std::vector<int> result = PE_objects[i][MATRIZ_SIZE - 1]->array_result;
        
        // Invertir la fila
        std::reverse(result.begin(), result.end());
        
        results.push_back(result);
    }

    
    auto ordered_result = order_output(results, {Image_input.size(), Image_input[0].size()}, MATRIZ_SIZE);


    save_matrix_to_txt(ordered_result, "ordered_result.txt");

    cout << "Operations Completed" << endl;

    return 0;
}