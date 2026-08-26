<cfif ComponentUOM IS NOT 4>
			<cfset HasSeperateVolume = 0>

			<cfset TotalVolumePounds = 0>
			<cfset TotalVolumeCases = 0>
			
			<cfset UseThisComponentForVolume = ComponentID>
		<!---Do this for normal--->
		<cfif ComponentType IS 1>				
		
			<cfquery name="DoesThisCompHaveAChild" datasource="#application.datasource#">
			SELECT Program_Growth_Component_ID AS Volume_Component_ID
			FROM Program_Growth_Components
			WHERE Parent_ID = '#ComponentID#'
			AND Deleted = 0
			</cfquery>			
		
			<cfif DoesThisCompHaveAChild.Recordcount GT 0>
			
				<cfset HasSeperateVolume = 1>
			
				<!---Get rate and lump sums--->
				
					<cfset UseThisComponentForVolume = DoesThisCompHaveAChild.Volume_Component_ID>
					
					<cfquery name="GetVolumeItems" datasource="#application.datasource#">
					SELECT 	BSA_Foodservice_Items_Master_ID, 
							Product_Group_Level_ID,
							Product_Group_ID,
							Program_Growth_Component_Product_Data_ID
					FROM 	GetItemsForGrowthComponent
					WHERE 	
							Program_Growth_Component_ID = '#UseThisComponentForVolume#'
					</cfquery>
									
					<!------ Find if any products is 'All products' ----->
					<cfquery name="qCheckGroupProducts" dbtype="query">
						SELECT		BSA_Foodservice_Items_Master_ID, Product_Group_ID, Program_Growth_Component_Product_Data_ID
						FROM		GetVolumeItems
						WHERE
									Product_Group_Level_ID = 1
					</cfquery>
					
					<cfif qCheckGroupProducts.recordCount>
					
						<cfset Product_Group_ID = qCheckGroupProducts.Product_Group_ID />
						<cfset ProductID = qCheckGroupProducts.BSA_Foodservice_Items_Master_ID />
						<cfset Original_Program_Growth_Component_Product_Data_ID = qCheckGroupProducts.Program_Growth_Component_Product_Data_ID />
						<!------ Go and get all products bought by this distributor during the concerned dates ----->
						<cfquery name="GetVolumeItems" datasource="#application.datasource#">
							SELECT		DISTINCT
										Invoice_Detail.BSA_Foodservice_Items_Master_ID,
										BSA_Foodservice_Items_Master.Description as ItemName,
										'#ProductID#' As RateProductID,
										'#Original_Program_Growth_Component_Product_Data_ID#' As Program_Growth_Component_Product_Data_ID
							FROM		Invoice_Header
										INNER JOIN Invoice_Detail
										ON
										Invoice_Detail.Deleted = 0
										AND
										Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
										INNER JOIN BSA_Foodservice_Items_Master
										ON
										BSA_Foodservice_Items_Master.Deleted = 0
										AND
										BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Invoice_Detail.BSA_Foodservice_Items_Master_ID
							WHERE
										Invoice_Header.Deleted = 0
										AND
										Invoice_Header.BSA_Foodservice_Customers_ID = '#DistributorNumber#'
										AND
										<cfif BB_Tolerance_TET IS 1>
										(	Invoice_Header.Invoice_Date >= #createODBCDate(StartDate)#
											AND
											Invoice_Header.Invoice_Date <= #createODBCDate(EndDate)#
										)
										<cfelse>
										(	Invoice_Header.Ship_Date >= #createODBCDate(StartDate)#
											AND
											Invoice_Header.Ship_Date <= #createODBCDate(EndDate)#
										)
									</cfif>
						</cfquery>
					<!---It's group--->
					</cfif>
			<!---It's seperate volume--->		
			
				<cfset QueryForLoop = "GetVolumeItems">
			
			<cfelse>
				<cfset QueryForLoop = "GetItemsForComponent">
			</cfif>
			
			<cfloop query="#QueryForLoop#">		
			
				<!---Get invoices for those items, that also match distributor and date range--->
				<cfquery name="GetInvoices" datasource="#application.datasource#">
				SELECT Pounds_Invoiced, Cases_Invoiced
				FROM GetInvoicesForLedger
				WHERE BSA_Foodservice_Items_Master_ID = '#evaluate("#QueryForLoop#.BSA_Foodservice_Items_Master_ID")#'
				AND BSA_Foodservice_Customers_ID = '#DistributorNumber#' 
				AND 
				<cfif BB_Tolerance_TET IS 1>
				(	Invoice_Date >= '#dateformat(StartDate)#'
					AND
					Invoice_Date <= '#dateformat(EndDate)#'
				)
				<cfelse>
				(	Ship_Date >= '#dateformat(StartDate)#'
					AND
					Ship_Date <= '#dateformat(EndDate)#'
				)
				</cfif>
				</cfquery>
				
			<!--- 	<cfdump var="#GetInvoices#"> --->
				
				<cfoutput query="GetInvoices">
					<cfset TotalVolumePounds = TotalVolumePounds + Pounds_Invoiced>
					<cfset TotalVolumeCases = TotalVolumeCases + Cases_Invoiced>
					<cfif UOM IS 1>
						<cfset TotalVolume = TotalVolume + Cases_Invoiced>
					<cfelse>
						<cfset TotalVolume = TotalVolume + Pounds_Invoiced>
					</cfif>
					<!---  Cases Invoiced: #Cases_Invoiced#<br>
					Pounds Invoiced: #Pounds_Invoiced#<br>
					Total Volume: #TotalVolume#<br>
				<hr>  --->
				</cfoutput>
				
				<!---End for each item--->
			<!---Get Items for Component--->
			</cfloop>

			<cfoutput>
					<td valign="top" align="right" colspan="3">#NumberFormat(TotalVolume, '___,___,___,___')# <cfif UOM IS 1>Cases<cfelse>Pounds</cfif></td></tr>
			</cfoutput>
			
			<cfif ComponentUOM IS 3>	
