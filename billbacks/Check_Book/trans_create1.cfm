<cfset application.returned_customer_setting.PayBy_awayX = 0 /><!--- D8914 Payby_awayX  Get rid of the switch  --->

<Cfif isdefined("url.new_bb_check")>
	<cfset form.new_bb_check = url.new_bb_check>
</CFIF>
<cfif isdefined("url.billback_ID")>
	<cfset form.billback_id = url.billback_ID>
</cfif>
<cfif isdefined("url.payeetype")>
	<cfset form.payeetype = url.payeetype>
</cfif>

<!--- <cfheader name="Cache-Control" value="no-store"> --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
</HEAD>

<CFIF isdefined("form.new_bb_check")>
	
	<!--- <CFLOCATION URL="Trans_Save_New.cfm?BBID=#FORM.Billback_ID#" ADDTOKEN="No">  --->
	
<CFELSE>
	<CFSET URL.PageTitle="#application.CompanyName#: Create Transaction">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="PageTitle" DEFAULT="">

<!---BJF Had to remove setting title since it contained redirect logic for users who can't access settings --->
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" BGCOLOR="Navy" BACKGROUND="/Images/gradient.jpg" WIDTH="100%" HEIGHT="25"><SPAN STYLE="color:white; font-size:14px; font-weight: bold;"><CFOUTPUT>#ucase(PageTitle)#</CFOUTPUT></SPAN></TD>
</TR>
</TABLE>
<BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</CFIF> 
<BR><BR>

<CFPARAM NAME="URL.State" DEFAULT="0">
<CFPARAM NAME="URL.RID" DEFAULT="0">
<CFPARAM NAME="FORM.Billback_id" DEFAULT="0">
<CFPARAM NAME="FORM.new_bb_check" DEFAULT="0">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the data for the passed record --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY name = "Balance_Check" datasource="#application.datasource#">
	select balance from ledger_table where ledger_ID = (select max(ledger_id) from ledger_table)
</CFQUERY>




<CFIF form.new_bb_check EQ 1>


<cfquery name="Get_Payee_Info" datasource="#application.datasource#">
    SELECT  DISTINCT 
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
    LEFT JOIN Billback_Unidentified_Payee
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
    WHERE
    bb.Deleted = 0    
    AND
	<CFIF IsDefined("FORM.Pay_Multi_Billbacks_ID")>
		bb.Billback_ID IN (#LISTQUALIFY(form.BillBack_ID,"'",",","All")#)
	<CFELSE>
		bb.Billback_ID = '#form.BillBack_ID#'
	</CFIF>    
   </cfquery>
   
	<CFDUMP VAR="#Get_Payee_Info#">
	
	
	<CFIF Not IsDefined("FORM.Pay_Multi_Billbacks_ID")>
		<cfset useLakebaseForGet_bb_code = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGet_bb_code>
	<cftry>
		<cfset Get_bb_code = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#form.billback_ID#",
				"select" = "bb_reference"
			}), "bb_reference"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_bb_code = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_bb_code>
<CFQUERY NAME="Get_bb_code" DATASOURCE="#application.datasource#">
			SELECT BB_Reference FROM billback WHERE billback_id='#form.billback_ID#'
		</CFQUERY>
</cfif>
	
		<CFQUERY name = "Get_desc_amt" datasource="#application.datasource#">
			SELECT a.Paid_amount amount,b.BB_Start_Date st_dt,b.BB_End_Date end_dt 
			FROM billback b,BB_approved a 
			WHERE a.billback_id = b.billback_id AND b.billback_id = '#form.billback_id#'
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="Get_desc_amt" DATASOURCE="#Application.Datasource#">
			SELECT 	Total_Paid_Amount Amount 
			
			FROM 	Pay_Multi_Billbacks
			
			WHERE 	Pay_Multi_Billbacks_ID = '#FORM.Pay_Multi_Billbacks_ID#' AND
					Deleted = 0
		</CFQUERY>
	</CFIF>

	<CFSET formattedDollar = Get_Desc_amt.Amount*100>
	<CFSET formattedDollar = Round(formattedDollar)>
	<CFSET formattedDollar = formattedDollar / 100>
