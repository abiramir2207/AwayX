<!---
alias_sources.cfm
--->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFPARAM NAME="URL.RID" DEFAULT="-1">
<cfparam name="Form.blnSubmit" default="0">
<CFPARAM NAME="Form.DOSEARCH" DEFAULT="0">
<cfoutput>
<CFPARAM NAME="URL.Search_Source_Code"  DEFAULT="">
<CFPARAM NAME="Form.Search_Source_Code" DEFAULT="#URL.Search_Source_Code#">
<CFPARAM NAME="URL.Search_Source_Type_Description" DEFAULT="">
<CFPARAM NAME="Form.Search_Source_Type_Description" DEFAULT="#URL.Search_Source_Type_Description#">
<CFPARAM NAME="URL.Search_Active" DEFAULT="2">
<CFPARAM NAME="Form.Search_Active" DEFAULT="#URL.Search_Active#">
<CFPARAM NAME="URL.Search_Created_Since_Date" DEFAULT="">
<CFPARAM NAME="Form.Search_Created_Since_Date" DEFAULT="#URL.Search_Created_Since_Date#">
<CFPARAM NAME="FORM.Source_Type" DEFAULT="">
<CFPARAM NAME="URL.Search_Display_In_OCR" DEFAULT="0">
<CFPARAM NAME="FORM.Search_Display_In_OCR" DEFAULT="#URL.Search_Display_In_OCR#">

</cfoutput>
<cfset strRetMessage = "" />
<cfset AliasSourcesManager = CreateObject("component", "components.settings.AliasSources.AliasSourcesManager").init() />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<!--- ************************* SAVE *************************--->
<cfif Form.blnSubmit IS 1>
	<cfset BBClaimSourceXREFID = 0 />
	<cfif form.BB_Claim_Source_XREF_ID neq "">
		<cfset BBClaimSourceXREFID = form.BB_Claim_Source_XREF_ID />
	</cfif>

	<cfif (appSettings.get_Setting('OCR_Upload_ON') EQ '1')>
			<cfif (NOT isDefined("FORM.Display_In_OCR"))>
				<CFPARAM NAME="FORM.Display_In_OCR" DEFAULT="0">
			</cfif>
			<cfset strRetMessage = AliasSourcesManager.addEditAliasSourcesType(
				BBClaimSourceXREFID = BBClaimSourceXREFID,
				SourceCode = form.Source_Code,
				SourceType = form.Source_Type,
				Active = Form.Active,
				userID = request.AccessStructure.User_ID,
				DisplayInOCR = FORM.Display_In_OCR) />
	<cfelse>			
			<cfset strRetMessage = AliasSourcesManager.addEditAliasSourcesType(
				BBClaimSourceXREFID = BBClaimSourceXREFID,
				SourceCode = form.Source_Code,
				SourceType = form.Source_Type,
				Active = Form.Active,
				userID = request.AccessStructure.User_ID) />
	</cfif>
	
</cfif>

<SCRIPT language="JavaScript">
	function SubmitForm()
	{
		var isError = 0;
		var re = /\s/g;
		var strMsg = new Array();
					
		var strValue; 
					
		strValue = document.MyForm.Source_Code.value.replace(re, "");					
		if (strValue.length == 0)
		{
		strMsg[strMsg.length] = "Please enter a code.";						
			isError = 1;
		}
										
		if (MyForm.Source_Type.value == 0)
		{
			strMsg[strMsg.length] = "Please select a description.";						
			isError = 1;
		}
					
		if (isError == 0)
		{
			disableButton("save_table", true, false);
			document.MyForm.blnSubmit.value = 1;
			MyForm.submit();						
		}
		else
		{
			alert(strMsg.join("\n"));
		}
		return false;
	}
			
	function doSearchNow()
	{
		document.MyForm.submit();
		return false;
	}
</SCRIPT>	

<!--- ************************* GET DATA *************************--->
<CFQUERY NAME="GetBB_Upload_Source_Type_Lookup" datasource="#application.datasource#">
	select Source_Type,Source_Type_Desc,Source_Category
	from BB_Upload_Source_Type_Lookup
	where Active = 1  --deleted = 0
	order by Source_Type_Desc
</CFQUERY>

<cfset qGetAliasSourceTypes = AliasSourcesManager.getAliasSourceTypes(			
			SearchSourceCode = Form.Search_Source_Code,
			SearchSourceTypeDescription = Form.Search_Source_Type_Description,
			SearchActive = Form.Search_Active,
			SearchCreatedSinceDate = Form.Search_Created_Since_Date) />

