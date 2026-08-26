<CFPARAM name="form.IFRAME_Extra_URL" 	default="">
<CFPARAM name="Form.PL_PostSubmit" 		default="">
<CFPARAM name="Form.PL_PreSubmit" 		default="">
<CFPARAM name="Form.PL_Final" 			default="">
<CFPARAM name="form.PL_ImportProducts"  default="0">
<CFPARAM name="form.PL_ImportAllProducts"  default="0">
<CFPARAM name="printresults" default="0">
<CFPARAM name="url.title" default="">
<CFPARAM name="form.title" default="#url.title#">
<CFPARAM name="url.SearchIsConductedFromOtherWindow" default="0">
<CFPARAM name="form.Report_Type" default="0">

<cfif url.SearchIsConductedFromOtherWindow EQ 1>
	<CFSET Form.IFRAME_Extra_URL = "?ShowCheckBoxes=1&SearchIsConductedFromOtherWindow=1">

	<cf_List_Compare List1="#Form.PL_PostSubmit#" List2="#Form.PL_PreSubmit#">

	<cfif listlen(trim(LC_Results1)) GT 0>
		<CFSET Form.PL_Final = listappend(Form.PL_Final, LC_Results1)>
	</cfif>

	<cfif listlen(trim(LC_Results2)) GT 0>
		<cfloop index="x" list="#LC_Results2#">
			<CFSET ItemPosition = listfind(Form.PL_Final, x)>
			<cfif ItemPosition NEQ 0>
				<cfset Form.PL_Final = listdeleteAt(Form.PL_Final, ItemPosition)>
			</cfif>
		</cfloop>
	</cfif>

</cfif>

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

<cfif form.PL_ImportProducts EQ 1>
	<cfoutput>
	<script>
		window.parent.returnValue = '#Form.PL_Final#';
		window.close();
	</script>
	</cfoutput>
<cfabort>
</cfif>

<cfif form.PL_ImportAllProducts EQ 1>
	<cfoutput>
	<script>
		window.parent.returnValue = '#form.PL_AllProductList#';
		window.close();
	</script>
	</cfoutput>
</cfif>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<!------ program_Search_Result.cfm ----->
<CFPARAM name="form.businessSegmentsOn" default="0">
<cfset Business_Segment_ID_List = "">
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
		<cfset form.businessSegmentsOn = 1 />
		<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
		<cfset Business_Segment_ID_List = ValueList(qGetBusSegments.Business_Segment_ID, ",")>
</cfif>

<CFINCLUDE TEMPLATE="Tables_Measures.cfm">

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<cfset udf = createObject( "component", "components.udf" )>
<cfoutput>
	#udf.cf_loader( " " )#
</cfoutput>
<script type="text/javascript">

	var intervalId = 0;

	function statusHandler()
	{
	}

	function clearHandler()
	{

        var loader = parent.document.getElementsByClassName("loader");
        if (loader.length) {
            loader[0].style.display = "none";
        }
	}

	function statusDisplay()
	{
	}

	statusHandler();

</script>

<div id="statusMessage" style="height: 1.5em; font-size: 2em; color: red;" align="center"></div>

<CFIF isdefined("FORM.DOSEARCH")>

<!--- <CFSET PW_Type="1">
 <SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
  <br><br><br>
   <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
  <br><br><br>
 </SPAN>
<CFFLUSH>
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT> --->

