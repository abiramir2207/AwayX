<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<cfif IsDefined("url.BBID")>
		<cfset Billback_ID=URL.BBID>
	<cfelseif IsDefined("Form.BBID")>
		<cfset Billback_ID= Form.BBID>
	<cfelseif isDefined("Form.Billback_ID")>
		<cfset Billback_ID = Form.Billback_ID>
	<cfelseif IsDefined("Url.Billback_ID")>
		<cfset Billback_ID = Url.Billback_ID>
	<cfelse>
		The billback is not defined.  Please use the navigation on the left to reload this billback.
		<cfabort>
	</cfif>

<!--- START: D41801:  Billback Sales Tax/Anand Rao/26-Mar-2014 
	  Check if the Billback's program template has sales tax on it. 	
--->
<cfset BBProgramManager = CreateObject("component", "components.Billback.Programs.BillbackProgramsManager") />
<cfset CheckTemplateSalesTax = BBProgramManager.getTemplateSalesTax(Billback_ID)>

<cfset bBillbackSalesTax = 0 />
<cfif (CheckTemplateSalesTax.RecordCount GTE 2)>
	<cfloop query = "CheckTemplateSalesTax">
		<cfif (CheckTemplateSalesTax.Billback_Sales_Tax EQ 1)>
			<cfset bBillbackSalesTax = 1 />
		</cfif>
	</cfloop>
<cfelseif (CheckTemplateSalesTax.Billback_Sales_Tax EQ 1)>
	<cfset bBillbackSalesTax = 1 />
</cfif>
<!--- END: D41801:  Billback Sales Tax/Anand Rao/26-Mar-2014 --->

<cfparam name="ShowSplit" default="1">
<cfset AutoConcileMatchCentralBB = appSettings.getAuto_Reconcile_Match_Central_BB() />
<!--- If they do fund allocation they can't split until after they allocate --->
<cfif ((application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1) OR AutoConcileMatchCentralBB EQ 1) >
	<cfset ShowSplit = 0>
</cfif>

<cfset InfoBar_BBID = Billback_ID>
<cfinclude template="/billbacks/capture/billback_load_infobar.cfm">

<html>
<head>
	<title>Billback Payment</title>
	<cfinclude template="/billbacks/capture/iframe_style.cfm">
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</head>

<cfinclude template="/get_access_profile.cfm">

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<cfquery name="GetBillbackInfo" datasource="#application.datasource#">
SELECT 	*
FROM Billback
WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<cfif application.returned_customer_setting.Upload_GL_Code NEQ 1>
	<cfif GetBillbackInfo.Billback_Status_ID EQ 4 AND LCase(application.returned_customer_setting.Show_Billback_Payment_Tab) EQ 1 AND appSettings.getSettlement_SAP_Business()>
		<cflocation  addtoken="No" url="/billbacks/Approval/SAP_Settlement_PayReq.cfm?Billback_ID=#Billback_ID#&PayRequested=1">
	<cfelseif GetBillbackInfo.Billback_Status_ID EQ 4 AND appSettings.getVendor_Selection_Pay_Req()>
		<cflocation url="/GL_Code/GL_Code_In_Billback/Payment_Request/Approve_VendorID_Selection_Pay_Req.cfm?Billback_ID=#Billback_ID#" addtoken="No">	
	<cfelseif GetBillbackInfo.Billback_Status_ID EQ 4 AND LCase(application.returned_customer_setting.Show_Billback_Payment_Tab) EQ 1 AND appSettings.getBillback_Payment_Request_Without_Vendor_Selection() NEQ 1>
		<cflocation addtoken="No" url="/Billbacks/Check_Book/Bank_Tran/General_Ledger_Account/View_Edit_Approve.cfm?BBID=#BBID#&view=1&FromPaymentTab=1">	
		<CFABORT>
	<cfelseif appSettings.getBudgetsFunctionalityOn() and GetBillbackInfo.Billback_Status_ID EQ 6><!--- budget feature is on and billback is in pending fund update status ---->
		<cflocation addtoken="no" url="budget_billback_select.cfm?BBID=#BBID#">
	<!---D55703 :: Vendor required setting in closing method settings panel START--->
	<cfelseif GetBillbackInfo.Billback_Status_ID EQ 7>
		<cflocation addtoken="no" url="/GL_Code/Gl_Code_In_Billback/Payment_Request/VendorID_Selection.cfm?Billback_ID=#BBID#">		
	<!---D55703 :: Vendor required setting in closing method settings panel END--->
	<cfelseif GetBillbackInfo.Billback_Status_ID NEQ 3 AND appSettings.getBillback_Payment_Request_Without_Vendor_Selection() NEQ 1>
		<BR><BR>
		<font color="red" size="+2"><div align="Center"><strong>You can pay a billback only when it has a status of "Approved".</strong></div></font>
		<CFABORT>
	</cfif>
