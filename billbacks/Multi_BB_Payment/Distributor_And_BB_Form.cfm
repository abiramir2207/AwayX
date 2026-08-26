<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>



<CFSET PAGE_TITLE="Multiple Billbacks Payment Request">
<CFINCLUDE TEMPLATE="/includes/header.cfm">

<STYLE>
TABLE.BorderTable TD Validate
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>

<CFIF IsDefined("URL.Pay_Multi_Billbacks_ID")>
	<CFIF IsDefined("URL.ShowButton")>
	<CFPARAM NAME="URL.FromFirstPage" DEFAULT="1">
	<CFSET FORM.Lock_Status= 1>
	</CFIF>
	<CFINCLUDE TEMPLATE="Lock_BB.cfm">
	<CFQUERY NAME="GetPayeeType" DATASOURCE="#Application.Datasource#">
		SELECT 		Billback_Payee_Type_ID,
					CASE 
					WHEN Billback.Billback_Payee_Type_ID = 1 THEN
						CAST(Billback_Distributor.Distributor_ID AS NVARCHAR(100))
					WHEN  Billback.Billback_Payee_Type_ID = 2 THEN
						CAST(Billback_Operator.Operator_ID AS NVARCHAR(100))
					WHEN Billback.Billback_Payee_Type_ID = 3 THEN
						CAST(Billback_Broker.Broker_ID AS NVARCHAR(100))
					END AS Payee_ID
	
		FROM 		Billback 
		LEFT JOIN 	Billback_Distributor ON Billback_Distributor.Billback_ID = Billback.Billback_ID AND Billback_Distributor.Deleted = 0
		LEFT JOIN 	Billback_Operator ON Billback_Operator.Billback_ID = Billback.Billback_ID AND Billback_Operator.Deleted = 0
		LEFT JOIN 	Billback_Broker ON Billback_Broker.Billback_ID = Billback.Billback_ID AND Billback_Broker.Deleted = 0
		WHERE 		Billback.Billback_ID = '#URL.BBID#'
	</CFQUERY>
	
	<cfset useLakebaseForBBList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pay_multi_billbacks_list")>
<cfif useLakebaseForBBList>
	<cftry>
		<cfset BBList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pay_multi_billbacks_list", {
				"pay_multi_billbacks_id" = "eq.#URL.Pay_Multi_Billbacks_ID#",
				"deleted" = "eq.0",
				"select" = "billback_id"
			}), "billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBBList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBBList>
<CFQUERY NAME="BBList" DATASOURCE="#Application.Datasource#">
		SELECT 	Billback_ID 
		
		FROM 	Pay_Multi_Billbacks_List 
		
		WHERE 	Pay_Multi_Billbacks_ID = '#URL.Pay_Multi_Billbacks_ID#' AND 
				Deleted = 0
	</CFQUERY>
</cfif>
	<CFSET BBIDList = VALUELIST(BBList.Billback_ID)>
	
	
	<CFSET FORM.Billback_ID = BBIDList>
	<CFSET FORM.PayeeType = GetPayeeType.Billback_Payee_Type_ID> 
		
	<CFIF GetPayeeType.Billback_Payee_Type_ID EQ 1>
		<CFSET FORM.Distributor_List = GetPayeeType.Payee_ID>
		<CFSET FORM.FromDistributorSearch = 1>
	<CFELSEIF GetPayeeType.Billback_Payee_Type_ID EQ 2>
		<CFSET FORM.Operator_List = GetPayeeType.Payee_ID>
		<CFSET FORM.FromOperatorSearch = 1>
	<CFELSEIF GetPayeeType.Billback_Payee_Type_ID EQ 3>
		<CFSET FORM.Broker_List = GetPayeeType.Payee_ID>
		<CFSET FORM.FromBrokerSearch = 1>
	</CFIF>
	
</CFIF>


<CFSET ShowDistributor = 0>
<CFSET ShowOperator = 0>
<CFSET ShowBroker = 0>

