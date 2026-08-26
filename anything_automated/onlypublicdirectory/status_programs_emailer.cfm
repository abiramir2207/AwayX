<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFINCLUDE TEMPLATE="\common_files\contracts\comparelist.cfm">
<cfset userManager = CreateObject("component", "components.user.UserManager") />
<cfquery name="getAllPositions" datasource="#application.datasource#">
select distinct top 1 User_Positions.User_Positions_ID, User_Positions.Position_Label
from User_Positions
where deleted = 0
and
(User_Positions.Position_Label != 'NULL' AND User_Positions.Position_Label != '') 
</cfquery>

<cfquery name="getGSettings" datasource="#application.datasource#">
				SELECT
					send_broker_email
				FROM
					General_Settings
</cfquery>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


<CFLOOP query="getAllPositions">
<cfquery name="userPositionContactInfo" datasource="#application.datasource#">
SELECT distinct  User_Positions.User_Positions_ID, User_Positions.Position_Label, _Users.User_Email
	FROM       	_Users 
				INNER JOIN	User_Position_Holders 
				ON _Users.User_ID = User_Position_Holders.User_ID 
				INNER JOIN	User_Positions 
				ON User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
	WHERE     
				User_Positions.Deleted = 0
				AND User_Position_Holders.deleted = 0
				AND _Users.Deleted = 0
				AND User_Positions.User_Positions_ID = <cfqueryparam value="#getAllPositions.User_Positions_ID#" cfsqltype="CF_SQL_INTEGER">
				<cfif appSettings.getsendsecondaryemail() EQ 0>
				AND User_Position_Holders.User_Position_Type <> 'S'
				</cfif>
</cfquery>


<cfif getGSettings.send_broker_email EQ 1>
	<cfset brokerEmailAddress = userManager.getBrokerEmailAddress(getAllPositions.User_Positions_ID) />
	<cfif Len(brokerEmailAddress) GT 0>
		<cfloop list="#brokerEmailAddress#" delimiters=";" index="thisBrokerEmail">
			<cfquery name="qGetEmailMatch" dbtype="query">
				SELECT 	*
				FROM	userPositionContactInfo
				WHERE
						User_Email LIKE '%#thisBrokerEmail#%'
			</cfquery>
			<cfif NOT qGetEmailMatch.recordCount>
				<cfset QueryAddRow(userPositionContactInfo) />
				<cfset QuerySetCell(userPositionContactInfo, "User_Email", thisBrokerEmail) />
			</cfif>
		</cfloop>
	</cfif>
</cfif>

<cfset emaillist = ValueList(userPositionContactInfo.User_Email)>

<CFSET GP_Supplied_Position = ValueList(getAllPositions.User_Positions_ID)>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">

<cfset List_From_My_Position_Down = GP_Position_List_From_My_Position_Down>


<cfquery name="getAllPrograms" datasource="#application.datasource#">
	SELECT Contract_Main.Contract_Number,Is_A_Revision,
contract_title,contract_start_date,contract_end_date,Contract_Status_Type_Desc,Service_Regions.Region_Name,Service_Markets.Market_Name,status_changed_date,contract_status.Contract_Status_Type_IDX
	FROM	dbo.Contract_Main 
			INNER JOIN dbo.Contract_Status ON dbo.Contract_Main.Contract_Main_ID = dbo.Contract_Status.Contract_Main_ID
			INNER JOIN Contract_Status_Types ON 
			dbo.Contract_Status.Contract_Status_Type_IDX = Contract_Status_Types.Contract_Status_Type_ID
			INNER JOIN	User_Positions 
				ON Contract_Main.creating_user_position_id = User_Positions.User_Positions_ID
			LEFT OUTER JOIN Service_Regions
			ON User_Positions.Service_Region_ID  = Service_Regions.Service_Region_ID
			LEFT OUTER JOIN Service_Markets
			ON User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID
	WHERE
		Contract_Main.Deleted = 0
			AND	Contract_Status.EmailSent = 0 --only select programs which havent had this email sent already
			AND status_changed_date BETWEEN '#Dateformat(DateAdd("ww", -1, now()),"mm/dd/yyyy")#' AND '#Dateformat(DateAdd("d", 1, now()),"mm/dd/yyyy")#'
AND creating_user_position_id IN (#List_From_My_Position_Down#)
group by Service_Regions.Region_Name,Service_Markets.Market_Name,
Contract_Main.contract_number,contract_title,contract_start_date,contract_end_date,Contract_Status_Type_Desc,contract_status.Contract_Status_Type_IDX ,status_changed_date,Is_A_Revision
order by Service_Regions.Region_Name,Service_Markets.Market_Name,
Contract_Main.contract_number,contract_status.Contract_Status_Type_IDX asc
</cfquery>

<CFINCLUDE TEMPLATE="\anything_automated\email\status_notification_programs.cfm">
<cfflush>
<CFSET request.AccessStructure.User_ID = "0000000000">
<!--- <cfsavecontent variable = "EmailContents">
			<CFINCLUDE TEMPLATE="status_notification_programs.cfm">
</cfsavecontent>
<cfoutput>
		<cfloop query="userPositionContactInfo">
			<cfset finalEmailAddress = userPositionContactInfo.User_Email>
			
			
			<cf_EmailWrapper 
				to="#finalEmailAddress#" 
				from="BlacksmithApplicationsNotificationService@#application.CompanyEmailSuffix#" 
				subject="Programs Status Notification" 
				type="HTML"
				messagetype="1" 
				generatedby="1" 
				apparea="1">
						<CF_Writing_Email_Attachment
  				Naming_Format="Program_Status_Notification"
				File_Extension="html"
				Relative_Path="\Temp_Files\Program_Status\"
				Output_Content="#EmailContents#"
				addNewLine="No"
				Return_File_Name="fName">
						<cf_emailwrapperparam file = "#fName#" store="yes" />
				
			<!--- </cfmail> --->
			</cf_EmailWrapper>
		</cfloop>
		</cfoutput> --->
</CFLOOP>

