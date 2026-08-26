<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfparam name="FORM.Deduction_ID" 	default="">
<cfparam name="URL.Deduction_ID" 	default="#FORM.Deduction_ID#">
<cfparam name="FORM.FromCredit" 	default="0">
<cfparam name="URL.FromCredit" 	default="#FORM.FromCredit#">
<cfparam name="FORM.FromDeduction" 	default="0">
<cfparam name="URL.FromDeduction" 	default="#FORM.FromDeduction#">
<cfparam name="FORM.SELECTION_ID" 	default="">
<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() /> 

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfset useLakebaseForDed_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForDed_Data>
	<cftry>
		<cfset Ded_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#Deduction_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDed_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDed_Data>
<CFQUERY NAME="Ded_Data" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Deductions WHERE Deduction_ID = '#Deduction_ID#' AND Deleted = 0
</CFQUERY>
</cfif>

<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="">
<CFSET CreditAssocAlreadyExist = 0 />


<!------ 
FORM.FormSubmitted = ""/0, means show first page with all =>< amounts
FORM.FormSubmitted = 1, means save into database
FORM.FormSubmitted = 2, means show multi selection form
 ----->
<CFIF FORM.FormSubmitted EQ 1>

	<CFIF FORM.FromCredit EQ 0>
		<!------ If from deduction --->
		
		<cfset returnValue = DeductionManager.associateCreditsToDeduction(
				deductionId = FORM.PassedDD,
				creditIdList = FORM.Selection_ID,
				fromCredit = 0) />
			
	<CFELSE>
		<!------ If from Credit --->
		
		<cfset returnValue = DeductionManager.associateCreditsToDeduction(
				deductionId = FORM.Selection_ID,
				creditIdList = FORM.PassedDD,
				fromCredit = 1) />
		
		<!------*********************************************************************************
		D16948: JRS - Deduction record was sent in GL Credit interface file
		check if this credit can be associated to a deduction - START
		It is possible that someone has already flagged it as write-off, associated to a billback or deduction
		*********************************************************************************------>
		
		<cfif returnValue eq 0>
		
		
			<BR><BR><BR><BR>
			
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>
						<B><FONT COLOR="Red" SIZE="3">
							You cannot associate this credit to a deduction at this point.
							<br>It is possible that this credit is already flagged as write-off or associated to a deduction. 
						</FONT></B>
					
					</TD>
				</TR>
			</TABLE>
			<SCRIPT language="JavaScript">
			function relocateThis()
			{
				window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#FORM.PassedDD#</CFOUTPUT>"
			}
			window.setTimeout('relocateThis()', 3000);	
			</SCRIPT>
			
			<cfabort>
		
		</cfif>
		
	</CFIF>	
	
	<BR><BR><BR><BR>
	
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">
			<CFIF FORM.SELECTION_ID NEQ "">
			This <CFIF FORM.FromCredit EQ 1>Credit<CFELSE>Deduction</CFIF> has been Associated with the selected <CFIF FORM.FromCredit EQ 1>Deduction<CFELSE>Credit(s)</CFIF>.
			<CFELSEIF FORM.FORMCreditAssocAlreadyExist EQ 1 AND FORM.FromCredit EQ 0>
			All existing Credit associations has been removed for this Deduction.
			</CFIF>			
			</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function relocateThis()
	{
		window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#FORM.PassedDD#</CFOUTPUT>"
	}
	window.setTimeout('relocateThis()', 2000);	
	</SCRIPT>
	<CFABORT>
