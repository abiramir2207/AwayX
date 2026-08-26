<!------ groupLevelApprovalValues.cfm ----->
<cfoutput>
<cfparam name="url.profileId" 	default="">
<cfif NOT isNumeric(url.profileId) OR url.profileId EQ 0>
	<cfabort>
</cfif>

<!------
This file will handle any group
For now, type code, type group, product hierarchy

application.returned_customer_setting.approval_on_type_code will give what type of group it is
1=type code, 0=type group,
21=product hierarchy 1,
22=product hierarchy 2,
etc.
----->
<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Approval Group Values</title>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
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
		if(iValue == '*' || !isNaN(fValue)){
			if(document.all.Margin.checked == true){
				input_name_start = 'Group_Approve_Margin_';
				ApplyValueForAll(input_name_start, iValue, checkbox_name_Start);
			}
			if(document.all.MarginOpr.checked == true){
				input_name_start = 'Group_Approve_Margin_Oper_';
				ApplyValueForAll(input_name_start, iValue, checkbox_name_Start);
			}
			if(document.all.ListPrice.checked == true){
				input_name_start = 'Group_Approve_List_Price_';
				ApplyValueForAll(input_name_start, iValue, checkbox_name_Start);
			}	
		}
	}
	</script>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
</head>

<body>

<!------ Get Approval Values ----->
<cfset qGetGroupAccessValues = approvalGroupManager.getGroupAccessValues("", url.profileId)>
<cfset sProfileName = CreateObject("component", "components.user.Profile").getProfileName(url.profileId)>
<cfset groupIdList = ValueList(qGetGroupAccessValues.Group_ID)>
<font COLOR="Navy" SIZE="+1">
#approvalGroupType.Label# Access / Approve for #sProfileName#
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
<cfset maxCols = 2>
<form method="post" name="frmGroupAccessApprove" action="groupLevelAccessValuesAction.cfm">
<table align="center" cellpadding="3" cellspacing="1" bgcolor="c0c0c0">
<thead bgcolor="c0c0c0">
<cfloop index="i" from="1" to="#maxCols#">
	<td align="center"><B>#approvalGroupType.Label#</B></td>
	<td align="center"><B>Approve</B></td>
	<td align="center"><B><cfif i eq 1><input type="checkbox" name="Margin"><br></cfif>Margin Variance<br>Dist Progs</B></td>
	<td align="center"><B><cfif i eq 1><input type="checkbox" name="MarginOpr"><br></cfif>Margin Variance<br>Oper Progs</B></td>
	<td align="center"><B><cfif i eq 1><input type="checkbox" name="ListPrice"><br></cfif>Variance<br>% of List Price</B></td>
<cfif application.appSettingsGet.getapprovalStandardOn() EQ 1>
	<td align="center"><B>Spend/lb <br>Variance</B></td>
</cfif>
</cfloop>
</thead>
<tr bgcolor="FFFFFF">
<cfloop query="qGetGroupAccessValues">
	<cfset bgColor = "">
	<cfif Group_Approve EQ 1>
		<cfset bgColor = "ffdead">
	</cfif>
	<cfset groupIdFieldName = ReplaceNoCase(Group_ID, "-", "_", "all")>
	<td bgcolor="#bgColor#">#Group_Name#</td>
	<td bgcolor="#bgColor#"><input onClick="changeDisableOtherObjects(this, this.form.Group_Approve_Margin_#groupIdFieldName#);changeDisableOtherObjects(this, this.form.Group_Approve_Margin_Oper_#groupIdFieldName#);changeDisableOtherObjects(this, this.form.Group_Approve_Spend_#groupIdFieldName#);changeDisableOtherObjects(this, this.form.Group_Approve_List_Price_#groupIdFieldName#);" type="checkbox" value="1" id="Group_Approve_#groupIdFieldName#" name="Group_Approve_#groupIdFieldName#"<cfif Group_Approve EQ 1> checked</cfif>></td>
	<td bgcolor="#bgColor#"><input type="textbox" value="#Group_Approve_Margin#" name="Group_Approve_Margin_#groupIdFieldName#" <cfif Group_Approve NEQ 1> disabled</cfif>  onkeyup="clenseTextBuffer(this, '*-.02134567890')" size="3">%</td>
	<td bgcolor="#bgColor#"><input type="textbox" value="#Group_ID_Margin_Operator#" name="Group_Approve_Margin_Oper_#groupIdFieldName#" <cfif Group_Approve NEQ 1> disabled</cfif>  onkeyup="clenseTextBuffer(this, '*-.02134567890')" size="3">%</td>
	<td bgcolor="#bgColor#"><input type="textbox" value="#Group_ID_List_Price#" name="Group_Approve_List_Price_#groupIdFieldName#" <cfif Group_Approve NEQ 1> disabled</cfif>  onkeyup="clenseTextBuffer(this, '*-.02134567890')" size="3">%</td>
<cfif application.appSettingsGet.getapprovalStandardOn() EQ 1>
	<td bgcolor="#bgColor#"><input type="textbox" value="#Group_Approve_Spend#" name="Group_Approve_Spend_#groupIdFieldName#" <cfif Group_Approve NEQ 1> disabled</cfif>  onkeyup="clenseTextBuffer(this, '*-.02134567890')" size="3">$</td>
</cfif>
<cfif not currentRow mod maxCols and currentRow neq recordCount></tr><tr bgcolor="FFFFFF"></cfif>
	<cfset x = currentRow>
</cfloop>
<cfif Evaluate((x mod maxCols)) NEQ 0>
<cfloop index="i" from="#Evaluate((x mod maxCols)+1)#" to="#maxCols#">
	<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
</cfloop>
</cfif>
</tr>
</table>
<input type="hidden" name="Group_ID_List" value="#groupIdList#">
<input type="hidden" name="Profile_ID" value="#url.profileId#">
<input type="hidden" name="approvalGroupType_tableName" value="#approvalGroupType.tableName#">
<input type="hidden" name="approvalGroupType_IDfield" value="#approvalGroupType.IDField#">
<br>
<table>
<TR>
	<TD colspan="100%"><cfinclude template="Select_GroupLevelAccess_Profiles.cfm" /></TD>
</TR>
</table>
<br>
<div align="center">
	<!------ <input type="submit" value="save"> ----->
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
</div>
</form>
</body>
</html>

</cfoutput>