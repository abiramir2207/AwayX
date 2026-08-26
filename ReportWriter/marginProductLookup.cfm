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
<CFQUERY NAME="q_getDistributors" datasource="#application.datasource#">
Select 	distinct cla.BSA_FoodService_Customers_ID,cla.Name
From	customer_lob_active cla
Order By cla.Name</CFQUERY>
<!-----------------------------------------------------------------------
End - Distributors from DB
--------------------------------------------------------------------------->


<cfinclude template="reportProductLookup.cfm">
