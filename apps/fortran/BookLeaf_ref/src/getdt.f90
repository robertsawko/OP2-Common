
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

MODULE getdt_mod

  IMPLICIT NONE

  PUBLIC :: getdt

CONTAINS

  SUBROUTINE getdt(dt)

    USE kinds_mod,       ONLY: rlk,ink
    USE reals_mod,       ONLY: ccut,zcut,cfl_sf,div_sf,dt_g,dt_min,     &
&                              dt_max
    USE integers_mod,    ONLY: nel,nshape,nnod,idtel
    USE logicals_mod,    ONLY: zdtnotreg,zmidlength
    USE paradef_mod,     ONLY: CommS,NProcW,zparallel
    USE pointers_mod,    ONLY: ielreg,rho,qq,csqrd,elx,ely,a1,a3,b1,b3, &
&                              ielnod,elvol,ndu,ndv
    USE scratch_mod,     ONLY: rscratch11,elu=>rscratch21,elv=>rscratch22
    USE geometry_mod,    ONLY: dlm,dln
    USE error_mod,       ONLY: halt
    USE utilities_mod,   ONLY: gather,gather2
    USE timing_mod,      ONLY: bookleaf_times
    USE TYPH_util_mod,   ONLY: get_time
    USE TYPH_Collect_mod,ONLY: TYPH_Gather
    USE op2_bookleaf, d_elu=>d_rscratch21,d_elv=>d_rscratch22
    USE getdt_kernels

    ! Argument list
    REAL(KIND=rlk),INTENT(INOUT)         :: dt
    ! Local
    INTEGER(KIND=ink)                    :: iel,ireg,ii,ierr
    REAL(KIND=rlk)                       :: w1,w2,dt_cfl,dt_div,t0,t1,t2,t3
    REAL(KIND=rlk),DIMENSION(0:NprocW-1) :: dtt

    ! Timer
    t0=get_time()

    idtel=0
    ! CFL
    call op_par_loop_8(getdt_cfl,s_elements, &
&           op_arg_dat(d_rscratch11,-1,OP_ID,1,'real(8)',OP_WRITE), &
&           op_arg_dat(d_rho,-1,OP_ID,1,'real(8)',OP_READ), &
&           op_arg_dat(d_csqrd,-1,OP_ID,1,'real(8)',OP_READ), &
&           op_arg_dat(d_qq,-1,OP_ID,1,'real(8)',OP_READ), &
&           op_arg_dat(d_elx,-1,OP_ID,4,'real(8)',OP_READ), &
&           op_arg_dat(d_ely,-1,OP_ID,4,'real(8)',OP_READ), &
&           op_arg_dat(d_zdtnotreg,1,m_el2reg,1,'integer(4)',OP_READ), &
&           op_arg_dat(d_zmidlength,1,m_el2reg,1,'integer(4)',OP_READ))


    ii=nel+1_ink
    w1=HUGE(1.0_rlk)
    call op_par_loop_2(getdt_minval,s_elements, &
&          op_arg_dat(d_rscratch11, -1, OP_ID,1,'real(8)',OP_READ), &
&          op_arg_gbl(w1,1,'real(8)',OP_MIN))
    call op_par_loop_4(getdt_minloc,s_elements, &
&          op_arg_dat(d_rscratch11, -1, OP_ID,1,'real(8)',OP_READ), &
&          op_arg_dat(d_elidx,      -1, OP_ID,1,'integer(4)',OP_READ), &
&          op_arg_gbl(w1,1,'real(8)',OP_READ), &
&          op_arg_gbl(ii,1,'integer(4)',OP_MIN))

    IF (w1.LT.0.0_rlk) CALL halt("ERROR: dt_cfl < 0",1)
    dt_cfl=cfl_sf*SQRT(w1)
    idtel=ii

    ! Divergence
    w2=TINY(1.0_rlk)
    CALL gather2(s_elements,m_el2node,d_ndu,d_elv)
    CALL gather2(s_elements,m_el2node,d_ndv,d_elu)
    call op_par_loop_8(getdt_div,s_elements, &
&          op_arg_dat(d_elu, -1, OP_ID,4,'real(8)',OP_READ), &
&          op_arg_dat(d_elv, -1, OP_ID,4,'real(8)',OP_READ), &
&          op_arg_dat(d_a1,  -1, OP_ID,1,'real(8)',OP_READ), &
&          op_arg_dat(d_a3,  -1, OP_ID,1,'real(8)',OP_READ), &
&          op_arg_dat(d_b1,  -1, OP_ID,1,'real(8)',OP_READ), &
&          op_arg_dat(d_b3,  -1, OP_ID,1,'real(8)',OP_READ), &
&          op_arg_dat(d_elvol,  -1, OP_ID,1,'real(8)',OP_READ), &
&          op_arg_gbl(w2,1,'real(8)',OP_MAX))

    dt_div=div_sf/w2

    !# Missing code here that can't be merged

    ! Find smallest timestep
    dt=MIN(dt_cfl,dt_div,dt_g*dt,dt_max)
    IF (zparallel) THEN
      t2=get_time()
      ierr=TYPH_Gather(dt,dtt,comm=CommS)
      t3=get_time()
      t3=t3-t2
      bookleaf_times%time_in_colls=bookleaf_times%time_in_colls+t3
      dt=MINVAL(dtt)
    ENDIF

    ! Check minimum
    IF (dt.LT.dt_min) CALL halt("ERROR: dt < dt_min",1,.true.)

    ! Timing data
    t1=get_time()
    t1=t1-t0
    bookleaf_times%time_in_getdt=bookleaf_times%time_in_getdt+t1

  END SUBROUTINE getdt

END MODULE getdt_mod
