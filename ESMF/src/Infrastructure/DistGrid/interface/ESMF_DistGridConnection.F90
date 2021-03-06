! $Id$
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
#define ESMF_FILENAME "ESMF_DistGridConnection.F90"
!==============================================================================
!
! ESMF DistGrid Module
module ESMF_DistGridConnectionMod
!
!==============================================================================
!
! This file contains the DistGridConnection shallow class implementation.
!
!------------------------------------------------------------------------------
! INCLUDES
#include "ESMF.h"

!==============================================================================
!BOPI
! !MODULE: ESMF_DistGridConnectionMod
!
!------------------------------------------------------------------------------

! !USES:
  use ESMF_UtilTypesMod           ! ESMF utility types
  use ESMF_InitMacrosMod          ! ESMF initializer macros
  use ESMF_LogErrMod              ! ESMF error handling
  use ESMF_F90InterfaceMod        ! ESMF F90-C++ interface helper
  
  implicit none

!------------------------------------------------------------------------------
! !PRIVATE TYPES:
  private

!------------------------------------------------------------------------------
! ! ESMF_DistGridConnection

  type ESMF_DistGridConnection
    sequence
    private
    integer :: connection(2*7+2)  ! reserve for maximum dimCount
    integer :: elementCount       ! number of actual elements in connection
    ESMF_INIT_DECLARE
  end type

!------------------------------------------------------------------------------
!
! !PUBLIC MEMBER FUNCTIONS:

! - ESMF-public methods:

  public ESMF_DistGridConnection
  public ESMF_DistGridConnectionSet
  public ESMF_InterfaceIntCreateDGConn
  

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

contains

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


! -------------------------- ESMF-public method -------------------------------
#undef  ESMF_METHOD
#define ESMF_METHOD "ESMF_DistGridConnectionInt()"
!BOPI
! !IROUTINE: ESMF_DistGridConnectionInt - Construct a DistGrid connection element
! !INTERFACE:
  subroutine ESMF_DistGridConnectionInt(connection, tileIndexA, tileIndexB, &
    positionVector, keywordEnforcer, orientationVector, rc)
!
! !ARGUMENTS:
    integer,        target, intent(out)           :: connection(:)
    integer,                intent(in)            :: tileIndexA
    integer,                intent(in)            :: tileIndexB
    integer,                intent(in)            :: positionVector(:)
type(ESMF_KeywordEnforcer), optional:: keywordEnforcer ! must use keywords below
    integer,                intent(in),  optional :: orientationVector(:)
    integer,                intent(out), optional :: rc
!
! !DESCRIPTION:
!   This call helps to construct a DistGrid connection,
!   which is a simple vector of integers, out of its components.
!
!   The arguments are:
!   \begin{description}
!   \item[connection] 
!     Element to be constructed. The provided {\tt connection} array must 
!     be dimensioned to hold exactly the number of integers that result from
!     the input information.
!   \item[tileIndexA] 
!     Index of one of the two tiles that are to be connected.
!   \item[tileIndexB] 
!     Index of one of the two tiles that are to be connected.
!   \item[positionVector] 
!     Position of tile B's minIndex with respect to tile A's minIndex.
!   \item[{[orientationVector]}]
!     Associates each dimension of tile A with a dimension in tile B's 
!     index space. Negative index values may be used to indicate a 
!     reversal in index orientation. It is erroneous to associate multiple
!     dimensions of tile A with the same index in tile B. By default
!     {\tt orientationVector = (/1,2,3,.../)}, i.e. same orientation as tile A.
!   \item[{[rc]}] 
!     Return code; equals {\tt ESMF\_SUCCESS} if there are no errors.
!   \end{description}
!
!EOPI
!------------------------------------------------------------------------------
    integer                 :: localrc      ! local return code
    type(ESMF_InterfaceInt) :: connectionArg        ! helper variable
    type(ESMF_InterfaceInt) :: positionVectorArg    ! helper variable
    type(ESMF_InterfaceInt) :: orientationVectorArg ! helper variable

    ! initialize return code; assume routine not implemented
    localrc = ESMF_RC_NOT_IMPL
    if (present(rc)) rc = ESMF_RC_NOT_IMPL
    
    ! Deal with (optional) array arguments
    connectionArg = ESMF_InterfaceIntCreate(connection, rc=localrc)
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return
    positionVectorArg = ESMF_InterfaceIntCreate(positionVector, rc=localrc)
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return
    orientationVectorArg = ESMF_InterfaceIntCreate(orientationVector, &
      rc=localrc)
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return

    ! call into the C++ interface, which will sort out optional arguments
    call c_ESMC_DistGridConnection(connectionArg, &
      tileIndexA, tileIndexB, positionVectorArg, orientationVectorArg, &
      localrc)
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return
      
    ! garbage collection
    call ESMF_InterfaceIntDestroy(connectionArg, rc=localrc)
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return
    call ESMF_InterfaceIntDestroy(positionVectorArg, rc=localrc)
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return
    call ESMF_InterfaceIntDestroy(orientationVectorArg, rc=localrc)
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return
    
    ! return successfully
    if (present(rc)) rc = ESMF_SUCCESS
 
  end subroutine ESMF_DistGridConnectionInt
