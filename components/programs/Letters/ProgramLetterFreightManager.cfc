<!--- 
FILE: 		BA Application - Model: ProgramLetterFreightManager Component	
FILEname:   ProgramLetterFreightManager.cfc											
CREATED:  	8/12/2008 - Brad Lee MMCP/ACI
EDITED:   	8/13/2008 - Brad Lee MMCP/ACI

FUNCTIONALITY: 
- ALL ProgramLetterFreight Display is generated and managed by this object. --->

<!--- COLDFUSION COMPONENT: ProgramLetterFreightManager --->
<cfcomponent displayname="ProgramLetterFreightManager" hint="I am the ProgramLetterFreight Manager.">

    <!--- Set the initialization flag to "False" --->
	<cfparam name="this.objectInitialized" type="boolean" default="0">
	
	<!--- If the construction process has not yet run... (keeps this from happening over and over) --->
	<cfif NOT this.objectInitialized>

		<!--- Set up the object skeleton --->
		<cfscript>
			// application.applicationname & 
			structInsert(this, 	"objName", 				"ProgramLetterFreightManager");
			structInsert(this, 	"objDateTimeCreated", 	createODBCDateTime(now()));
			structInsert(this,	"objectInitialized", 	"1",true);
		</cfscript>

		<!--- ProgramLetterFreightManager Methods [begin] ::::::::::::::::::::::::::::
		::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

        <!--- 0.) MODEL New METHOD: generateProgramLetterFreightDistributorDatas() [begin]
        
        FUNCTIONALITY: I generate an all inclusive array of structures for Program Letter Freight Distributor Display. --->
        
        <cffunction name="generateProgramLetterFreightDistributorDatas" access="public" output="no" hint="I retrieve Program Letter Freight Distributor Detail from the DB." returntype="struct">
        
        	<!--- INCOMING [begin] --->
            
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") [in alpha] --->
            <cfargument name="bLetterDisplayFixedPrice" 		required="true" type="boolean"/>
            <cfargument name="bLetterSectionDisplayFixedPrice" 	required="true" type="boolean">
            <cfargument name="customerFreightUom"				required="true" type="string"/>
            <cfargument name="program_bid_request_status_id"	required="true" type="numeric"/>
            <cfargument name="program_id" 						required="true" type="string"/>
            <cfargument name="qProgramDistributor" 				required="true" type="query"/>
            <cfargument name="qProgramFixedPrice" 				required="true" type="query"/>
            
            <!--- INCOMING [end] --->
            
            <!--- SET Local [begin] --->

			<!--- 1.) our overall STRUCTURE container --->
            <!--- Legend: var_stPLDIF = var_stProgramLetterDistributorItemFreight --->
			<cfset var var_stPLDIF = structNew()>

            <!--- 2.) ARRAY of distributors --->
            <cfset var var_aProgramLetterFreightDistributorDatas = arrayNew(1)>

            <cfset var var_lsProgramLetterFreightDistributorDetailKeys = arguments.qProgramDistributor.columnList>
            <cfset var var_currentProgramDistributor = 0>
            <cfset var var_currentProgramDistributorColumnKey = ''>
            
            	<!--- temp [begin] --->
            
				<!--- IV --->
                <cfset var var_q = queryNew('cols')>
                <cfset var var_lsFOBProgramDistributorFreightKeys = ''>
                <cfset var var_currentFOBProgramDistributorFreightColumnKey = ''>
            
            	<!--- temp [end] --->
            
            <!--- 3.) general info STRUCTURE --->
            <cfset var var_qProgramLetterFreightGeneralInfo = queryNew('cols')>
            
            <cfset var var_stProgramLetterFreightGeneralInfo = structNew()>
            <cfset var var_lsProgramLetterFreightGeneralInfoKeys = ''>
            <cfset var var_currentGeneralColumnKey = ''>
            
            <!--- 4.) freight_info ARRAY --->
            <cfset var var_qProgramLetterFreightFixedComponentGross = queryNew('cols')>
            <cfset var var_qProgramLetterFreightFixedComponentNet = queryNew('cols')>
            
            <!--- we need a list of NET item IDs from the incoming NET fixed_price query... [strings] --->
            <cfset var var_lsProgramFixedPriceNetItemIDs = replace(valueList(arguments.qProgramFixedPrice.item,','),' ','','all')>
            
            <!--- III --->
            <cfset var var_lsProgramLetterFreightWonItemIDs = getProgramLetterFreightWonItemIDs(arguments.program_id)>

        	<!--- SET Local [end] --->
            	
			<cfset var_q = getProgramLetterFreightDistributorDetail(arguments.program_id,arguments.qProgramDistributor.BSA_Foodservice_Customers_ID[1])>
            <cfset var_lsFOBProgramDistributorFreightKeys = var_q.columnList>
            
            <cfswitch expression="#arguments.customerFreightUom#">
                <cfcase value="cs">
                    <cfset structInsert(var_stPLDIF,"uomType",1,true)>
                    <cfset structInsert(var_stPLDIF,"iDecimalLen",2,true)>
                </cfcase>
                <cfdefaultcase>
                    <cfset structInsert(var_stPLDIF,"uomType",2,true)>
                    <cfset structInsert(var_stPLDIF,"iDecimalLen",4,true)>
                </cfdefaultcase>
            </cfswitch>
        
            <!--- /// 2.) distributor info [begin] --->
             <cfloop from="1" to="#arguments.qProgramDistributor.recordCount#" index="var_currentProgramDistributor">
		
                <cfset var_aProgramLetterFreightDistributorDatas[var_currentProgramDistributor] = structNew()>
    
                <cfloop list="#var_lsProgramLetterFreightDistributorDetailKeys#" index="var_currentProgramDistributorColumnKey" delimiters=",">
                    <cfset structInsert(var_aProgramLetterFreightDistributorDatas[var_currentProgramDistributor],var_currentProgramDistributorColumnKey,arguments.qProgramDistributor[var_currentProgramDistributorColumnKey][var_currentProgramDistributor])>
                </cfloop>
                
                <!--- temp [begin] --->
                
                <!--- IV --->
                <cfset structInsert(var_aProgramLetterFreightDistributorDatas[var_currentProgramDistributor],"stFOBProgramDistributorFreight",structNew(),true)>
                
                <cfset qTempFreight = getProgramLetterFreightDistributorDetail(arguments.program_id,arguments.qProgramDistributor.BSA_Foodservice_Customers_ID[var_currentProgramDistributor])>

                <cfloop list="#var_lsFOBProgramDistributorFreightKeys#" index="var_currentFOBProgramDistributorFreightColumnKey" delimiters=",">
                    <cfset structInsert(var_aProgramLetterFreightDistributorDatas[var_currentProgramDistributor].stFOBProgramDistributorFreight,var_currentFOBProgramDistributorFreightColumnKey,qTempFreight[var_currentFOBProgramDistributorFreightColumnKey][1])>
                </cfloop>

                <!--- temp [end] --->

            </cfloop>
            
            <!--- distributors --->
            <cfset structInsert(var_stPLDIF,"aProgramDistributor",var_aProgramLetterFreightDistributorDatas,true)>
            
            <!--- /// 2.) distributor info [end] --->

            <!--- /// 3.) general info [begin] I --->
            <cfset var_qProgramLetterFreightGeneralInfo = getProgramLetterFreightInitialInfo(arguments.program_id)>
            <cfset var_lsProgramLetterFreightGeneralInfoKeys = var_qProgramLetterFreightGeneralInfo.columnList>

            <cfloop query="var_qProgramLetterFreightGeneralInfo">
            
                <cfloop list="#var_lsProgramLetterFreightGeneralInfoKeys#" index="var_currentGeneralColumnKey" delimiters=",">
                    <cfset structInsert(var_stProgramLetterFreightGeneralInfo,var_currentGeneralColumnKey,var_qProgramLetterFreightGeneralInfo[var_currentGeneralColumnKey],true)>
                </cfloop>    

            </cfloop>
            
            <!--- general info --->
            <cfset structInsert(var_stPLDIF,"stFOBProgramInfo",var_stProgramLetterFreightGeneralInfo,true)>
            
            <!--- /// 3.) general info [end] I --->

            <!--- /// 4.) freight info [begin] II --->
    <cfset var_qProgramLetterFreightFixedComponentGross = getProgramLetterFreightFixedComponentGross(arguments.program_id)>

            <!--- let's eliminate any freight products that have been deleted from the fixed price area during a prior edit of this letter... --->
            <cfquery name="var_qProgramLetterFreightFixedComponentNet"  datasource="#application.datasource#">
              SELECT 	*
              FROM 		##tmp_ProgramLetterFreightFixedComponentGross
                <cfif arguments.bLetterDisplayFixedPrice AND arguments.bLetterSectionDisplayFixedPrice>
                    <cfif listLen(var_lsProgramFixedPriceNetItemIDs)>
                        WHERE		item IN (#listQualify(var_lsProgramFixedPriceNetItemIDs,"'",",")#)
                    <cfelse>
                        WHERE		1=2
                    </cfif>
                <cfelse>
                    <!--- IF our bid_status is either won, split OR lost... [begin] --->
                    <cfif listFind('2,3,4',arguments.program_bid_request_status_id,',')>
                        <cfif listLen(var_lsProgramLetterFreightWonItemIDs,',')>
                            <!---- if the letters do not have fixed price at all, confirm the freight products are won [ITEM_ID'S] ----->
                            WHERE		item IN (#replace(listQualify(var_lsProgramLetterFreightWonItemIDs,"'",",")," ","","ALL")#)
                        <cfelse>
                            WHERE		1=2 
                        </cfif>    
                    </cfif>
                    <!--- IF our bid_status is either won, split OR lost... [end] --->
                </cfif>      
            </cfquery>
            
            <!--- freight info --->
            <cfset structInsert(var_stPLDIF,"qFOBFixedComp",var_qProgramLetterFreightFixedComponentNet,true)>

            <!--- /// 4.) freight info [end] II --->

			<!--- Return the final container to the caller --->
            <cfreturn var_stPLDIF>
            
        </cffunction>
        <!--- METHOD: generateProgramLetterFreightDistributorDatas() [end] --->

		<!--- I.) MODEL Legacy METHOD: getProgramLetterFreightInitialInfo() [begin]
        
        FUNCTIONALITY: I retrieve Program Letter Freight Initial Information from the DB. --->
        
        <cffunction name="getProgramLetterFreightInitialInfo" access="private" output="no" hint="I retrieve Program Letter Freight Initial Information from the DB." returntype="any">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
            <cfargument name="program_id" required="true" type="string" />
        
            <cfset var var_qProgramLetterFreightInitialInfo = queryNew('cols')>
            
			<!--- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --->
        
            <cfquery name="var_qProgramLetterFreightInitialInfo" datasource="#application.datasource#"> 
                SELECT	Contract_Main.Contract_Main_ID, Contract_Number, Contract_Title, 
                Contract_Start_Date, Contract_End_Date,
                Contract_Reference_Number,
                Contract_Quantity, Contract_Quantity_UOM_IDX,
                Contract_Status_Type_IDX,
                programtype_id,
                Responsible_User_ID,
                Approved_By_User_ID, Approval_Date,
                Contract_Is_Locked, Contract_Locked_By_User_ID,
                ISNULL(Contract_Main_Aux_Data.Program_Spend, 0) as Program_Spend,
                Program_Control_Panel_Options.Template_Parent_ID,
                Program_Control_Panel_Options.First_Parent_ID,
                Program_Control_Panel_Options.Created_Type,
                Program_Control_Panel_Options.Generic_Type,
                Contract_Main.Approved, Contract_Main.Is_A_Revision,
                Contract_Main.Creating_User_Position_ID, 
                Contract_Main_Aux_Data.Simple_Budget_ID,
                Contract_Main_Aux_Data.Freight_Component_Type,
                Program_Control_Panel_Options.Freight_Approval_Required,
                Contract_Main_Aux_Data.Freight_Approved,
                Contract_Main_Aux_Data.Freight_Approved_By,
                Contract_Main_Aux_Data.Freight_Approved_Date,
                Contract_Main_Aux_Data.Freight_Contract_Start_Date,
                Contract_Main_Aux_Data.Freight_Contract_End_Date,
                Contract_Main.Applied_Pullbacks,
                Program_Control_Panel_Options.Pullbacks_On,
                Program_Control_Panel_Options.Pullback_Template_Type,
                Program_Control_Panel_Options.ProgramControl_Panel_Options_ID,
                CASE WHEN Program_Control_Panel_Options.Fixed_Type = 0 THEN
                    'Guaranteed'
                ELSE
                    'Variable'
                END
                    As Fixed_Type,
                Contract_Main_Aux_Data.Freight_Notes,Contract_Main.Notes
                FROM	Contract_Main
                INNER JOIN	Contract_Main_Aux_Data 
                ON 		Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
                INNER JOIN Program_Control_Panel_Options
                ON		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
                WHERE	Contract_Main.Contract_Main_ID = <cfqueryparam value="#arguments.program_id#" cfsqltype="CF_SQL_INTEGER">
            </cfquery>
                
            <!--- Return the final container to the caller --->
            <cfreturn var_qProgramLetterFreightInitialInfo>
            
        </cffunction>
        <!--- METHOD: getProgramLetterFreightInitialInfo() [end] --->

        <!--- II.) MODEL Legacy METHOD: getProgramLetterFreightFixedComponentGross() [begin]
        
        FUNCTIONALITY: I retrieve Program Letter Freight Fixed Component Gross Information from the DB. --->
        
        <cffunction name="getProgramLetterFreightFixedComponentGross" access="private" output="no" hint="I retrieve Program Letter Freight Fixed Component Gross Information from the DB." returntype="void">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
            <cfargument name="program_id" required="true" type="string" />
        
            <cfset var var_qProgramLetterFreightFixedComponentGross = queryNew('cols')>
  
	    <cfquery datasource="#application.datasource#">
  		if object_id('tempdb..##tmp_ProgramLetterFreightFixedComponentGross') is not null 
		drop table ##tmp_ProgramLetterFreightFixedComponentGross

		CREATE TABLE ##tmp_ProgramLetterFreightFixedComponentGross 
		(
		Program_Fixed_Component_Name_Id int,
		Program_Fixed_Component_Name varchar(50),
		Fixed_Component_Type int,
		Delivery_Type_Desc varchar(50),
		Item varchar(100),
		BSA_Foodservice_Items_Master_ID varchar(50),
		Description varchar(100),
		Fixed_Price_Value varchar(50),
		Gross_Weight varchar(50),
		Net_Weight varchar(50),
		Unit_Of_Measure_ID tinyint,
		Include_Claim_Rates_Report bit
		)
		CREATE CLUSTERED  INDEX [I_tmp_program_fixedprice_data] ON [##tmp_ProgramLetterFreightFixedComponentGross]([Item]) ON [PRIMARY]
	    </cfquery>

            <cfquery name="var_qProgramLetterFreightFixedComponentGross" datasource="#application.datasource#">
		INSERT INTO ##tmp_ProgramLetterFreightFixedComponentGross(Program_Fixed_Component_Name_Id,Program_Fixed_Component_Name,Fixed_Component_Type,Delivery_Type_Desc,Item,BSA_Foodservice_Items_Master_ID,
		Description,Fixed_Price_Value,Gross_Weight,Net_Weight,Unit_Of_Measure_ID,Include_Claim_Rates_Report)

                SELECT DISTINCT 
                Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id
                ,Program_Fixed_Component_Name.Program_Fixed_Component_Name
                ,Program_Fixed_Component_Name.Fixed_Component_Type
                ,Delivery_Type.Delivery_Type_Desc
                ,BSA_Foodservice_Items_Master.Item
                ,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
                ,BSA_Foodservice_Items_Master.Description
                ,Program_Fixed_Price_Product_Data.Fixed_Price_Value
                ,BSA_Foodservice_Items_Master.Gross_Weight
                ,BSA_Foodservice_Items_Master.Net_Weight
                ,Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
				,Payment_Type.Include_Claim_Rates_Report

                FROM Program_Fixed_Price_Product_Data
                INNER JOIN contract_products
                ON Program_Fixed_Price_Product_Data.contract_products_id = contract_products.contract_products_id
                AND Program_Fixed_Price_Product_Data.program_id = contract_products.contract_main_id
                INNER JOIN BSA_Foodservice_Items_Master
                ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = contract_products.BSA_Foodservice_Items_Master_ID 
                INNER JOIN Program_Fixed_Component 
                ON Program_Fixed_Component.Program_Fixed_Component_Id = 
                Program_Fixed_Price_Product_Data.Program_Fixed_Component_Id
                INNER JOIN Program_Fixed_Component_Name ON
                Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id = Program_Fixed_Component.Program_Fixed_Component_Name_Id
                INNER JOIN Delivery_Type
                ON Program_Fixed_Component_Name.Fixed_Component_Type = Delivery_Type.Delivery_Type_ID					
				LEFT JOIN Payment_Type 
				ON Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_id
               
		WHERE Contract_Products.Contract_Main_ID = <cfqueryparam value="#arguments.program_id#" cfsqltype="CF_SQL_INTEGER">
                AND Contract_Products.Deleted = 0
                AND Program_Fixed_Price_Product_Data.Deleted = 0
                AND Contract_Products.Product_Type_ID = 1
                AND Program_Fixed_Component_Name.Fixed_Component_Type IN (1,4) 
                AND Program_Fixed_Component.Deleted = 0
		<!--- Dev Note: Milan (24557). If any change in the SELECT clause OR ORDER BY clause OR any other change is made here. A corresponding
		change might need to be made on "generate_program_pdf.cfm" - On the freight section, where we use "##tmp_claim_report_results", we might
		need to make the ORDER BY clause same as here and then verify whether both the result sets are same.
		--->
                ORDER BY Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id,BSA_Foodservice_Items_Master.Item
            </cfquery>
            
        </cffunction>
        <!--- METHOD: getProgramLetterFreightFixedComponentGross() [end] --->

        <!--- III.) MODEL Legacy METHOD: getProgramLetterFreightWonItemIDs() [begin]
        
        FUNCTIONALITY: I retrieve Program Letter Freight Won Item IDs from the DB. --->
        
        <cffunction name="getProgramLetterFreightWonItemIDs" access="private" output="no" hint="I retrieve Program Letter Freight Won Item IDs from the DB." returntype="any">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
            <cfargument name="program_id" required="true" type="string" />
        
            <cfset var var_qProgramLetterFreightWonItemIDs = ''>
            <cfset var var_lsProgramLetterFreightWonItemIDs = ''>
            
            <cfquery name="var_qProgramLetterFreightWonItemIDs" datasource="#application.datasource#">
                SELECT	BSA_Foodservice_Items_Master.item
                FROM	program_product_bid_info,BSA_Foodservice_Items_Master
                WHERE	program_product_bid_info.program_id = <cfqueryparam value="#arguments.program_id#" cfsqltype="cf_sql_integer">
                AND		program_product_bid_info.won = 1
                AND		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = program_product_bid_info.Product_ID
            </cfquery>
            
            <cfset var_lsProgramLetterFreightWonItemIDs = valueList(var_qProgramLetterFreightWonItemIDs.item,",")>
                
            <!--- Return the final container to the caller --->
            <cfreturn var_lsProgramLetterFreightWonItemIDs>
            
        </cffunction>
        <!--- METHOD: getProgramLetterFreightWonItemIDs() [end] --->

        <!--- IV.) MODEL Legacy METHOD: getProgramLetterFreightDistributorDetail() [begin]
        
        FUNCTIONALITY: I retrieve Program Letter Freight Distributor Detail from the DB. --->
        
        <cffunction name="getProgramLetterFreightDistributorDetail" access="private" output="no" hint="I retrieve Program Letter Freight Distributor Detail from the DB." returntype="any">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
            <cfargument name="programId" 		required="true" 	type="numeric" />	
			<cfargument name="distributorId" 	required="false" 	type="string" default=""/>
        
            <cfset var var_qProgramLetterFreightDistributorDetail = ''>

            <cfquery name="var_qProgramLetterFreightDistributorDetail" datasource="#application.datasource#">			
                SELECT DISTINCT
                    Program_Distributor_Freight.Program_ID,
                    Program_Distributor_Freight.Distributor_ID,
                    Program_Distributor_Freight.Warehouse_Master_ID,
                    Program_Distributor_Freight.Default_Warehouse_Master_ID,
                    Program_Distributor_Freight.Freight_Bracket_Setting_ID,
                    Program_Distributor_Freight.Default_Freight_Bracket_Setting_ID,
                    Program_Distributor_Freight.Overridden_Warehouse_Master_ID,
                    Program_Distributor_Freight.Overridden_Freight_Bracket_Setting_ID,
                    Program_Distributor_Freight.Last_Updated_By,
                    Program_Distributor_Freight.Last_Updated_Date,
                    Program_Distributor_Freight.Deleted,
                    Program_Distributor_Freight.Created_Date,
                    ISNULL(CONVERT(Decimal(20,2), Program_Distributor_Freight.IBF_Rate), 0) As IBF_Rate,
                    ISNULL(CONVERT(Decimal(20,2), Program_Distributor_Freight.OBF_Rate), 0) As OBF_Rate,
                    ISNULL(CONVERT(Decimal(20,2), Program_Distributor_Freight.Pickup_Allowance), 0) As Pickup_Allowance,
                    CONVERT(Decimal(20,2), Program_Distributor_Freight.Default_IBF_Rate) As Default_IBF_Rate,
                    CONVERT(Decimal(20,2), Program_Distributor_Freight.Default_OBF_Rate) As Default_OBF_Rate,
                    CONVERT(Decimal(20,2), Program_Distributor_Freight.Default_Pickup_Allowance) As Default_Pickup_Allowance,
                    CONVERT(Decimal(20,2), Program_Distributor_Freight.Overridden_IBF_Rate) As Overridden_IBF_Rate,
                    CONVERT(Decimal(20,2), Program_Distributor_Freight.Overridden_OBF_Rate) As Overridden_OBF_Rate,
                    CONVERT(Decimal(20,2), Program_Distributor_Freight.Overridden_Pickup_Allowance) As Overridden_Pickup_Allowance,
                    CONVERT(Decimal(20,2), Contract_Distributors.Program_Weight) As Program_Weight,
                    BSA_Foodservice_Customers.Shr_Ship_to,
                    BSA_Foodservice_Customers.Name,			
                    BSA_Foodservice_Customers.Address_1,
                    BSA_Foodservice_Customers.Address_2,
                    BSA_Foodservice_Customers.City,
                    BSA_Foodservice_Customers.State,
                    BSA_Foodservice_Customers.ZipCode,
                    Warehouse_Master.Warehouse_Code,
                    Warehouse_Master.Warehouse_Name,
                    Warehouse_Master.Warehouse_Address_1,
                    Warehouse_Master.Warehouse_Address_2,
                    Warehouse_Master.Warehouse_City,
                    Warehouse_Master.Warehouse_State,
                    Warehouse_Master.Warehouse_Zip,
                    Warehouse_Master.Warehouse_Country_Code,
                    Freight_Lookup_Bracket_Settings.Freight_Bracket_Code,
                    Freight_Lookup_Bracket_Settings.Freight_Bracket_Label
                    FROM	Program_Distributor_Freight
                    
                    INNER JOIN Contract_Distributors
                    ON	Contract_Distributors.Deleted = 0
                    AND	Contract_Distributors.Contract_Main_ID = Program_Distributor_Freight.Program_ID
                    AND	Contract_Distributors.BSA_Foodservice_Customers_ID = Program_Distributor_Freight.Distributor_ID
                    
                    INNER JOIN BSA_Foodservice_Customers
                    ON	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Program_Distributor_Freight.Distributor_ID
                    
                    LEFT JOIN Warehouse_Master
                    ON	Warehouse_Master.Warehouse_Master_ID = Program_Distributor_Freight.Warehouse_Master_ID
                    
                    LEFT JOIN Freight_Lookup_Bracket_Settings
                    ON	Freight_Lookup_Bracket_Settings.Freight_Bracket_Setting_ID = Program_Distributor_Freight.Freight_Bracket_Setting_ID
                    WHERE Program_Distributor_Freight.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
                    <cfif arguments.distributorId neq "">
                    AND Program_Distributor_Freight.Distributor_ID = <cfqueryparam value="#arguments.distributorId#" cfsqltype="CF_SQL_VARCHAR">
                    </cfif>
                    AND	Program_Distributor_Freight.Deleted = 0
                    ORDER BY BSA_Foodservice_Customers.Shr_Ship_to
                </cfquery>
                
                <!--- Return the final container to the caller --->
                <cfreturn var_qProgramLetterFreightDistributorDetail>
            
        </cffunction>
        <!--- METHOD: getProgramLetterFreightDistributorDetail() [end] --->

        <!--- ProgramLetterFreightManager Methods [end] ::::::::::::::::::::::::::::
		::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
        
        <!--- ProgramLetterFreightManager [General Functions] Methods [begin] ::::::::
		::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
        
        <cffunction name="NumericRoundDecimal" output="false" returntype="string">
            <cfargument name="iValue" type="numeric" required="true" />
            <cfargument name="iDecimalLen" type="numeric" required="true" />
            <cfset var divVal = 10 ^ arguments.iDecimalLen />
            <cfset var newAmount = arguments.iValue />
            <cfset newAmount = newAmount * divVal />
            <cfset newAmount = Round(Val(newAmount)) />
            <cfset newAmount = newAmount / divVal />
            <cfreturn newAmount />	
        </cffunction>
        
        <!--- ProgramLetterFreightManager [General Functions] Methods [end] ::::::::
		::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

	</cfif>

</cfcomponent>