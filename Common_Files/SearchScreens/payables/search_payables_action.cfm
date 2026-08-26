<CFPARAM NAME="FORM.payable_distributor_broker_name" DEFAULT="">
<CFPARAM NAME="FORM.billback_ref_number" DEFAULT="">
<CFPARAM NAME="FORM.payable_age_days" DEFAULT="">
	<cf_Number_of_Rows maxrows="10">
<CFSET brokerflag=0>
<CFSET brokerlist="">
<CFIF trim(FORM.payable_distributor_broker_name) NEQ "">
	<!--- get the id's of the brokers that have this string in their name --->
	<CFQUERY NAME="Get_Broker_Data" datasource="#application.datasource#">
	Select			Broker_Legcy_Shard as list
	From			BSA_Foodservice_Brokers
	Where			(
					Broker_Name LIKE '#FORM.payable_distributor_broker_name#%'	or
					Broker_Name LIKE '%#FORM.payable_distributor_broker_name#'	or
					Broker_Name LIKE '%#FORM.payable_distributor_broker_name#%'	or
					Broker_Name LIKE '#FORM.payable_distributor_broker_name#'
					)
					and
					deleted = 0
	</CFQUERY> 
	<CFSET Brokerflag=1>
	<CFIF Get_Broker_Data.recordcount GT 0>
		<CFSET Brokerlist=valuelist(Get_Broker_Data.list)>
	<CFELSE>
		<CFSET Brokerlist="99999999999999999">
	</CFIF>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the descriptions of the distributors in this payable										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Is there a request for distributors match? --->
<CFSET distributorflag=0>
<CFSET distributorlist="">
<CFIF trim(payable_distributor_name) NEQ "">
	<!--- get the id's of the distributor that have this string in their name --->
	<CFQUERY NAME="Get_distributor_Data" datasource="#application.datasource#">
	Select			BSA_Foodservice_Customers_ID as list
	From			BSA_Foodservice_Customers
	Where			(
					Name LIKE '#payable_distributor_name#%'	or
					Name LIKE '%#payable_distributor_name#'	or
					Name LIKE '%#payable_distributor_name#%'	or
					Name LIKE '#payable_distributor_name#'
					)
					and
					deleted = 0
	</CFQUERY>
	<CFSET distributorflag=1>
	<CFIF Get_distributor_Data.recordcount GT 0>
		<CFSET distributorlist=valuelist(Get_distributor_Data.list)>
	<CFELSE>
		<CFSET distributorlist="99999999999999999">
	</CFIF>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the descriptions of the operators in this contract										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Is there a request for operator match? --->
<CFSET Operatorflag=0>
<CFSET Operatorlist="">
<CFIF trim(FORM.payable_contract_operator_name) NEQ "">
	<!--- get the id's of the operators that have this string in their name --->
	<CFQUERY NAME="Get_Operator_Data" datasource="#application.datasource#">
	Select			BSA_Operator_ID as list
	From			BSA_Operator
	Where			(
					operator_name LIKE '#payable_contract_operator_name#%'	or
					operator_name LIKE '%#payable_contract_operator_name#'	or
					operator_name LIKE '%#payable_contract_operator_name#%'	or
					operator_name LIKE '#payable_contract_operator_name#'
					)
					and
					deleted = 0
	</CFQUERY>
	<CFSET Operatorflag=1>
	<CFIF Get_Operator_Data.recordcount GT 0>
		<CFSET Operatorlist=valuelist(Get_Operator_Data.list)>
	<CFELSE>
		<CFSET Operatorlist="99999999999999999">
	</CFIF>
</CFIF>


