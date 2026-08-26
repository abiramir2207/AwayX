<cfparam name="form.File" default="">


<cfquery name="GetOperatorInfo" datasource="#application.datasource#">
	SELECT Operator_Name
	FROM BSA_Operator
	WHERE BSA_Operator_ID = '#form.operatorid#'
</cfquery>

	<CFSTOREDPROC PROCEDURE="GET_USDANOI_PRICE" DATASOURCE="#application.datasource#">
			<cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="@@BSA_Foodservice_Items_Master_ID" value="#form.productid#" null="No">
			<cfprocparam type = "OUT" VARIABLE="USDA_FinalPrice" dbVarName = "@@USDA_Price" CFSQLType="CF_SQL_FLOAT">
			<cfprocparam type = "OUT" VARIABLE="USDA_UOM" dbVarName = "@@UOM" CFSQLType="CF_SQL_INTEGER">
	</CFSTOREDPROC>
	<CFSET aCompVal = USDA_FinalPrice>
	<CFSET aCompValUOM = USDA_UOM>
	
	
	<cfquery name="getProductInfo" datasource="#application.datasource#">
		SELECT Net_Weight, item, description
		FROM BSA_Foodservice_Items_Master
		WHERE BSA_Foodservice_Items_Master_ID = '#form.productid#'
	</cfquery>

<cfquery name="GetBBs" datasource="#application.datasource#">
SELECT     dbo.BB_Item_Final.Item_Volume_Paid_CS, dbo.BB_Approved.Date_Approved, dbo.Billback.Billback_ID, dbo.Billback.BB_Title, 
                      dbo.Billback.BB_Reference, ISNULL(dbo.Program_Product_Volume.Volume_CS,0) AS Volume_CS, dbo.BSA_Foodservice_Customers.Name AS Distributor_Name, dbo.Billback.Billback_Payee_Type_ID
