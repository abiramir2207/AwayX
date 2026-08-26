<cfset dupAction = template.getDupAction(ContractControlID)>
<cfparam name="thisIsAPopUpWindow" 	default="0">
<cfparam name="currentAction" 		default="rfa">
<cfparam name="continueURL" 		default="contract_approve_broker_action.cfm?CID=#FORM.ApproveContract#&passedForm=dupWarning&duplicateprogram=true&dupAction=#dupAction#">
<cfparam name="URL.Mode" 	default="">
<CFPARAM name="url.bFromPlannerRFAApprove"	default="0">
<CFPARAM name="url.plannerAction"	default="">
<!------
	This file is used from RFA

	Has been modified so that it can be called when some one clicks 'click heer to approve'

	We do not use this message page for spending cap and dollar per pound approval schemes (contract_approve_action.cfm,
where the message is displayed there itself, may be we should chnage there also to use this file.
----->

<!------
By Deepa Kunnath
------------------------------------------------------------------------------------------------------------------------
variable: 			thisIsAPopUpWindow
definition: 		This variable is used so that different tyep of pages (main window, pop up window) can use this same dup warning window.
possible values: 	0 (default)
					1 - This is a pop up window, so in the case of email like, it has to load the email form in the mail window rathe rthan in the pop up window.
------------------------------------------------------------------------------------------------------------------------
variable: 			currentAction
definition: 		This variable is used so that different pages (rfa, approve) can use this same dup warning window.
possible values: 	rfa (default)  - when you click RFA
					toApprovalPage - when you click 'click heer to approve', it takes you through duplicate check,
					In the case of approval schemes like layered, disposal, standard, etc. it does not display this message window,
					so take them thru this befor they get to margin page.
					If toApprovalPage, always let them continue, the approval page is taking care of whether they can approve or not.
------------------------------------------------------------------------------------------------------------------------
variable: 			continueURL
definition: 		This variable is used so that the next page URL is used in a common way
possible values: 	contract_approve_broker_action (default) - see above
					or any othe rvalue the developers wat to provide while using this page.
------------------------------------------------------------------------------------------------------------------------
----->
<html>
<head>
	<title>Duplicate Warning Window</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<cf_include files="/script/javascript/dhtml.js">
</head>
<body>
<STYLE>
	TABLE.underline TD {
		border-bottom:solid #C0C0C0 1px;
	}
	div.msg {
		font-size:13px;
		text-align:center;
		margin:13px 0;
	}
	div.msg2 {
		font-size:13px;
		text-align:left;
		margin:13px 0 0 70px;
	}
</STYLE>
<cfset oldCrypValue = cryp.value>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset ContProgApprovalRights = Get_Profile_Settings.Cont_Prog_Approval_Rights />
<cfsavecontent variable="actions">
	<table style="margin:10px auto;" cellpadding="10">
		<tr>
			<cfif NOT(appSettings.getCheckAllDuplicateProgram())>
				<td>
					<CF_button
					button_name		=	""
					button_caption	=	"email"
					button_action	=	"emailCreator('#oldCrypValue#','#check_contract_number#');"
					button_type		=	"javascript_link"
					button_width	=	"130"
					button_color	=	"Navy"
					button_tip		=	"email notification"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
					>
				</td>
			</cfif>
			<cfif URL.Mode EQ "">
				<cfif dupAction EQ 1>
					<td>
							<CF_button
								button_name		=	"continueRFA"
								button_caption	=	"continue"
								button_action	=	"continueToRFA('#continueURL#', 'continueRFA_table');"
								button_type		=	"javascript_link"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	"continue with the application"
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"
							>
					</td>
				<cfelseif currentAction EQ "toApprovalPage">
					<td>
					<!--- if the user is going to approval page, the approval page will stop them if they are not supposed to approve,
						so them continue now, so that they can view the margins,
						see above for more info about "currentAction=toApprovalPage" --->
							<CF_button
								button_name		=	"continueURL"
								button_caption	=	"continue"
								button_action	=	"continueToURL('#continueURL#', 'continueURL_table')"
								button_type		=	"javascript_link"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	"continue with the application"
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"
							>
					</td>
				</cfif>
			</cfif>
			<cfif thisIsAPopUpWindow EQ 1>
				<cfset action = "window.close()">
				<cfset linktype = "javascript_link">
			<cfelse>
				<cfset action = "contract_edit_menu.cfm?CID=#FORM.ApproveContract#">
				<cfset linktype = "link">
			</cfif>
			<td>
				<cfif URL.Mode EQ "">
					<CF_button
						button_name		=	""
						button_caption	=	"cancel"
						button_action	=	"#action#"
						button_type		=	"#linktype#"
						button_width	=	"150"
						button_color	=	"Navy"
						button_tip		=	"Click here to return to program view..."
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold">
				<cfelse>
					<!---When coming from planner show continue or cancel with actions pertaining to planner rfa/approve--->
					<cfif url.bFromPlannerRFAApprove EQ 1>
						<cfif dupAction EQ 1>
							<td>
								<CF_button
										button_name		=	"continueRFA"
										button_caption	=	"continue"
										button_action	=	"plannerRFAapprove();"
										button_type		=	"javascript_link"
										button_width	=	"150"
										button_color	=	"Navy"
										button_tip		=	"continue with the application"
										font_color		=	"White"
										font_size		=	"12"
										font_weight		=	"bold"
								>
							</td>
						</cfif>
						<td>
							<CF_button
								button_name		=	""
								button_caption	=	"cancel"
								button_action	=	"window.close();"
								button_type		=	"javascript_link"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	"Click here to close"
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"
							>
						</td>
					<cfelse>
						<input type="button" onclick="javascript:window.close();" title="Close window" value="Close window">
					</cfif>
				</cfif>
			</td>
		</tr>
	</table>
	</cfsavecontent>

<div class="msg">
	Warning: Duplicate program(s) already exists
</div>
<cfoutput>#application.util.string.compress(actions)#</cfoutput>
<CFSET CheckAllProgram = appSettings.getCheckAllDuplicateProgram()>

<CFIF appSettings.getCheckAllDuplicateProgram()>
	<CFQUERY NAME="GetContractDetails" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Contract_Main WHERE Contract_main_ID IN (#DuplicateProgramIDList#)
	</CFQUERY>
	<CFOUTPUT>
	<!--- <BR><BR> --->
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="90%" STYLE="Border:2px solid navy;margin:0 auto;" CLASS="underline">
		<TR BGCOLOR="FFE083">
			<TD><B>CONTRACT NUMBER</B></TD>
			<TD><B>CONTRACT TITLE</B></TD>
			<TD><B>SALES PERSON</B></TD>
			<cfif appSettings.getShowManagerDetailsOnViewProgram()><TD><B>MANAGER</B></TD></cfif>
		</TR>
		<!--- per lamb, show them the link --->

		<CFLOOP QUERY="GetContractDetails">
			<cf_cryp	type = "en" string = "#Contract_Main_ID#" key = "#request.key#">
			<CFSET CID=cryp.value>
			<cfset targetURL = "/scorecard/program_display.cfm?display_program=1&CID=#CID#">
			<cfset targetWindow = "_blank">
			<cfset windowWidth = 800>
			<cfset windowHeight = 600>

			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" valign="top">
				<TD ALIGN="left">
					<!--- Dev Note: Milan (19512); If the profile setting allows, then show the program link --->
					<cfif Get_Profile_Settings.View_Prog_In_Duplicate_Check_Window EQ 1>
						<A onClick="javaScript: NewWindow(this.href , 'Catalog_Program' , #windowWidth# , #windowHeight# , 'yes' , 'yes'); return false;" target="#targetWindow#" HREF="#targetURL#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">
					</cfif>
						<B>#contract_number#</B>
					<cfif Get_Profile_Settings.View_Prog_In_Duplicate_Check_Window EQ 1>
						</A>
					</cfif>
				</TD>
				<TD>#contract_title#</TD>

				<!--- Dev Note: KAL; D8128 : Show detail information of user such as email, phone no--->
				<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(Creator_ID) /> <!--- Created User --->
				<cfset qPositionID = CreateObject("component", "components.user.UserManager").getPositionId(Creator_ID) /> <!--- Created User Position ID--->
				<cfset getpositionabove = CreateObject("component", "components.geography.position").getFirstPositionAbove(qPositionID) /> <!--- getting Manager position --->

				<td <cfif getpositionabove EQ -1>COLSPAN = "2"</cfif>>
					#qUser.User_Full_Name#<BR/>
					#qUser.Position_Label#<BR/>
					#qUser.User_Work_Phone# <cfif Len(qUser.Work_Phone_Ext) GT 0> Ext: #qUser.Work_Phone_Ext#</cfif><BR/>
					#qUser.Work_Address_1#&nbsp;#qUser.Work_Address_2#<BR/>
					#qUser.Work_City#&nbsp;#qUser.State_Code#&nbsp;#qUser.Work_Zip#<BR/>
					<a href="mailto:#qUser.User_Email#"><font size="2">#qUser.User_Email#</a>
				</td>

				<!--- START: D32448: Program Manager Incorrect on Duplicate Warning/Anand Rao/13-Jun-2012 --->
				<cfif appSettings.getShowManagerDetailsOnViewProgram()>
					<cfif getpositionabove neq -1>
						<cfset useLakebaseForPositionDescforManager = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForPositionDescforManager>
	<cftry>
		<cfset PositionDescforManager = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"user_positions_id" = "eq.#getpositionabove#",
				"select" = "position_label"
			}), "position_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForPositionDescforManager = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForPositionDescforManager>
