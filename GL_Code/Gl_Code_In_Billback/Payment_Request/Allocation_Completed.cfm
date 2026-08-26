<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1>		
<CFQUERY NAME="Payment_Requested" DATASOURCE="#Application.Datasource#">
	UPDATE 	GL_Code_Allocation
	SET 	Payment_Requested = 1,
			Pay_Req_By	= '#request.AccessStructure.User_ID#',
			Pay_Req_Date = getdate()
		
	WHERE 	Billback_ID = '#Billback_ID#' AND
			Deleted = 0
</CFQUERY>
</CFIF>
<CFQUERY NAME="GetPayee" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback WHERE Billback_ID = '#Billback_ID#'
</CFQUERY>

<CFSET ConsiderThisassociatedDistributorToBeThePayee = "" />
<CFIF GetPayee.Billback_Payee_Type_ID EQ 4><!------ If payee = other, check i distributor is associated ----->	
	<cfset Get_Dist_Info = CreateObject("component", "components.billback.BillbackDeviationManager").getBillbackDistributor(Billback_ID, 4) />
	<CFSET ConsiderThisassociatedDistributorToBeThePayee = Get_Dist_Info.BSA_Foodservice_Customers_ID />
</CFIF>

<CFSET Impersonate_Billback_Payee_Type_ID = GetPayee.Billback_Payee_Type_ID />

<CFIF GetPayee.Billback_Payee_Type_ID EQ 1 OR ConsiderThisassociatedDistributorToBeThePayee NEQ "">	
	<CFSET Impersonate_Billback_Payee_Type_ID = 1 />
	<!--- 
	<CFQUERY NAME="GetTemplateType" DATASOURCE="#Application.Datasource#">
		SELECT 		Program_Control_Panel_Options.*, Billback_Program.Program_ID
		FROM 		Billback_Program 
		INNER JOIN 	Contract_Main ON Contract_Main.Contract_main_ID = Billback_Program.Program_ID
		INNER JOIN 	Program_Control_Panel_Options ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
		WHERE 		Billback_ID = '#Billback_ID#' AND 
					Billback_Program.Deleted = 0
	</CFQUERY>
 	--->
	<CFQUERY NAME="SelectVendor" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT 	Vendor_Dist_Oper.Vendor_ID,
								Vendor_Dist_Oper.Distributor_ID

		FROM 		Vendor_Dist_Oper
		INNER JOIN 	Vendor_Master ON Vendor_Master.Vendor_ID = Vendor_Dist_Oper.Vendor_ID AND Vendor_Master.Deleted=0 AND Vendor_Master.Active_Code = 'A'
		<CFIF GetPayee.Billback_Payee_Type_ID EQ 1>
		INNER JOIN 	Billback_Distributor ON	
						(Billback_Distributor.Distributor_ID = Vendor_Dist_Oper.Distributor_ID
						OR Billback_Distributor.Distributor_ID = Vendor_Master.Vendor_Master_ID) AND
					Billback_Distributor.Deleted = 0 AND
					(LEN(Vendor_Dist_Oper.Operator_ID) = 0 OR Vendor_Dist_Oper.Operator_ID IS NULL) AND
					Billback_Distributor.Billback_ID = '#Billback_ID#'
		</CFIF>
		WHERE 		<!--- <CFIF GetTemplateType.Generic_Type EQ "Distributor Trade/Shelter">
					(LEN(Vendor_Dist_Oper.Operator_ID) = 0 OR Vendor_Dist_Oper.Operator_ID IS NULL) AND
					<CFELSEIF GetTemplateType.Generic_Type EQ "Operator-Deviated Pricing">
					Vendor_Dist_Oper.Operator_ID IN ( 	SELECT 	BSA_Operator_ID 
														FROM 	Contract_Operators 
														WHERE 	Contract_Main_ID = #GetTemplateType.Program_ID# AND 
																Deleted = 0 	) AND
					</CFIF> --->
					<CFIF GetPayee.Billback_Payee_Type_ID EQ 4 AND ConsiderThisassociatedDistributorToBeThePayee NEQ "">
					Vendor_Dist_Oper.Distributor_ID = '#ConsiderThisassociatedDistributorToBeThePayee#' AND 

					(LEN(Vendor_Dist_Oper.Operator_ID) = 0 OR Vendor_Dist_Oper.Operator_ID IS NULL) AND

					</CFIF>
					Vendor_Dist_Oper.Vendor_ID IS Not NULL AND
					Vendor_Dist_Oper.Deleted = 0
	</CFQUERY>