!------------------------------------------------------------------------------


! -------------------------- ESMF-public method -------------------------------
#undef  ESMF_METHOD
#define ESMF_METHOD "ESMF_DistGridConnectionSet()"
!BOP
! !IROUTINE: ESMF_DistGridConnectionSet - Set DistGridConnetion
! !INTERFACE:
  subroutine ESMF_DistGridConnectionSet(connection, tileIndexA, tileIndexB, &
    positionVector, keywordEnforcer, orientationVector, rc)
!
! !ARGUMENTS:
    type(ESMF_DistGridConnection), intent(out)           :: connection
    integer,                       intent(in)            :: tileIndexA
    integer,                       intent(in)            :: tileIndexB
    integer,                       intent(in)            :: positionVector(:)
type(ESMF_KeywordEnforcer), optional:: keywordEnforcer ! must use keywords below
    integer,                       intent(in),  optional :: orientationVector(:)
    integer,                       intent(out), optional :: rc
!         
! !STATUS:
! \begin{itemize}
! \item\apiStatusCompatibleVersion{5.2.0r}
! \end{itemize}
!
! !DESCRIPTION:
!   \label{api:DistGridConnectionSet}
!   Set an {\tt ESMF\_DistGridConnection} object to represent a connection 
!   according to the provided index space information.
!
!   The arguments are:
!   \begin{description}
!   \item[connection] 
!     DistGridConnection object.
!   \item[tileIndexA] 
!     Index of one of the two tiles that are to be connected.
!   \item[tileIndexB] 
!     Index of one of the two tiles that are to be connected.
!   \item[positionVector] 
!     Position of tile B's minIndex with respect to tile A's minIndex.
!   \item[{[orientationVector]}]
!     Associates each dimension of tile A with a dimension in tile B's 
!     index space. Negative index values may be used to indicate a 
!     reversal in index orientation. It is erroneous to associate multiple
!     dimensions of tile A with the same index in tile B. By default
!     {\tt orientationVector = (/1,2,3,.../)}, i.e. same orientation as tile A.
!   \item[{[rc]}] 
!     Return code; equals {\tt ESMF\_SUCCESS} if there are no errors.
!   \end{description}
!
!EOP
!------------------------------------------------------------------------------
    integer                 :: localrc      ! local return code
    integer                 :: dimCount

    ! initialize return code; assume routine not implemented
    localrc = ESMF_RC_NOT_IMPL
    if (present(rc)) rc = ESMF_RC_NOT_IMPL

    ! mark output as uninitialized    
    ESMF_INIT_SET_DELETED(connection)

    ! set the actual elementCount in connection member
    dimCount = size(positionVector)
    connection%elementCount = 2*dimCount+2
    
    call ESMF_DistGridConnectionInt(connection%connection(1:2*dimCount+2), &
      tileIndexA=tileIndexA, tileIndexB=tileIndexB, &
      positionVector=positionVector, orientationVector=orientationVector, &
      rc=localrc)
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return

    ! mark output as successfully initialized
    ESMF_INIT_SET_DEFINED(connection)

    ! return successfully
    if (present(rc)) rc = ESMF_SUCCESS
 
  end subroutine ESMF_DistGridConnectionSet
!------------------------------------------------------------------------------


! -------------------------- ESMF-public method -------------------------------
#undef  ESMF_METHOD
#define ESMF_METHOD "ESMF_InterfaceIntCreateDGConn()"
!BOPI
! !IROUTINE: ESMF_InterfaceIntCreateDGConn - Create InterfaceInt from DistGrid Connection List

