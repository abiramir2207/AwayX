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

<cfset Billback_ID = URL.Billback_ID>

<CFPARAM NAME="URL.Rate_Paid_Type" 	DEFAULT="">

<CFSWITCH EXPRESSION="#URL.Rate_Paid_Type#">
	<CFCASE VALUE="BB">
		<CFSET Volume_Field_LB = "Item_BB_Volume_LB">
		<CFSET Volume_Field_CS = "Item_BB_Volume_CS">
	</CFCASE>
	<CFCASE VALUE="E">
		<CFSET Volume_Field_LB = "Item_E_Volume_LB">
		<CFSET Volume_Field_CS = "Item_E_Volume_CS">
	</CFCASE>
	<CFCASE VALUE="A">
		<CFSET Volume_Field_LB = "Item_Volume_Approved_LB">
		<CFSET Volume_Field_CS = "Item_Volume_Approved_CS">
	</CFCASE>
	<CFDEFAULTCASE>
		<CFSET Volume_Field_LB = "0.00">
		<CFSET Volume_Field_CS = "0.00">
	</CFDEFAULTCASE>
</CFSWITCH>

<CFQUERY NAME="GetProducts" DATASOURCE="#application.datasource#">
		SELECT
		Contract_Main.Contract_Main_ID,
		Contract_Main.Contract_Title, 
		Contract_Main.Contract_Number,
		BB_Code,
		BB_Title,
		BSA_Foodservice_Customers.Name,
		BSA_Foodservice_Customers.Ship_to,
		IsNull(Program_Distributors_Trade_Rate.Rate, 0) AS TPA_LB,
		IsNull(Program_Distributors_Trade_Rate.Rate, 0) * CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT) AS TPA_CS,
		#Volume_Field_LB# AS Quantity_LB,
		#Volume_Field_CS# AS Quantity_CS,
		#Volume_Field_LB# * IsNull(Program_Distributors_Trade_Rate.Rate, 0) AS Dollar_Amount,
		Billback_Product.BB_Product_UOM,		 
		BSA_Foodservice_Items_Master.Description,
		BSA_Foodservice_Items_Master.Item,
		BSA_Foodservice_Items_Master.UPC,
		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
		Contract_Main.Contract_Main_ID, 		
		Contract_Main.Contract_Number, 
		Contract_Main.Contract_Title,		
		Program_Distributors_Trade.Rate,
		Trade_Contract.Contract_Title AS Trade_Contract_Title,
		Trade_Contract.Contract_Number AS Trade_Contract_Number
		FROM	Billback
		INNER JOIN	Billback_Distributor
		ON
		(
			(Billback_Distributor.Billback_ID = Billback.Billback_ID)
			AND
			(Billback.Billback_Payee_Type_ID = 1)
			AND
			(Billback_Distributor.Deleted = 0)
		)	
		INNER JOIN	Billback_Program
		ON
		(
			(Billback_Program.Billback_ID = Billback.Billback_ID)
			AND
			(Billback_Program.Deleted = 0)
		)
		INNER JOIN	Contract_Main
		ON
		(
			(Contract_Main.Contract_Number = (SELECT CM.Contract_Number FROM Contract_Main CM WHERE CM.Contract_Main_ID = Billback_Program.Program_ID))
			AND
			(Contract_Main.Contract_Status_Type_IDX IN (4,5,6))
		)
		INNER JOIN	Program_Control_Panel_Options
		ON
		(
			(Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID)
			AND
			(Program_Control_Panel_Options.Generic_Type IN ('Operator-Deviated Pricing', 'Bid Request'))
			AND
			(Program_Control_Panel_Options.Include_Trade = 0)
		)
		INNER JOIN	Billback_Product
		ON
		(
			(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(Billback_Product.Deleted = 0)
		)
		INNER JOIN	BSA_Foodservice_Items_Master
		ON
		(
			(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID)
			AND
			(BSA_Foodservice_Items_Master.Deleted = 0)
		)
		INNER JOIN	BB_Item_Final
		ON
		(
			(BB_Item_Final.Billback_ID = Billback.Billback_ID)
			AND
			(BB_Item_Final.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(BB_Item_Final.Billback_Product_ID = Billback_Product.Billback_Product_ID)
		)
		LEFT JOIN	Program_Distributors_Trade_Rate
		ON
		(
			(Program_Distributors_Trade_Rate.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID)
			AND
			(Program_Distributors_Trade_Rate.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID)
			AND
			(Program_Distributors_Trade_Rate.Deleted = 0)
		)
		RIGHT JOIN	Program_Distributors_Trade
		ON
		(
			(Program_Distributors_Trade.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID)
			AND
			(Program_Distributors_Trade.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID)
			AND
			(Program_Distributors_Trade.Deleted = 0)
		)
		LEFT JOIN Contract_Main Trade_Contract
		ON
		(
			Trade_Contract.Contract_Main_ID = Program_Distributors_Trade.Contract_Main_ID
		)
		INNER JOIN	BSA_Foodservice_Customers
		ON
		(
			(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID)
		)
	WHERE
		Billback.Deleted = 0
		AND
		Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	ORDER BY Contract_Main.Contract_Main_ID, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
</CFQUERY>


<CFOUTPUT>
<TABLE width="98%" CLASS="MaintableTHEAD">
<TR>
<TD NOWRAP>Billback</TD>
<TD WIDTH="20">:</TD>
<TD NOWRAP>[#GetProducts.BB_Code#]</TD>
<TD>#GetProducts.BB_Title#</TD>
</TR>
<TR>
<TD NOWRAP>#application.returned_customer_setting.distributor_label_singular#</TD>
<TD WIDTH="20">:</TD>
<TD NOWRAP>#GetProducts.Ship_To#</TD>
<TD>#GetProducts.Name#</TD>
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
	<tr bgcolor="FFCE84" VALIGN="top">
		<td width="20">Program</td>
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
		<td width="50">#application.returned_customer_setting.upc_label#</td>
		</cfif></cfif>	
		<td width="70">#application.returned_customer_setting.item_label#</td>		
		<td width="300">Description</td>
		<td width="90">TPA / <cfif UOM IS 1>case<CFELSE>pound</CFIF></td>
		<td>Volume (lb)</td>
		<td>Volume (cs)</td>
		<td align="center">Amount</td>
		<td>&nbsp;</td>
	</tr>
</CFOUTPUT>
<cfset ProductTotal = 0>
<CFSET counter = 0>
<CFOUTPUT query="GetProducts" GROUP="Contract_Main_ID">
	<TR BGCOLOR="FFEBCD">
		<TD COLSPAN="100%">[#Contract_Number#] #Contract_Title#</TD>
	</TR>
	<CFOUTPUT GROUP="BSA_Foodservice_Items_Master_ID">
	<CFSET counter = counter + 1 >
	<!------
	<cfset UOM = GetProducts.BB_Product_UOM>
	UOM can be always in LB or always in Cases
	As TPA is stored in LB, we can show it in LB itself, unless otherwise requested
	-------->
	<CFSET TR_NAME_END="#Contract_Main_ID##Replace(BSA_Foodservice_Items_Master_ID, "-", "_", "All")#">
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
			<td CLASS="TPA_DESC">#Trade_Contract_Number#</td>
			<td CLASS="TPA_DESC">#Left(Trade_Contract_Title, DESC_LEN)#</td>
			<td CLASS="TPA_DESC">#LSCurrencyFormat(Rate)#</td>
			<td colspan="4"></td>
		</tr>	
	</cfoutput>
	</cfif>
	<cfset ProductTotal = ProductTotal + Dollar_Amount>
	</CFOUTPUT>
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