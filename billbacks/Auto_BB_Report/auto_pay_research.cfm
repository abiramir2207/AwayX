<cfmodule template="/customTags/layout.cfm" layoutID = "autoPay" selectedIndex = #nav_index#><br>
<cfparam name="selectedTab" default="0">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings        = genSettingsManager.get()>
<cf_include file_to_include="/common_files/tabnav.css"/>
<cfoutput>
<div class="nav">
    <ul class="nav">
        <li <cfif selectedTab EQ 0>class="active"</cfif>>
            <a class="topnav" href="Auto_Pay_Research.cfm?selectedTab=0&nav_index=#nav_index#">Program Pacing</a>
        </li>
        <li <cfif selectedTab EQ 1>class="active"</cfif>>
            <a class="topnav" href="Auto_Pay_Research.cfm?selectedTab=1&nav_index=#nav_index#">Monthly Pacing</a>
        </li>
        <li <cfif selectedTab EQ 2>class="active"</cfif>>
            <a class="topnav" href="Auto_Pay_Research.cfm?selectedTab=2&nav_index=#nav_index#">Open Pay Periods</a>
        </li>
    </ul>
</div>
</cfoutput>

	<cfif selectedTab EQ 0>
		<cfinclude template = "/billbacks/auto_bb_report/auto_stats.cfm">
	<cfelseif selectedTab EQ 1>
		<cfinclude template = "/billbacks/auto_bb_report/summary_stats.cfm">
	<cfelse>
		<cfinclude template = "/billbacks/auto_bb_report/tickler.cfm">
	</cfif>

</cfmodule>			