#include <stdio.h>
#include <stdlib.h>

#define NUM_ELEMENTS 16
#define BLOCK_SIZE 16

__device__ void swap(int *a, int *b) {
	int temp = *a;
	*a = *b;
	*b = temp;
}

// TODO 2: define parameters
__global__ void oddEvenTranspositionSort(int *data, const size_t n) {
	int tid = blockIdx.x * blockDim.x + threadIdx.x;

	for (int i = 0; i < n; i++) {
		if ((i & 1) == 0) {  // Even phase
			// TODO 2: Compare and swap elements if thread id is even
			if ((tid & 1) == 0 && tid < (n - 1))
			{
				if (data[tid] > data[tid + 1])
				{
					swap(&data[tid], &data[tid + 1]);
				}
			}
		} else {           // Odd phase
			// TODO 3: Compare and swap elements if thread id is odd
			if ((tid & 1) == 1 && tid < (n - 1))
			{
				if (data[tid] > data[tid + 1])
				{
					swap(&data[tid], &data[tid + 1]);
				}
			}
		}
		// TODO 4: Sync threads
		__syncthreads();
	}
}

void generateData(int *data, int size) {
	srand(time(0));

	for (int i = 0; i < size; i++) {
		data[i] = rand() % 14 + 1;
	}
}

int main() {
	int *array = NULL;
	array = (int *)malloc(NUM_ELEMENTS * sizeof(int));
	generateData(array, NUM_ELEMENTS);

	printf("Original Array: ");
	for (int i = 0; i < NUM_ELEMENTS; i++) {
		printf("%d ", array[i]);
	}
	printf("\n");

	int *d_array;
	// TODO 0: Allocate device array and copy host elements to it
	cudaMalloc(&d_array, NUM_ELEMENTS * sizeof(int));
	cudaMemcpy(d_array, array, NUM_ELEMENTS * sizeof(int),
				cudaMemcpyHostToDevice);

	// TODO 1: Calculate blocks_no and block_size
	int blocks_no = NUM_ELEMENTS / BLOCK_SIZE;
	oddEvenTranspositionSort<<<blocks_no, BLOCK_SIZE>>>(d_array, NUM_ELEMENTS);
	cudaDeviceSynchronize();

	cudaMemcpy(array, d_array, NUM_ELEMENTS * sizeof(int),
				cudaMemcpyDeviceToHost);
	cudaFree(d_array);

	printf("Sorted Array: ");
	for (int i = 0; i < NUM_ELEMENTS; i++) {
		printf("%d ", array[i]);
	}
	printf("\n");

	free(array);
	return 0;
}
