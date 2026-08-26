<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFSET PageTitle="USERS: Approval Groups">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT LANGUAGE="JavaScript">
function approval_group_count_change(thisObj)
{
	var approval_group_count = parseInt(thisObj.value);
	var previous_count = parseInt(document.all.js__approval___group___count.value);
	if(isNaN(approval_group_count))
	{
		approval_group_count = 0;
	}
	
	if(approval_group_count > 99)
	{		
		//approval_group_count = 0;
		alert("The maximum number of approval groups is 99.")
		return false;
	}
	
	if(approval_group_count == 0)
	{		
		//approval_group_count = 0;
		alert("The minimum number of approval groups is 1.")
		return false;
	}	
	thisObj.value = approval_group_count;
	
	if(isNaN(previous_count))
	{
		previous_count = 0;
	}
	var tabObj = getParentObject(thisObj, "table");
	var trObj = getParentObject(thisObj, "tr");
	var trIndex = trObj.rowIndex;
	
	var i;
	for(i=1;i<=approval_group_count;i++)
	{
		if(i > previous_count)
		{
			insert_approval_group_row(i+trIndex, i, tabObj);
		}
	}
	//for(i=approval_group_count+1;i<=previous_count;i++)
	for(i=previous_count;i>approval_group_count;i--)
	{
		delete_approval_group_row(i+trIndex, i, tabObj);
	}
	document.all.js__approval___group___count.value = approval_group_count;
//	document.all.label_count.value = approval_group_count;
}

function insert_approval_group_row(rowPos, groupIndex, tabObj)
{
	////////////constants	
	var paddZero = "000";
	
	var groupIndexLen = groupIndex.toString().length;
	var paddedGroupIndex = paddZero.substr(0, paddZero.length - groupIndexLen) + groupIndex.toString();
	var newLabel2 = "Group " + groupIndex;
	var newLabel = "Approval group count " + paddedGroupIndex + " Label";
	
	var regExp = new RegExp(" ", "igm");
   	var newIDField = newLabel.replace(regExp, "_");

	var trObj = tabObj.insertRow(rowPos);
	var cellObj;
	
	cellObj = trObj.insertCell(0);
	cellObj.align = "right";
	//cellObj.vAlign = "top";
	cellObj.innerText = newLabel2 + " :";
	cellObj.className = "LabelStyle"
	
	cellObj = trObj.insertCell(1);
	cellObj.align = "left";
	//cellObj.vAlign = "top";
	cellObj.innerHTML = "<INPUT class=\"InputStyle\" MAXLENGTH=\"50\" TYPE=\"text\" NAME=\"" + newIDField + "\" CLASS=\"large\">";
	var objExistingValue;
	eval("objExistingValue = document.all.js__approval___group___" + groupIndex + ";");	
	
	if(objExistingValue)
	{
		var objNewIDField;
		eval("objNewIDField = cellObj.all." + newIDField + ";");		
		if(objNewIDField)
		{
			objNewIDField.value = objExistingValue.value;
		}
	}
}

function delete_approval_group_row(rowPos, groupIndex, tabObj)
{
	tabObj.deleteRow(rowPos);
}

function getParentObject(thisObj, tagName)
{
	if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
	{
		return thisObj;
	}
	else if(thisObj.tagName.toLowerCase() == "body")
	{
		return null;
	}
	else
	{
		return getParentObject(thisObj.parentElement, tagName);
	}
}

</SCRIPT>

<style>
	.LabelStyle {
		font-weight : bold;
	}

	.InputStyle {
		border: 1 solid Silver;
		width: 200px;
	}
	.InputStyle2 {
		border: 1 solid Silver;
		width: 100px;
	}
</style>

<CFQUERY NAME = "get_group" DATASOURCE = "#Application.Datasource#">
	SELECT * from Group_Labels WHERE Group_ID = 1
</CFQUERY>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
	SELECT _Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
	FROM _Users
	WHERE User_ID = '#get_group.LastUpdated_UserId#'
