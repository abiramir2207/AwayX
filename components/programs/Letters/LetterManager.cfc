<!--- 
FILE: 		BA Application - Model: LetterManager Component	
FILEname:   LetterManager.cfc											
CREATED:  	5/09/2008 - Brad Lee MMCP/ACI
EDITED:   	10/29/2008 - Brad Lee MMCP/ACI [17386]

FUNCTIONALITY: 
- ALL Letters are generated and managed by this object --->

<!--- COLDFUSION COMPONENT: LetterManager --->
<cfcomponent displayname="LetterManager" hint="I am the Letter Manager.">

	<!--- METHOD: deleteAllProgramPDFLettersInDBandFile [begin] --->
	<cffunction name="deleteAllProgramPDFLettersInDBandFile" output="false">
    
		<cfargument name="program_id" required="true" type="numeric" />
        
        <cfset var var_qProgramLetters 	= ''>

		<cfquery name="var_qProgramLetters" datasource="#application.datasource#">
			SELECT 	Program_Letters_ID
            FROM 	program_letters
			WHERE 	Program_ID = #trim(arguments.program_id)#
		</cfquery>
        	
        <cfloop query="var_qProgramLetters">
        	<cfscript>
        		deletePDFLetterInDBandFile(var_qProgramLetters.Program_Letters_ID);
			</cfscript>
        </cfloop>
        
	</cffunction>
    <!--- METHOD: deleteAllProgramPDFLettersInDBandFile [end] --->

	<!--- METHOD: deleteLetters [begin] --->
	<cffunction name="deleteLetters" output="false">
    
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="letter_type" required="true" type="numeric" />
        
		<cfquery name="qdeleteLetters" datasource="#application.datasource#">
			update program_letters
			set deleted = 1
			where program_id =  '#arguments.program_id#'
			and letter_type =  '#arguments.letter_type#'
		</cfquery>
        
	</cffunction>
    <!--- METHOD: deleteLetters [end] --->

	<!--- METHOD: deletePDFLetterInDBandFile [begin] --->
	<cffunction name="deletePDFLetterInDBandFile" output="false">
    
		<cfargument name="program_letter_id" required="true" type="numeric" />
        
        <cfset var var_letter_path 		= ''>
        <cfset var var_qDeleteLetter 	= ''>
        
        <cfset var_letter_path = replace(getLetterPath(program_letter_id),'.htm','.pdf','all')>

		<cfif len(trim(var_letter_path)) AND fileExists(var_letter_path)>
        	<cffile action="delete" file="#var_letter_path#">
        </cfif>

		<cfquery name="var_qDeleteLetter" datasource="#application.datasource#">
			DELETE 	FROM program_letters
			WHERE 	Program_Letters_ID = #trim(arguments.program_letter_id)#
		</cfquery>
        
	</cffunction>
    <!--- METHOD: deletePDFLetterInDBandFile [end] --->

	<!--- D16774 --->
	<!--- METHOD: getAllLetterInfo [begin] I return all row information for a specified letter. --->
	<cffunction name="getAllLetterInfo" output="false" displayname="getAllLetterInfo" hint="I return all row information for a specified letter.">
    
		<cfargument name="program_letter_id" required="true" type="numeric" />
        
        <cfset var var_qAllLetterInfo = queryNew('cols')>

		<cftry>

            <cfquery name="var_qAllLetterInfo" datasource="#application.datasource#">
              SELECT	*
              FROM		Program_Letters
              WHERE 	Program_Letters.Program_Letters_ID = #arguments.program_letter_id#
            </cfquery>
            
            <cfreturn var_qAllLetterInfo>
        
            <cfcatch>
            
            	<!--- return false to caller --->
                <cfreturn 0>
            
            </cfcatch>
        
        </cftry>
        
	</cffunction>
	<!--- METHOD: getAllLetterInfo [end] --->

	<!--- METHOD: getBasePrice [begin] --->
    <cffunction name="getBASEPRICE" output="false">
    
        <cfargument name="program_id" required="true" type="STRING" />
        
        <cfset useLakebaseForqgetBASEPRICE = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_product_margin")>
