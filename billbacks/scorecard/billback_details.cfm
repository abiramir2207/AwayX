<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>billback details</TITLE>
</HEAD>

<CFSET objBBManager = CreateObject("component", "components.billback.BillbackManager") />
<CFSET objBBMgr = CreateObject("component", "mvc.Models.Billback.BillbackManager") />
<CFSET objSettingsService = CreateObject("component", "mvc.Models.SettingsService") />
<CFSET appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<!--- get BB Details Info --->
<cfset Get_Billback_Info = objBBManager.getBillbackDetailsInfo(url.bbid)>

<!--- get BB Attachment Info --->
<cfset qgetBillbackAttachmentsTitle = objBBMgr.getBillbackAttachments(url.bbid,request.AccessStructure.user_id,1)>
<cfset qgetBillbackAttachmentsFileName = objBBMgr.getBillbackAttachments(url.bbid,request.AccessStructure.user_id,2)>

<!--- get BB Approval Info --->
<cfset qgetBillbackApprovalInfo = objBBMgr.getBillbackApprovalInfo(url.bbid)>

<!--- get BB Workflow Info --->
<cfset qgetWorkFlowData = objBBMgr.getWorkFlowData(url.bbid,0,1)>

<!--- get BB CRA Info --->
<cfset qgetApprovableUserList = objBBMgr.getApprovableUserList(url.bbid)>

<!--- get BB NRA Info --->
<cfset qgetNextApprovableUsers = objBBMgr.getNextApprovableUsers(url.bbid)>

<!--- get BB Interface Info --->
<cfset qgetBBInterfaceInfo = objBBMgr.getBBInterfaceInfo(url.bbid,1)>

<!--- get BB Misc Info --->
<cfset qgetBillbackMiscInfo = objBBMgr.getBillbackMiscInfo(url.bbid)>

<!--- get BB Settings Info --->
<cfset qBillbackSettings = objSettingsService.getBillbackSettings()>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<cfquery name="qryChkBSA_Assoc_Operator" datasource="#Application.Datasource#">
	SELECT Operator_ID, Operator_Legacy_ID, Operator_Name
	FROM Billback_Assoc_Operator
	WHERE Billback_ID = '#url.bbid#' AND
	Deleted = 0
</cfquery>

<cfquery NAME="getUploadedBB" datasource="#Application.Datasource#">
	SELECT Uploaded_Billback FROM Billback WHERE Billback_ID = '#url.bbid#'
</cfquery>

<cfset IsSplitChild = 0>
<cfif len(trim(Get_Billback_Info.BB_parent_ID)) GT 0>
	<cfset IsSplitChild = 1>
</cfif>

<BODY>

<div style="width:100%;background-color:#FFCE84;border-top:1px solid black;border-bottom:1px solid black;height:14px;font-size:13px;">
	<label style="font-weight:bold;">billback details</label>
</div>

<!--- Print/Email/Copy --->
<cfoutput>
<div style="margin-top:5px">
<a href="javascript:void()" onClick="openPrintPage('#url.BBID#')">Print</a>
&nbsp;&nbsp;
<a href="javascript:void()" onClick="emailBillback('#url.BBID#')">Email</a>
&nbsp;&nbsp;
<a href="javascript:void()" onClick="copyBillback('#url.BBID#')">Copy</a>
</div>
</cfoutput>

