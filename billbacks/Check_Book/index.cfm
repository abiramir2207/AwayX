<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
</HEAD>
<CFSET URL.PageTitle="#application.CompanyName#: Ledger">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BODY BGCOLOR="White" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="8" TOPMARGIN="12" RIGHTMARGIN="8">

<CFPARAM NAME = "FORM.Date_Comp_Operator" DEFAULT = "">
<CFPARAM NAME = "FORM.Date_Time" DEFAULT = "">
<CFPARAM NAME = "FORM.To_Date_Time" DEFAULT = "">
<CFPARAM NAME = "FORM.Trans_type" DEFAULT = "">
<CFPARAM NAME = "FORM.IssueDate_Comp_Operator" DEFAULT = "">
<CFPARAM NAME = "FORM.Check_Issue_date" DEFAULT = "">
<CFPARAM NAME = "FORM.To_Check_Issue_date" DEFAULT = "">
<CFPARAM NAME = "FORM.ClearenceDate_Comp_Operator" DEFAULT = "">
<CFPARAM NAME = "FORM.Check_Clearance_date" DEFAULT = "">
<CFPARAM NAME = "FORM.To_Check_Clearance_date" DEFAULT = "">
<CFPARAM NAME = "FORM.Check_Comp_Operator" DEFAULT = "">
<CFPARAM NAME = "FORM.check_number" DEFAULT = "">
<CFPARAM NAME = "FORM.To_check_number" DEFAULT = "">
<CFPARAM NAME = "FORM.Amount_Comp_Operator" DEFAULT = "">
<CFPARAM NAME = "FORM.Amount" DEFAULT = "">
<CFPARAM NAME = "FORM.To_Amount" DEFAULT = "">
<CFPARAM NAME = "FORM.curr_symbol" DEFAULT = "">
<CFPARAM NAME = "FORM.BB_reference" DEFAULT = "">


<CFIF NOT isdefined("URL.search_tool")>
<!---- Do not need to co-exist with form, will conflict with same field names ---->
	<cfparam name="FORM.startrow"  default="1">
   <CFPARAM NAME="FORM.frompage"   DEFAULT="1">
   <cfparam name="FORM.pageLength"  default=7>
   <CFSET startrow=FORM.startrow>
   <CFSET frompage=FORM.frompage>
   <cf_Number_of_Rows maxrows="#FORM.pageLength#">
	<CFOUTPUT>
	 <FORM name="Pagingform" ID="Pagingform" method = "post" action = "index.cfm">
   			<INPUT TYPE="HIDDEN" ID="startrow" name="startrow" VALUE="#FORM.startrow#">
			<INPUT TYPE="HIDDEN" ID="frompage" name="frompage" VALUE="#FORM.frompage#">
			<CFLOOP COLLECTION="#Form#" ITEM="FormItem">
			 <CFIF FormItem NEQ "startrow" AND FormItem NEQ "frompage">
			 	<CFIF IsDefined("Form.#FormItem#")>
				 <INPUT TYPE="HIDDEN" ID="#FormItem#" NAME="#FormItem#" VALUE="#Evaluate("Form.#FormItem#")#">
				 </CFIF>
			 </CFIF>			
			</CFLOOP>
			<!--------
			<CFLOOP COLLECTION="#URL#" ITEM="FormItem">
			 <CFIF FormItem NEQ "startrow" AND FormItem NEQ "frompage">
			 <INPUT TYPE="HIDDEN" ID="#FormItem#" NAME="#FormItem#" VALUE="#Evaluate("URL.#FormItem#")#">
			 </CFIF>			 
			</CFLOOP>
			-------->

	</FORM>
	</CFOUTPUT>
</CFIF>
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the checkbook ledger --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Select the latest record and if it is not paid delete it --->
<CFQUERY name = "check_previous" datasource = "#Application.datasource#">
	SELECT Ledger_ID,Amount,Paid FROM Ledger_Table where Ledger_ID = (SELECT max(Ledger_ID) FROM Ledger_Table)
</CFQUERY>
<CFOUTPUT>
<CFIF check_previous.recordcount GT 0>
<CFIF check_previous.paid NEQ 1 and check_previous.Amount LT 0>
	<CFQUERY name = "delete_unpaid" datasource = "#Application.datasource#">
		DELETE from Ledger_Table where Ledger_ID = #check_previous.ledger_ID# 
	</CFQUERY>
</CFIF>
</CFIF>
</CFOUTPUT> 
&nbsp;&nbsp;
<b>
<FONT COLOR="Red">[</FONT> <A HREF="index.cfm?search_tool=true">search ledger tool</A> <FONT COLOR="Red">]</FONT>
</b>
<!--- Legend --->
<CFIF not isdefined("URL.search_tool")>
<TABLE ALIGN = "Right">
	<TR>
		<TD><img src="/Images/blue.gif" alt="" width="6" height="6" border="0"></TD>
		<TD>&nbsp;</TD>
		<TD><font size=1>Foreign Currency</font></TD>
	</TR>
<!--- 	<TR>
		<TD><img src="/Images/bullet_red.gif" alt="" width="6" height="6" border="0"></TD>
		<TD>&nbsp;</TD>
		<TD><font size=1>Change in Approved Billback Amount</font></TD>
	</TR> --->
</TABLE>
</CFIF>
<BR><BR>

<!--- Display all records --->
<cfset useLakebaseForGet_Checkbook = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ledger_table")>
<cfif useLakebaseForGet_Checkbook>
	<cftry>
		<cfset Get_Checkbook = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ledger_table", {
				"order" = "date_time.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Checkbook = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Checkbook>
<CFQUERY NAME="Get_Checkbook" DATASOURCE="#application.datasource#">
	Select		*
	From		Ledger_Table
	Order by	Date_Time desc
</CFQUERY>
</cfif>

<SCRIPT type = "text/javascript">
function check_Comparison_Presence_Date(selectName, Field1, Field2, ErrSp)
{
	var bErr = 0;
	var oSelect = eval("document.all." + selectName);
	var oField1 = eval("document.all." + Field1);
	var oField2 = eval("document.all." + Field2);
	var oErrSp = eval("document.all." + ErrSp);

	
	if(oField1.value != ""  && oSelect.value == "")
	{
		queueMessage("Please select comparision <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> and try again ", oErrSp);
		bErr = 1;
	}
	else if(oSelect.value == "Between")
	{
		if(oField1.value =="" || oField2.value =="")
		{
			queueMessage("Please enter FROM and TO DATE if you choose BETWEEN comparison", oErrSp);
			bErr = 1;
		}
		else if(checkDate(oField1.value, oField2.value) >= 0)
		{
			queueMessage("FROM DATE must be less than TO DATE", oErrSp);
			bErr = 1;
		}
	}
	
	if(!bErr)
	{
		clearQueue(oErrSp);
	}	
	
	return bErr;
}


