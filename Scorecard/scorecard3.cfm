<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<CFINCLUDE TEMPLATE="Tables_Measures.cfm">

<CFPARAM name="url.title" default="">
<CFPARAM name="form.title" default="#url.title#">

<cfheader name="Cache-Control" value="no-store">
<CFPARAM NAME="URL.SECTION_TO_OPEN" DEFAULT="ALL">
<CFPARAM NAME="URL.AGREE_ID" 		DEFAULT="2">
<CFPARAM NAME="URL.SHEXP" DEFAULT="false">
<CFPARAM NAME="URL.SORTBY" DEFAULT="#Default_Sort#">
<cfparam name="url.printresults" default="0">
<cfparam name="form.currentProgramList" default="">
<cfparam name="form.currentStatusList" default="">
<cfparam name="form.currentStatusList2" default="">
<cfparam name="form.currentClaimRatesReportProgramList" default="">
<cfparam name="Sort_By_Name" default="0">
<CFPARAM name="form.businessSegmentsOn" default="0">
<cfset Business_Segment_ID_List = "" >
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
	<cfset form.businessSegmentsOn = 1 />
	<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
	<cfset Business_Segment_ID_List = ValueList(qGetBusSegments.Business_Segment_ID, ",")>
</cfif>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>

<CFSET sql_Sort_By="dbo.contract_main.contract_number">
<CFSWITCH expression="#URL.SORTBY#">	
	<CFCASE value="CO">
		<CFSET sql_Sort_By="dbo.BSA_Operator.Operator_Name">
	</CFCASE>	
	<CFCASE value="CN">
		<CFSET sql_Sort_By="dbo.contract_main.contract_number">
	</CFCASE>
	<CFCASE value="CT">
		<CFSET sql_Sort_By="dbo.contract_main.contract_Title">
	</CFCASE>
	<CFCASE value="PT">
		<CFSET sql_Sort_By="Program_Control_Panel_Options.Created_Type">
	</CFCASE>	
	<CFCASE value="SD">
		<CFSET sql_Sort_By="dbo.contract_main.Contract_Start_Date">
	</CFCASE>
	<CFCASE value="ED">
		<CFSET sql_Sort_By="dbo.contract_main.Contract_End_Date">
	</CFCASE>
	<CFCASE value="PP">
		<CFSET sql_Sort_By="ppUsers.Name_Last">
	</CFCASE>
	<CFCASE value="OP">
		<CFSET sql_Sort_By="OperatorID">
	</CFCASE>
	<CFCASE value="AP">

		<CFIF appSettings.get_Requester_Approver_Position()>
		<!--- If the program is approved --->
		<CFIF URL.SECTION_TO_OPEN GTE 4>
		<CFSET sql_Sort_By="dbo.User_Positions.Position_Approved_Label">
		<CFELSE>
		<CFSET sql_Sort_By="dbo.User_Positions.Position_To_Approve_Label">
		</CFIF>
		</CFIF>

	</CFCASE>
	<CFCASE value="RA">
	<CFIF appSettings.get_Requester_Approver()>
		<CFSET sql_Sort_By="_Users.Name_First">
	</CFIF>
	</CFCASE>

<!--- Dev Note: Milan; D6320. Here "DI" is the Distributor --->
	<CFCASE value="DI">
		<CFIF appSettings.getProgramScoreCard() NEQ 0>
			<CFSET sql_Sort_By="Name">
			<CFSET Sort_By_Name = "1">
		</CFIF>
	</CFCASE>
<!--- End Note: Milan; D6320 --->

	<CFCASE value="AD">
		
		<CFIF URL.SECTION_TO_OPEN EQ 2>
			<CFSET sql_Sort_By="dbo.contract_main.Broker_Approved_Date">
		<CFELSE>
			<CFSET sql_Sort_By="dbo.contract_main.Approval_date">		
		</CFIF>	

	</CFCASE>
	<CFCASE value="BUS_SEG">
		<CFSET sql_Sort_By="dbo.Business_Segment.Business_Unit_Desc">
	</CFCASE>	
</CFSWITCH>
<cfparam name="URL.SORTORDER" 	default="#Default_Sort_Order#">
<CFIF URL.SORTORDER EQ "DESC">
	<CFSET sql_Sort_By="#sql_Sort_By# DESC">
<CFELSE>
	<CFSET sql_Sort_By="#sql_Sort_By# ASC">
</CFIF>


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

<CFSET PW_Type="1">
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>


<CFFLUSH>


<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