,
	(
	SELECT ISNULL(SUM(Item_Volume_Paid_CS),0)
	FROM         dbo.Billback INNER JOIN
                      dbo.Billback_Program  ON dbo.Billback.Billback_ID = dbo.Billback_Program.Billback_ID INNER JOIN
                      dbo.Billback_Product ON dbo.Billback.Billback_ID = dbo.Billback_Product.Billback_ID INNER JOIN
                      dbo.BB_Item_Final ON dbo.Billback_Product.Billback_Product_ID = dbo.BB_Item_Final.Billback_Product_ID INNER JOIN
                      dbo.BB_Approved D ON dbo.Billback.Billback_ID = D.Billback_ID
	WHERE   
			(dbo.Billback.Billback_Status_ID >= 3) AND (dbo.Billback_Program.Program_ID = #form.programid#) 
AND (dbo.Billback_Product.Product_ID =  '#form.productid#')
			AND D.Date_Approved <= dbo.BB_Approved.Date_Approved 


	) AS RunningBBTotal,

(SELECT ISNULL(dbo.Program_Product_Volume.Volume_CS,0) - (
	SELECT ISNULL(SUM(Item_Volume_Paid_CS),0)
	FROM         dbo.Billback INNER JOIN
                      dbo.Billback_Program  ON dbo.Billback.Billback_ID = dbo.Billback_Program.Billback_ID INNER JOIN
                      dbo.Billback_Product ON dbo.Billback.Billback_ID = dbo.Billback_Product.Billback_ID INNER JOIN
                      dbo.BB_Item_Final ON dbo.Billback_Product.Billback_Product_ID = dbo.BB_Item_Final.Billback_Product_ID INNER JOIN
                      dbo.BB_Approved F ON dbo.Billback.Billback_ID = F.Billback_ID
	WHERE   
			(dbo.Billback.Billback_Status_ID >= 3) AND (dbo.Billback_Program.Program_ID = #form.programid#) 
AND (dbo.Billback_Product.Product_ID =  '#form.productid#')
			AND F.Date_Approved <= dbo.BB_Approved.Date_Approved 


	)) AS Balance
					  
FROM         dbo.Billback INNER JOIN
                      dbo.Billback_Program ON dbo.Billback.Billback_ID = dbo.Billback_Program.Billback_ID INNER JOIN
                      dbo.Billback_Product ON dbo.Billback.Billback_ID = dbo.Billback_Product.Billback_ID INNER JOIN
                      dbo.BB_Item_Final ON dbo.Billback_Product.Billback_Product_ID = dbo.BB_Item_Final.Billback_Product_ID INNER JOIN
                      dbo.BB_Approved ON dbo.Billback.Billback_ID = dbo.BB_Approved.Billback_ID INNER JOIN
                      dbo.Program_Product_Volume ON dbo.Billback_Product.Product_ID = dbo.Program_Product_Volume.BSA_Foodservice_Items_Master_ID AND 
                      dbo.Billback_Program.Program_ID = dbo.Program_Product_Volume.Program_ID INNER JOIN
                      dbo.Billback_Distributor ON dbo.Billback.Billback_ID = dbo.Billback_Distributor.Billback_ID INNER JOIN
                      dbo.BSA_Foodservice_Customers ON 
                      dbo.Billback_Distributor.Distributor_ID = dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
WHERE     (dbo.Billback.Billback_Status_ID >= 3) AND (dbo.Billback_Program.Program_ID = #form.programid#) AND 
                      (dbo.Billback_Product.Product_ID = '#form.productid#') AND dbo.Program_Product_Volume.deleted = 0
ORDER BY dbo.BB_Approved.Date_Approved
</cfquery>

<CFIF GetBBs.recordcount GT 0>
<cfquery name="GetStartVolume" datasource="#application.datasource#">
SELECT     ISNULL(Volume_CS, 0) AS Volume_CS
FROM         dbo.Program_Product_Volume
WHERE     (BSA_Foodservice_Items_Master_ID = '#form.productid#') AND (Program_ID = #form.programid#)
</cfquery>

<cfquery name="GetProgramDateSpan" datasource="#application.datasource#">
	SELECT dbo.ProgramDateSpanWeeks(#form.programid#) as ProgramSpanWeeksResult
</cfquery>

<cfquery name="getProgramSpan" datasource="#application.datasource#">

	SELECT dbo.ProgramDateSpanWeeks(#form.programid#)+1 AS ProgramDateSpanInWeeks,
	dbo.ProgramDateSpanDays(#form.programid#)+1 AS ProgramDateSpanInDays

</cfquery>


		<cfset d = USDA_FinalPrice>
		<cfif getProgramSpan.ProgramDateSpanInDays GT 0>
		<cfset TotalVolume = (GetStartVolume.Volume_CS * getProgramSpan.ProgramDateSpanInDays) / 7>
		<cfset TotalVolume = trim(numberformat(TotalVolume, '_________._'))>
			<cfif USDA_UOM EQ 2>
			<!--- Pound --->
			<cfset d = getProductInfo.net_weight * d>
			</cfif>
		<cfelse>
		<CFSET TotalVolume = getNOIProducts.Volume_CS>	
		</cfif>

</CFIF>

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>BSA Foods/Lamb-Weston</title>
</head>
<body>
<cfoutput>
<p><b><font size="4">#application.companyname#</font></b> <br>
#GetOperatorInfo.Operator_Name# <br>
Commodity NOI Performance Report <br>
#getProductInfo.Item# - #getProductInfo.description#
</p>
</cfoutput>

<bR>


<CFIF GetBBs.recordcount GT 0>

<table align="center" border="0" cellpadding="3" width="90%" bgcolor="#C0C0C0" cellspacing="1" >
	<cfinclude template="selReportUOM_tblrow.cfm">
	<tr>
		<td colspan="100%" bgcolor="#FFFFFF">
		<p><b>Pass Through Value Per <cfif USDA_UOM EQ 2>Pound<cfelse>Case</cfif> = $<cfoutput>#trim(numberformat(aCompVal, '___,___,___.__'))#</cfoutput> </b></p>
		</td>
	</tr>
	<tr>
		<td colspan="2" bgcolor="#FFFFFF" >&nbsp;</td>
		<td colspan="6" bgcolor="#FFFFFF" >
		<p align="center" ><b>Measured in Cases</b></td>
		<td bgcolor="#FFFFFF" >&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2" bgcolor="#FFFFFF" >
		<p align="center" ><b>Transaction Detail</b></td>
		<td colspan="3" bgcolor="#FFFFFF" >
		<p align="center" ><b>Allocation of Commodity</b></td>
		<td colspan="2" bgcolor="#FFFFFF" >
		<p align="center" ><b>Use of Commodity</b></td>
		<td bgcolor="#FFFFFF" >
		<b>Ending</b></td>
		<td bgcolor="#FFFFFF" >
		<b>Value</b></td>
	</tr>
	<tr>
		<td bgcolor="#FFFFFF" >
		<b>Date</b></td>
		<td bgcolor="#FFFFFF" >
		<b>Ref. #</b></td>
		<td bgcolor="#FFFFFF" >
		<b>Beginning</b></td>
		<td bgcolor="#FFFFFF" >
		<b>Current</b></td>
		<td bgcolor="#FFFFFF" >
		<b>Cumulative</b></td>
		<td bgcolor="#FFFFFF" >
		<b>Current</b></td>
		<td bgcolor="#FFFFFF" >
		<b>Cumulative</b></td>
		<td bgcolor="#FFFFFF" >
		<b>Balance</b></td>
		<td bgcolor="#FFFFFF" >
		<b>Available</b></td>
	</tr>
	<cfset THISCURRENTROW  = 1>
	<cfloop query="GetBBs">
		<cfquery name="getPayee" datasource="#application.datasource#">
			<cfswitch expression="">
				<cfcase value="1"><!--- Dstributor --->
SELECT     dbo.BSA_Foodservice_Customers.Name AS Payee_Name
FROM         dbo.Billback_Distributor INNER JOIN
                      dbo.BSA_Foodservice_Customers ON 
                      dbo.Billback_Distributor.Distributor_ID = dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
WHERE dbo.Billback_Distributor.Billback_ID = '#GetBBs.Billback_ID#' AND Deleted = 0
				</cfcase>
				<cfcase value="2"><!--- Operator --->
SELECT     dbo.BSA_Operator.Operator_Name AS Payee_Name
FROM         dbo.Billback_Operator INNER JOIN
                      dbo.BSA_Operator ON dbo.Billback_Operator.Operator_ID = dbo.BSA_Operator.BSA_Operator_ID
WHERE     (dbo.Billback_Operator.Billback_ID = '#GetBBs.Billback_ID#') AND (dbo.Billback_Operator.Deleted = 0)				
				</cfcase>
				<cfcase value="3"><!--- Broker --->
SELECT     dbo.BSA_Foodservice_Brokers.Broker_Name AS Payee_Name
FROM         dbo.BSA_Foodservice_Brokers INNER JOIN
                      dbo.Billback_Broker ON dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = dbo.Billback_Broker.Broker_ID
WHERE     (dbo.Billback_Broker.Billback_ID = '#GetBBs.Billback_ID#') AND (dbo.Billback_Broker.Deleted = 0)				
				</cfcase>
				
				<cfdefaultcase><!--- unknown --->
					
				</cfdefaultcase>
			</cfswitch>
		</cfquery>
	<cfoutput>
	<tr bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>White</CFIF>">
		<td nowrap>
		<a href="/billbacks/capture/INDEX.CFM?bbid=#GetBBs.Billback_ID#">#GetBBs.BB_Title# (#getPayee.Payee_Name#)</a></td>
		<td>
		<a href="/billbacks/capture/INDEX.CFM?bbid=#GetBBs.Billback_ID#">#GetBBs.BB_Reference#</a></td>
		<td align="left" x:num="5000">
		#trim(numberformat(TotalVolume, '___,___,___'))#
		</td>
		<td align="left" x:num="0">
		0</td>
		<td align="left" x:num="5000" x:fmla="=E4+C5+D5">
		<cfset c = trim(numberformat(TotalVolume, '_________'))>
		#trim(numberformat(TotalVolume, '___,___,___'))#
		</td>
		<td align="left" x:num="500">
		#trim(numberformat(GetBBs.Item_Volume_Paid_CS, '___,___,___'))#
		</td>
		<td align="left" x:num="500" x:fmla="=F5">
		<cfset e = trim(numberformat(GetBBs.RunningBBTotal, '_________'))>
		#trim(numberformat(GetBBs.RunningBBTotal, '___,___,___'))#
		</td>
		<td align="left" x:num="4500" x:fmla="=E5-G5">
		<CFSET f = c-e>
		#trim(numberformat(f, '___,___,___'))#</td>
		<td align="left" x:num="22860">
		<cfset g = f * d>
		$#trim(numberformat(g, '___,___,___.__'))# </td>
		</cfoutput>
	</tr>
	<cfset THISCURRENTROW  = THISCURRENTROW + 1>
	</cfloop>
	
</table>
<cfelse>
<div align="center" style="font-weight:bold; color: red; font-size: 20px;">There are not yet any associated billbacks.</div>
</cfif>

<br>
<cfset nextlocation = "search_action.cfm?operator=#form.operatorid#&programid=#form.programid#">

<table align="center">
	<tr bgcolor="#ffffff">
		<td align="right" style="cursor: hand;" onclick="history.back();"><b><font color="#FF0000">[</font> 
		<font color="#0000FF">return to previous screen</font>
		<font color="#FF0000">]</font></b></td>
		<td>&nbsp;</td>
		<td align="right">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>		
</table>

</body>

</html>


