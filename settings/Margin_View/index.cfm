<!---
Document Name:	peril_age.cfm
Directory:		/scorecard/settings
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	December 16, 2002

This allows an administrator to specify how many days old a billback needs to be to be marked imperilled.
--->

<!---If the form has been submitted--->
<cfif isDefined("form.blnSubmit")>
		<!---If there is no prior record for this group--->
		<cfif FORM.up_sv EQ 0>
			 <cfset useLakebaseForINSERT_Margin_View = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_view")>
<cfif useLakebaseForINSERT_Margin_View>
	<cftry>
		<cfset application.oLakebase.insertRow("margin_view", {
			"user_id" = "#request.AccessStructure.User_ID#",
			"date_updated" = "#createodbcdatetime(Now())#",
			"margin_view_type" = "#form.margin_view_type#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForINSERT_Margin_View = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForINSERT_Margin_View>
<CFQUERY NAME="INSERT_Margin_View" DATASOURCE="#application.datasource#">
				INSERT INTO Margin_View
				(User_ID, 
				Date_Updated, 
				Margin_View_Type)
				VALUES
				('#request.AccessStructure.User_ID#', 
				#createodbcdatetime(Now())#, 
				'#form.margin_view_type#')
			</CFQUERY>
</cfif> 
		
		<cfelse>
			 <CFQUERY NAME="UPDATE_Margin_View" DATASOURCE="#application.datasource#">
				UPDATE Margin_View
				SET User_ID 	= '#request.AccessStructure.User_ID#', 	
				Date_Updated 	= #createodbcdatetime(Now())#,
				Margin_View_Type	 	= '#form.margin_view_type#'
			</CFQUERY> 
		<!---No prior record--->
		</cfif>
		<!--- <CFLOCATION ADDTOKEN="No" URL="/settings/margin_view/index.cfm"> --->
</cfif>
<!---End form has been submitted logic--->

<HTML>
<HEAD>
	<TITLE>Margin View Settings</TITLE>
	<script SRC="/common_files/scripts/wholeNumberValidation.js"></script>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<CFSET pagetitle = "Margin View Settings">

<!---Displays the page title set above--->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">


<!--- Gets the date that this setting was updated --->
<CFQUERY NAME="DateUpdated" DATASOURCE="#application.datasource#">
SELECT	Margin_View.Date_Updated, 
		_Users.Name_First,
		_Users.Name_Last,
		Margin_View.Margin_View_Type
FROM	Margin_View
		LEFT JOIN _Users
		ON
		_Users.User_ID = Margin_View.User_ID
</CFQUERY>

<!--- Set the update/save flag that will be passed to the next page --->
<FORM ACTION="/settings/margin_view/index.cfm" METHOD="post" name="MarginView">

<!---Hidden boolean, which, if defined, tells me that the form has been submitted--->
<input type="hidden" name="blnSubmit" value="1">

<CFIF DateUpdated.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">
</CFIF>
	
	<!---Displays who last updated this information and when--->
	<CFIF DateUpdated.Date_Updated NEQ "">
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(DateUpdated.Date_Updated,  'm/d/yyy')# #timeformat(DateUpdated.Date_Updated, 'h:mm:ss TT')# by #DateUpdated.Name_First#  #DateUpdated.Name_Last#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
	</CFIF>


<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>
	<cfif isDefined("Form.BlnSubmit")><font color="navy"><b>Your change has been saved.</b><br></font></cfif>
	
		<B>How should the margin approval screen be displayed?</B>&nbsp;
		<hr color="navy">
		
		<cfset useLakebaseForGetMarginTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_view_type")>
<cfif useLakebaseForGetMarginTypes>
	<cftry>
		<cfset GetMarginTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("margin_view_type", {
				"deleted" = "eq.0",
				"order" = "margin_view_type_id.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetMarginTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetMarginTypes>
<cfquery name="GetMarginTypes" datasource="#application.datasource#">
		SELECT * FROM Margin_View_Type
		WHERE Deleted = 0
		ORDER BY Margin_View_Type_ID
		</cfquery>
</cfif>
		
		<cfoutput query="GetMarginTypes">
		<input type="radio" value="#Margin_View_Type_ID#" name="Margin_View_Type" <cfif Margin_View_Type_ID IS DateUpdated.Margin_View_Type>checked</cfif>> #Margin_Type_Description#<br>
		</cfoutput>
		
	</TD>
</TABLE>
<BR>

&nbsp; &nbsp; &nbsp; &nbsp; 
<CF_button
		button_name		=	""
		button_caption	=	"Save Preferences..."
		button_action	=	"MarginView.submit()"
		button_type		=	"javascript_link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>

</BODY>
</HTML>
