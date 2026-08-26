<cfsilent>
<!---
       Name:          header.cfm
       Copyright:     Copyright (c) 2013 Blacksmith Applications, Inc.       
       Created Date:  05/30/2013
       Created By:    Kal
       Label:		  34605
       Description:   Mass Price Change Utility
--->
</cfsilent>
<cfset URL.PageTitle="MASS PRICE CHANGE - UTILITY" />
<cfset PageTitle="MASS PRICE CHANGE UTILITY" />
<cfinclude template="/settings/settings_title.cfm">
<!---<cfinclude template="/helpsystem/help_link.cfm">--->

<!--- instructions/help file --->
<div class="buttonText" align="left">
	<span class="redBracket">[</span><a href="##" onclick="javascript:popHelp()">help</a><span class="redBracket">]</span>
</div>

<!--- display last action/user info --->
<cfoutput>
	<cfif MPCManager.lastMassUpdateUser().recordcount gte 1 >
		<center>
			<div class="headerUser">
				Last update: #MPCManager.lastMassUpdateUser().UPDATE_TYPE#,
				executed by #MPCManager.lastMassUpdateUser().USER_FULLNAME# on
				#dateformat(MPCManager.lastMassUpdateUser().CREATED_DATE, 'mm/dd/yyy')#
				#timeformat(MPCManager.lastMassUpdateUser().CREATED_DATE, 'h:mm:ss TT')#
			</div>
		</center>
	</cfif>
</cfoutput>
<br/>