<cfcomponent hint="Manage how Brokerage rates are handled when calculating Margin" extends="components.Base" output="false">
	
	<cffunction name="init" returntype="Components.Programs.Approval.BrokerageMarginCalc">
		<cfreturn this>
	</cffunction>
	
	<cffunction output="false" name="getMarginCalcSetting" returntype="Query">
			<CFQUERY NAME="qGetMarginCalc" datasource="#application.datasource#">
				SELECT BMC.*,
						 _Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName
				FROM Brokerage_Margin_Calc_Settings BMC
				LEFT JOIN _Users 
				ON _Users.User_ID = BMC.Upd_User_Id
			</CFQUERY>
			<cfreturn qGetMarginCalc>
	</cffunction>
	
	
	<cffunction name="updBrkMrgCalcSetting" access="public" output="false" returntype="void">
    	<cfargument name="column" type="string" required="true" />
		<cfargument name="value" type="Numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
       <CFQUERY NAME="qGetMarginCalc" datasource="#application.datasource#">
				UPDATE Brokerage_Margin_Calc_Settings 
				SET Status =  #arguments.value#,
					Upd_user_id = '#arguments.userId#',
					Upd_Date = getDate()
				WHERE column_Name = '#arguments.column#'
		</CFQUERY>
		
    </cffunction>
</cfcomponent>