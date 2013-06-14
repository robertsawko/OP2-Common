PREPROCESSOR = -fpp

OP2 = $(OP2_INSTALL_PATH)

F_OP2_MOD = $(OP2)/fortran/mod/$(OP2_COMPILER)
F_OP2_LIB = $(OP2)/fortran/lib

HDF5_LIB = -L$(HDF5_INSTALL_PATH)/lib -lhdf5

PARMETIS_INCLUDE_PATH ?= $(PARMETIS_INSTALL_PATH)
PARMETIS_LIB_PATH ?= $(PARMETIS_INSTALL_PATH)
PARMETIS_VER=3
ifeq ($(PARMETIS_VER),4)
  PARMETIS_INC = -I$(PARMETIS_INCLUDE_PATH)/include -DHAVE_PARMETIS -DPARMETIS_VER_4
  PARMETIS_LIB = -L$(PARMETIS_LIB_PATH)/lib -lparmetis -lmetis
else
  PARMETIS_INC = -I$(PARMETIS_INCLUDE_PATH)/ -DHAVE_PARMETIS
  PARMETIS_LIB = -L$(PARMETIS_LIB_PATH)/ -lparmetis -lmetis
endif

PTSCOTCH_INC    = -I$(PTSCOTCH_INSTALL_PATH)/include -DHAVE_PTSCOTCH
PTSCOTCH_LIB    = -L$(PTSCOTCH_INSTALL_PATH)/lib/ -lptscotch \
                  -L$(PTSCOTCH_INSTALL_PATH)/lib/ -lptscotcherr


ifeq ($(OP2_COMPILER),gnu)

else
ifeq ($(OP2_COMPILER),pgi)
  CC = pgcc
  #FC = pgfortran -fast -Mcuda=cuda5.0,cc35,fastmath,ptxinfo,keepgpu,keepptx -Mx,189,0x40 -Minline=adt_calc#-Munroll -Minline=save_soln,res_calc,bres_calc,adt_calc -Mipa=fast -Mx,189,0x40
  FC = pgfortran -fast -Mcuda=cuda5.0,cc20,fastmath,ptxinfo
  MPI_LIB = -L$(MPI_INSTALL_PATH)/lib -lmpi
  MPI_INC = -I$(MPI_INSTALL_PATH)/include
  MPIF90 = $(FC) -I$(MPI_INC) -L$(MPI_LIB)
  OPT = -DOP_PART_SIZE_1=$(PART_SIZE_ENV) -O2 
  OPENMP = -mp
  CPPLINK = -pgcpplibs
else
ifeq ($(OP2_COMPILER),intel)
  CC = icc -O0 -g
  FC = ifort -O0 -g
  MPI_LIB = -L$(MPI_INSTALL_PATH)/lib -lmpi
  MPI_INC = -I$(MPI_INSTALL_PATH)/include
  MPIF90 =  $(FC) -I$(MPI_INC) -L$(MPI_LIB)
  OPENMP = -openmp
  OPT = -DOP_PART_SIZE_1=$(PART_SIZE_ENV) -O2 -xSSE4.2 -vec-report -g
  CPPLINK = -lstdc++
else
ifeq ($(OP2_COMPILER),cray)
  CC = CC
  FC = ftn -em -p $(F_OP2_MOD)
  MPI_LIB = #-L$(MPI_INSTALL_PATH)/lib -lmpi
  MPI_INC = #-I$(MPI_INSTALL_PATH)/include
  MPIF90 = $(FC) -I$(MPI_INC) -L$(MPI_LIB)
  OPT = -O2 -DOP_PART_SIZE_1=$(PART_SIZE_ENV)
  OPENMP = -h omp -lomp
  CPPLINK = -hnopgas_runtime
else
print:
	echo "unrecognised value for OP2_COMPILER"
endif
endif
endif
endif

FLINK = -L$(F_OP2_LIB)
FMODS = -I$(F_OP2_MOD)

