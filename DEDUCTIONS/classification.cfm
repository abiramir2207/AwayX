<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Untitled</title>
</head>
<body>
<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="0">
<!--- Dev Note: Clay 9131: Allow Credit Write-Off (labels to match deduction type) --->
<CFPARAM NAME="Deduction_Label" Default="Deduction" />

<!---Gets data about deduction--->
<cfinclude template="/deductions/sql_Deduction_Info.cfm">

<CFIF Deduction_Info.Is_Credit EQ 1>
	<cfset Deduction_Label = "Credit" />
</CFIF>
	
<CFIF FORM.FormSubmitted EQ 1>
 	<cfset useLakebaseForUpdateReject = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUpdateReject>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{ "dd_classification_id" = FORM.DD_Classification_ID }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateReject = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateReject>
	<CFQUERY NAME="UpdateReject" DATASOURCE="#Application.Datasource#">
		UPDATE Deductions
		SET DD_Classification_ID = '#FORM.DD_Classification_ID#'
		WHERE Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
	</cfif>
	<cfset useLakebaseForGetSaved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
	<cfif useLakebaseForGetSaved>
		<cftry>
			<cfset GetSaved = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_classification", {
					"dd_classification_id" = "eq.#FORM.DD_Classification_ID#"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetSaved = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetSaved>
	<CFQUERY NAME="GetSaved" DATASOURCE="#Application.Datasource#">
		SELECT * FROM DD_Classification WHERE DD_Classification_ID = '#FORM.DD_Classification_ID#'
	</CFQUERY>
	</cfif>
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">The <cfoutput>#LCase(stDeductionLabels["Classification"])# of this #lcase(deduction_label)#</cfoutput> is "<CFOUTPUT>#GetSaved.DD_Classification_Desc#</CFOUTPUT>".</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function relocateThis()
	{
		window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#FORM.Deduction_ID#</CFOUTPUT>"
	}
	window.setTimeout('relocateThis()', 2000);	
	</SCRIPT>

<CFELSE>
	<cfset useLakebaseForSavedClass = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForSavedClass>
		<cftry>
			<cfset SavedClass = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"select" = "dd_classification_id",
					"deduction_id" = "eq.#Deduction_ID#"
				}),
				"dd_classification_id"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForSavedClass = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSavedClass>
	<cfquery name="SavedClass" datasource="#application.datasource#">
		SELECT DD_Classification_ID 
		  FROM Deductions 
		 WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
	</cfif>
	<cfquery name="GetAllClass" datasource="#application.datasource#">
		SELECT * 
		  FROM DD_Classification 
		 WHERE Deleted = 0 
		        <!--- 75969 includes saved classification regardless of its deleting status --->
				<cfif SavedClass.recordCount AND LEN(SavedClass.DD_Classification_ID)>
					OR DD_Classification_ID = #SavedClass.DD_Classification_ID#
				</cfif>
		 ORDER BY DD_Classification_Desc
	</cfquery>
	<cfoutput>
	<cfsavecontent variable="content">
		<form name="DDClassification" action="classification.cfm" method="post">
			<input type="hidden" name="Deduction_ID" value="#deduction_ID#">
			<input type="hidden" name="FormSubmitted" value="0">
			<table border="0" cellpadding="0" cellspacing="0" align="center">
				<tr>
					<td><b>Pick the #stDeductionLabels["Classification"]# this #lcase(deduction_label)# belongs to:</B>&nbsp;&nbsp;&nbsp;</td>		
					<td>
						<select name="DD_Classification_ID">
							<cfloop query="GetAllClass">
								<option value="#DD_Classification_ID#" 
									<cfif DD_Classification_ID EQ SavedClass.DD_Classification_ID>selected</cfif>>
									#DD_Classification_Desc#
								</option>						
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2" align="center"><br><br>
						<cf_button
							button_name    = ""
							button_caption = "save"
							button_action  = "validation()"
							button_type    = "javascript_link"
							button_width   = "100"
							button_color   = "Navy"
							button_tip     = ""
							font_color     = "White"
							font_size      = "12"
							font_weight    = "bold">
					</td>
				</tr>
			</table>
		</form>
	</cfsavecontent>
	#application.util.string.compress( content )#
	</cfoutput>

	<SCRIPT language="JavaScript">
	function validation()
	{
		if (document.all.DD_Classification_ID.value == "")
		{
			alert("Please select a classification.")
			document.all.DD_Classification_ID.focus()
		}
		else
		{
				document.all.FormSubmitted.value=1;
				document.all.DDClassification.submit();
		}
	}
	</SCRIPT>
</CFIF>
</body>
</html>
