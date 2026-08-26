<cfquery name="getGeoBasedReport" datasource="#application.datasource#">
SELECT     dbo.Contract_Products.BSA_Foodservice_Items_Master_ID, dbo.USDANOI_Programs_Approved.Program_ID, 
                      dbo.Contract_Products.Contract_Products_ID, dbo.Operator_ZipCode_Map.Operator_Name, dbo.Operator_ZipCode_Map.City, 
                      dbo.Operator_ZipCode_Map.State, dbo.Operator_ZipCode_Map.StateCode, dbo.Operator_ZipCode_Map.County, dbo.Operator_ZipCode_Map.ZIPCode, 
                      dbo.USDANOI_Programs_Approved.Contract_Number, dbo.USDANOI_Program_Product_Detail.Item, 
                      dbo.USDANOI_Program_Product_Detail.Description, dbo.USDANOI_Program_Product_Detail.Net_Weight, 
                      dbo.USDANOI_Program_Product_Detail.Volume_LB, dbo.USDANOI_Program_Product_Detail.Volume_CS, 
                      dbo.ProgramDateSpanWeeks(dbo.USDANOI_Programs_Approved.Program_ID) + 1 AS ProgramDateSpanInWeeks, 
                      dbo.ProgramDateSpanDays(dbo.USDANOI_Programs_Approved.Program_ID) + 1 AS ProgramDateSpanInDays, dbo.Operator_ZipCode_Map.StateFIPS, 
                      dbo.Contract_Operators.BSA_Operator_ID
FROM         dbo.USDANOI_Programs_Approved INNER JOIN
                      dbo.Contract_Products ON dbo.USDANOI_Programs_Approved.Program_ID = dbo.Contract_Products.Contract_Main_ID INNER JOIN
                      dbo.Contract_Operators ON dbo.USDANOI_Programs_Approved.Program_ID = dbo.Contract_Operators.Contract_Main_ID INNER JOIN
                      dbo.Operator_ZipCode_Map ON dbo.Contract_Operators.BSA_Operator_ID = dbo.Operator_ZipCode_Map.BSA_Operator_ID INNER JOIN
                      dbo.USDANOI_Program_Product_Detail ON 
                      dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.USDANOI_Program_Product_Detail.BSA_Foodservice_Items_Master_ID AND 
                      dbo.Contract_Products.Contract_Main_ID = dbo.USDANOI_Program_Product_Detail.Program_ID
WHERE     (dbo.Contract_Products.Deleted = 0) AND (dbo.Contract_Operators.Deleted = 0)

#preservesinglequotes(whereclause)#

#orderby#

</cfquery>

<!--- <cfdump var="#getGeoBasedReport#"> --->