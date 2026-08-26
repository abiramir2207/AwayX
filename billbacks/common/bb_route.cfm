<!------bb_route.cfm----->

<CFPARAM NAME="URL.BBID"								DEFAULT="">
<CFSET Document_ID=URL.BBID>
<CFSET Route_Document_Type="1">
<CFSET RedirectURL="/billbacks/capture/Billback_Summary.cfm?BBID=#URL.BBID#">

<CFINCLUDE TEMPLATE="/Route/Create_Route_Message.cfm">
<script>
	// BSD D11544   	
    try { window.parent.dyniframesize(); } catch (err) { };
</script>