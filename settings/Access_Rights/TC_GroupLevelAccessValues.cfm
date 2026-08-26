<!-----------------------------------------------------------------------------

FILE NAME:		TC_GroupLevelAccessValues.cfm
DESCRIPTION:	
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	10-Sep-2015	 Created

------------------------------------------------------------------------------> 
 
<cfif (FORM.SelProfiles EQ "")>
	Atlease one profile has to be selected!! <cfabort>
</cfif>

<cfoutput>
<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />
<cfset getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles(profile_id = FORM.SelProfiles)>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
 
<html>
<head>
	<title>Approval Group Setting</title>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>	
	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT SRC="/common_files/massUpdate.js"></SCRIPT>
	<script language="JavaScript">
	
	function clenseTextBuffer(textObject,validlist){
		var decimalPlaces = 2;
		if(textObject.value.indexOf("*") != -1){
			textObject.value = "*";
		}
		else{
			clenseText(textObject,validlist)
			limitXdecimalplaces(decimalPlaces, textObject);
		}
	}
	
	/* 
	IE 11 Issue: Earlier, "CHSelectAll" on "dom_common.js" used to be called, but now I have added this as a separate function,
	so that the "OnClick" event on the individual entries can be called.
	Below code calls the "OnClick" event on all the entries as all the entries have either been check or unchecked.
	Adding the below code calls the "OnClick" event and so disabled or enables the textboxes.
	thisObj.checked = checkOrUncheckBeforeFireEvent(bCheck);
	callfireEvent(document,thisObj,'Click');
	*/
	function CH_SelectAll(name_start, bCheck)
	{
		var inpColl = document.getElementsByTagName("INPUT");
		var inpCollLen = inpColl.length;
		var thisObj;
		for (var i=0;i<inpCollLen;i++)
		{
			thisObj = inpColl[i];
			if (thisObj.type == 'checkbox') 
			{
				if(thisObj.name.substr(0, name_start.length) == name_start)
				{
					/* true or false based on browser - IE 10 and above or IE 9 and below. 
					'1' as an argument below means "true". */
					thisObj.checked = checkOrUncheckBeforeFireEvent(bCheck);
					/* Call the "OnClick event" on the individual checkboxes. */
					callfireEvent(document,thisObj,'Click');
				}
			}
		}
	}

	function applyApprovalValueForall(input_name_start, iValue, checkbox_name_Start)
	{
		var fValue = parseFloat(iValue);
		if(iValue == '*' || !isNaN(fValue))
		{		
			ApplyValueForAll(input_name_start, iValue, checkbox_name_Start);
		}
	}
	
	function profileEdit(ID, Action) {
		dataArray = new Array(1);
		dataArray[0] = ID;
		dataArray[1] = Action;
		/*
		action:
			1=new
			2=edit
		*/
		pwinretval = window.showModalDialog("profile_admin_window.cfm",dataArray,"dialogHeight: 310px; dialogWidth: 500px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;");

		if(pwinretval == 1)
		{
			document.all.showMessage.value = 0;
			window.location.href = window.location.href;
		}
		pwinretval = 0;

	}	
	</script>
	
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
</head>

<body>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<!------ Get Approval Values ----->
<cfset qGetGroupAccessValues = approvalGroupManager.getGroupAccessValues("", "")>
<cfif application.appSettingsGet.getapprovalStandardOn() EQ 1>
	<cfset colAllowed = 3 />
<cfelse>
	<cfset colAllowed = 2 />
</cfif>

<!--- <cfset sProfileName = CreateObject("component", "components.user.Profile").getProfileName(url.profileId)> --->
<cfset groupIdList = Replace(QuotedValueList(qGetGroupAccessValues.Group_ID),"''",",","ALL")>
<cfset profileIdList = FORM.SelProfiles>
<font COLOR="Navy" SIZE="+1">
#approvalGroupType.Label# Access / Approve  
</font>
<HR COLOR="orange">
<table cellpadding="5" cellspacing="0" align="center">
<tr>
	<td><B>Approval</B> <input type="Checkbox" name="checkAll">
	<CF_smallLink 
		title = "apply all" 
		url = "##"
		parameters = "onClick=""javascript: CH_SelectAll('Group_Approve_', document.all.checkAll.checked);return false;"""
	>
	</td>
	<td><B>Variance</B>
	<input type="Text" name="approvaValueAll" onkeyup="clenseTextBuffer(this, '*-.02134567890')" size="3">
	<CF_smallLink 
		title = "apply all" 
		url = "##"
		parameters = "onClick=""javascript: applyApprovalValueForall('Group_Approve_Margin_', document.all.approvaValueAll.value, 'Group_Approve_');return false;"""
	>
	</td>

	<cfif application.appSettingsGet.getapprovalStandardOn() EQ 1>
	<td><B>Spend/lb Variance</B>
	<input type="Text" name="spendValueAll" onkeyup="clenseTextBuffer(this, '*-.02134567890')" size="3">
	<CF_smallLink 
		title = "apply all" 
		url = "##"
		parameters = "onClick=""javascript: applyApprovalValueForall('Group_Approve_Spend_', document.all.spendValueAll.value, 'Group_Approve_');return false;"""
	>
	</td>
	</cfif>
