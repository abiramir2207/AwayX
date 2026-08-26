<cfscript>
	appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();

	// <!--- list of tables that store profile settings data...these are standard, optional ones below...2 tokens seperated by | (pipe) 
	//       -> tablename : foriegn key to Profiles table (ls, margin, group, op group only) --->
	aSettings = [ 	 "Profiles_Settings|Profiles_ID"
					,"Profiles|Profiles_ID"
					,"BB_Profiles_Settings|Profiles_ID"
					,"Profile_LS_Approval|Profiles_ID"
					,"Margin_Group_Profile_Approval_Margins|PROFILE_ID"
					,"Group_Approval_Rights|USER_PROFILE_ID"
				];

	// <!--- Operating Group --->
	if ( appSettings.getOperatingGroupOn() ) {
		arrayAppend(aSettings, "Operating_Group_Profile_Map|PROFILES_ID" );
	}

	// <!------ Post Approval Status ----->
	if ( appSettings.getPgmPostApprovalStatus() ) {
		arrayAppend(aSettings, "Profile_Post_Approval_Status|PROFILES_ID" );
	}

	// <!--- deductions --->
	if ( application.appSettingsGet.getDeduction_Module() ) {
		arrayAppend(aSettings, "Deductions_Profiles_Settings|PROFILES_ID");
	}

	// <!--- customer type --->
	if ( appSettings.getCustomertype() eq 1 ) {
		arrayAppend(aSettings, "Profile_Customer_Type_Settings|PROFILES_ID");
	}

	wddx         = {};
	columns_list = [];
</cfscript>

<cfloop array="#aSettings#" index="tName">
	<cfscript>
		tkey  =	gettoken(tname, 2, "|");
		tname =	gettoken(tname, 1, "|");
		arrayAppend(columns_list, tname);
	</cfscript>
	
	<cfquery datasource="#application.datasource#" name="qProfileSetting">
		SELECT * 
		  FROM  <cfoutput>#tName#</cfoutput>
		<cfif tname neq "Profile_Customer_Type_Settings">
		 WHERE deleted = 0
		</cfif>
		ORDER BY <cfoutput>#tkey#</cfoutput>
	</cfquery>

	<cfscript>
		Profile                       = {};
		Profile[ tname ]              = {};
		Profile[ tname ].recordcount  = qProfileSetting.recordcount;
		Profile[ tname ].ColumnList   = qProfileSetting.columnlist; 
		Profile[ tname ].Master_Table = tname; 
	</cfscript>

	<cfloop list="#qProfileSetting.columnlist#" index="query_column">
		<cfset column_values = []>
		<!---  collect setting values from all profiles  --->
		<cfoutput query="qProfileSetting">
			<cfscript>
				// pull profile setting value and remove unwanted characters
				setting_value = replace( replace( qProfileSetting[ query_column ][ qProfileSetting.currentRow ], ",", "", "all" ), "|", "", "all" );
				arrayAppend(column_values, setting_value & "|" 
											& qProfileSetting.currentRow & "|" 
											& qProfileSetting[ tkey ][ qProfileSetting.currentRow ]);
			</cfscript>
		</cfoutput>
		<!---  combine all settings values from all profiles into one big list  ---> 
		<cfset Profile[ tname ][ query_column ] = arrayToList( column_values )>
	</cfloop>

	<!---  convert settings into wddx to store in the db  --->
	<cfwddx action="cfml2wddx" input="#profile#" output="wddx.#tname#" usetimezoneinfo="yes">
</cfloop> 

<cfquery datasource="#application.datasource#" name="qInProfilesLog">
	INSERT INTO Profiles_settings_log
				( user_id,
				  <cfoutput>#arrayToList( columns_list )#</cfoutput>
				)
		VALUES 	( '#Request.AccessStructure.user_id#'
				  <cfloop array="#columns_list#" index="pkName">
					,<cfqueryparam value="#wddx[ pkname ]#" cfsqltype="cf_sql_longvarchar">
				  </cfloop>
				)  
</cfquery>  