<CFPARAM NAME="FORM.Distributor_List" DEFAULT="">
<CFPARAM NAME="FORM.Old_Distributor_List" DEFAULT="">
<CFPARAM NAME="FORM.FromDistributorSearch" DEFAULT="0">

<CFPARAM NAME="FORM.Operator_List" DEFAULT="">
<CFPARAM NAME="FORM.Old_Operator_List" DEFAULT="">
<CFPARAM NAME="FORM.FromOperatorSearch" DEFAULT="0">
	
<CFPARAM NAME="FORM.Broker_List" DEFAULT="">
<CFPARAM NAME="FORM.Old_Broker_List" DEFAULT="">
<CFPARAM NAME="FORM.FromBrokerSearch" DEFAULT="0">

<CFPARAM NAME="FORM.Billback_ID" DEFAULT="">

<CFPARAM NAME="FORM.LockSubmit" DEFAULT="0">

<CFIF FORM.Billback_ID EQ "">
	<CFQUERY NAME="UnlockAnyLocked" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Allied
		
		SET 	BB_Is_Locked = 0,
				BB_Locked_By_User_ID = Null
				
		WHERE 	BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#' AND 
				BB_Is_Locked = 1
		AND BB_Locked_By_Match_Central = 0
	</CFQUERY>
</CFIF>


<!--- <CFDUMP VAR="#FORM#"> --->
<CFIF FORM.Billback_ID NEQ "">
	<CFIF FORM.PayeeType EQ 1>
		<CFIF FORM.Old_Distributor_List NEQ FORM.Distributor_List AND FORM.Old_Distributor_List NEQ "">
			<CFSET FORM.Billback_ID = "">		
		</CFIF>
	<CFELSEIF FORM.PayeeType EQ 2>
		<CFIF FORM.Old_Operator_List NEQ FORM.Operator_List AND FORM.Old_Operator_List NEQ "">
			<CFSET FORM.Billback_ID = "">
		</CFIF>
	<CFELSEIF FORM.PayeeType EQ 3>
		<CFIF FORM.Old_Broker_List NEQ FORM.Broker_List AND FORM.Old_Broker_List NEQ "">
			<CFSET FORM.Billback_ID = "">
		</CFIF>
	</CFIF>
</CFIF>

<!--- <CFDUMP VAR="#FORM#"> --->

<CFIF FORM.Distributor_List NEQ "">
	<cfset useLakebaseForDist_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForDist_Search_Result>
	<cftry>
		<cfset Dist_Search_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#FORM.Distributor_List#",
				"deleted" = "eq.0",
				"active_code" = "eq.A",
				"select" = "bsa_foodservice_customers_id,name,ship_to,address_1,address_2,city,state,zipcode,phone"
			}), "bsa_foodservice_customers_id,name,ship_to,address_1,address_2,city,state,zipcode,phone"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDist_Search_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDist_Search_Result>
<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT 		BSA_Foodservice_Customers_ID,
					Name,
					Ship_To,
					Address_1,
					Address_2,
					City,
					State,
					ZipCode,
					Phone
				 
		FROM 		BSA_Foodservice_Customers 
		
		WHERE		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#FORM.Distributor_List#' AND
					BSA_Foodservice_Customers.Deleted = 0	AND
					BSA_Foodservice_Customers.Active_Code = 'A'
	</CFQUERY>
</cfif>
</CFIF>	

<CFIF FORM.Operator_List NEQ "">
	<cfset useLakebaseForOp_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForOp_Search_Result>
	<cftry>
		<cfset Op_Search_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"bsa_operator_id" = "eq.#FORM.Operator_List#",
				"deleted" = "eq.0",
				"select" = "operator_name,operator_address,operator_city,operator_state,operator_zip,operator_address2"
			}), "operator_name,operator_address,operator_city,operator_state,operator_zip,operator_address2"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForOp_Search_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForOp_Search_Result>
<CFQUERY NAME="Op_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT 	Operator_Name,
				Operator_Address,
				Operator_City,
				Operator_State,
				Operator_Zip,
				Operator_Address2
				 
		FROM 	BSA_Operator 
		WHERE	BSA_Operator.BSA_Operator_ID = '#FORM.Operator_List#' AND
				BSA_Operator.Deleted = 0
	</CFQUERY>
