<cfoutput>Select 	Distinct Q_Brand_Desc.Q_Brand_ID, Q_Brand_Desc.Q_Brand, Product_Q_Brand_Desc.LOB
From	Product_Q_Brand_Desc, Q_Brand_Desc, product_category_lob_active
Where	Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID=product_category_lob_active.BSA_Foodservice_Items_Master_ID
	and	Product_Q_Brand_Desc.Q_Brand_ID=Q_Brand_Desc.Q_Brand_ID
	and	Product_Q_Brand_Desc.LOB IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#)
	and 	Product_Q_Brand_Desc.Deleted=0
	and 	Q_Brand_Desc.Deleted=0
	Order By Q_Brand_Desc.Q_Brand</cfoutput>
