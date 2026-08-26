 <!--- Loads the structure stSearch for use by the scorecard
 ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
<cfif Not isdefined("request.AccessStructure.User_ID")>
	<cfinclude template="/Application_Common.cfm">
	<!---<CFLOCATION URL="/logoff.cfm" ADDTOKEN="No">--->
</cfif>

<CFSET Default_Sort = "CT">
<CFSET Default_Sort_Order = "ASC">

<CFPARAM name="url.title" default="">
<CFPARAM name="form.title" default="#url.title#">

<cfheader name="Cache-Control" value="no-store">


<!---  Used to keep the users last search in memory
	- Param the session -> Param the URL to eq the session...If URL exixts, it will override session
	- then set the session to the Current URL so it will persist	MWS perf Scorecard		--->
<CFPARAM NAME="Session.SECTION_TO_OPEN" DEFAULT="ALL">
<CFPARAM NAME="Session.AGREE_ID" 		DEFAULT="2">
<CFPARAM NAME="Session.SHEXP" 			DEFAULT="false">
<CFPARAM NAME="Session.SORTBY" 			DEFAULT="#Default_Sort#">
<CFPARAM name="Session.SORTORDER" 		Default="#Default_Sort_Order#">


<CFPARAM NAME="URL.SECTION_TO_OPEN" DEFAULT="#Session.SECTION_TO_OPEN#">
<CFPARAM NAME="URL.AGREE_ID" 		DEFAULT="#Session.AGREE_ID#">
<CFPARAM NAME="URL.SHEXP" 			DEFAULT="#Session.SHEXP#">
<CFPARAM NAME="URL.SORTBY" 			DEFAULT="#Session.SORTBY#">
<CFPARAM name="URL.SORTORDER" 		Default="#Session.SORTORDER#">

<CFSET Session.SECTION_TO_OPEN	=	URL.SECTION_TO_OPEN>
<CFSET Session.AGREE_ID 		=	URL.AGREE_ID>
<CFSET Session.SHEXP 			=	URL.SHEXP>
<CFSET Session.SORTBY			=	URL.SORTBY>
<CFSET Session.SORTORDER 		=	URL.SORTORDER>

<!--- END This holds the users last request in session memory--->

<CFPARAM NAME="FORM.StartRow" DEFAULT="1">
<CFPARAM NAME="FORM.frompage" DEFAULT="1">
<CFPARAM NAME="FORM.TITLE" DEFAULT="#url.title#">

<cfparam name="url.printresults" default="0">
<cfparam name="form.currentProgramList" default="">


<CFPARAM name="form.businessSegmentsOn" default="0">
<cfset Business_Segment_ID_List = "" >
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
	<cfset form.businessSegmentsOn = 1 />
	<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
	<cfset Business_Segment_ID_List = ValueList(qGetBusSegments.Business_Segment_ID, ",")>
</cfif>

<!--- 
	1: WIP
	2: RFA
	3: Actually 3 is Approved, but here being used for pending approval
	4: PA
	5: ACT
	6: EXP
	8: LOS
	9: Catalog
 --->

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<CFINCLUDE TEMPLATE="access_permissions.cfm">


<CFSET THIS_STATUS=1>
<!--- 
changes made by gayathri to the query to reflect the Request for approval programs 
that are agreed by others but couldn't approve..this is for mainly lambweston, 
but still the query results don't change for other customers.
please don't get confused. 
Approved status was used for substatus of RFA (pending approval) 
since we don't have that field in the DB 
--->
<CFSWITCH EXPRESSION="#URL.SECTION_TO_OPEN#">
	<CFCASE VALUE="1,2,3,4,5,6,7,8,9" DELIMITERS=",">
		<CFSET THIS_STATUS=URL.SECTION_TO_OPEN>
	</CFCASE>
</CFSWITCH>

<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
<cfif appSettings.getPgmPostApprovalStatus() EQ 1>		
	<cfset FakeStatusIdForProgramPostApprovalStatus = ProgramPostApprovalStatusManager.getFakeStatusIdForProgramPostApprovalStatus() />
	<cfif URL.SECTION_TO_OPEN EQ FakeStatusIdForProgramPostApprovalStatus>
		<CFSET THIS_STATUS=URL.SECTION_TO_OPEN>
	</cfif>
