<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<CFINCLUDE TEMPLATE="../deviation/Deviation_Constants.CFM">

<cfif isDefined("url.BBID")>
	<CFSET Billback_ID=URL.BBID>
<cfelseif isDefined("form.BBID")>
	<CFSET Billback_ID=FORM.BBID>
<cfelse>
<font color="Red">You did not select a billback</font>
<cfabort>
</cfif>

<html>
<head>
	<title>Approval Details</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<SCRIPT LANGUAGE="JavaScript" SRC="/billbacks/deviation/common_js.js"></SCRIPT>

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


<!--------------------Set Constants        ------------------------------>


<CFSET Mouse_Over_Script=" onmouseover=""initTheTooltip('')"" onmouseout=""popOut()""">
<CFSET show_Yes_Start="<IMG SRC=""/Images/yes_small.gif"" BORDER=""0""">
<CFSET show_No_Start="<IMG SRC=""/Images/no_small.gif"" BORDER=""0""">
<CFSET show_Question_Start="<IMG SRC=""/Images/question_small.gif"" BORDER=""0""">
<CFSET show_Nothing_Start="<IMG SRC=""/Images/nothing_small.gif"" BORDER=""0""">
 
 
<CFSET show_Yes="#show_Yes_Start# #Mouse_Over_Script#>">
<CFSET show_No="#show_No_Start# #Mouse_Over_Script#>">
<CFSET show_Question="#show_Question_Start# #Mouse_Over_Script#>">
<CFSET show_Nothing="#show_Nothing_Start# #Mouse_Over_Script#>">

<CFSET show_Yes_Start="#show_Yes_Start#>">
<CFSET show_No_Start="#show_No_Start#>">
<CFSET show_Question_Start="#show_Question_Start#>">
<CFSET show_Nothing_Start="#show_Nothing_Start#>">


<CFSET Discount_Type_List="Fixed Price, #Application.RebateLabel#, #Application.LumpsumLabel#, Growth, Formula Price">


	<CFSET SHOW_PAYEE_UNKNOWN=1>
	<CFSET SHOW_PROGRAM_PNF=1>
	<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
	<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
	<CFSET SHOW_PRODUCT_UNKNOWN=1>
	<CFSET SHOW_DISCOUNT_UN_AUTH=1>
	<CFSET SHOW_DISCOUNT_RATE=1>
	<CFSET SHOW_DISCOUNT_VOLUME="1,2,5">
	<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
	<CFSET SHOW_DISCOUNT_RATE="1,2,5">
	<CFSET SHOW_LUMPSUM=1>
	<CFSET SHOW_GROWTH=1>

<!------------------------ Define Style ---------------------------------->

<CFSET PAYEE_TD_COLOR		="FFFFFF">
<CFSET PAYEE__IN_TD_COLOR	="FFFFFF">
<!------
<CFSET PROGRAM_TD_COLOR		="ffe4b5">
----->
<CFSET PROGRAM_TD_COLOR		="ccffcc">
<CFSET PROGRAM_TD_Width		="2">
<CFSET PRODUCT_TD_COLOR		="DDDDDD">
<CFSET PRODUCT_IN_TR_COLOR	="WhiteSmoke">
<CFSET LUMPSUM_TD_COLOR		="FFE4C4">
<CFSET LUMPSUM_IN_TR_COLOR	="FFFFFF">
<CFSET GROWTH_TD_COLOR		="lightsteelblue">
<CFSET GROWTH_IN_TR_COLOR	="FFFFFF">

<CFOUTPUT>
<SCRIPT LANGUAGE="JavaScript">
function Open_Close(thisObj)
{
	var trObj = thisObj.parentElement;
	var tableObj = trObj.parentElement;
	var imgObj = event.srcElement;
	var nestImgObj;
	var displayString = "";
	if(imgObj.tagName == "TD")
	{
		if(imgObj.all.IMG_CLOSE.style.display == "")
		{
			imgObj = imgObj.all.IMG_CLOSE;
		}
		else
		{
			imgObj = imgObj.all.IMG_OPEN;
		}
	}
	
	if(imgObj.id == "IMG_CLOSE")
	{
		nestImgObj = thisObj.all.IMG_OPEN;
		displayString = "none";
	}
	else
	{
		nestImgObj = thisObj.all.IMG_CLOSE;
		displayString = "";
	}

	var trObjs = tableObj.rows;
	var i, trLen;
	trLen = trObjs.length;
	for(i=trObj.rowIndex;i<trLen;i++)
	{
		if(trObjs[i].id)
		{
			if(trObjs[i].id == "Program_TR_NO_Colapse")
			{
				break;
			}
		}
		trObjs[i].style.display = displayString;
	}
	nestImgObj.style.display = "";
	imgObj.style.display = "none";
}


function Auto_Select_Program(thisObj)
{
	var trObj = getParentObject(thisObj, "TR");
	var tableObj = trObj.parentElement;
	var trObjs = tableObj.rows;
	var i, trLen;
	trLen = trObjs.length;
	for(i=trObj.rowIndex;i<trLen;i++)
	{
		if(trObjs[i].id)
		{
			if(trObjs[i].id == "Program_TR_NO_Colapse")
			{
				break;
			}			
		}
		Auto_Select_CheckBox_In_This_TR(trObjs[i], thisObj.value);
	}
}

function Auto_Select_CheckBox_In_This_TR(trObj, check_For_Value)
{	
	var i, chLen, chObjs;
	chObjs = trObj.getElementsByTagName("INPUT");
	chLen = chObjs.length;
	var thisCheck;
	for(i=0;i<chLen;i++)
	{
		if(chObjs[i].type == "radio")
		{		
			if(chObjs[i].name)
			{				
				thisCheck = chObjs[chObjs[i].name];
				if(thisCheck)
				{
					thisCheck[check_For_Value].checked = true;				
				}
			}
			break;
		}
	}
}

function checkRadios() 
{
	var el = document.forms[0].elements;
	for(var i = 0 ; i < el.length ; ++i) 
	{
		if(el[i].type == "radio") 
		{	
			if (el[i].name)
			{
				if (el[i].name != "Chk_Auto_Select")
				{
					var radiogroup = el[el[i].name]; // get the whole set of radio buttons.
					// alert("1+" + el[i].name)
					var itemchecked = false;
					for(var j = 0 ; j < radiogroup.length ; ++j) 
					{
						//alert(radiogroup[j].checked)
						radiogroup[j].disabled = false;
						if(radiogroup[j].checked) 
						{
							itemchecked = true;
							break;
						}
					}
		   			if(!itemchecked) 
					{ 
						alert("You have not selected a payment amount for an item.");
						if(el[i].focus)
							el[i].focus();
						return false;
					}
				}
			}
		}
	}
	//document.forms[0].submit();
	return true;
} 
</SCRIPT>

<STYLE>
	.Table_Header
	{
		font-size : 12px;
		font-weight:bold;
	}
	.payeeTD	
	{
		background-color:#PAYEE_TD_COLOR#;
	}
	.payeeInsideTD	
	{
		background-color:#PAYEE__IN_TD_COLOR#;
	}
	.NoValidDesc
	{
		color:red;
		font-weight:bold;
	}
	.NoValidDesc:LINK,.NoValidDesc:VISITED,.NoValidDesc:HOVER 
	{
		color:red;
	}
	.YesValidDesc
	{
		color: black;
	}
	.YesValidDesc:LINK,.YesValidDesc:VISITED,.YesValidDesc:HOVER
	{
		color: blue;
	}	
	.NotprocessedValidDesc
	{
		color: 999999;
	}
	.programTD
	{
		background-color:#PROGRAM_TD_COLOR#;
	}	
	.programLeft
	{
		border-left:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		background-color:FFFFFF;
	}
	.programBottom
	{
		border-left:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		border-bottom:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		border-right:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		background-color: FFFFFF;
	}
	.programRight
	{
		border-right:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		background-color: FFFFFF;
	}
	.lumpsumTD	
	{
		background-color:#LUMPSUM_TD_COLOR#;
	}
	.lumpsumInTR
	{
		background-color:#LUMPSUM_IN_TR_COLOR#;
	}
	.growthTD	
	{
		background-color:#GROWTH_TD_COLOR#;
	}
	.growthInTR
	{
		background-color:#GROWTH_IN_TR_COLOR#;
	}
	.productTD	
	{
		background-color:#PRODUCT_TD_COLOR#;
	}
	.productInTR
	{
		background-color:#PRODUCT_IN_TR_COLOR#;
	}
	.discountTD	
	{
		border-bottom:solid 000000 1px;
	}
