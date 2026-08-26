<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Untitled</title>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
</head>
<body>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset Sel_Vendor_Master_ID = "" />
<cfset lsBusinessSegmentID = "0" />
	
<cfparam name="FORM.DD_Reason_Code_ID" default="0">
<cfset bReasonCodeSelection = 0 />
	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

	<CFQUERY NAME="GetReasonCodes" DATASOURCE="#application.datasource#">
		 SELECT * 
		 FROM 			DD_Reason_Code 
		 WHERE 		Deleted = 0 
		 AND 			Display_In IN (2,3)
		 ORDER BY 	DD_Reason_Code_Description
	</CFQUERY>

	<CFQUERY NAME="qBillbackInfo" DATASOURCE="#Application.Datasource#">
		SELECT Billback.*, ISNULL(bcm.Closing_Method_Type, Billback.BB_Closing_Method) as Closing_Method_Type
		FROM 	Billback 
		LEFT JOIN Billback_Closing_Methods bcm ON bcm.iBillback_Closing_Method_ID = Billback.BB_Closing_Method
		WHERE Billback.Billback_ID = '#Billback_ID#'
	</CFQUERY>
		
	<cfset Closing_Method_Type = qBillbackInfo.Closing_Method_Type />

	<cfif isDefined("Form.NextAction") AND Form.NextAction EQ "SaveVendor">
		<CFQUERY NAME="VendorID" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_Approved
			SET 			Vendor_Master_ID = '#FORM.Vendor_Master_ID#'
			WHERE 		Billback_ID = '#Billback_ID#'
		</CFQUERY>
			<!---D55703 :: Vendor required setting in closing method settings panel START--->	
		<cfset useLakebaseForUpdateBillbackStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdateBillbackStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#Billback_ID#",
				"billback_status_id" = "eq.7"
			},
			{
				"billback_status_id" = "3"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateBillbackStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateBillbackStatus>
<cfquery name="UpdateBillbackStatus" datasource="#application.datasource#">
			UPDATE 	Billback 
			SET 			Billback_Status_ID = 3
			WHERE  	Billback_Id = '#Billback_ID#'
			AND 		Billback_Status_ID = 7
		</cfquery>
</cfif>	
	
		<CFIF IsDefined("Deduction_ID")><!--- If coming from deduction, go back to deduction --->
			<cflocation addtoken="no" url="/deductions/billback_select_vendor.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#&NextAction=VendorSaved" />	
		<CFELSE>
			<!---<cflocation addtoken="no" url="/billbacks/approval/payment_display.cfm?BBID=#Billback_ID#" /> --->
			<cflocation addtoken="no" url="/billbacks/capture/billback_summary.cfm?bbid=#Billback_ID#">	
		</CFIF>
			<!---D55703 :: Vendor required setting in closing method settings panel END--->
	</cfif>
	
	<CFIF NOT IsDefined("PayeeType")>	
		<CFSET PayeeType = qBillbackInfo.Billback_Payee_Type_ID>
	</CFIF>

	<CFSET ConsiderThisassociatedDistributorToBeThePayee = "" />
	<CFIF PayeeType EQ 4><!------ If payee = other, check i distributor is associated ----->	
		<cfset Get_Dist_Info = CreateObject("component", "components.billback.BillbackDeviationManager").getBillbackDistributor(Billback_ID, 4) />
		<CFSET ConsiderThisassociatedDistributorToBeThePayee = Get_Dist_Info.BSA_Foodservice_Customers_ID />
	</CFIF>
<!--- Payee is distributor --->
<CFIF PayeeType EQ 1 OR ConsiderThisassociatedDistributorToBeThePayee NEQ "">
	<CFIF appSettings.getVendorSearchInBBPayeePage() NEQ 1>
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT 		BSA_Foodservice_Customers.Name 	PayeeName,
							Vendor_Dist_Oper.Vendor_Dist_Oper_ID,
							Vendor_Master.Vendor_ID,
							BSA_Foodservice_Customers_ID,
							BSA_Foodservice_Customers.Name,
							--BSA_Operator.BSA_Operator_ID,
							--BSA_Operator.Operator_Name,
							--Legacy_ID,
							Shr_Ship_To,
							Vendor_Master.Vendor_Name,
							Vendor_Master.Address_1,
							Vendor_Master.Address_2,
							Vendor_Master.City,
							Vendor_Master.State,
							Vendor_Master.Zipcode,
							Vendor_Master.Vendor_Master_ID,
							BB_Approved.Vendor_Master_ID SavedVendor,
							BB_Approved.BB_Reason_Code_ID,
							BB_Approved.BB_Amount,
							BB_Approved.Paid_Amount,
							<CFIF PayeeType EQ 1>
							Billback_Distributor.Uploaded_Vendor_ID
							<CFELSEIF PayeeType EQ 4 AND ConsiderThisassociatedDistributorToBeThePayee NEQ "">
							NULL AS Uploaded_Vendor_ID
							</CFIF>
			FROM 		Vendor_Dist_Oper
			INNER JOIN 	BSA_Foodservice_Customers 
			ON Vendor_Dist_Oper.Distributor_ID  = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID 
			AND (LEN(Vendor_Dist_Oper.Operator_ID) = 0 
			OR 	Vendor_Dist_Oper.Operator_ID IS NULL)
			<CFIF PayeeType EQ 4 AND ConsiderThisassociatedDistributorToBeThePayee NEQ "">
				AND			BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#ConsiderThisassociatedDistributorToBeThePayee#'
				AND 		(LEN(Vendor_Dist_Oper.Operator_ID) = 0 OR Vendor_Dist_Oper.Operator_ID IS NULL)
			</CFIF>
			<CFIF PayeeType EQ 1>
				LEFT JOIN Billback_Distributor_List L 
				ON L.Billback_ID = '#Billback_ID#' 
				AND L.Deleted = 0
				INNER JOIN 	Billback_Distributor 
				ON (Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID OR 	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = L.Distributor_Id) 
				AND Billback_Distributor.Billback_ID = '#Billback_ID#' 
				AND Billback_Distributor.Deleted = 0
			</CFIF>
			LEFT JOIN	BB_Approved ON BB_Approved.Billback_ID = Billback_Distributor.Billback_ID	
			INNER JOIN 	Vendor_Master 
			ON (	
							(BB_Approved.Vendor_Master_Id IS NOT NULL AND Vendor_Master.Vendor_Master_Id = BB_Approved.Vendor_Master_Id)
					OR	(BB_Approved.Vendor_Master_Id IS NULL 	AND	Vendor_Master.Vendor_ID = Vendor_Dist_Oper.Vendor_ID) 
					) 
			AND Vendor_Master.Deleted=0 
			AND Vendor_Master.Active_Code = 'A'			
			WHERE 		Vendor_Dist_Oper.Deleted = 0
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT BSA_Foodservice_Customers.Name 	PayeeName,
						--Vendor_Dist_Oper.Vendor_Dist_Oper_ID,
						Vendor_Master.Vendor_ID,
						BSA_Foodservice_Customers_ID,
						BSA_Foodservice_Customers.Name,
						--BSA_Operator.BSA_Operator_ID,
						--BSA_Operator.Operator_Name,
						--Legacy_ID,
						Shr_Ship_To,
						Vendor_Master.Vendor_Name,
						Vendor_Master.Address_1,
						Vendor_Master.Address_2,
						Vendor_Master.City,
						Vendor_Master.State,
						Vendor_Master.Zipcode,
						Vendor_Master.Vendor_Master_ID,
						BB_Approved.Vendor_Master_ID SavedVendor,
						BB_Approved.BB_Reason_Code_ID,
						BB_Approved.BB_Amount,
						BB_Approved.Paid_Amount,            
						Billback_Distributor.Uploaded_Vendor_ID--Vendor_Master.Vendor_ID,Billback_Distributor.Uploaded_Vendor_ID,* 
			FROM 	Billback_Distributor 
			INNER JOIN 	BSA_Foodservice_Customers 
			ON Billback_Distributor.Distributor_ID  = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID 
			INNER JOIN 	BB_Approved 
			ON BB_Approved.Billback_ID = Billback_Distributor.Billback_ID
			LEFT JOIN	Vendor_Master 
			ON Vendor_Master.Deleted=0 
			AND Vendor_Master.Active_Code = 'A' 
			AND Vendor_Master.Vendor_ID = Billback_Distributor.Uploaded_Vendor_ID
			WHERE Billback_Distributor.Billback_ID = '#Billback_ID#' 
			AND Billback_Distributor.Deleted = 0
		</CFQUERY>	
	</CFIF>
	<cfset PayeeName = GetPayeeInfo.PayeeName />
	<!------ Get the other payee name ----->
	<CFIF PayeeType EQ 4 AND ConsiderThisassociatedDistributorToBeThePayee NEQ "">
		<cfset useLakebaseForGetOtherPayeeInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_unidentified_payee")>
<cfif useLakebaseForGetOtherPayeeInfo>
	<cftry>
		<cfset GetOtherPayeeInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_unidentified_payee", {
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0",
				"select" = "bb_up_name			payeename"
			}), "bb_up_name			payeename"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetOtherPayeeInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetOtherPayeeInfo>
