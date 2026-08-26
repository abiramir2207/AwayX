<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFSET pagetitle = "SYSTEM ADMINISTRATION: CUSTOMER SETTINGS">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="Functional_page.cfm"><B>functional fields list</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>

<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="other_fields_page.cfm"><B>other fields list</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>


<TABLE>
	<TR>
		<TD>Note : This is a list of cosmetic fields used in the application as the way you refer them. If you need any change contact our <a href = "send_email_form.cfm?nature=cosmetics">application administrator</a></TD>
	</TR>
</TABLE>

<br><br><br>

<DIV STYLE="font-size:13px;border-bottom:solid navy 1px;color:grey">LIST OF COSMETIC FIELDS</DIV>
<br><br>

<CFQUERY Name = "functional_fields" datasource="#application.datasource#">
	SELECT 		* 
	from 		customer_settings_column_nature 
	where 		column_nature = 'cosmetics' AND
				Column_Name IN (SELECT column_name FROM information_schema.columns 
								WHERE table_name = 'customer_settings')	
	ORDER BY 	column_name
</CFQUERY>

<CFSET record_count_one_less = #functional_fields.recordcount# -1>
<CFSET record_count = #functional_fields.recordcount#>

<CFSET array_column_name = ArrayNew(1)>
<CFSET array_column_description = ArrayNew(1)>

<CFOUTPUT query = "functional_fields">
<CFSET array_column_name[currentrow] = #column_name#> 
<CFSET array_column_description[currentrow] = #dispaly_label#>
</CFOUTPUT>
<CFIF record_count GT 0>
<CFQUERY name = "col_data_type" datasource="#application.datasource#">
	SELECT column_name,data_type FROM information_schema.columns 
	WHERE table_name = 'customer_settings' AND (
	<cfloop index = "loopcount" FROM = "1" TO = "#record_count_one_less#">
		column_name = '#array_column_name[loopcount]#' or
	</cfloop> 
	<cfloop index = "loopcount" FROM = "#record_count#" TO = "#record_count#">
		column_name = '#array_column_name[loopcount]#'
	</cfloop>) ORDER BY column_name
</CFQUERY>
<CFELSE>
	<CFABORT>
</CFIF>
<CFSET array_data_type = ArrayNew(1)>

<CFOUTPUT query = "col_data_type">
<CFSET array_data_type[currentrow] = #data_type#> 
</CFOUTPUT> 

<!---<cfoutput>
<cfloop index = "loopcount" from = "1" to = "#record_count#">
	#array_column_name[loopcount]#, #array_data_type[loopcount]#<br>
</cfloop>
</cfoutput>--->
<cfset useLakebaseForvalues_func_fields = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_settings")>
<cfif useLakebaseForvalues_func_fields>
	<cftry>
		<cfset values_func_fields = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvalues_func_fields = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvalues_func_fields>
<CFQUERY name = "values_func_fields" datasource="#application.datasource#">
	SELECT * from customer_settings
</CFQUERY>
</cfif>





<STYLE>
	input.small
		{
			font: 13px Arial;
			width: 250px;
		}
	input.large
		{
			font: 13px Arial;
			width: 500px;
		}
	select
		{
			font: 13px Arial;
			width: 250px;
		}
</STYLE>
<!---<CFLOOP index = "loopcount" FROM = "1" TO = "#record_count#">
			<CFSET column_value = #Evaluate("values_func_fields.#array_column_name[loopcount]#")#>
<CFOUTPUT>#column_value#</CFOUTPUT>
</cfloop>--->


<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" ALIGN="center">
<CFOUTPUT>
<CFLOOP index = "loopcount" FROM = "1" TO = "#record_count#">
	<TR>
		<TD ALIGN="right" NOWRAP VALIGN="top"><b>#array_column_description[loopcount]# :</b></TD>
		
		<CFIF array_data_type[loopcount] EQ 'bit'>
			<CFIF #Evaluate("values_func_fields.#array_column_name[loopcount]#")# EQ 1>
				<td>Yes</td>
			<CFELSE>
				<td>No</td>
			</CFIF>			
		<CFELSE>
			<TD>#Evaluate("values_func_fields.#array_column_name[loopcount]#")#</TD>
		</CFIF>
	</TR>
</CFLOOP>
</CFOUTPUT>
</TABLE>




</body>
</html>
