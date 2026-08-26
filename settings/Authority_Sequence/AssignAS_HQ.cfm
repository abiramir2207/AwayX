<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfset qAuthoritySequence = HQPositionManager.getAStoAssign(form.HQ_Position_Id,form.HQ_Position_Order_check)>
<cfset qASAssigned = HQPositionManager.getASAssigned(form.HQ_Position_Id)>
<cfset qASAssignedList = valuelist(qASAssigned.Authority_Sequence_ID)>
<table cellpadding="2" cellspacing="1" width="400" class="maintable">
<tr valign="top">
	<td colspan="100%">
	<SPAN CLASS="title2">Authority Sequences</SPAN>
	<HR COLOR="Blue" SIZE="1">
	</td>
</tr>
<cfif qAuthoritySequence.recordcount GT 0>
<tr valign="top">
	<td>&nbsp;</td>
	<td id="header"><B>Order</B></td>
	<td id="header"><B>Authority Name</B></td>
</tr>
<cfoutput><cfloop query="qAuthoritySequence">
<tr>
<td>
<input TYPE="Checkbox" NAME="Authority_Sequence_ID" value="#qAuthoritySequence.Authority_Sequence_Id#" <cfif listfind(qASAssignedList,qAuthoritySequence.Authority_Sequence_Id,",")>checked</cfif>>
</td>
<td>#Authority_Sequence_Order#</td>		
<td>#Authority_Sequence_Name#</td>		
</tr>
</cfloop>
<tr>
<td id="header" colspan="2">
<CF_smallLink 
				title = "Assign Authority Sequences" 
				url = "##"
				mouseovernotes = "Assign Authority Sequences"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'AssignHQSave', '#form.HQ_Position_ID#');"""
			>
			&nbsp;
</td>
<td id="header" colspan="2">
<CF_smallLink 
				title = "Remove all" 
				url = "##"
				mouseovernotes = "Remove all Authority Sequences Assigned"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'AssignHQDelete', '#form.HQ_Position_ID#');"""
			>
			&nbsp;
<CF_smallLink 
				title = "Cancel" 
				url = "##"
				mouseovernotes = "Cancel"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'HQ');"""
			>
			&nbsp;
</td>
</tr></cfoutput>
<cfelse>
<tr valign="top">
	<td colspan="100%">
	<SPAN CLASS="title2">No Authority Sequences available to assign.</SPAN>
	</td>
</tr>
<cfoutput>
<tr>
<td id="header">
<CF_smallLink 
				title = "Back" 
				url = "##"
				mouseovernotes = "Cancel"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'HQ');"""
			>
			&nbsp;
</td>
</tr></cfoutput>
</cfif>
</table>
<script>
function AssignASValidate(oForm)
{
	var bError = 0;
	if(Not_Any_Object_Checked(oForm.Authority_Sequence_ID))
	{
		clearQueue(document.all.err_sp_Authority_Sequence_Id);
	}
	else
	{
		queueMessage("Select atleast one Authority Sequence.", document.all.err_sp_Authority_Sequence_Id);
		bError++;
	}
	return bError;
}

function Not_Any_Object_Checked(chObj)
{
	var chLen, i;
	var returnValue = false;
	if(chObj)
	{
		chLen = chObj.length;
		if(chLen)
		{
			for(i=0;i<chLen;i++)
			{
				if(chObj[i].checked)
				{
					returnValue = true;
				}
			}
		}
		else
		{
			if(chObj.checked)
			{
				returnValue = true;
			}
		}
	}	
	return returnValue;

}
</script>

</body>
</html>
