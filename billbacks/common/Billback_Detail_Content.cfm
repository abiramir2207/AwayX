<CFIF LEN(trim(Billback_ID)) EQ 0>
	<CFLOCATION url="../search_screens/search_billbacks.cfm">
	<cfabort>
</CFIF>
<!---------------------------------------------------
This Page generates the Content for Billback Detail
---------------------------------------------------->
<style>

	#cellLabel
		{
			<!--- font-family:Arial; --->
			font-size: 11px;
			font-weight: bold;
			vertical-align : top;
		}

	#dataStyle
		{
			font-size: 11px;
		}

	TD
		{
			font-family:Arial;
		}
	HR
		{
			color: Navy;
		}

	.LeftRightBorder
	{
		border-left:solid #93BEE2 1px;
		border-right:solid #93BEE2 1px;
		border-top:solid #93BEE2 1px;
		font-size : 10px;
	}
	TABLE.LeftRightBorder TD
	{
		border-bottom:solid #93BEE2 1px; font-size : 10px;
	}
	.ThreeBorders
	{
	border-left:solid ffe4b5 1px;
	border-right:solid ffe4b5 1px;
	border-bottom:solid ffe4b5 1px;
	font-size: 10px;
	font-family: arial;
	}
	.RegularText
	{
	font-size: 10px;
	font-family: arial;
	}
	DIV.BreakHere
	{
		page-break-before: always;
	}
	body {
	font-family: Arial;
	background-color: white
	}
</style>
<script language="javascript">
		function expandMenu(objectID, parentID) {
			var object = document.getElementById("TR_"+objectID);
			var parent = document.getElementById(parentID);
			tempVar = eval("document.all.TR_"+objectID);
			var myPIcon = document.getElementById("picon_" + objectID);

			if (parent == null){
				object.style.display='none';
				return;
			}

			if (object.style.display =='block')  {
				myPIcon.src="/images/plus.gif";
				object.style.display='none';
				for(var x=0; x<tempVar.length;x++){
					tempVar[x].style.display = 'none';
				}
			}
			else {
				myPIcon.src="/images/minus.gif";
				object.style.display='block';
					for(var x=0; x<tempVar.length;x++){
					tempVar[x].style.display = 'block';
				}
			}
			return;
		}
</script>

<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_Display_Style.cfm">
<!---Gets application settings--->
<cfset BillbackSettingsManager = CreateObject("component", "components.billback.BillbackSettingsManager") />
<cfset getSubtotalDisplaySettings = BillbackSettingsManager.getSubtotalDisplaySettings()>
<cfparam name="url.SHOW_PRINT_VERSION" default="0">
<cfparam name="url.show_email_version" default="0">

<cfscript>
	// 33278 - added case, pound labels
	label.CFC = CreateObject("component","components.settings.labels.labels").init();
	label.query = label.CFC.getGeneralLabels( 'case plural' );
	label.case_plural = label.query.General_Labels_Label;
	label.query = label.CFC.getGeneralLabels( 'pound plural' );
	label.pound_plural = label.query.General_Labels_Label;
</cfscript>

<CFOUTPUT>
<!--- Get the Billback number --->
<cfquery name="Get_Billback_Info" datasource="#application.datasource#">
SELECT	  	BB_Code, BB_Title, BB_Reference, BB_Date, BB_Start_Date, BB_End_Date, BB_Amount, BB_Creator_Notes, Comments
FROM		Billback
WHERE
Billback.Deleted = <cfqueryparam value=0>
AND
Billback.Billback_ID = <cfqueryparam value='#Billback_ID#'>
</cfquery>

<CFSET Billback_Payable_Number=Get_Billback_Info.BB_Code>
<CFSET Billback_Billback_Title=Get_Billback_Info.BB_Title>
<cfparam name ="BB_group_Id" default="">
<cfquery name="Get_Payee_Info" datasource="#application.datasource#">
	SELECT
	------------------------Name
	CASE
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

	<!--- The billback may have an associated distributor when the payee is an operator OR broker. --->
	,CASE bb.Billback_Payee_Type_ID
		WHEN 2
			THEN
				Billback_Operator.Associated_Ship_to
		WHEN 3
			THEN
				Billback_Broker.Associated_Ship_to

		ELSE
			NULL
		END

	As Associated_Ship_to

	FROM
	Billback bb
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
	bb.Deleted = <cfqueryparam value=0>
	AND
	bb.Billback_ID = <cfqueryparam value='#Billback_ID#'>
</cfquery>


<table BORDER="0" WIDTH="99%" ALIGN="CENTER" BGCOLOR="ffffff" CELLPADDING="1" CELLSPACING="0">
	<CAPTION ALIGN="LEFT">
	<FONT SIZE="+2" COLOR="Red" FACE="Times New Roman">#application.returned_customer_setting.company_name#</FONT>
	</CAPTION>
	<TR>
		<TD COLSPAN="100%" BGCOLOR=""><B><FONT SIZE="+1" COLOR="Navy">Payable Number: #Billback_Payable_Number#</FONT></B><HR COLOR="Navy"></TD>
	</TR>
	<TR VALIGN="top">
		<TD ID="cellLabel">Payee:</TD>
		<TD rowspan="100%"><img src="/images/fill.gif" width="10"></TD>
		<TD ID="dataStyle" WIDTH="100%">
		#UCASE(Get_Payee_Info.Payee_Name)#
		<CFIF Len(Trim(Get_Payee_Info.City)) GT 0 AND Len(Trim(Get_Payee_Info.State_Code)) GT 0>
		<BR>#Get_Payee_Info.City#,#Get_Payee_Info.State_Code#
		</CFIF>
		</TD>
	</TR>
	<TR>
		<TD ID="cellLabel">Title:</TD>
		<TD ID="dataStyle" WIDTH="100%">#Billback_Billback_Title#</TD>
	</TR>
	<TR>
		<TD ID="cellLabel" NOWRAP>Billback Number:</TD>
		<TD ID="dataStyle" WIDTH="100%">#Get_Billback_Info.BB_Reference#</TD>
	</TR>
	<TR>
		<TD ID="cellLabel" NOWRAP>Billback date:</TD>
		<TD ID="dataStyle" WIDTH="100%">#DateFormat(Get_Billback_Info.BB_Date, 'MMMM DD, YYYY')#</TD>
	</TR>
	<TR>
		<TD ID="cellLabel" NOWRAP>Period:</TD>
			<TD ID="dataStyle">
			 #MonthAsString(datepart('m', Get_Billback_Info.BB_Start_Date))#&nbsp;#datepart('d', Get_Billback_Info.BB_Start_Date)#,&nbsp;#datepart('yyyy', Get_Billback_Info.BB_Start_Date)#
			to
			 #MonthAsString(datepart('m', Get_Billback_Info.BB_End_Date))#&nbsp;#datepart('d', Get_Billback_Info.BB_End_Date)#,&nbsp;#datepart('yyyy', Get_Billback_Info.BB_End_Date)#
			</TD>
	</TR>
	<TR>
		<TD ID="cellLabel" NOWRAP>Claimed Amount:</TD>
		<TD ID="dataStyle">#trim(Dollarformat(Get_Billback_Info.BB_Amount))#</TD>
	</TR>
	<TR>
		<TD ID="cellLabel" NOWRAP>Notes:</TD>
		<TD ID="dataStyle">#Get_Billback_Info.BB_Creator_Notes#</TD>
	</TR>
	<TR style="display:none;"><TD></TD></TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</CFOUTPUT>
