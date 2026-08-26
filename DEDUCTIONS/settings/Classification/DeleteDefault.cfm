<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<BR>

<CFPARAM NAME="FORM.DelActSubmitted" DEFAULT="0">
<CFPARAM NAME="FORM.Is_Default" DEFAULT="0">
<!--- <CFDUMP VAR="#FORM#">
<CFABORT> --->
<CFIF DelActSubmitted EQ 1>
	
	
	<CFTRANSACTION action="BEGIN">
	<cfset useLakebaseForUpdateDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
	<cfif useLakebaseForUpdateDefault>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_classification",
				{ "dd_classification_id" = "eq.#Form.DD_Classification_ID#" },
				{
					"dd_classification_desc" = Form.DD_Classification_Desc,
					"deleted" = Form.Deleted,
					"is_default" = 0
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateDefault = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateDefault>
	<CFQUERY NAME="UpdateDefault" DATASOURCE="#Application.Datasource#">
		UPDATE 		DD_Classification
		SET 		DD_Classification_Desc 	=	'#Form.DD_Classification_Desc#',
					Deleted					=	#Form.Deleted#,
					Is_Default				= 	0
					
		WHERE		DD_Classification_ID				=	'#Form.DD_Classification_ID#'
	</CFQUERY>
	</cfif>
	
	<cfset useLakebaseForNewDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
	<cfif useLakebaseForNewDefault>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_classification",
				{ "dd_classification_id" = "eq.#Form.New_Default#" },
				{ "is_default" = 1 }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForNewDefault = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForNewDefault>
	<CFQUERY NAME="NewDefault" DATASOURCE="#Application.Datasource#">
		UPDATE 		DD_Classification
		SET 		Is_Default				= 	1
					
		WHERE		DD_Classification_ID				=	'#Form.New_Default#'
	</CFQUERY>
	</cfif>
	<CFTRANSACTION action="COMMIT">
	</CFTRANSACTION>
	
	<SCRIPT language="JavaScript">
	function refeshOpener()
	{
		
		if (window.opener)
		{
			//window.opener.location.reload();
			//window.open('Create_Stage.cfm','mainwindow');
			//window.location.href="Create_Stage.cfm";
			window.opener.location.href="Create_Classifications.cfm";
		}
		window.close()
	}
	refeshOpener()
	</SCRIPT>
<CFELSE>
	<CFIF FORM.Deleted EQ 1 AND FORM.Is_Default NEQ 0>
		<CFSET reasonHere = 1>
	<CFELSE>
		<CFSET reasonHere = 2>
	</CFIF>
	<cfset useLakebaseForGet_all = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
<cfif useLakebaseForGet_all>
	<cftry>
		<cfset Get_all = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_classification", {
				"deleted" = "eq.0",
				"dd_classification_id" = "neq.#FORM.DD_Classification_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_all = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_all>
<CFQUERY NAME="Get_all" DATASOURCE="#Application.Datasource#">
		SELECT * FROM DD_Classification WHERE Deleted=0 AND DD_Classification_ID <> '#FORM.DD_Classification_ID#'
	</CFQUERY>
</cfif>
	<FORM NAME="DeleteAction" ACTION="DeleteDefault.cfm" METHOD="Post">
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="DelActSubmitted" VALUE="0">
	<INPUT TYPE="Hidden" NAME="DD_Classification_Desc" VALUE="#FORM.DD_Classification_Desc#">
	<INPUT TYPE="Hidden" NAME="DD_Classification_ID" VALUE="#FORM.DD_Classification_ID#">
	<INPUT TYPE="Hidden" NAME="Deleted" VALUE="#FORM.Deleted#">
	<INPUT TYPE="Hidden" NAME="Is_Default" VALUE="#FORM.Is_Default#">
	</CFOUTPUT>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD COLSPAN="100%" ALIGN="Center">
					<FONT SIZE="2" COLOR="Red"><B>
					<CFIF reasonHere EQ 1>
						You are about to inactivate the current default classification
					<CFELSE>
						You are about to reset the current default classification as not default any more
					</CFIF>					
					</B></FONT><BR><BR><BR>
				</TD>
			</TR>
			<TR>
				<TD ALIGN="Center"><B>Select new default classification:</B>
					<SELECT NAME="New_Default" ONCHANGE="Javascript: makeChanges()">
						<OPTION VALUE="">
						<CFOUTPUT QUERY="Get_all">
							<OPTION VALUE="#DD_Classification_ID#">#DD_Classification_Desc#</OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="100%" ALIGN="Right"><BR><BR><BR><B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="Javascript: closeWind()">abort</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
			</TR>
		</TABLE>
	</FORM>
		
</CFIF>

<SCRIPT language="JavaScript">
function closeWind()
{
	window.close()	
}

function makeChanges()
{
	if (document.all.New_Default.value == "")
	{
		alert("Please select a classification.")
	}
	else
	{
		var confirmAction = confirm("Press OK to set the selected classification as default.");
		if (confirmAction == true)
		{		
			document.all.DelActSubmitted.value=1
			document.DeleteAction.submit();
		}
		else
		{
			window.close()
		}
	}
}
</SCRIPT>

</body>
</html>