<cfif useLakebaseForqgetBASEPRICE>
	<cftry>
		<cfset qgetBASEPRICE = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_product_margin", {
				"contract_main_id" = "eq.#ARGUMENTS.program_id#",
				"deleted" = "eq.0",
				"select" = "base_sales_cs,base_sales_lb,product_id"
			}), "base_sales_cs,base_sales_lb,product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetBASEPRICE = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetBASEPRICE>
<cfquery name="qgetBASEPRICE" datasource="#application.datasource#">
            select base_sales_cs,base_sales_lb,product_id
            from contract_product_margin
            where contract_main_id = '#ARGUMENTS.program_id#'
            and deleted = 0
        </cfquery>
</cfif>
        
        <cfreturn QgetBASEPRICE />
	
	</cffunction>
    <!--- METHOD: getBasePrice [end] --->

	<!--- METHOD: getBidRequestProducts [begin] --->
	<cffunction name="getBidRequestProducts" output="false">
    
		<cfargument name="program_id" required="true" type="STRING" />
        
        <cfquery name="qgetBidRequestProducts" datasource="#application.datasource#">
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

	<cfreturn qgetBidRequestProducts />
    
	</cffunction>
    <!--- METHOD: getBidRequestProducts [end] --->

	<!--- METHOD: getDistributorDetails [begin] --->
	<cffunction name="getdistributordetails" output="false">
    
		<cfargument name="program_id" required="true" type="numeric" />
        
		<cfquery name="qgetdistributordetails" datasource="#application.datasource#">
			select BSA_Foodservice_Customers.Name,BSA_Foodservice_Customers.shr_ship_to,
			BSA_Foodservice_Customers.BSA_Foodservice_Customers_id
			from
			Contract_Distributors
			inner join BSA_Foodservice_Customers
			ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_id = 
			Contract_Distributors.BSA_Foodservice_Customers_id
			where contract_main_id = '#arguments.program_id#'
			and Contract_Distributors.deleted = 0
		</cfquery>
        
		<cfreturn qgetdistributordetails />
        
	</cffunction>
    <!--- METHOD: getDistributorDetails [end] --->

	<!--- METHOD: getDistributorEmail [begin] --->
	<cffunction name="getdistributoremail" output="false">
    
		<cfargument name="program_id" required="true" type="numeric" />
        
		<cfquery name="qgetdistributoremail" datasource="#application.datasource#">
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
        
		<cfreturn qgetdistributoremail />
        
	</cffunction>
    <!--- METHOD: getDistributorEmail [end] --->

	<!--- METHOD: getFixedPriceProducts [begin] --->
	<cffunction name="getFixedPriceProducts" output="false">
    
		<cfargument name="program_id" required="true" type="STRING" />
        
		<cfquery name="qgetFixedPriceProducts" datasource="#application.datasource#">
			SELECT    distinct BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description, 
						Program_Fixed_Price_Product_Data.Fixed_Price_Value, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_id,
						 Units_of_Measure.Abbreviation,Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID,
						Contract_Products.Contract_Main_ID,
						Program_Fixed_Component_Name.Program_Fixed_Component_Name,
						Program_Fixed_Component.Program_Fixed_Component_ID
						,Contract_Main.Contract_Start_date,Contract_Main.Contract_end_date
						,Contract_Main.Contract_Main_ID 
						,IsExclusionRevision,Fixed_Component_Paid_to
			FROM         Contract_Products 
						INNER JOIN	BSA_Foodservice_Items_Master 
						ON 
						Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
						INNER JOIN	Program_Fixed_Price_Product_Data 
						ON 
						Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID 
						INNER JOIN	Units_of_Measure 
						ON Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID = Units_of_Measure.Unit_Of_Measure_ID
						LEFT JOIN Program_Fixed_Component 
						ON Program_Fixed_Component.Program_Fixed_Component_Id = Program_Fixed_Price_Product_Data.Program_Fixed_Component_Id
						AND Program_Fixed_Component.DELETED = 0
						
						LEFT JOIN Program_Fixed_Component_Name 
						On Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id = Program_Fixed_Component.Program_Fixed_Component_Name_Id
						INNER JOIN 	Contract_Main 
						ON Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
			WHERE       Contract_Products.Deleted = 0 AND Program_Fixed_Price_Product_Data.Deleted = 0  
						--AND Contract_Main.deleted =0 
						AND Contract_Products.Product_Type_ID = 1
					  AND Contract_Products.Contract_Main_ID IN (#PreserveSingleQuotes(arguments.PROGRAM_ID)#)
						and ISNULL(cast(Program_Fixed_Price_Product_Data.Fixed_Price_Value as float),0) ! = 0	
			ORDER BY Program_Fixed_Component.Program_Fixed_Component_Id,contract_main.contract_main_id,Fixed_Component_Paid_to,BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description		
		</cfquery>
        
		<cfreturn qgetFixedPriceProducts />
        
	</cffunction>
    <!--- METHOD: getFixedPriceProducts [end] --->

	<!--- D16774 --->
	<!--- METHOD: getLastLetterID [begin] I return the last letter ID in the program_letters table. --->
	<cffunction name="getLastLetterID" output="false" displayname="getLastLetterID" hint="I return the last letter ID in the program_letters table.">
        
        <cfset var var_qGetLastLetterID = queryNew('cols')>
        <cfset var var_lastLetterID = 0>

		<cftry>

            <cfquery name="var_qGetLastLetterID" datasource="#application.datasource#">
              	SELECT  	MAX(Program_Letters_ID) AS lastLetterID
                FROM 		Program_Letters
                WHERE		deleted = 0
            </cfquery>
            
            <cfif var_qGetLastLetterID.recordCount EQ 1 AND var_qGetLastLetterID.lastLetterID[1]>
            
            	<cfset var_lastLetterID = var_qGetLastLetterID.lastLetterID[1]>
                
            </cfif>
            
            <cfreturn var_lastLetterID>
        
            <cfcatch>
            
            	<!--- return false to caller --->
                <cfreturn 0>
            
            </cfcatch>
        
        </cftry>
        
	</cffunction>
	<!--- METHOD: getLastLetterID [end] --->

	<!--- D16774 --->
	<!--- METHOD: getLetterPath [begin] I return the letter PATH for a specified letter. --->
	<cffunction name="getLetterPath" output="false" displayname="getLetterPath" hint="I return the letter PATH for a specified letter.">
    
		<cfargument name="program_letter_id" required="true" type="numeric" />
        
        <cfset var var_qLetterPath = queryNew('cols')>
        <cfset var var_letterPath = ''>

		<cftry>

            <cfquery name="var_qLetterPath" datasource="#application.datasource#">
              SELECT	letter_path
              FROM		Program_Letters
              WHERE 	Program_Letters.Program_Letters_ID = #arguments.program_letter_id#
            </cfquery>
            
            <cfif var_qLetterPath.recordCount EQ 1 AND len(trim(var_qLetterPath.letter_path[1]))>
            
            	<cfset var_letterPath = trim(var_qLetterPath.letter_path[1])>
                
            </cfif>
            
            <cfreturn var_letterPath>
        
            <cfcatch>
            
            	<!--- return false to caller --->
                <cfreturn 0>
            
            </cfcatch>
        
        </cftry>
        
	</cffunction>
	<!--- METHOD: getLetterPath [end] --->

	<!--- METHOD: getLetters [begin] --->
	<cffunction name="getLetters" output="false">
    
		<cfargument name="program_id" 		required="true" 	type="numeric" />
		<cfargument name="letter_type" 		required="true" 	type="numeric" />
        <cfargument name="order_by_clause" 	required="false" 	type="string" 	default="created_date DESC"/>
        
        <cfset var var_qLetters = queryNew('cols')>
        
        <cftry>
        
            <cfquery name="var_qLetters" datasource="#application.datasource#">
                SELECT 	program_letters.*, _users.name_first + ' ' + name_last as user_name
                FROM	program_letters
                INNER JOIN _users on _users.user_id = program_letters.created_by
                WHERE program_id =  '#arguments.program_id#'
                AND letter_type =  '#arguments.letter_type#'
                AND program_letters.deleted = 0
                ORDER BY #arguments.order_by_clause#
            </cfquery>
            
            <cfreturn var_qLetters />
            
            <cfcatch>
            
            	<!--- return false to caller --->
                <cfreturn 0>
            
            </cfcatch>
        
        </cftry>
        
	</cffunction>
    <!--- METHOD: getLetters [end] --->

	<!--- METHOD: getLetterSettings [begin] --->
	<cffunction name="getLetterSettings" output="false">
    
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="user_id" required="true" type="string" />
        
		<cfquery name="qgetLetterSettings" datasource="#application.datasource#">
			select 	* 
			from	Program_Letters_Settings
			where 	program_id = '#arguments.program_id#'
			<!---TSF: 10242 - Removing user_id from the where clause so that any user can view the letters--->
			-- and 	user_id = '#arguments.user_id#'
			and 	deleted = 0
		</cfquery>
        
		<cfreturn qgetLetterSettings />
        
	</cffunction>
    <!--- METHOD: getLetterSettings [end] --->

	<!--- D16774 --->
	<!--- METHOD: getLetterXML [begin] I return a specified letter's XML dna. --->
	<cffunction name="getLetterXML" output="false" displayname="getLetterXML" hint="I return a specified letter's XML dna.">
    
		<cfargument name="program_letter_id" required="true" type="numeric" />
        
        <cfset var var_qLetterXML = queryNew('cols')>
        <cfset var var_xLetterXML = ''>

		<cftry>

            <cfset useLakebaseForvar_qLetterXML = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters")>
<cfif useLakebaseForvar_qLetterXML>
	<cftry>
		<cfset var_qLetterXML = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_letters", {
				"program_letters_id" = "eq.#arguments.program_letter_id#",
				"select" = "letter_xml"
			}), "letter_xml"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvar_qLetterXML = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvar_qLetterXML>
