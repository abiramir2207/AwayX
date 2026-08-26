<!---
##	Description: RAL_Caller either displays the access level of the current report
##	or it shows the form fields used to maintain the access level for the Report.
##	this is only available for users with "Report" access (from User Profiles) of 4 and higher!!
##	10-7-2005: Modified the output to be driven by Report_Access_Level - D8429
##  8-25-2006: Added code to hide the none setting. - D10451
--->
<cfif ThisTag.ExecutionMode EQ "Start"><!--- Suppress Dual Execution --->
		<cfset RAL = CreateObject("component", "components.user.ReportsCentralAccess").init() />
		<cfset GetLevels = RAL.getRCACodeList(1) />
		<CFPARAM NAME="Attributes.ReportID"	DEFAULT="0" />
		<CFPARAM NAME="Attributes.SuppressOutput" DEFAULT="0">
		<CFPARAM NAME="Attributes.RAC" DEFAULT="0" />		
		<CFPARAM NAME="reportlevel" DEFAULT="0" />
		<cfset reportLevel = RAL.getRcAccess(Attributes.reportID) />
		
		<cfif Attributes.RAC GTE 4> <!--- Admins Only!! --->
			<cfif caller.url.maint is 1>
				<SELECT NAME="<cfoutput>#Attributes.reportID#</cfoutput>" STYLE="WIDTH: 65px;font-size: 10px;">
					<cfoutput query="GetLevels">
					<OPTION VALUE="#GetLevels.Level_Code#" class="al1" <CFIF reportLevel.level_code EQ GetLevels.Level_Code >SELECTED</cfif>>#Getlevels.Description#</OPTION>
					</cfoutput>
				</SELECT>
			<cfelse>
					<cfoutput><Span class="tal#reportLevel.level_code#">#reportLevel.Level_Code#</Span> </cfoutput>
			</cfif>
		</cfif>	
	
		<cfif Attributes.SuppressOutput EQ 0>
			<cfif Attributes.RAC GTE reportLevel.Level_Code AND reportLevel.active EQ 1>
				<cfoutput><a href="#reportLevel.report_url#" #reportLevel.report_url_options# #reportLevel.report_url_jscript# onclick="processingPopUpDisplay('div.customContainer');">#reportLevel.report_name#</a></cfoutput>
			<cfelse>
				<cfoutput>#reportLevel.report_name#</cfoutput>	
			</cfif>
		</cfif>
</cfif>
