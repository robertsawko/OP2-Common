//
// auto-generated by op2.m on 19-May-2012 18:46:35
//

// user function

__device__
#include "spMV.h"


// CUDA kernel function

__global__ void op_cuda_spMV(
  double *ind_arg0,
  double *ind_arg1,
  int   *ind_map,
  short *arg_map,
  double *arg4,
  int   *ind_arg_sizes,
  int   *ind_arg_offs,
  int    block_offset,
  int   *blkmap,
  int   *offset,
  int   *nelems,
  int   *ncolors,
  int   *colors,
  int   nblocks,
  int   set_size) {

  double arg0_l[1];
  double arg1_l[1];
  double arg2_l[1];
  double arg3_l[1];
  double *arg0_vec[4] = {
    arg0_l,
    arg1_l,
    arg2_l,
    arg3_l
  };
  double *arg1_vec[4];

  __shared__ int   *ind_arg0_map, ind_arg0_size;
  __shared__ int   *ind_arg1_map, ind_arg1_size;
  __shared__ double *ind_arg0_s;
  __shared__ double *ind_arg1_s;
  __shared__ int    nelems2, ncolor;
  __shared__ int    nelem, offset_b;

  extern __shared__ char shared[];

  if (blockIdx.x+blockIdx.y*gridDim.x >= nblocks) return;
  if (threadIdx.x==0) {

    // get sizes and shift pointers and direct-mapped data

    int blockId = blkmap[blockIdx.x + blockIdx.y*gridDim.x  + block_offset];

    nelem    = nelems[blockId];
    offset_b = offset[blockId];

    nelems2  = blockDim.x*(1+(nelem-1)/blockDim.x);
    ncolor   = ncolors[blockId];

    ind_arg0_size = ind_arg_sizes[0+blockId*2];
    ind_arg1_size = ind_arg_sizes[1+blockId*2];

    ind_arg0_map = &ind_map[0*set_size] + ind_arg_offs[0+blockId*2];
    ind_arg1_map = &ind_map[4*set_size] + ind_arg_offs[1+blockId*2];

    // set shared memory pointers

    int nbytes = 0;
    ind_arg0_s = (double *) &shared[nbytes];
    nbytes    += ROUND_UP(ind_arg0_size*sizeof(double)*1);
    ind_arg1_s = (double *) &shared[nbytes];
  }

  __syncthreads(); // make sure all of above completed

  // copy indirect datasets into shared memory or zero increment

  for (int n=threadIdx.x; n<ind_arg0_size*1; n+=blockDim.x)
    ind_arg0_s[n] = ZERO_double;

  for (int n=threadIdx.x; n<ind_arg1_size*1; n+=blockDim.x)
    ind_arg1_s[n] = ind_arg1[n%1+ind_arg1_map[n/1]*1];

  __syncthreads();

  // process set elements

  for (int n=threadIdx.x; n<nelems2; n+=blockDim.x) {
    int col2 = -1;

    if (n<nelem) {

      // initialise local variables

      for (int d=0; d<1; d++)
        arg0_l[d] = ZERO_double;
      for (int d=0; d<1; d++)
        arg1_l[d] = ZERO_double;
      for (int d=0; d<1; d++)
        arg2_l[d] = ZERO_double;
      for (int d=0; d<1; d++)
        arg3_l[d] = ZERO_double;

      arg1_vec[0] = ind_arg1_s+arg_map[4*set_size+n+offset_b]*1;
      arg1_vec[1] = ind_arg1_s+arg_map[5*set_size+n+offset_b]*1;
      arg1_vec[2] = ind_arg1_s+arg_map[6*set_size+n+offset_b]*1;
      arg1_vec[3] = ind_arg1_s+arg_map[7*set_size+n+offset_b]*1;
      // user-supplied kernel call


      spMV(  arg0_vec,
             arg4+(n+offset_b),
             arg1_vec);

      col2 = colors[n+offset_b];
    }

    // store local variables

      int arg0_map;
      int arg1_map;
      int arg2_map;
      int arg3_map;

      if (col2>=0) {
        arg0_map = arg_map[0*set_size+n+offset_b];
        arg1_map = arg_map[1*set_size+n+offset_b];
        arg2_map = arg_map[2*set_size+n+offset_b];
        arg3_map = arg_map[3*set_size+n+offset_b];
      }

    for (int col=0; col<ncolor; col++) {
      if (col2==col) {
        for (int d=0; d<1; d++)
          ind_arg0_s[d+arg0_map*1] += arg0_l[d];
        for (int d=0; d<1; d++)
          ind_arg0_s[d+arg1_map*1] += arg1_l[d];
        for (int d=0; d<1; d++)
          ind_arg0_s[d+arg2_map*1] += arg2_l[d];
        for (int d=0; d<1; d++)
          ind_arg0_s[d+arg3_map*1] += arg3_l[d];
      }
      __syncthreads();
    }

  }

  // apply pointered write/increment

  for (int n=threadIdx.x; n<ind_arg0_size*1; n+=blockDim.x)
    ind_arg0[n%1+ind_arg0_map[n/1]*1] += ind_arg0_s[n];

}


