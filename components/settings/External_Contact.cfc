<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\settings\External_Contact.cfc
	Date:      2015 September
	Author:    Chris Nguyen

	Remarks:   Form elements and url elements should be marged into request variables in the caller template prior to calling these non-remote functions
			   <!--- 52788 --->
--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cfcomponent displayname="External Contact" output="no" hint="Houses all external contact functions.">

	<cffunction name="get_contact" access="public" output="no" hint="Return an existing contact based on request variable." returntype="query">
		<cfquery name="local.get_contact" datasource="#application.datasource#">
			SELECT  First_Name
					, Last_Name
					, Email
					, Title
					, Company_Code
					, Company_Name
					, Notes
					, Address
					, City
					, State
					, ZIP
					, Phone
					, Ext
					, Fax
			  FROM External_Contacts
			 WHERE Contact_ID = <cfqueryparam  value="#request.contact_id#"  cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn local.get_contact>
	</cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="get_states" access="public" output="no" hint="Return states in US." returntype="query">
		<cfquery name="local.get_states" datasource="#application.datasource#">
			SELECT s.*, c.Country_Sort_Order
			  FROM _states s
			       JOIN _country c on s.Country_ID = c.Country_ID
			 ORDER BY isnull(c.Country_Sort_Order, c.country_id)
		</cfquery>

		<cfreturn local.get_states>
	</cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="add_contact" access="public" output="no" hint="Add a new contact based on request variables.">
		<cfquery name="local.add_contact" datasource="#application.datasource#">
			DELETE External_Contacts WHERE Deleted = 1
			INSERT INTO External_Contacts
						( First_Name
						, Last_Name
						, Email
						, Company_Code
						, Company_Name
						, Notes
						, Address
						, City
						, State
						, ZIP
						, Phone
						, Ext
						, Fax
						, Title
						)
				VALUES
						(  <cfqueryparam  value="#request.first_name#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.last_name#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.email#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.company_code#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.company_name#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.notes#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.address#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.city#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.state#"  cfsqltype="cf_sql_char"  null="#request.stateNull#">
						  ,<cfqueryparam  value="#request.zip#"  cfsqltype="cf_sql_char"  null="#request.zipNull#">
						  ,<cfqueryparam  value="#request.combined_phone#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.phone_ext#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.combined_fax#"  cfsqltype="cf_sql_char">
						  ,<cfqueryparam  value="#request.title#"  cfsqltype="cf_sql_char">
						)
		</cfquery>
	</cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="update_contact" access="public" output="no" hint="Update an existing contact based on request variables.">
		<cfquery name="local.update_contact" datasource="#application.datasource#">
           UPDATE  External_Contacts
              SET  First_Name     = <cfqueryparam value="#request.first_name#"  cfsqltype="cf_sql_char">
                   , Last_Name    = <cfqueryparam value="#request.last_name#"  cfsqltype="cf_sql_char">
                   , Email        = <cfqueryparam value="#request.email#"  cfsqltype="cf_sql_char">
                   , Company_Code = <cfqueryparam value="#request.company_code#"  cfsqltype="cf_sql_char">
                   , Company_Name = <cfqueryparam value="#request.company_name#"  cfsqltype="cf_sql_char">
                   , Notes        = <cfqueryparam value="#request.notes#"  cfsqltype="cf_sql_char">
                   , Address      = <cfqueryparam value="#request.address#"  cfsqltype="cf_sql_char">
                   , City         = <cfqueryparam value="#request.city#"  cfsqltype="cf_sql_char">
                   , State        = <cfqueryparam value="#request.state#"  cfsqltype="cf_sql_char"  null="#request.stateNull#">
                   , ZIP          = <cfqueryparam value="#request.zip#"  cfsqltype="cf_sql_char"  null="#request.zipNull#">
                   , Phone        = <cfqueryparam value="#request.combined_phone#"  cfsqltype="cf_sql_char">
                   , Ext          = <cfqueryparam value="#request.phone_ext#"  cfsqltype="cf_sql_char">
                   , Fax          = <cfqueryparam value="#request.combined_fax#"  cfsqltype="cf_sql_char">
                   , Title        = <cfqueryparam value="#request.title#"  cfsqltype="cf_sql_char">
            WHERE Contact_ID = <cfqueryparam value="#request.contact_id#"  cfsqltype="cf_sql_integer">
		</cfquery>
	</cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="delete_contact" access="public" returntype="void" output="no" hint="Delete a contact based on request ID">
		<cfquery name="local.query" datasource="#application.datasource#">
			DELETE External_Contacts
			 WHERE Contact_ID = <cfqueryparam value="#request.contact_id#"  cfsqltype="cf_sql_integer">
		</cfquery>
	</cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="is_duplicate_contact" access="remote" returnFormat="json" output="no">
		<cfargument name="contact_id" required="true" type="numeric">
		<cfargument name="first_name" required="true" type="string">
		<cfargument name="last_name" required="true" type="string">
		<cfargument name="company_code" required="true" type="string">
		<cfargument name="email" required="true" type="string">

		<!--- locate contact with same name, same company code & same email --->
		<cfquery name="local.duplicateExists" datasource="#application.datasource#">
			SELECT 1
			  FROM External_Contacts
			 WHERE First_Name =  <cfqueryparam  value="#arguments.first_name#"    cfsqltype="cf_sql_varchar">
			   AND Last_Name  =  <cfqueryparam  value="#arguments.last_name#"  cfsqltype="cf_sql_varchar">
			   AND Company_Code =  <cfqueryparam  value="#arguments.company_code#"  cfsqltype="cf_sql_varchar">
			   AND Email        =  <cfqueryparam  value="#arguments.email#"  cfsqltype="cf_sql_varchar">
			   AND Contact_ID <> <cfqueryparam  value="#arguments.contact_id#"   cfsqltype="cf_sql_integer">
			   AND Deleted = 0
		</cfquery>

		<cfscript>
			local.result = {};
			local.result.duplicateExists = (local.duplicateExists.recordCount gt 0);
		</cfscript>

		<cfreturn local.result>
	</cffunction>
</cfcomponent>