</CFIF>
<CFSET CurrentDeductionAmount = 0 />
<CFIF URL.FromCredit EQ 1>
	<CFQUERY NAME="GetEqualDD" DATASOURCE="#Application.Datasource#">
		SELECT 	Deductions.Distributor_ID,Deductions.Deduction_ID, Deductions.DD_Reference,
					Deductions.DD_DedID_SP_Number, Deductions.DD_Amount
		FROM 		Deductions Credit
		INNER JOIN 	Deductions ON  Deductions.Distributor_ID = Credit.Distributor_ID 
		WHERE 		Credit.Deduction_ID = '#Deduction_ID#' AND Deductions.Is_Credit <> 1 AND Deductions.DD_Status IN (1,2) AND
					Deductions.DD_Amount = ABS(Credit.DD_Amount) AND 
					Deductions.DD_Closure_ID IS NULL AND
					Deductions.Is_Write_Off = 0 AND
					Deductions.Deduction_ID NOT IN (SELECT DISTINCT DD_Parent_ID FROM Deductions WHERE DD_Parent_ID IS NOT NULL AND Deleted = 0) AND
					Deductions.Deleted = 0 AND 
					Credit.Deleted = 0
		ORDER BY	Deductions.DD_Amount, Deductions.DD_Reference, Deductions.DD_DedID_SP_Number 
	</CFQUERY>
	
	<CFQUERY NAME="GetEqualDDSameARDiffCust" DATASOURCE="#Application.Datasource#">
		SELECT 	Deductions.Distributor_ID,Deductions.Deduction_ID, Deductions.DD_Reference,
					Deductions.DD_DedID_SP_Number, Deductions.DD_Amount,
					BSA_FoodService_Customers.Name Distributor_Name 
		FROM 		Deductions Credit
		INNER JOIN 	Deductions
		ON  		Credit.Distributor_ID <> Deductions.Distributor_ID
		AND			Credit.DD_Reference = Deductions.DD_Reference
		LEFT JOIN 	BSA_FoodService_Customers
		ON			BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Deductions.Distributor_ID
		WHERE 		Credit.Deduction_ID = '#Deduction_ID#' AND Deductions.Is_Credit <> 1 AND Deductions.DD_Status IN (1,2) AND
					Deductions.DD_Amount = ABS(Credit.DD_Amount) AND 
					Deductions.DD_Closure_ID IS NULL AND
					Deductions.Is_Write_Off = 0 AND
					Deductions.Deduction_ID NOT IN (SELECT DISTINCT DD_Parent_ID FROM Deductions WHERE DD_Parent_ID IS NOT NULL AND Deleted = 0) AND
					Deductions.Deleted = 0 AND 
					Credit.Deleted = 0 
								
		ORDER BY	Deductions.DD_Amount, BSA_FoodService_Customers.Name, Deductions.DD_Reference, Deductions.DD_DedID_SP_Number 
	</CFQUERY>	
	
	<CFQUERY NAME="GetGreaterDD" DATASOURCE="#Application.Datasource#">
		SELECT 	Deductions.Distributor_ID,Deductions.Deduction_ID, Deductions.DD_Reference,
					Deductions.DD_DedID_SP_Number, Deductions.DD_Amount 
		FROM 		Deductions Credit
		INNER JOIN 	Deductions ON  Deductions.Distributor_ID = Credit.Distributor_ID 
		WHERE 		Credit.Deduction_ID = '#Deduction_ID#' AND Deductions.Is_Credit <> 1 AND Deductions.DD_Status IN (1,2) AND
					Deductions.DD_Amount > ABS(Credit.DD_Amount) AND 
					Deductions.DD_Amount > 0 AND
					Deductions.DD_Closure_ID IS NULL AND
					Deductions.Is_Write_Off = 0 AND
					Deductions.Deduction_ID NOT IN (SELECT DISTINCT DD_Parent_ID FROM Deductions WHERE DD_Parent_ID IS NOT NULL AND Deleted = 0) AND
					Deductions.Deleted = 0 AND 
					Credit.Deleted = 0
		
		ORDER BY 	Deductions.DD_Amount, Deductions.DD_Reference, Deductions.DD_DedID_SP_Number 
	</CFQUERY>
	
	<CFQUERY NAME="GetLesserDD" DATASOURCE="#Application.Datasource#">
		SELECT 	Deductions.Distributor_ID,Deductions.Deduction_ID, Deductions.DD_Reference,
					Deductions.DD_DedID_SP_Number, Deductions.DD_Amount, Credit.DD_Amount AS Deduction_Total_Amount
		FROM 		Deductions Credit
		INNER JOIN 	Deductions ON  Deductions.Distributor_ID = Credit.Distributor_ID 
		WHERE 		Credit.Deduction_ID = '#Deduction_ID#' AND Deductions.Is_Credit <> 1 AND Deductions.DD_Status IN (1,2) AND
					Deductions.DD_Amount < ABS(Credit.DD_Amount) AND 
					Deductions.DD_Amount > 0 AND
					Deductions.DD_Closure_ID IS NULL AND
					Deductions.Is_Write_Off = 0 AND
					Deductions.Deduction_ID NOT IN (SELECT DISTINCT DD_Parent_ID FROM Deductions WHERE DD_Parent_ID IS NOT NULL AND Deleted = 0) AND
					Deductions.Deleted = 0 AND 
					Credit.Deleted = 0
		
		ORDER BY 	Deductions.DD_Amount, Deductions.DD_Reference, Deductions.DD_DedID_SP_Number 
	</CFQUERY>
	
	<CFQUERY NAME="GetLesserDDSameARDiffCust" DATASOURCE="#Application.Datasource#">
		SELECT 	Deductions.Distributor_ID,Deductions.Deduction_ID, Deductions.DD_Reference,
					Deductions.DD_DedID_SP_Number, Deductions.DD_Amount, Credit.DD_Amount AS Deduction_Total_Amount,
					BSA_FoodService_Customers.Name Distributor_Name
		FROM 		Deductions Credit
		INNER JOIN 	Deductions 
		ON  		Credit.Distributor_ID <> Deductions.Distributor_ID
		AND			Credit.DD_Reference = Deductions.DD_Reference
		LEFT JOIN 	BSA_FoodService_Customers
		ON			BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Deductions.Distributor_ID
		WHERE 		Credit.Deduction_ID = '#Deduction_ID#' AND Deductions.Is_Credit <> 1 AND Deductions.DD_Status IN (1,2) AND
					Deductions.DD_Amount < ABS(Credit.DD_Amount) AND 
					Deductions.DD_Amount > 0 AND
					Deductions.DD_Closure_ID IS NULL AND
					Deductions.Is_Write_Off = 0 AND
					Deductions.Deduction_ID NOT IN (SELECT DISTINCT DD_Parent_ID FROM Deductions WHERE DD_Parent_ID IS NOT NULL AND Deleted = 0) AND
					Deductions.Deleted = 0 AND 
					Credit.Deleted = 0
		
		ORDER BY 	Deductions.DD_Amount, BSA_FoodService_Customers.Name, Deductions.DD_Reference, Deductions.DD_DedID_SP_Number 
	</CFQUERY>	
