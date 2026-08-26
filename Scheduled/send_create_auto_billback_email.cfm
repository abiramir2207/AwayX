<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

<!--- Get the new scheduled auto billbacks created --->
<cfquery name="getAllNewautoBillbacks" dataSource="#application.datasource#">
	SELECT  bb.billback_ID
	FROM   Billback bb INNER JOIN Billback_Program bbp
	ON bb.billback_ID = bbp.billback_ID
	WHERE bb.deleted = 0
	AND	bb.Sent_Create_Auto_Billback_Email = 0
	AND (bb.Scheduled_Auto_BB = 1 OR bb.scheduled_Operator_Auto_BB = 1)
</cfquery>

<cfset Billback_ID_List = "">
<cfset ProgramID_List ="">

<cfoutput query ="getAllNewautoBillbacks">
	<cfset BillbackID = getAllNewautoBillbacks.Billback_ID>

<!--- Loop through a billback only once --->
<cfif ListFindNoCase(Billback_ID_List, Billback_ID) eq 0>
	<cfset Billback_ID_List = ListAppend(Billback_ID_List,BillbackID)>
		<cfquery name="getNewautoBillback" dataSource="#application.datasource#">
			SELECT  cm.Contract_Number, u.User_Email, bb.BB_Code, bb.bb_start_date, bb.bb_end_Date, bb.Created_Date
				, bsao.Operator_Name
				,CASE WHEN (bsao.Legacy_ID IS NOT NULL AND Len(RTrim(LTrim(bsao.Legacy_ID))) != 0)
						THEN CAST(bsao.Legacy_ID As varchar(50))
						ELSE
						CAST(bsao.BSA_Operator_ID As varchar(50))
				 END As Operator_ID	
				, bsac.Name, bsac.Ship_To
				FROM   Billback bb
					INNER JOIN Billback_Program bbp
				ON bb.Billback_ID = bbp.Billback_ID
				AND bb.deleted = 0
				AND bbp.deleted = 0
					INNER JOIN Contract_Main cm
				ON cm.Contract_Main_ID = bbp.Program_ID
					LEFT JOIN Billback_operator bbo
				ON bb.Billback_ID = bbo.Billback_ID
				AND bbo.deleted = 0
					LEFT JOIN BSA_Operator bsao
				ON bbo.Operator_ID = bsao.BSA_Operator_ID
					LEFT JOIN Billback_Distributor bbd
				ON bb.Billback_ID = bbd.Billback_ID
					LEFT JOIN BSA_Foodservice_Customers bsac
				ON bbd.Distributor_ID = bsac.BSA_Foodservice_Customers_ID
				AND bbd.deleted = 0		
					LEFT JOIN _Users u
				ON cm.Responsible_User_ID = u.User_ID	
				WHERE bb.billback_ID = '#getAllNewautoBillbacks.Billback_ID#'	
				AND bb.Sent_Create_Auto_Billback_Email = 0
				AND (bb.Scheduled_Auto_BB = 1 OR bb.scheduled_Operator_Auto_BB = 1)		
				ORDER BY bb.Billback_ID, cm.Contract_Number
		</cfquery>

<!--- In the above query, Scheduled_Auto_BB is for Pactiv and scheduled_Operator_Auto_BB is for other clients, like McCain (As of Oct, 05) --->
<CF_EMAILWRAPPER 
		 TO	=	"#getNewautoBillback.User_Email#"
		 FROM		=	"#Contact_Admin_Email_Address#"
		 SUBJECT		=	"Auto Billback Creation Notification"
		 TYPE		=	"html" 
		 MESSAGETYPE="1" 
		 GENERATEDBY="1" 
		 APPAREA="3">

			<style type="text/css">
			.heading 	
				{
				font-family: verdana,arial,helvetica; font-size: 11px; font-weight: bold; 
				}
			.PageContent 
				{
				font-family:Verdana, Arial, Helvetica, sans-serif;font-size:11px; vertical-align:top;
				}
			.SectionHeaders
			{
				font-family:Verdana, Arial, Helvetica, sans-serif; font-size:12px; font-weight:bold; color:brown;
			}
			</style>

				<div class="heading" align="center">The following billback has been created on #DateFormat(getNewautoBillback.Created_Date, "mm/dd/yyyy")#</div>

				<table align="center" cellpadding="5" border="0">
					<tr>
						<td class="SectionHeaders">Claim Number</td>
						<td class="SectionHeaders">Contract Number</td>
					<cfif getNewautoBillback.Operator_Name neq "">
						<td class="SectionHeaders">#application.returned_customer_setting.operator_label_singular# Name</td>
						<td class="SectionHeaders">#application.returned_customer_setting.operator_label_singular# ##</td>
					<cfelseif getNewautoBillback.Name neq "">
						<td class="SectionHeaders">#application.returned_customer_setting.distributor_label_singular#</td>
						<td class="SectionHeaders">#application.returned_customer_setting.shard_ship_to_label#</td>
					</cfif>
						<td class="SectionHeaders">Claim period dates</td>
					</tr>

					<tr>
						<td class="PageContent">#getNewautoBillback.BB_Code#</td>
						<td class="PageContent"><cfloop query="getNewautoBillback">#Contract_Number#<br /></cfloop></td>
					<cfif getNewautoBillback.Operator_Name neq "">
						<td class="PageContent">#getNewautoBillback.Operator_Name#</td>
						<td class="PageContent">#getNewautoBillback.Operator_ID#</td>
					<cfelseif getNewautoBillback.Name neq "">
						<td class="PageContent">#getNewautoBillback.Name#</td>
						<td class="PageContent">#getNewautoBillback.Ship_To#</td>
					</cfif>
						<td class="PageContent">#DateFormat(getNewautoBillback.bb_start_date,"mm/dd/yyyy")# - #DateFormat(getNewautoBillback.bb_end_date,"mm/dd/yyyy")#</td>
					</tr>
				</table>
	</CF_EMAILWRAPPER>

	<CFQUERY NAME="UpdateSentBit" DATASOURCE="#Application.Datasource#">
		UPDATE Billback
		SET Sent_Create_Auto_Billback_Email = 1
		WHERE Billback_ID = '#Billback_ID#'
	</CFQUERY>	

</cfif>
</cfoutput>
