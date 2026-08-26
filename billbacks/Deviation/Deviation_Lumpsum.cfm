<CFSET Table_Width = 650>

<CFIF NOT IsDefined("INC_Deviation_Constants")>
	<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_Constants.CFM">
</CFIF>
<CFIF NOT IsDefined("INC_Date_Graph_Settings")>
	<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Date_Graph_Settings.cfm">
</CFIF>

<CFPARAM NAME="URL.Billback_Program_ID"								DEFAULT="">
<CFSET Billback_Program_ID=URL.Billback_Program_ID>
<CFPARAM NAME="SHOW_DEVIATION_DETAIL_HEADER" 	DEFAULT=True>
<CFPARAM NAME="SHOW_DEVIATION_DETAIL_FOOTER" 	DEFAULT=True>

<cfset BillbackDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
<cfset BillbackDeviationManager.setAppSettings(appSettings) />
<CFIF SHOW_DEVIATION_DETAIL_HEADER>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Billback <CFOUTPUT>#DEVIATION_LABEL# - #Application.LumpsumLabel#</CFOUTPUT> Amount</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<BLOCKQUOTE>


<STYLE>
TR.MaintableTHEAD TD
{
	font-size : 11px;
	border-bottom:solid 93BEE2 0px;
	font-weight : bold;
}
</STYLE>


<!------------------------------show spinner ---------------------------->

<CFSET PW_Type="1">
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<BR>
<CFELSE>
	<BLOCKQUOTE>
</CFIF>

<!---  only use cache when it is a billback detail  --->
<cfset variables.cachedWithin = (cgi.script_name contains "billback_detail.cfm" ? CreateTimeSpan(0, 1, 0, 0) : CreateTimeSpan(0, 0, 0, 0))>

