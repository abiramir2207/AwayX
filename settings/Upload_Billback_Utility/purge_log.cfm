<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
<cfset purgeRecords = uploadUtility.getPurgedUploads() />
<cfparam name="printable" default="0">

<cfif printable EQ 1>
	<cfinclude template="header.cfm">
</cfif>

<!--- Sub Section Title--->
<cfoutput>
	<br><span class="subheading">Purge Log</span><img src="/images/clear.gif" height="1px" width="410px">
	<B><FONT COLOR="Red">[</FONT>&nbsp;<a href="purge_log.cfm?printable=1" target="winPurgeLog"><img src="/images/printimg.gif"> printer friendly</a>&nbsp;<FONT COLOR="Red">]</FONT></B><br>
</cfoutput>
<br>

<div id="mainContent">
	<table border="1">
	<thead><th>ID</th><th>Header File</th><th>Detail File</th><th>Purged</th></thead>
	<tbody>
	<cfif purgeRecords.recordcount GT 0>
		<cfoutput query="purgeRecords">
			<tr><td>#upload_id#</td><td>#header_file_name#</td><td>#detail_file_name#</td><td>#deleted_by# on #dateformat(deleted_date,'MM/DD/YYYY')# #timeformat(deleted_date,'HH:MM TT')#</td></tr>	
		</cfoutput>
	</cfif>
	</tbody>
	</table>
</div>