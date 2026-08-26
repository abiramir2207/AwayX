<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<title>Revision Summary</title>
</HEAD>
<cfparam name="url.contract_number" default="0">
<cfparam name="form.SelectedPrograms" default="">
<cfparam name="form.globalCurrentProgramList" default="">
<cfparam name="url.showallversions" default="0">
<cfparam name="url.editOldProgram" default="0">	<!---D50074 :: Viewing and Editing prior program versions --->

<cfif (isDefined("URL.CID") AND URL.CID NEQ "")>
	<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
	<CFSET URL.Contract_Main_ID = cryp.value>
</cfif>
<cfif (isDefined ("URL.unlockProgram") AND URL.unlockProgram EQ 1 AND isDefined("URL.unlockProgramID") AND URL.unlockProgramID NEQ "")>
	<cfquery name="updDontAllowEdit" datasource="#application.datasource#">
		UPDATE Contract_Main
		SET Dont_Allow_Edit = 0
		WHERE Contract_Main_ID = #URL.unlockProgramID#
	</cfquery>
</cfif>
<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/default.js" />
<BODY>
<STYLE TYPE="text/css">
Body,
TD
{
	font: 12px Arial;
},
a
{
	color: Blue;
	text-decoration: none;
}
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 11px;}

	#Summary {border-top:double solid #93BEE2;border-bottom:double solid #93BEE2; font-size : 12px; color: black; font-weight : bold;}
	.header {font-size:12px; font-weight:bold; background-color:orange;}
	.copy {background-color:yellow}
</STYLE>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm"><!---D50074 :: Viewing and Editing prior program versions --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>   <!--- 30738 --->

<cfif url.contract_number NEQ '0'>
<cfquery name="getrevisionnumbers" datasource="#application.datasource#">
	SELECT Distinct
		U1.name_first + ''  + U1.name_last as created_user
		,U2.name_first + ' ' + U2.name_last as approved_user
		,CM.revision_version
		,CM.contract_main_id
		,CM.Contract_Title
		,CM.contract_Start_Date
		,CM.contract_End_Date
		,CM.Approval_Date
		,CM.Contract_Status_Type_IDX
		,CM.preactive_expired
		,CM.is_a_revision
		,CM.Contract_Status_Type_IDX
		,CM.Effective_Start_Date
		,CM.Approved
		,CM.Deleted
		,CM.Is_A_Revision
		,CM.Dont_Allow_Edit
		,CM.Contract_Is_Locked
		,isnull(CMAD.Freight_Component_Type, 0) as Freight_Component_Type
		,isnull(CM.renewal_of_contract_main_ID, 0) as Copied_Program_ID
		,isnull(CM2.revision_version, 0) as Copied_Version
		,isnull(CM2.contract_number + '-' + CASE
                                    WHEN LEN(CM2.revision_version) = 4 THEN RIGHT('000' + CAST(CM2.revision_version AS VARCHAR(10)), 4)
                                    WHEN LEN(CM2.revision_version) = 5 THEN RIGHT('000' + CAST(CM2.revision_version AS VARCHAR(10)), 5)
                                    ELSE RIGHT('000' + CAST(CM2.revision_version AS VARCHAR(10)), 3)
        END , '') as Copied_Contract_Number
	FROM contract_main CM
	LEFT JOIN contract_main_aux_data CMAD
		ON CM.contract_main_id = CMAD.contract_main_id
	LEFT JOIN contract_main CM2
		ON isnull(CM.renewal_of_contract_main_ID, 0) = CM2.contract_main_id
	INNER JOIN _users U1
		ON U1.user_id = CM.creator_id
	INNER JOIN _users U2
		ON U2.user_id = CM.Approved_By_User_ID
	WHERE CM.contract_number = <cfqueryparam value="#url.contract_number#" cfsqltype="cf_sql_varchar">
	<cfif ! url.showallversions>
		<cfif (isDefined("URL.CID") AND URL.CID NEQ "")>
			AND CM.contract_main_id != <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
		</cfif>
	</cfif>
	AND CM.revision_version != 0
	AND CM.Approved = 1
	ORDER BY CM.revision_version DESC
</cfquery>

