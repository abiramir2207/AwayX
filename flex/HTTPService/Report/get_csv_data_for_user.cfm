<cfsilent>
<!--- 
get_csv_data_for_user.cfm 
This file will be called from the flex tool
It is used by export to CSV button
--->
<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfheader name="Cache-Control" value="no-store">
<cfheader name="expires" value="#now()#">
</cfsilent>

<cfset oEffectiveNetPriceReport = CreateObject("component", "mvc.models.reports.EffectiveNetPriceReport.EffectiveNetPriceReport") />
<cfset oSettings = oEffectiveNetPriceReport.getSettingsObject() />

<!--- header start --->
<cfoutput>#oSettings.appflex.shardshiptolabel#,</cfoutput>
<cfoutput>#oSettings.appflex.distributorlabel#,</cfoutput>
<cfoutput>#oSettings.appflex.itemlabel#,</cfoutput>
<cfoutput>Description,</cfoutput>
<cfoutput>#oSettings.appflex.familylabel#,</cfoutput>
<cfoutput>#oSettings.appflex.buyinggrouplabel#,</cfoutput>
<cfoutput>#oSettings.appflex.regionlabel#,</cfoutput>
<cfoutput>#oSettings.appflex.brokerlabel#,</cfoutput>
<cfoutput>#oSettings.appflex.typecodelabel#,</cfoutput>
<cfoutput>INV CS,INV LB,INV $,PRICE CS,PRICE LB,</cfoutput>
<cfoutput>TRADE CS,TRADE LB,OPER CS,OPER LB,TOTAL $ CS,TOTAL $ LB,</cfoutput>
<cfoutput>TRADE %,OPER %,TOTAL % DISC,</cfoutput>
<cfoutput>NET CS,NET LB,AVE NET CS,AVE NET LB,NET INDEX,RETURN ON NET</cfoutput>
<cfoutput>#chr(13)##chr(10)#</cfoutput>
<!--- header end --->

<cfif isDefined("form.userId")>
<cfset marketIdList = oEffectiveNetPriceReport.getBelowMarketIDList(userId = form.userId) />
<CFQUERY NAME="getData" DATASOURCE="#Application.Datasource#">
	SELECT 	Distributor_ID,
			Distributor_Name,
			Broker_Name,
			Region_Name,
			Family_Name,
			Buying_Group_Name,
			Item,
			Item_Description,
			Type_Code_Desc,
			Cases_Invoiced,
			Pounds_Invoiced,
			Sales_Dollar,
			Base_Sales_CS,
			Base_Sales_LB,
			Trade_Rate_CS,
			Trade_Rate_LB,
			Operator_Rate_CS,
			Operator_Rate_LB,
			Total_Rate_CS,
			Total_Rate_LB,
			Trade_PERCENT_DISCOUNT,
			Operator_PERCENT_DISCOUNT,
			Total_PERCENT_DISCOUNT,
			Total_Net_Sales_CS,
			Total_Net_Sales_LB,
			Total_AVG_Net_Sales_CS,
			Total_AVG_Net_Sales_LB,
			--Total_Net_Sales_Index,
			Total_Return_On_Sales
	FROM	EFFECTIVE_SPENDING_RATE_EXTRACT_DATA
	WHERE	Item <> ''
	<cfif marketIdList neq ""><!--- not HQ --->
	AND		Service_Market_ID IN (#marketIdList#)
	</cfif>
</CFQUERY>
 

<!--- data start --->
<cfloop query="getData">
<cfoutput>#Distributor_ID#,</cfoutput>
<cfoutput>#Distributor_Name#,</cfoutput>
<cfoutput>#Broker_Name#,</cfoutput>
<cfoutput>#Region_Name#,</cfoutput>
<cfoutput>#Family_Name#,</cfoutput>
<cfoutput>#Buying_Group_Name#,</cfoutput>
<cfoutput>#Item#,</cfoutput>
<cfoutput>#Item_Description#,</cfoutput>
<cfoutput>#Type_Code_Desc#,</cfoutput>
<cfoutput>#Cases_Invoiced#,</cfoutput>
<cfoutput>#Pounds_Invoiced#,</cfoutput>
<cfoutput>#Sales_Dollar#,</cfoutput>
<cfoutput>#Base_Sales_CS#,</cfoutput>
<cfoutput>#Base_Sales_LB#,</cfoutput>
<cfoutput>#Trade_Rate_CS#,</cfoutput>
<cfoutput>#Trade_Rate_LB#,</cfoutput>
<cfoutput>#Operator_Rate_CS#,</cfoutput>
<cfoutput>#Operator_Rate_LB#,</cfoutput>
<cfoutput>#Total_Rate_CS#,</cfoutput>
<cfoutput>#Total_Rate_LB#,</cfoutput>
<cfoutput>#Trade_PERCENT_DISCOUNT#,</cfoutput>
<cfoutput>#Operator_PERCENT_DISCOUNT#,</cfoutput>
<cfoutput>#Total_PERCENT_DISCOUNT#,</cfoutput>
<cfoutput>#Total_Net_Sales_CS#,</cfoutput>
<cfoutput>#Total_Net_Sales_LB#,</cfoutput>
<cfoutput>#Total_AVG_Net_Sales_CS#,</cfoutput>
<cfoutput>#Total_AVG_Net_Sales_LB#,</cfoutput>
<cfoutput>,</cfoutput>
<!---<cfoutput>#Total_Net_Sales_Index#,</cfoutput>--->
<cfoutput>#Total_Return_On_Sales#</cfoutput>
<cfoutput>#chr(13)##chr(10)#</cfoutput>
</cfloop>
<!--- data end --->
</cfif>