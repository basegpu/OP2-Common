//
// auto-generated by op2.py
//

#include <dlfcn.h> // need to inclde in backend somewhere
//user function
#include "../res_calc.h"

int recompile = 1;
void (*function)(struct op_kernel_descriptor *desc) = NULL;

// host stub function
void op_par_loop_res_calc_execute(op_kernel_descriptor *desc) {

  op_set set = desc->set;
  char const *name = desc->name;
  int nargs = 8;

  op_arg arg0 = desc->args[0];
  op_arg arg1 = desc->args[1];
  op_arg arg2 = desc->args[2];
  op_arg arg3 = desc->args[3];
  op_arg arg4 = desc->args[4];
  op_arg arg5 = desc->args[5];
  op_arg arg6 = desc->args[6];
  op_arg arg7 = desc->args[7];

  op_arg args[8] = {arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7};

  // Compiling to Do JIT
  if (recompile) {
    if (function == NULL) {
      op_printf("JIT Compiling Kernel %s\n", name);
      void *handle;
      char *error;
      char *compstr =
          "/opt/compilers/intel/intelPS-2015/impi_latest/intel64//bin/mpicxx \
      -xAVX -DMPICH_IGNORE_CXX_SEEK -restrict -fno-alias -inline-forceinline -qopt-report=5 -parallel -DVECTORIZE \
      -I/home/mgiles/mudalige/OP2-GIT/OP2-Common/op2//c/include \
      -I/home/mgiles/mudalige/hdf5-1.8.19-intel/include \
      -I/opt/parmetis-intel//include -DHAVE_PARMETIS -DPARMETIS_VER_4 \
      -I/opt/ptscotch-intel//include -DHAVE_PTSCOTCH \
      -Iseq \
      -I. \
      -c seq/res_calc_seqkernel_rec.cpp -o seq/res_calc_seqkernel_rec.o -fPIC";
      char buf[500];
      // compute locally allocated range for the sub-block

      sprintf(buf, "%s", compstr);
      int ret = system(buf); // execute compilation with a system call

      // create .so from .o that was just created
      ret = system(
          "/opt/compilers/intel/intelPS-2015/impi_latest/intel64//bin/mpicxx \
      seq/res_calc_seqkernel_rec.o \
      -shared -o \
      seq/res_calc_seqkernel_rec.so");

      // load .so that was created
      handle = dlopen("seq/res_calc_seqkernel_rec.so", RTLD_LAZY);
      if (!handle) {
        fputs(dlerror(), stderr);
        exit(1);
      }

      function = (void (*)(ops_kernel_descriptor *))dlsym(
          handle, "op_par_loop_res_calc_rec_execute");
      if ((error = dlerror()) != NULL) {
        fputs(error, stderr);
        exit(1);
      }
    }
    (*function)(desc);
    return;
  }

  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timing_realloc(2);
  op_timers_core(&cpu_t1, &wall_t1);

  if (OP_diags>2) {
    printf(" kernel routine with indirection: res_calc\n");
  }

  int set_size = op_mpi_halo_exchanges(set, nargs, args);

  if (set->size >0) {

    for ( int n=0; n<set_size; n++ ){
      if (n==set->core_size) {
        op_mpi_wait_all(nargs, args);
      }
      int map0idx = arg0.map_data[n * arg0.map->dim + 0];
      int map1idx = arg0.map_data[n * arg0.map->dim + 1];
      int map2idx = arg2.map_data[n * arg2.map->dim + 0];
      int map3idx = arg2.map_data[n * arg2.map->dim + 1];


      res_calc(
        &((double*)arg0.data)[2 * map0idx],
        &((double*)arg0.data)[2 * map1idx],
        &((double*)arg2.data)[4 * map2idx],
        &((double*)arg2.data)[4 * map3idx],
        &((double*)arg4.data)[1 * map2idx],
        &((double*)arg4.data)[1 * map3idx],
        &((double*)arg6.data)[4 * map2idx],
        &((double*)arg6.data)[4 * map3idx]);
    }
  }

  if (set_size == 0 || set_size == set->core_size) {
    op_mpi_wait_all(nargs, args);
  }
  // combine reduction data
  op_mpi_set_dirtybit(nargs, args);

  // update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[2].name      = name;
  OP_kernels[2].count    += 1;
  OP_kernels[2].time     += wall_t2 - wall_t1;
  OP_kernels[2].transfer += (float)set->size * arg0.size;
  OP_kernels[2].transfer += (float)set->size * arg2.size;
  OP_kernels[2].transfer += (float)set->size * arg4.size;
  OP_kernels[2].transfer += (float)set->size * arg6.size * 2.0f;
  OP_kernels[2].transfer += (float)set->size * arg0.map->dim * 4.0f;
  OP_kernels[2].transfer += (float)set->size * arg2.map->dim * 4.0f;
}

void op_par_loop_res_calc(char const *name, op_set set, op_arg arg0,
                          op_arg arg1, op_arg arg2, op_arg arg3, op_arg arg4,
                          op_arg arg5, op_arg arg6, op_arg arg7) {

  op_kernel_descriptor *desc =
      (op_kernel_descriptor *)malloc(sizeof(op_kernel_descriptor));
  desc->name = name;
  desc->set = set;
  desc->device = 1;
  desc->index = 2;
  desc->hash = 5381;
  desc->hash = ((desc->hash << 5) + desc->hash) + 6;

  // save the iteration range

  // save the arguments
  desc->nargs = 8;
  desc->args = (op_arg *)malloc(8 * sizeof(op_arg));
  desc->args[0] = arg0;
  desc->hash = ((desc->hash << 5) + desc->hash) + arg0.dat->index;
  desc->args[1] = arg1;
  desc->hash = ((desc->hash << 5) + desc->hash) + arg1.dat->index;
  desc->args[2] = arg2;
  desc->hash = ((desc->hash << 5) + desc->hash) + arg2.dat->index;
  desc->args[3] = arg3;
  desc->hash = ((desc->hash << 5) + desc->hash) + arg3.dat->index;
  desc->args[4] = arg4;
  desc->hash = ((desc->hash << 5) + desc->hash) + arg4.dat->index;
  desc->args[5] = arg5;
  desc->hash = ((desc->hash << 5) + desc->hash) + arg5.dat->index;
  desc->args[6] = arg6;
  desc->hash = ((desc->hash << 5) + desc->hash) + arg6.dat->index;
  desc->args[7] = arg7;
  desc->hash = ((desc->hash << 5) + desc->hash) + arg7.dat->index;
  desc->function = op_par_loop_res_calc_execute;

  // if (OP_diags > 1) {
  //  op_timing_realloc(6, "res_calc_kernel");
  //}

  op_enqueue_kernel(desc);
}