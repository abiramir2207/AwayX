<cfcomponent extends="components.AjaxCFC.ajax">

	<!--- Get sales agreement Info --->
	<cffunction name="getExportSalesAgreement" output="no" returntype="query">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
			<CFQUERY NAME="selExportSalesAgreement" DATASOURCE = "#Application.Datasource#">
			SELECT esa.*,bsafc.Shr_Ship_To As Export_Shr_Ship_To,bsafc.Name As Export_Distributor,invt.Inv_Code + '-' + invt.Description1 + ',' +  invt.Description2 As PayTermsDesc
			,dbt.Shr_Bill_To As Export_Shr_Bill_To,eldc.Export_Lookup_Max_Weight,eltos.Export_lookup_Terms_of_Sale_Desc,eldc.Export_Lookup_Destination_Country_Desc
			,eldp1.Export_Lookup_Destination_Port_Desc As Mexican_Port,eldp2.Export_Lookup_Destination_Port_Desc As Named_Place
			,elo.Export_Lookup_Origin_Desc
			FROM Export_Sales_Agreement esa Left JOIN BSA_Foodservice_Customers bsafc
			ON esa.Export_Distributor_ID= bsafc.BSA_Foodservice_Customers_ID
			LEFT JOIN Distributor_Bill_To dbt
			ON bsafc.Distributor_Bill_To_ID = dbt.Distributor_Bill_To_ID
			LEFT JOIN Export_Lookup_Destination_Country eldc
			ON esa.Export_Destination_Country = eldc.Export_Lookup_Destination_Country_ID
			LEFT JOIN Export_Lookup_Terms_of_Sale eltos
			ON esa.Export_Terms_of_Sale = eltos.Export_Lookup_Terms_of_Sale_ID
			LEFT JOIN Export_Lookup_Destination_Ports eldp1
			ON esa.Export_Mexico_Port = eldp1.Export_Lookup_Destination_Port_ID
			LEFT JOIN Export_Lookup_Destination_Ports eldp2
			ON esa.Export_Named_Place = eldp2.Export_Lookup_Destination_Port_ID
			LEFT JOIN Export_Lookup_Origin elo
			ON esa.Export_Origin = elo.Export_Lookup_Origin_Code
			LEFT JOIN Invoice_Terms invt
			ON bsafc.Invoice_Terms = invt.Inv_Code
			WHERE esa.Export_Sales_Agreement_ID='#arguments.Export_Sales_Agreement_ID#'
			</CFQUERY>

	  <cfreturn selExportSalesAgreement>
	</cffunction>

	<!--- The logic is as follows:
	EXW	= 'ORIGIN' [no selection]
	FOB	= List of  'US PORTS'
	CFR	= List of  'FOREIGN PORTS'
	CIF	= List of  'FOREIGN PORTS'
	DAF	= List of  'DAF DELIVER POINTS'
	DES	= List of  'FOREIGN PORTS'
	DDU	= List of  'MEXICO DELIVERY POINTS'
	--->
	<cffunction name="getNamedPlace" output="no" returntype="array">
		<cfargument name="TOS" type="numeric">
		<cfargument name="Export_Sales_Agreement_ID" type="string" default="">
		<cfargument name="Export_Origin_Code" type="string" default="">
		<cfargument name="IsDisabled" type="boolean" default="0">

		<cfset ReturnValue  = ArrayNew(1)>
		<cfset useLakebaseForget_Named_Place_Type_ID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_terms_of_sale")>
<cfif useLakebaseForget_Named_Place_Type_ID>
	<cftry>
		<cfset get_Named_Place_Type_ID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_terms_of_sale", {
				"export_lookup_terms_of_sale_id" = "eq.#arguments.TOS#",
				"order" = "export_lookup_terms_of_sale_desc.asc",
				"select" = "export_lookup_named_place_type_id"
			}), "export_lookup_named_place_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_Named_Place_Type_ID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_Named_Place_Type_ID>
<cfquery name="get_Named_Place_Type_ID" datasource="#Application.Datasource#">
			SELECT Export_Lookup_Named_Place_Type_ID
			FROM Export_Lookup_Terms_of_Sale
			WHERE Export_Lookup_Terms_of_Sale_ID = '#arguments.TOS#'
			ORDER BY Export_Lookup_Terms_of_Sale_Desc
		</cfquery>
</cfif>
		
		<cfif arguments.Export_Sales_Agreement_ID neq "">
			<cfset Export_Sales_Agreement_Details = getExportSalesAgreement('#arguments.Export_Sales_Agreement_ID#')>
		</cfif>

		<cfset Export_Lookup_Named_Place_Type_ID = get_Named_Place_Type_ID.Export_Lookup_Named_Place_Type_ID>
		<cfset ReturnValue[1] = "<select name='Export_Named_Place' onChange=CheckValue('Export_Named_Place','#arguments.Export_Sales_Agreement_ID#','#arguments.IsDisabled#')">
			<cfif arguments.IsDisabled eq 1><cfset ReturnValue[1] = ReturnValue[1] & " disabled"></cfif>
		<cfset ReturnValue[1] = ReturnValue[1] & ">">
		
		<!--- FOR EXW - RETURN THE 'EXPORT ORIGIN SELECTED' --->
		<cfif Export_Lookup_Named_Place_Type_ID eq "">
			<cfquery name="get_Named_Place_Type_ID" datasource="#Application.Datasource#">
			SELECT Export_Lookup_Origin_Desc
			FROM Export_Lookup_Origin
			WHERE Export_Lookup_Origin_Code = '#arguments.Export_Origin_Code#'
			ORDER BY Export_Lookup_Origin_Desc
			</cfquery>

			<cfif arguments.Export_Origin_Code neq "" AND arguments.Export_Origin_Code neq 0>
				<cfset ReturnValue[1] = ReturnValue[1] & "<option value='#arguments.Export_Origin_Code#'>#get_Named_Place_Type_ID.Export_Lookup_Origin_Desc#</option>">
			<cfelse>
				<cfset ReturnValue[1] = ReturnValue[1] & "<option value='0'>None</option>">
			</cfif>

		<!--- FOR FOB,CFR,CIF,DES,DAF and DDU (ID - 1,2,2,2,3 and 4) - RETURNS 'LIST OF US PORTS OR FOREIGN PORTS OR DAF DELIVERY POINTS' --->
		<cfelse>
		<cfset ReturnValue[1] = ReturnValue[1] & "<option value='0'>None</option>">

		<cfset useLakebaseForqrygetNamedPlace = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_destination_ports")>
