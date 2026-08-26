<cfsilent>
<cfquery name="GetAllBillbacks" datasource="#application.datasource#">
SELECT DISTINCT Billback_ID, BB_Date
FROM BB_Program_Paid
WHERE Distributor_ID = '#DistributorNumber#'
AND Program_ID IN (#preservesinglequotes(ContractMainList)#)
AND BB_Product_Type_ID = #Billback_Type#
AND Billback_Status_ID >= 3
ORDER BY BB_Date DESC
</cfquery>
</cfsilent>
<cfset Debit = 0>
<table border="0"  CLASS="SubTable" cellspacing="0" cellpadding="1" width="100%">

<tr>
<td valign="top" style="border-bottom:solid #93BEE2 1px;">Date: </td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" nowrap>Payable Number:</td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" nowrap>Billback Number:</td>
<td valign="top" align="right" style="border-bottom:solid #93BEE2 1px;" nowrap>Billback Amount:</td>
</tr>

<cfloop query="GetAllBillbacks">
	<cfsilent>
	<cfquery name="GetBBInfo" datasource="#application.datasource#">
	SELECT BB_Title, BB_Date, BB_Code, BB_Reference FROM Billback
	WHERE Billback_ID = '#Billback_ID#'
	</cfquery>
	
	<cfset BB_Reference = GetBBInfo.BB_Reference>
	
	<cfquery name="GetBBTotalPaid" datasource="#application.datasource#">
	SELECT ISNULL(SUM(BB_Item_Final_Detail.Paid_Rate_CS * BB_Item_Final.Item_Volume_Paid_CS), 0) AS TotalPaid
	FROM BB_Item_Final
		INNER JOIN BB_Item_Final_Detail 
		ON BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID
		AND BB_Item_Final_Detail.BB_Product_Type = #Billback_Type#
		AND BB_Item_Final_Detail.Deleted = 0
	WHERE BB_Item_Final.Billback_ID = '#Billback_ID#'
	AND BB_Item_Final.Deleted = 0
	</cfquery>

	
	<cfset Debit = Debit + GetBBTotalPAid.TotalPaid>
	</cfsilent>
<cfoutput>
<tr>
		<td colspan="4" valign="top">
<cfsilent>
		<cfif UOM IS 1>
		<cfquery name="GetItemsForBillback" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Items_Master.Description, 
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					BB_Item_Final_Detail.Paid_Rate_CS AS Item_Rate_Paid, 
					BB_Item_Final.Item_Volume_Paid_CS AS Item_Volume_Paid
			FROM BB_Item_Final 
			INNER JOIN BB_Item_Final_Detail 
				ON BB_Item_Final.BB_Item_Final_ID = BB_Item_Final_Detail.BB_Item_Final_ID 
				AND BB_Item_Final_Detail.BB_Product_Type = #Billback_Type#
				AND BB_Item_Final_Detail.Deleted = 0 
			INNER JOIN Billback_Product
				ON Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID
				AND Billback_Product.Deleted = 0
			INNER JOIN BSA_Foodservice_Items_Master 
				ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID =
				Billback_Product.Product_ID 
				AND BSA_Foodservice_Items_Master.Deleted = 0 
			WHERE BB_Item_Final.Billback_ID = '#Billback_ID#' 
			AND BB_Item_Final_Detail.Paid_Rate_CS IS NOT NULL 
			AND BB_Item_Final.Item_Volume_Paid_CS IS NOT NULL 
			ORDER BY BSA_Foodservice_Items_Master.Description
			</cfquery>
		<cfelse>
			<cfquery name="GetItemsForBillback" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Items_Master.Description, 
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					BB_Item_Final_Detail.Paid_Rate_LB AS Item_Rate_Paid, 
					BB_Item_Final.Item_Volume_Paid_LB AS Item_Volume_Paid
			FROM BB_Item_Final 
			INNER JOIN BB_Item_Final_Detail 
				ON BB_Item_Final.BB_Item_Final_ID = BB_Item_Final_Detail.BB_Item_Final_ID 
				AND BB_Item_Final_Detail.BB_Product_Type = #Billback_Type#
				AND BB_Item_Final_Detail.Deleted = 0 
			INNER JOIN Billback_Product
				ON Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID
				AND Billback_Product.Deleted = 0
			INNER JOIN BSA_Foodservice_Items_Master 
				ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID =
				Billback_Product.Product_ID 
				AND BSA_Foodservice_Items_Master.Deleted = 0 
			WHERE BB_Item_Final.Billback_ID = '#Billback_ID#' 
			AND BB_Item_Final_Detail.Paid_Rate_LB IS NOT NULL  
			AND BB_Item_Final.Item_Volume_Paid_LB IS NOT NULL 
			ORDER BY BSA_Foodservice_Items_Master.Description
			</cfquery>
		</cfif>
</cfsilent>
		
		<cfif GetItemsForBillback.Recordcount GT 0>
		<cfif ShowDetails IS 0>
		
		
		<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"  
			BorderColor="#BorderColor#"  
			Image=""
			ImageOpen=""
			Title="<table width=100% bgcolor=#color2# cellpadding=0 cellspacing=0><tr><td>#DateFormat(BB_Date, 'MM/DD/YY')#&nbsp; &nbsp; &nbsp;</td> <Td>#GetBBInfo.BB_Code#&nbsp; &nbsp;</TD> <td>#ReplaceList(BB_Reference, "#chr(34)#,\", "&quot;,\")#&nbsp; &nbsp;</td> <td align=right><strong>#LSCurrencyFormat(GetBBTotalPAid.TotalPaid)#</strong></td></tr></table>"   
			TitleClosed="<table width=100% cellpadding=0 cellspacing=0 bgcolor=#color2#><tr><td>#DateFormat(BB_Date, 'MM/DD/YY')#&nbsp; &nbsp; &nbsp;</td> <Td>#GetBBInfo.BB_Code#&nbsp; &nbsp;</TD> <td>#ReplaceList(BB_Reference, "#chr(34)#,\", "&quot;,\")#&nbsp; &nbsp;</td> <td align=right><strong>#LSCurrencyFormat(GetBBTotalPaid.TotalPaid)#</strong></td></tr></table>" 
			TitleTooltip="Click here to toggle the view"  
			TitleColor="#TitleColor#"  
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="100%"
			Color="">	
		
		<div align="right">
		<table class="Maintable" width="95%" border="0" cellpadding="1" cellspacing="0" bgcolor="white">
		<tr><td style="border-bottom:solid ##93BEE2 1px;">Product:</td><td style="border-bottom:solid ##93BEE2 1px;" align="right">Quantity in <cfif UOM IS 1> Cs<cfelse> Lbs</cfif>:</td><td align="right" style="border-bottom:solid ##93BEE2 1px;">$&nbsp;Amount:</td></tr>
		
		
		
			<cfloop query="GetItemsForBillback">		
			
			<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF> <cfif CalledFrom IS NOT "Scheduled">onclick="NewWindow('/profiles/Products/Product_profile.cfm?PID=#GetItemsForBillback.BSA_Foodservice_Items_Master_ID#','name','400','450','Yes', 'No');return false;" NOWRAP style="cursor:pointer;"</cfif> >
		<td valign="top" >#left(GetItemsForBillback.Description, 30)#</td>
		<td valign="top" align="right"> #NumberFormat(GetItemsForBillback.Item_Volume_Paid, '___,___,___,___')#</td>
		<td valign="top" align="right">#LSCurrencyFormat(GetItemsForBillback.Item_Volume_Paid * GetItemsForBillback.Item_Rate_Paid)#</td>
			</tr>
			
			</cfloop> 
		</table></div>
		</cf_openlayer>
		
		<cfelse>
		
		
			<div align="right">
			<table width="100%" bgcolor="#color2#" cellpadding=0 cellspacing=0><tr><td>#DateFormat(BB_Date, 'MM/DD/YY')#&nbsp; &nbsp; &nbsp;</td> <Td>#GetBBInfo.BB_Code#&nbsp; &nbsp;</TD> <td>#BB_Reference#&nbsp; &nbsp;</td> <td align=right><strong>#LSCurrencyFormat(GetBBTotalPaid.TotalPaid)#</strong></td></tr></table>
		<table class="Maintable" border="0" cellpadding="1" cellspacing="0" bgcolor="white" width="95%">

		<tr><td style="border-bottom:solid ##93BEE2 1px;">Product:</td><td style="border-bottom:solid ##93BEE2 1px;" nowrap align="right">Quantity in <cfif UOM IS 1> Cs<cfelse> Lbs</cfif>:</td><td align="right" style="border-bottom:solid ##93BEE2 1px;">$&nbsp;Amount:</td></tr>
		
		 	<cfloop query="GetItemsForBillback">		
			
			<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF> onclick="NewWindow('/profiles/Products/Product_profile.cfm?PID=#GetItemsForBillback.BSA_Foodservice_Items_Master_ID#','name','400','450','Yes', 'No');return false;" NOWRAP style="cursor:pointer;" >
		<td valign="top" >#left(GetItemsForBillback.Description, 30)#</td>
		<td valign="top" align="right"> #NumberFormat(GetItemsForBillback.Item_Volume_Paid, '___,___,___,___')#</td>
		<td valign="top" align="right">#LSCurrencyFormat(GetItemsForBillback.Item_Volume_Paid * GetItemsForBillback.Item_Rate_Paid)#</td>
			</tr>
			
			</cfloop>  
		</table></div>
		</cfif>
		</cfif>
		</td>
	</tr>
</cfoutput>
</cfloop>


<cfif GetAllBillbacks.recordcount EQ 0>
<Tr>
<td>&nbsp; </td>
<td>&nbsp; </td>
<td align="Right" colspan="2">No billbacks found</td>
</TR>
</cfif> 



<!---

	<cfquery name="GetOneBillback" datasource="#application.datasource#">
	SELECT
	
	WHERE BB_Item_Final.Billback_Program_ID IN (#preservesinglequotes(ProgramNumber)#)
	AND BB_Item_Final_Detail.BB_Product_Type = #Billback_Type#
	AND BB_Item_Final.Billback_ID = '#Billback_ID#'
	
	SELECT BB_Rate, Billback_Product_Detail_ID
	FROM BB_Program_Paid 
	WHERE Program_ID IN (#preservesinglequotes(ProgramNumber)#)
	AND BB_Product_Type_ID = #Billback_Type#
	AND Billback_ID = '#Billback_ID#'
	</cfquery>
	
	<cfquery name="GetBBPaid" datasource="#application.datasource#">
	SELECT SUM(Item_Total_Paid) AS TotalPaid
	FROM BB_Item_Final
	WHERE Billback_ID = '#GetAllBillbacks.Billback_ID#'
	</cfquery>
	
		<cfset Debit = Debit + GetBBPaid + TotalPaid>
	
	<cfquery name="GetBBInfo" datasource="#application.datasource#">
	SELECT BB_Title, BB_Date, BB_Code, BB_Reference FROM Billback
	WHERE Billback_ID = '#Billback_ID#'
	</cfquery>
	
	<cfset BB_Reference = GetBBInfo.BB_Reference>
		
	<cfoutput>
	<tr>
		<td colspan="4" valign="top">

		<cfif ShowDetails IS 0>
		<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"  
			BorderColor="#BorderColor#"  
			Image=""
			ImageOpen=""
			Title="<table width=100% bgcolor=#color2# cellpadding=0 cellspacing=0><tr><td>#DateFormat(BB_Date, 'MM/DD/YY')#&nbsp; &nbsp; &nbsp;</td> <Td>#GetBBInfo.BB_Code#&nbsp; &nbsp;</TD> <td>#BB_Reference#&nbsp; &nbsp;</td> <td align=right><strong>#LSCurrencyFormat(TotalRateForBB)#</strong></td></tr></table>"   
			TitleClosed="<table width=100% cellpadding=0 cellspacing=0 bgcolor=#color2#><tr><td>#DateFormat(BB_Date, 'MM/DD/YY')#&nbsp; &nbsp; &nbsp;</td> <Td>#GetBBInfo.BB_Code#&nbsp; &nbsp;</TD> <td>#BB_Reference#&nbsp; &nbsp;</td> <td align=right><strong>#LSCurrencyFormat(TotalRateForBB)#</strong></td></tr></table>" 
			TitleTooltip="Click here to toggle the view"  
			TitleColor="#TitleColor#"  
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="100%"
			Color="">	
		
		<div align="right">
		<table class="Maintable" width="95%" border="0" cellpadding="1" cellspacing="0" bgcolor="white">
		<tr><td style="border-bottom:solid ##93BEE2 1px;">Product:</td><td style="border-bottom:solid ##93BEE2 1px;" align="right">Quantity in <cfif UOM IS 1> Cs<cfelse> Lbs</cfif>:</td><td align="right" style="border-bottom:solid ##93BEE2 1px;">$&nbsp;Amount:</td></tr>
		
			<cfloop query="GetOneBillback">
				<cfquery name="ProductDetail" datasource="#application.datasource#">
				SELECT BSA_Foodservice_Items_Master.Description,
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
				Billback_Product_Detail.BB_Rate, 
				Billback_Product.BB_Product_Quantity
				FROM  Billback_Product_Detail
					INNER JOIN Billback_Product
					ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
						INNER JOIN BSA_Foodservice_Items_Master
						ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
				WHERE Billback_Product_Detail_ID = '#Billback_Product_Detail_ID#'
				</cfquery>
							
			
			<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF> onclick="NewWindow('/profiles/Products/Product_profile.cfm?PID=#ProductDetail.BSA_Foodservice_Items_Master_ID#','name','400','450','Yes', 'No');return false;" NOWRAP style="cursor:pointer;" >
		<td valign="top" nowrap>#left(ProductDetail.Description, 30)#</td>
		<td valign="top" align="right" nowrap>#NumberFormat(ProductDetail.BB_Product_Quantity, '___,___,___')#</td>
		<td valign="top" align="right" nowrap>#LSCurrencyFormat(ProductDetail.BB_Rate)#</td>
			</tr>
			
			</cfloop>
		</table></div>
		</cf_openlayer>
		<cfelse>
			<div align="right">
			<table width="100%" bgcolor="#color2#" cellpadding=0 cellspacing=0><tr><td>#DateFormat(BB_Date, 'MM/DD/YY')#&nbsp; &nbsp; &nbsp;</td> <Td>#GetBBInfo.BB_Code#&nbsp; &nbsp;</TD> <td>#BB_Reference#&nbsp; &nbsp;</td> <td align=right><strong>#LSCurrencyFormat(TotalRateForBB)#</strong></td></tr></table>
		<table class="Maintable" border="0" cellpadding="1" cellspacing="0" bgcolor="white" width="95%">

		<tr><td style="border-bottom:solid ##93BEE2 1px;">Product:</td><td style="border-bottom:solid ##93BEE2 1px;">Quantity in <cfif UOM IS 1> Cs<cfelse> Lbs</cfif>:</td><td align="right" style="border-bottom:solid ##93BEE2 1px;">$&nbsp;Amount:</td></tr>
			<cfloop query="GetOneBillback">
				<cfquery name="ProductDetail" datasource="#application.datasource#">
				SELECT BSA_Foodservice_Items_Master.Description,
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
				Billback_Product_Detail.BB_Rate, 
				Billback_Product.BB_Product_Quantity
				FROM  Billback_Product_Detail
					INNER JOIN Billback_Product
					ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
						INNER JOIN BSA_Foodservice_Items_Master
						ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
				WHERE Billback_Product_Detail_ID = '#Billback_Product_Detail_ID#'
				</cfquery>
							
			
			<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF> onclick="NewWindow('/profiles/Products/Product_profile.cfm?PID=#ProductDetail.BSA_Foodservice_Items_Master_ID#','name','400','450','Yes', 'No');return false;" NOWRAP style="cursor:pointer;" >
		<td valign="top" >#left(ProductDetail.Description, 30)#</td>
		<td valign="top" align="right"> #NumberFormat(ProductDetail.BB_Product_Quantity, '___,___,___,___')#</td>
		<td valign="top" align="right">#LSCurrencyFormat(ProductDetail.BB_Rate)#</td>
			</tr>
			
			</cfloop>
		</table></div>
		
		</cfif>
		</td>
	</tr>
	</cfoutput>
	
</cfloop>

--->