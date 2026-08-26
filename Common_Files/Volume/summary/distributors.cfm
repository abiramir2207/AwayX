<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\Volume\Summary\distributors.cfm
      Date:     2012 July
      Author:   Chris Nguyen
      Purpose:  Display distributor volume forecast summary which includes VFs of current position and VFs of all below
                positions
----------------------------------------------------------------------------------------------------------------------->
<!--- call layout module to set up the heading and horizontal menu options --->
<cfmodule template="/customTags/layout.cfm" layoutID = "volume-forecast">

<!--- define format masks to be used on this page --->
<cfscript>
  const.volumeFormat  = "(,";
  const.percentFormat = "(.00";
</cfscript>

<!--- include volume forecast functions library --->
<cfinclude template="/Common_Files/Volume/g500/vfUDF.cfm">

<cfsavecontent variable="cssDetail">
  <style>
	 .thead0 {background:url('/images/gradback.png') repeat-x scroll 0 0 #B9C9FE;font-size:1.25em;letter-spacing:3px;text-align:center;}
   .thead1 {font-size:1.25em;letter-spacing:2px;}
   #tfoot {font-size:.9em;text-align:right;font-weight:bold;}
   thead th,tfoot th,.datagrid {border:1.05px solid #000!important;}
   thead th {text-align:left;}
   .alignr {text-align:right;}
   .b1 {border-left:1.05px solid #000!important;}
   .usd {width:6%;text-align:right;}
   .neg {color:red!important;}
   .datagrid tbody tr.even {background-color:#efe;}
  </style>
</cfsavecontent>
<cfhtmlhead text="#cssDetail#">

<!--------------------------------------------------------------------------------------------------------------------->

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegIsEnabled = businessSegManager.isEnabled()>

<cfif businessSegIsEnabled>
  <!---32355 - gather user assigned segments--->
  <cfset qClassCodes = businessSegManager.getActiveClassCodes(request.AccessStructure.User_ID, 0) />
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="getData">
	<!--- gather detail rows --->
	<cfquery name="qDetail" Datasource="#application.datasource#">
	-- Get values rounded at period / product pg level to match volume forecast spreadsheet
	IF OBJECT_ID('tempdb..##tmp_pg_period_level') IS NOT NULL
	  DROP TABLE ##tmp_pg_period_level

	SELECT  c.Name
	       ,VF_PLAN.vf_Plan_desc
	       ,VF_PLAN.vf_Plan_Id
	       ,c.BSA_Foodservice_Customers_ID
	       ,c.Shr_Ship_To
	       ,vfd.PG_Product_Category_ID
	       ,vfp.vf_Period_Id
	       ,TY_Delta_Percentage = ISNULL(VF_Detail.TY_Delta_Percentage, 0)
	       ,Market_Name = CASE VF_PLAN.Forecast_Level WHEN 4 THEN m.Market_Name ELSE m1.Market_Name END
	       ,Market_Number = CASE VF_PLAN.Forecast_Level WHEN 4 THEN m.Market_Number ELSE m1.Market_Number END
	       ,ly_volume = ISNULL(SUM( IsNull( vfd.LY_Volume, 0 ) ), 0)
	       ,act_ly_volume = ISNULL(SUM( CASE
	                               WHEN GetDate() > vfp.End_Date THEN IsNull( vfd.LY_Volume, 0 )
	                               ELSE 0
	                             END ), 0)
	       ,act_ty_volume = ISNULL(CAST( SUM( CASE
	                                     WHEN GetDate() > vfp.End_Date THEN IsNull( Actual, 0 )
	                                     ELSE 0
	                                   END ) AS DECIMAL( 25, 9 ) ), 0)
	       ,togo_ly_volume = ISNULL(CAST( SUM( CASE
	                                      WHEN GetDate() > vfp.End_Date THEN 0
	                                      ELSE IsNull( vfd.LY_Volume, 0 )
	                                    END ) AS DECIMAL( 25, 9 ) ), 0)
	       ,togo_ty_volume = ISNULL(Cast( SUM( CASE
	                                      WHEN GetDate() > vfp.End_Date THEN 0
	                                      ELSE Forecast_Cases * CASE VF_PLAN.vf_uom
	                                                              WHEN 2 THEN Cast( i.Net_Weight AS FLOAT )
	                                                              WHEN 9 THEN Cast( i.Case_Equivalent AS FLOAT )
	                                                              ELSE 1
	                                                            END
	                                    END ) AS DECIMAL( 25, 9 )), 0)
					,Start_Date = MIN(vfp.Start_Date)
	  INTO ##tmp_pg_period_level
	  FROM VF_PLAN
	       INNER JOIN VF_CLASS ON VF_CLASS.vf_Class_Id = VF_PLAN.vf_Plan_Class_Id
	                              AND VF_CLASS.Deleted = 0
	                              AND VF_CLASS.Active = 1
	       INNER JOIN VF_LEVEL ON VF_LEVEL.vf_Plan_Id = VF_PLAN.vf_Plan_Id
	                              AND VF_LEVEL.Deleted = 0
	       INNER JOIN VF_PERIOD vfp ON vfp.vf_Class_Id = VF_CLASS.vf_Class_Id
	       INNER JOIN VF_PRODUCT_DISTRIBUTOR_DETAIL vfd ON vfd.vf_Plan_Id = VF_PLAN.vf_Plan_Id
	                                                       AND vfd.vf_Level_Id = VF_LEVEL.vf_Level_Id
	                                                       AND vfd.vf_Period_Id = vfp.vf_Period_Id
				 LEFT JOIN VF_DETAIL ON VF_DETAIL.vf_Plan_Id = vfd.vf_Plan_Id
					                              AND VF_DETAIL.vf_Period_Id = vfd.vf_Period_Id
					                              AND VF_DETAIL.vf_Level_Id = vfd.vf_Level_Id
					                              AND VF_DETAIL.pg_Product_Category_Id = vfd.pg_Product_Category_Id
					                              AND VF_DETAIL.Deleted = 0
	       INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER i ON i.bsa_FoodService_Items_Master_Id = vfd.bsa_FoodService_Items_Master_Id
	       INNER JOIN BSA_FOODSERVICE_CUSTOMERS c ON c.bsa_FoodService_Customers_Id = vfd.bsa_FoodService_Customers_Id
				 LEFT JOIN ( SELECT  m.*, md.Distributor_ID
	                    FROM  SERVICE_MARKETS m
	                          INNER JOIN MARKET_DISTRIBUTOR md ON md.Service_Market_ID = m.Service_Market_ID
	                                                           AND md.Deleted = 0 ) AS m
	                 ON VF_PLAN.Forecast_Level = 4
	                 AND m.Distributor_ID = c.bsa_FoodService_Customers_Id
	                 AND m.Business_Segment_ID = VF_PLAN.vf_Plan_Segment_Id
			 	 LEFT JOIN SERVICE_MARKETS m1 ON VF_PLAN.Forecast_Level != 4
	                  									AND m1.Service_Market_ID = vfd.Service_Market_ID
	 WHERE VF_PLAN.Deleted = 0
         <cfif len(url.byClassIDs)>
        	  AND VF_PLAN.vf_Plan_Class_Id IN ( #url.byClassIDs# )
         </cfif>
	       AND VF_LEVEL.User_Position_Id IN ( SELECT Below_User_Positions_Id
	                                            FROM POSITIONS_BELOW_ME pbm
	                                           WHERE Below_User_Positions_Id IS NOT NULL
	                                                 AND pbm.User_Positions_Id IN ( SELECT uph.User_Positions_Id
	                                                                                  FROM USER_POSITION_HOLDERS uph
	                                                                                 WHERE uph.Deleted = 0
	                                                                                         AND Uph.User_Id = <cfqueryparam value="#request.AccessStructure.user_ID#" cfsqltype="cf_sql_varchar">) )
	       <cfif businessSegIsEnabled>
	         AND vf_Plan.VF_Plan_Segment_ID IN (
	           																					<cfif url.bySegmentId eq "" or url.bySegmentId eq "undefined">
	           																						<cfqueryparam value="#ValueList(qClassCodes.Business_Segment_ID)#" cfsqltype="cf_sql_integer" list="yes">
	           																					<cfelse>
	           																						<cfqueryparam value="#url.bySegmentId#" cfsqltype="cf_sql_integer" list="yes">
	           																					</cfif>
	           																		 )
	       </cfif>
	 GROUP BY  c.Name
						,VF_PLAN.vf_Plan_desc
	          ,VF_PLAN.vf_Plan_Id
						,c.BSA_Foodservice_Customers_ID
						,c.Shr_Ship_To
		        ,vfd.PG_Product_Category_ID
		        ,vfp.vf_Period_Id
		        ,VF_DETAIL.ty_Delta_Percentage
						,CASE VF_PLAN.Forecast_Level
						    WHEN 4 THEN m.Market_Name
						    ELSE m1.Market_Name
						 END
						,CASE VF_PLAN.Forecast_Level
						    WHEN 4 THEN m.Market_Number
						    ELSE m1.Market_Number
						 END


	SELECT  Name
	       ,vf_Plan_desc
	       ,BSA_Foodservice_Customers_ID
	       ,Shr_Ship_To
	       ,vf_Plan_Id
	       ,Market_Name
	       ,Market_Number
	       ,ly_volume = SUM(ly_volume)
	       ,act_ly_volume = SUM(act_ly_volume)
	       ,act_ty_volume = SUM(act_ty_volume)
	       ,togo_ly_volume = SUM(togo_ly_volume)
	       ,togo_ty_volume = SUM(togo_ty_volume)
	       ,Start_Date = MIN(Start_Date)
	FROM  ##tmp_pg_period_level
	Group By vf_Plan_Id
	       ,vf_Plan_desc
	       ,BSA_Foodservice_Customers_ID
				 ,Shr_Ship_To
	       ,Name
	       ,Market_Name
	       ,Market_Number
	Order By Name
	       ,vf_Plan_desc
	       ,Market_Name
	</cfquery>

	<!--- calculate totals --->
	<cfif qDetail.recordCount>
	  <cfquery name="qTotal" dbtype="query">
	    SELECT SUM( act_ly_volume )  AS act_ly_volume
	          ,SUM( act_ty_volume )  AS act_ty_volume
	          ,SUM( togo_ly_volume ) AS togo_ly_volume
	          ,SUM( togo_ty_volume ) AS togo_ty_volume
	          ,SUM( act_ty_volume + togo_ty_volume ) AS ann_ty_volume
	          ,SUM( ly_volume )                      AS ann_ly_volume
	      FROM qDetail
	  </cfquery>
	<cfelse>
	  <cfquery name="qTotal" Datasource="#application.datasource#">
	    SELECT 0 AS act_ly_volume
	          ,0 AS act_ty_volume
	          ,0 AS togo_ly_volume
	          ,0 AS togo_ty_volume
	          ,0 AS ann_ly_volume
	          ,0 AS ann_ty_volume
	  </cfquery>
	</cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<div style="margin:5px 0">
 <!---this include displays VF classes, segments and define url.byClassIDs & url.bySegmentId--->
 <cfinclude template="classSegment.cfm">
 <cfset getData()>

 <button style="float:right" onclick="getCSVData()">Export</button>
 <table class="datagrid" id="vfsummary">
 <thead>
  <tr>
      <th style="width=16%">Distributor</th>
      <th style="width=16%">VF Plan</th>
      <th style="width=5%">Territory</th>

      <th class="b1">Actual <br/>EQC</th>
      <th>Actual <br/>+/- Abs EQC</th>
      <th>Actual <br/>+/- % EQC</th>
      <th class="b1">To Go <br/>EQC</th>
      <th>To Go <br/>+/- Abs EQC</th>
      <th>To Go <br/>+/- % EQC</th>
      <th class="b1">Annual <br/>EQC</th>
      <th>Annual <br/>+/- Abs EQC</th>
      <th>Annual <br/>+/- % EQC</th>
  </tr>
 </thead>

 <cfif qDetail.recordCount>
   <!---Total row--->
   <tfoot id="tfoot">
    <tr>
    <cfoutput>
      <th>&nbsp;</th>
      <th>&nbsp;</th>
      <th style="text-align:right;font-size:1.1em;letter-spacing:2px;">Total</th>
      <!---Actual section--->
      <cfset dollarClass = 'usd' & ((qTotal.act_ty_volume lt 0) ? ' neg' : '')>
      <th class="b1 #dollarClass#">#NumberFormat(qTotal.act_ty_volume, const.volumeFormat)#</th>

      <cfset dollarClass = 'usd' & ((qTotal.act_ty_volume - qTotal.act_ly_volume) lt 0 ? ' neg' : '') >
      <th class="#dollarClass#">#deltaValue(ty=qTotal.act_ty_volume, ly=qTotal.act_ly_volume, percentage=0)#</th>
      <th class="#dollarClass#">#deltaValue(ty=qTotal.act_ty_volume, ly=qTotal.act_ly_volume, percentage=1)#</th>

      <!---To go section--->
      <cfset dollarClass = 'usd' & ((qTotal.togo_ty_volume lt 0) ? ' neg' : '')>
      <th class="b1 #dollarClass#">#NumberFormat(qTotal.togo_ty_volume, const.volumeFormat)#</th>

      <cfset dollarClass = 'usd' & ((qTotal.togo_ty_volume - qTotal.togo_ly_volume) lt 0 ? ' neg' : '') >
      <th class="#dollarClass#">#deltaValue(ty=qTotal.togo_ty_volume, ly=qTotal.togo_ly_volume, percentage=0)#</th>
      <th class="#dollarClass#">#deltaValue(ty=qTotal.togo_ty_volume, ly=qTotal.togo_ly_volume, percentage=1)#</th>

      <!---Annual section--->
      <cfset dollarClass = 'usd' & ((qTotal.ann_ty_volume lt 0) ? ' neg' : '')>
      <th class="b1 #dollarClass#">#NumberFormat(qTotal.ann_ty_volume, const.volumeFormat)#</th>

      <cfset dollarClass = 'usd' & ((qTotal.ann_ty_volume - qTotal.ann_ly_volume) lt 0 ? ' neg' : '') >
      <th class="#dollarClass#">#deltaValue(ty=qTotal.ann_ty_volume, ly=qTotal.ann_ly_volume, percentage=0)#</th>
      <th class="#dollarClass#">#deltaValue(ty=qTotal.ann_ty_volume, ly=qTotal.ann_ly_volume, percentage=1)#</th>
    </cfoutput>
    </tr>
   </tfoot>
 </cfif>

 <!--- summary body starts here --->
 <tbody>
   	 <!--- reduce white spaces as much as we can --->
     <cfsetting enablecfoutputonly="true">
     <cfloop query="qDetail">
     <cfoutput><tr></cfoutput>
         <cfoutput><td>#trim(qDetail.Name)# [#trim(qDetail.Shr_Ship_To)#]</td></cfoutput>
         <cfoutput><td>#qDetail.vf_Plan_desc#</td></cfoutput>
         <cfoutput><td>#trim(qDetail.Market_Name)# <cfif len(qDetail.Market_Number)>[#trim(qDetail.Market_Number)#]</cfif></td></cfoutput>

         <!---Actual section--->
         <cfset dollarClass = 'usd' & ((qDetail.act_ty_volume lt 0) ? ' neg' : '')>
         <cfoutput><td class="b1 #dollarClass#">#NumberFormat(qDetail.act_ty_volume, const.volumeFormat)#</td></cfoutput>

         <cfset dollarClass = 'usd' & ((qDetail.act_ty_volume - qDetail.act_ly_volume) lt 0 ? ' neg' : '') >
         <cfoutput><td class="#dollarClass#">#deltaValue(ty=qDetail.act_ty_volume, ly=qDetail.act_ly_volume, percentage=0)#</td></cfoutput>
         <cfoutput><td class="#dollarClass#">#deltaValue(ty=qDetail.act_ty_volume, ly=qDetail.act_ly_volume, percentage=1)#</td></cfoutput>

         <!---To go section--->
         <cfset dollarClass = 'usd' & ((qDetail.togo_ty_volume lt 0) ? ' neg' : '') >
         <cfoutput><td class="b1 #dollarClass#">#NumberFormat(qDetail.togo_ty_volume, const.volumeFormat)#</td></cfoutput>

         <cfset dollarClass = 'usd' & ((qDetail.togo_ty_volume - qDetail.togo_ly_volume) lt 0 ? ' neg' : '') >
         <cfoutput><td class="#dollarClass#">#deltaValue(ty=qDetail.togo_ty_volume, ly=qDetail.togo_ly_volume, percentage=0)#</td></cfoutput>
         <cfoutput><td class="#dollarClass#">#deltaValue(ty=qDetail.togo_ty_volume, ly=qDetail.togo_ly_volume, percentage=1)#</td></cfoutput>

         <!---Annual section--->
         <cfset annual_volume = qDetail.act_ty_volume + qDetail.togo_ty_volume>

         <cfset dollarClass = 'usd' &  ((annual_volume lt 0) ? ' neg' : '') >
         <cfoutput><td class="b1 #dollarClass#">#NumberFormat(annual_volume, const.volumeFormat)#</td></cfoutput>

         <cfset dollarClass = 'usd' & ((annual_volume - qDetail.ly_volume) lt 0 ? ' neg' : '') >
         <cfoutput><td class="#dollarClass#">#deltaValue(ty=annual_volume, ly=qDetail.ly_volume, percentage=0)#</td></cfoutput>
         <cfoutput><td class="#dollarClass#">#deltaValue(ty=annual_volume, ly=qDetail.ly_volume, percentage=1)#</td></cfoutput>
     <cfoutput></tr></cfoutput>
     </cfloop>
     <cfsetting enablecfoutputonly="false">
 </tbody>

 </table>
</div>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="js.cfm">

</cfmodule>