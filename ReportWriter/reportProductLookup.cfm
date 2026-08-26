<!--------------------- get lookup table data reportProductLookup.cfm---------------------------------->

<!-----------------------------------------------------------------------
Get Type Group from DB
--------------------------------------------------------------------------->
<!------ <CFQUERY NAME="q_getTypeGroups" datasource="#application.datasource#">
Select 	distinct tg.Type_Group_Desc_ID,tg.Type_Group_Desc
From	Type_Group_Desc tg, product_category_lob_active pcla
Where	pcla.Type_Group_Desc_ID=tg.Type_Group_Desc_ID	
		and tg.Deleted=0
Order By tg.Type_Group_Desc
</CFQUERY> ----->
<CFQUERY NAME="q_getTypeGroups" datasource="#application.datasource#">
	Select 	distinct Type_Group_Desc.Type_Group_Desc_ID,Type_Group_Desc.Type_Group_Desc
			<cfif businessSegEnabled>
			+ ' (' + 
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			(CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END)
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
			 + ')'
			AS Type_Group_Desc
			</cfif>
			,
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END AS Business_Unit_Desc
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
	From	Type_Group_Desc
			INNER JOIN product_category_lob_active
			ON	product_category_lob_active.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
			LEFT JOIN	Business_Segment
			ON	Business_Segment.Business_Segment_ID = Type_Group_Desc.Business_Segment_ID
	Where	Type_Group_Desc.Deleted=0
	Order By Type_Group_Desc.Type_Group_Desc
</CFQUERY>
<!-----------------------------------------------------------------------
End - Type Group from DB
--------------------------------------------------------------------------->

<!-----------------------------------------------------------------------
Get Q Brand from DB
--------------------------------------------------------------------------->

<cfif application.returned_customer_setting.use_product_q_brand EQ 1>

<CFQUERY NAME="q_getQBrands" datasource="#application.datasource#">
	<!------ <CFINCLUDE TEMPLATE="#application.returned_customer_setting.qry_q_brand_list#"> ----->
	Select 	distinct Q_Brand_Desc.Q_Brand_ID, Q_Brand_Desc.Q_Brand
			<cfif businessSegEnabled>
			+ ' (' + 
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			(CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END)
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
			 + ')'
			AS Q_Brand
			</cfif>
			, Product_Q_Brand_Desc.LOB,
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END AS Business_Unit_Desc
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
	From	Product_Q_Brand_Desc 
			INNER JOIN 	product_category_lob_active
			ON	product_category_lob_active.BSA_Foodservice_Items_Master_ID=Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID
			AND	Product_Q_Brand_Desc.LOB='F'
			INNER JOIN 	Q_Brand_Desc
			ON	Q_Brand_Desc.Deleted=0
			AND	Product_Q_Brand_Desc.Q_Brand_ID=Q_Brand_Desc.Q_Brand_ID
			LEFT JOIN	Business_Segment
			ON	Business_Segment.Business_Segment_ID = Q_Brand_Desc.Business_Segment_ID
	Where	
			Product_Q_Brand_Desc.Deleted=0
</CFQUERY>

<cfelse>

<CFQUERY NAME="q_getQBrands" datasource="#application.datasource#">
	<!------ <CFINCLUDE TEMPLATE="#application.returned_customer_setting.qry_q_brand_list#"> ----->
	Select 	distinct Q_Brand_Desc.Q_Brand_ID, Q_Brand_Desc.Q_Brand
			<cfif businessSegEnabled>
			+ ' (' + 
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			(CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END)
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
			 + ')'
			AS Q_Brand
			</cfif>
			, 'F' AS LOB,
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END AS Business_Unit_Desc
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
	From	Q_Brand_Desc 
			INNER JOIN 	product_category_lob_active
			ON	product_category_lob_active.Q_Brand_ID=Q_Brand_Desc.Q_Brand_ID
			LEFT JOIN	Business_Segment
			ON	Business_Segment.Business_Segment_ID = Q_Brand_Desc.Business_Segment_ID
	Where	
			Q_Brand_Desc.Deleted=0
</CFQUERY>

</cfif>
<!-----------------------------------------------------------------------
End - Q Brand from DB
--------------------------------------------------------------------------->


<!-----------------------------------------------------------------------
Get Type Code from DB
--------------------------------------------------------------------------->
<!------ <CFQUERY NAME="q_getTypeCodes" datasource="#application.datasource#">
	Select	distinct tc.Type_Code_Desc_ID,tc.Type_Code_Desc
	From	Type_Code_Desc tc,product_category_lob_active pcla
	Where	pcla.Type_Code_Desc_ID=tc.Type_Code_Desc_ID
			and tc.Deleted=0
	Order By tc.Type_Code_Desc
