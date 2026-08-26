<cfparam name="url.User_Id" default="">
<cfparam name="url.CID" default="">
<CFPARAM name="Usersagreedcount" default="0"> 

<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<CFSET URL.Contract_Main_ID = cryp.value>

<CFIF URL.User_Id is NOT "">

	<cfset realProgramManager = CreateObject("component", "components.programs.ProgramManager").init() />
	<cfset realProgramManager.setUserAgree(URL.Contract_Main_ID, URL.User_Id, request.AccessStructure.Profiles_ID) />
	
	<CFSET AgreeEmailProgramId 	= URL.Contract_Main_ID />
	<CFSET AgreeEmailUserId 	= URL.User_Id />
	<cfinclude template="/Common_Files/contracts/Send_Agree_Email.cfm">
</CFIF>

<!------ Update the Pending Approval table ----->
	<cfquery name="qUpdateApprovaltable" datasource="#application.datasource#">
		EXEC Populate_Program_Approvable_Positions #URL.Contract_Main_ID#
	</cfquery> 


<!---Tim Ford - 2/13/2019: WR D83808 - Program screens duplicating after agreeing in IE and Chrome 
	Form was submitting back to home page. Removed form submit and added opener.window.location.href back to contract_edit_menu.cfm
--->

<!---
<cfoutput>
<form name="FrmApproveAction" target="mywindowname" action="contract_edit_menu.cfm?CID=#URL.CID#" method="post">
</form>
</cfoutput>
--->
<script>
	window.close();
	opener.window.location.href="contract_edit_menu.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>";
	/*
	FrmApproveAction.submit();
	window.close();
	*/
</script>