<cfelse>
	<cfif GetBillbackInfo.Billback_Status_ID EQ 5>
		<cflocation url="/GL_Code/GL_Code_In_Billback/Allocation_layout.cfm?Billback_ID=#Billback_ID#&Recal_Fund=0&FinalAllocationDisp=1&PayeeType=#GetBillbackInfo.Billback_Payee_Type_ID#&FromPaid=1" addtoken="No">	
	<cfelseif GetBillbackInfo.Billback_Status_ID EQ 6>
		<cfif IsDefined("Deduction_ID")>
			<cflocation url="/GL_Code/GL_Code_In_Billback/Allocation.cfm?Billback_ID=#Billback_ID#&Recal_Fund=0&Deduction_ID=#Deduction_ID#" addtoken="No">	
		<cfelse>
			<cflocation url="/GL_Code/GL_Code_In_Billback/Allocation.cfm?Billback_ID=#Billback_ID#&Recal_Fund=0" addtoken="No">	
		</cfif>		
	<cfelseif GetBillbackInfo.Billback_Status_ID EQ 7>
		<cfif IsDefined("Deduction_ID")>
			<cflocation url="/GL_Code/GL_Code_In_Billback/Payment_Request/Allocation_Completed.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#" addtoken="No">
		<cfelse>
			<cflocation url="/GL_Code/GL_Code_In_Billback/Payment_Request/Allocation_Completed.cfm?Billback_ID=#Billback_ID#" addtoken="No">
		</cfif>			
	<cfelseif GetBillbackInfo.Billback_Status_ID EQ 4>		
		<cfif IsDefined("Deduction_ID")>
			<cflocation url="/GL_Code/GL_Code_In_Billback/Payment_Request/Payment_Request_Display.cfm?Billback_ID=#Billback_ID#&PayeeType=#GetBillbackInfo.Billback_Payee_Type_ID#&Deduction_ID=#Deduction_ID#" addtoken="NO">
		<cfelse>
			<cflocation url="/GL_Code/GL_Code_In_Billback/Payment_Request/Payment_Request_Display.cfm?Billback_ID=#Billback_ID#&PayeeType=#GetBillbackInfo.Billback_Payee_Type_ID#" addtoken="NO">
		</cfif>			
	<cfelse>
		<CFQUERY NAME="Checkstatus" DATASOURCE="#Application.Datasource#">
			SELECT 	Top 1 * 
			FROM 	GL_Code_Allocation
			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> 
			AND 	Deleted = 0
		</CFQUERY>	

		<cfif Checkstatus.RecordCount GT 0>
			<cfif Checkstatus.Allocation_Saved EQ 1 AND Checkstatus.Payment_Requested EQ 1>
				<cfif IsDefined("Deduction_ID")>
					<cflocation url="/GL_Code/GL_Code_In_Billback/Payment_Request/Allocation_Completed.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#" addtoken="No">
				<cfelse>
					<cflocation url="/GL_Code/GL_Code_In_Billback/Payment_Request/Allocation_Completed.cfm?Billback_ID=#Billback_ID#" addtoken="No">
				</cfif>				
			<cfelseif Checkstatus.Allocation_Saved EQ 1 AND Checkstatus.Payment_Requested EQ 0>
				<cfif IsDefined("Deduction_ID")>
					<cflocation url="/GL_Code/GL_Code_In_Billback/Allocation_layout.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#" addtoken="No">		
				<cfelse>
					<cflocation url="/GL_Code/GL_Code_In_Billback/Allocation_layout.cfm?Billback_ID=#Billback_ID#" addtoken="No">		
				</cfif>				
			</cfif>
		</cfif>
	</cfif>
</cfif>


<cfset Billback_Payable_Number = GetBillbackInfo.BB_Code>
<cfset BILLBACK_BILLBACK_TITLE  = GetBillbackInfo.BB_Title>
<cfset Payee_Type = GetBillbackInfo.Billback_Payee_Type_ID>

<cfinclude template="Payee_ID_Finder.cfm">

<cfoutput>

<cfinclude template="/helpsystem/help_link.cfm">
	<p></p>
	<script SRC="/billbacks/common/common_js_functions.js"></script>
	<SCRIPT LANGUAGE="JavaSCript">
		function submitForm(thisobj){
			<cfif appsettings.getClaimMech_Popup() IS 1>
			var fooFormObj = getParentObject(thisobj, 'form').name;
			NewWindow("claim_mechanics_popup.cfm?formName=" + fooFormObj + "&billBackId=#Billback_ID#", "ClaimMech", 300, 400, "yes", "yes");
			return false;
			</cfif>
			getParentObject(thisobj, 'form').submit();
			return false;
		}
	</SCRIPT>
