<cfparam name="form.pagemode" default="firstload">
<cfparam name="LastDateExclusionEntry" default ="">

<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<cfset Program_ID = cryp.value>

<!--- legacy code program ID buffers --->
<cfset THISPROGRAMID = Program_ID>
<cfset CSL_Contract_Main_ID = Program_ID>

<!--- set page code ID --->
<cfset CSL_CallingPageCode = "pe">

<cfset useLakebaseForcheckifparentisRFA = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForcheckifparentisRFA>
	<cftry>
		<cfset checkifparentisRFA = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#CSL_Contract_Main_ID#",
				"select" = "contract_status_type_idx"
			}), "contract_status_type_idx"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckifparentisRFA = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckifparentisRFA>
<cfquery name="checkifparentisRFA" datasource="#application.datasource#">
	select contract_status_type_idx from contract_main
	where contract_main_id = #CSL_Contract_Main_ID#
</cfquery>
</cfif>

<cfswitch expression="#lcase(form.pagemode)#">
	<cfcase value="add"> 
		
		<cfset Program_ID_To_Replicate = Program_ID>
		<cfset isdateexclusion = 1>
		<cfinclude template="replicate_program.cfm">
		
		<cfset LongTermData_ProgramID = Program_ID>
		<cfset LongTermData_Packet = Duplicate(Program)>
		<cfinclude template="SAVE_LongTermWDDXProgramCopy.cfm">
		
		<!--- <cfdump var="#program#"> --->
		<CFSET Program.Basic_Information.ISEXCLUSIONREVISION = 1>
		<CFSET Program.Basic_Information.Contract_Start_Date = form.start_date>
		<CFSET Program.Basic_Information.Contract_End_Date 	= form.end_date>
		<!--- custom release modifications --->
		<CFSET Program.Basic_Information.Is_A_Revision = 1>
		<CFSET Program.Basic_Information.DELETED = 0>
		<CFSET Program.Basic_Information.Is_Manual_Revision = 0>
		<CFSET Program.Basic_Information.Revision_of_Contract_Main_ID = Program_ID>
		<CFSET Program.Basic_Information.Parent_Revised_Contract_Main_ID = Program_ID>
		
	<CFSET Program.Basic_Information.APPROVAL_DATE = "NULL">
	<CFSET Program.Basic_Information.APPROVED = 0>
	<CFSET Program.Basic_Information.APPROVED_BY_USER_ID = "NULL">
	
	<cfif checkifparentisRFA.contract_status_type_idx EQ 2>
	<CFSET Program.Basic_Information.BROKER_APPROVED = 1>
	<CFSET Program.Basic_Information.BROKER_APPROVED_DATE = "#now()#">
	<CFSET Program.Basic_Information.BROKER_USER_ID = "#request.AccessStructure.user_id#">
	<cfelse>
	<CFSET Program.Basic_Information.BROKER_APPROVED = 0>
	<CFSET Program.Basic_Information.BROKER_APPROVED_DATE = "NULL">
	<CFSET Program.Basic_Information.BROKER_USER_ID = "NULL">
	</cfif>
	<CFSET Program.Basic_Information.CONTRACT_IS_LOCKED = 0>
	<CFSET Program.Basic_Information.RFA_EMAIL_SENT = 0>
	<CFSET Program.Basic_Information.SCORECARD_PROGRAM_AGREE = 0>
	<CFSET Program.Basic_Information.CONTRACT_STATUS_TYPE_IDX = 1>

			<!--- serialize packet --->
			<CFWDDX ACTION="CFML2WDDX" INPUT="#Program#" OUTPUT="Program_Packet" USETIMEZONEINFO="Yes">
			<!--- get application install path --->
			<!--- create usable directory information --->
			<CFSET The_File_Location = Application.Doc_Path & "\temp_files\contracts\XML_Programs\#replace('#Createuuid()##createuuid()#', '-','','ALL')#.xml">
			<!--- end create usable directory information --->	
			<!--- save the wddx packet to the disk because i cant pull the entire packet from the db easily--->
			<CFSET XML_File_Location = The_File_Location>	
			<CFFILE ACTION="WRITE" FILE="#XML_File_Location#" OUTPUT="#Program_Packet#" ADDNEWLINE="Yes">
			
		 	<CFQUERY NAME="savePacket" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO Contract_Renewal_Packets
				(Packet_Data, XML_File_Location)
				VALUES
				('#Program_Packet#', '#XML_File_Location#')
			
				SELECT Contract_Renewal_Packets_ID = @@IDENTITY  
				SET NOCOUNT OFF	
			</CFQUERY>
			
		<cfset form.CONTRACT_RENEWAL_PACKETS_ID = savePacket.Contract_Renewal_Packets_ID>
		<cfset PROGRAMID = Program_ID><!--- wow --->
		
		<cfinclude template="replicate_program_action.cfm">


		<cfset useLakebaseForsaveExclusion = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_exclusions")>
