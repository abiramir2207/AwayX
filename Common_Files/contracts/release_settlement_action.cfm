<cfparam name="Form.ListContractMainID" default="">
<cfparam name="FromFlex" default="">
<cfparam name="FromAGGrid" default="">

<cfset releasemanager = CreateObject("component","components.programs.releasesettlement.releasesettlementmanager") />
<cfif Form.ListContractMainID neq "">
	<cfset result = releasemanager.send(Form.ListContractMainID,request.accessstructure.user_id)>
<cfelse>
	<cfset result = releasemanager.send(form.cid,request.accessstructure.user_id)>
</cfif>

<cfif FromFlex EQ 1>
<script>
	window.opener.location.href = '/flex/search/ProgramSearchFx.cfm?Reload=1';
	window.close();
</script>
<cfelseif FromAGGrid EQ 1>
<script>
	window.opener.location.href = '/programs/program_search.cfm';
	window.close();
</script>
<cfelse>
	<cfif result>
		<script type="text/javascript" language="JavaScript">
			opener.focus();
			opener.location.reload(true);
			window.close();
		</script>
	<cfelse>
		<div style="font-size:14px;font-weight:bold;">Release Settlement</div>
		<hr style="width:350px;color:orange;" align="left">
		<p>Results: "This program cannot be released at this time."</p>
		<cfabort>
	</cfif>
</cfif>