function check_Comparison_Presence_Amount(selectName, Field1, Field2, ErrSp)
{
	var bErr = 0;
	var oSelect = eval("document.all." + selectName);
	var oField1 = eval("document.all." + Field1);
	var oField2 = eval("document.all." + Field2);
	var oErrSp = eval("document.all." + ErrSp);
	
	var Amount1 = parseFloat(oField1.value);
	var Amount2 = parseFloat(oField2.value);
	
	if(Amount1 < 0)
	{
		queueMessage("Amount cannot be less than zero", oErrSp);
		bErr = 1;
	}
	else if((oField1.value != "" && Amount1 != 0)  && oSelect.value == "")
	{
		queueMessage("Please select comparision <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> and try again", oErrSp);
		bErr = 1;
	}
	else if(oSelect.value == "Between")
	{
		if(oField1.value == "" || oField2.value == "")
		{
			queueMessage("Please enter FROM and TO AMOUNT if you choose BETWEEN comparison", oErrSp);
			bErr = 1;
		}
		else if(Amount1 > Amount2)
		{
			queueMessage("FROM AMOUNT must be less than TO AMOUNT", oErrSp);
			bErr = 1;
		}
	}
	
	if(!bErr)
	{
		clearQueue(oErrSp);
	}	
	return bErr;
}


function check_Comparison_Presence_Number(selectName, Field1, Field2, ErrSp)
{
	var bErr = 0;
	var oSelect = eval("document.all." + selectName);
	var oField1 = eval("document.all." + Field1);
	var oField2 = eval("document.all." + Field2);
	var oErrSp = eval("document.all." + ErrSp);
	
	var Amount1 = parseFloat(oField1.value);
	var Amount2 = parseFloat(oField2.value);
	
	if(Amount1 < 0)
	{
		queueMessage("Check Number cannot be less than zero", oErrSp);
		bErr = 1;
	}
	else if(oField1.value != ""  && oSelect.value == "")
	{
		queueMessage("Please select comparision <cfoutput>#application.returned_customer_setting.operator_label_singular# </cfoutput>and try again", oErrSp);
		bErr = 1;
	}	
	else if(oSelect.value == "Between")
	{
		if(oField1.value == "" || oField2.value == "")
		{
			queueMessage("Please enter FROM and TO CHECK NUMBER if you choose BETWEEN comparison", oErrSp);
			bErr = 1;
		}
		else if(Amount1 > Amount2)
		{		
			queueMessage("FROM CHECK NUMBER must be less than TO CHECK NUMBER", oErrSp);
			bErr = 1;
		}	
	}
	
	if(!bErr)
	{
		clearQueue(oErrSp);
	}
		
	return bErr;
}


function validate()
{
	x = document.search_tool;
	var bError = 0;
	//0 = date
	//1 = Amount
	//2 = text
	bError = (bError + check_Comparison_Presence_Date("Date_Comp_Operator", "Date_Time", "To_Date_Time", "SP_Date_Time"));
	bError = (bError + check_Comparison_Presence_Date("ClearenceDate_Comp_Operator", "Check_Clearance_date", "To_Check_Clearance_date", "SP_Check_Clearance_date"));
	bError = (bError + check_Comparison_Presence_Date("IssueDate_Comp_Operator", "Check_Issue_date", "To_Check_Issue_date","SP_Check_Issue_date"));
	bError = (bError + check_Comparison_Presence_Amount("Amount_Comp_Operator", "Amount", "To_Amount","SP_Amount"));
	bError = (bError + check_Comparison_Presence_Number("Check_Comp_Operator", "check_number", "To_check_number","SP_check_number"));
	
	if(bError > 0)
	{
		showMessageWindow();
		return false;
	}
	else
	{
		x.submit();
		return false;
	}
}


function reset_Form_Fields()
{
	resetSelect("Date_Comp_Operator");
	resetSelect("IssueDate_Comp_Operator");
	resetSelect("ClearenceDate_Comp_Operator");
	resetSelect("Check_Comp_Operator");
	resetSelect("Amount_Comp_Operator");	
	document.all.curr_symbol.selectedIndex = 0;
	document.all.BB_reference.value = "";
}

function resetSelect(selName)
{
	var sObj = document.getElementById(selName);
	if(sObj)
	{
		sObj.selectedIndex = 0;
		sObj.fireEvent('onchange');
	}
}

</SCRIPT>


<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js, /Common_Files/scripts/Date_Difference.js">
<CF_MessageWindow> 
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



<SCRIPT language="JavaScript">
function show_hide_between(thisobj, tdID, inpObjName, tdID2, inpObjName2)
{	
	var bShow = true;
	var bClear = false;
	if(thisobj.value == "Between")
	{
		bShow = true;
		bClear = false;
	}
	else
	{
		bShow = false;
		bClear = true;
	}
	//var tdObj = document.getElementById(tdID);
	eval("var tdObj = document.all." + tdID + ";");	
	if(tdObj)	
	{	
		if(tdObj.length)	
		{
			for(i=0;i<tdObj.length;i++)
			{
				showHideThisDiv(tdObj[i], bShow, inpObjName, bClear);
			}
		}
		else
		{
			showHideThisDiv(tdObj, bShow, inpObjName, bClear);
		}
	}
	
	
	///////////////////////////////////////////////////////////////////
	
	if(thisobj.value == "NULL")
	{
		bShow = false;
		bClear = true;
	}
	else if(thisobj.value == "")
	{
		bShow = true;
		bClear = true;
	}
	else
	{
		bShow = true;
		bClear = false;
	}
	
	//var tdObj = document.getElementById(tdID);
	eval("var tdObj = document.all." + tdID2 + ";");	
	if(tdObj)
	{	
		if(tdObj.length)	
		{
			for(i=0;i<tdObj.length;i++)
			{
				showHideThisDiv(tdObj[i], bShow, inpObjName2, bClear);
			}
		}
		else
		{
			showHideThisDiv(tdObj, bShow, inpObjName2, bClear);
		}
	}
	
}

function showHideThisDiv(tdObj, bShow, inpObjName, bClear)
{
	if(bShow)
	{
		//tdObj.style.display = "inline";
		tdObj.style.visibility = "visible";
		//var inpObj = document.getElementById(inpObjName);		
		
	}
	else
	{
		//tdObj.style.display = "none";
		tdObj.style.visibility = "hidden";		
	}
	
	if(bClear)
	{
		eval("var inpObj = tdObj.all." + inpObjName + ";");	
		if(inpObj)
		{
			inpObj.value="";
		}
	}
}

//disableDiv(divName,bDis,bHide)

function Transaction_Type(typeID)
{
	var bHide = false;
	if(typeID == 'credit')
	{
		bHide = true;
	}
	
	disableDiv("ROW_Issue_Date",bHide,false);
	disableDiv("ROW_Clearance_date",bHide,false);
	disableDiv("ROW_Check_Number",bHide,false);
	disableDiv("ROW_Billback_Number",bHide,false);	
	
}


