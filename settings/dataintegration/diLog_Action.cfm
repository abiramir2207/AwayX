<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->

<CFINCLUDE template="diLog_Include.cfm">

<!--------Set defaults------------->
<CFPARAM NAME="Form.logtable" DEFAULT="">
<CFPARAM NAME="Form.IDName" DEFAULT="">
<CFPARAM NAME="Form.logID" DEFAULT="">

<CFSET userID=request.AccessStructure.user_id>
<CFSET fromAction=true>
<!--------End Set defaults------------->



<!----------------------------------------------
Get Form Data
---------------------------------------->
<CFSET thisLogtable=Form.logtable>
<CFSET IDName=Form.IDName>
<CFSET thisLogID=Form.logID>

<!----------------------------------------------
End Get Form Data
---------------------------------------->

<CFSCRIPT>
allClear = true;
returnPage=2;
</CFSCRIPT>

<!----------------------------------------
Get Form Field Name
---------------------------------------->
<CFIF (ListLen(logTables,",") EQ ListLen(logItems,",")) AND (ListLen(logTables,",") EQ ListLen(originalDB,","))>
	
	<cfset thisLogtableIndex=ListFindNoCase(logTables, thisLogtable,",")>
	<cfif NOT thisLogtableIndex>
		<cfset allClear=false>
		<cfset writeToErrorMessage("Log table name not found in the available list","error_logDetails")>
	</cfif>
		
	<cfif NOT isNumeric(thisLogID)>
		<cfset allClear=false>
		<cfset writeToErrorMessage("Invalid Log ID","error_logDetails2")>
	<cfelse>
		<cfset thisLogID=Val(thisLogID)>
	</cfif>
	
	<cfoutput>
	<cfif allClear>
		<CFQUERY NAME="q_diLogFields" datasource="#application.datasource#">
			SELECT lower(column_name) as column_name,data_type,character_maximum_length
		    FROM information_schema.columns 
		    WHERE table_name='#thisLogtable#'
		</CFQUERY>
		<CFIF q_diLogFields.recordCount GT 0>			
			<br>
			<cfset sSql="">
			<cfloop query="q_diLogFields">
				<CFIF LCase(IDName) NEQ LCase(q_diLogFields.column_name)>
					<CFIF isDefined("Form.#q_diLogFields.column_name#")>
					<cfset sSql="#sSql#,#q_diLogFields.column_name#='#Evaluate("Form.#q_diLogFields.column_name#")#'">
					</CFIF>
				</CFIF>
			</cfloop>
			<cfif Len(sSql) GT 0>
				<CFSET sSql=Right(sSql,Len(sSql)-1)>
			</cfif>
			
			<cfif Len(sSql) GT 0>
				<cfset sSql="update #thisLogtable# set #sSql# where #IDName#=#thisLogID#">
				<CFQUERY NAME="q_diLogUpdate" datasource="#application.datasource#">
				#PreserveSingleQuotes(sSql)#
				</CFQUERY>
			<cfelse>
				<cfset allClear=false>
				<cfset writeToErrorMessage("Sql generation error","error_logDetails")>
			</cfif>
		<CFELSE>
			<cfset allClear=false>
			<cfset writeToErrorMessage("Table contains no fields","error_logDetails")>
		</CFIF>
	</cfif>
	</cfoutput>
<CFELSE>
	<CFSET allClear=false>
	<CFSET writeToErrorMessage("LogTable List Error, contact administrator","error_logDetails")>
</CFIF>
<!----------------------------------------
End Get Form Field Name
---------------------------------------->




<CFIF allClear>
	<!--------
	1. Update record
	2. Redirect to diLogPage
	--------->

	<!---------1. Insert new record------>
	
	
	<!---------2. Redirect to diLogPage------>	
	
	<CFLOCATION url="#diLogPage#?sActionMsg=Updated Log file">
	
<CFELSE>	
	<!----
	Some error occured, so show the dataIntegration.cfm with
	Error Message
	and also fill the form with the last edited but still not updated data	
	------->

	<CFSET sActionErr=true>
	<CFSET action="showError">
	<CFIF returnPage EQ 1>
		<CFINCLUDE template="#diLogPage#">
	<CFELSE>
		<CFINCLUDE template="#diLogDetailsPage#">
	</CFIF>
</CFIF>



<!-------------------------------------------------------------------------->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



