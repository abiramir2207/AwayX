<cfcomponent>
	<cffunction name="init" output="false" returntype="components.Billback.BB_Volume_Override">
		<cfreturn this />
</cffunction>

<cffunction name="BB_Override_Info_ById" access="public" ouput="false" returntype="query">
 <cfargument name="Billback_Id" type="String" required="true" />
 <cfset var get_BB_Volume_Override = "" />

    <cfquery name="get_BB_Volume_Override" datasource="#application.datasource#">
      Select BB_Volume_Override_ID
	  From  BB_Volume_Override
	  Where Billback_Id = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="CF_SQL_VARCHAR" />
    </cfquery>
	
	<cfreturn get_BB_Volume_Override />

</cffunction>
<cffunction name="update_BB_Override" access="public" ouput="false" returntype="void">
 <cfargument name="volume_override_id" type="numeric" required="true" />
 <cfargument name="deleted" type="numeric" required="true" />
 <cfset var update_BB_Volume_Override = "" />
 
 <cfquery name="update_BB_Volume_Override" datasource="#application.datasource#">
  	Update BB_Volume_Override
  	Set Override_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.accessstructure.user_id#" />,
      	Deleted =     <cfqueryparam value="#arguments.deleted#" cfsqltype="CF_SQL_BIT" />
  	where BB_Volume_Override_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.volume_override_id#" />
 </cfquery>
 
</cffunction>

<cffunction name="insertBBVolume" access="public" ouput="false" returntype="void">
 <cfargument name="billback_Id" type="string" required="true" />
 <cfset var insert_BB_Volume_Override = "" />

 <cfquery name="insert_BB_Volume_Override" datasource="#application.datasource#">
  		Insert Into BB_Volume_Override(Billback_ID,Override_By)
  		Values(<cfqueryparam value="#arguments.billback_Id#" cfsqltype=" cf_sql_varchar" />,
	           <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.accessstructure.user_id#" />
	          )
 </cfquery>
</cffunction>
 
 <cffunction name="getBBOverrideInfo" access="public" ouput="false" returntype="query">
  <cfargument name="billback_id" type="string" required="true" />
   <cfset var qGetOverrideInfo = "" />
   
  <cfquery name="qGetOverrideInfo" datasource="#application.datasource#">
   Select BB_Volume_Override.Override_Date,_Users.Name_First + ' ' + _Users.Name_Last As UserName
   From BB_Volume_Override
   Inner Join _Users
   On _Users.User_Id = BB_Volume_Override.Override_By
   where BB_Volume_Override.deleted = 0
   And BB_Volume_Override.billback_Id = <cfqueryparam value="#arguments.billback_Id#" cfsqltype=" cf_sql_varchar" />
 </cfquery>

 <cfreturn qGetOverrideInfo />
 </cffunction>
</cfcomponent>