</SCRIPT>
<!--- Number validation --->
<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/string_functions.js">

<!--- Show search tool is url.search_tool isdeined --->
<CFIF isdefined("URL.search_tool") <!--- or isdefined("URL.back") --->>
<CFQUERY NAME = "Billback" DATASOURCE = "#Application.Datasource#">
	SELECT DISTINCT(l.Billback_ID) billback_id, b.bb_reference bb_reference 
	FROM Ledger_table l,billback b 
	WHERE l.Billback_id = b.Billback_id AND l.Billback_id is not null
</CFQUERY>

<FIELDSET>
<LEGEND><B>Search Tool</B></LEGEND>
<CFOUTPUT>



<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0"  ALIGN = "CENTER">
	<FORM NAME = "search_tool" ACTION = "index.cfm" METHOD = "post">
	<INPUT TYPE = "hidden" NAME = "search">

	<TR>
		<TD ALIGN = "right" NOWRAP>
			<BR>
			<SPAN ID="SP_Date_Time">&nbsp;</SPAN><B>Date:</B>
		</TD>
		<TD ROWSPAN="100%" WIDTH="10">&nbsp;</TD>
		<TD ROWSPAN="100%" BGCOLOR="Navy" WIDTH="2"><IMG SRC="/Images/fill.gif" WIDTH="2" HEIGHT="2"></TD>
		<TD ROWSPAN="100%" WIDTH="10">&nbsp;</TD>

				<CFSET BK = "SELECTED">
				<CFSET Great = "">
				<CFSET Less = "">
				<CFSET eql = "">
				<CFSET BET = "">

			<CFIF FORM.Date_Comp_Operator EQ ">">
				<CFSET GREAT = "SELECTED">
			<CFELSEIF FORM.Date_Comp_Operator EQ "<">
				<CFSET LESS = "SELECTED">
			<CFELSEIF FORM.Date_Comp_Operator EQ "=">
				<CFSET EQL = "SELECTED">
			<CFELSEIF FORM.Date_Comp_Operator EQ "Between">
				<CFSET BET = "SELECTED">
			</CFIF>
		<TD><BR>
			<SELECT NAME="Date_Comp_Operator" onchange="javaSCript: show_hide_between(this, 'TD_To_Date_Time', 'To_Date_Time', 'TD_Date_Time', 'Date_Time');" STYLE = "WIDTH: 95px;"><!--- , 'TD_Date_Time', 'Date_Time' --->
				<OPTION VALUE = "" #BK#>
				<OPTION VALUE = ">" #GREAT#> Greater Than
				<OPTION VALUE = "<" #LESS#> Less Than
				<OPTION VALUE = "=" #EQL#> Equal To	
				<OPTION VALUE = "Between" #BET#>Between 			
			</SELECT>
		</TD>
		<TD COLSPAN="2">
			<DIV ID="TD_To_Date_Time" <CFIF FORM.Date_Comp_Operator NEQ "Between"> STYLE="VISIBILITY:HIDDEN;"</CFIF><!--- STYLE="VISIBILITY:HIDDEN;" --->>From</DIV>
			<DIV ID="TD_Date_Time">
			<CF_EASYDATE FORMNAME="search_tool" FIELDNAME="Date_Time" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Date_Time#">
			</DIV>
		</TD>
		<TD>		
			<DIV ID="TD_To_Date_Time" <CFIF FORM.Date_Comp_Operator NEQ "Between"> STYLE="VISIBILITY:HIDDEN;"</CFIF><!--- STYLE="VISIBILITY:HIDDEN;" --->>
			To<BR>
			<CF_EASYDATE FORMNAME="search_tool" FIELDNAME="To_Date_Time" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.To_Date_Time#">
			</DIV>
		</TD>		
	</TR>
	<TR>
		<TD><BR><B>Transaction Type:</B></TD>
			<CFSET debit = "CHECKED">
			<CFSET credit = "">
			<CFSET both = "">