</tr>
</table>
<cfset maxCols = getProfiles.RecordCount />
<cfset groupCount = 1 />

<form method="post" name="frmGroupAccessApprove" action="TC_GroupLevelAccessValuesAction.cfm">
<div align="right">
	<table>
		<tr>
			<td>
				<a href="##" onclick="javascript:window.open('tc_download.cfm?SelProfiles=#FORM.SelProfiles#','Report_Download','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Export to csv")#</a>
			</td>	 
			<td>
				<CF_BUTTON
					BUTTON_NAME		=	""
					BUTTON_CAPTION	=	"save"
					BUTTON_ACTION	=	"document.frmGroupAccessApprove.submit();"
					BUTTON_TYPE		=	"javascript_link"
					BUTTON_WIDTH	=	"100"
					BUTTON_COLOR	=	"Navy"
					BUTTON_TIP		=	""
					FONT_COLOR		=	"White"
					FONT_SIZE		=	"12"
					FONT_WEIGHT		=	"bold">
				</nobr>
			</td>
		</tr>
	</table>
</div>

<cfset maxColSize = "4.0" />
<cfset colSize = 6/(maxCols*colAllowed) />
<cfset maxWidth = 50 />
<cfloop from= 1 to="#maxCols#" index = "LoopCount">
	<cfloop from = 1 to = "#colAllowed#" index = "Loopcount">
		<cfset maxColSize = maxColSize & ", #colSize#" >
	</cfloop>
	<cfset maxWidth = maxWidth + 10 />
</cfloop>

<cfset variables.columnSizes = ListToArray(maxColSize)>
<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )>

<table id="datagrid" class="datagrid" style='table-layout:fixed;'><!--- align="center" cellpadding="3" cellspacing="1" bgcolor="c0c0c0"   border="1"  --->
	<thead>
		<tr>
			<th>&nbsp;</th>
			<cfloop query="getProfiles">
				<cfset i = getProfiles.profiles_id>
				<th id="id_profile_desc_#getProfiles.Profiles_ID#" title="#getProfiles.Profiles_Desc#" align="center"  onclick="profileEdit(#getProfiles.Profiles_ID#, 2);" onmouseover="this.style.backgroundColor='navy';this.firstChild.style.color='white';" onmouseout="this.style.backgroundColor='';this.firstChild.style.color='Blue';" nowrap colspan="2"> 
				<B>#getProfiles.Profiles_Short_Desc#</B></th>
			</cfloop>
		</tr>
		<tr bgcolor="FFFFFF">
		<cfloop index="i" from="1" to="#maxCols#">
			<cfif i EQ 1>
				<th align="center"  bgcolor="FFFFFF"><B>#approvalGroupType.Label#</B></td>
			</cfif>
			<th bgcolor="FFFFFF" align="center"><B>Approve</B></td>
			<th bgcolor="FFFFFF" align="center"><B>Margin Variance</B></td>
			<cfif application.appSettingsGet.getapprovalStandardOn() EQ 1>
				<th align="center" bgcolor="FFFFFF"><B>Spend/lb <br>Variance</B></td>
			</cfif>
		</cfloop>
		</tr>
	</thead>
	
	<cfsavecontent variable="variables.tbody">	
		<cfloop query="qGetGroupAccessValues">	
			<cfset GroupCount = 1 />
			<tr bgcolor="FFFFFF">	
			<cfloop query="getProfiles">	
				<cfset qGetGroupAccessProfileValues = approvalGroupManager.getGroupAccessValues(qGetGroupAccessValues.Group_ID, getProfiles.profiles_ID)>		
			<cfset bgColor = "">
			<cfif qGetGroupAccessValues.Group_Approve EQ 1>
				<cfset bgColor = "ffdead">
			</cfif>
			<cfset groupIdFieldName = ReplaceNoCase(qGetGroupAccessValues.Group_ID, "-", "_", "all") & "_pro_" & getProfiles.profiles_id >
			 	<Cfif GroupCount eq 1>
				<td>#qGetGroupAccessValues.Group_Name#</td>
			 	</cfif>
			<cfset groupCount++ />
			<td bgcolor="#bgColor#" align="center"><input  onClick="changeDisableOtherObjects(this, this.form.Group_Approve_Margin_#groupIdFieldName#);changeDisableOtherObjects(this, this.form.Group_Approve_Spend_#groupIdFieldName#);"  type="checkbox" value="1" id="Group_Approve_#groupIdFieldName#" name="Group_Approve_#groupIdFieldName#"<cfif qGetGroupAccessProfileValues.Group_Approve EQ 1> checked</cfif>></td>
			<td bgcolor="#bgColor#"><input type="textbox" value="#qGetGroupAccessProfileValues.Group_Approve_Margin#" name="Group_Approve_Margin_#groupIdFieldName#" <cfif qGetGroupAccessProfileValues.Group_Approve NEQ 1> disabled</cfif>  onkeyup="clenseTextBuffer(this, '*-.02134567890')" size="3">%</td>	
			<cfif application.appSettingsGet.getapprovalStandardOn() EQ 1>
				<td bgcolor="#bgColor#"><input type="textbox" value="#qGetGroupAccessProfileValues.Group_Approve_Spend#" name="Group_Approve_Spend_#groupIdFieldName#" <cfif qGetGroupAccessProfileValues.Group_Approve NEQ 1> disabled</cfif>  onkeyup="clenseTextBuffer(this, '*-.02134567890')" size="3">$</td>	
			</cfif>
		</cfloop>
		</tr>
	</cfloop>