</CFQUERY>
<CFOUTPUT>
<TABLE>
	<TR>
	<TD>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<tr><td>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(get_group.LastUpdated_Date, 'm/d/yyy')# #timeformat(get_group.LastUpdated_Date, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT></td></tr></table>
	</TD>
	</TR>
</TABLE>
<FORM NAME = "Group_labels" ACTION = "Group_Details_Action.cfm" METHOD = "POST">
<INPUT TYPE = "hidden" NAME = "Group_ID" VALUE = "#Get_Group.Group_ID#">
	
	<TABLE align="center" border="0">
		<TR>
			<TD colspan="100%">
				<SPAN CLASS="title2">Approval Group Maintenance</SPAN><BR>
				<HR COLOR="Orange">
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right" class="LabelStyle">Approval Group Count:</TD>
			<TD ROWSPAN="100%" BGCOLOR="Navy"></TD>
			<TD><INPUT class="InputStyle2"  <!--- onChange="javaScript: approval_group_count_change(this);" ---> NAME = "Approval_Group_Count" VALUE = "<CFIF Get_Group.Approval_group_count EQ "">0<CFELSE>#Get_Group.Approval_group_count#</CFIF>">&nbsp;&nbsp;<span style="display:inline-block; height: 15px; width: 30px; background-color:##3399ff; border: 1 solid Black; text-align: center; cursor: pointer;" onclick="approval_group_count_change(document.all.Approval_Group_Count)"><b style="color:white;">go</b></span></TD>
			<INPUT TYPE="HIDDEN" NAME="js__approval___group___count" VALUE="<CFIF Get_Group.Approval_group_count EQ "">0<CFELSE>#Get_Group.Approval_group_count#</CFIF>">
		</TR>
		<CFIF Get_Group.Approval_group_count EQ "">
			<CFSET ToIndex = 0>
		<CFELSE>		
			<CFSET ToIndex = Get_Group.Approval_group_count>
		</CFIF> 
		<CFLOOP INDEX = "loopcount" FROM = "1" TO = "#ToIndex#">
			<CFIF loopcount GT 99>
				<CFSET LABEL = "Approval_Group_Count_#loopcount#_Label">
				<CFSET DISPLAY = "Group #loopcount#">
			<CFELSEIF loopcount GT 9>
				<CFSET LABEL = "Approval_Group_Count_0#loopcount#_Label">
				<CFSET DISPLAY = "Group #loopcount#">
			<CFELSE>
				<CFSET LABEL = "Approval_Group_Count_00#loopcount#_Label">
				<CFSET DISPLAY = "Group #loopcount#">
			</CFIF>
			
			<CFSET Label_value = #Evaluate("Get_Group.#Label#")#>
		<TR>

			<TD ALIGN="right" class="LabelStyle">#DISPLAY# :</TD>

			<TD align="left"><input MAXLENGTH="50" class="InputStyle" type="text" name="#Label#" value="#Label_Value#"></TD>
		</TR>
		</CFLOOP>
		<!--- <TR>	
			<TD>&nbsp;</TD>	

			<TD>
				<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
						<A HREF="javascript: document.Group_labels.submit()"><B>save data</B></A>
				<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT></P>
			</TD>
		</TR> --->
	</TABLE>
	<BR><BR>
	<TABLE align="center">
			<TR>
				<TD>
				<DIV ALIGN="center">
					<CF_BUTTON
					BUTTON_NAME		=	""
					BUTTON_CAPTION	=	"save data"
					BUTTON_ACTION	=	"javascript:document.Group_labels.submit();"
					BUTTON_TYPE		=	"link"
					BUTTON_WIDTH	=	"100"
					BUTTON_COLOR	=	"Navy"
					BUTTON_TIP		=	""
					FONT_COLOR		=	"White"
					FONT_SIZE		=	"12"
					FONT_WEIGHT		=	"bold">
				</DIV>
				</TD>
			</TR>
		</TABLE>				
</FORM>
</CFOUTPUT>


</body>
</html>