<!--- 			<CFIF FORM.trans_type EQ "debit">
				<CFSET debit = "CHECKED">
				<CFSET credit = "">
				<CFSET both = "">		 --->
			<CFIF FORM.trans_type EQ "credit">
				<CFSET debit = "">
				<CFSET credit = "CHECKED">
				<CFSET both = "">
			<CFELSEIF FORM.trans_type EQ "both">
				<CFSET debit = "">
				<CFSET credit = "">
				<CFSET both = "CHECKED">
			</CFIF>
		<TD COLSPAN="2"><BR>
			<INPUT TYPE = "radio" NAME = "trans_type" VALUE ="debit" #debit# onclick="javaScript: Transaction_Type('debit');">Debit
			<INPUT TYPE = "radio" NAME = "trans_type" VALUE ="credit" #credit# onclick="javaScript: Transaction_Type('credit');">Credit
			<INPUT TYPE = "radio" NAME = "trans_type" VALUE ="both" #both# onclick="javaScript: Transaction_Type('both');">Both
		</TD>
	</TR>
	<TR ID="ROW_Issue_Date">
		<TD ALIGN = "right" NOWRAP>
			<BR> 
			<SPAN ID="SP_Check_Issue_date">&nbsp;</SPAN><B>Issue Date:</B>
		</TD>
				<CFSET BK = "SELECTED">
				<CFSET Great = "">
				<CFSET Less = "">
				<CFSET eql = "">
				<CFSET BET = "">
				<CFSET NULL_BK = "">

			<CFIF FORM.IssueDate_Comp_Operator EQ ">">
				<CFSET GREAT = "SELECTED">
			<CFELSEIF FORM.IssueDate_Comp_Operator EQ "<">
				<CFSET LESS = "SELECTED">
			<CFELSEIF FORM.IssueDate_Comp_Operator EQ "=">
				<CFSET EQL = "SELECTED">
			<CFELSEIF FORM.IssueDate_Comp_Operator EQ "Between">
				<CFSET BET = "SELECTED">
			<CFELSEIF FORM.IssueDate_Comp_Operator EQ "NULL">
				<CFSET NULL_BK = "SELECTED">
			</CFIF>

		<TD>
			<BR>
			<SELECT NAME="IssueDate_Comp_Operator" onchange="javaSCript: show_hide_between(this, 'TD_To_Check_Issue_date', 'To_Check_Issue_date', 'TD_Check_Issue_date', 'Check_Issue_date');" STYLE = "WIDTH: 95px;">
				<OPTION VALUE = "" SELECTED>
				<OPTION VALUE = "NULL" #NULL_BK#>Blank
				<OPTION VALUE = ">" #GREAT#> Greater Than
				<OPTION VALUE = "<" #LESS#> Less Than
				<OPTION VALUE = "=" #EQL#> Equal to 
				<OPTION VALUE = "Between" #BET#>Between
			</SELECT>
		</TD>
		<TD COLSPAN="2">
			<DIV ID="TD_To_Check_Issue_date"<CFIF FORM.IssueDate_Comp_Operator NEQ "Between"> STYLE="VISIBILITY:HIDDEN;"</CFIF>>From</DIV>
			<DIV ID="TD_Check_Issue_date"<CFIF FORM.IssueDate_Comp_Operator EQ "NULL"> STYLE="VISIBILITY:HIDDEN;"</CFIF>>
			<CF_EASYDATE FORMNAME="search_tool" FIELDNAME="Check_Issue_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Check_Issue_date#">
			</DIV>
		</TD>

		<TD>
			<DIV ID="TD_To_Check_Issue_date"<CFIF FORM.IssueDate_Comp_Operator NEQ "Between"> STYLE="VISIBILITY:HIDDEN;"</CFIF>>
			To <br>
			<CF_EASYDATE FORMNAME="search_tool" FIELDNAME="To_Check_Issue_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.To_Check_Issue_date#">
			</DIV>
		</TD>
		

	</TR>
	<TR ID="ROW_Clearance_date">
		<TD ALIGN = "right" NOWRAP>
			<BR>
			<SPAN ID="SP_Check_Clearance_date">&nbsp;</SPAN><B>Clearance Date:</B>
		</TD>
				<CFSET BK = "SELECTED">
				<CFSET Great = "">
				<CFSET Less = "">
				<CFSET eql = "">
				<CFSET BET = "">
				<CFSET NULL_BK = "">

			<CFIF FORM.ClearenceDate_Comp_Operator EQ ">">
				<CFSET GREAT = "SELECTED">
			<CFELSEIF FORM.ClearenceDate_Comp_Operator EQ "<">
				<CFSET LESS = "SELECTED">
			<CFELSEIF FORM.ClearenceDate_Comp_Operator EQ "=">
				<CFSET EQL = "SELECTED">
			<CFELSEIF FORM.ClearenceDate_Comp_Operator EQ "Between">
				<CFSET BET = "SELECTED">
			<CFELSEIF FORM.ClearenceDate_Comp_Operator EQ "NULL">
				<CFSET NULL_BK = "SELECTED">
			</CFIF>

		<TD>
			<BR>
			<SELECT NAME="ClearenceDate_Comp_Operator" onchange="javaSCript: show_hide_between(this, 'TD_To_Check_Clearance_date', 'To_Check_Clearance_date', 'TD_Check_Clearance_date', 'Check_Clearance_date');" STYLE = "WIDTH: 95px;">
				<OPTION VALUE = "" SELECTED>
				<OPTION VALUE = "NULL" #NULL_BK#>Blank
				<OPTION VALUE = ">" #GREAT#> Greater Than
				<OPTION VALUE = "<" #LESS#> Less Than
				<OPTION VALUE = "=" #EQL#> Equal To
				<OPTION VALUE = "Between" #BET#>Between
			</SELECT>
		</TD>
		<TD COLSPAN="2">
			<DIV ID="TD_To_Check_Clearance_date"<CFIF FORM.ClearenceDate_Comp_Operator NEQ "Between"> STYLE="VISIBILITY:HIDDEN;"</CFIF>>From</DIV>
			<DIV ID="TD_Check_Clearance_date"<CFIF FORM.ClearenceDate_Comp_Operator EQ "NULL"> STYLE="VISIBILITY:HIDDEN;"</CFIF>>
			<CF_EASYDATE FORMNAME="search_tool" FIELDNAME="Check_Clearance_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Check_Clearance_date#">
			</DIV>
		</TD>
		<TD>
			<DIV ID="TD_To_Check_Clearance_date"<CFIF FORM.ClearenceDate_Comp_Operator NEQ "Between"> STYLE="VISIBILITY:HIDDEN;"</CFIF>>
			To <BR><CF_EASYDATE FORMNAME="search_tool" FIELDNAME="To_Check_Clearance_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.To_Check_Clearance_date#">		
			</DIV>
		</TD>
		
	</TR>
	<TR ID="ROW_Check_Number">
		<TD ALIGN = "right" NOWRAP>
			<BR>
			<SPAN ID="SP_check_number">&nbsp;</SPAN><B>Check Number:</B>
		</TD>
				<CFSET BK = "SELECTED">
				<CFSET Great = "">
				<CFSET Less = "">
				<CFSET eql = "">
				<CFSET BET = "">

			<CFIF FORM.Check_Comp_Operator EQ ">">
				<CFSET GREAT = "SELECTED">
			<CFELSEIF FORM.Check_Comp_Operator EQ "<">
				<CFSET LESS = "SELECTED">
			<CFELSEIF FORM.Check_Comp_Operator EQ "=">
				<CFSET EQL = "SELECTED">
			<CFELSEIF FORM.Check_Comp_Operator EQ "Between">
				<CFSET BET = "SELECTED">
			</CFIF>

		<TD>
			<BR>
			<SELECT NAME="Check_Comp_Operator" onchange="javaSCript: show_hide_between(this, 'TD_To_check_number', 'To_check_number', 'TD_check_number', 'check_number');" STYLE = "WIDTH: 95px;">
				<OPTION VALUE = "" #BK#>
				<OPTION VALUE = ">" #GREAT#> Greater Than
				<OPTION VALUE = "<" #LESS#> Less Than
				<OPTION VALUE = "=" #EQL#> Equal To
				<OPTION VALUE = "Between" #BET#>Between
			</SELECT>
		</TD>
		<TD>
			<DIV ID="TD_To_check_number"<CFIF FORM.Check_Comp_Operator NEQ "Between"> STYLE="VISIBILITY:HIDDEN;"</CFIF>>From</DIV>
			<DIV ID="TD_check_number">
			<INPUT SIZE = "8" NAME = "check_number" VALUE = "#FORM.check_number#" ONKEYUP="clenseText(this,'0123456789')">
			</DIV>
		</TD>

		<TD>
		<DIV ID="TD_To_check_number"<CFIF FORM.Check_Comp_Operator NEQ "Between"> STYLE="VISIBILITY:HIDDEN;"</CFIF>>
		To <BR><INPUT SIZE = "8" NAME = "To_check_number" VALUE = "#FORM.To_check_number#" ONKEYUP="clenseText(this,'0123456789')">
		</DIV>
		</TD>
		
	</TR>
	<TR>
		<TD ALIGN = "right" NOWRAP>
			<BR>
			<SPAN ID="SP_Amount">&nbsp;</SPAN><B>Amount:</B>
		
			
			
		</TD>
				<CFSET BK = "SELECTED">
				<CFSET Great = "">
				<CFSET Less = "">
				<CFSET eql = "">
				<CFSET BET = "">

			<CFIF FORM.Amount_Comp_Operator EQ ">">
				<CFSET GREAT = "SELECTED">
			<CFELSEIF FORM.Amount_Comp_Operator EQ "<">
				<CFSET LESS = "SELECTED">
			<CFELSEIF FORM.Amount_Comp_Operator EQ "=">
				<CFSET EQL = "SELECTED">
			<CFELSEIF FORM.Amount_Comp_Operator EQ "Between">
				<CFSET BET = "SELECTED">
			</CFIF>

		<TD>
			<BR>
			<SELECT NAME="Amount_Comp_Operator" onchange="javaSCript: show_hide_between(this, 'TD_To_Amount', 'To_Amount', 'TD_Amount', 'Amount');" STYLE = "WIDTH: 95px;">
				<OPTION VALUE = "" #BK#>
				<OPTION VALUE = ">" #GREAT#> Greater Than
				<OPTION VALUE = "<" #LESS#> Less Than
				<OPTION VALUE = "=" #EQL#> Equal To
				<OPTION VALUE = "Between" #BET#>Between
			</SELECT>
		</TD>
				<CFSET USD = "SELECTED">
				<CFSET BRP = "">
				<CFSET CAN = "">
				<CFSET EUR = "">

			<CFIF FORM.curr_symbol EQ "US">
				<CFSET USD = "SELECTED">
			<CFELSEIF FORM.curr_symbol EQ "BP">
				<CFSET BRP = "SELECTED">
			<CFELSEIF FORM.curr_symbol EQ "CD">
				<CFSET CAN = "SELECTED">
			<CFELSEIF FORM.curr_symbol EQ "EU">
				<CFSET EUR = "SELECTED">
			</CFIF>

		<TD> 
			<br>
			<SELECT NAME = "curr_symbol" STYLE = "WIDTH:71px;">
				<OPTION VALUE = "US" #USD#>USD</OPTION>
				<OPTION VALUE = "BP" #BRP#>BRP</OPTION>
				<OPTION VALUE = "CD" #CAN#>CAN</OPTION>
				<OPTION VALUE = "EU" #EUR#>EUR</OPTION>
			</SELECT>
		</TD>
		<TD>
			<DIV ID="TD_To_Amount"<CFIF FORM.Amount_Comp_Operator NEQ "Between"> STYLE="VISIBILITY:HIDDEN;"</CFIF>>From</DIV>
			<DIV ID="TD_Amount">
			<INPUT SIZE = "8" NAME = "Amount" VALUE = "#FORM.Amount#" ONKEYUP="clenseText(this,'0123456789.')">
			</DIV>
			
		 </TD>
		<TD> 
		<DIV ID="TD_To_Amount"<CFIF FORM.Amount_Comp_Operator NEQ "Between"> STYLE="VISIBILITY:HIDDEN;"</CFIF>>
			To<BR><INPUT SIZE = "8" NAME = "To_Amount" VALUE = "#FORM.To_Amount#" ONKEYUP="clenseText(this,'0123456789.')">
		</DIV>
		
		</TD>
		
		
	</TR>
	<TR ID="ROW_Billback_Number">
		<TD ALIGN = "right" NOWRAP><BR><B>Billback Number:</B></strong></strong></TD>
		<TD COLSPAN="2"><BR><INPUT SIZE = "27" NAME = "BB_reference" VALUE = "#FORM.BB_reference#"> </TD>
	</TR>
	<TR>
		<TD COLSPAN="3"></TD>
		<TD ALIGN = "RIGHT" NOWRAP VALIGN = "bottom" COLSPAN = "8">
			<FONT COLOR="ff0000" >&nbsp;&nbsp;<B>[</B></FONT>
				<A HREF="return void(0);" OnClick="javascript: return validate();"><B>search ledger</B></A>
			<FONT COLOR="ff0000" ><B>]</B></FONT>
			 <FONT COLOR="ff0000" >&nbsp;&nbsp;<B>[</B></FONT>
				<!------
<A HREF="javascript: document.search_tool.reset();"><B>reset</B></A>
----->
				<A HREF="javascript: reset_Form_Fields();"><B>reset</B></A>
			<FONT COLOR="ff0000" ><B>]</B></FONT> 
		</TD>
	</TR>
