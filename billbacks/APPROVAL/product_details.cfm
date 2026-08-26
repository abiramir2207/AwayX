<html>
<head>
<title>Exclusion Details</title>
</head>
<body>

<CFSET TR_ID_START="TPA_Details">
<CFSET DESC_LEN=100>

<SCRIPT LANGUAGE="JavaScript">
var TR_ID_START = '<CFOUTPUT>#TR_ID_START#</CFOUTPUT>';

function toggleAllToSameStatus(display_Style, trName)
{
	var tabObj = document.all.TPA_TABLE;	
	var TRsToHide = tabObj.rows;
	var change_To_Style = display_Style;
	
	if(arguments.length > 1)
	{
		if(trName != "*")
		{
			TRsToHide = TRsToHide[TR_ID_START + "_" + trName];
		}
	}
	var i, trLen;
	if(TRsToHide)
	{	
		trLen = TRsToHide.length;
		if(change_To_Style.length == 0)
		{
			if(trLen >= 1)
			{
				if(TRsToHide[0].style.display == "none")
				{
					change_To_Style = "";
				}
				else
				{
					change_To_Style = "none";
				}				
			}
		}
		for(i=0;i<trLen;i++)
		{
			if(TRsToHide[i].id)
			{
				if(TRsToHide[i].id.substring(0, TR_ID_START.length) == TR_ID_START)
				{
					TRsToHide[i].style.display = change_To_Style;
				}
			}
		}
	}
}
</SCRIPT>

<STYLE>
TABLE.MaintableTHEAD TD 
{
	font-size : 12px;
	border-bottom:solid 93BEE2 0px;
	font-weight : bold;
}

.TPA_DESC
{
	background-color:eeeeee;
}
</STYLE>

<cfset BB_Program_Exclusion_ID = Url.BB_Program_Exclusion_ID>

<cfquery name="GetProgramName" datasource="#application.datasource#">
SELECT 	Contract_Main.Contract_Title, 
		Contract_Main.Contract_Number,
		Billback.BB_Code,
		Billback.BB_Title,
		BSA_Foodservice_Customers.Name,
		BSA_Foodservice_Customers.Ship_to
FROM 	BB_Program_Exclusion
		INNER JOIN 	Contract_Main 
		ON
		Contract_Main.Contract_Main_ID = BB_Program_Exclusion.Program_ID
		INNER JOIN	Billback
		ON
		Billback.Billback_ID = BB_Program_Exclusion.Billback_ID
		INNER JOIN	BSA_Foodservice_Customers
		ON
		(
			(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BB_Program_Exclusion.Distributor_ID)
		)
WHERE 	BB_Program_Exclusion_ID = '#BB_Program_Exclusion_ID#'
</cfquery>

<cfset ProgramName = GetProgramName.Contract_Title>
<!---------------
<cfquery name="GetProducts" datasource="#application.datasource#">
SELECT 	BB_Product_Exclusion.TPA_LB, 
		BB_Product_Exclusion.TPA_CS, 
		BB_Product_Exclusion.Quantity_LB, 
		BB_Product_Exclusion.Quantity_CS, 
		BB_Product_Exclusion.Dollar_Amount, 
		Billback_Product.BB_Product_UOM, 
		BSA_Foodservice_Items_Master.Description,
		BSA_Foodservice_Items_Master.Item,
		BSA_Foodservice_Items_Master.UPC
FROM 	BB_Product_Exclusion
		INNER JOIN 	Billback_Product 
		ON
		Billback_Product.Billback_Product_ID = BB_Product_Exclusion.Billback_Product_ID
		INNER JOIN 	BSA_Foodservice_Items_Master 
		ON
		BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
WHERE
BB_Product_Exclusion.BB_Program_Exclusion_ID = '#BB_Program_Exclusion_ID#'
AND BB_Product_Exclusion.Deleted = 0
</cfquery>
-------->

<cfquery name="GetProducts" datasource="#application.datasource#">
SELECT 	DISTINCT BB_Product_Exclusion.TPA_LB, 
		BB_Product_Exclusion.TPA_CS, 
		BB_Product_Exclusion.Quantity_LB, 
		BB_Product_Exclusion.Quantity_CS, 
		BB_Product_Exclusion.Dollar_Amount, 
		Billback_Product.BB_Product_UOM, 
		BSA_Foodservice_Items_Master.Description,
		BSA_Foodservice_Items_Master.Item,
		BSA_Foodservice_Items_Master.UPC,
		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
		Contract_Main.Contract_Main_ID, 
		Contract_Main.Contract_Number, 
		Contract_Main.Contract_Title,
		BB_Exclusion_TPA.Rate
FROM 		BB_Product_Exclusion
		INNER JOIN 	Billback_Product 
		ON
		(
			(Billback_Product.Billback_Product_ID = BB_Product_Exclusion.Billback_Product_ID)
		)
		INNER JOIN 	BSA_Foodservice_Items_Master 
		ON
		(
			BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
		)
		LEFT JOIN	BB_Exclusion_TPA
		ON
		(
			(BB_Exclusion_TPA.Product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID)
			AND
			(BB_Exclusion_TPA.Deleted = 0)
		)		
		LEFT JOIN	Contract_Main
		ON
		(
			Contract_Main.Contract_Main_ID = BB_Exclusion_TPA.Program_ID
		)
		LEFT JOIN	BSA_Foodservice_Customers
		ON
		(
			(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BB_Exclusion_TPA.Distributor_ID)
		)