! !INTERFACE:
  function ESMF_InterfaceIntCreateDGConn(connectionList, rc)
!
! !ARGUMENTS:
    type(ESMF_DistGridConnection), intent(in),  optional :: connectionList(:)
    integer,                       intent(out), optional :: rc
!         
! !RETURN VALUE:
    type(ESMF_InterfaceInt) :: ESMF_InterfaceIntCreateDGConn
!
! !DESCRIPTION:
!   Create a compacted 2D {\tt ESMF\_InterfaceInt} from a list of 
!   DistGridConnection objects. All of the DistGridConnetion objects in
!   {\tt connectionLis} must have the same elementCount.
!
!   The arguments are:
!   \begin{description}
!   \item[{[connectionList}]]
!     List of DistGridConnection objects.
!   \item[{[rc]}]
!     Return code; equals {\tt ESMF\_SUCCESS} if there are no errors.
!   \end{description}
!
!EOPI
!------------------------------------------------------------------------------
    integer                 :: localrc      ! local return code
    integer                 :: i, elementCount, stat, connectionListSize
    integer, pointer        :: farray(:,:)
    type(ESMF_InterfaceInt) :: array
    
    ! initialize return code; assume routine not implemented
    localrc = ESMF_RC_NOT_IMPL
    if (present(rc)) rc = ESMF_RC_NOT_IMPL
    
    connectionListSize = 0
    if (present(connectionList)) connectionListSize = size(connectionList)
    if (connectionListSize > 0) then
      ! allocate 2D Fortran array to hold connectionList in the internal format
      elementCount = connectionList(1)%elementCount ! initialize
      allocate(farray(elementCount,size(connectionList)), stat=stat)
      if (ESMF_LogFoundAllocError(stat, msg="allocating farray", &
        ESMF_CONTEXT)) &
        return  ! bail out
      do i=1, size(connectionList)
ESMF_INIT_CHECK_SHALLOW_SHORT(ESMF_DistGridConnectionGetInit, connectionList(i), rc)
        if (connectionList(i)%elementCount /= elementCount) then
          call ESMF_LogSetError(rcToCheck=ESMF_RC_ARG_BAD, &
            msg="elementCount mismatch between DistGridConnection elements.", &
            ESMF_CONTEXT, rcToReturn=rc)
          return
        endif
        farray(:,i) = connectionList(i)%connection(1:elementCount)
      enddo
      ! create InterfaceInt for farray and transfer ownership
      array = ESMF_InterfaceIntCreate(farray2D=farray, &
        transferOwnership=.true., rc=localrc)
      if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
        ESMF_CONTEXT, rcToReturn=rc)) return
    else
      ! dummy InterfaceInt
      array = ESMF_InterfaceIntCreate(rc=localrc)
      if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
        ESMF_CONTEXT, rcToReturn=rc)) return
    endif
 
    ! set return value
    ESMF_InterfaceIntCreateDGConn = array
    
    ! return successfully
    if (present(rc)) rc = ESMF_SUCCESS
 
  end function ESMF_InterfaceIntCreateDGConn
!------------------------------------------------------------------------------


! -------------------------- ESMF-internal method -----------------------------
#undef  ESMF_METHOD
#define ESMF_METHOD "ESMF_DistGridConnectionGetInit"
!BOPI
! !IROUTINE: ESMF_DistGridConnectionGetInit - Internal access routine for init code
!
! !INTERFACE:
  function ESMF_DistGridConnectionGetInit(connection) 
!
! !RETURN VALUE:
    ESMF_INIT_TYPE :: ESMF_DistGridConnectionGetInit   
!
! !ARGUMENTS:
    type(ESMF_DistGridConnection), intent(in), optional :: connection
!
! !DESCRIPTION:
!   Access init code.
!
!   The arguments are:
!   \begin{description}
!   \item [connection]
!     DistGridConnection object.
!   \end{description}
!
!EOPI
!------------------------------------------------------------------------------
    if (present(connection)) then
      ESMF_DistGridConnectionGetInit = ESMF_INIT_GET(connection)
    else
      ESMF_DistGridConnectionGetInit = ESMF_INIT_DEFINED
    endif

  end function ESMF_DistGridConnectionGetInit
!------------------------------------------------------------------------------


end module ESMF_DistGridConnectionMod
