//
// auto-generated by op2.py
//

//user function
__device__ void dotPV_gpu( const double *p, const double *v, double *c) { *c += (*p) * (*v); }

// CUDA kernel function
__global__ void op_cuda_dotPV(
  const double *__restrict arg0,
  const double *__restrict arg1,
  double *arg2,
  int   set_size ) {

  double arg2_l[1];
  for ( int d=0; d<1; d++ ){
    arg2_l[d]=ZERO_double;
  }

  //process set elements
  for ( int n=threadIdx.x+blockIdx.x*blockDim.x; n<set_size; n+=blockDim.x*gridDim.x ){

    //user-supplied kernel call
    dotPV_gpu(arg0+n*1,
          arg1+n*1,
          arg2_l);
  }

  //global reductions

  for ( int d=0; d<1; d++ ){
    op_reduction<OP_INC>(&arg2[d+blockIdx.x*1],arg2_l[d]);
  }
}


//host stub function
void op_par_loop_dotPV(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2){

  double*arg2h = (double *)arg2.data;
  int nargs = 3;
  op_arg args[3];

  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;

  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timing_realloc(4);
  op_timers_core(&cpu_t1, &wall_t1);
  OP_kernels[4].name      = name;
  OP_kernels[4].count    += 1;


  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  dotPV");
  }

  op_mpi_halo_exchanges_cuda(set, nargs, args);
  if (set->size > 0) {

    //set CUDA execution parameters
    #ifdef OP_BLOCK_SIZE_4
      int nthread = OP_BLOCK_SIZE_4;
    #else
      int nthread = OP_block_size;
    //  int nthread = 128;
    #endif

    int nblocks = 200;

    //transfer global reduction data to GPU
    int maxblocks = nblocks;
    int reduct_bytes = 0;
    int reduct_size  = 0;
    reduct_bytes += ROUND_UP(maxblocks*1*sizeof(double));
    reduct_size   = MAX(reduct_size,sizeof(double));
    reallocReductArrays(reduct_bytes);
    reduct_bytes = 0;
    arg2.data   = OP_reduct_h + reduct_bytes;
    arg2.data_d = OP_reduct_d + reduct_bytes;
    for ( int b=0; b<maxblocks; b++ ){
      for ( int d=0; d<1; d++ ){
        ((double *)arg2.data)[d+b*1] = ZERO_double;
      }
    }
    reduct_bytes += ROUND_UP(maxblocks*1*sizeof(double));
    mvReductArraysToDevice(reduct_bytes);

    int nshared = reduct_size*nthread;
    op_cuda_dotPV<<<nblocks,nthread,nshared>>>(
      (double *) arg0.data_d,
      (double *) arg1.data_d,
      (double *) arg2.data_d,
      set->size );
    //transfer global reduction data back to CPU
    mvReductArraysToHost(reduct_bytes);
    for ( int b=0; b<maxblocks; b++ ){
      for ( int d=0; d<1; d++ ){
        arg2h[d] = arg2h[d] + ((double *)arg2.data)[d+b*1];
      }
    }
    arg2.data = (char *)arg2h;
    op_mpi_reduce(&arg2,arg2h);
  }
  op_mpi_set_dirtybit_cuda(nargs, args);
  cutilSafeCall(cudaDeviceSynchronize());
  //update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[4].time     += wall_t2 - wall_t1;
  OP_kernels[4].transfer += (float)set->size * arg0.size;
  OP_kernels[4].transfer += (float)set->size * arg1.size;
}