<cfif useLakebaseForsaveExclusion>
	<cftry>
		<cfset application.oLakebase.insertRow("program_exclusions", {
			"original_program_id" = "#Program_ID#",
			"revision_program_id" = "#Renewed_Program_ID#",
			"start_date" = "#form.start_date#",
			"end_date" = "#form.end_date#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveExclusion = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveExclusion>
<cfquery name="saveExclusion" datasource="#application.datasource#">
			INSERT INTO Program_Exclusions
			(
				Original_Program_ID, 
				Revision_Program_ID,
				Start_Date,
				End_Date
			)
			VALUES
			(
				'#Program_ID#', 
				'#Renewed_Program_ID#',
				'#form.start_date#',
				'#form.end_date#'
			)
		</cfquery>
</cfif>
		<cflocation url="contract_exclusions.cfm?CID=#URL.CID#">
	</cfcase>
	
	<cfcase value="delete">
		<cfset useLakebaseForgetExclusionProgramID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_exclusions")>
<cfif useLakebaseForgetExclusionProgramID>
	<cftry>
		<cfset getExclusionProgramID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_exclusions", {
				"program_exclusion_id" = "eq.#form.delProgram_Exclusion_ID#",
				"select" = "revision_program_id"
			}), "revision_program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetExclusionProgramID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetExclusionProgramID>
<cfquery name="getExclusionProgramID" datasource="#application.datasource#">
			SELECT Revision_Program_ID
			FROM Program_Exclusions	
			WHERE Program_Exclusion_ID = '#form.delProgram_Exclusion_ID#'
		</cfquery>
</cfif>
		
		<cfset useLakebaseFordeleteExclusion = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_exclusions")>
<cfif useLakebaseFordeleteExclusion>
	<cftry>
		<cfset application.oLakebase.updateRows("program_exclusions",
			{
				"program_exclusion_id" = "eq.#form.delProgram_Exclusion_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteExclusion = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteExclusion>
<cfquery name="deleteExclusion" datasource="#application.datasource#">
			UPDATE Program_Exclusions
			SET Deleted = 1
			WHERE Program_Exclusion_ID = '#form.delProgram_Exclusion_ID#'
		</cfquery>
</cfif>
		
		<cfset useLakebaseFordeleteProgramWithIt = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseFordeleteProgramWithIt>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#getExclusionProgramID.Revision_Program_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteProgramWithIt = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteProgramWithIt>
<cfquery name="deleteProgramWithIt" datasource="#application.datasource#">
			UPDATE Contract_Main
			SET Deleted = 1
			WHERE Contract_Main_ID = #getExclusionProgramID.Revision_Program_ID#
		</cfquery>
</cfif>
		
		<cflocation url="contract_exclusions.cfm?CID=#URL.CID#">
	</cfcase>
</cfswitch>

<cfquery name="getContractNumber" datasource="#application.datasource#">
SELECT   Contract_number
FROM         dbo.Program_Exclusions INNER JOIN
                      dbo.Contract_Main ON dbo.Program_Exclusions.Revision_Program_ID = dbo.Contract_Main.Contract_Main_ID
	WHERE Program_Exclusions.Original_Program_ID = '#Program_ID#' AND Program_Exclusions.Deleted = 0
	ORDER BY Program_Exclusions.Start_Date
</cfquery>

<CFQUERY NAME="getContractCount" datasource="#application.datasource#">
	SELECT max(revision_version) as revision_version
	FROM Contract_main
	WHERE contract_number = '#getContractNumber.Contract_number#'
	AND IsExclusionRevision = 1
	AND Deleted = 0
</CFQUERY>

<cfif getContractCount.Recordcount GT 0>
	<CFQUERY NAME="updateRevisionVersion" datasource="#application.datasource#">
		UPDATE Contract_Main
		Set revision_version = #getContractCount.revision_version# + 1
		WHERE contract_number = '#getContractNumber.Contract_number#'
		AND IsExclusionRevision  = 1
		AND Deleted = 0
		AND revision_version = 1
	</CFQUERY>
	
	<cfset useLakebaseForgetRevisionVersion = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetRevisionVersion>
	<cftry>
		<cfset getRevisionVersion = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_number" = "eq.#getContractNumber.Contract_number#",
				"isexclusionrevision" = "eq.1",
				"deleted" = "eq.0",
				"select" = "contract_number,revision_version"
			}), "contract_number,revision_version"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetRevisionVersion = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetRevisionVersion>
