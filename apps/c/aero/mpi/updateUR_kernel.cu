//
// auto-generated by op2.m on 18-Apr-2012 14:58:50
//

// user function

__device__
#include "updateUR.h"


// CUDA kernel function

__global__ void op_cuda_updateUR(
  double *arg0,
  double *arg1,
  double *arg2,
  double *arg3,
  const double *arg4,
  int   offset_s,
  int   set_size ) {


  // process set elements

  for (int n=threadIdx.x+blockIdx.x*blockDim.x;
       n<set_size; n+=blockDim.x*gridDim.x) {

    // user-supplied kernel call


    updateUR(  arg0+n,
               arg1+n,
               arg2+n,
               arg3+n,
               arg4 );
  }
}


// host stub function

void op_par_loop_updateUR(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3,
  op_arg arg4 ){

  double *arg4h = (double *)arg4.data;

  int    nargs   = 5;
  op_arg args[5] = {arg0,arg1,arg2,arg3,arg4};

  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  updateUR \n");
  }

  op_mpi_halo_exchanges(set, nargs, args);

  // initialise timers

  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timers_core(&cpu_t1, &wall_t1);

  if (set->size >0) {


    // transfer constants to GPU

    int consts_bytes = 0;
    consts_bytes += ROUND_UP(1*sizeof(double));

    reallocConstArrays(consts_bytes);

    consts_bytes = 0;
    arg4.data   = OP_consts_h + consts_bytes;
    arg4.data_d = OP_consts_d + consts_bytes;
    for (int d=0; d<1; d++) ((double *)arg4.data)[d] = arg4h[d];
    consts_bytes += ROUND_UP(1*sizeof(double));

    mvConstArraysToDevice(consts_bytes);

    // set CUDA execution parameters

    #ifdef OP_BLOCK_SIZE_5
      int nthread = OP_BLOCK_SIZE_5;
    #else
      // int nthread = OP_block_size;
      int nthread = 128;
    #endif

    int nblocks = 200;

    // work out shared memory requirements per element

    int nshared = 0;

    // execute plan

    int offset_s = nshared*OP_WARPSIZE;

    nshared = nshared*nthread;

    op_cuda_updateUR<<<nblocks,nthread,nshared>>>( (double *) arg0.data_d,
                                                   (double *) arg1.data_d,
                                                   (double *) arg2.data_d,
                                                   (double *) arg3.data_d,
                                                   (double *) arg4.data_d,
                                                   offset_s,
                                                   set->size );

    cutilSafeCall(cudaThreadSynchronize());
    cutilCheckMsg("op_cuda_updateUR execution failed\n");

  }


  op_mpi_set_dirtybit(nargs, args);

  // update kernel record

  op_timers_core(&cpu_t2, &wall_t2);
  op_timing_realloc(5);
  OP_kernels[5].name      = name;
  OP_kernels[5].count    += 1;
  OP_kernels[5].time     += wall_t2 - wall_t1;
  OP_kernels[5].transfer += (float)set->size * arg0.size * 2.0f;
  OP_kernels[5].transfer += (float)set->size * arg1.size * 2.0f;
  OP_kernels[5].transfer += (float)set->size * arg2.size;
  OP_kernels[5].transfer += (float)set->size * arg3.size * 2.0f;
}

