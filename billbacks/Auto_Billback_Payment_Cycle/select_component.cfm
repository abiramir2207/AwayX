<!--- select_component.cfm- Copyright (c) 2004 Blacksmith Applications, Inc.--->
<!--- Created By: Tim Ford on 05/12/2005 --->
<!--- component selection screen based on distributor/program combination--->
<cfparam name="form.Program_List" default="0" />
<cfparam name="form.selected_row" default="0" />

<cfset qBillbackComps = AutoBillbackManager.getBillbackComponents(form.Program_List) />
<!--- need to sections to handle for single row (document.all.billback_component) or lists (array of check boxes document.all.billback_component[i]) --->
<script>
	function pay()
	{
		if(document.all.billback_component != null)
			{
			var selectLen = document.all.billback_component.length;
			if(selectLen == undefined)
				{
					if(document.all.billback_component.checked)
					{	
						document.all.command.value = 'svBillback';
						document.BillbackCompForm.submit();
						return;
					}
				}
			else
				{
					for(i=0;i<selectLen;i++)
						{
						if(document.all.billback_component[i].checked)
							{	
							document.all.command.value = 'svBillback';
							document.BillbackCompForm.submit();
							return;
							}
						}
				}
			}
			alert ("Please choose a program component to BillBack against. If none are available, then you may need to delete one before re-creating the BillBack.");
			return;
	}
	function DoSearch(url)
	{
	this.window.parent.location.href = url;
	}
</script>

<form action="" method="post" name="BillbackCompForm">
<br>
<TABLE BORDER="0" CELLPADDING="4" CELLSPACING="0" ALIGN="Center" class="MainTable" bgcolor="ffce84">
	<tr>
		<td><font size="2"><strong>Program</strong></font></td>
		<td><font size="2"><strong>SAP Reference ID</strong></font></td>
		<td><font size="2"><strong>From Date</strong></font></td>
		<td><font size="2"><strong>To Date</strong></font></td>
		<td><font size="2"><strong>Discount Type</strong></font></td>
		<td><font size="2"><strong>Component Name</strong></font></td>
		<td><font size="2"><strong>Pay</strong></font></td>
	</tr>
	<cfif qBillbackComps.RecordCount>
		<cfoutput query="qBillbackComps">
	
			<tr bgcolor="<CFIF CurrentRow mod 2>FFFFFF<CFELSE>CCFFCC</CFIF>">
				<td>#Program_Number#</td>
				<td>#SAP_Reference_ID#</td>
				<td>#DateFormat(Payment_Start_Date, "mm/dd/yyyy")#</td>
				<td>#DateFormat(Payment_End_Date, "mm/dd/yyyy")#</td>
				<td>#Discount_Type#</td>
				<td>#Component_Name#</td>
				<td><cfif trim(BB_Code) neq "">
						<span style="color:red; cursor:help" title="Please delete BB #BB_Code# before trying to re-create a BillBack for this component">
						<a href="javascript:void(0);" onclick="DoSearch('/billbacks/capture/INDEX.CFM?bbid=#Billback_id#')">#BB_code#</a>
						</span>
					<cfelse>
						<input name="billback_component" type="radio" value="#CurrentRow#" />
					</cfif></td>
			</tr>
			<input name="program_id_#CurrentRow#" type="hidden" value="#Program_ID#" />
			<input name="start_date_#CurrentRow#" type="hidden" value="#Payment_Start_Date#" />
			<input name="end_date_#CurrentRow#" type="hidden" value="#Payment_End_Date#" />
			<input name="component_id_#CurrentRow#" type="hidden" value="#Component_ID#" />
			<input name="program_component_id_#CurrentRow#" type="hidden" value="#Program_Component_ID#" />
			<input name="discount_type_id_#CurrentRow#" type="hidden" value="#Discount_Type_ID#" />
			<input name="Payment_Cycle_ID_#CurrentRow#" type="hidden" value="#Payment_Cycle_ID#" />
		</cfoutput>
		
	<cfelse>
		
		<tr>
			<td colspan="100%">There are no billback periods for this distributor and program.</td>
		</tr>
			
	</cfif>
</TABLE>
<TABLE BORDER="0" CELLPADDING="4" CELLSPACING="0" ALIGN="Center">
	<tr align="left">
		<td>
			<CF_button
				button_name		=	""
				button_caption	=	"save"
				button_action	=	"pay()"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
	</tr>
</TABLE>
<cfoutput>
<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
<INPUT TYPE="Hidden" NAME="command" VALUE="#FORM.command#">
</cfoutput>
</form>