<CFINCLUDE TEMPLATE="unlock_programs.cfm">


<CFPARAM NAME="WIP_Count"		DEFAULT="0">
<CFPARAM NAME="RFA_Count"		DEFAULT="0">
<CFPARAM NAME="P_ACTIVE_Count"	DEFAULT="0">
<CFPARAM NAME="ACTIVE_Count"	DEFAULT="0">
<CFPARAM NAME="EXPIRING_Count"	DEFAULT="0">

<!------ Get application settings ----->
<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()> --->

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
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
	<CFCASE VALUE="1,2,3,4,5,6,7,8,9,10" DELIMITERS=",">
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
	<cfelse>
		<cfset stSearch.agreeStatusId = URL.AGREE_ID>
	</cfif>	
	<cfset stSearch.FakeStatusIdForProgramPostApprovalStatus = FakeStatusIdForProgramPostApprovalStatus />
	
	<cfset stSearch.GP_Position_List_From_My_Position_Down = GP_Position_List_From_My_Position_Down>
	<cfset stSearch.GP_Position_List_From_My_Position_Down_SC = GP_Position_List_From_My_Position_Down_SC>
	<cfset stSearch.RFA_Agreed = Get_Profile_Settings.RFA_Agreed>
	<cfset stSearch.Business_Segment_ID_List = Business_Segment_ID_List>
	<cfset stSearch.Read_Only_Catalog_Access = Get_Profile_Settings.Read_Only_Catalog_Access>
	<cfset stSearch.title = url.title>
	<cfset stSearch.User_Positions_ID = UserPositionList>
	<cfset stSearch.ProgramsWithDistUnderMe = "0">
	<cfset stSearch.ProgramsWithBrokerUnderMe = "0">
	<cfset stSearch.ProgramsWithDistUnderMe_SC = "0">
	<cfset stSearch.ProgramsWithBrokerUnderMe_SC = "0">
	<cfif NOT Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
		<cfset stSearch.ProgramsWithDistUnderMe = ProgramsWithDistUnderMe>
		<cfset stSearch.ProgramsWithBrokerUnderMe = ProgramsWithBrokerUnderMe>
		<cfset stSearch.ProgramsWithDistUnderMe_SC = ProgramsWithDistUnderMe_SC>
		<cfset stSearch.ProgramsWithBrokerUnderMe_SC = ProgramsWithBrokerUnderMe_SC>
	</cfif>
	<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
		<cfset stSearch.programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
	</cfif>
	<cfset stSearch.Profiles_ID = request.AccessStructure.Profiles_ID>
	<cfset stSearch.program_margin_approval_method = Get_Profile_Settings.program_margin_approval_method>
	<cfset stSearch.User_ID = request.AccessStructure.User_ID>
	<cfset stSearch.UserClassCodeList = UserClassCodeList>
	<cfset stSearch.UserClassCodeUUIDList = UserClassCodeUUIDList>
	<cfset stSearch.sql_Sort_By = sql_Sort_By>
	<cfset stSearch.See_Awarded_In_Catalog = Get_Profile_Settings.See_Awarded_In_Catalog>
	<cfset stSearch.Approve_Freight_Programs = Get_Profile_Settings.Approve_Freight_Programs />
	<cfset get_This_Status_Programs = CreateObject("component", "components.programs.ProgramManager").search(stSearch)>
	
	
	
	
<CFSET PAGE_TITLE="Scorecard Detail">
<CFSET group="reports">



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Open layer Options																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!-----------------------------------------------------------------------------
Display the Result
------------------------------------------------------------------------------>
<CFPARAM NAME="URL.StartRow" DEFAULT="1">
<CFPARAM NAME="URL.frompage" DEFAULT="1">

<CFPARAM NAME="FORM.StartRow" DEFAULT="#URL.StartRow#">
<CFPARAM NAME="FORM.frompage" DEFAULT="#URL.frompage#">
<CFPARAM NAME="FORM.TITLE" DEFAULT="#url.title#">



<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>
<cf_Number_of_Rows maxrows=12>
<!------
<TABLE HEIGHT="100%" CELLSPACING="0" CELLPADDING="0" BORDER="0">
<TR>
<TD COLSPAN="100%" VALIGN="TOP">
----->
	

	<CFSET TheQuery=get_This_Status_Programs>
	<CFINCLUDE TEMPLATE="display_Program_List.cfm">	
	
<!------
</TD>
</TR>
<TR>
<TD COLSPAN="100%" WIDTH="100%" STYLE="font-size: 12px; color: Red;" VALIGN="TOP" ALIGN="LEFT">

