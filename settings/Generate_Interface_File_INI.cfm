<!------ Generate_Interface_File_INI.cfm ----->

<cfquery name="getDBName" datasource="#application.datasource#">
	select TOP 1 TABLE_CATALOG DB_NAME  from INFORMATION_SCHEMA.TABLES
</cfquery>
<cfset DB_NAME = getDBName.DB_NAME />

<!------ 
<cfswitch expression="#thisEnv#">
	<cfcase value="DEV">
		<cfset onDemandChangeProcessJobName = "BSA_ICM_4354_CHANGES" />
	</cfcase>
	<cfcase value="TST">
		<cfset onDemandChangeProcessJobName = "BSA_ICM_4354_CHANGES_TEST" />
	</cfcase>
	<cfcase value="QAS">
		<cfset onDemandChangeProcessJobName = "BSA_ICM_4354_CHANGES" />
	</cfcase>
</cfswitch>
 ----->
<cfset onDemandFeedbackJobName = "#DB_NAME#_Program_Feedback_Priority" />