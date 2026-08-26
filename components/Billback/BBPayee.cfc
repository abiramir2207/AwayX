<cfcomponent extends="components.AjaxCFC.ajax">
 <cfset variables.appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
 <cfset variables.businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cffunction name="init" output="false" returntype="components.Billback.BBPayee">
		<cfreturn this />
</cffunction>

<cffunction name="customerPayeeInfo" access="public" ouput="false" returntype="query">
 <cfargument name="shipTo" type="string" required="true" />
 <cfargument name="bBySingleId" type="boolean" required="false" default="0" />
 <cfargument name="top_rows" required="false" default="0">
 <cfset var qCustomerPayee = "" />


 <cfquery name="qCustomerPayee" datasource="#application.datasource#">
  		SELECT <cfif arguments.top_rows gt 0>
                    TOP #arguments.top_rows#
               <cfelse>
                    DISTINCT
               </cfif>
                    BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, BSA_Foodservice_Customers.Name,
					BSA_Foodservice_Customers.Address_1, BSA_Foodservice_Customers.City, BSA_Foodservice_Customers.State,
					BSA_Foodservice_Customers.ZipCode, BSA_Foodservice_Customers.Country_Code, Distributor_Family.Family_Name, BSA_Foodservice_Customers.Ship_To,
					BSA_Foodservice_Customers.Active_Code,
					BSA_Foodservice_Customers.Deleted,
					<cfif businessSegManager.isEnabled()>
					Business_Segment.Business_Unit_Desc,
					</cfif>
					<cfif NOT appSettings.getDistributorMultiPosition()>
					BSA_Foodservice_Brokers.Broker_Name, Service_Zones.Zone_Name, Service_Regions.Region_Name,
					</cfif>
					Distributor_Buying_Groups.Buying_Group_Name,  BSA_Foodservice_Customers.Shr_Ship_To,  BSA_Foodservice_Customers.Ship_To
		FROM		BSA_Foodservice_Customers
					INNER JOIN	Distributor_Family ON BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
					INNER JOIN	Distributor_Buying_Groups ON BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
					INNER JOIN	Line_Of_Business ON BSA_Foodservice_Customers.Line_Of_Business_ID = Line_Of_Business.Line_Of_Business_ID
					<cfif variables.businessSegManager.isEnabled()>
					Inner Join Business_Segment On Business_Segment.deleted = 0 AND Business_Segment.Business_Segment_ID = BSA_Foodservice_Customers.Business_Segment_ID
					</cfif>
					<cfif appSettings.getDistributorMultiPosition()>
					LEFT JOIN Market_Distributor ON Market_Distributor.Deleted = 0 AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
					LEFT JOIN Service_Markets ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
					</cfif>

					LEFT
					 JOIN	BSA_Foodservice_Brokers ON
					<cfif appSettings.getDistributorMultiPosition()>
					Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
					<cfelse>
					BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
					</cfif>
					LEFT JOIN	Service_Regions ON
					<cfif appSettings.getDistributorMultiPosition()>
					Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
					<cfelse>
					BSA_Foodservice_Brokers.Service_Region_ID = Service_Regions.Service_Region_ID
					</cfif>
					LEFT JOIN	Service_Zones ON Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID
					LEFT JOIN Distributor_Customer_ID	ON Distributor_Customer_ID.Customer_ID = BSA_Foodservice_Customers.Customer_ID
		WHERE		0 = 0


					<!---If limited by distributors they can see
						<cfif appsettings.getDistributorMultiPosition()>
								AND	Service_Markets.Service_Market_ID IN (SELECT Service_Market_ID FROM @Get_Marktets_Below_Me)
						<cfelse>
							AND	BSA_Foodservice_Brokers.Service_Market_ID IN (SELECT Service_Market_ID FROM @Get_Marktets_Below_Me)
						</cfif>
