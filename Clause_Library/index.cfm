<CFOUTPUT>
<CFSET PAGE_TITLE="Clause Library">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>#PAGE_TITLE#</TITLE>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" TOPMARGIN="0" onload="">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFSET ThisPage = CGI.SCRIPT_NAME>
<cfparam name="url.command" 	default="sClauseCategory">
<cfparam name="form.command" 	default="#url.command#">

<cfif ListFindNoCase("", form.command, ",")>
	<cfinclude template="/includes/call_please_wait.cfm">
</cfif>

<cfinclude template="/common_files/jQuery.cfm">

<script language="JavaScript">
	//show_please_wait(document.all.Hide_For_Please_Wait);
	function show_please_wait(hideForm)
	{
		document.all.PleaseWaitMessage.style.display = "";
		hideForm.style.display = "none";
	}

	//function will show delete category alert message
	function alertDelete(Clause_Category_ID)
	{
		if(confirm("By deleting a clause it will be removed from all templates and all programs. Do you want to continue?"))
		{
			window.location="/Clause_Library/index.cfm?command=delCategory&id="+Clause_Category_ID;
		}
		else
		{
			return false;
		}
	}

</script>

<cfparam name="url.update" default="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Removes HTML from the string.																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/script/cf/string_functions.cfm">
<span ID="Hide_For_Please_Wait">

<!---dont't display headers for these commands--->
<cfset noHeaderCommands = "dClause,spClause,eClauseProgram,arClauseProgram,sClauseProgram,dClauseProgram,elClauseProgram">
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<!--- Dev Note: Kal; D44629: French Clause variables --->			
<cfparam name="bFrenchClause" 				default="0">
<cfset variables.oLabels = CreateObject("component","components.settings.labels.labels").init() />
<cfset variables.qGetProgramLabelSetNames = variables.oLabels.GetProgramLabelSetNames() />
<cfset variables.labelSetNamesList = valueList(variables.qGetProgramLabelSetNames.Label_Set_Name) />
<cfset bFrenchClause = listFindNoCase(variables.labelSetNamesList,"French") />


<!------ TODO: get clauseLibraryAccess ----->
<!------
<cfset clauseLibraryManager = CreateObject("component", "components.clause_library.ClauseLibraryManager").init() />
<cfset clauseLibraryAccess = clauseLibraryManager.getClauseLibraryAccess(request.AccessStructure.Profiles_ID)>
----->
<cfset clauseLibraryAccess = 1 />

<cfif NOT ListFindNoCase(noHeaderCommands, form.command, ",") AND clauseLibraryAccess>
	<cfinclude template="header.cfm">
	<CFINCLUDE TEMPLATE="/includes/header.cfm">
</cfif>
<!--- Dev Note: KAL; D7109 --->
<cfset _hlp_current_script_path = "#CGI.SCRIPT_NAME#/command=#form.command#">
<CFSET GetHelpURL =1> <!--- This stops the [get help] from displaying twice--->
<!--- End Note: KAL; D7109 --->

<cfif url.update>
	<br><br>
	<div style="margin-top:-16px; margin-bottom:-16px;padding:5px;width:40%;border:solid;border-width:2px;border-color:orange;color:green;text-align:center;font-weight:bold;">Successfully updated Clause Name !!</div>
</cfif>

<!---switch for mode--->
<cfswitch expression="#form.command#">
<!--- Dev Note: Milan - 19623/25647: If "simple clauses" is ON, show new clauses functionalty, else the
      old one (The filename has the prefix "original").
--->
	<!------ create / edit clause category ----->
	<cfcase value="ceClauseCategory,svClauseCategory" delimiters=",">
		<cfif clauseLibraryAccess>
		  <cfif appSettings.getSimpleClause() eq 1>
			<cfinclude template="clause_category.cfm" />
		  <cfelse>
			<cfinclude template="original_clause_category.cfm" />
		  </cfif>
		</cfif>
	</cfcase>

	<!------ delete category ----->
	<cfcase value="delCategory">
		<cfset clauseCategoryManager = CreateObject("component", "components.clause_library.ClauseCategoryManager").init() />
		<cfset clauseCategoryManager.delete(url.id) />
		<cflocation url="index.cfm?command=sClauseCategory" />
	</cfcase>

	<!------ list/search clause category ----->
	<cfcase value="sClauseCategory" delimiters=",">
		<cfif clauseLibraryAccess>
		   <cfif appSettings.getSimpleClause() eq 1>
			<cfinclude template="clause_category_search.cfm" />
		   <cfelse>
			<cfinclude template="original_clause_category_search.cfm" />
		   </cfif>
		</cfif>
	</cfcase>

	<!------ search ----->
	<cfcase value="sClause" delimiters=",">
		<cfif clauseLibraryAccess>
		  <cfif appSettings.getSimpleClause() eq 1>
			<cfinclude template="clause_library_search.cfm">
		  <cfelse>
			<cfinclude template="original_clause_library_search.cfm">
		  </cfif>
		</cfif>
	</cfcase>

	<!------ popup search ----->
	<cfcase value="spClause" delimiters=",">
	 <cfif appSettings.getSimpleClause() eq 1>
		<cfinclude template="clause_library_search_popup.cfm">
	 <cfelse>
		<cfinclude template="original_clause_library_search_popup.cfm">
	 </cfif>
	</cfcase>

	<!------ display ----->
	<cfcase value="dClause">
		<cfinclude template="clause_library_display.cfm">
	</cfcase>

	<!------ delete clause ----->
	<cfcase value="delClause,delmsgClause">
	  <cfif appSettings.getSimpleClause() eq 1>
		<cfinclude template="clause_library_delete.cfm">
	  <cfelse>
		<cfinclude template="original_clause_library_delete.cfm">
	  </cfif>
	</cfcase>

	<!------ Create/edit, save ----->
	<cfcase value="ceClause,svClause" delimiters=",">
		<cfif clauseLibraryAccess>
		  <cfif appSettings.getSimpleClause() eq 1>
			<cfinclude template="clause_library_create_edit.cfm">
		  <cfelse>
			<cfinclude template="original_clause_library_create_edit.cfm">
		  </cfif>
		</cfif>
	</cfcase>

	<!------ edit from program ----->
	<cfcase value="eClauseProgram" delimiters=",">
		<cfif clauseLibraryAccess>
		  <cfif appSettings.getSimpleClause() eq 1>
			<cfinclude template="clause_library_create_edit.cfm">
		  <cfelse>
			<cfinclude template="original_clause_library_create_edit.cfm">
		  </cfif>
		</cfif>
	</cfcase>

	<!------ program clause ----->
	<cfcase value="sClauseProgram,dClauseProgram,arClauseProgram,elClauseProgram" delimiters=",">
	 <cfif appSettings.getSimpleClause() eq 1>
		<cfinclude template="clause_program_add_remove.cfm">
	 <cfelse>
		<cfinclude template="original_clause_program_add_remove.cfm">
	 </cfif>
	</cfcase>

</cfswitch>

</span>
<script language="JavaScript">
	function search_popup(sUrl)
	{
		NewWindow(sUrl, 'zipcode_search', '800', '600', 'Yes', 'No', true);
		return false;
	}
</script>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START
What  I did: Added New Jquery Text Editor WYUIWYG--->
		<script type="text/javascript" src="/Script/Editor/scripts/wysiwyg.js"></script>
		<script type="text/javascript" src="/Script/Editor/scripts/wysiwyg-settings.js"></script>
		<script type="text/javascript">
			WYSIWYG.attach('all', full);
		</script>
<!--- End Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  --->

</BODY>
</HTML>
</CFOUTPUT>