
<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

<cfparam name="URL.massApprovalProgramList" default="0">
<cfparam name="form.massApprovalProgramList" default="#URL.massApprovalProgramList#">
<cfparam name="form.alreadycheckedpaymenthistory" default="0">

<cfparam name="isScheduledProcess" default="0" />
<cfparam name="FromFlex" default="0">
<cfparam name="FromAGGrid" default="0">
<!--- Dev Note: KAL; 05/30/2012; D32177: When programs are agreed on mass approval; emails go to users with RFA Notificaltion off  --->
<cfset checkRFANotificationEmail = 1 />

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!--- Dev Note: KAL; D20566: Adding freight approval to mass approval process --->
<cfset application.oController.getObject(path="components.programs.Program",name="Program",bReload= 0) />
<cfset application.oController.getObject(path="components.freight.ProgramFreight",name="ProgramFreightManager",bReload= 0) />

<!--- If it is remote approval, then do not show the progress bar. --->
<cfif not(isScheduledProcess)>
<!----------------- Add Progress Bar ------------------------>
	<div id="progressbar" align="center">&nbsp;</div>
	<cfflush>

	<CFINCLUDE TEMPLATE="/includes/progress_bar.cfm">

	<script>
		function updateProgressBar(progressNum,TotalNum,percentComplete)
		{
			document.getElementById('progressbar').innerHTML = 'Processed ' +progressNum + ' of ' + TotalNum;
			if('document.Block'+percentComplete){
				document.getElementById('Block'+percentComplete).src = '/images/red_block.gif';
			}
		}
	</script>
	<cfflush>
</cfif>

