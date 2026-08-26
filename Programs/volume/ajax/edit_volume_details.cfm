<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="yes">    
<!---
  * ==================================================================================================== 
  *    @File: Programs\volume\ajax\edit_volume_details.cfm
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
    param name="form.action"       default="view";
    param name="form.group_by"     default="";
    param name="form.include_zero" default="0";
    param name="form.group_b"      default="";
    param name="form.product_group_level" default="0";

    volume_cfc     = createObject("component", "mvc.models.program.volume.volumeApplicator");
    qVolumes       = volume_cfc.getVolumeDetails(form.program_id, Ucase(form.action), Ucase(form.group_by), form.product_group_level);

    switch (form.group_by) {
        case "operator":
            return_columns = [   "Operator_ID"
                                ,"Operator_Name"       
                                ,"Item"
                                ,"Description"                        // [1] - always shown
                                ,"Cases"                              // [2] - visibility based on program setting
                                ,"Pounds"                             // [3] - visibility based on program setting
                                ,"BSA_Foodservice_Items_Master_ID"    // [4] - hidden, needed for form posting
                                ,"Net_Weight"                         // [5] - hidden, needed for forecast calculations
                                ,"User_Edited"                        // [6] - hidden, needed to display edit indicator
                                ,"Opportunity_Volume_LB"              // [7] - visibility based on program setting
                                ,"Opportunity_Volume_CS"              // [8] - visibility based on program setting
                                ,"Each_Volume"                        // [9] - visibility based on prsogram setting
                                ,"Sleeve_Volume"                      // [10] - visibility based on prsogram setting
                                ];                                
            break;
        case "customer":
            return_columns = [   "Shr_Ship_To"
                                ,"Name"       
                                ,"Cases"                              // [2] - visibility based on program setting
                                ,"Pounds"                             // [3] - visibility based on program setting
                                ,"BSA_Foodservice_Items_Master_ID"    // [4] - hidden, needed for form posting
                                ,"Net_Weight"                         // [5] - hidden, needed for forecast calculations
                                ,"User_Edited"                        // [6] - hidden, needed to display edit indicator
                                ,"Opportunity_Volume_LB"              // [7] - visibility based on program setting
                                ,"Opportunity_Volume_CS"              // [8] - visibility based on program setting
                                ,"Each_Volume"                        // [9] - visibility based on prsogram setting
                                ,"Sleeve_Volume"                      // [10] - visibility based on prsogram setting
                                ];                                
            break;
        default:
            return_columns = [   "Item"                               // [0] - always shown
                                ,"Description"                        // [1] - always shown
                                ,"Cases"                              // [2] - visibility based on program setting
                                ,"Pounds"                             // [3] - visibility based on program setting
                                ,"BSA_Foodservice_Items_Master_ID"    // [4] - hidden, needed for form posting
                                ,"Net_Weight"                         // [5] - hidden, needed for forecast calculations
                                ,"User_Edited"                        // [6] - hidden, needed to display edit indicator
                                ,"Opportunity_Volume_LB"              // [7] - visibility based on program setting
                                ,"Opportunity_Volume_CS"              // [8] - visibility based on program setting
                                ,"Each_Volume"                        // [9] - visibility based on prsogram setting
                                ,"Sleeve_Volume"                      // [10] - visibility based on prsogram setting
                                // ,"Invoice_Type"
                            ];                
    }
</cfscript>

<cfif qVolumes.recordCount eq 0>
    <cfoutput>{"total_cases":0,"total_pounds":0,"opportunity_total_cases":0,"opportunity_total_pounds":0,"total_each_volume":0,"total_sleeve_volume":0,"data":[]}</cfoutput>
<cfelse>
    <!--- filter out duplicates and group B selection (when applicable) --->
    <cfquery name="qUnique" dbtype="query">
        SELECT DISTINCT <cfoutput>#arrayToList(return_columns)#</cfoutput>
          FROM qVolumes
         WHERE 1 = 1
        <cfif form.include_zero eq 0>
            AND ( Cases > 0 OR Pounds > 0 )
        </cfif>
        <cfif trim(form.group_b) neq "">
            AND ( Invoice_Type = <cfoutput>'#trim(form.group_b)#'</cfoutput> )
        </cfif>
    </cfquery>

    <!--- calculate grand totals --->
    <cfquery name="qTotal" dbtype="query">
        SELECT	SUM(Cases) AS Total_Cases,
                SUM(Pounds) AS Total_Pounds,
                SUM(Each_Volume) AS Total_Each_Volume,
                SUM(Sleeve_Volume) AS Total_Sleeve_Volume,
                SUM(Opportunity_Volume_CS) AS Opportunity_Total_Cases,
                SUM(Opportunity_Volume_LB) AS Opportunity_Total_Pounds
        FROM   qUnique
    </cfquery>

    <cfif qTotal.recordCount eq 0>
        <cfoutput>{"total_cases":0,"total_pounds":0,"opportunity_total_cases":0,"opportunity_total_pounds":0,"total_each_volume":0,"total_sleeve_volume":0,"data":[]}</cfoutput>
    <cfelse>
        <cfoutput>{"total_cases":#qTotal.Total_Cases#,"total_pounds":#qTotal.Total_Pounds#,"opportunity_total_cases":#qTotal.Opportunity_Total_Cases#,"opportunity_total_pounds":#qTotal.Opportunity_Total_Pounds#,"total_each_volume":#qTotal.Total_Each_Volume#,"total_sleeve_volume":#qTotal.Total_Sleeve_Volume#,"data":#application.util.query.toDtJSON(qUnique, arrayToList( return_columns ))#}</cfoutput>
    </cfif>
</cfif>