<cfif useLakebaseForqrygetNamedPlace>
	<cftry>
		<cfset qrygetNamedPlace = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_destination_ports", {
				"export_lookup_named_place_type_id" = "eq.#Export_Lookup_Named_Place_Type_ID#",
				"order" = "export_lookup_destination_port_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetNamedPlace = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetNamedPlace>
<cfquery name="qrygetNamedPlace" datasource="#Application.Datasource#">
			SELECT * FROM Export_Lookup_Destination_Ports
			WHERE Export_Lookup_Named_Place_Type_ID = '#Export_Lookup_Named_Place_Type_ID#'
			ORDER BY Export_Lookup_Destination_Port_Desc
		</cfquery>
</cfif>

			<cfloop query="qrygetNamedPlace">
				<cfset ReturnValue[1] = ReturnValue[1] & "<option value='#Export_Lookup_Destination_Port_ID#'">
				<cfif arguments.Export_Sales_Agreement_ID neq "">
				<cfif Export_Sales_Agreement_Details.Export_Named_Place eq Export_Lookup_Destination_Port_ID>
				<cfset ReturnValue[1] = ReturnValue[1] & " selected">
				</cfif>
				</cfif>
			<cfset ReturnValue[1] = ReturnValue[1] & ">#Export_Lookup_Destination_Port_Desc#</option>">
			</cfloop>
		</cfif>
	
		<cfset ReturnValue[1]  = ReturnValue[1] &  "</select>">

		<cfset ReturnValue[2] = "<select name='Export_Mexico_Port'  onChange=CheckValue('Export_Mexico_Port','#arguments.Export_Sales_Agreement_ID#','#arguments.IsDisabled#');">
		<cfif arguments.IsDisabled eq 1><cfset ReturnValue[2] = ReturnValue[2] & " disabled"></cfif>
		<cfset ReturnValue[2] = ReturnValue[2] & ">">
		<cfset ReturnValue[2] = ReturnValue[2] & "<option value='0'>None</option>">
		
		<!--- FOR DAF (ID - 3), RETURNS 'MEXICO DELIVERY POINTS' ALSO --->
		<cfif Export_Lookup_Named_Place_Type_ID eq 3>
			<cfset useLakebaseForList_Mexico_Destinations = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_destination_ports")>
<cfif useLakebaseForList_Mexico_Destinations>
	<cftry>
		<cfset List_Mexico_Destinations = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_destination_ports", {
				"export_lookup_named_place_type_id" = "eq.4",
				"order" = "export_lookup_destination_port_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForList_Mexico_Destinations = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForList_Mexico_Destinations>
<cfquery name="List_Mexico_Destinations" datasource="#Application.Datasource#">
			SELECT * FROM Export_Lookup_Destination_Ports
			WHERE Export_Lookup_Named_Place_Type_ID = 4
			ORDER BY Export_Lookup_Destination_Port_Desc
			</cfquery>
</cfif>		

			<cfloop query="List_Mexico_Destinations">
				<cfset ReturnValue[2] = ReturnValue[2] & "<option value='#Export_Lookup_Destination_Port_ID#'">
				<cfif arguments.Export_Sales_Agreement_ID neq "">
				<cfif Export_Sales_Agreement_Details.Export_Mexico_Port eq Export_Lookup_Destination_Port_ID>
				<cfset ReturnValue[2] = ReturnValue[2] & " selected">
				</cfif>
				</cfif>
				
			<cfset ReturnValue[2] = ReturnValue[2] & ">#Export_Lookup_Destination_Port_Desc#</option>">
			</cfloop>
		</cfif>
		<cfset ReturnValue[2]  = ReturnValue[2] &  "</select>">

		<cfreturn ReturnValue>
	</cffunction>


	<!--- Does the foreign country allow pallets (yes or no) --->
	<cffunction name="getPalletIndicator" output="no" returntype="string">
		<cfargument name="Destination" type="numeric" required="Yes">
		<cfargument name="Export_Sales_Agreement_ID" type="string" default="">
		<cfargument name="IsDisabled" type="boolean" default="0">
		<cfargument name="ShowSelected" type="boolean" default="0" required="no">

		<cfset useLakebaseForqrygetPalletIndicator = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_destination_country")>
<cfif useLakebaseForqrygetPalletIndicator>
	<cftry>
		<cfset qrygetPalletIndicator = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_destination_country", {
				"export_lookup_destination_country_id" = "eq.#arguments.Destination#",
				"select" = "export_lookup_allow_pallets"
			}), "export_lookup_allow_pallets"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetPalletIndicator = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetPalletIndicator>
<cfquery name="qrygetPalletIndicator" datasource="#Application.Datasource#">
			SELECT Export_Lookup_Allow_Pallets
			FROM Export_Lookup_Destination_Country
			WHERE Export_Lookup_Destination_Country_ID = '#arguments.Destination#'
		</cfquery>