</cfsavecontent>
	<tbody>
		<cfoutput>#application.util.string.compress(variables.tbody)#</cfoutput>
	</tbody>	
</table>
<input type="hidden" name="Group_ID_List" value="#groupIdList#">
<input type="hidden" name="Profile_ID_List" value="#profileIdList#"> 
<input type="hidden" name="approvalGroupType_tableName" value="#approvalGroupType.tableName#">
<input type="hidden" name="approvalGroupType_IDfield" value="#approvalGroupType.IDField#">
<div align="right">
	<table>
		<tr>
			<td>
				<a href="##" onclick="javascript:window.open('tc_download.cfm?SelProfiles=#FORM.SelProfiles#','Report_Download','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Export to csv")#</a>
			</td>	 
			<td>
				<CF_BUTTON
					BUTTON_NAME		=	""
					BUTTON_CAPTION	=	"save"
					BUTTON_ACTION	=	"document.frmGroupAccessApprove.submit();"
					BUTTON_TYPE		=	"javascript_link"
					BUTTON_WIDTH	=	"100"
					BUTTON_COLOR	=	"Navy"
					BUTTON_TIP		=	""
					FONT_COLOR		=	"White"
					FONT_SIZE		=	"12"
					FONT_WEIGHT		=	"bold">
				</nobr>
			</td>
		</tr>
	</table>
</div>
</form>
</cfoutput>
<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
$(function() {
  var mydatagrid = $('#datagrid').show().dataTable({
       aaSorting: []
      ,"bAutoWidth": false
      ,"bPaginate": true
      ,"iDisplayLength": 1000
      ,"sDom": 'fptipr'
      ,"bSortClasses": false
      ,"bScrollCollapse": false
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"aoColumns": [
										   {"bSortable":true, "bSearchable":true}
										  <cfoutput><cfloop from="1" to="#maxCols*colAllowed#" index="LoopCount">
										  ,{"bSortable":false, "bSearchable":false}
										  </cfloop></cfoutput>
      							]
    }).fnSetFilteringDelay();

});
$('#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
$('#datagrid tbody').on('click', 'td', function(e) {
 if ( $(e.target).prop('checked') ) {
  var all_checked = 1;
  $('.toggle_one').each(function() {    <!---are all single toggle checked?--->
    if ( !$(this).prop('checked') ) {   <!---found one single toggle unchecked--->
       all_checked = 0;
       return false;
    }
  });
  $('#toggle_all').prop('checked', all_checked == 1 );
 }
 else {
      $('#toggle_all').prop('checked', false );   <!---at least one single toggle is unchecked so uncheck toggle all--->
 }
 });
$('#toggle_all').click(function(e){      <!---listen for click event on toggle all--->
  e.stopPropagation();
  $('.toggle_one').prop('checked', this.checked );
});

</script>
</body>
</html>

