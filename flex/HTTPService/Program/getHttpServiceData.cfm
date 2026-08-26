<cfsetting enablecfoutputonly="true" showdebugoutput="false">	
<!--- When HTTPServiceSessionExpired is 1, then CF session has expired, so not send any data to flex --->
<!--- AccessStructure code is copied from application_common.cfm. Since this file is not using application_common.cfm,
I needed this AccessStructure code here. --->
<cfif isdefined("session.AccessStructure") and (session.User_id eq cookie.User_Id)>
	<cfset request.AccessStructure = Session.AccessStructure>
	<!--- Include "session_tracker.cfm" only when we "request.AccessStructure" properly defined --->
	<CFINCLUDE TEMPLATE = "/session_tracker.cfm">
<cfelse>
	<cfif IsDefined("cookie.User_Info")>
		<!--- Deserialize WDDX user info packet that lives in the cookie --->
		<CFWDDX ACTION="WDDX2CFML" INPUT="#cookie.User_Info#" OUTPUT="request.AccessStructure">
		<!--- Write it to the session to avoid this next time...This may reduce WDDX parse errors--->
		<cfset Session.AccessStructure = request.AccessStructure>
		<cfset Session.User_id = request.AccessStructure.User_ID>
		<!--- Include "session_tracker.cfm" only when we "request.AccessStructure" properly defined --->
		<CFINCLUDE TEMPLATE = "/session_tracker.cfm">
	</cfif>
</cfif>


<cfif IsDefined("HTTPServiceSessionExpired") and HTTPServiceSessionExpired eq 0><cfsilent>
	<!--- D30168:Event error in program search START --->
<cfparam name="URL.Include_work_in_progress_below_me" default="0">
<cfparam name="URL.Creating_User_Position" default="0">
<cfparam name="URL.sStartDate" default="">
<cfparam name="URL.sEndDate" default="">
	<!--- D30168:Event error in program search END --->
<!--- The query below returns data in CSV format --->
<cfheader name="Cache-Control" value="no-store">
<cfheader name="expires" value="#now()#"> 

<cfset obj = CreateObject("component", "mvc.Models.Program.Search_Program") />

<cfset ProgramDetails = obj.getScoreCardData (

	userid = URL.UserID,

	startDate = URL.sStartDate,

	endDate = URL.sEndDate,

	showCatalog = URL.showCatalog,
	
	Include_work_in_progress_below_me = URL.Include_work_in_progress_below_me,
		
	Creating_User_Position = URL.Creating_User_Position

) />
<!--- I added a trailing comma at the end. This makes sure that the last column gets into flex correctly --->
<cfset ProgramHeader = 'contract_main_id'& ','& 'contract_reference_number'& ','&'contract_title'& ','&'status_id'& ','&'revision_version'& ','&'prefixed_contract_number'& ','&'searchable_contract_number'& ','&'contract_number'& ','&'contract_start_date'& ','&'contract_end_date'& ','&'status_abbreviation'& ','&'contract_status_type_desc'& ','&'rsp_user'& ','&'creator_user'& ','&'rfa_user'& ','&'approver_user'& ','&'owner_position'& ','&'rfa_position'& ','&'approver_position'& ','&'created_type'& ','&'include_claim_rates_report'& ','&'include_pricing_report'& ','&'payment_history'& ','&'approved_status'& ','&'is_catalog'& ','&'is_autorenew'& ','&'autorenew_pairs'& ','&'doc_attached'& ','&'revision_in_process'& ','&'rollover'& ','&'cancelled'& ','&'rfa_age'& ','&'program_post_approval_status_id'& ','&'disagreed'& ','&'expiring_no_revisions'& ','&'program_trade_spend'& ','&'program_volume'& ','&'program_payment'& ','&'Best_Plan_Program'& ','&'program_released'& ','&'acknowledged'& ','&'not_acknowledged'& ','&'release_eligible'& ','&'claim_mechanics'& ','&'business_segment'& ','&'legacy_id'& ','&'creation_method'& ','&'operator_id'& ','&'operator_name'&','>
</cfsilent><cfoutput>#ProgramHeader##chr(13)##chr(10)#</cfoutput>
<cfoutput query="ProgramDetails">#Prog_Details##chr(13)##chr(10)#</cfoutput>
</cfif>