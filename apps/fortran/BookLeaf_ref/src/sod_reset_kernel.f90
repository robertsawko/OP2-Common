!
! auto-generated by op2.py on 2015-01-26 23:17
!

MODULE SOD_RESET_MODULE
USE OP2_FORTRAN_DECLARATIONS
USE OP2_FORTRAN_RT_SUPPORT
USE ISO_C_BINDING
USE kinds_mod,    ONLY: ink,rlk
USE parameters_mod,ONLY: LI

USE OMP_LIB


CONTAINS

!DEC$ ATTRIBUTES FORCEINLINE :: sod_reset
SUBROUTINE sod_reset(ndx1,ndx2,ndx3,ndx4,xmid,ielmat,rho, &
&                      pre,ein,elmass,cnmass,eos_param,elvol,cnwt)

    USE kinds_mod,ONLY: rlk,ink
    USE parameters_mod,ONLY: LI, N_SHAPE

    implicit none

    REAL(KIND=rlk), INTENT(IN) :: ndx1,ndx2,ndx3,ndx4,elvol
    REAL(KIND=rlk), INTENT(INOUT) :: xmid
    REAL(KIND=rlk), INTENT(OUT) :: rho,pre,ein,elmass
    REAL(KIND=rlk), DIMENSION(N_SHAPE), INTENT(OUT) :: cnmass
    REAL(KIND=rlk), DIMENSION(N_SHAPE), INTENT(IN) :: cnwt
    REAL(KIND=rlk), DIMENSION(6,LI), INTENT(IN) :: eos_param
    INTEGER(KIND=ink), INTENT(OUT) :: ielmat


    IF ((0.25_rlk*(ndx1+ndx2+ndx3+ndx4)).LT.xmid) THEN
      ielmat=1_ink
      rho=1.0_rlk
      pre=1.0_rlk
    ELSE
      ielmat=2_ink
      rho=0.125_rlk
      pre=0.1_rlk
    ENDIF
    ein=pre/(rho*(eos_param(1,ielmat)-1.0_rlk))
    elmass=rho*elvol
    cnmass(1)=rho*cnwt(1)
    cnmass(2)=rho*cnwt(2)
    cnmass(3)=rho*cnwt(3)
    cnmass(4)=rho*cnwt(4)

  END SUBROUTINE sod_reset


SUBROUTINE op_wrap_sod_reset( &
& opDat1Local, &
& opDat5Local, &
& opDat6Local, &
& opDat7Local, &
& opDat8Local, &
& opDat9Local, &
& opDat10Local, &
& opDat11Local, &
& opDat12Local, &
& opDat13Local, &
& opDat14Local, &
& opDat1Map, &
& opDat1MapDim, &
& bottom,top)
real(8) opDat1Local(1,*)
real(8) opDat5Local(1)
integer(4) opDat6Local(1,*)
real(8) opDat7Local(1,*)
real(8) opDat8Local(1,*)
real(8) opDat9Local(1,*)
real(8) opDat10Local(1,*)
real(8) opDat11Local(4,*)
real(8) opDat12Local(LI*6)
real(8) opDat13Local(1,*)
real(8) opDat14Local(4,*)
INTEGER(kind=4) opDat1Map(*)
INTEGER(kind=4) opDat1MapDim
INTEGER(kind=4) bottom,top,i1
INTEGER(kind=4) map1idx, map2idx, map3idx, map4idx

DO i1 = bottom, top-1, 1
  map1idx = opDat1Map(1 + i1 * opDat1MapDim + 0)+1
  map2idx = opDat1Map(1 + i1 * opDat1MapDim + 1)+1
  map3idx = opDat1Map(1 + i1 * opDat1MapDim + 2)+1
  map4idx = opDat1Map(1 + i1 * opDat1MapDim + 3)+1