<TABLE ALIGN="Center" WIDTH="600" border="0" CELLSPACING="0" CELLPADDING="2">
	<colgroup>
		<col SPAN="1"></col>
		<col SPAN="1" ALIGN="left"></col>
	</colgroup>
	<tr VALIGN="top">
		<td nowrap COLSPAN="100%" style="background-color:blue;color:White;font-size:12px;font-weight:bold;">[#GetBillbackInfo.BB_Code#] #GetBillbackInfo.BB_Title#</td>
	</tr>
	<tr VALIGN="top">
		<td width="50%"><strong>Billback Number:</strong></td>
		<td><strong>#GetBillbackInfo.BB_Reference#</strong></td>
		<td width="*">&nbsp; </td>
	</tr>
	<tr VALIGN="top">
		<td><strong>Billback Date:</strong></td>
		<td><strong>#DateFormat(GetBillbackInfo.BB_Date, 'MMMM DD, YYYY')#</strong></td>
		<td >&nbsp; </td>
	</tr>
	<!---Get approval information--->
	<cfquery name="GetApprovalInfo" datasource="#application.datasource#">
		SELECT BB_Approved.Paid_Amount
		FROM BB_Approved
		WHERE BB_Approved.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	
	<cfif not isnumeric(GetApprovalInfo.Paid_Amount)>
		<cfquery name="GetApprovalInfo" datasource="#application.datasource#">
			SELECT 0 as Paid_Amount
		</cfquery>
	</cfif>
	
	<tr VALIGN="top">
		<td><strong>Billback Total:</strong></td>
		<td><strong>$#NumberFormat(GetApprovalInfo.Paid_Amount, '___,___,___,___.__')#</strong></td>
		<td >&nbsp; </td>
	</tr>
	<tr>
		<td ColSpan="100%" style="border-bottom: solid lightsteelblue 1px;"><strong>Notes:</strong></td>
	</tr>
	<tr>
		<td ColSpan="100%">#GetBillbackInfo.BB_Creator_Notes#</td>
	</tr>
		<!---Get Payee information--->
		<cfswitch expression="#Payee_type#">
			<cfcase value = 1>
				<cfquery name="GetPayeeInfo" datasource="#application.datasource#">
				SELECT Name AS Payee_Name, Address_1 AS Address1, Address_2 AS Address2, City AS City, State AS State, ZipCode AS ZipCode, Phone AS Phone
				FROM BSA_Foodservice_Customers
				WHERE BSA_Foodservice_Customers_ID = <cfqueryparam value="#Payee_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfcase>
			<cfcase value = 2>
				<cfquery name="GetPayeeInfo" datasource="#application.datasource#">
				SELECT Operator_Name AS Payee_Name, Operator_Address AS Address1, '' AS Address2, Operator_City AS City, Operator_State AS State, Operator_Zip AS ZipCode, zzz_Operator_Phone AS Phone
				FROM BSA_Operator
				WHERE BSA_Operator_ID = <cfqueryparam value="#Payee_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfcase>
			<cfcase value = 3>
				<cfquery name="GetPayeeInfo" datasource="#application.datasource#">
				SELECT Broker_Name AS Payee_Name, Address AS Address1, Address_2 AS Address2, City AS City, State AS State, Zip AS ZipCode, Phone_Number AS Phone
				FROM BSA_Foodservice_Brokers
				WHERE BSA_Foodservice_Brokers_ID = <cfqueryparam value="#Payee_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfcase>
			<cfcase value = 4>
				<cfquery name="GetPayeeInfo" datasource="#application.datasource#">
				SELECT BB_UP_Name AS Payee_Name, BB_UP_Address1 AS Address1, BB_UP_Address2 AS Address2, BB_UP_City AS City, BB_UP_State AS State, BB_UP_Zipcode AS ZipCode, BB_UP_Phone AS Phone
				FROM Billback_Unidentified_Payee
				WHERE Billback_Unidentified_Payee_ID = <cfqueryparam value="#Payee_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfcase>
			<cfcase value = 5>
				<cfquery name="GetPayeeInfo" datasource="#application.datasource#">
				SELECT BB_Distributor_Name AS Payee_Name, BB_Distributor_Address1 AS Address1, BB_Distributor_Address2 AS Address2, BB_Distributor_City AS City, BB_Distributor_State AS State, BB_Distributor_Zipcode AS ZipCode, (BB_Distributor_Phone + BB_Distributor_Phone_Extn) AS Phone
				FROM Billback_Distributor
				WHERE Billback_Distributor_ID = <cfqueryparam value="#Payee_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfcase>
			<cfcase value = 6>
				<cfquery name="GetPayeeInfo" datasource="#application.datasource#">
				SELECT BB_Operator_Name AS Payee_Name, BB_Operator_Address1 AS Address1, BB_Operator_Address2 AS Address2, BB_Operator_City AS City, BB_Operator_State AS State, BB_Operator_Zipcode AS ZipCode, (BB_Operator_Phone + BB_Operator_Phone_Extn) AS Phone
				FROM Billback_Operator
				WHERE Billback_Operator_ID = <cfqueryparam value="#Payee_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfcase>
			<cfcase value = 7>
			<cfquery name="GetPayeeInfo" datasource="#application.datasource#">
				SELECT BB_Broker_Name AS Payee_Name, BB_Broker_Address1 AS Address1, BB_Broker_Address2 AS Address2, BB_Broker_City AS City, BB_Broker_State AS State, BB_Broker_Zipcode AS ZipCode, (BB_Broker_Phone + BB_Broker_Phone_Extn) AS Phone
				FROM Billback_Broker
				WHERE Billback_Broker_ID = <cfqueryparam value="#Payee_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfcase>
		</cfswitch>
		</cfoutput>
	<tr>
		<td ColSpan="100%" style="border-bottom: solid lightsteelblue 1px;"><BR><strong>Payee:</strong></td>
	</tr>
	<cfoutput query="GetPayeeInfo">	
		<tr bgcolor="white">
			<td colspan="4">
				<blockquote>
					#Payee_Name#<br>
					#Address1#<Br>
					<cfif len(trim(Address2)) GT 0>#Address2#<br></cfif>
					#City# #State#, #ZipCode#<br>
					(#Left(Phone, 3)#) #Right(Left(Phone, 6), 3)#-#Right(Phone,4)#
				</blockquote>
			</td> 
		</tr>
	</cfoutput>

<!---Gets all Programs for the billback--->
	<cfif GetBillbackInfo.scheduled_Auto_BB >
		<CFQUERY NAME="GetProgramsForBB" DATASOURCE="#Application.Datasource#">
			SELECT 		Contract_number
							,Contract_Title
							,SUM(CAST(BB_Rate AS float)) AS Program_Total_Paid	
			FROM 	Billback_Product_Detail			
			INNER JOIN 	Billback_Product 
			ON Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID 
			AND Billback_Product.Deleted = 0
			INNER JOIN 	Billback_Program 
			ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID 
			AND	Billback_Program.Deleted = 0
			INNER JOIN 	Contract_Main 
			ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID	
			WHERE 	Billback_Product_Detail.Billback_ID ='#Billback_ID#' 
			AND 	Billback_Product_Detail.BB_Product_Type_ID != 10 
			AND		Billback_Product_Detail.BB_Rate IS NOT NULL 
			AND		(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1) 
			AND		Billback_Product_Detail.Deleted = 0						
			GROUP BY 	Program_ID,Contract_number,Contract_Title
		</CFQUERY>
	<cfelse>
		<cfquery name="GetProgramsForBB" datasource="#application.datasource#">
			SELECT 	Contract_Main.Contract_Title, Contract_Main.Contract_Number, Billback_Program.Program_ID, Billback_Program.BB_Program_Number, Billback_Program.BB_Program_Title,
			(ISNULL((SELECT SUM(BB_Item_Final.Item_Total_Paid) FROM BB_Item_Final 
			WHERE BB_Item_Final.Billback_Program_ID = Billback_Program.Billback_Program_ID), 0)
			+ 
			ISNULL((SELECT SUM(BB_Growth_Program.Paid_Amount) FROM BB_Growth_Program
			WHERE BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID), 0) 
			+
			ISNULL((SELECT SUM(BB_Lump_Sums.LS_Paid_Amount) FROM BB_Lump_Sums
			WHERE BB_Lump_Sums.Billback_Program_ID = Billback_Program.Billback_Program_ID), 0) )
			AS Program_Total_Paid,
			Contract_Main.Contract_Main_ID
			FROM 	Billback_Program
			INNER JOIN Contract_Main
			ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
			WHERE 	Billback_Program.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND Billback_Program.Deleted = 0
		</cfquery>
	</cfif>
	<cfif GetBillbackInfo.BB_Is_Child NEQ 1>
		<tr>
			<td colspan="4" style="border-bottom: solid lightsteelblue 1px;"><strong>Programs:</strong></td>
		</tr>	
		<cfloop query="GetProgramsForBB">
			<cfoutput>
				<tr <cfif currentrow mod 2>BGCOLOR="white"<cfelse>BGCOLOR="ccffcc"</cfif>>
					<td><strong>#Contract_Number#</strong> #Contract_Title#</td>
					<td></td>
					<Td align="right"><font color="Navy"><strong><cfif GetBillbackInfo.Negative_Billback EQ 1>#LSCurrencyFormat(GetBillbackInfo.BB_Amount)#<cfelse>#LSCurrencyFormat(Program_Total_Paid)#</CFIF></strong></font></TD>
					<td>&nbsp; </td>
				</tr>
			</cfoutput>
		</cfloop>
	</cfif>
	<tr>
		<td colspan="4">&nbsp; </td>
	</tr>

	<cfquery name="GetAdjustments" datasource="#application.datasource#">
		SELECT 	BB_Adjustment.BB_Adjustment_ID, BB_Adjustment.Billback_ID, BB_Adjustment.Payee_ID, BB_Adjustment.Billback_Payee_Type_ID, BB_Adjustment.Adjustment_Amount, Billback.BB_Title, Billback.BB_Date, Billback.BB_Reference, Billback.BB_Code
		FROM 	BB_Adjustment
		INNER JOIN Billback
		ON BB_Adjustment.Billback_ID = Billback.Billback_ID
		WHERE 	BB_Adjustment.Deleted = 0
		AND		BB_Adjustment.Adjustment_Deducted_From_BB_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<cfif GetAdjustments.Recordcount GT 0>
		<tr>
			<td colspan="4" style="border-bottom: solid lightsteelblue 1px;">
				<strong>Adjustments:</strong>
			</td>
		</tr>		
		<cfloop query="GetAdjustments">
			<cfoutput>
				<tr <cfif currentrow mod 2>BGCOLOR="white"<cfelse>BGCOLOR="ccffcc"</cfif>>
					<td><strong>#BB_Code#</strong> #BB_Title# (#BB_Reference#) - #DateFormat(BB_Date, 'MMMM DD, YYYY')#</td>
					<td></td>
					<Td align="right"><font color="Red"><strong>#DollarFormat(Evaluate(Adjustment_Amount*(-1)))#</strong></font></TD>
					<td>&nbsp; </td>
				</tr>
			</cfoutput>
		</cfloop>		
		<tr>
			<td colspan="4">&nbsp; </td>
		</tr>
	</cfif>
<!---Exclusions--->

	<cfquery name="GetExclusions" datasource="#application.datasource#">
		SELECT 	BB_Program_Exclusion.BB_Program_Exclusion_ID, Contract_Main.Contract_Title, Contract_Main.Contract_Number, 
		(SELECT SUM(Dollar_Amount) FROM BB_Product_Exclusion 
		WHERE BB_Product_Exclusion.BB_Program_Exclusion_ID = BB_Program_Exclusion.BB_Program_Exclusion_ID) AS Exclusion_Total
		FROM 	BB_Program_Exclusion
		INNER JOIN Contract_Main
		ON Contract_Main.Contract_Main_ID = BB_Program_Exclusion.Program_ID
		--AND Contract_Main.Deleted = 0
		WHERE 	BB_Program_Exclusion.Exclusion_Deducted_From_BB_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<cfif GetExclusions.Recordcount GT 0>
		<tr>
			<td colspan="4" style="border-bottom: solid lightsteelblue 1px;"><strong>Exclusions:</strong></td>
		</tr>		
		<cfloop query="GetExclusions">
			<cfoutput>
				<tr <cfif currentrow mod 2>BGCOLOR="white"<cfelse>BGCOLOR="ccffcc"</cfif>>
					<td><strong>#Contract_Number# </strong>#Contract_Title# </td>
					<td> <strong></strong> </td>
					<Td align="right"><font color="Red"><strong>#DollarFormat(Evaluate(Exclusion_Total*(-1)))#</strong></font></TD>
					<td>&nbsp; </td>
				</tr>
			</cfoutput>
		</cfloop>		
		<tr>
			<td colspan="4">&nbsp; </td>
		</tr>	
	</cfif>

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!---Claim Adjustment--->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	
	<CFQUERY NAME="GetTotClaim" DATASOURCE="#Application.Datasource#">
		SELECT 	SUM(CAST(BB_Rate AS float)) ClaimAd_Tot
		FROM 	Billback_Product_Detail 
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> 
		AND		BB_Product_Type_ID = 10 
		AND 	(Billback_Product_Detail.BB_Rate IS NOT NULL)
		AND		(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
		AND		Deleted = 0
	</CFQUERY>
	<cfif GetTotClaim.ClaimAd_Tot EQ "">
		<cfset GetTotClaim.ClaimAd_Tot = 0>
	</cfif>
	<cfif GetTotClaim.ClaimAd_Tot NEQ 0>		
		<CFQUERY NAME="GetProgramDetails" DATASOURCE="#Application.Datasource#">
			SELECT 		Contract_number
							,Contract_Title
							,SUM(CAST(BB_Rate AS float)) AS Tot_bb_Rate
			FROM 		Billback_Product_Detail
			INNER JOIN 	Billback_Product 
			ON Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID 
			AND Billback_Product.Deleted = 0
			INNER JOIN 	Billback_Program 
			ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID 
			AND Billback_Program.Deleted = 0
			INNER JOIN 	Contract_Main 
			ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID	
			WHERE 		Billback_Product_Detail.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> 
			AND  	   	Billback_Product_Detail.BB_Product_Type_ID = 10 
			AND       	Billback_Product_Detail.BB_Rate IS NOT NULL 
			AND     	(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1) 
			AND			Billback_Product_Detail.Deleted = 0		
			GROUP BY 	Program_ID,Contract_number,Contract_Title
		</CFQUERY>
		
		<cfquery name="GetApprovalInfo" datasource="#application.datasource#">
			SELECT BB_Approved.Paid_Amount
			FROM BB_Approved
			WHERE BB_Approved.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<tr>
			<td colspan="4" style="border-bottom: solid lightsteelblue 1px;"><strong>Claim Adjustment:</strong></td>
		</tr>
	
		<cfloop query="GetProgramDetails">
			<cfoutput>
				<tr <cfif currentrow mod 2>BGCOLOR="white"<cfelse>BGCOLOR="ccffcc"</cfif>>
					<td><strong>#Contract_Number# </strong>#Contract_Title# </td>
					<td> <strong></strong> </td>
					<Td align="right"><font color="Red"><strong>#DollarFormat(Tot_bb_Rate)#</strong></font></TD>
					<td>&nbsp; </td>
				</tr>
			</cfoutput>
		</cfloop>	
		<tr>
			<td colspan="4">&nbsp; </td>
		</tr>	
	</cfif> 
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Claim Adjustment End --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

		<!--- pullback applied amount --->
		<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
		<cfset GetPullbackInfo = PullbackManager.getPullbackAppliedInfo(Billback_ID) />
		<cfif GetPullbackInfo.BB_pullbacks_applied EQ 1>
			<tr>
				<td><strong><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Amount</strong></td>
				<td> <strong></strong> </td>
				<Td align="right"><font color="Red"><strong><cfoutput>#DollarFormat(GetPullbackInfo.Pullback_applied_Amount)#</cfoutput></strong></font></TD>
				<td>&nbsp; </td>
			</tr>
		</cfif>
		<!--- end pullback applied amount --->
		<!--- If the setting allows for Sales tax Info --->
		<cfif bBillbackSalesTax EQ 1>
		    <tr>
				<td><strong>Sales Tax:</strong></td>
				<td>&nbsp;</td>
				<td align="right"><font color="Navy"><strong><cfoutput>#Trim(DollarFormat(val(GetBillbackInfo.TotalTaxAmount)))#</cfoutput></strong></font></td>
				<td>&nbsp;</td>
		    </tr>
		</cfif>
<tr>
	<td COLSPAN="100%" ALIGN="center">
	<!-------- To Pay ------------>
	<BR>
	<CFOUTPUT>
	<cfinclude template="Get_Payment_Next_Page.cfm" />

	<FORM ACTION="#ActionPage#" METHOD="post" name="PaymentForm">
		<INPUT TYPE="HIDDEN" NAME="Billback_ID" VALUE="#Billback_ID#">
		<INPUT TYPE="HIDDEN" NAME="new_bb_check" VALUE="1">
		<INPUT TYPE="Hidden" NAME="PayeeType" VALUE="#GetBillbackInfo.Billback_Payee_Type_ID#">
	
		<STYLE>
			.BigFont{
				border-top: 2px solid ##C2DFF7;
				border-bottom: 2px solid ##C2DFF7;
			}
			.BigFont TD{
				font-size: 14px;
				font-weight: bold;
				color: Black;
			}
		</STYLE>
	<cfset TotalAmount =  val(GetApprovalInfo.Paid_Amount) + val(GetBillbackInfo.TotalTaxAmount)>
	<TABLE WIDTH="700" CELLPADDING="4" CELLSPACING="0" BORDER="0" CLASS="BigFont">		
	<TR>
		<TD>
			<cfif appSettings.getSplitBillbacks()>
				<cfif Not GetBillbackInfo.scheduled_Auto_BB AND GetBillbackInfo.Negative_Billback NEQ 1 AND ShowSplit NEQ 0>
					<cfif appSettings.getPullbacksOn() AND GetPullbackInfo.BB_pullbacks_applied EQ 1 AND GetBillbackInfo.BB_Is_Child NEQ 1>
						<A HREF="UnApplyPullBackForSplitting.cfm?Parent=#Billback_ID#" TITLE="Split this billback amount.">
							<cfoutput>#application.util.string.actionLinkFormat("split")#</cfoutput>
						</A>
					<cfelse>
						<A HREF="Split_BB.cfm?Billback_ID=#Billback_ID#" TITLE="Split this billback amount.">
							<cfoutput>#application.util.string.actionLinkFormat("split")#</cfoutput>
						</A>
					</cfif>				
				</cfif>
			</cfif>
		</TD>			
	<cfif appSettings.getPullbacksOn() AND GetBillbackInfo.Negative_Billback NEQ 1>		
		<!------ Display the Apply Pullback Link ----->
		<cfif Get_Profile_Settings.BB_Apply_Pullback>
			<cfsilent>
				<cfquery name="checkifpullbackfromthisprg" datasource="#application.datasource#">
					SELECT DISTINCT Pullback_From_This_Program 
					FROM billback
					INNER JOIN billback_program 
					ON billback_program.billback_id = billback.billback_id
					INNER JOIN contract_main 
					ON contract_main.contract_main_id = billback_program.program_id
					WHERE billback.billback_id = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfsilent>			
			<cfif checkifpullbackfromthisprg.Pullback_From_This_Program eq 1>
				<TD ALIGN="Center">
					<cfoutput>
						<cfset link = "apply "&#appsettings.getPullbackLabelLower()#>
						<A HREF="##" onClick="javaScript: submitapplypullbackform();return false;" TITLE="apply #appsettings.getPullbackLabelLower()# on the approval amount">
							#application.util.string.actionLinkFormat(link)#
						</A>
					</cfoutput>
					<script>
						function submitapplypullbackform(){
							NewWindow('/billbacks/approval/applypullbacks.cfm?BB_ID=<cfoutput>#Billback_Id#</cfoutput>','pullbackdetails','870','620','Yes', 'No');
						}
					</script>
				</TD>
			</cfif>
		</cfif>
		<!------ Display the Un-Apply Pullback Link ----->		
		<cfif GetPullbackInfo.BB_pullbacks_applied EQ 1>
			<TD ALIGN="Center">
				<cfoutput>
					<cfset link = "view applied "&#appsettings.getPullbackLabelLower()#>
						<A HREF="##" onClick="javaScript: submitunapplypullbackform();return false;" TITLE="view applied <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>">
							#application.util.string.actionLinkFormat(link)#
						</A>
				</cfoutput>
				<script>
					function submitunapplypullbackform(){
						NewWindow('/billbacks/approval/viewappliedpullbacks.cfm?BB_ID=<cfoutput>#Billback_Id#</cfoutput>','pullbackdetails','870','620','Yes', 'No');
					}
				</script>
			</TD>
		</cfif>		
	</cfif>
			<TD  ALIGN="Center">
      <!----------------------------------------------------------------------------- 
      Dev Notes: D18281:Solo - Add new closing method on billback entry	
      Added check for Credit memo[5] along with deduction[2] 
      -Anand Rao/29-May-09
      ------------------------------------------------------------------------------>
	
	<!--- 	For closing methods: 1 = payment, 2 = deduction. 
			There currently no special handling for the other methods.
			You can find a complete list in the mapping table Billback_Closing_Methods
	--->
			
	<cfif (GetBillbackInfo.Billback_Status_ID EQ 3)>	
		<cfif ((GetBillbackInfo.BB_Closing_Method EQ 1) OR (application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1))  
					AND (Get_Profile_Settings.BB_Pay_Req_Approval_Amount GTE GetApprovalInfo.Paid_Amount OR Get_Profile_Settings.BB_Pay_Req_Approval_Amount EQ "*")>
			<A HREF="##" onClick="javaScript: return submitForm(this);" TITLE="pay billback amount of #LSCurrencyFormat(TotalAmount)#">
				#application.util.string.actionLinkFormat("pay this amount")#
			</A>
		<cfelse>
			<FONT SIZE="1" COLOR="Blue">
			<cfif ((GetBillbackInfo.BB_Closing_Method EQ 1) OR (application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1))>
				You do not have sufficient payment request permissions.
			<cfelseif (GetBillbackInfo.BB_Closing_Method EQ 2)>
				<!--- D18281 if closing method is deduction or credit memo show this message --->
				Given the closing method selected, you must associate this transaction to a deduction.
			</cfif>				 
			</FONT>
		</cfif>
	<cfelse>			
		<FONT SIZE="2" COLOR="Blue"> Approved Amount:</FONT>
	</cfif>				
			</TD>			
			<TD ALIGN="Right">#DollarFormat(TotalAmount)#</TD>
		</TR>		
	</TABLE>
	
	</FORM>
	</CFOUTPUT>
	</td>
</tr>
</table>

<!--- Display The Appropriate Status --->
<cfset StatusDisplay_CELLSPACING			= 4>
<cfset StatusDisplay_CELLPADDING			= 0>
<cfset StatusDisplay_FONTCOLOR				= "white">
<cfset StatusDisplay_CELLBGCOLOR			= "green">
<cfset Program_Is_A_Revision 					= 0>
<cfset ISPROGRAMTEMPLATEAVAILABLE 		= 1>
<cfset DisAllowAccessBasedOnPosition 		= 0>

	<cfquery name="UnLockOtherBillbacksLockedByMe" datasource="#Application.Datasource#">
		UPDATE	Billback_Allied
		SET BB_Is_Locked = 0
		WHERE	BB_Is_Locked			=	1
		AND BB_Locked_By_User_ID	= <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
		<cfif LEN(trim(Billback_ID)) GT 0 AND Billback_ID NEQ 0>
		AND Billback_ID <> <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> 
		</cfif>
		AND BB_Locked_By_Match_Central = 0
	</cfquery>
	<cfquery name="GetLockStatus" datasource="#Application.Datasource#">
		SELECT BB_Is_Locked,BB_Locked_By_User_ID
		FROM  	Billback_Allied
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
		
	<cfif GetLockStatus.BB_Is_Locked EQ 1>
		<cfset DisAllowAccessBasedOnLockStatus 	= 0>
	<cfelse>
		<cfset DisAllowAccessBasedOnLockStatus 	= 1>
	</cfif>
		
	<cfif GetLockStatus.BB_Locked_By_User_ID NEQ request.AccessStructure.User_ID>
		<cfset DisAllowAccessBasedOnLockStatus 	= 1>
	</cfif>

	<style>
		TABLE.Maintable TD	{
			border-bottom:solid #93BEE2 1px; 
			font-size : 10px;
			}	
		#header{
				font-size: 12px;
			}
		#cellLabel{
				font-size: 11px;
				font-weight: bold;
				vertical-align : top;
			}
		#dataStyle{
				font-size: 11px;
			}
		TD	{
				font-family:Arial;
			}	
		HR{
				color: Navy;
			}
		.LeftRightBorder{
			border-left:solid #93BEE2 1px;
			border-right:solid #93BEE2 1px;
			border-top:solid #93BEE2 1px;
			font-size : 10px;
		}
		TABLE.LeftRightBorder TD{
			border-bottom:solid #93BEE2 1px; font-size : 10px;
		}	
	</style>