// host stub function

void op_par_loop_spMV(char const *name, op_set set,
  op_arg arg0,
  op_arg arg4,
  op_arg arg5 ){


  int    nargs   = 9;
  op_arg args[9];

  arg0.idx = 0;
  args[0] = arg0;
  for (int v = 1; v < 4; v++) {
    args[0 + v] = op_arg_dat(arg0.dat, v, arg0.map, 1, "double", OP_INC);
  }
  args[4] = arg4;
  arg5.idx = 0;
  args[5] = arg5;
  for (int v = 1; v < 4; v++) {
    args[5 + v] = op_arg_dat(arg5.dat, v, arg5.map, 1, "double", OP_READ);
  }

  int    ninds   = 2;
  int    inds[9] = {0,0,0,0,-1,1,1,1,1};

  if (OP_diags>2) {
    printf(" kernel routine with indirection: spMV\n");
  }

  // get plan

  #ifdef OP_PART_SIZE_3
    int part_size = OP_PART_SIZE_3;
  #else
    int part_size = OP_part_size;
  #endif

  int set_size = op_mpi_halo_exchanges(set, nargs, args);

  // initialise timers

  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timers_core(&cpu_t1, &wall_t1);

  if (set->size >0) {

    int op2_stride = set->size + set->exec_size + set->nonexec_size;
    op_decl_const_char(1, "int", sizeof(int), (char *)&op2_stride, "op2_stride");

    op_plan *Plan = op_plan_get(name,set,part_size,nargs,args,ninds,inds);


    // execute plan

    int block_offset = 0;

    for (int col=0; col < Plan->ncolors; col++) {

      if (col==Plan->ncolors_core) op_mpi_wait_all(nargs,args);

    #ifdef OP_BLOCK_SIZE_3
      int nthread = OP_BLOCK_SIZE_3;
    #else
      int nthread = OP_block_size;
    #endif

      dim3 nblocks = dim3(Plan->ncolblk[col] >= (1<<16) ? 65535 : Plan->ncolblk[col],
                      Plan->ncolblk[col] >= (1<<16) ? (Plan->ncolblk[col]-1)/65535+1: 1, 1);
      if (Plan->ncolblk[col] > 0) {
        int nshared = Plan->nsharedCol[col];
        op_cuda_spMV<<<nblocks,nthread,nshared>>>(
           (double *)arg0.data_d,
           (double *)arg5.data_d,
           Plan->ind_map,
           Plan->loc_map,
           (double *)arg4.data_d,
           Plan->ind_sizes,
           Plan->ind_offs,
           block_offset,
           Plan->blkmap,
           Plan->offset,
           Plan->nelems,
           Plan->nthrcol,
           Plan->thrcol,
           Plan->ncolblk[col],
           set_size);

        cutilSafeCall(cudaThreadSynchronize());
        cutilCheckMsg("op_cuda_spMV execution failed\n");
      }

      block_offset += Plan->ncolblk[col];
    }

    op_timing_realloc(3);
    OP_kernels[3].transfer  += Plan->transfer;
    OP_kernels[3].transfer2 += Plan->transfer2;

  }


  op_mpi_set_dirtybit(nargs, args);

  // update kernel record

  op_timers_core(&cpu_t2, &wall_t2);
  op_timing_realloc(3);
  OP_kernels[3].name      = name;
  OP_kernels[3].count    += 1;
  OP_kernels[3].time     += wall_t2 - wall_t1;
}