<CFELSEIF URL.FromDeduction EQ 1>
	<cfset AssociatedCredit = DeductionManager.getAssociatedCredits(Deduction_ID) />	
	<CFIF AssociatedCredit.RecordCount GT 0>
		<CFSET CreditAssocAlreadyExist = 1 />
	</CFIF>
	
	<cfset useLakebaseForqGetDeduction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForqGetDeduction>
		<cftry>
			<cfset qGetDeduction = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"select" = "dd_amount",
					"deduction_id" = "eq.#Deduction_ID#"
				}),
				"dd_amount"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForqGetDeduction = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForqGetDeduction>
	<CFQUERY NAME="qGetDeduction" DATASOURCE="#Application.Datasource#">
		SELECT 		Deductions.DD_Amount
		FROM 		Deductions 
		WHERE 		Deductions.Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
	</cfif>
	
	<CFSET CurrentDeductionAmount = qGetDeduction.DD_Amount />
	
	<CFQUERY NAME="GetEqualDD" DATASOURCE="#Application.Datasource#">
		SELECT 		Credit.Distributor_ID,Credit.Deduction_ID, Credit.DD_Reference,
					Credit.DD_DedID_SP_Number, Credit.DD_Amount
		FROM 		Deductions 
		INNER JOIN 	Deductions Credit ON  Credit.Distributor_ID = Deductions.Distributor_ID
		WHERE 		Deductions.Deduction_ID = '#Deduction_ID#' AND 
					Credit.Is_Credit = 1 AND 
					Credit.DD_Status IN (8, 9) AND
					Deductions.DD_Amount = ABS(Credit.DD_Amount) AND 
					(
					(
					Credit.DD_Status = 8 AND
					Credit.Is_Write_Off = 0 AND
					Credit.DD_Closure_ID IS NULL)
					OR (Credit.DD_Status = 9 AND Credit.DD_Closure_ID = <cfqueryparam value="#Deduction_ID#" cfsqltype="CF_SQL_VARCHAR">)
					)
					AND
					Credit.Deduction_ID NOT IN (SELECT DISTINCT DD_Parent_ID FROM Deductions WHERE DD_Parent_ID IS NOT NULL AND Deleted = 0) AND
					Credit.Deleted = 0 AND 
					Deductions.Deleted = 0 
								
		ORDER BY	Credit.DD_Amount, Credit.DD_Reference, Credit.DD_DedID_SP_Number 
	</CFQUERY>
	
	<CFQUERY NAME="GetEqualDDSameARDiffCust" DATASOURCE="#Application.Datasource#">
		SELECT 		Credit.Distributor_ID,Credit.Deduction_ID, Credit.DD_Reference,
					Credit.DD_DedID_SP_Number, Credit.DD_Amount,
					BSA_FoodService_Customers.Name Distributor_Name
		FROM 		Deductions 
		INNER JOIN 	Deductions Credit 
		ON  		Credit.Distributor_ID <> Deductions.Distributor_ID
		AND			Credit.DD_Reference = Deductions.DD_Reference
		LEFT JOIN 	BSA_FoodService_Customers
		ON			BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Credit.Distributor_ID
		WHERE 		Deductions.Deduction_ID = '#Deduction_ID#' AND 
					Credit.Is_Credit = 1 AND 
					Credit.DD_Status IN (8, 9) AND
					Deductions.DD_Amount = ABS(Credit.DD_Amount) AND 
					(
					(
					Credit.DD_Status = 8 AND
					Credit.Is_Write_Off = 0 AND
					Credit.DD_Closure_ID IS NULL)
					OR (Credit.DD_Status = 9 AND Credit.DD_Closure_ID = <cfqueryparam value="#Deduction_ID#" cfsqltype="CF_SQL_VARCHAR">)
					)
					AND
					Credit.Deduction_ID NOT IN (SELECT DISTINCT DD_Parent_ID FROM Deductions WHERE DD_Parent_ID IS NOT NULL AND Deleted = 0) AND
					Credit.Deleted = 0 AND 
					Deductions.Deleted = 0 
								
		ORDER BY	Credit.DD_Amount, BSA_FoodService_Customers.Name, Credit.DD_Reference, Credit.DD_DedID_SP_Number 
	</CFQUERY>
		
	<CFQUERY NAME="GetGreaterDD" DATASOURCE="#Application.Datasource#">
		SELECT 		Credit.Distributor_ID,Credit.Deduction_ID, Credit.DD_Reference,
					Credit.DD_DedID_SP_Number, Credit.DD_Amount 
		FROM 		Deductions 
		INNER JOIN 	Deductions Credit ON  Credit.Distributor_ID = Deductions.Distributor_ID
		WHERE 		Deductions.Deduction_ID = '#Deduction_ID#' AND 
					Credit.Is_Credit = 1 AND 
					Credit.DD_Status IN (8, 9) AND
					ABS(Credit.DD_Amount) > Deductions.DD_Amount  AND 
					Credit.DD_Amount < 0 AND
					(
					(
					Credit.DD_Status = 8 AND
					Credit.Is_Write_Off = 0 AND
					Credit.DD_Closure_ID IS NULL)
					OR (Credit.DD_Status = 9 AND Credit.DD_Closure_ID = <cfqueryparam value="#Deduction_ID#" cfsqltype="CF_SQL_VARCHAR">)
					)
					AND
					Credit.Deduction_ID NOT IN (SELECT DISTINCT DD_Parent_ID FROM Deductions WHERE DD_Parent_ID IS NOT NULL AND Deleted = 0) AND
					Credit.Deleted = 0 AND 
					Deductions.Deleted = 0 
		
		ORDER BY 	Credit.DD_Amount DESC, Credit.DD_Reference, Credit.DD_DedID_SP_Number 
	</CFQUERY>
	
	<CFQUERY NAME="GetLesserDD" DATASOURCE="#Application.Datasource#">
		SELECT 		Credit.Distributor_ID,Credit.Deduction_ID, Credit.DD_Reference,
					Credit.DD_DedID_SP_Number, Credit.DD_Amount, Deductions.DD_Amount AS Deduction_Total_Amount,
					Credit.DD_Closure_ID Credit_DD_Closure_ID
		FROM 		Deductions 
		INNER JOIN 	Deductions Credit ON  Credit.Distributor_ID = Deductions.Distributor_ID
		WHERE 		Deductions.Deduction_ID = <cfqueryparam value="#Deduction_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					Credit.Is_Credit = 1 AND 
					Credit.DD_Status IN (8, 9) AND
					ABS(Credit.DD_Amount) < Deductions.DD_Amount  AND 
					Credit.DD_Amount < 0 AND
					(
					(
					Credit.DD_Status = 8 AND
					Credit.Is_Write_Off = 0 AND
					Credit.DD_Closure_ID IS NULL)
					OR (Credit.DD_Status = 9 AND Credit.DD_Closure_ID = <cfqueryparam value="#Deduction_ID#" cfsqltype="CF_SQL_VARCHAR">)
					)
					AND					
					Credit.Deduction_ID NOT IN (SELECT DISTINCT DD_Parent_ID FROM Deductions WHERE DD_Parent_ID IS NOT NULL AND Deleted = 0) AND
					Credit.Deleted = 0 AND 
					Deductions.Deleted = 0 
		
		ORDER BY 	Credit.DD_Amount DESC, Credit.DD_Reference, Credit.DD_DedID_SP_Number		
	</CFQUERY>
	
	<CFQUERY NAME="GetLesserDDSameARDiffCust" DATASOURCE="#Application.Datasource#">
		SELECT 		Credit.Distributor_ID,Credit.Deduction_ID, Credit.DD_Reference,
					Credit.DD_DedID_SP_Number, Credit.DD_Amount, Deductions.DD_Amount AS Deduction_Total_Amount,
					Credit.DD_Closure_ID Credit_DD_Closure_ID,
					BSA_FoodService_Customers.Name Distributor_Name
		FROM 		Deductions 
		INNER JOIN 	Deductions Credit 
		ON  		Credit.Distributor_ID <> Deductions.Distributor_ID
		AND			Credit.DD_Reference = Deductions.DD_Reference
		LEFT JOIN 	BSA_FoodService_Customers
		ON			BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Credit.Distributor_ID
		WHERE 		Deductions.Deduction_ID = <cfqueryparam value="#Deduction_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					Credit.Is_Credit = 1 AND 
					Credit.DD_Status IN (8, 9) AND
					ABS(Credit.DD_Amount) < Deductions.DD_Amount  AND 
					Credit.DD_Amount < 0 AND
					(
					(
					Credit.DD_Status = 8 AND
					Credit.Is_Write_Off = 0 AND
					Credit.DD_Closure_ID IS NULL)
					OR (Credit.DD_Status = 9 AND Credit.DD_Closure_ID = <cfqueryparam value="#Deduction_ID#" cfsqltype="CF_SQL_VARCHAR">)
					)
					AND					
					Credit.Deduction_ID NOT IN (SELECT DISTINCT DD_Parent_ID FROM Deductions WHERE DD_Parent_ID IS NOT NULL AND Deleted = 0) AND
					Credit.Deleted = 0 AND 
					Deductions.Deleted = 0 
		
		ORDER BY 	Credit.DD_Amount DESC, BSA_FoodService_Customers.Name, Credit.DD_Reference, Credit.DD_DedID_SP_Number		
	</CFQUERY>	
