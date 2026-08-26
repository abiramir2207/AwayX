<!--- /mvc/Models/Program/FormulaItemLevel.cfc --->
<cfcomponent displayname="ItemLevelFormula" output="false" access="public">

<cffunction name="init" output="false" returntype="mvc.Models.Program.FormulaItemLevel">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <cfset variables.ContractId = arguments.contractId />
    <cfreturn this />
</cffunction>

<cffunction name="getBracketData" hint="json bracket data" access="remote" output="false" returntype="string" returnformat="JSON">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <cfset q = getBracketDataQuery(arguments.contractId)>
    <cfreturn application.util.query.toAgGridJSON(qGetInfo, 'rate, description, overRide, brackid, uom, bracketnumber') />

</cffunction>

<cffunction name="getBracketDataQuery" hint="bracketQuery" access="remote" output="false" returntype="query" >
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <cfargument name="bracketNumber" type="numeric" required="false" default="0" />

        <cfquery name="qDropTable" datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##tmp_Program_Fixed_Component_Name') IS NOT NULL
            DROP TABLE ##tmp_Program_Fixed_Component_Name
        </cfquery>

        <cfquery name="qGetInfo" datasource="#application.datasource#">
            /* get fixed price components selected on the template */
            SELECT	DISTINCT cn.*
            INTO	##tmp_Program_Fixed_Component_Name
            FROM	Contract_Main cm
            INNER JOIN  Program_Template_Component comp
            ON		comp.Template_ID = cm.ProgramType_ID
            AND		comp.Deleted = 0
            AND		comp.Discount_Type_ID = 1
            INNER JOIN Program_Fixed_Component_Name cn
            ON		cn.Program_Fixed_Component_Name_ID = comp.Component_ID
            WHERE	cm.Contract_Main_ID = '#arguments.contractId#'

             SELECT ISNULL(FPBD.rate,OFR.OBF_Rate) as rate,
                     F.Freight_Bracket_Label as description,
                     FPBD.Is_Over_Ride as overRide,
                     FPBD.Formula_Program_Bracket_Data_id as brackid,
                     Rate_UOM_Desc as uom,
                     Bracket_Number as bracketnumber
            FROM Formula_Program_Bracket_Data FPBD
            INNER JOIN Freight_Lookup_Bracket_Settings F ON
                F.Freight_Bracket_Code = FPBD.Bracket_Number
            INNER JOIN ##tmp_Program_Fixed_Component_Name N ON
                F.Freight_Bracket_Code = N.GPO_Program_Tier_Number
            INNER JOIN Outbound_Freight_Rate OFR ON
                OFR.Freight_Bracket_Setting_ID = F.Freight_Bracket_Setting_ID
                and ofr.deleted = 0
            LEFT JOIN Program_Fixed_Component PFC ON
                PFC.Program_Fixed_Component_Name_ID  = N.Program_Fixed_Component_Name_ID AND
                PFC.Program_Id = '#arguments.contractId#' AND
                PFC.Deleted = 0
            WHERE FPBD.Contract_Main_ID =  '#arguments.contractId#'  AND
                FPBD.deleted = 0
                 ----  AND Freight_Bracket_Code != '11'
            ORDER BY cast(F.Freight_Bracket_Code as int)
        </cfquery>
        <!--- <cfdump var='#qGetInfo#' output='c:/dump.log'/> --->

    <cfreturn qGetInfo />
</cffunction>

<cffunction name="getCompIdList" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
    <cfargument name="contractId" type="numeric" required="false" default="0" />

        <cfquery name="qGetCompInfo" datasource="#application.datasource#">
                SELECT  Distinct PFCN.Program_Fixed_Component_Name as compname,
                                PFC.Program_Fixed_Component_Id as compid,
                                PFCN.Program_Fixed_Component_Name_Id as compnameid,
                                PFCN.GPO_Program_Tier_Number
                FROM Program_Fixed_Component PFC
                INNER JOIN  Program_Fixed_Component_Name PFCN ON
                    PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
                WHERE 	PFC.Program_ID = '#arguments.contractId#' AND
                        PFC.Deleted = 0 AND
                        PFCN.Deleted = 0
                ORDER BY PFCN.GPO_Program_Tier_Number
        </cfquery>
        <!--- <cfdump var="#compIdList#" output="c:/dump.log" /> --->
    <cfreturn application.util.query.toAgGridJSON(qGetCompInfo, 'compname,compid,compnameid') />
</cffunction>

<cffunction name="insertBrackets" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <cfquery name="qGetExisting" datasource="#application.datasource#">
         select Contract_Main_ID,
                 Formula_Program_Bracket_Data_ID
        from Formula_Program_Bracket_Data
        where Contract_Main_ID = '#arguments.contractId#' AND
            Deleted = 0
    </cfquery>

    <cfif qGetExisting.recordcount EQ 0>
        <cfquery name="qDropTable" datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##tmp_Program_Fixed_Component_Name') IS NOT NULL
            DROP TABLE ##tmp_Program_Fixed_Component_Name
        </cfquery>

        <cfquery name="qInsertBrackets" datasource="#application.datasource#">
            /* get fixed price components selected on the template */
            SELECT	DISTINCT cn.*
            INTO	##tmp_Program_Fixed_Component_Name
            FROM	Contract_Main cm
            INNER JOIN  Program_Template_Component comp
            ON		comp.Template_ID = cm.ProgramType_ID
            AND		comp.Deleted = 0
            AND		comp.Discount_Type_ID = 1
            INNER JOIN Program_Fixed_Component_Name cn
            ON		cn.Program_Fixed_Component_Name_ID = comp.Component_ID
            WHERE	cm.Contract_Main_ID = '#arguments.contractId#'

            INSERT INTO Formula_Program_Bracket_Data (Contract_Main_ID,Bracket_Number,Bracket_Number_Desc,Rate,Rate_UOM_Desc,Rate_UOM_Id,Program_Fixed_Component_Name_Id)
            SELECT '#arguments.contractId#',
                    N.GPO_Program_Tier_Number,
                    F.Freight_Bracket_Label as description,
                    OFR.OBF_Rate,
                    'LBS',
                    2,
                    N.Program_Fixed_Component_Name_ID
            FROM Freight_Lookup_Bracket_Settings F
            INNER JOIN ##tmp_Program_Fixed_Component_Name N ON
                F.Freight_Bracket_Code = N.GPO_Program_Tier_Number
            INNER JOIn Outbound_Freight_Rate OFR ON
                OFR.Freight_Bracket_Setting_ID = F.Freight_Bracket_Setting_ID
                and ofr.deleted = 0
            LEFT JOIN Program_Fixed_Component PFC ON
                    PFC.Program_Id = '#arguments.contractId#' AND
                    PFC.Program_Fixed_Component_Name_Id = N.Program_Fixed_Component_Name_Id AND
                    PFC.Deleted = 0
            WHERE PFC.Program_Fixed_Component_ID IS NULL
            ORDER BY cast(F.Freight_Bracket_Code as int)
        </cfquery>
    </cfif>
    <cfif this.checkFormulaComponent(arguments.contractId) EQ 0>
        <cfset this.createFormulaComponents(arguments.contractId) />
    </cfif>
    <cfreturn this.getBracketData(arguments.contractId) />
</cffunction>

<cffunction name="addBracketsManual" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
    <cfargument name="contractId" type="numeric" required="false" default="0" />

        <cfquery name="qDropTable" datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##tmp_Program_Fixed_Component_Name') IS NOT NULL
            DROP TABLE ##tmp_Program_Fixed_Component_Name
        </cfquery>

        <cfquery name="qInsertBrackets" datasource="#application.datasource#">
            /* get fixed price components selected on the template */
            SELECT	DISTINCT cn.*
            INTO	##tmp_Program_Fixed_Component_Name
            FROM	Contract_Main cm
            INNER JOIN  Program_Template_Component comp
            ON		comp.Template_ID = cm.ProgramType_ID
            AND		comp.Deleted = 0
            AND		comp.Discount_Type_ID = 1
            INNER JOIN Program_Fixed_Component_Name cn
            ON		cn.Program_Fixed_Component_Name_ID = comp.Component_ID
            WHERE	cm.Contract_Main_ID = '#arguments.contractId#'

            INSERT INTO Formula_Program_Bracket_Data (Contract_Main_ID,Bracket_Number,Bracket_Number_Desc,Rate,Rate_UOM_Desc,Rate_UOM_Id,Program_Fixed_Component_Name_Id)
            SELECT '#arguments.contractId#',
                    N.GPO_Program_Tier_Number,
                    F.Freight_Bracket_Label as description,
                    OFR.OBF_Rate,
                    'LBS',
                    2,
                    N.Program_Fixed_Component_Name_ID
            FROM Freight_Lookup_Bracket_Settings F
            INNER JOIN ##tmp_Program_Fixed_Component_Name N ON
                F.Freight_Bracket_Code = N.GPO_Program_Tier_Number
            INNER JOIn Outbound_Freight_Rate OFR ON
                OFR.Freight_Bracket_Setting_ID = F.Freight_Bracket_Setting_ID
                and ofr.deleted = 0
            LEFT JOIN Program_Fixed_Component PFC ON
                    PFC.Program_Id = '#arguments.contractId#' AND
                    PFC.Program_Fixed_Component_Name_Id = N.Program_Fixed_Component_Name_Id AND
                    PFC.Deleted = 0
            WHERE PFC.Program_Fixed_Component_ID IS NULL
            ORDER BY cast(F.Freight_Bracket_Code as int)
        </cfquery>
    <cfset this.createFormulaComponents(arguments.contractId) />
    <cfreturn this.getBracketData(arguments.contractId) />
</cffunction>