<CFPARAM NAME="FORM.Status" DEFAULT="0">
<!------<CFPARAM NAME="FORM.ProgramType" DEFAULT="0">----->
<CFPARAM NAME="FORM.Generic_Type" DEFAULT="0">
<CFPARAM NAME="FORM.Discount_Identifier" DEFAULT="0">
<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">
<CFPARAM NAME="FORM.Customer_Filter" DEFAULT="">
<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.Start_date" DEFAULT="">
<CFPARAM NAME="FORM.End_date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.End_date" DEFAULT="">
<CFPARAM NAME="FORM.Program_Title" DEFAULT="">
<CFPARAM NAME="FORM.Program_Number" DEFAULT="">
<CFPARAM NAME="FORM.User_Position_Operator" 	DEFAULT="">
<CFPARAM NAME="FORM.User_Position_Of" 	DEFAULT="">
<CFPARAM NAME="FORM.User_Position" 	DEFAULT="#FORM.User_Position_Of#">
<CFPARAM NAME="FORM.Distributor_shipto" 	DEFAULT="">
<CFPARAM NAME="FORM.Service_Zone_ID" 	DEFAULT="0">
<CFPARAM NAME="FORM.Service_Region_ID" 	DEFAULT="0">
<CFPARAM NAME="FORM.Service_Market_ID" 	DEFAULT="0">
<cfparam name="FORM.Business_Segment_ID" 	default="0">
<cfparam name="FORM.Legacy_Deal_ID" 	default="">
<cfparam name="FORM.Responsible_Sales_Person" 	default="">
<cfparam name="FORM.readOnlyCatalogSearch" 	default="0">
<cfparam name="Form.RS_Start_Date" default="">
<cfparam name="Form.RS_Start_Date_Operator" default="">
<cfparam name="Form.RS_End_Date" default="">
<cfparam name="Form.RS_End_Date_Operator" default="">
<CFPARAM NAME="FORM.RS_User_Position_Of" 	DEFAULT="">
<CFPARAM NAME="FORM.RS_User_Position" 	DEFAULT="#FORM.RS_User_Position_Of#">
<cfparam name="form.currentProgramList" default="">
<cfparam name="form.currentStatusList" default="">
<cfparam name="form.currentStatusList2" default="">
<cfparam name="form.currentReportProgramList" default="">
<cfparam name="GL_Account" default="">
<cfparam name="Sort_By_Name" 	default="0">

						<CFIF LEN(FORM.RS_START_DATE_OPERATOR) NEQ 0>
								<CFSWITCH expression="#FORM.RS_Start_Date_Operator#">
									<CFCASE value="GREATER_OR_EQUAL">
										<CFSET FORM.RS_Start_Date_Operator = ">=" />
									</CFCASE>
									<CFCASE value="EQUAL">
										<CFSET FORM.RS_Start_Date_Operator = "=" />
									</CFCASE>
									<CFCASE value="LESS_OR_EQUAL">
										<CFSET FORM.RS_Start_Date_Operator = "<=" />
									</CFCASE>
									<CFDEFAULTCASE />
								</CFSWITCH>
						</CFIF>
						<CFIF LEN(FORM.RS_End_Date_Operator) NEQ 0>
								<CFSWITCH expression="#FORM.RS_End_Date_Operator#">
									<CFCASE value="GREATER_OR_EQUAL">
										<CFSET FORM.RS_End_Date_Operator = ">=" />
									</CFCASE>
									<CFCASE value="EQUAL">
										<CFSET FORM.RS_End_Date_Operator = "=" />
									</CFCASE>
									<CFCASE value="LESS_OR_EQUAL">
										<CFSET FORM.RS_End_Date_Operator = "<=" />
									</CFCASE>
									<CFDEFAULTCASE />
								</CFSWITCH>
						</CFIF>

<cfif url.SearchIsConductedFromOtherWindow EQ 0>
	<CFINCLUDE TEMPLATE="unlock_programs.cfm">
</cfif>

<!------ Get application settings ----->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<!----------------------------------------------------------
Access Permissions
----------------------------------------------------------->

<CFINCLUDE TEMPLATE="access_permissions.cfm">

<!---------------------------------------------------
Access Permission End
---------------------------------------------------->


<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<cfparam name="FORM.sort_by" 	default="#Default_Sort#">
<cfparam name="FORM.sort_Order" 	default="#Default_Sort_Order#">

