 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>



<cfparam name="FORM.FormSubmitted" default="0">
<cfparam name="Deduction_Label" default="Deduction" />

<cfinclude template="/deductions/sql_Deduction_Info.cfm">

<cfif Deduction_Info.Is_Credit EQ 1>
	<cfset Deduction_Label = "Credit" />
</cfif>
	
<cfif FORM.FormSubmitted EQ 1>
 	<cfset useLakebaseForUpdateReject = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUpdateReject>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{ "deductiontype_id" = FORM.DeductionType_ID }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateReject = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateReject>
	<cfquery name="UpdateReject" datasource="#Application.Datasource#">
		UPDATE Deductions
		   SET DeductionType_ID = '#FORM.DeductionType_ID#'
		 WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
	</cfif>
	<cfset useLakebaseForGetSaved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
	<cfif useLakebaseForGetSaved>
		<cftry>
			<cfset GetSaved = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deduction_type", {
					"deductiontype_id" = "eq.#FORM.DeductionType_ID#"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetSaved = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetSaved>
	<cfquery name="GetSaved" datasource="#Application.Datasource#">
		SELECT * FROM Deduction_Type WHERE DeductionType_ID = '#FORM.DeductionType_ID#'
	</cfquery>
	</cfif>
	<br><br><br><br>
	<table border="0" cellpadding="0" cellspacing="0" align="Center">
		<tr>
			<td><b><font color="Red" size="3">The <cfoutput>#LCase(stDeductionLabels["Deduction Type"])# of this #lcase(deduction_label)#</cfoutput> is "<cfoutput>#GetSaved.DeductionType_Desc#</cfoutput>".</font></b></td>
		</tr>
	</table>
	<script language="JavaScript">
	function relocateThis()
	{
		window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#FORM.Deduction_ID#</CFOUTPUT>"
	}
	window.setTimeout('relocateThis()', 2000);	
	</script>

<cfelse>
	<form name="DDClassification" action="deductionType.cfm" method="POST">
	<cfoutput>
	<input type="hidden" name="Deduction_ID" value="#deduction_ID#">
	</cfoutput>
	<input type="Hidden" name="FormSubmitted" value="0">
	<table border="0" cellpadding="0" cellspacing="0" align="Center">
		<tr>
			<td><b>Pick the <cfoutput>#stDeductionLabels["Deduction Type"]# this #lcase(deduction_label)#</cfoutput> belongs to:</b>&nbsp;&nbsp;&nbsp;</td>		
		
		<cfset useLakebaseForGetAllClass = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
		<cfif useLakebaseForGetAllClass>
			<cftry>
				<cfset GetAllClass = application.oLakebase.toQuery(
					application.oLakebase.selectRows("deduction_type", {
						"deleted" = "eq.0",
						"order" = "deductiontype_desc.asc"
					})
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetAllClass = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetAllClass>
		<cfquery name="GetAllClass" datasource="#Application.Datasource#">
			SELECT * FROM Deduction_Type WHERE Deleted = 0 ORDER BY DeductionType_Desc
		</cfquery>
		</cfif>
		<cfset useLakebaseForSavedClass = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForSavedClass>
			<cftry>
				<cfset SavedClass = application.oLakebase.toQuery(
					application.oLakebase.selectRows("deductions", {
						"select" = "deductiontype_id",
						"deduction_id" = "eq.#Deduction_ID#"
					}),
					"deductiontype_id"
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForSavedClass = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForSavedClass>
		<cfquery name="SavedClass" datasource="#Application.Datasource#">
			SELECT DeductionType_ID FROM Deductions WHERE Deduction_ID = '#Deduction_ID#'
		</cfquery>
		</cfif>
		
			<td>
				<select name="DeductionType_ID">
  				<!---create a blank value option when field is not populated--->
				  <cfif Deduction_Info.DeductionType_ID eq "">
						<option value="" SELECTED>&nbsp;</option>						
				  </cfif>
					<cfoutput query="GetAllClass">
						<option value="#DeductionType_ID#" <CFIF DeductionType_ID EQ SavedClass.DeductionType_ID>SELECTED</CFIF>>#DeductionType_Desc#</option>						
					</cfoutput>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="Center"><br><br> 
				<CF_button
					button_name	=	""
					button_caption	=	"save"
					button_action	=	"validation()"
					button_type	=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight	=	"bold"
								><br><br>				
			</td>
		</tr>
	</table>
	</form>
	
	<script language="JavaScript">
	function validation()
	{
		if (document.all.DeductionType_ID.value == "")
		{
			alert("Please select a value.")
			document.all.DeductionType_ID.focus()
		}
		else
		{
				document.all.FormSubmitted.value=1;
				document.all.DDClassification.submit();
		}
	}
	</script>
</cfif>
</body>
</html>