<CFOUTPUT>---formattedDollar #formattedDollar#---</CFOUTPUT>

<CFIF Not IsDefined("FORM.Pay_Multi_Billbacks_ID")>  
		<CFLOCATION URL="Trans_Save_New.cfm?BBID=#FORM.Billback_ID#&BB_Reference=#REPLACE(get_bb_code.BB_Reference,"##","")#&Name=#replace("get_payee_info.payee_name", "##", "")#&city=#get_payee_info.city#&state=#get_payee_info.state_code#&St_Date=#get_desc_amt.st_dt#&End_Dt=#get_desc_amt.end_dt#&Amount=#formattedDollar#" ADDTOKEN="No">
<CFELSE>
	<CFLOCATION URL="Trans_Save_New.cfm?Pay_Multi_Billbacks_ID=#FORM.Pay_Multi_Billbacks_ID#&Name=#replace("get_payee_info.payee_name", "##", "")#&city=#get_payee_info.city#&state=#get_payee_info.state_code#&Amount=#formattedDollar#" ADDTOKEN="No">
</CFIF>

<script type = "text/javascript"> 
	var org_amount = <cfoutput>#abs(numberformat(formattedDollar,"_.__"))#</cfoutput>
	var ck_balance = <CFOUTPUT>#numberformat(Balance_Check.balance,"_.__")#</CFOUTPUT>

	function validate()
	{	
		x = document.trans_create_form
		//alert(x);
		//alert((x.Amount.value != org_amount))
		if (x.Amount.value >= ck_balance)
		{//alert(x.Amount.value)
		//alert(ck_balance)
			alert("You Don't have enough fund in the Account")
			window.parent.tabClick('summary');
			return false
		}
			 
		/*if (x.Amount.value != org_amount)
		{
			comfirm_amt = confirm("The Amount You entered is not equal to the approved Amount. Press OK if this is the Amount to be paid")
			if (comfirm_amt == true)
			{
				change_reason = "";
				while((change_reason == null) || (change_reason.length == 0))
				{
					change_reason = window.prompt("Enter the Reason :", "")
				}
				x.amt_deviation_reason.value = change_reason;
				return true;
			}
			else
			{
				return false;
			}

		}	*/
		x.submit();
	}		
	</script>
	
</CFIF>

<cfset useLakebaseForcheck_no_list = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ledger_table")>
<cfif useLakebaseForcheck_no_list>
	<cftry>
		<cfset check_no_list = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ledger_table", {
				"check_number" = "not.is.null",
				"select" = "check_number"
			}), "check_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheck_no_list = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheck_no_list>
<CFQUERY name = "check_no_list" datasource="#application.datasource#">
	select check_number from ledger_table where check_number is not null
</CFQUERY>
</cfif>

 <CFOUTPUT>