! kernel call
CALL sod_reset( &
  & opDat1Local(1,map1idx), &
  & opDat1Local(1,map2idx), &
  & opDat1Local(1,map3idx), &
  & opDat1Local(1,map4idx), &
  & opDat5Local(1), &
  & opDat6Local(1,i1+1), &
  & opDat7Local(1,i1+1), &
  & opDat8Local(1,i1+1), &
  & opDat9Local(1,i1+1), &
  & opDat10Local(1,i1+1), &
  & opDat11Local(1,i1+1), &
  & opDat12Local(1), &
  & opDat13Local(1,i1+1), &
  & opDat14Local(1,i1+1) &
  & )
END DO
END SUBROUTINE
SUBROUTINE sod_reset_host( userSubroutine, set, &
& opArg1, &
& opArg2, &
& opArg3, &
& opArg4, &
& opArg5, &
& opArg6, &
& opArg7, &
& opArg8, &
& opArg9, &
& opArg10, &
& opArg11, &
& opArg12, &
& opArg13, &
& opArg14 )

IMPLICIT NONE
character(kind=c_char,len=*), INTENT(IN) :: userSubroutine
type ( op_set ) , INTENT(IN) :: set

type ( op_arg ) , INTENT(IN) :: opArg1
type ( op_arg ) , INTENT(IN) :: opArg2
type ( op_arg ) , INTENT(IN) :: opArg3
type ( op_arg ) , INTENT(IN) :: opArg4
type ( op_arg ) , INTENT(IN) :: opArg5
type ( op_arg ) , INTENT(IN) :: opArg6
type ( op_arg ) , INTENT(IN) :: opArg7
type ( op_arg ) , INTENT(IN) :: opArg8
type ( op_arg ) , INTENT(IN) :: opArg9
type ( op_arg ) , INTENT(IN) :: opArg10
type ( op_arg ) , INTENT(IN) :: opArg11
type ( op_arg ) , INTENT(IN) :: opArg12
type ( op_arg ) , INTENT(IN) :: opArg13
type ( op_arg ) , INTENT(IN) :: opArg14

type ( op_arg ) , DIMENSION(14) :: opArgArray
INTEGER(kind=4) :: numberOfOpDats
INTEGER(kind=4) :: n_upper
type ( op_set_core ) , POINTER :: opSetCore

INTEGER(kind=4), POINTER, DIMENSION(:) :: opDat1Map
INTEGER(kind=4) :: opDat1MapDim
real(8), POINTER, DIMENSION(:) :: opDat1Local
INTEGER(kind=4) :: opDat1Cardinality

real(8), POINTER, DIMENSION(:) :: opDat5Local
integer(4), POINTER, DIMENSION(:) :: opDat6Local
INTEGER(kind=4) :: opDat6Cardinality

real(8), POINTER, DIMENSION(:) :: opDat7Local
INTEGER(kind=4) :: opDat7Cardinality

real(8), POINTER, DIMENSION(:) :: opDat8Local
INTEGER(kind=4) :: opDat8Cardinality

real(8), POINTER, DIMENSION(:) :: opDat9Local
INTEGER(kind=4) :: opDat9Cardinality

real(8), POINTER, DIMENSION(:) :: opDat10Local
INTEGER(kind=4) :: opDat10Cardinality

real(8), POINTER, DIMENSION(:) :: opDat11Local
INTEGER(kind=4) :: opDat11Cardinality

real(8), POINTER, DIMENSION(:) :: opDat12Local
real(8), POINTER, DIMENSION(:) :: opDat13Local
INTEGER(kind=4) :: opDat13Cardinality

real(8), POINTER, DIMENSION(:) :: opDat14Local
INTEGER(kind=4) :: opDat14Cardinality

