<!------ Cost_Sequence.cfm ----->
<cfoutput>
<!--- <cfparam name="form.edit_cost_sequence" default = "0">
<cfparam name="form.edit_cost_sequence_id" default = "0">
<cfparam name="form.Cost_Sequence_Name" default = "">
<cfparam name="form.Cost_Sequence_Rate" default = "">--->
<cfparam name="maxlocvars" default = "0"> 
<cfparam name="savedcostvars" default = "0"> 

<cfset qCostSequence = costSequenceManager.getAll()>
<cfset Max_cost_Sequence_Order = 0>
<cfset savedcostvars = qCostSequence.recordcount>

<cfset maxlocvars = appSettings.getmaxlocalcostvars()>

<cfset Check_Add_Cost_Sequence_Order = 0>
<cfif isDefined("form.Add_Cost_Sequence_Order")>
	<cfset Check_Add_Cost_Sequence_Order = form.Add_Cost_Sequence_Order>	
</cfif>
<!--- 
<cfif form.EDIT_COST_SEQUENCE EQ  1>
	<cfif form.edit_cost_sequence_id NEQ "" OR form.edit_cost_sequence_id NEQ 0>
		<cfset getcostvariable_details = costSequenceManager.getAll(form.edit_cost_sequence_id)>
	</cfif>
	<cfif getcostvariable_details.recordcount GT 0>
		<cfset form.Cost_Sequence_Name = getcostvariable_details.COST_SEQUENCE_NAME>
		<cfset form.Cost_Sequence_Rate = getcostvariable_details.COST_SEQUENCE_RATE>
		<cfset form.Cost_Sequence_UOM =  getcostvariable_details.COST_SEQUENCE_UOM>
	</cfif>
</cfif> --->

		
<table cellpadding="2" cellspacing="1" width="800">
<tr valign="top">
<td width="60%">
	<SPAN CLASS="title2">Stored Records</SPAN>
	<HR COLOR="Blue" SIZE="1">
	<table cellpadding="2" cellspacing="0" align="center" class="Maintable" width="100%">
		<tr>
			<td id="header"><B>Order</B></td>
			<td id="header"><B>Cost Variable</B></td>
			<td id="header">&nbsp;</td>
			<td id="header">&nbsp;</td>
			<!--- <td id="header">&nbsp;</td> --->
		</tr>
		<cfloop query="qCostSequence">
		<cfset Cost_Sequence_Order_Change = 0>
		<cfset bgColor = "">
		<cfif Check_Add_Cost_Sequence_Order NEQ 0 AND Check_Add_Cost_Sequence_Order LTE Cost_Sequence_Order and form.command NEQ "edit">
			<cfset bgColor = "ffdead">
			<cfset Cost_Sequence_Order_Change = 1>
		</cfif>
		
		
		<cfif Check_Add_Cost_Sequence_Order EQ Cost_Sequence_Order and form.command NEQ "edit">
		<tr bgcolor="#bgColor#">
			<td>#Cost_Sequence_Order#</td>		
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		</cfif>
		<tr bgcolor="#bgColor#">
			<td>
			#Cost_Sequence_Order#
			<cfif Cost_Sequence_Order_Change> <font face="Courier New">-></font> #Cost_Sequence_Order+1#</cfif>
			</td>
			<td>#Cost_Sequence_Name#&nbsp;</td>
			<!--- <td>#trim(numberformat(Cost_Sequence_rate,'_-___,___,___,___,___.____'))#&nbsp;</td>
			<td>#Unit_Of_Measure_Desc#&nbsp;</td> --->
			<td id="header">
			<CF_smallLink 
				title = "insert" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'add', '#Cost_Sequence_Order#');"""
			>
			&nbsp;</td>
			<td id="header">
			<CF_smallLink 
				title = "edit" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'edit', '#qCostSequence.Cost_Sequence_id#');"""
			>
			&nbsp;</td>
			<!--- <td id="header">
			<CF_smallLink 
				title = "edit" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'edit', '#Cost_Sequence_ID#');"""
			>
			&nbsp;</td> --->
			<td id="header">
				<CF_smallLink 
					title = "delete" 
					url = "##"
					parameters = "onClick=""javascript: return submitForm('#formName#', 'delete', '#Cost_Sequence_ID#', '#Cost_Sequence_Name#');"""
				>
			&nbsp;</td>
		</tr>
		<cfset Max_Cost_Sequence_Order = Cost_Sequence_Order>
		</cfloop>	
		<tr>
		 <td colspan="100%" align="center" id="header">
		 <CF_smallLink 
				title = "add" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'add', #Max_Cost_Sequence_Order + 1#);"""
			>
		 <cfif qCostSequence.recordCount GT 1>
		&nbsp;&nbsp;&nbsp;
		<!---  <CF_smallLink 
				title = "change order" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'changeOrder1');"""
			>--->
		</cfif>  
		 </td>
		</tr>
	</table>
</td>

<cfparam name="form.Add_Cost_Sequence_Order" 	default="0">
<cfif form.Add_Cost_Sequence_Order EQ 0>
	<cfset form.Add_Cost_Sequence_Order = Max_Cost_Sequence_Order + 1>
</cfif>

<script>
function addEditSaveValidate(oForm)
{
	
	var bError = 0;
	var costName = oForm.Cost_Sequence_Name.value;
	var maxvars = <cfoutput>#maxlocvars#</cfoutput>;
	
	<cfoutput><cfif #savedcostvars# GTE #maxlocvars#>
		queueMessage("You cannot enter more than " + maxvars + " cost variables", " ");
		bError++;
	</cfif></cfoutput>
	//var costRate = oForm.Cost_Sequence_Rate.value;
	if(trim(costName) == "")
	{
		queueMessage("Cost Sequence Description cannot be empty", document.all.err_sp_Cost_Sequence_Name);
		bError++;
	}
	else
	{
		clearQueue(document.all.err_sp_Cost_Sequence_Name);
	}
	
	return bError;
}
</script>



<cfif form.command EQ "edit">
<cfset qCostSequenceName = costSequenceManager.getAll(id)>
<cfset get_Cost_Sequence_Name = qCostSequenceName.Cost_Sequence_Name>
<cfset form.sequence_id = qCostSequenceName.cost_sequence_id>
<cfset form.Add_Cost_Sequence_Order = qCostSequenceName.Cost_Sequence_Order>
<cfelse>
<cfset get_Cost_Sequence_Name = "">
<cfset form.sequence_id = 0>
</cfif>


<input value="#form.sequence_id#" name="id" type="Hidden">

<td width="40%">
<cfif form.command EQ "edit">
<SPAN CLASS="title2">Edit Cost Sequence</SPAN>
<cfelse>
	<SPAN CLASS="title2">Add Cost Sequence</SPAN>
</cfif>
	<HR COLOR="Blue" SIZE="1">
	<table cellpadding="2" cellspacing="0" align="right">
		<tr>
			<td><B>Order</B></td>
			<td>
			<input value="#form.Add_Cost_Sequence_Order#" name="Cost_Sequence_Order" size="2" readonly>
			</td>
		</tr>
		<tr>
			<td><B>Description</B>
			<span id="err_sp_Cost_Sequence_Name">&nbsp;</span>
			</td>
			<td>
			<input value="#get_Cost_Sequence_Name#" name="Cost_Sequence_Name" size="50">
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
			<br><br>
			<!--- <cfif form.edit_cost_sequence EQ 0> --->
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'addEditSave');"""
			>
			<!--- <cfelse>
			<CF_smallLink 
				title = "edit" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'addEditSave');"""
			>
			</cfif> --->
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