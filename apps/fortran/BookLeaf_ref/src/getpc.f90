
!Crown Copyright 2014 AWE.
!
! This file is part of Bookleaf.
!
! Bookleaf is free software: you can redistribute it and/or modify it under
! the terms of the GNU General Public License as published by the
! Free Software Foundation, either version 3 of the License, or (at your option)
! any later version.
!
! Bookleaf is distributed in the hope that it will be useful, but
! WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
! FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
! details.
!
! You should have received a copy of the GNU General Public License along with
! Bookleaf. If not, see http://www.gnu.org/licenses/.

MODULE getpc_mod

  IMPLICIT NONE

  PUBLIC :: getpc

CONTAINS

  SUBROUTINE getpc(d_rho,d_ein,d_pre,d_csqrd)

    USE kinds_mod,    ONLY: ink,rlk
    USE eos_mod,      ONLY: getpre,getcc
    USE timing_mod,   ONLY: bookleaf_times
    USE TYPH_util_mod,ONLY: get_time
    use parameters_mod, ONLY: LI
    use OP2_Fortran_Reference
    use, intrinsic :: ISO_C_BINDING
    USE op2_bookleaf, ONLY: s_elements, &
&                           d_ielmat
    USE getpc_kernels
    use integers_mod, ONLY: eos_type
    use reals_mod, ONLY: eos_param

    ! Argument list
    type(op_dat), INTENT(INOUT) :: d_rho,d_ein,d_pre,d_csqrd
    ! Local
    REAL(KIND=rlk)                               :: t0,t1

    ! Timer
    t0=get_time()

    !# Missing code here that can't be merged

    ! update pressure and sound speed
    call op_par_loop_7(getpc_update,s_elements, &
&           op_arg_dat(d_ielmat, -1,OP_ID,1,'integer(4)',OP_READ), &    
&           op_arg_gbl(eos_type, LI, 'integer(4)',OP_READ), &
&           op_arg_gbl(eos_param, 6*LI, 'real(8)',OP_READ), &
&           op_arg_dat(d_rho,    -1,OP_ID,1,'real(8)',OP_READ), &
&           op_arg_dat(d_ein,    -1,OP_ID,1,'real(8)',OP_READ), &
&           op_arg_dat(d_pre,    -1,OP_ID,1,'real(8)',OP_WRITE), &
&           op_arg_dat(d_csqrd,  -1,OP_ID,1,'real(8)',OP_WRITE))
    ! correct negative sound speeds
    call op_par_loop_1(getpc_merge,s_elements, &
&           op_arg_dat(d_csqrd,-1,OP_ID,1,'real(8)',OP_RW))

    !# Missing code here that can't be merged

    ! Timing data
    t1=get_time()
    t1=t1-t0
    bookleaf_times%time_in_eos=bookleaf_times%time_in_eos+t1

  END SUBROUTINE getpc

END MODULE getpc_mod
