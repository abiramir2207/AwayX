
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />

<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="0">
	
<CFIF FORM.FormSubmitted EQ 1>
 	<cfset useLakebaseForUpdate_CustRefNo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUpdate_CustRefNo>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{ "dd_customer_refno" = FORM.DD_Customer_RefNo }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdate_CustRefNo = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdate_CustRefNo>
	<CFQUERY NAME="Update_CustRefNo" DATASOURCE="#Application.Datasource#">
		UPDATE Deductions
		SET DD_Customer_RefNo = CAST(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#FORM.DD_Customer_RefNo#"> as varchar(25))
		WHERE Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
	</cfif>
	<cfset useLakebaseForGetSaved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForGetSaved>
		<cftry>
			<cfset GetSaved = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"select" = "dd_customer_refno",
					"deduction_id" = "eq.#Deduction_ID#"
				}),
				"dd_customer_refno"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetSaved = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetSaved>
	<CFQUERY NAME="GetSaved" DATASOURCE="#Application.Datasource#">
		SELECT ISNull(DD_Customer_RefNo, 'K') AS DD_Customer_RefNo FROM Deductions WHERE Deduction_ID = '#Deduction_ID#'
	</CFQUERY>		  
	</cfif>
	
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3"><CFOUTPUT>Modified #stDeductionLabels["Customer Reference"]# is #GetSaved.DD_Customer_RefNo#</CFOUTPUT></FONT></B></TD>
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
	<FORM NAME="DDCustRefNo" ACTION="Customer_RefNo.cfm" METHOD="POST">
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Deduction_ID" VALUE="#deduction_ID#">
	</CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="FormSubmitted" VALUE="0">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><cfoutput>#stDeductionLabels["Customer Reference"]#</cfoutput>:</B>&nbsp;&nbsp;&nbsp;</TD>		
		
		<cfset useLakebaseForGetCustRefNo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForGetCustRefNo>
			<cftry>
				<cfset GetCustRefNo = application.oLakebase.toQuery(
					application.oLakebase.selectRows("deductions", {
						"select" = "dd_customer_refno",
						"deduction_id" = "eq.#Deduction_ID#"
					}),
					"dd_customer_refno"
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetCustRefNo = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetCustRefNo>
			<CFQUERY NAME="GetCustRefNo" DATASOURCE="#Application.Datasource#">
				SELECT isNull(DD_Customer_RefNo,'') AS DD_Customer_RefNo FROM Deductions WHERE Deduction_ID = '#Deduction_ID#'
			</CFQUERY>				   
		</cfif>
			<cfoutput>
				<TD><input name="DD_Customer_RefNo" type="Text" size="25" value="#GetCustRefNo.DD_Customer_RefNo#" onblur="noSpecChars(this);"></TD>
			</cfoutput>
		</TR>
		<TR>
			<TD COLSPAN="2" ALIGN="Center"><BR><BR> 
				<CF_button
					button_name		=	""
					button_caption	=	"save"
					button_action	=	"validation()"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
								><BR><BR>				
			</TD>
		</TR>
	</TABLE>
	</FORM>
	
	<SCRIPT language="JavaScript">
	function validation(){	
		document.all.FormSubmitted.value=1;
		document.all.DDCustRefNo.submit()
	}
	// Added for Anphanumeric string and hyphen validation
	function noSpecChars(myString)
	{
		var val=myString.value;
		var re1 = /[a-zA-Z0-9\-\s]/g;
		var specialString = val.replace(re1,"");
		if (specialString.length >0) {
	    	alert("Special characters other than Hyphen(-) and Space are not allowed.");
			myString.focus();
			return false;
		}
	}
	</SCRIPT>
</CFIF>
</body>
</html>
