<!---
	Copyright (c)2010 Blacksmith Applications, Inc.
	Filename:		AwayX\enterMultiPositions.cfm
	Created:		6/17/2012
	Developer:		Kal
	Description:	SSO/LDAP user has multiple accounts/positions/profiles
	Usage:			enter.cfm/enterLDAP.cfm
	Tip:			This file's content is subset of  enterLDAP.cfm
--->

<form name="MyForm" id="MyForm" method="post">
	<table width="784" border="0" cellpadding="0" cellspacing="0" align="CENTER" valign="top">
		<tr>
			<td valign="TOP">
				<img src="/images/Logon_Blacksmith/index_01.gif" width="38" height="171" alt="" />
			</td>
			<td valign="TOP">
				<img src="<cfoutput>#appSettings.getLoginPageLogoPath()#</cfoutput>" alt="" />
				<br />
				<img src="/images/Logon_Blacksmith/index_05.gif" width="75" height="178" alt="" valign="top" />
			</td>
			<td valign="TOP">
				<img src="/images/Logon_Blacksmith/index_03.gif" width="606" height="98" border="0" usemap="#mymap" />
				<br />
				<table border="0" cellspacing="0" cellpadding="6" align="center">
					<tr>
						<td colspan="2" valign="TOP">
							<div class="Title4">
									You have multiple accounts associated with this login.<br/>
									Please select one from below (profile-primary position).<br/>
									To select another logoff and re-login.
							</div>
						</td>
					</tr>
					<tr>
						<td>
							<Select name="id" CLASS="Title6">
								<option>Select</option>
								<cfoutput query="LoginInfo">
									<!--- Dev Note: KAL; 6/15/2010; D21554: Get Profile Name and Position --->
									<cfset variables.profileName	= application.oProfile.getProfileName(LoginInfo.Profiles_ID)/>	<!--- get profile description --->
									<cfset variables.qGetUser 		= userManager.getUser(LoginInfo.User_ID)/>
									<cfset variables.positionLabel	= variables.qGetUser.Position_Label />								<!--- get position label --->
									<cfset variables.User_Full_Name	= variables.qGetUser.User_Full_Name />								<!--- get fullname --->
									<option value="#LoginInfo.user_ID#" title="#variables.User_Full_Name# (#LoginInfo.user_code#)">#variables.profileName# - #variables.positionLabel#</option>
								</cfoutput>
							</Select>
						</td>
						<td><input type="image" name="button" src="/Images/Logon_Blacksmith/logon.gif"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<img src="/images/Logon_Blacksmith/index_07.gif" width="38" height="104" alt="" />
			</td>
			<td align="CENTER">&nbsp;</td>
		</tr>
	</table>
	<cfoutput>
		<cfif not isDefined("LogonId")>
		<input type="hidden" name="user_code" value="#form.user_code#">
		<input type="hidden" name="User_Password" value="#form.User_Password#">
		</cfif>
		<input type="hidden" name="token" value="#form.token#">
		<input type="hidden" name="UserMultiPositionSelected" value="1">
	</cfoutput>
</form>