</CFIF>
<CFOUTPUT>
<FORM NAME="LinkCreditDD" ACTION = "LinkDeduction.cfm" METHOD="POST" STYLE="DISPLAY:INLINE;">
<INPUT TYPE="Hidden" NAME="FormSubmitted" VALUE="0"> 

<INPUT TYPE="Hidden" NAME="FORMCreditAssocAlreadyExist" VALUE="#CreditAssocAlreadyExist#">

<INPUT Type="Hidden" NAME="FromCredit" VALUE="#URL.FromCredit#">
<INPUT Type="Hidden" NAME="FromDeduction" VALUE="#URL.FromDeduction#">

<INPUT TYPE="Hidden" NAME="PassedDD" VALUE="#URL.Deduction_ID#">
<INPUT TYPE="Hidden" NAME="Deduction_ID" VALUE="#URL.Deduction_ID#">

<CFSET CHK_STR = "" />
<CFIF URL.FromDeduction EQ 1>
	<CFSET CHK_STR = "onpropertychange=""javascript:addRemoveCredit(this)""" />
</CFIF>
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">
	<CFIF GetEqualDD.RecordCount GT 0 OR GetEqualDDSameARDiffCust.RecordCount GT 0>
		<CFIF URL.FromCredit EQ 1>
			<CFSET Button_Caption = "Associate Deduction">
			<TR>
				<TD COLSPAN="100%" ALIGN="Center"><BR>
						<CF_button
							button_name	=	""
							button_caption	=	"#Button_Caption# "
							button_action	=	"validation()"
							button_type	=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight	=	"bold"
										><BR><BR></TD>
			</TR>
		</CFIF>		
	</CFIF>	
	
	<CFIF URL.FromDeduction EQ 1>
	
	<CFSET DISPLAY_DIFF = Ded_Data.DD_Amount>
	<cfif AssociatedCredit.RecordCount>
		<CFSET DISPLAY_DIFF = 0 />
	</cfif>

	<TR>
		<TD COLSPAN="100%" ALIGN="Center" ID="TD_ASSOCIATE_MULTIPLE_CREDIT">		
		<BR>
			<cfif DISPLAY_DIFF NEQ 0>			
					<a onClick="javascript: return validationMultiSelect();" style="cursor: hand">	#application.util.string.actionLinkFormat2('Associate Credit(s)')#</a>
			<cfelse>			
					#application.util.string.actionLinkFormat2('Associate Credit(s)')#
			</cfif>
		</TD>
	</TR>

	<TR>
		<TD><B>Ded Ref ##: <font color="red">#Ded_Data.DD_Reference#</font></B></TD>
		<TD COLSPAN="100%" align="right">
		<B>Available Deduction Amount:</B>&nbsp;&nbsp;&nbsp;<SPAN ID="SP_DISPLAY_DIFF" STYLE="ALIGN:RIGHT;WIDTH:100px;TEXT-ALIGN:RIGHT;BORDER:1px solid navy;FONT-WEIGHT:BOLD;display:inline-block;">#DOLLARFORMAT(DISPLAY_DIFF)#</SPAN>
		<INPUT TYPE="HIDDEN" NAME="INP_DISPLAY_DIFF" ID="INP_DISPLAY_DIFF" VALUE="#DISPLAY_DIFF#" />	
		</TD>
	</TR>
	</CFIF>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////// SAME CUSTOMER ID - EQUAL AMOUNT ///////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->	
	<TR>
		<TD COLSPAN="100%"><FONT COLOR="Navy" SIZE="2"><B><CFIF URL.FromCredit EQ 1>Deduction<CFELSE>Credit</CFIF> = #application.returned_customer_setting.shard_ship_to_label# and = $ Amount</B></FONT><HR COLOR="Orange"></TD>
	</TR>
	<CFIF GetEqualDD.RecordCount GT 0>
	<TR>
	<CFSET count = 0>
	<CFLOOP QUERY="GetEqualDD">
		<CFSET Current_Item_Selected = 0 />
		<CFIF URL.FromDeduction EQ 1>
		<cfquery name="qCurrentCreditSelectedAlready" dbtype="query">
			SELECT	*
			FROM	AssociatedCredit
			WHERE	Credit_ID = '#Deduction_ID#'
		</cfquery>
		<cfif qCurrentCreditSelectedAlready.recordcount>
			<CFSET Current_Item_Selected = 1 />
		</cfif>
		</CFIF>
		<CFSET Count = Count + 1>		
		<CFIF Count LT 4>
			
		<CFELSE>
			<CFSET Count = 1>
			</TR>
			<TR>
		</CFIF>	
		<TD BGCOLOR = "C6FFC6" STYLE = "Border: solid white 1px">
		<CFIF URL.FromDeduction EQ 1>
		<INPUT TYPE="Checkbox" NAME="Selection_ID" VALUE="#Deduction_ID#" AMOUNT="#DD_Amount#" #CHK_STR# <CFIF Current_Item_Selected EQ 1> CHECKED</CFIF>>
		<CFELSE>
		<INPUT TYPE="Radio" NAME="Selection_ID" VALUE="#Deduction_ID#" #CHK_STR# <CFIF Current_Item_Selected EQ 1> CHECKED</CFIF>>
		</CFIF>		
		&nbsp;&nbsp;#DD_DedID_SP_Number# / REF: #DD_REFERENCE#</TD>
	</CFLOOP>
	</TR>
	<CFELSE>
	<TR>
		<TD COLSPAN="100%" BGCOLOR = "C6FFC6"><B>None</B></TD>
	</TR>
	</CFIF>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////// SAME CUSTOMER ID - LESS AMOUNT ///////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->	

	
	<TR>
		<TD COLSPAN="100%"><BR><BR><FONT COLOR="Navy" SIZE="2"><B><CFIF URL.FromCredit EQ 1>Deduction<CFELSE>Credit</CFIF> = #application.returned_customer_setting.shard_ship_to_label# and < $ Amount</B></FONT>
		<CFIF URL.FromDeduction EQ 1 AND GetLesserDD.RecordCount GT 0>
		<br>
		<CF_smallLink 
			title = "select all" 
			url = "##"
			parameters = "onClick=""javascript: return ApplyCheckAll('TR_LESS_SAME_CUST', 1);"""
		>&nbsp;&nbsp;
		<CF_smallLink 
			title = "de-select all" 
			url = "##"
			parameters = "onClick=""javascript: return ApplyCheckAll('TR_LESS_SAME_CUST', 0);"""
		>
		</CFIF>
		<HR COLOR="Orange">
		</TD>
	</TR>
	<CFIF GetLesserDD.RecordCount GT 0>	
	<TR ID="TR_LESS_SAME_CUST">
	<CFSET count = 0>
	<CFLOOP QUERY="GetLesserDD">
		<CFSET Current_Item_Selected = 0 />
		<CFIF URL.FromDeduction EQ 1>
		<cfquery name="qCurrentCreditSelectedAlready" dbtype="query">
			SELECT	*
			FROM	AssociatedCredit
			WHERE	Credit_ID = '#Deduction_ID#'
		</cfquery>
		<cfif qCurrentCreditSelectedAlready.recordcount>
			<CFSET Current_Item_Selected = 1 />
		</cfif>
		</CFIF>
		<CFSET Count = Count + 1>		
		<CFIF Count LT 4>
			
		<CFELSE>
			<CFSET Count = 1>
			</TR>
			<TR ID="TR_LESS_SAME_CUST">			
		</CFIF>	
			<TD STYLE = "Border: solid C6FFC6 1px"><CFIF URL.FromDeduction EQ 1><INPUT TYPE="Checkbox" NAME="Selection_ID" VALUE="#Deduction_ID#" AMOUNT="#DD_Amount#" #CHK_STR# <CFIF Current_Item_Selected EQ 1> CHECKED</CFIF>>&nbsp;&nbsp;</CFIF>
			<B>#DD_DedID_SP_Number#</B><BR>#DOLLARFORMAT(DD_Amount)# / REF: #DD_REFERENCE#</TD>
	</CFLOOP>
	</TR>	
	<CFELSE>
	<TR>
		<TD COLSPAN="100%" STYLE = "Border: solid C6FFC6 1px"><B>None</B></TD>
	</TR>
	</CFIF>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////// DIFF CUSTOMER ID - SAME AR/REF ## - EQUAL & Lesser AMOUNT ////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->	
	<TR>
		<TD COLSPAN="100%"><BR><BR><FONT COLOR="Navy" SIZE="2"><B><CFIF URL.FromCredit EQ 1>Deduction<CFELSE>Credit</CFIF> = Ded Ref ## and <> #application.returned_customer_setting.shard_ship_to_label# </B></FONT><HR COLOR="Orange"></TD>
	</TR>
	<CFIF GetEqualDDSameARDiffCust.RecordCount GT 0>
	<TR>
	<CFSET count = 0>
	<CFLOOP QUERY="GetEqualDDSameARDiffCust">
		<CFSET Current_Item_Selected = 0 />
		<CFIF URL.FromDeduction EQ 1>
		<cfquery name="qCurrentCreditSelectedAlready" dbtype="query">
			SELECT	*
			FROM	AssociatedCredit
			WHERE	Credit_ID = '#Deduction_ID#'
		</cfquery>
		<cfif qCurrentCreditSelectedAlready.recordcount>
			<CFSET Current_Item_Selected = 1 />
		</cfif>
		</CFIF>
		<CFSET Count = Count + 1>		
		<CFIF Count LT 4>
			
		<CFELSE>
			<CFSET Count = 1>
			</TR>
			<TR>
		</CFIF>	
		<TD BGCOLOR = "C6FFC6" STYLE = "Border: solid white 1px">
		<CFIF URL.FromDeduction EQ 1>
		<INPUT TYPE="Checkbox" NAME="Selection_ID" VALUE="#Deduction_ID#" AMOUNT="#DD_Amount#" #CHK_STR# <CFIF Current_Item_Selected EQ 1> CHECKED</CFIF>>
		<CFELSE>
		<INPUT TYPE="Radio" NAME="Selection_ID" VALUE="#Deduction_ID#" #CHK_STR# <CFIF Current_Item_Selected EQ 1> CHECKED</CFIF>>
		</CFIF>		
		&nbsp;&nbsp;#DD_DedID_SP_Number# / #application.returned_customer_setting.shard_ship_to_label#: #Distributor_Name#</TD>
	</CFLOOP>
	</TR>	
	</CFIF>	
	<CFIF GetLesserDDSameARDiffCust.RecordCount GT 0> 
	<TR>
		<TD>
			<CFIF URL.FromDeduction EQ 1 AND GetLesserDDSameARDiffCust.RecordCount GT 0>
		<CF_smallLink 
			title = "select all" 
			url = "##"
			parameters = "onClick=""javascript: return ApplyCheckAll('TR_LESS_SAME_AR', 1);"""
		>&nbsp;&nbsp;
		<CF_smallLink 
			title = "de-select all" 
			url = "##"
			parameters = "onClick=""javascript: return ApplyCheckAll('TR_LESS_SAME_AR', 0);"""
		>
		</CFIF>
		</TD>
	</TR>
	<TR ID="TR_LESS_SAME_AR">	
	<CFSET count = 0>
	<CFLOOP QUERY="GetLesserDDSameARDiffCust">
		<CFSET Current_Item_Selected = 0 />
		<CFIF URL.FromDeduction EQ 1>
		<cfquery name="qCurrentCreditSelectedAlready" dbtype="query">
			SELECT	*
			FROM	AssociatedCredit
			WHERE	Credit_ID = '#Deduction_ID#'
		</cfquery>
		<cfif qCurrentCreditSelectedAlready.recordcount>
			<CFSET Current_Item_Selected = 1 />
		</cfif>
		</CFIF>
		<CFSET Count = Count + 1>		
		<CFIF Count LT 4>
			
		<CFELSE>
			<CFSET Count = 1>
			</TR>
			<TR ID="TR_LESS_SAME_AR">			
		</CFIF>	
			<TD STYLE = "Border: solid C6FFC6 1px"><CFIF URL.FromDeduction EQ 1><INPUT TYPE="Checkbox" NAME="Selection_ID" VALUE="#Deduction_ID#" AMOUNT="#DD_Amount#" #CHK_STR# <CFIF Current_Item_Selected EQ 1> CHECKED</CFIF>>&nbsp;&nbsp;</CFIF>
			<B>#DD_DedID_SP_Number#</B><BR>#DOLLARFORMAT(DD_Amount)# / #application.returned_customer_setting.shard_ship_to_label#: #Distributor_Name#</TD>
	</CFLOOP>
	</TR>	
	</CFIF>
	<CFIF GetLesserDDSameARDiffCust.RecordCount EQ 0 AND GetEqualDDSameARDiffCust.RecordCount EQ 0>
	<TR>
		<TD COLSPAN="100%" STYLE = "Border: solid C6FFC6 1px"><B>None</B></TD>
	</TR>
	</CFIF>
	

	
	