</cfif>

			<cfif arguments.Export_Sales_Agreement_ID neq "">
				<cfset Export_Sales_Agreement_Details = getExportSalesAgreement('#arguments.Export_Sales_Agreement_ID#')>
			</cfif>

			<cfset PalletIndicator ="<select name='Export_Pallet_Indicator'  onChange=CheckValue('Export_Pallet_Indicator','#arguments.Export_Sales_Agreement_ID#','#arguments.IsDisabled#');">
			<cfif arguments.IsDisabled eq 1><cfset PalletIndicator = PalletIndicator & " disabled"></cfif>
				<cfset PalletIndicator = PalletIndicator & ">">
				<cfset PalletIndicator = PalletIndicator & "<option value='0'>No</option>">

				<cfif qrygetPalletIndicator.Export_Lookup_Allow_Pallets eq 1>
		
					<cfset PalletIndicator = PalletIndicator & "<option value='1'">
						<cfif arguments.Export_Sales_Agreement_ID neq "">
							<cfif Export_Sales_Agreement_Details.Export_Pallet_Indicator eq qrygetPalletIndicator.Export_Lookup_Allow_Pallets and arguments.ShowSelected eq 1>
								<cfset PalletIndicator = PalletIndicator & " selected">
							</cfif>
						</cfif>
				<cfset PalletIndicator = PalletIndicator & ">Yes</option>">		
			</cfif>
				<cfset PalletIndicator = PalletIndicator & "</select>">

		<cfreturn PalletIndicator>
	</cffunction>

	<!--- If the foreign country allows pallets, then return the list of pallets --->
	<cffunction name="getPalletType" output="no" returntype="string">
		<cfargument name="Pallet_Indicator" type="numeric" required="Yes">
		<cfargument name="Country" type="numeric" required="no" default="0">
		<cfargument name="Export_Sales_Agreement_ID" type="string" default="" required="no">
		<cfargument name="IsDisabled" type="boolean" default="0">
		<cfargument name="ShowSelected" type="boolean" default="0" required="no">

		<cfquery name="qrygetPalletType" datasource="#Application.Datasource#">
		 SELECT pt.Export_Lookup_Pallet_Type_ID,pt.Export_Lookup_Pallet_Type_Desc
		 FROM Export_Lookup_Pallet_Type pt
		 WHERE NOT EXISTS
		 (
			SELECT Export_Lookup_Pallet_Type_ID
			FROM Export_Lookup_Pallet_Type_Not_Allowed ptna
			WHERE Export_Lookup_Destination_Country_ID = '#arguments.Country#'
			AND pt.Export_Lookup_Pallet_Type_ID =  ptna.Export_Lookup_Pallet_Type_ID
		 )
		 ORDER BY Export_Lookup_Pallet_Type_Desc
		</cfquery>

		<cfif arguments.Export_Sales_Agreement_ID neq "">
			<cfset Export_Sales_Agreement_Details = getExportSalesAgreement('#arguments.Export_Sales_Agreement_ID#')>
		</cfif>

		<cfset PalletType = "<select name='Export_Pallet_Type'">

		<cfif arguments.IsDisabled eq 1><cfset PalletType = PalletType & " disabled"></cfif>
			<cfset PalletType = PalletType & ">">
			<cfset PalletType = PalletType & "<option value='0'>None</option>">
				<cfif arguments.Pallet_Indicator eq 1>
					<cfloop query="qrygetPalletType">
						<cfset PalletType = PalletType & "<option value='#Export_Lookup_Pallet_Type_ID#'">
							<cfif arguments.Export_Sales_Agreement_ID neq "">
								<cfif Export_Sales_Agreement_Details.Export_Pallet_Type eq Export_Lookup_Pallet_Type_ID and arguments.ShowSelected eq 1>
									<cfset PalletType = PalletType & " selected">	
								</cfif>	
							</cfif>
									<cfset PalletType = PalletType & ">#Export_Lookup_Pallet_Type_Desc#</option>">
					</cfloop>
				</cfif>

			<cfset PalletType = PalletType & "</select>">
		
		<cfreturn PalletType>
	</cffunction>

	<!--- Get the terms of sale --->
	<cffunction name="getTermsOfSale" output="no" returntype="query">
		<cfargument name="Export_Customer_ID" type="numeric" required="false" default="0" />
		<cfquery name="qrygetTermsOfSale" datasource="#Application.Datasource#">
			SELECT a.* FROM 
			Export_Lookup_Terms_of_Sale a
			<cfif arguments.Export_Customer_ID neq 0>
			INNER JOIN Export_Customer_Details b
			ON a.Export_Lookup_Terms_of_Sale_ID = b.Export_Terms_of_Sale
			AND b.Export_Customer_ID = '#arguments.Export_Customer_ID#'
			</cfif>
			ORDER BY a.Export_Lookup_Terms_of_Sale_Desc
		</cfquery>
		
		<cfreturn qrygetTermsOfSale>
	</cffunction>

	<!--- Get the invoice terms --->
	<cffunction name="getInvoiceTerms" output="no" returntype="query">
		<cfset useLakebaseForqrygetInvoiceTerms = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("invoice_terms")>
