<!--------------------- get lookup table data reportProductLookup.cfm---------------------------------->

<!-----------------------------------------------------------------------
Get family from DB
--------------------------------------------------------------------------->
<CFQUERY NAME="q_getFamilys" datasource="#application.datasource#">
Select 	distinct f.family_ID,f.Family_Name
From	Distributor_Family f, customer_lob_active cla
Where	cla.family_ID=f.family_ID
		and f.Deleted=0
Order By f.Family_Name
</CFQUERY>
<!-----------------------------------------------------------------------
End - family from DB
--------------------------------------------------------------------------->

<!-----------------------------------------------------------------------
Get BuyingGroup from DB
--------------------------------------------------------------------------->
<CFQUERY NAME="q_getBuyingGroups" datasource="#application.datasource#">
Select 	distinct bg.Buying_Group_ID,bg.Buying_Group_Name
From	Distributor_Buying_Groups bg, customer_lob_active cla
Where	cla.buying_group_ID=bg.buying_group_ID
		and bg.Deleted=0 and bg.active_code='A'
Order By bg.Buying_Group_Name
</CFQUERY>
<!-----------------------------------------------------------------------
End - BuyingGroup from DB
--------------------------------------------------------------------------->

<!-----------------------------------------------------------------------
Get Distributors from DB
--------------------------------------------------------------------------->
<!----------
<CFQUERY NAME="q_getDistributors" datasource="#application.datasource#">
Select 	distinct cla.BSA_FoodService_Customers_ID,cla.Name
From	customer_lob_active cla
Order By cla.Name</CFQUERY>
----------->
<!-----------------------------------------------------------------------
End - Distributors from DB
--------------------------------------------------------------------------->

<!-----------------------------------------------------------------------
Get Zones from DB
--------------------------------------------------------------------------->
<CFQUERY NAME="q_getZones" datasource="#application.datasource#">
Select	distinct sz.Service_Zone_ID, sz.Zone_Name
From 	Service_Zones sz,broker_lob_active bla
Where	sz.Deleted=0
		and bla.Service_Zone_ID=sz.Service_Zone_ID
Order By sz.Zone_Name
</CFQUERY>

<!-----------------------------------------------------------------------
End - Get Zones from DB
--------------------------------------------------------------------------->
<!-----------------------------------------------------------------------
Get Regions from DB
--------------------------------------------------------------------------->
<CFQUERY NAME="q_getRegions" datasource="#application.datasource#">
Select	distinct sr.Service_Region_ID, sr.Region_Name
From 	Service_Regions sr,broker_lob_active bla
Where	sr.Deleted=0
		and bla.Service_Region_ID=sr.Service_Region_ID
Order By sr.Region_Name
</CFQUERY>
<!-----------------------------------------------------------------------
End - Get Regions from DB
--------------------------------------------------------------------------->
<!-----------------------------------------------------------------------
Get Brokers from DB
--------------------------------------------------------------------------->
<!--------
<CFQUERY NAME="q_getBrokers" datasource="#application.datasource#">
Select	bla.BSA_Foodservice_Brokers_ID,bla.Broker_Name
From 	broker_lob_active bla
Order By cfb.Broker_Name
</CFQUERY>
--------->
<!-----------------------------------------------------------------------
End - Get Brokers from DB
--------------------------------------------------------------------------->
