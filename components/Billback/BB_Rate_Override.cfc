<cfcomponent>
	<cffunction name="init" output="false" returntype="components.Billback.BB_Rate_Override">
		<cfreturn this />
</cffunction>

<cffunction name="BB_Rate_Override_Info_ById" access="public" ouput="false" returntype="query">
 <cfargument name="Billback_Id" type="String" required="true" />
 <cfset var get_BB_Rate_Override = "" />

    <cfquery name="get_BB_Rate_Override" datasource="#application.datasource#">
      Select BB_Rate_Override_ID
	  From  BB_Rate_Override
	  Where Billback_Id = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="CF_SQL_VARCHAR" />
    </cfquery>
	
	<cfreturn get_BB_Rate_Override />

</cffunction>
<cffunction name="update_BB_Rate_Override" access="public" ouput="false" returntype="void">
 <cfargument name="rate_override_id" type="numeric" required="true" />
 <cfargument name="deleted" type="numeric" required="true" />
 <cfset var qUpdate_BB_Rate_Override = "" />
 
 <cfquery name="qUpdate_BB_Rate_Override" datasource="#application.datasource#">
  	Update BB_Rate_Override
  	Set Override_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.accessstructure.user_id#" />,
      	Deleted =     <cfqueryparam value="#arguments.deleted#" cfsqltype="CF_SQL_BIT" />
  	where BB_Rate_Override_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.rate_override_id#" />
 </cfquery>
 
</cffunction>

<cffunction name="insertBBRate" access="public" ouput="false" returntype="void">
 <cfargument name="billback_Id" type="string" required="true" />
 <cfset var insert_BB_Rate_Override = "" />

 <cfquery name="insert_BB_Rate_Override" datasource="#application.datasource#">
  		Insert Into BB_Rate_Override(Billback_ID,Override_By)
  		Values(<cfqueryparam value="#arguments.billback_Id#" cfsqltype=" cf_sql_varchar" />,
	           <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.accessstructure.user_id#" />
	          )
 </cfquery>
</cffunction>
 
 <cffunction name="getBBRateOverrideInfo" access="public" ouput="false" returntype="query">
  <cfargument name="billback_id" type="string" required="true" />
   <cfset var qGetRateOverrideInfo = "" />
   
  <cfquery name="qGetRateOverrideInfo" datasource="#application.datasource#">
   Select BB_Rate_Override.Override_Date,_Users.Name_First + ' ' + _Users.Name_Last As UserName
   From BB_Rate_Override
   Inner Join _Users
   On _Users.User_Id = BB_Rate_Override.Override_By
   where BB_Rate_Override.deleted = 0
   And BB_Rate_Override.billback_Id = <cfqueryparam value="#arguments.billback_Id#" cfsqltype=" cf_sql_varchar" />
 </cfquery>

 <cfreturn qGetRateOverrideInfo />
 </cffunction>
</cfcomponent>