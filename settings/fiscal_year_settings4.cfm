<!--- generate fiscal year name based on end date of last period --->
<cfset Fiscal_Year = "FY_" & dateFormat( form[ 'Period_' & form.Number_of_periods & '_Ending_Date'], 'yyyy' )>

<!---  determine if fiscal year exists & get the number of periods based on record count --->
<cfquery name="getFiscalYear" datasource="#application.datasource#">
  SELECT 1
    FROM Fiscal_Year
   WHERE Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
         AND Fiscal_Year = '#Fiscal_Year#'
         AND Deleted = 0
</cfquery>

<cfset oldPeriodCount = getFiscalYear.recordCount>

<!---  fiscal year exists  --->
<cfif oldPeriodCount>
	<!---  track updated fiscal year rows in this array --->
	<cfset updated_Fiscal_Year_ID = []>

  <cfloop index="i" from="1" to="#form.number_of_periods#">
  	<cfset formPeriodID = FORM[ "Period_" & i & "_ID" ]>

    <cfquery datasource="#application.datasource#">
      <!--- formPeriodID has value the row exists --->
      <cfif len(trim(formPeriodID))>
	      UPDATE Fiscal_year
	         SET Start_Date      = #createodbcdatetime( form[ "Period_" & i & "_Starting_Date" ] )#
	             ,End_Date       = #createodbcdatetime( form[ "Period_" & i & "_Ending_Date"   ] )#
	             ,Period_Length  = #form[ "Period_" & i & "_Length" ]#
	             ,Fiscal_Year    = '#Fiscal_Year#'
	             ,Last_Updated   = #createodbcdatetime(now())#
	             ,Last_Updated_By_User_ID = '#request.AccessStructure.User_ID#'
	       WHERE Fiscal_Year_ID =  '#formPeriodID#'
      <cfelse>
        <!--- formPeriodID is blank user increased no. of periods --->
	      INSERT INTO Fiscal_year
		      (
		         Start_Date
		        ,End_Date
		        ,Fiscal_Year
		        ,Company_Main_ID
		        ,Period_Length
		        ,Last_Updated
		        ,Last_Updated_By_User_ID
		      )
	      VALUES
		      (
		         #createodbcdatetime( form[ "Period_" & i & "_Starting_Date" ] )#
		        ,#createodbcdatetime( form[ "Period_" & i & "_Ending_Date"   ] )#
		        ,'#Fiscal_Year#'
		        ,'#request.AccessStructure.Company_Main_ID#'
		        ,#form[ "Period_" & i & "_Length" ]#
		        ,#createodbcdatetime(now())#
		        ,'#request.AccessStructure.User_ID#'
		      )
      </cfif>
    </cfquery>

    <!---  keep track of updated rows  --->
    <cfif len(trim(formPeriodID))>
    	<cfset arrayAppend( updated_Fiscal_Year_ID, formPeriodID )>
    </cfif>
  </cfloop>

  <!---  delete extra rows because # of periods decreased  --->
  <cfif oldPeriodCount gt form.number_of_periods>
	  <cfquery name="deletepriorcalendar" datasource="#application.datasource#">
	    UPDATE Fiscal_year
	       SET Deleted = 1
	     WHERE Fiscal_Year = '#Fiscal_Year#'
	           AND Company_main_ID = '#request.AccessStructure.Company_Main_ID#'
	           AND Fiscal_Year_ID NOT IN ( <cfqueryparam list="true" value="#arrayToList( updated_Fiscal_Year_ID )#"> )
	  </cfquery>
  </cfif>

<cfelse>

  <cfquery name="deletepriorcalendar" datasource="#application.datasource#">
    UPDATE Fiscal_year
       SET Deleted = 1
     WHERE Fiscal_Year = '#Fiscal_Year#'
           AND Company_main_ID = '#request.AccessStructure.Company_Main_ID#'
  </cfquery>

  <cfloop index="i" from="1" to="#form.number_of_periods#">
    <cfquery datasource="#application.datasource#">
	      INSERT INTO Fiscal_year
		      (
		         Start_Date
		        ,End_Date
		        ,Fiscal_Year
		        ,Company_Main_ID
		        ,Period_Length
		        ,Last_Updated
		        ,Last_Updated_By_User_ID
		      )
	      VALUES
		      (
		         #createodbcdatetime( form[ "Period_" & i & "_Starting_Date" ] )#
		        ,#createodbcdatetime( form[ "Period_" & i & "_Ending_Date"   ] )#
		        ,'#Fiscal_Year#'
		        ,'#request.AccessStructure.Company_Main_ID#'
		        ,#form[ "Period_" & i & "_Length" ]#
		        ,#createodbcdatetime(now())#
		        ,'#request.AccessStructure.User_ID#'
		      )
    </cfquery>
  </cfloop>

</cfif>


<cflocation URL="fiscal_year_settings.cfm">