<CFQUERY NAME="GetOtherPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT 		BB_UP_Name			PayeeName
			FROM 		Billback_Unidentified_Payee
			WHERE 		Billback_Unidentified_Payee.Billback_ID = '#Billback_ID#' 
			AND			Billback_Unidentified_Payee.Deleted = 0
		</CFQUERY>
</cfif>
		<cfset PayeeName = GetOtherPayeeInfo.PayeeName />
	</CFIF>

	<cfquery name="GetPayeeID" datasource="#application.datasource#">
		SELECT 			Shr_Ship_To AS Payee_ID
		FROM 			Billback_Distributor 
		INNER JOIN BSA_Foodservice_Customers 
		ON 				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
		WHERE 			Billback_Distributor.Billback_ID = '#Billback_ID#'
	</cfquery>

<!--- Payee is operator --->	
<CFELSEIF PayeeType EQ 2>
	<cfset useLakebaseForGetAssociatedShipTo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator")>
<cfif useLakebaseForGetAssociatedShipTo>
	<cftry>
		<cfset GetAssociatedShipTo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_operator", {
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAssociatedShipTo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAssociatedShipTo>
<CFQUERY NAME="GetAssociatedShipTo" DATASOURCE="#Application.Datasource#">
		SELECT * 
		FROM 		Billback_Operator 
		WHERE 		Billback_ID = '#Billback_ID#' 
		AND 		Deleted = 0
	</CFQUERY>
