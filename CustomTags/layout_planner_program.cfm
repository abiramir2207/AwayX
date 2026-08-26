<!---------------------------------------------------------------------------------------------------------------------
	  Template: \CustomTags\Layout_Planner_Program.cfm
		  Date:  2016 August
		Author:  Chris Nguyen
	   Purpose:  Layout template for planner program
---------------------------------------------------------------------------------------------------------------------->
<cfif thisTag.executionMode is "start"><!DOCTYPE html>
	<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<cfif structKeyExists(attributes, "page_title")>
		  <title><cfoutput>#attributes.page_title#</cfoutput></title>
		</cfif>
		<cfinclude template="/Get_Access_Profile.cfm">
		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include files="/script/javascript/modernizr.js, /script/javascript/jquery.menu-aim.js, /styles/reset.css, /styles/css-loader.css">

		<cfsavecontent variable="head_content">
			<cf_include files="/styles/mega-dropdown.css, /styles/font-awesome.min.css">

			<cfset jQueryUI.widgets = "full">
			<cfinclude template="/common_files/jQueryUI.cfm">

			<style>
				body { padding: 0px; }
				header{height:46px;background:#9BC2E6;background-image:-webkit-linear-gradient(#9BC2E6,#d8e7f5);background-image:-o-linear-gradient(#9BC2E6,#d8e7f5);background-image:linear-gradient(#9BC2E6,#d8e7f5)}
				header div { float: left; margin:8px; }
				div.header { font-size:14px; font-weight:bold; letter-spacing:0.5px; padding-top: 6px; text-align: center; }
				div#layoutBody { margin:0 5px; }
				.cd-dropdown-trigger { margin-top:3px; }
				/* original = 80
				10 20 20 20
				10 15 15 25 15 */
				#hdr415 { width: 25%;  }
				#hdr415b { width: 25%; }
				#hdr416 { width: 10%;  }
				#hdr417 { width: 10%;  }
				#hdr419 { width: 10%; padding-top: 0px; float: right; text-align: right; }
                .cd-dropdown-content {
                    width: 150px;
                }
				span.reg { font-weight: normal; }
			</style>
		</cfsavecontent>
		<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
		<cfhtmlhead text="#application.util.string.compress( head_content )#">
	</head>
	<!------------------------------->
	<!---  get the required data  --->
	<!------------------------------->
	<cfsilent>

		<cfparam name="url.bLock"       default="0" />
		<cfparam name="url.bUnLock"     default="0" />
		<cfparam name="url.bCopy"       default="0" />
		<cfparam name="url.bRevise"     default="0" />

		<cfif structKeyExists(form, "programId")>
			<cfset this.programId = form.programId />
		<cfelseif structKeyExists(url, "programId")>
			<cfset this.programId = url.programId />
		<cfelse>
			<cfset this.programId = 0 />
		</cfif>

		<cfif structKeyExists(form, "customerId")>
			<cfset this.customerId = form.customerId />
		<cfelseif structKeyExists(url, "customerId")>
			<cfset this.customerId = url.customerId />
		<cfelse>
			<cfset this.customerId = "" />
		</cfif>

		<cfif structKeyExists(form, "plannerId")>
			<cfset this.plannerId = form.plannerId />
		<cfelseif structKeyExists(url, "plannerId")>
			<cfset this.plannerId = url.plannerId />
		<cfelse>
			<cfset this.plannerId = 0 />
		</cfif>

		<cfif structKeyExists(form, "templateId")>
			<cfset this.templateId = form.templateId />
		<cfelseif structKeyExists(url, "templateId")>
			<cfset this.templateId = url.templateId />
		<cfelse>
			<cfset this.templateId = 0 />
		</cfif>

		<!--- D113406 :: STAGE2 Program Search Page.  Modify some behaviors and fix issues related to locking and Status filters --->
		<cfif structKeyExists(form, "fromProgramSearch")>
			<cfset this.fromProgramSearch = form.fromProgramSearch />
		<cfelseif structKeyExists(url, "fromProgramSearch")>
			<cfset this.fromProgramSearch = url.fromProgramSearch />
		<cfelse>
			<cfset this.fromProgramSearch = 0 />
		</cfif>


		<cfset lock_component = createObject("component", "components.general.lock") />
		<cfif structKeyExists(url, "bLock") and url.bLock eq 1>
			<cfscript>
				lock_component.Lock("Planner",this.plannerID,false);
			</cfscript>
		</cfif>
        <cfscript>
		    planner_lock_status = lock_component.getStatus("Planner", this.plannerID);
        </cfscript>

		<cfinvoke component="components.programs.distributors.Distributor" method="getDistributor" returnVariable="variables.Distributor">
			<cfinvokeargument name="distributorID" value="#this.customerId#">
		</cfinvoke>

        <!--- planner is locked by current user --->
        <cfif planner_lock_status.is_locked and planner_lock_status.Locked_By_Other eq 0>

                <!--- unlock program only when url.bUnlock exists and equals to one --->
                <cfif structKeyExists(url, "bUnLock") and url.bUnLock eq 1>
                	<cfquery datasource="#application.datasource#">
                    		EXEC USP_Contract_Lock_Unlock @User_ID = '#request.accessStructure.User_ID#', @Unlock = 1, @Unlock_Program_ID = #this.programId#
                    	</cfquery>
                <cfelseif  url.bLock eq 1>
                    	<!--- default to edit mode automatically  --->
                    	<cfquery datasource="#application.datasource#">
                    		EXEC USP_Contract_Lock_Unlock @User_ID = '#request.accessStructure.User_ID#', @LOCK = 1, @Lock_Program_ID = #this.programId#
    		    	</cfquery>
                </cfif>

        </cfif>

 		<cfif planner_lock_status.is_locked and planner_lock_status.Locked_By_Other eq 0>
			<cfif structKeyExists(url, "bUnLock") and url.bUnLock eq 1>
				<cfscript>
					lock_component.unlockByID("Planner", this.plannerID);
				</cfscript>
			<cfelse>
				<cfscript>
					//Not Needed if: is_locked ==1 and planner_lock_status.Locked_By_Other eq 0
					//lock_component.Lock("Planner",this.plannerID,false);
				</cfscript>
			</cfif>

		<cfelseif url.bLock eq 1>
				<cfscript>
					lock_component.Lock("Planner",this.plannerID,false);
				</cfscript>
		</cfif>

		<cfset planner_lock_status = lock_component.getStatus("Planner", this.plannerID) />


		<cfquery name="qGetProgramInfo" datasource="#application.datasource#">
			SELECT  Contract_Main_ID, Contract_Is_Locked, Contract_Locked_By_User_ID, cm.Approved, cm.Contract_Status_Type_IDX, Status_Abbreviation,
					ISNULL(p.Approved, 0) as Planner_Approved, cm.ProgramType_ID, cm.Is_A_Revision, isnull(cm.Revision_of_Contract_Main_ID, 0) as Parent_Program_ID, cm.Contract_Number, cm.revision_version,
					p.Planner_NickName, cm.External_Client_Ack_Date, cm.Cancelled_by, PCPO.Check_Duplicate_Program, PCPO.Created_Type, PCPO.Discount_Lump_Sums_Document_Attachment_Mandated,
					cm.Released, PCPO.Document_Attachment_Required
			FROM    Contract_Main cm
			INNER JOIN Contract_Status_Types cst on cm.Contract_Status_Type_IDX = cst.Contract_Status_Type_ID
			LEFT JOIN Planners p ON p.Planner_ID = cm.Planner_ID
			INNER JOIN Program_Control_Panel_Options PCPO ON PCPO.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
			WHERE   Contract_Main_ID =  '#this.programId#'
		</cfquery>
		<cfset appSettings = application.appsettingsGet />

		<cfset bContractIsLocked = 1 />
		<cfif qGetProgramInfo.RecordCount and qGetProgramInfo.Contract_Locked_By_User_ID eq request.accessStructure.User_ID and qGetProgramInfo.Contract_Is_Locked eq 1>
			<cfset bContractIsLocked = 0 />
			<cfset url.bLock = 1 />
		<cfelse>
			<cfset bContractIsLocked = 1 />
			<cfset url.bLock = 0 />
		</cfif>

		<cfif this.programId eq 0>
			<cfset bContractIsLocked = 0 />
			<cfset url.bLock = 1 />
		</cfif>
		<cfif url.bCopy eq 1>
			<cfset bContractIsLocked = 0 />
			<cfset url.bLock = 1 />
		</cfif>

		<cfset letUserProceed = 1>
		<cfset messageArray = ArrayNew(1)>

		<cfquery name="getSettings" datasource="#application.datasource#">
			SELECT  *
			FROM    Program_Control_Panel_Options
			WHERE   ProgramControl_Panel_Options_ID = '#(qGetProgramInfo.recordCount ? qGetProgramInfo.ProgramType_ID : this.templateId)#'
				</cfquery>
		<cfif qGetProgramInfo.Contract_Status_Type_IDX EQ 1 AND Val(this.programId) NEQ 0>
				<cfset Contract_Main_ID = this.programId />

				<cfinclude template="\Common_Files\contracts\common_program_level_check.cfm">

                <cfif appSettings.getBudgetsFunctionalityOn() and appSettings.getBudgetSelectionRequired()>

                    <cfset useLakebaseForqGetBudget = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_program_selection")>
<cfif useLakebaseForqGetBudget>
	<cftry>
		<cfset qGetBudget = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_program_selection", {
				"program_id" = "eq.#this.programId#",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBudget = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBudget>
<cfquery name="qGetBudget" datasource="#application.datasource#">
                        SELECT  1
                        FROM    Budget_Program_Selection
                        WHERE   Program_ID = '#this.programId#'
                    </cfquery>
</cfif>

                    <cfif not qGetBudget.recordCount>
                        <cfset letUserProceed = 0 />
                        <cfset ArrayAppend(messageArray, "You must make a budget selection")>
                    </cfif>

                </cfif>
			</cfif>

		<cfscript>
			local.structProgramStatusButton = {};
			local.structProgramStatusButton.label = "";
			local.structProgramStatusButton.enabled = 0;
			local.structProgramStatusButton.disabledMessage = "";
			local.structProgramStatusButton.buttonId = "";

			local.structViewMarginButton = {};
			local.structViewMarginButton.label = "View Margins";
			local.structViewMarginButton.enabled = 1;
			local.structViewMarginButton.disabledMessage = "";
			local.structViewMarginButton.buttonId = "btnViewMargin";
			rfaValidateMessage = 0;

			//if the programs is being revised or copied then disable
			if((url.bCopy == 1 or url.bRevise == 1) AND (URL.programID EQ Form.ProgramID)){
				// *****************  WIP -> RFA
				local.structProgramStatusButton.label = "Req. Approval";
				local.structProgramStatusButton.enabled = 0;
				local.structProgramStatusButton.disabledMessage = "#Application.PlannerPrgLabel# must be saved first";
				local.structProgramStatusButton.buttonId = "";
			}
			else if(qGetProgramInfo.Contract_Status_Type_IDX == 1){
				// *****************  WIP -> RFA
				local.structProgramStatusButton.label = "Req. Approval";
				local.structProgramStatusButton.enabled = 1;
				local.structProgramStatusButton.disabledMessage = "";
				local.structProgramStatusButton.buttonId = "rfaprogram";
				if(letUserProceed == 0){
					//removing code to disable RFA button and show messages on mouseover.
					/*
					local.structProgramStatusButton.enabled = 0;
					local.structProgramStatusButton.disabledMessage = ArrayToList(messageArray, "&##13;");
					*/
					//Instead we are going to diplay messages in an alert so users are more clear why program cannot be RFA'd
					rfaValidateMessage = 1;
					displayAlert = ArrayNew(1);
					rfaMessageStruct = structNew();
					structInsert(rfaMessageStruct, "messages", messageArray);
					ArrayAppend(displayAlert, rfaMessageStruct);
				}
			}
			else if(qGetProgramInfo.Contract_Status_Type_IDX == 2 AND This.fromProgramSearch == 0){
				// *****************  RFA -> Approve
				local.structProgramStatusButton.label = "Approve";
				local.structProgramStatusButton.buttonId = "approveprogram";
				local.structProgramStatusButton.enabled = 1;

				if( qGetProgramInfo.Planner_Approved == 0){
					local.structProgramStatusButton.enabled = 0;
					local.structProgramStatusButton.disabledMessage = "#Application.PlannerLabel# need to be approved first";
				}

				if(application.util.query.get_Setting("planner_targets_enabled", 0) == '1') {
					local.structProgramStatusButton.enabled = 0;
					local.structProgramStatusButton.disabledMessage = "Approval within #Application.PlannerPrgLabel# is not allowed";
				}
			}
			else if(qGetProgramInfo.Contract_Status_Type_IDX > 2 || This.fromProgramSearch == 1) {
				local.structProgramStatusButton.label = "Approve";
				local.structProgramStatusButton.enabled = 0;
				if(qGetProgramInfo.Contract_Status_Type_IDX > 2) {
					local.structProgramStatusButton.disabledMessage = "#Application.PlannerPrgLabel# is already approved";
				}
				else if(This.fromProgramSearch == 1){
					local.structProgramStatusButton.disabledMessage = "#Application.PlannerPrgLabel# Approval should be executed in the Planner Tool.";
				}
			}

			if(bContractIsLocked == 1){ ///bContractIsLocked = 1 means I can edit, bContractIsLocked = 0 means I cannot edit
				local.structProgramStatusButton.enabled = 0;
				local.structProgramStatusButton.disabledMessage = "#Application.PlannerPrgLabel# need to be in edit mode";
			}
		</cfscript>
 
		<cfif rfaValidateMessage eq 1>
			<cfsavecontent variable="RFAMessages">
				<cfloop index="idx" from="1" to="#arrayLen(displayAlert)#">
					<cfoutput>#ArrayToList(displayAlert[idx].messages)#<br></cfoutput>
				</cfloop>
			</cfsavecontent>
		</cfif>
	</cfsilent>

	<body>
	<!----------------------------->
	<!--- display menu + header --->
	<!----------------------------->
	<cfsavecontent variable="variables.uncompressed">
	<cfoutput>

	<cfset this.href = "planner_program_create.cfm?programId=#this.programId#&plannerID=#this.plannerId#&customerID=#this.customerId#&templateId=#this.templateId#&bInit=1&fromProgramSearch=#this.fromProgramSearch#" />

	<header>
			<div class="cd-dropdown-wrapper">
				<a class="cd-dropdown-trigger" href="##0" tabindex="-1">menu</a>
				<nav class="cd-dropdown">
                    <cfscript>
                        DISABLED       = "disabled";
                        css            = { cancel:'', revise:'', delete:'', reset:'' };
                        program_status = val(qGetProgramInfo.Contract_Status_Type_IDX);

                        // wip
                        if (program_status eq 1) {
                            css.cancel = DISABLED;
                            css.revise = DISABLED;
                            css.reset  = DISABLED;
                        }
                        // rfa
                        else if (program_status eq 2) {
                            css.cancel = DISABLED;
                            css.revise = DISABLED;
                        }
                        // approved or expired
                        else if (program_status eq 3 or program_status eq 7) {
                            css.delete = DISABLED;
                        }

                        // cancelled
                        if (qGetProgramInfo.Cancelled_by gt '') {
                            css.cancel = DISABLED;
                            css.revise = DISABLED;
                            css.delete = DISABLED;
                        }

                        if (program_status gt 2) {
                            css.delete = DISABLED;
                        }

                        /*
                        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                        1 = Lock on approval and unlock when interface runs
                        2 = Lock on approval and unlock when acknowledged
                        3 = Lock on interface and unlock when acknowledged
                        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                        */
                        if (val( application.util.query.get_Setting("Program_Lock_Type_ID", 0)) AND val(this.programId) gt 0 AND qGetProgramInfo.recordCount AND qGetProgramInfo.Approved) {
                            //<!---if getProgramLockStatus() doesn't return 0 then we have to lock the program--->
                            if (createObject( "component", "components.programs.ProgramLockType").getProgramLockStatus(qGetProgramInfo.Contract_Main_ID)) {
                                css.revise = DISABLED;
                                css.cancel = DISABLED;
                            }
                        }

                        if (program_status neq 2) {
                            css.reset  = DISABLED;
                        }

                        if (val(qGetProgramInfo.Approved) neq 1 or val(qGetProgramInfo.Released) eq 1) {
                            css.cancel = DISABLED;
                        }

			if (val(qGetProgramInfo.Released) eq 1 and application.util.query.get_Setting("release_settlement_allow_revision",0) eq '0') {
                            css.revise = DISABLED;
                        }
						/*  115675:  Update planner to allow users to revise expired programs / Anand Rao / 23-May-2022  */
						if (appSettings.getRenew_expired_programs() EQ 0 AND qGetProgramInfo.Contract_Status_Type_IDX EQ 7)
						{
							css.revise = DISABLED;
						}
                    </cfscript>

					<ul class="cd-dropdown-content">
						 <!---D112591 - Ability to Add Comments When Uploading a Document
                		If the Ability to Add Comments When Uploading a Document: setting is on then use the custom upload
            			--->
						<cfset businessConsiderationReqDocUpload = application.util.query.get_Setting("Business_Consideration_Req_Doc_Upload", 0)>
                        <cfif businessConsiderationReqDocUpload>
                           <li><a href="##" onClick='popupInCenter("/planners/create/planner_program_documents_custom.cfm?programId=#this.programId#", "planner_program_documents", 1000, 800)'>documents</a></li>
                        <cfelse>
							<li><a href="##" onClick='popupInCenter("/planners/create/planner_program_documents.cfm?programId=#this.programId#", "planner_program_documents", 1000, 800)'>documents</a></li>
						</cfif>

						<li><a href="##" id="print" onClick="popupInCenter('/Planners/Create/planner_program_print.cfm?programId=#this.programId#&plannerID=#this.plannerId#&customerID=#this.customerId#&templateId=#this.templateId#&bInit=1', 'planner_program_print')">print</a></li>
						<li><a href="##" id="email" onClick="popupInCenter('/Planners/Create/planner_program_email.cfm?programId=#this.programId#&plannerID=#this.plannerId#&customerID=#this.customerId#&templateId=#this.templateId#&bInit=1', 'planner_program_email')">email</a></li>

						<li><a href="##" id="copy">copy</a></li>
						<li><a href="##" id="history">history</a></li>
						<cfif (qGetProgramInfo.Approved EQ 1 AND application.util.query.get_Setting("planner_targets_enabled", 0) EQ 0 AND Get_Profile_Settings.Planner_Margin_View EQ 1)>
							<cf_cryp type="en" key="#request.key#" string ="#this.programId#">
							<li><a href="##" id="approvedMargins"
								onClick="javascript:NewWindow('/common_files/contracts/contract_profit_analysis.cfm?CID=#cryp.value#&displayPreviousVersionMargin=0&margin_version=approved','Margins','990','650','Yes','Yes');"
								>approved margins</a></li>
						</cfif>
						<li class="cd-divider"></li>

						<li><a href="##" id="cancel" class="#css.cancel#">cancel</a></li>
						<li><a href="##" id="revise" class="#css.revise#">revise</a></li>
						<li><a href="##" id="delete" class="#css.delete#">delete</a></li>
						<li><a href="##" id="reset"  class="#css.reset#">reset</a></li>
						<li class="cd-divider"></li>

                        <li><a href="##" id="changes" onclick="NewWindow('/Common_Files/contracts/programChanges.cfm?Contract_main_id=#this.programId#','ProgramChanges','1000','600','Yes', 'No')">changes</a></li>

                        <cfset bus_considerations_is_on = appSettings.getSuppressBusinessConsiderations() ? 0 : 1>
                        <cfif bus_considerations_is_on>
                            <li><a href="##" onclick="business_considerations()">bus consideration</a></li>
                        </cfif>

						<li><a href="##" id="workflow" onClick="javascript:NewWindow('/workflow/workflow.cfm?Program_ID=#this.programId#', 'workflow', 1000, 800, 'yes', 'yes');">workflow</a></li>
						<li><a href="##" id="revisionhistory" onClick="javascript:NewWindow('/reportwriter/performance_reports/revisionreport.cfm?Contract_main_id=#this.programId#&Contract_Status=#qGetProgramInfo.Contract_Status_Type_IDX#&contract_number=#qGetProgramInfo.Contract_Number#&bypassRevSummary=1', 'revision history', 1200, 550, 'yes', 'yes');">revision history</a></li>

						<cfif getSettings.recordCount and getSettings.Enable_Program_Qualifications>
						    <li><a href="##" id="workflow" onClick="javascript:NewWindow('/Common_Files/contracts/qualifications.cfm?Program_ID=#this.programId#', 'qualifications', 1000, 800, 'yes', 'yes');">qualifications</a></li>
						</cfif>
						<cfif val(qGetProgramInfo.Check_Duplicate_Program)>
							<cf_cryp type="en" key="#request.key#" string ="#this.programId#">
							<li><a href="##" id="revisionhistory" onClick="javascript:NewWindow('/common_files/contracts/duplicate_check.cfm?CID=#cryp.value#&Mode=showDup&anyStatus=1&plannerId=#this.plannerId#','Duplicate_Check','870','720','Yes','No');">duplicate check</a></li>
						</cfif>
					</ul> <!-- .cd-dropdown-content -->
				</nav> <!-- .cd-dropdown -->
			</div> <!-- .cd-dropdown-wrapper -->

            <cfset request.program_in_edit_mode = false>
			<!--- do not display button to switch to edit mode when url.numb exists --->
			<cfif structKeyExists(url, "numb") or planner_lock_status.Locked_By_Other>
				<cfset url.bLock = 0>
			<cfelse>
				<!--- edit | read only button --->
				<div id="hdr413">
					<cfif bContractIsLocked eq 1>
						<cfset sReadOnly = replace(this.href, "&bUnLock=1", "") />
						<button class="readonly" title="click for edit" onClick="location.href='#this.href#&bLock=1'" tabindex="-1">Read Only</button>
					<cfelseif bContractIsLocked eq 0>
						<cfset sEdit = replace(this.href, "&bLock=1", "") />
                        <cfset request.program_in_edit_mode = true>
						<button class="edit" title="click for read only" onClick="location.href='#this.href#&bUnLock=1'" tabindex="-1">Edit</button>
					</cfif>
				</div>
			</cfif>
			<!--- customer information --->
			<cfscript>
				customer_info = [];
				if ( len(variables.distributor.ship_to) )
					arrayAppend(customer_info, variables.distributor.ship_to);
				if ( len(qGetProgramInfo.Planner_NickName) )
					arrayAppend(customer_info, qGetProgramInfo.Planner_NickName);
				else if ( len(variables.distributor.name) )
					arrayAppend(customer_info, variables.distributor.name);
			</cfscript>
			<div class="header shadow" id="hdr415">#arrayToList(customer_info, " - ")#</div>
			<div class="header shadow" id="hdr416">
			<cfif ((trim(qGetProgramInfo.Contract_Number) NEQ form.Contract_Number) AND URL.bCopy EQ 1)>
				#form.Contract_Number#
			<cfelse>
				#qGetProgramInfo.Contract_Number#
			</cfif>
			</div>
			<!--- status info --->
			<div class="header shadow" id="hdr417"><span class="reg">Status:</span> <cfif (url.bRevise eq 1) or (qGetProgramInfo.Is_A_Revision eq 1 and qGetProgramInfo.Approved eq 0)>revision in progress<cfelseif url.bCopy eq 1>WIP<cfelse>#qGetProgramInfo.Status_Abbreviation#</cfif></div>
			<div class="header shadow" id="hdr415b"><span class="reg">Type:</span> #qGetProgramInfo.Created_Type#</div>
			<!--- available action --->
			<cfif (qGetProgramInfo.Approved EQ 1 AND application.util.query.get_Setting("planner_targets_enabled", 0) EQ 0 AND Get_Profile_Settings.Planner_Margin_View EQ 1)>
				<!--- Display "View Margins" button since the program is in approved status --->
				<div id="hdr419"><button id="#local.structViewMarginButton.buttonId#" title="#local.structViewMarginButton.label#" class="btnNeutral" onClick="javascript:popupCenter2022('/common_files/contracts/contract_profit_analysis.cfm?CID=#cryp.value#&plannerId=#this.plannerId#','View_margin','LG','LG');">#local.structViewMarginButton.label#</button></div>
			<cfelse>
				<cfif Len(local.structProgramStatusButton.label)>
				<div id="hdr419"><button id="#local.structProgramStatusButton.buttonId#" tabindex="-1" <cfif local.structProgramStatusButton.enabled eq 0>disabled class="readonly" title="#local.structProgramStatusButton.disabledMessage#"<cfelse>class="edit"</cfif>>#local.structProgramStatusButton.label#</button></div>
				</cfif>
			</cfif>
	</header>
	</cfoutput>
	</cfsavecontent>
	<cfoutput>#application.util.string.compress( variables.uncompressed )#</cfoutput>


	<!--------------------------------------------------------------------------------------------------------------------->
	<div id="layoutBody">
    <!--------------------------------------------------------------------------------------------------------------------->
<cfelse>

	<cf_cryp type="en" key="#request.key#" string ="#this.programId#">

	<!--- main content from parent code is displayed here --->
	</div>   <!---id="layoutBody"--->
        <div id="layoutFoot" style='padding:5px;font-weight: normal;'></div>

        <!--- grap the most recent revision that is later than the current program - ngt --->
        <cfquery name="qRevised" datasource="#application.datasource#">
            SELECT TOP 1 contract_main_id
              FROM contract_main
             WHERE contract_number = (SELECT Contract_Number FROM contract_main cm WHERE cm.contract_main_id = #this.programID#)
                    AND contract_main_id > #this.programID#
                    AND deleted = 0
                    ORDER BY contract_main_id DESC
        </cfquery>

		<!--------------------------------------------------------------------------------------------------------------------->
		<script>
        // copy CF setting to a JS variable for business considerations
        let bus_considerations_is_on = <cfoutput>#(bus_considerations_is_on ? true : false)#;</cfoutput>
		jQuery(document).ready(function($){

			$(document).mouseup(function (e) {
				var container = $(".cd-dropdown-content, .cd-dropdown .cd-close, .cd-dropdown-trigger");
				if (!container.is(e.target) // if the target of the click isn't the container...
					&& container.has(e.target).length === 0) // ... nor a descendant of the container
				{
					var navIsVisible = ( !$('.cd-dropdown').hasClass('dropdown-is-active') ) ? true : false;
					if( !navIsVisible ) {
						toggleNav();
					}
				}
			});

			//open/close mega-navigation
			$('.cd-dropdown-trigger').on('click', function(event){
				event.preventDefault();
				toggleNav();
			});

			//close meganavigation
			$('.cd-dropdown .cd-close').on('click', function(event){
				event.preventDefault();
				toggleNav();
			});

			//on desktop - differentiate between a user trying to hover over a dropdown item vs trying to navigate into a submenu's contents
			var submenuDirection = ( !$('.cd-dropdown-wrapper').hasClass('open-to-left') ) ? 'right' : 'left';
			$('.cd-dropdown-content').menuAim({
				activate: function(row) {
					$(row).children().addClass('is-active').removeClass('fade-out');
					if( $('.cd-dropdown-content .fade-in').length == 0 ) $(row).children('ul').addClass('fade-in');
				},
				deactivate: function(row) {
					$(row).children().removeClass('is-active');
					if( $('li.has-children:hover').length == 0 || $('li.has-children:hover').is($(row)) ) {
						$('.cd-dropdown-content').find('.fade-in').removeClass('fade-in');
						$(row).children('ul').addClass('fade-out')
					}
				},
				exitMenu: function() {
					$('.cd-dropdown-content').find('.is-active').removeClass('is-active');
					return true;
				},
				submenuDirection: submenuDirection,
			});

			//submenu items - go back link
			$('.go-back').on('click', function(){
				var selected = $(this),
					visibleNav = $(this).parent('ul').parent('.has-children').parent('ul');
				selected.parent('ul').addClass('is-hidden').parent('.has-children').parent('ul').removeClass('move-out');
			});

			function toggleNav(){
				var navIsVisible = ( !$('.cd-dropdown').hasClass('dropdown-is-active') ) ? true : false;
				$('.cd-dropdown').toggleClass('dropdown-is-active', navIsVisible);
				$('.cd-dropdown-trigger').toggleClass('dropdown-is-active', navIsVisible);
				if( !navIsVisible ) {
					$('.cd-dropdown').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend',function(){
						$('.has-children ul').addClass('is-hidden');
						$('.move-out').removeClass('move-out');
						$('.is-active').removeClass('is-active');
					});
				}
			}

		});

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!---  keep track of number of changes ~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        let changes_count = 0;
        $("input[type=text], select").change(function() {
            ++changes_count;
        });

		$('#rfaprogram').on('click', function(event){

			//if RFAMessages exists then display them and return. These are the messages that come from common_program_level_check.cfm
			<cfif isDefined("RFAMessages")>
				dhtmlx.alert({
					title:"RFA Programs",
					type:"alert-error",
					text: "<cfoutput>#RFAMessages#</cfoutput>",
					width: "600px"
                });
				return;
            </cfif>

			//113315 Documents Attached Required Setting in Retail Events
			<cfif val(qGetProgramInfo.Discount_Lump_Sums_Document_Attachment_Mandated) or val(qGetProgramInfo.Document_Attachment_Required)>
			if (documentCheck()) {
				return false;
			}
			</cfif>
			if (duplicateProgramExists()) {
				return false;
			}

			if ( rates_are_invalid() ) {
					return false;
			}
				if ( checkQualification() ) {
					return false;
			}
			//run program duplicate checker based on program template settings if the template setting is on
			<cfif val(qGetProgramInfo.Check_Duplicate_Program)>
			if ( programDupChecker("rfa")) {
                return false;
            }
			</cfif>
            
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  disallow RFA until changes are saved  --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            if ( typeof changes_count !== "undefined" && changes_count > 0 ) {
                noty( {  text     : "Please click the save option<br> before selecting Req. Approval."
                        ,type     : "error"
                        ,buttons  : [  { text:'OK', addClass:'btn-primary', onClick:function($noty) {  $noty.close(); } } ]
                        ,killer   : true
				        ,timeout  : 0
                        ,layout   : "center" });
                return false;
            }

			show_loader( "PROCESSING PROGRAM, PLEASE WAIT...");
			$.ajax({
				 url: "/mvc/Models/Planner/PlannerProgramManager.cfc"
				 ,type: "post"
				 ,dataType: "json"
				 ,async: true
				 ,timeout: 60000
				 ,data: {
							method: "rfaProgram",
							programId:'<cfoutput>#this.programId#</cfoutput>',
							userId:'<cfoutput>#request.accessstructure.User_id#</cfoutput>'
						}
				 ,success: function(r) {
					 //runDupChecker variable to prevent popup from displaying in a loop
					 MyForm.runDupChecker.value = 1;
					 // if revision and shortcut routing is on then shortcut
					 if( <cfoutput>#val(qGetProgramInfo.Parent_Program_ID)#</cfoutput> > 0 && <cfoutput>#Get_Profile_Settings.Prevent_short_cut_routing#</cfoutput> == 0 ){
						 checkShortCutRouting();
					 }else{
						 <cfoutput>location.href="#this.href#";</cfoutput>
					 }
                }
				 ,error: function(r, status){alert(status)}
			});
		});

		checkShortCutRouting = function(){
			$.ajax({
				 url: "/mvc/Models/Planner/PlannerProgramManager.cfc"
				 ,type: "post"
				 ,dataType: "json"
				 ,async: true
				 ,timeout: 60000
				 ,data: {
							method: "checkShortCutRouting",
							programId:'<cfoutput>#this.programId#</cfoutput>',
							parentProgramId:'<cfoutput>#qGetProgramInfo.Parent_Program_ID#</cfoutput>',
							userId:'<cfoutput>#request.accessstructure.User_id#</cfoutput>'
						}
				 ,success: function(r) {
					if (r==1) {
						// shortCutApprove;
						$("form[name=approvalForm]").submit();
					}
					else{  <cfoutput>location.href="#this.href#";</cfoutput> }
                 }
				 ,error: function(r, status){alert(status)}
			});
		}

		// fn called back from approval form
		function callback_approve_program() {
			refresh_parent();
			<cfoutput>location.href="#this.href#";</cfoutput>
		}

        showMargin = function(){
            popupInCenter("/Common_Files/Contracts/contract_profit_analysis.cfm?CID=<cfoutput>#cryp.value#</cfoutput>&bFromPlanner=1", "programPlannerApprovalWindow", 1300, 800);
        }

        $('#approveprogram').on('click', function(event){
			// popupInCenter("/Common_Files/Contracts/contract_profit_analysis.cfm?CID=<cfoutput>#cryp.value#</cfoutput>&bFromPlanner=1", "programPlannerApprovalWindow", 1300, 800);
			//run program duplicate checker based on program template settings if the template setting is on
			<cfif val(qGetProgramInfo.Check_Duplicate_Program)>
			if ( programDupChecker('approve')) {
                return false;
            }
			</cfif>
            showMargin();
		});


		$("#delete").on('click', function(event){
			if (confirm("Are you sure you want to delete this program?") == true) {
				NewWindow('/Planners/Create/planner_program_delete.cfm?Program_ID=<cfoutput>#this.programId#</cfoutput>', 'delete', 1000, 800, 'yes', 'yes');
				window.close();
			}
		});

		$("#reset").on('click', function(event){
			if (confirm("Are you sure you want to reset this program?") == true) {
				$.ajax({
					url: "/mvc/Models/Planner/PlannerProgramManager.cfc",
					type: "post",
					dataType: "json",
					async: true,
					timeout: 60000,
					data: {
							method: "resetProgram",
							programId:'<cfoutput>#this.programId#</cfoutput>',
							userId:'<cfoutput>#request.accessstructure.User_id#</cfoutput>'
						},
						success: function(r) {window.location.reload();},
						error: function(r, status){alert(status)}
				});
			}
		});

	//Planners/Create/planner_program_copy_revise.cfm?programId=#this.programId#&plannerID=#this.plannerId#&customerID=#this.customerId#&templateId=#this.templateId#&bInit=1&bCopy=1
		$("#copy").on('click', function(event){
			show_loader( "COPYING PROGRAM, PLEASE WAIT...", 1500);
			<cfoutput>
			window.location.href = "/Planners/Create/planner_program_create.cfm?programId=#this.programId#&plannerID=#this.plannerId#&customerID=#this.customerId#&templateId=#this.templateId#&bInit=1&bCopy=1";
			</cfoutput>
		});
        //Planners/Create/planner_program_copy_revise.cfm?programId=#this.programId#&plannerID=#this.plannerId#&customerID=#this.customerId#&templateId=#this.templateId#&bInit=1&bRevise=1
        // ngt
		$("#revise").on('click', function(event){
            <cfoutput>
            let bRevise   = 1;
            let programId = #this.programId#;

            /* revised program exists - load it & ignore the revise request */
            <cfif qRevised.recordCount>
                bRevise   = 0;
                programId = #qRevised.contract_main_id#;
            </cfif>

            business_considerations();
            window.location.href = "/Planners/Create/planner_program_create.cfm"
                                        + "?programId=" + programId
                                        + "&bRevise=" + bRevise
                                        + "&plannerID=#this.plannerId#&customerID=#this.customerId#&templateId=#this.templateId#&bInit=1";
            </cfoutput>
		});

        function business_considerations() {
            // render business considerations popup only when its setting is on
            if (bus_considerations_is_on) {
                NewWindow(<cfoutput>"/common_files/contracts/EvaluationNotes.cfm?CID=#cryp.value#"</cfoutput>, "revise_planner_program", 1000, 800, 'yes', 'yes');
            }
        }

		$("#cancel").on('click', function(event){
            business_considerations();
			window.showModalDialog('/Common_Files/contracts/contract_cancel_form.cfm?CID=<cfoutput>#cryp.value#</cfoutput>', window, 'dialogHeight:400px;dialogWidth:500px;center:yes;edge:raised');
		});

		$("#history").on('click', function(event){
			NewWindow('/Common_Files/contracts/view_contract_history.cfm?CID=<cfoutput>#cryp.value#</cfoutput>&popUp=1', 'History','1000','600','Yes', 'No');
		});
