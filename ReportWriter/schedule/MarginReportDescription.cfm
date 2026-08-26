<cfparam Name="DescSeparator" default=", ">
<cfset reportDescription="">
	<!--------------------------- get geoFilter ---------------------------------->
	<cfset sSql="">
	<cfif IsDefined("rFilterItem") and IsDefined("rFilterItemValue")>
		<CFSET display_Value = "">
		<cfswitch expression="#rFilterItem#">
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
		</cfswitch>
		<cfif rFilterItemValue NEQ -1>
		<cfswitch expression="#rFilterItem#">
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
	<cfif IsDefined("rFilterCust") and IsDefined("rFilterCustValue")>
		<CFSET display_Value = "">
		<cfswitch expression="#rFilterCust#">			
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
		<cfif rFilterCustValue NEQ -1>
		<cfswitch expression="#rFilterCust#">
			<cfcase value="family">				
				<cfset sSql="Select f.Family_Name as itemValue From	Distributor_Family f Where	f.family_ID='#rFilterCustValue#'">
			</cfcase>
			<cfcase value="buyinggroup">
				<cfset sSql="Select bg.Buying_Group_Name as itemValue From	Distributor_Buying_Groups bg Where	bg.buying_group_ID='#rFilterCustValue#'">
			</cfcase>						
			<cfcase value="distributor">
				<cfset sSql="Select cla.Name as itemValue From customer_lob_active cla Where cla.BSA_FoodService_Customers_ID='#rFilterCustValue#'">
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

	
	<!--------------------------- get Margin filter ---------------------------------->
	<CFSET marginDesc="">
	<CFSWITCH expression="#rMarginOption#">
		<CFCASE value="GT">		
			<CFIF IsNumeric(rMarginValue1)>
				<CFSET marginDesc=">= $#rMarginValue1#">
			</CFIF>
		</CFCASE>
		<CFCASE value="LT">
			<CFIF IsNumeric(rMarginValue1)>
				<CFSET marginDesc="<= $#rMarginValue1#">
			</CFIF>
		</CFCASE>
		<CFCASE value="BTW">
			<CFIF IsNumeric(rMarginValue1) AND IsNumeric(rMarginValue2)>
				<CFIF rMarginValue1 GT rMarginValue2>
					<CFSET temp				=	rMarginValue2>
					<CFSET rMarginValue2	=	rMarginValue1>
					<CFSET rMarginValue1	=	temp>
				</CFIF>
				<CFSET marginDesc="Between $#rMarginValue1# and $#rMarginValue2#">
			</CFIF>
		</CFCASE>
	</CFSWITCH>
	<CFIF Len(marginDesc) GT 0>
		<cfset reportDescription=ListAppend(reportDescription," Margin #marginDesc#","#DescSeparator#")>
	</CFIF>
	<!--------------------------- get Margin filter ---------------------------------->