</cfif>
	<CFIF appSettings.getVendorSearchInBBPayeePage() NEQ 1>
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT 		Operator_Name	PayeeName,
							Vendor_Dist_Oper.Vendor_Dist_Oper_ID,
							Vendor_Master.Vendor_ID,
							BSA_Operator_ID,
							--BSA_Foodservice_Customers.Name,
							BSA_Operator.Operator_Name,
							Legacy_ID,
							--Shr_Ship_To,
							Vendor_Master.Vendor_Name,
							Vendor_Master.Address_1,
							Vendor_Master.Address_2,
							Vendor_Master.City,
							Vendor_Master.State,
							Vendor_Master.Zipcode,
							Vendor_Master.Vendor_Master_ID,
							BB_Approved.Vendor_Master_ID SavedVendor,
							Billback_Operator.Uploaded_Vendor_ID,
							BB_Approved.BB_Amount,
							BB_Approved.Paid_Amount,
							BB_Approved.BB_Reason_Code_ID
			FROM 		Vendor_Dist_Oper			
			INNER JOIN 	Billback_Operator 
			ON Billback_Operator.Operator_ID = Vendor_Dist_Oper.Operator_ID 
			AND	(LEN(Vendor_Dist_Oper.Distributor_ID) = 0 OR Vendor_Dist_Oper.Distributor_ID IS NULL)
			INNER JOIN 	BSA_Operator 
			ON Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID 
			LEFT JOIN	BB_Approved 
			ON BB_Approved.Billback_ID = Billback_Operator.Billback_ID
			INNER JOIN 	Vendor_Master ON
											(
												(BB_Approved.Vendor_Master_Id IS NOT NULL AND Vendor_Master.Vendor_Master_Id = BB_Approved.Vendor_Master_Id)
										OR 	(BB_Approved.Vendor_Master_Id IS NULL AND Vendor_Master.Vendor_ID = Vendor_Dist_Oper.Vendor_ID) 
											) 
			AND			Vendor_Master.Deleted=0 
			AND 		Vendor_Master.Active_Code = 'A'
			WHERE 		Billback_Operator.Billback_ID = '#Billback_ID#' 
			AND 		Billback_Operator.Deleted = 0 
			AND			Vendor_Dist_Oper.Deleted = 0					
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT 		Operator_Name	PayeeName,
							--Vendor_Dist_Oper.Vendor_Dist_Oper_ID,
							Vendor_Master.Vendor_ID,
							BSA_Operator_ID,
							--BSA_Foodservice_Customers.Name,
							BSA_Operator.Operator_Name,
							Legacy_ID,
							--Shr_Ship_To,
							Vendor_Master.Vendor_Name,
							Vendor_Master.Address_1,
							Vendor_Master.Address_2,
							Vendor_Master.City,
							Vendor_Master.State,
							Vendor_Master.Zipcode,
							Vendor_Master.Vendor_Master_ID,
							BB_Approved.Vendor_Master_ID SavedVendor,
							Billback_Operator.Uploaded_Vendor_ID,
							BB_Approved.BB_Amount,
							BB_Approved.Paid_Amount,
							BB_Approved.BB_Reason_Code_ID			
			FROM Billback_Operator 
			INNER JOIN 	BSA_Operator 
			ON Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID 
			INNER JOIN 	BB_Approved 
			ON BB_Approved.Billback_ID = Billback_Operator.Billback_ID
			LEFT JOIN	Vendor_Master 
			ON Vendor_Master.Deleted=0 
			AND Vendor_Master.Active_Code = 'A' 
			AND Vendor_Master.Vendor_ID = Billback_Operator.Uploaded_Vendor_ID
			WHERE Billback_Operator.Billback_ID = '#Billback_ID#' 
			AND Billback_Operator.Deleted = 0  
		</CFQUERY>
	</CFIF>
	<cfquery name="GetPayeeID" datasource="#application.datasource#">
		SELECT Legacy_ID AS Payee_ID
		FROM Billback_Operator 
		INNER JOIN BSA_Operator 
		ON BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID
		WHERE Billback_Operator.Billback_ID = '#Billback_ID#'
	</cfquery>
	<cfset PayeeName = GetPayeeInfo.PayeeName />
