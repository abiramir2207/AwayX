<cfoutput>SELECT     dbo.Price_List_Detail.Price_List_ID AS list_id, *, dbo.Price_List_Header.Price_List_Description AS Price_List_Desc
FROM         dbo.Price_List_Detail INNER JOIN
                      dbo.Price_List_Header ON dbo.Price_List_Detail.Price_List_Header_ID = dbo.Price_List_Header.Price_List_Header_ID
WHERE     (dbo.Price_List_Detail.Active_Code = 'A') AND Product_ID = '#FORM.BSA_Foodservice_Items_Master_ID#'
ORDER BY dbo.Price_List_Header.Price_List_Description</cfoutput>
