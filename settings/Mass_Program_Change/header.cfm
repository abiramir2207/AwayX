<cfsilent>
<!---
       Name:          header.cfm
       Copyright:     Copyright (c) 2010 Blacksmith Applications, Inc.
       Created Date:  12/01/2010
       Created By:    Kal
       Label:		  25195
       Description:   Mass Program Change Upload Utility
--->
</cfsilent>
<cfset URL.PageTitle="MASS PROGRAM CHANGE - UPLOAD UTILITY" />
<cfset PageTitle="MASS PROGRAM CHANGE UPLOAD UTILITY" />
<cfinclude template="/settings/settings_title.cfm">
<!---<cfinclude template="/helpsystem/help_link.cfm">--->

<!--- instructions/help file --->
<div class="buttonText" align="left">
	<span class="redBracket">[</span><a href="##" onclick="javascript:popHelp()">help</a><span class="redBracket">]</span>
</div>

<!--- display last action/user info --->
<cfoutput>
	<cfif MPCUManager.lastMassUpdateUser().recordcount gte 1 >
		<center>
			<div class="headerUser">
				Last update: #MPCUManager.lastMassUpdateUser().UPDATE_TYPE#,
				executed by #MPCUManager.lastMassUpdateUser().USER_FULLNAME# on
				#dateformat(MPCUManager.lastMassUpdateUser().CREATED_DATE, 'mm/dd/yyy')#
				#timeformat(MPCUManager.lastMassUpdateUser().CREATED_DATE, 'h:mm:ss TT')#
			</div>
		</center>
	</cfif>
</cfoutput>
<br/>