<script type = "text/javascript">
var check_no = new Array(#check_no_list.recordcount#)
</script>
</CFOUTPUT>
<CFOUTPUT query = "check_no_list">
<script type = "text/javascript">	
	check_no[#currentrow#-1]="#check_number#"
</script>
</CFOUTPUT>
 

<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></SCRIPT>
<script type = "text/javascript">
	function Change_Check_Wire_TR(thisObj)
	{
		var chColl = document.all[thisObj.name];
		if(chColl.length)
		{
			var trObj = document.all.Check_Wire_TR;			
			if(chColl[0].checked)
			{
				trObj.style.display = "";
			}
			else
			{
				trObj.style.display = "none";
			}
		}
	}
	
	function validate1()
	{	
		y = document.trans_create_form 
		mlen=y.Memo_Field.value
		len = y.Amount.value
		var ck_balance1 = <CFOUTPUT>#numberformat(Balance_Check.balance,"_.__")#</CFOUTPUT>

		if(mlen == "")
		{
			alert("Memo Field cannot be empty")
			y.Memo_Field.focus()			
			return false
		} 
		
					
		if (len == "" || len <= 0)
		{
			alert("Amount Cannot be empty or cannot be less than or equal to zero")
			y.Amount.focus()			
			return false
		}
		if (y.Amount.value >= ck_balance1 && y.trans_type[0].checked)
		{
			alert("You Don't have enough fund in the Account")
			window.location.href = "index.cfm";
			return false
		}
		y.submit();

	}
		
</script>

<script type = "text/javascript">
	function validate_check()
	{
	
		var count = <cfoutput>#check_no_list.recordcount#</cfoutput>
		y = document.trans_create_form 
		
		for(i=0;i<count;i++)
		{	
			if (y.Check_Number.value == check_no[i])
			{
				
				alert("Check No " + check_no[i] + " already exist")
				y.Check_Number.focus()
				return false
			}
			
		}
		if(y.Check_Issue_Date.value != "")
		{
			if(y.Check_Number.value == "")
			{
				alert("Enter Check No before entering Issue Date")
				y.Check_Number.focus()
				return false
			}
		}
		y.submit();
	}

	function validate2()
	{
		y = document.trans_create_form 
		
		
		if (y.Check_Clearance_Date.value != "")
		{	
			if(y.Check_Issue_Date.value == "")
			{
				alert("No Check Issue Date")
				y.Check_Issue_Date.focus()
				return false
			}
			
			if(checkDate(y.Check_Issue_Date.value, y.Check_Clearance_Date.value) <= 0)			
			{
				y.submit();
				return true
			}
			else
			{
				alert("Check Clearance Date cannot be less than Check Issue Date")
				y.Check_Clearance_Date.focus()
				return false
			}
		}		
		y.submit();

	}
	function justsubmit()
	{	
		document.trans_create_form.submit();
	}	 
		
</script>

<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
 
 
 
<SCRIPT>

function checkDate(dateStr1,dateStr2)
{
 var dateSplit; 
 var retVal = null;
 dateSplit = dateStr1.split("/"); 
 if(dateSplit.length > 2)
 {
  var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
  dateSplit = dateStr2.split("/");
  if(dateSplit.length > 2)
  {
   var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
   retVal = days_between(date1, date2, true);
  }
 }
 return retVal;
}
</SCRIPT>


<cfset useLakebaseForGet_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ledger_table")>
<cfif useLakebaseForGet_Data>
	<cftry>
		<cfset Get_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ledger_table", {
				"ledger_id" = "eq.#URL.RID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Data>
<CFQUERY NAME="Get_Data" DATASOURCE="#application.datasource#">
	Select		*
	From		Ledger_Table
	Where		Ledger_ID	=	#URL.RID#
</CFQUERY>
</cfif>




<!--- If there is a ledger_id passed this means that goes into edit mode not create mode --->
<CFSET isdisabled = "">
<CFIF URL.State eq 1>
	<CFSET state=" disabled">
	<CFSET formaction="trans_save_old.cfm">
	<DIV STYLE="border-bottom: 1px solid red; font-weight: bold;">Transaction <CFOUTPUT>#URL.RID#</CFOUTPUT></DIV>
<CFELSE>
	<CFSET state="">
	<CFSET formaction="trans_save_new.cfm">
	<DIV STYLE="border-bottom: 1px solid red; font-weight: bold;">New Transaction</DIV>
</CFIF>

<FORM NAME="trans_create_form" ACTION="<CFOUTPUT>#formaction#</CFOUTPUT>" METHOD="post" 
<CFIF application.returned_customer_setting.PayBy_awayX EQ 0>
	<CFSET callFunction = "justsubmit()">
<CFELSEIF form.new_bb_check EQ 1 AND application.returned_customer_setting.PayBy_awayX EQ 1> 	
	 <CFSET callFunction = "validate()">
<CFelseIF form.new_bb_check NEQ 1 and URL.State NEQ 1> 
	<CFSET callFunction = "validate1()">
	<!--- ONSUBMIT = "return validate1()"  --->
<CFELSEIF "#get_data.Check_Number#" EQ ""> 
	<CFSET callFunction = "validate_check()">
	<!--- ONSUBMIT = "return validate_check()" --->
<CFELSE>
	<CFSET callFunction = "validate2()">
	<!--- ONSUBMIT = "return validate2()" --->
</CFIF>>

<!---
<CFIF form.new_bb_check EQ 1> 
	ONSUBMIT="return validate()"
 --->

<CFOUTPUT>
<INPUT TYPE="hidden" NAME="User_ID" VALUE="#createuuid()#">
<INPUT TYPE="hidden" NAME="URL.RID" VALUE="#URL.RID#">
<INPUT type="hidden" NAME="new_bb_check" VALUE="#form.new_bb_check#">
<INPUT TYPE = "hidden" NAME = "amt_deviation_reason">
<INPUT TYPE = "hidden" NAME = "Billback_ID" VALUE = "#form.Billback_ID#">

</CFOUTPUT>
<TABLE >

<TR>
	<TD ALIGN="Right"><B>Transaction Date:</B></TD>
	<TD ROWSPAN="100%" STYLE="border-right:Solid 2px blue;">&nbsp;</TD>
	<TD>
		<CFIF Get_Data.Date_Time eq "">
			<CFOUTPUT>#dateformat(now(), 'm/d/yyyy')#</CFOUTPUT>
		<CFELSE>
			<CFOUTPUT>#dateformat(Get_Data.Date_Time, 'm/d/yyyy')#</CFOUTPUT>
		</CFIF>
	</TD>
</TR>

<CFIF form.new_bb_check EQ 1>
<TR>
	<TD ALIGN="Right"><B>Memo Field:</B></TD>
	<TD><CFOUTPUT><TEXTAREA COLS="70" ROWS="6" NAME="Memo_Field">Billback (Billback Number:#get_bb_code.BB_Reference#) to be paid to #trim(get_payee_info.payee_name)#, #trim(get_payee_info.city)#, #trim(get_payee_info.state_code)# for the period #dateformat(get_desc_amt.st_dt,"m/d/yyyy")# to #dateformat(get_desc_amt.end_dt,"m/d/yyy")# </TEXTAREA></CFOUTPUT> </TD>
</TR>
<TR>
	<TD ALIGN="Right"><B>Transaction Type:</B></TD>
	
	<TD>
		<INPUT TYPE="radio" NAME="trans_type" VALUE="check" CHECKED>Debit
		<INPUT TYPE="radio" NAME="trans_type" VALUE="deposit" DISABLED>Credit
	</TD>
</TR>
<INPUT TYPE="hidden" NAME="Currency" VALUE="US">
<TR>
	<TD ALIGN="Right"><B>Amount:</B></TD><CFOUTPUT>
	<INPUT TYPE="hidden" NAME="App_Amount" VALUE="#Get_Desc_amt.Amount#"> 
	<CFSET formattedDollar = Get_Desc_amt.Amount*100>
	<CFSET formattedDollar = Round(formattedDollar)>
	<CFSET formattedDollar = formattedDollar / 100>
	<TD><INPUT STYLE="text-align:right;" TYPE="text" NAME="Amount" VALUE="#(NumberFormat(formattedDollar, "_.__"))#" #state# <!--- ONKEYUP="clenseText(this,'0123456789.')" ---> READONLY></TD>
	</CFOUTPUT>
</TR>
<CFELSE>
<TR>
	<TD ALIGN="Right"><B>Memo Field:</B></TD>
	<TD><CFOUTPUT><TEXTAREA COLS="60" ROWS="4" NAME="Memo_Field" #state#>#Get_Data.Memo_Field#</TEXTAREA></CFOUTPUT></TD>
</TR>
<TR>
	<TD ALIGN="Right"><B>Transaction Type:</B> </TD>
	
	<TD>
		<CFIF get_data.Amount LT 0>
			<CFSET AMT_CHECKED_yes="CHECKED">
			<CFSET AMT_CHECKED_no="">
		<CFELSE>
			<CFSET AMT_CHECKED_yes="">
			<CFSET AMT_CHECKED_no="CHECKED">
		</CFIF>		

		<CFOUTPUT>
		<INPUT TYPE="radio" NAME="trans_type" VALUE="Check" #AMT_CHECKED_yes# #state# onClick="javaScript: Change_Check_Wire_TR(this);">Debit
		<INPUT TYPE="radio" NAME="trans_type" VALUE="deposit" #AMT_CHECKED_no# #state# onClick="javaScript: Change_Check_Wire_TR(this);">Credit
		</CFOUTPUT>
	</TD>
	
</TR>
<TR>
	<TD ALIGN="Right"><B>Currency:</B></TD>
	<TD><!--- <SELECT NAME="Currency">
		<OPTION VALUE="US" selected>US Dollars
		<OPTION VALUE="BP">British Pound
		<OPTION VALUE="CD">Canadian Dollars
		<OPTION VALUE="EC">European Euro 
	</SELECT> --->
<!--- 			<CFSET US_CHECKED="CHECKED">
			<CFSET CD_CHECKED="">
			<CFSET BP_CHECKED="">
			<CFSET EC_CHECKED="">
		<CFIF get_data.curr_symbol EQ "US">
			<CFSET US_CHECKED="CHECKED">
			<CFSET CD_CHECKED="">
			<CFSET BP_CHECKED="">
			<CFSET EC_CHECKED="">
		<CFELSEIF get_data.curr_symbol EQ "CD">
			<CFSET US_CHECKED="">
			<CFSET CD_CHECKED="CHECKED">
			<CFSET BP_CHECKED="">
			<CFSET EC_CHECKED="">
		<CFELSEIF get_data.curr_symbol EQ "BP">
			<CFSET US_CHECKED="">
			<CFSET CD_CHECKED="">
			<CFSET BP_CHECKED="CHECKED">
			<CFSET EC_CHECKED="">
		<CFELSEIF get_data.curr_symbol EQ "EC">
			<CFSET US_CHECKED="">
			<CFSET CD_CHECKED="">
			<CFSET BP_CHECKED="">
			<CFSET EC_CHECKED="CHECKED">
		</CFIF> --->
			<CFSET US_CHECKED="">
			<CFSET CD_CHECKED="">
			<CFSET BP_CHECKED="">
			<CFSET EC_CHECKED="">
		<CFIF get_data.curr_symbol EQ "US">
			<CFSET US_CHECKED="CHECKED">
		<CFELSEIF get_data.curr_symbol EQ "CD">
			<CFSET CD_CHECKED="CHECKED">
		<CFELSEIF get_data.curr_symbol EQ "BP">
			<CFSET BP_CHECKED="CHECKED">
		<CFELSEIF get_data.curr_symbol EQ "EC">
			<CFSET EC_CHECKED="CHECKED">
		<CFELSE>
			<CFSET US_CHECKED="CHECKED">
		</CFIF>		
			
	<CFOUTPUT>
	<TABLE>
		<TR>
			<TD><img src="flag_us.gif" title="American Flag" width="30" height="20" border="0"></TD>
			<TD><INPUT TYPE="radio" NAME="currency" VALUE="US" #US_CHECKED# #state#></TD>
			<TD><img src="flag_ca.gif" title="Canadian Flag" width="30" height="20" border="0"></TD>
			<TD><INPUT TYPE="radio" NAME="currency" VALUE="CD" #CD_CHECKED# #state#></TD>
		</TR>
		<TR>
			<TD><img src="flag_uk.gif" title="British Flag" width="30" height="20" border="0"></TD>
			<TD><INPUT TYPE="radio" NAME="currency" VALUE="BP" #BP_CHECKED# #state#></TD>
			<TD><img src="flag_eu.gif" title="European Flag" width="30" height="20" border="0"></TD>
			<TD><INPUT TYPE="radio" NAME="currency" VALUE="EC" #EC_CHECKED# #state#></TD>
		</TR>
	</TABLE>
	</CFOUTPUT>	
	</TD>
</TR>

<TR>
	<TD ALIGN="Right"><B>Amount:</B></TD>
	<TD ><CFOUTPUT><INPUT STYLE="text-align:right;" TYPE="text" NAME="Amount" <CFIF "#get_data.Amount#" NEQ "">VALUE="#replace(numberFormat(Get_Data.Amount,"_.__"),"-","")#"</CFIF> #state# ONKEYUP="clenseText(this,'0123456789.')"></CFOUTPUT></TD>

</TR>

</CFIF>

<CFIF URL.State eq 1>

<TR>
	<TD ALIGN="Right"><B>Check Number:</B></TD>
	<CFIF "#get_data.Check_Number#" NEQ "">
	<CFSET isdisabled = "DISABLED">
	</CFIF> 
	<CFOUTPUT>

	<TD><INPUT TYPE="text" NAME="Check_Number" VALUE="#Get_Data.Check_Number#" ONKEYUP="clenseText(this,'0123456789')" #isdisabled# ></TD>
	 </CFOUTPUT> 
</TR>
<TR>
	<TD ALIGN="Right"><B>Check Issue Date:</B></TD>
	<CFIF "#get_data.Check_Issue_Date#" NEQ "">
		<TD><INPUT TYPE = "text" NAME = "Check_Issue_Date" VALUE = "<CFOUTPUT>#dateformat(get_data.Check_Issue_Date,"m/d/yyyy")#</CFOUTPUT>" SIZE = "10" disabled></TD>
	<CFELSE>
		<TD><CF_EASYDATE FORMNAME="trans_create_form" FIELDNAME="Check_Issue_Date" FORMAT="mm/dd/yyyy"  DEFAULT="#Get_Data.Check_Issue_Date#"><!--- <INPUT TYPE="text" NAME="Check_Issue_Date"> ---></TD> 
	</CFIF>

</TR>
	
<TR>
	<TD ALIGN="Right"><B>Check Clearance Date:</B></TD>
	
	<CFIF "#get_data.Check_Clearance_Date#" NEQ "" or "#get_data.check_issue_date#" EQ "">	
	<TD><INPUT TYPE = "text" NAME = "Check_Clearance_Date" VALUE = "<CFOUTPUT>#dateformat(get_data.Check_Clearance_Date,"m/d/yyyy")#</CFOUTPUT>"  SIZE = "13" DISABLED></TD>
	<CFELSE>
	<TD><CF_EASYDATE FORMNAME="trans_create_form" FIELDNAME="Check_Clearance_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Get_Data.Check_Clearance_Date#"> <!--- <INPUT TYPE="text" NAME="Check_Clearance_Date"> ---></TD>
	
	</CFIF>


</TR>	
</CFIF>

<CFIF URL.State NEQ 1 AND application.returned_customer_setting.PayBy_awayX EQ 1>

<TR ID="Check_Wire_TR">
	<TD ALIGN="Right"><B>Mode of Transaction:</B></TD>
	<TD>
	<INPUT TYPE = "radio" NAME = "Trans_Mode" VALUE = "1" CHECKED>Check
	<INPUT TYPE = "radio" NAME = "Trans_Mode" VALUE = "0">Wire Transaction
	</TD>
</TR>
<CFELSEIF application.returned_customer_setting.PayBy_awayX EQ 0 AND URL.State NEQ 1>

	<INPUT TYPE = "hidden" NAME = "Trans_Mode" VALUE = "1"> 
</CFIF>

</TABLE>
<BR><BR><BR><BR>
<TABLE WIDTH="45%">
<TR>
	<TD align="center">
	<CFIF URL.State eq 1>					
		<CFOUTPUT>
			<CF_button
				button_name		=	""
				button_caption	=	"save data"
				button_action	=	"#callFunction#"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
		</CFOUTPUT>
	<CFELSE>	
		<CFOUTPUT>
			<CF_button
				button_name		=	""
				button_caption	=	"next step"
				button_action	=	"#callFunction#"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
		</CFOUTPUT>
	</CFIF>
	</TD>
</TR>


</TABLE>

</FORM>







<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
