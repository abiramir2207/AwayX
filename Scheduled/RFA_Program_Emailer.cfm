<cfset useLakebaseForgetSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetSettings>
	<cftry>
		<cfset getSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "rfa_email"
			}), "rfa_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetSettings>
<cfquery name="getSettings" datasource="#application.datasource#">
	SELECT RFA_Email
	FROM general_Settings
</cfquery>
</cfif>

<cfif getSettings.RFA_Email EQ 2>
		<cfquery name="getRFAEmailPrograms" datasource="#application.datasource#">
		SELECT     TOP 100 PERCENT dbo.Contract_Main.Contract_Main_ID, dbo.User_Position_Holders.User_Positions_ID, dbo.User_Positions.Service_Zone_ID, 
		                      dbo.User_Positions.Service_Region_ID, dbo.User_Positions.Service_Market_ID
		FROM         dbo.User_Position_Holders INNER JOIN
		                      dbo.Contract_Main INNER JOIN
		                      dbo.Contract_Main_Aux_Data ON dbo.Contract_Main.Contract_Main_ID = dbo.Contract_Main_Aux_Data.Contract_Main_ID ON 
		                      dbo.User_Position_Holders.User_ID = dbo.Contract_Main.Broker_User_ID INNER JOIN
		                      dbo.User_Positions ON dbo.User_Position_Holders.User_Positions_ID = dbo.User_Positions.User_Positions_ID
		WHERE     
		(dbo.Contract_Main.Deleted = 0)
		AND 
		(dbo.Contract_Main_Aux_Data.RFA_Email_Sent = 0)
		AND
		(dbo.User_Position_Holders.deleted = 0)
		AND 
		(dbo.User_Positions.Deleted = 0)
		AND NOT 
		(
			(dbo.User_Positions.Service_Zone_ID IS NULL)
			AND
			(dbo.User_Positions.Service_Region_ID IS NULL)
			AND
			(dbo.User_Positions.Service_Market_ID IS NULL)
		)
		ORDER BY dbo.User_Positions.Service_Zone_ID, dbo.User_Positions.Service_Region_ID, dbo.User_Positions.Service_Market_ID
		</cfquery>
		
		
		<cfset programStruct = StructNew()>
		<cfset programStruct.Positions = StructNew()> 
		<BR><BR>
		<cfloop query="getRFAEmailPrograms">
			<CFSET z = trim(getRFAEmailPrograms.Service_Zone_ID)>
			<CFSET r = trim(getRFAEmailPrograms.Service_Region_ID)>
			<CFSET m = trim(getRFAEmailPrograms.Service_Market_ID)>
			
			
			
			<cfquery name="getParentPosition" datasource="#application.datasource#">
				SELECT User_Positions_ID
				FROM User_Positions
				WHERE 
						<cfif len(m) GT 0>
							Service_Zone_ID = '#z#'
							AND
							Service_Region_ID = '#r#'
							AND
							Service_Market_ID IS NULL
						</cfif>
		
						<cfif len(r) GT 0 AND len(m) EQ 0>
							Service_Zone_ID = '#z#'
							AND
							Service_Region_ID IS NULL
							AND
							Service_Market_ID IS NULL					
						</cfif>				
			</cfquery>
			
			<cfset temp = isdefined("programStruct.Positions.POS_#getParentPosition.User_Positions_ID#")>
			<cfif not temp>
				<cfset "programStruct.Positions.POS_#getParentPosition.User_Positions_ID#.Programs" = Contract_Main_ID>
				<cfset "programStruct.Positions.POS_#getParentPosition.User_Positions_ID#.EmailAddress" = "">
			<cfelse>
				<cfset tempStruct = evaluate("programStruct.Positions.POS_#getParentPosition.User_Positions_ID#")>
				<cfset tempStruct.Programs = listappend(tempStruct.Programs, Contract_Main_ID)>
			</cfif>
		</cfloop> 
		
		<cfloop index="LongHandPosition" list="#StructKeyList(programStruct.Positions)#" delimiters=",">
			<cfset PositionID = listgetat(LongHandPosition, 2, "_")>
		
			<cfset tempStruct = evaluate("programStruct.Positions.#LongHandPosition#")>
			
			
			<cfif listlen(tempStruct.Programs) GT 0>
				<cfquery name="getEmailAddress" datasource="#application.datasource#">
					SELECT User_Email
					FROM _USERS
					WHERE User_ID IN(SELECT User_ID FROM User_Position_Holders WHERE User_Positions_ID = '#PositionID#' AND Deleted = 0)
				</cfquery>
				<cfset tempStruct.EmailAddress = getEmailAddress.User_Email>
			
				<cfquery name="getProgramInfo" datasource="#application.datasource#">
					SELECT Contract_Title,Contract_Number,Contract_Start_Date,Contract_End_Date
					FROM Contract_Main
					WHERE Contract_Main_ID IN(#tempStruct.Programs#)
					ORDER BY Contract_Number
				</cfquery>
				
		
		
						<CF_EMAILWRAPPER 
							TO			=	"bflynn@bigredflame.com"
							FROM		=	"bflynn@bigredflame.com"
							SUBJECT		=	"Ready For Approval (RFA) Programs - Daily Summary"
							TYPE		=	"html" 
							messagetype="1" 
							generatedby="2"
							appArea="1"
						>
		<style>
			.CONFIDENTIALITY_statement_td {
				width: 600px;
				background-color:WhiteSmoke;
				text-align: left;
				font-size: 12px;
				border: thin solid Red;
				
			}
		
			.email_title_td {
				font-size: 20px;
				font-weight: bold;
				color: Navy;
				
			}
			
			.informative_sentence {
				font-weight: bold;
				font-size: 13px;
				
			}
		
			.informative_sentence_critical_info {
				font-weight: bold;
				font-size: 13px;
				color: red;
				
			}
			
			.tableheaders {
				font-size:13px;
				font-weight:bold;
				border-bottom:thin #FFFFFF 0px; 
					
			}	
			BODY, TD, .normal
			{
				font-family : Arial;
				font-size : 8pt;
				color : Black;
			}
			
			
			TABLE.Maintable TD 
			{
				border-bottom:solid #93BEE2 1px; font-size : 10px;
			}
			
			.normal
			{
				font-family : Arial;
				font-size : 8pt;
				color : Black;
			}	
		</style>
		
		<cfoutput>
		<table cellspacing="0" cellpadding="0" align="center">
			<tr>
				<td class="email_title_td" align="center">Program(s) Ready For Approval Notification</td>
			</tr>
		</table>
		<hr width="600" color="Orange">
		<div align="center"><!--- #informative_sentence# ---></div>
		<BR><BR>
		<table cellspacing="0" cellpadding="3" align="center" width="700">
			<tr BGCOLOR="FFE083">
				<td width="100"><span class="tableheaders">Program</span></td>
				<td width="300"><span class="tableheaders">Title</span></td>
				<td><span class="tableheaders">Start</span></td>
				<td><span class="tableheaders">-</span></td>
				<td><span class="tableheaders">End</span></td>
			</tr>
			<cfloop query="getProgramInfo">
				<tr>
					<td><b>#getProgramInfo.Contract_Number#</b></td>
					<td><b>#getProgramInfo.Contract_Title#</b></td>
					<td><b>#dateformat(getProgramInfo.Contract_Start_Date, 'mm/dd/yyyy')#</b></td>
					<td><b>-</b></td>
					<Td><b>#dateformat(getProgramInfo.Contract_End_Date, 'mm/dd/yyyy')#</b></TD>
				</tr>
			</cfloop>
		</table>
		
		<hr width="600" color="Orange">
		
		<BR><BR>
		
		<table cellspacing="3" cellpadding="10" align="center">
			<tr>
				<td class="CONFIDENTIALITY_statement_td">
					#application.returned_customer_setting.CONFIDENTIALITY_CONTENT#
				</td>
			</tr>
		</table>
		<div align="center">this information is current as of #timeformat(Now(), 'h:m:ss tt')# on #dateformat(Now(), 'm/d/yyyy')#</div>
		</cfoutput>
						</CF_EMAILWRAPPER>	
			
			
			
		<!--- 		<!--- update RFA sent bit --->
				<cfquery name="update_RFA_Email_Bit" datasource="#application.datasource#">
					UPDATE Contract_Main_Aux_Data
					SET RFA_Email_Sent = 1
					WHERE Contract_Main_ID IN(#tempStruct.Programs#)
				</cfquery> --->
			
			</cfif>
		</cfloop>
</cfif>