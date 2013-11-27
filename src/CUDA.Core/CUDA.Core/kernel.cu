
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void changeTable(int *input, int *output, size_t pitch)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	
	output[i,j] = blockIdx.x;

}

int main()
{
	//allocation of matrix
	dim3 sizeOfDim(10,10);

	int *h_array;	
	int *d_array;
	int *output_array;

	size_t size = sizeOfDim.x * sizeOfDim.y * sizeof(int);

	size_t pitch;

	//allocation memory to host array
	h_array = (int*)malloc(size);

	for (int i = 0; i < sizeOfDim.x; i++)
	{
		for(int j = 0; j < sizeOfDim.y; j++)
		{
			h_array[i,j] = i+j;
		}
	}
	
	//allocation device array
	/*cudaMalloc(&d_array,size);
	cudaMalloc(&output_array, size);*/
	cudaMallocPitch(&d_array,&pitch, sizeOfDim.x * sizeof(int), sizeOfDim.y);
	cudaMallocPitch(&output_array, &pitch, sizeOfDim.x * sizeof(int), sizeOfDim.y);

		
	//copy data from host array to device array
	//cudaMemcpy(d_array, h_array, size, cudaMemcpyHostToDevice);
	cudaMemcpy2D(d_array,pitch,h_array,sizeOfDim.x * sizeof(int),sizeOfDim.x * sizeof(int),sizeOfDim.y,cudaMemcpyHostToDevice);


	//initialize block and threads
	dim3 threadsPerBlock(1,1);
	dim3 numberOfBlock(sizeOfDim.x / threadsPerBlock.x, sizeOfDim.y / threadsPerBlock.y);

	//do some cuda things
	changeTable<<<numberOfBlock,threadsPerBlock>>>(d_array, output_array, pitch);

	//copy result data from device to host
	//cudaMemcpy(h_array, output_array, size, cudaMemcpyDeviceToHost);
	cudaMemcpy2D(h_array, sizeOfDim.x * sizeof(int), output_array, pitch, sizeOfDim.x * sizeof(int), sizeOfDim.y, cudaMemcpyDeviceToHost);

	printf("Changed array \n");

	for (int i = 0; i < sizeOfDim.x; i++)
	{
		for (int j = 0; j < sizeOfDim.y; j++)
		{
			printf("%d \n",h_array[i,j]); 	

		}
		
	}	

	/*cudaFree(d_array);
	cudaFree(output_array);
	free(h_array);*/

	getchar();

}

