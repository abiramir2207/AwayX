<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \HelpSystem\help_link2.cfm
      Date:     2015 April
      Author:   Chris Nguyen
      Purpose:  Compact version of get help link at the top upper left
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="GetHelpURL" default="0">
<cfparam name="_hlp_current_script_path" default="#CGI.SCRIPT_NAME#"> <!--- Dev Note: KAL; D7109 --->
</cfsilent>
<cfif GetHelpURL eq 0>
	<cfoutput><div><a style="font-size:11px;" href="/helpsystem/readxml.cfm?help=#_hlp_current_script_path#" onclick="NewWindow(this.href,'OpenHelpFile','800','600','Yes', 'Yes');return false;" class="helplink"><span class=k86>[</span> get help <span class=k86>]</span></a></div></cfoutput>
<cfelse>
	<cfoutput><cfset URLLink = "/helpsystem/readxml.cfm?help=#_hlp_current_script_path#"></cfoutput>
</cfif>

