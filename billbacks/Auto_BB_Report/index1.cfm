<cfsilent>
<cfparam name="url.command" 	default="AutoPayReport">
<cfparam name="form.command" 	default="#url.command#">
<cfswitch expression="#form.command#">
	<!------ create / edit clause category ----->
	<cfcase value="settings" delimiters=",">		
		<cfset selectedIndex = 0>
	</cfcase>
	<!------ list/search clause category ----->
	<cfcase value="AutoPayReport" delimiters=",">
		<cfset selectedIndex = 1>
	</cfcase>		
</cfswitch>
</cfsilent>
<cfmodule template="/customTags/layout.cfm" 
							layoutID = "autoPay" 
							selectedIndex = "#selectedIndex#" 
							jQueryNoConflict = "yes" >
<CFOUTPUT>
<CFSET PAGE_TITLE="Clause Library">
<BR>

<CFSET URL.PageTitle="Payables: Manage Auto Pay">
<!--- bgcolor="#iif(CurrentRow Mod 2, de('ffffff'), de('C6FFC6'))#" --->

<CFSET ThisPage = CGI.SCRIPT_NAME>
<cfif ListFindNoCase("", form.command, ",")>
	<cfinclude template="/includes/call_please_wait.cfm">
</cfif>
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
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Removes HTML from the string.																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
<cfinclude template="/script/cf/string_functions.cfm">


<span ID="Hide_For_Please_Wait">

<!---dont't display headers for these commands--->
<cfset noHeaderCommands = "">

<!------ TODO: get clauseLibraryAccess ----->
<!------ 
<cfset clauseLibraryManager = CreateObject("component", "components.clause_library.ClauseLibraryManager").init() />
<cfset clauseLibraryAccess = clauseLibraryManager.getClauseLibraryAccess(request.AccessStructure.Profiles_ID)> 
----->
<!--- <cfset clauseLibraryAccess = 1 /> --->

<!---<cfif NOT ListFindNoCase(noHeaderCommands, form.command, ",")>
	<cfinclude template="header.cfm">
	<CFINCLUDE TEMPLATE="/includes/header.cfm">
</cfif>--->
<!--- Dev Note: KAL; D7109 --->
<cfset _hlp_current_script_path = "#CGI.SCRIPT_NAME#/command=#form.command#">
<CFSET GetHelpURL =1> <!--- This stops the [get help] from displaying twice--->
<!--- End Note: KAL; D7109 --->
<div style="height:650px;">
<!---switch for mode--->
<cfswitch expression="#form.command#">

	<!------ create / edit clause category ----->
	<cfcase value="settings" delimiters=",">		
		<cfinclude template="Auto_Pay_Settings.cfm" />
	</cfcase>
		
	<!------ list/search clause category ----->
	<cfcase value="AutoPayReport" delimiters=",">
		<cfinclude template="index.cfm" />
	</cfcase>	
		
</cfswitch>
</div>
</span>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</CFOUTPUT>
</cfmodule>