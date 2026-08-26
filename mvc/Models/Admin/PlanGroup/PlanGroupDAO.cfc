<cfcomponent output="false" alias="mvc.Models.Admin.PlanGroup.PlanGroupDAO">

	<cfscript>
		variables.oPlanGroupManager = createObject('component','components.settings.PlanningGroups.PlanningGroupsManager').init();
	</cfscript>

	<cffunction name="init" output="false" returntype="mvc.Models.Admin.PlanGroup.PlanGroupDAO">
		<cfreturn this />
	</cffunction>

	<cffunction name="getPlanGroupTypeByGrpType" returntype="Query" access="public" >
		<cfargument name="GroupID" required="true" type="string"  />
    	<!---<cfset var qGetActivePGTypeByGrpType = "" />
		<cfquery name="qGetActivePGTypeByGrpType" datasource="#application.datasource#">
			SELECT
		        PG_Type_ID,
		        PG_Type_Code,
		        PG_Type_Name,
		        PG_Group_Type,
		        Active,
		        Deleted,
		        Updated_Date,
		        Created_Date,
		        Created_By,
		        Updated_By
			FROM		PG_Type
			WHERE Active = 1
		    AND   PG_Group_Type = <cfqueryparam value="#arguments.GroupID#" cfsqltype="cf_sql_integer"/>
		    AND   Deleted = 0
    	</cfquery>
		<cfreturn qGetActivePGTypeByGrpType />--->

		<cfreturn oPlanGroupManager.fnGetActivePGTypesByGrpType(arguments.GroupID) />
	</cffunction>

	<cffunction name="getPlanGroupTypeCategory" returntype="Query" access="public" >
		<cfargument name="typeId" required="true" type="string"  />
		<cfargument name="groupTypeId" required="true" type="string"  />
    	<!---

		--->
		<cfscript>
			// Define the local scope.
			var LOCAL = StructNew();
			var qGetPlanGroupTypeMembers = '';
			var newColumnName = '';
			var oldColumnName = '';
			var oldList =
						"PG_Product_Category_ID,
						PG_Customer_Category_ID,
				        PG_Type_ID,
				        PG_Product_Category_Code,
				        PG_Product_Category_Name,
						PG_Customer_Category_Code,
				        PG_Customer_Category_Name,
				        Include_In_Other_PG";
			var newList =
						"categoryId,
						categoryId,
				        typeId,
				        code,
				        name,
						code,
				        name,
				        includeInOther";
			newlist = listToArray(newlist);
			oldList= listToArray(oldList);

			if(groupTypeId == 1){
				qGetPlanGroupTypeMembers = oPlanGroupManager.fnGetProductPGByTypeID(arguments.typeId);
			}
			else if(groupTypeId == 2){
				qGetPlanGroupTypeMembers = oPlanGroupManager.fnGetCustomerPGByTypeID(arguments.typeId);
			}
			 /* Rename columns to handle for different tables Product vs Item col names */
			// Get the list of column names.
			LOCAL.Columns = qGetPlanGroupTypeMembers.GetColumnNames();

			// Convert to a list so we can find the column name.
			LOCAL.ColumnList = ArrayToList(LOCAL.Columns);
			LOCAL.Columns = ListToArray(LOCAL.ColumnList);
			//WriteLog(file="application.log", text="#LOCAL.ColumnList# :: dao pg Type");
			 for(var i=1; i<=arrayLen(oldList); i++){
			 	newColumnName = trim(newList[i]);
				oldColumnName = trim(oldList[i]);

				// Get the index of the column name.
				LOCAL.ColumnIndex = ListFindNoCase(LOCAL.ColumnList,oldColumnName);
			 	// Make sure we have found a column.
				if (LOCAL.ColumnIndex){
					// Update the column name. We have to create our own array based on the list
					//since we cannot directly update the array passed back from the query object.
					LOCAL.Columns[ LOCAL.ColumnIndex ] = newColumnName;
					qGetPlanGroupTypeMembers.SetColumnNames(LOCAL.Columns);
					//WriteLog(file="application.log", text="#newColumnName# :: #oldColumnName# :: #ColumnIndex# :: #LOCAL.Columns[ LOCAL.ColumnIndex ]#  :: dao pg Type 2");
					//WriteLog(file="application.log", text="#qGetPlanGroupTypeMembers.GetColumnNames()[LOCAL.ColumnIndex]#  :: dao pg Type32");

				}

			 }
			// Set the column names.
			qGetPlanGroupTypeMembers.SetColumnNames(LOCAL.Columns);
		</cfscript>

		<cfreturn qGetPlanGroupTypeMembers />
	</cffunction>

</cfcomponent>