INTEGER(kind=4) :: threadID
INTEGER(kind=4) :: numberOfThreads
INTEGER(kind=4), DIMENSION(1:8) :: timeArrayStart
INTEGER(kind=4), DIMENSION(1:8) :: timeArrayEnd
REAL(kind=8) :: startTime
REAL(kind=8) :: endTime
INTEGER(kind=4) :: returnSetKernelTiming
LOGICAL :: firstTime_sod_reset = .TRUE.
type ( c_ptr )  :: planRet_sod_reset
type ( op_plan ) , POINTER :: actualPlan_sod_reset
INTEGER(kind=4), POINTER, DIMENSION(:) :: ncolblk_sod_reset
INTEGER(kind=4), POINTER, DIMENSION(:) :: blkmap_sod_reset
INTEGER(kind=4), POINTER, DIMENSION(:) :: nelems_sod_reset
INTEGER(kind=4), POINTER, DIMENSION(:) :: offset_sod_reset
INTEGER(kind=4), DIMENSION(1:14) :: indirectionDescriptorArray
INTEGER(kind=4) :: numberOfIndirectOpDats
INTEGER(kind=4) :: blockOffset
INTEGER(kind=4) :: nblocks
INTEGER(kind=4) :: partitionSize
INTEGER(kind=4) :: blockID
INTEGER(kind=4) :: nelem
INTEGER(kind=4) :: offset_b


INTEGER(kind=4) :: i1,i2,n

numberOfOpDats = 14

opArgArray(1) = opArg1
opArgArray(2) = opArg2
opArgArray(3) = opArg3
opArgArray(4) = opArg4
opArgArray(5) = opArg5
opArgArray(6) = opArg6
opArgArray(7) = opArg7
opArgArray(8) = opArg8
opArgArray(9) = opArg9
opArgArray(10) = opArg10
opArgArray(11) = opArg11
opArgArray(12) = opArg12
opArgArray(13) = opArg13
opArgArray(14) = opArg14

returnSetKernelTiming = setKernelTime(29 , userSubroutine//C_NULL_CHAR, &
& 0.d0, 0.00000,0.00000, 0)
call op_timers_core(startTime)

