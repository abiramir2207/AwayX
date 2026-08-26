<!---
FILE: 		BA Application - Model: LetterManager Component
FILEname:   LetterManager.cfc
CREATED:  	05/09/2008 - Brad Lee MMCP/ACI
EDITED:   	02/12/2009 - Brad Lee MMCP/ACI
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]

FUNCTIONALITY:
- ALL Letters are generated and managed by this object. (ONLY THE Controller extends main) --->

<!--- COLDFUSION COMPONENT: Model - Letter [Manager] --->
<cfcomponent displayname="LetterManager" hint="I am the letter blueprint in charge of all addition, manipulation, retrieval, and removal of data to and from BA Letters within the business logic layer.">

	<!--- Set the initialization flag to "False" --->
	<cfparam name="this.bObjectInitialized" type="boolean" default="0">

	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

	<!--- ENTITY Model METHOD: init() [begin] --->
	<cffunction name="init" output="false" returntype="mvc.Models.LetterManager" hint="I INITIALIZE the LETTER MANAGER object representing ALL Letter Manipulation in application scope." displayname="Initialize LetterManager">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="stLetterManagerDNA" type="struct" required="false" hint="Letter Manager Info" default="#structNew()#">

		<!--- init... --->

		<!--- Set up the object skeleton --->
		<cfscript>
			structInsert(this, 	"objName", 				uCase(application.applicationName) & " Application LetterManager");
			structInsert(this, 	"objDateTimeCreated", 	createODBCDateTime(now()));
			structInsert(this, 	"objDirectory",   		application.stMvcAppInfo.webrootMapping & "components/mvc/Models");
			structInsert(this, 	"objParentObject",   	"application.oController");
			structInsert(this, 	"objParentUserID",   	session.stMvcUserInfo.User_ID);
			structInsert(this, 	"stObjectInfo",   		structNew(),true);

			this.stObjectInfo.name 						= "The " & Ucase(application.applicationName) & " LetterManager";
			this.stObjectInfo.description 				= "I govern all LETTER requests for the " & Ucase(application.applicationName) & "  Application.";
			this.stObjectInfo.lockTimeoutSeconds		= application.stMvcAppInfo.lockTimeoutSeconds;

			//override our initial settings
			structAppend(this,arguments.stLetterManagerDNA,true);

			structInsert(this,	"bObjectInitialized", 	1,true);
		</cfscript>

		<!--- Return the final container to the caller --->
		<cfreturn this>

	</cffunction>
	<!--- ENTITY Model METHOD: init() [end] --->

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::
	:::::::::::: LetterManager Methods in alpha  :::::::::::
	::::::::::::::::::::::::::::::::::::::::::: [begin] --->

	<!--- 23 methods as of 02/12/09

	MVC Legend:
	1.) Please use camelCase() for methods,
	2.) Please always denote returnType,
	3.) Please try to always use cfqueryparam,
	4.) Please keep methods in alphabetical order within CFC named in verbNoun() syntax,
	5.) Please preface vars scoped local to methods with a var_ prefix (all should be),
	6.) Please employ dataType hints in naming such as:
		aSomething for Array,
		bSomething for Boolean,
		dSomething for Date,
		qSomething for Query,
		stSomething for Structure,
		xSomething for XML
	7.) The MVC Model only has a try/catch in onApplicationStart() and onSessionStart().
		Please do NOT use try/catch in CFC methods.
	Thanks. --->

	<!--- METHOD: deleteAllProgramPDFLettersInDBandFile [begin] --->
	<!--- This function is currently being used from "delete_letters.cfm" only. The function called "deleteLettersbyName" is being used in most cases now. --->
	<cffunction name="deleteAllProgramPDFLettersInDBandFile" access="public" output="no" hint="I delete all PDF files and/or the row in the program_letters table of the DB for a specified program." returntype="void" displayname="Models > Letter > deletePDFLetterInDBandFile()">

		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="distributor_id" required="false" type="string" default="" />
		<cfargument name="check_distributor" required="false" type="boolean" default="0" />
		<cfargument name="check_operator" required="false" type="boolean" default="0" />

		<!--- We MUST var all variables local to method! --->
		<cfset var var_qProgramLetters 	= ''>

		<!--- MVC: Please try to use cfqueryparam where we can --->
		<cfquery name="var_qProgramLetters" datasource="#application.datasource#">
			SELECT 	Program_Letters_ID
			FROM 	program_letters
			WHERE 	Program_ID = <cfqueryparam value="#trim(arguments.program_id)#" cfsqltype="cf_sql_integer">
			<cfif arguments.distributor_id neq "">
			AND
			(
			<!--- Dev Note: Milan (20639).When the user wants to to generate one distributor per letter,
			 and if we already had one distributor per letter before,  Just delete and recreate the letters
			 for the requested distributor(s). We use Distributor_ID to know the distributor..
			 Leave the other distributor letters untouched.
			--->
			Distributor_ID =  <cfqueryparam value="#trim(arguments.distributor_id)#" cfsqltype="cf_sql_varchar">

			<!--- Dev Note: Milan (20639).When the user wants to to generate one distributor per letter,
			 and if we already had a letter with multiple distributors before, delete it before generating new letter(s).
			 In this case (letter with multiple distributors), Distributor_ID is blank.
			--->
			OR
			CAST(Distributor_ID As varchar(50)) IS NULL
			OR
			CAST(Distributor_ID As varchar(50)) = ''
			)
			</cfif>

			<cfif arguments.distributor_id neq "" OR check_distributor eq 1>
			<!--- Dev Note: Milan (20639).When the user wants to to generate multiple distributors per letter (check_distributor = 1),
			Just delete all existing distributor letter(s), before creating new letter(s). We also use this condition for
			(arguments.distributor_id neq "") to filter records.
			--->
			AND Letter_Type = 2
			</cfif>

			<cfif check_operator eq 1>
			<!--- Dev Note: Milan (20639). It does not matter whether we want to generate multiple operators or one operator
			per letter.Just delete all existing operator letter(s), before creating new letter(s).
			--->
			AND Letter_Type = 1
			</cfif>
		</cfquery>

		<cfloop query="var_qProgramLetters">
			<cfscript>
				deletePDFLetterInDBandFile(var_qProgramLetters.Program_Letters_ID);
			</cfscript>
		</cfloop>

	</cffunction>
	<!--- METHOD: deleteAllProgramPDFLettersInDBandFile [end] --->

	<!--- -
		If the "Excel file for product group members" template setting is ON for distributor and at least one distributor letter has been selected
		OR
		"Excel file for product group members" template setting is ON for operator and at least one operator letter has been selected
	--->
	<cffunction name="getProgramLetterSettings" output="false" returntype="boolean">
		<cfargument name="letter_id_list" required="true" type="string" />
		<cfset local.bGenerateLetter = 0>
		<cfquery name="var_qProgramLetters" datasource="#application.datasource#">
			SELECT 	Program_Letters_ID
			FROM 	program_letters
			INNER JOIN Contract_Main
			ON program_letters.Program_ID = Contract_Main.Contract_Main_ID
			INNER JOIN Program_Control_Panel_Options
			ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			WHERE program_letters.Program_Letters_ID IN (<cfqueryparam value="#arguments.letter_id_list#" cfsqltype="cf_sql_varchar" list="true">)
			AND
			(
			(program_letters.Letter_Type = 1 AND Program_Control_Panel_Options.Operator_Generate_Excel_File_Product_Group_Members = 1)
			OR
			(program_letters.Letter_Type = 2 AND Program_Control_Panel_Options.Distributor_Generate_Excel_File_Product_Group_Members = 1)
			)
		</cfquery>
		<cfif var_qProgramLetters.recordcount>
			<cfset local.bGenerateLetter = 1>
		</cfif>
		<cfreturn local.bGenerateLetter>
	</cffunction>

	<!--- MODEL Legacy METHOD: deleteLetters() FUNCTIONALITY: I 'delete' letters by turning the 'deleted' switch ON in the DB. [begin] --->
	<cffunction name="deleteLetters" access="public" output="no" hint="I delete letters by turning the deleted switch ON in the DB." returntype="boolean" displayname="Models > Letter > deleteLetters()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" 	required="true" type="numeric" />
		<cfargument name="letter_type" 	required="true" type="numeric" />

		<!--- We MUST var all variables local to method! --->
		<cfset var var_bDeleteLettersStatus = 0>
		<cfset var var_qDeleteLetters = queryNew('cols')>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfquery name="var_qDeleteLetters" datasource="#application.datasource#">
			update program_letters
			set deleted = 1
			where program_id =  '#arguments.program_id#'
			and letter_type =  '#arguments.letter_type#'
		</cfquery>

		<cfset var_bDeleteLettersStatus = 1>

		<!--- Return the final container to the caller --->
		<cfreturn var_bDeleteLettersStatus>

	</cffunction>
	<!--- MODEL Legacy METHOD: deleteLetters() FUNCTIONALITY: I 'delete' letters by turning the 'deleted' switch ON in the DB. [end] --->

	<!--- MODEL New METHOD: deletePDFLetterInDBandFile() FUNCTIONALITY: I delete the PDF file and/or the row in the program_letters table
	of the DB for a specified letter. [begin] --->
	<cffunction name="deletePDFLetterInDBandFile" access="public" output="no" hint="I delete the PDF file and/or the row in the program_letters table of the DB for a specified letter." returntype="void" displayname="Models > Letter > deletePDFLetterInDBandFile()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_letter_id" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_letter_path 		= ''>
		<cfset var var_qDeleteLetter 	= ''>
		<cfset var var_EmailLogExists 	= 0>

		<cfset var_letter_path = replace(getLetterPath(program_letter_id),'.htm','.pdf','all')>

		<cfif appSettings.External_Contacts_Option NEQ 0 AND getLetterEmailLogExist(arguments.program_letter_id) eq 1>
				<cfset var_EmailLogExists =	 1>
		</cfif>

		<cfif var_EmailLogExists eq 0>
			<cfif len(trim(var_letter_path)) AND fileExists(var_letter_path)>
				<cffile action="delete" file="#var_letter_path#">
			</cfif>

			<!--- MVC: Please try to use cfqueryparam where we can --->
			<cfquery name="var_qDeleteLetter" datasource="#application.datasource#">
				DELETE 	FROM program_letters
				WHERE 	Program_Letters_ID = <cfqueryparam value="#arguments.program_letter_id#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<!--- If email log exists for the letter, then do not physically delete the letter. Users should be able to
			open letter from the email log.
			--->
			<cfquery name="var_qDeleteLetter" datasource="#application.datasource#">
				UPDATE program_letters
				SET Deleted = 1
				WHERE	Program_Letters_ID = <cfqueryparam value="#arguments.program_letter_id#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cfif>

		<!--- Return the final container to the caller --->
		<!--- na --->

	</cffunction>
	<!--- MODEL New METHOD: deletePDFLetterInDBandFile() FUNCTIONALITY: I delete the PDF file and/or the row in the program_letters table
	of the DB for a specified letter. [end] --->

	<!--------------------------------------------------------------------------------------------------------------------->

	<cffunction name="deleteLettersbyName" output="true" returntype="void" hint="Remove letters by name.">
	  <cfargument name="letter_name" type="string" required="true">
	  <cfargument name="distributor_id" type="string" required="false" default="">

	  <cfset var rsLetters = 0>
	  <cfquery name="rsLetters" datasource="#application.datasource#">
		  SELECT 	Program_Letters_ID
			FROM 	program_letters
		   WHERE 	Program_ID = <cfqueryparam value="#trim(arguments.program_id)#" cfsqltype="cf_sql_integer">
				  AND Letter_Name like <cfqueryparam value="#trim(arguments.letter_name)#" cfsqltype="cf_sql_varchar">

		  <cfif arguments.distributor_id neq "">
				 AND distributor_id = '#arguments.distributor_id#'
		  </cfif>
	  </cfquery>
	  <cfloop query="rsLetters">
		<cfset deletePDFLetterInDBandFile(rsLetters.Program_Letters_ID)>
	  </cfloop>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------->

	<!--- MODEL Legacy METHOD: getAllLetterInfo() FUNCTIONALITY: I retrieve all info for a specified letter. [begin] --->
	<cffunction name="getAllLetterInfo" access="public" output="no" hint="I retrieve all info for a specified letter." returntype="query" displayname="Models > Letter > getAllLetterInfo()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_letter_id" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qAllLetterInfo = queryNew('cols')>

		<!--- MVC: Please try to use cfqueryparam where we can --->
		<cfquery name="var_qAllLetterInfo" datasource="#application.datasource#">
		  SELECT	*
		  FROM		Program_Letters
		  WHERE 	Program_Letters.Program_Letters_ID = <cfqueryparam value="#arguments.program_letter_id#" cfsqltype="cf_sql_integer">
		</cfquery>

		<!--- Return the final container to the caller --->
		<cfreturn var_qAllLetterInfo>

	</cffunction>
	<!--- MODEL Legacy METHOD: getAllLetterInfo() FUNCTIONALITY: I retrieve selected info for a specified letter. [end] --->

	<!--- MODEL Legacy METHOD: getLetterInfo() FUNCTIONALITY: I retrieve selected info for a specified letter. [begin] --->
	<cffunction name="getLetterInfo" access="public" output="no" hint="I retrieve selected info for a specified letter." returntype="query" displayname="Models > Letter > getLetterInfo()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_letter_id" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qLetterInfo = queryNew('cols')>

		<!--- MVC: Please try to use cfqueryparam where we can --->
		<cfquery name="var_qLetterInfo" datasource="#application.datasource#">
		  SELECT	Letter_Type,Operator_Name,Distributor_Name,created_date,letter_name,_users.name_first + ' ' + _users.name_last as user_name
		  FROM		Program_Letters
		INNER JOIN _users ON _users.user_id = program_letters.created_by
		  WHERE 	Program_Letters.Program_Letters_ID = <cfqueryparam value="#arguments.program_letter_id#" cfsqltype="cf_sql_integer">
		</cfquery>

		<!--- Return the final container to the caller --->
		<cfreturn var_qLetterInfo>

	</cffunction>
	<!--- MODEL Legacy METHOD: getLetterInfo() FUNCTIONALITY: I retrieve seelcted info for a specified letter. [end] --->


	<!--- METHOD: New getBasePrice (new from Milan) FUNCTIONALITY: I retrieve the base price info for a letter's program. [begin] --->
	<cffunction name="getBasePrice" access="public" output="no" hint="I retrieve the base price info for a letter's program." returntype="query" displayname="Models > Letter > getBasePrice()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" required="true" type="string" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetBasePrice = queryNew('cols')>

		<!--- MVC: Please try to use cfqueryparam where we can --->
		<cfquery name="var_qGetBasePrice" datasource="#application.datasource#">
			select base_sales_cs,base_sales_lb,product_id
			from contract_product_margin
			where contract_main_id = <cfqueryparam value="#arguments.program_id#" cfsqltype="cf_sql_varchar">
			and deleted = 0
		</cfquery>

		<cfreturn var_qGetBasePrice />

	</cffunction>
	<!--- METHOD: New getBasePrice (new from Milan) FUNCTIONALITY: I retrieve the base price info for a letter's program. [end] --->

	<!--- METHOD: New getBidRequestProducts (new from Milan) FUNCTIONALITY: I retrieve the letter's bid request products. [begin] --->
	<cffunction name="getBidRequestProducts" output="false">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" required="true" type="string" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetBidRequestProducts = queryNew('cols')>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfquery name="var_qGetBidRequestProducts" datasource="#application.datasource#">
			SELECT    distinct BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description,
						ISNULL(dbo.Program_Bid_Request_Product.Price,0.0000) as Bidrequest_Price_Value, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_id,
						 Units_of_Measure.Abbreviation,dbo.Program_Bid_Request_Product.UOM as Unit_Of_Measure_ID,
						Contract_Products.Contract_Main_ID,
						Program_Fixed_Component_Name.Program_Fixed_Component_Name,
						Program_Bidrequest_Component.Program_Bidrequest_Component_Id
						,Contract_Main.Contract_Start_date,Contract_Main.Contract_end_date
						,Contract_Main.Contract_Main_ID
						,IsExclusionRevision,Program_Bidrequest_Component_Paid_to
			FROM         Contract_Products
						INNER JOIN	BSA_Foodservice_Items_Master
						ON
						Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						INNER JOIN	Program_Bid_Request_Product
						ON
						Contract_Products.Contract_Products_ID = Program_Bid_Request_Product.Contract_Products_ID
						INNER JOIN	Units_of_Measure
						ON Program_Bid_Request_Product.UOM = Units_of_Measure.Unit_Of_Measure_ID
						LEFT JOIN Program_Bidrequest_Component
						ON Program_Bidrequest_Component.Program_Bidrequest_Component_Id = Program_Bid_Request_Product.Program_Bidrequest_Component_Id
						AND Program_Bidrequest_Component.DELETED = 0

						LEFT JOIN Program_Fixed_Component_Name
						On Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id = Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id
						INNER JOIN 	Contract_Main
						ON Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
			WHERE       Contract_Products.Deleted = 0 AND Program_Bid_Request_Product.Deleted = 0
						--AND Contract_Main.deleted =0
						AND Contract_Products.Product_Type_ID = 10
					  AND Contract_Products.Contract_Main_ID IN (#PreserveSingleQuotes(arguments.PROGRAM_ID)#)
						and ISNULL(cast(Program_Bid_Request_Product.Price as float),0) ! = 0
			ORDER BY Program_Bidrequest_Component.Program_Bidrequest_Component_Id,contract_main.contract_main_id,Program_Bidrequest_Component_Paid_to,BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description
		</cfquery>

		<cfreturn var_qGetBidRequestProducts />

	</cffunction>
	<!--- METHOD: New getBidRequestProducts (new from Milan) FUNCTIONALITY: I retrieve the letter's bid request products. [end] --->

	<!--- MODEL Legacy METHOD: getDistributorDetails() FUNCTIONALITY: I retrieve distributor details. [begin] --->
	<cffunction name="getDistributorDetails" access="public" output="false" hint="I retrieve distributor details." returntype="query" displayname="Models > Letter > getDistributorEmail()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetDistributorDetails = queryNew('cols')>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfquery name="var_qGetDistributorDetails" datasource="#application.datasource#">
			select BSA_Foodservice_Customers.Name,BSA_Foodservice_Customers.shr_ship_to,
			BSA_Foodservice_Customers.BSA_Foodservice_Customers_id
			from
			Contract_Distributors
			inner join BSA_Foodservice_Customers
			ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_id =
			Contract_Distributors.BSA_Foodservice_Customers_id
			where contract_main_id = '#arguments.program_id#'
			and Contract_Distributors.deleted = 0
			order by BSA_Foodservice_Customers.Name
		</cfquery>

		<cfreturn var_qGetDistributorDetails />

	</cffunction>
	<!--- MODEL Legacy METHOD: getDistributorDetails() FUNCTIONALITY: I retrieve distributor details. [end] --->

	<!--- MODEL Legacy METHOD: getDistributorEmail() FUNCTIONALITY: I retrieve the distributor(s) email(s). [begin] --->
	<cffunction name="getDistributorEmail" access="public" output="false" hint="I retrieve the distributor(s) email(s)." returntype="query" displayname="Models > Letter > getDistributorEmail()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetDistributorEmail = queryNew('cols')>

		<!--- MVC: Please try to use cfqueryparam where we can --->
		<cfquery name="var_qGetDistributorEmail" datasource="#application.datasource#">
			select distinct _users.user_email,contract_distributors.bsa_foodservice_customers_id
			from contract_distributors
			inner join bsa_foodservice_customers on bsa_foodservice_customers.bsa_foodservice_customers_id =
			contract_distributors.bsa_foodservice_customers_id
			inner join bsa_foodservice_brokers on bsa_foodservice_brokers.bsa_foodservice_brokers_id =
			bsa_foodservice_customers.bsa_foodservice_brokers_id
			inner join user_positions on user_positions.service_market_id =
			bsa_foodservice_brokers.service_market_id
			and user_positions.deleted = 0
			inner join user_position_holders on user_position_holders.user_positions_id =
			user_positions.user_positions_id
			and user_positions.service_region_id IS NOT NULL and user_positions.service_zone_id IS NOT NULL
			and user_position_holders.deleted = 0
			inner join _users on _users.user_id = user_position_holders.user_id
			and _users.deleted = 0
			where contract_distributors.deleted =0
			and contract_distributors.contract_main_id = <cfqueryparam value="#arguments.program_id#" cfsqltype="CF_SQL_INTEGER">
			and user_position_holders.user_Position_type = 'P'
		</cfquery>

		<!--- Return the final container to the caller --->
		<cfreturn var_qGetDistributorEmail />

	</cffunction>
	<!--- MODEL Legacy METHOD: getDistributorEmail() FUNCTIONALITY: I retrieve all info for a specified letter. [end] --->

	<!--- METHOD: New getFixedPriceProducts (new from Milan) FUNCTIONALITY: I retrieve the letter's fixed price products. [begin] --->
	<cffunction name="getFixedPriceProducts" output="false">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" required="true" type="string" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetFixedPriceProducts = queryNew('cols')>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfquery name="var_qGetFixedPriceProducts" datasource="#application.datasource#">
			SELECT 	DISTINCT
				   	BSA_Foodservice_Items_Master.Item,
				   	BSA_Foodservice_Items_Master.Description,
					<!--- 63887 START ---->
					<!--- Unit_Of_Measure_ID = 6 is for "per hundred weight (CWT)" and that is stored in the db converted to LB.
					Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID is set to 2 for both - LB and CWT. The actual UOM is stored in the "user_picked_UOM" column.
					--->
				   CASE
					   	WHEN Units_of_Measure.Unit_Of_Measure_ID = 5
					   		THEN Program_Fixed_Price_Product_Data.User_Picked_Fixed_Price
					   	WHEN Units_of_Measure.Unit_Of_Measure_ID = 6
					   		THEN CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value AS FLOAT) * 100
					   	WHEN Units_of_Measure.Unit_Of_Measure_ID = 7
					   		THEN Program_Fixed_Price_Product_Data.User_Picked_Fixed_Price
					   ELSE Program_Fixed_Price_Product_Data.Fixed_Price_Value
				   END AS Fixed_Price_Value,
				   	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_id,
				   	Units_of_Measure.Abbreviation,
				   	Units_of_Measure.Unit_Of_Measure_ID,
				   	Contract_Products.Contract_Main_ID,
				   	Program_Fixed_Component_Name.Program_Fixed_Component_Name,
				   	Program_Fixed_Component.Program_Fixed_Component_ID,
				   	Contract_Main.Contract_Start_date,
				   	Contract_Main.Contract_end_date,
				   	Contract_Main.Contract_Main_ID,
				   	IsExclusionRevision,
				   	Fixed_Component_Paid_to,
				   	CASE
						WHEN Fixed_Component_Paid_to = 1
						THEN Program_Fixed_Component_Name+'_Distributor'
						ELSE Program_Fixed_Component_Name+'_Operator'
				   	END AS CompName
			FROM   Contract_Products
				   INNER JOIN BSA_Foodservice_Items_Master
					   ON Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				   INNER JOIN Program_Fixed_Price_Product_Data
					   ON Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
				   INNER JOIN Units_of_Measure
					   ON Units_of_Measure.Unit_Of_Measure_ID = CASE
																	WHEN Program_Fixed_Price_Product_Data.User_Picked_UOM IN(5, 6, 7)
																	THEN Program_Fixed_Price_Product_Data.User_Picked_UOM
																	ELSE Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
																END <!---63887 --->
				   LEFT JOIN Program_Fixed_Component
					   ON Program_Fixed_Component.Program_Fixed_Component_Id = Program_Fixed_Price_Product_Data.Program_Fixed_Component_Id
						  AND Program_Fixed_Component.DELETED = 0
				   LEFT JOIN Program_Fixed_Component_Name
					   ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id = Program_Fixed_Component.Program_Fixed_Component_Name_Id
				   INNER JOIN Contract_Main
					   ON Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
			WHERE  Contract_Products.Deleted = 0
				   AND Program_Fixed_Price_Product_Data.Deleted = 0
					--AND Contract_Main.deleted =0
				   AND Contract_Products.Product_Type_ID = 1
				   AND Contract_Products.Contract_Main_ID IN (#PreserveSingleQuotes(arguments.PROGRAM_ID)#)
				   AND ISNULL(CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value AS FLOAT), 0) != 0
			ORDER BY Program_Fixed_Component.Program_Fixed_Component_Id,
					 contract_main.contract_main_id,
					 Fixed_Component_Paid_to,
					 BSA_Foodservice_Items_Master.Item,
					 BSA_Foodservice_Items_Master.Description
		</cfquery>

		<cfreturn var_qGetFixedPriceProducts />

	</cffunction>
	<!--- METHOD: New getFixedPriceProducts (new from Milan) FUNCTIONALITY: I retrieve the letter's fixed price products. [end] --->

	<!--- MODEL New METHOD: getLastLetterID() FUNCTIONALITY: I retrieve the most recent (highest) letter ID from the program_letters
	table in the DB. [begin] --->
	<cffunction name="getLastLetterID" access="public" output="no" hint="I retrieve the most recent (highest) letter ID from the program_letters table in the DB." returntype="numeric" displayname="Models > Letter > getLastLetterID()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<!--- na --->

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetLastLetterID = queryNew('cols')>
		<cfset var var_lastLetterID = 0>

		<cfquery name="var_qGetLastLetterID" datasource="#application.datasource#">
			SELECT  	MAX(Program_Letters_ID) AS lastLetterID
			FROM 		Program_Letters
			WHERE		deleted = 0
		</cfquery>

		<cfif var_qGetLastLetterID.recordCount EQ 1 AND var_qGetLastLetterID.lastLetterID[1]>

			<cfset var_lastLetterID = var_qGetLastLetterID.lastLetterID[1]>

		</cfif>

		<!--- Return the final container to the caller --->
		<cfreturn var_lastLetterID>

	</cffunction>
	<!--- MODEL New METHOD: getLastLetterID() FUNCTIONALITY: I retrieve the most recent (highest) letter ID from the program_letters
	table in the DB. [end] --->

	<!--- MODEL New METHOD: getLetterManagerObject() FUNCTIONALITY: I create the LetterManager Model object as needed and return it. [begin] --->
	<cffunction name="getLetterManagerObject" access="public" output="no" hint="I create the LetterManager Model object as needed and return it." returntype="mvc.Models.LetterManager" displayname="Controllers > Letter > getLetterManagerObject()">

		<!--- let's set our initial value --->
		<cfset var var_oLetterManager = ''>

		<cfset var_oLetterManager = this>

		<!--- Return the final container to the caller --->
		<cfreturn var_oLetterManager>

	</cffunction>
	<!--- MODEL New METHOD: getLetterManagerObject() FUNCTIONALITY: I create the LetterManager Model object as needed and return it. [end] --->

	<!--- MODEL New METHOD: getLetterPath() FUNCTIONALITY: I retrieve the complete path for a specified letter. [begin] --->
	<cffunction name="getLetterPath" access="public" output="no" hint="I retrieve the complete path for a specified letter." returntype="string" displayname="Models > Letter > getLetterPath()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_letter_id" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qLetterPath = queryNew('cols')>
		<cfset var var_letterPath = ''>

		<!--- MVC: Please try to use cfqueryparam where we can --->
		<cfquery name="var_qLetterPath" datasource="#application.datasource#">
		  SELECT	letter_path
		  FROM		Program_Letters
		  WHERE 	Program_Letters.Program_Letters_ID = <cfqueryparam value="#arguments.program_letter_id#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif var_qLetterPath.recordCount EQ 1 AND len(trim(var_qLetterPath.letter_path[1]))>

			<cfset var_letterPath = trim(var_qLetterPath.letter_path[1])>

		</cfif>

		<!--- Return the final container to the caller --->
		<cfreturn var_letterPath>

	</cffunction>
	<!--- MODEL New METHOD: getLetterPath() FUNCTIONALITY: I retrieve the complete path for a specified letter. [end] --->

	<!--- MODEL Legacy METHOD: getLetters() FUNCTIONALITY: I retrieve a letters list from the DB. [begin] --->
	<cffunction name="getLetters" access="public" output="no" hint="I retrieve a letters list from the DB." returntype="query" displayname="Model > Letter > getLetters()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" 		required="true" 	type="numeric" />
		<cfargument name="letter_type" 		required="true" 	type="numeric" />
		<cfargument name="order_by_clause" 	required="false" 	type="string"	hint="SQL ORDER BY clause - optional" default="">
		<cfargument name="showAllLetters" 	required="false" 	type="boolean"	default="1">
		<cfargument name="FilterByID" 		required="false" 	type="string"	default="">

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetLetters = queryNew('cols')>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfquery name="var_qGetLetters" datasource="#application.datasource#">
	<!--- Milan (37515) - Earlier,it was "program_letters.*". Now, the column names are specifically mentioned here as "Letter_xml"
	column should not be incuded here. The size of "Letter_xml" column is huge and there is no need of it here.
	--->
			SELECT  program_letters.Program_Letters_id
			,program_letters.Program_Id
			,program_letters.Letter_Type
			,program_letters.Letter_Name
			,program_letters.Letter_Path
			,program_letters.Operator_Name
			,program_letters.Distributor_Name
			,program_letters.System_Generated
			,program_letters.Created_Date
			,program_letters.Created_By
			,program_letters.Distributor_Id
			,program_letters.Claim_Rates_Date
			,_users.name_first + ' ' + _users.name_last as user_name
			FROM	program_letters
			INNER JOIN _users ON _users.user_id = program_letters.created_by
			WHERE 	program_id =  '#arguments.program_id#'
			AND 	letter_type =  '#arguments.letter_type#'
			AND 	program_letters.deleted = 0
			<cfif arguments.showAllLetters eq 0>
			AND 1 = 0
			<cfelseif FilterByID neq "">
			AND program_letters.Distributor_Id = '#arguments.FilterByID#'
			</cfif>
			<cfif len(trim(arguments.order_by_clause))>
				ORDER BY 	#arguments.order_by_clause#
			</cfif>
		</cfquery>

		<!--- Return the final container to the caller --->
		<cfreturn var_qGetLetters>

	</cffunction>
	<!--- MODEL Legacy METHOD: getLetters() FUNCTIONALITY: I retrieve a letters list from the DB. [end] --->

	<!--- MODEL Legacy METHOD: getLetterSettings() FUNCTIONALITY: I retrieve letter settings from the DB. [begin] --->
	<cffunction name="getLetterSettings" access="public" output="no" hint="I retrieve letter settings from the DB." returntype="query" displayname="Model > Letter > getLetterSettings()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" 	required="true" type="numeric" />
		<cfargument name="user_id" 		required="true" type="string" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetLetterSettings = queryNew('cols')>

		<!--- MVC: Please try to use cfqueryparam where we can --->
		<cfquery name="var_qGetLetterSettings" datasource="#application.datasource#">
			select 	*
			from	Program_Letters_Settings
			where 	program_id = '#arguments.program_id#'
			<!---TSF: 10242 - Removing user_id from the where clause so that any user can view the letters--->
			<!--- and 	user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar"> --->
			and 	deleted = 0
		</cfquery>

		<!--- Return the final container to the caller --->
		<cfreturn var_qGetLetterSettings>

	</cffunction>
	<!--- MODEL Legacy METHOD: getLetterSettings() FUNCTIONALITY: I retrieve letter settings from the DB. [end] --->

	<!--- MODEL New METHOD: getLetterXML() FUNCTIONALITY: I retrieve a letter's XML from the Model. [begin] --->
	<cffunction name="getLetterXML" access="public" output="no" hint="I retrieve a letter's XML from the Model." returntype="xml" displayname="Models > Letter > getLetterXML()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_letter_id" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qLetterXML = queryNew('cols')>
		<cfset var var_xLetterXML = xmlNew(true)>

		<!--- MVC: Please try to use cfqueryparam where we can --->
		<cfquery name="var_qLetterXML" datasource="#application.datasource#">
		  SELECT	Letter_xml
		  FROM		Program_Letters
		  WHERE 	Program_Letters.Program_Letters_ID = <cfqueryparam value="#arguments.program_letter_id#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif var_qLetterXML.recordCount EQ 1 AND len(trim(var_qLetterXML.Letter_xml[1]))>

			<cfset var_xLetterXML = trim(var_qLetterXML.Letter_xml[1])>

		</cfif>

		<!--- Return the final container to the caller --->
		<cfreturn var_xLetterXML>

	</cffunction>
	<!--- MODEL New METHOD: getLetterXML() FUNCTIONALITY: I retrieve a letter's XML from the Model. [end] --->

	<!--- MODEL Legacy METHOD: getLumpSums() FUNCTIONALITY: I retrieve a letter's Lump Sums. [begin] --->
	<cffunction name="getLumpSums" output="false">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" required="true" type="string" />
		<cfargument name="program_bid_request_status_id" required="false" type="string" default="0" />
			<cfargument name="dist_id" required="false" type="string" default="0" />
		<cfargument name="bDistributorProductAttribute_1" required="false" type="string" default="0" />
		<cfargument name="bOperatorProductAttribute_1" required="false" type="string" default="0" />
		<cfargument name="IncludeInactive" required="false" type="string" default="1" />
		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetLumpSums = queryNew('cols')>

		<!--- Drop the temp table in a separate query:
		The change will be useful when we run "standard" letters and then change the app setting to run "custom" letters.
		Since the "custom" letter setting has more columns on the temp table, dropping the temp table using a separate query
		drops the temp table completely.
		--->
		<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
		 if object_id('tempdb..##TMP_LumpSum_Details') is not null
			 drop table ##TMP_LumpSum_Details
		</cfquery>

			<!--- MVC: Looks like we can't use cfqueryparam here? --->
			<cfquery name="var_qGetLumpSums" datasource="#application.datasource#">
			CREATE TABLE ##TMP_LumpSum_Details(
			item varchar(50),
			GTIN varchar(30),
			Net_Weight varchar(50),
			description varchar(255),
			BSA_FoodService_Items_Master_ID varchar(50),
			claim_mechanics varchar(50),
			Component_External_ID varchar(50),
			Component_Paid_To int,
			Lump_Sum_Amount varchar(50),
			Lump_Sum_Description varchar(900),
			Lump_Sum_Name varchar(255),
			Program_Lumps_Sum_Ext_ID int,
			Program_Lump_Sum_ID varchar(50),
			Program_Lump_Sum_Name varchar(255),
			Program_Lump_Sum_Name_ID int,
			External_ID varchar(255),
			BSA_Foodservice_Customers_ID varchar(50),
			Customer_Product_Number varchar(50),
			distributor_product_attribute_1 varchar(150),
			operator_product_attribute_1 varchar(150),
			Line_Number varchar(10)
			<!--- FOR HTML, i.e. "cfdocument" based PDF Letters --->
			<cfif appSettings.getlettersavailable() eq 2>
			,Group_Desc varchar(100)
			</cfif>
				)
				INSERT INTO ##TMP_LumpSum_Details(item,GTIN,Net_Weight,description,BSA_FoodService_Items_Master_ID,claim_mechanics,Component_External_ID,Component_Paid_To,Lump_Sum_Amount,Lump_Sum_Description,Lump_Sum_Name,
				Program_Lumps_Sum_Ext_ID,Program_Lump_Sum_ID,Program_Lump_Sum_Name,Program_Lump_Sum_Name_ID,External_ID<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>,BSA_Foodservice_Customers_ID,Customer_Product_Number</cfif>
			<cfif arguments.bDistributorProductAttribute_1 neq 0>,distributor_product_attribute_1</cfif>
			<cfif arguments.bOperatorProductAttribute_1 neq 0>,operator_product_attribute_1</cfif>,Line_Number<cfif appSettings.getlettersavailable() eq 2>,Group_Desc</cfif>
			)

			SELECT 	DISTINCT BSA_FoodService_Items_Master.item,BSA_Foodservice_Items_Master.GTIN,BSA_Foodservice_Items_Master.Net_Weight,
			BSA_FoodService_Items_Master.description,BSA_FoodService_Items_Master.BSA_FoodService_Items_Master_ID,
			Program_Lump_Sums.claim_mechanics, Program_Lump_Sums.Component_External_ID, Program_Lump_Sums.Component_Paid_To,
				Program_Lump_Sums.Lump_Sum_Amount, Program_Lump_Sums.Lump_Sum_Description, Program_Lump_Sums.Lump_Sum_Name, Program_Lump_Sums.Program_Lumps_Sum_Ext_ID,
				Program_Lump_Sums.Program_Lump_Sum_ID, Program_Lump_Sum_Name.Program_Lump_Sum_Name, Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID, Program_Lump_Sum_Name.External_ID
			<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>,BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,##TMP_Unique_Alias_Info.External_Code As Distributor_Product_Number</cfif>

			<!--- If DistributorProductAttribute_1 Is "Brand" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 1>
			,Brand.Brand_Name

			<!--- If DistributorProductAttribute_1 Is "Pack Size" --->
			<cfelseif arguments.bDistributorProductAttribute_1 eq 2>
			,Case_Count.Case_Count_Desc

			<!--- If DistributorProductAttribute_1 Is "QBrand" --->
			<cfelseif arguments.bDistributorProductAttribute_1 eq 3>
			,Q_Brand_Desc.Q_Brand

			<!--- If DistributorProductAttribute_1 Is "Type_Code" --->
			<cfelseif arguments.bDistributorProductAttribute_1 eq 4>
			,Type_Code_Desc.Type_Code_Desc

			<!--- If DistributorProductAttribute_1 Is "Type_Group" --->
			<cfelseif arguments.bDistributorProductAttribute_1 eq 5>
			,Type_Group_Desc.Type_Group_Desc
			</cfif>

			<!--- If OperatorProductAttribute_1 Is "Brand" --->
			<cfif arguments.bOperatorProductAttribute_1 eq 1>
			,Brand.Brand_Name

			<!--- If OperatorProductAttribute_1 Is "Pack Size" --->
			<cfelseif arguments.bOperatorProductAttribute_1 eq 2>
			,Case_Count.Case_Count_Desc

			<!--- If OperatorProductAttribute_1 Is "QBrand" --->
			<cfelseif arguments.bOperatorProductAttribute_1 eq 3>
			,Q_Brand_Desc.Q_Brand

			<!--- If OperatorProductAttribute_1 Is "Type_Code" --->
			<cfelseif arguments.bOperatorProductAttribute_1 eq 4>
			,Type_Code_Desc.Type_Code_Desc

			<!--- If OperatorProductAttribute_1 Is "Type_Group" --->
			<cfelseif arguments.bOperatorProductAttribute_1 eq 5>
			,Type_Group_Desc.Type_Group_Desc
			</cfif>

			,Program_Product_Bid_Info.Line_Number

			<cfif appSettings.getlettersavailable() eq 2>
			,All_Product_Group_Types.Group_Desc
			</cfif>

				FROM 	Program_Lump_Sums
						INNER JOIN Program_Lump_Sum_Name
						ON
						Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			LEFT JOIN Program_Lump_Sum_Product_Data ON Program_Lump_Sums.Program_Lump_Sum_ID = Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID
			AND Program_Lump_Sum_Product_Data.deleted = 0
			LEFT JOIN Contract_Products ON Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
			AND Contract_Products.deleted = 0
			LEFT JOIN BSA_Foodservice_Items_Master ON Contract_Products.BSA_FoodService_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_FoodService_Items_Master_ID

			<!--- Dev Note: Milan - 30173 (Get group level data from here. Do not join on group level id and do not use deleted column) --->
			<cfif appSettings.getlettersavailable() eq 2>
			LEFT OUTER JOIN All_Product_Group_Types
			ON Contract_Products.Product_Group_ID = CAST(All_Product_Group_Types.Group_GUID as varchar(50))
			</cfif>

			<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>
				INNER JOIN contract_distributors
				ON contract_distributors.contract_main_id = Program_Lump_Sums.Program_ID
				AND contract_distributors.deleted = 0
				AND contract_distributors.Contract_Main_ID = #PreserveSingleQuotes(arguments.PROGRAM_ID)#
				INNER JOIN BSA_Foodservice_Customers
				ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = contract_distributors.BSA_Foodservice_Customers_ID
				LEFT JOIN ##TMP_Unique_Alias_Info
				ON BSA_Foodservice_Items_Master.Item = ##TMP_Unique_Alias_Info.Item
				AND ##TMP_Unique_Alias_Info.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				AND ##TMP_Unique_Alias_Info.Use_For_Distributor_Payee_Only =
				CASE
					WHEN Program_Lump_Sums.Component_Paid_To <> 1
						THEN 0
				ELSE
					##TMP_Unique_Alias_Info.Use_For_Distributor_Payee_Only
				END
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Brand" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 1 OR arguments.bOperatorProductAttribute_1 eq 1>
			 LEFT JOIN Brand
			 ON BSA_Foodservice_Items_Master.Brand_ID = Brand.Brand_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Pack Size" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 2 OR arguments.bOperatorProductAttribute_1 eq 2>
				 LEFT JOIN Case_Count
				 ON BSA_Foodservice_Items_Master.Case_Count_ID = Case_Count.Case_Count_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "QBrand" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 3 OR arguments.bOperatorProductAttribute_1 eq 3>
			 LEFT JOIN Q_Brand_Desc
			 ON BSA_Foodservice_Items_Master.Q_Brand_ID = Q_Brand_Desc.Q_Brand_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Type_Code" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 4 OR arguments.bOperatorProductAttribute_1  eq 4>
			 LEFT JOIN Type_Code_Desc
			 ON BSA_Foodservice_Items_Master.Type_Code_Desc_ID= Type_Code_Desc.Type_Code_Desc_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Type_Group" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 5 OR arguments.bOperatorProductAttribute_1  eq 5>
			 LEFT JOIN Type_Group_Desc
			 ON BSA_Foodservice_Items_Master.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
			</cfif>

			 LEFT JOIN Program_Product_Bid_Info
			 ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Bid_Info.Product_ID
			 AND Program_Lump_Sums.Program_ID = Program_Product_Bid_Info.Program_ID
			 AND Program_Product_Bid_Info.deleted = 0

				<cfif listFind("2,3,4",arguments..program_bid_request_status_id,",")>
				AND 	BSA_Foodservice_Items_Master.BSA_FoodService_Items_Master_ID IN
								(	SELECT	Product_ID
										FROM	program_product_bid_info
										WHERE	program_product_bid_info.program_id = #PreserveSingleQuotes(arguments.PROGRAM_ID)#
										AND		program_product_bid_info.won = 1)
			</cfif>
			   WHERE Program_Lump_Sums.Program_ID = #PreserveSingleQuotes(arguments.PROGRAM_ID)#
			   AND Program_Lump_Sums.Deleted = 0
			<cfif arguments.IncludeInactive eq 0>
				AND BSA_Foodservice_Items_Master.Active_Code = 'A'
			</cfif>
			<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>
			   AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN  (#ListQualify(arguments.Dist_ID,"'")#)
			</cfif>

			   <cfif appSettings.getlettersavailable() neq 2>
			AND
			(
			<!--- For standard letters ("Itext" based pdf letters), show only those entries that are added from the application. These entries could
			be items or groups. Do not show group members. --->
			IsNull(Contract_Products.Captured_From_Group,0) = 0
			)
			<!--- FOR Custom letters (HTML, i.e. "cfdocument" based PDF Letter), get only products, and not groups. --->

			<!---	Comment this code as when the product groups did not have members, that component was not being shown on the letter. Now, group as well as product
			records are retrieved from this query Then CF only displays the item records at the item level and not the groups.
			--->
			<!---
			<cfelse>
			AND   IsNull(Contract_Products.Is_Group,0) = 0
			--->
			</cfif>
			</cfquery>


	</cffunction>
	<!--- MODEL Legacy METHOD: getLumpSums() FUNCTIONALITY: I retrieve a letter's Lump Sums. [end] --->

	<!--- MODEL New METHOD: getOperatorDetails() FUNCTIONALITY: I retrieve a letter's Operator Details. [begin] --->
	<cffunction name="getOperatorDetails" output="false" access="public" hint="I retrieve a letter's Operator Details." returntype="query" displayname="Models > Letter > getOperatorDetails()">>

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetOperatorDetails = queryNew('cols')>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfquery name="var_qGetOperatorDetails" datasource="#application.datasource#">
			select BSA_Operator.BSA_Operator_ID,Operator_Name,Legacy_ID
			from contract_operators
			inner join BSA_Operator
			ON BSA_Operator.BSA_Operator_ID = contract_operators.BSA_Operator_ID
			where contract_main_id = '#arguments.program_id#'
			and contract_operators.deleted = 0
		</cfquery>

		<cfreturn var_qGetOperatorDetails />

	</cffunction>
	<!--- MODEL New METHOD: getOperatorDetails() FUNCTIONALITY: I retrieve a letter's Operator Details. [end] --->

	<!--- MODEL Legacy METHOD: getProgramDetails() FUNCTIONALITY: I retrieve the letter's program details. [begin] --->
	<cffunction name="getProgramDetails" output="false" access="public" hint="I retrieve the letter's program details." returntype="query" displayname="Models > Letter > getProgramDetails()">
		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetProgramDetails = queryNew('cols')>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfquery name="var_qGetProgramDetails" datasource="#application.datasource#">
			select payment_cycle,contract_main_id,contract_number,contract_start_date,contract_end_date,dbo.Program_Control_Panel_Options.Generic_Type,
			Discount_Fixed_Prices,Discount_Rebates,Discount_Lump_Sums,Discount_Growth,Date_Exclusions_ON,Legacy_Deal_ID,
			_users.name_first, _users.name_last,_users.title,revision_version,paymentcycle,Program_Control_Panel_Options.BidRequestStatusOn
			from contract_main
			inner join Program_Control_Panel_Options
			ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
			inner join _users on _users.user_id = Contract_Main.Responsible_User_ID
			left join payment_cycle on payment_cycle.payment_cycle_id = contract_main.paymentcycle
			where contract_main_id = '#arguments.program_id#'
		</cfquery>

		<cfreturn var_qGetProgramDetails />

	</cffunction>
	<!--- MODEL Legacy METHOD: getProgramDetails() FUNCTIONALITY: I retrieve the letter's program details. [end] --->

	<!--- Get setting based on which price list date can be calculated --->
	<cffunction name="getSettingForPriceListDate" output="false" returntype="numeric">
		<cfargument name="program_id" required="true" type="string" />

		<cfset var PriceListSetting = 1>

		<cfquery name="qGetSettingForPriceListDate" datasource="#application.datasource#">
			SELECT pcpo.Base_Sales_based_on_Prg_Start_Date, pcpo.Select_Effective_Date_for_Price,
				   CM.Effective_Date_for_Price
			FROM Program_Control_Panel_Options pcpo
			INNER JOIN Contract_Main cm
			ON pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
			WHERE cm.Contract_Main_ID = #PreserveSingleQuotes(arguments.PROGRAM_ID)#
		</cfquery>

		<cfif qGetSettingForPriceListDate.Base_Sales_based_on_Prg_Start_Date eq 1
			  AND qGetSettingForPriceListDate.Select_Effective_Date_for_Price eq 1
			  AND qGetSettingForPriceListDate.Effective_Date_for_Price neq "">

			<cfset PriceListSetting = 2>

		<cfelseif qGetSettingForPriceListDate.Base_Sales_based_on_Prg_Start_Date eq 1
			  AND (qGetSettingForPriceListDate.Select_Effective_Date_for_Price eq 0
				   OR
				   qGetSettingForPriceListDate.Effective_Date_for_Price eq ""
				  )>
			<cfset PriceListSetting = 3>

		<!--- default --->
		<cfelseif qGetSettingForPriceListDate.Base_Sales_based_on_Prg_Start_Date eq 0>

			<cfset PriceListSetting = 1>

		</cfif>

	  <cfreturn PriceListSetting>

	</cffunction>

	<!--- Note: Dev Note(69526) - Get the "Alias Data" for the customer and product combination. --->
	<cffunction name="getProductAliases" output="true">
		<cfargument name="program_id" required="true" type="string" />
		<cfargument name="distList" required="true" type="string" />
		<cfargument name="showAlias" required="true" type="boolean" />

		<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
		if object_id('tempdb..##TMP_Alias_Info') is not null
		drop table ##TMP_Alias_Info

		if object_id('tempdb..##TMP_Unique_Alias_Info') is not null
		drop table ##TMP_Unique_Alias_Info

		if object_id('tempdb..##Customer_Primary_BB_Claim_Source_XREF_Info') is not null
		drop table ##Customer_Primary_BB_Claim_Source_XREF_Info
		</cfquery>

		<cfquery name="qGetProductAliases" datasource="#application.datasource#">
		CREATE TABLE ##TMP_Unique_Alias_Info
		(
		Item varchar(100),
		BB_Claim_Source_XREF_ID int,
		External_Code varchar(100),
		BSA_Foodservice_Customers_ID uniqueIdentifier,
		Row_ID int,
		Use_For_Distributor_Payee_Only bit
		)

		SELECT BSA_Foodservice_Customers.Shr_Ship_to,BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
				Primary_BB_Claim_Source_XREF_ID,0 As Use_For_Distributor_Payee_Only
		INTO ##Customer_Primary_BB_Claim_Source_XREF_Info
		FROM BSA_Foodservice_Customers
		WHERE BSA_Foodservice_Customers_ID IN (#ListQualify(arguments.distList, "'" , ",", "ALL")#)
			
		<cfif arguments.showAlias eq 1>
		
		<!--- Note: Dev Note(69526) - Below technique of populating the "Primary_BB_Claim_Source_XREF_ID" column has been used in
		"PROGRAM_CLAIM_RATES_REPORT" SP.

		Only when pays to = distributor, use EDI source when primary source is not available.
		If the payee is not distributor, then this populated "Primary_BB_Claim_Source_XREF_ID" cannot be used.
		Note: Checking for "pays to = distributor" will be done in the different discount type queries.
		--->
		UPDATE	t
		SET		Primary_BB_Claim_Source_XREF_ID = s.BB_Claim_Source_XREF_ID,
				Use_For_Distributor_Payee_Only = 1
		FROM	##Customer_Primary_BB_Claim_Source_XREF_Info t
			INNER JOIN BB_Claim_Dist_XREF x
		ON		x.Shipto = t.shr_ship_to
		AND		x.Deleted = 0
			INNER JOIN BB_Claim_Source_XREF s
		ON		s.BB_Claim_Source_XREF_ID = x.BB_Claim_Source_XREF_ID
		AND		s.Source_Type_Description = 'EDI-DIST'
		AND		s.Deleted = 0
		AND		s.Active = 1
		WHERE	t.Primary_BB_Claim_Source_XREF_ID IS NULL

		SELECT	BB_Claim_Item_XREF.Item,BB_Claim_Source_XREF_ID,External_Code,cpx.BSA_Foodservice_Customers_ID,
				Row_Number() OVER(Partition by BB_Claim_Item_XREF.Item,BB_Claim_Source_XREF_ID,BSA_Foodservice_Customers_ID Order By BB_Claim_Item_XREF.Created_Date desc) as Row_ID,
				cpx.Use_For_Distributor_Payee_Only
			INTO	##TMP_Alias_Info
		FROM ##Customer_Primary_BB_Claim_Source_XREF_Info cpx
			INNER JOIN BB_Claim_Item_XREF
		ON cpx.Primary_BB_Claim_Source_XREF_ID = BB_Claim_Item_XREF.BB_Claim_Source_XREF_ID
			INNER JOIN BSA_Foodservice_Items_Master
		ON BB_Claim_Item_XREF.Item = BSA_Foodservice_Items_Master.Item
			INNER JOIN Contract_Products
		ON Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
		WHERE BB_Claim_Item_XREF.deleted = 0
		AND Contract_Products.Contract_Main_ID = '#arguments.program_id#'
		AND Contract_Products.deleted = 0
		AND Contract_Products.Is_Group = 0
		AND (BB_Claim_Item_XREF.Item IS NOT NULL AND BB_Claim_Item_XREF.Item < > '')
		AND (BB_Claim_Item_XREF.External_Code IS NOT NULL AND BB_Claim_Item_XREF.External_Code < > '')

		INSERT INTO ##TMP_Unique_Alias_Info(Item,BB_Claim_Source_XREF_ID,External_Code,BSA_Foodservice_Customers_ID,Row_ID,Use_For_Distributor_Payee_Only)
		SELECT * FROM ##TMP_Alias_Info
		WHERE Row_ID = 1
		</cfif>
			
		<!--- Get values from Alias_Management_Products --->
		INSERT INTO ##TMP_Unique_Alias_Info(
				Item, BB_Claim_Source_XREF_ID, 
				External_Code, BSA_Foodservice_Customers_ID, 
				Row_ID, Use_For_Distributor_Payee_Only)
		SELECT	BSA_Foodservice_Items_Master.Item, 0 as BB_Claim_Source_XREF_ID, 
				Alias_Management_Products.distributor_product_number as External_Code, cpx.BSA_Foodservice_Customers_ID, 
				1 as Row_ID, cpx.Use_For_Distributor_Payee_Only
		FROM 	##Customer_Primary_BB_Claim_Source_XREF_Info cpx
		INNER JOIN Alias_Management_Products
		ON		Alias_Management_Products.Distributor_ID = cpx.BSA_Foodservice_Customers_ID
		INNER JOIN BSA_Foodservice_Items_Master
		ON 		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Alias_Management_Products.Product_ID
		INNER JOIN Contract_Products
		ON 		Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
		WHERE  	Contract_Products.Contract_Main_ID = '#arguments.program_id#'
		AND 	Contract_Products.deleted = 0
		AND 	Contract_Products.Is_Group = 0
		AND 	(Alias_Management_Products.distributor_product_number IS NOT NULL AND Alias_Management_Products.distributor_product_number <> '')
		AND 	NOT EXISTS (
			SELECT	1 
			FROM	##TMP_Unique_Alias_Info t 
			WHERE	t.BSA_Foodservice_Customers_ID = cpx.BSA_Foodservice_Customers_ID
			AND		t.Item = BSA_Foodservice_Items_Master.Item
		)


		if object_id('tempdb..##TMP_Alias_Info') is not null
		drop table ##TMP_Alias_Info

		if object_id('tempdb..##Customer_Primary_BB_Claim_Source_XREF_Info') is not null
		drop table ##Customer_Primary_BB_Claim_Source_XREF_Info
		</cfquery>
	</cffunction>

	<!--- MODEL Legacy METHOD: getRebateProducts() FUNCTIONALITY: I retrieve the letter's rebate products. [begin] (modified by Milan) --->
	<cffunction name="getRebateProducts" output="false">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
	<cfargument name="program_id" required="true" type="string" />
	<cfargument name="dist_id" required="false" type="string" default="0" />
	<cfargument name="bDistributorProductAttribute_1" required="false" type="string" default="0" />
	<cfargument name="bOperatorProductAttribute_1" required="false" type="string" default="0" />
	<cfargument name="IncludeInactive" required="false" type="string" default="1" />
	<cfset var PriceListDateSetting = getSettingForPriceListDate('#arguments.program_id#')>

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qInsertRebateProducts 	= queryNew('cols')>
		<cfset var var_qGetRebateProducts 		= queryNew('cols')>

	<!--- Drop the temp table in a separate query:
	The change will be useful when we run "standard" letters and then change the app setting to run "custom" letters.
	Since the "custom" letter setting has more columns on the temp table, dropping the temp table using a separate query
	drops the temp table completely.
	--->
	<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
			if object_id('tempdb..##TMP_Rebate_Price_Details') is not null
			drop table ##TMP_Rebate_Price_Details
	</cfquery>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfquery name="var_qInsertRebateProducts" datasource="#application.datasource#">
			CREATE TABLE ##TMP_Rebate_Price_Details(
				BSA_Foodservice_Items_Master_ID varchar(50),
				description varchar(255),
				Item varchar(50),
				GTIN varchar(30),
				Net_Weight varchar(50),
				Program_Rebates_Component_ID int,
				rate float,
				contract_start_date datetime,
				contract_end_date datetime,
				Program_Rebates_Component_Name [varchar](50),
				IsExclusionRevision bit,
				Component_Paid_to int,
				Unit_Of_Measure_ID tinyint,
				Abbreviation char(10),
				Abbreviation_Singular char(10),
				rebate_price_per_pound [varchar](100),
				rebate_price_per_case [varchar](100),
				rebate_price_percent [varchar](100),      <!---30303--->
				rebate_price_per_hundred_weight [varchar](100),
				BSA_Foodservice_Customers_ID varchar(50),
				customer_product_number [varchar](50),
				claim_mechanics [varchar](50),
				distributor_product_attribute_1 varchar(150),
				operator_product_attribute_1 varchar(150),
				Is_Group bit,
				Line_Number varchar(10)
				<!--- FOR HTML, i.e. "cfdocument" based PDF Letter, get bracket price --->
				<cfif appSettings.getlettersavailable() eq 2>
				,CS_Bracket_1 [varchar](100)
				,CS_Bracket_2 [varchar](100)
				,CS_Bracket_3 [varchar](100)
				,CS_Bracket_4 [varchar](100)
				,CS_Bracket_5 [varchar](100)
				,Price_List_Start_Date datetime
				,Group_Desc varchar(100)
				</cfif>
			)

			CREATE CLUSTERED  INDEX [I_Rebate_Price_Details_tmp] ON [##TMP_Rebate_Price_Details]([Program_Rebates_Component_ID],[Item]) ON [PRIMARY]

				INSERT INTO ##TMP_Rebate_Price_Details
				(
				BSA_Foodservice_Items_Master_ID,description,Item,GTIN,Net_Weight,<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>BSA_Foodservice_Customers_ID,Customer_Product_Number,</cfif>Program_Rebates_Component_ID,rate,contract_start_date,contract_end_date,
				Program_Rebates_Component_Name,IsExclusionRevision,Component_Paid_to,Unit_Of_Measure_ID,Abbreviation,Abbreviation_Singular,rebate_price_per_pound,
				rebate_price_per_case,rebate_price_percent,rebate_price_per_hundred_weight,claim_mechanics <!---30303--->
				<cfif arguments.bDistributorProductAttribute_1 neq 0>,distributor_product_attribute_1</cfif>
				<cfif arguments.bOperatorProductAttribute_1 neq 0>,operator_product_attribute_1</cfif>,Is_Group,Line_Number<cfif appSettings.getlettersavailable() eq 2>,CS_Bracket_1,CS_Bracket_2,CS_Bracket_3,CS_Bracket_4,CS_Bracket_5,Price_List_Start_Date,Group_Desc</cfif>
				)
				select distinct BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,description,
				BSA_Foodservice_Items_Master.Item,BSA_Foodservice_Items_Master.GTIN,BSA_Foodservice_Items_Master.Net_Weight,<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,##TMP_Unique_Alias_Info.External_Code As Distributor_Product_Number,</cfif>
				Program_Rebates_Component_Data.Program_Rebates_Component_ID,
				<!--- Unit_Of_Measure_ID = 6 is for "per hundred weight (CWT)" and that is stored in the db converted to LB.
					Program_Rebates_Component_Data.Unit_Of_Measure_ID is set to 2 for both - LB and CWT. The actual UOM is stored in the "user_picked_UOM" column.
				--->
			   CASE
				   	WHEN Units_of_Measure.Unit_Of_Measure_ID IN (5,6)
				   		THEN Program_Rebates_Component_Data.Scan_Rate
				   	WHEN Units_of_Measure.Unit_Of_Measure_ID = 6
				   		THEN CAST(Program_Rebates_Component_Data.Rate AS FLOAT) * 100
				   	ELSE Program_Rebates_Component_Data.Rate
			   END AS Rate,
				Contract_Main.contract_start_date, Contract_Main.contract_end_date,Program_Rebates_Component_Name.Program_Rebates_Component_Name,
				IsExclusionRevision,Component_Paid_to, Units_of_Measure.Unit_Of_Measure_ID,
				Units_of_Measure.Abbreviation,
				Units_of_Measure.Abbreviation_Singular,
				<!--- Unit_Of_Measure_ID = 6 is for "per hundred weight (CWT)" and that is stored in the db converted to LB.
				Program_Rebates_Component_Data.Unit_Of_Measure_ID is set to 2 for both - LB and CWT. The actual UOM is stored in the "user_picked_UOM" column.
				--->
				CASE WHEN Units_of_Measure.Unit_Of_Measure_ID = 2 OR Units_of_Measure.Unit_Of_Measure_ID = 6
						THEN cast(Program_Rebates_Component_Data.rate as float) <!---75851 and 63887 --->
				ELSE
						cast(Program_Rebates_Component_Data.rate as float) / cast(BSA_Foodservice_Items_Master.Net_Weight as float)
				END as rebate_price_per_pound,
				CASE WHEN Units_of_Measure.Unit_Of_Measure_ID = 2 OR Units_of_Measure.Unit_Of_Measure_ID = 6
						THEN cast(Program_Rebates_Component_Data.rate as float) * cast(BSA_Foodservice_Items_Master.Net_Weight as float) <!---75851 and 63887 --->
				ELSE	cast(Program_Rebates_Component_Data.rate as float)
				END as rebate_price_per_case,
				CASE WHEN Units_of_Measure.Unit_Of_Measure_ID = 3
						THEN cast(Program_Rebates_Component_Data.rate as float)  <!---30303--->
				ELSE null
				END as rebate_price_percent,
				<!--- Unit_Of_Measure_ID = 6 is for "per hundred weight (CWT)" and that is stored in the db converted to LB.
				Program_Rebates_Component_Data.Unit_Of_Measure_ID is set to 2 for both - LB and CWT. The actual UOM is stored in the "user_picked_UOM" column.
				--->
				CASE WHEN Units_of_Measure.Unit_Of_Measure_ID = 2 OR Units_of_Measure.Unit_Of_Measure_ID = 6
					THEN cast(Program_Rebates_Component_Data.rate as float) * 100
				WHEN Units_of_Measure.Unit_Of_Measure_ID = 1
					THEN (cast(Program_Rebates_Component_Data.rate as float) / cast(BSA_Foodservice_Items_Master.Net_Weight as float)) * 100
				ELSE cast(Program_Rebates_Component_Data.rate as float)
				END as rebate_price_per_hundred_weight,
			Payment_Type.Payment_Type_Name

		<!--- If DistributorProductAttribute_1 Is "Brand" --->
		<cfif arguments.bDistributorProductAttribute_1 eq 1>
		,Brand.Brand_Name

		<!--- If DistributorProductAttribute_1 Is "Pack Size" --->
		<cfelseif arguments.bDistributorProductAttribute_1 eq 2>
		,Case_Count.Case_Count_Desc

		<!--- If DistributorProductAttribute_1 Is "QBrand" --->
		<cfelseif arguments.bDistributorProductAttribute_1 eq 3>
		,Q_Brand_Desc.Q_Brand

		<!--- If DistributorProductAttribute_1 Is "Type_Code" --->
		<cfelseif arguments.bDistributorProductAttribute_1 eq 4>
		,Type_Code_Desc.Type_Code_Desc

		<!--- If DistributorProductAttribute_1 Is "Type_Group" --->
		<cfelseif arguments.bDistributorProductAttribute_1 eq 5>
		,Type_Group_Desc.Type_Group_Desc
		</cfif>

		<!--- If OperatorProductAttribute_1 Is "Brand" --->
		<cfif arguments.bOperatorProductAttribute_1 eq 1>
		,Brand.Brand_Name

		<!--- If OperatorProductAttribute_1 Is "Pack Size" --->
		<cfelseif arguments.bOperatorProductAttribute_1 eq 2>
		,Case_Count.Case_Count_Desc

		<!--- If OperatorProductAttribute_1 Is "QBrand" --->
		<cfelseif arguments.bOperatorProductAttribute_1 eq 3>
		,Q_Brand_Desc.Q_Brand

		<!--- If OperatorProductAttribute_1 Is "Type_Code" --->
		<cfelseif arguments.bOperatorProductAttribute_1 eq 4>
		,Type_Code_Desc.Type_Code_Desc

		<!--- If OperatorProductAttribute_1 Is "Type_Group" --->
		<cfelseif arguments.bOperatorProductAttribute_1 eq 5>
		,Type_Group_Desc.Type_Group_Desc
		</cfif>

		,Contract_Products.Is_Group
		,Program_Product_Bid_Info.Line_Number

		<!--- FOR HTML, i.e. "cfdocument" based PDF Letter, get bracket price --->
		<cfif appSettings.getlettersavailable() eq 2>
		,Price_List_Detail.CS_Bracket_1
		,Price_List_Detail.CS_Bracket_2
		,Price_List_Detail.CS_Bracket_3
		,Price_List_Detail.CS_Bracket_4
		,Price_List_Detail.CS_Bracket_5

			<!--- default ("Base Sales based on Prg Start Date" setting is OFF). Get today's date --->
			<cfif PriceListDateSetting eq 1>
			,Convert(varchar,GetDate(),101)

			<!--- effective date for price --->
			<cfelseif  PriceListDateSetting eq 2>
			,Convert(varchar,Contract_Main.Effective_Date_for_Price,101)

			<!--- program start date --->
			<cfelseif  PriceListDateSetting eq 3>
			,Convert(varchar,Contract_Main.Contract_Start_Date,101)
			</cfif>

			As Price_List_Start_Date
		,All_Product_Group_Types.Group_Desc
		</cfif>



				from
				Program_Rebates_Product_Data
				INNER JOIN
				Program_Rebates_Component_Data
				ON Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_Id
				and Program_Rebates_Component_Data.deleted = 0
				INNER JOIN Program_Rebates_Component
				ON Program_Rebates_Component_Data.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID
				and Program_Rebates_Component.deleted = 0
				and Program_Rebates_Component.program_id = Program_Rebates_Product_Data.program_id
				inner join Program_Rebates_Component_Name on
				Program_Rebates_Component_Name.Program_Rebates_Component_Name_id = Program_Rebates_Component.Program_Rebates_Component_Name_id
				inner join Units_of_Measure ON
				Units_of_Measure.Unit_Of_Measure_ID = CASE WHEN Program_Rebates_Component_Data.User_Picked_UOM IN (5,6,7) THEN Program_Rebates_Component_Data.User_Picked_UOM ELSE Program_Rebates_Component_Data.Unit_Of_Measure_ID END <!---75851 and 63887 --->
				inner join
				Contract_Products ON
				Contract_Products.Contract_Products_ID = Program_Rebates_Product_Data.Contract_Products_ID
				AND Contract_Products.Deleted = 0
				and Contract_Products.contract_main_id = Program_Rebates_Product_Data.program_id

		<cfif appSettings.getlettersavailable() neq 2>
		AND
		(
		<!--- For standard letters ("Itext" based pdf letters), show only those entries that are added from the application. These entries could
		be items or groups. Do not show group members. --->
		Contract_Products.Captured_From_Group = 0
		)
		<cfelse>
		<!--- FOR Custom letters (HTML, i.e. "cfdocument" based PDF Letter), get only products, and not groups. --->
		AND   IsNull(Contract_Products.Is_Group,0) = 0
		</cfif>

				INNER JOIN BSA_Foodservice_Items_Master ON
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID

		<!--- Dev Note: Milan - 30173 (Get group level data from here. Do not join on group level id and do not use deleted column) --->
		<cfif appSettings.getlettersavailable() eq 2>
		LEFT OUTER JOIN All_Product_Group_Types
		ON Contract_Products.Product_Group_ID = CAST(All_Product_Group_Types.Group_GUID as varchar(50))
		</cfif>

				INNER JOIN Contract_Main
				ON Contract_Main.Contract_Main_ID = Contract_Products.Contract_Main_ID

				LEFT JOIN Payment_Type
				ON Program_Rebates_Component.Claim_Mechanics = Payment_Type.Payment_Type_id

		<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>
		INNER JOIN contract_distributors
		ON contract_distributors.contract_main_id = Contract_Products.contract_main_id
		AND contract_distributors.deleted = 0
		INNER JOIN BSA_Foodservice_Customers
		ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = contract_distributors.BSA_Foodservice_Customers_ID
		LEFT JOIN ##TMP_Unique_Alias_Info
		ON BSA_Foodservice_Items_Master.Item = ##TMP_Unique_Alias_Info.Item
		AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = ##TMP_Unique_Alias_Info.BSA_Foodservice_Customers_ID
		AND ##TMP_Unique_Alias_Info.Use_For_Distributor_Payee_Only =
		CASE
			WHEN Program_Rebates_Component.Component_Paid_To <> 1
				THEN 0
		ELSE
			##TMP_Unique_Alias_Info.Use_For_Distributor_Payee_Only
		END
		</cfif>

		<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Brand" --->
		<cfif arguments.bDistributorProductAttribute_1 eq 1 OR arguments.bOperatorProductAttribute_1 eq 1>
		 LEFT JOIN Brand
		 ON BSA_Foodservice_Items_Master.Brand_ID = Brand.Brand_ID
		</cfif>

		<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Pack Size" --->
		<cfif arguments.bDistributorProductAttribute_1 eq 2 OR arguments.bOperatorProductAttribute_1 eq 2>
			 LEFT JOIN Case_Count
			 ON BSA_Foodservice_Items_Master.Case_Count_ID = Case_Count.Case_Count_ID
		</cfif>

		<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "QBrand" --->
		<cfif arguments.bDistributorProductAttribute_1 eq 3 OR arguments.bOperatorProductAttribute_1 eq 3>
		 LEFT JOIN Q_Brand_Desc
		 ON BSA_Foodservice_Items_Master.Q_Brand_ID = Q_Brand_Desc.Q_Brand_ID
		</cfif>

		<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Type_Code" --->
		<cfif arguments.bDistributorProductAttribute_1 eq 4 OR arguments.bOperatorProductAttribute_1  eq 4>
		 LEFT JOIN Type_Code_Desc
		 ON BSA_Foodservice_Items_Master.Type_Code_Desc_ID= Type_Code_Desc.Type_Code_Desc_ID
		</cfif>

		<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Type_Group" --->
		<cfif arguments.bDistributorProductAttribute_1 eq 5 OR arguments.bOperatorProductAttribute_1  eq 5>
		 LEFT JOIN Type_Group_Desc
		 ON BSA_Foodservice_Items_Master.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
		</cfif>

		LEFT JOIN Program_Control_Panel_Options
		ON Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID

		LEFT JOIN Program_Product_Bid_Info
		ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Bid_Info.Product_ID
		AND Contract_Main.Contract_Main_ID = Program_Product_Bid_Info.Program_ID
		AND Program_Product_Bid_Info.deleted = 0

		<!--- FOR HTML, i.e. "cfdocument" based PDF Letter, get bracket price --->
		<cfif appSettings.getlettersavailable() eq 2>
		LEFT JOIN Price_List_Detail
		ON Program_Control_Panel_Options.Margin_Price_List_Header_ID = Price_List_Detail.Price_List_Header_ID
		AND Price_List_Detail.deleted = 0
		AND Contract_Products.BSA_Foodservice_Items_Master_ID = Price_List_Detail.Product_ID

			<!--- default ("Base Sales based on Prg Start Date" setting is OFF) --->
			<cfif PriceListDateSetting eq 1>
			AND Price_List_Detail.Active_Code = 'A'

			<!--- effective date for price --->
			<cfelseif  PriceListDateSetting eq 2>
			AND Contract_Main.Effective_Date_for_Price >= Price_List_Detail.Start_Date
			AND Contract_Main.Effective_Date_for_Price <= Price_List_Detail.End_Date

			<!--- program start date --->
			<cfelseif  PriceListDateSetting eq 3>
			AND Contract_Main.Contract_Start_Date >= Price_List_Detail.Start_Date
			AND Contract_Main.Contract_Start_Date <= Price_List_Detail.End_Date
			</cfif>
		</cfif>

		WHERE Program_Rebates_Product_Data.Program_ID IN (#PreserveSingleQuotes(arguments.PROGRAM_ID)#)
				AND Program_Rebates_Product_Data.Deleted = 0
		<cfif arguments.IncludeInactive eq 0>
			AND BSA_Foodservice_Items_Master.Active_Code = 'A'
		</cfif>

		<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>
		AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN (#ListQualify(arguments.Dist_ID,"'")#)
		</cfif>

		<!--- FOR HTML, i.e. "cfdocument" based PDF Letter, do not include "price protection increase" component --->
		<cfif appSettings.getlettersavailable() eq 2>
		AND Program_Rebates_Component_Name.rebate_type <> 2
		</cfif>

		<cfif application.appSettingsGet.display_zeros_view_program eq 0>
			AND ISNULL( CAST( Program_Rebates_Component_Data.rate AS FLOAT ), 0 ) <> 0     <!--- 32483 --->
		</cfif>

				ORDER BY Program_Rebates_Component_Data.Program_Rebates_Component_ID,Component_Paid_to,item
		</cfquery>
	<!--- No need to select data from the temp table. (Comment the query) --->
	<!---
		<cfquery name="var_qGetRebateProducts" datasource="#application.datasource#">
			SELECT *
			FROM ##TMP_Rebate_Price_Details
		</cfquery>
	--->
		<cfreturn var_qGetRebateProducts />

	</cffunction>
	<!--- getGrowthProducts() FUNCTIONALITY: I retrieve the letter's growth products. (created by Milan) --->

			
	<cffunction name="getRebateAlterateRecaptureRates" output="false">

		<cfargument name="program_id" required="true" type="string" />

		<!--- Drop the temp table in a separate query --->
		<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_pgm_rebate_comp_alt') IS NOT NULL
			DROP TABLE ##tmp_pgm_rebate_comp_alt
			
			IF OBJECT_ID('tempdb..##tmp_pgm_alt_recap_rates') IS NOT NULL
			DROP TABLE ##tmp_pgm_alt_recap_rates
		</cfquery>

		<!--- We can't use cfqueryparam here as we need the temp table available outside the query --->
		<cfquery name="var_qInsertRebateAlterateRecaptureRates" datasource="#application.datasource#">
			declare @contract_main_id int = '#arguments.PROGRAM_ID#'
			
			select	rc.Program_Rebates_Component_ID, rc.Program_Rebates_Component_Name_ID, rc.Component_Paid_To, 
					isnull(arsetting.Alternate_Recapture_Rate_Index, 0) as Alternate_Recapture_Rate_Index, isnull(arsetting.Alternate_Recapture_Rate_Label, '') as Alternate_Recapture_Rate_Label
			into	##tmp_pgm_rebate_comp_alt
			from	Program_Rebates_Component rc
			inner join Alternate_Recapture_Rate_Setting arsetting
			on		arsetting.Program_Rebates_Component_Name_ID = rc.Program_Rebates_Component_Name_ID
			where	rc.Program_ID = @contract_main_id
			and		rc.Deleted = 0

			select	ar.Program_Rebates_Component_ID, comp.Component_Paid_To, 
					cp.BSA_Foodservice_Items_Master_ID, i.Item, 
					ar.Alternate_Recapture_Rate_Index, 
					ar.Rate, ar.UOM,
					Units_of_Measure.Abbreviation as UOM_Desc
			into	##tmp_pgm_alt_recap_rates
			from	Contract_Products cp
			inner join BSA_Foodservice_Items_Master i
			on		i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
			inner join ##tmp_pgm_rebate_comp_alt comp
			on		1 = 1
			inner join Program_Rebate_Alternate_Recapture_Rate ar
			on		ar.Contract_Main_ID = cp.Contract_Main_ID
			and		ar.Contract_Products_ID = cp.Contract_Products_ID
			and		ar.Program_Rebates_Component_ID = comp.Program_Rebates_Component_ID
			inner join Units_of_Measure 
			ON		Units_of_Measure.Unit_Of_Measure_ID = ar.UOM
			where	cp.Contract_Main_ID = @contract_main_id
			and		cp.Deleted = 0
			and		cp.Product_Type_ID = 2
			and		cp.Captured_From_Group = 0
			Order By ar.Program_Rebates_Component_ID, comp.Component_Paid_to, i.item, ar.Alternate_Recapture_Rate_Index
		</cfquery>
	
	</cffunction>
			
	<cffunction name="getGrowthProducts" output="false">
		<cfargument name="program_id" required="true" type="string" />
		<cfargument name="dist_id" required="false" type="string" default="0" />
		<cfargument name="bDistributorProductAttribute_1" required="false" type="string" default="0" />
		<cfargument name="bOperatorProductAttribute_1" required="false" type="string" default="0" />
		<cfargument name="IncludeInactive" required="false" type="string" default="1" />
		<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
			if object_id('tempdb..##TMP_Growth_Details') is not null
			drop table ##TMP_Growth_Details
		</cfquery>

		<cfquery name="var_qInsertGrowthProducts" datasource="#application.datasource#">
			CREATE TABLE ##TMP_Growth_Details(
			BSA_Foodservice_Items_Master_ID varchar(50),
			Description varchar(255),
			Item varchar(50),
			GTIN varchar(30),
			Program_Growth_Component_ID varchar(50),
			Rate float,
			Growth_Amount varchar(50),
			Program_Growth_Components_Name [varchar](50),
			Component_Paid_to int,
			Unit_Of_Measure_ID tinyint,
			component_UOM_Desc varchar(20),
			Abbreviation char(10),
			growth_price_per_pound [varchar](100),
			growth_price_per_case [varchar](100),
			growth_price_percent [varchar](100),
			BSA_Foodservice_Customers_ID varchar(50),
			customer_product_number [varchar](50),
			Claim_Mechanics [varchar](50),
			Tier_Number [varchar](50),
			Range_Start [varchar](50),
			Range_End [varchar](50),
			distributor_product_attribute_1 varchar(150),
			operator_product_attribute_1 varchar(150)
			)
			INSERT INTO ##TMP_Growth_Details
			(
			BSA_Foodservice_Items_Master_ID,
			Description,
			Item,
			GTIN,
			Program_Growth_Component_ID,
			Rate,
			Growth_Amount,
			Program_Growth_Components_Name,
			Component_Paid_to,
			Unit_Of_Measure_ID,
			component_UOM_Desc,
			Abbreviation,
			growth_price_per_pound,
			growth_price_per_case,
			growth_price_percent,
			<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>BSA_Foodservice_Customers_ID,Customer_Product_Number,</cfif>
			Claim_Mechanics,
			Tier_Number,
			Range_Start,
			Range_End
			<cfif arguments.bDistributorProductAttribute_1 neq 0>,distributor_product_attribute_1</cfif>
			<cfif arguments.bOperatorProductAttribute_1 neq 0>,operator_product_attribute_1</cfif>
			)
			SELECT	BFIM.BSA_Foodservice_Items_Master_ID,
					BFIM.Description,
					BFIM.Item,
					BFIM.GTIN,
					PGC.Program_Growth_Component_ID,
					PGCP.Rate,
					PGCT.Growth_Amount,
					PGCN.Program_Growth_Components_Name,
					PGC.Component_Paid_To,
					PGCP.Unit_Of_Measure_ID,
					CASE
					  WHEN PGC.component_UOM = 1 THEN
						'Cases'
					  WHEN PGC.component_UOM = 2 THEN
						'Pounds'
					  WHEN PGC.component_UOM = 3 THEN
						'%'
					  WHEN PGC.component_UOM = 4 THEN ---D35731 Growth Auto Pay
						'$'
					  ELSE
						'Not Supplied'
					  END AS component_UOM_Desc,
					UOM.Abbreviation,
					CASE
						WHEN UOM.Unit_Of_Measure_ID = 2 THEN cast(PGCP.Rate as float)
					ELSE
						cast(PGCP.Rate as float) / cast(BFIM.Net_Weight as float)
					END
						as growth_price_per_pound,
					CASE
						WHEN UOM.Unit_Of_Measure_ID = 2 THEN cast(PGCP.Rate as float) * cast(BFIM.Net_Weight as float)
					ELSE
						cast(PGCP.Rate as float)
					END
						as growth_price_per_case,
					CASE
						WHEN UOM.Unit_Of_Measure_ID = 3 THEN cast(PGCP.Rate as float)
					ELSE
						null
					END
						as growth_price_percent
					<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>,CD.BSA_Foodservice_Customers_ID,##TMP_Unique_Alias_Info.External_Code As Distributor_Product_Number</cfif>
					,PGC.Claim_Mechanics
					,PGCT.Tier_Number
					,PGCT.Range_Start
					,PGCT.Range_End

					<!--- If DistributorProductAttribute_1 Is "Brand" --->
					<cfif arguments.bDistributorProductAttribute_1 eq 1>
					,Brand.Brand_Name

					<!--- If DistributorProductAttribute_1 Is "Pack Size" --->
					<cfelseif arguments.bDistributorProductAttribute_1 eq 2>
					,Case_Count.Case_Count_Desc

					<!--- If DistributorProductAttribute_1 Is "QBrand" --->
					<cfelseif arguments.bDistributorProductAttribute_1 eq 3>
					,Q_Brand_Desc.Q_Brand

					<!--- If DistributorProductAttribute_1 Is "Type_Code" --->
					<cfelseif arguments.bDistributorProductAttribute_1 eq 4>
					,Type_Code_Desc.Type_Code_Desc

					<!--- If DistributorProductAttribute_1 Is "Type_Group" --->
					<cfelseif arguments.bDistributorProductAttribute_1 eq 5>
					,Type_Group_Desc.Type_Group_Desc
					</cfif>

					<!--- If OperatorProductAttribute_1 Is "Brand" --->
					<cfif arguments.bOperatorProductAttribute_1 eq 1>
					,Brand.Brand_Name

					<!--- If OperatorProductAttribute_1 Is "Pack Size" --->
					<cfelseif arguments.bOperatorProductAttribute_1 eq 2>
					,Case_Count.Case_Count_Desc

					<!--- If OperatorProductAttribute_1 Is "QBrand" --->
					<cfelseif arguments.bOperatorProductAttribute_1 eq 3>
					,Q_Brand_Desc.Q_Brand

					<!--- If OperatorProductAttribute_1 Is "Type_Code" --->
					<cfelseif arguments.bOperatorProductAttribute_1 eq 4>
					,Type_Code_Desc.Type_Code_Desc

					<!--- If OperatorProductAttribute_1 Is "Type_Group" --->
					<cfelseif arguments.bOperatorProductAttribute_1 eq 5>
					,Type_Group_Desc.Type_Group_Desc
					</cfif>

				FROM  Contract_Main CM
			INNER JOIN Program_Growth_Components PGC
				ON	 PGC.Program_ID = CM.Contract_Main_ID
				AND	PGC.Deleted = 0
			INNER JOIN Program_Growth_Components_Name PGCN
				ON	PGCN.Program_Growth_Components_Name_Id = PGC.Program_Growth_Components_Name_Id
			INNER JOIN Program_Growth_Component_Tiers PGCT
				ON	PGCT.Program_Growth_Component_ID = PGC.Program_Growth_Component_ID
				AND	PGCT.Deleted = 0
			INNER JOIN Contract_Products CP
				ON	CP.Contract_Main_ID = CM.Contract_Main_ID
				AND	CP.Deleted = 0
			INNER JOIN BSA_Foodservice_Items_Master BFIM
				ON	BFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID

				AND	CP.Product_Type_ID = 4
			<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>
				INNER JOIN contract_distributors CD
				ON CD.contract_main_id = PGC.Program_ID
				AND CD.deleted = 0
				AND CD.Contract_Main_ID =  #PreserveSingleQuotes(arguments.PROGRAM_ID)#
				INNER JOIN BSA_Foodservice_Customers BSAFC
				ON BSAFC.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
				LEFT JOIN ##TMP_Unique_Alias_Info
				ON BSA_Foodservice_Items_Master.Item = ##TMP_Unique_Alias_Info.Item
				AND ##TMP_Unique_Alias_Info.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				AND ##TMP_Unique_Alias_Info.Use_For_Distributor_Payee_Only =
				CASE
					WHEN Program_Rebates_Component.Component_Paid_To <> 1
						THEN 0
				ELSE
					##TMP_Unique_Alias_Info.Use_For_Distributor_Payee_Only
				END
			</cfif>
			INNER JOIN Program_Growth_Component_Product_Data PGCD
				ON	PGCD.Contract_Products_ID = CP.Contract_Products_ID
				AND	PGCD.Program_Growth_Component_ID = PGC.Program_Growth_Component_ID
				AND	PGCD.Deleted = 0
			INNER JOIN Program_Growth_Component_Product_Tier_Data PGCP
				ON	PGCP.Program_Growth_Component_Product_Data_ID = PGCD.Program_Growth_Component_Product_Data_ID
				AND	PGCP.Program_Growth_Component_Tier_ID = PGCT.Program_Growth_Component_Tier_ID
			INNER JOIN Units_of_Measure UOM
				ON UOM.Unit_of_Measure_id = PGCP.Unit_Of_Measure_ID

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Brand" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 1 OR arguments.bOperatorProductAttribute_1 eq 1>
			 LEFT JOIN Brand
			 ON BFIM.Brand_ID = Brand.Brand_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Pack Size" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 2 OR arguments.bOperatorProductAttribute_1 eq 2>
				 LEFT JOIN Case_Count
				 ON BFIM.Case_Count_ID = Case_Count.Case_Count_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "QBrand" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 3 OR arguments.bOperatorProductAttribute_1 eq 3>
			 LEFT JOIN Q_Brand_Desc
			 ON BFIM.Q_Brand_ID = Q_Brand_Desc.Q_Brand_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Type_Code" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 4 OR arguments.bOperatorProductAttribute_1 eq 4>
			 LEFT JOIN Type_Code_Desc
			 ON BFIM.Type_Code_Desc_ID= Type_Code_Desc.Type_Code_Desc_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Type_Group" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 5 OR arguments.bOperatorProductAttribute_1 eq 5>
			 LEFT JOIN Type_Group_Desc
			 ON BFIM.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
			</cfif>

			<!---WHERE CM.Contract_Number LIKE '%1961%'--->
			WHERE CM.Contract_Main_ID  = #PreserveSingleQuotes(arguments.PROGRAM_ID)#
			AND	CM.Deleted = 0
			 <cfif arguments.IncludeInactive eq 0>
				AND BFIM.Active_Code = 'A'
			</cfif>
			<cfif arguments.Dist_ID neq 0 AND len(arguments.Dist_ID) neq 0>
			AND BSAFC.BSA_Foodservice_Customers_ID IN (#ListQualify(arguments.Dist_ID,"'")#)
			</cfif>

			ORDER BY PGCT.Program_Growth_Component_ID,BFIM.Item,PGCT.Tier_Number,PGC.Component_Paid_To
		</cfquery>

		<!--- No need to select data from the temp table and return the data.
		The data from the temp table can be read without any select statements.
		--->

	</cffunction>


	<!--- MODEL New METHOD: getTemplateSettings() FUNCTIONALITY: I retrieve template settings. [begin] --->
	<cffunction name="getTemplateSettings" output="true">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="programId" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qGetTemplateSettings = queryNew('cols')>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfquery name="var_qGetTemplateSettings" datasource="#application.datasource#">
		select operator_letters_required,distributor_letters_required,
			Distributor_Fixed_Pricing,Distributor_Rebate,Distributor_Lumpsum,Distributor_Growth,
			operator_Fixed_Pricing,operator_Rebate,operator_Lumpsum,operator_Growth,
			Distributor_paysto_opr,Distributor_paysto_dis,Operator_paysto_opr,
			Operator_paysto_dis,Operator_Bid_Request,Distributor_Bid_Request,Program_Control_Panel_Options.include_freight_summary,
			Pre_Defined_Page_Break,Distributor_UOM,Operator_UOM,Distributor_Discount_Type,Operator_Discount_Type,Distributor_Component_Name,
			Operator_Component_Name,Distributor_Claim_Mechanism,Operator_Claim_Mechanism,Distributor_Payable_To,Operator_Payable_To,
			Distributor_Pricing_Type,Operator_Pricing_Type,Distributor_Payment_Frequency,Operator_Payment_Frequency,
			Distributor_GTIN,Operator_GTIN,Distributor_Product_Attribute_1,Operator_Product_Attribute_1,Distributor_Price_Brackets,Operator_Price_Brackets,
			Distributor_Open_Date,Operator_Open_Date,Distributor_Date_Needed,Operator_Date_Needed,Distributor_Expected_Date,Operator_Expected_Date,
			Distributor_Est_Value_Volume,Operator_Est_Value_Volume,Distributor_Dist_Product_Codes,
			Distributor_Customer_Acceptance_Block,Operator_Customer_Acceptance_Block,Distributor_Line,Operator_Line,Distributor_Notes,
			Distributor_show_volume_summary,
			Operator_show_volume_summary,
			Distributor_Product_Net_Weight,
			Operator_Product_Net_Weight,
			Operator_Notes,
			Bonus_Field,
			Program_Control_Panel_Options.letters_accepted_by <!---D36100  :: MOVE 'Letters Accepted By text' SETTING TO BE AT THE TEMPLATE LEVEL --->

			from
			contract_main
			inner join
			Program_Control_Panel_Options on
			contract_main.programtype_id = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			where contract_main.contract_main_id = '#arguments.programId#'
		</cfquery>

		<cfreturn var_qGetTemplateSettings />

	</cffunction>
	<!--- MODEL New METHOD: getTemplateSettings() FUNCTIONALITY: I retrieve template settings. [end] --->

	<!--- MODEL New METHOD: letterExistsInDBwithXMLandAsFile() FUNCTIONALITY: I identify IF all necessary 3 parts of a letter exist (db,file,xml)
	for a specified letter. [begin] --->
	<cffunction name="letterExistsInDBwithXMLandAsFile" access="public" output="no" hint="I identify IF all necessary 3 parts of a letter exist (db,file,xml) for a specified letter." returntype="boolean" displayname="Models > Letter > letterExistsInDBwithXMLandAsFile()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_letter_id" required="true" type="numeric" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_letter_path 	= ''>
		<cfset var var_letterXML 	= queryNew('cols')>
		<cfset var var_bLetterExistsInDBwithXMLandAsFile = 0>

	   <cfset var_letter_path = trim(replace(getLetterPath(program_letter_id),'.htm','.pdf','all'))>
	  <!--- Dev Note:29157 (Milan) - No need to load xml and then verify whether it is in XML format. The loading of xml takes a long time as the entire xml
			has to be loaded in memory to verify whether it is a valid xml.
		--->
	   <!--- Dev Note:29157 (Milan) - Now, "updateLetterXML" checks for data in xml format before inserting into the db --->
	   <!---<cfset var_letterXML = trim(getLetterXML(program_letter_id))>--->

	  <cfif fileExists(var_letter_path)><!---AND isXML(trim(var_letterXML))--->
			<cfset var_bLetterExistsInDBwithXMLandAsFile = 1>
	  </cfif>

		<!--- Return the final container to the caller --->
		<cfreturn var_bLetterExistsInDBwithXMLandAsFile>

	</cffunction>
	<!--- MODEL New METHOD: letterExistsInDBwithXMLandAsFile() FUNCTIONALITY: I identify IF all necessary 3 parts of a letter exist (db,file,xml)
	for a specified letter. [begin] --->

	<!--- MODEL Legacy METHOD: saveLetterSettings() FUNCTIONALITY: I save letter settings to the DB. [begin] --->
	<cffunction name="saveLetterSettings" access="public" output="no" hint="I save letter settings to the DB." returntype="void" displayname="Model > Letter > saveLetterSettings()">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_id" 	required="true" type="numeric" />
		<cfargument name="formScope" 	required="true" type="struct" />
		<cfargument name="user_id" 		required="true" type="string" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qDeleteLetterSettings 	= queryNew('cols')>
		<cfset var var_qInsertLetterSettings 	= queryNew('cols')>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfset useLakebaseForvar_qDeleteLetterSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters_settings")>
<cfif useLakebaseForvar_qDeleteLetterSettings>
	<cftry>
		<cfset application.oLakebase.updateRows("program_letters_settings",
			{
				"program_id" = "eq.#arguments.program_id#",
				"deleted" = "eq.0
			 
			--",
				"user_id" = "eq.#arguments.user_id#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvar_qDeleteLetterSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvar_qDeleteLetterSettings>
<cfquery name="var_qDeleteLetterSettings" datasource="#application.datasource#">
			UPDATE 	Program_Letters_Settings
			set 	deleted = 1
			where 	Program_id = '#arguments.program_id#'
			and		deleted = 0
			<!----- DRK: D10886 - Operator Letter - Not generating letter based on latest form selections
			Program_Letters_Settings table will no longer be based on user
			Even though we will keep inserting user info, to keep track of who generated the letters.
			----->
			-- and 	user_id = '#arguments.user_id#'
		</cfquery>
</cfif>

		<!--- MVC: Looks like we can't use cfqueryparam here? --->
		<cfset useLakebaseForvar_qInsertLetterSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters_settings")>
<cfif useLakebaseForvar_qInsertLetterSettings>
	<cftry>
		<cfset application.oLakebase.insertRow("program_letters_settings", {
			"program_id" = "#arguments.program_id#",
			"letter_type" = "#Evaluate("arguments.formScope.Letter_Type")#",
			"operator_letter_type" = "#evaluate("arguments.formScope.Operator_Letter_Type")#",
			"distributor_letter_type" = "#Evaluate("arguments.formScope.Distributor_Letter_TYpe")#",
			"opr_letter_settings" = "#evaluate("arguments.formScope.Opr_Letter_Settings")#",
			"dis_letter_settings" = "#Evaluate("arguments.formScope.Dis_Letter_Settings")#",
			"notification_type" = "#evaluate("arguments.formScope.notification_type")#",
			"addcustomerproductnumbers" = "#evaluate(formscope.Addcustomerproductnumbers)#",
			"user_id" = "#arguments.user_id#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForvar_qInsertLetterSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvar_qInsertLetterSettings>
<cfquery name="var_qInsertLetterSettings" datasource="#application.datasource#">
			INSERT INTO	Program_Letters_Settings
			(Program_id,Letter_Type,Operator_Letter_Type,Distributor_Letter_Type,
			Opr_Letter_Settings,Dis_Letter_Settings,Notification_type,Addcustomerproductnumbers,user_id)
			values
			(#arguments.program_id#,#Evaluate("arguments.formScope.Letter_Type")#,
			#evaluate("arguments.formScope.Operator_Letter_Type")#,#Evaluate("arguments.formScope.Distributor_Letter_TYpe")#,
			#evaluate("arguments.formScope.Opr_Letter_Settings")#,#Evaluate("arguments.formScope.Dis_Letter_Settings")#,
			#evaluate("arguments.formScope.notification_type")#,#evaluate(formscope.Addcustomerproductnumbers)#,'#arguments.user_id#')
		</cfquery>
</cfif>

	</cffunction>
	<!--- MODEL Legacy METHOD: saveLetterSettings() FUNCTIONALITY: I save letter settings to the DB. [end] --->

	<!--- MODEL Legacy METHOD: updateLetterXML() FUNCTIONALITY: I update the XML for a specified letter in the program_letters table in the DB. [begin] --->
	<cffunction name="updateLetterXML" access="public" output="no" hint="I update the XML for a specified letter in the program_letters table in the DB." returntype="void">

		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
		<cfargument name="program_letter_id" required="true" type="numeric" />
		<cfargument name="sProgramLetterXML" required="true" type="string" />

		<!--- MVC: We MUST var all variables local to method! --->
		<cfset var var_qUpdateLetterXML 	= ''>

		<cftry>

		<!--- MVC: Please try to use cfqueryparam where we can --->
		<!--- Dev Note: 29157 (Milan) - Earlier, the "letterExistsInDBwithXMLandAsFile" used to load xml to check whether the data
			  is in xml format, but now we add (cast as xml) code here, so that we do not have to load xml later for verification.
		 --->
		<cfquery name="var_qUpdateLetterXML" datasource="#application.datasource#">
			UPDATE	Program_Letters
			SET 	Letter_xml = CAST('#trim(arguments.sProgramLetterXML)#' As xml)
			WHERE 	Program_Letters_ID = <cfqueryparam value="#arguments.program_letter_id#" cfsqltype="cf_sql_integer">
		</cfquery>


				<!--- Dev Note: 29157 (Milan) - IF we have an 'error', delete the letter and xml data of the letter --->
				<cfcatch type="any">
					<cfscript>
						application.oLetterManager.deletePDFLetterInDBandFile(arguments.program_letter_id);
					</cfscript>
				</cfcatch>
		</cftry>

		<!--- Return the final container to the caller --->
		<!--- na  --->

	</cffunction>
	<!--- MODEL Legacy METHOD: updateLetterXML() FUNCTIONALITY: I update the XML for a specified letter in the program_letters table in the DB. [end] --->

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::
	:::::::::::: LetterManager Methods in alpha  :::::::::
	::::::::::::::::::::::::::::::::::::::::::: [end] --->


	<!--- Check whether the letter on the program has any discount types, where the "paid to"
	is operator or distributor, depending on the letter type - operator or distributor.
	--->
	<cffunction name="fnDiscountTypes" returntype="string" output="true">
	<cfargument name="letterType" type="numeric"> <!--- letterType 1=operator; 2=distributor --->
	<cfargument name="Contract_Main_ID" type="numeric">

	<cfquery name="vars.qDiscountTypes" datasource="#application.datasource#">
		WITH Discounts (Discount_Type_Id) as
		(
			SELECT 1 <!--- Fixed --->
			FROM Program_Fixed_Component F
			WHERE F.Deleted = 0
				AND F.Program_ID = <cfqueryparam value = "#arguments.Contract_Main_ID#" cfsqltype = "cf_sql_integer">
				AND F.Fixed_Component_Paid_To IN <cfif arguments.letterType eq 1> (2, 4) <cfelse> (1, 4) </cfif>

			UNION
			SELECT 2 <!--- Rebates --->
			FROM Program_Rebates_Component R
			WHERE R.Deleted = 0
				AND R.Program_ID =  <cfqueryparam value = "#arguments.Contract_Main_ID#" cfsqltype = "cf_sql_integer">
				AND R.Component_Paid_To IN <cfif arguments.letterType eq 1> (2, 4) <cfelse> (1, 4) </cfif>

			UNION
			SELECT 3 <!--- Lump sums --->
			FROM Program_Lump_Sums L
			WHERE L.Deleted = 0
				AND L.Program_ID =  <cfqueryparam value = "#arguments.Contract_Main_ID#" cfsqltype = "cf_sql_integer">
				AND L.Component_Paid_To IN <cfif arguments.letterType eq 1> (2, 4) <cfelse> (1, 4) </cfif>

			UNION
			SELECT 4 <!--- Growth --->
			FROM Program_Growth_Components G
			WHERE G.Deleted = 0
				AND G.Program_ID =  <cfqueryparam value = "#arguments.Contract_Main_ID#" cfsqltype = "cf_sql_integer">
				AND G.Component_Paid_To IN <cfif arguments.letterType eq 1> (2, 4) <cfelse> (1, 4) </cfif>
		)
		SELECT dt.Discount_Type_desc
		FROM Discounts d
		INNER JOIN Discount_Type dt
			ON dt.Discount_Type_Id = d.Discount_Type_Id
				AND dt.Deleted = 0
	</cfquery>

	<cfset discountTypesList = valueList(vars.qDiscountTypes.Discount_Type_desc, ", ")/>
	<cfreturn discountTypesList />
</cffunction>


<cffunction name="getLetterEmailLogExist" access="public" output="no" returntype="boolean">
	<cfargument name="program_letter_id" required="true" type="numeric" />

		<cfset var bLetterEmailLogExist = 0>

		<cfset useLakebaseForqgetLetterEmailLogExist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("message_log")>
<cfif useLakebaseForqgetLetterEmailLogExist>
	<cftry>
		<cfset qgetLetterEmailLogExist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("message_log", {
				"app_area_sub_identifier" = "eq.#arguments.program_letter_id#",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetLetterEmailLogExist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetLetterEmailLogExist>
<cfquery name="qgetLetterEmailLogExist" datasource="#application.datasource#">
			SELECT	1
			FROM	message_log
			WHERE	App_Area_Sub_Identifier = '#arguments.program_letter_id#'
		</cfquery>
</cfif>

		<cfif qgetLetterEmailLogExist.recordcount>
			<cfset bLetterEmailLogExist = 1>
		</cfif>

		<cfreturn bLetterEmailLogExist>
</cffunction>

<cffunction name="getProgramProductGroupMembers" access="public" output="false" returntype="query">
	<cfargument name="programId" required="true" type="numeric" />

	<cfquery name="qgetProgramProductGroupMembers" datasource="#application.datasource#">
		SELECT DISTINCT cp.Pricing_Level_ID,
				grp.Group_Desc,
				IsNull(bfim.Item,'N/A') As Item,
				IsNull(bfim.Description,'N/A') As Description
		FROM Contract_products cp
		INNER JOIN All_Product_Group_Types grp
		ON grp.Group_GUID = cp.BSA_Foodservice_Items_Master_ID
		LEFT JOIN Contract_Products mem
		ON	mem.Contract_Main_ID = cp.Contract_Main_ID
		AND	mem.Product_Group_ID = cp.Product_Group_ID
		AND	mem.Product_Type_ID = cp.Product_Type_ID
		AND	mem.Captured_From_Group = 1
		AND	mem.Deleted = 0
		LEFT JOIN BSA_Foodservice_Items_Master bfim
		ON bfim.BSA_Foodservice_Items_Master_ID = mem.BSA_Foodservice_Items_Master_ID
		WHERE cp.contract_main_id = '#arguments.programId#'
		and  cp.Deleted = 0
		and  cp.Is_Group = 1
		ORDER BY cp.Pricing_Level_ID, Item
	</cfquery>

	<cfreturn qgetProgramProductGroupMembers>
</cffunction>

</cfcomponent>