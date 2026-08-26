<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFINCLUDE TEMPLATE="Deviation_Constants.CFM">

<CFPARAM NAME="URL.Billback_Product_Detail_ID"								DEFAULT="">
<CFSET Billback_Product_Detail_ID=URL.Billback_Product_Detail_ID>

<html>
<head>
	<title>Billback <cfoutput>#appSettings.getDeviationLabel()#</cfoutput> - Product</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<BLOCKQUOTE>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

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

<CFQUERY  NAME="Billback_This_Discount_Type_Product_Detail" dataSource="#application.datasource#">

	SELECT	Billback_Program.Billback_ID,
			Billback_Product.Product_ID,
			CASE 
				WHEN Billback_Product.Product_ID IS NULL THEN
					Billback_Product.BB_Unknown_Product_Item_Number
				ELSE
					BSA_Foodservice_Items_Master.Item
			END AS Product_Item,
			CASE 
				WHEN Billback_Product.Product_ID IS NULL THEN
					Billback_Product.BB_Unknown_Product_Description
				ELSE
					BSA_Foodservice_Items_Master.Description
			END AS Product_Desc,
			Billback_Product_Detail.BB_Product_Type_ID,
			CASE
				WHEN Billback_Program.Program_ID IS NULL THEN
					Billback_Program.BB_Program_Number
				ELSE
					Contract_main.Contract_Number
			END AS Program_Number,
			CASE
				WHEN Billback_Program.Program_ID IS NULL THEN
					Billback_Program.BB_Program_Title
				ELSE
					Contract_main.Contract_Title
			END AS Program_Title,
			Billback_Product_Detail.BB_Rate
	FROM	Billback_Product_Detail
			INNER JOIN	Billback_Product ON((Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
			AND(Billback_Product.Deleted = 0))		
			LEFT JOIN	BSA_Foodservice_Items_Master ON((BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID))
			INNER JOIN	Billback_Program ON((Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID)
			AND (Billback_Program.Deleted = 0))
			LEFT JOIN	Contract_main ON((Contract_main.Contract_main_ID = Billback_Program.Program_ID))
	WHERE	Billback_Product_Detail.Deleted = 0				
	AND		Billback_Product_Detail.Billback_Product_Detail_ID = '#Billback_Product_Detail_ID#'
	
</CFQUERY>

<cfset useLakebaseForqBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqBillback>
	<cftry>
		<cfset qBillback = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_This_Discount_Type_Product_Detail.Billback_ID#",
				"select" = "bb_start_date,bb_end_date"
			}), "bb_start_date,bb_end_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqBillback>
<CFQUERY NAME="qBillback" dataSource="#application.datasource#">
	SELECT	BB_Start_Date, BB_End_Date
	FROM	Billback
	WHERE	Billback_ID = '#Billback_This_Discount_Type_Product_Detail.Billback_ID#'
</CFQUERY>
</cfif>

<cfset billback_start_date = qBillback.BB_Start_Date />
<cfset billback_end_date = qBillback.BB_End_Date />

<CFSET Product_Type_ID = Billback_This_Discount_Type_Product_Detail.BB_Product_Type_ID>
<CFSET Product_ID = Billback_This_Discount_Type_Product_Detail.Product_ID>

<cfset ProductReplacementID = "" />
<cfif appSettings.getProductReplacementEnabled()>
	<cfset BillbackDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
	<cfset ProductReplacementID = BillbackDeviationManager.getProductReplacementID(productId=Product_ID)>
</cfif>