<!--- 	<hr color="Red" width="100%"> --->

	<!---
	Need to pass in:
	*Component_ID (to get all items)
	*Distributor_ID (ditto)
	*GetTier.Range_End
	*GetTier.Range_Start
	*Program_Span
	*Program Start Date
--->
<cfoutput>
<!--- 		Distributor ID: #DistributorNumber#<br>
		Component ID: #Component_ID#<br>
		Range End %: #GetTier.Range_End#<br>
		Range Start %: #GetTier.Range_Start#<Br>
		Program Span: #ProgramSpan#<br>
		Program Start Date: #StartDate#<br>
		Trade Eligibility Trigger: #BB_Tolerance_TET#<br> --->


		<!---Should happen outside of loop--->

		<!---The sample for comparison depends on various settings--->
		
		<!---If comparison_type = 1 then the same period for the previous year--->
		
		<cfif GetComponents.Comparison_Type IS 1>
			<!--- Comparison Type is 1<br> --->
			<cfset Sample_Start_Date = request.app_general_functions.specialDateAdd("yyyy", -1, StartDate)>
			<cfset Sample_End_Date = request.app_general_functions.specialDateAdd("yyyy", -1, EndDate)>
			<cfset Days_in_Sample = DateDiff("d", Sample_Start_Date, Sample_End_Date)>
		<cfelseif GetComponents.Comparison_Type IS 2>
			<!--- Comparison Type is 2<br> --->
			<cfset SamplePeriod = GetComponents.Sample_Period * -1>
			<!--- Sample Period: #Sample_Period#<BR> --->			
			<cfset Sample_End_Date = request.app_general_functions.specialDateAdd("y", -1, StartDate)>
			<cfset Sample_Start_Date = request.app_general_functions.specialDateAdd("y", SamplePeriod, Sample_End_Date)>
			<cfset Days_in_Sample = DateDiff("d", Sample_Start_Date, Sample_End_Date)>
		<cfelse>
		<!--- Comparison Type is NOT 1 or 2<br> --->
		<cfset Sample_End_Date = request.app_general_functions.specialDateAdd("y", -1, StartDate)>
		<cfset Sample_Start_Date = request.app_general_functions.specialDateAdd("yyyy", -1, Sample_End_Date)>
		<cfset Days_in_Sample = DateDiff("d", Sample_Start_Date, Sample_End_Date)>
		</cfif>
		
		<!--- Sample End Date: #Sample_End_Date#<br>
		Sample Start Date: #Sample_Start_Date#<br>
		Days in Sample: #Days_In_Sample#<br>  --->
		<!---Get all items in component--->
		
		<cfquery name="YearAgoVolume" datasource="#application.datasource#">
		SELECT ISNULL(sum(cast(Invoice_Detail.Pounds_Invoiced as float)), 0) As Year_Ago_Pounds, ISNULL(sum(cast(Invoice_Detail.Cases_Invoiced as float)), 0) as Year_Ago_Cases
		FROM Invoice_Detail
		INNER JOIN Invoice_Header
		ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
		
		WHERE Invoice_Header.Deleted = 0
		AND Invoice_Detail.Deleted = 0
		<!--- AND Invoice_Header.Order_Status = 'I' --->
		<cfif BB_Tolerance_TET IS 1>
		AND Invoice_Header.Invoice_Date >= #Sample_Start_Date#
		AND Invoice_Header.Invoice_Date <= #Sample_End_Date#
		<cfelse>
		AND Invoice_Header.Ship_Date >= #Sample_Start_Date#
		AND Invoice_Header.Ship_Date <= #Sample_End_Date#
		</cfif>
		AND Invoice_Header.BSA_Foodservice_Customers_ID = '#DistributorNumber#'
		AND Invoice_Detail.BSA_Foodservice_Items_Master_ID IN 
			(SELECT Contract_Products.BSA_Foodservice_Items_Master_ID FROM Program_Growth_Component_Product_Data 
			INNER JOIN Contract_Products
			ON
			Contract_Products.Contract_Products_ID =Program_Growth_Component_Product_Data.Contract_Products_ID
			WHERE Program_Growth_Component_ID = '#UseThisComponentForVolume#')
		</cfquery> 
		
		<cfset Year_Ago_Pounds = YearAgoVolume.Year_Ago_Pounds>
		<cfset Year_Ago_Cases = YearAgoVolume.Year_Ago_Cases>
		
		<cfif UOM IS 1>
			<cfset Year_Ago_Volume = Year_Ago_Cases>
		<cfelse>
			<cfset Year_Ago_Volume = Year_Ago_Pounds>
		</cfif>

		<!---Figure out what their total volume should have been--->
		<cfset One_Day_Volume = Year_Ago_Volume / Days_In_Sample>
		<!---  One Day Volume: #One_Day_Volume#<br> --->

		<cfset Same_Period_Volume = One_Day_Volume * ProgramSpan>
	<!--- 	Same Period Volume: #Same_Period_Volume# = #One_Day_Volume# * #ProgramSpan#<br> ---></cfoutput>
	
		<cfset Same_Period_Volume_Percent = Same_Period_Volume / 100>
			
			<cfquery name="CalculateTiers" datasource="#application.datasource#">
			SELECT Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID,
			 cast(Program_Growth_Component_Tiers.Tier_Number as int) as Tier_Number, convert(float, Program_Growth_Component_Tiers.Range_Start) as Range_Start, 
			Program_Growth_Component_Tiers.Range_End, Program_Growth_Component_Tiers.Growth_Amount, 
			cast(Program_Growth_Component_Tiers.Range_Start as float) * cast(#Same_Period_Volume_Percent# as float) AS First_Tier_Start,
			
			CASE 
			WHEN Program_Growth_Component_Tiers.Range_End LIKE '*' THEN
				Program_Growth_Component_Tiers.Range_End
			ELSE
				CAST((cast(Program_Growth_Component_Tiers.Range_End as float) * cast(#Same_Period_Volume_Percent# as float)) AS NVARCHAR(50))	
			END AS Calculated_Range_End, 
			
			CASE 
			WHEN T1.Range_End LIKE '*' THEN
				T1.Range_End
			WHEN T1.Program_Growth_Component_Tier_ID IS NULL THEN
				'0'
			ELSE
				(cast(T1.Range_End as float) * #Same_Period_Volume_Percent# + 1) 
			END AS Next_Tier_Start
			
			FROM Program_Growth_Component_Tiers 
				LEFT JOIN Program_Growth_Component_Tiers T1
				ON T1.Tier_Number = (cast(Program_Growth_Component_Tiers.Tier_Number as float) - 1)
				AND T1.Program_Growth_Component_ID = Program_Growth_Component_Tiers.Program_Growth_Component_ID
			WHERE Program_Growth_Component_Tiers.Program_Growth_Component_ID = '#Component_ID#' 
			ORDER BY Program_Growth_Component_Tiers.Tier_Number
			
			</cfquery>
	
			 <!--- <cfdump var="#CalculateTiers#"> --->
			
		<!---Gets the tier if it is percent--->
			<cfquery name="GetTier" dbtype="query">
			SELECT Program_Growth_Component_Tier_ID, Next_Tier_Start as Range_Start, Calculated_Range_End as Range_End, Tier_Number, Range_Start AS RS_Detail, Range_End AS RE_Detail, Growth_Amount
			FROM CalculateTiers
			WHERE 
			((Tier_Number = 1 AND First_Tier_Start <= #TotalVolume#)
			OR (Tier_Number > 1 AND Next_Tier_Start <= #TotalVolume#))
			<!--- Don't know why the greater than 0 is there... --->
			 AND Next_Tier_Start > 0  
			ORDER BY Tier_Number
			</cfquery>
	
		<cfelse>
		
		<!---Gets the tier if it's not percent--->
				<cfquery name="GetTier" datasource="#application.datasource#">
				SELECT Program_Growth_Component_Tier_ID, Tier_Number, Range_Start, Range_End, '' AS RS_Detail, '' AS RE_Detail, Growth_Amount
				FROM Program_Growth_Component_Tiers
				WHERE Program_Growth_Component_ID = '#Component_ID#'
				AND Range_Start <= #TotalVolume# 
				ORDER BY Tier_Number
				</cfquery>
	
		</cfif>
		<!---   <cfdump var="#GetTier#">  --->  
	
		<!---Ends tier calculations--->
		<cfset TierCount = GetTier.Recordcount>
		<cfset RateType = GetComponents.Rate_Type>
		<cfset TierAttained = GetTier.Recordcount>
			
		<!---It's a stairway to heaven of x of y--->
		<cfelse>
				
		<!---Get the components to check whether they're hit or not.--->
		<cfquery name="GetTargetComponents" datasource="#application.datasource#">
		SELECT Program_Growth_Component_Tiers.Range_End, Program_Growth_Component_Tiers.Growth_Amount, Program_Growth_Components.Program_Growth_Component_ID AS Target_ID, Program_Growth_Components.Target_Order, ISNULL(sum(cast(GetInvoicesForLedger.Cases_Invoiced as float)), 0) AS Total_Cases, ISNULL(sum(cast(GetInvoicesForLedger.Pounds_Invoiced as float)), 0) AS Total_Pounds, Program_Growth_Components.Component_UOM AS Target_UOM, Program_Growth_Components.Comparison_Type,  Program_Growth_Components.Sample_Period, Program_Growth_Components.Rate_Type, Program_Growth_Components.Component_Name
		FROM Program_Growth_Components
			INNER JOIN Program_Growth_Component_Tiers
			ON Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
			AND Program_Growth_Component_Tiers.Deleted = 0
			INNER JOIN Program_Growth_Component_Product_Data ON 
			Program_Growth_Component_Product_Data.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
			AND Program_Growth_Component_Product_Data.Deleted = 0
			INNER JOIN Contract_Products ON 
			Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
			AND Contract_Products.Deleted = 0
			INNER JOIN GetInvoicesForLedger
			ON GetInvoicesForLedger.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			AND  GetInvoicesForLedger.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
				AND GetInvoicesForLedger.BSA_Foodservice_Customers_ID = '#DistributorNumber#' 
				AND 
				<cfif BB_Tolerance_TET IS 1>
				(	GetInvoicesForLedger.Invoice_Date >= '#dateformat(StartDate)#'
					AND
					GetInvoicesForLedger.Invoice_Date <= '#dateformat(EndDate)#'
				)
				<cfelse>
				(	GetInvoicesForLedger.Ship_Date >= '#dateformat(StartDate)#'
					AND
					GetInvoicesForLedger.Ship_Date <= '#dateformat(EndDate)#'
				)
				</cfif>
		WHERE Program_Growth_Components.Deleted = 0
		AND Program_Growth_Components.Parent_ID = '#ComponentID#'
		GROUP BY Program_Growth_Component_Tiers.Range_End, Program_Growth_Component_Tiers.Growth_Amount,  	Program_Growth_Components.Program_Growth_Component_ID, Program_Growth_Components.Target_Order, Program_Growth_Components.Component_UOM, Program_Growth_Components.Comparison_Type, Program_Growth_Components.Sample_Period, Program_Growth_Components.Rate_Type, Program_Growth_Components.Component_Name
		ORDER BY Program_Growth_Components.Target_Order
		</cfquery>
			
		<cfparam name="TierAttained" default="0">
		<cfparam name="FailureLevel" default="">
		<cfset ListOfHitTargets = "">
		
		<!---Check to see if you hit it--->
		<cfloop query="GetTargetComponents">
			<!---Checks to make sure it's not a stairway and we're not failing--->
			<cfif FailureLevel IS "" OR ComponentType IS 3>
			<!---It's case--->
			<cfif Target_UOM IS 1>
				<cfif Total_Cases GT Range_End>
					<cfset TierAttained = TierAttained + 1>
					<cfset ListOfHitTargets = listappend(ListOfHitTargets, "'" & Target_ID & "'", ",")>
				<cfelse>
					<cfset FailureLevel = Target_Order>
				</cfif>
			<!---It's pound--->
			<cfelseif Target_UOM IS 2>
				<cfif Total_Pounds GT Range_End>
					<cfset TierAttained = TierAttained + 1>
					<cfset ListOfHitTargets = listappend(ListOfHitTargets, "'" & Target_ID & "'", ",")>
				<cfelse>
					<cfset FailureLevel = Target_Order>
				</cfif>
			<!---It's percent--->
			<cfelse>
				
				<cfif Comparison_Type IS 1>
					<!--- Comparison Type is 1<br> --->
					<cfset Sample_Start_Date = request.app_general_functions.specialDateAdd("yyyy", -1, StartDate)>
					<cfset Sample_End_Date = request.app_general_functions.specialDateAdd("yyyy", -1, EndDate)>
					<cfset Days_in_Sample = DateDiff("d", Sample_Start_Date, Sample_End_Date)>
				<cfelseif Comparison_Type IS 2>
					<!--- Comparison Type is 2<br> --->
					<cfset SamplePeriod = Sample_Period * -1>
					<!--- Sample Period: #Sample_Period#<BR> --->			
					<cfset Sample_End_Date = request.app_general_functions.specialDateAdd("y", -1, StartDate)>
					<cfset Sample_Start_Date = request.app_general_functions.specialDateAdd("y", SamplePeriod, Sample_End_Date)>
					<cfset Days_in_Sample = DateDiff("d", Sample_Start_Date, Sample_End_Date)>
				<cfelse>
				<!--- Comparison Type is NOT 1 or 2<br> --->
				<cfset Sample_End_Date = request.app_general_functions.specialDateAdd("y", -1, StartDate)>
				<cfset Sample_Start_Date = request.app_general_functions.specialDateAdd("yyyy", -1, Sample_End_Date)>
				<cfset Days_in_Sample = DateDiff("d", Sample_Start_Date, Sample_End_Date)>
				</cfif>
				
				<!--- <cfoutput> Sample End Date: #Sample_End_Date#<br>
				Sample Start Date: #Sample_Start_Date#<br>
				Days in Sample: #Days_In_Sample#<br></cfoutput>   --->
				<!---Get all items in component--->
				
				<cfquery name="YearAgoVolume" datasource="#application.datasource#">
				SELECT ISNULL(sum(cast(Invoice_Detail.Pounds_Invoiced as float)), 0) As Year_Ago_Pounds, ISNULL(sum(cast(Invoice_Detail.Cases_Invoiced as float)), 0) as Year_Ago_Cases
				FROM Invoice_Detail
				INNER JOIN Invoice_Header
				ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
				
				WHERE Invoice_Header.Deleted = 0
				AND Invoice_Detail.Deleted = 0
				<!--- AND Invoice_Header.Order_Status = 'I' --->
				<cfif BB_Tolerance_TET IS 1>
				AND Invoice_Header.Invoice_Date >= #Sample_Start_Date#
				AND Invoice_Header.Invoice_Date <= #Sample_End_Date#
				<cfelse>
				AND Invoice_Header.Ship_Date >= #Sample_Start_Date#
				AND Invoice_Header.Ship_Date <= #Sample_End_Date#
				</cfif>
				AND Invoice_Header.BSA_Foodservice_Customers_ID = '#DistributorNumber#'
				AND Invoice_Detail.BSA_Foodservice_Items_Master_ID IN 
					(SELECT Contract_Products.BSA_Foodservice_Items_Master_ID FROM Program_Growth_Component_Product_Data 
					INNER JOIN Contract_Products
					ON
					Contract_Products.Contract_Products_ID =Program_Growth_Component_Product_Data.Contract_Products_ID
					WHERE Program_Growth_Component_ID = '#Target_ID#')
				</cfquery> 
				
				<cfset Year_Ago_Pounds = YearAgoVolume.Year_Ago_Pounds>
				<cfset Year_Ago_Cases = YearAgoVolume.Year_Ago_Cases>
				
				<cfif UOM IS 1>
					<cfset Year_Ago_Volume = Year_Ago_Cases>
				<cfelse>
					<cfset Year_Ago_Volume = Year_Ago_Pounds>
				</cfif>
		
				<!---Figure out what their total volume should have been--->
				<cfset One_Day_Volume = Year_Ago_Volume / Days_In_Sample>
				<!---  One Day Volume: #One_Day_Volume#<br> --->
		
				<cfset Same_Period_Volume = One_Day_Volume * ProgramSpan>
			<!--- 	Same Period Volume: #Same_Period_Volume# = #One_Day_Volume# * #ProgramSpan#<br> --->
			
				<cfset Same_Period_Volume_Percent = Same_Period_Volume / 100>
				<!--- <cfoutput>#Same_Period_Volume_Percent#</cfoutput> --->
				
				<cfif Total_Pounds GT Same_Period_Volume>
					<cfset TierAttained = TierAttained + 1>
					<cfset ListOfHitTargets = listappend(ListOfHitTargets, "'" & Target_ID & "'", ",")>
				<cfelse>
					<cfset FailureLevel = Target_Order>
				</cfif>
				
			</cfif>
			</cfif>
	
		
		</cfloop>
		<!---Get the tier before failure if the component type is stairway--->
		<cfif ComponentType IS 2>
			<cfif FailureLevel IS NOT "">
				<cfset TierAttained = FailureLevel - 1>
			</cfif>
		</cfif>	
		
		<cfset TierCount = GetTargetComponents.Recordcount>
		<cfset RateType = GetTargetComponents.Rate_Type>
		
		<!---Component type--->
		</cfif>

		<!---Make sure we pass consitent information back to the main page--->

<!---Component is $ instead of volume based--->		
<cfelse>

	<cfinclude template="growth_dollar_target.cfm">
<!---Component is $ instead of volume based--->		
</cfif>

		
		