----->
<cfif url.printresults EQ 0>
	<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
	<TR>
	<TD>
	<CF_Next_Previous_For_Forms
	formname="MyForm"
	query="get_This_Status_Programs"
	maxpages="30"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
	lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"		
	addparams="">
	</TD>
	<TD ALIGN="RIGHT">
		<FONT COLOR="Red" SIZE="2"><B>There <CFIF get_This_Status_Programs.recordcount EQ 1>Is<CFELSE>Are</CFIF><CFOUTPUT>&nbsp;#get_This_Status_Programs.recordcount#</CFOUTPUT> <CFIF get_This_Status_Programs.recordcount EQ 1>Program<CFELSE>Programs</CFIF> In This Criteria</B></FONT>
	</TD>
	</TR>
	<tr>
	<TABLE CELLPADDING="2" CELLSPACING="1" BORDER="0"><TR>
	<cfoutput>
<cfloop index="LoopCount" from="65" to="90">
  <TD><B>
 
  <CFIF chr(LoopCount) EQ url.TITLE>
  <FONT COLOR="FF0000">[</FONT>
  </CFIF>
  <A HREF="##" onClick="javaScript: return showstartingWith('#chr(LoopCount)#');">#chr(LoopCount)#</A>
 <CFIF chr(LoopCount) EQ url.TITLE>
  <FONT COLOR="FF0000">]</FONT></CFIF>
  </B></TD>
</cfloop>
<cfloop index="LoopCount" from="0" to="9">
	<TD><B>
 
  <CFIF LoopCount EQ url.TITLE>
  <FONT COLOR="FF0000">[</FONT>
  </CFIF>
  <A HREF="##" onClick="javaScript: return showstartingWith('#LoopCount#');">#LoopCount#</A>
 <CFIF LoopCount EQ url.TITLE>
  <FONT COLOR="FF0000">]</FONT></CFIF>
  </B></TD>
	</cfloop>
	<TD><B>
  <CFIF "" EQ url.TITLE>
  <FONT COLOR="FF0000">[</FONT>
  </CFIF>
  <A HREF="##" onClick="javaScript: return showstartingWith('');">ALL</A>
 <CFIF "" EQ url.TITLE>
  <FONT COLOR="FF0000">]</FONT></CFIF>
  </B>
	</TD>
	
	</cfoutput>
</TR></TABLE>
	</tr>
	</TABLE></cfif>
