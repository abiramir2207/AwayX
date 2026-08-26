<cfoutput>
<!---set defaults--->
<cfparam name="url.User_ID" default="" />
<cfparam name="form.User_ID" default="#url.User_ID#" />
<cfparam name="url.Program_ID" default="" />
<cfparam name="form.Program_ID" default="#url.Program_ID#" />
<cfparam name="url.Payment_Type_ID" default="" />
<cfparam name="form.Payment_Type_ID" default="#url.Payment_Type_ID#" />

<cfparam name="form.command" default="0" />

<!---initialize objects--->
<cfset ProgramAccountingSpecialists = CreateObject("component", "components.programs.AccountingSpecialists.ProgramAccountingSpecialists") />
<cfset AccountingSpecialists = CreateObject("component", "components.settings.AccountingSpecialists.AccountingSpecialists") />
<cfset qPaymentProcessor = AccountingSpecialists.get() />

<cfif form.command eq 1>
	
	<!---save accounting specialist info if it's from program--->
	<cfif trim(form.Program_ID) neq "">
		<cfset ProgramAccountingSpecialists.add(form.User_ID, form.Program_ID) />
	<cfelse>
		<cfset AccountingSpecialists.add(form.User_ID, form.Payment_Type_ID) />
	</cfif>
	
	<!---relocate opener and close window--->
	<script>
		
		opener.location.href = opener.location.href;
		window.close();
		
	</script>
	
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>

<SCRIPT LANGUAGE="JavaScript"><!--

	window.onresize= new Function("ResizeSelect();");
	function ResizeSelect()
	{	
		var selectObj = document.all.Accounting_Specialist_ID;
		var wdth = document.body.clientWidth - 50;
		var hght = document.body.clientHeight - 100;
		
		if (wdth < 150)
		{
			wdth = 100;
		}
		
		if (hght < 200)
		{
			hght = 200;
		}
		
		selectObj.style.width = wdth;
		selectObj.style.height = hght;
	}
	
	function save() 
	{
		thisForm = document.popupForm;

		if (thisForm.User_ID.value == "")
		{
			alert("Please select a Payment Processor or cancel.");
			return;
		}
		
		thisForm.command.value = 1;
		thisForm.submit();
    	return;
	}
	
//--></SCRIPT>

<title>Select Payment Processor</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<FORM action="" method="post" NAME="popupForm">
<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><B><font color="FF0000">[</font> <a href="javascript:save();">save</a> <font color="FF0000">]</font></B>&nbsp;<B><font color="FF0000">[</font> <a href="javascript:window.close();">cancel</a> <font color="FF0000">]</font></B></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td bgcolor="DFE6FF"><b>Select Payment Processor</b></td>
	</tr>
	<tr>
		<td>
			<select name="User_ID" size="10" style="width:150">
				<cfloop query="qPaymentProcessor">
					<option value="#User_ID#" <cfif User_ID eq form.User_ID>selected</cfif>>#Name#</option>
				</cfloop>
			</select>
		</td>
	</tr>
</table>
<input type="hidden" name="Payment_Type_ID" value="#form.Payment_Type_ID#" />
<input type="hidden" name="Program_ID" value="#form.Program_ID#" />
<input type="hidden" name="command" value="#form.command#" />

</form>
</body>
</html>
</cfoutput>