<!--- 
	

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---//////////////////////////////// DIFF CUSTOMER ID - SAME AR - LESS AMOUNT ///////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->	

	
	<TR>
		<TD COLSPAN="100%"><BR><BR><FONT COLOR="Navy" SIZE="2"><B><CFIF URL.FromCredit EQ 1>Deduction<CFELSE>Credits</CFIF> with the same Ded Ref ## but different #application.returned_customer_setting.shard_ship_to_label# and $ Amount less than the <CFIF URL.FromCredit EQ 1>Credit<CFELSE>Deduction</CFIF></B></FONT>
		<CFIF URL.FromDeduction EQ 1 AND GetLesserDDSameARDiffCust.RecordCount GT 0>
		<br>
		<CF_smallLink 
			title = "select all" 
			url = "##"
			parameters = "onClick=""javascript: return ApplyCheckAll('TR_LESS_SAME_AR', 1);"""
		>&nbsp;&nbsp;
		<CF_smallLink 
			title = "de-select all" 
			url = "##"
			parameters = "onClick=""javascript: return ApplyCheckAll('TR_LESS_SAME_AR', 0);"""
		>
		</CFIF>
		<HR COLOR="Orange">
		</TD>
	</TR>
	<CFIF GetLesserDDSameARDiffCust.RecordCount GT 0>
	<TR ID="TR_LESS_SAME_AR">
	<CFSET count = 0>
	<CFLOOP QUERY="GetLesserDDSameARDiffCust">
		<CFSET Current_Item_Selected = 0 />
		<CFIF URL.FromDeduction EQ 1>
		<cfquery name="qCurrentCreditSelectedAlready" dbtype="query">
			SELECT	*
			FROM	AssociatedCredit
			WHERE	Credit_ID = '#Deduction_ID#'
		</cfquery>
		<cfif qCurrentCreditSelectedAlready.recordcount>
			<CFSET Current_Item_Selected = 1 />
		</cfif>
		</CFIF>
		<CFSET Count = Count + 1>		
		<CFIF Count LT 4>
			
		<CFELSE>
			<CFSET Count = 1>
			</TR>
			<TR ID="TR_LESS_SAME_AR">			
		</CFIF>	
			<TD STYLE = "Border: solid C6FFC6 1px"><CFIF URL.FromDeduction EQ 1><INPUT TYPE="Checkbox" NAME="Selection_ID" VALUE="#Deduction_ID#" AMOUNT="#DD_Amount#" #CHK_STR# <CFIF Current_Item_Selected EQ 1> CHECKED</CFIF>>&nbsp;&nbsp;</CFIF>
			<B>#DD_DedID_SP_Number#</B><BR>#DOLLARFORMAT(DD_Amount)# / #application.returned_customer_setting.shard_ship_to_label#: #Distributor_Name#</TD>
	</CFLOOP>
	</TR>	
	<CFELSE>
	<TR>
		<TD COLSPAN="100%" STYLE = "Border: solid C6FFC6 1px"><B>None</B></TD>
	</TR>
	</CFIF>	

		 --->
		 
		 
		 
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---//////////////////////////////////// SAME CUSTOMER ID - GREATER AMOUNT //////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->	
	
	<TR>
		<TD COLSPAN="100%"><BR><BR><FONT COLOR="Navy" SIZE="2"><B><CFIF URL.FromCredit EQ 1>Deduction<CFELSE>Credit</CFIF> = #application.returned_customer_setting.shard_ship_to_label# and > $ Amount </B></FONT><HR COLOR="Orange"></TD>
	</TR>	
	<CFIF GetGreaterDD.RecordCount GT 0>
	<TR>
	<CFSET count = 0>
	<CFLOOP QUERY="GetGreaterDD">	
		<CFSET Count = Count + 1>		
		<CFIF Count LT 4>
			
		<CFELSE>
			<CFSET Count = 1>
			</TR>
			<TR>			
		</CFIF>	
		<TD STYLE = "Border: solid C6FFC6 1px"><A HREF="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#" target="_parent"><B>#DD_DedID_SP_Number#</B></A><BR>#DOLLARFORMAT(DD_Amount)# / REF: #DD_REFERENCE#</td>
	</CFLOOP>
	</TR>
	<CFELSE>
	<TR>
		<TD COLSPAN="100%" STYLE = "Border: solid C6FFC6 1px"><B>None</B></TD>
	</TR>
	</CFIF>