<table border="0" width="100%" cellpadding="2" cellspacing="3">
	<!--- Payable/Date Span/Analyst --->
	<tr>
		<td><b>Payable</b></td>
		<td><b>Date Span</b></td>
		<td><b>Analyst</b></td>
	</tr>
	<cfoutput>
	<tr>
		<td>#Get_Billback_Info.bb_code#</td>
		<td>#DateFormat(Get_Billback_Info.BB_Start_Date,"MM/DD/YYYY")# - #DateFormat(Get_Billback_Info.BB_End_Date,"MM/DD/YYYY")#</td>
		<td>#Get_Billback_Info.Analyst_User#</td>
	</tr>
	</cfoutput>

	<!--- Title/Locked By --->
	<cfset widthColSpan = 2>
	<cfif qgetBillbackMiscInfo.Locked_By eq "">
		<cfset widthColSpan = 3>
	</cfif>
	<cfoutput>
	<tr>
		<td colspan="#widthColSpan#"><b>Title</b></td>
		<cfif qgetBillbackMiscInfo.Locked_By neq "">
		<td><b>Locked By</b></td>
		</cfif>
	</tr>
	<tr>
		<td colspan="#widthColSpan#">#Get_Billback_Info.BB_Title#</td>
		<cfif qgetBillbackMiscInfo.Locked_By neq "">
		<td>#qgetBillbackMiscInfo.Locked_By#</td>
		</cfif>
	</tr>
	</cfoutput>

	<!--- Check #/Reference # --->
	<cfif Get_Billback_Info.Check_Number neq "" or Get_Billback_Info.referenceNum neq "">
	<tr>
		<cfif Get_Billback_Info.Check_Number neq "">
		<td><b>Check #</b></td>
		</cfif>
		<cfif Get_Billback_Info.referenceNum neq "">
		<td colspan="2"><b>Reference #</b></td>
		</cfif>
	</tr>
	<cfoutput>
	<tr>
		<cfif Get_Billback_Info.Check_Number neq "">
		<td>#Get_Billback_Info.Check_Number#</td>
		</cfif>
		<cfif Get_Billback_Info.referenceNum neq "">
		<td colspan="2">#Get_Billback_Info.referenceNum#</td>
		</cfif>
	</tr>
	</cfoutput>
	</cfif>

	<!--- Document Attachment --->
	<cfif ArrayLen(qgetBillbackAttachmentsTitle) GT 0>
	<tr>
		<td colspan="100%"><b>Document Attachment</b></td>
	</tr>
	<cfoutput>
	<cfloop from="1" to="#ArrayLen(qgetBillbackAttachmentsTitle)#" index="i">
	<tr>
		<td colspan="100%">
			<A href="javascript: confirmation('#jsStringFormat(qgetBillbackAttachmentsFileName[i])#');" TITLE="Click here to view '#qgetBillbackAttachmentsTitle[i]#'">
			#qgetBillbackAttachmentsTitle[i]#
			</A>
		</td>
	</tr>
	</cfloop>
	</cfoutput>
	</cfif>
<tr>
<td colspan="100%">
	<hr>
