<!----
	Filename:	C:\Work\Code\base\AwayX\DEDUCTIONS\settings\resend_billback_interface.cfm
	Created:	1/5/2012
 	Developer:	drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		D29824:New Settings.. 
	what:
		used to resend billbacks in 700 interface
	Cons:
		Not using CFC to pull BILLBACKS info as taught those queries wont use any where.
---->
<cfparam name="url.displaywindow" default="0">
<cfif url.displaywindow EQ 0>
	 <script>
	 	NewWindow("/billbacks/scorecard/billback_search.cfm?Type_search=impBillBacks", "BillbackSearchTool", 1000, 600, "yes", "yes");
	 </script>
</cfif>
	 <script>
	 	function importbillbacks(bb_id){
		document.resend_billbacks.billbackid.value = bb_id;
        document.resend_billbacks.submit();
        return false;
		}
		function selectAll(thisobj)
		{
			var bCheck = thisobj.checked;
			var chObjs = document.all.SelectedBB;
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
		function reopenserach(){
			NewWindow("/billbacks/scorecard/billback_search.cfm?Type_search=impBillBacks", "BillbackSearchTool", 1000, 600, "yes", "yes");
		}
	 </script>
	 

<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" bgcolor="#A7CAF2" WIDTH="100%" HEIGHT="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;"><SPAN STYLE="color:white; font-size:14px; font-weight: bold; padding-left:5px;">Resend Billback in Payment Interface</SPAN></TD>
</TR>
</TABLE>

<br>
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0">
<TR>
	<TD>
		<CF_smallLink 
					title = "back" 
					url = "deduction_external_settings.cfm"
					parameters = ""
					>
	</TD>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"search billbacks"
			button_action	=	"reopenserach();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"execute"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
</TR>
</TABLE>
<br>
	 
<CFIF application.returned_customer_setting.Customer_Keyword EQ "Mccain">
	<cfset  deviation_heading  = "VAR" />
	<cfset 	deviation_desc  = "Claim Variance" />
<CFELSE>
	<cfset  deviation_heading  =  "DEV" />
	<cfset 	deviation_desc  = "Deviation" />
</CFIF>

	 <form name="resend_billbacks" action="resend_billback_interface.cfm?displaywindow=1" method="post">
	 	<input type="hidden" name="billbackid" value="">
	 </form>
	 <cfif isdefined("form.billbackid")>


<cfset billbacks = #replace(form.billbackid, "_", "-", "ALL")#>

<cfquery name="GetBillBacks" datasource="#application.datasource#">
SELECT Billback_ID,BB_Title, BB_Closing_Method, BB_Code, BB_Date, BB_Reference, 
Billback_Payee_Type_ID, BB_Start_Date, BB_End_Date, Abbreviation
FROM 	Billback
Left join Billback_Closing_Methods
on Billback_Closing_Methods.iBillback_Closing_Method_ID = Billback.BB_Closing_Method
WHERE Billback.Billback_ID IN (<cfqueryparam value="#billbacks#" cfsqltype="cf_sql_varchar" list="yes">)
</cfquery>
<form name="resendBillbacks" action="resend_billback_interface.cfm?displaywindow=1" method="post" id="resendBillbacks">
<table width="90%" align="center">
	<tr style="background-color: orange">
		<td valign="top"><input type="checkbox" name="allbox" onclick="javaScript: selectAll(this);" CHECKED></td>
		<td valign="top"><b>Type<br>Dev</b></td>
		<td valign="top"><b>Payable #</b></td>
		<td valign="top"><b>Payee</b></td>
		<td valign="top"><b>Title</b></td>
		<td valign="top"><b>Start Date</b></td>
		<td valign="top"><b>End Date</b></td>
	</tr>

<cfoutput query="GetBillBacks" >
<cfset Payee_Name = "None">
		<!--- Get payee information for this billback --->
		<cfswitch expression="#Billback_Payee_Type_ID#">
			<!--- Distributor payee ---->
			<cfcase value="1">
				<cfquery name="GetPayee" datasource="#application.datasource#">
				SELECT ISNULL(BSA_Foodservice_Customers.Name,VM.Vendor_Name) as Payee_Name
				FROM Billback_Distributor
				LEFT JOIN BSA_Foodservice_Customers
					ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
				LEFT JOIN Vendor_Master VM ON ---added VM join for Auto Pay w/multiple distributors
					VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
				WHERE	Billback_Distributor.Billback_ID = '#Billback_ID#'
					AND Billback_Distributor.Deleted = 0
				</cfquery>
				<cfset Payee_Name = GetPayee.Payee_Name>
			</cfcase>
			<!--- Operator payee --->
			<cfcase value="2">
				<cfquery name="GetPayee" datasource="#application.datasource#">
				SELECT BSA_Operator.Operator_Name as Payee_Name
				FROM BSA_Operator
					INNER JOIN Billback_Operator
					ON Billback_Operator.Billback_ID = '#Billback_ID#'
					AND Billback_Operator.Deleted = 0
					AND BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID
				</cfquery>
				<cfset Payee_Name = GetPayee.Payee_Name>
			</cfcase>
			<!--- Broker payee --->
			<cfcase value="3">
				<cfquery name="GetPayee" datasource="#application.datasource#">
				SELECT BSA_Foodservice_Brokers.Broker_Name as Payee_Name
				FROM BSA_Foodservice_Brokers
					INNER JOIN Billback_Broker
					ON Billback_Broker.Billback_ID = '#Billback_ID#'
					AND Billback_Broker.Deleted = 0
					AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID
				</cfquery>
				<cfset Payee_Name = GetPayee.Payee_Name>
			</cfcase>
			<!--- In case there is another payee --->
			<cfdefaultcase>
				<cfset Payee_Name = "NA">
			</cfdefaultcase>
		</cfswitch>

	<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<td><input type="Checkbox" name="SelectedBB" VALUE="#Billback_ID#" CHECKED ></td>
		<td>#Abbreviation#<br>#deviation_heading#</td>
		<td>#BB_Code#</td>
		<td>#Payee_Name#</td>
		<td>#BB_Title#</td>
		<td>#dateformat(BB_Start_Date, "mm/dd/yyyy")#</td>
		<td>#dateformat(BB_End_Date, "mm/dd/yyyy")#</td>
	</tr>
</cfoutput>
	<tr><td colspan=100><br></td></tr>
	<tr>
		<td colspan= 100 align="center"> 
						<CF_button
							button_name		=	""
							button_caption	=	"Resend Billbacks"
							button_action	=	"resendBB()"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>	
		</td>
	</tr>
</table>
<input type="hidden" name="bbid" value="">
</form>
<cfinclude template="/common_files/jQuery.cfm">
<script>
function resendBB()
  {
  		var bb_id = "";
  	$("input:checkbox[name=SelectedBB]:checked").each(function() 
	{ 
	   
		   bb_id = bb_id.concat($(this).val());
		   bb_id = bb_id.concat(',');
	}); 
		document.resendBillbacks.bbid.value = bb_id;
	    document.resendBillbacks.submit();
  }
</script>

</cfif>
<cfif isdefined("form.bbid")>
   <cfset useLakebaseForResetPaymentRequest = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
   <cfif useLakebaseForResetPaymentRequest>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{ "billback_id" = "in.(#form.bbid#)" },
			{ "bb_payment_request_sent" = 0, "bb_payment_request_sent_on" = javaCast("null","") }
		)>
		<cfcatch type="any">
			<cfset useLakebaseForResetPaymentRequest = false>
		</cfcatch>
	</cftry>
   </cfif>
   <cfif NOT useLakebaseForResetPaymentRequest>
   <cfquery name="GetPayee" datasource="#application.datasource#">
	UPDATE 	Billback 
	SET 	BB_Payment_Request_Sent = 0, 
			BB_Payment_Request_Sent_On = NULL 
	WHERE 	Billback_ID IN (<cfqueryparam value="#form.bbid#" cfsqltype="cf_sql_varchar" list="yes">)
	</cfquery>
   </cfif>
<cfquery name="GetBillBacks" datasource="#application.datasource#">
SELECT Billback_ID,BB_Title, BB_Closing_Method, BB_Code, BB_Date, BB_Reference, 
Billback_Payee_Type_ID, BB_Start_Date, BB_End_Date, Abbreviation
FROM 	Billback
Left join Billback_Closing_Methods
on Billback_Closing_Methods.iBillback_Closing_Method_ID = Billback.BB_Closing_Method
WHERE Billback.Billback_ID IN (<cfqueryparam value="#form.bbid#" cfsqltype="cf_sql_varchar" list="yes">)
</cfquery>
<table width="90%" align="center">
	<tr>
		<td colspan="100" style="font-weight:bold;color:green;font-size:12px;">Successfully Resend Following Billbacks !!</td>
	</tr>
	<tr style="background-color: orange">
		<td valign="top"><b>Type<br>Dev</b></td>
		<td valign="top"><b>Payable #</b></td>
		<td valign="top"><b>Title</b></td>
	</tr>
<cfoutput query="GetBillBacks">
	<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<td>#Abbreviation#<br>#deviation_heading#</td>
		<td>#BB_Code#</td>
		<td>#BB_Title#</td>
	</tr>
</cfoutput>
</table>
</cfif>