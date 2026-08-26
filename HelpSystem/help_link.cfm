<!---
  * ==================================================================================================== 
  *    @File: \helpsystem\help_link.cfm
  *  @Author: Unknown
  *    @Date: Unknown
  * 
  * @Remarks: 
  *
  *
  * 
  *  
  * ==================================================================================================== 
--->
<cfparam name="GetHelpURL" default="0">
<cfparam name="_hlp_current_script_path" default="#CGI.SCRIPT_NAME#"> <!--- Dev Note: KAL; D7109 --->
<cfoutput>
<cfif GetHelpURL eq 0>
	<p><a href="/helpsystem/readxml.cfm?help=#_hlp_current_script_path#" onclick="NewWindow(this.href,'OpenHelpFile','800','600','Yes', 'Yes');return false;" >#application.util.string.actionLinkFormat2("get help")#</a></p>
<cfelse>
	<cfset URLLink = "/helpsystem/readxml.cfm?help=#_hlp_current_script_path#"><!--- Dev Note: KAL; D7109 --->
</cfif>
</cfoutput>
