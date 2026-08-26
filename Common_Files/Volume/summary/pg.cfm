<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\Volume\Summary\pg.cfm
      Date:     2012 July
      Author:   Chris Nguyen
      Purpose:  Display planning group volume forecast summary which includes VFs of current position and VFs of all below
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
   .border1 {border-left:1.05px solid #000!important;}
   .dollar {width:8%;text-align:right;}
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
	SELECT  pg.pg_Product_Category_Name
	       ,pg.pg_Product_Category_Id
				 ,ly_volume = ISNULL(SUM( IsNull( ly_Volume, 0 ) ), 0)
	       ,act_ly_volume = ISNULL(SUM( CASE
	                               WHEN GetDate() > vfp.End_Date THEN IsNull( ly_Volume, 0 )
	                               ELSE 0
	                             END ), 0)
	       ,act_ty_volume = ISNULL(SUM( CASE
	                               WHEN GetDate() > vfp.End_Date THEN IsNull( Actual_Volume, 0 )
	                               ELSE 0
	                             END ), 0)
	       ,togo_ly_volume = ISNULL(SUM( CASE
	                                WHEN GetDate() > vfp.End_Date THEN 0
	                                ELSE IsNull( ly_Volume, 0 )
	                              END ), 0)
	       ,togo_ty_volume = ISNULL(SUM( CASE
		                             WHEN GetDate() > vfp.End_Date THEN 0
		                             ELSE
		                               CASE
		                                 WHEN vfd.Use_Absolute = 0 THEN ( ly_Volume * ( 1 + ( IsNull( ty_Delta_Percentage, 0 ) / 100 ) ) )
		                                 ELSE IsNull( ty_Volume, 0 )
		                               END
		                           END ), 0)
					,Start_Date = MIN(vfp.Start_Date)
	  FROM VF_PLAN
	       INNER JOIN VF_CLASS ON VF_CLASS.vf_Class_Id = VF_PLAN.vf_Plan_Class_Id
	                              AND VF_CLASS.Deleted = 0
	                              AND VF_CLASS.Active = 1
	       INNER JOIN VF_LEVEL ON VF_LEVEL.vf_Plan_Id = VF_PLAN.vf_Plan_Id
	                              AND VF_LEVEL.Deleted = 0
	       LEFT JOIN USER_POSITIONS ON USER_POSITIONS.User_Positions_Id = VF_LEVEL.User_Position_Id
	       INNER JOIN VF_PERIOD vfp ON vfp.vf_Class_Id = VF_CLASS.vf_Class_Id
	       INNER JOIN VF_DETAIL vfd ON vfd.vf_Plan_Id = VF_PLAN.vf_Plan_Id
	                                   AND vfd.vf_Level_Id = VF_LEVEL.vf_Level_Id
	                                   AND vfd.vf_Period_Id = vfp.vf_Period_Id
	                                   AND vfd.Deleted = 0
	       INNER JOIN PG_PRODUCT_CATEGORY pg ON pg.pg_Product_Category_Id = vfd.pg_Product_Category_Id
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
	 GROUP BY pg.pg_Product_Category_Name
	         ,pg.pg_Product_Category_Id
	 ORDER BY pg.pg_Product_Category_Name
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
      <th style="width=16%">Planning&nbsp;&nbsp;Group</th>

      <th class="border1">Actual <br/>EQC</th>
      <th>Actual <br/>+/- Abs EQC</th>
      <th>Actual <br/>+/- % EQC</th>
      <th class="border1 alignc">To Go <br/>EQC</th>
      <th>To Go <br/>+/- Abs EQC</th>
      <th>To Go <br/>+/- % EQC</th>
      <th class="border1 alignc">Annual <br/>EQC</th>
      <th>Annual <br/>+/- Abs EQC</th>
      <th>Annual <br/>+/- % EQC</th>
  </tr>
 </thead>

 <cfif qDetail.recordCount>
   <!---Total row--->
   <tfoot id="tfoot">
    <tr>
    <cfoutput>
      <th colspan="1" style="text-align:right;font-size:1.1em;letter-spacing:2px;">Total</th>
      <!---Actual section--->
      <cfset negclass = (qTotal.act_ty_volume lt 0) ? 'neg' : ''>
      <th class="border1 dollar #negclass#">#NumberFormat(qTotal.act_ty_volume, const.volumeFormat)#</th>

      <cfset negclass = (qTotal.act_ty_volume - qTotal.act_ly_volume) lt 0 ? 'neg' : '' >
      <th class="dollar #negclass#">#deltaValue(ty=qTotal.act_ty_volume, ly=qTotal.act_ly_volume, percentage=0)#</th>
      <th class="dollar #negclass#">#deltaValue(ty=qTotal.act_ty_volume, ly=qTotal.act_ly_volume, percentage=1)#</th>

      <!---To go section--->
      <cfset negclass = (qTotal.togo_ty_volume lt 0) ? 'neg' : ''>
      <th class="border1 dollar #negclass#">#NumberFormat(qTotal.togo_ty_volume, const.volumeFormat)#</th>

      <cfset negclass = (qTotal.togo_ty_volume - qTotal.togo_ly_volume) lt 0 ? 'neg' : '' >
      <th class="dollar #negclass#">#deltaValue(ty=qTotal.togo_ty_volume, ly=qTotal.togo_ly_volume, percentage=0)#</th>
      <th class="dollar #negclass#">#deltaValue(ty=qTotal.togo_ty_volume, ly=qTotal.togo_ly_volume, percentage=1)#</th>

      <!---Annual section--->
      <cfset negclass = (qTotal.ann_ty_volume lt 0) ? 'neg' : ''>
      <th class="border1 dollar #negclass#">#NumberFormat(qTotal.ann_ty_volume, const.volumeFormat)#</th>

      <cfset negclass = (qTotal.ann_ty_volume - qTotal.ann_ly_volume) lt 0 ? 'neg' : '' >
      <th class="dollar #negclass#">#deltaValue(ty=qTotal.ann_ty_volume, ly=qTotal.ann_ly_volume, percentage=0)#</th>
      <th class="dollar #negclass#">#deltaValue(ty=qTotal.ann_ty_volume, ly=qTotal.ann_ly_volume, percentage=1)#</th>
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
        <cfoutput><td>#qDetail.pg_Product_Category_Name#</td></cfoutput>

         <!---Actual section--->
         <cfset negclass = (qDetail.act_ty_volume lt 0) ? 'neg' : ''>
       	<cfoutput><td class="border1 dollar #negclass#">#NumberFormat(qDetail.act_ty_volume, const.volumeFormat)#</td></cfoutput>

         <cfset negclass = (qDetail.act_ty_volume - qDetail.act_ly_volume) lt 0 ? 'neg' : '' >
         <cfoutput><td class="dollar #negclass#">#deltaValue(ty=qDetail.act_ty_volume, ly=qDetail.act_ly_volume, percentage=0)#</td></cfoutput>
         <cfoutput><td class="dollar #negclass#">#deltaValue(ty=qDetail.act_ty_volume, ly=qDetail.act_ly_volume, percentage=1)#</td></cfoutput>

         <!---To go section--->
         <cfset negclass = (qDetail.togo_ty_volume lt 0) ? 'neg' : '' >
         <cfoutput><td class="border1 dollar #negclass#">#NumberFormat(qDetail.togo_ty_volume, const.volumeFormat)#</td></cfoutput>

         <cfset negclass = (qDetail.togo_ty_volume - qDetail.togo_ly_volume) lt 0 ? 'neg' : '' >
         <cfoutput><td class="dollar #negclass#">#deltaValue(ty=qDetail.togo_ty_volume, ly=qDetail.togo_ly_volume, percentage=0)#</td></cfoutput>
         <cfoutput><td class="dollar #negclass#">#deltaValue(ty=qDetail.togo_ty_volume, ly=qDetail.togo_ly_volume, percentage=1)#</td></cfoutput>

         <!---Annual section--->
         <cfset annual_volume = qDetail.act_ty_volume + qDetail.togo_ty_volume>

         <cfset negclass = (annual_volume lt 0) ? 'neg' : '' >
         <cfoutput><td class="border1 dollar #negclass#">#NumberFormat(annual_volume, const.volumeFormat)#</td></cfoutput>

         <cfset negclass = (annual_volume - qDetail.ly_volume) lt 0 ? 'neg' : '' >
         <cfoutput><td class="dollar #negclass#">#deltaValue(ty=annual_volume, ly=qDetail.ly_volume, percentage=0)#</td></cfoutput>
         <cfoutput><td class="dollar #negclass#">#deltaValue(ty=annual_volume, ly=qDetail.ly_volume, percentage=1)#</td></cfoutput>
     <cfoutput></tr></cfoutput>
     </cfloop>
     <cfsetting enablecfoutputonly="false">
 </tbody>

 </table>
</div>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="js.cfm">

</cfmodule>