</CFQUERY> ----->
<CFQUERY NAME="q_getTypeCodes" datasource="#application.datasource#">
	Select	distinct Type_Code_Desc.Type_Code_Desc_ID,Type_Code_Desc.Type_Code_Desc
			<cfif businessSegEnabled>
			+ ' (' + 
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			(CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END)
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
			 + ')'
			AS Type_Code_Desc
			</cfif>
			,
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END AS Business_Unit_Desc
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
	From	Type_Code_Desc
			INNER JOIN product_category_lob_active
			ON	product_category_lob_active.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID
			LEFT JOIN	Business_Segment
			ON	Business_Segment.Business_Segment_ID = Type_Code_Desc.Business_Segment_ID
	Where	Type_Code_Desc.Deleted=0
	Order By Type_Code_Desc.Type_Code_Desc
</CFQUERY>
<!-----------------------------------------------------------------------
End - Type Code from DB
--------------------------------------------------------------------------->

<!-----------------------------------------------------------------------
Get Brand from DB
<!------ --------------------------------------------------------------------------->
<CFQUERY NAME="q_getBrands" datasource="#application.datasource#">
Select	distinct b.Brand_ID,b.Brand_Name
From	Brand b,product_category_lob_active pcla
Where	pcla.Brand_ID=b.Brand_ID
		and b.Deleted=0
Order By b.Brand_Name
</CFQUERY> ----->
<!---------------------------------------------------------------------------->
<CFQUERY NAME="q_getBrands" datasource="#application.datasource#">
	Select	distinct Brand.Brand_ID, Brand.Brand_Name
			<cfif businessSegEnabled>
			+ ' (' + 
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			(CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END)
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
			 + ')'
			AS Brand_Name
			</cfif>
			,
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END AS Business_Unit_Desc
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
	From	Brand
			INNER JOIN	product_category_lob_active
			ON	product_category_lob_active.Brand_ID = Brand.Brand_ID
			LEFT JOIN	Business_Segment
			ON	Business_Segment.Business_Segment_ID = Brand.Business_Segment_ID
	Where	Brand.Deleted=0
	Order By Brand.Brand_Name
</CFQUERY>
<!-----------------------------------------------------------------------
End - Type Code from DB
--------------------------------------------------------------------------->

<cfset productGroupIsOn = 0>
<cfquery name="qGetProductGroupExist1" datasource="#application.datasource#">
SELECT	*
FROM	INFORMATION_SCHEMA.TABLES
WHERE	TABLE_NAME = 'BSA_Product_Group'
</cfquery>
<cfquery name="qGetProductGroupExist2" datasource="#application.datasource#">
SELECT	*
FROM	INFORMATION_SCHEMA.COLUMNS
WHERE	COLUMN_NAME = 'BSA_Product_Group_ID'
		AND TABLE_NAME = 'BSA_Foodservice_Items_Master'
</cfquery>
<cfif qGetProductGroupExist1.recordCount AND qGetProductGroupExist2.recordCount>
	<cfset productGroupIsOn = 1>
</cfif>
<cfif productGroupIsOn>
<!---------------------------------------------------------------------------->
<CFQUERY NAME="q_getProductGroups" datasource="#application.datasource#">
	Select	distinct BSA_Product_Group.BSA_Product_Group_ID, BSA_Product_Group.Product_Group_Desc
			<cfif businessSegEnabled>
			+ ' (' + 
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			(CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END)
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
			 + ')'
			AS Product_Group_Desc
			</cfif>
			,
			<cfif application.returned_customer_setting.customer_keyword IS "conagra">
			CASE
			WHEN	Business_Segment.Business_Segment_ID = 1 THEN
				'Other'
			ELSE
				Business_Segment.Business_Unit_Desc
			END AS Business_Unit_Desc
			<cfelse>Business_Segment.Business_Unit_Desc
			</cfif>
	From	BSA_Product_Group
			INNER JOIN	product_category_lob_active
			ON	product_category_lob_active.BSA_Product_Group_ID = BSA_Product_Group.BSA_Product_Group_ID
			LEFT JOIN	Business_Segment
			ON	Business_Segment.Business_Segment_ID = BSA_Product_Group.Business_Segment_ID
	Where	BSA_Product_Group.Deleted=0
	Order By BSA_Product_Group.Product_Group_Desc
</CFQUERY>
</cfif>