<cffunction name="deleteBracket" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <cfargument name="BracketId" type="String" required="true" >
        <cfquery name="qDeleteBrackets" datasource="#application.datasource#">
            UPDATE PFC Set Deleted = 1
            FROM Program_Fixed_Component PFC
            INNER JOIN Program_Fixed_Component_Name FN ON
                FN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
            INNER JOIN Formula_Program_Bracket_Data GPTD ON
                FN.Program_Fixed_Component_Name_ID = GPTD.Program_Fixed_Component_Name_ID AND
                GPTD.Contract_Main_ID = PFC.Program_ID AND
                GPTD.Deleted = 0
            WHERE Program_ID = '#arguments.contractId#' AND
                PFC.Deleted = 0 AND
                GPTD.Formula_Program_Bracket_Data_Id in ('#arguments.BracketId#')

            UPDATE Formula_Program_Bracket_Data
            SET Deleted = 1 WHERE
            Formula_Program_Bracket_Data_Id  in ('#arguments.BracketId#') AND
            Contract_Main_Id = '#arguments.contractId#' AND
            Deleted = 0

             UPDATE PFPPD Set Deleted = 1
             FROM Program_Fixed_Price_Product_Data PFPPD
             LEFT JOIN Program_Fixed_Component PFC ON
                PFPPD.Program_ID = PFC.Program_Id AND
                PFC.Program_Fixed_Component_ID = PFPPD.Program_Fixed_Component_ID AND
                PFC.Deleted = 0
             WHERE PFPPD.Program_ID = '#arguments.contractId#' And
                    PFPPD.Deleted = 0 AND
                    PFC.Program_Fixed_Component_ID IS NULL
        </cfquery>

    <cfreturn this.getBracketData(arguments.contractId) />
</cffunction>

<cffunction name="resetBracket" output="false" returntype="string" returnformat="JSON" access="remote">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <cfargument name="aData" type="any" required="true" />

        <cfscript>
            // stuff
            var arrData = deserializeJson(aData);
            var a = arguments;
            var lCPid = '';
            for (i=1; i <= arrayLen(arrData);i=i+1) {
                    st = arrData[i];
                        lCPid = listappend(lCPid,st.brackid);
            }
        </cfscript>
