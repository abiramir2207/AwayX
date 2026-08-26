<cfparam name="form.programNumberList" 	default="">
<cfparam name="form.generateNow" 	default="0">
<cfparam name="url.action" 	default="">
<cfif url.action eq "reset">
	<cfquery name="qResetStatus" datasource="#application.datasource#">
		UPDATE	ICM_Interface_4354_Changes	
		SET		Status_ID = 3
		WHERE	Status_ID = 1
				AND Deleted = 0
	</cfquery>
	<cflocation addtoken="No" url="Generate_Interface_4354_Change_File.cfm" />
</cfif>
<cfoutput>
<!------ check if one is already running ----->
<cfquery name="qGetExistingProgramInterface" datasource="#application.datasource#">
	SELECT	*
	FROM	ICM_Interface_4354_Changes
	WHERE	Deleted = 0
			AND Status_ID IN (1,2)
</cfquery>

<cfset existingValidStatus = ValueList(qGetExistingProgramInterface.Status_ID)>
<cfset alreadyRunning = 0>
<!------ if anuthing is running  ----->
<cfif ListFindNoCase(existingValidStatus, 1, ",")>
		<cfset alreadyRunning = 1>
</cfif>
	
<cfif form.programNumberList NEQ "" AND alreadyRunning EQ 0 AND form.generateNow EQ 1>
	
	
	<cfquery name="qInsertIntoInterfaceTable" datasource="#application.datasource#">
		INSERT INTO ICM_Interface_4354_Changes
		(Created_By, User_Email)
		VALUES 
		('#request.AccessStructure.User_ID#', '#request.AccessStructure.User_Email#')
	</cfquery>
	
	<!------ get the latest id, I don't want to use trigger :(, so assuming there will be only one with status = 1 ----->
	<cfquery name="qGetLatestId" datasource="#application.datasource#">
		SELECT	ICM_Interface_4354_Changes_ID
		FROM	ICM_Interface_4354_Changes
		WHERE	Status_ID = 1
	</cfquery>
	
	<cfset uploadId = qGetLatestId.ICM_Interface_4354_Changes_ID>
	
	<!------ delete all existing ----->
	<cfquery name="qUpdateExisting" datasource="#application.datasource#">
		UPDATE	ICM_Interface_4354_Changes_Detail
		SET		Deleted = 1
	</cfquery>
	
	<!------ loop and insert each program ----->
	<cfloop list="#form.programNumberList#" index="thisId">
	
		<!------ add to table and start job ----->
		<cfquery name="qGetContractNumber" datasource="#application.datasource#">
			SELECT	DISTINCT Contract_Number
			FROM	Contract_Main
			WHERE	Contract_Main.Contract_Main_ID = #thisId#
		</cfquery>
		<cfset contract_Number = qGetContractNumber.Contract_Number>
		<cfquery name="qInsertIntoInterfaceFile" datasource="#application.datasource#">
			INSERT INTO ICM_Interface_4354_Changes_Detail 
			(ICM_Interface_4354_Changes_ID, Program_Number, Program_ID)
			Values ('#uploadId#', '#contract_Number#', #thisId#)
		</cfquery>
		
	</cfloop>	
	
	<cfquery name="qCallJob" datasource="#application.datasource#">
	EXEC Call_ICM_4354_Change_Process_Through_Job
	</cfquery>
	
	<cfmail to = "dkunnath@bigredflame.com"
			from = "dkunnath@bigredflame.com"
      		subject = "Program Interface change process initiated from #CGI.Server_Name#"
			>
		Program Interface change process initiated from #CGI.Server_Name# at #DateFOrmat(Now(), "mm/dd/yyyy")# #TimeFOrmat(Now(), "hh:mm:ss tt")#
	</cfmail>
		
	<cflocation addtoken="No" url="Generate_Interface_4354_Change_File.cfm?action=addedNow">
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
	<cfif alreadyRunning EQ 1 AND url.action EQ "addedNow">
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
<!------ get last successful ----->
<cfquery name="qGetLastSuccessful" dbtype="query">
	SELECT	*
	FROM	qGetExistingProgramInterface
	WHERE	Status_ID = 2
	Order By Created_Date DESC
</cfquery>
<cfif qGetLastSuccessful.recordCount>
	<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(qGetLastSuccessful.Created_By)>
	<!------ TODO: ----->
	<span><font color="blue" size="+1">Previous successful extract started by #qUser.User_Full_Name# at #DateFormat(qGetLastSuccessful.Created_Date, "mm/dd/yyyy")# #TimeFormat(qGetLastSuccessful.Created_Date, "hh:mm:ss tt")#</font></span>
</cfif>
<br><br><br>
<cfif alreadyRunning EQ 1 AND url.action EQ "addedNow">
	<!------ show message ----->
	<center>
	<font color="blue" size="+2">
	The process has been initiated. We will email you the file.
	</font>
	</center>	
<cfelseif alreadyRunning>
	<!------ show message ----->
	<center>
	<font color="red" size="+2">
	A process is already running.<br>
	<a href="Generate_Interface_4354_Change_File.cfm?action=reset">Click here to reset the status</a>
	</font>
	</center>	
<cfelse>
	<script language="JavaScript">
	function showProgramSearchWindow(formName) 
	{
		NewWindow("/search_screens/program_search.cfm?FormName=" + formName + "&FieldName=programNumberList&ReturnFieldName=Contract_Main_ID", "programwindow", 800, 600, "yes", "yes");
		return false;
	}
	function confirmCompletion(formName)
	{
		if(window.confirm("Do you want to generate the file now?"))
		{
			var oForm = eval("document." + formName);
			oForm.generateNow.value = 1;
			oForm.submit();
		}
		return false;
	}
	</script>
	<!------ show form ----->
	
	<form action="" name="frmInterfaceFile" method="post">
	<table width="90%" align="center">
	<tr valign="top">
		<td>Programs
		<CF_smallLink 
			title = "search" 
			url = "##"
			parameters = "onClick=""javascript: return showProgramSearchWindow('frmInterfaceFile');"""
		>
		</td>
		<td width="80%">
		<cfif form.programNumberList NEQ "">
		<!------ get program numbers ----->
		<cfquery name="qGetprogramNumbers" datasource="#application.datasource#">
		SELECT	Contract_Number, Contract_Main_ID
		FROM	Contract_Main
		WHERE	Contract_Main.Contract_Main_ID IN (#form.programNumberList#)
		</cfquery>
		<cfparam name="maxRows" 	default="8">
		<cfset cntr = 1>
		<table>
		<tr>
		<cfloop query="qGetprogramNumbers">
			<td>#Contract_Number#</td>
			<CFIF cntr mod maxRows><CFELSE></TR><TR></CFIF>
			<CFSET cntr = cntr + 1>
		</cfloop>
		<cfloop index="i" from="#Evaluate(cntr mod maxRows)#" to="#maxRows#">
			<TD></TD>
		</CFLOOP>
		</tr>
		</table>		
		<cfelse>None
		</cfif>
		</td>
	</tr>
	<cfif form.programNumberList NEQ "">
	<tr>
		<td colspan="2" align="center">
		<br>
		<CF_button
		button_name		=	""
		button_caption	=	"Generate File"
		button_action	=	"confirmCompletion('frmInterfaceFile');"
		button_type		=	"javascript_link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
		</td>
	</tr>
	</cfif>
	</table>
	<input type="hidden" name="programNumberList" value="#form.programNumberList#">
	<input type="hidden" name="generateNow" value="0">
	</form>
</cfif>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>


</cfoutput>
