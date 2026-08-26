<cfparam name="url.bbid" default="0">

<cfset return_BB_Status = 0>
<cfset return_BB_Is_Locked = 0>

<cfif url.bbid EQ 0>
	<cfset getInfo = queryNew("id")>
<cfelse>
	<cfquery name="getInfo" datasource="#application.datasource#">
		SELECT     dbo.Billback_Allied.BB_Is_Locked, dbo.Billback.Billback_Status_ID, dbo.Billback.Billback_ID
		FROM         dbo.Billback INNER JOIN
		                      dbo.Billback_Allied ON dbo.Billback.Billback_ID = dbo.Billback_Allied.Billback_id
		WHERE     (dbo.Billback.Billback_ID = '#url.bbid#')
	</cfquery>

	<cfset return_BB_Status = getInfo.BB_Is_Locked>
	<cfset return_BB_Is_Locked = getInfo.Billback_Status_ID>	
</cfif>


<script>
<cfoutput>	window.parent.getBBStats_BB_Locked = '#return_BB_Is_Locked#'
	window.parent.getBBStats_BB_Status = '#return_BB_Status#'
</cfoutput>
</script>