<html>
<cfoutput>
<!---set the lead time--->
<cfset leadTime = CreateObject("component", "components.futures_pricing.SettingsManager").get().getLeadTime() />
<!---set restrict customer deadline--->
<cfset restrictCustDL = CreateObject("component", "components.futures_pricing.SettingsManager").get().getRestrictCustDeadline() />
<cfset formName = "dateForm" />
<head>
<title>Request Dates Add/Edit</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script src="initial_request_create_edit.js"></script>
<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
<SCRIPT>
	
	function init()
	{
		var openerForm = opener.document.dataForm;
		var thisForm = document.#formName#;
		
		thisForm.Start_Date.value = openerForm.Start_Date.value;
		thisForm.End_Date.value = openerForm.End_Date.value;
		thisForm.Customer_Deadline.value = openerForm.Customer_Deadline.value;
	}
	
	function submitDate() 
	{
		var openerForm = opener.document.dataForm;
		var thisForm = document.#formName#;
		if (!validateDate(thisForm))
		{	
			return false;
		}
		openerForm.Start_Date.value = thisForm.Start_Date.value;
		openerForm.End_Date.value = thisForm.End_Date.value;
		openerForm.Customer_Deadline.value = thisForm.Customer_Deadline.value;
		openerForm.submit();
		self.close();
		return false;
	}
	
</SCRIPT>
</head>

<body onLoad="init()">

<br>
<B><FONT SIZE="4" COLOR="##003366">Edit Dates</FONT></B>&nbsp;&nbsp;&nbsp;
<hr color="##003366">
<form action="" method="post" name="#formName#">
<table>
	<TR>
		<TD ALIGN="right" VALIGN="top" NOWRAP>&nbsp;</TD>
		<TD VALIGN="top"><B>Start Date</B><BR>
			<CF_EASYDATE 
				FORMNAME="#formName#" 
				FIELDNAME="Start_Date" 
				FORMAT="mm/dd/yyyy" 
				DEFAULT="">
		</TD>
		<TD VALIGN="top"><B>End Date<BR></B>
			<CF_EASYDATE 
				FORMNAME="#formName#" 
				FIELDNAME="End_Date" 
				FORMAT="mm/dd/yyyy" 
				DEFAULT="">	
		</TD>
		<TD VALIGN="top"><B>Customer Deadline Date<BR>
		</B>
			<CF_EASYDATE 
				FORMNAME="#formName#" 
				FIELDNAME="Customer_Deadline" 
				FORMAT="mm/dd/yyyy" 
				DEFAULT="">
		</TD>
	</TR>
	<tr>
		<TD ALIGN="right" VALIGN="top" NOWRAP>&nbsp;</TD>
		<td>
			<CF_smallLink 
				title = "apply" 
				url = "##"
				parameters = "onClick=""javascript: return submitDate();"""
			>
			<CF_smallLink 
				title = "cancel" 
				url = "##"
				parameters = "onClick=""javascript: window.close();"""
			>
		</td>
	</tr>
</table>
<INPUT NAME="Today_Date" TYPE="Hidden" VALUE="#DateFormat(Now(), "mm/dd/yyyy")#" />
<INPUT NAME="Restrict_Cust_DL" TYPE="Hidden" VALUE="#trim(restrictCustDL)#" />
<INPUT NAME="Lead_Time" TYPE="Hidden" VALUE="#trim(leadTime)#" />
</form>
<script>
		
	//document.#formName#.Start_Date.onpropertychange = new Function("setCustomerDeadline(document.#formName#)");
		
</script>

</body>
</cfoutput>
</html>