</td>
</tr>
	<!--- Interface Info --->
	<cfif qgetBBInterfaceInfo neq "">
	<tr>
		<td colspan="100%"><b>Interface Info</b></td>
	</tr>
	<cfoutput>
	<tr>
		<td colspan="100%">#qgetBBInterfaceInfo#</td>
	</tr>
	<tr><td colspan="100%">&nbsp;</td></tr>
	</cfoutput>
	</cfif>

	<!--- EDI Duplicate --->
	<cfif qBillbackSettings.Enable_BB_Dup_Check eq 1 AND (Get_Billback_Info.BB_Upload_Dup_Group_ID neq 0 AND Get_Billback_Info.BB_Upload_Dup_Group_ID neq "")>
	<tr>
		<td colspan="100%"><b>EDI Duplicate</b>&nbsp;&nbsp;This Billback is flagged as an EDI Duplicate!</td>
	</tr>
	</cfif>

	<!--- Claimed/Expected/Paid Amt --->
	<cfoutput>
	<tr>
		<td><b>Claimed Amt</b>&nbsp;&nbsp;#dollarformat(Get_Billback_Info.BB_Amount)#</td>
		<td><b>Expected Amt <CF_SmallHelp
					width="180"
					displayShifyX = "-180"
					displayShifyY = "-50"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>Expected Amount is not populated until the billback is approved</center>
				</CF_SmallHelp></b>&nbsp;&nbsp;#dollarformat(qgetBillbackApprovalInfo.Expected_Amount)#</td>
		<td><b>Paid Amt</b>&nbsp;&nbsp;#dollarformat(qgetBillbackApprovalInfo.Paid_Amount)#</td>
	</tr>
	</cfoutput>

	<!--- Claimed vs Expected vs Paid Amt --->
	<cfoutput>
	<tr>
		<td><b>Claimed vs Expected</b>&nbsp;&nbsp;#dollarformat(qgetBillbackApprovalInfo.ClaimedVsExpected)#</td>
		<td><b>Claimed vs Paid</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#dollarformat(qgetBillbackApprovalInfo.ClaimedVsPaid)#</td>
		<td><b>Expected vs Paid</b>&nbsp;&nbsp;#dollarformat(qgetBillbackApprovalInfo.ExpectedVsPaid)#</td>
	</tr>
	</cfoutput>

	<!--- Deviation info --->
	<cfif Get_Billback_Info.Deviation_User neq "">
	<cfoutput>
	<tr>
		<td colspan="100%"><b>#appSettings.getDeviationLabel()# last run</b>&nbsp;&nbsp;#Get_Billback_Info.Deviation_User#, #DateFormat(Get_Billback_Info.Deviation_Ran_Date,"MM/DD/YYYY")# #Timeformat(Get_Billback_Info.Deviation_Ran_Date,"hh:mm tt")#</td>
	</tr>
	<tr>
		<td><b>#appSettings.getDeviationLabel()# cannot exceed</b>&nbsp;&nbsp;#DollarFormat(Get_Billback_Info.Cannot_Exceed_Dollar)# / #Get_Billback_Info.Cannot_Exceed_Percent#%</td>
		<td><b>Billback Deviated</b>&nbsp;&nbsp;#DollarFormat(Get_Billback_Info.Auto_Deviated_Amt)# / #Get_Billback_Info.Auto_Deviated_Percent#%</td>
		<td><b>Max Dollar Amt</b>&nbsp;&nbsp;#DollarFormat(Get_Billback_Info.Auto_Dev_Max_Dollar_Amount)#</td>
	</tr>
	</cfoutput>
	</cfif>

	</table>

	<br />

	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

	<!--- Workflow datagrid --->
	<div style="font-weight:bold;">Workflow</div>
	<table class="datagrid" id="datagrid">
	<thead>
		<tr>
			<th width="12%">Action</th>
			<th width="20%">Name</th>
			<th width="13%">Position</th>
			<th width="20%">Profile</th>
			<th width="20%">Authority Sequence</th>
			<th width="15%">Date</th>
			<th width="15%">&nbsp;</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="qgetWorkFlowData">
		<tr>
			<td>#Action#</td>
			<td>#Name#</td>
			<td>#Position#</td>
			<td>#Profiles_Desc#</td>
			<td>#Authority_Sequence_Name#</td>
			<td>#DateFormat(Action_Date,"MM/DD/YYYY")# #Timeformat(Action_Date,"hh:mm tt")#</td>
			<th>#Action_type#</th>
		</tr>
	</cfoutput>
	</tbody>
</table>

<!--- CRA datagrid --->
<cfif qgetApprovableUserList.recordcount gt 0>
<div style="font-weight:bold;clear:both;padding-top:5px;">CRA</div>
	<table class="datagrid" id="datagridCRA">
	<thead>
		<tr>
			<th width="25%">Name</th>
			<th width="25%">Position</th>
			<th width="25%">Profile</th>
			<th width="25%">Authority Sequence</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="qgetApprovableUserList">
		<tr>
			<td>#User_Full_Name#</td>
			<td>#Position_Label#</td>
			<td>#Profiles_Desc#</td>
			<td>#Authority_Sequence_Name#</td>
		</tr>
	</cfoutput>
	</tbody>
</table>
</cfif>

<!--- NRA datagrid --->
<cfif qgetNextApprovableUsers.recordcount gt 0>
<div style="font-weight:bold;clear:both;padding-top:5px;">NRA</div>
	<table class="datagrid" id="datagridNRA">
	<thead>
		<tr>
			<th width="25%">Name</th>
			<th width="25%">Position</th>
			<th width="25%">Profile</th>
			<th width="25%">Authority Sequence</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="qgetNextApprovableUsers">
		<tr>
			<td>#User_Full_Name#</td>
			<td>#Position_Label#</td>
			<td>#Profiles_Desc#</td>
			<td>#Authority_Sequence_Name#</td>
		</tr>
	</cfoutput>
	</tbody>
</table>
</cfif>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script>
<!--- WORKFLOW GRID CODE --->
var wfgrid = $('table#datagrid').dataTable({
	"bAutoWidth": false
	,"bPaginate": false
	,"bSortClasses": false
	,"bScrollCollapse": true
	,"sDom": 'ti'
	,"iDisplayLength": 4 // Number of records to show. Seems like this and "sScrollY" go together.
	,"sScrollY": "80px" // For vertical scrolling
	,"aaSorting": [[ 5, "asc" ], [6,'asc']] // Added the "Action_Type" column for sorting only.
	,"aoColumns": [
				{"bSearchable": false, 	"bSortable":true}
				,{"bSearchable": false, "bSortable":true}
				,{"bSearchable": false, "bSortable":true}
				,{"bSearchable": false, "bSortable":true}
				,{"bSearchable": false, "bSortable":true}
				,{"bSearchable": false, "bSortable":true}
				,{"bSearchable":false,	"bSortable":true, "bVisible":false} /* column for sorting */
				]
  });