<cfif useLakebaseForqrygetInvoiceTerms>
	<cftry>
		<cfset qrygetInvoiceTerms = application.oLakebase.toQuery(
			application.oLakebase.selectRows("invoice_terms", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetInvoiceTerms = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetInvoiceTerms>
<cfquery name="qrygetInvoiceTerms" datasource="#Application.Datasource#">
			SELECT * FROM 
			Invoice_Terms
			WHERE Deleted = 0
		</cfquery>
</cfif>
		
		<cfreturn qrygetInvoiceTerms>
	</cffunction>
	
	<!--- get the list of destinations, Max weight allowed for the country, and if the country allows pallets or not --->
	<cffunction name="getDestination" output="no" returntype="query">	
		<cfset useLakebaseForqrygetDestination = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_destination_country")>
<cfif useLakebaseForqrygetDestination>
	<cftry>
		<cfset qrygetDestination = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_destination_country", {
				"show_country" = "eq.1",
				"order" = "export_lookup_destination_country_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetDestination = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetDestination>
<cfquery name="qrygetDestination" datasource="#Application.Datasource#">
			SELECT * FROM 
			Export_Lookup_Destination_Country
			WHERE Show_Country = 1
			ORDER BY Export_Lookup_Destination_Country_Desc
		</cfquery>
</cfif>

		<cfreturn qrygetDestination>
	</cffunction>

	<!--- get the list of origin --->
	<cffunction name="getOrigin" output="no" returntype="query">
		<cfargument name="Export_Customer_ID" type="numeric" required="false" default="0" />
		<cfquery name="qrygetOrigin" datasource="#Application.Datasource#">
			SELECT a.* FROM 
			Export_Lookup_Origin a
			<cfif arguments.Export_Customer_ID neq 0>
			INNER JOIN Export_Customer_Details b
			ON a.Export_Lookup_Origin_ID = b.Export_Origin_ID
			AND b.Export_Customer_ID = '#arguments.Export_Customer_ID#'
			</cfif>
			ORDER BY Export_Lookup_Origin_Desc
		</cfquery>

		<cfreturn qrygetOrigin>
	</cffunction>

	<!--- Ge the freight for the 'Origin' and 'Destination' selected --->
	<cffunction name="getFreight" output="no" returntype="array">
		<cfargument name="Origin" type="string" required="Yes">
		<cfargument name="Destination" type="string" required="Yes">
		<cfargument name="TOS" type="numeric" required="Yes">

	<!--- When TOS is FOB, then Named Place's value (which is the Destination), is non-numeric.
		  This creates a query problem. Even though the datatype of Destination should be numeric, I have made a string,
		  due to Named Place's value being a string in the above-mentioned case --->
		<cfif IsNumeric(Destination) NEQ 0>
			<cfquery name="qrygetFreight" datasource="#Application.Datasource#">
			 SELECT elf.Export_Lookup_Freight_Cost
			 FROM Export_Lookup_Freight elf INNER JOIN Export_Lookup_Origin elo
			 ON elf.Export_Lookup_Origin_ID = elo.Export_Lookup_Origin_ID
			 WHERE elo.Export_Lookup_Origin_Code = '#arguments.Origin#'
			 AND elf.Export_Lookup_Destination_Port_ID = '#arguments.Destination#'
			</cfquery>
		<cfelse>
			<cfset qrygetFreight= QueryNew('Export_Lookup_Freight_Cost')>
		</cfif>

			<cfset Cost = ArrayNew(1)>

			<!--- get the freight --->
			<cfset Cost[1] = val(qrygetFreight.Export_Lookup_Freight_Cost)>
			<cfset StandardCharges =  getCost('Standard')>
			
			<!--- If the Origin is not selected or when Origin is "EXW",there is no freight --->
			<cfif arguments.TOS eq 1 OR arguments.TOS eq 0>
				<cfset Cost[1] = 0.00>
				<cfset Cost[2] = 0.00>
				<cfset Cost[3] = 0.00>

			<!--- Other then "EXW" i.e. for (FOB,CFR,CIF,DAF,DES and DDU), there is always a freight --->
			<cfelse>
				<!--- Inland Fuel Surcharge --->
				<cfset Cost[2] = StandardCharges.Export_Lookup_Cost[1]>
				<!--- Ocean Fuel Surcharge --->
				<cfset Cost[3] = StandardCharges.Export_Lookup_Cost[2]>
			</cfif>

			<cfif arguments.TOS eq 2>
				<cfset Cost[3] = 0.00>
			</cfif>

		<cfreturn Cost>
	</cffunction>
	
	<!--- Get the standard cost associated with exports --->
	<cffunction name="getCostAmount" output="no" returntype="array">
		<cfargument name="CostDesc" type="array" required="yes">
			<cfset CostAmount = ArrayNew(1)>
				<cfloop from="1" to="#ArrayLen(CostDesc)#" index="i">
					<cfset CostAmount[i] = val(getCost(arguments.CostDesc[i]).Export_Lookup_Cost)>
				</cfloop>

		<cfreturn CostAmount> 
	</cffunction>

	<!--- Get the fixed cost associated with exports (lookup values) --->
	<cffunction name="getCost" output="no" returntype="query">
		<cfargument name="CostType" type="string" required="no" default="">
			 <cfif arguments.CostType LT 0>
				<cfset arguments.CostType = 0>
			</cfif>

		<cfquery name="qrygetCost" datasource="#Application.Datasource#">
			SELECT Export_Lookup_Cost_ID, Export_LookUp_Cost, Export_Lookup_Cost_Desc
			FROM Export_Lookup_Costs
			<!--- Standard Cost --->
			<cfif arguments.CostType eq "Standard">
			WHERE Export_Lookup_Cost_ID IN ('1','2')<!--- Inland Fuel Surcharge,Ocean Fuel Surcharge --->
			<cfelseif arguments.CostType eq "Optional">
			<!--- Non-Standard Costs --->
			WHERE Export_Lookup_Cost_ID NOT IN ('1','2') <!--- Like Documentation, L/C charges etc --->
			<cfelse>
			<!--- Based on cost type --->
			WHERE Export_Lookup_Cost_ID = '#arguments.CostType#'
			</cfif>
			ORDER BY Export_Lookup_Cost_Desc
		</cfquery>
		
		<cfreturn qrygetCost>
	</cffunction>

	<!--- Get the variable cost associated with exports --->
	<cffunction name="getStandardCost" output="no" returntype="query">
		<cfargument name="Export_Sales_Agreement_ID" type="string" default="">
			<cfquery name="qrygetStandardCost" datasource="#Application.Datasource#">
			SELECT ec.Export_Cost_ID,ec.Export_Cost_Desc,ec.Export_Cost,ec.Export_Additional_Cost,ec.Show_Order_Sequence
			,elc.Export_Lookup_Cost_Desc
			FROM Export_Cost ec INNER JOIN Export_lookup_Costs elc
			ON elc.Export_Lookup_Cost_ID = ec.Export_Cost_Desc
			WHERE ec.Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
			ORDER BY ec.Show_Order_Sequence
			</cfquery>

		<cfreturn qrygetStandardCost>
	</cffunction>

	<!--- get the miscellaneous export cost --->
	<cffunction name="getMiscCost" output="no" returntype="array">
		<cfargument name="Export_Sales_Agreement_ID" type="string" default="">
			<cfset MiscCost = ArrayNew(1)>
			<cfif arguments.Export_Sales_Agreement_ID neq "">
				<cfquery name="qrygetMiscCost" datasource="#Application.Datasource#">
				SELECT Export_Misc_Cost_ID,Export_Misc_Cost_Desc,Export_Misc_Cost,Show_Order_Sequence
				FROM Export_Misc_Cost
				WHERE Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
				AND Export_Misc_Cost != 0
				ORDER BY Show_Order_Sequence
				</cfquery>

				<cfloop query="qrygetMiscCost">
					<cfset MiscCost[currentrow] = Export_Misc_Cost>
				</cfloop>
			</cfif>
		<cfreturn MiscCost>
	</cffunction>

	<!--- Get the relocation cost from the Item Origin place to the place of Origin --->
	<cffunction name="getRelocationCost" output="no" returntype="string">
		<cfargument name="BSA_Foodservice_Items_Master_ID" type="string" required="yes">
		<cfargument name="Export_Origin_To" type="string" required="yes">

		<cfquery name="qrygetRelocationCost" datasource="#Application.Datasource#">
			SELECT eor.Export_Origin_Relocation_Cost
			FROM Export_Lookup_Origin_Relocation eor INNER JOIN BSA_Foodservice_Items_Master bfim
			ON eor.Item_Origin_Code= bfim.Item_Origin_Code
			WHERE bfim.BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			AND eor.export_Origin_To = '#Trim(arguments.Export_Origin_To)#'
		</cfquery>

		<cfif qrygetRelocationCost.recordcount eq 0>
			<cfset Export_Origin_Relocation_Cost = 0.0000>
		<cfelse>
			<cfset Export_Origin_Relocation_Cost = qrygetRelocationCost.Export_Origin_Relocation_Cost>
		</cfif>

		<cfreturn Export_Origin_Relocation_Cost>
	</cffunction>

	<!--- Get the stickering costs (per LB) related to exports --->
	<cffunction name="getAllStickeringCosts" output="no" returntype="query">
		<cfset useLakebaseForqrygetAllStickeringCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_stickering_cost")>
<cfif useLakebaseForqrygetAllStickeringCosts>
	<cftry>
		<cfset qrygetAllStickeringCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_stickering_cost", {
				"select" = "export_stickering_cost_id,export_stickering_cost_desc,export_stickering_cost_lb"
			}), "export_stickering_cost_id,export_stickering_cost_desc,export_stickering_cost_lb"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetAllStickeringCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetAllStickeringCosts>
