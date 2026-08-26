<cfcomponent extends="components.base">

	<!--- Search programs --->
	<cffunction name="search" output="true" returntype="query">
	
		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />
		
		<cfset this.search = arguments.search>
		
		<!------ set defaults ----->
		<cfparam name="this.search.agreement_title" 	default="">
		<cfparam name="this.search.agreement_number" 	default="">
					
		<!------ Get application settings ----->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
		
		<!------ Get Program ----->
		<cfquery name="qGetPrograms" datasource="#application.datasource#">
			DECLARE @Positions_Below_Me table
			(
			  Below_User_Positions_ID   int          NOT NULL
			)
			INSERT INTO @Positions_Below_Me(Below_User_Positions_ID)
			SELECT	DISTINCT Below_User_Positions_ID
			FROM	Positions_Below_Me
			WHERE	User_Positions_ID IN (#PreserveSingleQuotes(this.search.User_Positions_ID)#)
			
		
			SELECT	DISTINCT Export_Sales_Agreement.*
					,_Users.Name_First 
					,_Users.Name_Last
					,BSA_Foodservice_Customers.Name
					,
					(
						SELECT 		COUNT(*)
						FROM		Contract_Attachments
						INNER JOIN 	Document_Details ON contract_attachments.Doc_ID = Document_Details.Doc_ID 								
									AND (	(	Public_View = 1
												AND User_Position_ID IN (#preserveSingleQuotes(this.search.GP_Position_List_From_My_Position_Down)#)
											) 						
												OR Public_View = 0	
										)
						WHERE
									Contract_Attachments.Export_Sales_Agreement_ID = Export_Sales_Agreement.Export_Sales_Agreement_ID
									AND
									Contract_Attachments.Deleted = 0
					) AS Contract_Attachments_Count
			FROM	Export_Sales_Agreement					
					LEFT JOIN BSA_Foodservice_Customers 
					ON 
					Export_Sales_Agreement.Export_Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
					LEFT JOIN _Users 
					ON 
					(
					(Export_Sales_Agreement.RFA_User_ID = _Users.User_ID)
					AND
					((Export_Sales_Agreement.RFA_User_ID = _Users.User_ID) AND (Export_Sales_Agreement.Contract_Status_Type_IDX = 2))
					OR
					((Export_Sales_Agreement.Approved_By_User_ID = _Users.User_ID) AND (Export_Sales_Agreement.Contract_Status_Type_IDX >= 4))
					)			
			WHERE	Export_Sales_Agreement.Deleted = 0
					AND	Export_Sales_Agreement.Contract_Status_Type_IDX >= 0				
					<!------ Access permissions start ----->
					----Check Access Permissions
					AND 
					(
						((
						(
							(Creating_User_Position_ID IN  (#this.search.User_Positions_ID#))
						)
						OR
						(
							(
							(1=2)
							<CFIF Len(this.search.GP_Position_List_From_My_Position_Down) GT 0>
							OR 
							Creating_User_Position_ID IN (#this.search.GP_Position_List_From_My_Position_Down#)
							</CFIF>
							)
							AND
							(Export_Sales_Agreement.Contract_Status_Type_IDX >= 2)						
						)
					)
					)
					)
					<!----------Check Access Permissions End ----->
					<!------ Access permissions end ----->
					<cfparam name="this.search.Status" 	default="-1">
					<CFIF  this.search.Status EQ "-1">
						<!------ all status ----->
					<CFELSEIF this.search.Status NEQ "0">
						<!------ particular status ----->
						AND Export_Sales_Agreement.Contract_Status_Type_IDX = #this.search.Status#
					<CFELSE>
						<!------ = 0, means all non-expired ----->
						AND Export_Sales_Agreement.Contract_Status_Type_IDX <> 7
					</CFIF>	
					<CFIF 	Super.variableExist("this.search.Start_Date", "") 
							AND Super.variableExist("this.search.Start_date_Operator", "")
							AND ISDate(this.search.Start_Date) 
							AND (this.search.Start_date_Operator EQ "Greater_Or_Equal" 
								OR this.search.Start_date_Operator EQ "Equal" 
								OR this.search.Start_date_Operator EQ "Less_Or_Equal"
								)>
						AND DateDiff(d, '#this.search.Start_Date#', Export_Start_Date)
						<CFSWITCH expression="#this.search.Start_date_Operator#">
							<CFCASE value="Greater_Or_Equal">
							>=
							</CFCASE>
							<CFCASE value="Equal">
							=
							</CFCASE>
							<CFCASE value="Less_Or_Equal">
							<=
							</CFCASE>
						</CFSWITCH>					
						0
					</CFIF>
					<CFIF 	Super.variableExist("this.search.End_Date", "")
							AND Super.variableExist("this.search.End_date_Operator", "")
							AND ISDate(this.search.End_Date) 
							AND (this.search.End_date_Operator EQ "Greater_Or_Equal" 
								OR this.search.End_date_Operator EQ "Equal" 
								OR this.search.End_date_Operator EQ "Less_Or_Equal"
								)>
						AND DateDiff(d, '#this.search.End_Date#', Export_Sales_Agreement.Export_End_Date)
						<CFSWITCH expression="#this.search.End_date_Operator#">
							<CFCASE value="Greater_Or_Equal">
							>=
							</CFCASE>
							<CFCASE value="Equal">
							=
							</CFCASE>
							<CFCASE value="Less_Or_Equal">
							<=
							</CFCASE>
						</CFSWITCH>					
						0
					</CFIF>
					<CFIF Super.variableExist("this.search.Agreement_Title", "")>
						AND Export_Sales_Agreement.Export_Sales_Agreement_Name LIKE '%#this.search.Agreement_Title#%'
					</CFIF>
					<CFIF Super.variableExist("this.search.Agreement_Number", "")>
						AND Export_Sales_Agreement.Export_Sales_Agreement_Number LIKE '%#this.search.Agreement_Number#%'
					</CFIF>
					
					<!------ search on customer/distributor ----->
					<cfparam name="this.search.Distributor_Name" 	default="">
					<cfparam name="this.search.Distributor_shipto" 	default="">
					<CFIF (Len(this.search.Distributor_Name) GT 0) OR (Len(this.search.Distributor_shipto) GT 0)>
								<CFIF Len(Trim(this.search.Distributor_Name)) GT 0>
								AND BSA_Foodservice_Customers.Name LIKE '%#this.search.Distributor_Name#%'
								</CFIF>
								<CFIF Len(Trim(this.search.Distributor_shipto)) GT 0>
								AND BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#this.search.Distributor_shipto#%'
								</CFIF>				
					</CFIF>
					<!------ search on geography ----->
					<cfparam name="this.search.Export_Destination_Country_ID" 	default="0">
					<CFIF Trim(this.search.Export_Destination_Country_ID) NEQ 0>
						AND Export_Sales_Agreement.Export_Destination_Country = '#this.search.Export_Destination_Country_ID#'
					</CFIF>
					<!--- A user could have multiple positions - For eg: 
							International - Primary
							Asia, Europe, Mexico - Secondary
					We want to know which one does the program belong to, out of the above secondary positions. 
					 --->
					<cfparam name="this.search.Service_Region_ID" 	default="0">
					<CFIF Trim(this.search.Service_Region_ID) NEQ 0>
						AND Creating_User_Position_ID IN  
						(
						SELECT User_Positions_ID
						FROM User_Positions
						WHERE Service_Region_ID = '#this.search.Service_Region_ID#'
						)
					</CFIF>								
			<cfif Super.variableExist("this.search.sql_Sort_By", "")>
			ORDER BY #this.search.sql_Sort_By#
			</cfif>
		</cfquery>
		
		<cfreturn qGetPrograms />
	</cffunction>

	<!--- get the country List --->
	<cffunction name="getCountryList" output="false" returntype="query">
		<cfargument name="Export_Customer_ID" type="numeric" required="false" default="0" />
		<cfargument name="CustomerType" type="numeric" required="false" default="0" />
			<cfquery name="qrygetCountryList" datasource="#application.datasource#">
			  SELECT a.Export_Lookup_Destination_Country_ID, a.Export_Lookup_Destination_Country_Desc
			  FROM Export_Lookup_Destination_Country a
			 <cfif arguments.CustomerType eq 1>
			  INNER JOIN Export_Customer b
			  ON a.Export_Lookup_Destination_Country_ID = b.Export_Customer_Country
			  AND b.Export_Customer_ID = '#arguments.Export_Customer_ID#'
			 <cfelseif arguments.CustomerType eq 2>
			  INNER JOIN Export_Notify_Details c
			  ON a.Export_Lookup_Destination_Country_ID = c.Export_Notify_Country
			  AND c.Export_Customer_ID = '#arguments.Export_Customer_ID#'
			 </cfif>
			 ORDER BY a.Export_Lookup_Destination_Country_Desc
			</cfquery>

		<cfreturn qrygetCountryList />
	</cffunction>
	
	<!--- get the customer details --->
	<cffunction name="getCustomerDetails" output="false" returntype="query">
		<cfargument name="customer_id" type="string" required="true" />
			<cfquery name="qrygetCustomer" datasource="#application.datasource#">
			 SELECT ec.*,ed.*,ecd.*,ebca.*
			 FROM Export_Customer ec
			 LEFT JOIN Export_Notify_Details ed
			 ON ec.Export_Customer_ID = ed.Export_Customer_ID
			 LEFT JOIN Export_Customer_Details ecd
			 ON ec.Export_Customer_ID = ecd.Export_Customer_ID
			 LEFT JOIN Export_Border_Crossing_Agent ebca
			 ON ec.Export_Customer_ID = ebca.Export_Customer_ID
			 WHERE ec.Export_Customer_ID = '#arguments.customer_id#'
			</cfquery>

		<cfreturn qrygetCustomer />
	</cffunction>

	<!--- Change the program into Work in Progress --->
	<cffunction name="MakeWIP" output="true" returntype="void">	
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
		<cfargument name="userId" required="true" type="string" />
		
		<cfquery name="qMakeWIP" datasource="#application.datasource#">	
			UPDATE 	Export_Sales_Agreement
			SET 	RFA_Approved = 0,
					RFA_Approved_Date = NULL,
					RFA_User_ID = NULL,
					Contract_Status_Type_IDX = 1
			WHERE 	Export_Sales_Agreement_ID = <cfqueryparam value="#arguments.Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">			
		</cfquery>
				
	</cffunction>

	<!--- Change the program into RFA --->
	<cffunction name="MakeRFA" output="true" returntype="void">	
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
		<cfargument name="userId" required="true" type="string" />
		
		<cfquery name="qMakeRFA" datasource="#application.datasource#">	
			UPDATE 	Export_Sales_Agreement
			SET 	RFA_Approved = 1,
					RFA_Approved_Date = getdate(),
					RFA_User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
					Contract_Status_Type_IDX = 2
			WHERE 	Export_Sales_Agreement_ID = <cfqueryparam value="#arguments.Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">			
		</cfquery>				
	</cffunction>

	<!--- Approve the program --->
	<cffunction name="ApproveAgreement" output="false" returntype="void">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
		<cfargument name="userId" required="true" type="string" />
		
		<cfquery NAME="getAgreementStartDate" datasource="#application.datasource#">
			SELECT 	Export_Start_Date
			FROM Export_Sales_Agreement
			WHERE Export_Sales_Agreement_ID = <cfqueryparam value="#arguments.Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfif DateDiff("d", now(), getAgreementStartDate.Export_Start_Date) lte 0>
			<cfset Status_ID = 5>
		<cfelse>
			<cfset Status_ID = 4>
		</cfif>

		<cfquery NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE 	Export_Sales_Agreement
			SET 	Approval_Date = getdate(), 
					Approved = 1, 
					Approved_By_User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
					Contract_Status_Type_IDX = '#Status_ID#'
			WHERE 	Export_Sales_Agreement_ID = <cfqueryparam value="#arguments.Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	
		<!------ Update Contract Status. This is in case the program is approved at the program start date or later ----->
		<cfquery name="UpdateContarctStatus" datasource="#application.datasource#">
			EXEC Check_Export_Sales_Agreement_Status #arguments.Export_Sales_Agreement_ID#
		</cfquery>	
	</cffunction>

	<!--- get the profile of the current user --->	
	<cffunction name="getProfile" output="false" returntype="query">	
		<cfargument name="userId" required="true" type="string" />
		
		<cfset useLakebaseForqgetProfile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users") AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForqgetProfile>
	<cftry>
		<cfset qgetProfile = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("_users", {
				"user_id" = "eq.#arguments.userId#",
				"select" = "profiles_id"
			}, "profiles_id", "profiles", "profiles_id", "profiles_desc"), "profiles_id,profiles_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetProfile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetProfile>
<cfquery name="qgetProfile" datasource="#application.datasource#">	
			SELECT u.Profiles_ID, p.Profiles_Desc
			FROM _Users u INNER JOIN Profiles p
			ON u.Profiles_ID =  p.Profiles_ID
			WHERE u.User_ID = '#arguments.userId#'
		</cfquery>
</cfif>	
	
		<cfreturn qgetProfile />
	</cffunction>

	<!--- get the users with a particular profile (For eg: One can pass "Credit Manager" argument, to get a list of users
		  with that profile) --->	
	<cffunction name="getUsers" output="false" returntype="query">	
		<cfargument name="profileType" required="true" type="string" default="" />
		
		<cfquery name="qgetUsers" datasource="#application.datasource#">
			SELECT u.User_ID,u.User_Email
			FROM _Users u INNER JOIN Profiles p
			ON u.Profiles_ID =  p.Profiles_ID
			WHERE p.Profiles_Desc ='#arguments.profileType#'
			AND u.Deleted = 0
		</cfquery>	
	
		<cfreturn qgetUsers />
	</cffunction>


	<!--- Lock/Unlock Program --->
	<cffunction name="setLockStatus" output="false" returntype="numeric">
		<cfargument name="Export_Sales_Agreement_ID" required="true" type="numeric" />
		<cfargument name="lockBit" required="true" type="numeric" />
		<cfargument name="userId" required="false" type="string" default="" />
		
		<cfset returnValue = 0>
		
		<cfif arguments.lockBit>
			
			<cfset canLock = false>
			
			<!------ check any other person has locked this program within the session timeout time ----->			
			<cfquery name="qCheckLockStatus" datasource="#application.datasource#">
				
				SELECT	esa.Sales_Agreement_Is_Locked, 
						esa.Sales_Agreement_Locked_By_User_ID,
						st.Session_ID, 
						(CAST(DateDiff(s, st.Session_Date_Time_Stamp, GetDate()) AS FLOAT)/(24.00*60.00*60.00)) AS User_Session,
						gs.Session_Expiration_Length
				FROM	Export_Sales_Agreement esa
						LEFT JOIN Session_Tracker st
						ON 
						st.Session_User_ID = esa.Sales_Agreement_Locked_By_User_ID
						INNER JOIN General_Settings gs
						ON 1=1
				WHERE
						esa.Export_Sales_Agreement_ID = <cfqueryparam value="#arguments.Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">
						AND esa.Deleted = 0						
			</cfquery>
			
			<cfif qCheckLockStatus.recordCount>
			
				<cfif 
						qCheckLockStatus.Sales_Agreement_Is_Locked EQ 0
						OR
						(
							qCheckLockStatus.Sales_Agreement_Is_Locked EQ 1
							AND
							(
								qCheckLockStatus.Session_ID EQ ""
								OR
								qCheckLockStatus.User_Session GT qCheckLockStatus.Session_Expiration_Length
								OR
								qCheckLockStatus.Sales_Agreement_Locked_By_User_ID EQ arguments.userId
							)
						)>
				
					<cfset canLock = true>
					
				<cfelse>
				
					<cfset returnValue = 3><!------ program is locked by someone else ----->
				
				</cfif>
				
			<cfelse>
			
				<cfset returnValue = 2><!------ program not found ----->
			
			</cfif>
			
			<cfif canLock>
				<!------ Unlock other programs locked by this user ----->
				<cfquery name="qSetLockStatusOtherPrograms" datasource="#application.datasource#">
					
					UPDATE 	Export_Sales_Agreement
					Set 	Sales_Agreement_Is_Locked = 0, 
							Sales_Agreement_Locked_By_User_ID = NULL,
							Sales_Agreement_Lock_Date = NULL
					WHERE 
							Export_Sales_Agreement_ID <> <cfqueryparam value="#arguments.Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">
							AND
							Deleted = 0
							AND
							Sales_Agreement_Is_Locked = 1
							AND
							Sales_Agreement_Locked_By_User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
					
				</cfquery>
				
				<!------ Lock it, if it is not locked ----->
				<cfquery name="qSetLockStatus1" datasource="#application.datasource#">
					
					UPDATE 	Export_Sales_Agreement
					Set 	Sales_Agreement_Is_Locked = 1, 
							Sales_Agreement_Locked_By_User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
							Sales_Agreement_Lock_Date = GetDate()
					WHERE 
							Export_Sales_Agreement_ID = <cfqueryparam value="#arguments.Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">
							AND
							Deleted = 0
							AND
							Sales_Agreement_Is_Locked = 0
													
				</cfquery>
				
				<cfset returnValue = 1>
				
			</cfif>
			
		<cfelse>
		
			<!------ Un Lock it, if it already locked ----->
			
			<cfquery name="qSetLockStatus0" datasource="#application.datasource#">
				
				UPDATE 	Export_Sales_Agreement
				Set 	Sales_Agreement_Is_Locked = 0, 
						Sales_Agreement_Locked_By_User_ID = NULL,
						Sales_Agreement_Lock_Date = NULL
				WHERE 
						Export_Sales_Agreement_ID = <cfqueryparam value="#arguments.Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">
						AND
						Sales_Agreement_Is_Locked = 1
						
			</cfquery>
			
			<cfset returnValue = 1>
			
		</cfif>
		
		<cfreturn returnValue />		
	</cffunction>

	<!--- Delete the Program --->
	<cffunction name="deleteSalesAgreement" output="true" returntype="boolean">
		<cfargument name="Export_Sales_Agreement_ID" required="true" type="numeric" />
		<cfargument name="lockedByUserId" required="true" type="string" />
		<cfargument name="userId" required="true" type="string" />
		
		<cfset returnValue = false>
		
		<cftransaction action="BEGIN" isolation="READ_COMMITTED">
		
			<cftry>
			
				<cfquery name="qDeleteSalesAgreement" datasource="#application.datasource#">
				
					SET NOCOUNT ON
				
					UPDATE	Export_Sales_Agreement
					SET		Deleted = 1,
							Deleted_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
							Deleted_Date = GetDate()
					WHERE	Export_Sales_Agreement_ID = <cfqueryparam value="#arguments.Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">
							AND Sales_Agreement_Is_Locked = 1
							AND Sales_Agreement_Locked_By_User_ID = <cfqueryparam value="#arguments.lockedByUserId#" cfsqltype="CF_SQL_VARCHAR">
							AND Deleted = 0

					SELECT Rows_Count = @@ROWCOUNT
					SET NOCOUNT OFF		
				</cfquery>
				
				<cfif qDeleteSalesAgreement.Rows_Count>
				
					<cfset returnValue = true>
					
				</cfif>		
				
				<cftransaction action="COMMIT">
				
				<cfcatch>
				
					<cftransaction action="ROLLBACK">
					<cfrethrow>
				
				</cfcatch>
			
			</cftry>
		
		</cftransaction>
		
		<cfreturn returnValue />	
	</cffunction>

	<!--- Standard Costs --->
	<cffunction name="getStandardCosts" output="false" returntype="query">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
			<cfset useLakebaseForqrygetStandardCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_cost") AND application.oLakebase.isTableMigrated("export_lookup_costs")>
<cfif useLakebaseForqrygetStandardCosts>
	<cftry>
		<cfset qrygetStandardCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("export_cost", {
				"export_sales_agreement_id" = "eq.#arguments.Export_Sales_Agreement_ID#",
				"export_additional_cost" = "neq.0",
				"order" = "show_order_sequence.asc",
				"select" = "export_additional_cost,export_cost_desc"
			}, "export_cost_desc", "export_lookup_costs", "export_lookup_cost_id", "export_lookup_cost_desc"), "export_additional_cost,export_lookup_cost_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetStandardCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetStandardCosts>
<cfquery name="qrygetStandardCosts" datasource="#application.datasource#">
			 SELECT elc.Export_Lookup_Cost_Desc,ec.Export_Additional_Cost
			 FROM Export_Cost ec INNER JOIN Export_lookup_Costs elc
			 ON elc.Export_Lookup_Cost_ID = ec.Export_Cost_Desc
			 WHERE ec.Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
			 AND Export_Additional_Cost != 0
			 ORDER BY ec.Show_Order_Sequence
			</cfquery>
</cfif>

		<cfreturn qrygetStandardCosts />
	</cffunction>

		<!--- Standard Costs (Lookup) --->
	<cffunction name="getLookupStandardCosts" output="false" returntype="query">
			<cfset useLakebaseForqrygetLookupStandardCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_costs")>
<cfif useLakebaseForqrygetLookupStandardCosts>
	<cftry>
		<cfset qrygetLookupStandardCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_costs", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetLookupStandardCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetLookupStandardCosts>
<cfquery name="qrygetLookupStandardCosts" datasource="#application.datasource#">
			 SELECT *
			 FROM Export_lookup_Costs
			</cfquery>
</cfif>

		<cfreturn qrygetLookupStandardCosts />
	</cffunction>

		<!--- Terms of Sale (Lookup) --->
	<cffunction name="getLookupTermsOfSale" output="false" returntype="query">
			<cfset useLakebaseForqrygetLookupTermsOfSale = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_terms_of_sale") AND application.oLakebase.isTableMigrated("export_lookup_named_place_type")>
<cfif useLakebaseForqrygetLookupTermsOfSale>
	<cftry>
		<cfset qrygetLookupTermsOfSale = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("export_lookup_terms_of_sale", {
				"select" = "*,export_lookup_named_place_type_id"
			}, "export_lookup_named_place_type_id", "export_lookup_named_place_type", "export_lookup_named_place_type_id", "export_lookup_named_place_type_desc"), "*,export_lookup_named_place_type_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetLookupTermsOfSale = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetLookupTermsOfSale>
<cfquery name="qrygetLookupTermsOfSale" datasource="#application.datasource#">
			 SELECT eltos.*,elnpt.Export_Lookup_Named_Place_Type_Desc
			 FROM Export_Lookup_Terms_of_Sale eltos
			 LEFT JOIN Export_Lookup_Named_Place_Type elnpt
			 ON eltos.Export_Lookup_Named_Place_Type_ID = elnpt.Export_Lookup_Named_Place_Type_ID
			</cfquery>
</cfif>

		<cfreturn qrygetLookupTermsOfSale />
	</cffunction>

		<!--- Named Place Type (Lookup) --->
	<cffunction name="getLookupNamedPlaceType" output="false" returntype="query">
			<cfset useLakebaseForqrygetLookupNamedPlaceType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_named_place_type")>
<cfif useLakebaseForqrygetLookupNamedPlaceType>
	<cftry>
		<cfset qrygetLookupNamedPlaceType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_named_place_type", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetLookupNamedPlaceType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetLookupNamedPlaceType>
<cfquery name="qrygetLookupNamedPlaceType" datasource="#application.datasource#">
			 SELECT *
			 FROM Export_Lookup_Named_Place_Type
			</cfquery>
</cfif>

		<cfreturn qrygetLookupNamedPlaceType />
	</cffunction>

		<!--- Pallet Type (Lookup) --->
	<cffunction name="getLookupPalletType" output="false" returntype="query">
			<cfset useLakebaseForqrygetLookupPalletType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_pallet_type")>
<cfif useLakebaseForqrygetLookupPalletType>
	<cftry>
		<cfset qrygetLookupPalletType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_pallet_type", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetLookupPalletType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetLookupPalletType>
<cfquery name="qrygetLookupPalletType" datasource="#application.datasource#">
			 SELECT *
			 FROM Export_Lookup_Pallet_Type
			</cfquery>
</cfif>

		<cfreturn qrygetLookupPalletType />
	</cffunction>

		<!--- Destination Ports (Lookup) --->
	<cffunction name="getLookupDestinationPorts" output="false" returntype="query">
			<cfset useLakebaseForqrygetLookupDestinationPorts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_destination_ports")>
<cfif useLakebaseForqrygetLookupDestinationPorts>
	<cftry>
		<cfset qrygetLookupDestinationPorts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_destination_ports", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetLookupDestinationPorts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetLookupDestinationPorts>
<cfquery name="qrygetLookupDestinationPorts" datasource="#application.datasource#">
			 SELECT *
			 FROM Export_Lookup_Destination_Ports
			</cfquery>
</cfif>

		<cfreturn qrygetLookupDestinationPorts />
	</cffunction>

		<!--- get the list of countries that are not an option in the select box provided in the Export Project.
			  The length of a few countries was too long. Therefore, I have shortened it to 30 characters. --->
	<cffunction name="getUnAddedCountries" output="no" returntype="query">	
		<cfquery name="qrygetUnAddedCountries" datasource="#Application.Datasource#">
		SELECT table1.Country_Name,table1.Country_Code  
		FROM _Country table1
		WHERE NOT EXISTS
		(
			SELECT table2.Export_Lookup_Destination_Country_Desc,table2.Country_Code  
			FROM Export_Lookup_Destination_Country table2
			WHERE table1.Country_Code = .table2.Country_Code
		)
		AND LEN(table1.Country_Name) ! > 30
		ORDER BY table1.Country_Name
		</cfquery>

		<cfreturn qrygetUnAddedCountries>
	</cffunction>

		<!--- Relocation Costs (Lookup) --->
	<cffunction name="getLookupRelocationCost" output="false" returntype="query">
			<cfset useLakebaseForqrygetLookupRelocationCost = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_origin_relocation")>
<cfif useLakebaseForqrygetLookupRelocationCost>
	<cftry>
		<cfset qrygetLookupRelocationCost = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_origin_relocation", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetLookupRelocationCost = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetLookupRelocationCost>
<cfquery name="qrygetLookupRelocationCost" datasource="#application.datasource#">
			 SELECT *
			 FROM Export_Lookup_Origin_Relocation
			</cfquery>
</cfif>

		<cfreturn qrygetLookupRelocationCost />
	</cffunction>

	<!--- Freight Charges (Lookup) --->
	<cffunction name="getLookupFreightCharges" output="false" returntype="query">
			<cfquery name="qrygetLookupFreightCharges" datasource="#application.datasource#">
			 SELECT eol.Export_Lookup_Origin_Code,eldp.Export_Lookup_Destination_Port_Desc,eldc.Export_Lookup_Destination_Country_Desc,elf.Export_Lookup_Freight_Cost
			 FROM Export_Lookup_Freight elf INNER JOIN Export_Lookup_Origin eol 
			 ON elf.Export_Lookup_Origin_ID = eol.Export_Lookup_Origin_ID
			 INNER JOIN Export_Lookup_Destination_Ports eldp
			 ON elf.Export_Lookup_Destination_Port_ID = eldp.Export_Lookup_Destination_Port_ID
			 INNER JOIN Export_Lookup_Destination_Country eldc
			 ON eldp.Export_Lookup_Destination_Country_ID = eldc.Export_Lookup_Destination_Country_ID
			 ORDER BY eldc.Export_Lookup_Destination_Country_ID
			</cfquery>

		<cfreturn qrygetLookupFreightCharges />
	</cffunction>

	<!--- Additional Freight Charges --->
	<cffunction name="getFreightCosts" output="false" returntype="query">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
			<cfset useLakebaseForqrygetFreightCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForqrygetFreightCosts>
	<cftry>
		<cfset qrygetFreightCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_sales_agreement", {
				"export_sales_agreement_id" = "eq.#arguments.Export_Sales_Agreement_ID#",
				"select" = "export_additional_freight_cost,export_additional_inland_fuel_surcharge,export_additional_ocean_fuel_surcharge"
			}), "export_additional_freight_cost,export_additional_inland_fuel_surcharge,export_additional_ocean_fuel_surcharge"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetFreightCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetFreightCosts>
<cfquery name="qrygetFreightCosts" datasource="#application.datasource#">
			 SELECT Export_Additional_Freight_Cost,Export_Additional_Inland_Fuel_Surcharge,Export_Additional_Ocean_Fuel_Surcharge
			 FROM Export_Sales_Agreement
	         WHERE Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
			</cfquery>
</cfif>

		<cfreturn qrygetFreightCosts />
	</cffunction>

	<!--- Misc Costs --->
	<cffunction name="getMiscCosts" output="false" returntype="query">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
			<cfset useLakebaseForqrygetMiscCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_misc_cost")>
<cfif useLakebaseForqrygetMiscCosts>
	<cftry>
		<cfset qrygetMiscCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_misc_cost", {
				"export_sales_agreement_id" = "eq.#arguments.Export_Sales_Agreement_ID#",
				"export_misc_cost" = "neq.0",
				"order" = "show_order_sequence.asc",
				"select" = "export_misc_cost_id,export_misc_cost_desc,export_misc_cost,show_order_sequence"
			}), "export_misc_cost_id,export_misc_cost_desc,export_misc_cost,show_order_sequence"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetMiscCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetMiscCosts>
<cfquery name="qrygetMiscCosts" datasource="#application.datasource#">
			SELECT Export_Misc_Cost_ID,Export_Misc_Cost_Desc,Export_Misc_Cost,Show_Order_Sequence
			 FROM Export_Misc_Cost
			 WHERE Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'	
			 AND Export_Misc_Cost != 0
			 ORDER BY Show_Order_Sequence
			</cfquery>
</cfif>

		<cfreturn qrygetMiscCosts />
	</cffunction>

		<!--- Pallet Type for Customer --->
	<cffunction name="getCustomerPalletType" output="false" returntype="query">
		<cfargument name="Export_Customer_ID" type="string" required="yes">
			<cfset useLakebaseForqrygetCustomerPalletType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_customer_details") AND application.oLakebase.isTableMigrated("export_lookup_pallet_type")>
<cfif useLakebaseForqrygetCustomerPalletType>
	<cftry>
		<cfset qrygetCustomerPalletType = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("export_customer_details", {
				"export_customer_id" = "eq.#arguments.Export_Customer_ID#",
				"select" = "export_customer_pallet_type"
			}, "export_customer_pallet_type", "export_lookup_pallet_type", "export_lookup_pallet_type_id", "export_lookup_pallet_type_desc"), "export_lookup_pallet_type_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetCustomerPalletType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetCustomerPalletType>
<cfquery name="qrygetCustomerPalletType" datasource="#application.datasource#">
			 SELECT b.Export_Lookup_Pallet_Type_Desc
			 FROM Export_Customer_Details a INNER JOIN Export_Lookup_Pallet_Type b
			 ON a.Export_Customer_Pallet_Type = b.Export_Lookup_Pallet_Type_ID
			 WHERE a.Export_Customer_ID = '#arguments.Export_Customer_ID#'
			</cfquery>
</cfif>
			
		<cfreturn qrygetCustomerPalletType />
	</cffunction>

		<!--- Count the BorderCrossingAgent Records --->
	<cffunction name="getBorderCrossingAgentRecords" output="false" returntype="query">
		<cfargument name="Export_Customer_ID" type="string" required="yes">
			<cfquery name="qrygetBorderCrossingAgentRecords" datasource="#application.datasource#">
			 SELECT Count(*) As NumberOfRecords
			 FROM Export_Border_Crossing_Agent
			 WHERE Export_Customer_id = '#Export_Customer_ID#'
			</cfquery>

	   <cfreturn qrygetBorderCrossingAgentRecords />
	</cffunction>

	
		<!--- Count the Notify Customer Records --->
	<cffunction name="getNotifyCustomerRecords" output="false" returntype="query">
		<cfargument name="Export_Customer_ID" type="string" required="yes">
			<cfquery name="qrygetNotifyCustomerRecords" datasource="#application.datasource#">
			 SELECT Count(*) As NumberOfRecords
			 FROM Export_Notify_Details
			 WHERE Export_Customer_id = '#Export_Customer_ID#'
			</cfquery>

	   <cfreturn qrygetNotifyCustomerRecords />
	</cffunction>

		<!--- get Notes --->
	<cffunction name="getNotes" output="false" returntype="query">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
			<cfset useLakebaseForqrygetNotes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForqrygetNotes>
	<cftry>
		<cfset qrygetNotes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_sales_agreement", {
				"export_sales_agreement_id" = "eq.#arguments.Export_Sales_Agreement_ID#",
				"select" = "export_special_conditions,export_internal_notes"
			}), "export_special_conditions,export_internal_notes"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetNotes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetNotes>
<cfquery name="qrygetNotes" datasource="#application.datasource#">
			 SELECT Export_Special_Conditions,Export_Internal_Notes
		     FROM Export_Sales_Agreement
		     WHERE Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'	
			</cfquery>
</cfif>

		<cfreturn qrygetNotes />
	</cffunction>
	
	<cffunction name="Att_display" access="public" returntype="query" output="false">
	
		<cfargument name="Sales_Agreement_ID" type="string" required="true" />
		<cfargument name="Access_Position_List" type="string" required="true" />
			
		<CFQUERY NAME = "qAtt_display" DATASOURCE="#Application.Datasource#">
	
			SELECT * 
			FROM 		Document_Details 
			INNER JOIN 	contract_attachments ON Document_Details.Doc_ID = contract_attachments.Doc_ID 
			
			WHERE 		contract_attachments.Export_Sales_Agreement_ID = #arguments.Sales_Agreement_ID# 
						AND contract_attachments.Deleted = 0				
						AND (	(	Public_View = 1
									AND User_Position_ID IN (#preserveSingleQuotes(arguments.Access_Position_List)#)
								) 						
										OR Public_View = 0								
							)
						
		</CFQUERY>
	
		<cfreturn qAtt_display />
	
	</cffunction>
</cfcomponent>