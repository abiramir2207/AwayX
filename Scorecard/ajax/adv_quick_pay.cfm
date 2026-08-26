<!---------------------------------------------------------------------------------------------------------------------
            Template: \ Common_Files\Contracts\Ajax\getEZRates.cfm
            Date:     20-May-2020
            Author:   Dinesh Rachala
            Purpose:  Get EZ Button Items and rates.
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
	<cfparam name="url.iDisplayStart"   default="0">
	<cfparam name="url.iDisplayLength"  default="100">
	<cfparam name="url.sEcho"           default="10">
	<cfparam name="url.iSortCol_0"      default="0">
	<cfparam name="url.SSORTDIR_0"      default="asc">
	<cfparam name="url.sSearch" default="">
	<cfparam name="url.type"      default="DD">
	<cfparam name="url.getAllDD"      default="0">
	<cfparam name="TotalDDAmount"      default="0">
	<cfparam name="DDList"      default="">


  <cfscript>
	reply = {};

	page_size   = val(url.iDisplayLength);
	if ( page_size eq -1) {
	  start_row   = 1;
	  end_row     = -1;
	}
	else {
	  start_row   = url.iDisplayStart + 1;
	  end_row     = url.iDisplayStart + page_size;
	}
	url.sSearch = trim(url.sSearch);
	unknown     = 'unknown';
	dSearch     = ( isDate(url.sSearch) ? dateFormat(parseDateTime(url.sSearch),'short') : unknown );

	// parse search string into an array of words
	if ( len(url.sSearch) ) {
	  arrayOfWords = reMatch( "[[:word:]]+", url.sSearch );
	}
	else {
	  arrayOfWords = [];
	}
	// concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
	listOfWords        = arrayToList(arrayOfWords, "%");
	url.iSortCol_0     = val(url.iSortCol_0);
  </cfscript>
  <!--- Generate JSON from Query --->
	<cfset reply.aaData = [] >
	<cfset variables.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<cfif url.type EQ 'DD'>
	<cfquery NAME="qRows" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##Deduction_Parent') IS NOT NULL
		DROP TABLE ##Deduction_Parent

		IF OBJECT_ID('tempdb..##Prg_Distributors') IS NOT NULL
		DROP TABLE ##Prg_Distributors

		SELECT CD.BSA_Foodservice_Customers_ID, CM.Distributor_Bill_To_ID
		INTO   ##Prg_Distributors
		FROM Contract_Distributors CD
		INNER JOIN BSA_Foodservice_Customers CM
		ON               CM.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
		WHERE Contract_Main_ID = #url.ContractMainID#
		AND CD.Deleted = 0

		SELECT DISTINCT DD_Parent_ID
		INTO   ##Deduction_Parent
		FROM   Deductions
		WHERE  Deleted = 0
		AND DD_Rejected = 0
		AND Is_Credit = 0
		AND DD_Parent_ID IS NOT NULL

		SELECT ROW_NUMBER() OVER(ORDER BY CASE WHEN D.Distributor_ID IS NULL THEN BL.Name ELSE BFC.Name END ASC) AS RowNum
								, D.DD_DedID
								, D.DD_Amount
								, CONVERT(VARCHAR(10), D.DD_Date, 101) as DD_Date
								, D.DD_Reference
								, CASE WHEN D.Distributor_ID IS NULL THEN BL.Shr_Bill_To ELSE BFC.Ship_To END as Customer_ID
								, CASE WHEN D.Distributor_ID IS NULL THEN BL.Name ELSE BFC.Name END as Customer_Name
								, Deduction_ID
								, REPLACE(BFC.Name,' ','_') AS CustomName
								, D.Is_Locked
								, U.name_first+' '+name_last AS DD_Locked_By
		FROM   Deductions D
		LEFT JOIN BSA_Foodservice_Customers BFC
		ON  BFC.BSA_Foodservice_Customers_ID = D.Distributor_ID
		LEFT JOIN Distributor_Bill_To BL
		ON BL.Distributor_Bill_To_ID = D.Distributor_Bill_To_ID
		LEFT JOIN _Users U
		ON U.User_ID = D.Locked_By
		WHERE D.Deleted = 0
		AND D.DD_Rejected = 0
		AND D.DD_Status IN (1,2)
		AND D.Is_Credit = 0
		AND D.Is_Write_Off = 0
		AND D.DD_Closure_ID IS NULL
		AND D.Deduction_ID NOT IN (SELECT DD_Parent_ID FROM ##Deduction_Parent)
		AND (
			(D.Distributor_ID IS NOT NULL AND D.Distributor_ID IN (SELECT BSA_Foodservice_Customers_ID FROM ##Prg_Distributors))/*Match on Ship To*/
			OR
			(D.Distributor_ID IS NULL AND D.Distributor_Bill_To_ID IN (SELECT Distributor_Bill_To_ID FROM ##Prg_Distributors)) /*Match on Bill To*/
			)
		AND D.DD_Amount <> '0.00'
	  	/*quick search at the top left */
		<cfif len( listOfWords )>
		AND (    D.DD_DedID LIKE '%#listOfWords#%'
							/*OR D.DD_Amount LIKE '%#listOfWords#%'
						OR D.DD_Date LIKE '%#listOfWords#%'*/
						OR D.DD_Reference LIKE '%#listOfWords#%'
						OR BFC.Ship_To LIKE '%#listOfWords#%'
						OR BL.Shr_Bill_To LIKE '%#listOfWords#%'
						OR BFC.Name LIKE '%#listOfWords#%'
						OR BL.Name LIKE '%#listOfWords#%'
						)
		</cfif>

		<cfswitch expression="#url.iSortCol_0#">
     <cfcase value='1'> ORDER BY D.DD_DedID #url.sSortDir_0# </cfcase>
     <cfcase value='2'> ORDER BY D.DD_Amount #url.sSortDir_0# </cfcase>
		 <cfcase value='3'> ORDER BY D.DD_Date #url.sSortDir_0# </cfcase>
     <cfcase value='4'> ORDER BY D.DD_Reference #url.sSortDir_0# </cfcase>
		 <cfcase value='5'> ORDER BY Customer_ID #url.sSortDir_0# </cfcase>
		 <cfcase value='6'> ORDER BY Customer_Name #url.sSortDir_0# </cfcase>
     <cfdefaultcase>    ORDER BY D.DD_DedID asc</cfdefaultcase>
   </cfswitch>
</cfquery>


<cfif end_row eq -1 OR url.getAllDD>
	<cfset start_row =1>
	<cfset end_row   = qRows.recordCount>
	<cfset TotalDDAmount = ArraySum(ListToArray(ValueList(qRows.DD_Amount)))>
	<cfset DDList = ValueList(qRows.Deduction_ID)>
<cfelse>
	<cfset end_row   = min(end_row, qRows.recordCount)>
</cfif>

	<cfloop query="qRows" startRow="#start_row#" endRow="#end_row#">
		<cfset CustomerName = REReplace(Customer_Name,"[^0-9A-Za-z. ]","","ALL")>
		<cfset CR = currentrow - 1>
		<cfscript>
			dArrayTmp = [];
			if (url.getAllDD){
				arrayAppend(dArrayTmp, Deduction_ID);
		}else{
			if (Is_Locked) {
				arrayAppend(dArrayTmp, '<img src="\images\not_allowed.gif" title="This Deduction is locked by #DD_Locked_By# and cannot be used in Quick Pay. Ask the user to unlock the Deduction and then it can be used in Quick Pay.">');
			}
			else{
			arrayAppend(dArrayTmp, '<input type="checkbox" name="deduction" value="#Deduction_ID#" id="#Deduction_ID#" onclick="addDD(this, '& '''#Deduction_ID#'''&' , '& '''#DD_DedID#'''&' , '& '''#DD_Amount#'''&' , '& '''#DD_Date#'''&' , '& '''#DD_Reference#'''&' , '& '''#Customer_ID#'''&' , '& '''#CustomerName#'''&' );">');
			}
		}
			arrayAppend(dArrayTmp, '<a href="##" onclick="preview(''#Deduction_ID#'' )" style="cursor:pointer;">#DD_DedID#</a>' );
			arrayAppend(dArrayTmp, dollarformat(DD_Amount));
			arrayAppend(dArrayTmp, DD_Date);
			arrayAppend(dArrayTmp, DD_Reference);
			arrayAppend(dArrayTmp, Customer_ID);
			arrayAppend(dArrayTmp, Customer_Name);
			arrayAppend(reply.aaData, dArrayTmp);
		</cfscript>
  </cfloop>


<cfelse>
	<cfquery NAME="qRowsTempDelete" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##DD_Shipto_BillTo') IS NOT NULL
		DROP TABLE ##DD_Shipto_BillTo

		IF OBJECT_ID('tempdb..##DD_Temp_Table') IS NOT NULL
		DROP TABLE ##DD_Temp_Table

		IF OBJECT_ID('tempdb..##Pgm_Accrual') IS NOT NULL
		DROP TABLE ##Pgm_Accrual

		IF OBJECT_ID('tempdb..##Pgm_Spent') IS NOT NULL
		DROP TABLE ##Pgm_Spent

		IF OBJECT_ID('tempdb..##Pgm_Trade_Spend') IS NOT NULL
		DROP TABLE ##Pgm_Trade_Spend

		IF OBJECT_ID('tempdb..##Pgm_Payments') IS NOT NULL
		DROP TABLE ##Pgm_Payments

		IF OBJECT_ID('tempdb..##Pgm_Budget_List') IS NOT NULL
		DROP TABLE ##Pgm_Budget_List

		IF OBJECT_ID('tempdb..##Pgm_Budget_Balance') IS NOT NULL
		DROP TABLE ##Pgm_Budget_Balance
</cfquery>
<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

	<cfset useLakebaseForqBBProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_profiles_settings")>
<cfif useLakebaseForqBBProfilesSettings>
	<cftry>
		<cfset qBBProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_profiles_settings", {
				"profiles_id" = "eq.#request.AccessStructure.Profiles_ID#",
				"deleted" = "eq.0",
				"select" = "bb_approve_critical"
			}), "bb_approve_critical"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqBBProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqBBProfilesSettings>
<cfquery NAME="qBBProfilesSettings" datasource="#application.datasource#">
		SELECT BB_Approve_Critical
		FROM BB_Profiles_Settings
		WHERE Profiles_ID = #request.AccessStructure.Profiles_ID#
		AND Deleted=0
	</cfquery>
</cfif>
	<cfset BB_Approve_Critical = qBBProfilesSettings.BB_Approve_Critical>

	<cfquery NAME="qRowsTemp" datasource="#application.datasource#">

		DECLARE @Profile_Forbidden_Template table
		(
			Template_ID   int          NOT NULL,
			Forbid_Access_Type int          NOT NULL
		)
		INSERT INTO @Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
		SELECT DISTINCT template_id, Forbid_Access_Type
		FROM 	Profile_Forbidden_Template
		WHERE 	Deleted = 0
		AND Forbid_Type = #forbidType#
		AND profile_id = #request.AccessStructure.Profiles_ID#


		SELECT D.Deduction_ID, D.Distributor_ID, D.Distributor_Bill_To_ID
		INTO ##DD_Shipto_BillTo
		FROM   Deductions D
		WHERE D.Deduction_ID = 	'#url.Deduction_ID#'
		AND D.Deleted = 0
		/*Below filters are not needed if we are checking them before. */
		<cfif ! appSettings.getDDAllowNegativeAmountCredits()>
		AND D.DD_Status IN (1,2)
		AND D.Is_Credit = 0
		<cfelse>
			AND D.DD_Status IN (1,2,8)
		</cfif>
		AND D.DD_Rejected = 0
		AND D.Is_Write_Off = 0
		AND D.DD_Closure_ID IS NULL

		DECLARE @Default_Program_Contract_Number VARCHAR(20)
		SELECT @Default_Program_Contract_Number = Contract_Number
		FROM Contract_Main
		WHERE Contract_Main_ID IN (SELECT Default_Program FROM Billback_Settings)

		declare @Display_Older_PGR_Versions_In_search bit

		SELECT @Display_Older_PGR_Versions_In_search = value
		from _Settings
		where Input_Name = 'Display_PGR_Versions_In_search'

		/*Get programs matching on Deduction Ship To or Bill To*/
		SELECT CM.Contract_Main_ID, CM.Contract_Number, CM.Contract_Title, CD.BSA_Foodservice_Customers_ID, C.Distributor_Bill_To_ID, C.Name AS Customer, DBT.Name AS BillTo
		,CASE @Display_Older_PGR_Versions_In_search WHEN '1' THEN CAST(0 as DECIMAL(20, 2)) /*Will be populated below*/
			ELSE ISNULL(CMAD.Total_Accrued_Dollars - CMAD.Total_Spent_Dollars, 0)
		END AS Accrual_Balance,
		CAST(0 as DECIMAL(20, 2)) as Total_Accrual,
		CAST(0 as DECIMAL(20, 2)) as Total_Spent,
		CAST(0 as DECIMAL(20, 2)) as Trade_Spend,
		CAST(0 as DECIMAL(20, 2)) as Budget_Balance,
		CASE WHEN CM.Effective_End_Date = MAX(CM.Effective_End_Date) OVER(PARTITION BY CM.Contract_Number)
		THEN 1
		ELSE 0
		END as Latest_Version,
		0 AS Budget_Count,
		CASE WHEN Prg_Locked_By_Quick_Pay =1 AND Contract_Locked_By_User_ID != '#request.AccessStructure.User_ID#'  THEN 1
		ELSE 0
		END AS Locked_By_Quick_Pay,
		U.Name_First+ ' '+U.Name_Last AS LockedBy,
		PCPO.Billback_Sales_Tax

		INTO ##DD_Temp_Table

		FROM Contract_Main CM
		INNER JOIN Program_Control_Panel_Options PCPO
		ON PCPO.Programcontrol_Panel_Options_ID = CM.ProgramType_ID
		INNER JOIN Contract_Main_Aux_Data CMAD
		ON              CM.Contract_Main_ID = CMAD.Contract_Main_ID
		INNER JOIN    Contract_Distributors CD
		ON                   CD.Contract_Main_ID = CM.Contract_Main_ID
		AND                  CD.Deleted =0
		INNER JOIN    BSA_Foodservice_Customers C
		ON                   C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
		LEFT JOIN Distributor_Bill_To  DBT
		ON 		DBT.Distributor_Bill_To_ID = C.Distributor_Bill_To_ID
		LEFT JOIN _Users U
		ON U.User_ID = CM.Contract_Locked_By_User_ID
		WHERE CM.Deleted = 0
		AND CM.Approved = 1
	<cfif url.ExpiredPrograms EQ 'true'>
		AND CM.Contract_Status_Type_IDX != 7
	</cfif>
	AND CM.ProgramType_ID
			<cfif forbidType EQ 1>NOT </cfif>/*- forbit type=1, forbid, 0=allow*/
			IN
			/* (Forbid_Access_Type = 1 means 'Access') */
			(select Template_ID from @Profile_Forbidden_Template WHERE Forbid_Access_Type =1)

	AND CM.Contract_Number != ISNULL(@Default_Program_Contract_Number,'') /*Not dummy program -*/
	<cfif ! BB_Approve_Critical>
		AND CM.Released=0 /*Not released*/
	</cfif>
	AND CM.Manual_Cancel=0 /*Not cancelled*/

	AND EXISTS  ( SELECT 1
			FROM ##DD_Shipto_BillTo D
			WHERE (
				(D.Distributor_ID IS NOT NULL AND D.Distributor_ID = CD.BSA_Foodservice_Customers_ID) /*Match on ship to*/
				OR
				(D.Distributor_ID IS NULL AND D.Distributor_Bill_To_ID = C.Distributor_Bill_To_ID) /*Match on Bill To*/
				)
	            )

	AND EXISTS (
		/*Rebate*/
		SELECT 1
		FROM Contract_Main C
		INNER JOIN  Program_Rebates_Component PRC
		ON                  PRC.Program_ID = C.Contract_Main_ID
		AND          			PRC.Deleted =0
		INNER JOIN   Program_Rebates_Component_Name PRCN
		ON                  PRCN.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID
			INNER JOIN  Payment_Type PT
		ON             PT.Payment_Type_ID = PRC.Claim_Mechanics
		AND          PT.Restrict_From_Billback=0 /*Not restricted from Billback*/
		AND          PT.Is_Auto_Pay=0 /*No Auto Pay*/
		AND          PT.Off_Invoice=0 /*No OffInvoice*/
		WHERE C.Contract_Number = CM.Contract_Number /*Display components from all program versions*/
		AND C.Approved = 1
		AND PRC.Component_Paid_To = 1 /*For now, only Payee = Distributor*/

		UNION

		/*Lumpsum*/
		SELECT 1
		FROM Contract_Main C
		INNER JOIN  Program_Lump_Sums PLC
		ON                  PLC.Program_ID = C.Contract_Main_ID
		AND          PLC.Deleted =0
		INNER JOIN   Program_Lump_Sum_Name PLCN
		ON                  PLCN.Program_Lump_Sum_Name_ID = PLC.Program_Lump_Sum_Name_ID
			INNER JOIN  Payment_Type PT
		ON                  PT.Payment_Type_ID = PLC.Claim_Mechanics
		AND          PT.Restrict_From_Billback=0 /*Not restricted from Billback*/
		AND          PT.Is_Auto_Pay=0 /*No Auto Pay*/
		AND          PT.Off_Invoice=0 /*No OffInvoice*/
		WHERE C.Contract_Number = CM.Contract_Number /*Display components from all program versions*/
		AND C.Approved =1
		AND PLC.Component_Paid_To = 1 /*For now, only Payee = Distributor*/

		UNION

		/*Fixed*/
		SELECT 1
		FROM Contract_Main C
		INNER JOIN  Program_Fixed_Component PFC
		ON                   PFC.Program_ID = C.Contract_Main_ID
		AND                  PFC.Deleted =0
		INNER JOIN    Program_Fixed_Component_Name PFCN
		ON                   PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
		INNER JOIN  Payment_Type PT
		ON                   PT.Payment_Type_ID = PFC.Claim_Mechanics
		AND                  PT.Restrict_From_Billback=0 /*Not restricted from Billback*/
		AND                  PT.Is_Auto_Pay=0 /*No Auto Pay*/
		AND                  PT.Off_Invoice=0 /*No OffInvoice*/
		WHERE C.Contract_Number = CM.Contract_Number --Display components from all program versions
		AND C.Approved =1
		AND PFC.Fixed_Component_Paid_to =1 /*For now, only Payee = Distributor*/
	)


<cfif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 1 OR variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 3>
	IF @Display_Older_PGR_Versions_In_search = '1'
	BEGIN

		SELECT	Contract_Number, SUM(Amount) as Accrual_Amount
		INTO	##Pgm_Accrual
		FROM	GLA_Combined gla
		WHERE	EXISTS (
			SELECT	1
			FROM	##DD_Temp_Table t
			WHERE	t.Contract_Number = gla.Contract_Number
		)
		GROUP BY Contract_Number

		UPDATE	t
		SET		Total_Accrual = acc.Accrual_Amount
		FROM	##DD_Temp_Table t
		INNER JOIN ##Pgm_Accrual acc
		ON		acc.Contract_Number = t.Contract_Number


		SELECT	Contract_Number, SUM(Paid_Amount) as Spent_Amount
		INTO	##Pgm_Spent
		FROM	Payment_History_Details d
		WHERE	EXISTS (
			SELECT	1
			FROM	##DD_Temp_Table t
			WHERE	t.Contract_Number = d.Contract_Number
		)
		GROUP BY Contract_Number

		UPDATE	t
		SET		Total_Spent = s.Spent_Amount
		FROM	##DD_Temp_Table t
		INNER JOIN ##Pgm_Spent s
		ON		s.Contract_Number = t.Contract_Number

		UPDATE	##DD_Temp_Table
		SET		Accrual_Balance =Total_Accrual - Total_Spent

	END
</cfif>
/*Trade Spend*/
<cfif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 4>
	SELECT  CM.Contract_Number,
	      SUM(
	      CASE WHEN ISNULL(t2.Latest_Version, 0) = 1
	      THEN CMAD.Program_Spend_Lumpsum
	      ELSE 0
	      END
	      +(
	          CMAD.Program_Spend_Non_Lumpsum
	          *
	          CAST(
	          CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
	          / CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as decimal(20, 4))
	          as decimal(20, 4)
	          )
	        )
	      ) AS Trade_Spend,
         CAST(0 AS DECIMAL(20,4)) as Est_Trade_Balance
	INTO  ##Pgm_Trade_Spend
	FROM  Contract_Main CM
	INNER JOIN Contract_Main_Aux_Data CMAD
	ON    CM.Contract_Main_ID = CMAD.Contract_Main_ID
	LEFT JOIN ##DD_Temp_Table t2
	ON    t2.Contract_Main_ID = CM.Contract_Main_ID
	WHERE EXISTS (
	SELECT  1
	FROM  ##DD_Temp_Table t
	WHERE t.Contract_Number = CM.Contract_Number
	)
	GROUP BY CM.Contract_Number

	UPDATE ##Pgm_Trade_Spend SET Est_Trade_Balance = Trade_Spend

	UPDATE t SET Est_Trade_Balance = t.Trade_Spend - phd.Paid_Amount
	FROM ##Pgm_Trade_Spend t
	CROSS JOIN ( SELECT  Contract_Number, SUM(paid_amount) paid_amount
                     FROM Payment_History_Details
                     GROUP BY Contract_Number
                   ) phd
	WHERE t.Contract_Number = phd.contract_number

	UPDATE  t
	SET   Trade_Spend = s.Est_Trade_Balance
	FROM  ##DD_Temp_Table t
	INNER JOIN ##Pgm_Trade_Spend s
	ON    s.Contract_Number = t.Contract_Number
</cfif>
	/*Budget Balance*/
	<cfif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 2 OR variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 3>
	SELECT	DISTINCT t.Contract_Number, b.Budget_ID, b.Allocation_Position_Level, b.Budget_Contribution_Factor_Type_ID,
		DENSE_RANK() OVER(Partition By t.Contract_Number
                     Order by CASE WHEN CAST(GetDate() as DATE) between bc.Start_Date and bc.End_Date THEN 1 ELSE 0 END Desc, bc.End_Date Desc, bc.Start_Date Desc) as RowID,
			count( *) OVER(Partition By t.Contract_Number ) as Budget_count
	INTO	##Pgm_Budget_List
	FROM	##DD_Temp_Table t
	INNER JOIN Budget_Program_Selection s
	ON s.Program_ID = t.Contract_Main_ID
	INNER JOIN Budget b
	ON b.Budget_ID = s.Budget_ID
	INNER JOIN Budget_Class bc
	ON bc.Budget_Class_ID = b.Budget_Class_ID

	/*Budget is position level*/
	SELECT b.Contract_Number, SUM(a.Budget_Dollar  - a.Actual_Dollar) as budget_Balance, b.Budget_count
	INTO   ##Pgm_Budget_Balance
	FROM   ##Pgm_Budget_List b
	INNER JOIN Budget_Position_Allocation a
	ON a.Budget_ID = b.Budget_ID
	WHERE  (b.Budget_Contribution_Factor_Type_ID = 3  OR b.Allocation_Position_Level != 4 )
	AND b.RowID <= 2 /*Pick latest 2 budgets from program only*/
	AND EXISTS (
			SELECT 1
			FROM Budget_Position_Program bPgm
			WHERE bPgm.Budget_ID = b.Budget_ID
			AND bPgm.Contract_Number = b.Contract_Number
			AND a.User_Position_ID = bPgm.User_Position_ID
		)
	GROUP BY b.Contract_Number, b.Budget_Count

	/*Budget is distributor level*/
	INSERT INTO ##Pgm_Budget_Balance (Contract_Number, budget_Balance, Budget_count)
	SELECT b.Contract_Number, SUM(a.Budget_Dollar  - a.Actual_Dollar) as budget_Balance, b.Budget_count
	FROM   ##Pgm_Budget_List b
	INNER JOIN Budget_Distributor_Allocation a
	ON a.Budget_ID = b.Budget_ID
	WHERE  b.Allocation_Position_Level = 4
	AND b.RowID <= 2  /* Pick latest 2 budgets from program only*/
	AND EXISTS (
			SELECT 1
			FROM   Budget_Distributor_Program bPgm
			WHERE  bPgm.Budget_ID = b.Budget_ID
			AND bPgm.Contract_Number = b.Contract_Number
			AND a.BSA_Foodservice_Customers_ID = bPgm.BSA_Foodservice_Customers_ID
	)
	GROUP BY b.Contract_Number, b.Budget_Count

	UPDATE	t
	SET Budget_Balance = s.budget_Balance, Budget_Count = s.Budget_Count
	FROM ##DD_Temp_Table t
	INNER JOIN (
		SELECT Contract_Number, SUM(budget_Balance) as budget_Balance, Budget_Count
		FROM ##Pgm_Budget_Balance
		GROUP BY Contract_Number, Budget_Count
	) s
	ON s.Contract_Number = t.Contract_Number
</cfif>
</cfquery>

<cfquery NAME="qRows" datasource="#application.datasource#">
SELECT Contract_Main_ID
	, Contract_Number
	, Accrual_Balance
	, Trade_Spend
	, Budget_Balance
	, Contract_Title
	, BSA_Foodservice_Customers_ID
	, Distributor_Bill_To_ID
	, Customer
	, BillTo
	,Budget_Count
	,Locked_By_Quick_Pay
	,LockedBy
	,Billback_Sales_Tax
FROM ##DD_Temp_Table
WHERE 1=1
/*quick search at the top left*/
	<cfif len( listOfWords )>
	AND (  Contract_Number LIKE '%#listOfWords#%'
		OR Contract_Title LIKE '%#listOfWords#%'
		OR Customer LIKE '%#listOfWords#%'
		OR BillTo LIKE '%#listOfWords#%'
		)
	</cfif>

	<cfif url.ZeroBalance EQ 'true'>
		<cfif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 1 OR variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 3> /*--- 1 : ACCRUAL ---- 3 :  ACCRUAL & BUDGET*/
			AND Accrual_Balance > 0
		<cfelseif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 2 OR variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 3>/* ---- 2 : BUDGET ---- 3 :  ACCRUAL & BUDGET*/
			AND Budget_Balance > 0
		<cfelse> /* Program Trade Estimate*/
			AND Trade_Spend > 0
		</cfif>
	</cfif>

	<cfswitch expression="#url.iSortCol_0#">
	 <cfcase value='2'> ORDER BY Contract_Number #url.sSortDir_0# </cfcase>
	 <cfcase value='3'> ORDER BY Accrual_Balance #url.sSortDir_0# </cfcase>
	 <cfcase value='4'> ORDER BY Trade_Spend #url.sSortDir_0# </cfcase>
	 <cfcase value='5'> ORDER BY Budget_Balance #url.sSortDir_0# </cfcase>
	 <cfcase value='6'> ORDER BY Contract_Title #url.sSortDir_0# </cfcase>
	 <cfcase value='7'> ORDER BY Customer #url.sSortDir_0# </cfcase>
	 <cfcase value='8'> ORDER BY BillTo #url.sSortDir_0# </cfcase>
	 <cfdefaultcase>     ORDER BY Contract_Main_ID asc</cfdefaultcase>
 </cfswitch>
</cfquery>


<cfif end_row eq -1>
	<cfset start_row =1>
	<cfset end_row   = qRows.recordCount>
<cfelse>
	<cfset end_row   = min(end_row, qRows.recordCount)>
</cfif>
<cfset QuickPay = createobject("component", "components.Billback.Quick_Pay") />
	<cfloop query="qRows" startRow="#start_row#" endRow="#end_row#">
		<cfset CR = currentrow - 1>
		<cfif Budget_Count GT 1>
			<cfset budgets = QuickPay.getBudgetBalance(Contract_Main_ID, Contract_Number)>
			<cfsavecontent variable="budgetInfo">
				<cfoutput query="budgets">
					#Budget_Desc#( #Budget_Class_Desc# )  #dollarformat(budget_Balance)#;
				</cfoutput>
			</cfsavecontent>
			<cfset imgPath='<img src="/images/i.gif" title="#budgetInfo#">' >
			<cfset BudgetBalance =  dollarformat(Budget_Balance)&' '&imgPath>
		<cfelse>
			<cfset BudgetBalance =  dollarformat(Budget_Balance)>
		</cfif>
		
		<cfscript>
			dArrayTmp = [];
			if (Locked_By_Quick_Pay) {
				arrayAppend(dArrayTmp, '<img src="\images\not_allowed.gif" title="This Program is locked by #LockedBy# and cannot be used in Quick Pay. Ask the user to unlock the Program and then it can be used in Quick Pay.">');
			}
			else{
				arrayAppend(dArrayTmp, '<input type="checkbox" name="Contract_Main_ID" value="#Contract_Main_ID#" id="#Contract_Main_ID#" onclick="addPrg(this, '& '''#Contract_Main_ID#'''&' , '& '''#BSA_Foodservice_Customers_ID#'''&' ,'& '''#Distributor_Bill_To_ID#'''&' , '& '''#REReplaceNoCase(Customer,"[^0-9A-Za-z ]","","ALL")#'''&' , '& '''#REReplaceNoCase(BillTo,"[^0-9A-Za-z ]","","ALL")#'''&' , '& '''#Contract_Number#'''&' , '& '''#REReplaceNoCase(Contract_Title,"[^0-9A-Za-z ]","","ALL")#'''&','& '''#Billback_Sales_Tax#'''&'  );">');
			}
			arrayAppend(dArrayTmp, Contract_Main_ID);
			arrayAppend(dArrayTmp, '<a href="##" onclick="openPRG(''#Contract_Main_ID#'' )" style="cursor:pointer;">#Contract_Number#</a>' );
			arrayAppend(dArrayTmp, dollarformat(Accrual_Balance));
			arrayAppend(dArrayTmp, dollarformat(Trade_Spend));
			arrayAppend(dArrayTmp, BudgetBalance);
			arrayAppend(dArrayTmp, #REReplaceNoCase(Contract_Title,"[^0-9A-Za-z ]","","ALL")#);
			arrayAppend(dArrayTmp, Customer);
			arrayAppend(dArrayTmp, BillTo);
			arrayAppend(reply.aaData, dArrayTmp);
		</cfscript>
  </cfloop>
</cfif>

<cfset reply.iTotalDisplayRecords = qRows.recordCount>
<cfset reply.TotalDDAmount = TotalDDAmount>
<cfset reply.DDList = DDList>

<cfscript>
	reply.sEcho = javacast('int', url.sEcho);
	sOut        = SerializeJSON( reply );
	sOut        = Replace (sOut, 'SECHO', 'sEcho', 'one');
	sOut        = Replace (sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one');
	sOut        = Replace (sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one');
	sOut        = Replace (sOut, 'AADATA', 'aaData', 'one');
	sOut        = Replace (sOut, 'TOTALDDAMOUNT', 'TotalDDAmount', 'one');
	sOut        = Replace (sOut, 'DDLIST', 'DDList', 'one');

  </cfscript>
</cfsilent>
<!---send JSON data back to client--->
<cfoutput>#sOut#</cfoutput>

</cfprocessingdirective>