</FORM>
</TABLE>

<br>
</CFOUTPUT>
</FIELDSET>
<SCRIPT LANGUAGE="JavaScript">
Transaction_Type('<CFOUTPUT>#FORM.trans_type#</CFOUTPUT>');
</SCRIPT>
</CFIF>	
<!--- If search tool is used --->
<CFIF isdefined("form.search")>
	<CFPARAM NAME = "first_selection" DEFAULT = "">
	<CFPARAM NAME = "Last_Selection" DEFAULT = "">
	<CFPARAM NAME = "BB_ID" DEFAULT = "">
<CFOUTPUT>
	<CFIF form.BB_Reference NEQ "">
		<CFQUERY NAME = "BB_Search" DATASOURCE = "#Application.Datasource#">
			SELECT Billback_ID from Billback WHERE BB_Reference = '#Form.BB_Reference#'
		</CFQUERY> 
		<CFIF bb_search.recordcount NEQ 0>
			<CFSET bb_id = 1>
		<CFELSE>
			<CFSET bb_id = 0>
			<!--- <B><U>Search Criteria:</U> </B>
			  <UL>
				  <LI>Billback Number is #Form.BB_Reference#		
			  </UL>
			  <b>There are no records matching this search criteria.</b>
			  <BR>
				<b>
				<FONT COLOR="Red">[</FONT> <A HREF="index.cfm?search_tool=true">back to search tool</A> <FONT COLOR="Red">]</FONT>
				</b>
			<CFABORT> --->
		</CFIF>
	</CFIF>

</CFOUTPUT>

<!--- First Selection --->
	<CFIF form.BB_Reference NEQ "">
		<CFSET First_selection = "BB_Reference">
	</CFIF>
	
	<CFIF form.Amount NEQ "">
		<CFSET First_selection = "Amount">
	</CFIF>	

	<CFIF form.check_number NEQ "">
		<CFSET First_selection = "check_number">
	</CFIF>	

	<CFIF form.Check_Clearance_date NEQ "" or FORM.ClearenceDate_Comp_Operator EQ "NULL">
		<CFSET First_selection = "Check_Clearance_date">
	</CFIF>	
	
	<CFIF form.Check_Issue_date NEQ "" or FORM.IssueDate_Comp_Operator EQ "NULL">
		<CFSET First_selection = "Check_Issue_date">
	</CFIF>	
	
	<CFIF form.Trans_type NEQ "both">
		<CFSET First_selection = "Trans_type">
	</CFIF>
	
	<CFIF form.Date_Time NEQ "">
		<CFSET First_selection = "Date_Time">
	</CFIF>

