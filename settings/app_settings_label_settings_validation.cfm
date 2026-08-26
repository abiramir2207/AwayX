<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfparam name="form.submitForm" default="0">
<cfparam name="URL.GROUP_LEVEL_ID" default="0">
<!--- Group_Template: PG_Group_Type: 1 - Product;  2 - Customer; 3 - Operator --->
<cfparam name="URL.PGGroupType" default="0">
<cfparam name="form.firstParentID" default="0">

<cfset objLabels = CreateObject("component", "components.settings.Labels.Labels")>

<!--- When the form sumbits --->
<cfif form.submitForm eq 1>
	<cfset objLabels.updateGroupTemplateSettings(URL.PGGroupType,URL.GROUP_LEVEL_ID,form.firstParentID)>

	<script>
		window.close();
		window.opener.location.reload();
	</script>
</cfif>

<cfinclude template="/common_files/jQuery.cfm">
<html>
<head>
	<title>View Templates</title>
	<SCRIPT>
		function expandTable(objectID) 
		{
			var object = document.getElementById("TB_"+objectID);
			tempVar = eval("document.all.TB_"+objectID);
			if (object.style.display =='block') {
				object.style.display='none';
				removeLink.style.visibility='none';
			}
			else {
				object.style.display='block';
				removeLink.style.visibility='visible';
			}
			return;
		}

		$(document).ready(function () {
			$("#selectAllOptions").click(function () {
				if($(".deleteOption").prop('checked') == true){
					$(".deleteOption").attr('checked', false);
				}
				else{
					$(".deleteOption").attr('checked', true);
				}
			});
		});
	</SCRIPT>
</head>
<body>



<BR>
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>	

<font color = "red"  STYLE="font-size:14px; font-family:Century Gothic;">
<b>You cannot deactivate this attribute because it is being used as a filter in a template.<br>Remove the attribute as a filter below before continuing with deactivating this attribute. </b>
</font>

<br><br>
<div style="width:100%;">
<div style="width:45%;float:left;"><cfoutput><a href="##" id="removeLink" <cfif form.submitForm eq 0> style="visibility:hidden" </cfif> onClick="document.frmTemplateList.submit();">#application.util.string.actionLinkFormat2("remove from selected")#</a></cfoutput></div>
	<div style="width:45%;float:left;">
		<b><font color="red">[</font></b>
		<a id="showTemplate" href="javascript:expandTable('ViewTemplate');"<font size="3"><b id="picon_showTemplate">view templates</b></font></a>
		<b><font color="red">]</font></b>
	</div>
</div>

<cfoutput> <br>
<cfset getTemplatesSettingsLabels = objLabels.getTemplatesSettingLabel(#URL.GROUP_LEVEL_ID#,#URL.PGGroupType#)>
</cfoutput>

<form name="frmTemplateList" method="post" action="app_settings_label_settings_validation.cfm?GROUP_LEVEL_ID=<cfoutput>#URL.GROUP_LEVEL_ID#&PGGroupType=#URL.PGGroupType#</cfoutput>">
<TABLE id="TB_ViewTemplate" <cfif form.submitForm eq 0> style="display:none" </cfif> WIDTH="99%" CELLPADDING="4" CELLSPACING="0" CLASS="Maintable" border="0">
	<!--- TABLE HEADERS --->
	<TR BGCOLOR="#FFCE84" valign="center">
		<TD ID="header"><input type='checkbox' name='delete' id='selectAllOptions' /></TD>
		<TD ID="header"><strong>Generic Type</strong></TD>
		<TD ID="header"><strong>Program Type<strong></TD>
		<TD ID="header"><strong>Description<strong></TD>
	</TR>
	<CFOUTPUT query = "getTemplatesSettingsLabels">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" >
			<TD valign="center"  <CFIF currentrow mod 2>FFFFFF<cfelse>C6FFC6</CFIF>" nowrap><input type='checkbox' name='firstParentID' value='#First_Parent_ID#' class='deleteOption' /></TD>
			<TD valign="center"  <CFIF currentrow mod 2>FFFFFF<cfelse>C6FFC6</CFIF>" nowrap>#Generic_Type#</TD>
			<TD valign="center"  <CFIF currentrow mod 2>FFFFFF<cfelse>C6FFC6</CFIF>" nowrap>#Created_Type#</TD>
			<TD valign="center"  <CFIF currentrow mod 2>FFFFFF<cfelse>C6FFC6</CFIF>" nowrap>#Program_Description#</TD>
		</TR>	
	</CFOUTPUT>
</TABLE>
	<input type="hidden" name="submitForm" value="1">
</form>
<p></p>	

</body>
</html>