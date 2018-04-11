#include <cuda_runtime_api.h> 
#include <iostream> 
#include <stdio.h>


#define BLOCK_SIZE 16
using namespace std; 


typedef struct {
    int width;
    int height;
    int stride; 
    int* elements;
} Matrix;


typedef struct {
    int width;
    int* elements;
} Vector;
 

__device__ float GetElement(const Matrix A, int row, int col)
{
    return A.elements[row * A.stride + col];
}

__device__ void SetElement(Matrix A, int row, int col, float value)
{
    A.elements[row * A.stride + col] = value;
}



void print_matrix(const Matrix A) {
	int i;
	int size = A.width * A.height;
    cout<<"size A "<<size<<endl;
    cout<<"    MATRIX    \n";
	for(i = 1; i <= size; i++) {
		cout<<A.elements[i-1]<<" ";
		if(i % 10 == 0) {
			cout<<"\n";
		}
	}	
}


__global__ void macierz_wektor_10_kernel(const Matrix, const Vector, Vector);
void macierz_wektor_10()
{
    //create Matrix and Vector on Host (CPU)
    Matrix A;
    Vector B;
    Vector C;
    
    A.width = A.height = A.stride = 10;
    size_t size_A = A.width * A.height * sizeof(int);
    A.elements = (int*) malloc(size_A);

    B.width = 10;
    size_t size_B = B.width * sizeof(int);
    B.elements = (int*) malloc(size_B);

    C.width = 10;
    size_t size_C = C.width * sizeof(int);
    C.elements = (int*) malloc(size_C);

    int i;
    for(i = 0; i < A.width*A.height; i++) {
        A.elements[i] = (i % 10) + 1;
    }
	
    print_matrix(A);    

    for(i = 0; i < B.width; i++) {
        B.elements[i] = (i % 10) + 1;
    }    

    //Load A and B to device memory
    Matrix d_A;
    d_A.width = d_A.stride = A.width; d_A.height = A.height;
    cudaMalloc(&d_A.elements, size_A);
    cudaMemcpy(d_A.elements, A.elements, size_A, cudaMemcpyHostToDevice);

    Vector d_B;
    d_B.width = B.width;
    cudaMalloc(&d_B.elements, size_B);
    cudaMemcpy(d_B.elements, B.elements, size_B, cudaMemcpyHostToDevice);

    Vector d_C;
    d_C.width = C.width;
    cudaMalloc(&d_C.elements, size_C);

    
    dim3 dimBlock(10, 1);
    dim3 dimGrid(1);
    macierz_wektor_10_kernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C);

    cudaMemcpy(C.elements, d_C.elements, size_C, cudaMemcpyDeviceToHost);
    for(i = 0; i < C.width; i++) {
        cout<<C.elements[i]<<" ";
    }
    cout<<endl;    
}


__global__ void macierz_wektor_10_kernel(const Matrix A, const Vector B, Vector C) {
    int col = threadIdx.x;
    printf("thread_id_x %d", threadIdx.x);
    int vec_val = B.elements[col];
    int mul = 0;
    int row;
    for(row = 0; row < A.height; row++) {
        mul += vec_val * A.elements[row*A.width + col];
    }
    C.elements[col] = mul;
    __syncthreads();
}




int main()
{ 
    macierz_wektor_10();    

    return 0;
}

