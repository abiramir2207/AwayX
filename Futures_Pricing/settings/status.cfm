<!------ preservation.cfm ----->
<cfoutput>
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">

<cfset statusManager = CreateObject("component", "components.futures_pricing.StatusManager") />
<cfset qAllStatus = statusManager.getAll() />

<cfif form.state>
	<cfset status = statusManager.get(0) />
	<cfset status.setId(form.id) />
	<cfparam name="form.FP_Status_Desc" 	default="">
	
	<cfset status.setDesc(form.FP_Status_Desc) />
	<cfset status.setUpdatedBy(request.AccessStructure.User_ID) />
	<cfset statusManager.save() />
	
	<cflocation addtoken="No" url="#thisPage#?command=lStatus" />
	<cfabort>
<cfelse>
	<cfset status = statusManager.get(form.id) />
</cfif>



<script language="JavaScript">
function validateAndSubmit(thisForm, sCommand)
{
	var isValid = true;
	isValid = validateThisField(2, document.all.FP_Status_Desc, "'Status Description' cannot be empty") && isValid;
	
	if(isValid)
	{
		submitForm(thisForm, sCommand);
	}
	else
	{
		showMessageWindow();
	}
	return false;
}
</script>

<table cellpadding="2" cellspacing="5" border="0" width="100%">
<tr valign="top">
	<td style="font-weight:bold;color:navy;font-size:12px;border-bottom:1px solid orange;">Stored Records</td>
	<td style="font-weight:bold;color:navy;font-size:12px;border-bottom:1px solid orange;"><cfif form.id>Edit Record</cfif></td>
</tr>
<tr valign="top">
	<td width="40%">
	<!------ list all ----->
	<span STYLE="height:300px;overflow:auto;">	
	<table cellpadding="2" cellspacing="0" class="MainTable" width="100%">
	<tr>
		<td>&nbsp;</td>
		<td id="header" width=""><B>Description</B></td>
	</tr>
	<cfloop query="qAllStatus">
		<tr>
		<td id="header" nowrap><B>Step #FP_Status_ID#.</B></td>
		<td width="100%">
		<a href="#thisPage#?command=#form.command#&id=#FP_Status_ID#">#FP_Status_Desc#&nbsp;</a><br>
		</td>
		</tr>
	</cfloop>
	</table>
	</span>	
	</td>
	<td width="60%">
	<cfif Len(status.getUpdatedBy()) GT 0>
	<TABLE align="center" BGCOLOR="White" BORDERCOLOR="Orange" BORDER="1" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(status.getUpdatedOn(), 'mm/dd/yyyy')# #timeformat(status.getUpdatedOn(), 'hh:mm:ss TT')# by #status.getUpdatedByUserName()#</B></FONT>
	</TD></TR></TABLE><BR>
	</cfif>
	<!------ add / edit ----->
	<cfif status.getId()>
	<table cellpadding="2" cellspacing="0">
	<tr>
		<td><B>Description:</B><span id="err_sp_FP_Status_Desc">&nbsp;&nbsp;</span></td>
		<td>
		<input type="Text" name="FP_Status_Desc" value="#status.getDesc()#" size="50" maxlength="50">
		</td>
	</tr>	
	</table>
	<input type="Hidden" name="id" value="#status.getId()#">
	<div align="center">	
	<CF_smallLink 
			title = "save" 
			url = "##"
			parameters = "onClick=""JavaScript: return validateAndSubmit(document.#formName#, '#form.command#');"""
		>
	</div>
	</cfif>
	</td>
</tr>
</table>

</cfoutput>