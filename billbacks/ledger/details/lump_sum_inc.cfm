
<cfquery name="GetLumpSumInfo" datasource="#application.datasource#">
SELECT Program_Lump_Sum_Name AS Lump_Sum_Name, Accrual_Log.Amount_Earned AS Lump_Sum_Amount 
FROM Accrual_Log
	INNER JOIN Program_Lump_Sums
	ON Program_Lump_Sums.Program_Lumps_Sum_Ext_Id = Accrual_Log.Program_Component_ID
	INNER JOIN Program_Lump_Sum_Name
	ON Program_Lump_Sums.Program_Lump_Sum_Name_ID = Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID
WHERE  Accrual_Log.Program_ID = #ContractID#
AND Accrual_Log.Deleted = 0
AND Accrual_Log.Discount_Type_ID = 3
AND Accrual_Log.Distributor_ID_Paid = '#DistributorNumber#'
</cfquery>

<cfset LumpSumCredit = 0>


<table width="99%" border="0" cellpadding="3" cellspacing="3" align="center" class="SubTable">

<Tr><td valign="top" width="50%">
<!---Lump sum credit--->



<cfif GetLumpSumInfo.Recordcount GT 0>
<table  WIDTH="100%" align="center"  border="0" CLASS="Maintable" cellspacing="0" cellpadding="2">
<tr>
<td valign="top"><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> Name:</td>
<td align="right" valign="top"><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> Amount:</td>
</tr>

<cfoutput query="GetLumpSumInfo">
 <TR VALIGN="top" <CFIF currentrow mod 2>BGCOLOR="#color3#"<CFELSE>BGCOLOR="white"</CFIF>>

		<TD valign="top" ALIGN="left">
#Lump_Sum_Name#<br></td><td align="right">
	#LSCurrencyFormat(Lump_Sum_Amount)#
	
	<cfset LumpSumCredit = LumpSumCredit + Lump_Sum_Amount>
</td></tr> 
</cfoutput>

</table>
<cfelse>
	No <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>
</cfif>
</td><td valign="top">

<!---End lump sum credit--->
<cfsilent>
<cfquery name="GetAllBillbacks" datasource="#application.datasource#">
SELECT DISTINCT Billback.Billback_ID, Billback.BB_Date, Billback.BB_Code
		FROM	
		Billback
		INNER JOIN	Billback_Program
		ON
		(
			(Billback_Program.Billback_ID = Billback.Billback_ID)
			AND
			(Billback_Program.Deleted = 0)
			AND Billback_Program.Program_ID IN (#preservesinglequotes(ContractMainList)#)
		)
		
		INNER JOIN	BB_Lump_Sums
		ON	
		(
			(BB_Lump_Sums.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(BB_Lump_Sums.Deleted = 0)
		)	
		
			INNER JOIN	Billback_Distributor			
			ON
			(
				(Billback_Distributor.Distributor_ID = '#DistributorNumber#')
				AND
				(Billback_Distributor.Billback_ID = Billback.Billback_ID)
				AND
				(Billback_Distributor.Deleted = 0)
			)			
		WHERE
		Billback.Deleted = 0		
		AND
		Billback.Billback_Status_ID >= 3 
</cfquery>
</cfsilent>

<table width="100%" cellpadding="2" cellspacing="0" border="0" class="Maintable">

<tr><td>&nbsp; &nbsp; Date:&nbsp; &nbsp;</td><td nowrap>Payable Number:</td><td>Billback Number:</td><td align="right">Total:</td></tr>
<cfif GetAllBillbacks.Recordcount GT 0>

<cfloop query="GetAllBillbacks">

<cfset useLakebaseForGetBBInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetBBInfo>
	<cftry>
		<cfset GetBBInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#GetAllBillbacks.Billback_ID#",
				"select" = "bb_title,bb_date,bb_code,bb_reference"
			}), "bb_title,bb_date,bb_code,bb_reference"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBBInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBBInfo>
<cfquery name="GetBBInfo" datasource="#application.datasource#">
	SELECT BB_Title, BB_Date, BB_Code, BB_Reference FROM Billback
	WHERE Billback_ID = '#GetAllBillbacks.Billback_ID#'
</cfquery>
</cfif>

<cfquery name="GetLS" datasource="#application.datasource#">
SELECT BB_Lump_Sums.LS_Paid_Amount, Contract_Title
FROM BB_Lump_Sums
	INNER JOIN Contract_Main
	ON Contract_Main.Contract_Main_ID = BB_Lump_Sums.Program_ID
WHERE BB_Lump_Sums.Billback_ID = '#Billback_ID#'
AND BB_Lump_Sums.Program_ID IN (#preservesinglequotes(ContractMainList)#)
AND BB_Lump_Sums.Deleted = 0
AND BB_Lump_Sums.LS_Paid_Amount IS NOT NULL
</cfquery>

<cfif GetLS.RecordCount GT 0>
		<cfoutput>
	
			<cfset LumpSumDebit = LumpSumDebit + GetLS.LS_Paid_Amount>
			
		<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF>><td>#DateFormat(GetBBInfo.BB_Date, 'MM/DD/YY')#&nbsp; &nbsp; &nbsp;</td> <Td >#GetBBInfo.BB_Code#&nbsp; &nbsp;</TD> <td>#GetBBInfo.BB_Reference#&nbsp; &nbsp;</td> <td align=right ><strong>#LSCurrencyFormat(GetLS.LS_Paid_Amount)#</strong></td></tr>

			</cfoutput>
	</cfif>

</cfloop>
	
</cfif>


<cfif GetAllBillbacks.recordcount EQ 0>
<Tr>
<td>&nbsp; </td>
<td>&nbsp; </td>
<td align="Right" valign="top" colspan="2">No billbacks found</td>
</TR>
</cfif> 

</table>


</td></tr>

</table>

