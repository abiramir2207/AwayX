<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Create a Call Log Entry</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/fixed_popup.js"></SCRIPT>
</head>
<cfinclude template="/Common_Files/jQuery.cfm">
<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">

<cfif isDefined("blnSubmit")>

	<cfset useLakebaseForInsertNote = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_call_log")>
	<cfif useLakebaseForInsertNote>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_call_log", {
				"deduction_id" = Form.Deduction_ID,
				"person_who_called" = request.AccessStructure.User_ID,
				"call_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
				"person_called" = Person_Called,
				"call_synopsis" = Call_Synopsis,
				"deleted" = false
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForInsertNote = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForInsertNote>
		<cfquery name="InsertNote" datasource="#application.datasource#">
			INSERT INTO DD_Call_Log
			(
				Deduction_ID,
				Person_Who_Called,
				Call_Date,
				Person_Called,
				Call_Synopsis
			)
			VALUES
			(
				'#Form.Deduction_ID#',
				'#request.AccessStructure.User_ID#',
				#Now()#,
				'#Person_Called#',
				'#Call_Synopsis#'

			)
		</cfquery>
	</cfif>

	<script>
		opener.document.all.Refresh.submit()
		window.close()		
	</script>
</cfif>

<cfoutput>

<form action="/deductions/communications/call_log.cfm" method="post" name="Call_Log">


<table width="90%" align="center"><tr><Td valign="Center">
<strong><font size="+1" color="navy">Create a Call Log Entry</font></strong></td><td valign="Center" align="right"><img src="/images/communicate.gif">&nbsp; &nbsp; &nbsp; </TD></tr>

</table>

<table width="90%" align="center"  border="0" ><!--- style="border-left:solid navy 2px; border-right:solid navy 2px; border-top:solid navy 2px; border-bottom:solid navy 2px;" --->

<tr>
	<td valign="top"><div id="error_Person_Called">&nbsp;</div>Person Called: </td>
	</tr><tr>
	<td><input name="Person_Called" size="43" maxlength="100" onfocus="skipcycle=true" onblur="skipcycle=false">
	</td>
</tr>

<tr>
	<td valign="top"><div id="error_Call_Synopsis">&nbsp;</div>Call Notes:  </td>
	</tr><tr>
	<td><textarea name="Call_Synopsis" cols="75" rows="13" onfocus="skipcycle=true" onblur="skipcycle=false"></textarea>
	</td>
</tr>

</table>

<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
<input type="hidden" name="blnSubmit" value="1">

<br>
<div align="center">
<a href="##" onClick="confirmCompletion();"><strong><font color="navy">[ save call ]</font></strong></a>
</div>
</form>



<CF_MessageWindow>
<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
<script>
/*
Seems like this function is not being used. So, commented it.
function popGLWindow() {
		selectedGLCode = parseInt(document.all.GL_Assignment_ID.value);
		vReturnValue = window.showModalDialog("/common_files/contracts/GL_Codes.cfm",selectedGLCode,"dialogHeight: 500px; dialogWidth: 700px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;");
		if(vReturnValue !=null)	{
			document.all.GL_Text.value = vReturnValue.GL_Name;
			document.all.GL_Assignment_ID.value = vReturnValue.value;
			selectedGLCode = vReturnValue.value
		}
	}
*/

function confirmCompletion(){
		
	ErrorCount = 0
				
		if(document.all.Person_Called.value.length == 0)	{
			ErrorCount++;
			queueMessage("You must enter the name of the person called.", document.all.error_Person_Called);
		}
		else
		{
			clearQueue(document.all.error_Person_Called);
		}
			
		if(  jQuery("textarea[name=Call_Synopsis]").val() == 0)	{ // ChromeFix document.all.Call_Synopsis.value.length
			ErrorCount++;
			queueMessage("You must enter notes on the call.", document.all.error_Call_Synopsis);
		}
		else
		{
			clearQueue(document.all.error_Call_Synopsis);
		}
		
		if(jQuery("textarea[name=Call_Synopsis]").val() > 999)	{  // ChromeFix document.all.Call_Synopsis.value.length
			ErrorCount++;
			queueMessage("Notes cannot exceed 1000 characters.", document.all.error_Call_Synopsis);
		}
		else
		{
			clearQueue(document.all.error_Call_Synopsis);
		}
				
			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0) {
					Call_Log.submit()
			}
			else {
				showMessageWindow()
			}	

		}
</script>

</cfoutput>
</body>
</html>
