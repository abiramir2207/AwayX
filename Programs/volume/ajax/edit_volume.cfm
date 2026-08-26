<cfsetting showDebugOutput="no">
<cfsilent>
<!---
  * ====================================================================================================
  *    @File: Programs\volume\ajax\edit_volume.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019-02-07 09:25:08
  *
  * @Remarks:
  *
  *
  *
  *
  * ====================================================================================================
--->
    <cfscript>
        param name="form.action" default="edit";
        param name="form.forecast" default="0";
        //form.action is always over written to "edit" so  we are taking forecast into account into account to set it to "Edit-Forecast"
        if(form.forecast) {
            form.action = "EDIT-FORECAST";
        }

        volume_cfc     = createObject("component", "mvc.models.program.volume.volumeApplicator");
        qVolumes       = volume_cfc.getVolumeDetails(form.program_id, form.action, form.group_by, form.product_group_level);

        return_columns = [   "\"                                  // [0] checkbox provided by DT select extension
                            ,"Item"                               // [1] - always shown
                            ,"Description"                        // [2] - always shown
                            ,"Cases"                              // [3] - visibility based on program setting
                            ,"Pounds"                             // [4] - visibility based on program setting
                            ,"BSA_Foodservice_Items_Master_ID"    // [5] - hidden, needed for form posting
                            ,"Net_Weight"                         // [6] - hidden, needed for forecast calculations
                            ,"User_Edited"                        // [7] - hidden, needed to display edit indicator
                            ,"Opportunity_Volume_LB"              // [8] - visibility based on program setting
                            ,"Opportunity_Volume_CS"              // [9] - visibility based on program setting
                            ,"Each_Volume"                        // [10] - visibility based on prsogram setting
                            ,"Sleeve_Volume"                      // [11] - visibility based on program setting
                        ];
    </cfscript>

    <!--- calculate grand totals --->
    <cfquery name="qTotal" dbtype="query">
        SELECT	SUM(Cases) AS Total_Cases,
                SUM(Pounds) AS Total_Pounds,
                SUM(Each_Volume) AS Total_Each_Volume,
                SUM(Sleeve_Volume) AS Total_Sleeve_Volume,
                SUM(Opportunity_Volume_CS) AS Opportunity_Total_Cases,
                SUM(Opportunity_Volume_LB) AS Opportunity_Total_Pounds
        FROM   qVolumes
    </cfquery>
</cfsilent>
<cfif qVolumes.recordCount eq 0>
    {"total_cases":0,"total_pounds":0,"opportunity_total_cases":0,"opportunity_total_pounds":0,"total_each_volume":0,"total_sleeve_volume":0,"data":[]}
<cfelse>
    <cfoutput>{"total_cases":#qTotal.Total_Cases#,"total_pounds":#qTotal.Total_Pounds#,"opportunity_total_cases":#qTotal.Opportunity_Total_Cases#,"opportunity_total_pounds":#qTotal.Opportunity_Total_Pounds#,"total_each_volume":#qTotal.Total_Each_Volume#,"total_sleeve_volume":#qTotal.Total_sleeve_Volume#,"data":#application.util.query.toDtJSON(qVolumes, arrayToList( return_columns ))#}</cfoutput>
</cfif>
