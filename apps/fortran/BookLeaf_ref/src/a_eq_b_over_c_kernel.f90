!
! auto-generated by op2.py on 2015-01-26 23:17
!

MODULE A_EQ_B_OVER_C_MODULE
USE OP2_FORTRAN_DECLARATIONS
USE OP2_FORTRAN_RT_SUPPORT
USE ISO_C_BINDING
USE kinds_mod,    ONLY: ink,rlk
USE parameters_mod,ONLY: LI

USE OMP_LIB


CONTAINS

!DEC$ ATTRIBUTES FORCEINLINE :: a_eq_b_over_c
SUBROUTINE a_eq_b_over_c(a,b,c)

    USE kinds_mod,ONLY: rlk

    implicit none

    REAL(KIND=rlk), INTENT(OUT) :: a
    REAL(KIND=rlk), INTENT(IN) :: b,c

    a = b / c

  END SUBROUTINE a_eq_b_over_c


SUBROUTINE op_wrap_a_eq_b_over_c( &
& opDat1Local, &
& opDat2Local, &
& opDat3Local, &
& bottom,top)
real(8) opDat1Local(1,*)
real(8) opDat2Local(1,*)
real(8) opDat3Local(1,*)
INTEGER(kind=4) bottom,top,i1

DO i1 = bottom, top-1, 1
! kernel call
CALL a_eq_b_over_c( &
  & opDat1Local(1,i1+1), &
  & opDat2Local(1,i1+1), &
  & opDat3Local(1,i1+1) &
  & )
END DO
END SUBROUTINE
SUBROUTINE a_eq_b_over_c_host( userSubroutine, set, &
& opArg1, &
& opArg2, &
& opArg3 )

IMPLICIT NONE
character(kind=c_char,len=*), INTENT(IN) :: userSubroutine
type ( op_set ) , INTENT(IN) :: set

type ( op_arg ) , INTENT(IN) :: opArg1
type ( op_arg ) , INTENT(IN) :: opArg2
type ( op_arg ) , INTENT(IN) :: opArg3

type ( op_arg ) , DIMENSION(3) :: opArgArray
INTEGER(kind=4) :: numberOfOpDats
INTEGER(kind=4) :: n_upper
type ( op_set_core ) , POINTER :: opSetCore

real(8), POINTER, DIMENSION(:) :: opDat1Local
INTEGER(kind=4) :: opDat1Cardinality

real(8), POINTER, DIMENSION(:) :: opDat2Local
INTEGER(kind=4) :: opDat2Cardinality

real(8), POINTER, DIMENSION(:) :: opDat3Local
INTEGER(kind=4) :: opDat3Cardinality

INTEGER(kind=4) :: threadID
INTEGER(kind=4) :: numberOfThreads
INTEGER(kind=4), DIMENSION(1:8) :: timeArrayStart
INTEGER(kind=4), DIMENSION(1:8) :: timeArrayEnd
REAL(kind=8) :: startTime
REAL(kind=8) :: endTime
INTEGER(kind=4) :: returnSetKernelTiming
INTEGER(kind=4) :: sliceStart
INTEGER(kind=4) :: sliceEnd
REAL(kind=4) :: dataTransfer


INTEGER(kind=4) :: i1,i2,n

numberOfOpDats = 3

opArgArray(1) = opArg1
opArgArray(2) = opArg2
opArgArray(3) = opArg3

returnSetKernelTiming = setKernelTime(5 , userSubroutine//C_NULL_CHAR, &
& 0.d0, 0.00000,0.00000, 0)
call op_timers_core(startTime)

n_upper = op_mpi_halo_exchanges(set%setCPtr,numberOfOpDats,opArgArray)


  numberOfThreads = omp_get_max_threads()

  opSetCore => set%setPtr

  opDat1Cardinality = opArg1%dim * getSetSizeFromOpArg(opArg1)
  opDat2Cardinality = opArg2%dim * getSetSizeFromOpArg(opArg2)
  opDat3Cardinality = opArg3%dim * getSetSizeFromOpArg(opArg3)
  CALL c_f_pointer(opArg1%data,opDat1Local,(/opDat1Cardinality/))
  CALL c_f_pointer(opArg2%data,opDat2Local,(/opDat2Cardinality/))
  CALL c_f_pointer(opArg3%data,opDat3Local,(/opDat3Cardinality/))


  !$OMP PARALLEL DO private (sliceStart,sliceEnd,i1,threadID)
  DO i1 = 0, numberOfThreads-1, 1
    sliceStart = opSetCore%size * i1 / numberOfThreads
    sliceEnd = opSetCore%size * (i1 + 1) / numberOfThreads
    threadID = omp_get_thread_num()
! kernel call
    CALL op_wrap_a_eq_b_over_c( &
    & opDat1Local, &
    & opDat2Local, &
    & opDat3Local, &
    & sliceStart, sliceEnd)
  END DO
  !$OMP END PARALLEL DO
  IF ((n_upper .EQ. 0) .OR. (n_upper .EQ. opSetCore%core_size)) THEN
    CALL op_mpi_wait_all(numberOfOpDats,opArgArray)
  END IF

  CALL op_mpi_set_dirtybit(numberOfOpDats,opArgArray)

  call op_timers_core(endTime)

  dataTransfer = 0.0
  dataTransfer = dataTransfer + opArg1%size * getSetSizeFromOpArg(opArg1) * 2.d0
  dataTransfer = dataTransfer + opArg2%size * getSetSizeFromOpArg(opArg2)
  dataTransfer = dataTransfer + opArg3%size * getSetSizeFromOpArg(opArg3)
  returnSetKernelTiming = setKernelTime(5 , userSubroutine//C_NULL_CHAR, &
  & endTime-startTime, dataTransfer, 0.00000, 1)
END SUBROUTINE
END MODULE