<cfset Print_Button_Show 				= 1>
<cfset Email_Button_Show 				= 1>
<cfset Fax_Button_Show 				= 1>
<cfset Route_Button_Show 				= 1>
<cfset Route_Button_Show 				= 1>
<cfset Route_Inbox_Button_Show	= 1>
<BR>

	<cfif NOT isDefined("ShowButtons")>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="1%" ALIGN="CENTER">
		<TR>			
			<cfif Print_Button_Show EQ 1>
				<TD>
					<CF_button
						button_name		=	""
						button_caption	=	"print"
						button_action	=	"NewWindow('../common/bb_printer_friendly.cfm?BBID=#Billback_ID#&Referrer=Payment','name','1000','600','No', 'No')"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>				
				</TD>
			</cfif>	
			<cfif Email_Button_Show EQ 1>
				<TD>
					<CF_button
						button_name		=	""
						button_caption	=	"email"
						button_action	=	"window.location.href='../common/bb_email_create.cfm?BBID=#Billback_ID#&Referrer=Payment'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>				
				</TD>
			</cfif>
		</TR>
		</TABLE>
	</cfif>
	<cfset local_bbid = Billback_ID>
	<cfinclude template="/Billbacks/capture/bb_menu_stats.cfm">
	<!--- BSD 11544 --->
	<script>
	  var url = '<cfoutput>#cgi.script_name#</cfoutput>';        
		if (url == '/Billbacks/common/bb_printer_friendly.cfm'){
          // do nothing
        }
		else {
			try { window.parent.dyniframesize(); } catch (err) { };
		}
   </script>	
</BODY>
</html> 