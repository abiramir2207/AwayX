<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Planning_Groups\_pg_action.cfm
      Date:     2015 March
      Author:   Chris Nguyen
      Purpose:  Display action links at the top of planning groups setting
----------------------------------------------------------------------------------------------------------------------->
<cfsilent>
<cfsetting enablecfoutputonly="true">
<cfsavecontent variable="variables.actions946">
<cfif Get_Profile_Settings.Planning_Groups_Create EQ 2>
	<cfif active>
		<cfoutput><a href="##" onclick="MultiDeActivate()">#application.util.string.actionLinkFormat2("deactivate groups")#</a></cfoutput>
	<cfelse>
		<cfoutput><a href="##" onclick="MultiActivate()">#application.util.string.actionLinkFormat2("activate groups")#</a></cfoutput>
	</cfif>
</cfif>
<cfoutput><a href="##" id="exm85" title="Select one or more planning groups below using the check box on the far left.  This link will provide an Excel sheet of the members of the groups you selected.">#application.util.string.actionLinkFormat2("export members")#</a></cfoutput>
<cfoutput><a href="##" id="ebm31" title="To research Planning Groups that contain specific products, distributors or operators, this link will provide a search utility.  The application will then provide an Excel sheet of the Planning Groups that your selection[s] are members of.">#application.util.string.actionLinkFormat2("export by members")#</a></cfoutput>
</cfsavecontent>
<cfsetting enablecfoutputonly="false">
</cfsilent>
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<style> div#cmd918 a { margin:0 20px 0 0; } </style>
<div style="margin:13px 0" id="cmd918"><cfoutput>#variables.actions946#</cfoutput></div>