</STYLE>

</CFOUTPUT>



<!--------------------------------------------------------------------------------
Get payee Info
--------------------------------------------------------------------------------->
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
		<CFIF SHOW_PAYEE_UNKNOWN EQ 1>
		,BB_Major_Deviation_Info.Unidentified_Payee
		</CFIF>
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
		<CFIF SHOW_PAYEE_UNKNOWN EQ 1>
		LEFT JOIN BB_Major_Deviation_Info
		ON
		(
			(BB_Major_Deviation_Info.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">)
			AND
			(BB_Major_Deviation_Info.Deleted = 0)
		)
		</CFIF>
		WHERE
		bb.Deleted = 0				
		AND
		(
			(bb.Billback_Payee_Type_ID = 1 AND Billback_Distributor.Billback_Distributor_ID IS NOT NULL)
			OR
			(bb.Billback_Payee_Type_ID = 2 AND Billback_Operator.Billback_Operator_ID IS NOT NULL)
			OR
			(bb.Billback_Payee_Type_ID = 3 AND Billback_Broker.Billback_Broker_ID IS NOT NULL)
			OR
			(bb.Billback_Payee_Type_ID >= 4)
		)
		AND
		bb.Billback_ID = '#Billback_ID#'
	</cfquery>

<!---------------------- LumpsUm --------------------------->
	<cfquery name="Get_Program_Lumpsum" datasource="#application.datasource#">
	SELECT     	Billback_Program_Lumpsum_Component.Billback_Program_ID
				, SUM(CAST(Amount AS FLOAT)) Total_Program_Lumpsum_Amount
				, NULL AS Lumpsum_Deviation	
	FROM       Billback_Program_Lumpsum_Component
				LEFT JOIN Program_Lump_Sums
				ON
				(
					(Program_Lump_Sums.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID)
				)		
	WHERE 
			Billback_Program_Lumpsum_Component.Billback_ID 		= <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND
			Billback_Program_Lumpsum_Component.Deleted 			= 0
	GROUP BY Billback_Program_Lumpsum_Component.Billback_Program_ID
	ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
	</CFQUERY>
	
<!-------------------------------------------
Get Program and Product Info
------------------------------------>
	
<cfparam name="ShowEVolume" default=0>

<CFSET Approved_Total_For_JavaScript = 0>
<cfset ApprovedTotal=0>
<cfset BB_Amount_Total=0>
<cfset E_Amount_Total=0>

	<cfquery name="Get_Program_Products" datasource="#application.datasource#">

		SELECT	Billback_Program.Billback_Program_ID, Billback_Product.Billback_Product_ID, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Billback_Product.BB_Product_Quantity, Units_Of_Measure.Unit_Of_Measure_Desc, Billback_Product.BB_Product_UOM, Contract_Main.ProgramType_ID,

<!---The item selections--->
BB_Item_Final.Item_Total_Paid, BB_Item_Final.BB_Item_Final_ID, BB_Item_Final_Detail.BB_Item_Final_Detail_ID, BB_Item_Final_Detail.Rate_Paid_Type, BB_Item_Final_Detail.BB_Product_Type, 
	
		CASE
			WHEN Billback_Product.BB_Product_UOM = 1
			THEN
				ISNULL(Expected_rate_CS, 0)
			ELSE
				ISNULL(Expected_rate_LB, 0)
		END AS Expected_Rate,
		
		CASE
			WHEN Billback_Product.BB_Product_UOM = 1
			THEN
				ISNULL(Billback_Rate_CS, 0)
			ELSE
				ISNULL(Billback_Rate_LB, 0)
		END AS Billback_Rate,
			
		CASE
			WHEN Billback_Product.BB_Product_UOM = 1
			THEN
				ISNULL(Approved_Rate_CS, 0)
			ELSE
				ISNULL(Approved_Rate_LB, 0)
		END AS Approved_Rate,
		
		CASE
			WHEN Billback_Product.BB_Product_UOM = 1
			THEN
				ISNULL(Item_BB_Volume_CS, 0)
			ELSE
				ISNULL(Item_BB_Volume_LB, 0)
		END AS Item_BB_Volume,
		
		CASE
			WHEN Billback_Product.BB_Product_UOM = 1
			THEN
				ISNULL(Item_E_Volume_CS, 0)
			ELSE
				ISNULL(Item_E_Volume_LB, 0)
		END AS Item_E_Volume,
		
		CASE
			WHEN Billback_Product.BB_Product_UOM = 1
			THEN
				ISNULL(Item_Volume_Approved_CS, 0)
			ELSE
				ISNULL(Item_Volume_Approved_LB, 0)
		END AS Item_Volume_Approved,
	
				Program_Control_Panel_Options.Generic_Type,
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
		Billback_Product_Detail.Billback_Product_Detail_ID, Billback_Product_Detail.BB_Product_Type_ID, Billback_Product_Detail.BB_Rate
		,BB_Product_Deviation_Info.Unauthorized_Product, BB_Product_Deviation_Info.Unknown_product
		<!---PNF--->
		<CFIF SHOW_PROGRAM_PNF EQ 1>
		,BB_Program_Deviation_Info.Program_Not_Found
		</CFIF>
		<!---Unauthorized Payee--->
		<CFIF SHOW_PROGRAM_UN_AUTH_PAYEE EQ 1>
		,BB_Program_Deviation_Info.Unauthorized_Payee
		</CFIF>
		<!----Date does not match---->
		<CFIF SHOW_PROGRAM_DATE_MISMATCH EQ 1>
		,BB_Program_Deviation_Info.Dates_Not_Match
		,CASE
		WHEN BB_Program_Deviation_Info.BB_Dollar_Amount = 0 THEN
			0 
		ELSE
			((BB_Program_Deviation_Info.Dates_Not_Match) * 100 / BB_Program_Deviation_Info.BB_Dollar_Amount) 	
		END AS Dates_Not_Match_Percent
		</CFIF>
		<!-----Date Overlap----->
		<CFIF SHOW_DISCOUNT_DATE_OVERLAP EQ 1>
		,BB_Overlap_Deviation_Info.Overlap
		</CFIF>
		<!---- Rate Devition ----->
		<CFIF ListLen(SHOW_DISCOUNT_RATE, ",") GT 0>
		,CASE 
		<CFLOOP LIST="#SHOW_DISCOUNT_RATE#" DELIMITERS="," INDEX="this_Discount_Type">
			<CFSWITCH EXPRESSION="#this_Discount_Type#">	
				<CFCASE VALUE="1">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 1 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Fixed_Product_Rate.Rate_Deviation_CS
					ELSE
						BB_Fixed_Product_Rate.Rate_Deviation_LB
					END				
				</CFCASE>
				<CFCASE VALUE="2">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 2 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Rebate_Product_Rate.Rate_Deviation_CS
					ELSE
						BB_Rebate_Product_Rate.Rate_Deviation_LB
					END				
				</CFCASE>
				<CFCASE VALUE="4">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 4 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Growth_Product_Rate.Rate_Deviation_CS
					ELSE
						BB_Growth_Product_Rate.Rate_Deviation_LB
					END				
				</CFCASE>
				<CFCASE VALUE="5">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 5 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Formula_Product_Rate.Rate_Deviation_CS
					ELSE
						BB_Formula_Product_Rate.Rate_Deviation_LB
					END				
				</CFCASE>
			</CFSWITCH>
		</CFLOOP>
		ELSE
			NULL
		END AS Discount_Rate_Deviation		
		</CFIF>		
		<!---- Volume Devition ----->
		<CFIF ListLen(SHOW_DISCOUNT_VOLUME, ",") GT 0>
		,CASE 
		<CFLOOP LIST="#SHOW_DISCOUNT_VOLUME#" DELIMITERS="," INDEX="this_Discount_Type">
			<CFSWITCH EXPRESSION="#this_Discount_Type#">	
				<CFCASE VALUE="1">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 1 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Fixed_Product_Volume.Volume_Deviation_CS
					ELSE
						BB_Fixed_Product_Volume.Volume_Deviation_LB
					END				
				</CFCASE>
				<CFCASE VALUE="2">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 2 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Rebate_Product_Volume.Volume_Deviation_CS
					ELSE
						BB_Rebate_Product_Volume.Volume_Deviation_LB
					END				
				</CFCASE>
				<CFCASE VALUE="4">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 4 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Growth_Product_Volume.Volume_Deviation_CS
					ELSE
						BB_Growth_Product_Volume.Volume_Deviation_LB
					END				
				</CFCASE>		
				<CFCASE VALUE="5">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 5 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Formula_Product_Volume.Volume_Deviation_CS
					ELSE
						BB_Formula_Product_Volume.Volume_Deviation_LB
					END				
				</CFCASE>				
			</CFSWITCH>
		</CFLOOP>
		ELSE
			NULL
		END AS Discount_Volume_Deviation		
		</CFIF>	

				<!--- Dev Note:9741; This value exists only for Billback_Payee_Type_ID = 2 (operator) and the operator has an associated distributor --->
		,Billback_Operator.Associated_Ship_to

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
				INNER JOIN	Program_Control_Panel_Options
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
		<CFIF (SHOW_PROGRAM_PNF EQ 1) OR (SHOW_PROGRAM_UN_AUTH_PAYEE EQ 1) OR (SHOW_PROGRAM_DATE_MISMATCH EQ 1)>
		LEFT JOIN BB_Program_Deviation_Info
		ON
		(
			(BB_Program_Deviation_Info.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(BB_Program_Deviation_Info.Deleted = 0)
		)
		</CFIF>		
		LEFT JOIN	
			(
			Billback_Product
			LEFT JOIN	BSA_Foodservice_Items_Master
			ON
			(
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
			(
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
				(Billback_Product_Detail.BB_Product_Type_ID IN (1,2,5))
			)
		ON
		(
		(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
		AND
		(Billback_Product.Deleted = 0)
		)
		LEFT JOIN BB_Product_Deviation_Info
		ON
		(
			(BB_Product_Deviation_Info.Billback_Product_ID = Billback_Product.Billback_Product_ID)
			AND
			(BB_Product_Deviation_Info.Deleted = 0)
			AND
			(BB_Product_Deviation_Info.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
		)
		<CFIF SHOW_DISCOUNT_DATE_OVERLAP EQ 1>
		LEFT JOIN BB_Overlap_Deviation_Info
		ON
		(
			(BB_Overlap_Deviation_Info.Billback_Product_ID = Billback_Product.Billback_Product_ID)
			AND
			(BB_Overlap_Deviation_Info.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
			AND
			(BB_Overlap_Deviation_Info.Deleted = 0)
		)
		</CFIF>
		<CFIF ListLen(SHOW_DISCOUNT_RATE, ",") GT 0>		
		<CFLOOP LIST="#SHOW_DISCOUNT_RATE#" DELIMITERS="," INDEX="this_Discount_Type">
			<CFSET discount_Type_Deviation_Table = "">
			<CFSWITCH EXPRESSION="#this_Discount_Type#">	
				<CFCASE VALUE="1">
					<CFSET discount_Type_Deviation_Table = "BB_Fixed_Product_Rate">
				</CFCASE>
				<CFCASE VALUE="2">
					<CFSET discount_Type_Deviation_Table = "BB_Rebate_Product_Rate">
				</CFCASE>
				<CFCASE VALUE="4">
					<CFSET discount_Type_Deviation_Table = "BB_Growth_Product_Rate">
				</CFCASE>
				<CFCASE VALUE="5">
					<CFSET discount_Type_Deviation_Table = "BB_Formula_Product_Rate">
				</CFCASE>						
			</CFSWITCH>
			<CFIF discount_Type_Deviation_Table NEQ "">
				LEFT JOIN	#discount_Type_Deviation_Table#
				ON
				(
					(#discount_Type_Deviation_Table#.Billback_ID = Billback.Billback_ID)
					AND
					(#discount_Type_Deviation_Table#.Billback_Program_ID = Billback_Program.Billback_Program_ID)
					AND
					(#discount_Type_Deviation_Table#.Billback_Product_ID = Billback_Product.Billback_Product_ID)
					AND
					(#discount_Type_Deviation_Table#.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
					AND
					(#discount_Type_Deviation_Table#.Deleted = 0)
				)
			</CFIF>
		</CFLOOP>		
		</CFIF>
		<CFIF ListLen(SHOW_DISCOUNT_VOLUME, ",") GT 0>		
		<CFLOOP LIST="#SHOW_DISCOUNT_VOLUME#" DELIMITERS="," INDEX="this_Discount_Type">
			<CFSET discount_Type_Deviation_Table = "">
			<CFSWITCH EXPRESSION="#this_Discount_Type#">	
				<CFCASE VALUE="1">
					<CFSET discount_Type_Deviation_Table = "BB_Fixed_Product_Volume">
				</CFCASE>
				<CFCASE VALUE="2">
					<CFSET discount_Type_Deviation_Table = "BB_Rebate_Product_Volume">
				</CFCASE>
				<CFCASE VALUE="4">
					<CFSET discount_Type_Deviation_Table = "BB_Growth_Product_Volume">
				</CFCASE>				
				<CFCASE VALUE="5">
					<CFSET discount_Type_Deviation_Table = "BB_Formula_Product_Volume">
				</CFCASE>
			</CFSWITCH>
			<CFIF discount_Type_Deviation_Table NEQ "">
				LEFT JOIN	#discount_Type_Deviation_Table#
				ON
				(
					(#discount_Type_Deviation_Table#.Billback_ID = Billback.Billback_ID)
					AND
					(#discount_Type_Deviation_Table#.Billback_Program_ID = Billback_Program.Billback_Program_ID)
					AND
					(#discount_Type_Deviation_Table#.Billback_Product_ID = Billback_Product.Billback_Product_ID)
					AND
					(#discount_Type_Deviation_Table#.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
					AND
					(#discount_Type_Deviation_Table#.Deleted = 0)
				)
			</CFIF>
		</CFLOOP>		
		</CFIF>
		LEFT JOIN BB_Item_Final
			ON BB_Item_Final.Billback_Product_ID = Billback_Product.Billback_Product_ID
			AND BB_Item_Final.Deleted =0
		LEFT JOIN BB_Item_Final_Detail
			ON BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID
			AND BB_Item_Final_Detail.Deleted = 0
			AND BB_Item_Final_Detail.BB_Product_Type = Billback_Product_Detail.BB_Product_Type_ID
		LEFT JOIN Billback_Operator
		 ON
		 (
			 Billback.Billback_ID = Billback_Operator.Billback_ID
			 AND Billback_Operator.Deleted = 0
		 )
		WHERE
		Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		ORDER BY Billback_Program.Billback_Program_ID, Billback_Product.Billback_Product_ID, Billback_Product_Detail.BB_Product_Type_ID 
	</cfquery>
	
	<CFSET TOTAL_COLUMNS=10>
	<FORM ACTION="payment.cfm" METHOD="POST" ID="CostList" NAME="CostList" onSubmit="javaScript: return checkRadios();">
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0">
		<COL SPAN="1" NOWRAP></COL><!---Payee--->
		<COL SPAN="1" NOWRAP></COL><!---Program--->
		<COL SPAN="1" WIDTH="50"></COL><!---Product--->
		<COL SPAN="2" WIDTH="30%" NOWRAP></COL><!---Discount Type--->
		<COL SPAN="1" NOWRAP WIDTH="100"></COL><!---Validation--->
		<COL SPAN="1" WIDTH="100" NOWRAP></COL><!---billback value--->
		<COL SPAN="2" WIDTH="100" NOWRAP></COL><!---expected value--->
		<COL SPAN="1" WIDTH="10" NOWRAP></COL><!---none--->
		<COL SPAN="1" WIDTH="" NOWRAP></COL><!---val amount--->
		
	<THEAD BGCOLOR="FFCE84">
		<TD CLASS="Table_Header" NOWRAP>Payee</TD>
		<TD CLASS="Table_Header" NOWRAP>Program</TD>
		<TD CLASS="Table_Header" NOWRAP>Product&nbsp;&nbsp;</TD>
		<TD COLSPAN="2" CLASS="Table_Header" NOWRAP>Discount Type</TD>
		<TD CLASS="Table_Header" NOWRAP>Validation</TD>
		<TD CLASS="Table_Header" NOWRAP>&nbsp; </TD>
		<TD CLASS="Table_Header" WIDTH="120" NOWRAP>Billback Value</TD>
		<TD CLASS="Table_Header" WIDTH="120" NOWRAP>Expected Value</TD>
		<TD CLASS="Table_Header" WIDTH="70" NOWRAP>None</TD>
		<TD CLASS="Table_Header" NOWRAP>&nbsp; </TD>
	</THEAD>
	<!--------- Show Payee -------->
	
	<cfif isDefined("url.Error")>
	<tr><td colspan="11" align="center">
	<cfif url.Error IS "E">
	<font color="red">The total for the amounts you entered exceeds the amount you can approve.</font>
	</cfif>
	</td></tr>
	</cfif>
	
	<TR>
		<TD COLSPAN="100%" CLASS="payeeTD"> 
		<CFOUTPUT>
		<CFIF Get_Payee_Info.recordCount GT 0>
			#Get_Payee_Info.Payee_Name#, #Get_Payee_Info.City#<CFIF Len(Trim(Get_Payee_Info.State_Code)) GT 0>, </CFIF>#Get_Payee_Info.State_Code#
		<CFELSE>
			NONE SUPPLIED
		</CFIF>
		</CFOUTPUT>
		</TD>
	</TR>
	<!--------- Show Unknown Payee -------->
	<CFOUTPUT>
	<TR CLASS="payeeInsideTD">
		<TD COLSPAN="5" CLASS="payeeInsideTD">&nbsp;</TD>
	<CFIF (SHOW_PAYEE_UNKNOWN EQ 1) AND (Get_Payee_Info.Unidentified_Payee NEQ "")>
		<CFIF Get_Payee_Info.Unidentified_Payee GT 0>
			<TD CLASS="NoValidDesc">Known Payee</TD>
			<TD CLASS="NoValidDesc">#show_No#</TD>
		<CFELSE>
			<TD CLASS="YesValidDesc">Known Payee</TD>
			<TD CLASS="YesValidDesc">#show_Yes#</TD>
		</CFIF>
	<CFELSE>
			<TD CLASS="NotprocessedValidDesc">Known Payee</TD>
			<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
	</CFIF>
		<TD COLSPAN="4">&nbsp;</TD>
	</TR>
	</CFOUTPUT>
	<!----- Show Programs and Products ------>
	<CFIF Get_Program_Products.RecordCount GT 0>
		<CFOUTPUT QUERY="Get_Program_Products" GROUP="Billback_Program_ID">
		
		<cfset Generic_Type = Get_Program_Products.Generic_Type>
		<cfset Associated_Ship_To = Get_Program_Products.Associated_Ship_To>

		<cfif Generic_Type IS "Distributor Trade/Shelter" OR Generic_Type IS "Operator-Deviated Pricing"  OR Associated_Ship_To neq "">
			<cfset ShowEVolume = 1>
		</cfif>
				
			<TR ID="Program_TR_NO_Colapse">
				<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
				<TD COLSPAN="6" CLASS="programTD">[#Get_Program_Products.Program_Number#] #Get_Program_Products.Program_Title#</TD>
				<TD CLASS="programTD">
					<INPUT TYPE="RADIO" ID="Chk_Auto_Select" NAME="Chk_Auto_Select" VALUE="0" onClick="javaScript: Auto_Select_Program(this);">All Billback
				</TD>
				<TD CLASS="programTD">
					<INPUT TYPE="RADIO" ID="Chk_Auto_Select" NAME="Chk_Auto_Select" VALUE="1" onClick="javaScript: Auto_Select_Program(this);">All Expected
				</TD>
				<TD CLASS="programTD">
					<INPUT TYPE="RADIO" ID="Chk_Auto_Select" NAME="Chk_Auto_Select" VALUE="2" onClick="javaScript: Auto_Select_Program(this);">All None
				</TD>
				<TD CLASS="programTD" OnClick="javaScript: Open_Close(this);" STYLE="CURSOR:pointer" NOWRAP><IMG SRC="/Images/up_1.gif" ID="IMG_CLOSE"><IMG SRC="/Images/down_1.gif" ID="IMG_OPEN" STYLE="DISPLAY:NONE;"></TD>
			</TR>
			
			<!----- Show Unknown Program ---------->
			
			<TR>
			<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
			<TD COLSPAN="4" CLASS="programLeft">&nbsp;</TD>
			<CFIF (SHOW_PROGRAM_PNF EQ 1) AND (Program_Not_Found NEQ "")>
					<CFIF Program_Not_Found GT 0>
					<TD CLASS="NoValidDesc">Known Program</TD>
					<TD CLASS="NoValidDesc">#show_No#</TD>
					<CFELSE>
					<TD CLASS="YesValidDesc">Known Program</TD>
					<TD CLASS="YesValidDesc">#show_Yes#</TD>
					</CFIF>
			<CFELSE>				
					<TD CLASS="NotprocessedValidDesc">Known Program</TD>
					<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
			</CFIF>
				<TD COLSPAN="4" CLASS="programRight">&nbsp;</TD>
			</TR>
			
			<!-------------- Show Unauthorized Payee -------------------->
			<TR>
				<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
				<TD COLSPAN="4" CLASS="programLeft">&nbsp;</TD>
			<CFIF (SHOW_PROGRAM_UN_AUTH_PAYEE EQ 1) AND (Unauthorized_Payee NEQ "")>
				<CFIF Unauthorized_Payee GT 0>
					<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="/billbacks/deviation/Authorized_Payee_List.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Authorized Payee</A></TD>
					<TD CLASS="NoValidDesc">#show_No#</TD>
				<CFELSE>
					<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="/billbacks/deviation/Authorized_Payee_List.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Authorized Payee</A></TD>
					<TD CLASS="YesValidDesc">#show_Yes#</TD>
				</CFIF>					
			<CFELSE>
				<TD CLASS="NotprocessedValidDesc">Authorized Payee</TD>
				<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
			</CFIF>
				 <TD COLSPAN="4" CLASS="programRight">&nbsp;</TD>
			</TR>
			
			<!-------------- Date mismatch --------------->
			<TR>
				<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
				<TD COLSPAN="4" CLASS="programLeft">&nbsp;</TD>
			<CFIF (SHOW_PROGRAM_DATE_MISMATCH EQ 1) AND (Dates_Not_Match NEQ "")>
				<CFIF Dates_Not_Match GT 0>
					<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="/billbacks/deviation/Deviation_Program_Date_Mismatch.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Date Match</A></TD>
					<TD CLASS="NoValidDesc">#show_No#</TD>
				<CFELSE>
					<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="/billbacks/deviation/Deviation_Program_Date_Mismatch.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Date Match</A></TD>
					<TD CLASS="YesValidDesc">#show_Yes#</TD>
				</CFIF>				
			<CFELSE>
				<TD CLASS="NotprocessedValidDesc">Date Match</TD>
				<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
			</CFIF>
				 <TD COLSPAN="4" CLASS="programRight">&nbsp;</TD>
			</TR>
		
			
		<!------ Start Lumpsum ---------------->
		<cfquery name="Total_Lumpsum" datasource="#application.datasource#">
		SELECT Lump_Sum_Deviation AS Lumpsum_Deviation, ISNULL(SUM(LS_Expected_Amount), 0) AS Expected, ISNULL(SUM(LS_Billback_Amount), 0) AS Billback, SUM(LS_Approved_Amount) AS Approved
		FROM BB_Lump_Sums
		WHERE Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND Deleted = 0
		Group BY Lump_Sum_Deviation
		ORDER BY Lump_Sum_Deviation
		</cfquery>
		
		<cfif Total_Lumpsum.Recordcount GT 0>
		
		<cfset E_Amount_Total = E_Amount_Total + Total_Lumpsum.Expected>
		<cfset BB_Amount_Total = BB_Amount_Total + Total_Lumpsum.Billback>
		
				<TR>
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="5" style="border-left: solid #LUMPSUM_TD_COLOR# 1px; border-top: solid #LUMPSUM_TD_COLOR# 1px; border-bottom: solid #LUMPSUM_TD_COLOR# 1px;">Deepa, we need to make it so if you choose this level you can't choose the bottom level.  Can you have selected either this level or the other, but not be required to select both?
<br>#Application.LumpsumLabel# Totals For This Program: </TD>		
					<TD COLSPAN="1" style="border-top: solid #LUMPSUM_TD_COLOR# 1px; border-bottom: solid #LUMPSUM_TD_COLOR# 1px;"><INPUT TYPE="RADIO" name="TLS_#Replace(Billback_Program_ID, "-","_", "all")#" value="BB" <cfif Total_LumpSum.Approved IS Total_Lumpsum.Billback> checked</cfif>>#LSCurrencyFormat(Total_Lumpsum.Billback)#</TD>
					<TD COLSPAN="1" style="border-top: solid #LUMPSUM_TD_COLOR# 1px; border-bottom: solid #LUMPSUM_TD_COLOR# 1px;"><INPUT TYPE="RADIO" name="TLS_#Replace(Billback_Program_ID, "-","_", "all")#" value="E" <cfif Total_LumpSum.Approved IS Total_Lumpsum.Expected> checked</cfif>>#LSCurrencyFormat(Total_Lumpsum.Expected)#</TD>
					<TD COLSPAN="1" style="border-right: solid #LUMPSUM_TD_COLOR# 1px;border-top: solid #LUMPSUM_TD_COLOR# 1px; border-bottom: solid #LUMPSUM_TD_COLOR# 1px;"><INPUT TYPE="RADIO" name="TLS_#Replace(Billback_Program_ID, "-","_", "all")#" value="None" <cfif Total_LumpSum.Approved IS 0> checked</cfif>></TD>
					<TD COLSPAN="1" CLASS="programRight">&nbsp;</TD>
				</TR>
			
			<cfquery name="Program_Lumpsum" datasource="#application.datasource#">
			SELECT 	Billback_Program_Lumpsum_Component.Billback_Program_Lumpsum_Component_ID,
			Program_Lump_Sum_Name.Program_Lump_Sum_Name AS Name, 
			Billback_Program_Lumpsum_Component.Amount, 
			Billback_Program_Lumpsum_Component.Component_Type_ID, 
			Program_Lump_Sums.Lump_Sum_Name
			FROM Billback_Program_Lumpsum_Component
				LEFT JOIN Program_Lump_Sums
				ON Program_Lump_Sums.Program_Lump_Sum_ID =
				Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
				AND Program_Lump_Sums.Deleted = 0
				LEFT JOIN Program_Lump_Sum_Name
				ON Program_Lump_Sums.Program_Lump_Sum_Name_ID = Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID
			WHERE Billback_Program_Lumpsum_Component.Deleted = 0
			AND Billback_Program_Lumpsum_Component.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND Billback_Program_Lumpsum_Component.Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		
			<cfloop query="Program_Lumpsum">
			<TR>
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="5" CLASS="lumpsumTD">
					&nbsp; &nbsp; &nbsp; 
					<cfif len(trim(Program_Lumpsum.Name)) GT 0>
						#Program_Lumpsum.Name# 
					<cfelseif len(trim(Program_Lumpsum.Lump_Sum_Name)) GT 0>
						#Program_Lumpsum.Lump_Sum_Name# 
					<cfelse>	
					#Application.LumpsumLabel# 
					</cfif>
					<cfif Program_Lumpsum.Component_Type_ID IS 2>
						(Growth #Application.LumpsumLabel#)
					</cfif>
					
					 </TD>		
					<TD COLSPAN="1" CLASS="lumpsumTD"><INPUT NAME="LS_#Replace(Program_Lumpsum.Billback_Program_Lumpsum_Component_ID, "-","_", "all")#" value="#Program_Lumpsum.Amount#" TYPE="RADIO">#LSCurrencyFormat(Program_Lumpsum.Amount)#</TD>
					<TD COLSPAN="1" CLASS="lumpsumTD"><!--- <INPUT TYPE="RADIO">#DollarFormat(Get_Program_Lumpsum.Total_Program_Lumpsum_Amount)# --->&nbsp; </TD>
					<TD COLSPAN="1" CLASS="lumpsumTD"><INPUT TYPE="RADIO" NAME="LS_#Replace(Program_Lumpsum.Billback_Program_Lumpsum_Component_ID, "-","_", "all")#" value="0"></TD>
					<TD COLSPAN="1" CLASS="programRight">&nbsp;</TD>
				</TR>			
			</cfloop>				
				
				<TR CLASS="lumpsumInTR">
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="3">&nbsp;</TD>
					<CFIF (SHOW_LUMPSUM EQ 1) AND Total_Lumpsum.Lumpsum_Deviation NEQ "">
						<CFIF Total_Lumpsum.Lumpsum_Deviation GT 0>
							<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="/billbacks/deviation/Deviation_Lumpsum.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
							<TD CLASS="NoValidDesc">#show_No#</TD>
						<CFELSE>
							<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="/billbacks/deviation/Deviation_Lumpsum.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
							<TD CLASS="YesValidDesc">#show_Yes#</TD>
						</CFIF>
					<CFELSE>
						<TD CLASS="NotprocessedValidDesc"><A CLASS="NotprocessedValidDesc" HREF="/billbacks/deviation/Deviation_Lumpsum.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
						<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
					</CFIF>
				 	<TD COLSPAN="4" CLASS="programRight">&nbsp;</TD>
				</TR>
				
				<TR>
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="7">&nbsp;</TD>
				 	<TD COLSPAN="2"  CLASS="programRight">&nbsp;</TD>
				</TR>
			</CFIF>
			<!------ End Lumpsum ------->
			
			<!---Growth--->
					<cfquery name="GetGrowth" datasource="#application.datasource#">
					SELECT 	Billback_Program_ID, ISNull(Expected_Amount, 0) AS Expected_Amount, ISNull(BB_Growth_Amount, 0) AS BB_Growth_Amount, Approved_Amount
							, Deviated_Amount
					FROM BB_Growth_Program
					WHERE Deleted = 0
					AND Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<cfif GetGrowth.RecordCount GT 0>
					<TR>
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
						<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
						<TD COLSPAN="5" CLASS="GrowthTD">Growth (Total)</TD>
						<TD CLASS="GrowthTD">
						
						<cfset E_Amount_Total = E_Amount_Total + GetGrowth.Expected_Amount>

						<cfset BB_Amount_Total = BB_Amount_Total + GetGrowth.BB_Growth_Amount>
						
								<input type="radio" name="GR_#Replace(GetGrowth.Billback_Program_ID, "-","_", "all")#" value="Billback_Growth"  <cfif GetGrowth.BB_Growth_Amount IS GetGrowth.Approved_Amount> checked</cfif>>
								#LSCurrencyFormat(GetGrowth.BB_Growth_Amount)# 
						</TD>
						<TD CLASS="GrowthTD">
					
								<input type="radio" name="GR_#Replace(GetGrowth.Billback_Program_ID, "-","_", "all")#" <cfif GetGrowth.Expected_Amount IS GetGrowth.Approved_Amount> checked</cfif>>												
								#LSCurrencyFormat(GetGrowth.Expected_Amount)#
						</TD>
						<TD CLASS="GrowthTD">
							<input type="radio" name="GR_#Replace(GetGrowth.Billback_Program_ID, "-","_", "all")#" value="None" <cfif GetGrowth.Approved_Amount IS 0> checked</cfif>>
						</TD>
					 	<TD CLASS="programRight">&nbsp;</TD>					
					</TR>
					<TR CLASS="growthInTR">
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="3">&nbsp;</TD>
					<CFIF (SHOW_GROWTH EQ 1) AND GetGrowth.Deviated_Amount NEQ "">
						<CFIF GetGrowth.Deviated_Amount LT 0>
							<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="/billbacks/deviation/Deviation_Growth_New.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
							<TD CLASS="NoValidDesc">#show_No#</TD>							
						<CFELSE>
							<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="/billbacks/deviation/Deviation_Growth_New.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
							<TD CLASS="YesValidDesc">#show_Yes#</TD>
						</CFIF>
					<CFELSE>
						<TD CLASS="NotprocessedValidDesc"><A CLASS="NotprocessedValidDesc" HREF="/billbacks/deviation/Deviation_Growth_New.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
						<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
					</CFIF>
				 	<TD CLASS="programRight" COLSPAN="4">&nbsp;</TD>
				</TR>
					
					<TR>
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="7">&nbsp;</TD>
				 	<TD COLSPAN="2"  CLASS="programRight">&nbsp;</TD>
				</TR>
					</cfif>
			
			
			<!---------- Start Products --------------->
			<CFIF Billback_Product_ID NEQ "">
				<CFOUTPUT GROUP="Billback_Product_ID">
					<TR>
						<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
						<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
						<TD COLSPAN="5" CLASS="productTD">#Get_Program_Products.Item_Number# #Get_Program_Products.Description#</TD>
						<TD CLASS="productTD">
								<CFSET Approved_Volume_JS = 0>
								<input bvolume="#Item_BB_Volume#" onClick="javaScript:adjust_Tally_volume(this);" type="radio" name="BB_#Replace(BB_Item_Final_ID, "-","_", "all")#" value="Item_BB_Volume"  
								<cfif Item_BB_Volume IS Item_Volume_Approved> subtractVolume="1" checked
								<CFSET Approved_Volume_JS = Item_BB_Volume><cfelse> subtractVolume="0"
								</cfif>>
								#NumberFormat(Item_BB_Volume, '___,___,___,___.__')# <cfif BB_Product_UOM IS 1>Cs<Cfelse>Lbs</cfif>
						</TD>
						<TD CLASS="productTD">
							<cfif ShowEVolume IS 1>
								<CFSET Expected_Volume = Item_E_Volume>
								<cfif len(trim(ShowEVolume)) LT 1>
									<CFSET Expected_Volume = 0>
								</cfif>								
							<cfelse>
								<CFSET Expected_Volume = "">
							</cfif>
							
							<cfif ShowEVolume IS 1>
								<input bvolume="#Expected_Volume#" onClick="javaScript:adjust_Tally_volume(this);" type="radio" name="BB_#Replace(BB_Item_Final_ID, "-","_", "all")#" value="Item_E_Volume" 
								<cfif Item_E_Volume IS Item_Volume_Approved> subtractVolume="1" checked
								<CFSET Approved_Volume_JS = Item_E_Volume><cfelse> subtractVolume="0"
								</cfif>>
							<cfelse>
								&nbsp;
							</cfif>
							
							<cfif ShowEVolume IS 1>
								#NumberFormat(Item_E_Volume, '___,___,___,___.__')#<cfif len(trim(ShowEVolume)) LT 1> 0 </cfif> <cfif BB_Product_UOM IS 1>Cs<Cfelse>Lbs</cfif>
							<cfelse>
								&nbsp;
							</cfif>
						</TD>
						<TD CLASS="productTD">
							<input bvolume="0" onClick="javaScript:adjust_Tally_volume(this);" type="radio" name="BB_#Replace(BB_Item_Final_ID, "-","_", "all")#" value="None" 
							<cfif Item_Volume_Approved IS 0> subtractVolume="1" checked
							<CFSET Approved_Volume_JS = 0><cfelse> subtractVolume="0"
							</cfif>>
						</TD>
					 	<TD CLASS="programRight">&nbsp;</TD>
					</TR>
					
							<!------- Show Product Unknown ------------->
					<TR CLASS="productInTR">
						<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
						<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
						<TD COLSPAN="3">&nbsp;</TD>
						<CFIF (SHOW_PRODUCT_UNKNOWN EQ 1) AND (Unknown_product NEQ "")>
							<CFIF Unknown_product GT 0>
								<TD CLASS="NoValidDesc">Known Product</TD>
								<TD CLASS="NoValidDesc">#show_No#</TD>
							<CFELSE>
								<TD CLASS="YesValidDesc">Known Product</TD>
								<TD CLASS="YesValidDesc">#show_Yes#</TD>
							</CFIF>
						<CFELSE>
							<TD CLASS="NotprocessedValidDesc">Know Product</TD>
							<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
						</CFIF>
						<TD COLSPAN="3">&nbsp;</TD>
						<TD COLSPAN="1" CLASS="programRight">&nbsp;</TD>
					</TR>
					<!-----Start Discount Type ------->
					<CFIF BB_Product_Type_ID NEQ "">
						<CFOUTPUT>
							<TR CLASS="productInTR">
								<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="1">&nbsp;</TD>								
								<TD COLSPAN="4" CLASS="discountTD">
									<CFIF BB_Product_Type_ID LTE ListLen(Discount_Type_List,",")>
										#Trim(ListGetAt(Discount_Type_List,BB_Product_Type_ID,","))#
									</CFIF>
								</TD>					
		<cfif len(trim(Expected_Rate)) LT 1>
			<cfset Expected_Rate_Rev = Billback_Rate>
		<cfelse>
			<cfset Expected_Rate_Rev = Expected_Rate>
		</cfif>
		
		<cfif len(trim(Item_E_Volume)) LT 1>
			<cfset Item_E_Volume_Rev = Item_BB_Volume>
		<cfelse>
			<cfset Item_E_Volume_Rev = Item_E_Volume>
		</cfif>
		
		<cfif len(trim(Billback_Rate)) LT 1>
			<cfset Billback_Rate_Rev = 0>
		<cfelse>
			<cfset Billback_Rate_Rev = Billback_Rate>
		</cfif>
		
		<cfif len(trim(Item_BB_Volume)) LT 1>
			<cfset Item_BB_Volume_Rev = 0>
		<cfelse>
			<cfset Item_BB_Volume_Rev = Item_BB_Volume>
		</cfif>
		
			<cfset E_Amount_Total = E_Amount_Total + (Expected_Rate_Rev * Item_E_Volume_Rev)>
	
		<cfset BB_Amount_Total = BB_Amount_Total + (Billback_Rate_Rev * Item_BB_Volume_Rev)>			
								<TD CLASS="discountTD" NOWRAP>
									<input brate="#Billback_rate#" bvolume="0" onClick="javaScript:adjust_Tally_rate(this);" type="radio" name="PR_#Replace(BB_Item_Final_Detail_ID, "-", "_", "all")#" value="Billback_Rate" 
									<cfif Billback_Rate IS Approved_Rate> subtractRate="1" checked
									<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + (Billback_Rate * Approved_Volume_JS)>
									<cfelse> subtractRate="0"
									</cfif>>
									  #LSCurrencyFormat(Billback_rate)# per <cfif BB_Product_UOM IS 1>case <cfelse> pound</cfif>
								</TD>
								<TD CLASS="discountTD" NOWRAP>
									<input brate="#Expected_Rate#" bvolume="0" subtractRate="0" onClick="javaScript:adjust_Tally_rate(this);" type="radio" name="PR_#Replace(BB_Item_Final_Detail_ID, "-", "_", "all")#" value="Expected_Rate" 
									<cfif Expected_Rate IS Approved_Rate> subtractRate="1" checked
									<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + (Expected_Rate * Approved_Volume_JS)>
									<cfelse> subtractRate="0"
									</cfif>>
									 #LSCurrencyFormat(Expected_Rate)# <cfif BB_Product_UOM IS 1>case <cfelse> pound</cfif>
								</TD>
								<TD CLASS="discountTD" NOWRAP>
									<input brate="0" type="radio" bvolume="0" subtractRate="0" onClick="javaScript:adjust_Tally_rate(this);" name="PR_#Replace(BB_Item_Final_Detail_ID, "-", "_", "all")#" value="None" 
									<cfif Approved_Rate IS 0> subtractRate="1" checked
									<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + (0 * Approved_Volume_JS)>
									<cfelse> subtractRate="0"
									</cfif>>
								</TD>
								 <TD COLSPAN="1" CLASS="programRight">&nbsp;</TD>				
							</TR>
							
							<!----- Unauthorized Discount Type --------->
							<TR CLASS="productInTR">
								<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="3">&nbsp;</TD>
							<CFIF (SHOW_DISCOUNT_UN_AUTH EQ 1) AND (Unauthorized_Product NEQ "")>
								<CFIF Unauthorized_Product GT 0>
									<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="/billbacks/deviation/Authorized_Product_List.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Authorized Product</A></TD>
									<TD CLASS="NoValidDesc">#show_No#</TD>
								<CFELSE>
									<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="/billbacks/deviation/Authorized_Product_List.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Authorized Product</A></TD>
									<TD CLASS="YesValidDesc">#show_Yes#</TD>
								</CFIF>
							<CFELSE>
								<TD CLASS="NotprocessedValidDesc">Authorized Product</TD>
								<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
							</CFIF>
								<TD COLSPAN="3">&nbsp; </TD>
								<TD COLSPAN="1" CLASS="programRight">&nbsp;</TD>
							</TR>
							
							<!----- Rate --------------->
							<CFSET This_Discount_Type_Rate_Detail_Page=Trim(ListGetAt(DETAIL_PAGE_EXPECTED_RATE, BB_Product_Type_ID, ","))>
							<CFSET This_Discount_Volume_Rate_Detail_Page=Trim(ListGetAt(DETAIL_PAGE_EXPECTED_VOLUME, BB_Product_Type_ID, ","))>
							<TR CLASS="productInTR">
								<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="3">&nbsp;</TD>
							<CFIF (ListLen(SHOW_DISCOUNT_RATE,",") GT 0) AND (FindNoCase(BB_Product_Type_ID, SHOW_DISCOUNT_RATE)) AND (Discount_Rate_Deviation NEQ "")>								
								<CFIF Discount_Rate_Deviation NEQ "" AND Discount_Rate_Deviation NEQ 0>
									<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="/billbacks/deviation/#This_Discount_Type_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Rate/#Left(Unit_Of_Measure_Desc, Len(Unit_Of_Measure_Desc) - 1)#</A></TD>
									<TD CLASS="NoValidDesc">#show_No#</TD>
									<CFSET Discount_Amount_Deviation=Discount_Rate_Deviation*BB_Product_Quantity>
									<CFIF Discount_Amount_Deviation GT BB_Rate>
										<CFSET Discount_Amount_Deviation = BB_Rate>
									</CFIF>
									
									<CFSET Amount_Deviation = Discount_Amount_Deviation>
									<CFSET Amount_Deviation = Abs(Amount_Deviation)>									
									<CFIF IsNumeric(BB_Rate) AND (BB_Rate NEQ "") AND BB_Rate NEQ 0>
										<CFSET Deviation_Percent = (Amount_Deviation/BB_Rate)*100>
									<CFELSE>
										<CFSET Deviation_Percent = 0>
									</CFIF>
									<CFIF Deviation_Percent GT 100>
										<CFSET Deviation_Percent=100>
									</CFIF>
									<CFSET Deviation_Percent = Abs(Deviation_Percent)>
								<CFELSE>
									<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="/billbacks/deviation/#This_Discount_Type_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Rate/#Left(Unit_Of_Measure_Desc, Len(Unit_Of_Measure_Desc) - 1)#</A></TD>
									<TD CLASS="YesValidDesc">#show_Yes#</TD>
								</CFIF>
							<CFELSE>									
									<TD CLASS="NotprocessedValidDesc"><A CLASS="NotprocessedValidDesc" HREF="/billbacks/deviation/#This_Discount_Type_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Rate/#Left(Unit_Of_Measure_Desc, Len(Unit_Of_Measure_Desc) - 1)#</A></TD>
									<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
							</CFIF>
								<TD COLSPAN="3">&nbsp; </TD>
								<TD COLSPAN="1" CLASS="programRight">&nbsp;</TD>
							</TR>

							<!--------- Volume ------------->							
							<TR CLASS="productInTR">
								<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="3">&nbsp;</TD>
							<CFIF (ListLen(SHOW_DISCOUNT_VOLUME,",") GT 0) AND (FindNoCase(BB_Product_Type_ID, SHOW_DISCOUNT_VOLUME)) AND (Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR Generic_Type EQ DEVIATION_CONSTANTS_Operator_Deviated  OR Associated_Ship_to neq "") AND (Discount_Volume_Deviation NEQ "")>
								<CFIF Discount_Volume_Deviation NEQ "" AND Discount_Volume_Deviation NEQ 0>
									<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="/billbacks/deviation/#This_Discount_Volume_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Volume</A></TD>
									<TD CLASS="NoValidDesc">#show_No#</TD>
									<CFIF Discount_Volume_Deviation GT BB_Product_Quantity>
										<CFSET Volume_Deviation = BB_Product_Quantity>
									<CFELSE>
										<CFSET Volume_Deviation = Discount_Volume_Deviation>
									</CFIF>	
									<CFIF IsNumeric(BB_Product_Quantity) AND (BB_Product_Quantity NEQ "") AND BB_Product_Quantity NEQ 0>
										<CFSET Volume_Deviation_Percent=Evaluate("#Volume_Deviation#/#BB_Product_Quantity#*100")>
									<CFELSE>
										<CFSET Volume_Deviation_Percent=0>
									</CFIF>									
									<CFSET Volume_Deviation_Percent = Abs(Volume_Deviation_Percent)>
									<CFIF Volume_Deviation_Percent GT 100>
										<CFSET Volume_Deviation_Percent=100>
									</CFIF>
									<CFSET Discount_Amount_Volume_Deviation=(BB_Rate*Volume_Deviation_Percent)/100>									
								<CFELSE>
									<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="/billbacks/deviation/#This_Discount_Volume_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Volume</A></TD>
									<TD CLASS="YesValidDesc">#show_Yes#</TD>
								</CFIF>
							<CFELSE>
									<CFIF (Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR Generic_Type EQ DEVIATION_CONSTANTS_Operator_Deviated  OR Associated_Ship_to neq "")>
										<CFSET show_Status_Image = show_Question>
									<CFELSE>
										<CFSET show_Status_Image = show_Nothing>
									</CFIF>									
									<TD CLASS="NotprocessedValidDesc"><A CLASS="NotprocessedValidDesc" HREF="/billbacks/deviation/#This_Discount_Volume_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Volume</A></TD>
									<TD CLASS="NotprocessedValidDesc">#show_Status_Image#</TD>
							</CFIF>
								<TD COLSPAN="3">&nbsp; </TD>
								<TD COLSPAN="1" CLASS="programRight">&nbsp;</TD>
							</TR>
							
							
							<!--------- Date Overlap --------->
							<TR CLASS="productInTR">
								<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="3">&nbsp;</TD>
							<CFIF (SHOW_DISCOUNT_DATE_OVERLAP EQ 1) AND (Overlap NEQ "")>
									<CFIF Overlap GT 0>
									<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="/billbacks/deviation/Deviation_Product_Date_Overlap.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Date</A></TD>
									<TD CLASS="NoValidDesc">#show_No#</TD>
									<CFELSE>
									<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="/billbacks/deviation/Deviation_Product_Date_Overlap.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Date</A></TD>
									<TD CLASS="YesValidDesc">#show_Yes#</TD>
									</CFIF>									
							<CFELSE>
									<TD CLASS="NotprocessedValidDesc">Date</TD>
									<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
							</CFIF>
								<TD COLSPAN="3">&nbsp; </TD>
								<TD COLSPAN="1" CLASS="programRight">&nbsp;</TD>
							</TR>
						</CFOUTPUT>
					</CFIF>
					
					<!--------- Close Product ---------->
					<TR>
						<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
						<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
						<TD COLSPAN="7">&nbsp;</TD>
					 	<TD COLSPAN="2" CLASS="programRight">&nbsp;</TD>
					</TR>
				</CFOUTPUT>
			</CFIF>
			
			<!------------ End Programs --------------->
			<TR>
				<TD CLASS="payeeInsideTD">&nbsp;</TD>
				<TD COLSPAN="100%" CLASS="programBottom">&nbsp;</TD>
			</TR>
			<TR ID="Program_TR_NO_Colapse">				 
				<TD COLSPAN="100%" CLASS="payeeInsideTD">&nbsp;</TD>					
			</TR>
			
		</CFOUTPUT> <!----- Programs ----->
	</CFIF>	
	</TABLE>

	<DIV ALIGN="CENTER">
	<cfoutput>
	
	<input type="hidden" name="BBID" value="#Billback_ID#">
	<input type="hidden" name="E_Amount_Total" value="#E_Amount_Total#">
	<input type="hidden" name="Billback_Amount_Total" value="#BB_Amount_Total#">
	<input type="hidden" name="ProcessDetails" value="1">
	</cfoutput>
	<br>

	<INPUT TYPE="SUBMIT" ID="Save_Product_Approval" NAME="Save_Product_Approval" VALUE="&nbsp; Next&nbsp; " STYLE="background-Color:Orange">
	</DIV>
	</FORM>
</BLOCKQUOTE>
<CFOUTPUT>
<DIV ID="divTooltip" STYLE="position:absolute;visibility:hidden;background-color: F5F5DC; z-index: 5000;width:250;height:50;border:1px solid black;">
<TABLE CELLPADDING="2" CELLPADDING="0" BORDER="0">
	 	<TR>
			<TD>
				#show_Yes_Start#&nbsp;No Deviation
			</TD>
			<TD>
				#show_No_Start#&nbsp;Deviated
			</TD>
		</TR>
		<TR>
			<TD>
				#show_Question_Start#&nbsp;Not yet processed
			</TD>
			<TD>
				#show_Nothing_Start#&nbsp;Will not be processed
			</TD>
		</TR>
	</TABLE>
</DIV>
</CFOUTPUT>
<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js">
</SCRIPT>

 <SCRIPT LANGUAGE="JavaScript">
document.body.onload=new Function ("popupInit();")

function initTheTooltip()
{
	popUp(-1)
}
</SCRIPT>

<cfparam name="ApprovedTotal" 	default=0>
<!--------- Floating Layer -------------------->
<CFINCLUDE TEMPLATE="Generic_Floating_Layer.cfm">

<div id="floatLayer" style="position: absolute; height:85px; width:300px; left:15px; top:1px; z-index: 100; border: 1 solid Navy; background-color: F5F5F5;cursor:pointer;"> 

  <table border="0" cellspacing="0" cellpadding="2" align="center" id="oTable" onclick="layerDisplayToggle()" width="100%">

  	<TR align="center">
		<td colspan="100%" style="color: white; font-weight:bold; background-color: Navy;" height="20">Information Summary</td>
	</TR>

	<TR>
		<TD height="15"></TD>
	</TR>	
		  
  	<TR>
		<TD class="dataLabelStyle" align="right" nowrap width="30%">Total Amount:</TD>
		
		<CFOUTPUT>
		<TD class="dataStyle" nowrap width="70%">
		$<SPAN id="Total_Approved_Amount">#NumberFormat(Approved_Total_For_JavaScript, "-_.__")#</SPAN>		
		<INPUT TYPE="HIDDEN" ID="Tally_Total_Approved_Amount" NAME="Tally_Total_Approved_Amount" VALUE="#ApprovedTotal#">	
	
		</TD>	
		</CFOUTPUT>	
	</TR>  	
	  
  </table>

  <table border="0" cellspacing="0" cellpadding="0" align="center" id="minLabel">
	<TR>
		<TD height="30" style="cursor:pointer; color: blue;" onclick="layerDisplayToggle()">minimize this window</TD>
	</TR>
  </table>
	
  <div id="expandSpan" style="color:red;font-size:12px;cursor:pointer;display: none;" align="center" onclick="layerDisplayToggle()" title="Click Here To Expand This Window"><img src="/images/view_summary.gif"></div>

 </div>



<script src="/billbacks/common/common_js_functions.js"></script>
<script language="JavaScript"> 	
	storeinparent = 0;
	layerDisplayToggle();
	storeinparent = 1;
	function adjust_Tally_volume(thisObj)
	{
		//Volume BB_
		//Rate PR_
		
		var checkName = "PR_";
		var chObjCol = document.all[thisObj.name];
		var i, chLen, thisVolume, subtractVolume, checkedVolumeObj, subtractVolumeObj, startIndex;
		subtractVolume = 0;
		var DeltaAmount = 0;
		chLen = chObjCol.length;
		thisVolume = 0;
		for(i=0;i<chLen;i++)
		{
			if(chObjCol[i].checked)
			{
				checkedVolumeObj = chObjCol[i];				
				thisVolume = parseFloat(checkedVolumeObj.bvolume);
			}
			if(chObjCol[i].subtractVolume == 1)
			{
				subtractVolumeObj = chObjCol[i];
				subtractVolume = parseFloat(subtractVolumeObj.bvolume);
			}
		}
		if(checkedVolumeObj)
		{
			var PR_Started = 0;
			var Volume_Started = 0;
			var nameStart, thisAmount;
			startIndex = checkedVolumeObj.sourceIndex;
			chObjCol = document.getElementsByTagName("INPUT");
			chLen = chObjCol.length;
			for(i=0;i<chLen;i++)
			{	
				if(chObjCol[i] == checkedVolumeObj)
				{
					if(PR_Started)
					{
						break;
					}
					Volume_Started = 1;
				}
				if(Volume_Started)
				{	
					if(chObjCol[i].type == "radio")
					{
						nameStart = chObjCol[i].name.substr(0, checkName.length);
						if(nameStart != checkName)
						{
							if(PR_Started)
							{
								break;
							}
						}
						else if(chObjCol[i].brate)
						{
							PR_Started = 1;
							chObjCol[i].bvolume = thisVolume;
							if(chObjCol[i].checked)
							{								
								thisAmount = (thisVolume - subtractVolume) * parseFloat(chObjCol[i].brate);
								DeltaAmount = parseFloat(DeltaAmount) + thisAmount;							
							}
						}
					}
				}
			}			
		}
		
		if(subtractVolumeObj)
		{
			subtractVolumeObj.subtractVolume = 0;
		}
		if(checkedVolumeObj)
		{
			checkedVolumeObj.subtractVolume = 1;
		}
		
		var existing_Amount = parseFloat(document.all.Total_Approved_Amount.innerText);
		existing_Amount = formatToDeciamalPlaces(existing_Amount, 2) + formatToDeciamalPlaces(DeltaAmount, 2);
		
		existing_Amount = formatToDeciamalPlaces(existing_Amount, 2);
		
		document.all.Total_Approved_Amount.innerText = existing_Amount;		
		event.cancelBubble = true;
	}
	
	function adjust_Tally_rate(thisObj)
	{
		
		var i,chLen;
		var chObjCol = document.all[thisObj.name];
		var DeltaAmount = 0;
		var thisRate = 0;
		var subtractRate = 0;
		var thisVolume = 0;
		var checkedRateObj, subtractRateObj;
		chLen = chObjCol.length;

		for(i=0;i<chLen;i++)
		{
			if(chObjCol[i].checked)
			{
				checkedRateObj = chObjCol[i];				
				thisRate = checkedRateObj.brate;
				thisVolume = checkedRateObj.bvolume;
			}
			if(chObjCol[i].subtractRate == 1)
			{
				subtractRateObj = chObjCol[i];
				subtractRate = subtractRateObj.brate;
			}
		}
		if(subtractRateObj)
		{
			subtractRateObj.subtractRate = 0;
		}
		if(checkedRateObj)
		{
			checkedRateObj.subtractRate = 1;
		}
		if(checkedRateObj)
		{	
			DeltaAmount = (thisRate - subtractRate) * thisVolume;
			var existing_Amount = parseFloat(document.all.Total_Approved_Amount.innerText);
			existing_Amount = formatToDeciamalPlaces(existing_Amount, 2) + formatToDeciamalPlaces(DeltaAmount, 2);
			existing_Amount = formatToDeciamalPlaces(existing_Amount, 2);
			document.all.Total_Approved_Amount.innerText = existing_Amount;		
			event.cancelBubble = true;
		}
		
	}
</script>
<!--------- Floating Layer -------------------->

</BODY>
</HTML>

<!--- update the status flags in the menu --->
<CFSET thisBBID = Billback_ID>
<cfinclude template="../capture/Billback_Status_Indicator.cfm">