<CFQUERY  NAME="Billback_This_Discount_Type_Products" dataSource="#application.datasource#">
	DECLARE @Date_Tolerance INT
	SELECT @Date_Tolerance = Date_Tolerance FROM _Application_Settings

	SELECT	DISTINCT 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
			BSA_Foodservice_Items_Master.Description, 
			BSA_Foodservice_Items_Master.Item, 
			BSA_Foodservice_Items_Master.UPC
	FROM	Billback_Product_Detail
			INNER JOIN	Billback_Product ON ((Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
			AND (Billback_Product.Deleted = 0))
			INNER JOIN	Billback_Program ON ((Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID)
			AND(Billback_Program.Deleted = 0))
			INNER JOIN 	Contract_Main
			ON
			(
				(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
			)
			INNER JOIN BB_Program_Info
			ON
			(
				(BB_Program_Info.Contract_Number = Contract_Main.Contract_Number)
				AND	
				(-- check for any overlap between program version dates and billback dates
					(-- program start date is between bb dates
					datediff(d, #createodbcdate(billback_start_date)#, BB_Program_Info.Approval_Start_Date) >= 0
						and 
						(
							datediff(d, BB_Program_Info.Approval_Start_Date, #createodbcdate(billback_end_date)#) >= 0							
							OR 
							/* Dev Note:45782 and 46562 - Normally a billback should be within the program's dates (at least a day) to be picked up, but when the
							"Date_Tolerance" has a value, the billback dates could be within the "date tolerance" limit to be considered.
							*/
							(@Date_Tolerance != 0 AND datediff(d,  '#billback_end_date#', Contract_Main.Effective_Start_Date) <= @Date_Tolerance) 
						)
					)
					or
					(-- billback start date is between program dates
					datediff(d, BB_Program_Info.Approval_Start_Date, #createodbcdate(billback_start_date)#) >= 0
						and	
						(
							datediff(d, #createodbcdate(billback_start_date)#, BB_Program_Info.Approval_End_Date) >= 0
							OR
							/* Dev Note:45782 and 46562 - Normally a billback should be within the program's dates (at least a day) to be picked up, but when the
							"Date_Tolerance" has a value, the billback dates could be within the "date tolerance" limit to be considered.
							*/
							(@Date_Tolerance != 0 AND datediff(d, Contract_Main.Effective_End_Date, '#billback_start_date#') <= @Date_Tolerance)
						)
					)
				)
			)
			INNER JOIN	Contract_Products
			ON
			(
				(Contract_Products.Contract_Main_ID = BB_Program_Info.Contract_Main_ID)
				AND
				(Contract_Products.Deleted = 0)
				<!------ discount_type = 10 is bid request in programs, but as claim adjustment already used up the id 10 in billback,
					bid request has an id of 11 in billback, but when looking at program tables we have to keep using 10 ----->
				AND			
				(Contract_Products.Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID 
				OR (Contract_Products.Product_Type_ID = 10 AND Billback_Product_Detail.BB_Product_Type_ID = 11))
			)		
			INNER JOIN	BSA_Foodservice_Items_Master
			ON
			(
				(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID)
				AND	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID NOT IN 
				(
					SELECT	Product_ID 
					FROM	Program_Product_Bid_Info 
					WHERE	Program_ID	= Contract_Main.Contract_Main_ID
					AND		Product_ID	= Contract_Products.BSA_Foodservice_Items_Master_ID
					AND		Won			= 0
					AND		Deleted		= 0
				)			
			)
	WHERE	Billback_Product_Detail.Deleted = 0				
	AND		Billback_Product_Detail.Billback_Product_Detail_ID = '#Billback_Product_Detail_ID#'
	<CFIF Product_Type_ID EQ 1>
	AND
			EXISTS
			(
				SELECT	Program_Fixed_Price_Product_Data_ID
				FROM	Program_Fixed_Price_Product_Data
				WHERE	
					Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					AND
					Program_Fixed_Price_Product_Data.Fixed_Price_Value IS NOT NULL
					AND
					Program_Fixed_Price_Product_Data.Deleted = 0
			)
	</CFIF>
	<CFIF Product_Type_ID EQ 2>
	AND
			EXISTS
			(
				SELECT	Program_Rebates_Product_Data_ID
				FROM	Program_Rebates_Product_Data
				WHERE	
					Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					AND
					Program_Rebates_Product_Data.Deleted = 0
			)
	</CFIF>		
</CFQUERY>

<CFQUERY  NAME="Billback_This_Discount_Type_Lost_Products" dataSource="#application.datasource#">
	SELECT	DISTINCT 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
			BSA_Foodservice_Items_Master.Description, 
			BSA_Foodservice_Items_Master.Item, 
			BSA_Foodservice_Items_Master.UPC
	FROM	Billback_Product_Detail
			INNER JOIN	Billback_Product ON ((Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
			AND (Billback_Product.Deleted = 0))
			INNER JOIN	Billback_Program ON ((Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID)
			AND(Billback_Program.Deleted = 0))
			INNER JOIN 	Contract_Main
			ON
			(
				(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
			)
			INNER JOIN BB_Program_Info
			ON
			(
				(BB_Program_Info.Contract_Number = Contract_Main.Contract_Number)
			)
			INNER JOIN	Contract_Products
			ON
			(
				(Contract_Products.Contract_Main_ID = BB_Program_Info.Contract_Main_ID)
				AND
				(Contract_Products.Deleted = 0)
				<!------ discount_type = 10 is bid request in programs, but as claim adjustment already used up the id 10 in billback,
					bid request has an id of 11 in billback, but when looking at program tables we have to keep using 10 ----->
				AND			
				(Contract_Products.Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID 
				OR (Contract_Products.Product_Type_ID = 10 AND Billback_Product_Detail.BB_Product_Type_ID = 11))
			)		
			INNER JOIN	BSA_Foodservice_Items_Master
			ON
			(
				(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID)
				AND	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN 
				(
					SELECT	Product_ID 
					FROM	Program_Product_Bid_Info 
					WHERE	Program_ID	= Contract_Main.Contract_Main_ID
					AND		Product_ID	= Contract_Products.BSA_Foodservice_Items_Master_ID
					AND		Won			= 0
					AND		Deleted		= 0
				)			
			)
	WHERE	Billback_Product_Detail.Deleted = 0				
	AND		Billback_Product_Detail.Billback_Product_Detail_ID = '#Billback_Product_Detail_ID#'
	<CFIF Product_Type_ID EQ 1>
	AND
			EXISTS
			(
				SELECT	Program_Fixed_Price_Product_Data_ID
				FROM	Program_Fixed_Price_Product_Data
				WHERE	
					Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					AND
					Program_Fixed_Price_Product_Data.Fixed_Price_Value IS NOT NULL
					AND
					Program_Fixed_Price_Product_Data.Deleted = 0
			)
	</CFIF>
	<CFIF Product_Type_ID EQ 2>
	AND
			EXISTS
			(
				SELECT	Program_Rebates_Product_Data_ID
				FROM	Program_Rebates_Product_Data
				WHERE	
					Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					AND
					Program_Rebates_Product_Data.Deleted = 0
			)
	</CFIF>		
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

<CFSET Discount_Type_List="Fixed Price, #Application.RebateLabel#, #Application.LumpsumLabel#, Growth, Formula Price,6,7,8,9,10,Bid Request">

<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0">
	<COLGROUP>
		<COL SPAN=2 NOWARAP STYLE="FONT-WEIGHT:BOLD;"></COL>
	</COLGROUP>
	<TR VALIGN="TOP">
		<TD>
		Program</TD>
		<TD>&nbsp;:&nbsp;</TD>
		<TD>[#Billback_This_Discount_Type_Product_Detail.Program_Number#] #Billback_This_Discount_Type_Product_Detail.Program_Title#
		</TD>
	</TR>
	<TR VALIGN="TOP">
		<TD>Claimed Product</TD>
		<TD>&nbsp;:&nbsp;</TD>
		<TD>#Billback_This_Discount_Type_Product_Detail.Product_Item#<BR>#Billback_This_Discount_Type_Product_Detail.Product_Desc#
		</TD>
	</TR>
	<TR VALIGN="TOP">
		<TD>Claimed Discount Type</TD>
		<TD>&nbsp;:&nbsp;</TD>
		<TD>#ListGetAt(Discount_Type_List, Billback_This_Discount_Type_Product_Detail.BB_Product_Type_ID, ",")#
		</TD>
	</TR>
</TABLE>

<BR>

<FONT SIZE=2><B>Authorized Product List for discount type #ListGetAt(Discount_Type_List, Billback_This_Discount_Type_Product_Detail.BB_Product_Type_ID, ",")#</B></CAPTION>
<HR COLOR="Orange">
</CFOUTPUT>

<CFIF Billback_This_Discount_Type_Products.recordCount GT 0>

<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" CLASS="Maintable" WIDTH="500">
	<THEAD BGCOLOR="FFCE84">
		<TD WIDTH="5%">&nbsp;</TD>
		<TD WIDTH="20%"><FONT SIZE="-1"><b><cfoutput>#application.returned_customer_setting.item_label#<</cfoutput>/b></FONT></TD>
		<TD WIDTH="20%"><FONT SIZE="-1"><b><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput></b></FONT></TD>
		<TD WIDTH="60%"><FONT SIZE="-1"><b>Description</b></FONT></TD>
		<TD>&nbsp;</TD>
	</THEAD>
		<CFOUTPUT QUERY="Billback_This_Discount_Type_Products">
		
		<cfif (Billback_This_Discount_Type_Products.currentRow mod 2) NEQ 0>
			<CFSET BGCOLOR="ccffcc">
		<CFELSE>
			<CFSET BGCOLOR="FFFFFF">
		</cfif>
		<CFIF (Product_ID EQ BSA_Foodservice_Items_Master_ID OR ProductReplacementID EQ BSA_Foodservice_Items_Master_ID)>
			<CFSET BGCOLOR="#DEVIATION_VALID_ROW_INDICATOR_COLOR#">
		</CFIF>
		<TR BGCOLOR="#BGCOLOR#">
			<TD>&nbsp;</TD>
			<TD>#Item#</TD>
			<TD>#UPC#&nbsp;</TD>
			<TD>#Description#</TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFOUTPUT>
</TABLE>
<CFELSE>
	<FONT COLOR="Red"><B>No Products Found</B></FONT><BR>
</CFIF>

<br>
<CFOUTPUT>
<FONT SIZE=2><B>Products Marked as Lost for discount type #ListGetAt(Discount_Type_List, Billback_This_Discount_Type_Product_Detail.BB_Product_Type_ID, ",")#</B></CAPTION>
<HR COLOR="Orange">
</CFOUTPUT>

<CFIF Billback_This_Discount_Type_Lost_Products.recordCount GT 0>

<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" CLASS="Maintable" WIDTH="500">
	<THEAD BGCOLOR="FFCE84">
		<TD WIDTH="5%">&nbsp;</TD>
		<TD WIDTH="20%"><FONT SIZE="-1"><b><cfoutput>#application.returned_customer_setting.item_label#<</cfoutput>/b></FONT></TD>
		<TD WIDTH="20%"><FONT SIZE="-1"><b><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput></b></FONT></TD>
		<TD WIDTH="60%"><FONT SIZE="-1"><b>Description</b></FONT></TD>
		<TD>&nbsp;</TD>
	</THEAD>
		<CFOUTPUT QUERY="Billback_This_Discount_Type_Lost_Products">
		
		<cfif (Billback_This_Discount_Type_Lost_Products.currentRow mod 2) NEQ 0>
			<CFSET BGCOLOR="ccffcc">
		<CFELSE>
			<CFSET BGCOLOR="FFFFFF">
		</cfif>
		<CFIF (Product_ID EQ BSA_Foodservice_Items_Master_ID OR ProductReplacementID EQ BSA_Foodservice_Items_Master_ID)>
			<CFSET BGCOLOR="#DEVIATION_VALID_ROW_INDICATOR_COLOR#">
		</CFIF>
		<TR BGCOLOR="#BGCOLOR#">
			<TD>&nbsp;</TD>
			<TD>#Item#</TD>
			<TD>#UPC#</TD>
			<TD>#Description#</TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFOUTPUT>
</TABLE>
<CFELSE>
	<FONT COLOR="Red"><B>No Products Found</B></FONT><BR>
</CFIF>

<CFQUERY NAME="Billback_Product_Deviation_Info" dataSource="#application.datasource#">
	SELECT	BB_Product_Deviation_Info.Unauthorized_Product
	FROM	Billback_Product_Detail
			INNER JOIN	Billback_Product
			ON
			(
				(Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID)
				AND
				(Billback_Product.Deleted = 0)		
			)
			INNER JOIN BB_Product_Deviation_Info
			ON
			(
				(BB_Product_Deviation_Info.Billback_Product_ID = Billback_Product.Billback_Product_ID)
				AND
				(BB_Product_Deviation_Info.Deleted = 0)
				AND
				(BB_Product_Deviation_Info.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
			)
	WHERE	Billback_Product_Detail.Billback_Product_Detail_ID = '#Billback_Product_Detail_ID#'
	AND		Billback_Product_Detail.Deleted = 0
</CFQUERY>

<BR><BR>
<B>Unauthorized Product <cfoutput>#appSettings.getDeviationLabel()#</cfoutput> calculation</B>
<HR COLOR="Orange">
<CFOUTPUT>
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="60%">	
	<TR VALIGN="TOP">
		<TD>#appSettings.getDeviationLabel()# Percentage</TD>
		<TD>A1</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>
		<CFSET Deviation_Percentage=100>
		<CFIF ISNumeric(Billback_This_Discount_Type_Product_Detail.BB_Rate) AND Billback_This_Discount_Type_Product_Detail.BB_Rate NEQ "" AND Billback_This_Discount_Type_Product_Detail.BB_Rate NEQ 0>
			<CFSET Deviation_Percentage=Evaluate("(#Billback_Product_Deviation_Info.Unauthorized_Product# * 100) / #Billback_This_Discount_Type_Product_Detail.BB_Rate#")>
		</CFIF>
		#NumberFormat(Deviation_Percentage, DEVIATION_PERCENT_FORMAT)#%
		</TD>
	</TR>
	<TR VALIGN="TOP">
		<TD>Amount claimed</TD>
		<TD>A2</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>#DollarFormat(Billback_This_Discount_Type_Product_Detail.BB_Rate)#</TD>
	</TR>
	<TR VALIGN="TOP">
		<TD>#appSettings.getDeviationLabel()# Amount</TD>
		<TD>A3 = A1 * A2</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>
		#DollarFormat(Billback_Product_Deviation_Info.Unauthorized_Product)#
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

