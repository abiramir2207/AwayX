<CFPARAM name="form.businessSegmentsOn" default="0">
<cfset Business_Segment_ID_List = "">
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
		<cfset form.businessSegmentsOn = 1 />
		<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
		<cfset Business_Segment_ID_List = ValueList(qGetBusSegments.Business_Segment_ID, ",")>
</cfif>

<!------ Get application settings ----->
<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()> --->

<CFINCLUDE TEMPLATE="access_permissions.cfm">

<cfset UserClassCodeList = "">
<cfset UserClassCodeUUIDList = ""> <!------ DEV NOTE: DRK 9674/9742 : if the template - restrict group type is class code alone ----->
<cfif businessSegManager.getClassCodesOn()>
	<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(request.AccessStructure.User_ID, 0) />
	<cfset UserClassCodeList = ValueList(qgetUserClassCodes.class_code_id)>
	<cfset UserClassCodeUUIDList = ValueList(qgetUserClassCodes.Class_Code_UUID) />
</cfif>

<cfset stSearch = StructNew()>
<cfset stSearch.businessSegmentsOn = form.businessSegmentsOn>
<cfset stSearch.Business_Segment_ID_List = Business_Segment_ID_List>
<cfset stSearch.User_Positions_ID = UserPositionList>
<cfset stSearch.GP_Position_List_From_My_Position_Down = GP_Position_List_From_My_Position_Down>
<cfset stSearch.GP_Position_List_From_My_Position_Down_SC = GP_Position_List_From_My_Position_Down_SC>
<cfset stSearch.ProgramsWithDistUnderMe_SC = "0">
<cfset stSearch.ProgramsWithBrokerUnderMe_SC = "0">
<cfif NOT Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
	<cfset stSearch.ProgramsWithDistUnderMe_SC = ProgramsWithDistUnderMe_SC>
	<cfset stSearch.ProgramsWithBrokerUnderMe_SC = ProgramsWithBrokerUnderMe_SC>
</cfif>
<cfset stSearch.RFA_Agreed = Get_Profile_Settings.RFA_Agreed>
<cfset stSearch.Profiles_ID = request.AccessStructure.Profiles_ID>
<cfset stSearch.program_margin_approval_method = Get_Profile_Settings.program_margin_approval_method>
<cfset stSearch.User_ID = request.AccessStructure.User_ID>
<cfset stSearch.Read_Only_Catalog_Access = Get_Profile_Settings.Read_Only_Catalog_Access>
<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
	<cfset stSearch.programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
</cfif>
<cfset stSearch.See_Awarded_In_Catalog = Get_Profile_Settings.See_Awarded_In_Catalog>
<cfset stSearch.Approve_Freight_Programs = Get_Profile_Settings.Approve_Freight_Programs />
<cfset stSearch.UserClassCodeList = UserClassCodeList>
<cfset stSearch.UserClassCodeUUIDList = UserClassCodeUUIDList>