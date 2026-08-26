<cfcomponent output="false" alias="components.Billback.BB_Auto_Report_Period">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="BB_Auto_Report_Period_ID" type="numeric" default="0">
	<cfproperty name="start_date" type="date" default="">
	<cfproperty name="end_date" type="date" default="">
	<cfproperty name="span" type="numeric" default="0">

	<cfscript>
		//Initialize the CFC with the default properties values.
		variables.BB_Auto_Report_Period_ID = 0;
		variables.start_date = "";
		variables.end_date = "";
		variables.span = 0;
	</cfscript>

	<cffunction name="init" output="false" returntype="BB_Auto_Report_Period">
		<cfargument name="id" required="false">
		<cfscript>
			if( structKeyExists(arguments, "id") )
			{
				load(arguments.id);
			}
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="getBB_Auto_Report_Period_ID" output="false" access="public" returntype="any">
		<cfreturn variables.BB_Auto_Report_Period_ID>
	</cffunction>

	<cffunction name="setBB_Auto_Report_Period_ID" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val))>
			<cfset variables.BB_Auto_Report_Period_ID = arguments.val>
		<cfelse>
			<cfset variables.BB_Auto_Report_Period_ID = 0>
		</cfif>
	</cffunction>

	<cffunction name="getStart_date" output="false" access="public" returntype="any">
		<cfreturn variables.Start_date>
	</cffunction>

	<cffunction name="setStart_date" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsDate(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Start_date = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid date"/>
		</cfif>
	</cffunction>

	<cffunction name="getEnd_date" output="false" access="public" returntype="any">
		<cfreturn variables.End_date>
	</cffunction>

	<cffunction name="setEnd_date" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsDate(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.End_date = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid date"/>
		</cfif>
	</cffunction>

	<cffunction name="getSpan" output="false" access="public" returntype="any">
		<cfreturn variables.Span>
	</cffunction>

	<cffunction name="setSpan" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Span = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>



	<cffunction name="save" output="false" access="public" returntype="BB_Auto_Report_Period">
		<cfscript>
			if(getBB_Auto_Report_Period_ID() eq 0)
			{
				create();
			}else{
				update();
			}
		</cfscript>
		<cfreturn init(variables.BB_Auto_Report_Period_ID)>
	</cffunction>



	<cffunction name="load" output="false" access="public" returntype="void">
		<cfargument name="id" required="true" >
		<cfset var qRead="">
		<cfquery name="qRead" datasource="#application.datasource#">
			select 	BB_Auto_Report_Period_ID, start_date, end_date, span
			from dbo.BB_Auto_Report_Period
			where BB_Auto_Report_Period_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.id#" />
		</cfquery>

		<cfscript>
			setBB_Auto_Report_Period_ID(qRead.BB_Auto_Report_Period_ID);
			setstart_date(qRead.start_date);
			setend_date(qRead.end_date);
			setspan(qRead.span);
		</cfscript>
	</cffunction>



	<cffunction name="create" output="false" access="private" returntype="void">
		<cfset var qCreate="">

		<cfset var local1=getstart_date()>
		<cfset var local2=getend_date()>
		<cfset var local3=getspan()>

		<cftransaction isolation="read_committed">
			<cfquery name="qCreate" datasource="#application.datasource#">
				insert into dbo.BB_Auto_Report_Period(start_date, end_date, span)
				values (
					<cfqueryparam value="#local1#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((local1 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local2#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((local2 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local3#" cfsqltype="CF_SQL_INTEGER" null="#iif((local3 eq ""), de("yes"), de("no"))#" />
				)
				SELECT Scope_Identity() AS PayPeriodId 
			</cfquery>

		<!--- 	<!--- If your server has a better way to get the ID that is more reliable, use that instead --->
			<cfquery name="qGetID" datasource="#application.datasource#">
				select BB_Auto_Report_Period_ID
				from dbo.BB_Auto_Report_Period
				where start_date = <cfqueryparam value="#local1#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((local1 eq ""), de("yes"), de("no"))#" />
				  and end_date = <cfqueryparam value="#local2#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((local2 eq ""), de("yes"), de("no"))#" />
				  and span = <cfqueryparam value="#local3#" cfsqltype="CF_SQL_INTEGER" null="#iif((local3 eq ""), de("yes"), de("no"))#" />
				order by BB_Auto_Report_Period_ID desc
			</cfquery> --->
		</cftransaction>

		<cfset variables.BB_Auto_Report_Period_ID = qCreate.PayPeriodId>
	</cffunction>



	<cffunction name="update" output="false" access="private" returntype="void">
		<cfset var qUpdate="">

		<cfquery name="qUpdate" datasource="#application.datasource#" result="status">
			update dbo.BB_Auto_Report_Period
			set start_date = <cfqueryparam value="#getstart_date()#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((getstart_date() eq ""), de("yes"), de("no"))#" />,
				end_date = <cfqueryparam value="#getend_date()#" cfsqltype="CF_SQL_TIMESTAMP" null="#iif((getend_date() eq ""), de("yes"), de("no"))#" />,
				span = <cfqueryparam value="#getspan()#" cfsqltype="CF_SQL_INTEGER" null="#iif((getspan() eq ""), de("yes"), de("no"))#" />
			where BB_Auto_Report_Period_ID = <cfqueryparam value="#getBB_Auto_Report_Period_ID()#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cffunction>



	<cffunction name="delete" output="false" access="public" returntype="void">
		<cfset var qDelete="">

		<cfquery name="qDelete" datasource="#application.datasource#" result="status">
			delete
			from dbo.BB_Auto_Report_Period
			where BB_Auto_Report_Period_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getBB_Auto_Report_Period_ID()#" />
		</cfquery>
	</cffunction>


</cfcomponent>