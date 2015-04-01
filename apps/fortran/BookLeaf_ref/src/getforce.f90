
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

MODULE getforce_mod

  IMPLICIT NONE

  PUBLIC :: getforce

CONTAINS
  

  SUBROUTINE getforce(nshape,nel,dt,elx,ely,elu,elv,elfx,elfy,pre,rho,  &
&                     zflag,d_elx,d_ely,d_elu,d_elv,d_elfx,d_elfy,d_pre,d_rho)

    USE kinds_mod,    ONLY: ink,rlk,lok
    USE logicals_mod, ONLY: zhg,zsp
    USE pointers_mod, ONLY: a1,a3,b1,b3,qx,qy
    USE gethg_mod,    ONLY: gethg
    USE getsp_mod,    ONLY: getsp
    USE timing_mod,   ONLY: bookleaf_times
    USE TYPH_util_mod,ONLY: get_time
    USE OP2_Fortran_Reference
    use, intrinsic :: ISO_C_BINDING
    USE op2_bookleaf, ONLY: m_el2node,m_el2el,s_elements, &
&                           d_qx,d_qy,d_a1,d_a3,d_b1,d_b3
    USE getforce_kernels

    implicit none
    ! Argument list
    INTEGER(KIND=ink),                   INTENT(IN)  :: nshape,nel
    REAL(KIND=rlk),                      INTENT(IN)  :: dt
    REAL(KIND=rlk),DIMENSION(nshape,nel),INTENT(IN)  :: elx,ely,elu,elv
    REAL(KIND=rlk),DIMENSION(nshape,nel),INTENT(OUT) :: elfx,elfy
    REAL(KIND=rlk),DIMENSION(nel),       INTENT(IN)  :: pre,rho
    LOGICAL(KIND=lok),                   INTENT(IN)  :: zflag
    type(op_dat), INTENT(IN) :: d_elx,d_ely,d_elu,d_elv,d_elfx,d_elfy,d_pre,d_rho
    ! Local
    INTEGER(KIND=ink),PARAMETER                      :: istrip=48_ink
    INTEGER(KIND=ink)                                :: i0,i1,jj,jp,iel
    REAL(KIND=rlk)                                   :: w1,t0,t1

    ! Timer
    t0=get_time()

    ! Pressure force
    call op_par_loop_7(getforce_pres,s_elements, &
&                    op_arg_dat(d_pre, -1,OP_ID,1,'real(8)',OP_READ), &
&                    op_arg_dat(d_elfx, -1,OP_ID,4,'real(8)',OP_WRITE), &
&                    op_arg_dat(d_elfy, -1,OP_ID,4,'real(8)',OP_WRITE), &
&                    op_arg_dat(d_a1,-1,OP_ID,1,'real(8)',OP_READ), &
&                    op_arg_dat(d_a3,-1,OP_ID,1,'real(8)',OP_READ), &
&                    op_arg_dat(d_b1,-1,OP_ID,1,'real(8)',OP_READ), &
&                    op_arg_dat(d_b3,-1,OP_ID,1,'real(8)',OP_READ))

    ! Artificial viscosity force
    call op_par_loop_4(getforce_visc,s_elements, &
&                    op_arg_dat(d_elfx, -1,OP_ID,4,'real(8)',OP_RW), &
&                    op_arg_dat(d_elfy, -1,OP_ID,4,'real(8)',OP_RW), &
&                    op_arg_dat(d_qx,-1,OP_ID,4,'real(8)',OP_READ), &
&                    op_arg_dat(d_qy,-1,OP_ID,4,'real(8)',OP_READ))


    ! Subzonal pressure force
    IF (zsp) CALL getsp(nshape,nel,rho,elx,ely,elfx,elfy)

    !# Missing code here that can't be merged
    IF (zflag) THEN
      !# Missing code here that can't be merged
      ! Anti-hourglass force
      IF (zhg) CALL gethg(nshape,nel,dt,rho,elu,elv,elfx,elfy)
    ENDIF

    ! Timing data
    t1=get_time()
    t1=t1-t0
    bookleaf_times%time_in_getfrc=bookleaf_times%time_in_getfrc+t1

  END SUBROUTINE getforce

END MODULE getforce_mod
