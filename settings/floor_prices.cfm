<HTML>

<BODY>
<CFSET URL.PageTitle="Administration: Floor Prices">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<STYLE TYPE="text/css">
Body, 
TD
{
	font: 12px Arial;
},
a 
{
	color: Blue;
	text-decoration: none;
}
</STYLE>

<cfset FormattedDate = dateformat(now(), 'mm-dd-yyyy')>

<cfquery name="GetFloorPrices" datasource="#application.datasource#">
SELECT Spending_Cap_Pricing_Floor.Item_Number, BSA_Foodservice_Items_Master.Description,
 Spending_Cap_Pricing_Floor.Pound_Distributor_Floor, Spending_Cap_Pricing_Floor.Pound_Operator_Floor
FROM Spending_Cap_Pricing_Floor
	INNER JOIN BSA_Foodservice_Items_Master
	ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Spending_Cap_Pricing_Floor.Product_ID
</cfquery>

<cfoutput>
<cfsavecontent variable="FloorPrices">
	<table width="90%" align="center" cellpadding="2" cellspacing="0">
	<tr>
		<th>Item number</th>
		<th>Description</th>
		<th>#application.returned_customer_setting.distributor_label_singular# Floor</th>
		<th>#application.returned_customer_setting.operator_label_singular# Floor</th>
	</tr>
	
	<tr>
		<td colspan="100%" align="right"><i>All floor values listed in pounds</i></td>
	</tr>
	
	<cfloop query="GetFloorPrices">
	<tr>
		<td>#Item_Number#</td>
		<td>#Description#</td>
		<td>#Pound_Distributor_Floor#</td>
		<td>#Pound_Operator_Floor#</td>
	</tr>
	
	</cfloop>
	
	</table>
</cfsavecontent> 

<cfset FloorPrices = "<cfheader name=""Content-Disposition"" value=""attachment;filename=floorprices_#formattedDate#.html"">#FloorPrices#">


<cfsavecontent variable="CSV_Version">
Item Number, Description, #application.returned_customer_setting.distributor_label_singular# Floor, 
#application.returned_customer_setting.operator_label_singular# Floor<p></p>
<cfloop query="GetFloorPrices">
#Item_Number#, #Description#, #Pound_Distributor_Floor#, #Pound_Operator_Floor#<br>
</cfloop>
</cfsavecontent>

<cfset CSV_Version = "<cfheader name=""Content-Disposition"" value=""attachment;filename=floorprices_#formattedDate#.csv"">#CSV_Version#">

</cfoutput>

<CFOUTPUT>#FloorPrices#</CFOUTPUT> 


<!----Build directory structure--->
<cfif DirectoryExists("#Application.Doc_Path#\temp_files\floorprice") IS FALSE>
	<cfdirectory action="create" directory="#Application.Doc_Path#/temp_files/floorprice">
</cfif>


<CFFILE 
				ACTION = "Write" 
				FILE   = "#Application.Doc_Path#\temp_files\floorprice\html#FormattedDate#.cfm" 
				OUTPUT = "#FloorPrices#" 
				ADDNEWLINE = "Yes"
				nameconflict = "overwrite"
	> 
	<CFFILE 
				ACTION = "Write" 
				FILE   = "#Application.Doc_Path#\temp_files\floorprice\csv#FormattedDate#.cfm" 
				OUTPUT = "#CSV_Version#" 
				ADDNEWLINE = "Yes"
				nameconflict = "overwrite"
	> 
	<hr>
	<p></p>
<div align="center">

<cfoutput><A href="/GetDocument.cfm?Filepath=temp_files/floorprice/html#FormattedDate#.cfm">Formatted version</A> &middot;
<A href="/GetDocument.cfm?Filepath=temp_files/floorprice/csv#FormattedDate#.cfm">Comma delimited list</A></cfoutput>
	</div>
</body>
</html>

