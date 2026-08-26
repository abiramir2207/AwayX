<cfcomponent>

	<cffunction name="set" output="false" returntype="struct">
   
	  	<cfargument name="currencyID" type="string" required="true" default="">	
		<cfargument name="currencyNameId" type="string" required="true" default="">
		<cfargument name="programID" type="numeric" required="true" default=0>
		<cfargument name="currencyName" type="string" required="true" default="">
		<cfargument name="currencyDesc" type="string" required="true" default="">
		<cfargument name="currencyUUID" type="string" required="true" default="#CreateUUID()#">
   
   		<cfscript>
		
			tmpStruct = structNew();
			tmpStruct.currencyID = arguments.currencyID;
			tmpStruct.currencyNameId = arguments.currencyNameId;
			tmpStruct.programID = arguments.programID;
			tmpStruct.currencyName = arguments.currencyName;
			tmpStruct.currencyDesc = arguments.currencyDesc;
			tmpStruct.currencyUUID = arguments.currencyUUID;

		</cfscript>
		
		<cfreturn tmpStruct />

	</cffunction>

	<cffunction name="checkExists" output="false" returntype="boolean">
   
	  	<cfargument name="currencyToCheck" type="array" required="true" default="">	
		<cfargument name="currencyID" type="string" required="true" default="">

   
   		<cfscript>
			
			doesExist = false;
			
			for (i=1; i lte ArrayLen(arguments.currencyToCheck); i = i+1)
			{
				if (not compareNoCase(arguments.currencyToCheck[i].currencyUUID, arguments.currencyID))
					doesExist = true;
			}
			
		</cfscript>
		
		<cfreturn doesExist />

	</cffunction>

	<cffunction name="get" output="false" returntype="query">
   		<cfargument name="id" type="numeric" required="false" default="0" />
   
		<cfquery name="qGetCurrencies" datasource="#application.datasource#">
			SELECT	Currency_ID,
					Currency_Name
			FROM 	Currency
			WHERE 	Deleted = 0
			<cfif arguments.id>
			AND		Currency_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER" />
			</cfif>
			ORDER BY 	Payment_Type_Name
		</cfquery>

		<cfreturn qGetCurrencies />
		
	</cffunction>

	<cffunction name="getDesc" output="false" returntype="string">
   		<cfargument name="id" type="numeric" required="false" default="0" />
   
		<cfset qGetCurrencies = get(arguments.id) />

		<cfreturn qGetCurrencies.Currency_Name />
		
   	</cffunction>

	<cffunction name="getActive" output="false" returntype="query">
   
		<cfset useLakebaseForqGetActiveCurrencies = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("currency")>
<cfif useLakebaseForqGetActiveCurrencies>
	<cftry>
		<cfset qGetActiveCurrencies = application.oLakebase.toQuery(
			application.oLakebase.selectRows("currency", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "currency_name.asc",
				"select" = "currency_id,currency_name,currency_code"
			}), "currency_id,currency_name,currency_code"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActiveCurrencies = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActiveCurrencies>
<cfquery name="qGetActiveCurrencies" datasource="#application.datasource#">
			SELECT	Currency_ID,
					Currency_Name,
					Currency_Code
			FROM 	Currency
			WHERE 	Deleted = 0
			AND		Active = 1
			ORDER BY 	Currency_Name
		</cfquery>
</cfif>

		<cfreturn qGetActiveCurrencies />
		
	</cffunction>

	<cffunction name="GetCurrency" output="false" returntype="query">
   
   		<cfargument name="currencyId" required="false" default=0 />
		
		<cfset useLakebaseForqGetCurrency = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("currency")>