</cfif>
<cfparam name="FakeStatusIdForProgramPostApprovalStatus" 	default="0">	

	<!---****************************************************--->	
	<cfset UserClassCodeList = "">
	<cfset UserClassCodeUUIDList = ""> <!------ DEV NOTE: DRK 9674/9742 : if the template - restrict group type is class code alone ----->
	<cfif businessSegManager.getClassCodesOn()>
		<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(request.AccessStructure.User_ID, 0) />
		<cfset UserClassCodeList = ValueList(qgetUserClassCodes.class_code_id)>
		<cfset UserClassCodeUUIDList = ValueList(qgetUserClassCodes.Class_Code_UUID) />
	</cfif>
	
	<cfset stSearch = StructNew()>
	<cfset stSearch.businessSegmentsOn = form.businessSegmentsOn>
	<cfset stSearch.scorecardStatus = THIS_STATUS>
	
	<cfif FakeStatusIdForProgramPostApprovalStatus EQ THIS_STATUS>
		<cfset stSearch.postApprovalStatusId = URL.AGREE_ID>
		<cfset stSearch.agreeStatusId = 0>
	<cfelse>
		<cfset stSearch.agreeStatusId = URL.AGREE_ID>
		<cfset stSearch.postApprovalStatusId = 0>
	</cfif>	
	<cfset stSearch.FakeStatusIdForProgramPostApprovalStatus = FakeStatusIdForProgramPostApprovalStatus />
	
	<cfset stSearch.GP_Position_List_From_My_Position_Down = GP_Position_List_From_My_Position_Down>
	<cfset stSearch.RFA_Agreed = request.Get_Profile_Settings.RFA_Agreed>
	<cfset stSearch.Business_Segment_ID_List = Business_Segment_ID_List>
	<cfset stSearch.Read_Only_Catalog_Access = request.Get_Profile_Settings.Read_Only_Catalog_Access>
	<cfset stSearch.title = url.title>
	<cfset stSearch.User_Positions_ID = UserPositionList>
	<cfset stSearch.ProgramsWithDistUnderMe = "0">
	<cfset stSearch.ProgramsWithBrokerUnderMe = "0">
	<!---<cfif NOT request.Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
		<cfset stSearch.ProgramsWithDistUnderMe = ProgramsWithDistUnderMe>
		<cfset stSearch.ProgramsWithBrokerUnderMe = ProgramsWithBrokerUnderMe>
	</cfif>--->
	<cfif request.Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
		<cfset stSearch.programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
	</cfif>
	<cfset stSearch.Profiles_ID = request.AccessStructure.Profiles_ID>
	<cfset stSearch.program_margin_approval_method = request.Get_Profile_Settings.program_margin_approval_method>
	<cfset stSearch.User_ID = request.AccessStructure.User_ID>
	<cfset stSearch.UserClassCodeList = UserClassCodeList>
	<cfset stSearch.UserClassCodeUUIDList = UserClassCodeUUIDList>
	<!--- <cfset stSearch.sql_Sort_By = sql_Sort_By>OLD mws new passes the code--->
	<cfset stSearch.sql_Sort_By = URL.SORTBY><!---the logic to determine sort field is in SP--->
	<cfset stSearch.SortOrder = URL.SORTORDER>
	<cfset stSearch.rStart = FORM.StartRow>
	<cfset stSearch.maxRow = 10000>
	<cfset stSearch.See_Awarded_In_Catalog = request.Get_Profile_Settings.See_Awarded_In_Catalog>
	<cfset stSearch.Program_Scorecard_Restrict_Created_By = request.Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
	<cfset stSearch.readOnlyCatalogSearch = 0>
	
	
	
<!---<cfoutput>  scorecardStatus = #stSearch.scorecardStatus# ::  RFA_Agreed = #stSearch.RFA_Agreed#    ::  agreeStatusId = #stSearch.agreeStatusId# ::  getProgramAgreeEscalate = #appSettings.getProgramAgreeEscalate()#<br>
	::  FakeStatusIdForProgramPostApprovalStatus = #stSearch.FakeStatusIdForProgramPostApprovalStatus#  ::  <!---User_Agreed_Programs_ID_List = #stsearch.User_Agreed_Programs_ID_List#---></cfoutput>
	---><!---<cfdump var="#stsearch#">--->
	<!---<cfparam name="session.searchArg" default="#StructNew()#">
	<cfset get_This_Status_Programs = CreateObject("component", "components.programs.ProgramManager").search2(stSearch)>--->
	
	<!---<cfset session.searchArg  = StructNew()>
	<cfset session.searchArg = stSearch>--->

