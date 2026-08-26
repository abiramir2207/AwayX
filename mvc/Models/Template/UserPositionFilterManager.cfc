<cfcomponent hint="Manage User Positions for a Template Filter" name="UserPositionFilterManager" alias="mvc.Models.Template.UserPositionFilterManager">
	
	<cffunction name="getUserPositionFilterList" hint="get comma seperated list of user position Ids" returntype="String" >
    	<cfargument name="Template_Filters_Id" type="Numeric" required="true" />

		<cfquery name="qGetUserPositionFilterList" datasource="#application.datasource#">
			SELECT	TFUP.User_Positions_Id
			FROM Template_Filters TF
			INNER JOIN Template_Filter_User_Positions TFUP ON
				TFUP.Template_Filters_Id = TF.Template_Filters_Id
			WHERE TF.Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#"> AND
				TF.Deleted = 0
		</cfquery>
		 <cfreturn ValueList(qGetUserPositionFilterList.User_Positions_Id,",")/>
    </cffunction>
	
	<cffunction name="getUserPositionFilterArray" hint="get array of user_position objs" returntype="Array" >
    	<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfscript>
			var stData = structNew();
			var arrPositionFilter = ArrayNew(1);
		</cfscript>
		<cfquery name="qGetUserPosFlt" datasource="#application.datasource#">
			SELECT	TFUP.User_Positions_Id,
					UP.Position_Label
			FROM Template_Filters TF
			INNER JOIN Template_Filter_User_Positions TFUP ON
				TFUP.Template_Filters_Id = TF.Template_Filters_Id
			LEFT JOIN User_Positions UP ON
				UP.User_Positions_Id = TFUP.User_Positions_Id
			WHERE TF.Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#"> AND
				TF.Deleted = 0
		</cfquery>
		<cfloop query="qGetUserPosFlt">
			<cfscript>
				stData = structNew();
				stData["__type__"] = "mvc.Models.Template.vos.UserPosition";
				stData["User_Positions_Id"] = qGetUserPosFlt.User_Positions_Id;
				stData["positionLabel"] = qGetUserPosFlt.Position_Label;
	        	ArrayAppend(arrPositionFilter, duplicate(stData));
			</cfscript>
		</cfloop>
		 <cfreturn arrPositionFilter />
    </cffunction>
    
	<!---Save to DB--->
	<cffunction name="setUserPositionFilterList" hint="insert list of user positions" returntype="numeric">
    	<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="userPositionsList" type="String" required="true" />
		<cfscript>
			var counter = 0;
			var list = application.util.list.removeDupes(arguments.userPositionsList);
		</cfscript>
		<cfquery name="qDelUPList" datasource="#application.datasource#">
			DELETE FROM Template_Filter_User_Positions
			WHERE  Template_Filters_Id =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#">
		</cfquery>
		<cfloop list="#list#" index="idx">
			<cfquery name="qLogMPRates" datasource="#application.datasource#">
				INSERT INTO Template_Filter_User_Positions (
					Template_Filters_Id,
					User_Positions_Id
				)
				SELECT 
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#idx#">
			</cfquery>
			<cfset counter =  counter + 1 />
		</cfloop>
    	<cfreturn counter />
    </cffunction>
</cfcomponent>