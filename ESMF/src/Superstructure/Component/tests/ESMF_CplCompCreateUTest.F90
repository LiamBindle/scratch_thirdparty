! $Id: ESMF_CplCompCreateUTest.F90,v 1.1.5.1 2013-01-11 20:23:44 mathomp4 Exp $
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
      program ESMF_CplCompCreateUTest

!------------------------------------------------------------------------------

#include "ESMF.h"
#include "ESMF_Macros.inc"

!==============================================================================
!BOP
! !PROGRAM: ESMF_CplCompCreateUTest - Unit test for Components.
!
! !DESCRIPTION:
! Tests, cursory and exahustive, for Coupler Component Create code.
!
!-------------------------------------------------------------------------
!
! !USES:
    use ESMF_TestMod     ! test methods
    use ESMF
    implicit none
    
!   ! Local variables
    integer :: rc
    character(ESMF_MAXSTR) :: cplname
    type(ESMF_CplComp) :: cpl, cplcompAlias
    logical:: cplcompBool

    ! individual test failure message
    character(ESMF_MAXSTR) :: failMsg
    character(ESMF_MAXSTR) :: name
    integer :: result = 0
    
    ! Internal State Variables
    type testData
    sequence
	integer :: testNumber
    end type

    type dataWrapper
    sequence
	type(testData), pointer :: p
    end type
    
#ifdef ESMF_TESTEXHAUSTIVE
    logical :: bool
    type(ESMF_VM) :: vm
    type(ESMF_CplComp) :: cpl2
    integer :: localPet
    character(ESMF_MAXSTR) :: cname, bname
    type (dataWrapper) :: wrap1, wrap2
    type(testData), target :: data1, data2
    logical         :: isPresent
#endif

