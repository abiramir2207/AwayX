<cfparam Name="DescSeparator" default=", ">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset reportDescription="">
	<!--------------------------- get geoFilter ---------------------------------->
	<cfset sSql="">
	<cfif IsDefined("rFilter") and IsDefined("rFilterValue")>
		<CFSET display_Value = "">
		<cfswitch expression="#rFilter#">
			<cfcase value="zone">
				<CFSET display_Value = "#application.returned_customer_setting.zone_label_singular#">
			</cfcase>
			<cfcase value="region">
				<CFSET display_Value = "#application.returned_customer_setting.region_label_singular#">
			</cfcase>						
			<cfcase value="broker">
				<CFSET display_Value = "#application.returned_customer_setting.broker_label_singular#">
			</cfcase>
		</cfswitch>
		<cfif rFilterValue NEQ -1>
			<cfswitch expression="#rFilter#">
				<cfcase value="zone">
					<cfset sSql="Select	sz.Zone_Name as itemValue From Service_Zones sz Where sz.Service_Zone_ID='#rFilterValue#'">
				</cfcase>
				<cfcase value="region">
					<cfset sSql="Select	sr.Region_Name as itemValue From Service_Regions sr Where sr.Service_Region_ID='#rFilterValue#'">
				</cfcase>						
				<cfcase value="broker">
					<cfset sSql="Select	Broker_Name as itemValue From BSA_Foodservice_Brokers Where BSA_Foodservice_Brokers_ID='#rFilterValue#'">
				</cfcase>							
			</cfswitch>
		<cfelse>
			<cfset reportDescription=ListAppend(reportDescription," all #display_Value#","#DescSeparator#")>
		</cfif>

		<cfif sSql NEQ "">
			<CFQUERY NAME="q_getDescValue" datasource="#application.datasource#">
				#PreserveSingleQuotes(sSql)#
			</CFQUERY>
			<cfif q_getDescValue.recordCount GT 0>
				<!-----<cfset reportDescription="#reportDescription##rFilter# - #Trim(q_getDescValue.itemValue)#">------->
				<cfset reportDescription=ListAppend(reportDescription," #display_Value# - #Trim(q_getDescValue.itemValue)#","#DescSeparator#")>
			</cfif>
		</cfif>
	</cfif>
	<!--------------------------- End get geoFilter ---------------------------------->
	
	<!--------------------------- get itemFilter ---------------------------------->
	<cfset sSql="">
	<cfif IsDefined("rFilterItems") and IsDefined("rFilterItemValue")>
		<CFSET display_Value = "">
		<cfswitch expression="#rFilterItems#">
			<cfcase value="typegroup">				
				<CFSET display_Value = "#application.returned_customer_setting.type_group_label_singular#">
			</cfcase>
			<cfcase value="qbrand">
				<CFSET display_Value = "#application.returned_customer_setting.q_brand_label_singular#">
			</cfcase>						
			<cfcase value="typecode">
				<CFSET display_Value = "#application.returned_customer_setting.type_code_label_singular#">
			</cfcase>
			<cfcase value="brand">
				<CFSET display_Value = "brand">
			</cfcase>
			<cfcase value="productGroup">
				<CFSET display_Value = "Product Group">
			</cfcase>
			<cfcase value="product">
				<CFSET display_Value = "product">
			</cfcase>
			<cfcase value="distributor">
				<CFSET display_Value = "#application.returned_customer_setting.distributor_label_plural#">
			</cfcase>	
			<cfcase value="family">
				<CFSET display_Value = "#application.returned_customer_setting.family_name_label_singular#">
			</cfcase>
			<cfcase value="buyinggroup">
				<CFSET display_Value = "#application.returned_customer_setting.buying_group_label_singular#">
			</cfcase>	
		</cfswitch>
		<cfif rFilterItemValue NEQ -1>
		<cfswitch expression="#rFilterItems#">
			<cfcase value="typegroup">				
				<cfset sSql="Select tg.Type_Group_Desc as itemValue From Type_Group_Desc tg Where tg.Type_Group_Desc_ID='#rFilterItemValue#'">
			</cfcase>
			<cfcase value="qbrand">
				<cfset sSql="Select qb.Q_Brand as itemValue From Q_Brand_Desc qb Where qb.Q_Brand_ID='#rFilterItemValue#'">
			</cfcase>						
			<cfcase value="typecode">
				<cfset sSql="Select tc.Type_Code_Desc as itemValue From Type_Code_Desc tc Where tc.Type_Code_Desc_ID='#rFilterItemValue#'">
			</cfcase>
			<cfcase value="brand">
				<cfset sSql="Select b.Brand_Name as itemValue From Brand b Where b.Brand_ID='#rFilterItemValue#'">
			</cfcase>
			<cfcase value="productGroup">
				<cfset sSql="Select pg.Product_Group_Desc as itemValue From BSA_Product_Group pg Where pg.BSA_Product_Group_ID='#rFilterItemValue#'">
			</cfcase>
			<cfcase value="product">
				<cfset sSql="Select pca.Description as itemValue From BSA_Foodservice_Items_Master pca Where pca.BSA_Foodservice_Items_Master_ID='#rFilterItemValue#'">
			</cfcase>
			<cfcase value="distributor">
				<cfset sSql="Select	BSA_Foodservice_Customers.Name as itemValue From BSA_Foodservice_Customers Where BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID='#rFilterItemValue#'">
			</cfcase>
			<cfcase value="family">
				<cfset sSql="Select	Distributor_Family.Family_Name as itemValue From Distributor_Family Where Distributor_Family.Family_ID='#rFilterItemValue#'">
			</cfcase>
			<cfcase value="buyinggroup">
				<cfset sSql="Select	Distributor_Buying_Groups.Buying_Group_Name as itemValue From Distributor_Buying_Groups Where Distributor_Buying_Groups.Buying_Group_ID='#rFilterItemValue#'">
			</cfcase>			
		</cfswitch>
		<cfelse>
			<cfset reportDescription=ListAppend(reportDescription," all #display_Value#","#DescSeparator#")>
		</cfif>
		

		<cfif sSql NEQ "">
			<CFQUERY NAME="q_getDescValue" datasource="#application.datasource#">
				#PreserveSingleQuotes(sSql)#
			</CFQUERY>
			<cfif q_getDescValue.recordCount GT 0>
				<cfset reportDescription=ListAppend(reportDescription," #display_Value# - #Trim(q_getDescValue.itemValue)#","#DescSeparator#")>
			</cfif>
		</cfif>		
	</cfif>
	<!--------------------------- End get itemFilter ---------------------------------->

	<!--------------------------- get Status ---------------------------------->
	<cfif rStatus NEQ -1>
		<cfset sSql="Select Contract_Status_Type_Desc as status From Contract_Status_Types Where Contract_Status_Type_ID in (#rStatus#)">
		<CFQUERY NAME="q_getDescValue" datasource="#application.datasource#">
			#PreserveSingleQuotes(sSql)#
		</CFQUERY>
		<cfif q_getDescValue.recordCount GT 0>
			<cfset tmpreportDescription="">
			<cfloop query="q_getDescValue">
				<cfset tmpreportDescription=ListAppend(tmpreportDescription,Trim(q_getDescValue.status),",")>				
			</cfloop>
			<cfset reportDescription=ListAppend(reportDescription," Status - #tmpreportDescription# ","#DescSeparator#")>
		</cfif>
	<cfelse>
		<cfset reportDescription=ListAppend(reportDescription," All Status","#DescSeparator#")>
	</cfif>
	<!--------------------------- End get Status ---------------------------------->
	
	<cfparam name="rOutputStartDate" 	default="">
	<cfparam name="rOutputStartDateOperatorSymbol" 	default="">
	<!--------------------------- get Start Date ---------------------------------->
	<cfif rOutputStartDate NEQ "" AND rOutputStartDateOperatorSymbol NEQ "">
		<cfset reportDescription=ListAppend(reportDescription," Start Date #rOutputStartDateOperatorSymbol# #rOutputStartDate# ","#DescSeparator#")>		
	</cfif>
	<!--------------------------- End get Start Date ---------------------------------->
	
	<cfparam name="rOutputEndDate" 	default="">
	<cfparam name="rOutputEndDateOperatorSymbol" 	default="">	
	<!--------------------------- get End Date ---------------------------------->
	<cfif rOutputEndDate NEQ "" AND rOutputEndDateOperatorSymbol NEQ "">
		<cfset reportDescription=ListAppend(reportDescription," End Date #rOutputEndDateOperatorSymbol# #rOutputEndDate# ","#DescSeparator#")>		
	</cfif>
	<!--------------------------- End get End Date ---------------------------------->
	
	<!--------------------------- get Business Segment ---------------------------------->
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfif businessSegManager.isEnabled()>
	<cfif rBusinessSegment NEQ -1>		
		<cfset q_getDescValue = businessSegManager.getList(rBusinessSegment)>
		
		<cfif q_getDescValue.recordCount GT 0>
			<cfset tmpreportDescription="">
			<cfloop query="q_getDescValue">
				<cfset tmpreportDescription=ListAppend(tmpreportDescription,Trim(q_getDescValue.Business_Unit_Desc),",")>				
			</cfloop>
			<cfset reportDescription=ListAppend(reportDescription," #appSettings.getbusiness_segment_label()# - #tmpreportDescription# ","#DescSeparator#")>
		</cfif>
	<cfelse>
		<cfset reportDescription=ListAppend(reportDescription," All Business Segment","#DescSeparator#")>
	</cfif>
	</cfif>
	<!--------------------------- End get Business Segment ---------------------------------->
	
	<!--------------------------- get discount identifier ---------------------------------->
	<cfset discountIdentifierManager = CreateObject("component","components.programs.discount_identifier.discountidentifier")>
	<cfif discountIdentifierManager.discountIdentifierOn()>
	<cfif rDiscountIdentifier NEQ -1>
		<cfset q_getDescValue = discountIdentifierManager.getCompFromList(rDiscountIdentifier)>
		
		<cfif q_getDescValue.recordCount GT 0>
			<cfset tmpreportDescription="">
			<cfloop query="q_getDescValue">
				<cfset tmpreportDescription=ListAppend(tmpreportDescription,Trim(q_getDescValue.Discount_Identifier_Desc),",")>				
			</cfloop>
			<cfset reportDescription=ListAppend(reportDescription," Discount Identifier - #tmpreportDescription# ","#DescSeparator#")>
		</cfif>
	<cfelse>
		<cfset reportDescription=ListAppend(reportDescription," All Discount Identifier","#DescSeparator#")>
	</cfif>
	</cfif>
	<!--------------------------- End get discount identifier ---------------------------------->
		
	<!--------------------------- get ProgramType ---------------------------------->
	<!------<cfif rProgramTypes NEQ -1>
		<cfset sSql="Select	Created_Type From Program_Control_Panel_Options Where ProgramControl_Panel_Options_ID in (#rProgramTypes#)">
		<CFQUERY NAME="q_getDescValue" datasource="#application.datasource#">
			#PreserveSingleQuotes(sSql)#
		</CFQUERY>
		<cfif q_getDescValue.recordCount GT 0>
			<cfset tmpreportDescription="">
			<cfloop query="q_getDescValue">
				<cfset tmpreportDescription=ListAppend(tmpreportDescription,Trim(q_getDescValue.Created_Type),",")>				
			</cfloop>
			<cfset reportDescription=ListAppend(reportDescription," Program Type - #tmpreportDescription# ","#DescSeparator#")>
		</cfif>
	<cfelse>
		<cfset reportDescription=ListAppend(reportDescription," All Program Types","#DescSeparator#")>
	</cfif>----->
	<!--------------------------- get ProgramType ---------------------------------->
	
	<!--------------------------- get Generic Type ---------------------------------->
	<cfif rGenericTypes NEQ -1>
		<cfset sSql="Select	Generic_Type From Generic_Type Where Generic_Type_ID in (#rGenericTypes#)">
		<CFQUERY NAME="q_getDescValue" datasource="#application.datasource#">
			#PreserveSingleQuotes(sSql)#
		</CFQUERY>
		<cfif q_getDescValue.recordCount GT 0>
			<cfset tmpreportDescription="">
			<cfloop query="q_getDescValue">
				<cfset tmpreportDescription=ListAppend(tmpreportDescription,Trim(q_getDescValue.Generic_Type),",")>				
			</cfloop>
			<cfset reportDescription=ListAppend(reportDescription," Generic Type - #tmpreportDescription# ","#DescSeparator#")>
		</cfif>
	<cfelse>
		<cfset reportDescription=ListAppend(reportDescription," All Generic Types","#DescSeparator#")>
	</cfif>
	<!--------------------------- get Generic Type ---------------------------------->
	
	
