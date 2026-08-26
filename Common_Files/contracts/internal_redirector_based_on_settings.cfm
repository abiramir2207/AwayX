<CFPARAM name="redirector_Program_ID" default="0">
<CFPARAM name="redirector_FromPage_ID" default="1">
<!--- 
	1 = Basic Info
	2 = Operator
	3 = Broker
	4 = Distributor
	5 = Products
 --->

<CFPARAM name="GetSettingsRedirector.Specify_Distributors" default="1">
<CFPARAM name="GetSettingsRedirector.Specify_Operators" default="1">
<CFPARAM name="GetSettingsRedirector.Specify_Brokers" default="1">
<CFPARAM name="GetSettingsRedirector.Specify_Products" default="1">
<CFPARAM name="GetSettingsRedirector.Enable_Program_Qualifications" default="0">
<CFPARAM name="qualPopup" default="0">

<!--- This is needed for LSAutoPay Generic Type that has special page availability --->
<cfif NOT ISDEFINED("variables.bHideFromLSAutoPay") AND ISDEFINED("FORM.Contract_Main_ID")>
	<cfset CSL_Contract_Main_Id = FORM.Contract_Main_ID />
	<CFINCLUDE TEMPLATE="commonqueries.cfm">
</CFIF>

<cfset appSettings = application.appsettingsGet />

<cfinclude template="/get_access_profile.cfm">

