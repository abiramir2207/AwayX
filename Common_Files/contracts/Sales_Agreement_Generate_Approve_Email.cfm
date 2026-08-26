<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		Send mail to the user who requested approval
		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<!--- STATUS CHANGE NOTIFICATION EMAIL --->
	<CFQUERY NAME="getThisProgramsStatusEmail" datasource="#application.datasource#">
		SELECT 	Contract_Status_Type_IDX, Revision_Of_Export_Sales_Agreement_ID, RFA_User_ID, Export_Sales_Agreement_Number, Export_Sales_Agreement_Name, Creating_User_Position_ID
						,Creator_ID
		FROM 	Export_Sales_Agreement
		WHERE 	Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
	</CFQUERY>

<CFIF getThisProgramsStatusEmail.Contract_Status_Type_IDX GTE 3><!----  Approved ------>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	
	<cfset userManager = CreateObject("component", "components.user.UserManager") />
	<cfset Approved_Date = now()>
	
	<cfquery name="getUserName" datasource="#application.datasource#">
		SELECT Name_First, Name_Last, User_Email
		FROM _Users
		WHERE User_ID = '#request.AccessStructure.user_id#'
	</cfquery>

	<cfquery name="getCreatorEmail" datasource="#application.datasource#">
		SELECT User_Email
		FROM _Users
		WHERE User_ID = '#getThisProgramsStatusEmail.Creator_ID#'
	</cfquery>
	
	<cfset uName = getUserName.Name_First & " " & getUserName.Name_Last>
	<cfset uEmail = getUserName.User_Email>

	<cfset Creating_User_Position_ID = getThisProgramsStatusEmail.Creating_User_Position_ID>

	<cfset CSL_Export_Sales_Agreement_ID = Export_Sales_Agreement_ID>	

		<!---<cfif appSettings.getSendAutoAttachments()>--->
			<cfsavecontent variable = "EmailContents">
				<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#\temp_files\program\Export_Programs_View_Private_#CSL_Export_Sales_Agreement_ID#.htm">
			</cfsavecontent>
		<!---</cfif>--->
			
			<!--- SEND EMAIL TO ALERT USERS of status change --->
			<cfif len(trim(getCreatorEmail.User_Email)) GT 0 AND trim(getCreatorEmail.User_Email) NEQ trim(uEmail)>
			<cfoutput>
				<CF_EMAILWRAPPER 
					TO			=	"#getCreatorEmail.User_Email#"
			        FROM		=	"#uEmail#"
			        SUBJECT		=	"Program #getThisProgramsStatusEmail.Export_Sales_Agreement_Number# has been approved"
					TYPE		=	"html" 
					messagetype="1" 
					generatedby="2"
					appArea="1"
				>
						<TABLE>
						<TR>
						<TD VALIGN="top">
						Program [#getThisProgramsStatusEmail.Export_Sales_Agreement_Number#] "#getThisProgramsStatusEmail.Export_Sales_Agreement_Name#" has been approved by  #uName# on #DateFormat(Approved_Date, "mm/dd/yyyy")#
						</TD>
						</TR>
						</TABLE>
					<cfif appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
						<CF_Writing_Email_Attachment
			 			Naming_Format="Program_#getThisProgramsStatusEmail.Export_Sales_Agreement_Name#"
						File_Extension="html"
						Relative_Path="\Temp_Files\Program\"
						Output_Content="#EmailContents#"
						addNewLine="No"
						Return_File_Name="fName">
								
						<cf_emailwrapperparam file = "#fName#" store="yes" />
					</cfif>
				</CF_EMAILWRAPPER>
			</cfoutput>
			</cfif>
	</cfif>

	<script>
		opener.location.href = 'sales_agreement_edit_menu.cfm?CID=<cfoutput>#CID#</cfoutput>';
		window.close();
	</script>