<CFQUERY NAME="payableSearchQuery" datasource="#application.datasource#">
	SELECT 
		Payables.*,
		BSA_Foodservice_Customers.*,
		Contract_Main.*
	FROM 
		Payables,
		BSA_Foodservice_Customers,
		Contract_Main
	WHERE
			Payables.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
			AND
			Payables.Contract_Main_ID = Contract_Main.Contract_Main_ID
			AND
			Payables.Deleted = 0
			<!--- Look for a match in the broker field --->
			<CFIF brokerflag GT 0>
					and
					(
					<cfset conj = "">
					<cfloop list="#brokerlist#" index="i" delimiters = ",">
						#conj# BSA_Foodservice_Customers.Std_Broker = #i#
						<cfset conj="or">
					</cfloop>
					)
			</CFIF>
			<!--- End of Look for broker --->

			<!--- Look for a match in the distributor field --->
			<CFIF distributorflag GT 0>
					and
					(
					<cfset conj = "">
					<cfloop list="#distributorlist#" index="i" delimiters = ",">
						#conj# Payables.Distributor_ID = #i#
						<cfset conj="or">
					</cfloop>
					)
			</CFIF>
			<!--- End of Look for distributor --->	

			<!--- Look for a match in the distributor field --->
			<CFIF operatorflag GT 0>
					and
					(
					<cfset conj = "">
					<cfloop list="#operatorlist#" index="i" delimiters = ",">
						#conj# Contract_Main.Operator_ID LIKE '%#i#%'
						<cfset conj="or">
					</cfloop>
					)
			</CFIF>
			<!--- End of Look for distributor --->				
			
			<CFIF len(form.billback_ref_number) GT 0>
				and
					(
						Payables.Payable_reference_number LIKE '#trim(form.billback_ref_number)#'
						or
						Payables.Payable_reference_number LIKE '%#trim(form.billback_ref_number)#'
						or
						Payables.Payable_reference_number LIKE '#trim(form.billback_ref_number)#%'
						or
						Payables.Payable_reference_number LIKE '%#trim(form.billback_ref_number)#%'
					)
			</CFIF>
			
			<CFSET spanSTARTdatevar = form.billback_creation_date_start>
			<CFSET spanENDdatevar = form.billback_creation_date_end>
			
			<CFIF len(spanSTARTdatevar) GT 0 AND len(spanENDdatevar) GT 0>
					and
						(
							
							<cfset spanSTARTdatevar = dateadd('d', -1, spanSTARTdatevar)>
							Payables.Date_Recorded > #createodbcdatetime(createdatetime(year(spanSTARTdatevar),month(spanSTARTdatevar),day(spanSTARTdatevar),23,59,59))#
							AND
							<cfset spanENDdatevar = dateadd('d', 1, spanENDdatevar)>
							Payables.Date_Recorded < #createodbcdatetime(createdatetime(year(spanENDdatevar),month(spanENDdatevar),day(spanENDdatevar),00,00,00))#
						)
			</CFIF>

			<CFSET spanSTARTdatevar = form.PAYMENT_DATE_END>
			<CFSET spanENDdatevar = form.PAYMENT_DATE_START>
			
			<CFIF len(spanSTARTdatevar) GT 0 AND len(spanENDdatevar) GT 0>
					and
						(
							<cfset spanSTARTdatevar = dateadd('d', -1, spanSTARTdatevar)>							
							Payables.Paid_Date > #createodbcdatetime(createdatetime(year(spanSTARTdatevar),month(spanSTARTdatevar),day(spanSTARTdatevar),23,59,59))#
							AND
							<cfset spanENDdatevar = dateadd('d', 1, spanENDdatevar)>
							Payables.Paid_Date < #createodbcdatetime(createdatetime(year(spanENDdatevar),month(spanENDdatevar),day(spanENDdatevar),00,00,00))#
						)
			</CFIF>

			<CFIF len(trim(FORM.payable_age_days)) GT 0>
				<CFIF isnumeric(FORM.payable_age_days)>
					and
						(
							
							DATEDIFF(d, Payables.Billback_Date, #createodbcdatetime(NOW())#) >= '#FORM.payable_age_days#'
						)
				</CFIF>
			</CFIF>
			
			
			<CFIF len(trim(FORM.PAYABLE_NUMBER)) GT 0>
				AND
				Payables.Billback_Num = '#trim(FORM.PAYABLE_NUMBER)#'
			</CFIF>
			<cfif FORM.payable_status NEQ 6>
				AND
				Payables.Payable_Status_Type_IDX = '#FORM.payable_status#'
			</cfif>

	ORDER BY BSA_Foodservice_Customers.Name asc
</CFQUERY> 

<cfif payableSearchQuery.RecordCount LTE form.STARTROW><cfset form.STARTROW = 1></cfif>

<SPAN CLASS="title2">Supplied Payable Search Criteria:</SPAN>
<HR COLOR="Orange">


<!--- <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the description of the contractstatus codes												 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfswitch expression = #contract_status#>
  <cfcase value = "0">
	  <CFSET status_description="All Contract Status">
  </cfcase>
  <cfcase value = "1">
	  <CFSET status_description="Work in Progress">
  </cfcase>
  <cfcase value = "2">
	  <CFSET status_description="Preactive Contracts">
  </cfcase>
  <cfcase value = "3">
	  <CFSET status_description="Active Contracts">
  </cfcase>
  <cfcase value = "4">
	  <CFSET status_description="Archived/Expired">
  </cfcase>
  <cfcase value = "5">
	  <CFSET status_description="Expiring in 8 weeks or less">
  </cfcase>
</cfswitch>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the descriptions of the types of contracts retrieved										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfswitch expression = #TEMPLATE#>
  <cfcase value = "0">
	  <CFSET contract_type="<FONT COLOR=""Gray"">Contracts Only</FONT>">
  </cfcase>
  <cfcase value = "1">
	  <CFSET contract_type="<FONT COLOR=""Red""><B>Templates only</B></FONT>">
  </cfcase>
  <cfcase value = "2">
	  <CFSET contract_type="<FONT COLOR=""Red""><B>Contracts & Templates</B></FONT>">
  </cfcase>
</cfswitch>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get all of the UOM descriptions																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF uom NEQ "All">
	<cfset useLakebaseForGet_UOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGet_UOM>
	<cftry>
		<cfset Get_UOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {
				"unit_of_measure_id" = "eq.#uom#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_UOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_UOM>
<CFQUERY NAME="Get_UOM" datasource="#application.datasource#">
	Select	*
	From	Units_of_Measure
	Where	Unit_of_Measure_ID	=	#uom#
	</CFQUERY>
</cfif>
<CFELSE>
	<CFSET Get_UOM.Unit_of_Measure_Desc="Any U.O.M.">	
</CFIF>
 --->





<CFOUTPUT>
	<TABLE border="0" cellspacing="0" CELLPADDING="1" WIDTH="800">
		<TR>
			<TD NOWRAP><B>Payable Number:</B></TD>
			<TD NOWRAP><CFIF payable_number EQ ""><FONT COLOR="Gray">Any Payable Number</FONT><CFELSE><FONT COLOR="Red"><B>#payable_number#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Billback Ref. Number:</B></TD>
			<TD NOWRAP><CFIF billback_ref_number EQ ""><FONT COLOR="Gray">Any Reference Number</FONT><CFELSE><FONT COLOR="Red"><B>#billback_ref_number#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Days Old:</B></TD>
			<TD NOWRAP><CFIF payable_age_days EQ ""><FONT COLOR="Gray">Any Age</FONT><CFELSE><FONT COLOR="Red"><B>#payable_age_days#</B></FONT></CFIF></TD>
		</TR>
		<TR>
			<TD NOWRAP><B>Broker:</B></TD>
			<TD NOWRAP><CFIF payable_distributor_broker_name EQ ""><FONT COLOR="Gray">Any Broker</FONT><CFELSE><FONT COLOR="Red"><B>#payable_distributor_broker_name#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>#application.returned_customer_setting.operator_label_singular#:</B></TD>
			<TD NOWRAP><CFIF payable_contract_operator_name EQ ""><FONT COLOR="Gray">All #application.returned_customer_setting.operator_label_plural#></FONT><CFELSE><FONT COLOR="Red"><B>#payable_contract_operator_name#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>#application.returned_customer_setting.distributor_label_singular#:</B></TD>
			<TD NOWRAP><CFIF payable_distributor_name EQ ""><FONT COLOR="Gray">Any #application.returned_customer_setting.distributor_label_singular#</FONT><CFELSE><FONT COLOR="Red"><B>#payable_distributor_name#</B></FONT></CFIF></TD>
		</TR>
		<TR>
			<TD NOWRAP><B>Billback Date Range</B></TD>
			<TD NOWRAP><CFIF len(billback_creation_date_start) EQ 0 OR len(billback_creation_date_end) EQ 0><FONT COLOR="Gray">Any Date Range</FONT><CFELSE><FONT COLOR="Red"><B>#billback_creation_date_start# - #billback_creation_date_end#<B></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Payament Date Range</B></TD>
			<TD NOWRAP><CFIF len(payment_date_start) EQ 0 OR len(payment_date_end) EQ 0><FONT COLOR="Gray">Any Date Range</FONT><CFELSE><FONT COLOR="Red"><B>#payment_date_start# - #payment_date_end#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP>&nbsp;</TD>
			<TD NOWRAP>&nbsp;</TD>
		</TR>

		<TR>
			<TD COLSPAN="8"><BR></TD>
		</TR>

	</TABLE>

	<TABLE border="0" cellspacing="0" CELLPADDING="1" WIDTH="800">
				<TR>
					<TD><B>Status codes:</B></TD>
					<TD NOWRAP><IMG SRC="/Images/expiring.gif" ALIGN="middle"></TD><TD>Aging</TD>
					<TD NOWRAP><IMG SRC="/Images/active.gif" ALIGN="middle"></TD><td>Approved</td>
					<TD NOWRAP><IMG SRC="/Images/preactive.gif" ALIGN="middle"></td><td>Pre-Approved</TD>
					<TD NOWRAP><IMG SRC="/Images/wip.gif" ALIGN="middle"></td><td>Work in progress</TD>
					<TD NOWRAP><IMG SRC="/Images/expired.gif" ALIGN="middle"></td><td>Paid Billback</TD>
				</TR>
<!--- 
				<TR>
					<TD><B>Status codes:</B></TD>
					<TD NOWRAP><IMG SRC="/Images/expiring.gif" ALIGN="middle"> Aging</TD>
					<TD NOWRAP><IMG SRC="/Images/active.gif" ALIGN="middle"> Approved</TD>
					<TD NOWRAP><IMG SRC="/Images/preactive.gif" ALIGN="middle"> Pre-Approved</TD>
					<TD NOWRAP><IMG SRC="/Images/wip.gif" ALIGN="middle"> Work in progress</TD>
					<TD NOWRAP><IMG SRC="/Images/expired.gif" ALIGN="middle">Payed Billback</TD>
				</TR>

 --->		
		</table>
	
</CFOUTPUT>



<style>
	body, table, td
		{font-family: Arial; font-size: 12px;}
	.data
		{font-size: 12px; font-weight: bold}
	select, TEXTAREA
		{width:	200px;font-size: 10px;}
	TEXTAREA
		{width:	400px;font-size: 10px;}

	TABLE.Maintable TD 
		{border-bottom:sol    93BEE2 1 x; font-size : 10px;}
	
	Maintable
		{cellspacing: 0;}
	
	header 
		{font-size: 12px;}
</style>

<SPAN CLASS="title2"><CFOUTPUT>There are<CFIF payableSearchQuery.Recordcount EQ 0> no <CFELSE> #payableSearchQuery.Recordcount# </CFIF>payables that match the above criteria</CFOUTPUT></SPAN>

<TABLE CELLPADDING="4" CELLSPACING="0" ID="payablesSearchResults" CLASS="maintable" WIDTH="800">
	<TR VALIGN="bottom" BGCOLOR="#FFCE84">
		<td>&nbsp;</td>
		<TD ID="header"><B>Payable #</B></TD>
		<TD ID="header"><B>Days<BR>Old</B></TD>
		<TD ID="header"><B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput><BR>Name</B></TD>
		<TD ID="header"><B>Billback<BR>Amount</B></TD>
		<TD ID="header"><B>Billback<BR>Ref #</B></TD>
		<TD ID="header"><B>BillBack<BR>Date</B></TD>
		<TD ID="header"><B>Contract<BR>Title</B></TD>
	</TR>

	

	<CFOUTPUT QUERY="payableSearchQuery" startrow="#StartRow#" maxrows="#MaxRows#">

<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
		<cf_cryp type="en" string="#payableSearchQuery.Payable_ID#" key="#caller.key#">
		<td><cfset psi_status_value = payableSearchQuery.Payable_Status_Type_IDX><CFINCLUDE TEMPLATE="/common_files/payables2/payable_status_icon.cfm"></td>
		<TD CLASS="data" NOWRAP><A HREF="payable_edit_menu.cfm?PID=#cryp.value#" STYLE="cursor: help;" ONMOUSEOVER="menuID=1;URLstring='?PID=#cryp.value#';" ONMOUSEOUT="menuID=0;">#payableSearchQuery.Billback_Num#&nbsp;</A></TD>
		<TD ALIGN="center"><CFIF len(trim(payableSearchQuery.Paid_Date)) GT 0>Paid<cfelse><cfif DATEDIFF('d', payableSearchQuery.Billback_Date, NOW()) NEQ 0>#DATEDIFF('d', payableSearchQuery.Billback_Date, NOW())#<cfelse>1</cfif></CFIF>&nbsp;</TD>
		<TD>#payableSearchQuery.Name#&nbsp;</TD>
		<TD>$#trim(numberformat(payableSearchQuery.Billback_Amt, '___________^.00'))#&nbsp;</TD>
		<TD>#payableSearchQuery.Payable_reference_number#&nbsp;</TD>
		<TD>#dateformat(payableSearchQuery.Billback_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD>#payableSearchQuery.Contract_Title#&nbsp;</TD>

	</TR>
	</CFOUTPUT>
</TABLE>

<HR COLOR="Orange" SIZE="2">
<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
<cf_Next_Previous_FOR_GENERALSEARCHTOOL
	maxpages		=	"25"
	query			=	"payableSearchQuery"										
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">">
</DIV>
<HR COLOR="Orange" SIZE="2">