<!--- Dev Note: KAL; D19440: Approval via Email: If scheduled process, skip this check --->
<cfif not(isScheduledProcess)>
	<cfif form.alreadycheckedpaymenthistory EQ 0>
		<cfif appSettings.getpaymenthistoryon() and Get_Profile_Settings.payment_history_alert EQ 1>
			<cfquery name="getprogramswithpaymenthistory" datasource="#application.datasource#">
				select contract_number, contract_title,contract_start_date, contract_end_date,contract_main_id 
				from	contract_main
				where contract_main_id IN (#form.massApprovalProgramList#)
				and is_a_revision = 1
			</cfquery>

			<cfif getprogramswithpaymenthistory.recordcount GT 0>

				<div align="center"><b>The following revisions might have payment history.</b><br><br></div>
				<table cellspacing="0" cellpadding="3" align="center" width="700">
						<tr BGCOLOR="FFE083">
							<td width="100"><span CLASS="tableheaders" valign="top">Program</span></td>
							<td width="300"><span CLASS="tableheaders" valign="top">Title</span></td>
							<td><span CLASS="tableheaders" valign="top">Start Date</span></td>
							<td><span CLASS="tableheaders" valign="top">End Date</span></td>
							<td><span CLASS="tableheaders" valign="top">Payment History Link</span></td>
						</tr>
						<cfoutput query="getprogramswithpaymenthistory">
						<tr>
							<td width="100">#contract_number#</td>
							<td width="300">#contract_title#</td>
							<td>#dateformat(contract_start_date,"mm/dd/yyyy")#</td>
							<td>#dateformat(contract_end_date,"mm/dd/yyyy")#</td>
							<td><A HREF="##" style="cursor:pointer;" TITLE="Payment History for #Contract_Number#" onclick="NewWindow('/common_files/contracts/view_contract_payment_history.cfm?ContractId=#contract_main_id#','paymenthistorywindow','1150','620','Yes', 'No'); return false;"><img src="/images/time-money.gif" border = "0"></A></td>
						</tr>
						</cfoutput>
				</table>
				<br><br>
				<table align="center">
					<tr>
						<td>Do you want to continue with mass approval?</b>	</td>
						<td>
							<CF_button
									button_name		=	""
									button_caption	=	"Continue Approval"
									button_action	=	"javascript:document.all.approvalForm.submit();"
									button_type		=	"javascript_link"
									button_width	=	"50"
									button_color	=	"Navy"
									button_tip		=	"save your comments"
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold"
								>
						</td>
						<td>
							<cfif FromFlex eq 0>
								<CF_button
									button_name		=	""
									button_caption	=	"Back to Scorecard"
									button_action	=	"javascript:discontinueapproval();"
									button_type		=	"javascript_link"
									button_width	=	"50"
									button_color	=	"Navy"
									button_tip		=	"save your comments"
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold">
							<!--- Go to main search page (if the user accesses this file from Flex program Search tool --->
							<cfelse>
								<CF_button
									button_name		=	""
									button_caption	=	"Back to Main Search Page"
									button_action	=	"javascript:discontinueapproval();"
									button_type		=	"javascript_link"
									button_width	=	"50"
									button_color	=	"Navy"
									button_tip		=	"save your comments"
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold">
							</cfif>

						</td>
					</tr>
				</table>
				<!--- Pass values in the URL (Useful when the user accesses this file from Flex program Search tool) --->
				<form action="massapproval.cfm?massApprovalProgramList=<cfoutput>#form.massApprovalProgramList#&FromFlex=#FromFlex#&FromAGGrid=#FromAGGrid#</cfoutput>" method="post" name="approvalForm" id="approvalForm">
					<input type="Hidden" name="massApprovalProgramList" value="<cfoutput>#form.massApprovalProgramList#</cfoutput>">
					<input type="Hidden" name="alreadycheckedpaymenthistory" value="1">
				</form>

				<script>
				function discontinueapproval()
				{
					<cfif FromFlex eq 1>
						location.href = '/flex/search/ProgramSearchFx.cfm';
					<cfelseif FromAGGrid eq 1>
						window.close();		
					<cfelse>
						location.href = '/scorecard/scorecard1.cfm?SECTION_TO_OPEN=2';
					</cfif>
				}
				</script>
				<cfabort>
			</cfif> <!--- getprogramswithpaymenthistory --->
		</cfif> <!--- getpaymenthistoryon --->
	</cfif> <!--- form.alreadycheckedpaymenthistory --->


	<CFSET PW_Type="1">
	<span id="PleaseWaitMessage">
	 <br><br><br>
	 <center>
	 <blockquote><blockquote>
	 <font size="+2"><strong>DO NOT CLOSE THIS WINDOW</strong></font>

	 <FORM NAME="timerForm" onSubmit="0"><font size="+2" color="maroon">Time Elapsed:</font>&nbsp;
			<input type="text" name="timerField" size="10" style="border: 0 none; font-size: 20px; color: maroon;"></FORM>
	 <p>
	You are approving <cfoutput>#listlen(form.massApprovalProgramList)#</cfoutput> program(s). It may take a significant amount of time to process the approval of these programs, and evaluate whether you will be approving or agreeing to them.<p></p> Please do not close this window until the processing has stopped, or not all the programs you have selected will be approved.</p>

	<p>We will email you a summary of the approval or agreement to these programs when the process completes.</p>

	<p>Until then, you can <a href="/manufacturers/home.cfm" target="_Blank">click here to continue to work in our application.</a>

	<p></p><strong>DO NOT LOG OUT</strong> until this process is complete.</p>

	<SCRIPT LANGUAGE="JavaScript">
	<!-- Beginning of JavaScript --------
	/*
		JavaScript Timer
		Written by Jerry Aman, Optima System, June 1, 1996.
		Part of the PageSpinner distribution.

		Portions based upon the JavaScript setTimeout example at:
		http://home.netscape.com/eng/mozilla/Gold/handbook/javascript/

		We will not be held responsible for any unwanted
		effects due to the usage of this script or any derivative.
		No warrantees for usability for any specific application are
		given or implied.

		You are free to use and modify this script,
		if the credits above are given in the source code
	*/

		var	timerID = null
		var	timerRunning = false
		var	startDate
		var	startSecs

		function stopclock()
		{
			if(timerRunning)
				clearTimeout(timerID)
				timerRunning = false
		}

		function startclock()
		{
			startDate = new Date()
			startSecs = (startDate.getHours()*60*60) + (startDate.getMinutes()*60)
								+ startDate.getSeconds()

			stopclock()
			showtime()
		}


	/*	-------------------------------------------------
		showtime()
		Puts the amount of time that has passed since
		loading the page into the field named timerField in
		the form named timeForm
		-------------------------------------------------	*/

		function showtime()
		{
			// this doesn't work correctly at midnight...

			var now = new Date()
			var nowSecs = (now.getHours()*60*60) + (now.getMinutes()*60) + now.getSeconds()
			var elapsedSecs = nowSecs - startSecs;

			var hours = Math.floor( elapsedSecs / 3600 )
			elapsedSecs = elapsedSecs - (hours*3600)

			var minutes = 	Math.floor( elapsedSecs / 60 )
			elapsedSecs = elapsedSecs - (minutes*60)

			var seconds = elapsedSecs

			var timeValue = "" + hours
			timeValue  += ((minutes < 10) ? ":0" : ":") + minutes
			timeValue  += ((seconds < 10) ? ":0" : ":") + seconds

				// Update display
			document.timerForm.timerField.value = timeValue
			timerID = setTimeout("showtime()",1000)
			timerRunning = true
		}

	// -- End of JavaScript code -------------- -->
		startclock();
	</SCRIPT>

	</blockquote></blockquote>
	</span>
	<CFFLUSH>


	<SCRIPT>
		document.all.PleaseWaitMessage.style.display='none';
	</SCRIPT>

</cfif> <!--- isScheduledProcess --->

	<CFSET THIS_STATUS=3>
	<CFPARAM name="form.businessSegmentsOn" default="0">
	<CFPARAM NAME="URL.StartRow" DEFAULT=0>


	<CFPARAM NAME="FORM.StartRow" DEFAULT=#URL.StartRow#>
	<cfparam name="form.ProgramDoneList" default="">

	<CFSET StartRow = FORM.StartRow>
	<!---This should process all programs on one big page--->
	<cfset maxrows=(listlen(form.massApprovalProgramList))>
	<cfset StartRow = StartRow + maxrows>
	<cfset NumberOfPages = round(listlen(form.massApprovalProgramList)/maxrows)>
	<cfset ThisPage = StartRow/maxrows>


<cfset Business_Segment_ID_List = "" >
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
	<cfset form.businessSegmentsOn = 1 />
	<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
	<cfset Business_Segment_ID_List = ValueList(qGetBusSegments.Business_Segment_ID, ",")>
</cfif>
<!--- D38387 Programs not routing for approval START --->
	 <CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	     SELECT User_Positions_ID
	     FROM User_Position_Holders
	     WHERE User_ID = '#request.AccessStructure.user_id#' 
	     AND Deleted = 0
	 </CFQUERY>
	 <CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>
	 
 	<CFQUERY NAME="getThisRegionsSubMarketPostions" datasource="#application.datasource#">
	 	if object_id('tempdb..##Positions_Below_Me') is not null 
	 	drop table ##Positions_Below_Me 
	
	 	Create  table ##Positions_Below_Me
	 	(
	 	  Below_User_Positions_ID   int          NOT NULL
	 	)
	
	
	 	INSERT INTO ##Positions_Below_Me(Below_User_Positions_ID)
	 	SELECT	DISTINCT Below_User_Positions_ID
	 	FROM	Positions_Below_Me
	 	WHERE	User_Positions_ID IN (#preservesinglequotes(GP_Supplied_Position)#)

	 	CREATE  CLUSTERED  INDEX [I_Below_User_Positions_ID_tmp] ON [dbo].[##Positions_Below_Me]([Below_User_Positions_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]
 	</CFQUERY>	 
 <!--- D38387 Programs not routing for approval END --->


<CFINCLUDE TEMPLATE="access_permissions.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>


	<!--- 74451: Volume sent in 2000 interface / 05-Feb-2018 / Anand Rao --->
	<cfset volumeApplicator = CreateObject("component", "mvc.Models.Program.Volume.VolumeApplicator") />	
	<cfloop index="frmProgID" from="1" to="#maxrows#"> 
		<cfset ProgramVolume = CreateObject("component", "components.programs.volume.ProgramVolume") />
		<!--- this function will make sure groups member are capture if program has groups and contract_main.group_processed = 1  --->
		<cfset ProgramVolume.processGroups(programID = ListGetAT(form.massApprovalProgramList,frmProgID)) />
		
		<cfstoredproc procedure="Get_Program_Product_Volume_Forecast" datasource="#application.datasource#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@contract_main_id" null="no" value="#ListGetAT(form.massApprovalProgramList,frmProgID)#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@mode" null="no" value="EDIT">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@group_by" null="no" value="">
			      
			<cfprocresult name="getProductVolumeChk" resultset="1">
			<cfprocresult name="getForecastIdChk" resultset="2">
		</cfstoredproc>
		
	
		<!--- Get all the rows that has the cases as 1, which means it is not user edited and we need to update it with the forecast values. --->	
		<cfquery name="qChkUserChanged" dbtype="query">
			SELECT * FROM getProductVolumeChk WHERE cases_Temp = 1 and user_edited = 0
		</cfquery>
		
		<!--- 
			Check to see if the 2 recordcounts are different, meaning there is atleast 
			one row which does not have cases_temp as 1, ie user modified the row.
		 --->
		<cfif (getProductVolumeChk.RecordCount NEQ qChkUserChanged.RecordCount)>
			
			<cfstoredproc procedure="Get_Program_Product_Volume_Forecast" datasource="#application.datasource#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@contract_main_id" null="no" value="#ListGetAT(form.massApprovalProgramList,frmProgID)#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@mode" null="no" value="EDIT-FORECAST">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@group_by" null="no" value="">
			      
			<cfprocresult name="getProductVolume" resultset="1">
			<cfprocresult name="getForecastId" resultset="2">
		</cfstoredproc>
			
			<cfset colList = getProductVolume.ColumnList />
			<cfset arVolume = ArrayNew(1) />
			<cfloop query="getProductVolume">
				<cfset stVol = StructNew() />
				<cfloop list="#colList#" index="thisColumn">
					<cfset stVol["#thisColumn#"] = getProductVolume["#thisColumn#"][currentRow] />
				</cfloop>
				<cfset arVolume[ArrayLen(arVolume) + 1] = stVol />
			</cfloop>
			
			<cfset returnValue = volumeApplicator.updateVolumeDetails(
					ProgramId = #ListGetAT(form.massApprovalProgramList,frmProgID)#, 
					updateVolumeData = arVolume,
					UserID = request.AccessStructure.User_ID,
					sReturnType = "struct") />
		
		</cfif>			
	</cfloop>
	<!--- END: 74451  --->

	<cfquery name="getRevisionData" datasource="#application.datasource#">
		SELECT  top #maxrows#
				Contract_Main.Is_A_Revision, Contract_Main.Contract_Main_ID, Parent_Programs.Contract_Start_Date AS Parent_Contract_Start_Date,
				Contract_Main.Contract_Number, Contract_Main.Contract_Title, Contract_Main.Contract_Status_Type_IDX,Contract_Main.Contract_Start_Date,
				Contract_Main.Contract_End_Date, Parent_Programs.Contract_End_Date AS Parent_Contract_End_Date, Parent_Programs.Contract_Main_ID AS Parent_Contract_Main_ID
				,Contract_Main.Creating_User_Position_ID,PCPO.EZButton_On
		FROM	Contract_Main
		LEFT OUTER JOIN Contract_Main Parent_Programs ON Contract_Main.Revision_of_Contract_Main_ID = Parent_Programs.Contract_Main_ID
		INNER JOIN Program_Control_Panel_Options PCPO
		ON PCPO.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
		WHERE Contract_Main.Contract_Main_ID IN (#form.massApprovalProgramList#)
		AND Contract_Main.contract_status_type_idx = 2
		<cfif form.ProgramDoneList NEQ "">
		AND  Contract_Main.Contract_Main_ID NOT IN (#ListQualify(form.ProgramDoneList,"'",",","all")#)
		</cfif>
		ORDER BY Contract_Main.Contract_Main_ID
	</cfquery>

	<cfset form.ProgramDoneList = ListAppend(form.ProgramDoneList,ValueList(getRevisionData.Contract_Main_ID))>

	<cfset form_massApprovalProgramList = form.massApprovalProgramList />
	<cfset form_ProgramDoneList = form.ProgramDoneList />

<!--- "cfsavecontent" for the header. --->
<cfsavecontent variable = "ApprovedAgreedListHeader">
<table cellspacing="0" cellpadding="3" align="center" width="700">
<tr BGCOLOR="FFE083">
	<td width="100"><span CLASS="tableheaders" valign="top">Program</span></td>
	<td width="300"><span CLASS="tableheaders" valign="top">Title</span></td>
	<td width="100"><span CLASS="tableheaders" valign="top">Start</span></td>
	<td width="25"><span CLASS="tableheaders" valign="top">-</span></td>
	<td width="100"><span CLASS="tableheaders" valign="top">End</span></td>
	<td width="100"><span CLASS="tableheaders" valign="top">Approved/Agreed</span></td>
</tr>
</table>
</cfsavecontent>
	
<cfloop query="getRevisionData">
<!--- Milan Mushran (43893) "cfsavecontent" tag for each of the program.
This is needed as we are using <cfflush> for the progress bar and we so we
cannot use <cfflush> inside "cfsavecontent" tag.
--->
<cfset CMID = getRevisionData.Contract_Main_ID>

<cfsavecontent variable = "ApprovedAgreedList_#CMID#">
<table cellspacing="0" cellpadding="3" align="center" width="700">
		<cfset LetUserApprove = 0>

 <!--- D38387 Programs not routing for approval START --->
	<cfquery name="checkPositions" datasource="#application.datasource#">
	SELECT * 
	FROM ##Positions_Below_Me
	WHERE Below_User_Positions_ID = #getRevisionData.Creating_User_Position_ID#
	</cfquery>
		<cfif checkPositions.recordcount EQ 0>
			<cfset LetUserApprove = -1>
		<!--- DO NOTHING --->
 <!--- D38387 Programs not routing for approval END --->

		<cfelseif Get_Profile_Settings.program_margin_approval_method IS 5><!--- LAYERED --->
			
			<!--- Approve freight if the user has rights to approve freight  --->
			<cfset qProgramInfo = application.oProgram.getProgramInfo(programId = getRevisionData.Contract_Main_ID) />

			<cfif qProgramInfo.contract_status_type_idx eq 2
				and   qProgramInfo.Freight_Approval_Required eq 1
				and   qProgramInfo.Freight_Approved eq 0
				and   Get_Profile_Settings.Approve_Freight_Programs eq 1>
				<cfset application.oProgramFreightManager.approveFreight(programID = getRevisionData.Contract_Main_ID, userId = request.AccessStructure.User_ID) />
			</cfif>

			<!--- set variables --->
			<CF_Cryp type="en" key="#request.key#" string ="#getRevisionData.Contract_Main_ID#">
			<cfset URL.CID = cryp.value>
			<cfset stMassApproval = StructNew() />
			<cfset programAgreeOnlyForBudgetDollar = 0 />
			<!--- Dev Note: drachala; D28091: Mass Approve issue  START
			What  I did: we are resetting PRPGRAMAGREE and CANNOTAPPROVESETTINGS to 0--->
			<cfset ProgramAgree = 0 />
			<cfset CannotApproveSettings = 0>
			<!--- End Dev Note: drachala; D28091: Mass Approve issue  --->
			<!--- Dev Note: drachala; D28874: Mass approve multiple programs  START            
            Added/Changed: Reset following variables to 0--->
			<cfset CANNOTAPPROVE = 0>
			<cfset CANNOTAPPROVEGROUPMARGIN = 0>
			<cfset CANNOTAPPROVEITEM = 0>
			<cfset CANNOTAPPROVEITEMMARGIN = 0>
			<cfset CANNOTAPPROVELUMPSUM = 0>
			<cfset CANNOTAPPROVEPROGRAMMARGIN = 0>
			<!--- End Dev Note: drachala; D28874: Mass approve multiple programs  --->
			<cfset massapproval = 1>
			<cfset approvaltype = 1 /> <!--- it's wierd, defaults to 1 --->
			<cfset agreetype = 0 />
			<cfset LetUserApprove = -1 /> <!--- no action --->
			<cfset form.BUSINESS_CONSIDERATIONS = "" />
			<cfif IsDefined("Discount_Queries_Called") and Discount_Queries_Called eq 1>
				<cfset Discount_Queries_Called = 0 >
			</cfif>
			<!--- Dev Note: drachala; D28875: Element TEMPLATE_FILTER_DESCRIPTION is undefined in CSLGETCONTRACTINFO  START
            Added/Changed: reset commonqueries_Called variable to rerun query CSLGETCONTRACTINFO in common Queries file.--->
			<cfset commonqueries_Called = 0 />
			<!--- End Dev Note: drachala; D28875: Element TEMPLATE_FILTER_DESCRIPTION is undefined in CSLGETCONTRACTINFO  --->
			<cfset margin_version = "current" />

	<!---D49430 :: APF Enhancement: Mass Approval for programs using max rates START--->
	<!--- D58160  :: Mass Approved Programs in RFA
		IN Label D49430 we did not took into account that a program can have combination of Rebate, lumpsum and fixed components.
		Code written in label D494320 to only auto approve items which match ez button scenario reset of items not approved in that scenario.
		FIX :: Removed else statement around regular approval process so that Items which does not match ez button scenario can go through normal approval process.
	--->	
	<cfif appSettings.getCustomMaxRate() AND getRevisionData.EZButton_On>
	
		<cfset qProductsNotApproved = CreateObject("component","components.programs.Approval.ApprovalManager").autoApproveEZProducts(CMID, request.AccessStructure.user_id) />
		
		<cfif qProductsNotApproved.recordcount AND Get_Profile_Settings.EzButton_Approve_Beyond_MaxRate EQ 0>
			<cfset agreetype = 1 />
		</cfif>
			
	</cfif>

			<!--- call margin routine --->
			<cfsilent>
			<cfinclude template="/common_files/contracts/layered_margin_calculation_mass_approve.cfm">
			</cfsilent>


<!---D49430 :: APF Enhancement: Mass Approval for programs using max rates END--->			
			<!--- can user agree or approve this program --->
			<cfif approvaltype eq 1 or agreetype eq 1>

				<!--- set budget variables --->
				<cfif appSettings.getBudgetsFunctionalityOn()>

					<!--- flag the program as agreed
					- if the program has more than one budget as an option
					- or if the budget dollar is not withtin approval limits  --->
					<cfif programAgreeOnlyForBudgetDollar >
						<cfloop list="#StructKeyList(stMassApproval)#" index="thisKey">
							<cfif Left(thisKey, 15) eq "ProductApprove_"
									or Left(thisKey, 13) eq "GroupApprove_">
								<cfset thisValue = stMassApproval[thisKey] />
								<cfset newKey = Replace(thisKey, "Approve", "Agree") />
								<cfset StructDelete(stMassApproval, thisKey)>
								<cfset StructInsert(stMassApproval, newKey, thisValue)>
							</cfif>
						</cfloop>
					</cfif>
				</cfif>

				<!--- we don't want old vars from program 1 to carry over to program 2 --->
				<cfloop list="#StructKeyList(form)#" index="thisKey">
					<cfif Left(thisKey, 15) eq "ProductApprove_"
							or Left(thisKey, 13) eq "GroupApprove_">
						<cfset StructDelete(form, thisKey)>
					</cfif>
				</cfloop>

				<cfset StructAppend(form, stMassApproval)>
				<cfset form.programid = URL.CID />
				<cfset form.FIELDNAMES =  StructKeyList(stMassApproval) />

				<!---Approve MP If necessary--->
				<cfset MPManager = CreateObject("component", "mvc.Models.Template.MarketPriceManager") />
				<cfif MPManager.getProgramActiveMPList(getRevisionData.Contract_Main_ID) gt 0>
					<cfset tmp =  MPManager.approveMarketPriceProgram(getRevisionData.Contract_Main_ID) />
				</cfif>
				
				<!--- call margin action to set the products / type code / program as agreed / approved --->
				<cfinclude template="/common_files/contracts/contract_layered_Approve_Action.cfm">

				<CFQUERY NAME="qGetProgramStatus" datasource="#application.datasource#">
					SELECT	Contract_Status_Type_IDX
					FROM	Contract_Main
					WHERE 	Contract_Main_ID = '#getRevisionData.Contract_Main_ID#'
				</CFQUERY>

				<!--- set the variable LetUserApprove so it can show the details --->
				<cfif qGetProgramStatus.Contract_Status_Type_IDX GTE 3>
					<cfset LetUserApprove = 1 />
				<cfelse>
					<cfset LetUserApprove = 0 />
				</cfif>

			</cfif>

		<cfelseif Get_Profile_Settings.program_margin_approval_method IS 4><!--- SPENDING CAP --->

		  	<cfsilent>
			<CF_Cryp type="en" key="#request.key#" string ="#getRevisionData.Contract_Main_ID#">
			<cfset URL.CID = cryp.value>
			
			<!--- D37447 START:  Mass Approve TEMPLATE_FILTER_DESCRIPTION is undefined error --->
			<!--- Dev Note: drachala; D28091: Mass Approve issue  START
			What  I did: we are resetting PRPGRAMAGREE and CANNOTAPPROVESETTINGS to 0--->
			<cfset ProgramAgree = 0 />
			<cfset CannotApproveSettings = 0>
			<!--- End Dev Note: drachala; D28091: Mass Approve issue  --->
			<!--- Dev Note: drachala; D28874: Mass approve multiple programs  START            
            Added/Changed: Reset following variables to 0--->
			<cfset CANNOTAPPROVE = 0>
			<cfset CANNOTAPPROVEGROUPMARGIN = 0>  
			<cfset CANNOTAPPROVEITEM = 0>
			<cfset CANNOTAPPROVEITEMMARGIN = 0> 
			<cfset CANNOTAPPROVELUMPSUM = 0>  
			<cfset CANNOTAPPROVEPROGRAMMARGIN = 0>  
			<!--- End Dev Note: drachala; D28874: Mass approve multiple programs  --->
			<cfset massapproval = 1>
			<cfset approvaltype = 1 /> <!--- it's wierd, defaults to 1 --->
			<cfset agreetype = 0 />
			<cfset LetUserApprove = -1 /> <!--- no action --->			
			<cfset form.BUSINESS_CONSIDERATIONS = "" />
			<cfif IsDefined("Discount_Queries_Called") and Discount_Queries_Called eq 1>
				<cfset Discount_Queries_Called = 0 >
			</cfif>
			<!--- Dev Note: drachala; D28875: Element TEMPLATE_FILTER_DESCRIPTION is undefined in CSLGETCONTRACTINFO  START            
            Added/Changed: reset commonqueries_Called variable to rerun query CSLGETCONTRACTINFO in common Queries file.--->
			<cfset commonqueries_Called = 0 />
			<!--- End Dev Note: drachala; D28875: Element TEMPLATE_FILTER_DESCRIPTION is undefined in CSLGETCONTRACTINFO  --->
			<!--- D37447 END:  Mass Approve TEMPLATE_FILTER_DESCRIPTION is undefined error --->
			
			
			<cfset startrow = 1>
			<cfinclude template="/common_files/contracts/program_approval.cfm">
			</cfsilent>


			 <cfif LetUserApprove EQ 1>
			 	 <cfset CloseWindow = 0>
				 <CFQUERY NAME="GetContractInfo" datasource="#application.datasource#">
						SELECT Contract_Start_Date, Contract_End_Date, Revision_Of_Contract_Main_ID
						FROM Contract_Main
						WHERE Contract_Main_ID = '#getRevisionData.Contract_Main_ID#'
				</CFQUERY>
				 <cfinclude template="/common_files/contracts/contract_approve_action_include.cfm">
			<cfelse>
				<!---taken from common_files/contracts/program_agree_action.cfm--->
				<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init() />
				<cfset realProgramManager = programManager/>
				<cfset programManager.setUserAgree(getRevisionData.Contract_Main_ID, request.AccessStructure.User_ID, request.AccessStructure.Profiles_ID) />
				<!------ Update the Pending Approval table ----->
				<cfquery name="qUpdateApprovaltable" datasource="#application.datasource#">
					EXEC Populate_Program_Approvable_Positions #getRevisionData.Contract_Main_ID#
				</cfquery>
				<CFSET AgreeEmailProgramId 	= getRevisionData.Contract_Main_ID />
				<CFSET AgreeEmailUserId 	= request.AccessStructure.user_id />
				<cfinclude template="/Common_Files/contracts/Send_Agree_Email.cfm">
			</cfif>

		<cfelse>
			<cfset LetUserApprove = -1>
		</cfif>

		<cfoutput>
			<tr>
				<td width="100"><b>#getRevisionData.Contract_Number#</b></td>
				<td width="300"><b>#getRevisionData.Contract_Title#</b></td>
				<td width="100"><b>#dateformat(getRevisionData.Contract_Start_Date, 'mm/dd/yyyy')#</b></td>
				<td width="25"><b>-</b></td>
				<Td width="100"><b>#dateformat(getRevisionData.Contract_End_Date, 'mm/dd/yyyy')#</b></TD>
				<cfif LetUserApprove EQ 1>
				<Td width="100"><b>Approved</b></TD>
				<cfelseif LetUserApprove EQ -1>
				<Td width="100"><b>No Action</b></TD>
				<cfelse>
				<Td width="100"><b>Agreed</b></TD>
				</cfif>
			</tr>
		</cfoutput>
		</table>
		</cfsavecontent>

		<!--- If it is remote approval, then we not show the progress bar. --->
		<cfif not(isScheduledProcess)>
			<!--- Note: Here 1 means 10% and 10 means 100% --->
			<cfset PercentDone = Int(Ceiling((getRevisionData.currentrow/getRevisionData.recordcount) * 100)/10)>

			<cfoutput>
			<script>
				updateProgressBar('#getRevisionData.currentRow#','#getRevisionData.recordCount#','#PercentDone#');
			</script>
			</cfoutput>
			<cfflush>
		</cfif>
	</cfloop>

<!--- Ger a list of program id's.
I am not using the form variable passed because it is possible (not common) that one or more programs
fail the conditions in the query (getRevisionData) and so do not get processed.
--->
<cfquery name="qGetProgramIDs" dbtype="query">
	SELECT Contract_Main_ID 
	FROM getRevisionData
</cfquery>

<!--- Earlier, we only had one "cfsavecontent" tag above. Now, we need to show a progress bar.
For progress bar, we need to use "cfflush". "cfflush" cannot be inside the "cfsavecontent" tag.
That is why the "cfsavecontent" above is being used a little differently:
- One for the header.
- Rest for all the programs which have been approved. There will be 1 for every program.
.--->
<!--- Need to loop through all the programs below, so that one --->
<cfoutput>
	#ApprovedAgreedListHeader#
	<cfloop query="qGetProgramIDs">
		#Evaluate('ApprovedAgreedList_'&Contract_Main_ID)#
	</cfloop>

	<cf_EmailWrapper
		to="#request.AccessStructure.User_Email#"
		from="#Contact_Admin_Email_Address#"
		subject="Programs Approved/Agreed in Mass Approval"
		type="HTML"
		messagetype="1"
		generatedby="1"
		apparea="1">

		#ApprovedAgreedListHeader#
		<cfloop query="qGetProgramIDs">
			#Evaluate('ApprovedAgreedList_'&Contract_Main_ID)#
		</cfloop>
	</cf_EmailWrapper>
</cfoutput>

<!--- Dev Note: KAL; D19440: Approval via Email: If scheduled process, skip this check --->
<cfif not(isScheduledProcess)>

	<cfoutput>
		<FORM ACTION="massapproval.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
			<INPUT TYPE="Hidden" NAME="massApprovalProgramList" VALUE="#form_massApprovalProgramList#">
			<INPUT TYPE="Hidden" NAME="StartRow" VALUE="#StartRow#">
			<INPUT TYPE="Hidden" NAME="ProgramDoneList" VALUE="#form_ProgramDoneList#">
		</FORM>
	</cfoutput>


	<BR>
	<div align="center">
		<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">
			<cfif FromFlex eq 1>
				<A HREF="/flex/search/ProgramSearchFx.cfm?Reload=1">return to search</A>
			<cfelseif FromAGGrid eq 1>
				<A HREF="void()" onClick="goBackToMainPage()">return to Main Page</A>				
			<cfelse>
				<A HREF="/Manufacturers/home.cfm">return to Main Page</A>
			</cfif>
		</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
	</div>


	<SCRIPT LANGUAGE="javaScript">
		function goBackToMainPage(){
			window.opener.location.href = '/programs/program_search.cfm';
			window.close();
		}
	
		function submitmassapprovalform()
		{
			MyForm.submit();
		}
	</script>

</cfif> <!--- isScheduledProcess 
/* Hide the progress bar */
--->

<script>
 if(document.getElementById('Progress_Bar')){
 	document.getElementById('Progress_Bar').style.display = 'none';
 }
 </script>