</cfif>	
</CFIF>

<CFIF FORM.Broker_List NEQ "">
	<cfset useLakebaseForBro_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_brokers")>
<cfif useLakebaseForBro_Search_Result>
	<cftry>
		<cfset Bro_Search_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_brokers", {
				"bsa_foodservice_brokers_id" = "eq.#FORM.Broker_List#",
				"deleted" = "eq.0",
				"active_code" = "eq.A",
				"select" = "bsa_foodservice_brokers_id,broker_name,address,address_2,city,state,zip"
			}), "bsa_foodservice_brokers_id,broker_name,address,address_2,city,state,zip"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBro_Search_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBro_Search_Result>
<CFQUERY NAME="Bro_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT 	BSA_Foodservice_Brokers_ID,
				Broker_Name,
				Address,
				Address_2,
				City,
				State,
				Zip
				 
		FROM 	BSA_Foodservice_Brokers 
		WHERE	BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = '#FORM.Broker_List#' AND
				BSA_Foodservice_Brokers.Deleted = 0	AND
				BSA_Foodservice_Brokers.Active_Code = 'A'
	</CFQUERY>
</cfif>
</CFIF>

<CFIF FORM.Billback_ID NEQ "">
	<CFQUERY NAME="GetBBInfo" DATASOURCE="#Application.Datasource#">
		SELECT 		Billback.Billback_ID,
					BB_Code,
					BB_Title,
					BB_Approved.Paid_Amount,
					BB_Reference,
					BB_Date,
					BB_Start_Date,
					BB_End_Date,
					BB_Is_Locked,
					BB_Locked_By_User_ID
					
		FROM 		Billback
		INNER JOIN	Billback_Allied ON Billback_Allied.Billback_ID = Billback.Billback_ID
		INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
				
		WHERE 		Billback.Billback_ID IN(#LISTQUALIFY(FORM.Billback_ID,"'",",","All")#) AND 
					Billback.Deleted = 0
				
		ORDER BY	BB_Code
	</CFQUERY><!---  <CFDUMP VAR="#GetBBInfo#"> --->
</CFIF>

<CFIF FORM.LockSubmit EQ 1>
<CFDUMP VAR="#FORM#">
<CFABORT>
</CFIF>
<CFOUTPUT>
<FORM NAME="MultiBB" ACTION="Distributor_And_BB_Form.cfm" METHOD="Post">

<INPUT TYPE="Hidden" NAME="FromDistributorSearch" VALUE="0">
<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
<INPUT TYPE="Hidden" NAME="Old_Distributor_List" VALUE="#FORM.Old_Distributor_List#">

<INPUT TYPE="Hidden" NAME="FromOperatorSearch" VALUE="0">
<INPUT TYPE="Hidden" ID="Operator_List" NAME="Operator_List" VALUE="#FORM.Operator_List#">
<INPUT TYPE="Hidden" NAME="Old_Operator_List" VALUE="#FORM.Old_Operator_List#">


<INPUT TYPE="Hidden" NAME="FromBrokerSearch" VALUE="0">
<INPUT TYPE="Hidden" ID="Broker_List" NAME="Broker_List" VALUE="#FORM.Broker_List#">
<INPUT TYPE="Hidden" NAME="Old_Broker_List" VALUE="#FORM.Old_Broker_List#"> 

<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
<INPUT TYPE="Hidden" NAME="Billback_ID" VALUE="#FORM.Billback_ID#">

<CFSET Locked_Img = "/Images/Deviations/lock_yes.jpg">
<CFSET UnLocked_Img = "/Images/Deviations/lock_no.jpg">
<INPUT TYPE="Hidden" NAME="LockSubmit" VALUE="0">

<CFSET LockStatus = 0>
<!--- <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">	
	<TR>
		<TD VALIGN="Top" ALIGN="Center"><BR><BR>
			<CFIF FORM.Billback_ID NEQ "">
				<CFIF LockStatus EQ 2>
					<img src="/Images/Deviations/lock_yes.jpg" alt="" width="40" height="40" border="0">
				<CFELSEIF LockStatus EQ 1>				
					<INPUT TYPE="Hidden" NAME="Lock_Status" VALUE="0">  					
					<CFOUTPUT><INPUT TYPE="Hidden" NAME="Locked_By" VALUE=""></CFOUTPUT>
					<INPUT TYPE="Image" SRC="#Locked_Img#" ONMOUSEOVER="this.src='#UnLocked_Img#';" ONMOUSEOUT="this.src='#Locked_Img#';" ONCLICK="Javascript: LockUnLock();">									
					<BR><B><FONT COLOR="Blue">&nbsp;&nbsp;LOCKED</FONT></B>
				<CFELSEIF LockStatus EQ 0>				
					<INPUT TYPE="Hidden" NAME="Lock_Status" VALUE="1">
					<INPUT TYPE="Hidden" NAME="Locked_By" VALUE="#request.AccessStructure.user_ID#">
					<INPUT TYPE="Image" SRC="#UnLocked_Img#" ONMOUSEOVER="this.src='#Locked_Img#';" ONMOUSEOUT="this.src='#UnLocked_Img#';" ONCLICK="Javascript: LockUnLock();">										
					<BR><B><FONT COLOR="Blue">&nbsp;&nbsp;UNLOCKED</FONT></B>
				</CFIF>	
			<CFELSE>
				<INPUT TYPE="Image" SRC="#UnLocked_Img#">
			</CFIF>&nbsp;&nbsp;		
		</TD>
		<TD> --->
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="700">
				<TR ALIGN="Center">
					<TD>
						<B>Select Payee Type:</B>
						<INPUT TYPE="Radio" NAME="PayeeType" VALUE="1" ONCLICK="DirectPayee(1)" <CFIF FORM.Distributor_List NEQ "">Checked</CFIF><CFIF IsDefined("URL.Pay_Multi_Billbacks_ID") AND FORM.PayeeType NEQ 1>DISABLED</CFIF>> #application.returned_customer_setting.distributor_label_singular#
						<INPUT TYPE="Radio" NAME="PayeeType" VALUE="2" ONCLICK="DirectPayee(2)" <CFIF FORM.Operator_List NEQ "">Checked</CFIF><CFIF IsDefined("URL.Pay_Multi_Billbacks_ID") AND FORM.PayeeType NEQ 2>DISABLED</CFIF>> #application.returned_customer_setting.operator_label_singular#
						<INPUT TYPE="Radio" NAME="PayeeType" VALUE="3" ONCLICK="DirectPayee(3)" <CFIF FORM.Broker_List NEQ "">Checked</CFIF><CFIF IsDefined("URL.Pay_Multi_Billbacks_ID") AND FORM.PayeeType NEQ 3>DISABLED</CFIF>> Broker
					</TD>		
				</TR>
				<TR>
					<TD><HR COLOR="Orange"></TD>
				</TR>
			</TABLE>
			
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="700">		
				<TR>
					<TD ID="DIST_TD" <CFIF ShowDistributor NEQ 0 OR FORM.FromDistributorSearch NEQ 0 OR FORM.Distributor_List NEQ "">BGCOLOR="FFE083"</CFIF>><SPAN ID="Distributor" <CFIF ShowDistributor EQ 0 AND FORM.FromDistributorSearch EQ 0 AND FORM.Distributor_List EQ "">STYLE="DISPLAY:NONE"</CFIF>>&nbsp;&nbsp;<B>DISTRIBUTOR &nbsp;&nbsp;<CFIF NOT IsDefined("URL.Pay_Multi_Billbacks_ID")><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="##" onClick="javaScript: showSearchWindow(1);">pick</A><FONT COLOR="Red" SIZE="2"> ]</FONT></CFIF></B></SPAN></TD>
				</TR>
				<CFIF IsDefined("Dist_Search_Result") AND Dist_Search_Result.Recordcount GT 0>	
				<TR>
					<TD><SPAN ID="Dist_Details">
						<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
							<TR>
								<TD WIDTH="120">&nbsp;&nbsp;<B>Name:</B></TD>
								<TD>#Dist_Search_Result.Name# <B>(#Dist_Search_Result.Ship_To#)</B></TD>
							</TR>
							<TR>
								<TD>&nbsp;&nbsp;<B>Address:</B></TD>
								<TD>#Dist_Search_Result.Address_1#</TD>
							</TR>
							<CFIF TRIM(Dist_Search_Result.Address_2) NEQ "">
							<TR>
								<TD>&nbsp;</TD>
								<TD>#Dist_Search_Result.Address_2#</TD>
							</TR>
							</CFIF>
							<TR>
								<TD>&nbsp;&nbsp;</TD>
								<TD>#TRIM(Dist_Search_Result.City)#, #Dist_Search_Result.State# - #Dist_Search_Result.ZipCode#</TD>
							</TR>
							<TR>
								<TD>&nbsp;&nbsp;<B>Phone:</B></TD>
								<TD>#Dist_Search_Result.Phone#</TD>
							</TR>
						</TABLE></SPAN>
					</TD>
				</TR>	
				</CFIF>
				
				<TR>
					<TD ID="OP_TD" <CFIF ShowOperator NEQ 0 OR FORM.FromOperatorSearch NEQ 0 OR FORM.Operator_List NEQ "">BGCOLOR="FFE083"</CFIF>><SPAN ID="Operator" <CFIF ShowOperator EQ 0 AND FORM.FromOperatorSearch EQ 0 AND  FORM.Operator_List EQ "">STYLE="DISPLAY:NONE"</CFIF>>&nbsp;&nbsp;<B>#application.returned_customer_setting.operator_label_singular# &nbsp;&nbsp;<CFIF NOT IsDefined("URL.Pay_Multi_Billbacks_ID")><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="##" onClick="javaScript: showSearchWindow(2);">pick</A><FONT COLOR="Red" SIZE="2"> ]</FONT></CFIF></B></SPAN></TD>
				</TR>	
				
				<CFIF IsDefined("Op_Search_Result") AND Op_Search_Result.Recordcount GT 0>	
				<TR>
					<TD><SPAN ID="Op_Details">
						<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
							<TR>
								<TD WIDTH="120">&nbsp;&nbsp;<B>Name:</B></TD>
								<TD>#Op_Search_Result.Operator_Name#</TD>
							</TR>
							<TR>
								<TD>&nbsp;&nbsp;<B>Address:</B></TD>
								<TD>#Op_Search_Result.Operator_Address#</TD>
							</TR>
							<CFIF TRIM(Op_Search_Result.Operator_Address2) NEQ "">
							<TR>
								<TD>&nbsp;</TD>
								<TD>#Op_Search_Result.Operator_Address2#</TD>
							</TR>
							</CFIF>
							<TR>
								<TD>&nbsp;&nbsp;</TD>
								<TD>#TRIM(Op_Search_Result.Operator_City)#, #Op_Search_Result.Operator_State# - #Op_Search_Result.Operator_Zip#</TD>
							</TR>				
						</TABLE></SPAN>
					</TD>
				</TR>	
				</CFIF>
				
				<TR>
					<TD ID="BRO_TD"<CFIF ShowBroker NEQ 0 OR FORM.FromBrokerSearch NEQ 0 OR FORM.Broker_List NEQ "">BGCOLOR="FFE083"</CFIF>><SPAN ID="Broker" <CFIF ShowBroker EQ 0 AND FORM.FromBrokerSearch EQ 0 AND FORM.Broker_List EQ "">STYLE="DISPLAY:NONE"</CFIF>>&nbsp;&nbsp;<B>BROKER &nbsp;&nbsp;<CFIF NOT IsDefined("URL.Pay_Multi_Billbacks_ID")><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="##" onClick="javaScript: showSearchWindow(3);">pick</A><FONT COLOR="Red" SIZE="2"> ]</FONT></CFIF></B></SPAN></TD>
				</TR>
				<CFIF IsDefined("Bro_Search_Result") AND Bro_Search_Result.Recordcount GT 0>	
				<TR>
					<TD><SPAN ID="Bro_Details">
						<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
							<TR>
								<TD WIDTH="120">&nbsp;&nbsp;<B>Name:</B></TD>
								<TD>#Bro_Search_Result.Broker_Name#</TD>
							</TR>
							<TR>
								<TD>&nbsp;&nbsp;<B>Address:</B></TD>
								<TD>#Bro_Search_Result.Address#</TD>
							</TR>
							<CFIF TRIM(Bro_Search_Result.Address_2) NEQ "">
							<TR>
								<TD>&nbsp;</TD>
								<TD>#Bro_Search_Result.Address_2#</TD>
							</TR>
							</CFIF>
							<TR>
								<TD>&nbsp;&nbsp;</TD>
								<TD>#TRIM(Bro_Search_Result.City)#, #Bro_Search_Result.State# - #Bro_Search_Result.Zip#</TD>
							</TR>				
						</TABLE></SPAN>
					</TD>
				</TR>	
				</CFIF>
				
			</TABLE>
			
			<CFSET SelectedPayeeType = 0>
			<CFIF FORM.Distributor_List NEQ "" >
				<CFSET SelectedPayeeType = 1>
			<CFELSEIF FORM.Operator_List NEQ "">
				<CFSET SelectedPayeeType = 2>
			<CFELSEIF FORM.Broker_List NEQ "">
				<CFSET SelectedPayeeType = 3>
			</CFIF>
			<BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="700">
				<TR>
					<TD ID="BB_TD" <CFIF SelectedPayeeType NEQ 0>BGCOLOR="FFE083"</CFIF>><SPAN ID="Billback" <CFIF SelectedPayeeType EQ 0>STYLE="DISPLAY:NONE"</CFIF>>&nbsp;&nbsp;<B>BILLBACK &nbsp;&nbsp;<CFIF NOT IsDefined("URL.Pay_Multi_Billbacks_ID")><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="##" onClick="javaScript: BBSearch('#SelectedPayeeType#');">pick</A><FONT COLOR="Red" SIZE="2"> ]</FONT></CFIF></B></SPAN></TD>
				</TR>
				<TR>
					<TD><SPAN ID="BBDetail" <CFIF FORM.Billback_ID EQ "">STYLE="DISPLAY:NONE"</CFIF>><BR>
						<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="700" CLASS="BorderTable">
							<TR BGCOLOR="FFE083">
								<TD><INPUT TYPE="CheckBox" NAME="allbox" ONCLICK="javaScript: selectAll(this);" CHECKED></TD>
								<TD><B><FONT SIZE="2">Payable ##</FONT></B></TD>
								<TD><B><FONT SIZE="2">Date<BR>Billback ##</FONT></B></TD>
								<TD><B><FONT SIZE="2">Title</FONT></B></TD>
								<TD><B><FONT SIZE="2">Start<BR>End</FONT></B></TD>
								<TD><B><FONT SIZE="2">Amount</FONT></B></TD>
							</TR>
							<CFIF FORM.Billback_ID NEQ "">
								<CFLOOP QUERY="GetBBInfo">			
								
									<!--- UnComment it at last
									<CFQUERY NAME="LockBB" DATASOURCE="#Application.Datasource#">
										UPDATE 	Billback_Allied 
										
										SET		BB_Is_Locked = 1,
												BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#',
												BB_Lock_Date = getdate()
												
										WHERE 	Billback_ID = '#Billback_ID#'
									</CFQUERY> --->
									 
									
									<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
										<TD VALIGN="Top"><INPUT TYPE="CheckBox" NAME="FinalBB" VALUE="#Billback_ID#" CHECKED></TD>
										<TD VALIGN="Top"><B><FONT SIZE="2">[ </FONT>#BB_Code#<FONT SIZE="2"> ]</FONT></B></TD>
										<CFSET Disp_Ref = BB_Reference>
										<CFSET Ref_Len = 30>
										<CFIF LEN(Disp_Ref) GT Ref_Len>
											<CFSET Disp_Ref = LEFT(Disp_Ref,Ref_Len)>
											<CFSET Disp_Ref = "#Disp_Ref#...">
										</CFIF>
										<TD VALIGN="Top">#DateFormat(BB_Date,"mm/dd/yyyy")#<BR>#Disp_Ref#</TD>
										<TD VALIGN="Top">#BB_Title#</TD>
										<TD VALIGN="Top">#DateFormat(BB_Start_Date,"mm/dd/yyyy")#<BR>#DateFormat(BB_End_Date,"mm/dd/yyyy")#</TD>
										<TD VALIGN="Top">#DollarFormat(Paid_Amount)#</TD>
									</TR>
								</CFLOOP>					
							</CFIF>
						</TABLE>
						<BR><BR>
						<CFIF NOT IsDefined("URL.BBID") OR IsDefined("URL.ShowButton")>
						<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="700">
							<TR>
									<TD ALIGN="Center" STYLE="Border: None">
										<CF_button
											button_name		=	""
											button_caption	=	"Make Payment"
											button_action	=	"Validate()"
											button_type		=	"javascript_link"
											button_width	=	"100"
											button_color	=	"Navy"
											button_tip		=	""
											font_color		=	"White"
											font_size		=	"12"
											font_weight		=	"bold"	>
									
									</TD>
								</TR>
						</TABLE>
						</CFIF>
						</SPAN>
					</TD>
				</TR>
			</TABLE>
		<!--- </TD>
	</TR>
</TABLE> --->
</FORM>
</CFOUTPUT>

<SCRIPT language="JavaScript">

function selectAll(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.FinalBB;
	if(chObjs.length)
	{
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++)
		{
			chObjs[i].checked = bCheck;
		}
	}
	else
	{
		chObjs.checked = bCheck;
	}	
}

