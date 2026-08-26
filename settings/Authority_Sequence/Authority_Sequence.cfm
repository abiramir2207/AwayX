<!------ Authority_Sequence.cfm ----->
<cfoutput>
<cfset qAuthoritySequence = authoritySequenceManager.getAll()>
<cfset Max_Authority_Sequence_Order = 0>

<cfset Check_Add_Authority_Sequence_Order = 0>
<cfif isDefined("form.Add_Authority_Sequence_Order")>
	<cfset Check_Add_Authority_Sequence_Order = form.Add_Authority_Sequence_Order>	
</cfif>

<!--- Get the date last updated and the user that did the update									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Update_Data" datasource="#application.datasource#" MAXROWS="1">
	select top 1 Authority_Sequence.updated_date, _users.name_first, _users.name_last
	from Authority_Sequence, _users
	where Authority_Sequence.updated_by = _users.user_id
	and _users.deleted = 0
	order by 1 desc
</CFQUERY>
<cfif Get_Update_Data.RecordCount>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0"  width="530">
<TR>
<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(Get_Update_Data.Updated_Date, 'm/d/yyy')# #timeformat(Get_Update_Data.Updated_Date, 'h:mm:ss TT')# by #Get_Update_Data.name_first# #Get_Update_Data.name_last#
</B></FONT>	
 </TD>
</TR>
</TABLE><br>
</cfif>
<table cellpadding="2" cellspacing="1" width="750">
<tr valign="top">
<td width="50%">
	<SPAN CLASS="title2">Stored Records</SPAN>
	<HR COLOR="Blue" SIZE="1">
	<table cellpadding="2" cellspacing="0" align="center" class="Maintable" width="100%">
		<tr>
			<td id="header"><B>Order</B></td>
			<td id="header"><B>Authority Name</B></td>
			<td id="header">&nbsp;</td>
			<td id="header">&nbsp;</td>
			<td id="header">&nbsp;</td>
		</tr>
		<cfloop query="qAuthoritySequence">
		<cfset Authority_Sequence_Order_Change = 0>
		<cfset bgColor = "">
		<cfif Check_Add_Authority_Sequence_Order NEQ 0 AND Check_Add_Authority_Sequence_Order LTE Authority_Sequence_Order>
			<cfset bgColor = "ffdead">
			<cfset Authority_Sequence_Order_Change = 1>
		</cfif>
		<cfif Check_Add_Authority_Sequence_Order EQ Authority_Sequence_Order>
		<tr bgcolor="#bgColor#">
			<td>#Authority_Sequence_Order#</td>		
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		</cfif>
		<tr bgcolor="#bgColor#">
			<td>
			#Authority_Sequence_Order#
			<cfif Authority_Sequence_Order_Change> <font face="Courier New">-></font> #Authority_Sequence_Order+1#</cfif>
			</td>
			<td>#Authority_Sequence_Name#&nbsp;</td>
			<td id="header">
			<CF_smallLink 
				title = "insert" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'add', '#Authority_Sequence_Order#');"""
			>
			&nbsp;</td>
			<td id="header">
			<CF_smallLink 
				title = "edit" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'edit', '#Authority_Sequence_Order#', '#Authority_Sequence_Name#', '#Authority_Sequence_ID#');"""
			>
			&nbsp;</td>
			<td id="header">
			<cfset qGetUserAssosiated = authoritySequenceManager.getUserAssosiated(Authority_Sequence_ID) />
			
			<cfif NOT qGetUserAssosiated.recordCount>
				<CF_smallLink 
					title = "delete" 
					url = "##"
					parameters = "onClick=""javascript: return submitForm('#formName#', 'delete', '#Authority_Sequence_ID#', '#Authority_Sequence_Name#');"""
				>
			</cfif>
			&nbsp;</td>
		</tr>
		<cfset Max_Authority_Sequence_Order = Authority_Sequence_Order>
		</cfloop>	
		<tr>
		 <td colspan="100%" align="center" id="header">
		 <CF_smallLink 
				title = "add" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'add', #Max_Authority_Sequence_Order + 1#);"""
			>
		<cfif qAuthoritySequence.recordCount GT 1>
		&nbsp;&nbsp;&nbsp;
		 <CF_smallLink 
				title = "change order" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'changeOrder1');"""
			>
		</cfif>
		 </td>
		</tr>
	</table>
</td>

<cfparam name="form.Add_Authority_Sequence_Order" 	default="0">
<cfif form.Add_Authority_Sequence_Order EQ 0>
	<cfset form.Add_Authority_Sequence_Order = Max_Authority_Sequence_Order + 1>
</cfif>

<script>
function addEditSaveValidate(oForm)
{
	var bError = 0;
	var authName = oForm.Authority_Sequence_Name.value;
	if(trim(authName) == "")
	{
		queueMessage("Authority Sequence Description cannot be empty", document.all.err_sp_Authority_Sequence_Name);
		bError++;
	}
	else
	{
		clearQueue(document.all.err_sp_Authority_Sequence_Name);
	}
	return bError;
}
</script>


<input value="#form.id#" name="id" type="Hidden">
<td width="50%">
	<SPAN CLASS="title2">Add Authority Sequence</SPAN>
	<HR COLOR="Blue" SIZE="1">
	<table cellpadding="2" cellspacing="0" align="center">
		<tr>
			<td><B>Order</B></td>
			<td>
			<input value="#form.Add_Authority_Sequence_Order#" name="Authority_Sequence_Order" size="2" readonly>
			</td>
		</tr>
		<tr>
			<td><B>Description</B>
			<span id="err_sp_Authority_Sequence_Name">&nbsp;</span>
			</td>
			<td>
			<input value="" name="Authority_Sequence_Name" size="50">
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
			<br><br>
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'addEditSave');"""
			>
			&nbsp;&nbsp;&nbsp;
			<CF_smallLink 
				title = "cancel" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'list');"""
			>
			</td>
		</tr>
	</table>
</td>
</tr>
</table>
</cfoutput>