<cfquery name="PositionDescforManager" datasource="#application.datasource#">
								SELECT Position_Label FROM User_Positions
								WHERE User_Positions_ID = '#getpositionabove#'
						</cfquery>
</cfif>
						<cfif PositionDescforManager.recordcount GT 0>
							<cfquery name="getManagerDetails" datasource="#application.datasource#">
								SELECT top 1 	name_first + ' ' + name_last AS User_Full_Name,
												Work_Phone_1 + '-' + Work_Phone_2 + '-' + Work_Phone_3 As User_Work_Phone, Work_Phone_Ext,
												User_Email,
												Work_Address_1, Work_Address_2, Work_City, Work_State, Work_Zip, _states.State_Code
										from	user_position_holders
												inner join _users on _users.user_id = user_position_holders.user_id
										and 	_users.deleted = 0
												LEFT JOIN _states ON _states.State_ID = _Users.Work_State
										where 	user_position_holders.user_positions_id = '#getpositionabove#'
										and 	user_position_type = 'P'
										and 	user_position_holders.deleted = 0
							</cfquery>
							<td>
								#getManagerDetails.User_Full_Name#<BR/>
								#PositionDescforManager.Position_Label#<BR/>
								#getManagerDetails.User_Work_Phone# <cfif Len(getManagerDetails.Work_Phone_Ext) GT 0> Ext: #getManagerDetails.Work_Phone_Ext#</cfif><BR/>
								#getManagerDetails.Work_Address_1#&nbsp;#getManagerDetails.Work_Address_2#<BR/>
								#getManagerDetails.Work_City#&nbsp;#getManagerDetails.State_Code#&nbsp;#getManagerDetails.Work_Zip#<BR/>
								<a href="mailto:#getManagerDetails.user_email#"><font size="2">#getManagerDetails.User_Email#</a>
							</td>
						</cfif>	<!--- PositionDescforManager.recordcount GT 0 --->
					</cfif>	<!--- getpositionabove neq -1 --->
				<!--- End Note: KAL; D8128 --->
				</cfif> <!--- END: <cfif appSettings.getShowManagerDetailsOnViewProgram()>
					D32448: Program Manager Incorrect on Duplicate Warning/Anand Rao/13-Jun-2012
					--->
			</TR>
		</CFLOOP>
	</TABLE>
	<!--- <BR><BR> --->
	<cfset cryp.value = oldCrypValue >
	<cfset popup_name = "dup_program_by_product">
	<form id="dup_program_by_product" method="post" action="/common_files/contracts/dup_program_by_product.cfm" target="#popup_name#">
		<cfoutput>
		<input type="hidden" name="DuplicateProgramIDList" value="#DuplicateProgramIDList#">
		<input type="hidden" name="ContractControlID" value="#ContractControlID#">
		<input type="hidden" name="ProgramID" value="#cryp.value#">
		<input type="hidden" name="is_component_checked" value="#is_component_checked#">
		<input type="hidden" name="is_rate_checked" value="#is_rate_checked#">
		<input type="hidden" name="reportType" value="product">
		<input type="hidden" name="TemplateID" value="#getProgramTemplateInfo.ProgramType_ID#">
		</cfoutput>
	</form>
	<div class="msg2">
		<p>To see duplicate programs by product, click this link: <a href="##" onclick="dup_program_by_product('#popup_name#');">#application.util.string.linkFormat("level 1 - by product")#</a></p>
		Duplicate Reason:
		<CFSET iList = "Brokers,Distributors,Operators"/>
		<cfparam name="variables.payeeMatch" default=""/>
		<cfset dup_reasons = []>
		<CFLOOP QUERY="getDefintion">
			<CFIF Item NEQ 1 AND IsChecked EQ 1>
				<CFIF Generic_Type EQ "LSAutoPay" AND ListFind(variables.iList,Item_Name)>
					<CFIF Item_Name EQ variables.payeeMatch>
						<cfset arrayAppend(dup_reasons, lcase("Matching #Item_Name#"))>
					</CFIF>
				<CFELSE>
					<cfset arrayAppend(dup_reasons, lcase("Matching #Item_Name#"))>
				</CFIF>
			</CFIF>
		</CFLOOP>
		<cfif arrayLen(dup_reasons) gt 0>
			<cfset dup_reasons[1] = application.util.string.fCase(dup_reasons[1])>
			<cfif arrayLen(dup_reasons) gt 1>
				<cfset dup_reasons[ arrayLen(dup_reasons) ] = "and " & dup_reasons[ arrayLen(dup_reasons) ]>
			</cfif>
			#replace(arrayToList(dup_reasons, ", "), ", and", " and")#
		</cfif>
	</div>
	<!--- <BR><BR> --->
	</CFOUTPUT>
