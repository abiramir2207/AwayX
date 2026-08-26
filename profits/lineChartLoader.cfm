<!--- UUID must be given --->
<cfparam name="URL.uuid" type="UUID">
<!--- Call the CustomTag <cf_lineChart> with this UUID --->
<cf_lineChart internalUUID=#URL.uuid#>