<CFSET sql_Sort_By="dbo.contract_main.contract_number">
<CFSWITCH expression="#FORM.sort_by#">
	<CFCASE value="CN">
		<CFSET sql_Sort_By="dbo.contract_main.contract_number">
	</CFCASE>
	<CFCASE value="CO">
		<CFSET sql_Sort_By="dbo.BSA_Operator.Operator_Name">
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
	<CFCASE value="AD">
		<CFSET sql_Sort_By="dbo.contract_main.Approval_date">
	</CFCASE>
	<CFCASE value="ST">
		<CFSET sql_Sort_By="dbo.contract_main.Contract_Status_Type_IDX">
	</CFCASE>
	<CFCASE value="BUS_SEG">
		<CFSET sql_Sort_By="dbo.Business_Segment.Business_Unit_Desc">
	</CFCASE>
	<CFCASE value="PP">
		<CFSET sql_Sort_By="ppUsers.Name_Last">
	</CFCASE>
		<!--- Dev Note: Milan; D8539 --->
	<CFCASE value="OP">
		<CFSET sql_Sort_By="OperatorID">
	</CFCASE>
	<!---  Here "DI" is the Distributor (The original label is 6320,  but I had forgotten to add this here with that label)  --->
	<CFCASE value="DI">
		<CFIF appSettings.getProgramScoreCard() NEQ 0>
			<CFSET sql_Sort_By="Name">
			<CFSET Sort_By_Name = "1">
		</CFIF>
	</CFCASE>
	<!--- End Note: Milan; D8539 --->
</CFSWITCH>

<CFIF FORM.sort_Order EQ "DESC">
	<CFSET sql_Sort_By="#sql_Sort_By# DESC">
<CFELSE>
	<CFSET sql_Sort_By="#sql_Sort_By# ASC">
</CFIF>


<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
	<cfset UserClassCodeList = "">
	<cfset UserClassCodeUUIDList = ""> <!------ DEV NOTE: DRK 9674/9742 : if the template - restrict group type is class code alone ----->
	<cfif businessSegManager.getClassCodesOn()>
		<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(request.AccessStructure.User_ID, 0) />
		 <cfset UserClassCodeList = ValueList(qgetUserClassCodes.class_code_id)>
		 <cfset UserClassCodeUUIDList = ValueList(qgetUserClassCodes.Class_Code_UUID) />
	</cfif>

	<cfset stSearch = StructNew()>
	<cfset stSearch = form>
	<cfset stSearch.businessSegmentsOn = form.businessSegmentsOn>
	<cfset stSearch.GP_Position_List_From_My_Position_Down = GP_Position_List_From_My_Position_Down>
	<cfset stSearch.GP_Position_List_From_My_Position_Down_SC = GP_Position_List_From_My_Position_Down_SC>
	<cfset stSearch.Business_Segment_ID_List = Business_Segment_ID_List>
	<cfset stSearch.Read_Only_Catalog_Access = Get_Profile_Settings.Read_Only_Catalog_Access>
	<cfset stSearch.title = form.title>
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
	<cfset stSearch.UserClassCodeList = UserClassCodeList>
	<cfset stSearch.UserClassCodeUUIDList = UserClassCodeUUIDList />
	<cfset stSearch.sql_Sort_By = sql_Sort_By>
	<cfset stSearch.See_Awarded_In_Catalog = Get_Profile_Settings.See_Awarded_In_Catalog>
	<!--- dinesh for Label D26891  --->
	<cfif isdefined("from_position")>
	<cfset stSearch.from_position = #from_position#>
	<cfset stSearch.Include_work_in_progress_below_me = #Include_work_in_progress_below_me#>
	</cfif>
	<!--- dinesh for Label D26891  --->

	<cfset TheQuery = CreateObject("component", "components.programs.ProgramManager").search(stSearch)>

		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>

			<cfparam name="FORM.startrow" 	default="1">
			<CFPARAM NAME="FORM.frompage" 		DEFAULT="1">
			<cfparam name="FORM.pageLength" 	default=100>
			<CFPARAM NAME="FORM.TITLE" DEFAULT="#url.title#">
			<CFSET startrow=FORM.startrow>
			<CFSET frompage=FORM.frompage>
			<cf_Number_of_Rows maxrows="#FORM.pageLength#">

			<!---Startrow can never be less than 0 and never be non-integer--->
			<cfif startrow LT 1 OR isNumeric(startrow) IS false>
				<cfset startrow = 1>
			</cfif>
			<script>

	var currentProgramList = <cfoutput>"#form.currentProgramList#"</cfoutput>;
	var currentStatusList = <cfoutput>"#form.currentStatusList#"</cfoutput>;
	var currentStatusList2 = <cfoutput>"#form.currentStatusList2#"</cfoutput>;
	var currentReportProgramList = <cfoutput>"#form.currentReportProgramList#"</cfoutput>;


	  var globalcurrentProgramList = currentProgramList;
      function approveSelectedProgram()
      {
	     if(globalcurrentProgramList.length > 0)
	     {
	       if(confirm("Press OK to approve the selected programs."))
	       {
	       	document.all.massApprovalProgramList.value = globalcurrentProgramList;
			document.all.approvalForm.submit();
		   }
	     }
	     else
	     {
		    alert("Please select at least one program Ready For Approval first.")
	     }
	   }

      var globalcurrentStatusList = currentStatusList;
      function editSelectedProgramStatus()
      {
	       if(globalcurrentStatusList.length > 0)
	       {
	          if(confirm("Press OK to change the selected programs status."))
	          {
	          	document.all.massEditStatusList.value = globalcurrentStatusList;
			    document.all.editStatusForm.submit();
		      }
	       }
	       else
	       {
		        alert("Please select at least one program to change the proposal status.")
	       }
	  }

	function getReport(ReportType)
	{
		var ReportTitle = ''

		if(ReportType == 1)
		{
			ReportTitle = 'claim rates'
		}
		else if(ReportType == 2)
		{
			ReportTitle = 'pricing'
		}

		if(currentReportProgramList.length > 0)
		{
	      NewWindow("about:blank",	 "report", "600", "500", "Yes", "Yes");
		    document.all.report_program_id_list.value = currentReportProgramList;
				document.all.report_type.value = ReportType;
		    document.all.ReportForm.submit();
     }
     else
     {
			alert("Please select at least one program to report against.")
		 }
	}

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
			globalcurrentStatusList = currentStatusList;
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
			globalcurrentProgramList = currentProgramList;
		}
	}

	function selectedProgramListReport(oChkBx) {
		programID = oChkBx.value;
		if(oChkBx.getAttribute("bIncludeInReport") == "1")
		{
			if(oChkBx.checked)
			{
				//add to list
				currentReportProgramList = ListAppendItem(currentReportProgramList, ",", programID);
			}
			else
			{
				//remove from list
				currentReportProgramList = ListDeleteItem(currentReportProgramList, ",", programID, 1);
			}
			document.all.MyForm.currentReportProgramList.value = currentReportProgramList;
		}
	}

	function massApproveSelectedPrograms() {

	}

