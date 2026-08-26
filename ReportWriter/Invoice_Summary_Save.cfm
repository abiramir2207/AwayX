<!---------------------------------------------------
This Page gets the Content for Invoice Criteria
and saves it to a file
and return the file name
---------------------------------------------------->

<CFSAVECONTENT VARIABLE="Summary_Content">

<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<cfset email_flag = 1>
<!---<cfinclude TEMPLATE="reportInvoiceForm.cfm">--->
<cfoutput>#session.saved_invoice_form#</cfoutput>

<cfif application.returned_customer_setting.confidentiality_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.confidentiality_switch EQ 1>
<div align="Center">
<table width="90%" BORDER="0" CELLSPACING="0" CELLPADDING="2">
	<TR>
		<TD COLSPAN="100%">
			<br>				
			<hr color="navy">
			<cfoutput>#application.returned_customer_setting.confidentiality_content#</cfoutput>
			<hr color="navy">
		</TD>
	</TR>
</table></div>
	</cfif></cfif>
	<BR><BR><BR>

</CFSAVECONTENT>

<!--- create usable directory information --->
<CFSET The_File_Location = Application.Doc_Path & '\Temp_files' & HTML_File_Path>
<!--- end create usable directory information --->	

<!--- Build complete path --->
<CFSET completepath=The_File_Location>

<!--- Save the file to the server --->
<cffile action="write" file="#completepath#" output="#Summary_Content#">