<!------ SUBMIT BUTTON FOR DEDUCTION ----->	
	<!--- 
	<CFIF URL.FromDeduction EQ 1>
	<TR>
		<TD COLSPAN="100%" ALIGN="Center" ID="TD_ASSOCIATE_MULTIPLE_CREDIT">		
		<BR>
		<SPAN ID="SP_ASSOCIATE_MULTIPLE_CREDI_ENABLED" <CFIF DISPLAY_DIFF NEQ 0> STYLE="DISPLAY:NONE;"</CFIF>>
		<CF_smallLink 
			title = "Associate Credit(s)" 
			url = "##"
			parameters = "onClick=""javascript: return validationMultiSelect();"""
		>
		</SPAN>
		<SPAN ID="SP_ASSOCIATE_MULTIPLE_CREDI_DISABLED" <CFIF DISPLAY_DIFF EQ 0> STYLE="DISPLAY:NONE;"</CFIF>>
		<CF_smallLink 
			title = "Associate Credit(s)" 
			url = "##"
			enabled = 0
		>
		</SPAN>	
		</TD>
	</TR>
	</CFIF>
	 --->
</TABLE>
</FORM>
</CFOUTPUT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT language="JavaScript">
<cfoutput>
var deductionAmount = parseFloat("#CurrentDeductionAmount#");
</cfoutput>
if(isNaN(deductionAmount))
{
	deductionAmount = 0;
}
function validation()
{
	if(Any_Object_Checked(document.all.Selection_ID))
	{
		document.LinkCreditDD.FormSubmitted.value = 1;
		document.LinkCreditDD.submit();			
	}
	else
	{
		alert("Please select at least one deduction to Close the Credit with.")
	}
	return false;
}