<CFELSE>
		<br>The program that matches your program is <cfoutput>[#check_contract_number#]: #check_contract_title#</cfoutput>
		<br>
</CFIF>

<div class="msg2">
	<cfif appSettings.getCheckAllDuplicateProgram()>
		If you would like to email the owner of the existing program, click their email address listed above
	<cfelse>
		Would you like to email the owner of the existing program to make modifications?
	</cfif>

	<!--- get email address for the creator of the program based on check_contract_creator--->
	<CFSET objHandle = CreateObject("component", "components.user.UserManager")>
	<cfset creator_email_addr = objHandle.getUser(#check_contract_creator#).User_Email>

	<form id="myDupForm" name="myDupForm" method="post">
		<cfoutput>
				<input type="hidden" id="contract_main_id" name="contract_main_id" value="#check_contract_number#">
				<input type="hidden" id="check_contract_number" name="check_contract_number" value="#check_contract_number#">
				<input type="hidden" id="check_contract_title" name="check_contract_title" value="#check_contract_title#">
				<input type="hidden" id="creator_email_addr" name="creator_email_addr" value="#creator_email_addr#">
				<input type="hidden" id="ApproveContract" name="ApproveContract" value="#FORM.ApproveContract#">
				<input type="hidden" name="BUSINESS_CONSIDERATIONS" value="#form.BUSINESS_CONSIDERATIONS#">
				<input type="hidden" name="Cont_Prog_Approval_Rights" value="#ContProgApprovalRights#">
		</cfoutput>
	</form>
	<!--- long list of duplicate programs so display actions again --->
	<cfif IsDefined("GetContractDetails") AND GetContractDetails.recordCount gt 3>
		<cfoutput>#application.util.string.compress(actions)#</cfoutput>
	</cfif>
</div>

<script>

function continueToURL(sUrl, sTableName) {
	disableButton(sTableName, true, false);
	window.location.href = sUrl;
}

function continueToRFA(sUrl, sTableName) {
	disableButton(sTableName, true, false);
	document.all.myDupForm.action = sUrl;
	document.myDupForm.submit()
}

function emailCreator(contract_main_id,check_contract_number) {
	var isDefinedCheckAll = "<CFOUTPUT>#CheckAllProgram#</CFOUTPUT>";
	if (isDefinedCheckAll == 1)
	{
		var DupContractIDList = "<CFOUTPUT>#DuplicateProgramIDList#</CFOUTPUT>";
		document.all.myDupForm.action = "contract_email_create.cfm?passedForm=dupForm&contractMainId=" + contract_main_id+"&DupContractIDList=" +DupContractIDList;
	}
	else
		document.all.myDupForm.action = "contract_email_create.cfm?passedForm=dupForm&contractMainId=" + contract_main_id;

	<cfif thisIsAPopUpWindow>
		document.all.myDupForm.target = "mywindowname";
	</cfif>
	document.myDupForm.submit()
	<cfif thisIsAPopUpWindow>
		window.close();
	</cfif>
}
function dup_program_by_product(popup_name) {
	/* open a new popup and send the form there */
	popupInCenter('', popup_name);
	document.getElementById('dup_program_by_product').submit();
}

//function to call when coming from planner program RFA and Approve
function plannerRFAapprove(){
	//set runDupChecker to 0 to prevent popup from displaying in a loop
	opener.document.MyForm.runDupChecker.value = 0;
	//if RFA then trigger the rfa click event 
	<cfif url.plannerAction eq "rfa">
		$(opener.document.getElementById("rfaprogram")).trigger("click");
	//if approve then trigger the approve click event 
	<cfelseif url.plannerAction eq "approve">
		$(opener.document.getElementById("approveprogram")).trigger("click");
	</cfif>
	window.close();
}
</script>
<cfset request.focusHiLightOff = true>
</body>
</html>