function anyCheckBoxChecked(chObj)
{
	var bChecked = false;
	if(chObj.length)
	{
		var i, chLen;
		chLen = chObj.length;
		for(i=0;i<chLen;i++)
		{
			if(chObj[i].checked)
			{
				bChecked = true;
				break;
			}
		}
	}
	else
	{
		if(chObj.checked)
		{
			bChecked = true;
		}		
	}
	return bChecked;
}

function Validate()
{
	if(!anyCheckBoxChecked(document.all.FinalBB))	
	{
		alert("Please select atleast a billback to make payment.");
	}
	else
	{
		document.MultiBB.action = "Pay_Mulit_BB_Action.cfm";
		document.MultiBB.submit();
	}
}

function LockUnLock()
{	
	if(!anyCheckBoxChecked(document.all.FinalBB))	
	{
		alert("Please select atleast a billback and try again.");
	}
	else
	{
		document.all.LockSubmit.value = 1;
		//document.MultiBB.submit();
	}
}

function DirectPayee(Type)
{
	if (Type == 1)
	{
		document.all.Operator.style.display="none";
		if(document.all.Op_Details)
		{
			document.all.Op_Details.style.display="none";
		}
		document.all.OP_TD.bgColor = "ffffff";
		
		document.all.Broker.style.display="none";
		if(document.all.Bro_Details)
		{
			document.all.Bro_Details.style.display="none";
		}
		document.all.BRO_TD.bgColor = "ffffff";		
		
		document.all.Distributor.style.display="";
		document.all.DIST_TD.bgColor = "FFE083";
		
		hideBillback()
		resetBBID()
	}
	else if (Type == 2)
	{		
		document.all.Distributor.style.display="none";
		if (document.all.Dist_Details)
		{
			document.all.Dist_Details.style.display="none";
		}
		document.all.DIST_TD.bgColor = "ffffff";
		
		document.all.Broker.style.display="none";
		if(document.all.Bro_Details)
		{
			document.all.Bro_Details.style.display="none";
		}
		document.all.BRO_TD.bgColor = "ffffff";		
						
		document.all.Operator.style.display="";
		document.all.OP_TD.bgColor = "FFE083";
		
		hideBillback()
		resetBBID()
	}
	else if (Type == 3)
	{	
		document.all.Distributor.style.display="none";
		if (document.all.Dist_Details)
		{
			document.all.Dist_Details.style.display="none";
		}		
		document.all.DIST_TD.bgColor = "ffffff";
		
		document.all.Operator.style.display="none";
		if(document.all.Op_Details)
		{
			document.all.Op_Details.style.display="none";
		}
		document.all.OP_TD.bgColor = "ffffff";
		
		document.all.Broker.style.display="";
		document.all.BRO_TD.bgColor = "FFE083";
		
		hideBillback()
		resetBBID()
	}	
}


