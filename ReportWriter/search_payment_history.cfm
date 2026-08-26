<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Payment History</title>
<STYLE>
	.sectionHead
	{
		font-weight:bold;
		font-size:15px;
		color:red;
		border-bottom:2px solid #0000CD;
	}
</STYLE>

<script language="JavaScript" src="/script/javascript/string_functions.js"></script>

<CF_MessageWindow>
<script language="javascript">
 function CheckValid()
	{
		var ErrorCount = 0;
 
			if(document.SearchForm.Start_date.value == '')
			{			
					ErrorCount++;		
				  queueMessage("You must enter a start date.", document.all.SP_Start_date);			
			}
			else
			{
				  clearQueue(document.all.SP_Start_date);
			}

			if(document.SearchForm.End_date.value == '')
			{			
					ErrorCount++;		
				  queueMessage("You must enter a end date.", document.all.SP_End_date);			
			}
			else
			{
				  clearQueue(document.all.SP_End_date);
			}

			if(ErrorCount == 0)
			{
					SearchForm.submit();	
			}
			else
			{
					showMessageWindow();
			}
	}

	function ChangeStatus()
	{
		if(document.SearchForm.Amount_Operator.value == '')
		{
			document.all.ClaimAmount.disabled = true; 
			document.all.ClaimAmount.style.backgroundColor='cccccc';
		}
		
		else
		{
			document.all.ClaimAmount.disabled = false; 
			document.all.ClaimAmount.style.backgroundColor='ffffff';
		}
	}
</script>
</head>

<CFPARAM NAME="FORM.ClaimAmount" 		DEFAULT="">
<CFPARAM NAME="FORM.Payment_Cycle" 	DEFAULT="">
<CFPARAM NAME="FORM.Accounting_Specialist" 	DEFAULT="">
<CFPARAM NAME="FORM.Distributor_List"  DEFAULT="">
<CFPARAM NAME="FORM.Date_Operator"  DEFAULT="">
<CFPARAM NAME="FORM.Amount_Operator"  DEFAULT="">
<CFPARAM NAME="GTE_Operators"  DEFAULT=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
<CFPARAM NAME="GTE_Operator_Symbols"  DEFAULT=" ,>=,=,<=">
<CFPARAM NAME="cnt"  DEFAULT="0">

<script language="javascript">
		function showDistSearchWindow() 
		{	
		document.SearchForm.target = "_self";
		document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
		NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=SearchForm", "SearchForm", 800, 400, "yes", "yes")
		}
</script>

<cfset AccountingSpecialistobj = CreateObject("component", "components.settings.AccountingSpecialists.AccountingSpecialists") />

<cfset AllAccountingSpecialists = AccountingSpecialistobj.get(Isdeleted=1)>

<cfset useLakebaseForgetPaymentCycle = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_cycle")>
<cfif useLakebaseForgetPaymentCycle>
	<cftry>
		<cfset getPaymentCycle = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_cycle", {
				"select" = "payment_cycle_id,payment_cycle"
			}), "payment_cycle_id,payment_cycle"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPaymentCycle = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPaymentCycle>
<cfquery name="getPaymentCycle" datasource="#application.datasource#">
	SELECT Payment_Cycle_ID, Payment_Cycle
	FROM Payment_Cycle
</cfquery>
</cfif>

		<CFIF FORM.Distributor_List NEQ "">
			<cfset useLakebaseForDist_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForDist_Search_Result>
	<cftry>
		<cfset Dist_Search_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#FORM.Distributor_List#",
				"deleted" = "eq.0",
				"active_code" = "eq.A",
				"order" = "name.asc",
				"select" = "bsa_foodservice_customers_id,name"
			}), "bsa_foodservice_customers_id,name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDist_Search_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDist_Search_Result>
<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT BSA_Foodservice_Customers_ID,Name 
				FROM BSA_Foodservice_Customers 
				WHERE
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#FORM.Distributor_List#'
					AND
					BSA_Foodservice_Customers.Deleted = 0
					AND
					BSA_Foodservice_Customers.Active_Code = 'A'
				ORDER BY Name
			</CFQUERY>
</cfif>
			<CFSET Selected_Distributor= Dist_Search_Result.Name>
		</CFIF>


