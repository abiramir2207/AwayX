<cfparam Name="DescSeparator" default="<br>">
<cfset reportDescription="">


	<!--------------------------- get geoFilter ---------------------------------->
	<cfset sSql="">
	<cfif IsDefined("Form.rFilter")>		
		<cfswitch expression="#Form.rFilter#">
			<cfcase value="zone">
				<cfif Form.rZones NEQ -1>
					<cfset sSql="Select	sz.Zone_Name as itemValue From Service_Zones sz Where sz.Service_Zone_ID='#Form.rZones#'">
				<cfelse>
					<cfset reportDescription="#reportDescription#all #Form.rFilter#s">
				</cfif>
			</cfcase>
			<cfcase value="region">
				<cfif Form.rRegions NEQ -1>
					<cfset sSql="Select	sr.Region_Name as itemValue From Service_Regions sr Where sr.Service_Region_ID='#Form.rRegions#'">
				<cfelse>
					<cfset reportDescription="#reportDescription#all #Form.rFilter#s">
				</cfif>
			</cfcase>						
			<cfcase value="broker">
				<cfif Form.rBrokers NEQ -1>
					<cfset sSql="Select	Broker_Name as itemValue From BSA_Foodservice_Brokers Where BSA_Foodservice_Brokers_ID='#Form.rBrokers#'">
				<cfelse>
					<cfset reportDescription="#reportDescription#all #Form.rFilter#s">
				</cfif>
			</cfcase>
		</cfswitch>

		<cfif sSql NEQ "">
			<CFQUERY NAME="q_getDescValue" datasource="#application.datasource#">
				#PreserveSingleQuotes(sSql)#
			</CFQUERY>
			<cfif q_getDescValue.recordCount GT 0>
				<cfset reportDescription="#reportDescription##Form.rFilter# - #Trim(q_getDescValue.itemValue)#">
			</cfif>
		</cfif>		
	</cfif>
	<!--------------------------- End get geoFilter ---------------------------------->
	
	<!--------------------------- get itemFilter ---------------------------------->
	<cfset sSql="">
	<cfif IsDefined("Form.rFilterItems")>		
		<cfswitch expression="#Form.rFilterItems#">
			<cfcase value="typegroup">
				<cfif Form.rTypegroups NEQ -1>
					<cfset sSql="Select tg.Type_Group_Desc as itemValue From Type_Group_Desc tg Where tg.Type_Group_Desc_ID='#Form.rtypegroups#'">
				<cfelse>
					<cfset reportDescription="#reportDescription##DescSeparator#all #Form.rFilterItems#s">
				</cfif>
			</cfcase>
			<cfcase value="qbrand">
				<cfif Form.rQBrands NEQ -1>
					<cfset sSql="Select qb.Q_Brand as itemValue From Q_Brand_Desc qb Where qb.Q_Brand_ID='#Form.rqbrands#'">
				<cfelse>
					<cfset reportDescription="#reportDescription##DescSeparator#all #Form.rFilterItems#s">
				</cfif>
			</cfcase>						
			<cfcase value="typecode">
				<cfif Form.rTypeCodes NEQ -1>
					<cfset sSql="Select tc.Type_Code_Desc as itemValue From Type_Code_Desc tc Where tc.Type_Code_Desc_ID='#Form.rtypecodes#'">
				<cfelse>
					<cfset reportDescription="#reportDescription##DescSeparator#all #Form.rFilterItems#s">
				</cfif>
			</cfcase>
			<cfcase value="brand">
				<cfif Form.rBrands NEQ -1>
					<cfset sSql="Select b.Brand_Name as itemValue From Brand b Where b.Brand_ID='#Form.rbrands#'">
				<cfelse>
					<cfset reportDescription="#reportDescription##DescSeparator#all #Form.rFilterItems#s">
				</cfif>
			</cfcase>
		</cfswitch>
		<cfif sSql NEQ "">
			<CFQUERY NAME="q_getDescValue" datasource="#application.datasource#">
				#PreserveSingleQuotes(sSql)#
			</CFQUERY>
			<cfif q_getDescValue.recordCount GT 0>
				<cfset reportDescription="#reportDescription##DescSeparator##Form.rFilterItems# - #Trim(q_getDescValue.itemValue)#">
			</cfif>
		</cfif>		
	</cfif>
	<!--------------------------- End get itemFilter ---------------------------------->

	<!--------------------------- get Status ---------------------------------->
	<cfif Form.rStatus NEQ -1>
		<cfset sSql="Select Contract_Status_Type_Desc as status From Contract_Status_Types Where Contract_Status_Type_ID=#Form.rStatus#">
		<CFQUERY NAME="q_getDescValue" datasource="#application.datasource#">
			#PreserveSingleQuotes(sSql)#
		</CFQUERY>
		<cfif q_getDescValue.recordCount GT 0>
			<cfset reportDescription="#reportDescription##DescSeparator#Status - #Trim(q_getDescValue.status)#">
		</cfif>
	</cfif>
	<!--------------------------- End get Status ---------------------------------->
		
	<!--------------------------- get ProgramType ---------------------------------->
	<cfif Form.rProgramTypes NEQ -1>
		<cfset sSql="Select	Created_Type From Program_Control_Panel_Options Where ProgramControl_Panel_Options_ID='#Form.rProgramTypes#'">
		<CFQUERY NAME="q_getDescValue" datasource="#application.datasource#">
			#PreserveSingleQuotes(sSql)#
		</CFQUERY>
		<cfif q_getDescValue.recordCount GT 0>
			<cfset reportDescription="#reportDescription##DescSeparator#Program Type - #Trim(q_getDescValue.Created_Type)#">
		</cfif>
	</cfif>
	<!--------------------------- get ProgramType ---------------------------------->
	