<CFELSEIF PayeeType EQ 3>
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT 	Brk.Broker_Name PayeeName,
						--Vendor_Dist_Oper.Vendor_Dist_Oper_ID,
						V.Vendor_ID,
						Brk.BSA_Foodservice_Brokers_ID,
						Brk.Broker_Name,
						--BSA_Operator.BSA_Operator_ID,
						--BSA_Operator.Operator_Name,
						--Legacy_ID,
						Broker_Shard, --Shr_Ship_To,
						V.Vendor_Name,
						V.Address_1,
						V.Address_2,
						V.City,
						V.State,
						V.Zipcode,
						V.Vendor_Master_ID,
						A.Vendor_Master_ID SavedVendor,
						A.BB_Reason_Code_ID,
						A.BB_Amount,
						A.Paid_Amount,
						BB.Uploaded_Vendor_ID--Vendor_Master.Vendor_ID,Billback_Distributor.Uploaded_Vendor_ID,* 
			FROM 	Billback_Broker BB
			INNER JOIN 	BSA_Foodservice_Brokers Brk 
			ON 			BB.Broker_ID  = Brk.BSA_Foodservice_Brokers_ID 
			INNER JOIN 	BB_Approved A 
			ON A.Billback_ID = BB.Billback_ID
			LEFT JOIN	Vendor_Master V 
			ON V.Vendor_Master_ID = Brk.BSA_Foodservice_Brokers_ID 
			AND	V.Deleted=0 
			AND V.Active_Code = 'A'
			WHERE BB.Billback_ID = '#Billback_ID#' 
			AND BB.Deleted = 0
		</CFQUERY>
		
		<CFQUERY name="GetPayeeID" datasource="#application.datasource#">
			SELECT Broker_Legcy_Shard AS Payee_ID
			FROM Billback_Broker 
			INNER JOIN BSA_Foodservice_Brokers
			ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID
			WHERE Billback_Broker.Billback_ID = '#Billback_ID#'
		</CFQUERY>
<!--- Payee is broker --->
<CFELSE>
	<BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">Payee is not a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> and not a <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>...</FONT></B></TD>
		</TR>
	</TABLE>	
	<cfquery name="GetPayeeID" datasource="#application.datasource#">
		SELECT Broker_Legcy_Shard AS Payee_ID
		FROM Billback_Broker 
		INNER JOIN BSA_Foodservice_Brokers
		ON BSA_Foodservice_Brokers.BSA_Foodservice_Broker_ID = Billback_Broker.Broekr_ID
		WHERE Billback_Broker.Billback_ID = '#Billback_ID#'
	</cfquery>
</CFIF>
	<cfif Not isDefined("FORM.Vendor_ID") or (isDefined("FORM.Vendor_ID") and FORM.Vendor_ID eq "") or appSettings.getBBAllowVendorMasterSearch()>
		<cfquery name="getsavedvendor" datasource="#application.datasource#">
			SELECT * 
			FROM BB_Approved
			INNER JOIN Vendor_Master 
			ON Vendor_Master.Vendor_Master_ID = BB_Approved.Vendor_Master_ID 
			AND Vendor_Master.Active_Code = 'A' 
			AND Vendor_Master.Deleted = 0
			WHERE Billback_ID = '#Billback_ID#'
		</cfquery>
		<cfif getsavedvendor.recordcount gt 0>
			<cfparam name="form.vendor_id" default="#getsavedvendor.vendor_id#">
		<cfelse>
			<cfparam name="form.vendor_id" default="#getpayeeinfo.uploaded_vendor_id#">	
		</cfif>
	</cfif>


<CFOUTPUT>
	<CFIF PayeeType EQ 1 OR PayeeType EQ 2 OR PayeeType EQ 3 OR (PayeeType EQ 4 AND ConsiderThisassociatedDistributorToBeThePayee NEQ "")>
	<BR><BR><BR>
	<FORM NAME="VendorIDSel" ACTION="/GL_Code/GL_Code_In_Billback/Payment_Request/Payment_Request_Display.cfm" METHOD="Post">
		<INPUT TYPE="Hidden" NAME="Vendor_ID" VALUE="#FORM.Vendor_ID#">
		<CFIF IsDefined("Deduction_ID")>
			<INPUT TYPE="Hidden" NAME="Deduction_ID" VALUE="#Deduction_ID#">
		</CFIF>
		<INPUT TYPE="Hidden" NAME="Billback_ID" VALUE="#Billback_ID#">
		<INPUT TYPE="hidden" NAME="PayeeType" VALUE="#PayeeType#">
		<CFIF PayeeType EQ 1>
			<INPUT TYPE="Hidden" NAME="distributor_id" VALUE="#GetPayeeInfo.BSA_Foodservice_Customers_ID#">
		<CFELSEIF PayeeType EQ 4 AND ConsiderThisassociatedDistributorToBeThePayee NEQ "">
			<INPUT TYPE="Hidden" NAME="distributor_id" VALUE="#ConsiderThisassociatedDistributorToBeThePayee#">
		<CFELSEIF PayeeType EQ 2>
			<INPUT TYPE="Hidden" NAME="operator_id" VALUE="#GetPayeeInfo.BSA_Operator_ID#">
		</CFIF>
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" STYLE="Border-Bottom: 2px Solid Navy;Border-Left: 2px Solid Navy;Border-Right: 2px Solid Navy;Border-Top: 2px Solid Navy;" ALIGN="Center">