</script>



<!--- Dinesh Rachala LABEL 26667 START--->
<!-- This Variables is used to customize the pop up window -->
<cfif isdefined("form.type")>
<cfset variables.dr_type = #form.type#>
<cfelse>
<cfset variables.dr_type = 'htm'>
</cfif>
<!--- Dinesh Rachala LABEL 26667 END--->

<cfset from_position = #form.from_position#>

<cfinclude TEMPLATE="display_Program_List.cfm">


<!--- Dinesh Rachala LABEL 26667 & D26891   START--->
<!--- This JavaScript function will collect the Contact_Number
     from child window(display_program_list) and send those values to parent page of this window which is program_search_form.cfm --->
<script>
  function importProducts_reassign() {
         // Get value of fname and lname properties.
        var s = "";
        // Iterate over embedded object's properties.
        for (i=0; i<document.test.statusCheckBox.length; i++) {
        if (document.test.statusCheckBox[i].checked==true)
        		{s +=  document.test.statusCheckBox[i].value + ",";}
    }
        reassign(s);
    }
    function reassign(s){
			window.parent.reassign(s);
   }
</script>
<!--- Dinesh Rachala LABEL 26667 & D26891  END--->
		<cfif printresults EQ 0>

			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
			<TR>
			<TD>
			<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<CF_Next_Previous_For_Forms
				formname="MyForm"
				query="TheQuery"
				maxpages="30"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams="">
			</DIV>
			</TD>
			<TD ALIGN="RIGHT">
				<FONT COLOR="Red" SIZE="2"><B>There <CFIF TheQuery.recordcount EQ 1>is<CFELSE>are&nbsp;</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1> program<CFELSE> programs</CFIF> that <CFIF TheQuery.recordcount EQ 1>matched<CFELSE>match</CFIF> the above criteria&nbsp; </B></FONT>
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

			</TABLE>
		</cfif>
			<SCRIPT LANGUAGE="javaScript">
				function getthisPage(thisObj)
				{
					window.parent.showSearchResult(false, thisObj.startrow.value,thisObj.frompage.value);
					return false;
				}

			</SCRIPT>

			<CFOUTPUT>
			<FORM ACTION="/scorecard/program_Search_Result.cfm#form.IFRAME_Extra_URL#&title=#url.title#" METHOD="post" NAME="MyForm" ID="MyForm" onSubmit="javaScript: return getthisPage(this);">
			<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
			<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
			<INPUT TYPE="Hidden" NAME="title" VALUE="#title#">
			<input type="Hidden" name="ImportAllList" value="#ValueList(TheQuery.Contract_Main_ID)#">
			<INPUT TYPE="Hidden" NAME="currentProgramList" VALUE="#form.currentProgramList#">
            <INPUT TYPE="hidden" NAME="currentStatusList" VALUE="#form.currentStatusList#">
			<INPUT TYPE="hidden" NAME="currentStatusList2" VALUE="#form.currentStatusList2#">
			<INPUT TYPE="hidden" NAME="currentReportProgramList" VALUE="#form.currentReportProgramList#">
			<INPUT TYPE="hidden" NAME="ReportType" VALUE="#form.report_type#">
			</FORM>
			</CFOUTPUT>


			<SCRIPT>
			function generateSelectedProgramsList() {
				returnList = "";

				for(var x=0;x<window.document.all.SelectedPrograms.length; x++) {
					oTempBx = window.document.all.SelectedPrograms[x];

					if(oTempBx.checked) {
						returnList = returnList + oTempBx.value + ",";
					}
				}


				returnList = returnList.substring(0, returnList.length-1);

				return returnList
			}

			function navigate(frompage, startrow)
			{
				<cfif URL.ShowCheckBoxes EQ 1><cfoutput>
					window.parent.document.all.chkAll.checked 		= false;
					window.parent.SearchForm.PL_PreSubmit.value 	= "#form.ILPL_PreSubmit#";
					window.parent.SearchForm.PL_PostSubmit.value 	= generateSelectedProgramsList();
					window.parent.SearchForm.PL_Final.value 		= "#Form.PL_Final#";
				</cfoutput></cfif>

				window.parent.SearchForm.currentProgramList.value 		= document.all.MyForm.currentProgramList.value;
				window.parent.SearchForm.currentStatusList.value 		= document.all.MyForm.currentStatusList.value;
				window.parent.SearchForm.currentStatusList2.value 		= document.all.MyForm.currentStatusList2.value;
				window.parent.SearchForm.currentReportProgramList.value 		= document.all.MyForm.currentReportProgramList.value;

				window.parent.showSearchResult(false, startrow,frompage);
			}

   			function getthisPage(thisObj)
			{
				thisObj.submit();
				return false;
			}

			function showstartingWith(sValue)
			{
				var searchFrm = window.parent.SearchForm;
				searchFrm.title.value = sValue;
				searchFrm.startrow.value = 1;
				searchFrm.action = "/scorecard/program_Search_Result.cfm#form.IFRAME_Extra_URL#&title=" + sValue;
				searchFrm.submit();
				return false;
			}

			</SCRIPT>


		<CFELSE>
			<BR>
			<FONT COLOR="Red" SIZE="2"><B>There are no programs that match the specified criteria</B></FONT>
		</CFIF>
	<script>
		clearHandler();
	</script>

	<script>
		<cfoutput>
			#udf.hide_cf_loader()#
		</cfoutput>
	</script>

</CFIF>
<form action="massapproval.cfm" method="post" name="approvalForm" id="approvalForm" target="_parent">
	<input type="Hidden" name="massApprovalProgramList" value="">
</form>

<!--- BSD: Added for Mass Update on Proposal Status --->
<form action="masseditstatus.cfm" method="post" name="editStatusForm" id="editStatusForm" target="_parent">
	<input type="Hidden" name="massEditStatusList" value="" />
	<input type="hidden" name="massEditProposalStatus" value="" />

</form>

<form action="/reportwriter/program_claim_rates_report.cfm" method="post" name="ReportForm" id="ReportForm" target="report">
	<input type="Hidden" name="report_program_id_list" value="">
	<input type="Hidden" name="report_type" value="">
</form>

</BODY>