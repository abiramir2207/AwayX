<cfparam name="isTextFormat"  default = "false" >
<cfparam name="application.returned_customer_setting.Program_Quantity_Label"  default="Program Qty" />
<cfparam name="bHideMarketPrice" default="0">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<!--- <cfset appSettings = genSettingsManager.get()> --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<!------ Start Clause Code ----->
<cfset clauseProgramManager = CreateObject("component", "components.clause_library.ClauseProgramManager").init() />
<!------ End  Clause Code ----->

<!--- view program component --->

<cfset ViewProgramManager = CreateObject("component", "components.programs.Display_Program.viewprogramtemplateManager") />

<!---initialize group info--->
<cfset GroupDataManager = CreateObject("component","components.products.Group.DataManager").init() />
<!--- <cfset this.isGroup = GroupDataManager.isGroupDeal(CSLGetContractInfo.Contract_Main_ID) /> --->
<!---default params for business segments--->
<CFPARAM name="Business_Segment_ID" default="0">
<CFPARAM name="businessSegmentsOn" default="0">

<!---default params for LOB--->
<CFPARAM name="Line_Of_Business_ID" default="0">
<cfset businessSegmentsOn = 0/>

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
	<cfset businessSegmentsOn = 1 />
	<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(CSLGetContractInfo.Contract_Main_ID) />
	<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
</cfif>
<cfif appSettings.getSalesOrgOn()>
<cfset LOBManager = CreateObject("component", "components.programs.business_segment.LOBManager") />
	<cfset LOBIdForProgram = LOBManager.getLOBIdByProgram(CSLGetContractInfo.Contract_Main_ID) />
<cfif LOBIdForProgram NEQ "">
	<cfset qGetThisLOB = LOBManager.get(LOBIdForProgram) />
	<cfset Line_Of_Business_Name = qGetThisLOB.Line_Of_Business_Name>
<cfelse>
	<cfset Line_Of_Business_Name = "No #appSettings.getlob_label()#">
</cfif>
</cfif>

<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />

<cfset getContractUOMLabel = ViewProgramManager.getContractUOMLabel(CSLGetContractInfo.Contract_Quantity_UOM_IDX)>

<cfset getprogramstatus = CreateObject("component", "components.programs.Program")>

<cfset getContract_Main_Aux_Data = ViewProgramManager.getContract_Main_Aux_Data(CSL_Contract_Main_ID)>


<!---- temp set to txt --->
<cfif isTextFormat EQ "true">
	<CFSET claimHandle = CreateObject("component", "components.reports.claim")>
	<cfsetting enablecfoutputonly="Yes" showdebugoutput="no" >
</cfif>

<cfif isTextFormat EQ true >
	<cfset TabChar = Chr(9)>
	<cfset NewLine = Chr(13) & Chr(10)>
</cfif>

<!--- Tim Ford - WR 48513 - Expiry Notices emails not sent: Adding Profiles_ID to request.AccessStructure to prevent errors from scheduled tasks --->
<cfif not IsDefined("request.AccessStructure.Profiles_ID")>
	<cfset request.accessstructure.profiles_id = CreateObject("component", "components.user.UserManager").getUser(CSLGetContractInfo.Responsible_User_ID).Profiles_ID />
</cfif>

<cfif isTextFormat EQ false>
<cfinclude template="display_view_program_html.cfm">
<cfelse>
<cfinclude template="display_view_program_txt.cfm">
</cfif>