<cfquery name="var_qLetterXML" datasource="#application.datasource#">
              SELECT	Letter_xml
              FROM		Program_Letters
              WHERE 	Program_Letters.Program_Letters_ID = #arguments.program_letter_id#
            </cfquery>
</cfif>
            
            <cfif var_qLetterXML.recordCount EQ 1 AND len(trim(var_qLetterXML.Letter_xml[1]))>
            
            	<cfset var_xLetterXML = trim(var_qLetterXML.Letter_xml[1])>
                
            </cfif>
            
            <cfreturn var_xLetterXML>
        
            <cfcatch>
            
            	<!--- return false to caller --->
                <cfreturn 0>
            
            </cfcatch>
        
        </cftry>
        
	</cffunction>
	<!--- METHOD: getLetterXML [end] --->

	<!--- METHOD: getLumpSums [begin] --->
	<cffunction name="getlumpsums" output="false">
    
		<cfargument name="program_id" required="true" type="STRING" />
        
        <cfquery name="qgetlumpsums" datasource="#application.datasource#">
        	SELECT 	Program_Lump_Sums.*, Program_Lump_Sum_Name.Program_Lump_Sum_Name, Program_Lump_Sum_Name.External_ID
                    ,Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date, Contract_Main.IsExclusionRevision
            FROM 	Program_Lump_Sums
                    INNER JOIN Program_Lump_Sum_Name
                    ON 
                    Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
                    INNER JOIN 	Contract_Main 
                    ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
            WHERE 	Program_ID IN (#PreserveSingleQuotes(arguments.PROGRAM_ID)#)	
        
                    AND Program_Lump_Sums.Deleted = 0
            ORDER BY Program_Lump_Sums.Program_ID,Lump_Sum_Amount
        </cfquery>
        
		<cfreturn qgetlumpsums />
        
	</cffunction>
    <!--- METHOD: getLumpSums [end] --->

	<!--- METHOD: getOperatorDetails [begin] --->
	<cffunction name="getoperatordetails" output="false">
    
		<cfargument name="program_id" required="true" type="numeric" />
        
		<cfquery name="qgetoperatordetails" datasource="#application.datasource#">
			select BSA_Operator.BSA_Operator_ID,Operator_Name
			from
			contract_operators
			inner join BSA_Operator
			ON BSA_Operator.BSA_Operator_ID = contract_operators.BSA_Operator_ID
			where contract_main_id = '#arguments.program_id#'
			and contract_operators.deleted = 0
		</cfquery>
        
		<cfreturn qgetoperatordetails />
        
	</cffunction>
    <!--- METHOD: getOperatorDetails [end] --->

	<!--- METHOD: getProgramDetails [begin] --->
	<cffunction name="getprogramdetails" output="false">
    
		<cfargument name="program_id" required="true" type="numeric" />
        
		<cfquery name="qgetprogramdetails" datasource="#application.datasource#">
			select payment_cycle,contract_main_id,contract_number,contract_start_date,contract_end_date,dbo.Program_Control_Panel_Options.Generic_Type,
			Discount_Fixed_Prices,Discount_Rebates,Discount_Lump_Sums,Discount_Growth,Date_Exclusions_ON,
_users.name_first, _users.name_last,_users.title,revision_version,paymentcycle,Program_Control_Panel_Options.BidRequestStatusOn
			from contract_main
			inner join Program_Control_Panel_Options
			ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
inner join _users on _users.user_id = Contract_Main.Responsible_User_ID
			left join payment_cycle on payment_cycle.payment_cycle_id = contract_main.paymentcycle
			where contract_main_id = '#arguments.program_id#'
		</cfquery>
        
		<cfreturn qgetprogramdetails />
        
	</cffunction>
    <!--- METHOD: getProgramDetails [end] --->

	<!--- METHOD: getRebateProducts [begin] --->
    <cffunction name="getRebateProducts" output="false">
    
        <cfargument name="program_id" required="true" type="STRING" />
        
        <cfquery name="qInsertRebateProducts" datasource="#application.datasource#">	
		if object_id('tempdb..##TMP_Rebate_Price_Details') is not null
		drop table ##TMP_Rebate_Price_Details

		CREATE TABLE ##TMP_Rebate_Price_Details(
			BSA_Foodservice_Items_Master_ID varchar(50),
			description nvarchar(255),
			Item nvarchar(50),
			Program_Rebates_Component_ID int,
			rate float,
			contract_start_date datetime,
			contract_end_date datetime,
			Program_Rebates_Component_Name [nvarchar](50),
			IsExclusionRevision bit,
			Component_Paid_to int,
			Unit_Of_Measure_ID tinyint,
			Abbreviation char(10),
			rebate_price_per_pound [nvarchar](100),
			rebate_price_per_case [nvarchar](100),
			customer_product_number [nvarchar](50)
		)

		CREATE CLUSTERED  INDEX [I_Rebate_Price_Details_tmp] ON [##TMP_Rebate_Price_Details]([Program_Rebates_Component_ID],[Item]) ON [PRIMARY]
		
			INSERT INTO ##TMP_Rebate_Price_Details
			(
			BSA_Foodservice_Items_Master_ID,description,Item,Program_Rebates_Component_ID,rate,contract_start_date,contract_end_date,
			Program_Rebates_Component_Name,IsExclusionRevision,Component_Paid_to,Unit_Of_Measure_ID,Abbreviation,rebate_price_per_pound,
			rebate_price_per_case
			)
            select distinct BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,description,
            BSA_Foodservice_Items_Master.Item,Program_Rebates_Component_Data.Program_Rebates_Component_ID,
            cast(Program_Rebates_Component_Data.rate as float) as rate
            ,Contract_Main.contract_start_date, Contract_Main.contract_end_date,Program_Rebates_Component_Name.Program_Rebates_Component_Name,
            IsExclusionRevision,Component_Paid_to,Program_Rebates_Component_Data.Unit_Of_Measure_ID
            ,Units_of_Measure.Abbreviation,
            CASE 
            WHEN Units_of_Measure.Unit_Of_Measure_ID = 2 THEN cast(Program_Rebates_Component_Data.rate as float)
            ELSE cast(Program_Rebates_Component_Data.rate as float) / cast(BSA_Foodservice_Items_Master.Net_Weight as float)
            END as rebate_price_per_pound,
            CASE 
            WHEN Units_of_Measure.Unit_Of_Measure_ID = 2 THEN cast(Program_Rebates_Component_Data.rate as float) * cast(BSA_Foodservice_Items_Master.Net_Weight as float)
            ELSE cast(Program_Rebates_Component_Data.rate as float)
            END as rebate_price_per_case
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
            Units_of_Measure.Unit_of_Measure_id = Program_Rebates_Component_Data.Unit_Of_Measure_ID
            inner join
            Contract_Products ON
            Contract_Products.Contract_Products_ID = Program_Rebates_Product_Data.Contract_Products_ID
            AND Contract_Products.Deleted = 0
            and Contract_Products.contract_main_id = Program_Rebates_Product_Data.program_id
                            AND 
                            (
                                
                                (Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
                                OR
                                
                                (ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
                            ) 
                            
            INNER JOIN BSA_Foodservice_Items_Master ON
            BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
                            
            INNER JOIN Contract_Main
            ON Contract_Main.Contract_Main_ID = Contract_Products.Contract_Main_ID
            WHERE 	Program_Rebates_Product_Data.Program_ID IN (#PreserveSingleQuotes(arguments.PROGRAM_ID)#)
            AND		Program_Rebates_Product_Data.Deleted = 0
            ORDER BY Program_Rebates_Component_Data.Program_Rebates_Component_ID,Component_Paid_to,item
        </cfquery>

		<CFQUERY NAME="qgetRebateProducts" datasource="#application.datasource#">
			SELECT * 
			FROM ##TMP_Rebate_Price_Details
		</CFQUERY>
       
        <cfreturn qgetRebateProducts />
    
    </cffunction>
    <!--- METHOD: getRebateProducts [end] --->

	<!--- METHOD: getTemplateSettings [begin] --->
    <!--- D16586 RBL added Program_Control_Panel_Options.include_freight_summary --->
	<cffunction name="gettemplatesettings" output="true">
    
		<cfargument name="programId" required="true" type="numeric" />
        
			<cfquery name="qgettemplatesettings" datasource="#application.datasource#">
				select operator_letters_required,distributor_letters_required,
				Distributor_Fixed_Pricing,Distributor_Rebate,Distributor_Lumpsum,Distributor_Growth,
				operator_Fixed_Pricing,operator_Rebate,operator_Lumpsum,operator_Growth,
				Distributor_paysto_opr,Distributor_paysto_dis,Operator_paysto_opr,
				Operator_paysto_dis,Operator_Bid_Request,Distributor_Bid_Request,Program_Control_Panel_Options.include_freight_summary
				
				from
				contract_main
				inner join 
				Program_Control_Panel_Options on
				contract_main.programtype_id = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
				where contract_main.contract_main_id = '#arguments.programId#'
			</cfquery>
            
		<cfreturn qgettemplatesettings />
        
	</cffunction>
    <!--- METHOD: getTemplateSettings [end] --->

	<!--- METHOD: letterExistsInDBwithXMLandAsFile [begin] --->
	<cffunction name="letterExistsInDBwithXMLandAsFile" output="false" returntype="boolean">
    
		<cfargument name="program_letter_id" required="true" type="numeric" />
        
        <cfset var var_letter_path 	= ''>
        <cfset var var_letterXML 	= queryNew('cols')>
        <cfset var var_bLetterExistsInDBwithXMLandAsFile = 0>
        
        <cftry>
        
			<cfset var_letter_path = trim(replace(getLetterPath(program_letter_id),'.htm','.pdf','all'))>
				
            <cfset var_letterXML = trim(getLetterXML(program_letter_id))>

            <cfif fileExists(var_letter_path) AND isXML(trim(var_letterXML))>	
                <cfset var_bLetterExistsInDBwithXMLandAsFile = 1>
            </cfif>

            <cfreturn var_bLetterExistsInDBwithXMLandAsFile>
            
            <cfcatch>
            
            	<!--- return false to caller --->
                <cfreturn 0>
            
            </cfcatch>
        
        </cftry>

	</cffunction>
    <!--- METHOD: letterExistsInDBwithXMLandAsFile [end] --->

	<!--- METHOD: saveLetterSettings [begin] --->
	<cffunction name="saveLetterSettings" output="false">
    
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="formScope" required="true" type="struct" />
		<cfargument name="user_id" required="true" type="string" />
        
		<cfquery name="qDeleteLetterSettings" datasource="#application.datasource#">
			update 	Program_Letters_Settings
			set 	deleted = 1
			where 	Program_id = '#arguments.program_id#'
			and		deleted = 0
			<!----- DRK: D10886 - Operator Letter - Not generating letter based on latest form selections
			Program_Letters_Settings table will no longer be based on user
			Even though we will keep inserting user info, to keep track of who generated the letters.
			----->
			-- and 	user_id = '#arguments.user_id#'
		</cfquery>
	
        <cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
            INSERT INTO	Program_Letters_Settings
            (Program_id,Letter_Type,Operator_Letter_Type,Distributor_Letter_Type,
            Opr_Letter_Settings,Dis_Letter_Settings,Notification_type,Addcustomerproductnumbers,user_id)
            values
            (#arguments.program_id#,#Evaluate("arguments.formScope.Letter_Type")#,
            #Evaluate("arguments.formScope.Operator_Letter_Type")#,#Evaluate("arguments.formScope.Distributor_Letter_TYpe")#,
            #Evaluate("arguments.formScope.Opr_Letter_Settings")#,#Evaluate("arguments.formScope.Dis_Letter_Settings")#,
            #Evaluate("arguments.formScope.notification_type")#,#evaluate(formscope.Addcustomerproductnumbers)#,'#arguments.user_id#')
        </cfquery>
	</cffunction>
	<!--- METHOD: saveLetterSettings [end] --->
    
    <!--- D16774 --->
	<!--- METHOD: updateLetterXML [begin] I update the XML for an edited program letter. --->
	<cffunction name="updateLetterXML" output="false" displayname="updateLetterXML" hint="I update the XML for an edited program letter." returntype="void">

		<cfargument name="program_letter_id" required="true" type="numeric" />
        <cfargument name="sProgramLetterXML" required="true" type="string" />
                
        <cfset var var_qUpdateLetterXML 	= ''>

		<cftry>

            <cfquery name="var_qUpdateLetterXML" datasource="#application.datasource#">
              	UPDATE	Program_Letters
                SET 	Letter_xml = '#trim(arguments.sProgramLetterXML)#'
                WHERE 	Program_Letters_ID = #arguments.program_letter_id#
            </cfquery>

            <cfcatch>
            
            	<!--- return false to caller --->
                <cfreturn 0>
            
            </cfcatch>
        
        </cftry>
        
	</cffunction>
	<!--- METHOD: updateLetterXML [end] --->

</cfcomponent>
	