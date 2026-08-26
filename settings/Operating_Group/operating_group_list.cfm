<!--- get operating groups to display --->
<!--- mcCain enhancement(add sort by) ---->
<cfset sort_by_fields = "10,3" />
<cfset qGetOperatingGroups = operatingGroupManager.get(form.level,0,sort_by_fields) />
<cfoutput>	
<cfset parentLevel = operatingGroupManager.getParentLevelId(form.level) />
<cfset applyAllowanceCode = operatingGroupManager.applyAllowanceCode(form.level) />
<cfset allowanceCodeManager = CreateObject("component", "components.Operating_Group.AllowanceCodeManager").init() />

<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="##FFCE84">
		<TD STYLE="font-size:11px;">
			<b>#operatingGroupLabel# ID</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b><cfoutput>#operatingGroupLabel#</cfoutput></b>
		</TD>
		<cfif parentLevel GT 0>
		<TD STYLE="font-size:11px;">
			<B>#operatingGroupManager.getLabel(parentLevel)#</B>
		</TD>
		</cfif>
		<cfif applyAllowanceCode>
		<TD STYLE="font-size:11px;">
			<B>Allowance Code</B>
		</TD>
		</cfif>
		<TD STYLE="font-size:11px;">
			<b>Edit</b>
		</TD>
		<TD STYLE="font-size:11px;" align="center">
			<b>Activate/DeActivate</b>
		</TD>
	</TR>
	<cfif not qGetOperatingGroups.RecordCount>
		<tr>
			<td colspan="100%">N/A&nbsp;</td>
		</tr>
	</cfif>
	<cfloop QUERY="qGetOperatingGroups">
	<cfset bgColor = "FFFFFF">
	<CFIF CURRENTROW MOD 2>	
		<cfset bgColor = "CCFFCC">
	</CFIF>
	<cfif NOT Active>
		<cfset bgColor = "CCCCCC">
	</cfif>
	<TR BGCOLOR="#bgColor#">
		<TD nowrap>#Operating_Group_Number#</TD>
		<TD nowrap>#Operating_Group_Desc#</TD>
		<cfif parentLevel GT 0>
		<TD nowrap>#Parent_Operating_Group_Desc#</TD>
		</cfif>
		<cfif applyAllowanceCode>
		<TD nowrap>#Allowance_Code_Desc#</TD>
		</cfif>
		<td><a href="" onClick="JavaScript: return submitForm('#form.level#', 'ceForm','#Operating_Group_ID#', 'displayList');">(edit)</a></td>
		<td align="center">
		<cfif Active>
		<a title="Deactivate this #operatingGroupLabel#" href="" onClick="JavaScript: return submitForm('#form.level#', 'dactivate','#Operating_Group_ID#');"><img src="/images/not_allowed.gif" border="0"></a>
		<cfelse>
		<a title="Activate this #operatingGroupLabel#" href="" onClick="JavaScript: return submitForm('#form.level#', 'activate','#Operating_Group_ID#');"><img src="/images/on_the_program_item.gif" border="0"></a>
		</cfif>
		</td>	
	</TR>	
	</cfloop>
</TABLE>
</cfoutput>
