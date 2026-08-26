<!-----------------------------------------------------------------------------

FILE NAME:		TC_GroupLevelAccessValues.cfm
DESCRIPTION:	
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	14-Sep-2015	 Created

------------------------------------------------------------------------------> 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<cfset PAGE_TITLE="Select Profiles">
<cfset maxCount = 10 />
<cfset URL.PageTitle="#application.returned_customer_setting.type_code_label_singular# Access/Approve :: Select Profiles">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
	<script language="javascript">
	function submitForm() 
	{
		var i, len, inputs = document.frmProfiles.getElementsByTagName("input");
		var chkCount = 0;
		for (i = 0, len = inputs.length; i < len; i++) 
		{
	        if (inputs[i].type === "checkbox" && inputs[i].checked)
			{
				chkCount++;
			}
		}
		if (chkCount == 0)
		{
			alert('Please select atleast one profile to proceed!!');
		}
		else
		{
			document.frmProfiles.submit();
		}
	}
	
	function chkSelCount()
	{
		var i, len, inputs = document.frmProfiles.getElementsByTagName("input");
		var chkCount = 0;
		var maxChkCount = 10;
	    for (i = 0, len = inputs.length; i < len; i++) 
		{
	        if (inputs[i].type === "checkbox" && inputs[i].checked)
			{
				chkCount++;
			}
	        if (chkCount == maxChkCount)
			{
				// alert('Only 10 profiles can be selected. Please click the continue link');
				break;
			}
    	}
		// check if 10 checkboxes are checked disable all the other once the count is reached.
		if (chkCount == maxChkCount)
		{
			for (i = 0, len = inputs.length; i < len; i++) 
			{
	       		if (inputs[i].type === "checkbox" && !(inputs[i].checked))
				{
					inputs[i].disabled = true;
				}
			}
		}
		// if one checkbox is unchecked, then enable all, so that the user can change his selection
		if (chkCount < maxChkCount)
		{
			for (i = 0, len = inputs.length; i < len; i++) 
			{
					inputs[i].disabled = false;
			}
		}
 	}
	</script>
</HEAD>

<BODY BGCOLOR="WhiteSmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="8" RIGHTMARGIN="8" TOPMARGIN="8" onLoad="">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<br>
<cfoutput>
<cfset getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles()>
<cfset maxCols = 2>
<form action="TC_GroupLevelAccessValues.cfm" method="post" name="frmProfiles" id="frmProfiles">
	<table border="0" cellspacing="0" cellpadding="2" align="center" width="500">
		<tr>
			<td align="right">
				<CF_button
					button_name		=	""
					button_caption	=	"continue"
					button_action	=	"submitForm();"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
				<br>
			</td>
		</tr>
		<tr>
			<td>
				<strong><font color="red">Note:	 Only #maxCount# profiles can be picked and once 10 is selected, the others will get disabled.</font></strong>
			</td>
		</tr>
	</table>

	<table border="1" cellspacing="0" cellpadding="2" align="center" width="500" bordercolor="cccc99">
		<thead bgcolor="c0c0c0">
			<tr  BGCOLOR="ffce84">
				<cfloop index="i" from="1" to="#maxCols#">
					<td width="20">&nbsp;</td>
					<td><strong>Profiles</strong></td>
				</cfloop>
			</tr>
		</thead>	
		<tr>
			<cfloop query="getProfiles">
				<td width="25" align="center">
					<input type="Checkbox" name="selProfiles" value="#getProfiles.profiles_id#" onclick="chkSelCount();">
				</td>
				<td>
					&nbsp;#getProfiles.Profiles_Short_Desc#
				</td>
				<cfif not currentRow mod maxCols and currentRow neq recordCount></tr><tr bgcolor="FFFFFF"></cfif>
				<cfset x = currentRow>
			</cfloop>
		<cfif Evaluate((x mod maxCols)) NEQ 0>
			<cfloop index="i" from="#Evaluate((x mod maxCols)+1)#" to="#maxCols#">
				<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
			</cfloop>
		</cfif>
		</tr>
	</table>
	<table border="0" cellspacing="0" cellpadding="2" align="center" width="500">
		<tr>
			<td align="right">
				<br>
				<CF_button
					button_name		=	""
					button_caption	=	"continue"
					button_action	=	"submitForm();"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</td>
		</tr>
	</table>
	</cfoutput>
</form>

</BODY>
</HTML>