<!----------------------------------------------------------------------------------
Name         :  AwayX/Planners/Create/planner_scorecard.cfm
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  04/Aug/2016
Created By   :  Anand Rao
Description  :  Download programs from planner scorecard.
---------------------------------------------------------------------------------->

<cfparam name="URL.plannerID" default="" />

<!--- Initiate the CFC --->
<cfscript>
    plannerManager   = CreateObject("component","mvc.Models.Planner.PlannerManager");
    qPlannerPrograms = plannerManager.getPlannerPrograms(plannerID=url.plannerID);
    
    // <!--- query the data for file --->
    DownloadFileName = "Planner_Programs_"& URL.plannerID & "_" & DateFormat(now(), "mm_dd_yyyy") & ".csv";
    pathFileName     = "#Application.Doc_Path#\Data_Files\Created\settings\Planners\Download\" & DownloadFileName;
    
    // <!--- Create a STRING BUFFER to hold the output --->
    fileOutput= CreateObject("java","java.lang.StringBuffer").Init();
</cfscript>

<!--- header row --->
<cfif URL.fileParam EQ "Download">
	<cfset fileOutput.append( arrayToList( [ "STATUS"
                                            ,"RFA DAYS"
                                            , "PROGRAM" 
                                            , "TITLE"
                                            , "TYPE"
                                            , "PERF TYPE"
                                            , "BUDGET"
                                            , "DEL START DATE"
                                            , "DEL END DATE" ], "," ) )
                    .append(Chr(13) & Chr(10))>
	
	<!--- detail row: loop through the query, and append the records to the buffer	--->
	<cfloop query="qPlannerPrograms">
        <cfset fileOutput.append( arrayToList( [  '"' & Contract_Status_Type_Desc & '"'
                                                , '"' & RFA_Days & '"'
                                                , '"' & Contract_number & '"'
                                                , '"' & Contract_Title & '"'
                                                , '"' & Created_Type & '"'
                                                , '"' & Description & '"'
                                                , '"' & Budget_Desc & '"'
                                                , '"' & dateFormat(Contract_Start_Date, 'mm/dd/yyyy') & '"'
                                                , '"' & dateFormat(Contract_End_Date, 'mm/dd/yyyy') & '"'
                                                ], "," ) )
		                .append(Chr(13) & Chr(10))>
	</cfloop>
 
 	<!--- Write the string buffer to the file, convert to String ---->
	<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#">	
	<cflocation URL="/getDocument.cfm?filePath=#pathFileName#"> 
</cfif>