<cfif redirector_Program_ID GT 0>
	<!--- get the settings of the contract program type if it has one--->
	<cfquery name="GetSettingsRedirector" datasource="#application.datasource#">
		SELECT 
			Generic_Type,
			Specify_Distributors,
			Specify_Operators,
			Specify_Brokers,
			Specify_Products,
			Rates_By_Category,
			Discount_Fixed_Prices,
			Discount_Rebates,
			Discount_Lump_Sums,
			Discount_Growth,
			Discount_Formula_Pricing,
			Bid_Rule_Option,
			Discount_BidRequest,
			Fixed_Rebate_Grid_Option,
			Enable_Program_Qualifications,
			Allow_Vendor_Only,
			RFP_Process
		FROM 
			Program_Control_Panel_Options
		WHERE 
			ProgramControl_Panel_Options_ID = '#trim(redirector_Program_ID)#'
	</cfquery>

	<!--- if pricing products by category redirect to category selection under products tab else redirect to the product search tool --->
	<CFIF GetSettingsRedirector.Rates_By_Category EQ 1>
		<CFSET Products_Page = "select_product_cats.cfm">
	<CFELSE>
		<CFSET Products_Page = "select_products.cfm">
	</CFIF>

	<!--- default page --->
	<CFSET redirector_NextLocation="contract_edit_menu.cfm">

	<CFSWITCH expression="#redirector_FromPage_ID#">

		<!--- From Basic Information --->
		<cfcase value="1">		
			
			<CFIF GetSettingsRedirector.Bid_Rule_Option EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Bids.cfm"></CFIF>
			<!--- <CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1>	<CFSET redirector_NextLocation="Formula_Pricing_Index.cfm"></CFIF> --->
			<CFIF GetSettingsRedirector.Discount_Growth 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Growth.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Lump_Sums 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Lump_Sums.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Rebates 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Rebates.cfm"></CFIF>
			
			<CFIF GetSettingsRedirector.Discount_Fixed_Prices 	EQ 1 and GetSettingsRedirector.Fixed_Rebate_Grid_Option neq 1>
				<CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1 AND appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1 AND GetSettingsRedirector.RFP_Process EQ 0>
					<CFSET redirector_NextLocation="/Common_Files/contracts/Formula/Fixed_Formula_Items.cfm">
				<CFELSEIF appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 and GetSettingsRedirector.RFP_Process EQ 1>   
					<cfset redirector_NextLocation = '/Common_Files/contracts/OPP/RFP_Form_Tabs.cfm'>
				<CFELSE>
					<CFIF appSettings.getFixedcomponents_on()>
						<CFSET redirector_NextLocation="Contract_Discount_Fixed_Component.cfm">
					<CFELSE>
						<CFSET redirector_NextLocation="Contract_Discount_Fixed_Prices.cfm">
					</CFIF>
				</CFIF>
			</CFIF>
			<!--- Dev Note: Kal; D43866: Disable auto-invoke for Rates page --->
			<cfif GetSettingsRedirector.Fixed_Rebate_Grid_Option eq 1>	<CFSET redirector_NextLocation="contract_edit_menu.cfm"></cfif>
			<CFIF GetSettingsRedirector.Generic_Type IS "Distributor Off-Invoice">	<CFSET redirector_NextLocation="off-invoice.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Specify_Brokers 		EQ 1 
				AND	Get_Profile_Settings.View_Broker_List EQ 1 AND variables.bShowBrokerLink>	<CFSET redirector_NextLocation="select_brokers.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Specify_Distributors 	EQ 1 AND variables.bShowDistributorLink>	<CFSET redirector_NextLocation="select_distributors.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Specify_Operators 		EQ 1 AND variables.bShowOperatorlink>	<CFSET redirector_NextLocation="select_Operators.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Allow_Vendor_Only EQ 1>	<CFSET redirector_NextLocation="select_vendors.cfm"></CFIF>
		</cfcase>

		<!--- From Operator Page --->
		<cfcase value="2">
			<CFIF GetSettingsRedirector.Bid_Rule_Option EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Bids.cfm"></CFIF>
			<!--- <CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1>	<CFSET redirector_NextLocation="Formula_Pricing_Index.cfm"></CFIF> --->
			<CFIF GetSettingsRedirector.Discount_Growth 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Growth.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Lump_Sums 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Lump_Sums.cfm"></CFIF>
			<!--- GetSettings.Fixed_Rebate_Grid_Option eq 1 --->
			<CFIF GetSettingsRedirector.Discount_Rebates 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Rebates.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Fixed_Prices 	EQ 1 and GetSettingsRedirector.Fixed_Rebate_Grid_Option neq 1>
				<CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1 AND appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1 and GetSettingsRedirector.RFP_Process EQ 0>
					<CFSET redirector_NextLocation="/Common_Files/contracts/Formula/Fixed_Formula_Items.cfm">
				<CFELSEIF appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 and GetSettingsRedirector.RFP_Process EQ 1>   
					<cfset redirector_NextLocation = '/Common_Files/contracts/OPP/RFP_Form_Tabs.cfm'>
				<CFELSE>	
					<CFIF appSettings.getFixedcomponents_on()>
						<CFSET redirector_NextLocation="Contract_Discount_Fixed_Component.cfm">
					<CFELSE>
						<CFSET redirector_NextLocation="Contract_Discount_Fixed_Prices.cfm">
					</CFIF>
				</CFIF>
			</CFIF>
			<!--- Dev Note: Kal; D43866: Disable auto-invoke for Rates page --->
			<cfif GetSettingsRedirector.Fixed_Rebate_Grid_Option eq 1>	<CFSET redirector_NextLocation="contract_edit_menu.cfm"></cfif>
			<CFIF GetSettingsRedirector.Generic_Type IS "Distributor Off-Invoice">	<CFSET redirector_NextLocation="off-invoice.cfm"></CFIF>
			<!---TSF: Modification Bid Request--->
			<CFIF GetSettingsRedirector.Generic_Type EQ "Bid Request" AND GetSettingsRedirector.Discount_BidRequest EQ 1>
			<CFIF appSettings.getBidRequestComponentsOn() eq 1>
					<CFSET redirector_NextLocation="/Common_Files/contracts/bid_request/bid_request_Component.cfm">
				<CFELSE>
					<CFSET redirector_NextLocation="/Common_Files/contracts/bid_request/bid_request.cfm">
				</CFIF>
			</CFIF>
			<CFIF GetSettingsRedirector.Specify_Brokers 		EQ 1 
				AND	Get_Profile_Settings.View_Broker_List EQ 1 AND variables.bShowBrokerLink>	<CFSET redirector_NextLocation="select_brokers.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Specify_Distributors 	EQ 1 AND variables.bShowDistributorLink>	<CFSET redirector_NextLocation="select_distributors.cfm"></CFIF>		
		</cfcase>

		<!--- From Distributors Page --->	
		<cfcase value="4">
			<!--- <CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1>	<CFSET redirector_NextLocation="Formula_Pricing_Index.cfm"></CFIF> --->
			<CFIF GetSettingsRedirector.Discount_Growth 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Growth.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Lump_Sums 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Lump_Sums.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Rebates 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Rebates.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Fixed_Prices 	EQ 1 and GetSettingsRedirector.Fixed_Rebate_Grid_Option neq 1>
				<CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1 AND appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1 and GetSettingsRedirector.RFP_Process EQ 0>
					<CFSET redirector_NextLocation="/Common_Files/contracts/Formula/Fixed_Formula_Items.cfm">
				<CFELSEIF appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 and GetSettingsRedirector.RFP_Process EQ 1>   
					<cfset redirector_NextLocation = '/Common_Files/contracts/OPP/RFP_Form_Tabs.cfm'>
				<CFELSE>
					<CFIF appSettings.getFixedcomponents_on()>
						<CFSET redirector_NextLocation="Contract_Discount_Fixed_Component.cfm">
					<CFELSE>
						<CFSET redirector_NextLocation="Contract_Discount_Fixed_Prices.cfm">
					</CFIF>
				</CFIF>
			</CFIF>
			<!--- Dev Note: Kal; D43866: Disable auto-invoke for Rates page --->
			<cfif GetSettingsRedirector.Fixed_Rebate_Grid_Option eq 1>	<CFSET redirector_NextLocation="contract_edit_menu.cfm"></cfif>
			<CFIF GetSettingsRedirector.Generic_Type IS "Distributor Off-Invoice">	<CFSET redirector_NextLocation="off-invoice.cfm"></CFIF>
			<!---TSF: Modification Bid Request--->
			<CFIF GetSettingsRedirector.Generic_Type EQ "Bid Request" AND GetSettingsRedirector.Discount_BidRequest EQ 1>	
			<CFIF appSettings.getBidRequestComponentsOn() eq 1>
					<CFSET redirector_NextLocation="/Common_Files/contracts/bid_request/bid_request_Component.cfm">
				<CFELSE>
					<CFSET redirector_NextLocation="/Common_Files/contracts/bid_request/bid_request.cfm">
				</CFIF>
			</CFIF>
			<CFIF GetSettingsRedirector.Specify_Brokers 		EQ 1 
				AND	Get_Profile_Settings.View_Broker_List EQ 1 AND variables.bShowBrokerLink>	<CFSET redirector_NextLocation="select_brokers.cfm"></CFIF>
		</cfcase>

		<!--- From Broker Page --->	
		<cfcase value="3">
			<CFIF GetSettingsRedirector.Bid_Rule_Option EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Bids.cfm"></CFIF>
			<!--- <CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1>	<CFSET redirector_NextLocation="Formula_Pricing_Index.cfm"></CFIF> --->
			<CFIF GetSettingsRedirector.Discount_Growth 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Growth.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Lump_Sums 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Lump_Sums.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Rebates 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Rebates.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Fixed_Prices 	EQ 1 and GetSettingsRedirector.Fixed_Rebate_Grid_Option neq 1>	
				<CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1 AND appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1 and GetSettingsRedirector.RFP_Process EQ 0>
					<CFSET redirector_NextLocation="/Common_Files/contracts/Formula/Fixed_Formula_Items.cfm">
				<CFELSEIF appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 and GetSettingsRedirector.RFP_Process EQ 1>   
					<cfset redirector_NextLocation = '/Common_Files/contracts/OPP/RFP_Form_Tabs.cfm'>
				<CFELSE>
					<CFIF appSettings.getFixedcomponents_on()>
						<CFSET redirector_NextLocation="Contract_Discount_Fixed_Component.cfm">
					<CFELSE>
						<CFSET redirector_NextLocation="Contract_Discount_Fixed_Prices.cfm">
					</CFIF>
				</CFIF>
			</CFIF>
			<!--- Dev Note: Kal; D43866: Disable auto-invoke for Rates page --->
			<cfif GetSettingsRedirector.Fixed_Rebate_Grid_Option eq 1>	<CFSET redirector_NextLocation="contract_edit_menu.cfm"></cfif>
			<CFIF GetSettingsRedirector.Generic_Type IS "Distributor Off-Invoice">	<CFSET redirector_NextLocation="off-invoice.cfm"></CFIF>
			<!---TSF: Modification Bid Request--->
			<CFIF GetSettingsRedirector.Generic_Type EQ "Bid Request" AND GetSettingsRedirector.Discount_BidRequest EQ 1>	
			<CFIF appSettings.getBidRequestComponentsOn() eq 1>
					<CFSET redirector_NextLocation="/Common_Files/contracts/bid_request/bid_request_Component.cfm">
				<CFELSE>
					<CFSET redirector_NextLocation="/Common_Files/contracts/bid_request/bid_request.cfm">
				</CFIF>
			</CFIF>
		</cfcase>


		<!--- From fixed prices Page --->	
		<cfcase value="5">
			<CFIF GetSettingsRedirector.Bid_Rule_Option EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Bids.cfm"></CFIF>
			<!--- <CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1>	<CFSET redirector_NextLocation="Formula_Pricing_Index.cfm"></CFIF> --->
			<CFIF GetSettingsRedirector.Discount_Growth 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Growth.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Lump_Sums 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Lump_Sums.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Rebates 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Rebates.cfm"></CFIF>
		</cfcase>

		<!--- From rebates Page --->	
		<cfcase value="6">
			<CFIF GetSettingsRedirector.Bid_Rule_Option EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Bids.cfm"></CFIF>
			<!--- <CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1>	<CFSET redirector_NextLocation="Formula_Pricing_Index.cfm"></CFIF> --->
			<!--- <cfif GetSettingsRedirector.Fixed_Rebate_Grid_Option eq 1>	<CFSET redirector_NextLocation="/flex/Program/ContractMain.cfm"></cfif> --->
			<CFIF GetSettingsRedirector.Discount_Growth 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Growth.cfm"></CFIF>
			<CFIF GetSettingsRedirector.Discount_Lump_Sums 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Lump_Sums.cfm"></CFIF>
		</cfcase>

		<!--- From lump sums Page --->	
		<cfcase value="7">
			<CFIF GetSettingsRedirector.Bid_Rule_Option EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Bids.cfm"></CFIF>
			<!--- <CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1>	<CFSET redirector_NextLocation="Formula_Pricing_Index.cfm"></CFIF> --->
			<!--- <cfif GetSettingsRedirector.Fixed_Rebate_Grid_Option eq 1>	<CFSET redirector_NextLocation="/flex/Program/ContractMain.cfm"></cfif> --->
			<CFIF GetSettingsRedirector.Discount_Growth 		EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Growth.cfm"></CFIF>
		</cfcase>

		<!---CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1>	<CFSET redirector_NextLocation="Formula_Pricing_Index.cfm"></CFIF--->	
		<!--- From Growth Page --->	
		<cfcase value="8">
			<CFIF GetSettingsRedirector.Bid_Rule_Option EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Bids.cfm"></CFIF>
			<!--- <CFIF GetSettingsRedirector.Discount_Formula_Pricing EQ 1>	<CFSET redirector_NextLocation="Formula_Pricing_Index.cfm"></CFIF> --->
			<!--- <cfif GetSettingsRedirector.Fixed_Rebate_Grid_Option eq 1>	<CFSET redirector_NextLocation="/flex/Program/ContractMain.cfm"></cfif> --->
			<CFSET redirector_NextLocation="contract_edit_menu.cfm">
		</cfcase>
		
		<!--- From Formula Pricing --->	
		<cfcase value="9">
			<CFIF GetSettingsRedirector.Bid_Rule_Option EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Bids.cfm"></CFIF>
		</cfcase>
		
		<!--- from bid page --->
		<cfcase value="10">
			<CFIF GetSettingsRedirector.Discount_Rebates EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Rebates.cfm">
			<CFELSE>
				<CFSET redirector_NextLocation="contract_edit_menu.cfm">
			</CFIF>
		</cfcase>

		<!--- from vendor page --->
		<cfcase value="11">
			<CFIF GetSettingsRedirector.Allow_Vendor_Only EQ 1>	<CFSET redirector_NextLocation="Contract_Discount_Lump_Sums.cfm">
			<CFELSE>
				<CFSET redirector_NextLocation="contract_edit_menu.cfm">
			</CFIF>
		</cfcase>
	</CFSWITCH>
<cfelse>
	No program_id was supplied for <CFOUTPUT>#CF_TEMPLATE_PATH#</CFOUTPUT>	
</cfif>

<!--- Dev Note: Kal; D44706: Program Qualifications Redirection --->	
<!--- When no other discount types are present and qualifications are on, only then display the qualifications popup. --->
<cfif GetSettingsRedirector.Enable_Program_Qualifications eq 1 AND redirector_NextLocation eq "contract_edit_menu.cfm"> 
		<cfset qualPopup = 1 /> 
</cfif>