<cfcomponent hint="check template access and redirect" extends="components.ajaxCFC.ajax">
	
	<cffunction name="verifyTemplateAccess" output="no" returntype="numeric">
		<cfargument      name="Billback_ID" type="string" required="true">
		<cfargument      name="forbidType" type="boolean" required="true">
		<cfargument      name="Profiles_ID" type="numeric" required="true">
        
			<cfquery name="qverifyTemplateAccess" datasource="#Application.Datasource#">	
				DECLARE @Profile_Forbidden_Template table
				(
				  Template_ID   int          NOT NULL,
				  Forbid_Access_Type int          NOT NULL
				)
				INSERT INTO @Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
				select 	distinct template_id, Forbid_Access_Type
				from 	Profile_Forbidden_Template 
				where 	Deleted = 0
						AND Forbid_Type = #arguments.forbidType#
						AND profile_id = #arguments.Profiles_ID#
			
				SELECT Billback_ID
					FROM Billback_Program
					INNER JOIN Contract_Main
					ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
					WHERE Billback_Program.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND Billback_Program.Deleted = 0
					AND Contract_Main.ProgramType_ID
					<cfif forbidType EQ 0>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
					in 
					<!--- (Forbid_Access_Type = 1 means 'Access') --->
					(select Template_ID from @Profile_Forbidden_Template WHERE Forbid_Access_Type = 1)
			</cfquery> 

	   	<CFIF qverifyTemplateAccess.RecordCount EQ 0>
	      	<cfreturn 1>
		<CFELSE>
			<cfreturn 0>
		</CFIF>
	</cffunction>
</cfcomponent>