<CFELSEIF GetPayee.Billback_Payee_Type_ID EQ 2>
	<!--- 
	<CFQUERY NAME="GetAssociatedShipTo" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback_Operator WHERE Billback_ID = '#Billback_ID#' AND Deleted = 0
	</CFQUERY>
	 --->
	<CFQUERY NAME="SelectVendor" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT 	Vendor_Dist_Oper.Vendor_ID,					
								Vendor_Dist_Oper.Operator_ID

		FROM 		Vendor_Dist_Oper
		INNER JOIN 	Vendor_Master ON Vendor_Master.Vendor_ID = Vendor_Dist_Oper.Vendor_ID AND Vendor_Master.Deleted=0 AND Vendor_Master.Active_Code = 'A'
		INNER JOIN 	Billback_Operator ON Billback_Operator.Operator_ID = Vendor_Dist_Oper.Operator_ID AND
				(LEN(Vendor_Dist_Oper.Distributor_ID) = 0 OR Vendor_Dist_Oper.Distributor_ID IS NULL)					
				

		WHERE 		Billback_Operator.Billback_ID = '#Billback_ID#' AND
					Vendor_Dist_Oper.Vendor_ID IS Not NULL AND
					<!--- 
					<CFIF GetAssociatedShipTo.Associated_Ship_To NEQ "">
					Vendor_Dist_Oper.Distributor_ID = '#GetAssociatedShipTo.Associated_Ship_To#' AND
					</CFIF>
					 --->
					Billback_Operator.Deleted = 0 AND
					Vendor_Dist_Oper.Deleted = 0
	</CFQUERY>
<CFELSEIF GetPayee.Billback_Payee_Type_ID EQ 3><!---  Brokerage Program (generic type) --->
<CFSET Impersonate_Billback_Payee_Type_ID = 1 />
<CFQUERY NAME="SelectVendor" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT 	VDO.Vendor_ID,
								VDO.Distributor_ID
		FROM 		Vendor_Dist_Oper VDO
		INNER JOIN 	Vendor_Master V ON V.Vendor_ID = VDO.Vendor_ID AND 
					V.Deleted=0 AND 
					V.Active_Code = 'A'
		INNER JOIN 	BillBack_Distributor_List L ON
					L.Billback_ID = '#Billback_ID#' AND	
					L.Distributor_ID = VDO.Distributor_ID AND
					L.Deleted = 0 AND
					(LEN(VDO.Operator_ID) = 0 OR VDO.Operator_ID IS NULL)		
		WHERE 		VDO.Vendor_ID IS Not NULL AND
					VDO.Deleted = 0
	</CFQUERY>
<CFELSE>
	<BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">Payee is not a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> and not a <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>...</FONT></B></TD>
		</TR>
	</TABLE>	
</CFIF>

<CFIF Impersonate_Billback_Payee_Type_ID EQ 1 OR Impersonate_Billback_Payee_Type_ID EQ 2>
	
	<CFIF SelectVendor.RecordCount EQ 0 AND appSettings.getBBAllowVendorMasterSearch() NEQ 1 AND Get_Profile_Settings.BB_Allow_Vendor_Master_Search NEQ 1>
		<CFIF IsDefined("Deduction_ID")>
			<CFLOCATION URL="VendorID_Null_Notify.cfm?Billback_ID=#Billback_ID#&PayeeType=#GetPayee.Billback_Payee_Type_ID#&Deduction_ID=#Deduction_ID#" ADDTOKEN="No">
		<CFELSE>
			<CFLOCATION URL="VendorID_Null_Notify.cfm?Billback_ID=#Billback_ID#&PayeeType=#GetPayee.Billback_Payee_Type_ID#" ADDTOKEN="No">
		</CFIF>			
	<CFELSE>	
		<CFIF IsDefined("Deduction_ID")>
			<CFLOCATION URL="VendorID_Selection.cfm?Billback_ID=#Billback_ID#&PayeeType=#GetPayee.Billback_Payee_Type_ID#&Deduction_ID=#Deduction_ID#" ADDTOKEN="No">
		<CFELSE>
			<CFLOCATION URL="VendorID_Selection.cfm?Billback_ID=#Billback_ID#&PayeeType=#GetPayee.Billback_Payee_Type_ID#" ADDTOKEN="No">
		</CFIF>					
	</CFIF>
</CFIF>
<!--- 
<BR><BR><BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD><B><FONT COLOR="Red" SIZE="3">This page is under constuction...</FONT></B></TD>
	</TR>
</TABLE>
 --->
 <script>
	if(window.parent.payment_tab)
	{
		window.parent.current_menu_item = "payment";
		window.parent.assignActiveTab();
		window.parent.buildMenu();
	}
</script>
</body>
</html>