<cfset qGetCurrentAliasSources = AliasSourcesManager.getAliasSourceTypes(BBClaimSourceXREFID = #URL.RID#) />

<CFSET URL.PageTitle="Alias Sources">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- ************************* DISPALY LAST UPDATED BY INFO *************************--->
<CFQUERY NAME="GetLastUpdatedDetails" datasource="#application.datasource#">
		Select		TOP 1 Updated_By, Updated_Date
		From		BB_Claim_Source_XREF
		Order by	Updated_Date Desc
</CFQUERY>
<CFSET Last_Updated_By = GetLastUpdatedDetails.Updated_By />
<CFSET Last_Updated_Date = GetLastUpdatedDetails.Updated_Date />

<CFIF Last_Updated_By NEQ "">
	<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT 	_Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
		FROM 	_Users
		WHERE 	User_ID = '#Last_Updated_By#'
	</CFQUERY>
</CFIF>


<FORM ACTION="alias_sources.cfm" METHOD="post" NAME="MyForm">

<CFIF Last_Updated_By NEQ "">
	<table border="1" align="left" cellpadding="2" cellspacing="0" bordercolor="Orange" bgcolor="White" width="750" style="width:800px;">
		<tr>
		<td> <font size="1"><B>This <cfif url.RID GT 0>record <cfelse> setting</cfif> was last updated on <CFOUTPUT>#dateformat(Last_Updated_Date, 'm/d/yyy')# #timeformat(Last_Updated_Date, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT></td>
		</tr>
	</table><br/>&nbsp;
</CFIF>
<br>


<!--- ************************* SEARCH FORM *************************--->
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;" width="750"  style="width:800px;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">search</LEGEND>
<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="1" WIDTH="750">
	<TR>
		<TD valign="bottom">
			Code: <input type="text" Name="Search_Source_Code" value="<cfoutput>#form.Search_Source_Code#</cfoutput>" style="width:140px;">
		</TD>
		<TD valign="bottom">
			Description: <input type="text" Name="Search_Source_Type_Description" value="<cfoutput>#form.Search_Source_Type_Description#</cfoutput>" style="width:140px;">
		</TD>		
		<TD valign="bottom">			
			<span ID="searchItemLabel">Status:</span>
			<SELECT NAME="Search_Active"  style="width:100px;">
			<OPTION VALUE="2" <cfif Form.Search_Active eq 2> selected</cfif>>All</OPTION>
			<OPTION VALUE="1" <cfif Form.Search_Active eq 1> selected</cfif>>Active</OPTION>
			<OPTION VALUE="0" <cfif Form.Search_Active eq 0> selected</cfif>>Inactive</OPTION>	
			</SELECT>	
		</TD>
		<TD ALIGN="left" NOWRAP>
		<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
		<!--- &nbsp;&nbsp; --->
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: return doSearchNow();">search alias sources</a><FONT COLOR="#FF0000">]</FONT></B>
		<B><FONT COLOR="#FF0000">[</FONT><a href="/Settings/Alias_Sources/alias_sources.cfm" target="mainwindow">reset</a><FONT COLOR="#FF0000">]</FONT></B>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</TD>
	</TR>	
</TABLE>		
	<INPUT TYPE="Hidden" NAME="Search_Display_In_OCR" VALUE="#form.Search_Display_In_OCR#">
	<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
</FIELDSET><br/>&nbsp;


<!--- ************************* DISPLAY THE CONTENTS *************************--->
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="900">
	<TR>
		<!--- ************************* DISPLAY EXISTING RECORDS *************************--->
		<TD VALIGN="top">
			<SPAN CLASS="title2">Existing Alias Sources</SPAN>
			<HR COLOR="Blue" SIZE="1">
			
			<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
				<TR>
					<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Code</B></SPAN></TD>
					<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
					<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Status</B></SPAN></TD>
					<cfif (appSettings.get_Setting('OCR_Upload_ON') EQ '1')>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Display in CIA</B></SPAN></TD>
					</cfif>
				</TR>
				<CFOUTPUT QUERY="qGetAliasSourceTypes">
					<cfif (appSettings.get_Setting('OCR_Upload_ON') EQ '1')>
						<cfset URLDisplayInOCR = "&Display_In_OCR=#FORM.Search_Display_In_OCR#" />
					<cfelse>
						<cfset URLDisplayInOCR = "" />
					</cfif>
				<TR>
					<TD NOWRAP><A HREF="alias_sources.cfm?RID=#BB_Claim_Source_XREF_ID#&Search_Source_Code=#Form.Search_Source_Code#&Search_Source_Type_Description=#Form.Search_Source_Type_Description#&Search_Active=#Form.Search_Active#&Search_Created_Since_Date=#Form.Search_Created_Since_Date##URLDisplayInOCR#" Title="Click to Edit">#Source_Code#</A></TD>
					<TD NOWRAP><A HREF="alias_sources.cfm?RID=#BB_Claim_Source_XREF_ID#&Search_Source_Code=#Form.Search_Source_Code#&Search_Source_Type_Description=#Form.Search_Source_Type_Description#&Search_Active=#Form.Search_Active#&Search_Created_Since_Date=#Form.Search_Created_Since_Date##URLDisplayInOCR#" Title="Click to Edit">#Source_Type_Description#</A></TD>
					<TD NOWRAP align="center">
						<CFIF Active EQ 1>
							<IMG SRC="/images/yes_small.gif" TITLE="active record...">
						<CFELSE>
							<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
						</CFIF>
					</TD>
					
					<cfif (appSettings.get_Setting('OCR_Upload_ON') EQ '1')>
						<td>
							<CFIF Display_in_OCR EQ 1>
								<IMG SRC="/images/yes_small.gif" TITLE="Display In CIA Module">
							<CFELSE>
								<IMG SRC="/images/no_small.gif" TITLE="Do Not Display In CIA Module">
							</CFIF>
						</td>
					</cfif>
				</TR>
				</CFOUTPUT>
			</TABLE>
			<BR>
			<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
			<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record
		</TD>
		<!--- ************************* ADD/EDIT RECORD FORM *************************--->
		<TD VALIGN="top">
		<cfif (url.RID GT 0)>
			<SPAN CLASS="title2">Edit Record</SPAN> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT><A HREF="alias_sources.cfm"><B>create new entry</B></A><FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
		<cfelse>
			<SPAN CLASS="title2">Add Record</SPAN> 
		</cfif>
			
			<HR COLOR="Blue" SIZE="1">					
			
			<TABLE CELLSPACING="5" CELLPADDING="0" >
				<cfoutput>
				<TR>
					<TD VALIGN="top" ALIGN="right"><B>Code</B></TD>
					<TD VALIGN="top">
						<INPUT SIZE="62" NAME="Source_Code" VALUE="#qGetCurrentAliasSources.Source_Code#" MAXLENGTH="70"  style="width:320px;">
					</TD>
				</TR>
				<TR>
					<TD VALIGN="top" ALIGN="right"><B>Description</B></TD>
					<TD VALIGN="top">
						<SELECT NAME="Source_Type"  style="width:320px;">
							<OPTION VALUE="0">select source type description</OPTION>
							<CFLOOP QUERY="GetBB_Upload_Source_Type_Lookup">
								<OPTION VALUE="#trim(GetBB_Upload_Source_Type_Lookup.Source_Type)#" #IIF(trim(qGetCurrentAliasSources.Source_Type) EQ GetBB_Upload_Source_Type_Lookup.Source_Type, DE(" SELECTED"), DE(""))#>#UCase(GetBB_Upload_Source_Type_Lookup.Source_Type_Desc)#</OPTION>
							</CFLOOP>
						</SELECT>
						<INPUT TYPE="hidden" NAME="BB_Claim_Source_XREF_ID" VALUE="#qGetCurrentAliasSources.BB_Claim_Source_XREF_ID#">
					</TD>
				</TR>
				</cfoutput>
				<TR>
					<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
					<TD VALIGN="top">
						<!--- Is this record deleted? --->
						<CFIF qGetCurrentAliasSources.Active EQ 0 >
							<CFSET active="">
							<CFSET inactive=" CHECKED">							
						<CFELSE>
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						</CFIF>
						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="1" NAME="Active" #active#>Active&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="0" NAME="Active" #inactive#>Inactive 
						</CFOUTPUT>
					</TD>
				</TR>
				<cfif (appSettings.get_Setting('OCR_Upload_ON') EQ '1')>
					<tr>
						<TD VALIGN="top" ALIGN="right"><B>Display in Claims Module as a Source:</B></TD>
						<TD VALIGN="top">
						<CFIF qGetCurrentAliasSources.Display_In_OCR EQ 0 OR qGetCurrentAliasSources.Display_In_OCR EQ "">
							<CFSET isChecked="">
						<CFELSE>
							<CFSET isChecked="CHECKED">
						</CFIF>
						  <input type="checkbox" Name="Display_In_OCR"  <cfoutput>#isChecked#</cfoutput> value="1">
						</TD>
					</tr>
				</cfif>
				<TR>
					<TD VALIGN="top" ALIGN="right"></TD>
					<TD VALIGN="top">
						<CF_button
							button_name	=	"save"
							button_caption	=	"save data"
							button_action	=	"return SubmitForm();"
							button_type	=	"javascript_link"
							button_width	=	"75"
							button_color	=	"Navy"
							button_tip	=	""
							font_color	=	"White"
							font_size		=	"12"
							font_weight	=	"bold"
						>						
					</TD>
				</TR>
				<!--- Display the return message,if it was successful or failure --->
				<cfif strRetMessage NEQ "">
					<tr>
						<td colspan="2">
							<div align="center"><font color="red"><strong><cfoutput>#strRetMessage#</cfoutput></strong></font></div>			
						</td>
					</tr>
				</cfif>
			</TABLE>
			<input type="hidden" name="blnSubmit" value="0">
		</TD>
	</TR>
</TABLE>
<B>
</FORM>

<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="alias_sources.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>

