<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<CFINCLUDE TEMPLATE="scReportCommon.cfm">

<CFPARAM NAME="URL.rID" DEFAULT="">
<CFPARAM NAME="rID" DEFAULT="#URL.rID#">
<CFPARAM NAME="reportType" DEFAULT="programSummary">

<CFIF isNumeric(rID)>
	
	<CFQUERY NAME="q_getReportDetails" datasource="#application.datasource#">
	SELECT 	rt.Report_Type_ID,rt.Report_Type,rt.User_ID,rtemp.*
	FROM	Report_Type rt,Report_Template rtemp
	WHERE	rt.Report_Type_ID=rtemp.Report_Type_ID
			and
			rt.Report_Type_ID=#rID#
	</CFQUERY>
	<CFIF q_getReportDetails.recordCount GT 0>
		<CFSET reportType=q_getReportDetails.Report_Type>
		<CFQUERY NAME="q_getReportStructure" datasource="#application.datasource#">
			SELECT 	rs.*
			FROM	Report_Type rt,Report_Structure rs
			WHERE	rt.Report_Type_ID=rs.Report_Type_ID
			and
			rt.Report_Type_ID=#rID#
		</CFQUERY>
		<!--- <cfoutput>#q_getReportDetails.Report_Type#</cfoutput>
		<cfabort> --->

		<!-----------------------------------------------------------------------
		Get Email Address from DB
		--------------------------------------------------------------------------->
		<CFQUERY NAME="q_getOwnerEmail" datasource="#application.datasource#">
		Select	User_Email,Name_First + ' ' + Name_Last as uName,company_main_id
		From	_Users
		Where	User_ID='#q_getReportDetails.User_ID#'
		</CFQUERY>
		<!-----------------------------------------------------------------------
		End - Get Email Address from DB
		--------------------------------------------------------------------------->
		
		<CFIF q_getOwnerEmail.recordCount GT 0>
			<CFSET ownerEmail=q_getOwnerEmail.User_Email>
			<CFSET ownerName=q_getOwnerEmail.uName>	
			<cfset request.AccessStructure.Company_Main_ID = q_getOwnerEmail.company_main_id>	
		<CFELSE>
			<CFSET ownerEmail="">
			<CFSET ownerName="">
		</CFIF>
		
		<cfif reportType EQ "programSummary">
			<CFINCLUDE TEMPLATE="#schProgramPage#">
		<cfelseif reportType EQ "productSummary">
			<CFINCLUDE TEMPLATE="#schProductPage#">
		<cfelseif reportType EQ "Product_Based_Margin_Analysis">
			<CFINCLUDE TEMPLATE="#schMaginProduct#">
		<cfelseif reportType EQ "Program_Based_Margin_Analysis">
			<CFINCLUDE TEMPLATE="#schMaginProduct#">
		<cfelseif reportType EQ "invoiceprogramSummary">
			<CFINCLUDE TEMPLATE="#schProgramPage#">
		<cfelseif reportType EQ "invoiceproductSummary">
			<CFINCLUDE TEMPLATE="#schProductPage#">
		<cfelseif reportType EQ "programPerformance">
			<CFINCLUDE TEMPLATE="#schPerformancePage#">
		</cfif>
		
	
	</CFIF>
	
</CFIF>
