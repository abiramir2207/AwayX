
<CFIF isdefined("Form.deleterule")>
	<!--- Delete all rules from the pricing rule table --->
	<CFQUERY NAME="Delete_Rule1" datasource="#application.datasource#">
		Delete from 	Pricing_Rule
		Where			Pricing_Rule_ID = '#Pricing_Rule_ID#';
		Delete from 	Pricing_Rule_Products
		Where			Pricing_Rule_ID = '#Pricing_Rule_ID#'
	</CFQUERY>
	<script language="JavaScript">
		function seeya()
		{
			window.parent.window.location.href="index.cfm";
		}
		setTimeout('seeya()',0000); 
	</script>
<CFELSE>
	<script language="JavaScript">
	function seeya()
	{
		history.back();
	}
	setTimeout('history.back()',0000); 
	</script>
</CFIF>