<table width="100%" cellpadding="2" cellspacing="0" border="0" class="maintable">
<tr style="vertical-align:bottom;">
	<td class="header">&nbsp;</td>
	<td class="header">Revision Version</td>
	<td width="20%" class="header">Contract Title</td>
	<td class="header">Contract <br>Start Date</td>
	<td class="header">Contract<br> End Date</td>
	<td class="header">Created By</td>
	<td class="header">Approved By</td>
	<td class="header">Approved <br> Date</td>
	<td class="header">Copied From</td>
	<cfif appSettings.getDisplayQuoteLetter() eq 1 and appSettings.getlettersavailable() neq 4>    <!--- 30738, 46751 --->
		<td class="header">Quote Letter</td>
	</cfif>
	<cfif application.util.query.get_Setting('Custom_RFP_Process',0) EQ 1>
		<td class="header">P&L</td>
	</cfif>
	<!---D50074 :: Viewing and Editing prior program versions START--->
	<!--- <cfif appSettings.getModifyExpiredPrograms() AND Get_Profile_Settings.Modify_Expired_Programs AND url.editOldProgram></cfif> --->
	<td class="header">Action</td>
	<!---D50074 :: Viewing and Editing prior program versions END--->
</tr>
<tr><td colspan="100%"><hr width="100%" color="navy"></td></tr>

<FORM ACTION="contract_emailfaxprint.cfm" METHOD="post" NAME="RevisionHistory" ID="RevisionHistory" target="blank">
<cfoutput query="getrevisionnumbers">
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
<cf_cryp type="en" string ="#getrevisionnumbers.contract_main_id#" key="#request.key#">
<cfset ContractID = cryp.value>
	<TD><input type="Checkbox" value="#getrevisionnumbers.Contract_Main_ID#" onclick="selectedProgramListManage(this)"></TD>
	<td><A STYLE="cursor:pointer;" <cfif getrevisionnumbers.preactive_expired EQ 1> title="This version was never active due to a subsequent revision"</cfif> ONCLICK="viewContract('#ContractID#')">#Contract_Number# -  <cfif len(revision_version) eq 4>#right("000#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("000#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif></A>
	<cfsilent>
		<cfquery name="AreThereRevisions" datasource="#application.datasource#">
			SELECT count(Contract_Main_ID) AS numberofrevisions
			FROM Contract_Main
			WHERE Revision_of_Contract_Main_ID = #getrevisionnumbers.contract_main_id#
		</cfquery>
	</cfsilent>

	<cfif AreThereRevisions.numberofrevisions GT 0>
		<cfset imgsrc = "/images/delta_gray.gif">
		<cfset imgALT = "This program has been Revised..." >
	<cfelseif getrevisionnumbers.is_a_revision EQ 1>
		<cfset imgsrc = "/images/delta.gif">
		<cfset imgALT = "This is a Revision..." >
	</cfif>
	<cfset imgclick = "STYLE=""cursor:pointer;"" onclick=""javascript:showrevisiondetails('#getrevisionnumbers.contract_main_id#','#getrevisionnumbers.Contract_Status_Type_IDX#');""">
	<IMG SRC="#imgsrc#" BORDER="0" TITLE="#imgALT#" #imgclick#>
	<cfif Freight_Component_Type neq 0>
		<br>
		<CF_smallLink
			title = "freight"
			url = "##"
			parameters = "onClick=""javascript: return viewFreightPage('#ContractID#');return false;"""
		>
	</cfif>