<!--- Last Selection --->
	<CFIF form.Date_Time NEQ "">
		<CFSET Last_selection = "Date_Time">
	</CFIF>

	<CFIF form.Trans_type NEQ "both">
		<CFSET Last_selection = "Trans_type">
	</CFIF>

	<CFIF form.Check_Issue_date NEQ "" or FORM.IssueDate_Comp_Operator EQ "NULL">
		<CFSET Last_selection = "Check_Issue_date">
	</CFIF>	

	<CFIF form.Check_Clearance_date NEQ "" or FORM.ClearenceDate_Comp_Operator EQ "NULL">
		<CFSET Last_selection = "Check_Clearance_date">
	</CFIF>	

	<CFIF form.check_number NEQ "">
		<CFSET Last_selection = "check_number">
	</CFIF>	

	<CFIF form.Amount NEQ "">
		<CFSET Last_selection = "Amount">
	</CFIF>	

	<CFIF form.BB_Reference NEQ "">
		<CFSET Last_selection = "BB_Reference">
	</CFIF>
<!--- <CFOUTPUT>
	fIRST #First_Selection#<BR>
	Second #Last_Selection#
</CFOUTPUT>
 --->
<CFIF first_selection NEQ "" and Last_selection NEQ  "">


 	<CFIF BB_ID EQ 1 or BB_ID EQ "">
	<!--- <CFOUTPUT>
	  fIRST #First_Selection#<BR>
	Second #Last_Selection#
	#FORM.Check_Issue_date# 
	Amount #FORM.AMOUNT# 
	curr #FORM.curr_symbol#
	</CFOUTPUT> --->
 <!--- <CFABORT> --->
 		<CFOUTPUT>
 		<CFQUERY NAME = "Get_Checkbook" DATASOURCE = "#Application.Datasource#">      
			SELECT		*
			FROM		Ledger_Table
			WHERE 
			<CFIF form.Date_Time NEQ "" AND first_selection EQ "Date_Time" AND Last_selection NEQ "Date_Time">
				CONVERT(char(10),date_time,101) #FORM.Date_Comp_Operator# '#FORM.Date_Time#' <CFIF FORM.Date_Comp_Operator EQ "Between">AND '#FORM.To_Date_Time#'</CFIF> AND
			<CFELSEIF form.Date_Time NEQ "" AND Last_selection EQ "Date_Time">
				CONVERT(char(10),date_time,101) #FORM.Date_Comp_Operator#  '#FORM.Date_Time#' <CFIF FORM.Date_Comp_Operator EQ "Between">AND '#FORM.To_Date_Time#'</CFIF>
			</CFIF> 			
				
			<CFIF (form.Check_Issue_date NEQ "" OR FORM.IssueDate_Comp_Operator EQ "NULL")AND first_selection EQ "Check_Issue_date" AND Last_selection NEQ "Check_Issue_date">
				CONVERT(char(10),Check_Issue_Date,101) <CFIF FORM.IssueDate_Comp_Operator NEQ "NULL">#FORM.IssueDate_Comp_Operator# '#FORM.Check_Issue_date#' <CFIF FORM.IssueDate_Comp_Operator EQ "Between"> AND '#FORM.To_Check_Issue_date#'</CFIF> <CFELSE> IS NULL</CFIF> AND
			<CFELSEIF (form.Check_Issue_date NEQ ""or FORM.IssueDate_Comp_Operator EQ "NULL") AND Last_selection EQ "Check_Issue_date">
				CONVERT(char(10),Check_Issue_Date,101) <CFIF FORM.IssueDate_Comp_Operator NEQ "NULL">#FORM.IssueDate_Comp_Operator# '#FORM.Check_Issue_date#' <CFIF FORM.IssueDate_Comp_Operator EQ "Between"> AND '#FORM.To_Check_Issue_date#'</CFIF><CFELSE> IS NULL</CFIF>
			</CFIF>

			<CFIF (form.Check_Clearance_date NEQ "" OR FORM.ClearenceDate_Comp_Operator EQ "NULL") AND first_selection EQ "Check_Clearance_date" AND Last_selection NEQ "Check_Clearance_date">
				CONVERT(char(10),Check_Clearance_Date,101) <CFIF FORM.ClearenceDate_Comp_Operator NEQ "NULL">#FORM.ClearenceDate_Comp_Operator# '#FORM.Check_Clearance_date#'<CFIF FORM.ClearenceDate_Comp_Operator EQ "Between"> AND '#FORM.To_Check_Clearance_date#'</CFIF> <CFELSE> IS NULL</CFIF> AND
			<CFELSEIF (form.Check_Clearance_date NEQ "" OR FORM.ClearenceDate_Comp_Operator EQ "NULL") AND Last_selection EQ "Check_Clearance_date">
				CONVERT(char(10),Check_Clearance_Date,101) <CFIF FORM.ClearenceDate_Comp_Operator NEQ "NULL">#FORM.ClearenceDate_Comp_Operator# '#FORM.Check_Clearance_date#'<CFIF FORM.ClearenceDate_Comp_Operator EQ "Between"> AND '#FORM.To_Check_Clearance_date#'</CFIF> <CFELSE> IS NULL </CFIF>
			</CFIF>

			<CFIF form.check_number NEQ "" AND first_selection EQ "check_number" AND Last_selection NEQ "check_number">
				Check_Number #FORM.Check_Comp_Operator# #form.Check_Number# <CFIF FORM.Check_Comp_Operator EQ "Between">AND #form.To_Check_Number#</CFIF> AND
			<CFELSEIF form.check_number NEQ "" AND Last_selection EQ "check_number">
				Check_Number #FORM.Check_Comp_Operator# #form.Check_Number# <CFIF FORM.Check_Comp_Operator EQ "Between"> AND #form.To_Check_Number#</CFIF>
			</CFIF>
			
			<CFIF form.Amount NEQ "" AND first_selection EQ "Amount" AND Last_selection NEQ "Amount" AND FORM.Curr_Symbol EQ "US">
				<CFIF FORM.trans_type EQ "both">ABS</CFIF>(Amount) #FORM.Amount_comp_operator# <CFIF FORM.Trans_type EQ "debit">-</CFIF>#FORM.Amount# <CFIF FORM.Amount_comp_operator EQ "Between">AND <CFIF FORM.Trans_type EQ "debit">-</CFIF>#FORM.To_Amount#</CFIF> AND 		
			<CFELSEIF form.Amount NEQ "" AND Last_selection EQ "Amount" AND FORM.Curr_Symbol EQ "US">
				<CFIF FORM.trans_type EQ "both">ABS</CFIF>(Amount) #FORM.Amount_comp_operator# <CFIF FORM.Trans_type EQ "debit">-</CFIF>#FORM.Amount# <CFIF FORM.Amount_comp_operator EQ "Between">AND <CFIF FORM.Trans_type EQ "debit">-</CFIF>#FORM.To_Amount#</CFIF>
			<CFELSEIF form.Amount NEQ "" AND first_selection EQ "Amount" AND Last_selection NEQ "Amount" AND FORM.Curr_Symbol NEQ "US">
				Foreign_Curr_Amount #FORM.Amount_comp_operator# #FORM.Amount# <CFIF FORM.Amount_comp_operator EQ "Between">AND #FORM.To_Amount# </CFIF> AND Curr_Symbol = '#FORM.Curr_Symbol#' AND <CFIF FORM.trans_type EQ "both">ABS</CFIF>Amount <CFIF FORM.Trans_type EQ "debit">< 0 <CFELSEIF FORM.Trans_type EQ "credit"> > 0</CFIF> AND		
			<CFELSEIF form.Amount NEQ "" AND Last_selection EQ "Amount" AND FORM.Curr_Symbol NEQ "US">
				Foreign_Curr_Amount #FORM.Amount_comp_operator# #FORM.Amount# <CFIF FORM.Amount_comp_operator EQ "Between">AND #FORM.To_Amount# </CFIF> AND Curr_Symbol = '#FORM.Curr_Symbol#' AND <CFIF FORM.trans_type EQ "both">ABS</CFIF>Amount <CFIF FORM.Trans_type EQ "debit">< 0 <CFELSEIF FORM.Trans_type EQ "credit"> > 0</CFIF>

			<CFELSEIF form.Amount EQ "" AND first_selection EQ "trans_type" AND Last_selection NEQ "trans_type" AND FORM.Curr_Symbol EQ "US">
				<CFIF FORM.trans_type EQ "both">ABS</CFIF>(Amount) <CFIF FORM.trans_type EQ "both">> 0<CFELSEIF FORM.trans_type EQ "credit"> > 0 <CFELSEIF FORM.trans_type EQ "debit">< 0 </CFIF>  AND 		
			<CFELSEIF form.Amount EQ "" AND Last_selection EQ "trans_type" AND FORM.Curr_Symbol EQ "US">
				<CFIF FORM.trans_type EQ "both">ABS</CFIF>(Amount) <CFIF FORM.trans_type EQ "both">> 0<CFELSEIF FORM.trans_type EQ "credit"> > 0 <CFELSEIF FORM.trans_type EQ "debit">< 0 </CFIF>
			<CFELSEIF form.Amount EQ "" AND first_selection EQ "trans_type" AND Last_selection NEQ "trans_type" AND FORM.Curr_Symbol NEQ "US">
				Curr_Symbol = '#FORM.Curr_Symbol#' AND <CFIF FORM.trans_type EQ "both">ABS</CFIF>(Amount) <CFIF FORM.trans_type EQ "debit">< 0 <CFELSE> > 0  </CFIF> AND		
			<CFELSEIF form.Amount EQ "" AND Last_selection EQ "trans_type" AND FORM.Curr_Symbol NEQ "US">
				Curr_Symbol = '#FORM.Curr_Symbol#' AND <CFIF FORM.trans_type EQ "both">ABS</CFIF>(Amount) <CFIF FORM.trans_type EQ "debit">< 0 <CFELSE> > 0  </CFIF>
			</CFIF>
		
			<CFIF bb_id EQ 1>
				<CFIF form.BB_Reference NEQ "" AND first_selection EQ "BB_Reference" AND Last_selection NEQ "BB_Reference" >
					Billback_ID = '#BB_Search.Billback_ID#' AND
				<CFELSEIF form.BB_Reference NEQ "" AND Last_selection EQ "BB_Reference">
					Billback_ID = '#BB_Search.Billback_ID#'
				</CFIF>
			</CFIF>
		
			Order by	Date_Time desc
		</CFQUERY>  
		</CFOUTPUT>
 
	<CFELSE>
		There are no records matching the search criteria....
	</CFIF>
  	<!--- Search criteria Diplay  --->
	<CFIF not isdefined("URL.search_tool")>
		<CFOUTPUT>
		<CFIF (bb_id eq 1 or BB_ID eq "")>
 			<B><U>Search Criteria:</U> </B>
		</CFIF>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	 	<b>
		<FONT COLOR="Red">[</FONT> 
		<SCRIPT language="JavaScript">
			function back_To_Search()
			{
				document.Pagingform.action = "index.cfm?search_tool=true";
				document.Pagingform.submit();
			}
		</SCRIPT>
		<A HREF="##" onClick="javaScript: return back_To_Search();">adjust current search criteria</A>	
		<FONT COLOR="Red">]</FONT>
	
		</b>
  		<UL>
	  	<CFIF form.Date_Time NEQ "">
			<LI>Date 
  			<CFIF FORM.Date_Comp_Operator EQ "=">
				equal to
			<CFELSEIF FORM.Date_Comp_Operator EQ ">">
				greater than
			<CFELSEIF FORM.Date_Comp_Operator EQ "<">
				less than
			<CFELSEIF FORM.Date_Comp_Operator EQ "Between">
				between
			</CFIF>
  			#FORM.Date_Time#
		</CFIF> 
		<CFIF FORM.Date_Comp_Operator EQ "Between">
			and #FORM.To_Date_Time#
		</CFIF>
		
		<CFIF form.Trans_type NEQ "both">
			<LI>Transaction type:
			<CFIF FORM.Trans_type EQ "debit">
				&nbsp;debit
			<CFELSEIF FORM.Trans_type EQ "credit">
				&nbsp;credit
			<CFELSEIF FORM.Trans_type EQ "both">
				&nbsp;debit and credit
			</CFIF>
		</CFIF>

	  	<CFIF form.Check_Issue_date NEQ "">
			<LI>Issue Date 
			<CFIF FORM.IssueDate_Comp_Operator EQ "=">
				equal to
			<CFELSEIF FORM.IssueDate_Comp_Operator EQ ">">
				greater than
			<CFELSEIF FORM.IssueDate_Comp_Operator EQ "<">
				less than
			<CFELSEIF FORM.IssueDate_Comp_Operator EQ "Between">
				between
			</CFIF>
			#FORM.Check_Issue_date#
			<CFIF FORM.IssueDate_Comp_Operator EQ "Between">
				and #FORM.To_Check_Issue_date#
			</CFIF>
		<CFELSEIF form.Check_Issue_date EQ "" AND FORM.IssueDate_Comp_Operator EQ "NULL">
			<LI>Check is not Issued 
		</CFIF>

  		<CFIF form.Check_Clearance_date NEQ "">
  			<LI>Clearance Date
			<CFIF FORM.ClearenceDate_Comp_Operator EQ "=">
				equal to
			<CFELSEIF FORM.ClearenceDate_Comp_Operator EQ ">">
				greater than
			<CFELSEIF FORM.ClearenceDate_Comp_Operator EQ "<">
				less than
			<CFELSEIF FORM.ClearenceDate_Comp_Operator EQ "Between">
				between
			</CFIF> 
		 	#FORM.Check_Clearance_date# 
	 		<CFIF FORM.ClearenceDate_Comp_Operator EQ "Between"> 
	 			and #FORM.To_Check_Clearance_date#
			</CFIF>
		<CFELSEIF form.Check_Clearance_date EQ "" AND FORM.ClearenceDate_Comp_Operator EQ "NULL">
			<LI>Ckeck is not Cleared
		</CFIF>

		<CFIF form.check_number NEQ "">
			<LI>Check No 
			<CFIF FORM.Check_Comp_Operator EQ "=">
				equal to
			<CFELSEIF FORM.Check_Comp_Operator EQ ">">
				greater than
			<CFELSEIF FORM.Check_Comp_Operator EQ "<">
				less than
			<CFELSEIF FORM.Check_Comp_Operator EQ "Between">
				between
			</CFIF> 
			#form.Check_Number# 
			<CFIF FORM.Check_Comp_Operator EQ "Between"> 
				and #form.To_Check_Number#
			</CFIF>
		</CFIF>

		<CFIF form.Amount NEQ "">
			<LI>Amount 
			<CFIF FORM.Amount_comp_operator EQ "=">
				equal to
			<CFELSEIF FORM.Amount_comp_operator EQ ">">
				greater than
			<CFELSEIF FORM.Amount_comp_operator EQ "<">
				less than
			<CFELSEIF FORM.Amount_comp_operator EQ "Between">
				between
			</CFIF> 
			#FORM.Amount# 
			<CFIF FORM.Amount_comp_operator EQ "Between">
				and #FORM.To_Amount#
			</CFIF>
		</CFIF> 
		
		<CFIF FORM.curr_symbol NEQ "US">
			<LI>Currency:
			<CFIF FORM.curr_symbol EQ "BP">
				&nbsp;British Pounds
			<CFELSEIF FORM.curr_symbol EQ "EU">
				&nbsp;Euro
			<CFELSEIF FORM.curr_symbol EQ "CA">
				&nbsp;Canadian Dollars
			</CFIF>
			
		</CFIF>
		
  		<CFIF form.BB_Reference NEQ "">
  			<LI>Billback Number is #Form.BB_Reference#
		</CFIF>
		</UL>


		<CFIF Get_Checkbook.recordcount EQ 0>
			<b>There are no records matching this search criteria.</b>	
			<BR><br><br>	
		</CFIF>
	
		<!--- if bb_reference no is wrong abort  --->
		<CFIF bb_id eq 0 or Get_Checkbook.recordcount EQ 0>
			<CFABORT>
		</CFIF>
	</CFOUTPUT>
	</CFIF>