all: clean airfoil_hdf5_seq airfoil_hdf5_openmp_$(PART_SIZE_ENV) airfoil_hdf5_mpi airfoil_hdf5_mpi_genseq airfoil_hdf5_mpi_openmp_$(PART_SIZE_ENV) airfoil_hdf5_cuda airfoil_hdf5_mpi_cuda

airfoil_hdf5_seq: constants.F90 airfoil_seqfun.F90 airfoil_hdf5.F90 input.F90
	$(FC) $(OPT) $(FMODS) -c constants.F90 input.F90 airfoil_seqfun.F90 airfoil_hdf5.F90
	$(FC) $(OPT) $(FLINK) constants.o input.o airfoil_hdf5.o airfoil_seqfun.o -o airfoil_hdf5_seq -lop2_for_seq -lop2_hdf5 $(HDF5_LIB) $(MPI_LIB) -lz

airfoil_hdf5_openmp_$(PART_SIZE_ENV): airfoil_hdf5_op.F90 save_soln_kernel.F90 adt_calc_kernel.F90 input.F90 \
	res_calc_kernel.F90 bres_calc_kernel.F90 update_kernel.F90 constants.F90 airfoil_seqfun.F90
	$(FC) $(OPT) $(OPENMP) $(FMODS) -c constants.F90 input.F90 \
	save_soln_kernel.F90 update_kernel.F90 bres_calc_kernel.F90 \
	res_calc_kernel.F90 adt_calc_kernel.F90 airfoil_hdf5_op.F90 airfoil_seqfun.F90
	$(FC) $(OPT) $(OPENMP) $(FLINK) constants.o input.o airfoil_seqfun.o \
	save_soln_kernel.o adt_calc_kernel.o res_calc_kernel.o \
	bres_calc_kernel.o update_kernel.o airfoil_hdf5_op.o -o airfoil_hdf5_openmp_$(PART_SIZE_ENV) -lop2_for_openmp -lop2_hdf5 $(HDF5_LIB) $(MPI_LIB) -lz

airfoil_hdf5_cuda: airfoil_hdf5_op.F90 save_soln_kernel.CUF adt_calc_kernel.CUF input.F90 \
        res_calc_kernel.CUF bres_calc_kernel.CUF update_kernel.CUF constants.F90 input.F90 cudaConfigurationParams.F95
ifeq ($(OP2_COMPILER),pgi)
	$(FC) $(OPT) $(OPENMP) $(FMODS) $(FLINK) -DOP2_WITH_CUDAFOR cudaConfigurationParams.F95 constants.F90 input.F90 \
        save_soln_kernel.CUF update_kernel.CUF bres_calc_kernel.CUF \
        res_calc_kernel.CUF adt_calc_kernel.CUF airfoil_hdf5_op.F90 -o airfoil_hdf5_cuda -lop2_for_cuda -lop2_hdf5 $(HDF5_LIB) $(MPI_LIB) -lz
else
	@echo "airfoil_hdf5_cuda cannot be built with $(OP2_COMPILER) compilers .. requires PGI CUDA FORTRAN compiler"
endif

airfoil_hdf5_mpi: constants.F90 airfoil_seqfun.F90 airfoil_hdf5.F90 input.F90
	$(FC) $(OPT) $(FMODS) -c constants.F90 airfoil_seqfun.F90 input.F90 airfoil_hdf5.F90
	$(FC) $(OPT) $(FLINK) $(CPPLINK) $(PARMETIS_INC) $(PTSCOTCH_INC) constants.o input.o airfoil_hdf5.o \
	airfoil_seqfun.o -o airfoil_hdf5_mpi -lop2_for_mpi $(PARMETIS_LIB) $(PTSCOTCH_LIB) $(HDF5_LIB) $(MPI_LIB) -lz

