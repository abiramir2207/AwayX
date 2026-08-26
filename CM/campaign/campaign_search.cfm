<cfoutput>

<!---set default values--->
<cfparam name="url.id" default=0 />
<cfparam name="form.id" default="#url.id#" />
<cfparam name="form.state" default="0" />
<CFPARAM NAME="FORM.Campaign_Name" 	DEFAULT="">
<CFPARAM NAME="FORM.Campaign_Start_Date" 	DEFAULT="">
<CFPARAM NAME="FORM.Campaign_End_Date" 	DEFAULT="">


<cfset campMang = CreateObject("component","cm.campaign.com.CampaignManager").init() />


<!------ Show search screen ----->
<FORM ACTION="#cmHandler#" METHOD="post" NAME="frm#commandSuffix#" ID="MyForm" STYLE="DISPLAY:INLINE">
	
	<FIELDSET STYLE="padding:8px; width: 500px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Campaign search</LEGEND>
	 <TABLE>
	<TR>
		<TD>
			<B>Campaign Name:</B><BR>
			<INPUT TYPE="text" NAME="Campaign_Name" STYLE="width:	200px; font-size: 10px;" VALUE="<CFOUTPUT>#FORM.Campaign_Name#</CFOUTPUT>">
		</TD>
		<TD>
			<B>Start Date:</B><BR>
			<CF_EASYDATE 
					FORMNAME="frm#commandSuffix#" 
					FIELDNAME="Campaign_Start_Date" 
					FORMAT="mm/dd/yyyy" 
					DEFAULT="#FORM.Campaign_Start_Date#">
		</TD>
		<TD>
			<B>End Date:</B><BR>
			<CF_EASYDATE 
					FORMNAME="frm#commandSuffix#" 
					FIELDNAME="Campaign_End_Date" 
					FORMAT="mm/dd/yyyy" 
					DEFAULT="#FORM.Campaign_End_Date#">
		</TD>
	</TR>	
	</TABLE>
	
	<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="center">
		<TR>
			<TD ALIGN="left">
			<input type="Submit" value="Search">
			</TD>
		</TR>
	</TABLE>
	
	<!------ common ----->
	<input type="hidden" name="command" value="s#commandSuffix#" />
	<INPUT TYPE="hidden" NAME="state" VALUE="1">
	</FIELDSET>
	
</form>

<cfif form.state NEQ 0>
	<!------ show result ----->
	<cfset 	qSearchResult = campMang.getByFilter(form)>
	
	<table cellpadding="2" cellspacing="1" border="0" class="SearchResult">
		<thead valign="top">
			<th>Name</th>
			<th>Start Date</th>
			<th>End Date</th>
		</thead>
		<cfloop query="qSearchResult">
		<tr valign="top">
			<td><a href="#cmHandler#?command=ceCampaign&id=#CM_Campaign_ID#">#Campaign_Name#</a></td>
			<td>#DateFormat(Campaign_Start_Date, "mm/dd/yyyy")#</td>
			<td>#DateFormat(Campaign_End_Date, "mm/dd/yyyy")#</td>			
		</tr>
		</cfloop>
	</table>
	
</cfif>

</cfoutput>