//113315 Documents Attached Required Setting in Retail Events
function documentCheck(){
	var PrgDcoumentList = []

	$.ajax({ url: "/mvc/Models/Planner/PlannerProgramManager.cfc"
							,type: "post"
							,timeout:60000
							,data: { method: "getDocumentCount"
												, program_id:'<cfoutput>#this.programId#</cfoutput>'
												}
							,dataType: "json"
							,async: false
							,success: function(r) {
									PrgDcoumentList = r;
							}
							,error: function(XMLHttpRequest, textStatus, errorThrown) {
									alert("Status: " + textStatus); alert("Error: " + errorThrown);
							}
	});

	iPgmDocLen = PrgDcoumentList.DATA[0][0];

	if(iPgmDocLen == 0){
			sMessage = "You should have at least one document attached to this program."
			alert(sMessage);
			return 1;
	}

}

function checkQualification(){
	var qualificationRequired = 1;

	$.ajax({ url: "/mvc/Models/Planner/PlannerProgramManager.cfc"
							,type: "post"
							,timeout:60000
							,data: {
										method: "getQualificationRequired",
										templateId: '<cfoutput>#this.templateId#</cfoutput>',
										programId:'<cfoutput>#this.programId#</cfoutput>'
									}
							,dataType: "json"
							,async: false
							,success: function(r) {
									qualificationRequired = r;
							}
							,error: function(XMLHttpRequest, textStatus, errorThrown) {
									alert("Status: " + textStatus); alert("Error: " + errorThrown);
							}
	});


	if(qualificationRequired == 0){

		noty( {  text     : "Qualifications must be completed before moving forward."
				,type     : "error"
				,buttons  : [  { text:'OK', addClass:'btn-primary', onClick:function($noty) {  $noty.close(); } } ]
				,killer   : true
				,timeout  : 0
				,layout   : "center" });
		return 1;

	}

}
</script>
	<!--- injects style for focused element here instead of using Application.cfc which places the same code oustide of </html> tag --->
	<cfinclude template="/common_files/focus.cfm">     <!--- 47143 --->
	</body>
	</html>
</cfif>     <!--- if thisTag.executionMode is "start" --->