<!--- Dev Note: Milan (44393 and 45193)
When the billback has "payment" as it's closing method AND the below app setting is ON, we do not want the user to see the vendor select page as the vendor is already selected.
Using label 44393, we already had code to redirect the user to summary page when the below condition exists, but on the new "webssd" environment the redirect was taking time and so
the vendor select screen has been hidden for the below condition.
The reason why the code is also looking for 'FORM.Vendor_ID eq "" ' is because if for some reason there is no vendor, the user should be taken to the vendor select screen.
Note: I think the purpose of giving the user a chance to change a vendor is why we show the vendor select screen here.
Note: (WR 60998) - Now a different app setting is being used below - "getSkipVendorSelectionOnBBApproval".
--->
<CFIF NOT(Closing_Method_Type EQ 1 AND appSettings.getSkipVendorSelectionOnBBApproval() eq 1) OR FORM.Vendor_ID eq "">
	<TR>
		<TD><B><FONT COLOR="NAVY" SIZE="2">Associate a Vendor ID <CFIF qBillbackInfo.BB_Closing_Method NEQ 2>before requesting  payment</CFIF></FONT></B><HR COLOR="Orange"></TD>
	</TR>
	<TR>
		<TD>
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD><B>Payee Type:</B></TD>
					<TD>
						<CFIF PayeeType EQ 1>#application.returned_customer_setting.distributor_label_singular#
						<CFELSEIF PayeeType EQ 2>#application.returned_customer_setting.operator_label_singular#
						<CFELSEIF PayeeType EQ 4>Other</CFIF>
					</TD>
				</TR>
				<TR>
					<TD><B>Payee Name:</B></TD>
					<TD>#GetPayeeInfo.PayeeName# </TD>		
				</TR>
				<CFIF PayeeType EQ 1 OR PayeeType EQ 2>
				<TR>
					<TD><B><CFIF PayeeType EQ 1>#application.returned_customer_setting.Shard_Ship_To_Label#<CFELSEIF PayeeType EQ 2>#application.returned_customer_setting.operator_label_singular# ID</CFIF>:</B></TD>
					<TD><CFIF PayeeType EQ 1>#GetPayeeInfo.Shr_Ship_To#<CFELSEIF PayeeType EQ 2><CFIF GetPayeeInfo.Legacy_ID NEQ "">#GetPayeeInfo.Legacy_ID#<CFELSE>#GetPayeeInfo.BSA_Operator_ID#</CFIF></CFIF></TD>
				</TR>
				</CFIF>
				<TR>
					<TD VALIGN="Top"><B>Vendor ID:</B></TD>					
					<TD>
						<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0">							
							<CFIF appSettings.getBBAllowVendorMasterSearch()>								
								<!--- D13783 See if there's a match between ship to and vendor ID --->
								<cfset useLakebaseForFindVendorMatch = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
<cfif useLakebaseForFindVendorMatch>
	<cftry>
		<cfset FindVendorMatch = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vendor_master", {
				"vendor_id" = "eq.#GetPayeeID.Payee_ID#",
				"select" = "vendor_master_id,vendor_id"
			}), "vendor_master_id,vendor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForFindVendorMatch = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFindVendorMatch>
<cfquery name="FindVendorMatch" datasource="#application.datasource#">
									SELECT Vendor_Master_ID, Vendor_ID 
									FROM Vendor_Master
									WHERE Vendor_ID = '#GetPayeeID.Payee_ID#'
								</cfquery>
</cfif>								
								<cfif FindVendorMatch.Recordcount IS 1 and len(trim(FORM.Vendor_ID)) LT 1>
									<cfset FORM.Vendor_ID = FindVendorMatch.Vendor_ID>
									<CFQUERY NAME="SetVendorID" DATASOURCE="#Application.Datasource#">	
										UPDATE 	b
										SET 	Vendor_Master_ID = v.Vendor_Master_ID
										FROM BB_Approved b
										INNER JOIN Vendor_Master v 
										ON v.Vendor_ID = '#FORM.Vendor_ID#'
										WHERE 	Billback_ID = '#Billback_ID#'
									</CFQUERY>
								</cfif>
								<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
								<cfset busSegOn = 0 />
								<cfif (businessSegManager.isEnabled())>
									<cfset busSegOn = 1 />
								</cfif>
								<cfquery name="getBusSegFromPrg" datasource="#Application.Datasource#">
									SELECT BS.Business_Segment_ID, BS.Business_Unit_Desc
									FROM Billback B
									INNER JOIN Billback_Program BP
									ON BP.Billback_ID = B.Billback_ID
									AND BP.Deleted = 0
									INNER JOIN Contract_Main CM
									ON CM.Contract_Main_ID = BP.Program_ID
									INNER JOIN Business_Segment BS
									ON BS.Business_Segment_ID = CM.Business_Segment_ID
									WHERE B.billback_id = '#Billback_ID#' 
								</cfquery>
								<cfif (isDefined("getBusSegFromPrg") AND (getBusSegFromPrg.RecordCount NEQ 0))>
									<cfset lsBusinessSegmentID = Valuelist(getBusSegFromPrg.Business_Segment_ID) />
									<cfif (lsBusinessSegmentID EQ "")>
										<cfset lsBusinessSegmentID = 0 />
									</cfif>
								</cfif>
								<TR>
									<TD COLSPAN="100%"><B>
										<cfif appSettings.getBBAllowVendorMasterSearch() AND Get_Profile_Settings.BB_Allow_Vendor_Master_Search EQ 1>
											<cfif ((busSegOn EQ 1) AND (businessSegManager.isEnabledForVendorType() NEQ 0) AND (isDefined("getBusSegFromPrg") AND (getBusSegFromPrg.RecordCount NEQ 0)))> 
