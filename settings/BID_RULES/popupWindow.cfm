<script>
	window.returnValue = 1;
</script>

<cfif FileExists("#Application.Doc_Path#\data_files\created\settings\bid_rules\rulesarelocked")>
<cffile action="READ" file="#Application.Doc_Path#\data_files\created\bid_rules\rulesarelocked" variable="filecontents">
	<cfset tempArray = listtoarray(filecontents, ",")>
	<cfif trim(tempArray[1]) NEQ trim(request.AccessStructure.user_id)>
		<script>
			window.close();
		</script>
		<cfabort>
	</cfif>
</cfif>

<cffile action="WRITE" file="#Application.Doc_Path#\data_files\created\settings\bid_rules\rulesarelocked" output="#request.AccessStructure.user_id#,#now()#" addnewline="Yes">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Manage Bid Rule</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!-- <iframe name="contentWindow" src="popupWindow_Content.cfm" width="100%" height="100%" scrolling="no" frameborder="0"></iframe> -->
<iframe name="contentWindow" src="" width="100%" height="100%" scrolling="Yes" frameborder="0"></iframe>
<cfoutput>
<script>
	contentWindow.location.href = "popupWindow_Content.cfm?id=" + window.dialogArguments[0] + "&Action=" + window.dialogArguments[1]
</script>
</cfoutput>
	
</BODY>
</HTML>