</CFIF>

</CFIF>


 <CFIF not isdefined ("URL.search_tool")> 
<TABLE CELLPADDING="3" CELLSPACING="0" WIDTH="100%">
<TR VALIGN="bottom">
	<TD CLASS="maintableheader">&nbsp;</TD>
	<TD CLASS="maintableheader">&nbsp;<!--- Trans.<BR>Number ---></TD>
	<TD CLASS="maintableheader">&nbsp;</TD>
	<TD CLASS="maintableheader">Date&nbsp;</TD>
 	<TD CLASS="maintableheader" WIDTH="100%">Memo Field&nbsp;</TD> 
	<TD CLASS="maintableheader">&nbsp;</TD>
	<TD CLASS="maintableheader" ALIGN="right">Amount&nbsp;</TD>
	<TD CLASS="maintableheader">&nbsp;</TD> 
	<TD CLASS="maintableheader">Check<BR>Number&nbsp;</TD>
	<TD CLASS="maintableheader">Issue Date&nbsp;</TD>
	<TD CLASS="maintableheader">Clearance Date&nbsp;</TD>
	<TD CLASS="maintableheader" ALIGN="right">Balance&nbsp;</TD>
</TR>

	

<CFOUTPUT QUERY="Get_Checkbook" startrow="#StartRow#" maxrows="#MaxRows#">
<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
	<TD CLASS="maintable"><B><FONT COLOR="Red">[</FONT></B>&nbsp;</TD>
	<TD ALIGN="right" CLASS="maintable"><B><A HREF="trans_create1.cfm?rid=#Ledger_ID#&state=1">#Ledger_ID#</A></B>&nbsp;</TD>
	<TD CLASS="maintable"><B><FONT COLOR="Red">]</FONT></B>&nbsp;</TD>
	<TD CLASS="maintable">#dateformat(Date_Time, 'm/d/yyyy')#&nbsp;</TD>
 	<TD CLASS="maintable" ALIGN="jusdity">#Memo_Field#&nbsp;</TD> 