<cfif useLakebaseForqGetCurrency>
	<cftry>
		<cfset qGetCurrency = application.oLakebase.toQuery(
			application.oLakebase.selectRows("currency", {
				"currency_id" = "eq.#arguments.currencyId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCurrency = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCurrency>
<cfquery name="qGetCurrency" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Currency
			WHERE 	Currency_ID = #arguments.currencyId#	
		</cfquery>
</cfif>

		<cfreturn qGetCurrency />
		
	</cffunction>

	<cffunction name="GetCurrencyFromList" output="false" returntype="query">
   
   		<cfargument name="currencyIdList" type="string" required="true" />
		
		<cfquery name="qGetCurrency" datasource="#application.datasource#">
			SELECT 	Currency_ID,
					Currency_Name
			FROM 	Currency
			WHERE 	Currency_ID IN (#arguments.currencyIdList#)
		</cfquery>

		<cfreturn qGetCurrency />
		
	</cffunction>

	<cffunction name="getInActive" output="false" returntype="query">

		<cfquery name="qGetActiveCurrencies" datasource="#application.datasource#">
			SELECT 	Currency_ID,
					Currency_Name,
					Currency_Code
			FROM 	Currency
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY Currency_Name
		</cfquery>

		<cfreturn qGetActiveCurrencies />
		
	</cffunction>

	<cffunction name="add" output="false" hint="Function used to add a new currencyonent.">
	
		<cfargument name="currencyName" required="false" default="" />	
		<cfargument name="currencyCode" required="false" default="" />
		<cfargument name="User_ID" required="false" default="" />	
		
		<cfquery name="qGetActiveCurrency" datasource="#application.datasource#">
			SELECT	Currency_ID, Currency_Name
			FROM	Currency
			WHERE	Currency_Name = '#trim(arguments.currencyName)#'
			AND		deleted = 0
		</cfquery>
		
		<cfif not qGetActiveCurrency.RecordCount>
			
			<cfquery name="qGetActiveCurrency" datasource="#application.datasource#">
			SET NOCOUNT ON 
				INSERT INTO	Currency
					(Currency_Name, Currency_Code, Created_Date, Last_Edited_By, Last_Edited_Date, Active)
				VALUES
					('#arguments.currencyName#', '#arguments.currencyCode#', getdate(),
					<cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
					getdate(), 1
					)
				SELECT Currency_ID = @@IDENTITY 
				SET NOCOUNT OFF
			</cfquery>

			<cfset SettingNameMgt = "CurrencyID_"&"#qGetActiveCurrency.Currency_ID#"/> 
			<cfquery name="InsertSettings_List" datasource="#application.datasource#">
				INSERT INTO Settings_List (Setting_Type, TemplatePageSequence, Setting_Name, Setting_Label,Category)
				VALUES ('TemplateSecondpage', 2, '#SettingNameMgt#', '#arguments.currencyName# - #arguments.currencyCode#','Template')
			</cfquery>			
		</cfif>
	
		<cfreturn qGetActiveCurrency.Currency_ID />
		
	</cffunction>

	<cffunction name="deactivate" output="false" hint="Function used to deactivate currencyonents.">
	
		<cfargument name="currencyIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Currency
			SET		Active = 0
			WHERE	Currency_ID IN(#arguments.currencyIds#)
		</cfquery>
		
	</cffunction>

	<cffunction name="activate" output="false" hint="Function used to activate currencyonents.">
	
		<cfargument name="currencyIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Currency
			SET		Active = 1
			WHERE	Currency_ID IN(#arguments.currencyIds#)
		</cfquery>
		
	</cffunction>

	<cffunction name="delete" output="false" hint="Function used to delete currencyonents.">
	
		<cfargument name="currencyIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Currency
			SET		Deleted = 1
			WHERE	Currency_ID IN(#arguments.currencyIds#)
		</cfquery>
		
	</cffunction>

	<cffunction name="update" output="false" hint="Function used to update currencyonents." returntype="boolean">
	
		<cfargument name="currencyId" required="false" default="" />
		<cfargument name="currencyName" required="false" default="" />	
		<cfargument name="currencyCode" required="false" default="" />
		<cfargument name="Restrict_From_Billback" required="false" default="" />	
		<cfargument name="User_ID" required="false" default="" />
   		
		<cfset bCurrencyNameExists = false />		
		
		<cfquery datasource="#application.datasource#">
			UPDATE 	Currency
			SET		Currency_Name = <cfqueryparam value="#arguments.currencyName#" cfsqltype="CF_SQL_VARCHAR">,
					Currency_Code =  <cfqueryparam value="#arguments.currencyCode#" cfsqltype="CF_SQL_VARCHAR">,
					Last_Edited_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
					Last_Edited_Date = getdate()
			WHERE	Currency_ID = #arguments.currencyId#
		</cfquery>
		
		<cfreturn bCurrencyNameExists />
		
	</cffunction>

	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a currency can be deleted or not.">
   
   		<cfargument name="nameID" type="numeric" required="false" default="" />
			
		<cfquery name="qCheckCurrencyName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Currency
				INNER JOIN Currency_Mapping
				ON Currency_Mapping.Currency_ID = Currency.Currency_ID
				AND 	Currency_Mapping.Deleted = 0
				INNER JOIN Program_Control_Panel_Options
				ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Currency_Mapping.Template_ID
			WHERE 	Currency.Currency_ID = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
			AND 	Currency.deleted = 0 
		</cfquery>
		
		<!---if we get a count back from qCheckcurrencyName then set canDelete to false--->
		<cfif qCheckCurrencyName.count>
			<cfset bCanDelete = false />
		<cfelse>
			<cfset bCanDelete = true />
		</cfif>
		
		<cfreturn bCanDelete />
		
	</cffunction>

</cfcomponent>