<!------
</TD>
</TR>
</TABLE>
----->
<!------
<HR COLOR="Orange" SIZE="2">
----->
<script>
	var currentProgramList = <cfoutput>"#form.currentProgramList#"</cfoutput>;
	var currentStatusList = <cfoutput>"#form.currentStatusList#"</cfoutput>;
	var currentStatusList2 = <cfoutput>"#form.currentStatusList2#"</cfoutput>;
	var currentClaimRatesReportProgramList = <cfoutput>"#form.currentClaimRatesReportProgramList#"</cfoutput>;
	var programStatus = "";
	
			 
	function selectedProgramStatusManage(oChkBx) {
		programID = oChkBx.value;
		if(oChkBx.getAttribute("bCanChangeBidStatus") == "1")
		{
			if(oChkBx.checked) {
				//add to list
				if(currentStatusList.length == 0)
				{
				  	if (document.getElementById('wonlost_' + programID).innerHTML == "W")
				  	 {
				  	 	programStatus = 2;
				  	 }
				  	 else
				  	 {
				  	 	programStatus = 4;
				  	 }
				  	 newProgramID = programID + '_' + programStatus;
				  	 currentStatusList = newProgramID;
				  	 currentStatusList2 = programID;
				}
				else{
					
					if (document.getElementById('wonlost_' + programID).innerHTML == "W")
				  	 {
				  	 	programStatus = 2;
				  	 }
				  	 else
				  	 {
				  	 	programStatus = 4;
				  	 }
					newProgramID = programID + '_' + programStatus;
					currentStatusList = currentStatusList + ',' + newProgramID;
					currentStatusList2 = currentStatusList2 + ',' + programID;
					
				}
			}
			else {
				//remove from list
				tmpArray =  currentStatusList.split(",");
				tmpcurrentStatusList = "";
				for(var x=0; x<tmpArray.length; x++) {
					if(tmpArray[x] != programID + '_' + programStatus) {
					
						if(tmpcurrentStatusList.length == 0){
							tmpcurrentStatusList = tmpArray[x];
						}
						else{
							tmpcurrentStatusList = tmpcurrentStatusList + ',' + tmpArray[x];
						}				
					}
				}
				
				tmpArray2 =  currentStatusList2.split(",");
				tmpcurrentStatusList2 = "";
				for(var y=0; y<tmpArray2.length; y++) {
					if(tmpArray2[y] != programID) {
					
						if(tmpcurrentStatusList2.length == 0){
							tmpcurrentStatusList2 = tmpArray2[y];
						}
						else{
							tmpcurrentStatusList2 = tmpcurrentStatusList2 + ',' + tmpArray2[y];
						}				
					}
				}
				currentStatusList = tmpcurrentStatusList;
				currentStatusList2 = tmpcurrentStatusList2;
			}
	           
			document.all.MyForm.currentStatusList.value = currentStatusList;
			document.all.MyForm.currentStatusList2.value = currentStatusList2;
			window.parent.window.globalcurrentStatusList = currentStatusList;
		}
	}
	
	function selectedProgramListManage(oChkBx) {
		programID = oChkBx.value;
		if(oChkBx.getAttribute("bCanMassApprove") == "1")
		{
			if(oChkBx.checked) {
				//add to list
				if(currentProgramList.length == 0)
				{
				  	currentProgramList = programID;
				}
				else{
					
					currentProgramList = currentProgramList + ',' + programID;
				}
			}
			else {
				//remove from list
				tempArray =  currentProgramList.split(",")
				tempcurrentProgramList = "";
				for(var x=0; x<tempArray.length; x++) {
					if(tempArray[x] != programID) {
					
						if(tempcurrentProgramList.length == 0){
							tempcurrentProgramList = tempArray[x];
						}
						else{
							tempcurrentProgramList = tempcurrentProgramList + ',' + tempArray[x]
						}				
					}
				}
				currentProgramList = tempcurrentProgramList;
			}
	
			document.all.MyForm.currentProgramList.value = currentProgramList;
			window.parent.window.globalcurrentProgramList = currentProgramList;
		}
	}
	
	function selectedProgramListClaimRatesReport(oChkBx) {
		programID = oChkBx.value;
		if(oChkBx.bIncludeInClaimRatesReport == "1")
		{
			if(oChkBx.checked) 
			{
				//add to list
				currentClaimRatesReportProgramList = ListAppendItem(currentClaimRatesReportProgramList, ",", programID);			
			}
			else 
			{
				//remove from list
				currentClaimRatesReportProgramList = ListDeleteItem(currentClaimRatesReportProgramList, ",", programID, 1);			
			}
			
			document.all.MyForm.currentClaimRatesReportProgramList.value = currentClaimRatesReportProgramList;
			window.parent.window.globalcurrentClaimRatesReportProgramList = currentClaimRatesReportProgramList;
		}
	}
	
	function massApproveSelectedPrograms() {
		
	}
	
</script>

<CFOUTPUT>

<FORM ACTION="#CGI.SCRIPT_NAME#?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#&AGREE_ID=#URL.AGREE_ID#&SORTBY=#URL.SORTBY#&SORTORDER=#SORTORDER#&title=#url.title#" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<INPUT TYPE="Hidden" NAME="title" VALUE="#title#">
<INPUT TYPE="Hidden" NAME="currentProgramList" VALUE="#form.currentProgramList#" />
<INPUT TYPE="hidden" NAME="currentStatusList" VALUE="#form.currentStatusList#" />
<INPUT TYPE="hidden" NAME="currentStatusList2" VALUE="#form.currentStatusList2#" />
<INPUT TYPE="hidden" NAME="currentClaimRatesReportProgramList" VALUE="#form.currentClaimRatesReportProgramList#" />
</FORM>
<SCRIPT LANGUAGE="javaScript">
	function getthisPage(thisObj)
	{
		thisObj.submit();
		return false;
	}
	
	function showstartingWith(sValue)
	{
		var searchFrm = document.MyForm;
		searchFrm.title.value = sValue;
		searchFrm.startrow.value = 1;
		searchFrm.action = "#CGI.SCRIPT_NAME#?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#&AGREE_ID=#URL.AGREE_ID#&SORTBY=#URL.SORTBY#&SORTORDER=#SORTORDER#&title=" + sValue;
		searchFrm.submit();
		return false;
	}
	
</SCRIPT>

</CFOUTPUT>
<cfif url.printresults EQ 1>
<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm"> 
</cfif>
</BODY>