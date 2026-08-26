<!---------------------------------------------------------------------------------------------------------------------
Template:	/Planners/Create/planner_program_approve.cfm
Date:  		09/14/2019
Author:		Kal
Purpose:  	Single Page Planner Program Create
----------------------------------------------------------------------------------------------------------------------->
<cfdump var="#form#"/>
<cfparam name="approval_method" default="0">
<cfparam name="approved_by_user_id" default="">
<cfparam name="program_id" default="0">

<cfinclude template="/Get_Access_Profile.cfm">
<cfif Get_Profile_Settings.program_margin_approval_method IS 4> <!--- spending cap --->
    <cfset program_id =  form.program_id />
    <cfinclude template="/common_files/contracts/contract_approve_action_include.cfm" />
<cfelse>
    <cfset form.approval_method = 5 /> <!--- layered --->
    <cfset form.Approved_By_User_ID = request.AccessStructure.user_id />
    <cfset Program_ID = form.program_id />
    <cfinclude template="/common_files/contracts/Contract_layered_approve_action_Auto.cfm" />
    <!---D49082 :: Email settings for prg approval not working correctly START --->
    <cfset contract_main_id = form.program_id />
    <!--- Dev Note(49272) - On "Contract_layered_approve_action_Auto.cfm", "FORM.ApproveContract" gets set to Contract_main_ID. Resetting "FORM.ApproveContract" to CID below. --->
    <cfset FORM.ApproveContract  = contract_main_id>
    <cfset CloseWindow  = 0 >
    <cfinclude template="/common_files/contracts/generate_approve_email.cfm">
    <!---D49082 :: Email settings for prg approval not working correctly END --->
</cfif>

<script>
	opener.show_loader();
	opener.callback_approve_program();
	window.close();
</script>