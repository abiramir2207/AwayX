
<cfparam name="blnSubmit" default="0">
<cfparam name="form.Program_List" default=""> 
<cfparam name="FORM.USE_DFLT_PRG"   default="0" />	
<cfset appSettings = application.appSettingsGet>
<!---If form has been submitted, save --->
<cfif blnSubmit IS 1>
	<cfif isDefined("form.Program_List")>
	<cfquery name="UpdateDefaultProgram" datasource="#application.datasource#">
	UPDATE Billback_Settings
	SET Default_Program = '#form.Program_List#',
	USE_DFLT_PRG = <cfqueryparam value="#FORM.USE_DFLT_PRG#" cfsqltype="CF_SQL_BIT">, 
	Default_Updated_By = '#Request.Accessstructure.User_ID#',
	Default_Updated_Date = getdate()
	</cfquery>

	</cfif>
</cfif>
<!--- End: If form has been submitted, save --->

<Cfquery name="ExistingDefaultProgram" datasource="#application.datasource#">
SELECT Default_Program,USE_DFLT_PRG, _Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName, Default_Updated_Date,
Contract_Main.Contract_Title, Contract_Main.Contract_Number, Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date
FROM Billback_Settings
	LEFT JOIN Contract_Main
	ON Contract_Main.Contract_Main_ID = Billback_Settings.Default_Program
	INNER JOIN _Users 
	ON _Users.User_ID = Billback_Settings.Default_Updated_By
</CFQUERY>
<cfset FORM.USE_DFLT_PRG = ExistingDefaultProgram.USE_DFLT_PRG />
<Cfset FORM.program_List = ExistingDefaultProgram.Default_Program />
<cfoutput>
<br>
<script language="JavaScript">
	function submitFormDefaultProgram()
	{
		document.all.DefaultProgram.blnSubmit.value = 1;
		document.all.DefaultProgram.submit();
		return false;
	}
</script>
<!--- Display last updated --->

<cfif Len(ExistingDefaultProgram.Default_Updated_Date) GT 0>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0"  ALIGN="left" width="500">
<TR>
<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(ExistingDefaultProgram.Default_Updated_Date, 'mm/dd/yyyy')# #timeformat(ExistingDefaultProgram.Default_Updated_Date, 'hh:mm:ss TT')# by #ExistingDefaultProgram.UpdatedByFullName#</B></FONT>
</TD>
</TR>
</TABLE>

</cfif>
<!--- End last updated display --->
<br><br><br><table><tr><th><font color="navy">Billbacks - Default Program</font></th></tr></table><br>

<!---  <form name="DefaultProgram" method="post" action="deduction_external_settings.cfm">   --->
<!--- <form action="/billbacks/capture/upload_Billback/Default_Program.cfm" method="post" name="DefaultProgram" id="DefaultProgram"> --->
  <form action="/deductions/settings/deduction_external_settings.cfm" method="post" name="DefaultProgram" id="DefaultProgram"> 
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="left" CLASS="UnderLine" WIDTH="500">

<Cfif Len(ExistingDefaultProgram.Default_Updated_Date) GT 0>
<tr>
<TD  nowrap STYLE="border-bottom:None"><B><FONT SIZE="2" COLOR="Navy">Current default program:</FONT></B></TD> 
<td>
<cf_cryp string="#ExistingDefaultProgram.Default_Program#" type="en" key="#request.key#">
				<CFSET CID = cryp.value>
<A onClick="javaScript: NewWindow(this.href , 'Catalog_Program' , 750 , 550 , 'yes' , 'yes'); return false;" target="_blank" HREF="/scorecard/program_display.cfm?display_program=1&CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #ExistingDefaultProgram.Contract_Number#"><font color="660033"><b>#ExistingDefaultProgram.Contract_Number#</b></font></A>
# ExistingDefaultProgram.Contract_Title# (#dateformat(ExistingDefaultProgram.Contract_Start_Date, 'MM/DD/YYYY')# to #dateformat(ExistingDefaultProgram.Contract_End_Date, 'MM/DD/YYYY')#)</td></tr>
</CFIF>
<TR>
		<TD STYLE="border-bottom:None"><B><FONT SIZE="2" COLOR="Navy">Select new program to be default:</FONT></B></TD> 
		<td>	<CF_button
							button_name		=	""
							button_caption	=	"select default program"
							button_action	=	"searchPrograms()"
							button_type		=	"javascript_link"
							button_width	=	"200"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>	</td>
	</TR>
<tr>
	<td colspan="100%"><small>This program is used in automated billback uploads. If a program cannot be found matching the billback criteria, this program will be used. Billbacks cannot be submitted for approval if this program is associated with the billback, so be sure there will never be a valid claim made against this program. The default program does not need to have any special information: distributors, products, etc.</small></td>
</tr>
	<cfif appSettings.getThirdPartyBBUpload() eq 1>
<tr>
			<TD STYLE="border-bottom:None"><B><FONT SIZE="2" COLOR="Navy">Use Default Program if operator and/or distributor is invalid:</FONT></B><img src="/images/help_small.gif"
			Title="When this setting is unchecked, if a operator and/or distributor is invalid then the billback is rejected and not loaded.   When this setting is checked, if a opearator and/or distributor is invalid then they will be associated to the Default Program."/></TD> 
			</td>
			<td>
				 <input name="USE_DFLT_PRG" type="checkbox" value="1" <cfif FORM.USE_DFLT_PRG eq 1>checked</cfif> />
			</td>
		</tr>
<tr>
		<td></td>
		<td align="center">
			<br />
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return submitFormDefaultProgram();"""
			>
		</td>
	</tr>		
</cfif>	
</table>
<input type="hidden" name="blnSubmit" value="1">
<input type="hidden" name="Program_List" id="Program_List" value="#form.Program_List#">
<input type="hidden" name="ExistingProgramList" value="#ExistingDefaultProgram.Default_Program#">
<input type="hidden" name="FilterSearchPrograms" id="FilterSearchPrograms" value="0">
</form>
</cfoutput>
<!--- Display current value and allow for update --->

<script>
function searchPrograms()
{
NewWindow("/billbacks/search_screens/search_programs.cfm?Formname=DefaultProgram&fieldname=Program_List&SelectSingleSearchResultOnly=1", "programswindow", 800, 600, "yes", "yes");
}
</script>