function hideBillback()
{
	document.all.Billback.style.display="none";
	document.all.BBDetail.style.display="none";
	document.all.BB_TD.bgColor = "ffffff";		
}

function resetBBID()
{
	document.all.Billback_ID.value = "";	
}

function BBSearch(Type)
{
	var formObj = document.MultiBB;
	var oldTarget = formObj.target;	
	document.all.Old_Distributor_List.value = document.all.Distributor_List.value;
	document.all.Old_Operator_List.value = document.all.Operator_List.value;
	document.all.Old_Broker_List.value = document.all.Broker_List.value;
	document.MultiBB.action = "Eligible_BB_List.cfm";
	formObj.target = "BBL";
	NewWindow("", 'BBL', '870', '600', 'Yes', 'No', true);
	document.MultiBB.submit();
	formObj.target = oldTarget;
}

function BBSearch1(Type)
{
	var payeeID = "";

	if (Type == 1)
	{
		payeeID = document.all.Distributor_List.value;				
	}
	else if (Type == 2)
	{
		payeeID = document.all.Operator_List.value;		
	}
	else if (Type ==3)
	{
		payeeID = document.all.Broker_List.value;		
	}
	NewWindow("/Billbacks/Multi_BB_Payment/Eligible_BB_List.cfm?PayeeType="+Type+"&payeeID="+payeeID, "BBsearch", 800, 600, "yes", "yes")	
}

