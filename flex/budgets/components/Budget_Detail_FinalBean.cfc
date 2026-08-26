<cfcomponent output="false" alias="flex.budgets.components.Budget_Detail_FinalBean">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="Budget_Detail_Allocation_ID" type="numeric" default="0">
	<cfproperty name="Budget_ID" type="numeric" default="0">
	<cfproperty name="Control_Level_1_Number" type="string" default="">
	<cfproperty name="Control_Level_2_Number" type="string" default="">
	<cfproperty name="Control_Level_1_Name" type="string" default="">
	<cfproperty name="Control_Level_2_Name" type="string" default="">
	<cfproperty name="Level_Value" type="numeric" default="0">
	<cfproperty name="Level_Value_Percentage" type="numeric" default="0">
	<cfproperty name="New_Level_Value" type="numeric" default="0">
	<cfproperty name="New_Level_Value_Percentage" type="numeric" default="0">
	<cfproperty name="Deleted" type="numeric" default="0">
	<cfproperty name="Created_Date" type="date" default="">
	<cfproperty name="Updated_Date" type="date" default="">
	<cfproperty name="Manual_Qty" type="numeric" default="0">
	<cfproperty name="Manual_Percentage" type="numeric" default="0">
	<cfproperty name="Manual_Comments" type="string" default="">
	<cfproperty name="Budget_Adjustment_Change" type="numeric" default="0">
	<cfproperty name="Budget_Value" type="numeric" default="0">
	
	<cfscript>
		//Initialize the CFC with the default properties values.
		variables.Budget_Detail_Allocation_ID = 0;
		variables.Budget_ID = 0;
		variables.Control_Level_1_Number = "";
		variables.Control_Level_2_Number = "";
		variables.Control_Level_1_Name = "";
		variables.Control_Level_2_Name = "";
		variables.Level_Value = 0;
		variables.Level_Value_Percentage = 0;
		variables.New_Level_Value = 0;
		variables.New_Level_Value_Percentage = 0;
		variables.Deleted = 0;
		variables.Created_Date = "";
		variables.Updated_Date = "";
		variables.Manual_Qty = 0;
		variables.Manual_Percentage = 0;
		variables.Manual_Comments = "";
		variables.Budget_Adjustment_Change = 0;
		variables.Budget_Value = 0;
	</cfscript>

	<!--- Initialize Component --->
	<cffunction name="init" output="false" returntype="Budget_Detail_FinalBean">
		<cfreturn this>
	</cffunction>

	<!--- Budget Detail Allocation ID --->	
	<cffunction name="getBudget_Detail_Allocation_ID" output="false" access="public" returntype="any">
		<cfreturn variables.Budget_Detail_Allocation_ID>
	</cffunction>

	<cffunction name="setBudget_Detail_Allocation_ID" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Budget_Detail_Allocation_ID = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>

	<!--- Budget ID--->
	<cffunction name="getBudget_ID" output="false" access="public" returntype="any">
		<cfreturn variables.Budget_ID>
	</cffunction>

	<cffunction name="setBudget_ID" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Budget_ID = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>

	<!--- Control Level 1 Number --->
	<cffunction name="getControl_Level_1_Number" output="false" access="public" returntype="any">
		<cfreturn variables.Control_Level_1>
	</cffunction>

	<cffunction name="setControl_Level_1_Number" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.Control_Level_1_Number = arguments.val>
	</cffunction>

	<!--- Control Level 2 Number --->
	<cffunction name="getControl_Level_2_Number" output="false" access="public" returntype="any">
		<cfreturn variables.Control_Level_2_Number>
	</cffunction>

	<cffunction name="setControl_Level_2_Number" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.Control_Level_2_Number = arguments.val>
	</cffunction>

	<!--- Control Level 1 Name --->
	<cffunction name="getControl_Level_1_Name" output="false" access="public" returntype="any">
		<cfreturn variables.Control_Level_1_Name>
	</cffunction>

	<cffunction name="setControl_Level_1_Name" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.Control_Level_1_Name = arguments.val>
	</cffunction>

	<!--- Control Level 2 Name --->
	<cffunction name="getControl_Level_2_Name" output="false" access="public" returntype="any">
		<cfreturn variables.Control_Level_2_Name>
	</cffunction>

	<cffunction name="setControl_Level_2_Name" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.Control_Level_2_Name = arguments.val>
	</cffunction>

	<!--- Level Value --->
	<cffunction name="getLevel_Value" output="false" access="public" returntype="any">
		<cfreturn variables.Level_Value>
	</cffunction>

	<cffunction name="setLevel_Value" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Level_Value = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>

	<!--- Level Value % --->
	<cffunction name="getLevel_Value_Percentage" output="false" access="public" returntype="any">
		<cfreturn variables.Level_Value_Percentage>
	</cffunction>

	<cffunction name="setLevel_Value_Percentage" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Level_Value_Percentage = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>

	<!--- New Level Value --->
	<cffunction name="getNew_Level_Value" output="false" access="public" returntype="any">
		<cfreturn variables.New_Level_Value>
	</cffunction>

	<cffunction name="setNew_Level_Value" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.New_Level_Value = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>

	<!--- New Level Value %--->
	<cffunction name="getNew_Level_Value_Percentage" output="false" access="public" returntype="any">
		<cfreturn variables.New_Level_Value_Percentage>
	</cffunction>

	<cffunction name="setNew_Level_Value_Percentage" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.New_Level_Value_Percentage = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>

	<!--- Deleted --->
	<cffunction name="getDeleted" output="false" access="public" returntype="any">
		<cfreturn variables.Deleted>
	</cffunction>

	<cffunction name="setDeleted" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Deleted = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>

	<!--- Created Date --->
	<cffunction name="getCreated_Date" output="false" access="public" returntype="any">
		<cfreturn variables.Created_Date>
	</cffunction>

	<cffunction name="setCreated_Date" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsDate(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Created_Date = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid date"/>
		</cfif>
	</cffunction>

	<!--- Updated Date --->
	<cffunction name="getUpdated_Date" output="false" access="public" returntype="any">
		<cfreturn variables.Updated_Date>
	</cffunction>

	<cffunction name="setUpdated_Date" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsDate(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Updated_Date = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid date"/>
		</cfif>
	</cffunction>
	
	<!--- Manual Qty --->
	<cffunction name="getManual_Qty" output="false" access="public" returntype="any">
		<cfreturn variables.Manual_Qty>
	</cffunction>

	<cffunction name="setManual_Qty" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Manual_Qty = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<!--- Manual % --->
	<cffunction name="getManual_Percentage" output="false" access="public" returntype="any">
		<cfreturn variables.Manual_Percentage>
	</cffunction>

	<cffunction name="setManual_Percentage" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Manual_Percentage = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>	
	
	<!--- Manual Comments --->
	<cffunction name="getManual_Comments" output="false" access="public" returntype="any">
		<cfreturn variables.Manual_Comments>
	</cffunction>

	<cffunction name="setManual_Comments" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.Manual_Comments = arguments.val>
	</cffunction>
	
	<!--- Budget Adjustment Change % --->		
	<cffunction name="getBudget_Adjustment_Change" output="false" access="public" returntype="any">
		<cfreturn variables.Budget_Adjustment_Change>
	</cffunction>

	<cffunction name="setBudget_Adjustment_Change" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Budget_Adjustment_Change = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>		
	
	
	<!--- Budget Value --->
	<cffunction name="getBudget_Value" output="false" access="public" returntype="any">
		<cfreturn variables.Budget_Value>
	</cffunction>

	<cffunction name="setBudget_Value" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Budget_Value = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>	
	
	
</cfcomponent>