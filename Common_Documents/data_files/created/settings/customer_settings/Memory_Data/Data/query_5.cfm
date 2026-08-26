<cfoutput>SELECT     dbo.Price_List_Header_Special.Ship_To AS list_id, dbo.Price_List_Header_Special.Description AS PRICE_LIST_DESC, 
                      dbo.Price_List_Detail_Special.LB_Bracket_1, dbo.Price_List_Detail_Special.LB_Bracket_2, dbo.Price_List_Detail_Special.LB_Bracket_3, 
                      dbo.Price_List_Detail_Special.LB_Bracket_4, dbo.Price_List_Detail_Special.LB_Bracket_5, dbo.Price_List_Detail_Special.CS_Bracket_1, 
                      dbo.Price_List_Detail_Special.CS_Bracket_2, dbo.Price_List_Detail_Special.CS_Bracket_3, dbo.Price_List_Detail_Special.CS_Bracket_4, 
                      dbo.Price_List_Detail_Special.CS_Bracket_5, dbo.Price_List_Detail_Special.LB_Bracket_AVG, dbo.Price_List_Detail_Special.CS_Bracket_AVG, 
                      dbo.Price_List_Detail_Special.LB_FOB_Price, dbo.Price_List_Detail_Special.CS_FOB_Price, dbo.Price_List_Detail_Special.LB_FOB_Price_AVG, 
                      dbo.Price_List_Detail_Special.CS_FOB_Price_AVG, dbo.Price_List_Detail_Special.Total_LB_Bracket_AVG, 
                      dbo.Price_List_Detail_Special.Total_CS_Bracket_AVG, dbo.Price_List_Detail_Special.Active_Code, dbo.Price_List_Detail_Special.Product_ID
FROM         dbo.Price_List_Detail_Special INNER JOIN
                      dbo.Price_List_Header_Special ON 
                      dbo.Price_List_Detail_Special.Price_List_Header_Special_ID = dbo.Price_List_Header_Special.Price_List_Header_Special_ID
WHERE     (dbo.Price_List_Detail_Special.Active_Code = 'A') AND (dbo.Price_List_Detail_Special.Product_ID = '#FORM.BSA_Foodservice_Items_Master_ID#')
ORDER BY dbo.Price_List_Header_Special.Description</cfoutput>
