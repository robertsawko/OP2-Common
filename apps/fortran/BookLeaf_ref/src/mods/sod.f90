
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


SUBROUTINE modify()

  USE kinds_mod,   ONLY: ink,rlk
  USE pointers_mod,ONLY: ndx,ndy,ielmat,ielnod,rho,pre,ein,elvol,cnwt,  &
&                        elmass,cnmass,spmass
  USE integers_mod,ONLY: nel,nnod
  USE reals_mod,   ONLY: eos_param
  USE logicals_mod,ONLY: zsp
  USE parameters_mod,ONLY: LI
  USE op2_bookleaf
  USE sod_kernels

  ! Local
  INTEGER(KIND=ink) :: inod,iel,ii,n1,n2,n3,n4
  REAL(KIND=rlk)    :: x1,x2,x3,x4,y1,y2,y3,y4,w1,w2,w3,w4,xmid

  ! find mid-point
  x1=ndx(1)
  x2=x1
  call op_par_loop_3(sod_midpoint, s_nodes, &
&         op_arg_dat(d_ndx,-1,OP_ID,1,'real(8)',OP_READ), &
&         op_arg_gbl(x1,1,'real(8)',OP_MIN), &
&         op_arg_gbl(x2,1,'real(8)',OP_MAX))
  xmid=0.5_rlk*(x1+x2)

  ! reset variables

  call op_par_loop_14(sod_reset,s_elements, &
&         op_arg_dat(d_ndx,1,m_el2node,1,'real(8)',OP_READ), &
&         op_arg_dat(d_ndx,2,m_el2node,1,'real(8)',OP_READ), &
&         op_arg_dat(d_ndx,3,m_el2node,1,'real(8)',OP_READ), &
&         op_arg_dat(d_ndx,4,m_el2node,1,'real(8)',OP_READ), &
&         op_arg_gbl(xmid,1,'real(8)',OP_READ), &
&         op_arg_dat(d_ielmat,-1,OP_ID,1,'integer(4)',OP_WRITE), &
&         op_arg_dat(d_rho,-1,OP_ID,1,'real(8)',OP_WRITE), &
&         op_arg_dat(d_pre,-1,OP_ID,1,'real(8)',OP_WRITE), &
&         op_arg_dat(d_ein,-1,OP_ID,1,'real(8)',OP_WRITE), &
&         op_arg_dat(d_elmass,-1,OP_ID,1,'real(8)',OP_WRITE), &
&         op_arg_dat(d_cnmass,-1,OP_ID,4,'real(8)',OP_WRITE), &
&         op_arg_gbl(eos_param,LI*6,'real(8)',OP_READ), &
&         op_arg_dat(d_elvol,-1,OP_ID,1,'real(8)',OP_READ), &
&         op_arg_dat(d_cnwt,-1,OP_ID,4,'real(8)',OP_READ))

  ! reset subzonal pressure mass
  IF (zsp) THEN
    call op_par_loop_10(sod_subz,s_elements, &
&            op_arg_dat(d_ndx, 1,m_el2node,1,'real(8)',OP_READ), &
&            op_arg_dat(d_ndx, 2,m_el2node,1,'real(8)',OP_READ), &
&            op_arg_dat(d_ndx, 3,m_el2node,1,'real(8)',OP_READ), &
&            op_arg_dat(d_ndx, 4,m_el2node,1,'real(8)',OP_READ), &
&            op_arg_dat(d_ndy, 1,m_el2node,1,'real(8)',OP_READ), &
&            op_arg_dat(d_ndy, 2,m_el2node,1,'real(8)',OP_READ), &
&            op_arg_dat(d_ndy, 3,m_el2node,1,'real(8)',OP_READ), &
&            op_arg_dat(d_ndy, 4,m_el2node,1,'real(8)',OP_READ), &
&            op_arg_dat(d_rho,-1,OP_ID    ,1,'real(8)',OP_READ), &
&            op_arg_dat(d_spmass,-1,OP_ID ,4,'real(8)',OP_WRITE))
!     DO iel=1,nel
!       n1=ielnod(1,iel)
!       n2=ielnod(2,iel)
!       n3=ielnod(3,iel)
!       n4=ielnod(4,iel)
!       x3=0.25_rlk*(ndx(n1)+ndx(n2)+ndx(n3)+ndx(n4))
!       y3=0.25_rlk*(ndy(n1)+ndy(n2)+ndy(n3)+ndy(n4))
!       DO inod=1,4
!         x1=ndx(ielnod(inod,iel))
!         y1=ndy(ielnod(inod,iel))
!         ii=MOD(inod,4)+1_ink
!         x2=0.5_rlk*(x1+ndx(ielnod(ii,iel)))
!         y2=0.5_rlk*(y1+ndy(ielnod(ii,iel)))
!         ii=MOD(inod+2,4)+1_ink
!         x4=0.5_rlk*(x1+ndx(ielnod(ii,iel)))
!         y4=0.5_rlk*(y1+ndy(ielnod(ii,iel)))
!         w1=-x1+x2+x3-x4
!         w2=-x1-x2+x3+x4
!         w3=-y1+y2+y3-y4
!         w4=-y1-y2+y3+y4
!         spmass(inod,iel)=rho(iel)*(w1*w4-w2*w3)
!       ENDDO
!     ENDDO
  ENDIF

END SUBROUTINE modify