<cfset useLakebaseForCurr_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("commodities_symbol")>
<cfif useLakebaseForCurr_Name>
	<cftry>
		<cfset Curr_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("commodities_symbol", {
				"symbol" = "eq.#curr_symbol#",
				"select" = "symbol_description"
			}), "symbol_description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCurr_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCurr_Name>
<CFQUERY NAME = "Curr_Name" DATASOURCE="#application.datasource#">
	SELECT Symbol_Description FROM commodities_symbol WHERE symbol='#curr_symbol#'
</CFQUERY>
</cfif>

 	<TD CLASS="maintable">
	<CFIF #curr_symbol# NEQ "US">
		<img src="/Images/blue.gif" title="Currency: #curr_Name.Symbol_Description##chr(13)# Amount: #foreign_curr_Amount##chr(13)# Exchange Rate:#Ex_rate#" width="6" height="6" border="0">
	<CFELSE>
	&nbsp;
	</CFIF></TD>
	<TD CLASS="maintable" ALIGN="right">#dollarformat(Amount)#&nbsp;</TD>
	<TD CLASS="maintable"><CFIF #Amt_Deviation_Reason# NEQ ""><img src="/Images/bullet_red.gif" title="Amount Approved : #app_amount##chr(13)#Amount Paid : #abs(amount)##chr(13)#Reason : #Amt_Deviation_Reason#" width="6" height="6" border="0"><CFELSE>&nbsp;</CFIF></TD> 
	<TD CLASS="maintable">#Check_Number#&nbsp;</TD>
	<TD CLASS="maintable">#dateformat(Check_Issue_Date, 'm/d/yyyy')#&nbsp;</TD>
	<TD CLASS="maintable">#dateformat(Check_Clearance_Date, 'm/d/yyyy')#&nbsp;</TD>
	<TD CLASS="maintable" ALIGN="right">#dollarformat(Balance)#&nbsp;</TD>
</TR>
</CFOUTPUT>
<CFOUTPUT>
<TR>
	<TD COLSPAN="100%">		
		<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <CF_Next_Previous_For_Forms
    formname="Pagingform"
    query="Get_Checkbook"
    maxpages="40"
    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    addparams="">
   </DIV>	  
	</TD>
</TR>
</CFOUTPUT>
</TABLE>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