</td>
	<td>#Contract_Title#</td>
	<td>#Dateformat(contract_Start_Date, "mm/dd/yyyy")#</td>
	<td>#Dateformat(contract_End_Date, "mm/dd/yyyy")#&nbsp; </td>
	<td>#created_user#</td>
	<td>#approved_user#</td>
	<td>#Dateformat(Approval_Date, "mm/dd/yyyy")#</td>
	<td>
		<cfif Copied_Program_ID neq 0>
			<CF_CRYP type="en" string="#Copied_Program_ID#" key="#request.key#" return="copyCryp">
			<cfset copiedCMId = copyCryp.value>
			<a href="##" onclick="viewContractWithLHLinks('#copiedCMId#')">#application.util.string.actionLinkFormat(Copied_Contract_Number)#</a>
		<cfelse>
			#Copied_Contract_Number#
		</cfif>
		 &nbsp;
	</td>
	<cfif appSettings.getDisplayQuoteLetter() eq 1 and appSettings.getlettersavailable() neq 4>    <!--- 30738, 46751 --->
		<cfset displaytext = 'generate'>
		<td><a href="javascript:window.location='/common_files/contracts/letters/distributors.cfm?Contract_Main_ID=#getrevisionnumbers.Contract_Main_ID#'">#application.util.string.actionLinkFormat(displaytext)#</a></td>
	</cfif>
	<cfif application.util.query.get_Setting('Custom_RFP_Process',0) EQ 1>
		<td><a href="##" onclick="verticalPNL('#ContractID#')">#application.util.string.actionLinkFormat('P&L')#</a></td>
	</cfif>
	<!---D50074 :: Viewing and Editing prior program versions START--->
	<td>
	<a href="##" onclick="copy_program(this, '#cryp.value#')">#application.util.string.actionLinkFormat2("copy")#</a>
	<cfif (appSettings.getModifyExpiredPrograms()
			AND Get_Profile_Settings.Modify_Expired_Programs
			AND getrevisionnumbers.Approved
			AND getrevisionnumbers.Deleted
			AND len(getrevisionnumbers.Effective_Start_Date)
			AND url.editOldProgram)>
			<cfset displaytext = 'modify program'>
			&nbsp; <a  id="#cryp.value#" href="##" onclick="modifyprogram('#cryp.value#');">#application.util.string.actionLinkFormat(displaytext)#</a>
			<cfset displaytext = 'Processing...'>
			<span id="s_#cryp.value#" style="display:none;">#application.util.string.actionLinkFormat(displaytext)#</span>
			<!--- Only Blacksmith user who has admin privelege can see this link --->
			<cfif (request.AccessStructure.Blacksmith_User EQ 1 AND request.AccessStructure.User_Rights_ID EQ '9999')>
				<cfset displaytext = 'unlock program'>
					<cfif (getrevisionnumbers.Dont_Allow_Edit EQ 1)>
					&nbsp;<a href="##" onclick="unlockProgram('#getrevisionnumbers.contract_main_id#');">#application.util.string.actionLinkFormat(displaytext)#</a>
					<cfelse>
					&nbsp;<font color="grey">#application.util.string.actionLinkFormat(displaytext)#</font>
				</cfif>
			</cfif>

	</cfif>
	<cfset displaytext = 'export to XL'>
	<a href="##" onClick="NewWindow('/common_files/contracts/export2excel.cfm?CID=#ContractID#&ContractNumber=#Contract_Number#','Export','870','720','Yes','Yes');">#application.util.string.actionLinkFormat(displaytext)#</a>
	</td>
	<!---D50074 :: Viewing and Editing prior program versions END--->
</tr>
</cfoutput>
<INPUT TYPE="Hidden" NAME="SelectedPrograms" VALUE="#form.SelectedPrograms#">
</form>
</table>
<br>
<table align="center">
<tr colspan="100%">
			<TD width="100px">
					<CF_button
						button_name		=	""
						button_caption	=	"print"
						button_action	=	"fn_PrintEmailFax('P');"
						button_type		=	"javascript_link"
						button_width	=	"90"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
			<TD width="100px">
					<CF_button
						button_name		=	""
						button_caption	=	"email"
						button_action	=	"fn_PrintEmailFax('E');"
						button_type		=	"javascript_link"
						button_width	=	"90"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
			<TD width="100px">
					<CF_button
						button_name		=	""
						button_caption	=	"close"
						button_action	=	"window.close();"
						button_type		=	"javascript_link"
						button_width	=	"90"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
		</tr>
</table>

<cfelse>
Invalid Program Number
</cfif>

<cfinclude template="\common_files\jQuery.cfm">

<script>
var globalCurrentProgramList = "";
function viewContract(program_id)
{
NewWindow('/scorecard/program_display.cfm?display_program=1&CID='+program_id,'ViewProgram','800','600','Yes', 'Yes');
}