<body onload="if(document.all.Amount_Operator.value==''){document.all.ClaimAmount.disabled = true; document.all.ClaimAmount.style.backgroundColor='cccccc';}">
<form name="SearchForm" action="search_payment_history_results.cfm" method="post">
<table border="0">
		<TR VALIGN="TOP">
				<TD COLSPAN="100%" CLASS="sectionHead"><strong>Search Criteria</strong></TD>
		</TR>
		<TR>
				<TD><B>Accounting Specialist:</B>&nbsp;&nbsp;<br />
							<SPAN ID="SP_Accounting_Specialist">
							<select name="Accounting_Specialist">
									<option value="">**ALL** Specialists</option>
								<cfoutput query="AllAccountingSpecialists">
									<option value="#User_ID#" <cfif User_ID eq Form.Accounting_Specialist> SELECTED</cfif>>#Name#</option>
								</cfoutput>
							</select>
							</SPAN>
					</TD>

					<TD><B>Payment Cycle:</B>&nbsp;&nbsp;<br />
							<SPAN ID="SP_Payment_cycle">
							<select name="Payment_Cycle">
									<option value="0">**ALL** Cycles</option>
								<cfoutput query="getPaymentCycle">
									<option value="#Payment_Cycle_ID#" <cfif Payment_Cycle_ID eq Form.Payment_Cycle> SELECTED</cfif>>#Payment_Cycle#</option>
								</cfoutput>
							</select>
							</SPAN>
					</TD>
					<cfoutput>
					<TD><B>Billback Create Start:</B>&nbsp;&nbsp;
							<CFPARAM NAME="Form.Start_date" DEFAULT="">
							<SPAN ID="SP_Start_date"></SPAN>
					<!--- Call the "EASYDATE" custom tag for the calendar --->
							<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#Form.Start_date#">							
					</TD>

					<TD><B>Billback Create End:</B>&nbsp;&nbsp;
							<CFPARAM NAME="Form.End_date" DEFAULT="">
							<SPAN ID="SP_End_date"></SPAN>
				<!--- Call the "EASYDATE" custom tag for the calendar --->
							<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#Form.End_date#">
							
					</TD>
				  </cfoutput>
		</TR>
			<cfoutput>
		<TR>
			<CFPARAM NAME="Selected_Distributor" DEFAULT="">
			<CFPARAM NAME="FORM.Distributor" DEFAULT="0">
			<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">

				<TD class="label">
				<B>Rebate Recipient:</B>&nbsp;<BR>	
								<INPUT NAME="Distributor_Name" ID="Distributor_Name" VALUE="#Selected_Distributor#" style="background-color: ##E9E9E9" READONLY>
									<B><a href="javascript: void(0);" onClick="javaScript: showDistSearchWindow();"><IMG border="0" src="/images/searchtool.gif" ></a></B>
									<B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="##" ONCLICK="Javascript:document.all.SearchForm.Distributor_List.value='';document.all.SearchForm.Distributor_Name.value=''">reset</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
							<INPUT TYPE="Hidden" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
				</TD>

				<TD>
					<B>Total Claim Amount:</B><BR>
						<table>
							<tr>
								<td>
									<cfset cnt = 0>				
									<SELECT OnChange="ChangeStatus();" NAME="Amount_Operator" ID="Amount_Operator" STYLE="WIDTH:45px">
										<CFSET cnt=0>
										<CFLOOP LIST="#GTE_Operator_Symbols#" INDEX="thisOperator">
											<CFSET cnt=cnt+1>
											<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Amount_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(GTE_Operator_Symbols,cnt))#</OPTION>
										</CFLOOP>
									</SELECT>
								</td>			
								<td>
										<INPUT name="ClaimAmount" id="ClaimAmount" type="text" align="left" size="15" maxlength="50" value="#Form.ClaimAmount#" ONKEYUP="clenseText(this, '0123456789.');">							
								</td>
							</tr>
						</table>
				</TD>

				<TD valign="bottom"><B>Report Type:</B>&nbsp;<BR>	
					<input type="radio" name="ReportType" value="1" checked>HTML
					<input type="radio" name="ReportType" value="2">Excel
				</TD>

				<TD valign="bottom">
					<B><FONT COLOR="red">[</FONT> <A HREF="##" ONCLICK="return CheckValid();">run report</A> <FONT COLOR="red">]</FONT></B>
				</TD>
		</TR>
		</cfoutput>
	</table>

</form>
</body>
</html>