<!----
	Filename:	C:\Work\Code\base\AwayX\DEDUCTIONS\Closure\DD_Non_Trade_Invoice.cfm
	Created:	12/28/2011
 	Developer:	drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		Use to list out invoice, if user click on INVOICE we will redirect to DD_NON_TRADE_ALL_ITEMS.CFM
	Usage: DD NON TRADE
---->
<cfparam name="url.from" default="pop-up">
<div style="background: url(/Images/gradient.jpg); background-color:#A7CAF2; background-repeat : no-repeat; width:100%; height:20px; padding:5px; color: White; font-weight: bold; font-size: 16px;">
		Invoice Search
</div>
<style>
	.button{
		border: none;
		background-color: white;
		font-weight: bold;
		color: blue;
		width:50px;
		cursor:pointer;
		}
	 .bracket{
	 	font-weight: bold;
		color: red;
	 }
</style>
<cfparam name="form.Invoice" default="">

<cfif NOT isDefined("Deduction_ID")>
	<cfset Deduction_ID = #url.Deduction_ID#>
</cfif>
<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">
<cfinclude template="/deductions/sql_Deduction_Info.cfm">
<cfoutput>
	<table width="100%;">
		<tr style="font-weight: bold; font-size:20px;">
			<td>#Deduction_Info.DD_DedID_SP_Number#</td>
			<td>
				<CFIF Deduction_Info.ShipToName NEQ "">
						#Deduction_Info.ShipToName# (#Deduction_Info.Shr_Ship_To#)
					<CFELSE>
						#Deduction_Info.Name# (#Deduction_Info.Shr_Bill_To#)
				</CFIF>
			</td>
			<td align="right">#LSCurrencyFormat(Deduction_Info.DD_Amount)#</td>
		</tr>
	</table>


	<div style="width: 100%; float: right; text-align:right;">
			<a href="DD_Non_Trade_All_Items.cfm?Deduction_ID=#Deduction_ID#&Profile_ID=#url.profile_id#&from=#url.from#">#ActionText("Search Items")#</a>
			&nbsp;&nbsp;
      		<cfif url.from EQ "pop-up">
			<a href="/deductions/update_status.cfm?Deduction_ID=#Deduction_ID#"> #ActionText("Back")# </a>
			</cfif>
	</div>
</cfoutput>

<cfif isdefined("form.submit")>
	<cfset form.Invoice = #form.Invoice#>
</cfif>
<!--- D29907  for ISSUE 4 --->
<cfif isdefined("form.submit") AND #len(form.Invoice)# EQ 0>
	<div style="background-color:red; color: white; font-weight: bold; width:100%; padding-top:5px; padding-bottom:5px;">
		&nbsp;&nbsp;&nbsp;INVOICE NUMBER FIELD IS EMPTY.
	</div>
<cfelseif isdefined("form.submit") AND (#len(form.Invoice)# GT 0 and #len(form.Invoice)# LT 4)>
	<div style="background-color:red; color: white; font-weight: bold; width:100%; padding-top:5px; padding-bottom:5px;">
		&nbsp;&nbsp;&nbsp;INVOICE NUMBER FIELD SHOULD ATLEAST HAVE 4 CHARACTERS.
	</div>
</cfif>
<!--- D29907  for ISSUE 4 --->
<cfoutput>
	<form name="invoice" action="dd_non_trade_invoice.cfm?profile_id=#url.profile_id#&Deduction_id=#url.Deduction_ID#&from=#url.from#" method="post">
	<table>
		<tr>
			<td style="font-weight: bold; font-size:13px;">Invoice Number:</td>
			<td><input type="text" name="Invoice" value="#form.Invoice#">
			<input type="hidden" name="profile_id" value="#url.profile_id#">
			<input type="hidden" name="Deduction_ID" value="#url.Deduction_ID#">
			<span class="bracket">[</span> <input type="submit" name="submit" value="Search" class="button"><span class="bracket">]</span> 
			</td>
		</tr>
	</table>
	</form>
</cfoutput>

<!--- D29907  for ISSUE 4 --->
<cfif isdefined("form.submit") AND #len(form.Invoice)# GTE 4>
<cfset InvoiceInfo = CreateObject("component", "components.deduction.nontrade") />
<cfset Invoices = InvoiceInfo.InvoicesForNonTrade(#form.Invoice#, #form.Deduction_ID#)><!--- D39095 :: Deduction Filtering  --->
	
<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
.action { font-weight:bold; margin:0 3px 0 3px; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<cfscript>
  vars = StructNew();
</cfscript>


<hr><br>

<table id="Invoice" class="datagrid" border="0">
	<thead>
					<tr>
	    				<th>Invoice Number</th>
						<th>Ship To</th>
	    				<th>Name</th>
					</tr>
	</thead>
	<tbody>
		<cfoutput query="Invoices">
					<tr>
						<td><a href="DD_Non_Trade_All_Items.cfm?Deduction_ID=#form.Deduction_ID#&Invoice_ID=#Invoice_Header_ID#&Profile_ID=#form.Profile_ID#&from=#url.from#">#shared_Invoice_number#</a></td>
					 	<td>#Shr_ship_to#</td>
					 	<td>#Name#</td>
					</tr>
		</cfoutput>
	</tbody>
</table>


<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.0/jquery.min.js"></script>
<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
	var grid = $('#Invoice').dataTable({
			"bAutoWidth": false
			,"bPaginate": true
			,"bSortClasses": false
			,"bScrollCollapse": true
			,"sDom": 'Rlfrtip'
			,"sScrollXInner": "100%"
			,"aaSorting": [[ 0, "asc" ]] 
  			,"aoColumns": [   {"sWidth": "30%", "sType": "numeric"}
							, {"sWidth": "30%", "sType": "numeric"}
                  			, {"sWidth": "30%"}]
}).fnSetFilteringDelay();
<!--- adjust the grid when window is resized --->
$(window).resize(function(){
  grid.fnAdjustColumnSizing();
});

$('table#Invoice tr').hover (
	function() { $(this).addClass("over"); },
	function() { $(this).removeClass("over"); }
);

</script>



</cfif>