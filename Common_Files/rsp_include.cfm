<!--- correct --->
<cfparam name="form.Program_ID" default="">
<cfparam name="form.IsCopyProgram" default="0">
<cfparam name="bypassRSPSelect" default="0">
<cfset qCurrentUser = userManager.getUser(request.AccessStructure.User_ID) />

<!------ select the sales person responsible ----->
<cfoutput>
	<cfset showSalesPersonSelection = false>
	<cfif application.returned_customer_setting.responsible_person AND NOT isDefined("FORM.Responsible_User_Id_Position_Id")>
		<cfset stStruct = StructNew() />
		<cfset stStruct.userPosition = userManager.getPositionId(request.AccessStructure.User_ID, 0) />
		<!--- Dev Note: Clay 9478 - if display_eligible_rsp is on, display the pull-down list for results of 1 or greater. --->
		<cfif 		ListLen(stStruct.userPosition, ",") GT 1
			or	(appsettings.getDisplayEligibleRSP() EQ 1 and (qCurrentUser.Is_Eligible_RSP EQ 0 or qCurrentUser.Is_On_Behalf_Of EQ 1))
			and bypassRSPSelect eq 0
		>
			<cfset showSalesPersonSelection = true />
		</cfif>
	</cfif>

	<cfparam name="FORM.Responsible_User_Id_Position_Id" 	default="#This_User_Positions_ID#_#request.AccessStructure.User_ID#">
	<cfset FORM.Responsible_Position_Id = ListFirst(FORM.Responsible_User_Id_Position_Id, "_")>
	<cfset FORM.Responsible_User_Id = ListLast(FORM.Responsible_User_Id_Position_Id, "_")>

	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

	<cfif showSalesPersonSelection>
		<cfif businessSegManager.isEnabled() AND appSettings.getClassCodesOn()>
			<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(request.AccessStructure.User_ID, 0) />
			<cfset stStruct.UserClassCodeList = ValueList(qgetUserClassCodes.class_code_id)>
		</cfif>
		<cfset stStruct.returnUserSecondaryPositionsForUser = request.AccessStructure.User_ID>
		<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
			<cfset stStruct.userId = request.AccessStructure.User_ID>
		</cfif>
		<cfif appsettings.getDisplayEligibleRSP() EQ 1>
			<cfset stStruct.Eligible_RSP = 1>
			<cfset stStruct.Is_On_Behalf_Of = 0>
		</cfif>
		<cfset stStruct.userPositionType = "P,S">
		
		<cfset stStruct.sortBy = "Position_Level,User_Positions.Position_Label,_Users.Name_First" />
		<cfset Users = userManager.search(stStruct) />

		<!--- Dev Note Clay 9846: Handle when a single eligible rsp is returned and the current user isn't an eligible rsp--->
		<cfif Users.recordCount GT 1 OR (Users.RecordCount EQ 1 AND (qCurrentUser.Is_Eligible_RSP EQ 0 OR qCurrentUser.Is_On_Behalf_Of EQ 1))>
			<script language="JavaScript">
				function selectResponsibleUser(formName){
					event.returnValue = false;
					var oForm = eval("document." + formName);
					oForm.submit();
				}
			</script>
			<form method="post" name="MyForm" id="MyForm" ACTION="">
				<br><br>
				<table cellpadding="0" cellspacing="0" align="center" width="70%" height="100" style="border:2px solid black;align="center"">
					<tr>
						<td align="right" nowrap><b>Responsible Person:</b>&nbsp;&nbsp;&nbsp;</td>
						<td>
							<select name="Responsible_User_Id_Position_Id" id="Responsible_User_Id_Position_Id">
								<cfloop query="Users">
									<cfif Users.Position_Level eq 3>
										<cfset positionlevel = "#application.returned_customer_setting.market_label_singular#"/>
									<cfelseif Users.Position_Level eq 2>
										<cfset positionlevel = "#application.returned_customer_setting.region_label_singular#"/>
									<cfelseif Users.Position_Level eq 1>
										<cfset positionlevel = "#application.returned_customer_setting.zone_label_singular#"/>
									<cfelse>
										<cfset positionlevel = "Headquarters"/>
									</cfif>
									<option value="#User_Positions_ID#_#USER_ID#" <cfif USER_ID eq FORM.Responsible_User_Id AND User_Positions_ID EQ FORM.Responsible_Position_Id>selected</cfif>>
									#positionlevel# &nbsp;[#Position_Label#] &nbsp;#USER_FULL_NAME# <cfif appSettings.getPgmViewDisplaySPRAddress2() AND len(trim(company_name)) GT 0>- #Company_Name#</cfif></option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td colspan="2" align="center">
							<cf_smallLink
								title = "select user"
								url = "##"
								parameters = "onClick=""javascript: return selectResponsibleUser('MyForm');"""
							>
						</td>
					</tr>
				</table>
				<cfif len(trim(form.Program_ID)) GT 0>
					<input type="hidden" name="Program_ID" value="#form.Program_ID#">
					<input type="hidden" name="IsRevisionOfExistingContract" value="#form.IsRevisionOfExistingContract#" >
					<input type="hidden" name="IsCopyProgram" value="#form.IsCopyProgram#" >
					<input type="hidden" name="IsRollOver" value="#form.IsRollOver#" >
					<!--- Copied Search Sequence Indicators --->
					<input type="hidden" name="NewSearchSequence" value="<cfoutput>#Form.NewSearchSequence#</cfoutput>" >
					<input type="hidden" name="New_Business_Segment" value="<cfoutput>#Form.New_Business_Segment#</cfoutput>">
					<input type="hidden" name="New_Spending_Category" value="<cfoutput>#Form.New_Spending_Category#</cfoutput>">
					<input type="hidden" name="suppressProductsDistributors" value="<cfoutput>#Form.suppressProductsDistributors#</cfoutput>">
					<input type="hidden" name="Contract_Reference_Number" value="<cfoutput>#FORM.Contract_Reference_Number#</cfoutput>">
					<cfif appSettings.getView_Legacy_ID() EQ 1>
						<input type="hidden" name="legacy_id" value="<cfoutput>#form.legacy_id#</cfoutput>" >
					</cfif>
					<input type="hidden" name="start_date" value="<cfoutput>#form.start_date#</cfoutput>" >
					<input type="hidden" name="end_date" value="<cfoutput>#form.end_date#</cfoutput>" >
				</cfif>
			</form>
			<cfabort>
			<!--- Dev Note: Clay 9478 - Display Error when the current user is not a valid RSP and no valid RSPs occupy their position --->
		<cfelseif Users.recordCount EQ 0>
			<table align="center" width="100%">
				<tr><td style="color:rgb(255,0,0);font-weight:bold;text-align:center;">There are no valid Responsible Sales People in your postion.  Please notify your administrator. </td></tr>
			</table>
			<cfabort>
		</cfif>
	</cfif>
</cfoutput>
