<cfparam name="url.User_Id" default="">
<cfparam name="url.CID" default="">
<!--- Dev Note: KAL; 8891 --->
<cfparam name="userName" default="">
<cfparam name="evalAction" default="">
<cfparam name="notes" default="">
<cfparam name="mode" default="0">
<cfparam name="Contract_Number" default="">
<cfparam name="NoteType" default="1">
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset display_business_consideration = 0 ><!--- Dev Note: KAL; 8891 --->
<cfif Get_Profile_Settings.Internal_Notes EQ 1 and appSettings.getbusinessconsiderations_on() EQ 1>
	<cfset display_business_consideration = 1 ><!--- Dev Note: KAL; 9559 --->
</cfif>

<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<CFSET URL.Contract_Main_ID = cryp.value>
<cfoutput>
<CFIF URL.User_Id is NOT "">

	<CFSET RejectEmailProgramId 	= URL.Contract_Main_ID />
	<CFSET RejectEmailUserId 	= URL.User_Id />
		<!--- Dev Note: KAL;  8891 --->
		<cfif display_business_consideration and notes NEQ ""> <!--- Dev Note: KAL; 9559 --->
			<cfset useLakebaseForpostEvaluationNotes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_evaluation_notes")>
<cfif useLakebaseForpostEvaluationNotes>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_evaluation_notes", {
			"entered_by" = "#form.userName#",
			"eval_action" = "#form.evalAction#",
			"notes" = "#trim(form.notes)#",
			"contract_number" = "#form.Contract_Number#",
			"contract_notes_type" = "#NoteType#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForpostEvaluationNotes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForpostEvaluationNotes>
<cfquery name="postEvaluationNotes" datasource="#application.datasource#">
				INSERT INTO Contract_Evaluation_Notes 
						(Entered_By, Eval_Action, Notes, Contract_Number, Contract_Notes_Type)
				VALUES	('#form.userName#','#form.evalAction#','#trim(form.notes)#','#form.Contract_Number#', '#NoteType#')
			</cfquery>
</cfif>
		</cfif>
	
<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.standard_program_approval") />
<cfset getuseremails = ApprovalProgramManager.getUsersInfo(RejectEmailProgramId,RejectEmailUserId)>
<cfset fromemail="#getuseremails.User_Email#">
<cfset toemail="#getuseremails.RFA_Email#;#getuseremails.RSP_Email#">
<cfset subject="Program #getuseremails.contract_number#/#getuseremails.contract_title# rejected">
<CF_EMAILWRAPPER 
						TO			=	"#toemail#"
				        FROM		=	"#fromemail#"
				        SUBJECT		=	"#subject#"
						TYPE		=	"html" 
						messagetype="1" 
						generatedby="2"
						appArea="1"
					>				
		Rejected By: #getuseremails.user_name#<br>
		Date: #Dateformat(now(),"mm/dd/yyyy")#<br>
		Comments:#form.notes#
</CF_EMAILWRAPPER>	

	<cfset useLakebaseForsaveBusinessConsiderations = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForsaveBusinessConsiderations>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#RejectEmailProgramId#"
			},
			{
				"broker_approved" = "0",
				"contract_status_type_idx" = "1",
				"rejected" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForsaveBusinessConsiderations = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveBusinessConsiderations>
<CFQUERY NAME="saveBusinessConsiderations" datasource="#application.datasource#">
		UPDATE Contract_Main
		set broker_approved = 0,
		contract_status_type_idx =1,
		rejected = 1
		WHERE Contract_Main_ID = '#RejectEmailProgramId#'
	</CFQUERY>
</cfif>

	<cfset useLakebaseFordeleteagree = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_agree")>
<cfif useLakebaseFordeleteagree>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_agree", {
			"programid" = "eq.#RejectEmailProgramId#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteagree = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteagree>
<CFQUERY NAME="deleteagree" datasource="#application.datasource#">
	delete from
	Program_Agree
	where ProgramId= '#RejectEmailProgramId#'
	</CFQUERY>
</cfif>
</CFIF>
 <form name="FrmApproveAction" target="mywindowname" action="contract_edit_menu.cfm?CID=#URL.CID#" method="post">
</form> 
</cfoutput>
<script>
	FrmApproveAction.submit();
	window.close();
</script>