<CFPARAM NAME="FORM.CONTRACT_STATUS" DEFAULT="">
<CFPARAM NAME="FORM.Program_Type" DEFAULT="0">
<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Zone_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
<CFPARAM NAME="FORM.Distributor" DEFAULT="">
<CFPARAM NAME="FORM.Broker" DEFAULT="">





<CFQUERY NAME="getUserInformation" datasource="#application.datasource#">
	SELECT     dbo.User_Positions.Service_Zone_ID, dbo.User_Positions.Service_Region_ID, dbo.User_Positions.Service_Market_ID, 
	                     dbo.User_Position_Holders.User_ID, dbo.User_Position_Holders.deleted, dbo.User_Positions.Deleted, 
	                     dbo.User_Position_Holders.User_Positions_ID
	FROM         dbo.User_Positions INNER JOIN
	                     dbo.User_Position_Holders ON dbo.User_Positions.User_Positions_ID = dbo.User_Position_Holders.User_Positions_ID
	WHERE     (dbo.User_Position_Holders.deleted = 0) AND (dbo.User_Positions.Deleted = 0) AND dbo.User_Position_Holders.User_ID = '#request.AccessStructure.User_ID#'
</CFQUERY>



<!--- get approver data --->


<CFSET Position_Type = "0">
<!--- Market --->
<CFIF 
	len(trim(getUserInformation.Service_Zone_ID)) GT 0
	AND
	len(trim(getUserInformation.Service_Region_ID)) GT 0
	AND
	len(trim(getUserInformation.Service_Market_ID)) GT 0
>
	<CFSET Position_Type = "MARKET">
	
	<CFSET Position_List_From_My_Position_Down = getUserInformation.User_Positions_ID>
	
	
</CFIF>

<!--- Region --->
<CFIF 
	len(trim(getUserInformation.Service_Zone_ID)) GT 0
	AND
	len(trim(getUserInformation.Service_Region_ID)) GT 0
	AND
	getUserInformation.Service_Market_ID 	EQ ""
>
	<CFSET Position_Type = "REGION">
	
	<CFQUERY NAME="getThisRegionsSubMarketPostions" datasource="#application.datasource#">
		SELECT     dbo.User_Positions.User_Positions_ID
		FROM         dbo.Service_Regions INNER JOIN
		                      dbo.Service_Markets ON dbo.Service_Regions.Service_Region_ID = dbo.Service_Markets.Service_Region_ID INNER JOIN
		                      dbo.User_Positions ON dbo.Service_Regions.Service_Region_ID = dbo.User_Positions.Service_Region_ID AND 
		                      dbo.Service_Markets.Service_Market_ID = dbo.User_Positions.Service_Market_ID
		WHERE     (dbo.User_Positions.Deleted = 0) AND (dbo.Service_Regions.Service_Region_ID = '#getUserInformation.Service_Region_ID#')
	</CFQUERY>
	<CFSET Position_List_From_My_Position_Down = valuelist(getThisRegionsSubMarketPostions.User_Positions_ID)>
	<CFSET Position_List_From_My_Position_Down = listappend(Position_List_From_My_Position_Down,getUserInformation.User_Positions_ID)>
</CFIF>


<!--- ZONE --->
<CFIF 
	len(trim(getUserInformation.Service_Zone_ID)) GT 0
	AND
	getUserInformation.Service_Region_ID	EQ	""
	AND
	getUserInformation.Service_Market_ID 	EQ	""
