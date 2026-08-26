<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFQUERY NAME="TheQuery" DATASOURCE="#application.datasource#">	
	SELECT 	DISTINCT
		dbo.Service_Zones.Zone_Name AS Zone_Name,
		dbo.Service_Regions.Region_Name AS Region_Name,
		dbo.BSA_Foodservice_Customers.Name,
		<cfif isDefined("time_span") and time_span EQ "Two_Fiscal_Year"> 0 <cfelse> sum(convert(decimal(10,2), dbo.Invoice_Detail.Pounds_Invoiced)) </cfif> AS total_pounds_invoiced,
		<cfif isDefined("time_span") and time_span EQ "Two_Fiscal_Year"> 0 <cfelse> sum(convert(decimal(10,2), dbo.Invoice_Detail.Cases_Invoiced)) </cfif> AS  total_cases_invoiced,
		<cfif isDefined("time_span") and time_span EQ "Two_Fiscal_Year"> 0 <cfelse> sum(convert(decimal(10,2), dbo.Invoice_Detail.Sales_Dollars)) </cfif> AS  total_sales,
		(dbo.BSA_Foodservice_Customers.Name + '(' + dbo.BSA_Foodservice_Customers.Shr_Ship_To + ')' ) AS Customer_Ship_To
	From	dbo.Invoice_Header 
		INNER JOIN 	dbo.Invoice_Detail ON dbo.Invoice_Header.Invoice_Header_ID = dbo.Invoice_Detail.Invoice_Header_ID 
		INNER JOIN	dbo.BSA_Foodservice_Items_Master ON dbo.Invoice_Detail.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
		INNER JOIN	dbo.BSA_Foodservice_Customers ON dbo.Invoice_Header.BSA_Foodservice_Customers_ID = dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID 
		<cfif NOT appSettings.getDistributorMultiPosition()>
		INNER JOIN	dbo.BSA_Foodservice_Brokers ON dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
		<cfelse>
		INNER JOIN Market_Distributor ON Market_Distributor.Deleted = 0 AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
		INNER JOIN Service_Markets ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
		</cfif>
		INNER JOIN	dbo.Service_Regions on 
		<cfif NOT appSettings.getDistributorMultiPosition()>
		Service_Regions.Service_Region_ID = BSA_Foodservice_Brokers.Service_Region_ID
		<cfelse>
		Service_Regions.Service_Region_ID = Service_Markets.Service_Region_ID
		</cfif>
		INNER JOIN	Service_Zones on dbo.Service_Zones.Service_Zone_ID = Service_Regions.Service_Zone_ID	
	WHERE 	0=0
		AND	dbo.Invoice_Header.Deleted = 0
		AND	dbo.Invoice_Detail.Deleted = 0
		AND dbo.BSA_Foodservice_Customers.DELETED = 0 
		AND	dbo.Service_Zones.Deleted = 0 
		AND	dbo.Service_Regions.Deleted = 0
				
		<!---Invoice --->
			<!--- for reference --->
				<CFIF Len(Trim(Form.Ship_To)) GT 0>
			AND dbo.BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#Form.Ship_To#%'
		</CFIF>
			<!--- end for reference --->
			<!--- Customer/Distributor: Family_Name --->
			<CFIF isDefined("FORM.Family_Name") and FORM.Family_Name NEQ 0 and len(FORM.Family_Name) GT 0>
				AND dbo.BSA_Foodservice_Customers.Family_ID = '#FORM.Family_Name#'
			</CFIF>
		
			<!--- Custormer/Distributor: buying group --->
			<CFIF isDefined("FORM.Buying_Group") and FORM.Buying_Group NEQ 0 and len(FORM.Buying_Group) GT 0>
				AND dbo.BSA_Foodservice_Customers.Buying_Group_ID = '#FORM.Buying_Group#'
			</CFIF>
			
			<!--- Customer/Distributor: Zone --->
			<CFIF isDefined("FORM.Zone_ID") and FORM.Zone_ID NEQ 0 and len(FORM.Zone_ID) GT 0>
				AND dbo.BSA_Foodservice_Brokers.Service_Zone_ID = '#FORM.Zone_ID#'
			</CFIF>
		
			<!--- Customer/Distributor: Region --->
			<CFIF isDefined("FORM.Region_ID") and FORM.Region_ID NEQ 0 and len(FORM.Region_ID) GT 0>
				AND dbo.BSA_Foodservice_Brokers.Service_Region_ID = '#FORM.Region_ID#'
			</CFIF>
			
			<CFIF isDefined("Form.Ship_To") and Len(Trim(Form.Ship_To)) GT 0>
				AND dbo.BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#Form.Ship_To#%'
			</CFIF>
			
			<!--- Broker: Broker --->
			<!--- Product: --->
			<!--- type group --->
			<CFIF isDefined("FORM.Type_Group_Desc_ID") and FORM.Type_Group_Desc_ID NEQ 0>
				AND dbo.BSA_Foodservice_Items_Master.Type_Group_Desc_ID = '#FORM.Type_Group_Desc_ID#'
			</CFIF>
			<!--- type code --->
			<CFIF isDefined("FORM.Type_Code_Desc_ID") and FORM.Type_Code_Desc_ID NEQ 0>
				AND dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = '#FORM.Type_Code_Desc_ID#'
			</CFIF>
			<CFIF isDefined("FORM.item_number") and len(trim(FORM.item_number)) NEQ 0>
				AND
				(
					dbo.BSA_Foodservice_Items_Master.Item 	like 	'%#preservesinglequotes(FORM.item_number)#%'
					or
					dbo.BSA_Foodservice_Items_Master.Item 	like 	'#preservesinglequotes(FORM.item_number)#%'
					or
					dbo.BSA_Foodservice_Items_Master.Item 	like 	'%#preservesinglequotes(FORM.item_number)#'
					or
					dbo.BSA_Foodservice_Items_Master.Item 	=	 	'#preservesinglequotes(FORM.item_number)#'
				)
			</CFIF>
			
			<!--- Broker --->
			
			
			<CFIF isDefined("FORM.Broker") and FORM.Broker NEQ "" and len(FORM.Broker) GT 0>
				AND dbo.InvoiceVolumeDetail.BSA_Foodservice_Brokers_ID = '#trim(FORM.Broker)#'
			</CFIF>
			
			<CFIF isDefined("FORM.searchstring") and len(trim(FORM.searchstring)) GT 0>
				AND
				dbo.InvoiceVolumeDetail.Name LIKE '%#trim(form.searchstring)#%'
				OR dbo.InvoiceVolumeDetail.City LIKE '%#trim(form.searchstring)#%'
				OR dbo.InvoiceVolumeDetail.Family_Name LIKE '%#trim(form.searchstring)#%'
				<CFIF isnumeric(form.searchstring)>
					OR dbo.InvoiceVolumeDetail.Shr_Family LIKE '%#trim(form.searchstring)#%'
				</CFIF>
				OR dbo.InvoiceVolumeDetail.Broker_Name LIKE '%#trim(form.searchstring)#%'
			</CFIF> 
			
			<cfif isDefined("time_span") and time_span EQ "Fiscal_Period">
				<cfif TET NEQ 2>
					AND dbo.Invoice_Header.Invoice_Date >= '#FYPSD#'
					AND dbo.Invoice_Header.Invoice_Date <= '#FYPED#'
				<cfelse>
					AND dbo.Invoice_Header.Ship_Date >= '#FYPSD#'
					AND dbo.Invoice_Header.Ship_Date <= '#FYPED#'
				</cfif>
			</cfif>
			<cfif isDefined("time_span") and time_span EQ "Fiscal_Period_Year_Ago">
				<cfif TET NEQ 2>
					AND dbo.Invoice_Header.Invoice_Date >= '#LFYPSD#'
					AND dbo.Invoice_Header.Invoice_Date <= '#LFYPED#'
				<cfelse>
					AND dbo.Invoice_Header.Ship_Date >= '#LFYPSD#'
					AND dbo.Invoice_Header.Ship_Date <= '#LFYPED#'
				</cfif>
			</cfif>
			<cfif isDefined("time_span") and time_span EQ "Fiscal_Year">
				<cfif TET NEQ 2>
					AND dbo.Invoice_Header.Invoice_Date >= '#FYSD#'
					AND dbo.Invoice_Header.Invoice_Date <= '#FYED#'
				<cfelse>
					AND dbo.Invoice_Header.Ship_Date >= '#FYSD#'
					AND dbo.Invoice_Header.Ship_Date <= '#FYED#'
				</cfif>
			</cfif>
			<cfif isDefined("time_span") and time_span EQ "Fiscal_Year_Year_Ago">
				<cfif TET NEQ 2>
					AND dbo.Invoice_Header.Invoice_Date >= '#LFYSD#'
					AND dbo.Invoice_Header.Invoice_Date <= '#LFYED#'
				<cfelse>
					AND dbo.Invoice_Header.Ship_Date >= '#LFYSD#'
					AND dbo.Invoice_Header.Ship_Date <= '#LFYED#'
				</cfif>
			</cfif>
			<cfif isDefined("time_span") and time_span EQ "Fiscal_Quarter">
				<cfif TET NEQ 2>
					AND dbo.Invoice_Header.Invoice_Date >= '#FYQSD#'
					AND dbo.Invoice_Header.Invoice_Date <= '#FYQED#'
				<cfelse>
					AND dbo.Invoice_Header.Ship_Date >= '#FYQSD#'
					AND dbo.Invoice_Header.Ship_Date <= '#FYQED#'
				</cfif>	
			</cfif>
			<cfif isDefined("time_span") and time_span EQ "Fiscal_Quarter_Year_Ago">
				<cfif TET NEQ 2>
					AND dbo.Invoice_Header.Invoice_Date >= '#LFYQSD#'
					AND dbo.Invoice_Header.Invoice_Date <= '#LFYQED#'
				<cfelse>
					AND dbo.Invoice_Header.Ship_Date >= '#LFYQSD#'
					AND dbo.Invoice_Header.Ship_Date <= '#LFYQED#'
				</cfif>
			</cfif>
			<cfif isDefined("time_span") and time_span EQ "Two_Fiscal_Year">
				<cfif TET NEQ 2>
					AND dbo.Invoice_Header.Invoice_Date >= '#LFYSD#'
					AND dbo.Invoice_Header.Invoice_Date <= '#FYED#'
				<cfelse>
					AND dbo.Invoice_Header.Ship_Date >= '#LFYSD#'
					AND dbo.Invoice_Header.Ship_Date <= '#FYED#'
				</cfif>
			</cfif>
	group by Zone_Name, Region_Name, dbo.BSA_Foodservice_Customers.Name,dbo.BSA_Foodservice_Customers.Shr_Ship_To
	order by Zone_Name, Region_Name
	
</CFQUERY>
<!--- <cfdump var = #TheQuery#> --->
