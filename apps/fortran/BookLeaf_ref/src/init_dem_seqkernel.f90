!
! auto-generated by op2.py on 2015-01-26 18:29
!

MODULE INIT_DEM_MODULE
USE OP2_FORTRAN_DECLARATIONS
USE OP2_FORTRAN_RT_SUPPORT
USE ISO_C_BINDING
USE kinds_mod,    ONLY: ink,rlk
USE parameters_mod,ONLY: LI


CONTAINS

!DEC$ ATTRIBUTES FORCEINLINE :: init_dem
SUBROUTINE init_dem(im,mat_rho,mat_ein,rho,ein,elmass,elvol,cnmass,cnwt)

    USE kinds_mod,ONLY: rlk
    USE parameters_mod,ONLY: LI, N_SHAPE

    implicit none

    REAL(KIND=rlk), INTENT(OUT) :: rho,ein,elmass
    REAL(KIND=rlk), DIMENSION(N_SHAPE), INTENT(OUT) :: cnmass
    REAL(KIND=rlk), DIMENSION(LI), INTENT(IN) :: mat_rho,mat_ein
    REAL(KIND=rlk), INTENT(IN) :: elvol
    INTEGER(KIND=ink), INTENT(IN) :: im
    REAL(KIND=rlk), DIMENSION(N_SHAPE), INTENT(IN) :: cnwt

    rho=mat_rho(im)
    ein=mat_ein(im)
    elmass=rho*elvol
    cnmass(1:N_SHAPE)=rho*cnwt(1:N_SHAPE)


  END SUBROUTINE init_dem


SUBROUTINE op_wrap_init_dem( &
  & opDat1Local, &
  & opDat2Local, &
  & opDat3Local, &
  & opDat4Local, &
  & opDat5Local, &
  & opDat6Local, &
  & opDat7Local, &
  & opDat8Local, &
  & opDat9Local, &
  & bottom,top)
  integer(4) opDat1Local(1,*)
  real(8) opDat2Local(LI)
  real(8) opDat3Local(LI)
  real(8) opDat4Local(1,*)
  real(8) opDat5Local(1,*)
  real(8) opDat6Local(1,*)
  real(8) opDat7Local(1,*)
  real(8) opDat8Local(4,*)
  real(8) opDat9Local(4,*)
  INTEGER(kind=4) bottom,top,i1

  DO i1 = bottom, top-1, 1
! kernel call
  CALL init_dem( &
    & opDat1Local(1,i1+1), &
    & opDat2Local(1), &
    & opDat3Local(1), &
    & opDat4Local(1,i1+1), &
    & opDat5Local(1,i1+1), &
    & opDat6Local(1,i1+1), &
    & opDat7Local(1,i1+1), &
    & opDat8Local(1,i1+1), &
    & opDat9Local(1,i1+1) &
    & )
  END DO
