<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\programs\ClaimRates.cfc
	Date:      2013 June
	Author:    Chris Nguyen
--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cfcomponent displayname="Claim Rates" output="no" hint="Houses all claim rates functions.">

  <cffunction name="getClaimRatesColumns" access="public" returntype="array" output="no" hint="Returns claim rates column names and labels.">
  	<cfargument name="config_id" required="true">

  	<!---do NOT use <cfset var ..> scoping here, we need to have vars.query349873 & vars.columns349873 visible in _addColumn() calls--->
  	<cfquery name="vars.query349873" datasource="#application.datasource#">
  		SELECT *
  		  FROM CLAIM_RATES_SETTING
  		 WHERE Deleted = 0
  		       <!--- Not sure whether "default" will ever be passed. Not removing this condition, as we are not 100% about it.
			   Just a note that currently we do not look at the name "default" for the defualt record.
			   --->
			   <cfif arguments.config_id eq "default">
  		         AND Config_Name = '<cfoutput>#arguments.config_id#</cfoutput>'
  		       <cfelse>
  		 				 AND Config_ID = <cfoutput>#arguments.config_id#</cfoutput>
  		 		</cfif>
  	</cfquery>

		<!---TODO: make changes to this statement whenever Claim_Rates_Setting schema change is made--->
		<cfscript>
		  vars.columns349873 = [];

		  _addColumn( 'program_Number' );
		  _addColumn( 'program_Title' );
		  _addColumn( 'effective_Date' );
		  _addColumn( 'distributor_ID' );
		  _addColumn( 'distributor_Name' );
		  _addColumn( 'buying_Group_Id' );
		  _addColumn( 'buying_Group_Name' );
		  _addColumn( 'broker_ID' );
		  _addColumn( 'broker_Name' );
		  _addColumn( 'family_Name' );
		  _addColumn( 'start_Date' );
		  _addColumn( 'end_Date' );
		  _addColumn( 'component_Type' );
		  _addColumn( 'component_Name' );
		  _addColumn( 'Distributor_Product_Number' );
		  _addColumn( 'GTin' );
		  _addColumn( 'item_Number' );
		  _addColumn( 'item_Description' );
		  _addColumn( 'distributor_Fob_Price_Per_Case' );
		  _addColumn( 'inbound_Freight_Per_Case' );
		  _addColumn( 'outbound_Freight_Per_Case' );
		  _addColumn( 'distributor_Final_Price_Per_Case' );
		  _addColumn( 'operator_Contract_Price_Per_Case' );
		  _addColumn( 'expected_Fixed_Price_Claim_Rate_Per_Case' );
		  _addColumn( 'expected_Rebate_Rate_Per_Case' );
		  _addColumn( 'Case_Count_Desc' );
		  _addColumn( 'Program_Fixed_Price_Per_Case' );
		  _addColumn( 'Operator_ID' );
		  _addColumn( 'Operator_Name' );

	      _addColumn( "Program_Fixed_Price_Per_Pound" );
	      _addColumn( "Rebate_Per_Program_Pound" );
	      _addColumn( "Program_Volume_Per_Pound" );
	      _addColumn( "Program_Volume_Per_Case" );
	      _addColumn( "Prod_Var_A" );
	      _addColumn( "Prod_Var_B" );
	      _addColumn( "Type_Code" );
	      _addColumn( "Type_Group" );
	      _addColumn( "QBrand" );
	      _addColumn( "Brand" );
	      _addColumn( "RSP" );
	      _addColumn( "RSP_Position" );
 		  _addColumn( "Currency_Conversion_Factor" );
		   _addColumn( "Currency_Code" );
		   _addColumn( "Bid_Open_Date" );
		   _addColumn( "Effective_Date_For_Price" );
		   _addColumn( "Legacy_ID" );
		   _addColumn( "Line_Number" );
		   _addColumn( 'Program_Percent_Rate' );

		  // sort array of columns based on column orders
		  local.sortedColumns = application.util.array.arrayOfStructsSort(vars.columns349873, "seq");
		</cfscript>

    <cfreturn local.sortedColumns>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="_addColumn" access="private" returntype="void" output="no" hint="Adds a specified column to the array when it is flagged to include on claim rates report.">
  	<cfargument name="columnName" required="true">

		<!---is the column flagged to include in the report?  "vars.query349873" is defined & initialized in parent function --->
		<cfif vars.query349873[ arguments.columnName & "_Include" ][1] eq "1">
			<!---add column name, column sequence, column label to the array "vars.columns349873" (defined in parent function)--->
			<cfoutput>
			<cfset arrayAppend( vars.columns349873, {  name ="#arguments.columnName#"
																											,seq  ="#vars.query349873[ arguments.columnName & "_Sequence" ][1]#"
																											,label="#_sanitizeLabel(vars.query349873[ arguments.columnName & "_Label" ][1])#"  } )>
			</cfoutput>
		</cfif>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getClaimRates" access="public" returntype="query" output="no" hint="Returns claim rates settings.">
  	<cfargument name="config_id" required="false" default="">

  	<cfquery name="local.query" datasource="#application.datasource#">
  		SELECT *,
  		       (SELECT COUNT(1)
  		          FROM Program_Control_Panel_Options
  		         WHERE Program_Control_Panel_Options.Claim_Rates_Config_ID = CLAIM_RATES_SETTING.Config_ID
  		           AND Program_Control_Panel_Options.IsDominant = 1
  		           AND Program_Control_Panel_Options.Deleted = 0) AS UsageCount
  		  FROM CLAIM_RATES_SETTING
  		 WHERE Deleted = 0
					<!--- If it is a newly created setting, get the details from the existing "default" record. --->
  		 			<cfif arguments.config_id eq "-1">
  		 			 AND default_setting = 1
  		 			<cfelseif val(arguments.config_id) neq 0>
  		 				AND Config_ID = <cfoutput>#arguments.config_id#</cfoutput>
  		 			</cfif>
  		       ORDER BY Config_Name
  	</cfquery>
    <cfreturn local.query>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getClause" access="public" returntype="string" output="no" hint="Returns claim rates clause.">
  	<cfargument name="config_id" required="true">

  	<cfquery name="local.query" datasource="#application.datasource#">
  		SELECT CONVERT(varchar(MAX), b.Clause_Library_Body) AS Clause_Library_Body
  		  FROM CLAIM_RATES_SETTING a
  		       INNER JOIN Clause_Library b ON b.Clause_Library_ID = a.Clause_Library_ID
  		 WHERE a.Deleted = 0
  		 				AND a.Config_ID = <cfoutput>#arguments.config_id#</cfoutput>
  	</cfquery>

    <cfreturn local.query.Clause_Library_Body>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getTemplates" access="public" returntype="query" output="no" hint="Returns template related claim rates settings.">
  	<cfargument name="ProgramControl_Panel_Options_ID" required="false" default="">

  	<cfquery name="local.query" datasource="#application.datasource#">
  		SELECT DISTINCT
  		        Created_Type
  		       ,First_Parent_ID
  		       ,Program_Description
  		       ,Claim_Rates_Config_ID
  		 			<cfif val(arguments.ProgramControl_Panel_Options_ID) neq 0>
  		       	,b.Config_Name
  		 			</cfif>
  		  FROM Program_Control_Panel_Options a
  		  LEFT JOIN CLAIM_RATES_SETTING b ON a.Claim_Rates_Config_ID = b.Config_ID
  		 WHERE a.Deleted = 0
  		 			AND a.IsDominant = 1
  		 			<cfif val(arguments.ProgramControl_Panel_Options_ID) neq 0>
  		 				AND ProgramControl_Panel_Options_ID = <cfoutput>#arguments.ProgramControl_Panel_Options_ID#</cfoutput>
  		 			</cfif>
  		       ORDER BY a.created_type
  	</cfquery>
    <cfreturn local.query>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="deleteClaimRateConfig" access="public" returntype="void" output="no" hint="Delete claim rates setting.">
  	<cfargument name="config_id" required="false" default="">

  	<cfquery name="local.query" datasource="#application.datasource#">
  		 UPDATE CLAIM_RATES_SETTING
  		    SET Deleted = 1
  		        ,Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
  		  WHERE Config_ID = <cfoutput>#arguments.config_id#</cfoutput>
  	</cfquery>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="_sanitizeLabel" access="private" returntype="string" output="no" hint="Remove special characters that cause problems.">
  	<cfargument name="label" required="true">

		<cfreturn replaceNoCase( arguments.label, ",", "", "all" )>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="saveClaimRateConfig" access="public" returntype="void" output="no" hint="Save config settings based on form parameters.">
		<!--- If a default setting is being set, remove the previous default setting --->
		<cfif form.default_setting eq 1>
			<cfquery name="updSetting" datasource="#application.datasource#">
				UPDATE CLAIM_RATES_SETTING
				SET default_setting = 0
				WHERE default_setting = 1
			</cfquery>
		</cfif>

		<cfif val(form.config_ID) eq -1>
  		<cfquery name="local.query" datasource="#application.datasource#">
	  		INSERT INTO CLAIM_RATES_SETTING
	  					( Config_Name, Updated_By, Default_Setting )
	  		VALUES
	  		     (  <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.config_name#">
	  		       ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
				   ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.default_setting#"> )

	  		SELECT SCOPE_IDENTITY() AS Config_ID
  		</cfquery>
			<cfset form.config_ID = local.query.config_ID>
		</cfif>

		<cfquery name="local.update" datasource="#application.datasource#">
			 UPDATE CLAIM_RATES_SETTING
	  		   SET Updated_By  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
	  		      <cfif structKeyExists(form, "Config_Name")>    <!---Default setting would not have config_name due to its disabled status--->
	  		      	,Config_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.config_name#">
	  		      </cfif>
			       ,Program_Number_Label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Program_Number_Label)#">
					  	,Program_Number_Include = <cfif structKeyExists(form, "Program_Number_Include")>1<cfelse>0</cfif>
					  	,Program_Number_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Program_Number_Sequence#">

					  	,Program_Title_Label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Program_Title_Label)#">
					  	,Program_Title_Include = <cfif structKeyExists(form, "Program_Title_Include")>1<cfelse>0</cfif>
					  	,Program_Title_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Program_Title_Sequence#">

					  	,effective_Date_Label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.effective_Date_Label)#">
					  	,Effective_Date_Include = <cfif structKeyExists(form, "Effective_Date_Include")>1<cfelse>0</cfif>
					  	,Effective_Date_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Effective_Date_Sequence#">

					  	,Distributor_ID_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Distributor_ID_Label)#">
					  	,Distributor_ID_Include = <cfif structKeyExists(form, "Distributor_ID_Include")>1<cfelse>0</cfif>
					  	,Distributor_ID_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Distributor_ID_Sequence#">

					  	,Distributor_Name_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Distributor_Name_Label)#">
					  	,Distributor_Name_Include = <cfif structKeyExists(form, "Distributor_Name_Include")>1<cfelse>0</cfif>
					  	,Distributor_Name_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Distributor_Name_Sequence#">

					  	,Buying_Group_Id_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Buying_Group_Id_Label)#">
					  	,Buying_Group_Id_Include = <cfif structKeyExists(form, "Buying_Group_Id_Include")>1<cfelse>0</cfif>
				  	 	,Buying_Group_Id_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Buying_Group_Id_Sequence#">

				  	 	,Buying_Group_Name_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Buying_Group_Name_Label)#">
					  	,Buying_Group_Name_Include = <cfif structKeyExists(form, "Buying_Group_Name_Include")>1<cfelse>0</cfif>
					  	,Buying_Group_Name_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Buying_Group_Name_Sequence#">

					  	,Broker_ID_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Broker_ID_Label)#">
					  	,Broker_ID_Include = <cfif structKeyExists(form, "Broker_ID_Include")>1<cfelse>0</cfif>
					  	,Broker_ID_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Broker_ID_Sequence#">

					  	,Broker_Name_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Broker_Name_Label)#">
					  	,Broker_Name_Include = <cfif structKeyExists(form, "Broker_Name_Include")>1<cfelse>0</cfif>
					  	,Broker_Name_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Broker_Name_Sequence#">

					  	,Family_Name_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Family_Name_Label)#">
					  	,Family_Name_Include = <cfif structKeyExists(form, "Family_Name_Include")>1<cfelse>0</cfif>
					  	,Family_Name_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Family_Name_Sequence#">

					  	,Start_Date_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Start_Date_Label)#">
					  	,Start_Date_Include = <cfif structKeyExists(form, "Start_Date_Include")>1<cfelse>0</cfif>
					  	,Start_Date_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Start_Date_Sequence#">

					  	,End_Date_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.End_Date_Label)#">
					  	,End_Date_Include = <cfif structKeyExists(form, "End_Date_Include")>1<cfelse>0</cfif>
					  	,End_Date_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.End_Date_Sequence#">

					  	,Component_Type_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Component_Type_Label)#">
					  	,Component_Type_Include = <cfif structKeyExists(form, "Component_Type_Include")>1<cfelse>0</cfif>
					  	,Component_Type_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Component_Type_Sequence#">

					  	,Component_Name_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Component_Name_Label)#">
					  	,Component_Name_Include = <cfif structKeyExists(form, "Component_Name_Include")>1<cfelse>0</cfif>
					  	,Component_Name_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Component_Name_Sequence#">

					  	,Distributor_Product_Number_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Distributor_Product_Number_Label)#">
					  	,Distributor_Product_Number_Include = <cfif structKeyExists(form, "Distributor_Product_Number_Include")>1<cfelse>0</cfif>
					  	,Distributor_Product_Number_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Distributor_Product_Number_Sequence#">

					  	,GTin_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.GTin_Label)#">
					  	,GTin_Include = <cfif structKeyExists(form, "GTin_Include")>1<cfelse>0</cfif>
					  	,GTin_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.GTin_Sequence#">

					  	,Item_Number_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Item_Number_Label)#">
					  	,Item_Number_Include = <cfif structKeyExists(form, "Item_Number_Include")>1<cfelse>0</cfif>
					  	,Item_Number_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Item_Number_Sequence#">

					  	,Item_Description_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Item_Description_Label)#">
					  	,Item_Description_Include = <cfif structKeyExists(form, "Item_Description_Include")>1<cfelse>0</cfif>
					  	,Item_Description_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Item_Description_Sequence#">

					  	,Distributor_Fob_Price_Per_Case_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Distributor_Fob_Price_Per_Case_Label)#">
					  	,Distributor_Fob_Price_Per_Case_Include = <cfif structKeyExists(form, "Distributor_Fob_Price_Per_Case_Include")>1<cfelse>0</cfif>
					  	,Distributor_Fob_Price_Per_Case_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Distributor_Fob_Price_Per_Case_Sequence#">

					  	,Inbound_Freight_Per_Case_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Inbound_Freight_Per_Case_Label)#">
					  	,Inbound_Freight_Per_Case_Include = <cfif structKeyExists(form, "Inbound_Freight_Per_Case_Include")>1<cfelse>0</cfif>
					  	,Inbound_Freight_Per_Case_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Inbound_Freight_Per_Case_Sequence#">

					  	,Outbound_Freight_Per_Case_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Outbound_Freight_Per_Case_Label)#">
					  	,Outbound_Freight_Per_Case_Include = <cfif structKeyExists(form, "Outbound_Freight_Per_Case_Include")>1<cfelse>0</cfif>
					  	,Outbound_Freight_Per_Case_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Outbound_Freight_Per_Case_Sequence#">

					  	,Distributor_Final_Price_Per_Case_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Distributor_Final_Price_Per_Case_Label)#">
					  	,Distributor_Final_Price_Per_Case_Include = <cfif structKeyExists(form, "Distributor_Final_Price_Per_Case_Include")>1<cfelse>0</cfif>
					  	,Distributor_Final_Price_Per_Case_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Distributor_Final_Price_Per_Case_Sequence#">

					  	,Operator_Contract_Price_Per_Case_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Operator_Contract_Price_Per_Case_Label)#">
					  	,Operator_Contract_Price_Per_Case_Include = <cfif structKeyExists(form, "Operator_Contract_Price_Per_Case_Include")>1<cfelse>0</cfif>
					  	,Operator_Contract_Price_Per_Case_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Operator_Contract_Price_Per_Case_Sequence#">

					  	,Expected_Fixed_Price_Claim_Rate_Per_Case_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Expected_Fixed_Price_Claim_Rate_Per_Case_Label)#">
					  	,Expected_Fixed_Price_Claim_Rate_Per_Case_Include = <cfif structKeyExists(form, "Expected_Fixed_Price_Claim_Rate_Per_Case_Include")>1<cfelse>0</cfif>
					  	,Expected_Fixed_Price_Claim_Rate_Per_Case_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Expected_Fixed_Price_Claim_Rate_Per_Case_Sequence#">

					  	,Expected_Rebate_Rate_Per_Case_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Expected_Rebate_Rate_Per_Case_Label)#">
					  	,Expected_Rebate_Rate_Per_Case_Include = <cfif structKeyExists(form, "Expected_Rebate_Rate_Per_Case_Include")>1<cfelse>0</cfif>
					  	,Expected_Rebate_Rate_Per_Case_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Expected_Rebate_Rate_Per_Case_Sequence#">

					  	,Program_Fixed_Price_Per_Case_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Program_Fixed_Price_Per_Case_Label)#">
					  	,Program_Fixed_Price_Per_Case_Include = <cfif structKeyExists(form, "Program_Fixed_Price_Per_Case_Include")>1<cfelse>0</cfif>
					  	,Program_Fixed_Price_Per_Case_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Program_Fixed_Price_Per_Case_Sequence#">

					  	,Case_Count_Desc_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Case_Count_Desc_Label)#">
					  	,Case_Count_Desc_Include = <cfif structKeyExists(form, "Case_Count_Desc_Include")>1<cfelse>0</cfif>
					  	,Case_Count_Desc_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Case_Count_Desc_Sequence#">

					  	,Operator_Name_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Operator_Name_Label)#">
					  	,Operator_Name_Include = <cfif structKeyExists(form, "Operator_Name_Include")>1<cfelse>0</cfif>
					  	,Operator_Name_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Operator_Name_Sequence#">

					  	,Operator_ID_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Operator_ID_Label)#">
					  	,Operator_ID_Include = <cfif structKeyExists(form, "Operator_ID_Include")>1<cfelse>0</cfif>
					  	,Operator_ID_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Operator_ID_Sequence#">



					  	,Program_Fixed_Price_Per_Pound_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Program_Fixed_Price_Per_Pound_Label)#">
					  	,Program_Fixed_Price_Per_Pound_Include = <cfif structKeyExists(form, "Program_Fixed_Price_Per_Pound_Include")>1<cfelse>0</cfif>
					  	,Program_Fixed_Price_Per_Pound_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Program_Fixed_Price_Per_Pound_Sequence#">

					  	,Rebate_Per_Program_Pound_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Rebate_Per_Program_Pound_Label)#">
					  	,Rebate_Per_Program_Pound_Include = <cfif structKeyExists(form, "Rebate_Per_Program_Pound_Include")>1<cfelse>0</cfif>
					  	,Rebate_Per_Program_Pound_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Rebate_Per_Program_Pound_Sequence#">

					  	,Program_Volume_Per_Pound_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Program_Volume_Per_Pound_Label)#">
					  	,Program_Volume_Per_Pound_Include = <cfif structKeyExists(form, "Program_Volume_Per_Pound_Include")>1<cfelse>0</cfif>
					  	,Program_Volume_Per_Pound_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Program_Volume_Per_Pound_Sequence#">

					  	,Program_Volume_Per_Case_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Program_Volume_Per_Case_Label)#">
					  	,Program_Volume_Per_Case_Include = <cfif structKeyExists(form, "Program_Volume_Per_Case_Include")>1<cfelse>0</cfif>
					  	,Program_Volume_Per_Case_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Program_Volume_Per_Case_Sequence#">

					  	,Prod_Var_A_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Prod_Var_A_Label)#">
					  	,Prod_Var_A_Include = <cfif structKeyExists(form, "Prod_Var_A_Include")>1<cfelse>0</cfif>
					  	,Prod_Var_A_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Prod_Var_A_Sequence#">

					  	,Prod_Var_B_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Prod_Var_B_Label)#">
					  	,Prod_Var_B_Include = <cfif structKeyExists(form, "Prod_Var_B_Include")>1<cfelse>0</cfif>
					  	,Prod_Var_B_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Prod_Var_B_Sequence#">

					  	,Type_Code_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Type_Code_Label)#">
					  	,Type_Code_Include = <cfif structKeyExists(form, "Type_Code_Include")>1<cfelse>0</cfif>
					  	,Type_Code_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Type_Code_Sequence#">

					  	,Type_Group_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Type_Group_Label)#">
					  	,Type_Group_Include = <cfif structKeyExists(form, "Type_Group_Include")>1<cfelse>0</cfif>
					  	,Type_Group_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Type_Group_Sequence#">

					  	,QBrand_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.QBrand_Label)#">
					  	,QBrand_Include = <cfif structKeyExists(form, "QBrand_Include")>1<cfelse>0</cfif>
					  	,QBrand_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.QBrand_Sequence#">

					  	,Brand_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Brand_Label)#">
					  	,Brand_Include = <cfif structKeyExists(form, "Brand_Include")>1<cfelse>0</cfif>
					  	,Brand_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Brand_Sequence#">

					  	,RSP_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.RSP_Label)#">
					  	,RSP_Include = <cfif structKeyExists(form, "RSP_Include")>1<cfelse>0</cfif>
					  	,RSP_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.RSP_Sequence#">

					  	,RSP_Position_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.RSP_Position_Label)#">
					  	,RSP_Position_Include = <cfif structKeyExists(form, "RSP_Position_Include")>1<cfelse>0</cfif>
					  	,RSP_Position_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.RSP_Position_Sequence#">

					  	,Currency_Conversion_Factor_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Currency_Conversion_Factor_Label)#">
					  	,Currency_Conversion_Factor_Include = <cfif structKeyExists(form, "Currency_Conversion_Factor_Include")>1<cfelse>0</cfif>
					  	,Currency_Conversion_Factor_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Currency_Conversion_Factor_Sequence#">
						<cfif structKeyExists(form, "clause_library_id") AND form.clause_library_id NEQ ''>
					  		,Clause_Library_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.clause_library_id#">
						</cfif>
					  	,By_Group = <cfqueryparam cfsqltype="cf_sql_bit" value="#form.By_Group#">

						,Currency_Code_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Currency_Code_Label)#">
					  	,Currency_Code_Include = <cfif structKeyExists(form, "Currency_Code_Include")>1<cfelse>0</cfif>
					  	,Currency_Code_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Currency_Code_Sequence#">

						,Bid_Open_Date_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Bid_Open_Date_Label)#">
					  	,Bid_Open_Date_Include = <cfif structKeyExists(form, "Bid_Open_Date_Include")>1<cfelse>0</cfif>
					  	,Bid_Open_Date_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Bid_Open_Date_Sequence#">

						,Effective_Date_For_Price_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Effective_Date_For_Price_Label)#">
					  	,Effective_Date_For_Price_Include = <cfif structKeyExists(form, "Effective_Date_For_Price_Include")>1<cfelse>0</cfif>
					  	,Effective_Date_For_Price_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Effective_Date_For_Price_Sequence#">

						,Legacy_ID_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Legacy_ID_Label)#">
					  	,Legacy_ID_Include = <cfif structKeyExists(form, "Legacy_ID_Include")>1<cfelse>0</cfif>
					  	,Legacy_ID_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Legacy_ID_Sequence#">

						,Line_Number_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Line_Number_Label)#">
					  	,Line_Number_Include = <cfif structKeyExists(form, "Line_Number_Include")>1<cfelse>0</cfif>
					  	,Line_Number_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Line_Number_Sequence#">

					  	,Program_Percent_Rate_Label =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form.Program_Percent_Rate_Label)#">
					  	,Program_Percent_Rate_Include = <cfif structKeyExists(form, "Program_Percent_Rate_Include")>1<cfelse>0</cfif>
					  	,Program_Percent_Rate_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Program_Percent_Rate_Sequence#">

						,Default_Setting = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.default_setting#">

			  WHERE Config_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.config_id#">
		</cfquery>

		<!---this statement is needed to take care of a scenario when users made no template selection--->
		<cfparam name="form.templates" default="">

		<cfquery name="local.update" datasource="#application.datasource#">
		   <!---remove previously assigned templates that are no longer selected--->
				UPDATE Program_Control_Panel_Options
				   SET Claim_Rates_Config_ID = NULL
				 WHERE Claim_Rates_Config_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.config_id#">
				   AND NOT First_Parent_ID IN ( <cfqueryparam cfsqltype="cf_sql_integer" value="#form.templates#" list="true"> )
				   AND Deleted = 0

				<!---assign selected templates--->
				UPDATE Program_Control_Panel_Options
				   SET Claim_Rates_Config_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.config_id#">
				 WHERE First_Parent_ID IN ( <cfqueryparam cfsqltype="cf_sql_integer" value="#form.templates#" list="true"> )
				   AND Deleted = 0
		</cfquery>

  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="duplicateExists" access="remote" returnFormat="json" output="no">
		<cfargument name="config_id" required="true" type="numeric">
		<cfargument name="config_name" required="true" type="string">

		<cfscript>
			local.result = {};
		</cfscript>

		<cftry>
			<cfquery name="local.query" datasource="#application.datasource#">
				SELECT 1
					  FROM CLAIM_RATES_SETTING
				 WHERE Config_ID    <> <cfqueryparam cfsqltype="cf_sql_integer"      value="#arguments.config_id#">
				   AND Config_Name  =  <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.config_name#">
				   AND Deleted      =  0
			</cfquery>
			<cfcatch type="any">
				<!--- oops! error just occurred --->
				<cfset local.query = queryNew( 'foo' )>
			</cfcatch>
		</cftry>

		<cfset local.result.duplicateExists = (local.query.recordCount gt 0)>
		<cfreturn local.result>
	</cffunction>

</cfcomponent>

