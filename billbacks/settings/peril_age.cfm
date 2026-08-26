<!---
Document Name:	peril_age.cfm
Directory:		/scorecard/settings
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	December 16, 2002

This allows an administrator to specify how many days old a billback needs to be to be marked imperilled.
--->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!---If the form has been submitted--->
<cfif isDefined("form.blnSubmit")>
	<!---If the expiration range entered is numeric--->
	<cfif isnumeric(FORM.BB_Danger_Range) AND isNumeric(form.AutoBB_Notify_Days)>
		<!---If there is no prior record for this group--->
		<cfif FORM.up_sv EQ 0>
			 <CFQUERY NAME="INSERT_Danger_Date" DATASOURCE="#application.datasource#">
				INSERT INTO Billback_Settings
				(User_ID, 
				BB_Danger_Range, 
				AutoBB_Notify_Days,
				BB_Range_Update_Date, 
				BB_Range_Editor_ID)
				VALUES
				('#request.AccessStructure.Company_Main_ID#', 
				#int(form.BB_Danger_Range)#, 
				#int(FORM.AutoBB_Notify_Days)#,
				#createodbcdatetime(Now())#, 
				'#request.AccessStructure.User_ID#')
			</CFQUERY> 
		
		<cfelse>
			 <CFQUERY NAME="UPDATE_Danger_Date" DATASOURCE="#application.datasource#">
				UPDATE Billback_Settings
				SET BB_Danger_Range 	= #int(FORM.BB_Danger_Range)#,
				AutoBB_Notify_Days 		= #int(FORM.AutoBB_Notify_Days)#, 	
				BB_Range_Update_Date 	= #createodbcdatetime(Now())#,
				BB_Range_Editor_ID	 	= '#request.AccessStructure.User_ID#'
				WHERE User_ID			= '#request.AccessStructure.Company_Main_ID#'
			</CFQUERY> 
		<!---No prior record--->
		</cfif>
		<CFLOCATION ADDTOKEN="No" URL="peril_age.cfm">
	<!---Range not numeric--->
	</cfif> 
</cfif>
<!---End form has been submitted logic--->

<HTML>
<HEAD>
	<TITLE>Billback Age Settings</TITLE>
	<script SRC="/common_files/scripts/wholeNumberValidation.js"></script>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<CFSET pagetitle = "Billback: Age Warning Settings">

<!---Displays the page title set above--->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">


<!--- Gets the date that this setting was updated --->
<CFQUERY NAME="Get_Danger_Date" DATASOURCE="#application.datasource#">
SELECT	Billback_Settings.BB_Range_Update_Date, Billback_Settings.AutoBB_Notify_Days, 
		_Users.Name_First,
		_Users.Name_Last,
		Billback_Settings.BB_Danger_Range
FROM	Billback_Settings
		LEFT JOIN _Users
		ON
		_Users.User_ID = Billback_Settings.BB_Range_Editor_ID
WHERE	Billback_Settings.User_ID		=		'#request.AccessStructure.Company_Main_ID#'
</CFQUERY>

<!--- Set the update/save flag that will be passed to the next page --->
<FORM ACTION="peril_age.cfm" METHOD="post" name="Peril">

<!---Hidden boolean, which, if defined, tells me that the form has been submitted--->
<input type="hidden" name="blnSubmit" value="1">

<CFIF Get_Danger_Date.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">
	
	<!---Displays who last updated this information and when--->
	<CFIF Get_Danger_Date.BB_Range_Update_Date NEQ "">
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_Danger_Date.BB_Range_Update_Date,  'm/d/yyy')# #timeformat(Get_Danger_Date.BB_Range_Update_Date, 'h:mm:ss TT')# by #Get_Danger_Date.Name_First#  #Get_Danger_Date.Name_Last#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
	</CFIF>
</CFIF>

<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>
	<cfif isDefined("Form.BlnSubmit")><font color="navy"><b>Your change has been saved.</b><br></font></cfif>
	
		<B>How many days after the billback day should the billback be marked as being in danger of being deducted?</B>&nbsp;&nbsp; </TD><Td>
		<INPUT TYPE="text" SIZE="4" NAME="BB_Danger_Range" VALUE="<CFIF len(Get_Danger_Date.BB_Danger_Range) GT 0><CFOUTPUT>#Get_Danger_Date.BB_Danger_Range#</CFOUTPUT><CFELSE>30</CFIF>" onkeyup="nextBox(this, 'NONE', 3)">
	</TD></tr>
	
	<tr><td align="right"><strong>Days after end of period to notify about readiness to settle</strong>&nbsp; &nbsp; </td>
		<td><INPUT TYPE="text" SIZE="4" NAME="AutoBB_Notify_Days" VALUE="<CFIF len(Get_Danger_Date.AutoBB_Notify_Days) GT 0><CFOUTPUT>#Get_Danger_Date.AutoBB_Notify_Days#</CFOUTPUT><CFELSE>1</CFIF>" onkeyup="nextBox(this, 'NONE', 3)"></td>
	</tr>
</TABLE>
<BR>

<div align="center">
<CF_button
		button_name		=	""
		button_caption	=	"Save Preferences..."
		button_action	=	"Peril.submit()"
		button_type		=	"javascript_link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</div>

</BODY>
</HTML>