<cfloop list="#lCPid#" index="BracketID">
    <cfset this.updateBracket(arguments.contractId, #BracketID#, 0, 1) />
</cfloop>
</cffunction>

<cffunction name="updateBracket" output="false" returntype="string" returnformat="JSON" access="remote">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <cfargument name="BracketId" type="numeric" required="true" >
    <cfargument name="rate" type="numeric" required="false" default = "0">
    <cfargument name="reset" type="numeric" required="false" default = "0">

    <cfscript>
        var a = arguments;
    </cfscript>
    <cfif arguments.reset>
        <CFQUERY NAME="updBracket" DATASOURCE="#application.datasource#">
            UPDATE FPBD SET  rate = OFR.OBF_Rate,
                            Is_Over_Ride = 0
            FROM Formula_Program_Bracket_Data FPBD
            INNER JOIN Freight_Lookup_Bracket_Settings F ON
                F.Freight_Bracket_Code = FPBD.Bracket_Number
            INNER JOIn Outbound_Freight_Rate OFR ON
                OFR.Freight_Bracket_Setting_ID = F.Freight_Bracket_Setting_ID
                and ofr.deleted = 0
            Where FPBD.Formula_Program_Bracket_Data_Id = #a.BracketId#
        </CFQUERY>
    <cfelse>
        <CFQUERY NAME="updBracket" DATASOURCE="#application.datasource#">
            Update Formula_Program_Bracket_Data
            Set rate = #a.rate#,
                Is_Over_Ride = 1
            Where Formula_Program_Bracket_Data_Id = #a.BracketId#
        </CFQUERY>
    </cfif>

    <CFQUERY NAME="recalc" DATASOURCE="#application.datasource#" result='res'>
        UPDATE	 PD
        SET Fixed_Price_Value =
            CASE WHEN Unit_Of_Measure_ID = 2 THEN CAST(PD.Market_Price_Rate_Orig + FPBD.rate as DECIMAL(18,4))
                WHEN Unit_Of_Measure_ID = 1 THEN CAST((PD.Market_Price_Rate_Orig + FPBD.rate) * I.Net_Weight  as DECIMAL(18,4))
                ELSE CAST(PD.Market_Price_Rate_Orig + FPBD.rate as DECIMAL(18,4))
            END
        --,Unit_Of_Measure_ID = 2
        FROM	Contract_Products CP
        INNER JOIN BSA_Foodservice_Items_Master I ON
            I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
        INNER JOIN	dbo.Program_Fixed_Price_Product_Data PD ON
            PD.Contract_Products_ID = CP.Contract_Products_ID AND
            PD.Deleted = 0
        INNER JOIN Program_Fixed_Component PFC ON
                PFC.Program_Fixed_Component_ID  = PD.Program_Fixed_Component_ID
        INNER JOIN Program_Fixed_Component_Name N ON
                PFC.Program_Fixed_Component_Name_Id = N.Program_Fixed_Component_Name_Id
        INNER JOIN Formula_Program_Bracket_Data FPBD ON
            FPBD.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_Id and
            fpbd.Contract_Main_ID = cp.Contract_Main_ID
        WHERE
            FPBD.Formula_Program_Bracket_Data_ID = #a.BracketId# and
            CP.Deleted = 0 AND
            CP.Contract_main_id = #a.contractId# AND
            CP.Product_Type_Id = 1
    </CFQUERY>
    <!--- <cfscript>
        writedump(var="#res#", output="c:\dump.log");
    </cfscript> --->
    <cfreturn getBracketData(a.contractId)>
</cffunction>


<cffunction name="updateBracketUom" output="false" returntype="string" returnformat="JSON" access="remote">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <cfargument name="BracketId" type="numeric" required="true" >
    <cfargument name="uom" type="String" required="false" default = "0">
    <cfscript>
        var a = arguments;
        var uomId = 2;
        if(a.uom == 'CS'){
            uomId =1;
        }
    </cfscript>
    <CFQUERY NAME="updBracket" DATASOURCE="#application.datasource#">
            Update Formula_Program_Bracket_Data
            Set Rate_UOM_Desc = '#a.uom#',
                Rate_UOM_Id = #uomId#
            Where Formula_Program_Bracket_Data_Id = #a.BracketId#
    </CFQUERY>
    <CFQUERY NAME="recalc" DATASOURCE="#application.datasource#">
        UPDATE	 PD
        SET 	<cfif uomId eq 2>
                    Fixed_Price_Value = CAST(PD.Market_Price_Rate_Orig + FPBD.rate as DECIMAL(18,4))
                <cfelse>
                    Fixed_Price_Value = CAST(  ((PD.Market_Price_Rate_Orig + FPBD.rate)*I.net_weight ) as DECIMAL(18,4))
                </cfif>
        ,Unit_Of_Measure_ID = #uomId#
        FROM	Contract_Products CP
        INNER JOIN	dbo.Program_Fixed_Price_Product_Data PD ON
            PD.Contract_Products_ID = CP.Contract_Products_ID AND
            PD.Deleted = 0
        INNER JOIN Program_Fixed_Component PFC ON
                PFC.Program_Fixed_Component_ID  = PD.Program_Fixed_Component_ID
        INNER JOIN Program_Fixed_Component_Name N ON
                PFC.Program_Fixed_Component_Name_Id = N.Program_Fixed_Component_Name_Id
        INNER JOIN Formula_Program_Bracket_Data FPBD ON
            FPBD.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_Id and
            fpbd.Contract_Main_ID = cp.Contract_Main_ID
        INNER JOIN BSA_Foodservice_Items_Master I ON
            I.BSA_Foodservice_Items_Master_Id =  CP.BSA_Foodservice_Items_Master_Id
        WHERE
            FPBD.Formula_Program_Bracket_Data_ID = #a.BracketId# and
            CP.Deleted = 0 AND
            CP.Contract_main_id = #a.contractId# AND
            CP.Product_Type_Id = 1
    </CFQUERY>
    <cfreturn getBracketData(a.contractId)>
</cffunction>

<cffunction name="updateItemUom" output="false" returntype="string" returnformat="JSON" access="remote">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <cfargument name="contractProdId" type="numeric" required="true" >
    <cfargument name="uom" type="String" required="false" default = "0">
    <cfargument name="byComponent" type="String" required="false" default = "0">
    <cfscript>
        var a = arguments;
        var uomId = 2;
        if(a.uom == 'CS'){
            uomId =1;
        }
        //return '';

        objProgramManager =  CreateObject("component", "components.programs.ProgramManager");
        decimalLen = objProgramManager.decimalPrecisionByUOM(uomId,0,true);

    </cfscript>
<!--- 	<CFQUERY NAME="updBracket" DATASOURCE="#application.datasource#">
            Update Formula_Program_Bracket_Data
            Set Rate_UOM_Desc = '#a.uom#',
                Rate_UOM_Id = #uomId#
            Where Formula_Program_Bracket_Data_Id = #a.BracketId#
    </CFQUERY> --->
    <cfif arguments.byComponent eq 1>
        <!-----------------------------------------------------------------------------------------
        A program may have more than one component.
        We will update the UOM on all component records for the products.
        But fixed price value will only be updated on the component selected on the formula rule.
        ------------------------------------------------------------------------------------------->
        <cfquery name="recalc" datasource="#application.datasource#">
            UPDATE	PD
            SET 	<cfif uomId eq 2>
                        Fixed_Price_Value = CASE WHEN R.Program_Fixed_Component_ID =  PD.Program_Fixed_Component_ID THEN CAST(PD.Market_Price_Rate_Orig as DECIMAL(18,#decimalLen#)) ELSE 0.00 END
                    <cfelse>
                        Fixed_Price_Value = CASE WHEN R.Program_Fixed_Component_ID =  PD.Program_Fixed_Component_ID THEN CAST(((PD.Market_Price_Rate_Orig) * I.net_weight) as DECIMAL(18,#decimalLen#)) ELSE 0.00 END
                    </cfif>
                    ,Unit_Of_Measure_ID = #uomId#
            FROM	Contract_Products CP
                    INNER JOIN Program_Fixed_Price_Product_Data PD ON
                    PD.Contract_Products_ID = CP.Contract_Products_ID AND
                    PD.Deleted = 0
                    INNER JOIN BSA_Foodservice_Items_Master I ON
                    I.BSA_Foodservice_Items_Master_Id =  CP.BSA_Foodservice_Items_Master_Id
                    INNER JOIN Program_Formula_Pricing_Rules R On
                    R.Contract_Products_Id = CP.Contract_Products_Id AND R.Deleted = 0
            WHERE	CP.Deleted = 0
            AND		CP.Contract_main_id = #a.contractId#
            AND		CP.Contract_Products_Id = #a.contractProdId#
            AND		CP.Product_Type_Id = 1
        </cfquery>
    <cfelse>
    <CFQUERY NAME="recalc" DATASOURCE="#application.datasource#">
        UPDATE	 PD
        SET 	<cfif uomId eq 2>
                    Fixed_Price_Value = CAST(PD.Market_Price_Rate_Orig + FPBD.rate as DECIMAL(18,4))
                <cfelse>
                    Fixed_Price_Value = CAST(  ((PD.Market_Price_Rate_Orig + FPBD.rate)*I.net_weight ) as DECIMAL(18,4))
                </cfif>
        ,Unit_Of_Measure_ID = #uomId#
        FROM	Contract_Products CP
        INNER JOIN	dbo.Program_Fixed_Price_Product_Data PD ON
            PD.Contract_Products_ID = CP.Contract_Products_ID AND
            PD.Deleted = 0
        INNER JOIN Program_Fixed_Component PFC ON
                PFC.Program_Fixed_Component_ID  = PD.Program_Fixed_Component_ID
        INNER JOIN Program_Fixed_Component_Name N ON
                PFC.Program_Fixed_Component_Name_Id = N.Program_Fixed_Component_Name_Id
        INNER JOIN Formula_Program_Bracket_Data FPBD ON
            FPBD.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_Id and
            fpbd.Contract_Main_ID = cp.Contract_Main_ID
        INNER JOIN BSA_Foodservice_Items_Master I ON
            I.BSA_Foodservice_Items_Master_Id =  CP.BSA_Foodservice_Items_Master_Id
        WHERE
            CP.Deleted = 0 AND
            CP.Contract_main_id = #a.contractId# AND
            CP.Contract_Products_Id = #a.contractProdId# AND
            CP.Product_Type_Id = 1
    </CFQUERY>
    </cfif>
    <cfreturn getFormulaProducts(a.contractId)>
</cffunction>
<cffunction name="saveScheduleOption" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <cfargument name="optionId" type="numeric" required="false" default="0" />
        <cfscript>
        var a = arguments;
    </cfscript>
        <cfquery name="qSaveSchedule" datasource="#application.datasource#">
                Update Contract_Main
                SET Formula_Price_Rebate_Type = #a.optionId#
                where Contract_main_Id = #a.contractId#
        </cfquery>

        <cfquery name="qSaveScheduleRules" datasource="#application.datasource#">
                Update Program_Formula_Pricing_Rules
                SET FP_Schedule_Option_Id = #a.optionId#
                where Program_ID = #a.contractId# and
                        deleted = 0
        </cfquery>
        <!--- <cfdump var="#compIdList#" output="c:/dump.log" /> --->
    <cfreturn 'Schedule Saved'/>
</cffunction>

<cffunction name="checkFormulaComponent" hint="" access="public" output="false" returntype="numeric">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfscript>
        var a = arguments;
    </cfscript>
        <cfquery name="qSaveScheduleRules" datasource="#application.datasource#">
            SELECT Program_Fixed_Component_ID
            FROM Program_Fixed_Component PFC
            WHERE Program_ID = #a.contractId# AND
                    Deleted = 0
        </cfquery>
        <!--- <cfdump var="#compIdList#" output="c:/dump.log" /> --->
    <cfreturn qSaveScheduleRules.recordcount />
</cffunction>


<cffunction name="createFormulaComponents" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
    <cfargument name="contractId" type="numeric" required="false" default="0" />
    <!--- <cfargument name="Claim_Mechanics" type="numeric" required="false" default="0" /> --->

        <cfquery name="qSaveBrackets" datasource="#application.datasource#">
            DECLARE
            @Program_Fixed_Component_Name_ID int,
            @External_ID VarChar(150),
            @Bracket_Number INT,
            @Contract_Main_ID INT = '#arguments.contractId#',
            @Claim_Mechanics INT,
            @GL_account_Id INT,
            @Rate_UOM_Id INT = 2,
            @Program_Fixed_Component_ID INT,
            @Payment_Cycle_ID INT

            /* get default claim mechanics from the template */
            SELECT	@Claim_Mechanics = t.ClaimMechDefaultOption
            FROM	Contract_Main cm
            INNER JOIN  Program_Control_Panel_Options t
            ON		t.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
            WHERE	cm.Contract_Main_ID = '#arguments.contractId#'

            IF ISNULL(@Claim_Mechanics, 0) = 0
            BEGIN
                SELECT @Claim_Mechanics =  payment_Type_Id
                FROM Payment_Type where Payment_Type_Name like '%invoice%' and
                            deleted = 0
            END

            SELECT @Payment_Cycle_ID = Payment_Cycle_ID FROM Payment_Cycle WHERE Payment_Cycle like '%Upon Due%'

            -- UPDATE Contract_Main
            -- SET ClaimMechanics =
            -- WHERE Contract_Main_ID = @Contract_Main_ID
            /*
            UPDATE PFC Set Deleted = 1
            FROM Program_Fixed_Component PFC
            INNER JOIN Program_Fixed_Component_Name FN ON
                FN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
            LEFT JOIN Formula_Program_Bracket_Data GPTD ON
                FN.Program_Fixed_Component_Name_ID = GPTD.Program_Fixed_Component_Name_ID AND
                GPTD.Contract_Main_ID = PFC.Program_ID AND
                GPTD.Deleted = 0
            WHERE Program_ID = @Contract_Main_ID AND
                PFC.Deleted = 0 AND
                GPTD.Program_Fixed_Component_Name_ID IS NULL

             UPDATE PFPPD Set Deleted = 1
             FROM Program_Fixed_Price_Product_Data PFPPD
             LEFT JOIN Program_Fixed_Component PFC ON
                PFPPD.Program_ID = PFC.Program_Id AND
                PFC.Program_Fixed_Component_ID = PFPPD.Program_Fixed_Component_ID AND
                PFC.Deleted = 0
             WHERE PFPPD.Program_ID = @Contract_Main_ID And
                    PFPPD.Deleted = 0 AND
                    PFC.Program_Fixed_Component_ID IS NULL
            */
            DECLARE tmp_cursor CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
                SELECT F.Program_Fixed_Component_Name_ID, External_ID, T.Bracket_Number, GL_account_Id
                FROM Formula_Program_Bracket_Data T
                INNER JOIN Program_Fixed_Component_Name f ON
                        F.Program_Fixed_Component_Name_ID = t.Program_Fixed_Component_Name_ID
                LEFT JOIN GL_Component_Mapping GCM
                    ON GCM.Discount_Type_ID = 1
                    AND GCM.Component_Name_ID = f.Program_Fixed_Component_Name_ID
                WHERE Contract_Main_ID = @Contract_Main_ID
                    AND T.Deleted = 0
                    AND NOT Exists(
                                    SELECT Program_Fixed_Component_Name_ID
                                    FROM Program_Fixed_Component PFC
                                    WHERE Program_ID = @Contract_Main_ID AND
                                            Deleted = 0 AND
                                            Program_Fixed_Component_Name_ID = F.Program_Fixed_Component_Name_ID
                                )

                ORDER BY T.Bracket_Number

                OPEN tmp_cursor

                    FETCH NEXT FROM tmp_cursor
                    INTO @Program_Fixed_Component_Name_ID, @External_ID, @Bracket_Number, @GL_account_Id

                        WHILE @@FETCH_STATUS = 0
                        BEGIN
                        --Do Something
                        SET NOCOUNT ON
                        ---- UPDATE Tier Data
                        -- UPDATE GPO_Program_Tier_Data
                        -- SET Program_Fixed_Component_Name_ID = @Program_Fixed_Component_Name_ID
                        -- WHERE Bracket_Number = @Bracket_Number AND
                        -- 	  Contract_Main_ID = @Contract_Main_ID
                        ---- INSERT Component

                        INSERT INTO Program_Fixed_Component
                        (
                            Program_Fixed_Component_Name_ID,
                            Fixed_Component_Paid_To,
                            Program_ID,
                            Claim_Mechanics,
                            GL_Account_ID,
                            Component_External_ID
                            --,Payee_Type
                        )
                        VALUES
                        (
                            @Program_Fixed_Component_Name_ID,
                            1,
                            @Contract_Main_ID,
                            @Claim_Mechanics,
                            @GL_account_Id,
                            @External_ID
                        )
                        SELECT @Program_Fixed_Component_ID = @@IDENTITY
                        SET NOCOUNT OFF

                        INSERT INTO Program_Payment_Cycle
                            (Program_ID, Discount_Type_Id, Payment_Cycle_ID,Component_ID)
                        VALUES
                            (@Contract_Main_ID,'1',@Payment_Cycle_ID,@Program_Fixed_Component_ID)


                            -- Get the next tmp.
                        FETCH NEXT FROM tmp_cursor
                        INTO @Program_Fixed_Component_Name_ID, @External_ID, @Bracket_Number, @GL_account_Id
                    END
                CLOSE tmp_cursor
            DEALLOCATE tmp_cursor


                INSERT INTO Program_Fixed_Price_Product_Data
                        (Program_ID, Contract_Products_ID, Fixed_Price_Value, Unit_Of_Measure_ID, Program_Fixed_Component_ID)
                SELECT CP.Contract_Main_Id, CP.Contract_Products_ID, 0, ISNULL(X.Unit_Of_Measure_ID,2), PFC.Program_Fixed_Component_ID
                FROM Contract_Products CP
                INNER JOIN Program_Fixed_Component PFC ON
                    CP.Contract_Main_Id = PFC.Program_Id AND
                    PFC.Deleted = 0
                LEFT JOIN Program_Fixed_Price_Product_Data PFPPD ON
                    PFPPD.Program_ID = PFC.Program_Id AND
                    PFC.Program_Fixed_Component_ID = PFPPD.Program_Fixed_Component_ID AND
                    PFPPD.Contract_Products_ID = CP.Contract_Products_ID AND
                    PFPPD.deleted = 0
                OUTER APPLY (
                    select top 1 Unit_Of_Measure_ID
                    FROM  Program_Fixed_Price_Product_Data PFPPD2
                    where PFPPD2.Contract_Products_ID = PFPPD.Contract_Products_ID AND
                        PFPPD2.deleted = 0

                ) X
                WHERE CP.Contract_Main_Id = @Contract_Main_ID AND
                        PFPPD.Program_ID IS NULL

        </cfquery>
        <!--- re- run formula calc --->
        <cfquery name="qGetBracketsToInsert" datasource="#application.datasource#">
            DECLARE
            @tmp_id uniqueidentifier,
            @tmp_name VarChar(50)

            DECLARE tmp_cursor_formula CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
            SELECT Program_Formula_Pricing_Rule_ID
            FROM Program_Formula_Pricing_Rules
            where program_Id = '#arguments.contractId#' and deleted = 0

            OPEN tmp_cursor_formula

            FETCH NEXT FROM tmp_cursor_formula
            INTO @tmp_id

            WHILE @@FETCH_STATUS = 0
            BEGIN
            --Recalc Formula
             exec Formula_Price_Item_Calculation  @tmp_id

                    -- Get the next tmp.
                FETCH NEXT FROM tmp_cursor_formula
                INTO @tmp_id
            END
            CLOSE tmp_cursor_formula
            DEALLOCATE tmp_cursor_formula
        </cfquery>

        <!--- <cfset program_fixed_component_id = addNewFixedCategory.Program_Fixed_Component_ID> --->
    <!--- <cfreturn getBracketProducts( #arguments.contractId# ) /> --->

    <cfreturn 'DONE CREATE' />
</cffunction>



<cffunction name="getFormulaProducts" hint="getCpaProducts" access="remote" output="false" returntype="string" returnformat="JSON">
        <cfargument name="contractId" type="numeric" required="true" default="0" />
        <cfargument name="ContractProdId" type="numeric" required="false" default="0" />
        <cfargument name="ProdId" type="string" required="false" default="" />
        <cfscript>
            var jsonData = '';
            var a = arguments;
            jsonData = serializeJson(getFormulaProductsObject(a.contractId,a.ContractProdId,a.ProdId));
            //writedump(var=form,output='c:\dump.log');
        </cfscript>

        <cfreturn jsonData/>
    </cffunction>

    <cffunction name="getFormulaProductsObject" hint="" access="Public" output="false" returntype="Array">
        <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfargument name="ContractProdId" type="numeric" required="false" default="0" />
        <cfargument name="ProdId" type="string" required="false" default="" />
        <cfscript>
            // stuff
            var a = arguments;
        </cfscript>


        <cfquery name="qGetCpaFixedFComps" datasource="#application.datasource#">
                SELECT PFC.Program_Fixed_Component_ID,
                       PFCN.Program_Fixed_Component_Name_ID,
                       PFCN.Program_Fixed_Component_Name
                FROM Program_Fixed_Component PFC
                INNER JOIN Program_Fixed_Component_Name PFCN
                    ON PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
                WHERE PFC.Program_ID = #a.contractId# AND
                        PFC.Deleted = 0 AND
                        PFCN.Deleted = 0
        </cfquery>
        <cfscript>
            var data = {};
            var data2 = {};
            var aResult = [];
            var qFixedComps = qGetCpaFixedFComps;
            var qProdData = '';
            var qProdFixData = '';
            var id = 0;
            var i = 1;
            var p = 1;
            i=1;
             //writedump(var=qFixedComps,output='c:\dump.log');
            //-------------------------------------   GET FIXED   ------------------------------
            for (compFixRow in qFixedComps) {
                qProdFixData = getFormulaFixedProductData(compFixRow.Program_Fixed_Component_ID,a.contractId,a.ProdId);
               // writedump(var=qProdFixData,output='c:\dump.log');
                p=1;
                for (dataFixRow in qProdFixData) {
                     data = {};
                     id = compFixRow.Program_Fixed_Component_ID;
                     nameId = compFixRow.Program_Fixed_Component_Name_ID;
                     if(! Isnumeric(dataFixRow.fixed_price_value)){
                         dataFixRow.fixed_price_value = 0;
                    }
                    data['program_fixed_component_id_#id#'] = compFixRow.program_fixed_component_id;
                    data['program_fixed_component_name_id_#id#'] = compFixRow.program_fixed_component_name_id;
                    data['program_fixed_component_name_#id#'] = compFixRow.program_fixed_component_name;
                       data['program_fixed_price_product_data_id_#id#']= dataFixRow.program_fixed_price_product_data_id;
                       data['program_fixed_component_id_byname_#nameId#']= dataFixRow.program_fixed_component_id;
                       data['rate_#id#'] = dataFixRow.fixed_price_value;
                    data['unit_of_measure_id_#id#'] = dataFixRow.unit_of_measure_id;
                    if(i==1){
                        data['contract_products_id_fixed']= dataFixRow.contract_products_id;
                        data['contract_products_id']= dataFixRow.contract_products_id;
                        data['item'] = dataFixRow.item;
                        data['description'] = dataFixRow.description;
                        data['netweight'] = dataFixRow.net_weight;
                        data['uom'] = dataFixRow.uom;
                        data['bsa_foodservice_items_master_id'] = dataFixRow.bsa_foodservice_items_master_id;
                        aResult.append(data);
                    }
                    else{
                    data2 = {};
                    data2 = aResult[P];
                    data2.Append(data);
                    aResult[P] = data2;
                    }
                    p++;
                }
                i++;
            }
            //jsonData = serializeJson(aResult);
            //writedump(var=aResult,output='c:\dump.log');
        </cfscript>

        <cfreturn aResult/>
    </cffunction>

    <cffunction name="getFormulaFixedProductData" hint="getCpaFixedProductData" access="public" output="false" returntype="query">
        <cfargument name="ComponentId" type="numeric" required="false" default="0" />
        <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfargument name="ProdId" type="string" required="false" default="" />

        <cfquery name="qGetFormulaFixedProductData" datasource="#application.datasource#">
                SELECT PFC.Program_Fixed_Component_ID,
                      PFPPD.Program_Fixed_Price_Product_Data_ID,
                      PFPPD.Fixed_Price_Value,
                      PFPPD.Unit_Of_Measure_Id,
                      PFC.Program_Fixed_Component_Name_ID,
                      PFCN.Program_Fixed_Component_Name,
                      CP.Contract_Products_Id,
                      CP.BSA_Foodservice_Items_Master_Id,
                      I.Item,
                      I.description,
                      I.net_weight,
                      CASE WHEN Unit_Of_Measure_ID = 2 THEN 'LBS'
                            WHEN Unit_Of_Measure_ID = 1 THEN 'CS'
                            ELSE 'CS'
                        END AS uom
                FROM Program_Fixed_Component PFC
                INNER JOIN Program_Fixed_Component_Name PFCN ON
                    PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
                INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
                    PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID
                INNER JOIN Contract_Products CP ON
                    CP.Contract_Products_ID = PFPPD.Contract_Products_ID
                INNER JOIN BSA_Foodservice_Items_Master I ON I.BSA_Foodservice_Items_Master_Id = CP.BSA_Foodservice_Items_Master_Id
                WHERE PFC.Program_ID = #arguments.contractId#  AND
                    PFC.Program_Fixed_Component_Id =  #arguments.ComponentId# AND
                    PFPPD.Program_ID = #arguments.contractId# AND
                    CP.Deleted = 0 AND
                    PFC.Deleted = 0 AND
                    PFPPD.Deleted = 0
                    <cfif arguments.ProdID NEQ ''>
                        AND I.Item = '#arguments.ProdId#'
                    </cfif>
                order by I.Item,CP.BSA_Foodservice_Items_Master_Id DESC
        </cfquery>

        <cfreturn qGetFormulaFixedProductData />
    </cffunction>

    <cffunction name="saveSelectedProducts" hint="save" access="remote" output="false" returntype="string" returnformat="JSON">
        <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfargument name="arrData" type="any" required="false" default="0" />

        <cfscript>
            // stuff
            try {
                var a = arguments;

                var arr = deserializeJSON(arguments.arrData);
                //writedump(var=arr,output='c:\dump.log');
                var form = structNew();
                for (i=1;i LTE ArrayLen(arr);i=i+1) {
                    form['#arr[i].name#'] = arr[i].value;
                }
                var arrProds = ListToArray(Form.Product_List);
                var existingProds = ListToArray(Form.ExistingProductList);
                var existingProdsTmp = ListToArray(Form.ExistingProductList);

                // get list of existing items we need to delete -> not in Product_List means see ya.
                for (n=1;n LTE ArrayLen(arrProds);n=n+1) {
                    existingProds.delete(arrProds[n]);
                }
                //Only insert New Products so clean up the "new" list
                for (n=1;n LTE ArrayLen(existingProdsTmp);n=n+1) {
                    arrProds.delete(existingProdsTmp[n]);
                }

                insProds = ArrayToList(arrProds);
                delProds = ArrayToList(existingProds);
                //writedump(var=delProds,output='c:\dump.log');

            }
            catch (any e) {
                writedump(var=e,output='c:\dump.log');
                throw(message=e.message);
            }
        </cfscript>
        <cftry>
            <cfif len(trim(insProds)) GT 0>
                <cfquery name="qInsSelectedFixedContractProd" datasource="#application.datasource#" result='qResult'>
                    INSERT INTO Contract_Products(
                            Contract_Main_ID,
                            BSA_Foodservice_Items_Master_ID,
                            Base_Sales_CS,
                            Date_Created,
                            Deleted,
                            Product_Type_ID,
                            Product_Process_Flag,
                            Pricing_Level_ID,
                            Is_Group,
                            Product_Group_Level_ID,
                            Dynamic_Static_Groups,
                            Discounted_Item,
                            Captured_From_Group,
                            EZButton_On_Default,
                            products_not_captured_flag,
                            Include_In_Margin,
                            Include_In_Volume
                        )
                    SELECT	#a.contractId#,
                        I.BSA_Foodservice_Items_Master_Id,
                        CAST(0 AS Decimal(12,4))  AS Base_Sales_CS,
                        GETDATE() AS Created_Date,
                        0 AS Deleted,
                        1 AS Product_Type_ID,
                        0 AS Product_Process_Flag,
                        1 AS Pricing_Level_ID,
                        0 AS Is_Group,
                        0 AS Product_Group_Level_ID,
                        0 AS Dynamic_Static_Groups,
                        1 AS Discounted_Item,
                        0 AS Captured_From_Group,
                        0 AS EZButton_On_Default,
                        0 AS products_not_captured_flag,
                        1 AS Include_In_Margin,
                        1 AS Include_In_Volume
                    FROM BSA_Foodservice_Items_Master I
                    WHERE I.BSA_Foodservice_Items_Master_Id in (<cfqueryparam value="#insProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

                </cfquery>
                <!--- <cfdump var="#qResult#" output="c:\dump.log"> --->
                <cfquery name="qInsCPAFixedCompData" datasource="#application.datasource#">
                    INSERT INTO Program_Fixed_Price_Product_Data (
                            Program_ID,
                            Contract_Products_ID,
                            Fixed_Price_Value,
                            Unit_Of_Measure_ID,
                            Program_Fixed_Component_ID
                        )
                        SELECT
                            CM.Contract_Main_Id,
                            CP.Contract_Products_Id,
                            CP.Base_Sales_Cs,
                            2 as Unit_Of_Measure_ID,
                            PFC.Program_Fixed_Component_ID
                        FROM Contract_Main CM
                        INNER JOIN Program_Fixed_Component PFC ON
                            PFC.Program_ID = CM.Contract_Main_Id AND
                            PFC.Deleted = 0
                        INNER JOIN Contract_Products CP ON
                            CP.Contract_Main_Id = CM.Contract_Main_Id AND
                            CP.BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#insProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
                        WHERE CM.Contract_Main_Id = #a.contractId#  AND
                                CP.Deleted = 0 AND
                                CP.Product_Type_ID = 1
                </cfquery>
            </cfif>
            <cfif len(trim(delProds)) GT 0>
                <cfquery name="qDeleteCPArebate" datasource="#application.datasource#">
                    DELETE PFPPD
                    FROM  Contract_Products CP
                    INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
                        PFPPD.Contract_Products_ID = CP.Contract_Products_ID
                    WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
                        CP.Product_Type_ID = 1 AND
                        CP.BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#delProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

                    DELETE FROM Contract_Products WHERE Contract_Main_Id = #a.contractId# AND BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#delProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

                </cfquery>
            </cfif>

            <cfcatch>
                <cfdump var="#cfcatch#" output="c:\dump.log">
                <cfrethrow>
            </cfcatch>
        </cftry>

        <cfreturn getFormulaProducts(a.contractId) />

    </cffunction>

    <cffunction name="deleteBracketProducts" hint="Mass Apply Rates" access="remote" output="false" returntype="string" returnformat="JSON">
        <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfargument name="aData" type="any" required="true" />
            <cfscript>
                // stuff
                var arrData = deserializeJson(aData);
                var a = arguments;
                var lCPid = '';
                for (i=1; i <= arrayLen(arrData);i=i+1) {
                    st = arrData[i];
                        lCPid = listappend(lCPid,st.contract_products_id);
                }
            </cfscript>
            <cfquery name="qDeletSelectedFormulaProds" datasource="#application.datasource#" result='qDeletSelectedCPAProds'>

                UPDATE PFPPD set deleted = 1
                FROM  Contract_Products CP
                INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
                    PFPPD.Contract_Products_ID = CP.Contract_Products_ID
                WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
                    CP.Product_Type_ID = 1 AND
                    CP.Contract_Products_ID in (<cfqueryparam value="#lCPid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

                UPDATE Contract_Products SET DELETED = 1
                where Contract_Main_Id = #a.contractId# AND
                    Contract_Products_Id IN(<cfqueryparam value="#lCPid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

                UPDATE Program_Formula_Pricing_Rules SET Contract_Products_Id = 0 , Program_Id = 0
                WHERE Contract_Products_Id IN(<cfqueryparam value="#lCPid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
            </cfquery>

            <cfreturn 'DELETE_Formula PRODUCTS'/>
    </cffunction>


    <cffunction name="getSavedFormulas" hint="Saved Formulas" access="remote" output="false" returntype="any">
        <cfargument name="contractId" type="numeric" required="false" default="0" />

        <cfquery name="qgetSavedFormula" datasource="#application.datasource#">
                SELECT Program_Formula_Pricing_Rule_ID,
                        Program_ID,
                        Rule_Name,
                        Number_Of_Comms,
                        Created_Date,
                        Formula_Price
                FROM Program_Formula_Pricing_Rules
                WHERE Saved = 1 AND Deleted = 0
        </cfquery>

        <cfreturn qgetSavedFormula />

    </cffunction>
    <cffunction name="removeFromSaved" hint="Saved Formulas" access="remote" output="false" returntype="string" returnformat="JSON">
        <cfargument name="Program_Formula_Pricing_Rule_ID" type="any" required="false" default="" />

        <cfquery name="qremoveFromSaved" datasource="#application.datasource#">
                UPDATE  Program_Formula_Pricing_Rules SET Saved = 0
                WHERE Program_Formula_Pricing_Rule_ID = '#arguments.Program_Formula_Pricing_Rule_ID#'
        </cfquery>

        <cfreturn application.util.query.toAgGridJSON(this.getSavedFormulas(), 'Program_Formula_Pricing_Rule_ID, Program_ID, Rule_Name, Formula_Price') />

    </cffunction>

    <cffunction name="createFromSaved" hint="create from saved Formula" access="remote" output="false" returntype="any">
        <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfargument name="formulaId" type="string" required="true" default="" />
        <cfargument name="contractProductsId" type="numeric" required="true" default="" />
        <cfargument name="oldFormulaId" type="string" required="true" default="" />
        <cfscript>
            var a = arguments;
        </cfscript>
        
        <!--- Handling for retroactive dates for this client --->
        <cfif application.util.query.get_setting('Margin_Display_Style') EQ "CUSTOM_T">
            
            <cfquery name="qGetContractStart" datasource="#application.datasource#">
                select	Contract_Start_Date, Formula_Price_Rebate_Type as Schedule_ID
                from	Contract_Main
                where 	Contract_Main_ID = '#a.contractId#'
            </cfquery>

            <cfset processDate = getRetroactiveCalcProcDate(qGetContractStart.Contract_Start_Date, Val(qGetContractStart.Schedule_ID), '') />
            
        <cfelse>
            <cfset processDate = "NULL" />
        </cfif>

        <cfquery name="qCreateFromSavedDel" datasource="#application.datasource#">
                UPDATE Program_Formula_Pricing_Rules
                SET Contract_Products_Id = 0 , Program_Id = 0
                WHERE Contract_Products_Id = '#a.contractProductsId#'

                UPDATE Program_Formula_Pricing_Rules
                SET deleted = 1
                WHERE Contract_Products_Id = '#a.contractProductsId#' AND Saved = 0
        </cfquery>

        <cfquery name="qCreateFromSaved" datasource="#application.datasource#">
                DECLARE
                @newRule table (formula_id uniqueidentifier)

                DECLARE
                @newCom table (Com_id uniqueidentifier)

                declare
                @formulaId uniqueidentifier,
                @comId uniqueidentifier,
                @processDate Date = NULL
            
                <cfif processDate NEQ "NULL">
                    SET @processDate = '#DateFormat(processDate, "mm/dd/yyyy")#'
                </cfif>

                    INSERT INTO Program_Formula_Pricing_Rules(Program_ID,Rule_Name,Number_Of_Comms,
                            FP_Schedule_Option_ID,FP_Formula_Type_ID,Formula_Price,Contract_Products_Id,Active)
                            OUTPUT INSERTED.Program_Formula_Pricing_Rule_ID
                        INTO @newRule
                    SELECT	'#a.contractId#' , Rule_Name, Number_Of_Comms,
                            R.FP_Schedule_Option_ID, R.FP_Formula_Type_ID, Formula_Price, '#a.contractProductsId#', 1
                    FROM Program_Formula_Pricing_Rules R
                    WHERE	R.Program_Formula_Pricing_Rule_ID = '#a.formulaId#' AND
                            R.Deleted = 0
                select @formulaId = formula_id from @newRule

                UPDATE R SET FP_Schedule_Option_ID = (SELECT Formula_Price_Rebate_Type from Contract_main Where contract_main_id = '#a.contractId#')
                FROM Program_Formula_Pricing_Rules R
                WHERE R.Program_Formula_Pricing_Rule_ID =  @formulaId
                  AND R.Deleted = 0


                DECLARE
                @tmp_id uniqueidentifier

                DECLARE tmp_cursor_Fpco CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
                    SELECT	Program_Formula_Pricing_Rule_Comm_Data_Id
                    FROM	Program_Formula_Pricing_Rule_Comm_Data CD
                    WHERE CD.Program_Formula_Pricing_Rule_ID = '#a.formulaId#' AND
                            CD.Deleted = 0

                OPEN tmp_cursor_Fpco

                FETCH NEXT FROM tmp_cursor_Fpco
                INTO @tmp_id

                WHILE @@FETCH_STATUS = 0
                BEGIN
                    INSERT INTO Program_Formula_Pricing_Rule_Comm_Data
                                (Program_ID, Program_Formula_Pricing_Rule_ID, Comm_Count, Exchange,Symbol,
                                Weight, Commodities_Symbol_ID, Start_Price, Compound_Price,
                                Independent_Price, Final_Price, FP_Formula_Type_ID, Active)
                                OUTPUT INSERTED.Program_Formula_Pricing_Rule_Comm_Data_ID
                                INTO @newCom
                    SELECT	'#a.contractId#', @formulaId, Comm_Count, Exchange,Symbol,
                                Weight, Commodities_Symbol_ID, Start_Price, Compound_Price,
                                Independent_Price, Final_Price, FP_Formula_Type_ID, 1
                    FROM	Program_Formula_Pricing_Rule_Comm_Data CD
                    WHERE CD.Program_Formula_Pricing_Rule_Comm_Data_Id = @tmp_id

                    select @comId = com_id from @newCom
                    select @comId

                    INSERT INTO Formula_Pricing_Commodity_Overage
                                    (Program_Formula_Pricing_Rule_ID, Program_Formula_Pricing_Rule_Comm_Data_ID,
                                    Overage_Index, Description, Amount, UOM, Calc_Type)
                    SELECT	@formulaId, @comId,
                            Overage_Index, Description, Amount, UOM, Calc_Type
                    FROM	Formula_Pricing_Commodity_Overage
                    WHERE Program_Formula_Pricing_Rule_ID = '#a.formulaId#' AND
                            Program_Formula_Pricing_Rule_Comm_Data_Id = @tmp_id AND
                            Deleted = 0

                        -- Get the next tmp.
                    FETCH NEXT FROM tmp_cursor_Fpco
                    INTO @tmp_id
                END
                CLOSE tmp_cursor_Fpco
                DEALLOCATE tmp_cursor_Fpco

                EXEC  Formula_Price_Item_Calculation  @formulaId, @processDate
        </cfquery>

        <cfreturn 'createFromSaved' />

    </cffunction>

    <cffunction name="createFromSavedRFP" hint="create from saved Formula" access="remote" output="false" returntype="any">
        <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfargument name="formulaId" type="string" required="true" default="" />
        <cfargument name="contractProductsId" type="numeric" required="true" default="" />
        <cfargument name="oldFormulaId" type="string" required="true" default="" />
        <cfscript>
            var a = arguments;
        </cfscript>

        <cfquery name="qCreateFromSavedDel" datasource="#application.datasource#">
                UPDATE Program_Formula_Pricing_Rules
                SET Contract_Products_Id = 0 , Program_Id = 0
                WHERE Program_Formula_Pricing_Rule_ID = '#a.oldFormulaId#'

                UPDATE Program_Formula_Pricing_Rules
                SET deleted = 1
                WHERE Program_Formula_Pricing_Rule_ID = '#a.oldFormulaId#' AND Saved = 0
        </cfquery>

        <cfquery name="qCreateFromSaved" datasource="#application.datasource#">
                DECLARE
                @newRule table (formula_id uniqueidentifier)

                DECLARE
                @newCom table (Com_id uniqueidentifier)

                declare
                @formulaId uniqueidentifier,
                @comId uniqueidentifier

                    INSERT INTO Program_Formula_Pricing_Rules(Program_ID,Rule_Name,Number_Of_Comms,
                            FP_Schedule_Option_ID,FP_Formula_Type_ID,Formula_Price,Contract_Products_Id,Active)
                            OUTPUT INSERTED.Program_Formula_Pricing_Rule_ID
                        INTO @newRule
                    SELECT	'#a.contractId#' , Rule_Name, Number_Of_Comms,
                            R.FP_Schedule_Option_ID, R.FP_Formula_Type_ID, Formula_Price, '#a.contractProductsId#', 1
                    FROM Program_Formula_Pricing_Rules R
                    WHERE	R.Program_Formula_Pricing_Rule_ID = '#a.formulaId#' AND
                            R.Deleted = 0
                select @formulaId = formula_id from @newRule

                UPDATE R SET FP_Schedule_Option_ID = (SELECT Formula_Price_Rebate_Type from Contract_main Where contract_main_id = '#a.contractId#')
                FROM Program_Formula_Pricing_Rules R
                WHERE R.Program_Formula_Pricing_Rule_ID =  @formulaId
                  AND R.Deleted = 0

                UPDATE R
                    SET Program_Fixed_Component_Id = PFC.Program_Fixed_Component_Id,
                        R.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_Id
                    FROM Program_Formula_Pricing_Rules R
                    INNER JOIN Program_Fixed_Component PFC ON
                        PFC.Program_Id = R.Program_Id
                    WHERE R.Program_Id = '#a.contractId#' AND
                        PFC.Deleted = 0 AND
                        R.Deleted = 0


                DECLARE
                @tmp_id uniqueidentifier

                DECLARE tmp_cursor_Fpco CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
                    SELECT	Program_Formula_Pricing_Rule_Comm_Data_Id
                    FROM	Program_Formula_Pricing_Rule_Comm_Data CD
                    WHERE CD.Program_Formula_Pricing_Rule_ID = '#a.formulaId#' AND
                            CD.Deleted = 0

                OPEN tmp_cursor_Fpco

                FETCH NEXT FROM tmp_cursor_Fpco
                INTO @tmp_id

                WHILE @@FETCH_STATUS = 0
                BEGIN
                    INSERT INTO Program_Formula_Pricing_Rule_Comm_Data
                                (Program_ID, Program_Formula_Pricing_Rule_ID, Comm_Count, Exchange,Symbol,
                                Weight, Commodities_Symbol_ID, Start_Price, Compound_Price,
                                Independent_Price, Final_Price, FP_Formula_Type_ID, Active,Comm_End_Price)
                                OUTPUT INSERTED.Program_Formula_Pricing_Rule_Comm_Data_ID
                                INTO @newCom
                    SELECT	'#a.contractId#', @formulaId, Comm_Count, Exchange,Symbol,
                                Weight, Commodities_Symbol_ID, Start_Price, Compound_Price,
                                Independent_Price, Final_Price, FP_Formula_Type_ID, 1, Comm_End_Price
                    FROM	Program_Formula_Pricing_Rule_Comm_Data CD
                    WHERE CD.Program_Formula_Pricing_Rule_Comm_Data_Id = @tmp_id

                    select @comId = com_id from @newCom
                    select @comId

                    INSERT INTO Formula_Pricing_Commodity_Overage
                                    (Program_Formula_Pricing_Rule_ID, Program_Formula_Pricing_Rule_Comm_Data_ID,
                                    Overage_Index, Description, Amount, UOM, Calc_Type)
                    SELECT	@formulaId, @comId,
                            Overage_Index, Description, Amount, UOM, Calc_Type
                    FROM	Formula_Pricing_Commodity_Overage
                    WHERE Program_Formula_Pricing_Rule_ID = '#a.formulaId#' AND
                            Program_Formula_Pricing_Rule_Comm_Data_Id = @tmp_id AND
                            Deleted = 0

                        -- Get the next tmp.
                    FETCH NEXT FROM tmp_cursor_Fpco
                    INTO @tmp_id
                END
                CLOSE tmp_cursor_Fpco
                DEALLOCATE tmp_cursor_Fpco

                EXEC  Formula_Price_RFP_Calculation  @formulaId
        </cfquery>

        <cfreturn 'createFromSaved' />

    </cffunction>

    <cffunction name="QueryToArray" access="public" returntype="array" output="false" hint="This turns a query into an array of structures.">
        <!--- Define arguments. --->
        <cfargument name="Data" type="query" required="yes" />
        <cfscript>
            var LOCAL = StructNew();
            LOCAL.Columns = ListToArray( ARGUMENTS.Data.ColumnList );
            LOCAL.QueryArray = ArrayNew( 1 );
            for (LOCAL.RowIndex = 1 ; LOCAL.RowIndex LTE ARGUMENTS.Data.RecordCount ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){
                LOCAL.Row = StructNew();
                for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE ArrayLen( LOCAL.Columns ) ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){
                    LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];
                    LOCAL.Row[ LOCAL.ColumnName ] = ARGUMENTS.Data[ LOCAL.ColumnName ][ LOCAL.RowIndex ];
                }
                ArrayAppend( LOCAL.QueryArray, LOCAL.Row );
            }
            return( LOCAL.QueryArray );
        </cfscript>
    </cffunction>

    <cffunction name="getFPFixedComps" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
        <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfargument name="hasData" type="numeric" required="false" default="0" />
            <cfscript>
                // stuff
                var a = arguments;
            </cfscript>
            <cfquery name="qGetFPFixedComps" datasource="#application.datasource#">
                SELECT 	'' AS chkbox,
                        F.Program_Fixed_Component_Name_Id as CompId,
                        F.Program_Fixed_Component_Name as name,
                        CASE WHEN PFC.Program_Fixed_Component_Id IS NOT NULL THEN 1
                        ELSE 0
                        END AS Selected,
                        CASE WHEN  F.OFF_Invoice_On = 1 THEN
                            ISNULL(nullif(PFC.Claim_Mechanics,0),PTOI.Payment_Type_ID)
                        ELSE ISNULL(nullif(PFC.Claim_Mechanics,0),PT.Payment_Type_ID)
                        END AS pay_id,
                        CASE WHEN  F.OFF_Invoice_On = 1 THEN
                            PTOI.Payment_type_Name
                        ELSE PT.Payment_type_Name
                        END as pay_name,
                        ISNULL(PFC.Program_Fixed_Component_Id,0) as prg_comp_id
                FROM 	Contract_Main CM
                INNER JOIN	Program_Control_Panel_Options PCPO ON
                    CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
                INNER JOIN Program_Template_Component ptc ON
                    ptc.Template_ID = pcpo.ProgramControl_Panel_Options_ID
                INNER JOIN Payment_Template_Mapping PTM on PTM.Template_ID =  PCPO.ProgramControl_Panel_Options_ID
                INNER JOIN Program_Fixed_Component_Name F ON
                    F.Program_Fixed_Component_Name_Id = PTC.Component_Id
                LEFT JOIN Program_Fixed_Component PFC ON
                    PFC.Program_Id = CM.Contract_Main_Id AND
                    PFC.Program_Fixed_Component_Name_Id = F.Program_Fixed_Component_Name_Id AND
                    PFC.Deleted = 0
                LEFT JOIN Program_Fixed_Component_Profile PFCP ON
                    PFCP.Program_Fixed_Component_Name_ID = F.Program_Fixed_Component_Name_Id AND
                    PFCP.Profiles_ID = #request.AccessStructure.Profiles_ID# AND
                    PFCP.Deleted = 0
                LEFT JOIN Payment_Type PT ON PT.Payment_Type_ID = PTM.Payment_Type_ID AND PT.Off_Invoice = 0
                LEFT JOIN Payment_Type PTOI ON PTOI.Payment_Type_ID =  PTM.Payment_Type_ID AND PTOI.Off_Invoice = 1
                WHERE CM.Contract_Main_Id = '#a.contractId#' AND
                PTC.Deleted = 0 AND
                F.Deleted = 0 AND
                PTC.Discount_Type_Id = 1 AND
                (
                    (   PT.Payment_Type_ID IS NOT NULL AND F.OFF_Invoice_On = 0) OR
                    ( PTOI.Payment_Type_ID is not null AND F.OFF_Invoice_On = 1)
                ) AND
                ISNULL(PFCP.Allow_User_To_View,1) = 1
                ORDER BY F.Program_Fixed_Component_Name
            </cfquery>
        <cfreturn application.util.query.toAgGridJSON(qGetFPFixedComps, 'compid,name,selected,pay_id,pay_name,prg_comp_id')  />
    </cffunction>
    <cffunction name="saveFPFixedComp" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
        <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfargument name="Component_Name_ID" type="numeric" required="false" default="0" />
        <cfargument name="Claim_Mechanics" type="numeric" required="false" default="0" />
            <cfquery name="qInsFPFixedComps" datasource="#application.datasource#" result="q">
                INSERT INTO Program_Fixed_Component
                        (Program_ID,Program_Fixed_Component_Name_Id,Fixed_Component_Paid_To, Claim_Mechanics, GL_account_Id)
                SELECT #arguments.contractId#,
                    PFCN.Program_Fixed_Component_Name_Id,
                    ISNULL(PTC.Default_Paid_To_CF_Pages,1) AS Fixed_Component_Paid_To,
                    #arguments.Claim_Mechanics# AS Claim_Mechanics,
                    GCM.GL_Account_Id
                FROM Program_Fixed_Component_Name PFCN
                INNER JOIN Contract_Main CM ON
                    CM.Contract_Main_ID = #arguments.contractId#
                INNER JOIN Program_Control_Panel_Options PCPO ON
                    PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
                LEFT JOIN GL_Component_Mapping GCM
                    ON GCM.Discount_Type_ID = 1
                    AND GCM.Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
                LEFT JOIN Program_Template_Component PTC ON
                    Template_Id = PCPO.ProgramControl_Panel_Options_ID AND
                    PTC.Discount_Type_Id = 1 AND
                    PTC.Component_Id = PFCN.Program_Fixed_Component_Name_ID AND
                    PTC.Deleted = 0
                WHERE Program_Fixed_Component_Name_id = #arguments.Component_Name_ID# AND
                        PFCN.Deleted = 0 AND
                         NOT EXISTS(
                                SELECT Program_ID FROM Program_Fixed_Component PFC2
                                WHERE PFC2.Program_ID = #arguments.contractId# AND
                                        PFC2.Deleted = 0 AND
                                        PFC2.Program_Fixed_Component_Name_id = #arguments.Component_Name_ID#
                            )
                UPDATE Contract_Main
                SET ClaimMechanics = '#arguments.Claim_Mechanics#'
                WHERE Contract_Main_ID = #arguments.contractId#
            </cfquery>
            <cfquery name="qInsFPFixedCompData" datasource="#application.datasource#">
                    INSERT INTO Program_Fixed_Price_Product_Data (
                            Program_ID,
                            Contract_Products_ID,
                            Fixed_Price_Value,
                            Unit_Of_Measure_ID,
                            Program_Fixed_Component_ID
                        )
                        SELECT
                            CM.Contract_Main_Id,
                            CP.Contract_Products_Id,
                            0,--CP.Base_Sales_Cs,
                            ISNULL(MAX(fx.Unit_Of_Measure_ID), 1) as Unit_Of_Measure_ID,
                            PFC.Program_Fixed_Component_ID
                        FROM Contract_Main CM
                        INNER JOIN Program_Fixed_Component PFC ON
                            PFC.Program_ID = CM.Contract_Main_Id AND
                            PFC.Deleted = 0
                        INNER JOIN Contract_Products CP ON
                            CP.Contract_Main_Id = CM.Contract_Main_Id
                        --we will get the UOM from existing component entry if one exists
                        LEFT JOIN Program_Fixed_Price_Product_Data fx on fx.Contract_Products_ID = CP.Contract_Products_ID and fx.Deleted = 0
                        WHERE CM.Contract_Main_Id = #arguments.contractId#  AND
                                PFC.Program_Fixed_Component_Name_id = #arguments.Component_Name_ID# AND
                                CP.Deleted = 0 AND
                                CP.Product_Type_ID = 1
                        group by CM.Contract_Main_Id,
                            CP.Contract_Products_Id,
                            PFC.Program_Fixed_Component_ID
            </cfquery>
        <cfreturn 'SAVED'  />
    </cffunction>
    <cffunction name="deleteFPComponents" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
        <cfargument name="contractId" type="numeric" required="false" default="0" />
            <cfscript>
                // stuff
                var a = arguments;
            </cfscript>
                <cfquery name="qDeleteFPComponent" datasource="#application.datasource#">
                    DELETE FROM Contract_Products WHERE Contract_Main_Id = #a.contractId#
                    DELETE FROM Program_Fixed_Price_Product_Data WHERE  Program_Fixed_Component_ID IN (SELECT Program_Fixed_Component_ID FROM Program_Fixed_Component PFC WHERE PFC.Program_ID =#a.contractId#)
                    UPDATE Program_Fixed_Component SET Deleted = 1 WHERE Program_ID = #a.contractId# And Deleted = 0
                </cfquery>
        <cfreturn 'DeleteComponents Done' />
    </cffunction>
    <cffunction name="updClaimMechanic" hint="Save Form Fields on Change" access="remote" output="false" returntype="any">
        <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfargument name="stData" type="string" required="true" />
        <cfscript>
            // stuff
            var a = arguments;
            var st = deserializeJson(a.stData);
            var cmId = st.pay_type.pay_id;
            var compId = st.prg_comp_id;
        </cfscript>
            <cfdump var="#st#" output="c:/dump.log" />
            <cfquery name="qSaveInfo" datasource="#application.datasource#">
                Update Program_Fixed_Component set Claim_Mechanics = #cmId#
                WHERE Program_Id = #a.contractId# AND
                        Program_Fixed_Component_id = #compId#
            </cfquery>
        <cfreturn arguments />
    </cffunction>
    <cffunction name="deleteOneFPComponent" hint="Mass Apply Rates" access="remote" output="false" returntype="string" returnformat="JSON">
        <cfargument name="contractId" type="numeric" required="false" default="0" />
        <cfargument name="compId" type="string" required="true" default="0" />
            <cfscript>
                // stuff
                var a = arguments;
            </cfscript>
            <cfquery name="qDeleteOneComponentProds" datasource="#application.datasource#" result='qDelOneCompProd'>
                DELETE PFPPD
                FROM  Contract_Products CP
                INNER JOIN Program_Fixed_Component PFC ON
                    PFC.Program_ID = CP.Contract_Main_Id
                INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
                    PFPPD.Contract_Products_ID = CP.Contract_Products_ID
                    AND PFPPD.Program_fixed_Component_Id = PFC.Program_fixed_Component_Id
                WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
                    CP.Product_Type_ID = 1 AND
                    PFC.Program_fixed_Component_Name_Id = #a.compID#
                DELETE FROM PFC
                FROM Program_Fixed_Component PFC
                WHERE PFC.Program_ID = #a.contractId# AND
                    PFC.Program_fixed_Component_Name_Id = #a.compID#
            </cfquery>
            <cfreturn 'deleteComponent'/>
    </cffunction>

    <cfscript>
    function getFPExportProducts( required numeric program_id ) output="false" hint="Returns products needed for formula pricing export" {
        // important - column names served as column headers on frontend page; hidden columns are prefixed with an underscore character
        return queryExecute( " SELECT 	I.Item,
                                        I.Description AS 'Item Desc',
                                        Formula_Price AS 'Formula Price',
                                        CED.Exchange_Detail_Abrev AS 'Exchange',
                                        CS.Symbol_Description AS 'Commodity',
                                        T.Formula_Type_Description AS 'Type',
                                        CD.Start_Price AS 'Start Price',
                                        CD.Weight,
                                        CD.Final_Price AS 'Final Price',
                                        R.Program_Formula_Pricing_Rule_ID AS '_Program_Formula_Pricing_Rule_ID',
                                        CP.BSA_Foodservice_Items_Master_ID AS '_BSA_Foodservice_Items_Master_ID',
                                        CD.Program_Formula_Pricing_Rule_Comm_Data_ID AS '_Program_Formula_Pricing_Rule_Comm_Data_ID',
                                        (
                                            SELECT COUNT(*)
                                              FROM Formula_Pricing_Commodity_Overage fpco
                                             WHERE fpco.Program_Formula_Pricing_Rule_Comm_Data_ID = CD.Program_Formula_Pricing_Rule_Comm_Data_ID
                                                    AND fpco.Deleted = 0
                                        )
                                        AS _Calculations_Count,
                                        R.Number_Of_Comms AS _Number_Of_Comms,
                                        CD.Final_Price AS '_Final_Price'
                                FROM Contract_Products CP
                                        INNER JOIN BSA_Foodservice_Items_Master I
                                            ON I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
                                        INNER JOIN Program_Formula_Pricing_Rules R
                                            ON R.Program_ID = CP.Contract_Main_ID
                                            AND R.Contract_Products_Id = CP.Contract_Products_ID
                                            AND R.Deleted = 0
                                        INNER JOIN Program_Formula_Pricing_Rule_Comm_Data CD
                                            ON CD.Program_Formula_Pricing_Rule_ID = R.Program_Formula_Pricing_Rule_ID
                                            AND CD.Deleted = 0
                                        INNER JOIN Commodities_Symbol CS
                                            ON CD.Commodities_Symbol_ID = CS.Commodities_Symbol_ID
                                        INNER JOIN Commodities_Exchange_Detail CED
                                            ON CD.Exchange = CED.Exchange_Detail_ID
                                        LEFT JOIN FP_Formula_Types T
                                            ON T.FP_Formula_Type_ID = CD.FP_Formula_Type_ID
                                WHERE CP.Contract_Main_ID = ?
                                        AND CP.Deleted = 0
                                        ORDER BY I.Item,
                                            CED.Exchange_Detail_Abrev,
                                            CS.Symbol_Description ",
                                [ arguments.program_id ], { datasource: application.datasource } );
    }

    function getFPExportMarkets( required numeric program_id ) output="false" hint="Returns markets needed for formula pricing export" {
        return queryExecute( " SELECT DISTINCT
                                      CS.Symbol_Description AS [Commodity],   -- Commodity
                                      ex.Exchange_Detail_Abrev AS [Exchange], -- Exchange
                                      FP.Formula_Type_Description AS [Type],  -- Type
                                      FORMAT( calc.Commodity_Date, 'MM/dd/yyyy' ) AS [Date],          -- Date
                                      calc.Commodity_Value AS [Value],        -- Value
                                      CD.Start_Price AS [Avg]
                                 FROM Program_Formula_Pricing_Rules R
                                        INNER JOIN Contract_Products cp
                                            ON cp.Contract_Products_ID = R.Contract_Products_Id
                                            AND cp.Deleted = 0
                                        INNER JOIN BSA_Foodservice_Items_Master i
                                            ON i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
                                        INNER JOIN Program_Formula_Pricing_Rule_Comm_Data CD
                                            ON CD.Program_Formula_Pricing_Rule_ID = R.Program_Formula_Pricing_Rule_ID
                                            AND CD.Deleted = 0
                                        INNER JOIN Commodities_Symbol CS
                                            ON CD.Commodities_Symbol_ID = CS.Commodities_Symbol_ID
                                        LEFT JOIN FP_Formula_Types FP
                                            ON FP.FP_Formula_Type_ID = CD.FP_Formula_Type_ID
                                        INNER JOIN Program_Formula_Pricing_Rule_Calc_Comm_Value calc
                                            ON calc.Program_ID = R.Program_ID
                                            AND calc.Program_Formula_Pricing_Rule_ID = R.Program_Formula_Pricing_Rule_ID
                                            AND calc.Program_Formula_Pricing_Rule_Comm_Data_ID = CD.Program_Formula_Pricing_Rule_Comm_Data_ID
                                        INNER JOIN Commodities_Exchange_Detail ex
                                            ON ex.Exchange_Detail_ID = CS.Exchange_Detail_ID
                                WHERE R.Program_ID = ? AND R.Deleted = 0
                                ORDER BY [Exchange],
                                        [Commodity],
                                        [Type],
                                        [Date] ",
                            [ arguments.program_id ] );
    }

    function getFPExportCalculations( required numeric program_id ) output="false" hint="Returns calculations needed for formula pricing export" {
        // important - column names served as column headers on frontend page; hidden columns are prefixed with an underscore character
        return queryExecute( "  SELECT  fpco.Description AS 'Component Description',
                                        fpco.Amount AS 'Component Input',
                                        fpco.UOM AS 'Component UOM',
                                        NULL AS 'Final Component Value',
                                        /* do not change the column names start with an underscore character */
                                        fpco.Amount AS '_Amount',
                                        fpco.UOM AS '_UOM',
                                        CP.BSA_Foodservice_Items_Master_ID AS '_BSA_Foodservice_Items_Master_ID',
                                        CD.Program_Formula_Pricing_Rule_Comm_Data_ID AS '_Program_Formula_Pricing_Rule_Comm_Data_ID',
                                        fpco.Calc_Type AS '_Calc_Type',
                                        CD.Start_Price AS '_Start_Price'
                                  FROM Contract_Products CP
                                        INNER JOIN Program_Formula_Pricing_Rules R
                                            ON R.Program_ID = CP.Contract_Main_ID
                                            AND R.Contract_Products_Id = CP.Contract_Products_ID
                                            AND R.Deleted = 0
                                        INNER JOIN Program_Formula_Pricing_Rule_Comm_Data CD
                                            ON CD.Program_Formula_Pricing_Rule_ID = R.Program_Formula_Pricing_Rule_ID
                                            AND CD.Deleted = 0
                                        INNER JOIN Formula_Pricing_Commodity_Overage fpco
                                            ON fpco.Program_Formula_Pricing_Rule_Comm_Data_ID = CD.Program_Formula_Pricing_Rule_Comm_Data_ID
                                            AND fpco.Deleted = 0
                                        INNER JOIN BSA_Foodservice_Items_Master i
                                            ON i.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
                                 WHERE CP.Contract_Main_ID = ?
                                        AND CP.Deleted = 0
                                        ORDER BY fpco.Program_Formula_Pricing_Rule_Comm_Data_ID,
                                                    fpco.Calc_Type DESC,
                                                    fpco.Overage_Index ",
                            [ arguments.program_id ] );
    }

    function getFPExportModifications( required numeric program_id ) output="false" hint="Returns modifications needed for formula pricing export" {
        // important - column names served as column headers on frontend page; hidden columns are prefixed with an underscore character
        return queryExecute( "  SELECT a.Description AS 'Modification Description',
                                       a.Amount AS 'Modification Input',
                                       a.UOM AS 'Modification UOM',
                                       NULL AS 'Final Modification Value',
                                       a.Amount AS '_Amount',
                                       a.UOM AS '_UOM',
                                       a.Calc_Type AS '_Calc_Type',
                                       a.Final_Price AS '_Final_Price',
                                       ISNULL(a.Compound_Price,0) AS 'Compound_Price_notNull',
                                       cp.BSA_Foodservice_Items_Master_ID AS '_BSA_Foodservice_Items_Master_ID'
                                  FROM Program_Formula_Pricing_Rules R
                                        INNER JOIN Contract_Products cp
                                            ON cp.Contract_Products_ID = R.Contract_Products_Id
                                            AND cp.Deleted = 0
                                        INNER JOIN Program_Formula_Pricing_Rule_Overage a
                                            ON a.Program_Formula_Pricing_Rule_ID = R.Program_Formula_Pricing_Rule_ID
                                            AND a.Deleted = 0
                                 WHERE R.Program_ID = ?
                                        AND R.Deleted = 0
                                    ORDER BY cp.BSA_Foodservice_Items_Master_ID,
                                        a.Calc_Type DESC,
                                        a.Overage_Index ",
                            [ arguments.program_id ] );
    }


    function getFormulaPricingExport( required numeric program_id ) output="false" hint="Returns data needed for formula pricing export" {

        return { products: getFPExportProducts( arguments.program_id ),
                 markets: getFPExportMarkets( arguments.program_id ),
                 calculations: getFPExportCalculations( arguments.program_id ),
                 modifications: getFPExportModifications( arguments.program_id )
                 };
    }
    </cfscript>

    <cffunction name="saveFormulaPriceItemCalculation" access="public" output="false" returntype="any">
        <cfargument name="contractId" 	type="numeric" required="true" />
        <cfargument name="ruleID" 		type="string" required="true" />

        <cfset dateNull = "Yes" />
        <cfset procDate = now() />
        
        <!--- Handling for retroactive dates for this client --->
        <cfif application.util.query.get_setting('Margin_Display_Style') EQ "CUSTOM_T">

            <!--- Get program start date --->
            <cfquery NAME="qGetProgramStartDate" DATASOURCE="#application.datasource#">
                select	Contract_Start_Date
                from	Contract_Main
                where 	Contract_Main_ID = #arguments.contractId#
            </cfquery>

            <cfset dateNull = "No" />
            <cfset procDate = getRetroactiveCalcProcDate(qGetProgramStartDate.Contract_Start_Date, 0, arguments.ruleID) />
        </cfif>
        
        <cfstoredproc procedure="Formula_Price_Item_Calculation" datasource="#application.datasource#">
            <cfprocparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.ruleID#">
            <cfprocparam cfsqltype="CF_SQL_DATE" value="#procDate#" null="#dateNull#">
        </cfstoredproc>

    </cffunction>
            
    <cffunction name="getRetroactiveCalcProcDate" access="public" output="false" returntype="date">
        <cfargument name="programStart" type="date" required="true" />
        <cfargument name="scheduleId" 	type="numeric" required="false" default="0" />
        <cfargument name="ruleID" 		type="string" required="false" default="0" />

        <cfquery NAME="qGetRetroactiveCalcProcDate" DATASOURCE="#application.datasource#">
            DECLARE @FP_Schedule_Option_ID int = #arguments.scheduleId#,
					@Program_Formula_Pricing_Rule_ID varchar(50) = '#arguments.ruleID#', 
                    @Contract_Start DATE = '#DateFormat(ARGUMENTS.programStart, "mm/dd/yyyy")#'
            
			/* When program start date is today or after, no need to do special logic, use default date of Getdate() */
			IF @Contract_Start >= CAST(GetDate() as DATE)
			BEGIN
				SELECT GetDate() as Proc_Date
				RETURN;
			END

			/* Get Schedule when Schedule_ID is 0 and Rule_ID is passed in */
			IF @FP_Schedule_Option_ID = 0 AND @Program_Formula_Pricing_Rule_ID != ''
			BEGIN
				SELECT	@FP_Schedule_Option_ID = R.FP_Schedule_Option_ID
				FROM	Program_Formula_Pricing_Rules R 
				WHERE	R.Program_Formula_Pricing_Rule_ID = @Program_Formula_Pricing_Rule_ID 
				AND		R.Deleted = 0
			END
			
			IF ISNULL(@FP_Schedule_Option_ID, 0) = 0
			BEGIN
				SELECT @Contract_Start as Proc_Date
			END
			ELSE
			BEGIN
				SELECT	CASE 
						/*Subtract 1 day*/
						WHEN O.Effective_Day_Type IN ('NextMonth','NextQuarter','NextMonth','NextFiscalMonth') THEN DateAdd(d, -1, @Contract_Start)
						/* Subtract number of days from Effective_Day_When and add one day */
						WHEN O.Effective_Day_Type = 'DaysFromPrice' AND Price_Day_Frequency = 'Weekly' THEN DateAdd(d, -1*O.Effective_Day_When+1, @Contract_Start)
						/* Default = Use program start date */
						ELSE @Contract_Start
						END as Proc_Date
				FROM	FP_Schedule_Options O
				WHERE	O.FP_Schedule_Option_ID = @FP_Schedule_Option_ID
			END
        </cfquery>

        <cfreturn qGetRetroactiveCalcProcDate.Proc_Date />
        
    </cffunction>

    <cffunction name="recalculateFormula" access="remote" output="false" returntype="string" returnformat="JSON">
        <cfargument name="contractId" 	type="numeric" required="true" />
       

        <!--- Handling for retroactive dates for this client --->
        <cfif application.util.query.get_setting('Margin_Display_Style') EQ "CUSTOM_T">
            
            <cfquery name="qGetContractStart" datasource="#application.datasource#">
                select	Contract_Start_Date, Formula_Price_Rebate_Type as Schedule_ID
                from	Contract_Main
                where 	Contract_Main_ID = '#arguments.contractId#'
            </cfquery>

            <cfset processDate = getRetroactiveCalcProcDate(qGetContractStart.Contract_Start_Date, Val(qGetContractStart.Schedule_ID), '') />
            
        <cfelse>
            <cfset processDate = "NULL" />
        </cfif>

        <cfquery NAME="qRecalcFormula" DATASOURCE="#application.datasource#">

            DECLARE 
            @tmp_Program_Formula_Pricing_Rule_ID uniqueidentifier,
            @processDate Date = NULL
            
            <cfif processDate NEQ "NULL">
                SET @processDate = '#DateFormat(processDate, "mm/dd/yyyy")#'
            </cfif>

            DECLARE tmp_cursor_Calc CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR 
            SELECT Program_Formula_Pricing_Rule_ID
            FROM Program_Formula_Pricing_Rules R
            WHERE R.Program_ID = #arguments.contractId#
            AND     Deleted = 0

            OPEN tmp_cursor_Calc

            FETCH NEXT FROM tmp_cursor_Calc 
            INTO @tmp_Program_Formula_Pricing_Rule_ID

            WHILE @@FETCH_STATUS = 0
            BEGIN
                
                EXEC Formula_Price_Item_Calculation @tmp_Program_Formula_Pricing_Rule_ID, @processDate

                -- Get the next tmp.
                FETCH NEXT FROM tmp_cursor_Calc 
                INTO @tmp_Program_Formula_Pricing_Rule_ID
            END 
            CLOSE tmp_cursor_Calc
            DEALLOCATE tmp_cursor_Calc

        </cfquery>

        <cfreturn 'Formula Recalculated'/>

    </cffunction>

</cfcomponent>