airfoil_hdf5_mpi_genseq: airfoil_hdf5_op.F90 input.F90 save_soln_seqkernel.F90 adt_calc_seqkernel.F90 \
	res_calc_seqkernel.F90 bres_calc_seqkernel.F90 update_seqkernel.F90 constants.F90 airfoil_seqfun.F90
	$(FC) $(OPT) $(OPENMP) $(FMODS) -c constants.F90 input.F90 \
	save_soln_seqkernel.F90 update_seqkernel.F90 bres_calc_seqkernel.F90 \
	res_calc_seqkernel.F90 adt_calc_seqkernel.F90 airfoil_hdf5_op.F90
	$(FC) $(OPT) $(OPENMP) $(FLINK) $(CPPLINK) $(PARMETIS_INC) $(PTSCOTCH_INC) input.o constants.o \
	save_soln_seqkernel.o adt_calc_seqkernel.o res_calc_seqkernel.o \
	bres_calc_seqkernel.o update_seqkernel.o airfoil_hdf5_op.o -o airfoil_hdf5_mpi_genseq \
	-lop2_for_mpi $(PARMETIS_LIB) $(PTSCOTCH_LIB) $(HDF5_LIB) $(MPI_LIB) -lz

airfoil_hdf5_mpi_openmp_$(PART_SIZE_ENV): airfoil_hdf5_op.F90 input.F90 save_soln_kernel.F90 adt_calc_kernel.F90 \
	res_calc_kernel.F90 bres_calc_kernel.F90 update_kernel.F90 constants.F90 airfoil_seqfun.F90
	$(FC) $(OPT) $(OPENMP) $(FMODS) -c constants.F90 input.F90 \
	save_soln_kernel.F90 update_kernel.F90 bres_calc_kernel.F90 \
	res_calc_kernel.F90 adt_calc_kernel.F90 airfoil_hdf5_op.F90
	$(FC) $(OPT) $(OPENMP) $(FLINK) $(CPPLINK) $(PARMETIS_INC) $(PTSCOTCH_INC) input.o constants.o \
	save_soln_kernel.o adt_calc_kernel.o res_calc_kernel.o \
	bres_calc_kernel.o update_kernel.o airfoil_hdf5_op.o -o airfoil_hdf5_mpi_openmp_$(PART_SIZE_ENV) \
	-lop2_for_mpi $(PARMETIS_LIB) $(PTSCOTCH_LIB) $(HDF5_LIB) $(MPI_LIB) -lz

airfoil_hdf5_mpi_cuda: airfoil_hdf5_op.F90 save_soln_kernel.CUF adt_calc_kernel.CUF input.F90 \
	res_calc_kernel.CUF bres_calc_kernel.CUF update_kernel.CUF constants.F90 input.F90 cudaConfigurationParams.F95
ifeq ($(OP2_COMPILER),pgi)
	$(FC) $(OPT) $(OPENMP) $(FMODS) $(FLINK) $(CPPLINK) $(PARMETIS_INC) $(PTSCOTCH_INC) -DOP2_WITH_CUDAFOR \
	cudaConfigurationParams.F95 constants.F90 input.F90 save_soln_kernel.CUF update_kernel.CUF bres_calc_kernel.CUF \
        res_calc_kernel.CUF adt_calc_kernel.CUF \
	airfoil_hdf5_op.F90 -o airfoil_hdf5_mpi_cuda -lop2_for_mpi_cuda $(PARMETIS_LIB) $(PTSCOTCH_LIB) $(HDF5_LIB) $(MPI_LIB) -lz
else
	@echo "airfoil_hdf5_mpi_cuda cannot be built with $(OP2_COMPILER) compilers .. requires PGI CUDA FORTRAN compiler"
endif

clean:
	rm -f *.o
	rm -f *.mod
	rm -f $(EXEC)
	rm -f *~
	rm -f airfoil_hdf5_seq
	rm -f airfoil_hdf5_mpi
	rm -f airfoil_hdf5_openmp_$(PART_SIZE_ENV) airfoil_hdf5_mpi_openmp_$(PART_SIZE_ENV)
	rm -f airfoil_hdf5_mpi_genseq
	rm -f airfoil_hdf5_cuda airfoil_hdf5_mpi_cuda