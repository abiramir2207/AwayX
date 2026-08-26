<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Delete WIP</TITLE>
	
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
	
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "SYSTEM ADMINISTRATION: Delete WIP Billbacks and Programs">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!---Help Files--->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<p></p>

<form name="DeleteWIP" action="confirm_deletion.cfm" method="post">

<table>
<tr>
	<td><strong>Purge WIP records older than this many days:</strong></td>
	<td><input type="text" name="Days_Back" size="10" onKeyUp="clenseText(this, '0123456789')"></td>
</tr>
<tr>
	<td><strong>Purge WIP programs:</strong></td>
	<td><input type="checkbox" name="Purge_Programs" value="1"></td>
</tr>
<tr>
	<td><strong>Purge WIP billbacks:</strong></td>
	<td><input type="checkbox" name="Purge_Billbacks" value="1"></td>
</tr>

<tr><td colspan="2" align="Center"><input type="submit" value="Confirm deleted records"></td></tr>

</table>

</form>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>