<CFSILENT>
	<CFSET SHOW_DEVIATION_DETAIL_HEADER = False>
	<CFSET SHOW_DEVIATION_DETAIL_FOOTER = False>
	<CFSET Discount_Type_List="Fixed Price, #Application.RebateLabel#, #Application.LumpsumLabel#, Growth, Formula Price">


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Program Lumpsum, Growth and Products
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->


<!---------------------- Get All Growth ----------------------------->
<CFQUERY  dataSource="#application.datasource#" NAME="Get_Program_Growth">
	SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) AS Total_Growth,
			Billback_Program.Billback_Program_ID,
			ISNull(Expected_Amount, 0) AS Expected_Amount,
			ISNull(BB_Growth_Amount, 0) AS BB_Growth_Amount,
			ISNull(Paid_Amount, 0) AS BB_Approved_Amount
	FROM
			Billback
			INNER JOIN Billback_Program
			ON
			(
				(Billback_Program.Billback_ID = Billback.Billback_ID)
				AND
				(Billback_Program.Deleted = 0)
			)
			INNER JOIN 	Billback_product
			ON
			(	(Billback_Product.Billback_ID = '#Billback_ID#')
				AND
				(Billback_product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(Billback_product.Deleted = 0)
			)
			INNER JOIN Billback_Product_Detail
			ON
			(	(Billback_Product_Detail.Billback_ID = '#Billback_ID#')
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
			LEFT JOIN BB_Growth_Program
			ON
			(
				(BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(BB_Growth_Program.Deleted = 0)
			)
		WHERE
			Billback.Billback_ID = <cfqueryparam value='#Billback_ID#'>
		GROUP BY Billback_Program.Billback_Program_ID, BB_Growth_Program.Deviated_Amount
					, Expected_Amount, BB_Growth_Amount, Paid_Amount
</CFQUERY>


<!---------------------- LumpsUm --------------------------->
<cfquery name="Get_Program_Lumpsum" datasource="#application.datasource#">
	SELECT     	Billback_Program_Lumpsum_Component.Billback_Program_ID
				, SUM(CAST(Amount AS FLOAT)) Total_Program_Lumpsum_Amount,
				ISNull(BB_Lump_Sums.LS_Expected_Amount, 0) AS Expected,
				ISNull(LS_Billback_Amount, 0) AS Billback,
				ISNull(LS_Paid_Amount, 0) AS Approved
	FROM       Billback_Program_Lumpsum_Component
				LEFT JOIN BB_Lump_Sums
				ON
				(
					(BB_Lump_Sums.Billback_Program_ID = Billback_Program_Lumpsum_Component.Billback_Program_ID)
				)
	WHERE
			(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
			AND
			(LEN(Billback_Program_Lumpsum_Component.Amount) > <cfqueryparam value=0>)
			AND
			(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = <cfqueryparam value=1>)
			AND
			(CAST(Billback_Program_Lumpsum_Component.Amount AS Float) > <cfqueryparam value=0>)
			AND
			Billback_Program_Lumpsum_Component.Billback_ID 		= <cfqueryparam value='#Billback_ID#'>
			AND
			Billback_Program_Lumpsum_Component.Deleted 			= <cfqueryparam value=0>
	GROUP BY Billback_Program_Lumpsum_Component.Billback_Program_ID, BB_Lump_Sums.Lump_Sum_Deviation
			, BB_Lump_Sums.LS_Expected_Amount, LS_Billback_Amount, LS_Paid_Amount
	ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
</CFQUERY>

<cfquery name="Get_Billback_Lumpsum" datasource="#application.datasource#">
	SELECT     	Billback_Program_Lumpsum_Component.Billback_Program_ID
				, Billback_Program_Lumpsum_Component_ID
				, CAST(Amount AS FLOAT) BB_Lumpsum_Amount
				, Component_Type_ID
				,CASE
				WHEN Component_Type_ID = 1 THEN
					Program_Lump_Sums.Lump_Sum_Name
				WHEN Component_Type_ID = 3 THEN
					Program_Growth_Components.Component_Name + ' Tier ' + Program_Growth_Component_Tiers.Tier_Number
				ELSE
					Billback_Program_Lumpsum_Component.Name
				END AS Component_Name
	FROM       	Billback_Program_Lumpsum_Component
				LEFT JOIN Program_Lump_Sums
				ON
				Program_Lump_Sums.Program_Lump_Sum_ID =	Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
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
	WHERE
			Billback_Program_Lumpsum_Component.Billback_ID 		= <cfqueryparam value='#Billback_ID#'>
			AND
			Billback_Program_Lumpsum_Component.Deleted 			= <cfqueryparam value=0>
	ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
	</CFQUERY>

<cfset productGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
<cfset ProductGroupType	= productGroupAttributeManager.getProductGroupAttributes(groupLevelId = getSubtotalDisplaySettings.Group_Claim_By_Product_Attribute) />

<cfquery name="Get_Program_Products" datasource="#application.datasource#">
SELECT	Billback_Program.Billback_Program_ID, Billback_Product.Billback_Product_ID, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Billback_Product.BB_Product_Quantity, Units_Of_Measure.Unit_Of_Measure_Desc, Billback_Product.BB_Product_UOM,contract_main.contract_main_id,
<cfif getSubtotalDisplaySettings.Display_Product_Group_BB EQ 1>
#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD# as Group_Name_Id,
cast(#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# as nvarchar(50)) as Group_Id,
<cfelse>
'' as Group_Name_Id, '' as Group_Id,
</cfif>
			Program_Control_Panel_Options.Generic_Type,
			<!---The item selections--->
			BB_Item_Final.BB_Item_Final_ID,
			BB_Item_Final_Detail.BB_Item_Final_Detail_ID,
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final_Detail.Expected_rate_CS, 0)
			ELSE
				ISNULL(BB_Item_Final_Detail.Expected_rate_LB, 0)
			END AS Expected_Rate,
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final_Detail.Billback_Rate_CS, 0)
			ELSE
				ISNULL(BB_Item_Final_Detail.Billback_Rate_LB, 0)
			END AS Billback_Rate,
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final_Detail.Paid_Rate_CS, 0)
			ELSE
				ISNULL(BB_Item_Final_Detail.Paid_Rate_LB, 0)
			END AS Approved_Rate,
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final.Item_BB_Volume_CS, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_BB_Volume_LB, 0)
			END AS Item_BB_Volume,
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final.Item_E_Volume_CS, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_E_Volume_LB, 0)
			END AS Item_E_Volume,
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final.Item_Volume_Paid_CS, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_Volume_Paid_LB, 0)
			END AS Item_Approved_Volume,
			ISNULL(CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final.Item_Volume_Paid_CS, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_Volume_Paid_LB, 0)/net_weight
			END,0) AS Item_Approved_Volume_CS,
			ISNULL(CASE
			WHEN Billback_Product.BB_Product_UOM = 2 THEN
				ISNULL(BB_Item_Final.Item_Volume_Paid_LB, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_Volume_Paid_CS, 0)* net_weight
			END,0) AS Item_Approved_Volume_LB,
				ISNULL(CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final.Item_E_Volume_CS, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_E_Volume_CS, 0)/net_weight
			END,0) AS Item_Expected_Volume_CS,
			ISNULL(CASE
			WHEN Billback_Product.BB_Product_UOM = 2 THEN
				ISNULL(BB_Item_Final.Item_E_Volume_LB, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_E_Volume_CS, 0)* net_weight
			END,0) AS Item_Expected_Volume_LB,
			ISNULL(CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final.Item_BB_Volume_CS, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_BB_Volume_CS, 0)/net_weight
			END,0) AS Item_BB_Volume_CS,
			ISNULL(CASE
			WHEN Billback_Product.BB_Product_UOM = 2 THEN
				ISNULL(BB_Item_Final.Item_BB_Volume_LB, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_BB_Volume_CS, 0)* net_weight
			END,0) AS Item_BB_Volume_LB,
			CASE
			WHEN Billback_Program.Program_ID IS NULL THEN
				Billback_Program.BB_Program_Title
			ELSE
				Contract_Main.Contract_Title
			END AS Program_Title
			,CASE
			WHEN Billback_Program.Program_ID IS NULL THEN
				Billback_Program.BB_Program_Number
			ELSE
				Contract_Main.Contract_Number
			END AS Program_Number
			,CASE
			WHEN Billback_Product.Product_ID IS NULL THEN
				Billback_Product.BB_Unknown_Product_Item_Number
			ELSE
				BSA_Foodservice_Items_Master.Item
			END AS Item_Number
			,CASE
			WHEN Billback_Product.Product_ID IS NULL THEN
				Billback_Product.BB_Unknown_Product_Description
			ELSE
				BSA_Foodservice_Items_Master.Description
			END AS Description,
			Net_Weight,
			Billback_Product_Detail.Billback_Product_Detail_ID, Billback_Product_Detail.BB_Product_Type_ID, Billback_Product_Detail.BB_Rate

			<!--- The billback may have an associated distributor when the payee is an operator OR broker. --->
			,CASE Billback.Billback_Payee_Type_ID
				WHEN 2
					THEN
						Billback_Operator.Associated_Ship_to
				WHEN 3
					THEN
						Billback_Broker.Associated_Ship_to
				ELSE
					NULL

				END

			As Associated_Ship_to

	FROM
			Billback
			INNER JOIN
			(
				Billback_Program
				LEFT JOIN	Contract_Main
				ON
				(
					(Billback_Program.Program_ID = Contract_Main.Contract_Main_ID)
				)
				LEFT JOIN	Program_Control_Panel_Options
				ON
				(
					(Program_Control_Panel_Options.ProgramControl_Panel_Options_ID  = Contract_Main.ProgramType_ID)
				)
			)
			ON
			(
				(Billback_Program.Billback_ID = Billback.Billback_ID)
				AND
				(Billback_Program.Deleted = 0)
			)
			LEFT JOIN
			(
				Billback_Product
				LEFT JOIN	BSA_Foodservice_Items_Master
				ON
				(	(Billback_Product.Billback_ID = '#Billback_ID#')
					AND
					(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID=Billback_Product.Product_ID)
					AND
					(BSA_Foodservice_Items_Master.Deleted = 0)
				)
				LEFT JOIN	Units_of_Measure
				ON
					(Units_of_Measure.Unit_Of_Measure_ID = Billback_Product.BB_Product_UOM)
			)
			RIGHT JOIN	Billback_Product_Detail
			ON
			(	(Billback_Product_Detail.Billback_ID = '#Billback_ID#')
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
				(Billback_Product_Detail.BB_Product_Type_ID IN (1,2,5,10,11))
			)
		ON
		(
			(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(Billback_Product.Deleted = 0)
		)
		LEFT JOIN BB_Item_Final
		ON
		(	(BB_Item_Final.Billback_ID = '#Billback_ID#')
			AND
			BB_Item_Final.Billback_Product_ID = Billback_Product.Billback_Product_ID
			AND
			BB_Item_Final.Deleted =0
		)
		LEFT JOIN BB_Item_Final_Detail
		ON
		(
			BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID
			AND
			BB_Item_Final_Detail.Deleted = 0
			AND
			BB_Item_Final_Detail.BB_Product_Type = Billback_Product_Detail.BB_Product_Type_ID
		)
		LEFT JOIN Billback_Operator
		ON
		(
		Billback.Billback_ID = Billback_Operator.Billback_ID
		AND Billback_Operator.Deleted = 0
		)
		LEFT JOIN Billback_Broker
		ON
		(
		Billback.Billback_ID = Billback_Broker.Billback_ID
		AND Billback_Broker.Deleted = 0
		)
		<cfif getSubtotalDisplaySettings.Display_Product_Group_BB EQ 1>
		left join #ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE# on
		#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# = BSA_Foodservice_Items_Master.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD#
		</cfif>
WHERE
			Billback.Billback_ID = <cfqueryparam value='#Billback_ID#'>
ORDER BY 	Billback_Program.Billback_Program_ID,
<cfif getSubtotalDisplaySettings.Display_Product_Group_BB EQ 1>
#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD#,
</cfif>
Billback_Product.Billback_Product_ID, Billback_Product_Detail.BB_Product_Type_ID
</cfquery>

	<CFSET Deviation_Show_Expected_Values = 1>
	<CFSET SHOW_IMAGE = 0>

	<CFSET ADDSCRIPT = "No">
	<CFSET USEIMGGRAPH = false>
</CFSILENT>
	<CFIF NOT IsDefined("INC_Deviation_Constants")>
		<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_Constants.CFM">
	</CFIF>
	<CFIF NOT IsDefined("INC_Date_Graph_Settings")>
		<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Date_Graph_Settings.cfm">
	</CFIF>

<cfsilent>
<CFSET Total_Billback_Amount = 0>
<CFSET Total_Billback_Deviation = 0>
<CFSET Total_Approved_Billback_Amount = 0>
</cfsilent>
<TR>
		<TD COLSPAN="100%">
			<BR>
				<B><FONT SIZE="2" COLOR="Navy">Programs and Products</FONT></B>
</TD>
</TR>
</TABLE>
<TABLE CELLPADDING="2" id="programsproducts" CELLSPACING="0" BORDER="0" WIDTH="98%" ALIGN="center">
	<TR BGCOLOR="FFFACD">
		<Td WIDTH="25%" nowrap>&nbsp;</Td>
		<cfoutput>
		<Td width="8%" align="right"><b>#label.pound_plural#</b></TD>
		<Td width="8%" align="right"><b>#label.case_plural#</b></TD>
		<Td width="9%" align="right"><b>Claimed</b></TD>
		<Td width="8%" align="right"><b>#label.pound_plural#</b></TD>
		<TD width="8%" align="right"><b>#label.case_plural#</b></TD>
		<TD width="9%" align="right"><b>Expected</b></TD>
		<Td width="8%" align="right"><b>#label.pound_plural#</b></TD>
		<TD width="8%" align="right"><b>#label.case_plural#</b></TD>
		</cfoutput>
		<TD width="9%" align="right"><b>Approved/Paid</b></TD>
	</TR>
	<CFIF Get_Program_Products.RecordCount GT 0>
	<cfsilent>
	<cfquery name="getgroupdistintitemdetails" dbtype="query">
	select distinct Item_BB_Volume_CS, Item_BB_Volume_LB,
	Item_Expected_Volume_CS,Item_Expected_Volume_LB,
	Item_Approved_Volume_CS,Item_Approved_Volume_LB,group_id,billback_program_id,
	Billback_Product_ID
	from Get_Program_Products
	</cfquery>
		<cfset total_BB_approved_volume_lb = 0>
		<cfset total_BB_approved_volume_cs = 0>
		<cfset total_BB_expected_volume_lb = 0>
		<cfset total_BB_expected_volume_cs = 0>
		<cfset total_BB_claimed_volume_lb = 0>
		<cfset total_BB_claimed_volume_cs = 0>
		<CFSET Total_Expected_Amount = 0>
		<CFSET Total_Claimed_Amount = 0>
		<cfset Total_Approved_Amount = 0>
	</cfsilent>
		<CFOUTPUT QUERY="Get_Program_Products" GROUP="Billback_Program_ID">
		<cfsilent>
		<CFSET Total_Approved_Program_Amount = 0>
		<CFSET Total_Expected_Program_Amount = 0>
		<CFSET Total_Claimed_Program_Amount = 0>
		</cfsilent>
			<!--- Programs ---->
			<TR CLASS="programTD">
				<TD COLSPAN="100%" style="font-size:9px">
[#Get_Program_Products.Program_Number#] #Get_Program_Products.Program_Title#</TD>
			</TR>
			<cfsilent>
			<!------ Start Lumpsum ---------------->
			<CFQUERY DBTYPE="query" NAME="This_Program_lumpsum">
			SELECT	*
			FROM	Get_Program_Lumpsum
			WHERE
					Billback_Program_ID = '#Billback_Program_ID#'
			</CFQUERY>
			<CFQUERY DBTYPE="query" NAME="This_Billback_lumpsum">
			SELECT	*
			FROM	Get_Billback_Lumpsum
			WHERE
					Billback_Program_ID = '#Billback_Program_ID#'
			</CFQUERY>
			<CFQUERY DBTYPE="query" NAME="This_Billback_lumpsum_Sum">
			SELECT	SUM(BB_Lumpsum_Amount) AS BB_Lump_Total
			FROM	Get_Billback_Lumpsum
			WHERE
					Billback_Program_ID = '#Billback_Program_ID#'
			</CFQUERY>
			</cfsilent>
			<CFIF This_Program_lumpsum.recordCount GT 0>
				<TR CLASS="lumpsumInTR">
				<TD align="left" width="25%" style="font-size:9px">
				#Application.LumpsumLabel#</TD>
				<!--- <TD colspan="4">&nbsp;<!----#LSCurrencyFormat(This_Billback_lumpsum_Sum.BB_Lump_Total)#----></TD><!--- BB ---> --->
				<td colspan="5">&nbsp;</td>
				<TD align="right" width="9%" style="font-size:9px">
#LSCurrencyFormat(This_Program_lumpsum.Expected)#</TD><!--- EX --->			<td colspan="2">&nbsp;</td>
				<TD align="right" width="9%" style="font-size:9px">
#LSCurrencyFormat(This_Program_lumpsum.Approved)#</TD><!--- Paid --->
				</TR>
				<cfsilent>
				<CFSET Total_Approved_Billback_Amount = Total_Approved_Billback_Amount + This_Program_lumpsum.Approved>
				<CFSET Total_Approved_Program_Amount = Total_Approved_Program_Amount + This_Program_lumpsum.Approved>
				<CFSET Total_Expected_Program_Amount = Total_Expected_Program_Amount + This_Program_lumpsum.Expected>
				<CFSET Total_Claimed_Program_Amount = Total_Claimed_Program_Amount + This_Billback_lumpsum_Sum.BB_Lump_Total>
				</cfsilent>
				<CFLOOP QUERY="This_Billback_lumpsum">
					<TR CLASS="lumpsumTD">
						<TD  style="font-size:9px">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#This_Billback_lumpsum.Component_Name#</TD>
<td colspan="2">&nbsp;</td>
<TD align="right" style="font-size:9px">
#LSCurrencyFormat(This_Billback_lumpsum.BB_Lumpsum_Amount)#</TD>
<td colspan="2">&nbsp;</td>
<TD align="right" style="font-size:9px">
#LSCurrencyFormat(This_Program_lumpsum.Expected)#</TD><!--- EX --->
<td colspan="2">&nbsp;</td>
<TD align="right" style="font-size:9px">
#LSCurrencyFormat(This_Program_lumpsum.Approved)#</TD><!--- Paid --->
					</TR>
				</CFLOOP>
			</CFIF>
			<cfsilent>
			<!---------- Start Growth Get_Program_Growth --------->
			<CFQUERY DBTYPE="query" NAME="This_Program_Growth">
			SELECT	*
			FROM	Get_Program_Growth
			WHERE
					Billback_Program_ID = '#Billback_Program_ID#'
			</CFQUERY>
			</cfsilent>
			<CFIF This_Program_Growth.recordCount GT 0>
				<TR CLASS="growthInTR">
				<TD style="font-size:9px">Growth</TD>
				<td colspan="2">&nbsp;</td>
				<TD align="right" style="font-size:9px">
#LSCurrencyFormat(This_Program_Growth.BB_Growth_Amount)# </TD><!--- BB --->
				<td colspan="2">&nbsp;</td>
				<TD align="right" style="font-size:9px">
#LSCurrencyFormat(This_Program_Growth.Expected_Amount)#</TD><!--- EX --->
				<td colspan="2">&nbsp;</td>
				<TD align="right" style="font-size:9px">
#LSCurrencyFormat(This_Program_Growth.BB_Approved_Amount)#</TD><!--- Paid --->
				</TR>
				<cfsilent>
				<CFSET Total_Approved_Billback_Amount = Total_Approved_Billback_Amount + This_Program_Growth.BB_Approved_Amount>
				<CFSET Total_Approved_Program_Amount = Total_Approved_Program_Amount + This_Program_Growth.BB_Approved_Amount>
				<CFSET Total_Expected_Program_Amount = Total_Expected_Program_Amount + This_Program_Growth.Expected_Amount>
				<CFSET Total_Claimed_Program_Amount = Total_Claimed_Program_Amount + This_Program_Growth.BB_Growth_Amount>
				</cfsilent>
			</CFIF>

			<!---------- Start Products --------------->
			<CFIF Billback_Product_ID NEQ "">
			<cfoutput group="Group_Id">
			<cfif getSubtotalDisplaySettings.Display_Product_Group_BB EQ 1>
			<cfsilent>
			<cfset BB_group_Id = replace(Get_Program_Products.Group_Id, "-","_","ALL")>

			<cfquery name="getgroupdetails" dbtype="query">
			select sum(Item_BB_Volume * Billback_rate) as claimed_amount,
			sum(Item_E_Volume * Expected_Rate) as expected_amount,
			sum(Item_Approved_Volume * Approved_rate) as approved_amount
			from Get_Program_Products where group_id = '#Get_Program_Products.Group_Id#'
			and billback_program_id = '#Get_Program_Products.billback_program_id#'
			</cfquery>
			<cfquery name="getgroupvolumedetails" dbtype="query">
			select
			SUM(Item_BB_Volume_CS) as claimed_volume_cs,
			SUM(Item_BB_Volume_LB) as claimed_volume_lb,
			SUM(Item_Expected_Volume_CS) as expected_volume_cs,
			SUM(Item_Expected_Volume_LB) as expected_volume_lb,
			SUM(Item_Approved_Volume_CS) as approved_volume_cs,
			SUM(Item_Approved_Volume_LB) as approved_volume_lb
			from getgroupdistintitemdetails where group_id = '#Get_Program_Products.Group_Id#'
			and billback_program_id = '#Get_Program_Products.billback_program_id#'
			</cfquery>
			</cfsilent>
			<tr>
			<td valign="top" width="25%" style="font-size:9px">
			<a id="#Get_Program_Products.contract_main_id#_#BB_group_Id#_m1" href="javascript:expandMenu('#Get_Program_Products.contract_main_id#_#BB_group_Id#','#Get_Program_Products.contract_main_id#_#BB_group_Id#_m1');"><cfif url.SHOW_PRINT_VERSION EQ 0 and url.show_email_version EQ 0><img src="/images/plus.gif" border="0" width=10 id="picon_#Get_Program_Products.contract_main_id#_#BB_group_Id#" height=10><cfelse><img src="/images/minus.gif" border="0" width=10 id="picon_#Get_Program_Products.contract_main_id#_#BB_group_Id#" height=10></cfif>
	#Get_Program_Products.Group_Name_Id#</a> </td>
			<cfif getgroupdetails.recordcount GT 0>
			<td valign="top" width="8%" align="right" style="font-size:9px">
#numberformat(getgroupvolumedetails.claimed_volume_lb,"___,___,___,___")#</td>
			<td valign="top" width="8%" align="right" style="font-size:9px">
#numberformat(getgroupvolumedetails.claimed_volume_cs,"___,___,___,___")#</td>
			<TD align="right" valign="top" width="9%" style="font-size:9px">
#LSCurrencyFormat(getgroupdetails.claimed_amount)#
			<cfsilent>
				<cfif getgroupvolumedetails.claimed_volume_cs NEQ 0>
				<cfset G_BB_Rate_CS = getgroupdetails.claimed_amount/getgroupvolumedetails.claimed_volume_cs>
				<cfelse>
				<cfset G_BB_Rate_CS = 0>
				</cfif>
				<cfif getgroupvolumedetails.claimed_volume_lb NEQ 0>
				<cfset G_BB_Rate_lb = getgroupdetails.claimed_amount/getgroupvolumedetails.claimed_volume_lb>
				<cfelse>
				<cfset G_BB_Rate_lb = 0>
				</cfif>
			</cfsilent><br>
				#LSCurrencyFormat(G_BB_Rate_CS)#/cs<br>
				#LSCurrencyFormat(G_BB_Rate_lb)#/lb
</TD><!--- BB --->
<td valign="top" align="right" width="8%" style="font-size:9px"> #numberformat(getgroupvolumedetails.expected_volume_lb,"___,___,___,___")#</td>
<td valign="top" align="right" width="8%" style="font-size:9px">
#numberformat(getgroupvolumedetails.expected_volume_cs,"___,___,___,___")#</td>
<TD align="right" valign="top" width="9%" style="font-size:9px">
#LSCurrencyFormat(getgroupdetails.expected_amount)#
			<cfsilent>
				<cfif getgroupvolumedetails.expected_volume_cs NEQ 0>
				<cfset G_E_Rate_CS = getgroupdetails.expected_amount/getgroupvolumedetails.expected_volume_cs>
				<cfelse>
				<cfset G_E_Rate_CS = 0>
				</cfif>
				<cfif getgroupvolumedetails.expected_volume_lb NEQ 0>
				<cfset G_E_Rate_lb = getgroupdetails.expected_amount/getgroupvolumedetails.expected_volume_lb>
				<cfelse>
				<cfset G_E_Rate_lb = 0>
				</cfif>
			</cfsilent><br>
				#LSCurrencyFormat(G_E_Rate_cs)#/cs<br>
				#LSCurrencyFormat(G_E_Rate_lb)#/lb
			</TD><!--- EX --->
			<td valign="top" align="right" width="8%" style="font-size:9px">
#numberformat(getgroupvolumedetails.approved_volume_lb,"___,___,___,___")#</td>
			<td valign="top" align="right" width="8%" style="font-size:9px">
#numberformat(getgroupvolumedetails.approved_volume_cs,"___,___,___,___")#</td>
			<TD align="right" width="9%" valign="top" style="font-size:9px">
#LSCurrencyFormat(getgroupdetails.approved_amount)#
			<cfsilent>
				<cfif getgroupvolumedetails.approved_volume_cs NEQ 0>
				<cfset G_A_Rate_CS = getgroupdetails.approved_amount/getgroupvolumedetails.approved_volume_cs>
				<cfelse>
				<cfset G_A_Rate_CS = 0>
				</cfif>
				<cfif getgroupvolumedetails.approved_volume_lb NEQ 0>
				<cfset G_A_Rate_lb = getgroupdetails.approved_amount/getgroupvolumedetails.approved_volume_lb>
				<cfelse>
				<cfset G_A_Rate_lb = 0>
				</cfif>
			</cfsilent><br>
				#LSCurrencyFormat(G_A_Rate_cs)#/cs<br>
				#LSCurrencyFormat(G_A_Rate_lb)#/lb
			</TD><!--- Paid --->
			<cfelse>
			<TD colspan="100%">&nbsp;</TD>
			</cfif>
			</tr>
			</cfif>
			<CFSET Current_Product_Volume = Item_Approved_Volume>
			<cfset productcount = 0>
				<CFOUTPUT GROUP="Billback_Product_ID">
				<cfsilent>
				<cfset productcount = productcount + 1>
				<cfset P_Billback_Amount =0>
				<cfset P_Expected_Amount = 0>
				<cfset P_Approved_Amount = 0>
				<CFIF BB_Product_Type_ID NEQ "">
					<CFOUTPUT>
				<cfset P_Billback_Amount = P_Billback_Amount + Get_Program_Products.item_BB_Volume * Get_Program_Products.Billback_rate>
				<cfset P_Expected_Amount = P_Expected_Amount + Get_Program_Products.Item_E_Volume * Get_Program_Products.Expected_Rate>
				<cfset P_Approved_Amount = P_Approved_Amount+  Get_Program_Products.Item_Approved_Volume * Get_Program_Products.Approved_Rate>

				<CFSET Total_Approved_Billback_Amount = Total_Approved_Billback_Amount + (Get_Program_Products.Item_Approved_Volume * Get_Program_Products.Approved_Rate)>
				<CFSET Total_Approved_Program_Amount = Total_Approved_Program_Amount + (Get_Program_Products.Item_Approved_Volume * Get_Program_Products.Approved_Rate)>
				<CFSET Total_Expected_Program_Amount = Total_Expected_Program_Amount + (Get_Program_Products.Item_E_Volume * Get_Program_Products.Expected_Rate)>
				<CFSET Total_Claimed_Program_Amount = Total_Claimed_Program_Amount + (Get_Program_Products.item_BB_Volume * Get_Program_Products.Billback_rate)>
					</CFOUTPUT>
				</CFIF>
	</cfsilent>
				<!--- CLASS="productTR" --->
				<cfif getSubtotalDisplaySettings.Display_Product_Group_BB EQ 0>
				<TR BGCOLOR="#IIf(productcount Mod 2, DE('FFFACD'), DE('ffffff'))#">
				<cfelse>
				<TR <cfif url.SHOW_PRINT_VERSION EQ 0 and url.show_email_version EQ 0>style="display:none"</cfif>  id="TR_#Get_Program_Products.contract_main_id#_#BB_group_Id#" BGCOLOR="#IIf(productcount Mod 2, DE('FFFACD'), DE('ffffff'))#">
				</cfif>
				<TD align="left" valign="top" style="font-size:9px" width="25%">
#Get_Program_Products.Item_Number#<br>#Left(Get_Program_Products.Description, 20)#</TD>
	<td valign="top" align="right" width="8%" style="font-size:9px" >
#numberformat(Get_Program_Products.Item_BB_Volume_LB,"___,___,___,___")#</td>
	<td valign="top" align="right" width="8%" style="font-size:9px">
#numberformat(Get_Program_Products.Item_BB_Volume_CS,"___,___,___,___")#</td>
	<TD align="right" valign="top" width="9%" style="font-size:9px">#LSCurrencyFormat(P_Billback_Amount)#
				<!--- <cfsilent>
				<cfif Item_BB_Volume_CS NEQ 0>
				<cfset P_BB_Rate_CS = P_Billback_Amount/Item_BB_Volume_CS>
				<cfelse>
				<cfset P_BB_Rate_CS = 0>
				</cfif>
				<cfif Item_BB_Volume_LB NEQ 0>
				<cfset P_BB_Rate_LB = P_Billback_Amount/Item_BB_Volume_LB>
				<cfelse>
				<cfset P_BB_Rate_LB = 0>
				</cfif>
				</cfsilent><br>
				#LSCurrencyFormat(P_BB_Rate_CS)#/cs<br>
				#LSCurrencyFormat(P_BB_Rate_lb)#/lb --->
				</TD><!--- BB --->
	<td valign="top" align="right" width="8%" style="font-size:9px">
#numberformat(Get_Program_Products.Item_Expected_Volume_LB,"___,___,___,___")#</td>
	<td valign="top" align="right" width="8%" style="font-size:9px">
#numberformat(Get_Program_Products.Item_Expected_Volume_CS,"___,___,___,___")#</td>
	<TD align="right" valign="top" width="9%" style="font-size:9px">
#LSCurrencyFormat(P_Expected_Amount)#</TD>
				<!--- <cfsilent>
				<cfif Item_Expected_Volume_CS NEQ 0>
				<cfset P_E_Rate_CS = P_Expected_Amount/Item_Expected_Volume_CS>
				<cfelse>
				<cfset P_E_Rate_CS = 0>
				</cfif>
				<cfif Item_Expected_Volume_LB NEQ 0>
				<cfset P_E_Rate_LB = P_Expected_Amount/Item_Expected_Volume_LB>
				<cfelse>
				<cfset P_E_Rate_LB = 0>
				</cfif>
				</cfsilent><br>
				#LSCurrencyFormat(P_E_Rate_CS)#/cs<br>
				#LSCurrencyFormat(P_E_Rate_lb)#/lb ---><!--- EX --->
	<td valign="top" align="right" width="8%"  style="font-size:9px">
#numberformat(Get_Program_Products.Item_Approved_Volume_LB,"___,___,___,___")#</td>
	<td valign="top" align="right" width="8%"  style="font-size:9px">
#numberformat(Get_Program_Products.Item_Approved_Volume_CS,"___,___,___,___")#</td>
	<TD align="right" valign="top" width="9%"  style="font-size:9px">
	#LSCurrencyFormat(P_Approved_Amount)#</TD>
				<!--- <cfsilent>
				<cfif Item_Approved_Volume_CS NEQ 0>
				<cfset P_A_Rate_CS = P_Approved_Amount/Item_Approved_Volume_CS>
				<cfelse>
				<cfset P_A_Rate_CS = 0>
				</cfif>
				<cfif Item_Approved_Volume_LB NEQ 0>
				<cfset P_A_Rate_LB = P_Approved_Amount/Item_Approved_Volume_LB>
				<cfelse>
				<cfset P_A_Rate_LB = 0>
				</cfif>
				</cfsilent><br>
				#LSCurrencyFormat(P_A_Rate_CS)#/cs<br>
				#LSCurrencyFormat(P_A_Rate_lb)#/lb ---><!--- Paid --->
				</TR>
				<!--- <CFIF BB_Product_Type_ID NEQ "">
					<CFOUTPUT>
						<TR CLASS="productInTR" id="#BB_group_Id#_m">
						<TD COLSPAN="1"></TD>
						<TD>#Trim(ListGetAt(Discount_Type_List,BB_Product_Type_ID,","))#</TD>
						<TD>#LSCurrencyFormat(Billback_rate)# / #Unit_Of_Measure_Desc#</TD>
						<TD>#LSCurrencyFormat(Expected_Rate)# / #Unit_Of_Measure_Desc#</TD>
						<TD>#LSCurrencyFormat(Approved_Rate)# / #Unit_Of_Measure_Desc#</TD>
						</TR>
						<CFSET Total_Approved_Billback_Amount = Total_Approved_Billback_Amount + Current_Product_Volume * Approved_Rate>
					</CFOUTPUT>
				</CFIF> --->
				</CFOUTPUT>
			</cfoutput>
			</CFIF>
		<cfsilent>
			<cfset BB_group_Id = replace(Get_Program_Products.Group_Id, "-","_","ALL")>
			<cfquery name="getBBprogramdetails" dbtype="query">
			select SUM(Item_BB_Volume_CS) as claimed_volume_cs,
			SUM(Item_BB_Volume_LB) as claimed_volume_lb,
			SUM(Item_Expected_Volume_CS) as expected_volume_cs,
			SUM(Item_Expected_Volume_LB) as expected_volume_lb,
			SUM(Item_Approved_Volume_CS) as approved_volume_cs,
			SUM(Item_Approved_Volume_LB) as approved_volume_lb
			from getgroupdistintitemdetails where billback_program_id = '#Get_Program_Products.billback_program_id#'
			</cfquery>
		<cfif getBBprogramdetails.recordcount GT 0>
		<cfset total_BB_approved_volume_lb = total_BB_approved_volume_lb + getBBprogramdetails.approved_volume_lb>
		<cfset total_BB_approved_volume_cs = total_BB_approved_volume_cs + getBBprogramdetails.approved_volume_cs>
		<cfset total_BB_expected_volume_lb = total_BB_expected_volume_lb + getBBprogramdetails.expected_volume_lb>
		<cfset total_BB_expected_volume_cs = total_BB_expected_volume_cs + getBBprogramdetails.expected_volume_cs>
		<cfset total_BB_claimed_volume_lb = total_BB_claimed_volume_lb + getBBprogramdetails.claimed_volume_lb>
		<cfset total_BB_claimed_volume_cs = total_BB_claimed_volume_cs + getBBprogramdetails.claimed_volume_cs>
		<CFSET Total_Expected_Amount = Total_Expected_Amount + Total_Expected_Program_Amount>
		<CFSET Total_Claimed_Amount = Total_Claimed_Amount + Total_Claimed_Program_Amount>
		<CFSET Total_Approved_Amount = Total_Approved_Amount + Total_Approved_Program_Amount>
	</cfif>
		</cfsilent>
		<TR>
		<!------Total Approved  Amount----->
		<TD width="25%" style="font-size:9px"><strong>Sub Total</strong> </TD>
		<td align="right" width="8%" style="font-size:9px">
<strong>#numberformat(getBBprogramdetails.claimed_volume_lb,"___,___,___,___")#</strong>
		</td>
		<td align="right" width="8%" style="font-size:9px">
	<strong>#numberformat(getBBprogramdetails.claimed_volume_cs,"___,___,___,___")#</strong>
		</td>
		<TD align="right" width="9%" style="font-size:9px">
		<strong>#DollarFormat(Total_Claimed_Program_Amount)#</strong>
		</TD>
		<td align="right" width="8%" style="font-size:9px">
	<strong>#numberformat(getBBprogramdetails.expected_volume_lb,"___,___,___,___")#</strong>
		</td>
		<td align="right" width="8%" style="font-size:9px">
	<strong>#numberformat(getBBprogramdetails.expected_volume_cs,"___,___,___,___")#</strong>
		</td>
		<TD align="right" width="9%" style="font-size:9px">
		<strong>#DollarFormat(Total_Expected_Program_Amount)#</strong></TD>
		<td align="right" width="8%" style="font-size:9px">
	<strong>#numberformat(getBBprogramdetails.approved_volume_lb,"___,___,___,___")#</strong>
		</td>
		<td align="right" width="8%" style="font-size:9px">
	<strong>#numberformat(getBBprogramdetails.approved_volume_cs,"___,___,___,___")#</strong>
		</td>
		<TD align="right" width="9%" style="font-size:9px">
		<strong>#DollarFormat(Total_Approved_Program_Amount)#</strong></TD>
	</TR>
	<tr>
		<TD STYLE="border-top:2px Navy solid;" colspan="100%">&nbsp;</TD>
	</tr>
		</CFOUTPUT>
<cfoutput>
<TR BGCOLOR="FFFACD" style="height:20px">
		<TD width="25%" nowrap style="font-size:9px"><strong>TOTAL</strong> </TD>
		<td align="right" width="8%" style="font-size:9px">
	<strong>#numberformat(total_BB_claimed_volume_lb,"___,___,___,___")#</strong>
		</td>
		<td align="right" width="8%" style="font-size:9px">
	<strong>#numberformat(total_BB_claimed_volume_cs,"___,___,___,___")#</strong>
		</td>
		<TD align="right" width="9%" style="font-size:9px">
		<strong>#DollarFormat(Total_Claimed_Amount)#</strong></TD>
		<td align="right" width="8%" style="font-size:9px">
	<strong>#numberformat(total_BB_expected_volume_lb,"___,___,___,___")#</strong>
		</td>
		<td align="right" width="8%" style="font-size:9px">
<strong>#numberformat(total_BB_expected_volume_cs,"___,___,___,___")#</strong>
		</td>
		<TD align="right" width="9%" style="font-size:9px">
		<strong>#DollarFormat(Total_Expected_Amount)#</strong></TD>
		<td align="right" width="8%" style="font-size:9px">
	<strong>#numberformat(total_BB_approved_volume_lb,"___,___,___,___")#</strong>
		</td>
		<td align="right" width="8%" style="font-size:9px">
	<strong>#numberformat(total_BB_approved_volume_cs,"___,___,___,___")#</strong>
		</td>
		<TD align="right" width="9%" style="font-size:9px">
		<strong>#DollarFormat(Total_Approved_Amount)#</strong>
		</TD>
	</TR>
	<tr>
		<TD STYLE="border-top:2px Navy solid;" colspan="100%">&nbsp;</TD>
	</tr>
</cfoutput>
	</CFIF>
</table>
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="99%" ALIGN="center">
	<CFOUTPUT>
	<cfsilent>
	<cfquery name="GetExclusions" datasource="#application.datasource#">
		SELECT 	BB_Program_Exclusion.BB_Program_Exclusion_ID,
				Contract_Main.Contract_Title, Contract_Main.Contract_Number,
				(SELECT SUM(Dollar_Amount) FROM BB_Product_Exclusion
				WHERE
				BB_Product_Exclusion.BB_Program_Exclusion_ID = BB_Program_Exclusion.BB_Program_Exclusion_ID)
				AS Exclusion_Total,
				Billback.BB_Code, Billback.BB_Title
		FROM 	BB_Program_Exclusion
				INNER JOIN Contract_Main
				ON Contract_Main.Contract_Main_ID = BB_Program_Exclusion.Program_ID
				AND Contract_Main.Deleted = 0
				INNER JOIN Billback
				ON
				Billback.Billback_ID = BB_Program_Exclusion.Billback_ID
		WHERE
				BB_Program_Exclusion.Exclusion_Deducted_From_BB_ID = <cfqueryparam value='#Billback_ID#'>
	</cfquery>
	</cfsilent>
	<CFIF GetExclusions.Recordcount GT 0>
		<tr>
			<TD></TD>
			<td colspan="5" style="border-bottom:1px navy solid;"><strong>Exclusions:</strong></td>
		</tr>
		<cfloop query="GetExclusions">
		<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> valign="bottom">
			<TD COLSPAN="2"></TD>
			<TD COLSPAN="3">
			<B>Billback</B>:&nbsp;&nbsp; [#BB_Code#] #BB_Title#
			<BR>
			<B>Program</B>: [#Contract_Number#] #Contract_Title#
			</TD>
			<TD align="right"><font color="Red"><strong>#DollarFormat(Evaluate(Exclusion_Total*(-1)))#</strong></font></TD>
		</TR>
		<cfsilent>
		<CFSET Total_Approved_Billback_Amount = Total_Approved_Billback_Amount - Exclusion_Total>
		</cfsilent>
		</cfloop>
	</CFIF>
	<cfsilent>
	<cfquery name="GetAdjustments" datasource="#application.datasource#">
		SELECT 	BB_Adjustment.BB_Adjustment_ID, BB_Adjustment.Billback_ID, BB_Adjustment.Payee_ID, BB_Adjustment.Billback_Payee_Type_ID, BB_Adjustment.Adjustment_Amount, Billback.BB_Title, Billback.BB_Date, Billback.BB_Reference, Billback.BB_Code
		FROM 	BB_Adjustment
				INNER JOIN Billback
				ON BB_Adjustment.Billback_ID = Billback.Billback_ID
		WHERE 	BB_Adjustment.Deleted = 0
				AND
				BB_Adjustment.Adjustment_Deducted_From_BB_ID = <cfqueryparam value='#Billback_ID#'>
	</cfquery>
	</cfsilent>
	<cfif GetAdjustments.Recordcount GT 0>
		<tr>
			<td colspan="100%" style="border-bottom:1px navy solid;" align="left"><strong>Adjustments:</strong></td>
		</tr>
		<cfloop query="GetAdjustments">
		<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
			<TD COLSPAN="1"></TD>
			<td COLSPAN="3">
			<B>Billback</B>:&nbsp;&nbsp; [#BB_Code#] #BB_Title# (#BB_Reference#) - #DateFormat(BB_Date, 'MMMM DD, YYYY')#</td>
			<Td align="right"><font color="Red"><strong>#DollarFormat(Evaluate(Adjustment_Amount*(-1)))#</strong></font></TD>
		</tr>
		<cfsilent>
		<CFSET Total_Approved_Billback_Amount = Total_Approved_Billback_Amount - Adjustment_Amount>
		</cfsilent>
		</cfloop>
	</cfif>
	<cfif GetExclusions.Recordcount GT 0 OR GetAdjustments.Recordcount GT 0>
	<TR>
		<!------Total_Approved_Billback_Amount----->
		<TD STYLE="border-top:2px Navy solid;">&nbsp;</TD>
		<TD colspan="3" CLASS="Table_Header" STYLE="border-top:2px Navy solid;">Total approved billback amount = </TD>
		<TD CLASS="Table_Header" ALIGN="right" STYLE="border-top:2px Navy solid;">#DollarFormat(Total_Approved_Billback_Amount)#</TD>
	</TR>
	</cfif>
	</CFOUTPUT>
</TABLE>

<!------ Details ------>

<CFIF Get_Program_Products.RecordCount GT 0>
<cfsilent>
	<CFSET DRK_Billback_Program_ID = "">
	<CFSET DRK_Billback_Product_ID = "">
	<CFSET DRK_Billback_Product_Discount_ID = "">
</cfsilent>
	<CFLOOP QUERY="Get_Program_Products">
		<CFIF Billback_Program_ID NEQ DRK_Billback_Program_ID>
			<CFSET DRK_Billback_Program_ID = Billback_Program_ID>
			<CFOUTPUT>
			<strong>[#Get_Program_Products.Program_Number#] #Get_Program_Products.Program_Title#</strong>
			<HR COLOR="Navy">
			</CFOUTPUT>
			<cfsilent>
			<CFSET URL.Billback_Program_ID = Get_Program_Products.Billback_Program_ID>
			<!------ Start Lumpsum ---------------->
			<CFQUERY DBTYPE="query" NAME="This_Program_lumpsum">
			SELECT	*
			FROM	Get_Program_Lumpsum
			WHERE
					Billback_Program_ID = '#Billback_Program_ID#'
			</CFQUERY>
			</cfsilent>
			<CFIF This_Program_lumpsum.recordCount GT 0>
				<DIV CLASS="BreakHere">
				<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_lumpsum.cfm">
				</DIV>
			</CFIF>
			<cfsilent>
			<!---------- Start Growth Get_Program_Growth --------->
			<CFQUERY DBTYPE="query" NAME="This_Program_Growth">
			SELECT	*
			FROM	Get_Program_Growth
			WHERE
					Billback_Program_ID = '#Billback_Program_ID#'
			</CFQUERY>
			</cfsilent>
			<CFIF This_Program_Growth.recordCount GT 0>
				<DIV CLASS="BreakHere">
				<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_Growth_New.cfm">
				</DIV>
			</CFIF>
		</CFIF>
		<CFIF BB_Product_Type_ID NEQ DRK_Billback_Product_Discount_ID OR Billback_Product_ID NEQ DRK_Billback_Product_ID>
			<CFSET DRK_Billback_Product_ID = BB_Product_Type_ID>
			<CFSET DRK_Billback_Product_Discount_ID = Billback_Product_ID>
			<CFIF  Get_Program_Products.BB_Product_Type_ID NEQ 10 AND BB_Product_Type_ID NEQ "">
				<CFSET URL.Billback_Product_Detail_ID = Billback_Product_Detail_ID>
				<CFSET URL.BB_Product_Type_ID = BB_Product_Type_ID>
				<DIV CLASS="BreakHere">
				<cfset pgSrc = "Details" />
				<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_Product_Rate.cfm">
				<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR Generic_Type EQ DEVIATION_CONSTANTS_Operator_Deviated  OR Associated_Ship_to neq "">
				<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_Product_Volume.cfm">
				</CFIF>
				</DIV>
			</CFIF>
		</CFIF>
	</CFLOOP>
</CFIF>




	<TABLE WIDTH="99%">
	<cfif application.returned_customer_setting.confidentiality_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.confidentiality_switch EQ 1>
	<TR>
		<TD COLSPAN="100%">
			<br>
			<hr>
		<font size="-2">
			<cfoutput>#application.returned_customer_setting.confidentiality_content# </cfoutput></font>
			<hr>
		</TD>
	</TR>
	</cfif></cfif>
	</TABLE>



