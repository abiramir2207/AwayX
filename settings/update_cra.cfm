<!----
	Filename:	C:\Work\Code\base\AwayX\settings\update_cra.cfm
	Created:	2/10/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USE TO UPDATE CRA
	Usage:
		settings / programs / settings
---->
<cfquery name="updatecra" datasource="#application.datasource#" >
	EXEC Populate_Program_Approvable_Positions 0
</cfquery>
<div style="color:green;font-size:12px;" align="center"><b>Done. This window will close automatically in 2 seconds.<b/></div>
<script>
	setTimeout("closewindow()",2000);
	function closewindow(){
		self.close();
	}
</script> 