<cfoutput>SELECT     dbo.BSA_Foodservice_Items_Master.Item, dbo.BSA_Foodservice_Items_Master.UPC, dbo.BSA_Foodservice_Items_Master.Description, 
                      dbo.BSA_Foodservice_Items_Master.Line_Of_Business_ID, dbo.BSA_Foodservice_Items_Master.Active_Code, 
                      dbo.Type_Code_Desc.Type_Code_Desc, dbo.Type_Group_Desc.Type_Group_Desc, dbo.Brand.Brand_Name, 
                      dbo.BSA_Foodservice_Items_Master.Catch_Weight, dbo.BSA_Foodservice_Items_Master.Gross_Weight, 
                      dbo.BSA_Foodservice_Items_Master.Net_Weight, dbo.Line_Of_Business.Line_Of_Business_Name, dbo.Line_Of_Business.Line_Of_Business, 
                      dbo.Q_Brand_Desc.Q_Brand
FROM         dbo.BSA_Foodservice_Items_Master INNER JOIN
                      dbo.Type_Code_Desc ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID INNER JOIN
                      dbo.Type_Group_Desc ON dbo.BSA_Foodservice_Items_Master.Type_Group_Desc_ID = dbo.Type_Group_Desc.Type_Group_Desc_ID INNER JOIN
                      dbo.Brand ON dbo.BSA_Foodservice_Items_Master.Brand_ID = dbo.Brand.Brand_ID INNER JOIN
                      dbo.Line_Of_Business ON dbo.BSA_Foodservice_Items_Master.Line_Of_Business_ID = dbo.Line_Of_Business.Line_Of_Business_ID INNER JOIN
                      dbo.Product_Q_Brand_Desc ON 
                      dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = dbo.Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID
                       AND dbo.Line_Of_Business.Line_Of_Business = dbo.Product_Q_Brand_Desc.LOB INNER JOIN
                      dbo.Q_Brand_Desc ON dbo.Product_Q_Brand_Desc.Q_Brand_ID = dbo.Q_Brand_Desc.Q_Brand_ID
 Where		dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID		=		'#ID#'</cfoutput>
