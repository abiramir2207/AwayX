<!---
Name: 			claim_form_email_send.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	07/17/2009
Created By:		Tim Ford     
Description:	This file is responsible for sending an email of the One Page Claim Form
--->

<cfoutput>
<cfparam name="form.Form_ID"		default="0" />
<cfparam name="form.ClaimForm_ID"	default="0" />

<cfset variables.brokerProgramManager 	= createObject('component','components.Billback.BrokerProgramsManager').init(application.datasource) />
<cfset variables.qGetClaim 				= variables.brokerProgramManager.getClaim(form.Form_ID) />
<cfset variables.qGetClaimForm 			= variables.brokerProgramManager.getClaimForm(form.Form_ID,form.ClaimForm_ID) />
<cfif form.ClaimForm_ID neq "0">
	<cfset variables.qGetClaimFormDetails	= variables.brokerProgramManager.getClaimDetails(form.Form_ID,form.ClaimForm_ID) />
<cfelse>
	<cfset variables.qGetClaimFormDetails	= variables.brokerProgramManager.getNewClaimDetails(form.Form_ID) />
</cfif>


<!--- Date/Time stamp construction to be used in the naming scheme of the file --->
<CFSET datetimestamp = "#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">


<!--- Build file name --->
<CFSET filename_email =	"#trim(variables.qGetClaim.BA_Id)#_#trim(datetimestamp)#_#gettickcount()#">

<CFSET Claim_Form_HTML_File_Path="\temp_files\billback\HTML_Billbacks\#filename_email#.htm">

<!--- create usable directory information --->
<CFSET The_File_Location = Application.Doc_path & Claim_Form_HTML_File_Path>
<!--- end create usable directory information --->	

<!--- Build complete path --->
<CFSET completepath = The_File_Location>

<cfsavecontent variable="Claim_Form_Content">
	<cfinclude template="Claim_Form_Email.cfm" />
</cfsavecontent>

<!--- Save the file to the server --->
<cffile action="write" file="#completepath#" output="#Claim_Form_Content#">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send email..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_EMAILWRAPPER 
	TO			=	"#Form.Recipient_Email_Address#"
	FROM		=	"#request.AccessStructure.User_Email#"
	SUBJECT		=	"#Form.Sendersubject#"
	TYPE		=	"html"
	MESSAGETYPE = 	"1"
	generatedBy	=	"3"
	appArea		=	"3" 
	userid		=	"#request.AccessStructure.user_id#">		
		
	<TABLE WIDTH="100%">
		<TR VALIGN="top">
			<TD>
				#Form.Message_Body#
			</TD>		
		</TR>
	</TABLE>

	<cf_emailwrapperparam file = "#completepath#" store="yes">


</CF_EMAILWRAPPER>
<script>
	window.close();
</script>
</cfoutput>

