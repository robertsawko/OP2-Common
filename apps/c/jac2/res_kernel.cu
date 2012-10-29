//
// auto-generated by op2.m on 19-Oct-2012 16:21:11
//

// user function

__device__
#include "res.h"


// CUDA kernel function

__global__ void op_cuda_res(
  float *ind_arg0,
  float *ind_arg1,
  int   *ind_map,
  short *arg_map,
  double *arg0,
  const float *arg3,
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

  float arg2_l[1];

  __shared__ int   *ind_arg0_map, ind_arg0_size;
  __shared__ int   *ind_arg1_map, ind_arg1_size;
  __shared__ float *ind_arg0_s;
  __shared__ float *ind_arg1_s;
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
    ind_arg1_map = &ind_map[1*set_size] + ind_arg_offs[1+blockId*2];

    // set shared memory pointers

    int nbytes = 0;
    ind_arg0_s = (float *) &shared[nbytes];
    nbytes    += ROUND_UP(ind_arg0_size*sizeof(float)*1);
    ind_arg1_s = (float *) &shared[nbytes];
  }

  __syncthreads(); // make sure all of above completed

  // copy indirect datasets into shared memory or zero increment

  for (int n=threadIdx.x; n<ind_arg0_size*1; n+=blockDim.x)
    ind_arg0_s[n] = ind_arg0[n%1+ind_arg0_map[n/1]*1];

  for (int n=threadIdx.x; n<ind_arg1_size*1; n+=blockDim.x)
    ind_arg1_s[n] = ZERO_float;

  __syncthreads();

  // process set elements

  for (int n=threadIdx.x; n<nelems2; n+=blockDim.x) {
    int col2 = -1;

    if (n<nelem) {

      // initialise local variables

      for (int d=0; d<1; d++)
        arg2_l[d] = ZERO_float;

      // user-supplied kernel call


      res(  arg0+(n+offset_b)*1,
            ind_arg0_s+arg_map[0*set_size+n+offset_b]*1,
            arg2_l,
            arg3 );

      col2 = colors[n+offset_b];
    }

    // store local variables

      int arg2_map;

      if (col2>=0) {
        arg2_map = arg_map[1*set_size+n+offset_b];
      }

    for (int col=0; col<ncolor; col++) {
      if (col2==col) {
        for (int d=0; d<1; d++)
          ind_arg1_s[d+arg2_map*1] += arg2_l[d];
      }
      __syncthreads();
    }

  }

  // apply pointered write/increment

  for (int n=threadIdx.x; n<ind_arg1_size*1; n+=blockDim.x)
    ind_arg1[n%1+ind_arg1_map[n/1]*1] += ind_arg1_s[n];

}


// host stub function

void op_par_loop_res(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3 ){

  float *arg3h = (float *)arg3.data;

  int    nargs   = 4;
  op_arg args[4];

  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;

  int    ninds   = 2;
  int    inds[4] = {-1,0,1,-1};

  if (OP_diags>2) {
    printf(" kernel routine with indirection: res\n");
  }

  // get plan

  #ifdef OP_PART_SIZE_0
    int part_size = OP_PART_SIZE_0;
  #else
    int part_size = OP_part_size;
  #endif

  int set_size = op_mpi_halo_exchanges(set, nargs, args);

  // initialise timers

  double cpu_t1, cpu_t2, wall_t1=0, wall_t2=0;
  op_timing_realloc(0);
  OP_kernels[0].name      = name;
  OP_kernels[0].count    += 1;

  if (set->size >0) {

    op_plan *Plan = op_plan_get(name,set,part_size,nargs,args,ninds,inds);

    op_timers_core(&cpu_t1, &wall_t1);

    // transfer constants to GPU

    int consts_bytes = 0;
    consts_bytes += ROUND_UP(1*sizeof(float));

    reallocConstArrays(consts_bytes);

    consts_bytes = 0;
    arg3.data   = OP_consts_h + consts_bytes;
    arg3.data_d = OP_consts_d + consts_bytes;
    for (int d=0; d<1; d++) ((float *)arg3.data)[d] = arg3h[d];
    consts_bytes += ROUND_UP(1*sizeof(float));

    mvConstArraysToDevice(consts_bytes);

    // execute plan

    int block_offset = 0;

    for (int col=0; col < Plan->ncolors; col++) {

      if (col==Plan->ncolors_core) op_mpi_wait_all(nargs,args);

    #ifdef OP_BLOCK_SIZE_0
      int nthread = OP_BLOCK_SIZE_0;
    #else
      int nthread = OP_block_size;
    #endif

      dim3 nblocks = dim3(Plan->ncolblk[col] >= (1<<16) ? 65535 : Plan->ncolblk[col],
                      Plan->ncolblk[col] >= (1<<16) ? (Plan->ncolblk[col]-1)/65535+1: 1, 1);
      if (Plan->ncolblk[col] > 0) {
        int nshared = Plan->nsharedCol[col];
        op_cuda_res<<<nblocks,nthread,nshared>>>(
           (float *)arg1.data_d,
           (float *)arg2.data_d,
           Plan->ind_map,
           Plan->loc_map,
           (double *)arg0.data_d,
           (float *)arg3.data_d,
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

        cutilSafeCall(cudaDeviceSynchronize());
        cutilCheckMsg("op_cuda_res execution failed\n");
      }

      block_offset += Plan->ncolblk[col];
    }

    op_timing_realloc(0);
    OP_kernels[0].transfer  += Plan->transfer;
    OP_kernels[0].transfer2 += Plan->transfer2;

  }


  op_mpi_set_dirtybit(nargs, args);

  // update kernel record

  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[0].time     += wall_t2 - wall_t1;
}

