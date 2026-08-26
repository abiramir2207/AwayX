<!-----------------------------------------------------------------------------

FILE NAME:		view_market_purchase_filter.cfm
DESCRIPTION:	Displays the Position_ID and budgets selected
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	21-Apr-2015	

------------------------------------------------------------------------------> 
<CFSET PAGETITLE = "#application.returned_customer_setting.market_label_singular# Purchase Filter">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<html>
<head>
	<title>View Purchase Filter</title>
</head>

<body>

 <cfquery name="vars.getMarketPurchaseFilter" datasource="#application.datasource#">
	 SELECT Up.* 
             , Business_Segment.Business_Unit_Desc
             ,Budget.Budget_code, Budget.Budget_Desc
      FROM ( SELECT User_Positions.Position_Label
                    , User_Positions.User_Positions_Id
                    , Service_Zones.Zone_Name
                    , Service_Regions.Region_Name
                    , Service_Markets.Market_Name
                    , User_Positions.Service_Zone_Id
                    , User_Positions.Service_Region_Id
                    , User_Positions.Service_Market_Id
                    , User_Positions.Deleted
                    , Position_Number = CASE
                                          WHEN User_Positions.Service_Market_Id IS NOT NULL THEN Service_Markets.Market_Number
                                          WHEN User_Positions.Service_Region_Id IS NOT NULL
                                               AND User_Positions.Service_Market_Id IS NULL THEN Service_Regions.Region_Number
                                          WHEN User_Positions.Service_Zone_Id IS NOT NULL
                                               AND User_Positions.Service_Region_Id IS NULL
                                               AND User_Positions.Service_Market_Id IS NULL THEN Service_Zones.Zone_Number
                                          ELSE 'HQ'
                                        END
                    , Position_Level = CASE
                                         WHEN User_Positions.Service_Market_Id IS NOT NULL THEN 3
                                         WHEN User_Positions.Service_Region_Id IS NOT NULL
                                              AND User_Positions.Service_Market_Id IS NULL THEN 2
                                         WHEN User_Positions.Service_Zone_Id IS NOT NULL
                                              AND User_Positions.Service_Region_Id IS NULL
                                              AND User_Positions.Service_Market_Id IS NULL THEN 1
                                         ELSE 0
                                       END
                    , Business_Segment_Id = CASE
                                              WHEN User_Positions.Service_Market_Id IS NOT NULL THEN Service_Markets.Business_Segment_Id
                                              WHEN User_Positions.Service_Market_Id IS NULL
                                                   AND User_Positions.Service_Region_Id IS NOT NULL THEN Service_Regions.Business_Segment_Id
                                              WHEN User_Positions.Service_Market_Id IS NULL
                                                   AND User_Positions.Service_Region_Id IS NULL
                                                   AND User_Positions.Service_Zone_Id IS NOT NULL THEN Service_Zones.Business_Segment_Id
                                              ELSE 0
                                            END
               FROM User_Positions
                    LEFT JOIN Service_Zones
                      ON Service_Zones.Service_Zone_Id = User_Positions.Service_Zone_Id
                    LEFT JOIN Service_Regions
                      ON Service_Regions.Service_Region_Id = User_Positions.Service_Region_Id
                    LEFT JOIN Service_Markets
                      ON Service_Markets.Service_Market_Id = User_Positions.Service_Market_Id
              WHERE 1 = 1

                    AND LEN(User_Positions.Position_Label) > 0
                      AND User_Positions.User_Positions_ID IN (SELECT User_Position_ID FROM Budget_Position_Filter WHERE Budget_ID = #URL.Budget_ID#)
                    
           ) AS Up
           LEFT JOIN Business_Segment
             ON Business_Segment.Business_Segment_Id = Up.Business_Segment_Id
             
           INNER JOIN Budget_Position_Filter BPF ON BPF.User_Position_ID = Up.User_Positions_ID
           INNER JOIN Budget ON Budget.Budget_ID = BPF.Budget_ID
             
      WHERE 1 = 1
	  AND BPF.Deleted = 0


 </cfquery>
  <cfif vars.getMarketPurchaseFilter.RecordCount EQ 0>
 	<div align="center"><strong>No <cfoutput>#application.returned_customer_setting.market_label_singular#</cfoutput> have been selected.</strong></div>
 <cfelse>
 
 <table bgcolor="#ffffce" border="1" borderColor="800040" cellpadding="2" cellspacing="1" width="100%">
 		<tr bgcolor="#cc9999">	
		
			<td>
				<strong>Position</strong>
			</td>
			<td>
				<strong>Position Numer</strong>
			</td>
			<td>
				<strong>Segment</strong>
			</td>
			<td>
				<strong><cfoutput>#application.returned_customer_setting.market_label_singular#</cfoutput> Name</strong>
			</td>
 		</tr>	
 	<cfloop query = "vars.getMarketPurchaseFilter">
		<cfoutput>
		    <tr>	
				<td>
					#Position_Label#	
				</td>
				<td>
					#Position_Number#
				</td>
				<td>
					#Business_Unit_Desc#
				</td>
				<td>
					#Market_name#
				</td>
			</tr>
		</cfoutput>	
	</cfloop>
 </table>
 
 </cfif>
 <br>
 <br>
 
<div align="center"><input type="button" value="Close Window" onClick="javascript:window.close();"></div>
</body>
</html>
