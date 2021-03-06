! $Id: ESMF_ArrayCreateGetUTest.F90,v 1.1.5.1 2013-01-11 20:23:43 mathomp4 Exp $
!
! Earth System Modeling Framework
! Copyright 2002-2012, University Corporation for Atmospheric Research,
! Massachusetts Institute of Technology, Geophysical Fluid Dynamics
! Laboratory, University of Michigan, National Centers for Environmental
! Prediction, Los Alamos National Laboratory, Argonne National Laboratory,
! NASA Goddard Space Flight Center.
! Licensed under the University of Illinois-NCSA License.
!
!==============================================================================
!
program ESMF_ArrayCreateGetUTest

!------------------------------------------------------------------------------
 
#include "ESMF_Macros.inc"
#include "ESMF.h"

!==============================================================================
!BOP
! !PROGRAM: ESMF_ArrayCreateGetUTest - This unit test file tests ArrayCreate()
!   and ArrayGet() methods.
! !DESCRIPTION:
!
! The code in this file drives Fortran ArrayCreate(), ArrayGet() unit tests.
! The companion file ESMF\_Array.F90 contains the definitions for the
! Array methods.
!
!-----------------------------------------------------------------------------
! !USES:
  use ESMF_TestMod     ! test methods
  use ESMF

  implicit none

!------------------------------------------------------------------------------
! The following line turns the CVS identifier string into a printable variable.
  character(*), parameter :: version = &
    '$Id: ESMF_ArrayCreateGetUTest.F90,v 1.1.5.1 2013-01-11 20:23:43 mathomp4 Exp $'
!------------------------------------------------------------------------------

  ! cumulative result: count failures; no failures equals "all pass"
  integer :: result = 0

  ! individual test result code
  integer :: rc

  ! individual test failure message
  character(ESMF_MAXSTR) :: failMsg
  character(ESMF_MAXSTR) :: name

  !LOCAL VARIABLES:
  type(ESMF_VM):: vm
  integer:: petCount, localPet
  type(ESMF_ArraySpec):: arrayspec, arrayspec2
  type(ESMF_Array):: array, arrayAlias, arrayCpy, arrayUnInit
  type(ESMF_DistGrid):: distgrid, distgrid2
  real(ESMF_KIND_R8)      :: farray1D(10)
  real(ESMF_KIND_R8)      :: farray2D(10,10)
  real(ESMF_KIND_R4)      :: farray3D(10,10,10)
  integer(ESMF_KIND_I4)   :: farray4D(10,10,10,10)
  real(ESMF_KIND_R8), pointer     :: farrayPtr1D(:)
  real(ESMF_KIND_R8), pointer     :: farrayPtr2D(:,:)
  real(ESMF_KIND_R4), pointer     :: farrayPtr3D(:,:,:)
  real(ESMF_KIND_R4), pointer     :: farrayPtr3Dx(:,:,:)
  integer(ESMF_KIND_I4), pointer  :: farrayPtr4D(:,:,:,:)
  character (len=80)      :: arrayName
  integer, allocatable:: totalLWidth(:,:), totalUWidth(:,:)
  integer, allocatable:: totalLBound(:,:), totalUBound(:,:)
  integer, allocatable:: computationalLWidth(:,:), computationalUWidth(:,:)
  logical:: arrayBool
    
  integer:: count
  
  