WHERE
BB_Product_Exclusion.BB_Program_Exclusion_ID = '#BB_Program_Exclusion_ID#'
AND BB_Product_Exclusion.Deleted = 0
ORDER BY BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number
</cfquery>

<CFOUTPUT>
<TABLE width="98%" CLASS="MaintableTHEAD">
<TR>
<TD NOWRAP WIDTH="70">Program</TD>
<TD WIDTH="20">:</TD>
<TD NOWRAP WIDTH="100">[#GetProgramName.Contract_Number#]</TD>
<TD WIDTH="90%">#GetProgramName.Contract_Title#</TD>
</TR>
<TR>
<TD NOWRAP>Billback</TD>
<TD WIDTH="20">:</TD>
<TD NOWRAP>[#GetProgramName.BB_Code#]</TD>
<TD>#GetProgramName.BB_Title#</TD>
</TR>
<TR>
<TD NOWRAP>#application.returned_customer_setting.distributor_label_singular#</TD>
<TD WIDTH="20">:</TD>
<TD NOWRAP>#GetProgramName.Ship_To#</TD>
<TD>#GetProgramName.Name#</TD>
</TD>
</TR>
</TABLE>
</SPAN>
</CFOUTPUT>
<HR COLOR="Orange">

<span style="color: black; font-size: 12px; font-weight:bold;">click here to <a onclick="javaScript: toggleAllToSameStatus('inline');" style="cursor:pointer; color:red;"><font color="blue">[</font>show<font color="blue">]</font></a> or <a onclick="javaScript: toggleAllToSameStatus('none');" style="cursor:pointer; color:red;"><font color="blue">[</font>hide<font color="blue">]</font></a> the product rate breakdowns</span>
<cfset UOM = 2>
<table width="98%" border="0" cellpadding="2" cellspacing="0" class="MainTable" ID="TPA_TABLE">
	<CFOUTPUT>
	<tr bgcolor="FFCE84">
		<td>&nbsp;</td>
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
		<td width="50">#application.returned_customer_setting.upc_label#</td>
		</cfif></cfif>	
		<td width="70">#application.returned_customer_setting.item_label#</td>		
		<td width="300">Description</td>
		<td width="90">TPA / <cfif UOM IS 1>case<CFELSE>pound</CFIF></td>
		<td>Volume (pound)</td>
		<td>Volume (case)</td>
		<td align="center">Amount</td>
		<td>&nbsp;</td>
	</tr>
</CFOUTPUT>
<cfset ProductTotal = 0>
<CFSET counter = 0>
<CFOUTPUT query="GetProducts" GROUP="BSA_Foodservice_Items_Master_ID">
	<CFSET counter = counter + 1 >
	<!------
	<cfset UOM = GetProducts.BB_Product_UOM>
	UOM can be always in LB or always in Cases
	As TPA is stored in LB, we can show it in LB itself, unless otherwise requested
	-------->
	<CFSET TR_NAME_END=Replace(BSA_Foodservice_Items_Master_ID, "-", "_", "All")>
	<tr <CFIF counter mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> onclick="javaScript: toggleAllToSameStatus('', '#TR_NAME_END#');" style="cursor:pointer;">
		<td>&nbsp;</td>
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
		<td>#UPC#</td>
		</cfif></cfif>	
		<td>#Item#</td>		
		<td>#Left(Description, DESC_LEN)#</td>
		<td>#LSCurrencyFormat(TPA_LB)#</td>
		<td>#Quantity_LB#</td>
		<td>#Quantity_CS#</td>
		<td align="right">#LSCurrencyFormat(Dollar_Amount)#</td>
		<td>&nbsp;</td>
	</tr>
	<cfif Contract_Main_ID NEQ "">
		<tr id="#TR_ID_START#_#TR_NAME_END#" style="display:none;">
			<td></td>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
			<td></td>
			</cfif></cfif>
			<td bgcolor="000080" style="color:white;">Contract ##</td>
			<td bgcolor="000080" style="color:white;">Title</td>
			<td bgcolor="000080" style="color:white;">Rate / pound</td>
			<td colspan="4"></td>
		</tr>		
	<cfoutput>
		<tr id="#TR_ID_START#_#TR_NAME_END#" style="display:none;">
			<td></td>			
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
			<td></td>
			</cfif></cfif>
			<td CLASS="TPA_DESC">#Contract_Number#</td>
			<td CLASS="TPA_DESC">#Left(Contract_Title, DESC_LEN)#</td>
			<td CLASS="TPA_DESC">#LSCurrencyFormat(Rate)#</td>
			<td colspan="4"></td>
		</tr>	
	</cfoutput>
	</cfif>
	<cfif Dollar_Amount neq "" and IsNumeric(Dollar_Amount) >
		<cfset ProductTotal = ProductTotal + Dollar_Amount>
 	</cfif>
</CFOUTPUT>
<cfoutput>
<tr>
	<td align="Right" colspan="8" style="border-bottom:none;font-size:11px"><strong>Program Total:&nbsp; &nbsp; &nbsp;  #LSCurrencyFormat(ProductTotal)#</strong></td>
	<td style="border-bottom:none;">&nbsp; </td>
</tr>
</cfoutput>
</table>
<p></p>
<strong><font color="red">[</font> <A href="#" onclick="window.close()">Close</A> <font color="red">]</font></strong>
</div>


</body>
</html>