<!--- Get top 100 errors --->
<cfoutput><SCRIPT LANGUAGE="JavaScript" SRC="bigbillback.js"></SCRIPT></cfoutput>

<cfquery name="Top100Errors" datasource="#application.datasource#">
SELECT TOP 100 * 
FROM Big_Billback 
WHERE Has_Error = 1
AND Billback_ID = '#Billback_ID#'
AND Big_Billback_Summary_ID = '#Big_Billback_Summary_ID#'
AND Deleted = 0
ORDER BY Big_Billback_ID
</cfquery>

<cfquery name="ErrorCount" datasource="#application.datasource#">
SELECT count(Big_Billback_ID) AS ErrorCount
FROM Big_Billback
WHERE Billback_ID = '#Billback_ID#'
AND Big_Billback_Summary_ID = '#Big_Billback_Summary_ID#'
AND Has_Error = 1
AND Deleted = 0
</cfquery>


<cfquery name="RowCount" datasource="#application.datasource#">
SELECT count(Big_Billback_ID) AS AllRows
FROM Big_Billback
WHERE Billback_ID = '#Billback_ID#'
AND Big_Billback_Summary_ID = '#Big_Billback_Summary_ID#'
AND Deleted = 0
</cfquery>

<style>
.needs_attention
{
	background-color: yellow;
}

	
TABLE.Maintable TD	
	{
		border-bottom:solid #93BEE2 1px; 
		font-size : 10px;
	}

##header 
	{
		font-size: 12px;
	}

##dataStyle
	{
		font-size: 10px;
	}
	
TD
	{
		font-family:Arial;
	}	 
	
TH
	{
		font-family:Arial;
		font-size:12px;
		background-color: orange;
		border-bottom:solid #93BEE2 1px; 
	}
</style>

<cfoutput>
<cfif Top100Errors.Recordcount GT 0>
<!--- Master layout table --->
<table width="800" align="center" class="Maintable" cellpadding="2" cellspacing="0" border="0">
<tr class="header"><div align="center"><b>There are #ErrorCount.ErrorCount# errors out of #RowCount.AllRows# records</b>
 <br>
				<CF_smallLink 
					title = "delete entries and re-enter" 
					url = "##"
					parameters = "onClick=""deleteAndReenter('#Billback_ID#','#Big_Billback_Summary_ID#');"""
					>

</div><br></tr>

	<!---Header --->
	<tr>
		
		<th>#application.returned_customer_setting.distributor_label_singular#</th>
		<th>&nbsp; </th>
		<th>Product</th>
		<th>&nbsp; </th>
		<th>Volume</th>
		<th>UOM</th>
		<th>Amount</th>
		<th>Delete </th>
	</tr>
	<!--- End Header --->
<form name="BBBValidation" method="post" action="secondary_billback_validation.cfm">
<input type="hidden" name="Billback_ID" value="#Billback_ID#">
<input type="hidden" name="Big_Billback_Summary_ID" value="#Big_Billback_Summary_ID#">
	<!--- Display errors --->
	
	<cfset BigBillbackIDList = "">
	
	<cfloop query="Top100Errors">
		<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			
			<td>
				<cfif Distributor_Error IS 1>
					<input type="text" size="35" maxlength="55" name="Distributor_#Big_Billback_ID#" value="#distributor#" class="needs_attention">
				<cfelse>
					#Distributor#
					<input type="hidden" name="Distributor_#Big_Billback_ID#" value="#distributor#">
				</cfif>
			</td>
				<td>
				<cfif Distributor_Error IS 1>
					<CF_smallLink 
					title = "find #lcase(application.returned_customer_setting.distributor_label_singular)#" 
					url = "##"
					parameters = "onClick=""findDistributor('#Big_Billback_ID#');return false;"""
					><cfelse>
				&nbsp; 
				
				</cfif>
				</td>
			
			<td>
				<cfif Product_Error IS 1>
					<input type="text" size="35" maxlength="55" name="Product_#Big_Billback_ID#" value="#replace(product, """", "&quot;")#" class="needs_attention">
				<cfelse>
				#Product#
					<input type="hidden" name="Product_#Big_Billback_ID#" value="#product#">
				</cfif>
			</td>
				<td>
				<cfif Product_Error IS 1>
					<CF_smallLink 
					title = "find product" 
					url = "##"
					parameters = "onClick=""findProduct('#Big_Billback_ID#');return false;"""
					><cfelse>
				&nbsp; 
				</cfif>
				</td>
			
			<td align="right">
				<cfif Volume_Error IS 1>
					<input type="text" size="10" maxlength="20" name="Volume_#Big_Billback_ID#" value="#Volume#" class="needs_attention" align="right">
				<cfelse>
					#Volume#
					<input type="hidden" name="Volume_#Big_Billback_ID#" value="#Volume#">
				</cfif>
			</td>
			<td align="right">
				<cfif Volume_Error IS 1>
					<!--- <input type="text" size="10" maxlength="20" name="Volume_#Big_Billback_ID#" value="#Volume#" class="needs_attention" align="right"> --->
					<select name="UOM_#Big_Billback_ID#" class="needs_attention" align="right">
						<option value="CS" <cfif (UOM EQ "CS")>selected</cfif>>CS</option>
						<option value="LB" <cfif (UOM EQ "LB")>selected</cfif>>LB</option>
					</select>
				<cfelse>
					<select name="UOM_#Big_Billback_ID#">
						<option value="CS" <cfif (UOM EQ "CS")>selected</cfif>>CS</option>
						<option value="LB" <cfif (UOM EQ "LB")>selected</cfif>>LB</option>
					</select>
				</cfif>
			</td>
			<td align="right">
				<cfif Amount_Error IS 1 or ISNUMERIC(Amount) EQ 0>
					$<input type="text" size="10" maxlength="20" name="Amount_#Big_Billback_ID#" value="#Amount#" class="needs_attention" align="right">
				<cfelse>
					#lscurrencyformat(Amount)#
					<input type="hidden" name="Amount_#Big_Billback_ID#" value="#Amount#">
				</cfif>
			</td>
			<td><input type="checkbox" value="#Big_Billback_ID#" name="BB_To_Delete"></td>
		</tr>
		<cfset BigBillbackIDList = listappend(BigBillbackIDList,Big_Billback_ID)>
	</cfloop>
	
	
	<input type="hidden" name="BigBillbackIDList" value="#BigBillbackIDList#">
	
	
	<tr><td colspan="100%" align="Center">
	<CF_smallLink 
					title = "validate and continue" 
					url = "##"
					parameters = "onClick=""javascript: BBBValidation.submit();return false;"""
					>
	</td></tr>
	<!--- End Display errors --->
	</form>	

</table>
<!--- Master layout table --->

<cfelse>
<!---No error records --->


<html>
<head><title>Import Big Billback Data</title>

</head>
<body>

<div align="center">
There were no errors in your entry. You will be entering #RowCount.AllRows# records into the billback.
<p></p> If you were expecting more records, there may have been an error in the data you copied. Please remove any blank rows or subtotal rows and try again.
<p></p>
				<CF_smallLink 
					title = "continue billback processing" 
					url = "##"
					parameters = "onClick=""billbackContinue('#Billback_ID#','#Big_Billback_Summary_ID#');return false;"""
					> 
					
</div>
</body>
</html>
<!---Error records --->
</cfif>

<script>

 try { window.parent.dyniframesize(); } catch (err) { };
 window.parent.buildMenu();
 
if (document.body.scrollTop != 0)
{
    document.body.scrollTop = 0;
}
</script>
</cfoutput>