function showSearchWindow(Type) 
{			
	document.all.Form_Submitted.value=0;		
	document.MultiBB.target = "_self";
	document.MultiBB.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";	
	if (Type == 1)
	{
		document.all.Old_Operator_List.value = "";
		document.all.Operator_List.value= "";
		document.all.FromOperatorSearch.value = 0;
		document.all.Old_Broker_List.value = "";
		document.all.FromBrokerSearch.value = 0;		
		document.all.Broker_List.value="";
		document.all.FromDistributorSearch.value = 1;		
		document.all.Old_Distributor_List.value = document.all.Distributor_List.value;
		NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=MultiBB", "Distsearch", 800, 600, "yes", "yes")
	}
	else if (Type == 2)
	{
		document.all.Old_Distributor_List.value = "";
		document.all.Distributor_List.value= "";
		document.all.FromDistributorSearch.value = 0;	
		document.all.Old_Broker_List.value = "";
		document.all.Broker_List.value="";	
		document.all.FromBrokerSearch.value = 0;
		document.all.FromOperatorSearch.value=1;
		document.all.Old_Operator_List.value = document.all.Operator_List.value;
		NewWindow("/Billbacks/search_Screens/PM_select_Operators.cfm?Formname=MultiBB", "Opsearch", 800, 600, "yes", "yes")		
	}
	else if (Type == 3)
	{
		document.all.Old_Distributor_List.value = "";
		document.all.Distributor_List.value= "";
		document.all.FromDistributorSearch.value = 0;	
		document.all.Old_Operator_List.value = "";
		document.all.Operator_List.value= "";
		document.all.FromOperatorSearch.value = 0;
		document.all.FromBrokerSearch.value=1;
		document.all.Old_Broker_List.value = document.all.Broker_List.value;
		NewWindow("/Billbacks/search_Screens/PM_select_Brokers.cfm?Formname=MultiBB", "Brosearch", 800, 600, "yes", "yes")
	}
}

</SCRIPT>
</body>
</html>
