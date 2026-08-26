<!----------------- Add Spinner ------------------------>
<!------

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

----->
<!----------------- Add Spinner ------------------------>

<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


<!---Gets the current user's position--->
<cfset useLakebaseForgetUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetUserPosition>
	<cftry>
		<cfset getUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserPosition>
<CFQUERY NAME="getUserPosition" DATASOURCE="#application.datasource#">
SELECT User_Positions_ID
FROM User_Position_Holders
WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
</cfif>

<!---Includes approval rights stuff--->
<CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">

<cfparam name="Route_Document_ID" 	default="">



	<CFQUERY NAME="Is_This_Billback_Accessible" DATASOURCE="#APPLICATION.DATASOURCE#">
		SELECT	 
			CASE 
			WHEN User_Positions.User_Positions_ID IS NULL THEN
				''
			ELSE
				CAST(bb.Billback_ID AS VARCHAR(36))
			END AS Accessible_Billback_ID
			
		FROM	
		Billback bb
		---------------------------------------------------			
		LEFT JOIN	
			(
			Billback_Distributor
			LEFT JOIN 
			BSA_Foodservice_Customers
			ON 
			(Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)
			)
		ON
		(
		(Billback_Distributor.Billback_ID = bb.Billback_ID)
		AND
		(bb.Billback_Payee_Type_ID = 1)
		AND
		(Billback_Distributor.Deleted = 0)
		)
		----------------------------------------------------
		LEFT JOIN
			Billback_Broker
		ON
		(
		(Billback_Broker.Billback_ID = bb.Billback_ID)
		AND
		(bb.Billback_Payee_Type_ID = 3)
		AND
		(Billback_Broker.Deleted = 0)
		)
		----------------------------------------------------	
		LEFT JOIN
			BSA_Foodservice_Brokers
		ON
		(
		(Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
		<cfif NOT appSettings.getDistributorMultiPosition()>
		OR
		(BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
		</cfif>
		)
		<cfif appSettings.getDistributorMultiPosition()>
		LEFT JOIN	Market_Distributor
		ON Market_Distributor.Deleted = 0
		AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Market_Distributor.Distributor_ID
		</cfif>
		LEFT JOIN	User_Positions 
		ON 
		(
			(
				(BSA_Foodservice_Brokers.Service_Market_ID = User_Positions.Service_Market_ID)
				OR
				(bb.BB_Creator_User_Position_ID = User_Positions.User_Positions_ID)			
				<cfif appSettings.getDistributorMultiPosition()>
				OR
				(Market_Distributor.Service_Market_ID = User_Positions.Service_Market_ID)
				</cfif>
			)
			AND
			(User_Positions.User_Positions_ID IN (#GP_Position_List_From_My_Position_Down#))			
		)
		WHERE
		bb.Deleted = 0		
		<CFIF Len(Route_Document_ID) GT 0>
		AND
		bb.Billback_ID = '#Route_Document_ID#'
		</CFIF>
	</CFQUERY>
	<cfset Route_Document_Access				=	"">
	<CFIF Is_This_Billback_Accessible.recordCount GT 0>
		<cfset Route_Document_Access = 	listqualify(valuelist(Is_This_Billback_Accessible.Accessible_Billback_ID), chr(39))>
	</CFIF>


