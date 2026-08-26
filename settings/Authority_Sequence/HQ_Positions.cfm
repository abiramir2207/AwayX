<!------ HQ_Positions.cfm ----->
<cfoutput>
<cfset qHQPositions = HQPositionManager.getAll()>
<cfset Max_HQ_Position_Order = 0>

<cfset Check_Add_HQ_Position_Order = 0>
<cfif isDefined("form.Add_HQ_Position_Order")>
	<cfset Check_Add_HQ_Position_Order = form.Add_HQ_Position_Order>	
</cfif>
<!--- Get the date last updated and the user that did the update									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Update_Data" datasource="#application.datasource#" MAXROWS="1">
	select top 1 HQ_Positions.updated_date, _users.name_first, _users.name_last
	from HQ_Positions, _users
	where HQ_Positions.updated_by = _users.user_id
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
<td width="70%">
	<SPAN CLASS="title2">Stored Records</SPAN>
	<HR COLOR="Blue" SIZE="1">
	<table cellpadding="2" cellspacing="0" align="center" class="Maintable" width="100%">
		<tr>
			<td id="header"><B>Order</B></td>
			<td id="header" nowrap><B>Position Name</B></td>
			<td id="header">&nbsp;</td>
			<td id="header">&nbsp;</td>
			<td id="header">&nbsp;</td>
			<td id="header"><B>Assign</B></td>
		</tr>
		<cfloop query="qHQPositions">
		<cfset HQ_Position_Order_Change = 0>
		<cfset bgColor = "">
		<cfif Check_Add_HQ_Position_Order NEQ 0 AND Check_Add_HQ_Position_Order LTE HQ_Position_Order>
			<cfset bgColor = "ffdead">
			<cfset HQ_Position_Order_Change = 1>
		</cfif>
		<cfif Check_Add_HQ_Position_Order EQ HQ_Position_Order>
		<tr bgcolor="#bgColor#">
			<td>#HQ_Position_Order#</td>		
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		</cfif>
		<tr bgcolor="#bgColor#">
			<td>
			#HQ_Position_Order#
			<cfif HQ_Position_Order_Change> <font face="Courier New">-></font> #HQ_Position_Order+1#</cfif>
			</td>
			<td nowrap>#HQ_Position_Name#&nbsp;</td>
			<td id="header" nowrap>
			<CF_smallLink 
				title = "insert" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'addHQ', '#HQ_Position_Order#');"""
			>
			&nbsp;</td>
			<td id="header" nowrap>
			<CF_smallLink 
				title = "edit" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'editHQ', '#HQ_Position_Order#', '#HQ_Position_Name#', '#HQ_Position_ID#');"""
			>
			&nbsp;</td>
			<td id="header" nowrap>
			<cfset qGetASAssosiated = HQPositionManager.getASAssosiated(HQ_Position_ID) />
			
			<cfif NOT qGetASAssosiated.recordCount>
				<CF_smallLink 
					title = "delete" 
					url = "##"
					parameters = "onClick=""javascript: return submitForm('#formName#', 'deleteHQ', '#HQ_Position_ID#', '#HQ_Position_Name#');"""
				>
			</cfif>
			&nbsp;</td>
			<td id="header" nowrap>
			<CF_smallLink 
				title = "AS" 
				url = "##"
				mouseovernotes = "Assign Authority Sequences"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'AssignHQ', '#HQ_Position_ID#','#HQ_Position_Order#');"""
			>
			&nbsp;</td>
		</tr>
		<cfset Max_HQ_Position_Order = HQ_Position_Order>
		</cfloop>	
		<tr>
		 <td colspan="100%" align="left" id="header" >
		 <CF_smallLink 
				title = "add" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'addHQ', #Max_HQ_Position_Order + 1#);"""
			>
		 </td>
		</tr>
	</table>
</td>

<cfparam name="form.Add_HQ_Position_Order" 	default="0">
<cfif form.Add_HQ_Position_Order EQ 0>
	<cfset form.Add_HQ_Position_Order = Max_HQ_Position_Order + 1>
</cfif>

<script>
function addEditSaveValidate(oForm)
{
	var bError = 0;
	var authName = oForm.HQ_Position_Name.value;
	if(trim(authName) == "")
	{
		queueMessage("HQ Position Description cannot be empty", document.all.err_sp_HQ_Position_Name);
		bError++;
	}
	else
	{
		clearQueue(document.all.err_sp_HQ_Position_Name);
	}
	return bError;
}
</script>


<input value="#form.id#" name="id" type="Hidden">
<td width="50%">
	<SPAN CLASS="title2">Add HQ Position</SPAN>
	<HR COLOR="Blue" SIZE="1">
	<table cellpadding="2" cellspacing="0" align="center">
		<tr>
			<td><B>Order</B></td>
			<td>
			<input value="#form.Add_HQ_Position_Order#" name="HQ_Position_Order" size="2" readonly>
			</td>
		</tr>
		<tr>
			<td><B>Description</B>
			<span id="err_sp_HQ_Position_Name">&nbsp;</span>
			</td>
			<td>
			<input value="" name="HQ_Position_Name" size="50">
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
			<br><br>
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#','addEditSaveHQ');"""
			>
			&nbsp;&nbsp;&nbsp;
			<CF_smallLink 
				title = "cancel" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'HQ');"""
			>
			</td>
		</tr>
	</table>
</td>
</tr>
</table>
</cfoutput>