<font color="red">[ </font><a onclick="searchData('vm',<cfoutput>#lsBusinessSegmentID#</cfoutput>)" style="cursor: pointer;"> vendor master</a><font color="red"> ]</font>&nbsp;&nbsp; 
										<cfelse>	
											<font color="red">[ </font><a onclick="searchData('vm',<cfoutput>#lsBusinessSegmentID#</cfoutput>)" style="cursor: pointer;"> vendor master</a><font color="red"> ]</font>&nbsp;&nbsp; 
										</cfif>
										</cfif>
										<cfif appSettings.getBBAllowVendorCrossRefSearch()>
											<font color="red">[ </font><a onclick="searchData('vn',<cfoutput>#lsBusinessSegmentID#</cfoutput>)" style="cursor: pointer;"> vendor cross ref</a><font color="red"> ]</font></B>						
										</cfif>
									</TD>
								</TR>
								<CFIF FORM.Vendor_ID NEQ "">
									<cfset useLakebaseForGetVendorMaster = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
<cfif useLakebaseForGetVendorMaster>
	<cftry>
		<cfset GetVendorMaster = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vendor_master", {
				"vendor_id" = "eq.#FORM.Vendor_ID#",
				"active_code" = "eq.A",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetVendorMaster = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetVendorMaster>
<CFQUERY NAME="GetVendorMaster" DATASOURCE="#Application.Datasource#">
										SELECT * 
										FROM Vendor_Master 
										WHERE Vendor_ID = '#FORM.Vendor_ID#' 
										AND Active_Code = 'A' 
										AND Deleted = 0
									</CFQUERY>
</cfif>
									<CFSET FORM.Vendor_Master_ID = GetVendorMaster.Vendor_Master_ID>
									<TR BGCOLOR="FFE083">
										<TD>&nbsp;</TD>
										<TD><B>Vendor Name<BR>Vendor ##</B></TD>
										<TD><B>Address</B></TD>	
									</TR>
									<CFIF GetVendorMaster.RecordCount GT 0>
										<CFLOOP QUERY="GetVendorMaster">
										<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
											<TD VALIGN="Top"><INPUT TYPE="Radio" NAME="Vendor_Master_ID" VALUE="#Vendor_Master_ID#" CHECKED></TD><!---  <CFIF Vendor_Master_ID EQ GetPayeeInfo.SavedVendor>CHECKED</CFIF> --->
											<cfset Sel_Vendor_Master_ID = Vendor_Master_ID />
											<CFSET ReplacedID = REPLACE(Vendor_Master_ID,"-","_","All")>
											<CFIF LEN(Vendor_Name) GT 20>
												<CFSET DispVendorName = LEFT(Vendor_Name,20)>
											<CFELSE>
												<CFSET DispVendorName = Vendor_Name>
											</CFIF>
											<TD VALIGN="Top" TITLE="#Vendor_Name#">#DispVendorName#<CFIF LEN(Vendor_Name) GT 20>...</CFIF><BR><B>#Vendor_ID#</B></TD>
											<TD VALIGN="Top">#Address_1#<CFIF Address_2 NEQ "">,<BR>#Address_2#,</CFIF><BR>#City#, #State#, #Zipcode#</TD>										
										</TR>
										</CFLOOP>
									</CFIF>
								</CFIF> 
							<CFELSE>
							<TR BGCOLOR="FFE083">
								<TD>&nbsp;</TD>
								<TD><B>Vendor Name<BR>Vendor ##</B></TD>
								<TD><B>Address</B></TD>	
							</TR>
								<CFLOOP QUERY="GetPayeeInfo">
								        <CFIF FORM.Vendor_ID NEQ "" OR Len(Trim(GetPayeeInfo.Vendor_Name)) GT 0>
									<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
										<TD VALIGN="Top"><INPUT TYPE="Radio" NAME="Vendor_Master_ID" VALUE="#Vendor_Master_ID#" <CFIF Vendor_Master_ID EQ SavedVendor>CHECKED</CFIF>></TD>
										<cfset Sel_Vendor_Master_ID = Vendor_Master_ID />
										<CFSET ReplacedID = REPLACE(Vendor_Master_ID,"-","_","All")>
										<cfif appSettings.getVendorSearchInBBPayeePage() NEQ 1 >
											<INPUT TYPE="Hidden" NAME="Vendor_Dist_Oper_ID_#ReplacedID#" VALUE="#Vendor_Dist_Oper_ID#">
										</cfif>
										<CFIF LEN(Vendor_Name) GT 20>
											<CFSET DispVendorName = LEFT(Vendor_Name,20)>
										<CFELSE>
											<CFSET DispVendorName = Vendor_Name>
										</CFIF>
										<TD VALIGN="Top" TITLE="#Vendor_Name#">#DispVendorName#<CFIF LEN(Vendor_Name) GT 20>...</CFIF><BR><B>#Vendor_ID#</B></TD>
										<TD VALIGN="Top">#Address_1#<CFIF Address_2 NEQ "">,<BR>#Address_2#,</CFIF><BR>#City#, #State#, #Zipcode#</TD>
									</TR>
								        </CFIF>
								</CFLOOP>
							</CFIF>
						</TABLE>
					</TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
	<TR>