!-------------------------------------------------------------------------------
! The unit tests are divided into Sanity and Exhaustive. The Sanity tests are
! always run. When the environment variable, EXHAUSTIVE, is set to ON then 
! the EXHAUSTIVE and sanity tests both run. If the EXHAUSTIVE variable is set
! to OFF, then only the sanity unit tests.
! Special strings (Non-exhaustive and exhaustive) have been
! added to allow a script to count the number and types of unit tests.
!------------------------------------------------------------------------------- 

  !------------------------------------------------------------------------
  call ESMF_TestStart(ESMF_SRCLINE, rc=rc)  ! calls ESMF_Initialize() internally
  !------------------------------------------------------------------------
  
  !------------------------------------------------------------------------
  ! preparations
  call ESMF_VMGetGlobal(vm, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  call ESMF_VMGet(vm, localPet=localPet, petCount=petCount, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  
  !------------------------------------------------------------------------
  ! this unit test requires to be run on exactly 4 PETs
  if (petCount /= 4) goto 10

  !------------------------------------------------------------------------
  ! DistGrid preparation
  distgrid = ESMF_DistGridCreate(minIndex=(/1,1/), maxIndex=(/15,23/), &
    regDecomp=(/2,2/), rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate Allocate 2D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(typekind=ESMF_TYPEKIND_R8, distgrid=distgrid, &
    indexflag=ESMF_INDEX_GLOBAL, name="MyArray", rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "Array equality before assignment Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  arrayBool = (arrayAlias.eq.array)
  call ESMF_Test(.not.arrayBool, name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  ! Testing ESMF_ArrayAssignment(=)()
  write(name, *) "Array assignment and equality Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  arrayAlias = array
  arrayBool = (arrayAlias.eq.array)
  call ESMF_Test(arrayBool, name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  ! Testing ESMF_ArrayOperator(==)()
  write(name, *) "Array equality after destroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  arrayBool = (arrayAlias==array)
  call ESMF_Test(.not.arrayBool, name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  ! Testing ESMF_ArrayOperator(/=)()
  write(name, *) "Array non-equality after destroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  arrayBool = (arrayAlias/=array)
  call ESMF_Test(arrayBool, name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "Double ArrayDestroy through alias Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(arrayAlias, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate Allocate 2D ESMF_TYPEKIND_R8 rank inconsistency Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(typekind=ESMF_TYPEKIND_R8, distgrid=distgrid, &
    indexflag=ESMF_INDEX_GLOBAL, undistLBound=(/0/), undistUBound=(/2,2/), &
    name="MyArray", rc=rc)
  call ESMF_Test((rc.ne.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate Allocate 2D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(typekind=ESMF_TYPEKIND_R8, distgrid=distgrid, &
    indexflag=ESMF_INDEX_GLOBAL, name="MyArray", rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArraySet Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArraySet(array, name="MyArrayNewName", rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  ! ArraySpec preparation
  call ESMF_ArraySpecSet(arrayspec, typekind=ESMF_TYPEKIND_R8, rank=2, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate Allocate 2D ESMF_TYPEKIND_R8 Test w/ ArraySpec"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(arrayspec=arrayspec, distgrid=distgrid, &
    indexflag=ESMF_INDEX_GLOBAL, name="MyArray", rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayPrint 2D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet name, 2D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, arrayspec=arrayspec2, name=arrayName, rc=rc)
  print *, "Array name: ", arrayname
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet Fortran array pointer, 2D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=farrayPtr2D, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "Getting Attribute count from an Array"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_AttributeGet(array, count, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "Verify Attribute count from an Array"
  write(failMsg, *) "Incorrect count"
  call ESMF_Test((count.eq.0), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate from Copy, uninitialized Array Test"
  write(failMsg, *) "Incorrectly returned ESMF_SUCCESS"
  arrayCpy = ESMF_ArrayCreate(arrayUnInit, rc=rc)
  call ESMF_Test((rc /= ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate from Copy, 2D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  arrayCpy = ESMF_ArrayCreate(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayPrint from Copy after original destroy, 2D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(arrayCpy, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy of Copy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(arrayCpy, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate from Ptr with 3D farray on 2D DistGrid Test as Ptr"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  allocate(farrayPtr3D(-2:6,12,3:10))
  array = ESMF_ArrayCreate(farrayPtr=farrayPtr3D, distgrid=distgrid, &
    name="MyArray", rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayPrint for ArrayCreate from Ptr Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=farrayPtr3Dx, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "Deallocate returned pointer Test"
  write(failMsg, *) "Did not return success"
  deallocate(farrayPtr3Dx, stat=rc)
  call ESMF_Test((rc.eq.0), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate with 3D farray on 2D DistGrid Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  allocate(farrayPtr3D(8,12,10))
  array = ESMF_ArrayCreate(farray=farrayPtr3D, distgrid=distgrid, &
    indexflag=ESMF_INDEX_GLOBAL, name="MyArray", rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  deallocate(farrayPtr3D)
  nullify(farrayPtr3D)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate with 3D farray on 2D DistGrid w/ ESMF_DATACOPY_VALUE Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  allocate(farrayPtr3D(8,12,10))
  array = ESMF_ArrayCreate(farray=farrayPtr3D, distgrid=distgrid, &
    indexflag=ESMF_INDEX_GLOBAL, name="MyArray", datacopyflag=ESMF_DATACOPY_VALUE, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  deallocate(farrayPtr3D)
  nullify(farrayPtr3D)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate with 3D farrayPtr on 2D DistGrid w/ ESMF_DATACOPY_VALUE Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  allocate(farrayPtr3D(8,12,10))
  array = ESMF_ArrayCreate(farrayPtr=farrayPtr3D, distgrid=distgrid, &
    name="MyArray", datacopyflag=ESMF_DATACOPY_VALUE, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  deallocate(farrayPtr3D)
  nullify(farrayPtr3D)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate with 3D farray on 2D DistGrid w/ distgridToArrayMap Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  allocate(farrayPtr3D(12,13,10))
  array = ESMF_ArrayCreate(farray=farrayPtr3D, distgrid=distgrid, &
    distgridToArrayMap=(/2,1/), computationalLWidth=(/0,5/), &
    indexflag=ESMF_INDEX_GLOBAL, name="MyArray", rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  deallocate(farrayPtr3D)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate Allocate 2D ESMF_TYPEKIND_R8 w/ negative computational widths Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(arrayspec=arrayspec, distgrid=distgrid, &
    indexflag=ESMF_INDEX_GLOBAL, computationalLWidth=(/-1,-1/), &
    computationalUWidth=(/-2,-3/), name="MyArray Negative", rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayPrint 2D ESMF_TYPEKIND_R8 w/ computational widths Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate Allocate 2D ESMF_TYPEKIND_R8 w/ computationalEdge widths Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(arrayspec=arrayspec, distgrid=distgrid, &
    indexflag=ESMF_INDEX_GLOBAL, computationalEdgeLWidth=(/0,-1/), &
    computationalEdgeUWidth=(/-2,+1/), name="MyArray Negative Edge", rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayPrint 2D ESMF_TYPEKIND_R8 w/ computationalEdge widths Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet 2D ESMF_TYPEKIND_R8 w/ computationalEdge widths Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  allocate(totalLWidth(2,1))
  allocate(totalUWidth(2,1))
  allocate(computationalLWidth(2,1))
  allocate(computationalUWidth(2,1))
  call ESMF_ArrayGet(array, totalLWidth=totalLWidth, totalUWidth=totalUWidth, &
    computationalLWidth=computationalLWidth, &
    computationalUWidth=computationalUWidth, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "Check total widths for 2D ESMF_TYPEKIND_R8 w/ computationalEdge widths Test"
  write(failMsg, *) "Total widths are wrong"
  call ESMF_Test((totalLWidth(1,1)==max(0,computationalLWidth(1,1))&
    .and.totalLWidth(2,1)==max(0,computationalLWidth(2,1))&
    .and.totalUWidth(1,1)==max(0,computationalUWidth(1,1))&
    .and.totalUWidth(2,1)==max(0,computationalUWidth(2,1))), &
    name, failMsg, result, ESMF_SRCLINE)
  deallocate(totalLWidth, totalUWidth)
  deallocate(computationalLWidth, computationalUWidth)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate Allocate 2D ESMF_TYPEKIND_R8 w/ computationalEdge and total widths Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(arrayspec=arrayspec, distgrid=distgrid, &
    indexflag=ESMF_INDEX_GLOBAL, computationalEdgeLWidth=(/0,-1/), &
    computationalEdgeUWidth=(/-2,+1/), totalLWidth=(/1,2/), totalUWidth=(/3,4/),&
    name="MyArray Negative Edge", rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayPrint 2D ESMF_TYPEKIND_R8 w/ computationalEdge and total widths Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet 2D ESMF_TYPEKIND_R8 w/ computationalEdge and total widths Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  allocate(totalLWidth(2,1))
  allocate(totalUWidth(2,1))
  allocate(totalLBound(2,1))
  allocate(totalUBound(2,1))
  call ESMF_ArrayGet(array, totalLWidth=totalLWidth, totalUWidth=totalUWidth, &
    totalLBound=totalLBound, totalUBound=totalUBound, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "Check total widths for 2D ESMF_TYPEKIND_R8 w/ computationalEdge and total widths Test"
  write(failMsg, *) "Total widths are wrong"
  call ESMF_Test((totalLWidth(1,1)==1.and.totalLWidth(2,1)==2.and.&
    totalUWidth(1,1)==3.and.totalUWidth(2,1)==4), &
    name, failMsg, result, ESMF_SRCLINE)
  deallocate(totalLWidth, totalUWidth)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "Check total bounds for 2D ESMF_TYPEKIND_R8 w/ computationalEdge and total widths Test"
  write(failMsg, *) "Total bounds are wrong"
  if (localPet==0) then
    call ESMF_Test((totalLBound(1,1)==0.and.totalLBound(2,1)==-1.and.&
    totalUBound(1,1)==11.and.totalUBound(2,1)==16), &
      name, failMsg, result, ESMF_SRCLINE)
  else if (localPet==1) then
    call ESMF_Test((totalLBound(1,1)==8.and.totalLBound(2,1)==-1.and.&
    totalUBound(1,1)==18.and.totalUBound(2,1)==16), &
      name, failMsg, result, ESMF_SRCLINE)
  else if (localPet==2) then
    call ESMF_Test((totalLBound(1,1)==0.and.totalLBound(2,1)==11.and.&
    totalUBound(1,1)==11.and.totalUBound(2,1)==27), &
      name, failMsg, result, ESMF_SRCLINE)
  else if (localPet==3) then
    call ESMF_Test((totalLBound(1,1)==8.and.totalLBound(2,1)==11.and.&
    totalUBound(1,1)==18.and.totalUBound(2,1)==27), &
      name, failMsg, result, ESMF_SRCLINE)
  endif  
  deallocate(totalLBound, totalUBound)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  ! cleanup  
  call ESMF_DistGridDestroy(distgrid, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  
  ! test validate code
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "DistGrid Validate of non-created DistGrid Test"
  write(failMsg, *) "Did not return ESMF_RC_OBJ_NOT_CREATED"
  call ESMF_DistGridValidate(distgrid2, rc=rc)
  call ESMF_Test((rc.eq.ESMF_RC_OBJ_NOT_CREATED), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "DistGrid create DistGrid Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  distgrid2 = ESMF_DistGridCreate(minIndex=(/1/), maxIndex=(/40/), rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "DistGrid Validate of created DistGrid Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_DistGridValidate(distgrid2, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "DistGrid destroy DistGrid Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_DistGridDestroy(distgrid2, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "DistGrid Validate of destroyed DistGrid Test"
  write(failMsg, *) "Did not return ESMF_RC_OBJ_DELETED"
  call ESMF_DistGridValidate(distgrid2, rc=rc)
  call ESMF_Test((rc.eq.ESMF_RC_OBJ_DELETED), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  ! preparations
  distgrid = ESMF_DistGridCreate(minIndex=(/1/), maxIndex=(/40/), rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate AssmdShape 1D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(farray=farray1D, distgrid=distgrid, &
    indexflag=ESMF_INDEX_DELOCAL, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet Fortran array pointer, 1D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=farrayPtr1D, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet w/ incompatible Fortran array pointer, 1D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=farrayPtr2D, rc=rc)
  call ESMF_Test((rc.ne.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayPrint AssmdShape 1D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate AssmdShape 1D ESMF_TYPEKIND_R8 w/ negative computationalEdge widths Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(farray=farray1D, distgrid=distgrid, &
    indexflag=ESMF_INDEX_DELOCAL, computationalEdgeLWidth=(/-1/), &
    computationalEdgeUWidth=(/-1/), rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayPrint AssmdShape 1D ESMF_TYPEKIND_R8 w/ negative computationalEdge widths Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  ! cleanup  
  call ESMF_DistGridDestroy(distgrid, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  
  !------------------------------------------------------------------------
  ! preparations
  distgrid = ESMF_DistGridCreate(minIndex=(/1,1/), maxIndex=(/40,10/), rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate AssmdShape 2D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(farray=farray2D, distgrid=distgrid, &
    indexflag=ESMF_INDEX_DELOCAL, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet Fortran array pointer, 2D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=farrayPtr2D, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet w/ incompatible Fortran array pointer, 2D ESMF_TYPEKIND_R8 Test"
  write(failMsg, *) "Did return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=farrayPtr3D, rc=rc)
  call ESMF_Test((rc.ne.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  ! cleanup  
  call ESMF_DistGridDestroy(distgrid, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  
  !------------------------------------------------------------------------
  ! preparations
  distgrid = ESMF_DistGridCreate(minIndex=(/1,1,1/), maxIndex=(/40,10,10/), &
    rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate AssmdShape 3D ESMF_TYPEKIND_R4 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(farray=farray3D, distgrid=distgrid, &
    indexflag=ESMF_INDEX_DELOCAL, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet Fortran array pointer, 3D ESMF_TYPEKIND_R4 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=farrayPtr3D, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  ! cleanup  
  call ESMF_DistGridDestroy(distgrid, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  
  !------------------------------------------------------------------------
  ! preparations
  distgrid = ESMF_DistGridCreate(minIndex=(/1,1,1,1/), &
    maxIndex=(/40,10,10,10/), rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayCreate AssmdShape 4D ESMF_TYPEKIND_I4 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(farray=farray4D, distgrid=distgrid, &
    indexflag=ESMF_INDEX_DELOCAL, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayGet Fortran array pointer, 4D ESMF_TYPEKIND_I4 Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=farrayPtr4D, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
    
  !------------------------------------------------------------------------
  !NEX_UTest_Multi_Proc_Only
  write(name, *) "ArrayDestroy Test"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

  !------------------------------------------------------------------------
  ! cleanup  
  call ESMF_DistGridDestroy(distgrid, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  
10 continue
  !------------------------------------------------------------------------
  call ESMF_TestEnd(result, ESMF_SRCLINE) ! calls ESMF_Finalize() internally
  !------------------------------------------------------------------------

end program ESMF_ArrayCreateGetUTest