function validationMultiSelect()
{
	var objINPDisplayDiff = document.all.INP_DISPLAY_DIFF;
	if(objINPDisplayDiff)
	{
		var SPDisplayDiffAmount = parseFloat(objINPDisplayDiff.value);
		if(isNaN(SPDisplayDiffAmount))
		{
			SPDisplayDiffAmount = 0;
		}
		if(SPDisplayDiffAmount == 0 || deductionAmount == SPDisplayDiffAmount)
		{
			if(deductionAmount == SPDisplayDiffAmount)
			{
				<cfif CreditAssocAlreadyExist>
				if(!window.confirm("All existing Credit associations will be removed. Do you want to continue?"))
				{
					return false;
				}
				</cfif>
			}
			document.LinkCreditDD.FormSubmitted.value = 1;
			document.LinkCreditDD.submit();
		}
		else
		{
			alert("Total sum of credit amount must equal the deduction amount")
		}
	}
	return false;
}
function showCreditMultiSelection()
{
	document.LinkCreditDD.FormSubmitted.value = 2;
	document.LinkCreditDD.submit();
	return false;
}

function addRemoveCredit(thisObj)
{
	if(thisObj)
	{
		var thisAmount = parseFloat(thisObj.AMOUNT);
		if(isNaN(thisAmount))
		{
			thisAmount = 0;
		}
		var objSPDisplayDiff = document.all.SP_DISPLAY_DIFF;
		var objINPDisplayDiff = document.all.INP_DISPLAY_DIFF;
		var SPDisplayDiffAmount = parseFloat(objINPDisplayDiff.value);
		if(isNaN(SPDisplayDiffAmount))
		{
			SPDisplayDiffAmount = 0;
		}
		
		if(thisObj.checked)
		{
			SPDisplayDiffAmount = SPDisplayDiffAmount + thisAmount;
		}
		else
		{
			SPDisplayDiffAmount = SPDisplayDiffAmount - thisAmount;
		}
		SPDisplayDiffAmount = formatToDecimalPlaces(SPDisplayDiffAmount, 2);
		
		
		objINPDisplayDiff.value = SPDisplayDiffAmount;
		var displayStr = "$" + formatWithComma(formatToDecimalPlaces(SPDisplayDiffAmount, 2, 1), 3, 1);
		if(SPDisplayDiffAmount < 0)
		{
			displayStr = "(" + displayStr + ")"
			objSPDisplayDiff.style.color = "red";
		}
		else if(SPDisplayDiffAmount == 0)//If SPDisplayDiffAmount = 0 that means the credit amount selections match the deduction amount
		{
			objSPDisplayDiff.style.color = "blue";			
		}
		else
		{
			objSPDisplayDiff.style.color = "black";			
		}
		
		if(SPDisplayDiffAmount == 0)
		{
			enableDisableTD(true);
		}
		<cfif CreditAssocAlreadyExist>
		else if(deductionAmount == SPDisplayDiffAmount)
		{
			enableDisableTD(true);
		}
		</cfif>
		else
		{
			enableDisableTD(false);
		}
		objSPDisplayDiff.innerText = displayStr;
		
	}
}
function enableDisableTD(bEnable)
{
	var spEnabledObj = document.all.SP_ASSOCIATE_MULTIPLE_CREDI_ENABLED;
	var spDisabledObj = document.all.SP_ASSOCIATE_MULTIPLE_CREDI_DISABLED;
	if(bEnable)
	{
		spEnabledObj.style.display = "";
		spDisabledObj.style.display = "none";
	}
	else
	{
		spEnabledObj.style.display = "none";
		spDisabledObj.style.display = "";
	}
	
	
}

function ApplyCheckAll(sSuffix, bCheck)
{
	var i, trCount, bCheck;
	var trObjs = eval("document.all." + sSuffix);
	if(trObjs)
	{
		trCount = trObjs.length;
		if(trCount)
		{
			for(i=0;i<trCount;i++)
			{
				ApplyCheckAllForTR(trObjs[i], bCheck)
			}
		}
		else
		{
			ApplyCheckAllForTR(trObjs, bCheck)
		}
	}
	return false;
}

function ApplyCheckAllForTR(trObj, bCheck)
{
	var i, inpCount;
	var inpObj = trObj.getElementsByTagName("INPUT");
	inpCount = inpObj.length;
	if(inpCount)
	{
		for(i=0;i<inpCount;i++)
		{
			if(inpObj[i].name == "Selection_ID")
			{
				if(inpObj[i].checked != bCheck)
				{
					inpObj[i].checked = bCheck;
				}
			}
		}
	}
	else
	{
		if(inpObj.name == "Selection_ID")
		{
			if(inpObj.checked != bCheck)
			{
				inpObj.checked = bCheck;
			}
		}
	}	
}

</SCRIPT>

</body>
</html>
