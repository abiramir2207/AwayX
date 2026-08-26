<cfparam name="url.CID" 				default="">
<cfparam name="form.submitForm"			default="0">
<cfparam name="form.Program_ID"			default="">
<cfparam name="form.Distributor_List"	default="">
<cfparam name="form.Contract_Title"		default="">
<cfparam name="url.initialized"			default="">

<cfset PAGE_TITLE="Mass Program Copy">

<cfif len(trim(url.cid))>
	<!--- Decrypt Contract ID --->
	<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfset form.Program_ID = cryp.value />
</cfif>

<!--- Dev Note:Milan (25639) - Start - This page submits to itself for mass copy and so I am checking to see whether the mass copy process has already started or not. 
If not, then do the following validation below to check for the validity of the template (active or not).
--->
<cfif NOT(form.submitForm eq 1 OR url.initialized eq 1)>

<!--- Dev Note:Milan (25639) - I have copied most of the code for allow/disallow access from "contract_renewal_action.cfm" --->
<CFQUERY NAME="getProgramTemplateInfo" datasource="#application.datasource#">
SELECT     dbo.Program_Control_Panel_Options.Active, dbo.Program_Control_Panel_Options.Deleted,dbo.Contract_Main.Contract_Status_Type_IDX, 
	   First_Parent_ID
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Program_Control_Panel_Options ON 
                      dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
WHERE dbo.Contract_Main.Contract_Main_ID = '#form.Program_ID#'
</CFQUERY>

<!--- Dev Note:Milan (25639)- Check whether the most recent version is active --->
<cfset useLakebaseForgetActiveTemplateVersion = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetActiveTemplateVersion>
	<cftry>
		<cfset getActiveTemplateVersion = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"first_parent_id" = "eq.#getProgramTemplateInfo.First_Parent_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1",
				"isdominant" = "eq.1",
				"select" = "isdominant"
			}), "isdominant"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetActiveTemplateVersion = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetActiveTemplateVersion>
<CFQUERY NAME="getActiveTemplateVersion" datasource="#application.datasource#">
SELECT IsDominant
FROM Program_Control_Panel_Options
WHERE First_Parent_ID = '#getProgramTemplateInfo.First_Parent_ID#'
AND Deleted = 0
AND Active = 1
AND IsDominant = 1
</CFQUERY>
</cfif>

<!--- Dev Note:Milan (25639) - I have copied most of the code for allow/disallow access from "contract_renewal_action.cfm" --->
<CFSET TemplateIsReuseable = 1>
<CFIF trim(getProgramTemplateInfo.Active) EQ 0 OR trim(getProgramTemplateInfo.Deleted) EQ 1>
	<CFSET TemplateIsReuseable = 0>
</CFIF>

<CFSET ContinueWithApproval = 1>

<CFIF TemplateIsReuseable EQ 0>
	<CFSET ContinueWithApproval = 0>
</CFIF>

<!--- Dev Note:Milan (25639) - Not sure whether we need this condition. I just copied this condition from "contract_renewal_action.cfm" which has the 
      code for copy/rollover/revise.
 ---->
<CFIF getProgramTemplateInfo.Contract_Status_Type_IDX GTE 4 AND getProgramTemplateInfo.Contract_Status_Type_IDX LT 7>
	<CFSET ContinueWithApproval = 1>
</CFIF>

<!---  Dev Note:Milan (25639) - If the template is not active, disallow access. Here we are disallowing mass copy if the 
	template is not active.
--->
<CFIF getActiveTemplateVersion.RecordCount EQ 0>
	<CFSET ContinueWithApproval = 0>
</CFIF>

<!--- Dev Note:Milan (25639) - End - This page submits to itself for mass copy and so I am checking to see whether the mass copy process has already started or not. 
If yes, then set ContinueWithApproval = 1, so that the mass copy process can continue.
--->
<CFELSE>

	<CFSET ContinueWithApproval = 1>
</CFIF>

<CFIF ContinueWithApproval EQ 0>

	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	
	<HTML>
	<HEAD>
		<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
		<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	</HEAD>
	
	<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<BR><BR><BR>
	<DIV ALIGN="center" STYLE="font-size: 15px;"><B>The template you are attempting to use has been removed from circulation.<BR>You will be returned to the view program page.</B></DIV>

	<script language="JavaScript">
		function seeya()
		{
			window.close();
		}
		setTimeout('seeya()',2000); 
	</script>

	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFINCLUDE TEMPLATE="/includes/footer.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	</BODY>
	</HTML>

<CFELSE>

<cfif form.submitForm eq 1>

	<cfset objMassCopy = createObject("component", "components.programs.MassCopyPrograms") />
	<cfset variables.massProgramCopyID = objMassCopy.saveMassCopyProgramData(form.Program_ID, form.Contract_Title, request.accessstructure.User_ID, form.Distributor_List) />
	<cfinclude template="mass_program_copy_process.cfm" />
	<cflocation url="mass_program_copy.cfm?initialized=1" />
	<cfabort />
	
</cfif>

<cfif url.initialized eq 1>
<html>
<head>
	<title><cfoutput>#PAGE_TITLE#</cfoutput> initialized</title>
