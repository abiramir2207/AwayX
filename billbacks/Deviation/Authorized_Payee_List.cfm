<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFINCLUDE TEMPLATE="Deviation_Constants.CFM">

<CFPARAM NAME="URL.Billback_Program_ID"								DEFAULT="">
<CFSET Billback_Program_ID=URL.Billback_Program_ID>

<html>
<head>
	<title>Billback Deviation - Unauthorized Payee</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<BLOCKQUOTE>

<!------------------------------show spinner ---------------------------->
<!------
<CFSET PW_Type="1">
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
----->

<!------ Get Billback Information ----->
<cfset billbackSummaryManager = CreateObject("component", "components.billback.BillbackSummaryManager") />
<cfset Billback_ID = billbackSummaryManager.getBillbackIDForProgram(Billback_Program_ID) />
<cfset billbackSummaryManager = billbackSummaryManager.init(Billback_ID) />
<cfset billbackInfo = billbackSummaryManager.getBillbackInfo(Billback_ID) />
<cfset getPayeeInfo = billbackSummaryManager.getPayeeInfo() />
<CFSET BB_Payee_Type	= billbackSummaryManager.getPayeeType()>

<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Payee">
	SELECT	
			bb.BB_Code,  bb.BB_Title
	------------------------ID
	,CASE
		WHEN bb.Billback_Payee_Type_ID=1 THEN  
		CAST(Billback_Distributor.Distributor_ID AS VARCHAR(60))
		
		WHEN bb.Billback_Payee_Type_ID=2 THEN
		CAST(Billback_Operator.Operator_ID AS VARCHAR(60))
		
		WHEN bb.Billback_Payee_Type_ID=3 THEN 
		CAST(Billback_Broker.Broker_ID AS VARCHAR(60))
	END AS BB_Payee_ID			
	
	------------------------Name
	,CASE
		WHEN bb.Billback_Payee_Type_ID=1 THEN  
		BSA_Foodservice_Customers.Name  
		
		WHEN bb.Billback_Payee_Type_ID=2 THEN
		BSA_Operator.Operator_Name  
		
		WHEN bb.Billback_Payee_Type_ID=3 THEN 
		BSA_Foodservice_Brokers.Broker_Name
		 
		WHEN bb.Billback_Payee_Type_ID=4 THEN
		Billback_Unidentified_Payee.BB_UP_Name
		
		WHEN bb.Billback_Payee_Type_ID=5 THEN
		Billback_Distributor.BB_Distributor_Name
		
		WHEN bb.Billback_Payee_Type_ID=6 THEN
		Billback_Operator.BB_Operator_Name
		
		WHEN bb.Billback_Payee_Type_ID=7 THEN
		Billback_Broker.BB_Broker_Name
		 
	END AS Payee_Name
	-------------------------City
	,CASE
	WHEN bb.Billback_Payee_Type_ID=1 THEN		
		BSA_Foodservice_Customers.City
		
	WHEN bb.Billback_Payee_Type_ID=2 THEN
		BSA_Operator.Operator_City
		
	WHEN bb.Billback_Payee_Type_ID=3 THEN	
		BSA_Foodservice_Brokers.City
		
	WHEN bb.Billback_Payee_Type_ID=4 THEN
		Billback_Unidentified_Payee.BB_UP_Name

	WHEN bb.Billback_Payee_Type_ID=5 THEN		
		Billback_Distributor.BB_Distributor_City
		
	WHEN bb.Billback_Payee_Type_ID=6 THEN
			Billback_Operator.BB_Operator_City

	WHEN bb.Billback_Payee_Type_ID=7 THEN	
			Billback_Broker.BB_Broker_City

	END AS City
	-------------------------State
	,CASE
	WHEN bb.Billback_Payee_Type_ID=1 THEN		
		BSA_Foodservice_Customers.State		
	
	WHEN bb.Billback_Payee_Type_ID=2 THEN
		BSA_Operator.Operator_State
	
	WHEN bb.Billback_Payee_Type_ID=3 THEN	
		BSA_Foodservice_Brokers.State
	
	WHEN bb.Billback_Payee_Type_ID=4 THEN
		_States.State_Code
	
	WHEN bb.Billback_Payee_Type_ID=5 THEN		
		_States.State_Code
	
	WHEN bb.Billback_Payee_Type_ID=6 THEN
		_States.State_Code
	
	WHEN bb.Billback_Payee_Type_ID=7 THEN	
		_States.State_Code
	
	END AS State_Code
	,bb.Billback_Payee_Type_ID
	FROM	
	Billback_Program
	INNER JOIN	Billback bb
	ON
	(
		(Billback_Program.Billback_ID = bb.Billback_ID)
		AND
		(bb.Deleted = 0)
	)
	----------------------------------------------------
	LEFT JOIN	
		(
		Billback_Broker
		LEFT JOIN
		BSA_Foodservice_Brokers
		ON
		(Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
		)
	ON
	(
	(Billback_Broker.Billback_ID = bb.Billback_ID)
	AND
	(
		(bb.Billback_Payee_Type_ID = 3)
		OR
		(bb.Billback_Payee_Type_ID = 7)
	)
	AND
	(Billback_Broker.Deleted = 0)
	)
	----------------------------------------------------				
	LEFT JOIN	
		(
		Billback_Distributor
		LEFT JOIN 
		BSA_Foodservice_Customers
		ON 
		(Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)
		)
	ON
	(
	(Billback_Distributor.Billback_ID = bb.Billback_ID)
	AND
	(
		(bb.Billback_Payee_Type_ID = 1)
		OR
		(bb.Billback_Payee_Type_ID = 5)
	)
	AND
	(Billback_Distributor.Deleted = 0)
	)
	
	----------------------------------------------------				
	LEFT JOIN	
		(
		Billback_Operator
		LEFT JOIN
		BSA_Operator
		ON
		(Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID)
		)
	ON
	(
	(Billback_Operator.Billback_ID = bb.Billback_ID)
	AND
	(
		(bb.Billback_Payee_Type_ID = 2)
		OR
		(bb.Billback_Payee_Type_ID = 6)
	)
	AND
	(Billback_Operator.Deleted = 0)				
	)
	----------------------------------------------------				
	LEFT JOIN	Billback_Unidentified_Payee
	ON
	(
	(Billback_Unidentified_Payee.Billback_ID = bb.Billback_ID)
	AND
	(bb.Billback_Payee_Type_ID = 4)
	AND
	(Billback_Unidentified_Payee.Deleted = 0)
	)
	----------------------------------------------------				
	LEFT JOIN _States
	ON
	(
	((bb.Billback_Payee_Type_ID = 5) AND (_States.State_ID=Billback_Distributor.BB_Distributor_State))
	OR
	((bb.Billback_Payee_Type_ID = 6) AND (_States.State_ID=Billback_Operator.BB_Operator_State))
	OR
	((bb.Billback_Payee_Type_ID = 7) AND (_States.State_ID=Billback_Broker.BB_Broker_State))
	OR
	((bb.Billback_Payee_Type_ID = 4) AND (_States.State_ID=Billback_Unidentified_Payee.BB_UP_State))
	)
	WHERE
		Billback_Program.Deleted = 0				
		AND
		Billback_Program.Billback_Program_ID = '#Billback_Program_ID#'
</CFQUERY>

<CFQUERY  dataSource="#application.datasource#" NAME="Program_Info">
	SELECT	Billback_Program.Program_ID, 
		CASE 
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
	FROM	Billback_Program	
		LEFT JOIN 	Contract_Main
		ON
		(
			(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
		)
	WHERE	
			Billback_Program.Billback_Program_ID = '#Billback_Program_ID#'
			AND
			Billback_Program.Deleted = 0
</CFQUERY>

<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Program_Payees">

	IF OBJECT_ID('tempdb..##Contracts') IS NOT NULL
	DROP TABLE ##Contracts
	CREATE TABLE ##Contracts
	(	
		Contract_Main_ID int
	)
	
	INSERT INTO ##Contracts
	SELECT	DISTINCT BB_Program_Info.Contract_Main_ID
	FROM	Billback_Program	
	INNER JOIN 	Contract_Main
	ON		Contract_Main.Contract_Main_ID = Billback_Program.Program_ID	
	INNER JOIN BB_Program_Info
	ON		BB_Program_Info.Contract_Number = Contract_Main.Contract_Number
	WHERE	Billback_Program.Billback_Program_ID = '#Billback_Program_ID#'
	AND		Billback_Program.Deleted = 0
	AND		'#DateFormat(billbackInfo.BB_Start_Date, "mm/dd/yyyy")#' <= Approval_End_Date
	AND		'#DateFormat(billbackInfo.BB_End_Date, "mm/dd/yyyy")#' >= Approval_Start_Date
			
		
	<!--- -- Get list of authorized payee types from program --->
	IF OBJECT_ID('tempdb..##Tmp_Payee_Types') IS NOT NULL
	DROP TABLE ##Tmp_Payee_Types
	CREATE TABLE ##Tmp_Payee_Types (Payee_Type int)
	
	<!--- -- Include fixed price component payee type from program if billback has fixed price --->
	IF EXISTS (
			SELECT	1 
			FROM	Billback_Product bp 
			INNER JOIN Billback_Product_Detail d ON d.Billback_Product_ID = bp.Billback_Product_ID AND d.BB_Product_Type_ID = 1 AND d.Deleted = 0
			WHERE	bp.Billback_Program_ID = '#Billback_Program_ID#' 
			AND		bp.Deleted = 0
			)
	INSERT INTO ##Tmp_Payee_Types (Payee_Type)
	SELECT	c.Fixed_Component_Paid_to
	FROM	Program_Fixed_Component c
	WHERE	c.Program_ID IN (SELECT CTmp.Contract_Main_ID FROM ##Contracts CTmp)
	AND		c.Deleted = 0
	
	<!--- -- Include rebate component payee type from program if billback has rebate --->
	<!--- -- Get the component selected on the billback, then get the payee types for that component from program versions with efefctive dates --->
	INSERT INTO ##Tmp_Payee_Types (Payee_Type)
	SELECT	c.Component_Paid_To as Payee_Type
	FROM	Billback_Program_Rebate_Component bc
	INNER JOIN Program_Rebates_Component c
	ON		c.Program_Rebates_Component_Name_ID = bc.Program_Rebates_Component_Name_ID
	AND		c.Program_ID IN (SELECT CTmp.Contract_Main_ID FROM ##Contracts CTmp)
	AND		c.Deleted = 0
	WHERE	bc.Billback_ID = '#Billback_ID#'
	AND		bc.Deleted = 0
	
	<!--- -- Include ls component payee type from program if billback has ls --->
	IF EXISTS (
			SELECT	1 
			FROM	Billback_Program_Lumpsum_Component c
			WHERE	c.Billback_Program_ID = '#Billback_Program_ID#' 
			AND		c.Deleted = 0
			AND		c.Component_Type_ID IN (1,2)
			)
	INSERT INTO ##Tmp_Payee_Types (Payee_Type)
	SELECT	c.Component_Paid_To as Payee_Type
	FROM	Program_Lump_Sums c
	WHERE	c.Program_ID IN (SELECT CTmp.Contract_Main_ID FROM ##Contracts CTmp)
	AND		c.Deleted = 0
	
	<!--- -- Include growth component payee type from program if billback has growth --->
	IF EXISTS (
			SELECT	1 
			FROM	Billback_Product bp 
			INNER JOIN Billback_Product_Detail d ON d.Billback_Product_ID = bp.Billback_Product_ID AND d.BB_Product_Type_ID = 4 AND d.Deleted = 0
			WHERE	bp.Billback_Program_ID = '#Billback_Program_ID#' 
			AND		bp.Deleted = 0
			)
	INSERT INTO ##Tmp_Payee_Types (Payee_Type)
	SELECT	c.Component_Paid_To as Payee_Type
	FROM	Program_Growth_Components c
	WHERE	c.Program_ID IN (SELECT CTmp.Contract_Main_ID FROM ##Contracts CTmp)
	AND		c.Deleted = 0


	IF OBJECT_ID('tempdb..##Tmp_Payee_List') IS NOT NULL
	DROP TABLE ##Tmp_Payee_List
	CREATE TABLE ##Tmp_Payee_List (Payee_ID VARCHAR(50), PayeeName VARCHAR(500), PayeeNumber VARCHAR(50), Payee_Type int)

	IF EXISTS (SELECT 1 FROM ##Tmp_Payee_Types WHERE Payee_Type = 1) <!--- -- Only if program has component with payee type --->
	BEGIN
		INSERT INTO ##Tmp_Payee_List (Payee_ID, PayeeName, PayeeNumber, Payee_Type)
		SELECT	CAST(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AS VARCHAR(50)) AS Payee_ID, BSA_Foodservice_Customers.Name AS PayeeName, BSA_Foodservice_Customers.Ship_to AS PayeeNumber
				, 1 as Payee_Type
		FROM	Contract_Distributors
		INNER JOIN	BSA_Foodservice_Customers
		ON		Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
		WHERE	Contract_Distributors.Contract_Main_ID IN (SELECT CTmp.Contract_Main_ID FROM ##Contracts CTmp)
		AND		Contract_Distributors.Deleted = 0
		
	END
	<cfif BB_Payee_Type EQ 1>
	ELSE
	BEGIN
		INSERT INTO ##Tmp_Payee_List (Payee_ID, PayeeName, PayeeNumber, Payee_Type)
		SELECT	'' AS Payee_ID, '' AS PayeeName, '' AS PayeeNumber, 1 as Payee_Type
	END
	</cfif>
		
	IF EXISTS (SELECT 1 FROM ##Tmp_Payee_Types WHERE Payee_Type = 2) <!--- -- Only if program has component with payee type --->
	BEGIN
		INSERT INTO ##Tmp_Payee_List (Payee_ID, PayeeName, PayeeNumber, Payee_Type)
		SELECT	CAST(BSA_Operator.BSA_Operator_ID AS VARCHAR(50)) AS Payee_ID, BSA_Operator.Operator_Name AS PayeeName, '&nbsp;' AS PayeeNumber
				, 2 as Payee_Type
		FROM	Contract_Operators
		INNER JOIN	BSA_Operator
		ON		Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID
		WHERE	Contract_Operators.Contract_Main_ID IN (SELECT CTmp.Contract_Main_ID FROM ##Contracts CTmp)
		AND		Contract_Operators.Deleted = 0
				
	END
	<cfif BB_Payee_Type EQ 2>
	ELSE
	BEGIN
		INSERT INTO ##Tmp_Payee_List (Payee_ID, PayeeName, PayeeNumber, Payee_Type)
		SELECT	'' AS Payee_ID, '' AS PayeeName, '' AS PayeeNumber, 2 as Payee_Type
	END
	</cfif>
	
	IF EXISTS (SELECT 1 FROM ##Tmp_Payee_Types WHERE Payee_Type = 3) <!--- -- Only if program has component with payee type --->
	BEGIN
		INSERT INTO ##Tmp_Payee_List (Payee_ID, PayeeName, PayeeNumber, Payee_Type)
		SELECT	CAST(BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID AS VARCHAR(50)) AS Payee_ID, BSA_Foodservice_Brokers.Broker_Name AS PayeeName, BSA_Foodservice_Brokers.Broker_Shard AS PayeeNumber
				, 3 as Payee_Type
		FROM	Contract_Brokers
		INNER JOIN	BSA_Foodservice_Brokers
		ON		Contract_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID			
		WHERE	Contract_Brokers.Contract_Main_ID IN (SELECT CTmp.Contract_Main_ID FROM ##Contracts CTmp)
		AND		Contract_Brokers.Deleted = 0		
	END
	<cfif BB_Payee_Type EQ 3>
	ELSE
	BEGIN
		INSERT INTO ##Tmp_Payee_List (Payee_ID, PayeeName, PayeeNumber, Payee_Type)
		SELECT	'' AS Payee_ID, '' AS PayeeName, '' AS PayeeNumber, 3 as Payee_Type
	END
	</cfif>
	
	SELECT	DISTINCT *	
	FROM 	##Tmp_Payee_List
	ORDER BY Payee_Type
</CFQUERY>

<CFOUTPUT>
<STYLE>
	TABLE.Date_Dev_Table
	{
		/*border-left:solid blue 1px;
		border-bottom:solid blue 1px;*/
	}
</STYLE>
<BR><BR>

<SCRIPT LANGUAGE="JavaScript">
	
</SCRIPT>

<CFSET payee_Type_List="#application.returned_customer_setting.distributor_label_singular#,#application.returned_customer_setting.operator_label_singular#,Broker,Other,Unknown #application.returned_customer_setting.distributor_label_singular#,Unknown #application.returned_customer_setting.operator_label_singular#,Unknown Broker,Unknown Payee">
<CFSET payee_Type_Number_List="Ship To,&nbsp;,ID">

<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0">
	<COLGROUP>
		<COL SPAN=2" NOWARAP STYLE="FONT-WEIGHT:BOLD;"></COL>
	</COLGROUP>
	<TR>
		<TD>Billback</TD>
		<TD>&nbsp;:&nbsp;</TD>
		<TD>&nbsp;[#billbackInfo.BB_Code#]</TD>
		<TD>&nbsp;#billbackInfo.BB_Title#</TD>		
	</TR>	
	<CFIF getPayeeInfo.RecordCount GT 0>	
		<CFSET BB_Payee_ID="">
		
		<CFSET BB_Payee_ID		= getPayeeInfo.BB_Payee_ID>		
		
		<TR VALIGN="TOP">
			<TD>#application.returned_customer_setting.Billback_Payee_Label# (#ListGetAt(payee_Type_List, billbackSummaryManager.getPayeeType(), ",")#)</TD>
			<TD>&nbsp;:&nbsp;</TD>
			<TD COLSPAN="2">		
			#getPayeeInfo.Payee_Name#
			<BR>#getPayeeInfo.City#<CFIF Len(getPayeeInfo.State_Code) GT 0>, </CFIF>#getPayeeInfo.State_Code#
			</TD>
		</TR>
		
		<cfif BB_Payee_Type EQ 4 AND Len(Trim(BB_Payee_ID)) NEQ 0>
			<CFSET BB_Payee_Type	= 1><!------ Use the distributor, if payee type = other and ship to is associated ----->			
			<TR VALIGN="TOP">
				<TD>#application.returned_customer_setting.distributor_label_singular#</TD>
				<TD>&nbsp;:&nbsp;</TD>
				<TD COLSPAN="2">
				#getPayeeInfo.Associated_Dist_Name#<cfif getPayeeInfo.Associated_Payee_ShipTo is not ''> &nbsp;(#getPayeeInfo.Associated_Payee_ShipTo#) </cfif>
				<BR>#getPayeeInfo.Associated_Dist_City#<CFIF Len(getPayeeInfo.Associated_Dist_State) GT 0>, </CFIF>#getPayeeInfo.Associated_Dist_State#
				</TD>
			</TR>
		</cfif>
	</CFIF>
</TABLE>



<BR>

<FONT SIZE=2><B>Authorized Payee List for Program [#Program_Info.Contract_Number#] #Program_Info.Contract_Title#</B><CFIF Program_Info.Program_ID EQ "">#DEVIATION_SHOW_PNF#</CFIF></CAPTION>
</CFOUTPUT>
<HR COLOR="Orange">

<CFOUTPUT QUERY="Billback_Program_Payees" GROUP="Payee_Type">
<CFIF Payee_ID NEQ "">
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" CLASS="Maintable" WIDTH="500">
	<CAPTION STYLE="FONT:11px" ALIGN="LEFT"><B>#ListGetAt(payee_Type_List,Payee_Type)#s</B></CAPTION>
	<THEAD BGCOLOR="FFCE84">
		<TD WIDTH="10%">&nbsp;</TD>
		<TD WIDTH="20%"><FONT SIZE="-1"><b>#ListGetAt(payee_Type_Number_List,Payee_Type,",")#</b></FONT></TD>
		<TD WIDTH="65%"><FONT SIZE="-1"><b>Name</b></FONT></TD>
		<TD>&nbsp;</TD>
	</THEAD>
		<CFOUTPUT>
		<cfif (Billback_Program_Payees.currentRow mod 2) NEQ 0>
			<CFSET BGCOLOR="ccffcc">
		<CFELSE>
			<CFSET BGCOLOR="FFFFFF">
		</cfif>
		<CFIF (BB_Payee_ID EQ Payee_ID) AND (Payee_Type EQ BB_Payee_Type)>
			<CFSET BGCOLOR="#DEVIATION_VALID_ROW_INDICATOR_COLOR#">
		</CFIF>
		<TR BGCOLOR="#BGCOLOR#">
			<TD>&nbsp;</TD>
			<TD>#PayeeNumber#</TD>
			<TD>#PayeeName#</TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFOUTPUT>
</TABLE>
<CFELSE>
	<BR><FONT COLOR="Red"><B>#ListGetAt(payee_Type_List,Payee_Type)# is not a valid payee type for the discount/component selected</B></FONT><BR>
</CFIF>


</CFOUTPUT>
<BR><BR>
<B>Unauthorized Payee deviation calculation</B>
<HR COLOR="Orange">

<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Program_Payee_Deviation_Info">
SELECT	
		BB_Program_Deviation_Info.Unauthorized_Payee
		--, BB_Program_Deviation_Info.BB_Dollar_Amount
		-----------------Total Amount claimed for this program
		, (IsNUll((SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
			FROM	Billback_Program
				INNER JOIN	Billback_Product
				ON
				( (Billback_Product.Billback_ID = Billback_Program.Billback_ID) 
						AND
					(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
					AND
					(Billback_Product.Deleted = 0)
				)
				INNER JOIN	Billback_Product_Detail
				ON
				(	Billback_Product_Detail.Billback_ID = Billback_Product.Billback_id
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
				)
			WHERE
				Billback_Program.Billback_Program_ID = '#Billback_Program_ID#'
			GROUP BY Billback_Program.Billback_Program_ID
			), 0)  + 
			IsNull((SELECT	SUM(CAST(Billback_Program_Lumpsum_Component.Amount AS FLOAT))
			FROM	Billback_Program
				INNER JOIN	 Billback_Program_Lumpsum_Component
				ON
				(
					(Billback_Program_Lumpsum_Component.Billback_Program_ID = Billback_Program.Billback_Program_ID)
					AND
					( Billback_Program_Lumpsum_Component.Deleted = 0)
				)
			WHERE
				Billback_Program.Billback_Program_ID = '#Billback_Program_ID#'
			GROUP BY Billback_Program.Billback_Program_ID), 0)
			) AS BB_Dollar_Amount
			-----------------Total Amount claimed for this program
	FROM	Billback_Program	
	INNER JOIN BB_Program_Deviation_Info
		ON
		(
			(BB_Program_Deviation_Info.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(BB_Program_Deviation_Info.Deleted = 0)
		)
	WHERE	
		Billback_Program.Billback_Program_ID = '#Billback_Program_ID#'
		AND
		Billback_Program.Deleted = 0
</CFQUERY>

<CFOUTPUT>
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="60%">	
	<TR>
		<TD>Deviation percentage</TD>
		<TD>A1</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>
		<CFSET Deviation_Percent=100>
		<CFIF ISNumeric(Billback_Program_Payee_Deviation_Info.BB_Dollar_Amount) AND Billback_Program_Payee_Deviation_Info.BB_Dollar_Amount NEQ "" AND Billback_Program_Payee_Deviation_Info.BB_Dollar_Amount NEQ 0>
			<CFSET Deviation_Percent=Evaluate("(#Billback_Program_Payee_Deviation_Info.Unauthorized_Payee# * 100)/#Billback_Program_Payee_Deviation_Info.BB_Dollar_Amount#")>
		</CFIF>	
		#NumberFormat(Deviation_Percent, DEVIATION_PERCENT_FORMAT)#%
		</TD>
	</TR>
	<TR>
		<TD>Total Amount claimed for this program</TD>
		<TD>A2</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>#DollarFormat(Billback_Program_Payee_Deviation_Info.BB_Dollar_Amount)#</TD>
	</TR>
	<TR>
		<TD>Deviated Amount</TD>
		<TD>A3 = A1 * A2</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>
		#DollarFormat(Billback_Program_Payee_Deviation_Info.Unauthorized_Payee)#
		</TD>
	</TR>
</TABLE>
</CFOUTPUT>
	<BR><BR>
<DIV ALIGN="center">
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
		</DIV>	
		<BR><BR>


</BLOCKQUOTE>
</BODY>
</HTML>

