<cfcomponent hint="Operator" extends="components.Base">
	
	<cffunction name="getOperator" output="false" returntype="query">
		
		<cfargument name="search" type="struct" required="true" />
		<cfargument name="sortBy" type="string" required="false" default="" />
		<cfargument name="sortOrder" type="string" required="false" default="" />
		
		<cfset this.search = arguments.search>
		
		<cfset sqlSortBy="Operator_Name">
		<cfswitch expression="#arguments.sortBy#">
			<cfcase value="Location Type">
				<cfset sqlSortBy="Operator_Location_Type">
			</cfcase>
			<cfcase value="City">
				<cfset sqlSortBy="Operator_City">
			</cfcase>
			<cfcase value="State">
				<cfset sqlSortBy="Operator_State">
			</cfcase>
			<cfcase value="## of Locations">
				<cfset sqlSortBy="CAST(Operator_Number_Of_Locations AS FLOAT)">
			</cfcase>
			<cfcase value="Doing Business As">
				<cfset sqlSortBy="Operator_DBA">
			</cfcase>
			<cfcase value="Position">
				<cfset sqlSortBy="Position_Label">
			</cfcase>	
		</cfswitch>
		
		<cfif UCase(arguments.sortOrder) EQ "DESC">
			<cfset sqlSortBy="#sqlSortBy# DESC">
		<cfelse>
			<cfset sqlSortBy="#sqlSortBy# ASC">
		</cfif>
		
		<cfquery name="qGetOperator" datasource="#application.datasource#">
			SELECT	Legacy_id,BSA_Operator_ID, Operator_Name, Operator_Location_Type, Operator_City, Operator_State, Operator_Number_Of_Locations, Operator_DBA
					<cfif Super.variableExist("this.search.positionId", "")>
					,User_Positions.User_Positions_ID, User_Positions.Position_Label
					</cfif>
			FROM	BSA_Operator
					<cfif Super.variableExist("this.search.positionId", "")>
					INNER JOIN User_Positions
					ON
					User_Positions.Deleted = 0
					AND
					User_Positions.User_Positions_ID = BSA_Operator.User_Positions_ID
					AND
					User_Positions.User_Positions_ID = #FORM.UID#
					</cfif>
			WHERE
					BSA_Operator.Deleted = 0
					AND BSA_Operator.display_code = 'A'
					<cfif Super.variableExist("this.search.categoryId", "")>
						AND Operator_Category_ID = #this.search.categoryId#
					</cfif>
					<cfif Super.variableExist("this.search.priorityId", "")>
						AND Operator_Priority_ID = #this.search.priorityId#
					</cfif>
					<cfif Super.variableExist("this.search.idList", "")><!------ not null ----->
						AND	BSA_Operator.BSA_Operator_ID IN (#this.search.idList#)
					<cfelse>
						<cfif Super.variableExist("this.search.idList", "1")><!------ null ----->
						AND	1	=	2
						</cfif>							
					</cfif>
			ORDER BY #sqlSortBy#
		</cfquery>
		
		<cfreturn qGetOperator />
		
	</cffunction>
	
	<cffunction name="saveOperatorPosition" output="false">
		
		<cfargument name="positionId" type="numeric" required="true" />
		<cfargument name="idList" type="string" required="false" default="" />
		
		<cfif arguments.idList NEQ "">
			<cfquery name="updateoperatorposition" datasource="#application.datasource#">
				UPDATE	BSA_Operator
				SET		BSA_Operator.User_Positions_ID = #arguments.positionId#
				WHERE
						BSA_Operator.BSA_Operator_ID IN (#arguments.idList#)
			</cfquery>
		</cfif>
	
	</cffunction>
	
</cfcomponent>