function viewContractWithLHLinks(program_id)
{
	NewWindow('/common_files/contracts/Contract_Edit_Menu.cfm?display_program=1&CID='+program_id + '&bViewReadOnly=1','ViewProgram','800','600','Yes', 'Yes');
}

	function PrintEmailFax(){
			if(globalCurrentProgramList.length > 0)
			{
			document.all.RevisionHistory.submit();
			}
			else
			{
			alert("Please select a program");
			}
	}


var SelectedPrograms = <cfoutput>"#form.SelectedPrograms#"</cfoutput>
	function selectedProgramListManage(oChkBx) {
		programID = oChkBx.value;
		if(oChkBx.checked) {
			//add to list
			if(SelectedPrograms.length == 0){
				SelectedPrograms = programID;
			}
			else{
				SelectedPrograms = SelectedPrograms + ',' + programID
			}
		}
		else {
			//remove from list
			tempArray = SelectedPrograms.split(",")
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
			SelectedPrograms = tempcurrentProgramList;
		}

		document.all.RevisionHistory.SelectedPrograms.value = SelectedPrograms;
		globalCurrentProgramList = SelectedPrograms;
	}

		function fn_PrintEmailFax(type)
{
if(globalCurrentProgramList.length > 0)
			{
			NewWindow('/common_files/contracts/contract_emailfaxprint.cfm?program_list='+globalCurrentProgramList+'&action_type='+type+'&contract_number=<cfoutput>#url.contract_number#'</cfoutput>,'ViewProgram','800','600','Yes', 'Yes');
			}
			else
			{
			alert("Please select a program");
			}
}
function showrevisiondetails(contractid,status)
{
	NewWindow('/reportwriter/performance_reports/revisionreport.cfm?Contract_main_id='+contractid+'&Contract_Status='+status,'ProgramRevisionDetails','1200','550','Yes', 'Yes')

}
function viewFreightPage(program_id)
{
	NewWindow('/common_files/contracts/freight/index.cfm?mode=summary&CID='+program_id,'ViewProgramFreight','800','600','Yes', 'Yes');
	return false;
}
//D50074 :: Viewing and Editing prior program versions START
function modifyprogram(program_id){
	window.opener.location = '/Common_Files/Contracts/Contract_Edit_Menu.cfm?CID='+program_id;
	document.getElementById(program_id).style.display = 'none';
	document.getElementById('s_'.concat(program_id)).style.display = 'block';
	setTimeout(function(){
	    self.close();
	},1500);
}
<cfoutput>
function unlockProgram(program_ID){
	window.location.href = 'contract_revision_history.cfm?unlockProgram=1&editOldProgram=1&CID=#URL.CID#&contract_number=#url.contract_number#&unlockProgramID='+ program_ID  ;
}
</cfoutput>
function copy_program(el, program_id){
	jQuery(el).closest('tr').addClass('copy');
 	if (!confirm("Are you sure you want to copy this version?")){
		jQuery(el).closest('tr').removeClass('copy');
	}
	else {
		var pathtoOpen= '/Common_Files/Contracts/Contract_edit_Menu.cfm?CID='+program_id+'&IsCopyProgram=1';
		window.open(pathtoOpen,"summary","location=0,status=0,scrollbars=1,left=0,top=0,width=1000,height=800");
/*
		self.close();
		window.opener.close();
		var summary_window = window.opener.opener;
 		summary_window.RenewForm.Program_ID.value = program_id;
		summary_window.RenewForm.IsCopyProgram.value = 1;
		summary_window.RenewForm.submit();
*/
 	}
}
//D50074 :: Viewing and Editing prior program versions END

	function verticalPNL(id) {
    // NewWindowTopLeft( '/common_files/processing.cfm?actualPage=/common_files/contracts/contract_profit_analysis.cfm'
        <cfif application.util.query.get_Setting('Custom_RFP_Process',0) EQ 1>
            popupCenterByPercentages( '/common_files/contracts/verticalpnl_hm.cfm'
                                        + '?verticalPNL=1'
                                        + '&CID=' + id
                                        + '&displayPreviousVersionMargin=0'
                                        + '&margin_version=xx',
                                        'verticalPNL1',
                                        90, 90);
        <cfelse>
        	console.log('Should Not Be Here');
        </cfif>
    }
</script>
</body>
</html>