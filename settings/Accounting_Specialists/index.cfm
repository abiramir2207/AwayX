<CFOUTPUT>
<CFSET PAGETITLE = "PROGRAMS: PAYMENT PROCESSOR">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE></TITLE>

<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="accounting_specialists.js"></SCRIPT>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Accounting Specialists List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFPARAM NAME="url.display" 	DEFAULT="profile">
<CFPARAM NAME="form.display" 	DEFAULT="#url.display#">
<CFPARAM NAME="form.command" 	DEFAULT="">
<cfparam name="form.Accounting_Specialist_ID" default="">

<cfscript>
	AccountingSpecialists = CreateObject("component","components.settings.AccountingSpecialists.AccountingSpecialists");
</cfscript>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD SPECIALIST///////////--->
<cfif form.command eq "add">

	<cfset AccountingSpecialists.add(form.Accounting_Specialist_Name) />
	
<!---/////////////EDIT SPECIALIST///////////--->
<cfelseif form.command eq "edit">
	
	<cfset AccountingSpecialists.update(form.Accounting_Specialist_ID, form.Accounting_Specialist_Name) />
	
<!---/////////////DELETE SPECIALIST///////////--->
<cfelseif form.command eq "delete">

	<cfset AccountingSpecialists.delete(form.lAccounting_Specialist_ID) />

<!---/////////////ADD PROFILE ACCESS///////////--->
<cfelseif form.command eq "applyProfileAccess">

	<cfparam name="form.Profiles_ID" default="" />
	<cfset AccountingSpecialists.addProfileAccess(form.Profiles_ID) />
	
</cfif>
	
<cfset form.command = "" />

<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->

<!---/////////////DISPLAY LIST///////////--->
<cfif form.display eq "list">
	
	<cfset qGetSpecialists = AccountingSpecialists.get() />
	
<!---/////////////DISPLAY EDIT///////////--->
<cfelseif form.display eq "edit">

	<cfset qGetSpecialist = AccountingSpecialists.get(form.Accounting_Specialist_ID) />
	<cfset form.Accounting_Specialist_Name = qGetSpecialist.Accounting_Specialist_Name />

<!---/////////////DISPLAY PROFILES///////////--->
<cfelseif form.display eq "profile">

	<cfset qGetProfiles = AccountingSpecialists.getProfiles() />
	<cfset lProfileAccess = AccountingSpecialists.getProfileAccessList() />
	
</cfif>

<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<cfinclude template="_accounting_specialists_header.cfm" />

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!---switch for each action--->
<cfswitch expression="#form.display#">
	
	<cfcase value="list">
		<cfinclude template="_accounting_specialists_list.cfm" />
	</cfcase>
	
	<cfcase value="add,edit">
		<cfinclude template="_accounting_specialists_add_edit.cfm" />
	</cfcase>
	
	<cfcase value="profile">
		<cfinclude template="_accounting_specialists_profiles.cfm" />
	</cfcase>
	
</cfswitch>	

<cfoutput>
<!---hidden form fields--->
<input name="display" type="hidden" value="#form.display#" />
<input name="command" type="hidden" value="#form.command#" />
<input name="Accounting_Specialist_ID" type="hidden" value="#form.Accounting_Specialist_ID#" />
</cfoutput>
</FORM>

</BODY>
</HTML>
