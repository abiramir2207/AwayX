<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		Send mail to the user who requested approval
		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<!--- STATUS CHANGE NOTIFICATION EMAIL --->
	<cfset useLakebaseForgetThisProgramsStatusEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForgetThisProgramsStatusEmail>
	<cftry>
		<cfset getThisProgramsStatusEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_sales_agreement", {
				"export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#",
				"select" = "contract_status_type_idx,revision_of_export_sales_agreement_id,rfa_user_id,export_sales_agreement_number,export_sales_agreement_name,creating_user_position_id,creator_id"
			}), "contract_status_type_idx,revision_of_export_sales_agreement_id,rfa_user_id,export_sales_agreement_number,export_sales_agreement_name,creating_user_position_id,creator_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetThisProgramsStatusEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetThisProgramsStatusEmail>
<CFQUERY NAME="getThisProgramsStatusEmail" datasource="#application.datasource#">
		SELECT 	Contract_Status_Type_IDX, Revision_Of_Export_Sales_Agreement_ID, RFA_User_ID, Export_Sales_Agreement_Number, Export_Sales_Agreement_Name, Creating_User_Position_ID
						,Creator_ID
		FROM 	Export_Sales_Agreement
		WHERE 	Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
	</CFQUERY>
</cfif>

<CFIF getThisProgramsStatusEmail.Contract_Status_Type_IDX GTE 3><!----  Approved ------>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	
	<cfset userManager = CreateObject("component", "components.user.UserManager") />
	<cfset Approved_Date = now()>
	
	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"select" = "name_first,name_last,user_email"
			}), "name_first,name_last,user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<cfquery name="getUserName" datasource="#application.datasource#">
		SELECT Name_First, Name_Last, User_Email
		FROM _Users
		WHERE User_ID = '#request.AccessStructure.user_id#'
	</cfquery>
</cfif>

	<cfset useLakebaseForgetCreatorEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetCreatorEmail>
	<cftry>
		<cfset getCreatorEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#getThisProgramsStatusEmail.Creator_ID#",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCreatorEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCreatorEmail>
<cfquery name="getCreatorEmail" datasource="#application.datasource#">
		SELECT User_Email
		FROM _Users
		WHERE User_ID = '#getThisProgramsStatusEmail.Creator_ID#'
	</cfquery>
</cfif>
	
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