END SUBROUTINE
SUBROUTINE init_dem_host( userSubroutine, set, &
  & opArg1, &
  & opArg2, &
  & opArg3, &
  & opArg4, &
  & opArg5, &
  & opArg6, &
  & opArg7, &
  & opArg8, &
  & opArg9 )

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

  type ( op_arg ) , DIMENSION(9) :: opArgArray
  INTEGER(kind=4) :: numberOfOpDats
  INTEGER(kind=4), DIMENSION(1:8) :: timeArrayStart
  INTEGER(kind=4), DIMENSION(1:8) :: timeArrayEnd
  REAL(kind=8) :: startTime
  REAL(kind=8) :: endTime
  INTEGER(kind=4) :: returnSetKernelTiming
  INTEGER(kind=4) :: n_upper
  type ( op_set_core ) , POINTER :: opSetCore

  integer(4), POINTER, DIMENSION(:) :: opDat1Local
  INTEGER(kind=4) :: opDat1Cardinality

  real(8), POINTER, DIMENSION(:) :: opDat2Local
  real(8), POINTER, DIMENSION(:) :: opDat3Local
  real(8), POINTER, DIMENSION(:) :: opDat4Local
  INTEGER(kind=4) :: opDat4Cardinality

  real(8), POINTER, DIMENSION(:) :: opDat5Local
  INTEGER(kind=4) :: opDat5Cardinality

  real(8), POINTER, DIMENSION(:) :: opDat6Local
  INTEGER(kind=4) :: opDat6Cardinality

  real(8), POINTER, DIMENSION(:) :: opDat7Local
  INTEGER(kind=4) :: opDat7Cardinality

  real(8), POINTER, DIMENSION(:) :: opDat8Local
  INTEGER(kind=4) :: opDat8Cardinality

  real(8), POINTER, DIMENSION(:) :: opDat9Local
  INTEGER(kind=4) :: opDat9Cardinality


  INTEGER(kind=4) :: i1

  numberOfOpDats = 9

  opArgArray(1) = opArg1
  opArgArray(2) = opArg2
  opArgArray(3) = opArg3
  opArgArray(4) = opArg4
  opArgArray(5) = opArg5
  opArgArray(6) = opArg6
  opArgArray(7) = opArg7
  opArgArray(8) = opArg8
  opArgArray(9) = opArg9

  returnSetKernelTiming = setKernelTime(0 , userSubroutine//C_NULL_CHAR, &
  & 0.d0, 0.00000,0.00000, 0)
  call op_timers_core(startTime)

  n_upper = op_mpi_halo_exchanges(set%setCPtr,numberOfOpDats,opArgArray)

  opSetCore => set%setPtr

  opDat1Cardinality = opArg1%dim * getSetSizeFromOpArg(opArg1)
  opDat4Cardinality = opArg4%dim * getSetSizeFromOpArg(opArg4)
  opDat5Cardinality = opArg5%dim * getSetSizeFromOpArg(opArg5)
  opDat6Cardinality = opArg6%dim * getSetSizeFromOpArg(opArg6)
  opDat7Cardinality = opArg7%dim * getSetSizeFromOpArg(opArg7)
  opDat8Cardinality = opArg8%dim * getSetSizeFromOpArg(opArg8)
  opDat9Cardinality = opArg9%dim * getSetSizeFromOpArg(opArg9)
  CALL c_f_pointer(opArg1%data,opDat1Local,(/opDat1Cardinality/))
  CALL c_f_pointer(opArg2%data,opDat2Local, (/opArg2%dim/))
  CALL c_f_pointer(opArg3%data,opDat3Local, (/opArg3%dim/))
  CALL c_f_pointer(opArg4%data,opDat4Local,(/opDat4Cardinality/))
  CALL c_f_pointer(opArg5%data,opDat5Local,(/opDat5Cardinality/))
  CALL c_f_pointer(opArg6%data,opDat6Local,(/opDat6Cardinality/))
  CALL c_f_pointer(opArg7%data,opDat7Local,(/opDat7Cardinality/))
  CALL c_f_pointer(opArg8%data,opDat8Local,(/opDat8Cardinality/))
  CALL c_f_pointer(opArg9%data,opDat9Local,(/opDat9Cardinality/))


  CALL op_mpi_wait_all(numberOfOpDats,opArgArray)
  CALL op_wrap_init_dem( &
  & opDat1Local, &
  & opDat2Local, &
  & opDat3Local, &
  & opDat4Local, &
  & opDat5Local, &
  & opDat6Local, &
  & opDat7Local, &
  & opDat8Local, &
  & opDat9Local, &
  & 0, n_upper)

  CALL op_mpi_set_dirtybit(numberOfOpDats,opArgArray)

  call op_timers_core(endTime)

  returnSetKernelTiming = setKernelTime(0 , userSubroutine//C_NULL_CHAR, &
  & endTime-startTime,0.00000,0.00000, 1)
END SUBROUTINE
END MODULE