<!--------------------------------------------------------------------------------------
Get Program , Product Info for display and fo rbeing used in other queries
--------------------------------------------------------------------------------------->
<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Product_Program">
SELECT  Billback.Billback_ID, Billback.BB_Start_Date, Billback.BB_End_Date, Billback.BB_Code, Billback.BB_Title
	, BB_Approved.Date_Approved
	, Billback_Distributor.Distributor_ID
	, Billback_Program.Program_ID
	,CASE
		WHEN Billback_Program.Program_ID IS NULL THEN
			Billback_Program.BB_Program_Number
		ELSE
			Contract_Main.Contract_Number
		END AS Contract_Number,
		CASE
		WHEN Billback_Program.Program_ID IS NULL THEN
			Billback_Program.BB_Program_Title
		ELSE
			Contract_Main.Contract_Title
		END AS Contract_Title
	, Billback_Program_Lumpsum_Component.Billback_Program_ID
	, Billback_Program_Lumpsum_Component_ID, ISNULL(Amount, 0) AS Amount
	,CASE
	WHEN Component_Type_ID = 1 THEN
		Program_Lump_Sum_Name.Program_Lump_Sum_Name
	WHEN Component_Type_ID = 3 THEN
		Program_Growth_Components.Component_Name + ' Tier ' + Program_Growth_Component_Tiers.Tier_Number
	ELSE
		Billback_Program_Lumpsum_Component.Name
	END AS Component_Name
	, (
			SELECT 	MIN(Approval_Start_Date)
			FROM 	BB_Program_Info
			WHERE
				BB_Program_Info.Contract_Number = Contract_Main.Contract_Number
				AND
				BB_Program_Info.Deleted = <cfqueryparam value=0>
			) AS Program_Start_Date
		, (
			SELECT 	MAX(Approval_End_Date)
			FROM 	BB_Program_Info
			WHERE
				BB_Program_Info.Contract_Number = Contract_Main.Contract_Number
				AND
				BB_Program_Info.Deleted = <cfqueryparam value=0>
			) AS Program_End_Date
		, 0 AS BB_Type
		, Program_Control_Panel_Options.Generic_Type
		, Program_Control_Panel_Options.Discount_Lump_Sums_Distributor_Mandated
		,
		(
		SELECT COUNT(*)
		FROM	Billback_Product
			INNER JOIN Billback_Product_Detail
			ON
			(	(Billback_Product_Detail.Billback_ID = Billback_Product.BillBack_Id)
				AND
				(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
				AND
				(Billback_Product_Detail.Deleted = 0)
				AND
				(Billback_Product_Detail.BB_Rate IS NOT NULL)
				AND
				(LEN(Billback_Product_Detail.BB_Rate) > 0)
				AND
				(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
				AND
				(CAST(Billback_Product_Detail.BB_Rate AS Float) > 0)
				AND
				(Billback_Product_Detail.BB_Product_Type_ID = 4)
			)
		WHERE
			(Billback_Product.Billback_ID = Billback_Program.BillBack_Id)
				AND
			Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID
			AND
			Billback_Product.Deleted = <cfqueryparam value=0>
		) AS Calculate_Growth_lumpsum
FROM    Billback_Program
	INNER JOIN	Billback
	ON
	(
		(Billback.Billback_ID = Billback_Program.Billback_ID)
		AND
		(Billback.Deleted = 0)
	)
	LEFT JOIN BB_Approved
	ON
	(
		(BB_Approved.Billback_ID = Billback.Billback_ID)
		AND
		(Billback.Billback_Status_ID >= 3)
	)
	LEFT JOIN	Billback_Program_Lumpsum_Component
	ON
	(
		(Billback_Program_Lumpsum_Component.Billback_Program_ID = Billback_Program.Billback_Program_ID)
		AND
		(Billback_Program_Lumpsum_Component.Deleted = 0)
		AND
		(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
		AND
		(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
		AND
		(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
		AND
		(CAST(Billback_Program_Lumpsum_Component.Amount AS Float) != 0)
	)
	LEFT JOIN Program_Growth_Components
	ON
	(
		Program_Growth_Components.Program_Growth_Component_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
	)
	LEFT JOIN Program_Growth_Component_Tiers
	ON
	(
		Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = Billback_Program_Lumpsum_Component.Program_Growth_Component_Tier_ID
	)
	LEFT JOIN	Billback_Distributor
	ON
	(
		(Billback_Distributor.Billback_ID = Billback.Billback_ID)
		AND
		(Billback.Billback_Payee_Type_ID = 1)
		AND
		(Billback_Distributor.Deleted = 0)
	)
	LEFT JOIN	Contract_Main
	ON
	(
		(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
	)
	LEFT JOIN	Program_Control_Panel_Options
	ON
	(
		(Program_Control_Panel_Options.ProgramControl_Panel_Options_ID  = Contract_Main.ProgramType_ID)
		--AND
		--(Program_Control_Panel_Options.Deleted = 0)
	)
	LEFT JOIN Program_Lump_Sums
	ON
	(
		(Program_Lump_Sums.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID)
	)
	LEFT JOIN Program_Lump_Sum_Name
					ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
WHERE
	Billback_Program.Billback_Program_ID = <cfqueryparam value='#Billback_Program_ID#'>
ORDER BY Component_Name

</CFQUERY>

<CFSET Billback_Start_Date 					= Billback_Product_Program.BB_Start_Date>
<CFSET Billback_End_Date 					= Billback_Product_Program.BB_End_Date>
<CFSET Contract_Number 						= Billback_Product_Program.Contract_Number>
<CFSET Program_Title 						= Billback_Product_Program.Contract_Title>
<CFSET BSA_Foodservice_Customers_ID 	= Billback_Product_Program.Distributor_ID>
<CFSET Billback_ID 							= Billback_Product_Program.Billback_ID>
<CFSET Date_Approved						= Billback_Product_Program.Date_Approved>
<CFSET Payable_Number 						= Billback_Product_Program.BB_Code>
<CFSET Billback_Title 						= Billback_Product_Program.BB_Title>
<CFSET Program_Start_Date 					= Billback_Product_Program.Program_Start_Date>
<CFSET Program_End_Date 					= Billback_Product_Program.Program_End_Date>
<CFSET Generic_Type 						= Billback_Product_Program.Generic_Type>
<CFSET Calculate_Growth_lumpsum				= Billback_Product_Program.Calculate_Growth_lumpsum>
<CFSET Billback_Program_Program_ID			= Billback_Product_Program.Program_ID>
<CFSET Discount_Lump_Sums_Distributor_Mandated = Billback_Product_Program.Discount_Lump_Sums_Distributor_Mandated>
<CFSET Contract_Main_ID						= Billback_Program_Program_ID>
<CFINCLUDE TEMPLATE="BB_Payee.cfm">

<!--------------------------------------------------------------------------------------
Display the Billback information
--------------------------------------------------------------------------------------->
<CFOUTPUT>


<CFSET Total_Billback_LumpSum = 0>
<CFSET Total_Expected_LumpSum = 0>
<CFSET Total_Program_LumpSum = 0>
<CFSET Total_Growth_LumpSum = 0>


<SPAN CLASS="Title2">Billback #Application.LumpsumLabel# Information</SPAN>
<HR COLOR="Orange">
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
	<CFIF Billback_Product_Program.recordCount GT 0>
		<TR BGCOLOR="FFFFFF" CLASS="MaintableTHEAD" STYLE="border-bottom:none">
			<TD COLSPAN="100%">
				<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#">
					<TR ALIGN="LEFT">
						<TD>Billback</TD>
						<TD>[#Payable_Number#]</TD>
						<TD WIDTH="80%">#Billback_Title#</TD>
					</TR>
					<TR ALIGN="LEFT">
						<TD>Program</TD>
						<TD NOWRAP>[#Contract_Number#]</TD>
						<TD>#Program_Title#
						<CFIF Billback_Program_Program_ID EQ "">
						#DEVIATION_SHOW_PNF#
						</CFIF>
						</TD>
					</TR>
				</TABLE>
			</TD>
		</TR>
		<TR BGCOLOR="FFCE84" CLASS="MaintableTHEAD" STYLE="border-bottom:solid 93BEE2 1px;">
			<TD WIDTH="30">&nbsp;</TD>
			<TD>Component</TD>
			<TD>Amount</TD>
			<TD WIDTH="30">&nbsp;</TD>
		</TR>
		<CFLOOP QUERY="Billback_Product_Program">
		<CFSET Total_Billback_LumpSum = Total_Billback_LumpSum + Billback_Product_Program.Amount>
		<TR>
			<TD>&nbsp;</TD>
			<TD>#Billback_Product_Program.Component_Name#</TD>
			<TD>#DollarFormat(Billback_Product_Program.Amount)#</TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFLOOP>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%">
			Total Billback #Application.LumpsumLabel# Amount (&##931; Amount) = #DollarFormat(Total_Billback_LumpSum)#
			</TD>
		</TR>
	<CFELSE>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%"><B><FONT COLOR="Red">No Component found</FONT></B></TD>
		</TR>
	</CFIF>
</TABLE>

<BR>
<SPAN CLASS="Title2">Expected #Application.LumpsumLabel# Amount Calculation</SPAN>
<HR COLOR="Orange">
<TABLE CELLPADDING="1" CELLSPACING="3" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" BGCOLOR="FFFFFF">
<TR>
<TD BGCOLOR="WhiteSmoke">
<!------------------------------------------------------------
Step 1: Find Lumpsum Dates to find out which program to pick
------------------------------------------------------------->
<CFIF DATEDIFF("d", Program_End_Date, Billback_End_Date) GTE 0>
	<CFSET Lumpsum_End_Date = Program_End_Date>
<CFELSE>
	<CFSET Lumpsum_End_Date = Billback_End_Date>
</CFIF>

<cfset payee_unauthorized = 0 />
<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Check_Payee_UnAuthorized">
	SELECT	Unauthorized_Payee
	FROM	BB_Program_Deviation_Info
	WHERE	BB_Program_Deviation_Info.Billback_Program_ID = <cfqueryparam value='#Billback_Program_ID#'>
	AND		BB_Program_Deviation_Info.Deleted = <cfqueryparam value=0>
</CFQUERY>
<cfif Check_Payee_UnAuthorized.recordCount>
	<cfif Check_Payee_UnAuthorized.Unauthorized_Payee neq 0>
		<cfset payee_unauthorized = 1 />
	</cfif>
</cfif>
<!----------------------------------------------------------------------------------
Lump sum
----------------------------------------------------------------------------------->
<cfif payee_unauthorized neq 0>
	<BR>
	<B><FONT COLOR="Red">This payee is not authorized to billback against this program</FONT></B>
	<BR><BR>
	</TD></TR></TABLE>
<cfelse><!--- payee us authorized - start --->
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
<CAPTION ALIGN="LEFT" STYLE="font-size:11px;color:blue;"><B>#Application.LumpsumLabel# Amount from program [#Contract_Number#] #Program_Title#</B></CAPTION>
<cfset BillbackPayeeType = BillbackDeviationManager.getBillbackPayeeType(Billback_ID) />
<cfif Discount_Lump_Sums_Distributor_Mandated EQ 0>
	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Program_lumpsum">
		SELECT	Program_Lump_Sum_Name.Program_Lump_Sum_Name AS Lump_Sum_Name, Program_Lump_Sums.Lump_Sum_Amount
		FROM	Contract_Main
				INNER JOIN	BB_Program_Info
				ON
				(
					(BB_Program_Info.Contract_Main_ID = Contract_Main.Contract_Main_ID)
					AND
					(BB_Program_Info.Deleted = 0)
					AND
					(DATEDIFF(d, Approval_Start_Date, #createodbcdate(Lumpsum_End_Date)#) >= 0)
					AND
					(DATEDIFF(d, #createodbcdate(Lumpsum_End_Date)#, Approval_End_Date) >= 0)
				)
				INNER JOIN	Program_Lump_Sums
				ON
				(
					(Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID)
					AND
					(Program_Lump_Sums.Deleted = 0)
				)
				<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBCheckPayTo()>
				AND 	(Program_Lump_Sums.Component_Paid_To = #BillbackPayeeType# OR (Program_Lump_Sums.Component_Paid_To = 4 AND #BillbackPayeeType# IN (1,2)))
				</cfif>
				<cfif appSettings.getClaims_at_Comp_Level()>
				<!---- Ana - D17239 - starting this label Lumpsum will work based on Name_ID instead og Comp_ID----->
				AND 	Program_Lump_Sums.Program_Lump_Sum_Name_ID IN
				(	SELECT		DISTINCT BB_Component_Program_Lump_Sums.Program_Lump_Sum_Name_ID
					FROM		Billback_Program_Lumpsum_Component
					INNER JOIN	Program_Lump_Sums as BB_Component_Program_Lump_Sums ON --claim component table
								Billback_Program_Lumpsum_Component.Billback_Program_ID = '#Billback_Program_ID#' AND
								Billback_Program_Lumpsum_Component.Deleted = 0 AND
								BB_Component_Program_Lump_Sums.Deleted = 0 AND
								BB_Component_Program_Lump_Sums.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
				)
				<!--- Ana - D17239 -- Commenting for this label. Details in the label -------
				INNER JOIN Billback_Program_Lumpsum_Component
				ON Billback_Program_Lumpsum_Component.Billback_Program_ID = '#Billback_Program_ID#'
				AND Billback_Program_Lumpsum_Component.Deleted = 0

				INNER JOIN  Program_Lump_Sums as BB_Component_Program_Lump_Sums --claim component table
				ON		BB_Component_Program_Lump_Sums.Deleted = 0
				AND 	BB_Component_Program_Lump_Sums.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
				AND 	Program_Lump_Sums.Program_Lump_Sum_Name_ID = BB_Component_Program_Lump_Sums.Program_Lump_Sum_Name_ID --->
				</cfif>
				<cfif Discount_Lump_Sums_Distributor_Mandated>
				INNER JOIN Program_Lump_Sum_Distributor
				ON 	Program_Lump_Sum_Distributor.Deleted = 0
				AND Program_Lump_Sum_Distributor.Program_ID = Program_Lump_Sums.Program_ID
				<cfif appSettings.getClaims_at_Comp_Level()>
				AND Program_Lump_Sum_Distributor.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
				</cfif>
				AND Program_Lump_Sum_Distributor.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
				<cfif Len(BSA_Foodservice_Customers_ID) GT 0>
				AND Program_Lump_Sum_Distributor.Distributor_ID = '#BSA_Foodservice_Customers_ID#'
				<cfelse>
				AND 1 = 2
				</cfif>
				</cfif>
				INNER JOIN Program_Lump_Sum_Name
				ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
		WHERE
				Contract_Main.Contract_Number = <cfqueryparam value='#Contract_Number#'>
		AND		#payee_unauthorized# = <cfqueryparam value=0>
	</CFQUERY>
	<CFIF Program_lumpsum.recordCount GT 0>
		<TR BGCOLOR="FFCE84" CLASS="MaintableTHEAD" STYLE="border-bottom:solid 93BEE2 1px;">
			<TD WIDTH="30">&nbsp;</TD>
			<TD>#Application.LumpsumLabel# Component</TD>
			<TD>#Application.LumpsumLabel# Amount</TD>
			<TD WIDTH="30">&nbsp;</TD>
		</TR>
		<CFLOOP QUERY="Program_lumpsum">
		<CFSET Total_Program_LumpSum = Total_Program_LumpSum + Program_lumpsum.Lump_Sum_Amount>
		<TR>
			<TD>&nbsp;</TD>
			<TD>#Program_lumpsum.Lump_Sum_Name#</TD>
			<TD>#DollarFormat(Program_lumpsum.Lump_Sum_Amount)#</TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFLOOP>
	<CFELSE>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%"><B><FONT COLOR="Red">No #Application.LumpsumLabel# Component found in the program for this payee</FONT></B></TD>
		</TR>
	</CFIF>

<cfelse>
	<cfset qGetProgramLumpSumForBillback = BillbackDeviationManager.getProgramLumpSumForBillback(Billback_ID, Contract_Number, BillbackPayeeType) />

	<CFIF qGetProgramLumpSumForBillback.recordCount GT 0>
		<TR BGCOLOR="FFCE84" CLASS="MaintableTHEAD" STYLE="border-bottom:solid 93BEE2 1px;">
			<TD WIDTH="30">&nbsp;</TD>
			<TD>#Application.LumpsumLabel# Component</TD>
			<TD>Pgm Avail Amt</TD>
			<TD>Component Amount</TD>
			<TD>Already Paid Amount</TD>
			<TD>Claimed Amount</TD>
			<TD>Available #Application.LumpsumLabel# Amount</TD>
			<TD WIDTH="30">&nbsp;</TD>
		</TR>
		<CFLOOP QUERY="qGetProgramLumpSumForBillback">
		<CFSET Total_Program_LumpSum = Total_Program_LumpSum + Expected_Amount>
		<TR>
			<TD>&nbsp;</TD>
			<TD>#Lump_Sum_Name#</TD>
			<TD>#DollarFormat(Program_Avail_Total)#</TD>
			<TD>#DollarFormat(Program_Amount)#</TD>
			<TD>#DollarFormat(Already_Paid_Amount)#</TD>
			<TD>#DollarFormat(Claimed_Amount)#</TD>
			<TD>#DollarFormat(Expected_Amount)#</TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFLOOP>
	<CFELSE>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%"><B><FONT COLOR="Red">Claimed #Application.LumpsumLabel# Components not found in the program</FONT></B></TD>
		</TR>
	</CFIF>
</cfif>


	<TR CLASS="MaintableTHEAD">
		<TD COLSPAN="100%" ALIGN="RIGHT">
		Total #Application.LumpsumLabel# Amount (&##931; #Application.LumpsumLabel# Amount) = #DollarFormat(Total_Program_LumpSum)#
		</TD>
	</TR>
</TABLE>
</TD>
</TR>

<CFSET Total_Growth_LumpSum = 0>
<CFIF Calculate_Growth_lumpsum GTE 1>
	<TR>
	<TD BGCOLOR="WhiteSmoke">

	<CFQUERY DBTYPE="QUERY" NAME="All_Unordered_Dates">
		SELECT	Program_Start_Date AS Start_Date, Program_End_Date AS End_Date, Contract_Number AS Code, (BB_Type + 0) AS THIS_BILLBACK
		FROM	Billback_Product_Program
		UNION
		SELECT	BB_Start_Date AS Start_Date, BB_End_Date AS End_Date, BB_Code AS Code, (BB_Type + 1) AS THIS_BILLBACK
		FROM	Billback_Product_Program
	</CFQUERY>



	<!----------------------------------------------------------------------------------
	Growth Lump sum
	----------------------------------------------------------------------------------->
	<CFIF Billback_Program_Program_ID NEQ "">
		<CFSET Billback_interval=DATEDIFF("d", Billback_Product_Program.BB_Start_Date, Billback_Product_Program.BB_End_Date) + 1>
		<CFSET FromLumpSum = 1>
		<CFINCLUDE TEMPLATE="Growth_Common_Amount_Calc.cfm">
	<CFELSE>
		<CFSET Component_Based_Volume = QueryNew("")>
	</CFIF>

	<!------ <CFDUMP VAR="#Component_Based_Volume#"> ----->

	<CFSET this_Component_LumpSum = 0>
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
	<CAPTION ALIGN="LEFT" STYLE="font-size:11px;color:blue;"><B>#Application.LumpsumLabel# Amount from growth</B></CAPTION>
		<CFIF Component_Based_Volume.recordCount GT 0>
			<TR BGCOLOR="FFCE84" CLASS="MaintableTHEAD" STYLE="border-bottom:solid 93BEE2 1px;">
				<TD WIDTH="30">&nbsp;</TD>
				<TD>Growth Component</TD>
				<TD>Amount</TD>
				<TD WIDTH="30">&nbsp;</TD>
			</TR>

			<CFLOOP QUERY="Component_Based_Volume">
			<TR VALIGN="TOP">
				<TD>&nbsp;</TD>
				<TD WIDTH="70%">
				<CFSET Open_Layer_Caption = "#Component_Based_Volume.component_name# (#Component_Based_Volume.Component_Type_Desc#)">
				<CF_openLayer
					Border="#Border#"
					BorderSize="0"
					BorderColor="#BorderColor#"
					Image="#Image#"
					ImageOpen="#ImageOpen#"
					Title="#Open_Layer_Caption#"
					TitleClosed="#Open_Layer_Caption#"
					TitleTooltip="#Open_Layer_Caption#"
					TitleColor="#TitleColor#"
					TitleFont="#TitleFont#"
					TitleSize="#TitleSize#"
					IsClosed="Yes"
					Width="80%"
					AddScript="#AddScript#">

					<CFSET THis_Program_Growth_Component_ID = Component_ID>
					<CFSET Volume_Program_Growth_Component_ID = Component_ID>
					<cfset Program_Growth_Component_ID = Component_ID>
					<CFSET this_Component_LumpSum = 0>
					<!------ Target method ----->
					<cfif Component_Based_Volume.component_type NEQ 1>
						<cfset componentIDRe = Replace(THis_Program_Growth_Component_ID, "-", "_", "all")>
						<cfset arTragetComp = Evaluate("ArTargetComponents#componentIDRe#")>
						<cfset arLen = ArrayLen(arTragetComp)>
						<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="100%" CLASS="Maintable">
						<cfif arLen GT 0>
							<TR BGCOLOR="FFCE84" CLASS="MaintableTHEAD" STYLE="border-bottom:solid 93BEE2 1px;">
							<TD>Name</TD>
							<TD>Target</TD>
							<TD>#Application.LumpsumLabel# Amount</TD>
							</TR>
							<cfloop from="1" to="#arLen#" index="i">
								<cfset stTisTragetComponent = arTragetComp[i]>
								<cfif (i mod 2) NEQ 0>
									<CFSET BGCOLOR="ccffcc">
								<CFELSE>
									<CFSET BGCOLOR="FFFFFF">
								</cfif>
								<cfif stTisTragetComponent.targetAttained>
									<CFSET BGCOLOR="yellow">
									<CFSET this_Component_LumpSum = this_Component_LumpSum + stTisTragetComponent.growthAmount>
								</cfif>
								<TR bgcolor="#BGCOLOR#">
								<TD>#stTisTragetComponent.targetComponentName#</TD>
								<TD>#stTisTragetComponent.targetValue# #stTisTragetComponent.targetUOM#</TD>
								<TD>#DollarFormat(stTisTragetComponent.growthAmount)#</TD>
								</TR>
							</cfloop>
						<cfelse>
						<TR CLASS="MaintableTHEAD">
							<TD COLSPAN="100%"><B><FONT COLOR="Red">No tier information found</FONT></B></TD>
						</TR>
						</cfif>
						</TABLE>
					<cfelse><!------ normal same volume & rate targets ----->
						<CFSET Total_Pounds_Invoiced = Component_Based_Volume.component_volume_lb>
						<CFSET Total_Cases_Invoiced = Component_Based_Volume.component_volume_cs>
						<CFIF Component_UOM EQ 1>
							<CFSET Total_Invoice_Statistics_In_Pgm_UOM = component_volume_cs>
							<!--- For Dollar percent growth --->
						<CFELSEIF Component_UOM EQ 3 AND Program_Growth_Comparison_Period_UOM_ID eq 2>
							<CFSET Total_Invoice_Statistics_In_Pgm_UOM = Component_Sales_Dollars>
						<CFELSE>
							<CFSET Total_Invoice_Statistics_In_Pgm_UOM = component_volume_lb>
						</CFIF>

						<CFINCLUDE TEMPLATE="Growth_Tier_Information.cfm">
						<CFSET Get_Tier_Info = Get_Tier_Range_Info>

						<CFSET Display_Component_UOM = Component_UOM>
						<CFIF Display_Component_UOM EQ 3>
							<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2>
							<!--- lbs --->
								<CFSET Display_Component_UOM = 2>
							<CFELSE>
							<!--- dollars --->
								<CFSET Display_Component_UOM = 4>
							</CFIF>
						</CFIF>
						<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="100%" CLASS="Maintable">
							<TR CLASS="MaintableTHEAD">
								<TD COLSPAN="100%">
								Total #Program_Growth_Comparison_Period_UOM# for Component :
								#Total_Invoice_Statistics_In_Pgm_UOM#
								#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#
								</TD>
							</TR>
							<CFIF Get_Tier_Info.recordCount GT 0>
								<TR BGCOLOR="FFCE84" CLASS="MaintableTHEAD" STYLE="border-bottom:solid 93BEE2 1px;">
									<TD WIDTH="30">&nbsp;</TD>
									<TD NOWRAP>Start (#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#)</TD>
									<TD NOWRAP>End (#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#)</TD>
									<TD>#Application.LumpsumLabel# Amount</TD>
									<TD WIDTH="30">&nbsp;</TD>
								</TR>
								<CFLOOP QUERY="Get_Tier_Info">
								<cfif (Get_Tier_Info.currentRow mod 2) NEQ 0>
									<CFSET BGCOLOR="ccffcc">
								<CFELSE>
									<CFSET BGCOLOR="FFFFFF">
								</cfif>

								<CFIF Get_Tier_Info.TIER_ATTAINED_MULTI EQ 1>
									<CFSET this_Component_LumpSum = this_Component_LumpSum + Get_Tier_Info.Growth_Amount>
									<CFSET BGCOLOR="#DEVIATION_VALID_ROW_INDICATOR_COLOR#">
								</CFIF>
								<TR BGCOLOR="#BGCOLOR#">
									<TD>&nbsp;</TD>
									<TD>#Get_Tier_Info.Range_Start#</TD>
									<TD>#Get_Tier_Info.Range_End#</TD>
									<TD>#Get_Tier_Info.Growth_Amount#</TD>
									<TD>&nbsp;</TD>
								</TR>
								</CFLOOP>
							<CFELSE>
								<TR CLASS="MaintableTHEAD">
									<TD COLSPAN="100%"><B><FONT COLOR="Red">No tier information found</FONT></B></TD>
								</TR>
							</CFIF>
							</TABLE>
						</cfif>
						<CFSET Total_Growth_LumpSum = Total_Growth_LumpSum + this_Component_LumpSum>
						</CF_openLayer>

					</TD>
					<TD>#DollarFormat(this_Component_LumpSum)#</TD>
					<TD>&nbsp;</TD>
				</TR>
			</CFLOOP>
		<CFELSE>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%"><B><FONT COLOR="Red">No Growth Component for claimed products</FONT></B></TD>
		</TR>
		</CFIF>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%" ALIGN="RIGHT">
			Total #Application.LumpsumLabel# Amount from growth( &##931; Amount) = #DollarFormat(Total_Growth_LumpSum)#
			</TD>
		</TR>
	</TABLE>

	</TD>
	</TR>
</CFIF>

<CFSET Lumpsum_From_Other_BB = 0>
<cfif Discount_Lump_Sums_Distributor_Mandated EQ 0>
<TR>
<TD BGCOLOR="WhiteSmoke">
<!----------------------------------------------------------------------------------
Get Lumpsum from other Billbacks for this payee
----------------------------------------------------------------------------------->

<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Get_Previous_Lump_Info">
SELECT	Billback.Billback_ID, Billback.BB_Code, Billback.BB_Title,
		<cfif appSettings.getClaims_at_Comp_Level()> ISNULL(SUM(BB_Program_Lump_Sum_Distributor.Paid_Amount), 0)
		<cfelse> ISNULL(BB_Lump_Sums.LS_Paid_Amount, 0)
		</cfif> AS Amount
		FROM
		Billback
		<CFIF Date_Approved NEQ "">
			<CFIF IsDate(Date_Approved)>
				INNER JOIN BB_Approved
				ON
				(
					(BB_Approved.Billback_ID = Billback.Billback_ID)
					AND
					--(DATEDIFF(s, BB_Approved.Date_Approved, #CreateODBCDateTime(Date_Approved)#) > 0)
					(dbo.D_DATEDIFF('ms', BB_Approved.Date_Approved, #CreateODBCDateTime(Date_Approved)#) > 0)
				)
			</CFIF>
		</CFIF>
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
			(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
			AND
			(Contract_Main.Contract_Number = '#Contract_Number#')
		)
		<cfif appSettings.getClaims_at_Comp_Level()>
		<!---- Ana - D17239 - starting this label Lumpsum will work based on Name_ID instead og Comp_ID----->
		INNER JOIN BB_Program_Lump_Sum_Distributor
		ON		BB_Program_Lump_Sum_Distributor.Billback_Program_ID = Billback_Program.Billback_Program_ID AND
				BB_Program_Lump_Sum_Distributor.Billback_ID = Billback.Billback_ID AND
				BB_Program_Lump_Sum_Distributor.Deleted = 0
		<cfelse>
		INNER JOIN	BB_Lump_Sums
		ON
		(
			(BB_Lump_Sums.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(BB_Lump_Sums.Deleted = 0)
		)
		</cfif>
		<CFSWITCH EXPRESSION="#Billback_Payee_Type_ID#">
			<CFCASE VALUE="1">
			INNER JOIN	Billback_Distributor
			ON
			(<!--- Dev Note(70957) - For a program which has a lumpsum amount of x and more than one distributor, that amount is available as long as one
			or more of those distributors claim that amount. Once the claimed amount exceeds x, then the expected amount will be 0.
			--->
			<cfif Discount_Lump_Sums_Distributor_Mandated EQ 1>
				(Billback_Distributor.Distributor_ID = '#Payee_ID#')
				AND
			</cfif>
				(Billback_Distributor.Billback_ID = Billback.Billback_ID)
				AND
				(Billback.Billback_Payee_Type_ID = 1)
				AND
				(Billback_Distributor.Deleted = 0)
			)
			</CFCASE>
			<CFCASE VALUE="3">
			INNER JOIN	Billback_Broker
			ON
			(
				(Billback_Broker.Billback_ID = Billback.Billback_ID)
				AND
				(Billback.Billback_Payee_Type_ID = 3)
				AND
				(Billback_Broker.Deleted = 0)
			)
			INNER JOIN BSA_Foodservice_Brokers
			ON	BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID
			AND	BSA_Foodservice_Brokers.Broker_Legcy_Shard = '#Payee_Number#'
			</CFCASE>
			<CFCASE VALUE="2">
			INNER JOIN	Billback_Operator
			ON
			(
				(Billback_Operator.Operator_ID = #Payee_ID#)
				AND
				(Billback_Operator.Billback_ID = Billback.Billback_ID)
				AND
				(Billback.Billback_Payee_Type_ID = 2)
				AND
				(Billback_Operator.Deleted = 0)
			)
			</CFCASE>
			<CFDEFAULTCASE>
				INNER JOIN Billback_Distributor
				ON
				(
					(1=2)
				)
			</CFDEFAULTCASE>
		</CFSWITCH>
		WHERE
		Billback.Deleted = <cfqueryparam value=0>
		AND
		Billback.Billback_ID <> <cfqueryparam value='#Billback_ID#'>
		AND
		Billback.Billback_Status_ID >= <cfqueryparam value=#DEVIATION_OVERLAPPED_BB_STATUS#>
		AND Billback.Billback_Status_ID <> <cfqueryparam value=8>
		<cfif appSettings.getClaims_at_Comp_Level()>
		AND		BB_Program_Lump_Sum_Distributor.Program_Lump_Sum_Name_ID IN
		(
		SELECT		Program_Lump_Sums.Program_Lump_Sum_Name_ID
		FROM		Billback_Program
		INNER JOIN	Contract_Main
		ON	Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
		AND	Contract_Main.Contract_Number = '#Contract_Number#'
		INNER JOIN	Billback_Program_Lumpsum_Component
		ON	Billback_Program_Lumpsum_Component.Billback_Program_ID = Billback_Program.Billback_Program_ID
		AND	Billback_Program_Lumpsum_Component.Deleted = 0
		INNER JOIN	Program_Lump_Sums
		ON	Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
		AND	Program_Lump_Sums.Deleted = 0
		AND Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
		WHERE	Billback_Program.Billback_ID = <cfqueryparam value='#Billback_ID#'>
		AND		Billback_Program.Deleted = <cfqueryparam value=0>
		)
		Group By Billback.Billback_ID, Billback.BB_Code, Billback.BB_Title, Contract_Main.Contract_Number
		</cfif>
		Order By Billback.Billback_ID
</CFQUERY>


<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
<CAPTION ALIGN="LEFT" STYLE="font-size:11px;color:blue;"><B>#Application.LumpsumLabel# Amount from other Billbacks</B></CAPTION>
	<CFIF Get_Previous_Lump_Info.recordCount GT 0>
		<TR BGCOLOR="FFCE84" CLASS="MaintableTHEAD" STYLE="border-bottom:solid 93BEE2 1px;">
			<TD WIDTH="30">&nbsp;</TD>
			<TD>Billback</TD>
			<TD>Amount</TD>
			<TD WIDTH="30">&nbsp;</TD>
		</TR>
		<CFLOOP QUERY="Get_Previous_Lump_Info">
		<CFSET Lumpsum_From_Other_BB = Lumpsum_From_Other_BB + Get_Previous_Lump_Info.Amount>
		<TR>
			<TD>&nbsp;</TD>
			<TD>[#Get_Previous_Lump_Info.BB_Code#] #Get_Previous_Lump_Info.BB_Title#</TD>
			<TD>#DollarFormat(Get_Previous_Lump_Info.Amount)#</TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFLOOP>
	<CFELSE>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%"><B><FONT COLOR="Red">No previous claimed #LCase(Application.LumpsumLabel)# amount <cfif appSettings.getClaims_at_Comp_Level()>for the selected components</cfif></FONT></B></TD>
		</TR>
	</CFIF>
	<TR CLASS="MaintableTHEAD">
		<TD COLSPAN="100%" ALIGN="RIGHT">
		Total #Application.LumpsumLabel# Amount from other billbacks( &##931; Amount) = #DollarFormat(Lumpsum_From_Other_BB)#
		</TD>
	</TR>
</TABLE>

</TD>
</TR>
</cfif>
</TABLE>

<CFSET Total_Expected_LumpSum = Total_Program_LumpSum + Total_Growth_LumpSum - Lumpsum_From_Other_BB>

<BR>
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="#Table_Width#" ALIGN="CENTER">
		<TR>
			<TD>Total Amount from #Application.LumpsumLabel# Components</TD>
			<TD>A1</TD>
			<TD>&nbsp=&nbsp;</TD>
			<TD>
			#DollarFormat(Total_Program_LumpSum)#
			</TD>
		</TR>
		<TR>
			<TD>Total Amount from Growth Components</TD>
			<TD>A2</TD>
			<TD>&nbsp=&nbsp;</TD>
			<TD>
			#DollarFormat(Total_Growth_LumpSum)#
			</TD>
		</TR>
		<cfif Discount_Lump_Sums_Distributor_Mandated EQ 0>
		<TR>
			<TD>Total #Application.LumpsumLabel# Amount from previous billbacks</TD>
			<TD>A3</TD>
			<TD>&nbsp=&nbsp;</TD>
			<TD>
			#DollarFormat(Lumpsum_From_Other_BB)#
			</TD>
		</TR>
		</cfif>
		<TR CLASS="MaintableTHEAD">
			<TD>Total Expected #Application.LumpsumLabel# Amount</TD>
			<TD>A4 = A1 + A2<cfif Discount_Lump_Sums_Distributor_Mandated EQ 0> - A3</cfif></TD>
			<TD>&nbsp=&nbsp;</TD>
			<TD>
			#DollarFormat(Total_Expected_LumpSum)#
			</TD>
		</TR>
		<CFIF Total_Billback_LumpSum LT Total_Expected_LumpSum>
		<TR CLASS="MaintableTHEAD">
			<TD>Effective Expected #Application.LumpsumLabel# Amount</TD>
			<TD>#Application.LumpsumLabel# Amount Claimed</TD>
			<TD>&nbsp=&nbsp;</TD>
			<TD>
			<CFSET Total_Expected_LumpSum = Total_Billback_LumpSum>
			#DollarFormat(Total_Expected_LumpSum)#
			</TD>
		</TR>
		</CFIF>
	</TABLE>
</cfif><!--- payee us authorized - end --->
</CFOUTPUT>


<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Billback_Lumpsum_Deviation_Info">
SELECT	BB_Lump_Sums.LS_Expected_Amount

	FROM	BB_Lump_Sums
	WHERE
		BB_Lump_Sums.Billback_Program_ID = <cfqueryparam value='#Billback_Program_ID#'>
		AND
		BB_Lump_Sums.Deleted = <cfqueryparam value=0>
</CFQUERY>

<CFIF Billback_Lumpsum_Deviation_Info.recordCOunt GT 0>
	<CFSET Total_Expected_LumpSum = Billback_Lumpsum_Deviation_Info.LS_Expected_Amount>

	<!------------- Show deviation calculation ------------------>
	<BR>
	<SPAN CLASS="Title2"><cfoutput>#Application.LumpsumLabel# #DEVIATION_LABEL_SMALL#</cfoutput> calculation</SPAN>
	<HR COLOR="Orange">
		<CFOUTPUT>
		<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="#Evaluate("Table_Width*2/3")#">
			<TR>
				<TD>#Application.LumpsumLabel# Amount Claimed</TD>
				<TD>A1</TD>
				<TD>&nbsp:&nbsp;</TD>
				<TD>
				#DollarFormat(Total_Billback_LumpSum)#
				</TD>
			</TR>
			<TR>
				<TD><B>Expected #Application.LumpsumLabel# Amount</B></TD>
				<TD><B>A2</B></TD>
				<TD>&nbsp:&nbsp;</TD>
				<TD>
				<B>#DollarFormat(Total_Expected_LumpSum)#</B>
				</TD>
			</TR>
			<TR>
				<TD>#DEVIATION_LABEL# Amount</TD>
				<TD>A3 = A1 - A2</TD>
				<TD>&nbsp:&nbsp;</TD>
				<TD>
				<CFSET dev_Amount = val(Total_Expected_LumpSum) - val(Total_Billback_LumpSum)>
				#DollarFormat(dev_Amount)#
				</TD>
			</TR>
			<CFIF dev_Amount GT 0>
			<TR>
				<TD>Effective Deviated Amount</TD>
				<TD>A4</TD>
				<TD>&nbsp:&nbsp;</TD>
				<TD>
				<CFSET dev_Amount = 0>
				#DollarFormat(dev_Amount)#
				</TD>
			</TR>
			</CFIF>
			<TR>
				<TD>#Application.LumpsumLabel# Amount #DEVIATION_LABEL# Percentage</TD>
				<TD>A5 = A4 / A2</TD>
				<TD>&nbsp:&nbsp;</TD>
				<TD>
				<CFSET dev_Amount_Percent = (dev_Amount * 100) / Total_Billback_LumpSum>
				#NumberFormat(dev_Amount_Percent, DEVIATION_PERCENT_FORMAT)#%
				</TD>
			</TR>
		</TABLE>
		</CFOUTPUT>
	</CFIF>
	<BR><BR>
	<CFIF ADDSCRIPT EQ "Yes">
	<SCRIPT LANGUAGE="javaScript">
	showDates();
	</SCRIPT>
	</CFIF>
	<CFIF SHOW_DEVIATION_DETAIL_FOOTER>
	<TABLE ALIGN="CENTER" WIDTH="50%">
		<TD ALIGN="CENTER">
		<CF_button
				button_name		=	""
				button_caption	=	"print"
				button_action	=	"printPage();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"print"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
		<TD ALIGN="CENTER">
		<CF_button
				button_name		=	""
				button_caption	=	"close this window"
				button_action	=	"window.close();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"close this window"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
	</TABLE>
	<SCRIPT LANGUAGE="JavaScript" SRC="common_js.js"></SCRIPT>
	<SCRIPT LANGUAGE="JavaScript">
	window.onbeforeprint=new Function ("AllOpenLayers(1);");
	</SCRIPT>
	<BR><BR>
</BLOCKQUOTE>
</BODY>
</HTML>
<CFELSE>
	</BLOCKQUOTE>
</CFIF>
