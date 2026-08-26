<!--- correct --->
<cfparam name="form.Sales_Agreement_ID" default="">

<cfset userManager = CreateObject("component", "components.user.UserManager") />
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!------ get user positions id ----->
<cfset This_User_Positions_ID = userManager.getPositionId(request.AccessStructure.User_ID, 1) />

<!------ select the sales person responsible ----->
<cfoutput>
<cfset showSalesPersonSelection = false>
	<cfset stStruct = StructNew() />
	<cfset stStruct.userPosition = userManager.getPositionId(request.AccessStructure.User_ID, 0) />
	<!--- Dev Note: Clay 9478 - if display_eligible_rsp is on, display the pull-down list for results of 1 or greater. --->
	<cfif ListLen(stStruct.userPosition, ",") GTE 1>	
		<cfset showSalesPersonSelection = true />
	</cfif>

<cfparam name="FORM.Responsible_User_Id_Position_Id" 	default="#This_User_Positions_ID#_#request.AccessStructure.User_ID#">
<cfset FORM.Responsible_Position_Id = ListFirst(FORM.Responsible_User_Id_Position_Id, "_")>
<cfset FORM.Responsible_User_Id = ListLast(FORM.Responsible_User_Id_Position_Id, "_")>


<cfif showSalesPersonSelection>	
	<cfset stStruct.returnUserSecondaryPositionsForUser = request.AccessStructure.User_ID>
	<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
		<cfset stStruct.userId = request.AccessStructure.User_ID>
	</cfif>
		<cfif appsettings.getDisplayEligibleRSP() EQ 1>
			<cfset stStruct.Eligible_RSP = 1>
		</cfif>
		<cfset stStruct.userPositionType = "P,S">
	
	<cfset stStruct.sortBy = "User_Positions.Position_Label,_Users.Name_First" />
	<cfset Users = userManager.search(stStruct) />	
	
		<!--- Dev Note Clay 9846: Handle when a single eligible rsp is returned and the current user isn't an eligible rsp--->
		<cfif Users.recordCount GT 1 OR (Users.RecordCount EQ 1 AND userManager.isUserEligibleRSP(request.AccessStructure.User_ID) EQ 0)>
		<script language="JavaScript">
			function selectResponsibleUser(formName)
			{
				event.returnValue = false;
				var oForm = eval("document." + formName);
				oForm.submit();
			}
		</script>
		<form method="post" name="MyForm" id="MyForm" ACTION="/common_files/contracts/sales_agreement.cfm">
		<br><br>
		<TABLE cellpadding="0" cellspacing="0" align="center" width="70%" height="100" style="border:2px solid black;align="center"">
		<TR>
			<TD align="right" nowrap><B>Responsible Person:</B>&nbsp;&nbsp;&nbsp;</TD>
			<TD>
			<select name="Responsible_User_Id_Position_Id" id="Responsible_User_Id_Position_Id">
				<cfloop query="Users">
				<option value="#User_Positions_ID#_#USER_ID#" <cfif USER_ID eq FORM.Responsible_User_Id AND User_Positions_ID EQ FORM.Responsible_Position_Id>selected</cfif>> 
				[#Position_Label#] #USER_FULL_NAME# <cfif len(trim(company_name)) GT 0>- #Company_Name#</cfif></option>
				</cfloop>
			</select>
			</TD>
		</TR>
		<TR>
			<TD colspan="2" align="center">
				<CF_smallLink 
					title = "select user" 
					url = "##"
					parameters = "onClick=""javascript: return selectResponsibleUser('MyForm');"""
				>
			</TD>
		</TR>
		</TABLE>
		</form>
	<cfelseif (Users.RecordCount EQ 1 OR userManager.isUserEligibleRSP(request.AccessStructure.User_ID) EQ 1)>
			<form method="post" name="MyForm" id="MyForm" ACTION="/common_files/contracts/sales_agreement.cfm">
					<input type="hidden" name="Responsible_User_Id_Position_Id" value="#Users.User_Positions_ID#_#USER_ID#">
			</form>
			<script language="JavaScript">
					MyForm.submit();
			</script>
	<!--- Dev Note: Clay 9478 - Display Error when the current user is not a valid RSP and no valid RSPs occupy their position --->
	<cfelseif Users.recordCount EQ 0>
		<TABLE align="center" width="100%">
			<tr><td style="color:rgb(255,0,0);font-weight:bold;text-align:center;">There are no valid Responsible Sales People in your postion.  Please notify your administrator. </td></tr>
		</TABLE>
	</cfif>
</cfif>
</cfoutput>