<!--- hovering background color switching --->
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
$('.dataTables_scrollBody').css('min-height', '50px');

<!--- CRA GRID CODE --->
var cragrid = $('table#datagridCRA').dataTable({
	"bAutoWidth": false
	,"bPaginate": false
	,"bSortClasses": false
	,"bScrollCollapse": true
	,"sDom": 'ti'
	,"iDisplayLength": 4 // Number of records to show. Seems like this and "sScrollY" go together.
	,"sScrollY": "80px" // For vertical scrolling
	,"aaSorting": [[ 1, "asc" ]]
	,"aoColumns": [
				{"bSearchable": false, 	"bSortable":true}
				,{"bSearchable": false, 	"bSortable":true}
				,{"bSearchable": false, 	"bSortable":true}
				,{"bSearchable": false, 	"bSortable":true}
				]
  });
<!--- hovering background color switching --->
$('table#datagridCRA tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

<!--- NRA GRID CODE --->
var nragrid = $('table#datagridNRA').dataTable({
	"bAutoWidth": false
	,"bPaginate": false
	,"bSortClasses": false
	,"bScrollCollapse": true
	,"sDom": 'ti'
	,"iDisplayLength": 4 // Number of records to show. Seems like this and "sScrollY" go together.
	,"sScrollY": "80px" // For vertical scrolling
	,"aaSorting": [[ 1, "asc" ]]
	,"aoColumns": [
				{"bSearchable": false, 	"bSortable":true}
				,{"bSearchable": false, 	"bSortable":true}
				,{"bSearchable": false, 	"bSortable":true}
				,{"bSearchable": false, 	"bSortable":true}
				]
  });
<!--- hovering background color switching --->
$('table#datagridNRA tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });


$(window).resize( function() {
	wfgrid.fnAdjustColumnSizing();
	wfgrid.fnDraw();

	cragrid.fnAdjustColumnSizing();
	cragrid.fnDraw();

	nragrid.fnAdjustColumnSizing();
	nragrid.fnDraw();
} );


/* Print function */
function openPrintPage(bb_id){
	NewWindow("/billbacks/common/bb_printer_friendly.cfm?BBID=" + bb_id + "","print","1000","600","Yes", "No");
	return false;
}

/* Email function */
function emailBillback(bb_id)
{
	NewWindow("/billbacks/common/bb_email_create.cfm?BBID=" + bb_id + "","email","800","600","Yes", "No");
	return false;
}

/* Copy function */
function copyBillback(bb_id)
{
	var IsSplitChild = '<cfoutput>#IsSplitChild#</cfoutput>';
	var copyAssocOperator = 0;
		if (IsSplitChild == 0)
		{

			<cfif (isDefined("qryChkBSA_Assoc_Operator") AND qryChkBSA_Assoc_Operator.RecordCount NEQ 0 AND (isDefined("getUploadedBB") AND getUploadedBB.Uploaded_Billback EQ 2 OR getUploadedBB.Uploaded_Billback EQ 3)) >
				<cfoutput>
					if(confirm("Do you want to also copy over the Associated Operator information?"))
					{
						copyAssocOperator = 1;
					}
				</cfoutput>
			</cfif>
			NewWindow("/billbacks/capture/Copy_ThisBB.cfm?BBID=" + bb_id + "&copyAssocOperator=" + copyAssocOperator,"copy","800","600","Yes", "No");
			return false;
		}
		else
		{
			alert("You cannot copy the child of a split billback. Please copy the parent of this billback.");
		}
}
</script>

<style>
/* This is used to reduce the height between the different data tables above.
The default height if a data table is 302 px. Needed to reduce that, so that
multiple data tables do not have a lot of space between them.
*/
.dataTables_wrapper {
   _height: 72px;
   min-height: 72px;
}
</style>


</BODY>
</HTML>