<CFQUERY NAME="getRevisionVersion" datasource="#application.datasource#">
		SELECT contract_number,revision_version
		FROM Contract_Main
		WHERE contract_number = '#getContractNumber.Contract_number#'
		AND IsExclusionRevision  = 1
		AND Deleted = 0
	</CFQUERY>
</cfif>
</cfif>


<!--- decrypt program id --->
<cfquery name="getExclusions" datasource="#application.datasource#">
SELECT    *,dbo.Contract_Main.Contract_Quantity_UOM_IDX
FROM         dbo.Program_Exclusions INNER JOIN
                      dbo.Contract_Main ON dbo.Program_Exclusions.Revision_Program_ID = dbo.Contract_Main.Contract_Main_ID
	WHERE Program_Exclusions.Original_Program_ID = '#Program_ID#' AND Program_Exclusions.Deleted = 0
	ORDER BY Program_Exclusions.Start_Date
</cfquery>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left : 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>

<BLOCKQUOTE><BLOCKQUOTE>

<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = Program_ID>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:120px; z-index:1; left: 80px; top: 0px;"> </cfif>
<cfinclude template="minimal_contract_info.cfm">


<cfoutput>
	
	<cfset Date_Exclusion_Start_Date = DateFormat(CSLGETCONTRACTINFO.CONTRACT_Start_DATE,"MM/DD/YYYY")>
	<cfset jsYear_ProgramStartDate = DateFormat(CSLGETCONTRACTINFO.CONTRACT_Start_DATE, 'yyyy')>
	<cfset jsMonth_ProgramStartDate = DateFormat(CSLGETCONTRACTINFO.CONTRACT_Start_DATE, 'm')-1>
	<cfset jsDay_ProgramStartDate = DateFormat(CSLGETCONTRACTINFO.CONTRACT_Start_DATE, 'd')>

	<cfset jsYear_ProgramEndDate = DateFormat(CSLGETCONTRACTINFO.CONTRACT_End_DATE, 'yyyy')>
	<cfset jsMonth_ProgramEndDate = DateFormat(CSLGETCONTRACTINFO.CONTRACT_End_DATE, 'm')-1>
	<cfset jsDay_ProgramEndDate = DateFormat(CSLGETCONTRACTINFO.CONTRACT_End_DATE, 'd')>

	<cfset jsYear_Today = DateFormat(Now(), 'yyyy')>
	<cfset jsMonth_Today = DateFormat(Now(), 'm')-1>
	<cfset jsDay_Today = DateFormat(Now(), 'd')>
	
	<script>
	
	//create a list of existing program exclusion dates
	var ExistingDates = new Array();
	<cfset RC = 0>
	<cfloop query="getExclusions">
		<cfset jsYear_ExclusionStartDate = DateFormat(getExclusions.Start_DATE, 'yyyy')>
		<cfset jsMonth_ExclusionStartDate  = DateFormat(getExclusions.Start_DATE, 'm')-1>
		<cfset jsDay_ExclusionStartDate  = DateFormat(getExclusions.Start_DATE, 'd')>	

		<cfset jsYear_ExclusionEndDate = DateFormat(getExclusions.End_DATE, 'yyyy')>
		<cfset jsMonth_ExclusionEndDate = DateFormat(getExclusions.End_DATE, 'm')-1>
		<cfset jsDay_ExclusionEndDate = DateFormat(getExclusions.End_DATE, 'd')>
		
		<cfset LastDateExclusionEntry = DateFormat(getExclusions.End_DATE, "MM/DD/YYYY")>
		
		ExistingDates[#RC#] = new Array("#getExclusions.Program_Exclusion_ID#", new Date(#jsYear_ExclusionStartDate#,#jsMonth_ExclusionStartDate#,#jsDay_ExclusionStartDate#), new Date(#jsYear_ExclusionEndDate#,#jsMonth_ExclusionEndDate#,#jsDay_ExclusionEndDate#))
		<cfset RC = RC + 1>
	</cfloop>
		
	
	function checkUserDatesAgainstExistingDates(oStartDate,oEndDate, callerType) {
		/*
			callerType
			1 = user
			2 = function
		*/
			var showOK = 1;
			var LastDateExclusion = new Date();
			var DateExclusionStartDate = new Date();
		
			//end date must come after start date
			if(UserStartDate >= UserEndDate) {
				alert("The start date must be before the end date.");
				return false;
				showOK = 0;
			}

			//start date must be one day after the program start date 
			DateExclusionStartDate = <cfoutput>"#Date_Exclusion_Start_Date#"</cfoutput>;			
			DateExclusionStartDate = convertValueToJSDate(DateExclusionStartDate);
			if(UserStartDate < DateExclusionStartDate) {
				alert("The start date must be on or after the program start date.");
				return false;
				showOK = 0;
			}

			//end date must not exceed program end date
			if(UserEndDate > ProgramEndDate) {
				alert("The end date must be on or before the end date of the program which is: #DateFormat(CSLGETCONTRACTINFO.CONTRACT_End_DATE, 'mm/dd/yyyy')#");
				return false;
				showOK = 0;
			}
			
			// Date exclusions must be entered in chronological order
			<cfif LastDateExclusionEntry neq "">
			LastDateExclusion = <cfoutput>"#LastDateExclusionEntry#"</cfoutput>;			
			LastDateExclusion = convertValueToJSDate(LastDateExclusion);
			
			if(oStartDate < LastDateExclusion)
			{
				alert("Date exclusions must be entered in chronological order. Adjust your dates or delete the previously saved date/s");
				return false;
				showOK = 0;
			}	
			</cfif>	
		
		
		if(ExistingDates.length == 0 && showOK == 1 && callerType == 1) 
		{
			alert("The proposed range is acceptable");
		}
		
		if(ExistingDates.length == 0) return true;	
		
		noOverlapFound = true;
		for(var x=0; x<ExistingDates.length; x++) {
			e = ExistingDates[x];
			existingStart = e[1];
			existingEnd = e[2];
			newStart = oStartDate;
			newEnd = oEndDate;
			
			oRow = eval("document.all.exRow_" + e[0]);
		
<!--- 		alert(existingStart + " - " + existingEnd);
		alert(1 + " " + (existingStart >= newStart && existingEnd >= newEnd));
		alert(2 + " " + (existingStart <= newStart && existingEnd <= newEnd));
		alert(3 + " " + (existingStart >= newStart && existingEnd <= newEnd)); --->
		
		if( (existingStart > newStart && existingStart > newEnd) || (existingEnd < newStart && existingEnd < newEnd)  ){
				color = "";
				oRow.style.backgroundColor = '';	
		}
		else {
				oRow.style.backgroundColor = 'Red';
				noOverlapFound = false;		
		}
	}

		if(!noOverlapFound) alert("Overlap discovered with highlighted exclusion");
		
		if(noOverlapFound && callerType == 1) alert("The proposed date range is available.")
		
		return noOverlapFound;

}
	
		// expects mm/dd/yyyy
		function convertValueToJSDate(oValue) {
			rawDataArray 	= oValue.split("/");
			tmpMonth 			= rawDataArray[0];
			tmpDay 				 = rawDataArray[1];
			tmpYear 			= rawDataArray[2];
			tmpMonth = tmpMonth - 1;
			tmpDate = new Date(tmpYear,tmpMonth,tmpDay);
			return tmpDate;
		}
		
		
		var ProgramStartDate = new Date(#jsYear_ProgramStartDate#,#jsMonth_ProgramStartDate#,#jsDay_ProgramStartDate#);
		var ProgramEndDate = new Date(#jsYear_ProgramEndDate#,#jsMonth_ProgramEndDate#,#jsDay_ProgramEndDate#);
		
		var UserStartDate = new Date();
		var UserEndDate = new Date();
		
		var TodaysDate = new Date(#jsYear_Today#,#jsMonth_Today#,#jsDay_Today#);
		
		function addExclusion() {
			UserStartDate = convertValueToJSDate(document.all.start_date.value);
			UserEndDate = convertValueToJSDate(document.all.end_date.value);
			


			if(checkUserDatesAgainstExistingDates(UserStartDate, UserEndDate, 2)) document.all.MyForm.submit();
		}

			
		function deleteExclusion(exID) {
			if(confirm("Press OK to confirm")) {
				document.all.pagemode.value = 'delete';
				document.all.delProgram_Exclusion_ID.value = exID;
				document.all.MyForm.submit();
			}
			
		}
		
		function verifyExclusionDateSpan() {
			UserStartDate = convertValueToJSDate(document.all.start_date.value);
			UserEndDate = convertValueToJSDate(document.all.end_date.value);		
			checkUserDatesAgainstExistingDates(UserStartDate, UserEndDate, 1);
		}
		
		function initTheTooltip(){
			return true;
		}
		function popOut(){
			return true;
		}
	</script>
</cfoutput>

<!--- <cfdump var="#variables#"> --->
<cfset tmpExStart = CSLGETCONTRACTINFO.CONTRACT_START_DATE>
<cfset tmpExEnd = CSLGETCONTRACTINFO.CONTRACT_END_DATE>

<cfif getExclusions.recordcount GT 0>
	<cfset useLakebaseForgetLastEndDate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getexclusions")>
<cfif useLakebaseForgetLastEndDate>
	<cftry>
		<cfset getLastEndDate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getexclusions", {
				"order" = "end_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetLastEndDate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetLastEndDate>
<cfquery name="getLastEndDate" dbtype="query">
			SELECT *
			FROM getExclusions
			ORDER BY End_Date DESC
	</cfquery>
</cfif>
	<cfset tmpExStart = DateAdd('d',1,getLastEndDate.End_Date)>
</cfif>

<!--- outter table --->
<style>
.tableheaders
	{
		font-size:12px;
		font-weight:bold;
		border-bottom:thin #FFFFFF 0px; 
	}
</style>

<table width="600" border="0" align="center">
	<tr>
		<td valign="top">
				<form action="contract_exclusions.cfm?CID=<cfoutput>#URL.CID#</cfoutput>" method="post" name="MyForm" id="MyForm">
				<table>
					<tr>
						<td colspan="100%" valign="bottom" style="border-bottom: thin solid Navy;font-size: 14px;font-weight: bold;">Exclusion Details:</td>
					</tr>
					<tr>
						<td>
						<b>Exclusion Start:</b>
						<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="start_date" FORMAT="mm/dd/yyyy" DEFAULT="#tmpExStart#"></td>
						
						<td width="20px">&nbsp;
							
						</td>
						
						<td>
						<b>Exclusion End:</b>
						<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="end_date" FORMAT="mm/dd/yyyy" DEFAULT="#tmpExEnd#"></td>
					</tr>
					<tr>
						<td style="border-top: thin solid Navy;" colspan="100%" align="center"><br><span style="cursor: pointer;color: blue;" onclick="addExclusion()"><b style="color:red;">[</b>save <b style="color:red;">]</b></span>
						&nbsp;&nbsp;&nbsp;<span style="cursor: pointer;color: blue;" onclick="verifyExclusionDateSpan()"><b style="color:red;">[</b>validate dates<b style="color:red;">]</b></span>
						</td>
					</tr>
				</table>
					<input type="Hidden" name="pagemode" value="add">
					<input type="Hidden" name="delProgram_Exclusion_ID" value="">
					
				</form>		
		</td>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<!--- outer table  --->
		<td valign="top">
				<table cellspacing="0" cellpadding="3" width="300px">
					<tr>
						<td colspan="100%" valign="bottom" style="border-bottom: thin solid Navy;font-size: 14px;font-weight: bold;" nowrap>Existing Exclusions :</td>
					</tr>
					<tr BGCOLOR="#ffce84">
						<td class="tableheaders" align="center">Status</td>
						<td class="tableheaders">Start Date</td>
						<td class="tableheaders">End Date</td>
						<td class="tableheaders">Program #</td>
						<td class="tableheaders">&nbsp;</td>
					</tr>
					
					<cfoutput query="getExclusions">
						<CFIF currentrow mod 2>
							<CFSET BG_COLOR = "white">
						<CFELSE>
							<CFSET BG_COLOR = "##ccffcc">
						</CFIF>
						<cf_cryp type="en" string ="#getExclusions.Revision_Program_ID#" key="#request.key#">
						<tr id="exRow_#getExclusions.Program_Exclusion_ID#" bgcolor="#BG_COLOR#">
							<td align="center">
							<CFSWITCH EXPRESSION="#getExclusions.Contract_Status_Type_IDX#">
									<CFCASE VALUE="1">
										<!--- WIP --->
										<IMG SRC="/images/wip.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
									</CFCASE>
									<CFCASE VALUE="2">
										<!--- Ready For Approval --->
										<IMG SRC="/images/rfa.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
									</CFCASE>
									<CFCASE VALUE="4">
										<!--- Preactive Programs --->
										<IMG SRC="/images/preactive.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
									</CFCASE>
									<CFCASE VALUE="5">
										<!--- Active Programs --->
										<IMG SRC="/images/active.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
									</CFCASE>
									<CFCASE VALUE="6">
										<!--- Expiring --->
										<IMG SRC="/images/expiring.gif"<!--- ALT="Contract expires in #diff# days."---> onmouseover="initTheTooltip('')" onmouseout="popOut()">
									</CFCASE>
									<CFCASE VALUE="7">
										<!--- Archived/Expired --->
										<IMG SRC="/images/expired.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
									</CFCASE>
									<CFCASE VALUE="8">
										<!--- Rejected/Lost --->
										<IMG SRC="/images/not_allowed.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
									</CFCASE>																		
								</CFSWITCH>							
							</td>
							<td>#DateFormat(getExclusions.start_date, 'mm/dd/yyyy')#</td>
							<td>#DateFormat(getExclusions.end_date, 'mm/dd/yyyy')#</td>
							<td><a href="contract_edit_menu.cfm?CID=#cryp.value#">#Replace(Contract_Number,"000-","")#-<cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif></a></td>
							<td><!--- <a href="contract_edit_menu.cfm?CID=#cryp.value#">edit</a>&nbsp;|&nbsp; ---><a onclick="deleteExclusion(#getExclusions.Program_Exclusion_ID#)" style="cursor: pointer;">delete</a></td>
						</tr>
					</cfoutput>

					<cfif getExclusions.recordcount EQ 0>
						<tr>
							<td colspan="100%" align="center"><BR><span style="font-weight:bold;color:red;">No Exclusion Dates Defined</span></td>
						</tr>
					</cfif>
					
					<tr>
					
					</tr>
				</table>
		</td>
	</tr>
</table>
<!--- outter table --->




</BLOCKQUOTE></BLOCKQUOTE>
</body>
</html>