<CFELSE>
<!--- Dev Note: Milan (44393 and 45193)
Do not show the user the vendor select screen above. Instead, add logic to get the vendor and use a hidden variable instead of a radio button and then
redirect the user to the summary page  (the next page redirects to the summary page).
Also add "REDIRECTING TO SUMMARY PAGE. PLEASE WAIT !!" below so that whenever it takes time to redirect, the user can see this message.
--->
	<CFIF appSettings.getBBAllowVendorMasterSearch()>
									
		<!--- D13783 See if there's a match between ship to and vendor ID --->
		<cfquery name="FindVendorMatch" datasource="#application.datasource#">
		SELECT Vendor_Master_ID, Vendor_ID 
		FROM Vendor_Master
		WHERE Vendor_ID = '#GetPayeeID.Payee_ID#'
		</cfquery>
		
		<cfif FindVendorMatch.Recordcount IS 1 and len(trim(FORM.Vendor_ID)) LT 1>
			<cfset FORM.Vendor_ID = FindVendorMatch.Vendor_ID>
		</cfif>

		<CFIF FORM.Vendor_ID NEQ "">
			<CFQUERY NAME="GetVendorMaster" DATASOURCE="#Application.Datasource#">
				SELECT * 
				FROM Vendor_Master 
				WHERE Vendor_ID = '#FORM.Vendor_ID#' 
				AND Active_Code = 'A' 
				AND Deleted = 0
			</CFQUERY>		
			<CFIF GetVendorMaster.RecordCount GT 0>
				<CFLOOP QUERY="GetVendorMaster">
				<INPUT TYPE="hidden" NAME="Vendor_Master_ID" VALUE="#Vendor_Master_ID#">
				<cfset Sel_Vendor_Master_ID = Vendor_Master_ID />
				</CFLOOP>			
			<span style="color:red;font-weight:bold">REDIRECTING TO SUMMARY PAGE. PLEASE WAIT !!</span>
			</CFIF>
		</CFIF>
	</CFIF>
</CFIF>

<cfif FORM.Vendor_ID NEQ "" OR Len(Trim(GetPayeeInfo.Vendor_Name)) GT 0>
	<cfif (appSettings.getShowReasonCodeOnBBApprovalScreen() AND (appSettings.getReasonCodeInBillbackDisplaySetting() EQ 1 OR (appSettings.getReasonCodeInBillbackDisplaySetting() EQ 2 AND GetPayeeInfo.Paid_Amount LT GetPayeeInfo.BB_Amount)))>
	<TR>
		<TD>
			<cfset reasonCodePerRow = 2 />
			<cfinclude template="/billbacks/APPROVAL/BB_Reason_Code_Selection.cfm" />
			<cfset bReasonCodeSelection = 1 />		
		</TD>
	</TR>	
	<TR>
		<TD>&nbsp;</TD>
	</TR>
	</cfif>
	
	<CFQUERY NAME="BB_Info" DATASOURCE="#Application.Datasource#">
		SELECT 		Round(BB_Approved.Paid_Amount,2) ApprovedAmt,
						ISNULL(ROUND(Billback.TotalTaxAmount,2),0) TotalTaxAmount,
						Round(BB_Approved.Paid_Amount,2)+ISNULL(ROUND(Billback.TotalTaxAmount,2),0) AmountToPay
		FROM 		Billback 
		INNER JOIN 	BB_Approved 
		ON BB_Approved.Billback_ID = Billback.Billback_ID
		WHERE 		Billback.Billback_ID = '#Billback_ID#'
	</CFQUERY>

			<cfif Closing_Method_Type EQ 1 AND appSettings.getSkipVendorSelectionOnBBApproval() eq 1>
			<!--- Dev Note: 44393. The code which gets fired in this condition is the JS code. That code is towards the end of this file.
			The "submitThis" function is automatically called without user interaction and the billback behavior is such as if the user is "saving" 
			(column:  "BB_Payment_Request_Prepared") the payment request. So, the payment request is automatically set to "HOLD:".
			The payment request is never approved from here in this condition. The user who can approve payment request does so from the
			billback scorecard, i.e. the billback is "RELEASED" from the scorecard. This code is applicable for "payment" only.
			Note: WR(60998) -  Now a different app setting is being used above - "getSkipVendorSelectionOnBBApproval".
			--->
			
			<cfelseif Closing_Method_Type NEQ 1><!--- closing method = deduction,Adjustment,OffInvoice ---->
				<TD ALIGN="Center">
					<CF_button
							button_name		=	"save"
							button_caption	=	"Save Vendor"
							button_action	=	"submitThis('SaveVendor', 'save_table')"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold">
				</TD>
			<cfelse>
				<cfinclude template="/get_access_profile.cfm">
				<cfset Permit_Approval = 0>
				
				<cfif Get_Profile_Settings.BB_Pay_Req_Approval_Amount NEQ "*">
					<cfif BB_Info.ApprovedAmt LTE Get_Profile_Settings.BB_Pay_Req_Approval_Amount>
						<cfset Permit_Approval = 1>
					<cfelse>
						<cfset Permit_Approval = 0>
					</cfif>
				<cfelse>
					<cfset Permit_Approval = 1>
				</cfif>			
			
				<TD ALIGN="Center">
					<cfif Permit_Approval EQ 1>
							<CF_button
									button_name		=	"save"
									button_caption	=	"Save Vendor and Approve Payment Request"
									button_action	=	"submitThis('Approve', 'save_table')"
									button_type		=	"javascript_link"
									button_width	=	"100"
									button_color	=	"Navy"
									button_tip		=	""
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold">	
					<cfelse>				
							<CF_button
									button_name		=	"save"
									button_caption	=	"Save Vendor and Save Payment Request"
									button_action	=	"submitThis('Save', 'save_table')"
									button_type		=	"javascript_link"
									button_width	=	"100"
									button_color	=	"Navy"
									button_tip		=	""
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold">					
				</cfif>
			</TD>
		</cfif>
	</cfif>
	</TR>
