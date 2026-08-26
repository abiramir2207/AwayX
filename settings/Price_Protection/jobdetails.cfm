<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<cfparam name="url.jobid" default="">
<cfif url.jobid NEQ "">
<cfset form.job_details = 1>
<cfset priceprotectionManager = CreateObject("component", "components.settings.price_protection.price_protection_manager")>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset getjobdetails = priceprotectionManager.getjobsscheduled(url.type, url.jobid)>
<cfset getproducts = priceprotectionManager.getjobproductdetails(url.jobid)>
<cfset getoperators = priceprotectionManager.getjoboperatordetails(getjobdetails.Opr_List)>
<cfset getprograms = priceprotectionManager.getprograms(url.jobid)>
<cfoutput>
<SPAN CLASS="Title4">
<b>Job Name:</b>#getjobdetails.job_name#
<BR>
<b>Price Protection Rate</b>: $#trim(numberformat(getjobdetails.Price_Protection_Rate, '_-___.____'))#<cfif getjobdetails.Price_Protection_UOM EQ 1>/CS<cfelse>/LB</cfif>
<cfif appsettings.getSearchSequenceOn()>
<cfset form.SEARCH_SEQUENCE_ID = getjobdetails.Search_Sequence_ID>
<cfset searchSequenceManager 			= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />		
<cfset SearchSequence = searchSequenceManager.getSearchSequenceInfo(getjobdetails.Search_Sequence_ID) />
<br>Search Sequence: #SearchSequence.Search_Sequence_Desc#
</cfif>
</SPAN>
<br><br>
<table width="90%" cellpadding="2" cellspacing="0" border="0" class="maintable">
<TR BGCOLOR="FFCE84" colspan="100%">
<TD STYLE="font-size:11px;" colspan="100%">
<b>Operators</b>
</TD>
</TR>
<tr>
<cfif getoperators.recordcount GT 0>
<CFLOOP QUERY="getOperators">
		<TD CLASS="dataStyle" WIDTH="10%" VALIGN="top" BGCOLOR="F2F2F2" STYLE="cursor: help;">
										<span>
											<FONT SIZE="1">
											#ucase(trim(getOperators.Operator_Name))#
											<cfif application.returned_customer_setting.Operator_Legacy_Id_On EQ 1 AND Legacy_ID NEQ "">
											(#Legacy_ID#)<cfelse>(#BSA_Operator_ID#)</cfif>
											</FONT>
										</span>
									</TD>
									<CFIF getOperators.CURRENTROW MOD 3><CFELSE></TR><TR></CFIF>
								</CFLOOP>
<cfelse>
<td>No Operators</td>
</cfif>
</tr>
<tr><td>&nbsp;</td></tr>
<TR BGCOLOR="FFCE84" colspan="100%">
<TD STYLE="font-size:11px;" colspan="100%">
<b>Products</b>
</TD>
</TR>
<tr>
<cfif getproducts.recordcount GT 0>
<CFLOOP QUERY="getProducts">
		<TD CLASS="dataStyle" WIDTH="10%" VALIGN="top" BGCOLOR="F2F2F2" STYLE="cursor: help;">
										<span>
											<FONT SIZE="1">
											#ucase(trim(getProducts.item))#<br>
											#getProducts.description#
											</FONT>
										</span>
									</TD>
									<CFIF getProducts.CURRENTROW MOD 3><CFELSE></TR><TR></CFIF>
								</CFLOOP>
<cfelse>
<td>No products</td>
</cfif></tr>
</table></cfoutput>
<cfset form.item_list = valuelist(getproducts.BSA_Foodservice_Items_Master_ID)>
<cfset form.Operator_List = valuelist(getOperators.bsa_operator_id)>
<br><br>
<cfinclude template="get_programs_for_job.cfm">

<cfelse>
Sufficient data not provided
</cfif>

</body>
</html>
