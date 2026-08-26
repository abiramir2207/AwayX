<!------ preservation.cfm ----->
<cfoutput>
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">

<cfset preservationManager = CreateObject("component", "components.futures_pricing.PreservationManager") />
<cfset qAllPreservations = preservationManager.getAll() />

<cfif form.state>
	<cfset preservation = preservationManager.get(0) />
	<cfset preservation.setId(form.id) />
	<cfif form.command EQ "dPreservation">
	
		<cfset preservationManager.delete() />
	
	<cfelse>
	
		<cfparam name="form.Preservation_Desc" 	default="">
		<cfparam name="form.Active" 	default="0">
		
		<cfset preservation.setDesc(form.Preservation_Desc) />
		<cfset preservation.setActive(form.Active) />
		<cfset preservation.setUpdatedBy(request.AccessStructure.User_ID) />
		<cfset preservationManager.save() />
		
	</cfif>
	<cflocation addtoken="No" url="#thisPage#?command=lPreservation" />
	<cfabort>
<cfelse>
	<cfset preservation = preservationManager.get(form.id) />
</cfif>


<script language="JavaScript">
function validateAndSubmit(thisForm, sCommand)
{
	var isValid = true;
	isValid = validateThisField(2, document.all.Preservation_Desc, "'Preservation Description' cannot be empty") && isValid;
	
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
	<td style="font-weight:bold;color:navy;font-size:12px;border-bottom:1px solid orange;"><cfif form.id>Edit<cfelse>Add New</cfif> Record</td>
</tr>
<tr valign="top">
	<td width="40%">
	<!------ list all ----->
	<span STYLE="height:300px;overflow:auto;">	
	<table cellpadding="2" cellspacing="0" class="MainTable" width="100%">
	<tr>
		<td id="header" width=""><B>Description</B></td>
		<td id="header" width="15" nowrap><B>Status</B></td>
	</tr>
	<cfloop query="qAllPreservations">
		<tr>
		<td>
		<a href="#thisPage#?command=#form.command#&id=#FP_Preservation_ID#">#Preservation_Desc#</a><br>
		</td>
		<td>
			<cfif Active>
			<img src="/images/yes_small.gif" alt="Active">
			<cfelse>
			<img src="/images/no_small.gif" alt="Inactive">
			</cfif>
		</td>
		</tr>
	</cfloop>
	</table>
	</span>	
	</td>
	<td width="60%">
	<cfif Len(preservation.getUpdatedBy()) GT 0>
	<TABLE align="center" BGCOLOR="White" BORDERCOLOR="Orange" BORDER="1" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(preservation.getUpdatedOn(), 'mm/dd/yyyy')# #timeformat(preservation.getUpdatedOn(), 'hh:mm:ss TT')# by #preservation.getUpdatedByUserName()#</B></FONT>
	</TD></TR></TABLE><BR>
	</cfif>
	<!------ add / edit ----->
	<table cellpadding="2" cellspacing="0">
	<tr>
		<td><B>Description:</B><span id="err_sp_Preservation_Desc">&nbsp;&nbsp;</span></td>
		<td>
		<input type="Text" name="Preservation_Desc" value="#preservation.getDesc()#" size="50" maxlength="50">
		</td>
	</tr>
	<tr>
		<td><B>Active</B> (*)</td>
		<td>
		<cfset disableActiveBox = false />
		<cfif preservation.getActive() AND form.id>
			<cfif preservationManager.getRequestWithPreservation(form.id).recordCount>
				<cfset disableActiveBox = true />
			</cfif>
		</cfif>
		<cfif disableActiveBox>
		<input type="Checkbox" value="1" <cfif preservation.getActive()> checked</cfif> disabled>
		<input type="Hidden" name="Active" value="1">
		<cfelse>
		<input type="Checkbox" name="Active" value="1" <cfif preservation.getActive()> checked</cfif>>
		</cfif>
		</td>
	</tr>
	</table>
	<input type="Hidden" name="id" value="#preservation.getId()#">
	<div align="center">
	<cfif NOT preservation.getActive()>
	<CF_smallLink 
			title = "delete" 
			url = "##"
			parameters = "onClick=""JavaScript: return submitForm(document.#formName#, 'dPreservation');"""
		>
	&nbsp;&nbsp;&nbsp;
	</cfif>
	<CF_smallLink 
			title = "save" 
			url = "##"
			parameters = "onClick=""JavaScript: return validateAndSubmit(document.#formName#, '#form.command#');"""
		>
	</div>
	<br><br>
	(*) A disabled "active" choice indicates that there is at least one futures pricing request that has this preservation. Thus, the user will not be able to make this preservation inactive. 
	</td>
</tr>
<tr>
	<td>
	<img src="/images/yes_small.gif" alt="Active"> - active record
	<br>
	<img src="/images/no_small.gif" alt="Inactive"> - inactive record
	<br><br>
	<CF_smallLink 
		title = "create new" 
		url = "#thisPage#?command=#form.command#"
	>
	</td>
</tr>
</table>

</cfoutput>