n_upper = op_mpi_halo_exchanges(set%setCPtr,numberOfOpDats,opArgArray)

  partitionSize = 0

  numberOfThreads = omp_get_max_threads()
  indirectionDescriptorArray(1) = 0
  indirectionDescriptorArray(2) = 0
  indirectionDescriptorArray(3) = 0
  indirectionDescriptorArray(4) = 0
  indirectionDescriptorArray(5) = -1
  indirectionDescriptorArray(6) = -1
  indirectionDescriptorArray(7) = -1
  indirectionDescriptorArray(8) = -1
  indirectionDescriptorArray(9) = -1
  indirectionDescriptorArray(10) = -1
  indirectionDescriptorArray(11) = -1
  indirectionDescriptorArray(12) = -1
  indirectionDescriptorArray(13) = -1
  indirectionDescriptorArray(14) = -1

  numberOfIndirectOpDats = 1

  planRet_sod_reset = FortranPlanCaller( &
  & userSubroutine//C_NULL_CHAR, &
  & set%setCPtr, &
  & partitionSize, &
  & numberOfOpDats, &
  & opArgArray, &
  & numberOfIndirectOpDats, &
  & indirectionDescriptorArray,2)

  CALL c_f_pointer(planRet_sod_reset,actualPlan_sod_reset)
  CALL c_f_pointer(actualPlan_sod_reset%ncolblk,ncolblk_sod_reset,(/actualPlan_sod_reset%ncolors_core/))
  CALL c_f_pointer(actualPlan_sod_reset%blkmap,blkmap_sod_reset,(/actualPlan_sod_reset%nblocks/))
  CALL c_f_pointer(actualPlan_sod_reset%offset,offset_sod_reset,(/actualPlan_sod_reset%nblocks/))
  CALL c_f_pointer(actualPlan_sod_reset%nelems,nelems_sod_reset,(/actualPlan_sod_reset%nblocks/))

  opSetCore => set%setPtr

  opDat1Cardinality = opArg1%dim * getSetSizeFromOpArg(opArg1)
  opDat1MapDim = getMapDimFromOpArg(opArg1)
  opDat6Cardinality = opArg6%dim * getSetSizeFromOpArg(opArg6)
  opDat7Cardinality = opArg7%dim * getSetSizeFromOpArg(opArg7)
  opDat8Cardinality = opArg8%dim * getSetSizeFromOpArg(opArg8)
  opDat9Cardinality = opArg9%dim * getSetSizeFromOpArg(opArg9)
  opDat10Cardinality = opArg10%dim * getSetSizeFromOpArg(opArg10)
  opDat11Cardinality = opArg11%dim * getSetSizeFromOpArg(opArg11)
  opDat13Cardinality = opArg13%dim * getSetSizeFromOpArg(opArg13)
  opDat14Cardinality = opArg14%dim * getSetSizeFromOpArg(opArg14)
  CALL c_f_pointer(opArg1%data,opDat1Local,(/opDat1Cardinality/))
  CALL c_f_pointer(opArg1%map_data,opDat1Map,(/opSetCore%size*opDat1MapDim/))
  CALL c_f_pointer(opArg5%data,opDat5Local, (/opArg5%dim/))
  CALL c_f_pointer(opArg6%data,opDat6Local,(/opDat6Cardinality/))
  CALL c_f_pointer(opArg7%data,opDat7Local,(/opDat7Cardinality/))
  CALL c_f_pointer(opArg8%data,opDat8Local,(/opDat8Cardinality/))
  CALL c_f_pointer(opArg9%data,opDat9Local,(/opDat9Cardinality/))
  CALL c_f_pointer(opArg10%data,opDat10Local,(/opDat10Cardinality/))
  CALL c_f_pointer(opArg11%data,opDat11Local,(/opDat11Cardinality/))
  CALL c_f_pointer(opArg12%data,opDat12Local, (/opArg12%dim/))
  CALL c_f_pointer(opArg13%data,opDat13Local,(/opDat13Cardinality/))
  CALL c_f_pointer(opArg14%data,opDat14Local,(/opDat14Cardinality/))


  blockOffset = 0

  DO i1 = 0, actualPlan_sod_reset%ncolors-1, 1
    IF (i1 .EQ. actualPlan_sod_reset%ncolors_core) THEN
      CALL op_mpi_wait_all(numberOfOpDats,opArgArray)
    END IF

    nblocks = ncolblk_sod_reset(i1 + 1)
    !$OMP PARALLEL DO private (threadID, blockID, nelem, offset_b)
    DO i2 = 0, nblocks-1, 1
      threadID = omp_get_thread_num()
      blockID = blkmap_sod_reset(i2+blockOffset+1)
      nelem = nelems_sod_reset(blockID+1)
      offset_b = offset_sod_reset(blockID+1)
      CALL op_wrap_sod_reset( &
      & opDat1Local, &
      & opDat5Local, &
      & opDat6Local, &
      & opDat7Local, &
      & opDat8Local, &
      & opDat9Local, &
      & opDat10Local, &
      & opDat11Local, &
      & opDat12Local, &
      & opDat13Local, &
      & opDat14Local, &
      & opDat1Map, &
      & opDat1MapDim, &
      & offset_b, offset_b+nelem)
    END DO
    !$OMP END PARALLEL DO
    blockOffset = blockOffset + nblocks
  END DO
  IF ((n_upper .EQ. 0) .OR. (n_upper .EQ. opSetCore%core_size)) THEN
    CALL op_mpi_wait_all(numberOfOpDats,opArgArray)
  END IF

  CALL op_mpi_set_dirtybit(numberOfOpDats,opArgArray)

  call op_timers_core(endTime)

  returnSetKernelTiming = setKernelTime(29 , userSubroutine//C_NULL_CHAR, &
  & endTime-startTime, actualPlan_sod_reset%transfer,actualPlan_sod_reset%transfer2, 1)
END SUBROUTINE
END MODULE