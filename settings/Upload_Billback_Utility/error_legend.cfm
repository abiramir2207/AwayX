<!---  
       Name:          error_legend.cfm           
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  11367
       Description:   
--->
 
<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
<cfset getErrors = uploadUtility.getErrorCodes() />

<!--- Sub Section Title--->
<cfoutput>
	<br><span class="subheading">Error Codes</span><img src="/images/clear.gif" height="1px" width="410px"><B><FONT COLOR="Red">[</FONT>&nbsp;<a href="error_legend.cfm?printable=1" target="winErrorLegend"><img src="/images/printimg.gif"> printer friendly</a>&nbsp;<FONT COLOR="Red">]</FONT></B><br>
</cfoutput>
<br>

<cfparam name="printable" default="0">

<cfif printable EQ 1>
	<cfinclude template="header.cfm">
</cfif>

<div id="markup">
	<table border='1' style="border-collapse:collapsed">
	<thead><tr><th>Error ID</th><th>Error Description/Rules</th></tr></thead>
	<tbody>
	<cfoutput query="getErrors">
		<tr><td rowspan="2">#Error_CODE#</td><td>#Error_Desc#</td></tr>
		<tr><td >#error_valid_rules#</td></tr>
	</cfoutput>
	</tbody>
	</table>
</div>