</TABLE>
	<cfif appSettings.getDisplay_Vendor_ID_Null_Form() EQ 1>
		  <div align="center">
			  <br>
				  <CF_smallLink 
				  	title = "click to get a vendor ID NULL Notification form" 
				  	url = "/gl_code/gl_code_in_billback/payment_request/Vendor_ID Null New Vendor Form FORGE.xls"
				  	parameters = " target=""_blank""" >
			  <br>(Please fill the Vendor ID NULL Notification form and email it to place the request)
		  </div>
	</cfif>
<input type="hidden" name="NextAction" value="">
</FORM>
</CFIF>
</CFOUTPUT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<SCRIPT language="JavaScript">
		function submitThis(NextAction, disableClickedButtonName){
			/* If reasoncode exists */
			<cfif bReasonCodeSelection>
			if(!isReasonCodeSelected()){
				alert("Please select a Reason Code");
				return false;
			}
			</cfif>
			<CFIF Closing_Method_Type NEQ 1><!--- closing method = deduction,Adjustment,Offinvoice ---->
			document.VendorIDSel.action = "VendorID_Selection.cfm";
			<CFELSE>
			document.VendorIDSel.action = "/GL_Code/GL_Code_In_Billback/Payment_Request/Payment_Request_Display.cfm"
			</CFIF>
			if(Any_Object_Checked(document.all.Vendor_Master_ID)){
				document.all.NextAction.value = NextAction;
				document.all.VendorIDSel.submit();
				disableButton(disableClickedButtonName, true, false);
			}
			else{
				alert("Please select a vendor ID.");
				//document.all.Vendor_ID.focus();
			}
		}
		function searchData(typeofdata, busSegIDs){
			document.VendorIDSel.action = "VendorID_Selection.cfm"
			switch (typeofdata){
				case "vn":
					if (document.VendorIDSel.distributor_id){
						NewWindow("/GL_Code/Vendor_Management/Vendor_Cross_Ref_Search.cfm?Formname=VendorIDSel&Distributor_ID="+document.VendorIDSel.distributor_id.value, "Vensearchwindow", 1100, 600, "yes", "yes")
					}
					else{
						NewWindow("/GL_Code/Vendor_Management/Vendor_Cross_Ref_Search.cfm?Formname=VendorIDSel&operator_id="+document.VendorIDSel.operator_id.value, "Vensearchwindow", 1100, 600, "yes", "yes")
					}				
					break;
				
				case "vm":
					NewWindow("/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=VendorIDSel&lsBusinessSegmentID=" + busSegIDs, "Vensearchwindow", 800, 600, "yes", "yes")							
					break;
			}
		}
	</SCRIPT>

<!--- (START) Dev Note: 44393. This code gets fired automatically and without user interaction. --->
<CFIF Closing_Method_Type EQ 1 AND appSettings.getSkipVendorSelectionOnBBApproval() eq 1>

<!--- Dev Note (74916) - The issue was that the billback was set to "payment request status", but "BB_Payment_Request_Approved" and the other columns (see below)
were still not being updated. Perhaps the user closed this page before the upDate. The update happens on "Payment_Request_Display.cfm" on javascript submit below.
To make sure that this update happens, adding the query below as the server-side code will be always called. The JS code would be called only if the user had the
page opened. Note - The JS code is redirected to "Payment_Request_Display.cfm" for the update.
--->
<cfquery name="DefaultSignedToOn" datasource="#application.datasource#">
	UPDATE Billback
	SET		BB_Payment_Request_Approved = 1,
			BB_Payment_Request_Approved_Date = getdate(),
			BB_Payment_Request_Approved_By = '#request.AccessStructure.User_ID#'
			<cfif Sel_Vendor_Master_ID NEQ "">
			,Billback_Status_ID = 4
			</cfif>
	WHERE Billback_ID = '#Billback_ID#'
</cfquery>

<SCRIPT>
if(document.all.Vendor_Master_ID){	
	/* In case the vendor selection (radio) is unchecked, check it. */
	document.all.Vendor_Master_ID.checked = true;
	submitThis('Save', 'save_table');
}
</SCRIPT>
</CFIF>
<!--- (END) Dev Note: 44393. This code gets fired automatically and without user interaction. --->

</body>
</html>
<script>

 try { window.parent.dyniframesize(); } catch (err) { };

</script>