!-------------------------------------------------------------------------------
!   The unit tests are divided into Sanity and Exhaustive. The Sanity tests are
!   always run. When the environment variable, EXHAUSTIVE, is set to ON then
!   the EXHAUSTIVE and sanity tests both run. If the EXHAUSTIVE variable is set
!   to OFF, then only the sanity unit tests.
!   Special strings (Non-exhaustive and exhaustive) have been
!   added to allow a script to count the number and types of unit tests.
!-------------------------------------------------------------------------------
        
   ! Initialize framework
   call ESMF_TestStart(ESMF_SRCLINE, rc=rc)

    !------------------------------------------------------------------------
    !NEX_UTest
    cplname = "One Way Coupler"
    cpl = ESMF_CplCompCreate(name=cplname, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a Coupler Component Test"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !NEX_UTest
    write(name, *) "CplComp equality before assignment Test"
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    cplcompBool = (cplcompAlias.eq.cpl)
    call ESMF_Test(.not.cplcompBool, name, failMsg, result, ESMF_SRCLINE)
    
    !------------------------------------------------------------------------
    !NEX_UTest
    ! Testing ESMF_CplCompAssignment(=)()
    write(name, *) "CplComp assignment and equality Test"
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    cplcompAlias = cpl
    cplcompBool = (cplcompAlias.eq.cpl)
    call ESMF_Test(cplcompBool, name, failMsg, result, ESMF_SRCLINE)
    
    !------------------------------------------------------------------------
    !NEX_UTest
    write(name, *) "CplCompDestroy Test"
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    call ESMF_CplCompDestroy(cpl, rc=rc)
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
    
    !------------------------------------------------------------------------
    !NEX_UTest
    ! Testing ESMF_CplCompOperator(==)()
    write(name, *) "CplComp equality after destroy Test"
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    cplcompBool = (cplcompAlias==cpl)
    call ESMF_Test(.not.cplcompBool, name, failMsg, result, ESMF_SRCLINE)
    
    !------------------------------------------------------------------------
    !NEX_UTest
    ! Testing ESMF_CplCompOperator(/=)()
    write(name, *) "CplComp non-equality after destroy Test"
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    cplcompBool = (cplcompAlias/=cpl)
    call ESMF_Test(cplcompBool, name, failMsg, result, ESMF_SRCLINE)
    
    !------------------------------------------------------------------------
    !NEX_UTest
    write(name, *) "Double CplCompDestroy through alias Test"
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    call ESMF_CplCompDestroy(cplcompAlias, rc=rc)
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !NEX_UTest
    cplname = "One Way Coupler"
    cpl = ESMF_CplCompCreate(name=cplname, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a Coupler Component Test"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !NEX_UTest
    write(name, *) "CplCompDestroy Test"
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    call ESMF_CplCompDestroy(cpl, rc=rc)
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
    
#ifdef ESMF_TESTEXHAUSTIVE
!-------------------------------------------------------------------------

    !------------------------------------------------------------------------
    !EX_UTest
    ! Query the run status of a deleted Coupler Component
    bool = ESMF_CplCompIsPetLocal(cpl, rc=rc)
    write(failMsg, *) "Did not return ESMF_RC_OBJ_DELETED"
    write(name, *) "Query run status of a deleted Coupler Component"
    call ESMF_Test((rc.eq.ESMF_RC_OBJ_DELETED), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !EX_UTest
    ! Verify that the run status is false
    write(failMsg, *) "Did not return false"
    write(name, *) "Query run status of a deleted Coupler Component"
    call ESMF_Test((.not.bool), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !EX_UTest
    ! Create a Coupler Component with a negative number in the petlist
    ! to force an error.
    cname = "CplComp with out of range PetList"
    cpl2 = ESMF_CplCompCreate(name=cname, petList=(/0,-3/), rc=rc)
    write(failMsg, *) "Did not return ESMF_RC_ARG_VALUE"
    write(name, *) "Creating a Coupler Component with a negative number in petList"
    call ESMF_Test((rc.eq.ESMF_RC_ARG_VALUE), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !EX_UTest
    ! Create a Coupler Component setting with an out of range petlist
    ! to force an error.
    cname = "CplComp with out of range PetList"
    cpl2 = ESMF_CplCompCreate(name=cname, petList=(/0,2,5,8/), rc=rc)
    write(failMsg, *) "Did not return ESMF_RC_ARG_VALUE"
    write(name, *) "Creating a Coupler Component with out of range petList"
    call ESMF_Test((rc.eq.ESMF_RC_ARG_VALUE), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !EX_UTest
    ! Query the run status of a Gridded Component
    bool = ESMF_CplCompIsPetLocal(cpl2, rc=rc)
    write(failMsg, *) "Did not return ESMF_RC_OBJ_NOT_CREATED"
    write(name, *) "Query run status of a non- created Gridded Component"
    ! most compilers return "ESMF_RC_OBJ_NOT_CREATED
    ! pgi returns "ESMF_RC_OBJ_BAD"
    call ESMF_Test(((rc.eq.ESMF_RC_OBJ_NOT_CREATED).or.(rc.eq.ESMF_RC_OBJ_BAD)), &
                                name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !EX_UTest
    ! Test creation of a Component
    cplname = "One Way Coupler"
    cpl = ESMF_CplCompCreate(name=cplname, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a Coupler Component Test"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !EX_UTest
    ! Query clockIsPresent
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Query clockIsPresent bit for Clock that was not set Test"
    call ESMF_CplCompGet(cpl, clockIsPresent=isPresent, rc=rc)
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !EX_UTest
    ! Verify clockIsPresent
    write(failMsg, *) "Did not verify"
    write(name, *) "Verify clockIsPresent for Clock that was not set Test"
    call ESMF_Test((.not.isPresent), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !EX_UTest
    ! Query the run status of a Coupler Component
    bool = ESMF_CplCompIsPetLocal(cpl, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Query run status of a Coupler Component"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !------------------------------------------------------------------------
    !EX_UTest
    ! Verify that the run status is true
    write(failMsg, *) "Did not return true"
    write(name, *) "Query run status of a Coupler Component"
    call ESMF_Test((bool), name, failMsg, result, ESMF_SRCLINE)

!-------------------------------------------------------------------------
!   !
    !EX_UTest
!   !  Test validate a Coupler Component

    call ESMF_CplCompValidate(cpl, rc=rc)

    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Validating a Coupler Component Test"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
!-------------------------------------------------------------------------
!   !
    !EX_UTest
!   !  Test get a Coupler Component name

    call ESMF_CplCompGet(cpl, name=bname, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Getting  a Coupler Component name Test"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


!-------------------------------------------------------------------------
!   !
    !EX_UTest
!   !  Verify the name is correct
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Verifying the correct Component name was returned Test"
    call ESMF_Test((bname.eq."One Way Coupler"), name, failMsg, result, ESMF_SRCLINE)

!-------------------------------------------------------------------------
!   !
    !EX_UTest
!   !  Test Set a Coupler Component name
    cname = "Two Way Coupler"
    call ESMF_CplCompSet(cpl, name=cname, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Setting  a Coupler Component name Test"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

!-------------------------------------------------------------------------
!   !
    !EX_UTest
!   !  Test get a Coupler Component name
    call ESMF_CplCompGet(cpl, name=bname, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Getting  a Coupler Component name Test"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


!-------------------------------------------------------------------------
!   !
    !EX_UTest
!   !  Verify the name is correct
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Verifying the correct Component name was returned Test"
    call ESMF_Test((bname.eq."Two Way Coupler"), name, failMsg, result, ESMF_SRCLINE)


!-------------------------------------------------------------------------
!   !  Set Internal State
    !EX_UTest
    data1%testnumber=4567
    wrap1%p=>data1

    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Set Internal State Test"
    call ESMF_CplCompSetInternalState(cpl, wrap1, rc)
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

!-------------------------------------------------------------------------
!   !
!   !  Get Internal State
    !EX_UTest

    !wrap2%p=>data2
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Get Internal State Test"
    call ESMF_CplCompGetInternalState(cpl, wrap2, rc)
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

!-------------------------------------------------------------------------
!   !
!   !  Verify Internal State
    !EX_UTest
    data2 = wrap2%p
    write(failMsg, *) "Did not return correct data"
    write(name, *) "Verify Internal State Test"
    call ESMF_Test((data2%testnumber.eq.4567), name, failMsg, result, ESMF_SRCLINE)
    print *, "data2%testnumber = ", data2%testnumber
!-------------------------------------------------------------------------
!   !
    !EX_UTest
!   !  Test printing a component

    call ESMF_CplCompPrint(cpl, rc=rc)

    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Printing a Coupler Component Test"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

!-------------------------------------------------------------------------
!   !
    !EX_UTest
    ! Wait for a concurrent component to finish executing.

    call ESMF_CplCompWait(cpl, rc=rc)

    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Wait for a Coupler Component Test"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
!-------------------------------------------------------------------------
!   !
    !EX_UTest
!   !  Destroying a component

    call ESMF_CplCompDestroy(cpl, rc=rc)

    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Destroying a Coupler Component Test"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

#endif

    call ESMF_TestEnd(result, ESMF_SRCLINE)

    end program ESMF_CplCompCreateUTest
    
