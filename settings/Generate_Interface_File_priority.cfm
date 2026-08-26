<cfparam name="form.programNumberList" 	default="">
<cfparam name="form.generateNow" 	default="0">
<cfparam name="url.action" 	default="">

<cfset jobName = "Conagra_ICMQAS_Program_Interface_4354_PRIORITY" />

<cfoutput>

<cfif Left(url.action, 5) EQ "start">
	
	<!------ call price chnage file ----->
	<cfhttp url="#application.HTTPVar##CGI.SERVER_NAME#/scheduled/Update_Fixed_Price_Difference.cfm" method="get" resolveurl="no">
	
	<cfquery name="qCallJob" datasource="#application.datasource#">
	EXEC msdb..sp_start_job @job_name = '#jobName#', @step_name = 'Conagra_ICM_Program_Interface_4354_P#Right(url.action, 1)#'
	</cfquery>
	
	<cfmail to = "dkunnath@bigredflame.com"
			from = "dkunnath@bigredflame.com"
      		subject = "Thanksgiving program Interface priority initiated from #CGI.Server_Name#"
			>
		Thanksgiving program Interface priority initiated from #CGI.Server_Name# at #DateFOrmat(Now(), "mm/dd/yyyy")# #TimeFOrmat(Now(), "hh:mm:ss tt")#
	</cfmail>
		
	<cflocation addtoken="No" url="Generate_Interface_File_Priority.cfm?action=addedNow">
	
</cfif>

<cfquery name="qGetJobStatus" datasource="#application.datasource#">
	EXEC  msdb..sp_help_job @job_name = '#jobName#', @job_aspect = 'JOB', @execution_status = 1
</cfquery>

<cfset alreadyRunning = 0>
<cfif qGetJobStatus.recordCount GT 0>
	<cfset alreadyRunning = 1>
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>	
	<cfif alreadyRunning EQ 1>
	<META HTTP-EQUIV="Refresh" CONTENT="5">
	</cfif>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "PROGRAMS: GENERATE INTERFACE FILE">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfinclude template="Generate_Interface_File_Header.cfm">

<br><br>
<br><br><br><hr color="orange">

<cfif url.action EQ "addedNow">
	<!------ show message ----->
	<center>
	<font color="green" size="+2">
	The process has been initiated. The file will be posted in the FTP server.
	</font>
	<br><br>
	<a href="Generate_Interface_File_priority.cfm"><B>4354 Jobs for Thanks Giving weekend</B></a>
	<br><br>
	</center>
<cfelse>

	
	<cfif alreadyRunning>
		<center>
		<font color="green" size="+2">
		The job is still executing.
		</font>
		<br><br>
		<a href="Generate_Interface_File_priority.cfm"><B>4354 Jobs for Thanks Giving weekend</B></a>
		<br><br>
		</center>
	<cfelse>
		<cfloop index="i" from="1" to="4">
		<a href="Generate_Interface_File_Priority.cfm?action=start#i#"><B>Click here to start set #i#</B></a> (File name: F4354_AWAYX_IN_P#i#)
		<br><br>
	   </cfloop>	
	</cfif>
	
</cfif>

<hr color="orange">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>


</cfoutput>
