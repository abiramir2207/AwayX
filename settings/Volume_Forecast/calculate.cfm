<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Volume_Forecast\calculate.cfm
	Created:	2/13/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		<brief description of what the file is used for>
	Usage:
		<templates that depend on this file>
---->
<cfoutput>
	<cfquery name="updatecra" datasource="#application.datasource#" >
		EXEC Populate_VF_Level #url.id#
		EXEC Populate_VF_Detail #url.id#
	</cfquery>
</cfoutput>


<div style="color:green;font-size:12px;" align="center"><b>Calculate is done. This window will close automatically in 3 seconds.<b/></div>

<script>
	window.opener.enableCalculate();
	setTimeout("closewindow()",3000);
	function closewindow(){
		self.close();	
	}
</script> 
