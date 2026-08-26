<cfcomponent displayname="Alias Sources Manager" output="false">

<cffunction name="init" output="false" >
		<cfreturn this />
</cffunction>


<cffunction name="getAliasSourceTypes" hint="return all the Alias Sources Type records that macthes the criteria" access="public" output="false" returntype="query">
	
	<cfargument name="BBClaimSourceXREFID" type="numeric" required="false" default="0" />
	<cfargument name="SearchSourceCode" type="string" required="false" default="" />
	<cfargument name="SearchSourceTypeDescription" type="string" required="false" default="" />
	<cfargument name="SearchActive" type="numeric" required="false" default="2" />
	<cfargument name="SearchCreatedSinceDate" type="string" required="false" default="" />

	<cfif IsDate(arguments.SearchCreatedSinceDate) >
			<cfset Search_Created_Since_Date = #DateFormat(arguments.SearchCreatedSinceDate, "mm/dd/yyyy")#/>
	<cfelse>
			<cfset Search_Created_Since_Date = ""/>
	</cfif>

	 
	<cfset var qGetAliasSourcesTypes = "" />
	
	<cfquery name="qGetAliasSourcesTypes" datasource="#application.datasource#">
		SELECT	*
		FROM	BB_Claim_Source_XREF
		WHERE	1=1
		<cfif BBClaimSourceXREFID neq 0>
			AND BB_Claim_Source_XREF_ID = #BBClaimSourceXREFID#
		<cfelse>
			<cfif len(trim(arguments.SearchSourceCode)) GT 0>
				AND Source_Code like '%#SearchSourceCode#%'
			</cfif>
			<cfif len(trim(arguments.SearchSourceTypeDescription)) GT 0>
				AND Source_Type_Description like '%#SearchSourceTypeDescription#%'
			</cfif>
			<cfif  arguments.SearchActive LT 2>
				AND Active = #SearchActive#
			</cfif>
			<cfif len(trim(Search_Created_Since_Date)) GT 0>
				AND Created_Date >=  '#Search_Created_Since_Date#'
			</cfif>
		</cfif>
		ORDER BY BB_Claim_Source_XREF.Source_Code, BB_Claim_Source_XREF.Source_Type_Description
	</cfquery>
	
	<cfreturn qGetAliasSourcesTypes />	
</cffunction>

<cffunction name="addEditAliasSourcesType" hint="insert/update credit type record" access="public" output="false" returntype="any">

	<cfargument name="BBClaimSourceXREFID" type="numeric" required="true" />
	<cfargument name="SourceCode" type="string" required="true" />
	<cfargument name="SourceType" type="string" required="true" />
	<cfargument name="Active" type="boolean" required="true" />
	<cfargument name="userID" type="string" required="true" />
	<cfargument name="DisplayInOCR" type="boolean" required="false" />

	<cfset var Source_Code = LTRIM(RTRIM(arguments.SourceCode))>
	
	<cfset var qInsertData = "" />
	<cfset var qUpdateData = "" />
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	<cfquery name="qCheckIfExists" datasource="#application.datasource#">
			<!--- Dev Note(70533) - We should only check a combination of source_code and source_type --->
			SELECT * FROM BB_Claim_Source_XREF
			WHERE 	Source_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Source_Code#" /> 
			AND Source_Type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.SourceType#" />
	</cfquery>
	<!--- Check to see if the values  that --->
	<cfif (qCheckIfExists.RecordCount EQ 0 AND arguments.BBClaimSourceXREFID EQ 0)>
		<!--- Insert the record --->
			<CFQUERY NAME="qInsertData" datasource="#application.datasource#">
				INSERT INTO BB_Claim_Source_XREF
					(
					Source_Code,
					Source_Type, 
					Source_Type_Description,
					Created_By,
					Display_In_OCR
					)
				VALUES
					(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Source_Code#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.SourceType#" />,
					(select TOP 1 UPPER(Source_Type_Desc) from BB_Upload_Source_Type_Lookup where Source_Type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.SourceType#" />), 
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#" />
					<cfif (appSettings.get_Setting('OCR_Upload_ON') EQ '1')>
						,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.DisplayInOCR#" />
					<cfelse>
						,<cfqueryparam cfsqltype="cf_sql_bit" value="0" />
					</cfif>	
					)
			</CFQUERY>
			<cfset strRetMessage = "Record was successfully added!!" />
		<cfelseif (qCheckIfExists.RecordCount EQ 1 AND arguments.BBClaimSourceXREFID NEQ 0)>
			<!--- Update the record --->
			<CFQUERY NAME="qUpdateData" datasource="#application.datasource#">
				UPDATE 		BB_Claim_Source_XREF
				SET 		Source_Code 		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#Source_Code#" />,
						Source_Type 		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.SourceType#" />,
						Source_Type_Description =  (select UPPER(Source_Type_Desc) from BB_Upload_Source_Type_Lookup where Source_Type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.SourceType#" />), 
						Updated_Date		= GetDate(),
						Updated_By		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#" />,
						Active			= <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.Active#" />
						<cfif (appSettings.get_Setting('OCR_Upload_ON') EQ '1')>
							,Display_In_OCR 	= <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.DisplayInOCR#" />
						</cfif>
				WHERE		BB_Claim_Source_XREF_ID		= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.BBClaimSourceXREFID#" />
			</CFQUERY>
			<cfset strRetMessage = "Record was successfully updated!!" />
	<cfelse>
		<cfset strRetMessage = "ERROR: The combination of code and Description Type already exists!!" />
	</cfif>
	<cfreturn strRetMessage />
	
</cffunction>

</cfcomponent>