</head>
	<body>
		<table border="0" cellpadding="0" cellspacing="0" align="center">
		<tr>
			<th colspan="100%" align="left">
				<font color="RED">Mass Copy has been initialized succesfully.</font>
			</th>
		</tr>
		<tr>
			<td align="center">
				<br>
				<CF_button
					button_name		=	""
					button_caption	=	"close"
					button_action	=	"window.close()"
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
	</body>
	</html>
	<cfabort />

</cfif>

<cfif len(trim(form.Distributor_List))>
	<cfquery name="qGetDistributors" datasource="#application.datasource#">
		SELECT	*
		FROM	BSA_Foodservice_Customers
		WHERE	BSA_Foodservice_Customers_ID IN (#listQualify(form.Distributor_List, "'", ",", "ALL")#)
	</cfquery>
</cfif>

<cfquery name="qGetProgram" datasource="#application.datasource#">
	SELECT	Contract_Main_ID, Business_Segment_ID, Line_Of_Business_ID
	FROM	Contract_Main
	WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Program_ID#" />	
</cfquery>

<cfset Business_Segment_ID = 0 />
<cfset Line_Of_Business_ID = "" />
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
	<cfset Business_Segment_ID = qGetProgram.Business_Segment_ID />
</cfif>

<cfif appSettings.getSalesOrgOn()>
	<cfset Line_Of_Business_ID = qGetProgram.Line_Of_Business_ID />
</cfif>

<html>
<head>
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>
	
	<script SRC="/Script/javascript/string_functions.js"></script>
	
	<SCRIPT language="JavaScript">
		function distributorSearch()
		{
			<cfoutput>
			NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=massCopyProgramForm&FieldName=Distributor_List&SelectSingleSearchResultOnly=0&ShowActiveDistributorsOnly=1&BusinessSegment=#Business_Segment_ID#&LineofBusiness=#Line_Of_Business_ID#", "distributorwindow", 850, 600, "yes", "yes");
			</cfoutput>
		}
		
		function validate()
		{
			var programTitle 	= trim(document.massCopyProgramForm.Contract_Title.value);
			var distributorList = trim(document.massCopyProgramForm.Distributor_List.value);

			if (programTitle.length == 0) 
			{
				alert('Please enter a Program Title.');
				return;
			}
			else if (distributorList.length == 0)
			{
				alert('Please select at least one distributor.');
				return;
			}
			
			document.massCopyProgramForm.submitForm.value = 1;
			document.massCopyProgramForm.submit();
		}
	</SCRIPT>
</head>
<body>
<cfoutput>
<FORM action="mass_program_copy.cfm" METHOD="post" NAME="massCopyProgramForm">
<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<th colspan="100%" align="left">
			<font color="navy">Mass Program Copy</font>
		</th>
	</tr>
</table>
<hr color="##FFA500" />
<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td colspan="100%">
			<BR>
		</td>
	</tr>
	<tr>
    	<td colspan="100%">
			Program Title: <input name="Contract_Title" type="text" value="#form.Contract_Title#" size="40" />
			<cfmodule 
					template="/customtags/smallhelp.cfm"
					showImage = 1
					width = 250>
					<div style="width:250px">
					The title entered in this field will be concatenated along with the distributor name to form the program title of the program copy.<br/> 
					Ex. 2010 Marketing - Sysco Chicago.
					</div>
			</cfmodule>
		</td>
	</tr>
	
	<tr>
		<td colspan="100%">
			<br>
			<CF_button
				button_name		=	""
				button_caption	=	"select #lcase(application.returned_customer_setting.distributor_label_plural)#"
				button_action	=	"distributorSearch()"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				class			=	"NotMaintable">
			<!---/////////////////////////////// Distributor List /////////////////////////////////--->
			<cfif len(trim(form.Distributor_List)) and qGetDistributors.RecordCount>
				<br>
				<table border="0" cellspacing="0" class="Maintable" width="80%">
					<tr  BGCOLOR="FFCE84">
						<td id="header">
							<b>Name</b>
						</td>
						<td>&nbsp;&nbsp;</td>
						<td id="header">
							<b>Ship To</b>
						</td>
					</tr>
				<cfloop query="qGetDistributors">
					<tr bgcolor="#IIf(qGetDistributors.CurrentRow Mod 2,  DE('C6FFC6'), DE('ffffff'))#">
						<td nowrap="nowrap">								
							#Name#
						</td>
						<td>&nbsp;&nbsp;</td>
						<td nowrap="nowrap">
							#Ship_To#
						</td>
					</tr>
				</cfloop>
				</table>
			</cfif>
		</td>
	</tr>
	<input type="hidden" name="submitForm" 			value="#form.submitForm#" />
	<input type="hidden" name="Program_ID" 			value="#form.Program_ID#" />
	<input type="hidden" name="Distributor_List" 	value="#form.Distributor_List#" />
</table>

<BR><BR>

<table border="0" cellpadding="2" cellspacing="0">
	<tr>
		<td>
			<CF_button
				button_name		=	""
				button_caption	=	"start mass copy"
				button_action	=	"validate()"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
		<td>
			<CF_button
				button_name		=	""
				button_caption	=	"cancel"
				button_action	=	"window.close()"
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
</FORM>
</cfoutput>
</body>
</html>

</CFIF>
