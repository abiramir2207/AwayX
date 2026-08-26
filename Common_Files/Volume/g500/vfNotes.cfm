<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\Volume\g500\vfNotes.cfm
      Date:     Jan 10, 2013
      Author:   Chris Nguyen
      Purpose:  Display volume forecast notes with option to create new notes

      Notes:    URL parameter names are soundex values so they are not obvious to users (more secure)

      Required Input:  1. url.l143: VF Level ID (numeric)
                       
      Optional Input:  1. url.r354: read-only indicator: pass 'f420' value to allow editing,
                                                         pass anything else to prevent changes
----------------------------------------------------------------------------------------------------------------------->
<html>
<cfparam name="url.r354" default="">
<head>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  <cfinclude template="vfUDF.cfm">        <!---volume forecast functions library--->
  <cfinclude template="/get_access_profile.cfm">
  <title>Volume Forecast Notes</title>
  <style>
  form, #top-bar, h3 { margin:0; }
  #top-bar {
    top: 0px;
    left: 0px;
    position: fixed;
    height: 60px;
    width: 100%;
    z-index: 999;
    overflow: hidden;
    background:white;
  }
  h3 { padding:5px 0 0 10px; }
  hr { color:red; margin:0 5px; }
  #actions { padding:5px 0 0 10px; }
  #content { padding:60px 0 0 0; position:relative; }

  .even {BACKGROUND-COLOR: #eeffee}
  @media print {
    .noPrint { display:none; }
  }
  </style>
</head>

<cfif cgi.request_method eq "post">
  <cfif len(trim(form.notes))>
    <cfset useLakebaseForSaveData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vf_notes")>
    <cfif useLakebaseForSaveData>
      <cftry>
        <cfset application.oLakebase.insertRow("vf_notes", {
          "vf_level_id" = url.l143,
          "vf_notes" = form.notes,
          "created_by" = request.AccessStructure.User_ID
        })>
        <cfcatch type="any">
          <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
          <cfset useLakebaseForSaveData = false>
        </cfcatch>
      </cftry>
    </cfif>
    <cfif NOT useLakebaseForSaveData>
      <cfquery name="saveData" Datasource="#application.datasource#">
        INSERT INTO VF_NOTES
              (  vf_Level_Id
                ,vf_Notes
                ,Created_By
              )
        VALUES ( #url.l143#
                 ,'#form.notes#'
                 ,'#request.AccessStructure.User_ID#'
               )
      </cfquery>
    </cfif>
  </cfif>
  <script type="text/javascript">
    // window.close();
  </script>
</cfif>

<cfquery name="qVolumePlan" Datasource="#application.datasource#">
    SELECT Plan_Name = vf_Plan.vf_Plan_desc
          ,Forecast_Level
           ,Position_Customer = CASE
                                  WHEN vf_Plan.Forecast_Level = 4 THEN bsa_FoodService_Customers.Name + ' (' + bsa_FoodService_Customers.shr_ship_to + ')'
                                  WHEN vf_Level.Service_Market_Id IS NOT NULL THEN Service_Markets.Market_Name
                                  WHEN vf_Level.Service_Region_Id IS NOT NULL
                                       AND vf_Level.Service_Market_Id IS NULL THEN Service_Regions.Region_Name
                                  WHEN vf_Level.Service_Zone_Id IS NOT NULL
                                       AND vf_Level.Service_Region_Id IS NULL
                                       AND vf_Level.Service_Market_Id IS NULL THEN Service_Zones.Zone_Name
                                  ELSE 'HQ'
                                END
      FROM vf_Level
            INNER JOIN vf_Plan ON vf_Plan.vf_Plan_Id = vf_Level.vf_Plan_Id
            LEFT OUTER JOIN Service_Regions ON vf_level.Service_Region_ID  = Service_Regions.Service_Region_ID
            LEFT OUTER JOIN Service_Markets ON vf_Level.Service_Market_ID = Service_Markets.Service_Market_ID    
            LEFT OUTER JOIN Service_Zones ON vf_Level.Service_Zone_ID = Service_Zones.Service_Zone_ID    
            LEFT JOIN bsa_FoodService_Customers ON vf_Plan.Forecast_Level = 4 AND vf_Level.bsa_FoodService_Customers_Id = bsa_FoodService_Customers.bsa_FoodService_Customers_Id
     WHERE vf_Level.vf_level_id = #url.l143#
</cfquery>

<cfquery name="qNotes" Datasource="#application.datasource#">
    SELECT vf_Notes.*
           ,User_Name = _Users.Name_First + ' ' + _Users.Name_Last
      FROM vf_Notes
           INNER JOIN _Users ON _Users.User_ID = vf_Notes.Created_By
     WHERE VF_Level_ID = <cfqueryparam value="#url.l143#" cfsqltype="cf_sql_integer">
     ORDER BY VF_Notes_ID DESC
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->
<body>
<div id="top-bar">
  <cfoutput>
  <h3>Notes for #qVolumePlan.Plan_Name# - #qVolumePlan.Position_Customer#</h3>
  </cfoutput>
  <hr class="noPrint"/>
  <div class="noPrint" id="actions">
    <cfif qNotes.recordCount>
      <a href="javascript:window.print()"><cfoutput>#application.util.string.actionLinkFormat("print this page")#</cfoutput></a>
    </cfif> 
    <a href="##" <cfif qNotes.recordCount>style="margin-left:15px;"</cfif> onClick="javascript:window.close();"><cfoutput>#application.util.string.actionLinkFormat("close window")#</cfoutput></a>
  </div>
</div>

<div id="content">
  <!---allow to add notes--->
  <cfif url.r354 eq 'f420'>
    <form id="vfnotes" action=<cfoutput>"vfnotes.cfm?l143=#url.l143#&r354=#url.r354#"</cfoutput> method="post">
      <table align="center" width="96%" class="datagrid noPrint">
        <thead>
          <tr>
            <th>ADD NOTES</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><textarea id="text" name="notes" rows="5" cols="160"></textarea><div id="chars"></div></td>
          </tr> 
        </tbody>
      </table>
    </form>
    <div style="text-align:center;margin:15px 0" class="noPrint">
    <a href="##" onClick="javascript:saveNotes();"><cfoutput>#application.util.string.actionLinkFormat("save notes")#</cfoutput></a>
    </div>
  </cfif>
  
  <table align="center" width="96%" class="datagrid">
  <thead>
    <tr>
      <th width="18%">DATE</th>
      <th width="22%">USER NAME</th>
      <th width="60%">NOTES</th>
    </tr>
  </thead>
  <tbody>
    <cfif qNotes.recordCount eq 0>
      <tr><td colspan="4" class="norecords" align="center">No Notes Found</td></tr>
    <cfelse>
      <cfoutput query="qNotes">
        <tr <cfif (qNotes.currentRow mod 2) eq 0>class="even"</cfif>>
          <td>#Application.Util.DateTime.dateTimeFormat( qNotes.Created_Date)#</td>
          <td>#qNotes.User_Name#</td>
          <td>#qNotes.vf_Notes#</td>
        </tr>
      </cfoutput>
    </cfif>
  </tbody>
  </table>
</div>    <!---end of div content--->


<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->
<cfinclude template="/common_files/jQuery.cfm">

<script type="text/javascript">
(function($) {
    $.fn.extend( {
        limiter: function(limit, elem) {
            $(this).on("keyup focus", function() {
                setCount(this, elem);
            });
            function setCount(src, elem) {
                var chars = src.value.length;
                if (chars > limit) {
                    src.value = src.value.substr(0, limit);
                    chars = limit;
                }
                elem.html( (limit - chars) + " remaining characters");
            }
            setCount($(this)[0], elem);
        }
    });
})(jQuery);
saveNotes = function() {
  if ( $('#text').val().length == 0 ) {
    // nothing was entered for notes - go back
    return false;
  }
  // submit the page with entered notes
  $('#vfnotes').submit();
}
<!---allow to add notes--->
<cfif url.r354 eq 'f420'>
  var elem = $("#chars");
  $("#text").limiter(500, elem);
</cfif>
</script>
</body>
</html>