<cfquery name="qrygetAllStickeringCosts" datasource="#Application.Datasource#">
			SELECT Export_Stickering_Cost_ID,Export_Stickering_Cost_Desc,Export_Stickering_Cost_LB
			FROM Export_Lookup_Stickering_Cost
		</cfquery>
</cfif>

		<cfreturn qrygetAllStickeringCosts>
	</cffunction>

	<!--- Get the actual stickering cost --->
	<cffunction name="getStickeringCost" output="no" returntype="array">
		<cfargument name="Add_Stickering_Cost" type="boolean" required="no">
		<cfargument name="Export_Stickering_Type" type="string" required="no">
		<cfargument name="Export_Stickering_Product" type="string" required="no">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="no" default="">

		<cfif arguments.Export_Sales_Agreement_ID neq "">
			<cfquery name="qrygetStickeringCost" datasource="#Application.Datasource#">			
			  SELECT Export_Sticker,CAST(Export_Sticker_Rate As varchar(10)) As Export_Sticker_Rate
			  FROM Export_Products
			  WHERE Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'			 
			  AND BSA_Foodservice_Items_Master_ID = '#arguments.Export_Stickering_Product#'
			</cfquery>
		</cfif>

		<cfif arguments.Export_Sales_Agreement_ID eq "" OR qrygetStickeringCost.Recordcount eq 0>
			<cfquery name="qrygetStickeringCost" datasource="#Application.Datasource#">
			 SELECT CAST(Export_Stickering_Cost_LB As varchar(10)) As Export_Stickering_Cost
			 FROM Export_Lookup_Stickering_Cost
			 WHERE Export_Stickering_Cost_ID = '#arguments.Export_Stickering_Type#'
		    </cfquery>
		</cfif>

		<cfset Export_Stickering_Data = ArrayNew(1)>

		<!--- Whenever the change is for all the products, then there is no "Export_Sales_Agreement_ID" as an argument --->
			<cfset Export_Stickering_Data[1]= arguments.Export_Stickering_Product>
			<cfif IsDefined("qrygetStickeringCost.Export_Sticker")>
				<cfset Export_Stickering_Data[2]= val(qrygetStickeringCost.Export_Sticker)>
				<cfset Export_Stickering_Data[3]= qrygetStickeringCost.Export_Sticker_Rate>
			<cfelse>
				<cfif arguments.Add_Stickering_Cost neq 0 AND Export_Stickering_Type neq 0>
					<cfset Export_Stickering_Data[2]= qrygetStickeringCost.Export_Stickering_Cost>
				<cfelse>
					<cfset Export_Stickering_Data[2]= 0.0000>
				</cfif>
			</cfif>

		<cfreturn Export_Stickering_Data>
	</cffunction>

	<cffunction name="UpdateStickeringData" output="no" returntype="numeric">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
		<cfargument name="ExportStickeringType" type="numeric" required="yes">

		<cfset useLakebaseForupdateStickeringType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForupdateStickeringType>
	<cftry>
		<cfset application.oLakebase.updateRows("export_sales_agreement",
			{
				"export_sales_agreement_id" = "eq.#arguments.Export_Sales_Agreement_ID#"
			},
			{
				"export_stickering_cost_id" = "#arguments.ExportStickeringType#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateStickeringType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateStickeringType>
<cfquery name="updateStickeringType" datasource="#Application.Datasource#">
			UPDATE Export_Sales_Agreement
			SET Export_Stickering_Cost_ID = '#arguments.ExportStickeringType#'
			WHERE Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
		</cfquery>
</cfif>
		<!--- I am returning a  value here because AJAXCFC expects a return value --->
		<cfreturn 1>
	</cffunction>

	<cffunction name="UpdateMiscCost" output="no" returntype="numeric">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
		<cfargument name="Misc_Cost" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Misc_Cost_Desc" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Misc_Cost_Desc_CostNumber" type="Array" required="no" default="#Arraynew(1)#">

		<cfset useLakebaseForDelExistingMiscCost = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_misc_cost")>
<cfif useLakebaseForDelExistingMiscCost>
	<cftry>
		<cfset application.oLakebase.deleteRows("export_misc_cost", {
			"export_sales_agreement_id" = "eq.#arguments.Export_Sales_Agreement_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelExistingMiscCost = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelExistingMiscCost>
<cfquery name="DelExistingMiscCost" datasource="#Application.Datasource#">
			DELETE FROM Export_Misc_Cost
			WHERE Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
		</cfquery>
</cfif>
		<!--- I am starting from index 2, because the array being passed somehow stores blank in the first index
			  and therefore I replaced it with a 0 on that page (Sales_Agreement.cfm). I just dont use that array
			  entry here --->
		<cfloop from="2" to="#Arraylen(Misc_Cost_Desc)#" index="i">
			<cfquery name="InsertExportMiscCost" datasource="#application.datasource#">
			 INSERT INTO Export_Misc_Cost(Export_Sales_Agreement_ID,Export_Misc_Cost_Desc,Export_Misc_Cost,Show_Order_Sequence)
			 VALUES('#arguments.Export_Sales_Agreement_ID#','#Misc_Cost_Desc[i]#','#val(Misc_Cost[i])#','#Misc_Cost_Desc_CostNumber[i]#')
			</cfquery>
		</cfloop>

		<!--- I am returning a  value here because AJAXCFC expects a return value ---> 
		<cfreturn 1>
	</cffunction>

	<cffunction name="UpdateExportCost" output="no" returntype="numeric">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
		<cfargument name="Export_Cost" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Export_Cost_Desc" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Export_Additional_Cost" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Export_Cost_Desc_CostNumber" type="Array" required="no" default="#Arraynew(1)#">

		<cfquery name="DelExistingExportCost" datasource="#Application.Datasource#">
			DELETE FROM Export_Cost
			WHERE Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
		</cfquery>
		<!--- I am starting from index 2, because the array being passed somehow stores blank in the first index
			  and therefore I replaced it with a 0 on that page (Sales_Agreement.cfm). I just dont use that array
			  entry here--->
		<cfloop from="2" to="#Arraylen(Export_Cost)#" index="i">
			<cfquery name="InsertExportCost" datasource="#application.datasource#">
			 INSERT INTO Export_Cost(Export_Sales_Agreement_ID,Export_Cost_Desc,Export_Cost,Export_Additional_Cost,Show_Order_Sequence)
			 VALUES('#Export_Sales_Agreement_ID#','#Export_Cost_Desc[i]#','#val(Export_Cost[i])#','#val(Export_Additional_Cost[i])#','#Export_Cost_Desc_CostNumber[i]#')
			</cfquery>
		</cfloop>

		<!--- I am returning a  value here because AJAXCFC expects a return value ---> 
		<cfreturn Arraylen(Export_Cost)>
	</cffunction>

	<cffunction name="UpdateStandardCosts" output="no" returntype="numeric">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
		<cfargument name="Freight_Cost" type="string" required="yes">
		<cfargument name="Additional_Freight_Cost" type="string" required="yes">
		<cfargument name="Inland_Fuel_Surcharge" type="string" required="yes">
		<cfargument name="Additional_Inland_Fuel_Surcharge" type="string" required="yes">
		<cfargument name="Ocean_Fuel_Surcharge" type="string" required="yes">
		<cfargument name="Additional_Ocean_Fuel_Surcharge" type="string" required="yes">
		
			  <cfquery name="qryUpdateStandardCosts" datasource="#application.datasource#">
			   UPDATE Export_Sales_Agreement
				SET Export_Freight_Cost='#val(arguments.Freight_Cost)#'
				,Export_Additional_Freight_Cost='#val(arguments.Additional_Freight_Cost)#'
				,Export_Inland_Fuel_Surcharge='#val(arguments.Inland_Fuel_Surcharge)#'
				,Export_Additional_Inland_Fuel_Surcharge='#val(arguments.Additional_Inland_Fuel_Surcharge)#'
				,Export_Ocean_Fuel_Surcharge='#val(arguments.Ocean_Fuel_Surcharge)#'
				,Export_Additional_Ocean_Fuel_Surcharge='#val(arguments.Additional_Ocean_Fuel_Surcharge)#'
			   WHERE Export_Sales_Agreement_ID='#arguments.Export_Sales_Agreement_ID#'
			  </cfquery>

		<!--- I am returning a  value here because AJAXCFC expects a return value ---> 
		<cfreturn 1>
	</cffunction>

	<!--- Get the "export charge" and "NSP" related to a product --->
	<cffunction name="getCostorNSP" output="no" returntype="array">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
		<cfargument name="BSA_Foodservice_Items_Master_ID" type="string" required="yes">
		<cfargument name="Target_NSP" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Standard_Costs" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Additional_Costs" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Relocation_Costs" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Add_Stickering_Costs" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Stickering_Costs" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Accrual_Costs" type="Array" required="no" default="#Arraynew(1)#">
		<cfargument name="Sales_Charge" type="Array" required="no" default="#Arraynew(1)#">

			<CFQUERY NAME="qryGetProductDetails" datasource="#application.datasource#">
			 SELECT distinct IsNull(Export_Net_Loadability,0) As Export_Net_Loadability 
			 FROM Export_Products
			 WHERE Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
			 AND BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			 AND Export_Products.Deleted = 0
			</CFQUERY>
	<!---
	"sub total" is the sum of regular freight and regular Inland fuel surcharge and regular ocean fuel surcharge
	and regular export cost: 
	SubTotal = SubTotal + Export_Freight_Cost + Export_Inland_Fuel_Surcharge + Export_Ocean_Fuel_Surcharge
	SubTotal = SubTotal + Export_Cost
	**************************************************
	"Charge_SubTotal" is the sum of Additional freight and Additional Inland fuel surcharge and Additional ocean fuel surcharge
	and additional export cost and Misc Cost:
	Charge_SubTotal = Charge_SubTotal + Export_Additional_Freight_Cost + Export_Additional_Inland_Fuel_Surcharge + Export_Additional_Ocean_Fuel_Surcharge
	Charge_SubTotal = Charge_SubTotal + Export_Additional_Cost
	Charge_SubTotal = Charge_SubTotal + Export_Misc_Cost
	**************************************************
	"sales charge" is Sale Unit Price * Net Loadability
	Sales_Charge = Export_Net_Loadability * Export_Sale_Unit_Price
	**************************************************
	"Total_Accrual" is Accrual * Net Loadability
	Total_Accrual = Export_Net_Loadability * Export_Accrual>
	**************************************************
	"Total_Relocation" is Relocation Cost * Net Loadability
	Total_Relocation = Export_Net_Loadability * Export_Origin_Relocation_Cost>
	**************************************************
	"Total_Stickering" is Sticker_Rate * Net Loadability
	Total_Stickering = Export_Net_Loadability * Export_Sticker_Rate
	**************************************************
	"Total_Cost" is total of SubTotal and Total_Accrual and Total_Relocation and Total_Stickering
	Total_Cost = SubTotal + Total_Accrual + Total_Relocation + Total_Stickering
	**************************************************
	"Total_Charge" is the total of Sales_Charge and Charge_SubTotal
	Total_Charge = Sales_Charge + Charge_SubTotal
	**************************************************
	"Total_NSP" is  Total_Charge minus Total_Cost
	Total_NSP = Total_Charge - Total_Cost>
	**************************************************
	"NSP" is  Total_NSP divided by Export_Net_Loadability
	NSP = Total_NSP/Export_Net_Loadability>
	--->

		<cfset SubTotal = 0>
		<cfset Charge_SubTotal = 0>
		<cfset Net_Cost_Charge = 0>
		<cfset NSP = 0>
		<cfset Total_Cost = 0>
		<cfset Total_Charge = 0>
		<cfset SalesCharge = 0>
		<cfset RelocationCosts = 0>
		<cfset StickeringCosts = 0>
		<cfset AccrualCosts = 0>
		<cfset TargetNSP = 0>
		
		<cfset ReturnValue = ArrayNew(1)>

		<cfloop from="1" to="#Arraylen(Target_NSP)#" index="i">
			<cfset TargetNSP = TargetNSP + Target_NSP[i]>
			<cfset useLakebaseForupdateCost = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_products")>
<cfif useLakebaseForupdateCost>
	<cftry>
		<cfset application.oLakebase.updateRows("export_products",
			{
				"bsa_foodservice_items_master_id" = "eq.#arguments.BSA_Foodservice_Items_Master_ID#",
				"export_sales_agreement_id" = "eq.#arguments.Export_Sales_Agreement_ID#"
			},
			{
				"export_target_net_sales_price" = "#Target_NSP[i]#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateCost = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateCost>
<cfquery name="updateCost" datasource="#Application.Datasource#">
			UPDATE Export_Products
			SET Export_Target_Net_Sales_Price = '#Target_NSP[i]#'
			WHERE BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			AND Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
			</cfquery>
</cfif>
		</cfloop>

		<cfloop from="1" to="#Arraylen(Standard_Costs)#" index="i">
			<cfset SubTotal = SubTotal + arguments.Standard_Costs[i]>
		</cfloop>

		<cfloop from="1" to="#Arraylen(Additional_Costs)#" index="i">
			<cfset Charge_SubTotal = Charge_SubTotal + arguments.Additional_Costs[i]>
		</cfloop>
	
		<cfif qrygetProductDetails.Export_Net_Loadability GT 0>
			<cfset Net_Cost_Charge = Evaluate((SubTotal - Charge_SubTotal)/qryGetProductDetails.Export_Net_Loadability)>
		<cfelse>
			<cfset Net_Cost_Charge = 0>
		</cfif>

		<cfloop from="1" to="#Arraylen(Relocation_Costs)#" index="i">
			<cfset RelocationCosts = RelocationCosts + Relocation_Costs[i]>
		</cfloop>

		<cfset RelocationCosts = val(qryGetProductDetails.Export_Net_Loadability) * val(RelocationCosts)>

		<cfloop from="1" to="#Arraylen(Stickering_Costs)#" index="i">
		<cfset StickeringCosts = StickeringCosts + Stickering_Costs[i]>
			<cfquery name="updateCost" datasource="#Application.Datasource#">
			UPDATE Export_Products
			SET Export_Sticker_Rate = '#StickeringCosts#'	
			WHERE BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			AND Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
			</cfquery>
		</cfloop>

		<cfloop from="1" to="#Arraylen(Add_Stickering_Costs)#" index="i">
			<cfquery name="updateCost" datasource="#Application.Datasource#">
			UPDATE Export_Products
			SET Export_Sticker = '#Add_Stickering_Costs[i]#'	
			WHERE BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			AND Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
			</cfquery>
		</cfloop>

	
		<cfset StickeringCosts = val(qryGetProductDetails.Export_Net_Loadability) * val(StickeringCosts)>

		<cfloop from="1" to="#Arraylen(Accrual_Costs)#" index="i">
			<cfset AccrualCosts = AccrualCosts + Accrual_Costs[i]>
			<cfquery name="updateCost" datasource="#Application.Datasource#">
			UPDATE Export_Products
			SET Export_Accrual = '#AccrualCosts#'
			WHERE BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			AND Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
			</cfquery>
		</cfloop>

		<cfset AccrualCosts = val(qryGetProductDetails.Export_Net_Loadability) * val(AccrualCosts)>

		<cfset Total_Cost = SubTotal + RelocationCosts + StickeringCosts + AccrualCosts>

		<cfloop from="1" to="#Arraylen(Sales_Charge)#" index="i">
			<cfset SalesCharge = SalesCharge + Sales_Charge[i]>
			<cfquery name="updateCost" datasource="#Application.Datasource#">
			UPDATE Export_Products
			SET Export_Sale_Unit_Price = '#SalesCharge#'
			WHERE BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			AND Export_Sales_Agreement_ID = '#arguments.Export_Sales_Agreement_ID#'
			</cfquery>
		</cfloop>

		<cfset SalesCharge = val(qryGetProductDetails.Export_Net_Loadability) * val(SalesCharge)>

		<cfset Total_Charge = Charge_SubTotal + SalesCharge>

		<cfset Total_NSP = Total_Charge - Total_Cost>

		<cfif qryGetProductDetails.Export_Net_Loadability GT 0>
			<cfset NSP = Total_NSP/qryGetProductDetails.Export_Net_Loadability>
		<cfelse>
			<cfset NSP = 0>
		</cfif>

		<cfset ReturnValue[1] = Net_Cost_Charge>
		<cfset ReturnValue[2] = NSP>
		<cfset ReturnValue[3] = arguments.BSA_Foodservice_Items_Master_ID>

		<cfreturn ReturnValue>
	</cffunction>

	<!--- Get the Maximum loadable area (height and weight) --->
	<cffunction name="getMaxLoadableArea" output="no" returntype="array">
		<cfargument name="IsPallet" type="boolean" required="yes">
		<cfargument name="MaxWeightAllowed" type="numeric" required="yes">

			<cfset Max_Height_Container = 96>
			<cfset Max_Height_Pallet = 6>
			<cfset Max_Weight_Pallet = 1500>

				<cfset LoadableArea = ArrayNew(1)>

				<!--- Size of the container minus size of the Pallet will give the Max loadable area and weight --->
			  <cfif arguments.IsPallet eq 1>
				<cfset Max_Height = Max_Height_Container - Max_Height_Pallet>
				<cfset Max_Weight = arguments.MaxWeightAllowed - Max_Weight_Pallet>
			  <cfelse>
				<cfset Max_Height = Max_Height_Container>
				<cfset Max_Weight = arguments.MaxWeightAllowed>
			  </cfif>
				
				<cfset LoadableArea[1] =  Max_Height>
				<cfset LoadableArea[2] =  Max_Weight>

		<cfreturn LoadableArea>
	</cffunction>

	<!--- get the customer details --->
	<cffunction name="getCustomerDetails" output="no" returntype="query">
		<cfargument name="Customer_ID" type="string" required="yes">
			<CFQUERY NAME="qrygetCustomerDetails" DATASOURCE = "#Application.Datasource#">
			 SELECT RTRIM(LTRIM(bsafc.Name)) As Name,RTRIM(LTRIM(bsafc.Address_1)) As Address_1,RTRIM(LTRIM(bsafc.Address_2)) As Address_2
			 ,RTRIM(LTRIM(bsafc.City)) As City,RTRIM(LTRIM(bsafc.State)) As State,RTRIM(LTRIM(bsafc.ZipCode)) As ZipCode
			 ,RTRIM(LTRIM(dbt.Name)) As Dist_Bill_To_Name,RTRIM(LTRIM(dbt.Address1)) As Dist_Bill_To_Address_1,RTRIM(LTRIM(dbt.Address2)) As Dist_Bill_To_Address_2
			 ,RTRIM(LTRIM(bsafc.City)) As Dist_Bill_To_City,RTRIM(LTRIM(dbt.State)) As Dist_Bill_To_State,RTRIM(LTRIM(dbt.Zip)) As Dist_Bill_To_ZipCode
			 FROM BSA_Foodservice_Customers bsafc LEFT JOIN Distributor_Bill_To dbt
			 ON bsafc.Distributor_Bill_To_ID = dbt.Distributor_Bill_To_ID
			 WHERE bsafc.BSA_Foodservice_Customers_ID = '#arguments.Customer_ID#'
			</CFQUERY>

		<cfreturn qrygetCustomerDetails>
	</cffunction>

	<!--- get the product details (Get all Sales products which have sales unit price OR Accrual > 0 - based on "CostType" passed --->
	<cffunction name="getProductDetails" output="no" returntype="query">
		<cfargument name="Export_Sales_Agreement_ID" type="string" required="yes">
		<cfargument name="CostType" type="numeric" required="no">
			<CFQUERY NAME="qryProductDetails" DATASOURCE = "#Application.Datasource#">
			SELECT bfim.BSA_Foodservice_Items_Master_ID,bfim.Item,bfim.Description,ep.Export_End_User
			,ep.Export_Volume_Limit,IsNull(ep.Export_Sale_Unit_Price,0) As Export_Sale_Unit_Price,ep.Export_Notes
			,ep.Export_Accrual,bfim.Net_Weight
			 FROM	BSA_Foodservice_Items_Master bfim 
			INNER JOIN
			Export_Products ep 
			ON  bfim.BSA_Foodservice_Items_Master_ID = ep.BSA_Foodservice_Items_Master_ID
			AND ep.Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
			AND ep.Deleted = 0
			<cfif arguments.CostType eq 1>
			AND Export_Sale_Unit_Price ! = 0
			<cfelseif arguments.CostType eq 2>
			AND Export_Accrual ! = 0
			</cfif>
			ORDER BY Item
			</CFQUERY>
		<cfreturn qryProductDetails>
	</cffunction>

	
	<!--- get the valid status types for a new customer to be approved --->
	<cffunction name="getValidCustomerStatusTypes" output="false" returntype="Array">
	  <cfargument name="ExportCustomerID" type="numeric" required="Yes">
	  <cfargument name="StatusAllowed" type="numeric" required="Yes">

		<cfset useLakebaseForqrygetCustomerStatusTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_customer_status_types")>
<cfif useLakebaseForqrygetCustomerStatusTypes>
	<cftry>
		<cfset qrygetCustomerStatusTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_lookup_customer_status_types", {
				"export_lookup_customer_status_type_id" = "eq.#arguments.StatusAllowed#",
				"deleted" = "eq.0",
				"select" = "export_lookup_customer_status_type_id,export_lookup_customer_status_type_desc"
			}), "export_lookup_customer_status_type_id,export_lookup_customer_status_type_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetCustomerStatusTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetCustomerStatusTypes>
<cfquery name="qrygetCustomerStatusTypes" datasource="#application.datasource#">
			SELECT Export_Lookup_Customer_Status_type_ID,Export_Lookup_Customer_Status_Type_Desc
			FROM Export_Lookup_Customer_Status_Types
			WHERE Export_Lookup_Customer_Status_type_ID = '#arguments.StatusAllowed#'
			AND Deleted = 0
		</cfquery>
</cfif>

		<cfset ReturnValue = ArrayNew(1)>
		
		<cfset ReturnValue[1] = qrygetCustomerStatusTypes.Export_Lookup_Customer_Status_type_ID>
		<cfset ReturnValue[2] = qrygetCustomerStatusTypes.Export_Lookup_Customer_Status_Type_Desc>

		<cfreturn ReturnValue>
	</cffunction>
</cfcomponent>