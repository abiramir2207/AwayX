<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\last_update.cfm
      Date:     2013 March
      Author:   Chris Nguyen
      Purpose:  Update Budget.Last_Updated_By/Date columns
----------------------------------------------------------------------------------------------------------------------->

UPDATE Budget
   SET   Last_Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
       , Last_Updated_Date = GETDATE()
 WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