--->
					<!--- Tim Ford - 07/25/2014: Label 44048 - Search By Bill back ID and Copy Bill Back
							Adding this code to handle for the Search By Id field from the Billback Payee Form.
							There are cases when the Ship To and the Shr Ship To are not the same causing records to not return when a ship to is entered.
							If the getExact_List_Matching_On application setting is off and the the bBySingleId arguments is passed then we are going to use
							a like clause against the Shr_Ship_To field.
					--->
					<cfif arguments.bBySingleId and variables.appsettings.getExact_List_Matching_On() IS 0>
						AND (
							dbo.BSA_Foodservice_Customers.Shr_Ship_To like <cfqueryparam value="%#trim(arguments.shipTo)#%" cfsqltype="cf_sql_varchar">
							OR
							dbo.BSA_Foodservice_Customers.Ship_To like <cfqueryparam value="%#trim(arguments.shipTo)#%" cfsqltype="cf_sql_varchar">
							)
					<cfelse>
						AND (
							dbo.BSA_Foodservice_Customers.Shr_Ship_To In (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shipTo#" list="yes" separator="," />)
							OR
							dbo.BSA_Foodservice_Customers.Ship_To In (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shipTo#" list="yes" separator="," />)
							)
					</cfif>

		ORDER BY BSA_Foodservice_Customers.Deleted, BSA_Foodservice_Customers.Active_Code
                </cfquery>
                    <cfreturn  qCustomerPayee />
    </cffunction>
	<!--- Dev Note(78635): For "vendor only billbacks" --->
	<cffunction name="VendorOnlyPayee" access="public" ouput="false" returntype="query">
	 <cfargument name="vendorID" type="string" required="true" />

		<cfquery name="local.qVendorOnlyPayee" datasource="#application.datasource#">
            /* ***********************************************************************************************************
            * this query is only used by payee_form.cfm, it gets call remotely and the frontend needs only one row back
            *********************************************************************************************************** */
			SELECT TOP 1 BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,Vendor_Name As Name,
					Vendor_Master.Address_1,Vendor_Master.City,Vendor_Master.state,
					Vendor_Master.zipcode, RTRIM(Vendor_ID) As Ship_To, RTRIM(Vendor_ID) As Shr_Ship_To
			FROM		Vendor_Master
			INNER JOIN  BSA_Foodservice_Customers
			ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Vendor_Master.Vendor_Master_ID
			WHERE BSA_Foodservice_Customers.Is_Vendor = 1
			AND Vendor_Master.Vendor_id Like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.vendorId#%" />
		 </cfquery>

          <cfreturn  local.qVendorOnlyPayee />
    </cffunction>

	<cffunction name="vendorPayee" access="public" ouput="false" returntype="query">
		<cfargument name="brokerShard" type="string" required="true" />
		<cfset var qGetBrokerShard = "" />

		<cfquery name="qGetBrokerShard" datasource="#application.datasource#">
                /* ***********************************************************************************************************
                * this query is only used by payee_form.cfm, it gets call remotely and the frontend needs only one row back
                *********************************************************************************************************** */
               Select TOP 1 dbo.Service_Zones.Zone_Name AS Zone_Name,
			              dbo.Service_Regions.Region_Name AS Region_name,
			              dbo.BSA_Foodservice_Brokers.*
			   From       dbo.BSA_Foodservice_Brokers INNER JOIN
                          dbo.Service_Regions ON dbo.BSA_Foodservice_Brokers.Service_Region_ID =
						  dbo.Service_Regions.Service_Region_ID INNER JOIN
                          dbo.Service_Zones ON dbo.BSA_Foodservice_Brokers.Service_Zone_ID =
						  dbo.Service_Zones.Service_Zone_ID
		       Where       0 = 0
			   And 		  dbo.BSA_Foodservice_Brokers.DELETED = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
			   And        dbo.BSA_Foodservice_Brokers.Active_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="A" />
		       And        dbo.BSA_Foodservice_Brokers.Broker_Legcy_Shard = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.brokerShard#" />
 		</cfquery>

		 <cfreturn qGetBrokerShard />
	</cffunction>

	<cffunction name="operatorPayee" access="public" ouput="false" returntype="query">
	 <cfargument name="operatorId" type="any" required="true" />
	 <cfset var qReturnOperatorId = "" />
	 <cftry>

		<!---try getting operator by the legacy id first--->
		<cfquery name="qOperatorByLegacyId" datasource="#application.datasource#">
                /* ***********************************************************************************************************
                * this query is only used by payee_form.cfm, it gets call remotely and the frontend needs only one row back
                *********************************************************************************************************** */
                SELECT TOP 1 *
       		FROM		BSA_Operator
			<cfif variables.appsettings.getExact_List_Matching_On() IS 0>
	  		WHERE		Legacy_ID like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.operatorId)#%" />
			<cfelse>
			WHERE		Legacy_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.operatorId)#" />
			</cfif>
			AND 		Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
    	</cfquery>

            <cfif qOperatorByLegacyId.RecordCount>
                <cfreturn qOperatorByLegacyId>

            <!---if we don't get an operator by legacy id, then try to get operator by BSA ID if the id is numeric--->
            <cfelseif isNumeric(arguments.operatorId)>
                <cfquery name="local.qOperatorByBSAId" datasource="#application.datasource#">
                    /* ***********************************************************************************************************
                    * this query is only used by payee_form.cfm, it gets call remotely and the frontend needs only one row back
                    *********************************************************************************************************** */
                    SELECT TOP 1 *
                    FROM		BSA_Operator
                    WHERE		BSA_Operator_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.operatorId#" />
                    AND 		Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
                </cfquery>

                <cfreturn local.qOperatorByBSAId>
            </cfif>

            <cfcatch type="any">
                <cflog file="debug" text="#cfcatch.Detail#" />
            </cfcatch>
        </cftry>

        <cfquery name="local.qOperatorByEmptyQuery" datasource="#application.datasource#">
            SELECT	TOP 1 *
            FROM		BSA_Operator
            WHERE		1 = 2
        </cfquery>

        <cfreturn local.qOperatorByEmptyQuery>
	</cffunction>

	<cffunction name="getVendorById" access="public" ouput="false" returntype="query">
	 <cfargument name="vendorId" type="string" required="true" />

	 <cfset var qVendorInfo = "" />
	 <cfquery name="qVendorInfo" datasource="#application.datasource#">
        /* ***********************************************************************************************************
         * this query is only used by payee_form.cfm, it gets call remotely and the frontend needs only one row back
         *********************************************************************************************************** */
        SELECT 	TOP 1 Vendor_ID,
				Vendor_Name as vendorName,
				Vendor_Master.Address_1 as vendorAddress1,
				Vendor_Master.Address_2 as vendorAddress2,
				Vendor_Master.City as vendorCity,
				Vendor_Master.State as vendorState,
				Vendor_Master.Zipcode as vendorZipCode
	FROM 		Vendor_Master

	WHERE 		Vendor_Master.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
	AND         Vendor_Master.Active_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="A" />
	And         Vendor_Master.Vendor_id Like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.vendorId#%" />

	ORDER BY 	Vendor_ID ASC

     </cfquery>

	<cfreturn qVendorInfo />
	</cffunction>

</cfcomponent>