>
	<CFSET Position_Type = "ZONE">

	<CFQUERY NAME="getZoneHolderPosition_ID" datasource="#application.datasource#">
		SELECT     dbo.User_Positions.User_Positions_ID, dbo.Service_Zones.Service_Zone_ID
		FROM         dbo.Service_Zones INNER JOIN
		                      dbo.User_Positions ON dbo.Service_Zones.Service_Zone_ID = dbo.User_Positions.Service_Zone_ID
		WHERE     (dbo.User_Positions.Service_Region_ID IS NULL) AND (dbo.User_Positions.Service_Market_ID IS NULL) AND 
		                      (dbo.Service_Zones.Service_Zone_ID = '#getUserInformation.Service_Zone_ID#')
	</CFQUERY>
	
	<CFSET Position_List_From_My_Position_Down = valuelist(getZoneHolderPosition_ID.User_Positions_ID)>

	<CFQUERY NAME="getRegionsBelongingToThisZone" datasource="#application.datasource#">
		SELECT     User_Positions_ID, Service_Region_ID
		FROM         dbo.User_Positions
		WHERE     (Service_Zone_ID = '#getUserInformation.Service_Zone_ID#') AND (Service_Market_ID IS NULL)
	</CFQUERY>

	<CFSET Position_List_From_My_Position_Down = Position_List_From_My_Position_Down & "," & valuelist(getRegionsBelongingToThisZone.User_Positions_ID)>	
	<CFSET AllRegionsInThisZone = valuelist(getRegionsBelongingToThisZone.Service_Region_ID)>
	
	<CFQUERY NAME="getMarketPositionsInTheseRegions" datasource="#application.datasource#">
		SELECT     dbo.User_Positions.User_Positions_ID
		FROM         dbo.Service_Regions INNER JOIN
		                      dbo.Service_Markets ON dbo.Service_Regions.Service_Region_ID = dbo.Service_Markets.Service_Region_ID INNER JOIN
		                      dbo.User_Positions ON dbo.Service_Regions.Service_Region_ID = dbo.User_Positions.Service_Region_ID AND 
		                      dbo.Service_Markets.Service_Market_ID = dbo.User_Positions.Service_Market_ID
		WHERE     (dbo.User_Positions.Deleted = 0) AND (dbo.Service_Regions.Service_Region_ID IN (#replace(listqualify(AllRegionsInThisZone, "'", ","), '"', "'", "ALL")#))	
	</CFQUERY>
	<CFSET Position_List_From_My_Position_Down = Position_List_From_My_Position_Down & "," & valuelist(getMarketPositionsInTheseRegions.User_Positions_ID)>	

</CFIF>

<!--- GOD --->
<CFIF 
	getUserInformation.Service_Zone_ID		EQ	""
	AND
	getUserInformation.Service_Region_ID	EQ	""
	AND
	getUserInformation.Service_Market_ID 	EQ	""
>
	<CFSET Position_Type = "GOD">
	<CFQUERY NAME="getGODPositions" datasource="#application.datasource#">
		SELECT User_Positions_ID
		FROM User_Positions
		WHERE Deleted = 0
	</CFQUERY>
	<CFSET Position_List_From_My_Position_Down = valuelist(getGODPositions.User_Positions_ID)>
</CFIF>

<CFIF Position_Type NEQ "0">
	<CFIF len(trim(getUserInformation.Service_Zone_ID)) GT 0><CFSET Zone_ID_Search = getUserInformation.Service_Zone_ID></CFIF>
	<CFIF len(trim(getUserInformation.Service_Region_ID)) GT 0><CFSET Region_ID_Search = getUserInformation.Service_Region_ID></CFIF>
	<CFIF len(trim(getUserInformation.Service_Market_ID)) GT 0><CFSET Market_ID_Search = getUserInformation.Service_Market_ID></CFIF>
</CFIF>


<CFPARAM NAME="Zone_ID_Search" DEFAULT="">
<CFPARAM NAME="Region_ID_Search" DEFAULT="">
<CFPARAM NAME="Market_ID_Search" DEFAULT="">

<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\Approver_Tree_Search.cfm">


<CFQUERY NAME="getProgramTypes" datasource="#application.datasource#">
	SELECT Created_Type
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#FORM.Program_Type#'
</CFQUERY>

<CFQUERY NAME="GetRegion" datasource="#application.datasource#">
	SELECT *
	FROM Service_Regions
	WHERE 0=1
</CFQUERY>
<cfif FORM.Region_ID NEQ "0">
	<cfset useLakebaseForGetRegion = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_regions")>
	<cfif useLakebaseForGetRegion>
		<cftry>
			<cfset GetRegion = application.oLakebase.toQuery(
				application.oLakebase.selectRows("service_regions", { "service_region_id" = "eq.#FORM.Region_ID#" })
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetRegion = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetRegion>
		<CFQUERY NAME="GetRegion" datasource="#application.datasource#">
			SELECT *
			FROM Service_Regions
			WHERE Service_Region_ID = '#FORM.Region_ID#'
		</CFQUERY>
	</cfif>
</cfif>

<CFQUERY NAME="GetZone" datasource="#application.datasource#">
	SELECT *
	FROM Service_Zones
	WHERE 0=1
</CFQUERY>
<cfif FORM.Zone_ID NEQ "0">
<CFQUERY NAME="GetZone" datasource="#application.datasource#">
	SELECT *
	FROM Service_Zones
	WHERE Service_Zone_ID = '#FORM.Zone_ID#'
</CFQUERY>
</cfif>

<CFQUERY NAME="GetDistFamily" datasource="#application.datasource#">
	SELECT *
	FROM Distributor_Family
	WHERE 0=1
</CFQUERY>

<cfif FORM.family_name NEQ "0">
<CFQUERY NAME="GetDistFamily" datasource="#application.datasource#">
	SELECT *
	FROM Distributor_Family
	WHERE Family_ID = '#FORM.family_name#'
	ORDER BY Family_Name
</CFQUERY>
</cfif>
<CFQUERY NAME="GetStatus" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Status_Types
	WHERE 0=1
</CFQUERY>

<cfif listlen(FORM.contract_status) NEQ "0">
<CFQUERY NAME="GetStatus" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Status_Types
	WHERE Contract_Status_Type_ID IN(#FORM.contract_status#)
	ORDER BY Contract_Status_Type_Desc
</CFQUERY>
</cfif>




<!--- temp variable override until templates functionality is recoded --->
<cfset template = 0>


<SPAN CLASS="title2">Supplied Program Search Criteria:</SPAN>
<HR COLOR="Orange">


<CFOUTPUT>
	<TABLE border="0" cellspacing="0" CELLPADDING="1" WIDTH="800">
		<TR>
			<TD NOWRAP><B>Program Type:</B></TD>
			<TD NOWRAP><CFIF getProgramTypes.recordcount EQ 0><FONT COLOR="Gray">Any Type</FONT><CFELSE><FONT COLOR="Red"><B>#getProgramTypes.Created_Type#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Program Title</B></TD>
			<TD NOWRAP><CFIF contract_title EQ ""><FONT COLOR="Gray">Any Title</FONT><CFELSE><FONT COLOR="Red"><B>#contract_title#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Program Number:</B></TD>
			<TD NOWRAP><CFIF contract_number EQ ""><FONT COLOR="Gray">Any Contract Number</FONT><CFELSE><FONT COLOR="Red"><B>#contract_number#</B></FONT></CFIF></TD>
		</TR>
		<TR>
			<TD NOWRAP><B>Broker:</B></TD>
			<TD NOWRAP><CFIF Broker EQ ""><FONT COLOR="Gray">All Brokers</FONT><CFELSE><FONT COLOR="Red"><B>#Broker#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Region:</B></TD>
			<TD NOWRAP><CFIF GetRegion.recordcount EQ 0><FONT COLOR="Gray">Any Region</FONT><CFELSE><FONT COLOR="Red"><B>#GetRegion.Region_Name#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Zone:</B></TD>
			<TD NOWRAP><CFIF GetZone.recordcount EQ 0><FONT COLOR="Gray">Any Zone</FONT><CFELSE><FONT COLOR="Red"><B>#GetZone.Zone_Name#</B></FONT></CFIF></TD>
		</TR>
		<TR>
			<TD NOWRAP><B>#application.returned_customer_setting.distributor_label_singular#:</B></TD>
			<TD NOWRAP><CFIF Distributor EQ ""><FONT COLOR="Gray">All #application.returned_customer_setting.distributor_label_plural#</FONT><CFELSE><FONT COLOR="Red"><B>#Distributor#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>#application.returned_customer_setting.distributor_label_singular# Family:</B></TD>
			<TD NOWRAP><cfif GetDistFamily.recordcount EQ 0><FONT COLOR="Gray">All Families</FONT><CFELSE><FONT COLOR="Red"><B>#GetDistFamily.Family_Name#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>#application.returned_customer_setting.operator_label_singular#:</B></TD>
			<TD NOWRAP><CFIF Operator EQ ""><FONT COLOR="Gray">All #application.returned_customer_setting.operator_label_plural#</FONT><CFELSE><FONT COLOR="Red"><B>#Operator#</B></FONT></CFIF></TD>
		</TR>		
		<TR>
			<TD NOWRAP><B>Program Status:</B></TD>
			<TD NOWRAP COLSPAN="100%"><CFIF listlen(FORM.contract_status) EQ 0><FONT COLOR="Gray">All Programs</FONT><CFELSE><FONT COLOR="Red"><B>#replace(valuelist(GetStatus.Contract_Status_Type_Desc), ",", ", ", "ALL")#</B></FONT></CFIF></TD>
		</TR>		
		<TR>
			<TD COLSPAN="8"><BR></TD>
		</TR>


		
		<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
			Select		*
			From		_Users_Settings
			Where		User_ID		=		'#request.AccessStructure.Company_Main_ID#'
		</CFQUERY>

		<TR>
			<TD><B>Status codes:</B></TD>
			<TD NOWRAP><IMG SRC="/Images/wip.gif" ALIGN="middle"> Work in progress</TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><IMG SRC="/Images/RFA.gif" ALIGN="middle"> Ready For Approval</TD>
			<TD NOWRAP><IMG SRC="/Images/preactive.gif" ALIGN="middle"> Pre-Active</TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><IMG SRC="/Images/expiring.gif" ALIGN="middle"> Expiring in < #Get_Settings.Contract_Expiration_Range# weeks</TD>
			<TD NOWRAP><IMG SRC="/Images/active.gif" ALIGN="middle"> Active</TD>
			<TD NOWRAP><IMG SRC="/Images/expired.gif" ALIGN="middle"> Expired contracts</TD>
			<TD NOWRAP></TD>
		</TR>



	</TABLE>
</CFOUTPUT>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>






<!--- find programs with distributors in positions that concern me --->
<CFIF listlen(Position_List_From_My_Position_Down)GT 0 AND FORM.contract_status GTE 3>
<CFQUERY NAME="getProgramsWithDistributorsInMyPositionBranch" datasource="#application.datasource#">
SELECT     dbo.User_Positions.User_Positions_ID, dbo.Contract_Distributors.Contract_Main_ID, dbo.Contract_Main.Contract_Status_Type_IDX
FROM         dbo.Service_Regions INNER JOIN
                      dbo.User_Positions INNER JOIN
                      dbo.Service_Markets ON dbo.User_Positions.Service_Market_ID = dbo.Service_Markets.Service_Market_ID ON 
                      dbo.Service_Regions.Service_Region_ID = dbo.Service_Markets.Service_Region_ID INNER JOIN
                      dbo.BSA_Foodservice_Customers INNER JOIN
                      dbo.BSA_Foodservice_Brokers ON 
                      dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID INNER
                       JOIN
                      dbo.Contract_Distributors ON 
                      dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = dbo.Contract_Distributors.BSA_Foodservice_Customers_ID INNER JOIN
                      dbo.Contract_Main ON dbo.Contract_Distributors.Contract_Main_ID = dbo.Contract_Main.Contract_Main_ID ON 
                      dbo.Service_Markets.Service_Market_ID = dbo.BSA_Foodservice_Brokers.Service_Market_ID
WHERE     (dbo.Service_Markets.Deleted = 0) AND (dbo.User_Positions.Deleted = 0) AND (dbo.Contract_Distributors.Deleted = 0) AND 
                      (dbo.BSA_Foodservice_Customers.Deleted = 0) AND (dbo.Contract_Main.Contract_Status_Type_IDX = #FORM.contract_status#) AND (dbo.Contract_Main.Deleted = 0)
					  AND dbo.User_Positions.User_Positions_ID IN(#Position_List_From_My_Position_Down#)

					  <CFIF FORM.Program_Type NEQ "0">
					  	<!--- program type filter --->
						AND dbo.Contract_Main.ProgramType_ID = '#FORM.Program_Type#'
					  </CFIF>
					  
					  <CFIF FORM.Region_ID NEQ "0">
					  	<!--- region filter --->
						AND dbo.Service_Markets.Service_Region_ID = '#FORM.Region_ID#'
					  </CFIF>

					  <CFIF FORM.Zone_ID NEQ "0">
					  	<!--- zone filter --->
						AND dbo.Service_Regions.Service_Zone_ID = '#FORM.Zone_ID#'
					  </CFIF>
					  
					  <CFIF FORM.Family_Name NEQ "0">
					  	<!--- family name --->
						dbo.BSA_Foodservice_Customers.Family_ID = '#FORM.Family_Name#'
					  </CFIF>

				<!--- distribuotr_name --->
				<CFIF trim(FORM.Distributor) NEQ "">
						and
						(
						dbo.BSA_Foodservice_Customers.Name LIKE '#trim(FORM.Distributor)#%'		or
						dbo.BSA_Foodservice_Customers.Name LIKE '%#trim(FORM.Distributor)#'		or
						dbo.BSA_Foodservice_Customers.Name LIKE '%#trim(FORM.Distributor)#%'	or
						dbo.BSA_Foodservice_Customers.Name LIKE '#trim(FORM.Distributor)#'		
						)
				</CFIF>					  
</CFQUERY>
<CFSET ProgramsWithDistributorsInPositionsThatConcernMe = valuelist(getProgramsWithDistributorsInMyPositionBranch.Contract_Main_ID)>
<CFELSE>
	<CFSET ProgramsWithDistributorsInPositionsThatConcernMe = "">
</CFIF>

<!--- find programs with brokers in positions that concern me --->
<CFIF listlen(Position_List_From_My_Position_Down)GT 0  AND FORM.contract_status GTE 3>
<CFQUERY NAME="getProgramsWithBrokersInMyPositionBranch" datasource="#application.datasource#">
SELECT     dbo.User_Positions.User_Positions_ID, dbo.Contract_Main.Contract_Status_Type_IDX, dbo.Contract_Brokers.Contract_Main_ID
FROM         dbo.Service_Regions INNER JOIN
                      dbo.User_Positions INNER JOIN
                      dbo.Service_Markets ON dbo.User_Positions.Service_Market_ID = dbo.Service_Markets.Service_Market_ID ON 
                      dbo.Service_Regions.Service_Region_ID = dbo.Service_Markets.Service_Region_ID INNER JOIN
                      dbo.Contract_Brokers INNER JOIN
                      dbo.BSA_Foodservice_Brokers ON 
                      dbo.Contract_Brokers.BSA_Foodservice_Brokers_ID = dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID INNER JOIN
                      dbo.Contract_Main ON dbo.Contract_Brokers.Contract_Main_ID = dbo.Contract_Main.Contract_Main_ID ON 
                      dbo.Service_Markets.Service_Market_ID = dbo.BSA_Foodservice_Brokers.Service_Market_ID
WHERE     (dbo.Service_Markets.Deleted = 0) AND (dbo.User_Positions.Deleted = 0) AND (dbo.Contract_Main.Contract_Status_Type_IDX = #FORM.contract_status#) AND 
                      (dbo.Contract_Main.Deleted = 0) AND (dbo.User_Positions.User_Positions_ID IN (#Position_List_From_My_Position_Down#))
					  <CFIF FORM.Program_Type NEQ "0">
					  	<!--- program type filter --->
						AND dbo.Contract_Main.ProgramType_ID = '#FORM.Program_Type#'
					  </CFIF>

					  <CFIF FORM.Region_ID NEQ "0">
					  	<!--- region filter --->
						AND dbo.Service_Markets.Service_Region_ID = '#FORM.Region_ID#'
					  </CFIF>					  
					  <CFIF FORM.Zone_ID NEQ "0">
					  	<!--- zone filter --->
						AND dbo.Service_Regions.Service_Zone_ID = '#FORM.Zone_ID#'
					  </CFIF>	
					  
				<!--- <B>distribuotr</B>_name --->
				<CFIF trim(FORM.Broker) NEQ "">
						and
						(
						dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '#trim(FORM.Broker)#%'		or
						dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '%#trim(FORM.Broker)#'		or
						dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '%#trim(FORM.Broker)#%'	or
						dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '#trim(FORM.Broker)#'		
						)
				</CFIF>								  				  
					  
</CFQUERY>
<CFSET ProgramsWithBrokersInPositionsThatConcernMe = valuelist(getProgramsWithBrokersInMyPositionBranch.Contract_Main_ID)>
<CFELSE>
	<CFSET ProgramsWithBrokersInPositionsThatConcernMe = "">
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main query to Get contract data																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Contracts" datasource="#application.datasource#">
SELECT    dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo.Contract_Main.*
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
WHERE
	0=0					  
			<!--- Get only the contracts that have not been "deleted" --->
			and
			Deleted = 0

			<!--- Look for contract number --->
			<CFIF trim(contract_number) NEQ "">
					and
					(
					Contract_Number LIKE '#trim(contract_number)#%'		or
					Contract_Number LIKE '%#trim(contract_number)#'		or
					Contract_Number LIKE '%#trim(contract_number)#%'	or
					Contract_Number LIKE '#trim(contract_number)#'		
					)
			</CFIF>
			<!--- End of Look for contract number --->

			<!--- Look for string in contract title --->
			<CFIF trim(contract_title) NEQ "">
					and
					(
					Contract_Title LIKE '#contract_title#%'		or
					Contract_Title LIKE '%#contract_title#'		or
					Contract_Title LIKE '%#contract_title#%'	or
					Contract_Title LIKE '#contract_title#'		
					)
			</CFIF>
			<!--- End of Look for string in contract title --->

		
			<!--- Look at the contract status if it's About to EXPIRE --->
			<CFSWITCH EXPRESSION="#FORM.contract_status#">
					
				<CFCASE VALUE="1">
					<!--- WIP --->
					AND
					Contract_Status_Type_IDX = '1'
					AND 
					Creating_User_Position_ID = '#getUserInformation.User_Positions_ID#'
				</CFCASE>
				
				<CFCASE VALUE="2">
					<!--- Ready For Approval --->
					AND
					Contract_Status_Type_IDX = '2'
	
					<CFIF listlen(Position_List_From_My_Position_Down) GT 0>
						AND 
						Creating_User_Position_ID IN(#Position_List_From_My_Position_Down#)
					</CFIF>
				</CFCASE>

				<CFCASE VALUE="4">
					<!--- Preactive Programs --->
					AND
					Contract_Status_Type_IDX = '4'
	
					<CFIF listlen(Position_List_From_My_Position_Down) GT 0>
						AND 
						Creating_User_Position_ID IN(#Position_List_From_My_Position_Down#)
					</CFIF>
				</CFCASE>
								
				<CFCASE VALUE="5">
					<!--- Active Programs --->
					AND
					Contract_Status_Type_IDX = '5'
	
					<CFIF listlen(Position_List_From_My_Position_Down) GT 0>
						AND 
						Creating_User_Position_ID IN(#Position_List_From_My_Position_Down#)
					</CFIF>
				</CFCASE>

				<CFCASE VALUE="6">
					<!--- Expiring --->
					AND
					Contract_Status_Type_IDX = '6'
	
					<CFIF listlen(Position_List_From_My_Position_Down) GT 0>
						AND 
						Creating_User_Position_ID IN(#Position_List_From_My_Position_Down#)
					</CFIF>
				</CFCASE>

				<CFCASE VALUE="7">
					<!--- Expired --->
					AND
					Contract_Status_Type_IDX = '7'
	
					<CFIF listlen(Position_List_From_My_Position_Down) GT 0>
						AND 
						Creating_User_Position_ID IN(#Position_List_From_My_Position_Down#)
					</CFIF>
				</CFCASE>
			</CFSWITCH>

			<!--- get contract only --->
			And Template = 0
			<!--- Get contracts for this company only --->
			and
			Owner_Company_ID	=	'#request.AccessStructure.Company_Main_ID#'
			
			<CFIF listlen(ProgramsWithDistributorsInPositionsThatConcernMe) GT 0>
				OR Contract_Main_ID IN(#ProgramsWithDistributorsInPositionsThatConcernMe#)
			</CFIF>
			<CFIF listlen(ProgramsWithBrokersInPositionsThatConcernMe) GT 0>
				OR Contract_Main_ID IN(#ProgramsWithBrokersInPositionsThatConcernMe#)
			</CFIF>

			  <CFIF FORM.Program_Type NEQ "0">
			  	<!--- program type filter --->
				AND dbo.Contract_Main.ProgramType_ID = '#FORM.Program_Type#'
			  </CFIF>
						
			Order by Contract_End_Date asc
</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- End of Main query to Get contract data														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->









<BR>
<SPAN CLASS="title2"><CFOUTPUT>There are<CFIF Get_Contracts.Recordcount EQ 0> no <CFELSE> #Get_Contracts.Recordcount# </CFIF>contracts that match the above criteria</CFOUTPUT></SPAN>

<TABLE CLASS="Maintable" WIDTH="85%" CELLPADDING="3" CELLSPACING="0">

<CFIF Get_Contracts.Recordcount NEQ 0>
<TR BGCOLOR="#FFCE84" VALIGN="bottom">
	<TD>&nbsp;</TD>
	<TD ID="header" ALIGN="center"><B>Status</B></TD>
	<TD ID="header"><B>Contract #</B></TD>
	<!--- <TD ID="header"><B>Operator Name</B></TD> --->
	<TD ID="header"><B>Contract Title</B></TD>
	<TD ID="header"><B>Start Date</B></TD>
	<TD ID="header"><B>End Date</B></TD>
	<TD ID="header"><B>Quantity</B></TD>
	<TD ID="header"><B>UOM</B></TD>
</TR>
<TR>
	<TD BGCOLOR="Orange" COLSPAN="10"></TD>
</TR>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Defines the number of rows to display per "page"										       --->
	<cf_Number_of_Rows maxrows="10">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT QUERY="Get_Contracts"  startrow="#StartRow#" maxrows="#MaxRows#">
<CFSET CID = contract_main_id>

<CFSET GST_ID = CID>
<CFIF Revision_of_Contract_Main_ID EQ "">
	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
<CFELSE>
	<TR BGCOLOR="##CCFFFF" VALIGN="top">
</CFIF>

	<TD><CF_GeneralSearchTool_OPTION>&nbsp;</TD>
	<TD NOWRAP ALIGN="center">
		<CFSWITCH EXPRESSION="#Get_Contracts.Contract_Status_Type_IDX#">
			<CFCASE VALUE="1">
				<!--- WIP --->
				<IMG SRC="/images/wip.gif" TITLE="Work in progress.">
			</CFCASE>
			<CFCASE VALUE="2">
				<!--- Ready For Approval --->
				<IMG SRC="/images/rfa.gif" TITLE="Ready For Approval.">
			</CFCASE>
			<CFCASE VALUE="4">
				<!--- Preactive Programs --->
				<IMG SRC="/images/preactive.gif" TITLE="Contract in pre-active state.">
			</CFCASE>
			<CFCASE VALUE="5">
				<!--- Active Programs --->
				<IMG SRC="/images/active.gif" TITLE="Contract currently active.">
			</CFCASE>
			<CFCASE VALUE="6">
				<!--- Expiring --->
				<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(Contract_End_Date, 'm/d/yyyy'))>
				<IMG SRC="/images/expiring.gif" TITLE="Contract expires in #diff# days.">
			</CFCASE>
			<CFCASE VALUE="7">
				<!--- Archived/Expired --->
				<IMG SRC="/images/expired.gif" TITLE="Contract has expired.">
			</CFCASE>																		
		</CFSWITCH>
	
	</TD>
	<TD NOWRAP>
		<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
		
		<!--- <A HREF="/common_files/contracts/contract_view_master.cfm?CID=#CID#" STYLE="FONT-SIZE:12PX;" TITLE="View the details for contract #Contract_Number#">#Contract_Number#</A> --->
		<CF_cryp type="en" string="#CID#" key="#caller.key#">
		<A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#cryp.value#" <!--- ONMOUSEOVER="menuID=2;URLstring='?CID=#cryp.value#&RO=1'" ONMOUSEOUT="menuID=0" ---> STYLE="FONT-SIZE:12PX;" TITLE="View the details for contract #Contract_Number#">#Contract_Number#</A>
		<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>
	</TD>
	<!--- <TD>#operatorname#&nbsp;</TD> --->
	<TD>#Contract_Title#&nbsp;</TD>
	<TD NOWRAP>#dateformat(Contract_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
	<TD NOWRAP>#dateformat(Contract_End_Date, 'm/d/yyyy')#&nbsp;</TD>
	<TD NOWRAP>#numberformat(Contract_Quantity, '_,___,___,___,___')#&nbsp;</TD>
	<TD NOWRAP>#Unit_of_Measure_Desc#&nbsp;</TD>
</TR>
</CFOUTPUT>
</TABLE>
<HR COLOR="Orange" SIZE="2">
<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">

<cf_Next_Previous_FOR_GENERALSEARCHTOOL
	maxpages		=	"25"
	query			=	"Get_Contracts"										
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">">
</DIV>
<HR COLOR="Orange" SIZE="2">
