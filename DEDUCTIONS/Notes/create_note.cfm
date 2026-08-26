<cfparam name="DD_Note" default="">
<cfparam name="Edit" default="0">

<cfif isDefined("blnSubmit")>

	<cfif Edit IS 1>
		<cfset useLakebaseForUpdateNote = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_notes")>
		<cfif useLakebaseForUpdateNote>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_notes",
					{ "dd_note_id" = "eq.#DD_Note_ID#" },
					{ "dd_note" = DD_Note }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateNote = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateNote>
		<cfquery name="UpdateNote" datasource="#application.datasource#">
		Update DD_Notes
		Set DD_Note = '#DD_Note#'
		WHERE DD_Note_ID = '#DD_Note_ID#'
		</cfquery>
		</cfif>
	<cfelse>
		<cfset useLakebaseForInsertNote = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_notes")>
		<cfif useLakebaseForInsertNote>
			<cftry>
				<cfset application.oLakebase.insertRow("dd_notes", {
					"deduction_id" = Form.Deduction_ID,
					"dd_note" = DD_Note,
					"dd_note_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"dd_note_by" = request.AccessStructure.User_ID
				})>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForInsertNote = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForInsertNote>
		<cfquery name="InsertNote" datasource="#application.datasource#">
			INSERT INTO DD_notes
			(
				Deduction_ID,
				DD_Note,
				DD_Note_Date,
				DD_Note_By
			)
			VALUES
			(
				'#Form.Deduction_ID#',
				'#DD_Note#', 
				#Now()#,
				'#request.AccessStructure.User_ID#'
			)
		</cfquery>
		</cfif>
		
		<cfquery name="Latest_Notes" datasource="#application.datasource#">
			UPDATE Deductions
			SET Notes_Count = (SELECT COUNT(Deleted) FROM DD_Notes WHERE Deduction_ID  = Deductions.Deduction_ID AND Deleted = 0),
			Latest_DD_Note_ID = (SELECT TOP 1 DD_Note_ID FROM DD_Notes WHERE Deduction_ID  = Deductions.Deduction_ID AND Deleted = 0 ORDER BY Created_Date DESC)
			FROM Deductions WHERE Deleted = 0 AND Deduction_ID = '#Form.Deduction_ID#'
		</cfquery>
	</cfif>
	
	<script>
		opener.document.all.Refresh.submit()
		window.close()		
	</script>
</cfif>

<cfif isDefined("DD_Note_ID")>
	<cfset useLakebaseForGetNote = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_notes")>
	<cfif useLakebaseForGetNote>
		<cftry>
			<cfset GetNote = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_notes", {
					"dd_note_id" = "eq.#DD_Note_ID#"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetNote = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetNote>
	<cfquery name="GetNote" datasource="#application.datasource#">
	SELECT * FROM DD_Notes
	WHERE DD_Note_ID = '#DD_Note_ID#'
	</cfquery>
	</cfif>
	
	<cfset Edit = 1>
	
</cfif>

<cfoutput>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Create a Note</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/fixed_popup.js"></SCRIPT>
</head>
<cfinclude template="/common_files/jQuery.cfm">
<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">
<form action="/deductions/notes/create_note.cfm" method="post" name="Note">


<table width="90%" align="center"><tr><Td valign="Center">
<strong><font size="+1" color="navy">Create a Note</font></strong></td><td valign="Center" align="right"><img src="/images/notes.gif">&nbsp; &nbsp; &nbsp; </TD></tr>

</table>

<table width="90%" align="center"  ><!--- style="border-left:solid navy 2px; border-right:solid navy 2px; border-top:solid navy 2px; border-bottom:solid navy 2px;" --->

<tr>
	
	<td>
	<textarea name="DD_Note" cols="55" rows="15" maxlength="255" onfocus="skipcycle=true" onblur="skipcycle=false"><cfif Edit IS 1>#GetNote.DD_Note#</cfif></textarea>
	</td>
</tr>

</table>

<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
<input type="hidden" name="blnSubmit" value="1">
<input type="hidden" name="Edit" value="#Edit#">
<cfif Edit IS 1>
<input type="hidden" name="DD_Note_ID" value="#DD_Note_ID#">
</cfif>
<br>
<div align="center">
<a href="##" onClick="confirmCompletion();"><font color="navy"><strong>[ save note ]</strong></font></a>
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
			
		// if(document.all.DD_Note.value.length == 0)	{   ChromeFix :: use jquiery to access text area form element
		if(jQuery("textarea[name=DD_Note]").val().length == 0)	{
			
			ErrorCount++;
			queueMessage("You must enter note text.", document.all.error_DD_Note);
		}
		else
		{
			clearQueue(document.all.error_DD_Note);
		}

		
			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0) {
					Note.submit()
			}
			else {
				showMessageWindow()
			}	

		}
</script>

</cfoutput>
</body>
</html>
