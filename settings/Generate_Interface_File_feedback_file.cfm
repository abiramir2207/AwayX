<cfparam name="form.generateNow" 	default="0">
<cfparam name="url.action" 	default="">

<cfinclude template="Generate_Interface_File_INI.cfm">

<cfoutput>

<cfif onDemandFeedbackJobName EQ "">
	<center>
	<font color="red">
	<B>This process is not available for this environment</B>
	</font>
	</center>
	<cfabort>
</cfif>

<cfif url.action EQ "startfeedbackfile">
	
	<cfquery name="qCallJob" datasource="#application.datasource#">
	EXEC msdb..sp_start_job @job_name = '#onDemandFeedbackJobName#'
	</cfquery>
	
	<cfmail to = "dkunnath@bigredflame.com"
			from = "dkunnath@bigredflame.com"
      		subject = "Program feedback priority initiated from #CGI.Server_Name#"
			>
		Program feedback priority initiated from #CGI.Server_Name# at #DateFOrmat(Now(), "mm/dd/yyyy")# #TimeFOrmat(Now(), "hh:mm:ss tt")#
	</cfmail>
		
	<cflocation addtoken="No" url="Generate_Interface_File_feedback_file.cfm?action=addedNow">
	
</cfif>

<cfset alreadyRunning = 0>
<!------ 
<cfquery name="qGetJobStatus" datasource="#application.datasource#">
	EXEC  msdb..sp_help_job @job_name = '#onDemandFeedbackJobName#', @job_aspect = 'JOB', @execution_status = 1
</cfquery>

<cfif qGetJobStatus.recordCount GT 0>
	<cfset alreadyRunning = 1>
</cfif>
 ----->
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


<cfif url.action EQ "addedNow">
	<!------ show message ----->
	<center>
	<font color="green" size="+2">
	The process has been initiated.
	</font>
	<br><br>
	<a href="Generate_Interface_File_feedback_file.cfm"><B>Feedback file upload</B></a>
	<br><br>
	</center>
<cfelse>

	
	<cfif alreadyRunning>
		<center>
		<font color="green" size="+2">
		The job is still executing.
		</font>
		<br><br>
		<a href="Generate_Interface_File_feedback_file.cfm"><B>Feedback file upload</B></a>
		<br><br>
		</center>
	<cfelse>
		<a href="Generate_Interface_File_feedback_file.cfm?action=startfeedbackfile"><B>Click here to start feedback file upload</B></a>
		<br><br><br>
		Make sure the file <B>F4354_AWAYX_OUT_MANUAL</B> is in the appropriate FTP server
		<br>
		(DEV - /culinary, TST - /nucleus_tst, QAS - /nucleus_qas)
		<br><br>
	</cfif>
	
</cfif>

<hr color="orange">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>


</cfoutput>
