<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<CFSET PAGE_TITLE="#appsettings.getPullbackLabel()# Amount Calculation">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<script>
		function toggleRateDisplay(ID,sts) {
			tempVar = eval("document.all.RS_"+ID);
			if(tempVar != null){
				if(sts == 0) {
					if(tempVar[0].style.display == "none") {
						toggleStatus = ""
					}
					else {
						toggleStatus = "none"
					}
				}
				else{
					toggleStatus = sts
				}
				
				
				for(var x=0; x<tempVar.length;x++){
					tempVar[x].style.display = toggleStatus;
				}
			}
		}	
	</script>

	<style>
		TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
		#header {font-size: 12px;}
	</style>

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">


<!----------------- Add Spinner ------------------------>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
<!----------------- Add Spinner ------------------------>

<cfparam name="url.type"  default="LB">
<cfparam name="URL.CID" 	default=0>
<cfparam name="url.ProductId" default=0>
<CFPARAM name="url.margin_type" default="1">
<CFPARAM NAME="STAT_MULTIPLIER" default= 1>

<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET URL.CID = cryp.value>

<CFIF URL.CID EQ 0 OR URL.ProductId EQ 0 OR NOT isNumeric(URL.CID)>
	<BLOCKQUOTE>
	<BR><BR><BR><SPAN CLASS="TITLE2">Invalid Contract/Product information</SPAN>
	</BLOCKQUOTE>
	<CFABORT>
</CFIF>

<cfset type = url.type>
<CFSET CID=URL.CID>
<CFSET ProductId = url.ProductId>


<cfset appSettings = application.appSettingsGet />

<CFQUERY NAME="Program_Details" DATASOURCE="#Application.Datasource#">
	SELECT 	Contract_Number, Contract_Start_Date, Contract_End_Date, Search_Sequence_ID, Program_Control_Panel_Options.Exclude_Same_Spending_Cat_From_TPA, Program_Control_Panel_Options.Generic_Type,
            Program_Control_Panel_Options.First_Parent_ID
	FROM 	Contract_Main
	INNER JOIN Program_Control_Panel_Options
	ON		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	WHERE 	Contract_Main_ID = <cfqueryparam value="#CID#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>

<cfset excludeOperatorTPA = 0 />
<!----- if current program is an operator program and if the application switch is on ----->
<cfif appSettings.getOperatorTPAInDistributorPrograms() AND ListFindNOCase("Operator Direct or HQ Programs,Operator-Deviated Pricing", Program_Details.Generic_Type) NEQ 0>
	<cfset excludeOperatorTPA = 1 />
</cfif>

<cfset excludeSameSpendingCategoryFromTPAForThisProgram = 0 />
<cfif appSettings.getOperatingGroupOn() AND Program_Details.Exclude_Same_Spending_Cat_From_TPA EQ 1>
	<cfset excludeSameSpendingCategoryFromTPAForThisProgram = 1 />
</cfif>

<cfset searchSequenceNumber = 0 />
<cfset operatingGroupId = 0 />
<!------ If Operating Group is on ----->
<cfif appSettings.getOperatingGroupOn()>
	<!------ Get the search sequence number  ----->
	<cfset searchSequenceManager 			= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />		
	<cfset Search_Sequence_Name = searchSequenceManager.getSearchSequenceInfo(Program_Details.Search_Sequence_ID) />
	<cfset searchSequenceNumber = Val(Search_Sequence_Name.Search_Sequence_Legacy) />
	
	<!------ operating group id ----->
	<cfset operatingGroupManager 	= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset programLevel2Level 		= operatingGroupManager.getProgramLevel2Level() />
	<cfset operatingGroupId 		= operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=CID) />
</cfif>

<cfset productPrice = 0 />

<CFQUERY NAME="getBasePrice" datasource="#application.datasource#">
	SELECT 	Program_Price_LB
	FROM 	contract_product_margin
	WHERE 	Contract_Main_ID = <cfqueryparam value="#CID#" cfsqltype="CF_SQL_INTEGER">
	AND 	product_id = '#replace(ProductId, "_", "-", "ALL")#'
</CFQUERY>

<cfif getBasePrice.recordCount and IsNumeric(getBasePrice.Program_Price_LB)>
	<cfset productPrice = getBasePrice.Program_Price_LB />
</cfif>

<cfset dateoverlap = -31 />

<CFQUERY NAME="qDeleteTmpTable" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##TMP_Recapture_Rates') IS NOT NULL
	DROP TABLE  ##TMP_Recapture_Rates
	
    IF OBJECT_ID('tempdb..##TMP_Alternate_Recapture_Rate') IS NOT NULL
	DROP TABLE  ##TMP_Alternate_Recapture_Rate    
</CFQUERY>
    
<CFQUERY NAME="getThisProductsDistCombos" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##TMP_Recapture_Rates') IS NOT NULL
	DROP TABLE  ##TMP_Recapture_Rates
    
	SELECT     	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, 
				BSA_Foodservice_Customers.Ship_To, 
				BSA_Foodservice_Customers.Name, 
				BSA_Foodservice_Customers.City, 
				BSA_Foodservice_Customers.State,
				Contract_Distributors.Program_Weight, 
				BSA_Foodservice_Items_Master.UPC, 
				BSA_Foodservice_Items_Master.Description, 
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
				CAST(BSA_Foodservice_Items_Master.net_weight as float) as net_weight, 
				BSA_Foodservice_Items_Master.CASE_EQUIVALENT,
                Contract_Main.Contract_Title, Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date, Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number,
                cast(cast(Program_Distributors_Trade.Rate as float)as decimal(20,6)) as Rate,
                ISNULL(Program_Distributors_Trade.Rate_Percent_On_Fixed_Price, 0) as Rate_Percent_On_Fixed_Price,
    
                CAST(null as decimal(14, 4)) as Alternate_Recapture_Rate_LB,
                CAST(0 as bit) as Do_Not_Recapture
                
    INTO        ##TMP_Recapture_Rates
	FROM		Contract_Distributors
	
	INNER JOIN	Program_Distributors_Trade 
	ON			Program_Distributors_Trade.Deleted = 0
	AND			Program_Distributors_Trade.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
	
	<cfif appSettings.getOperatingGroupOn()>
	<cfif excludeSameSpendingCategoryFromTPAForThisProgram EQ 1>
	AND			Program_Distributors_Trade.Operating_Group_ID <> #operatingGroupId#
	</cfif>
	AND			Program_Distributors_Trade.Search_Sequence_ID = Program_Distributors_Trade.Min_Search_Sequence_ID
	</cfif>
	
	INNER JOIN	Contract_Main 
	ON 			Program_Distributors_Trade.Contract_Main_ID = Contract_Main.Contract_Main_ID 
	AND 		contract_main.Contract_Number != '#Program_Details.Contract_Number#'
	AND			Contract_Main.Pullback_From_This_Program = 1
	
	INNER JOIN 	Program_Control_Panel_Options
	ON			Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_id
	AND			Program_Control_Panel_Options.Pullbacks_On = 1
	AND			Program_Control_Panel_Options.generic_type = 'Distributor Trade/Shelter'
	
	INNER JOIN	BSA_Foodservice_Customers 
	ON 			Program_Distributors_Trade.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID 
	INNER JOIN	BSA_Foodservice_Items_Master 
	ON			Program_Distributors_Trade.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
	AND 		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#replace(ProductId, "_", "-", "ALL")#'
	
	WHERE	Contract_Distributors.Deleted = 0
	AND		Contract_Distributors.Contract_Main_ID = #CID#
	<cfif Program_Details.Generic_Type NEQ "Operator Direct or HQ Programs" AND Program_Details.Generic_Type NEQ "Operator-Deviated Pricing">
    AND     1=2
    </cfif>
	AND (
				((DATEDIFF(d, contract_main.contract_start_date, '#Program_Details.Contract_End_Date#') >= #dateoverlap#) AND (DATEDIFF(d, '#Program_Details.Contract_End_Date#', contract_main.contract_end_date) >= 0)) 
			OR	((DATEDIFF(d, contract_main.contract_start_date, '#Program_Details.Contract_Start_Date#') >= 0) AND (DATEDIFF(d, '#Program_Details.Contract_Start_Date#', contract_main.contract_end_date) >= 0)) 
			OR	((DATEDIFF(d, '#Program_Details.Contract_Start_Date#', contract_main.contract_end_date) >= 0) AND (DATEDIFF(d, contract_main.contract_end_date, '#Program_Details.Contract_End_Date#') >= 0)) 
			OR	((DATEDIFF(d, '#Program_Details.Contract_Start_Date#', contract_main.contract_start_date) >= 0) AND (DATEDIFF(d, contract_main.contract_start_date, '#Program_Details.Contract_End_Date#') >= #dateoverlap#))
		)
	
	<cfif appSettings.getTPA_Includes_Program_Dates()>
	/* If there are multiple revision of a program, get the latest revision.Note: The latest version of the program 
		 should also meet the date/customer/item criteria (gets filtered by the conditions below). This is important
		 because sometimes the latest version might not meet the criteria, but any version before it. 
	*/
	AND Contract_Main.Contract_Main_ID =
	(
			SELECT MAX(Contract_Main_ID)
			FROM Program_Distributors_Trade pdt
			WHERE Contract_Main.Contract_Number = pdt.Contract_Number
			AND 
			(
				/* Contract Start Date of the current program is within the TPA program date span */
				(
				'#Program_Details.Contract_Start_Date#' >= pdt.Contract_Start_Date
				AND
				'#Program_Details.Contract_Start_Date#' <= pdt.Contract_End_Date
				)
			OR
				/* Contract End Date of the current program is within the TPA program date span */
				(
				'#Program_Details.Contract_End_Date#' >= pdt.Contract_Start_Date
				AND
				'#Program_Details.Contract_End_Date#' <= pdt.Contract_End_Date
				)
			 OR
				/* The complete date span of the TPA program is within the date span of the current program */
				(
				pdt.Contract_Start_Date >= '#Program_Details.Contract_Start_Date#'
				AND
				pdt.Contract_End_Date <= '#Program_Details.Contract_End_Date#'
				)
			 )
			 AND Program_Distributors_Trade.BSA_Foodservice_Customers_ID = pdt.BSA_Foodservice_Customers_ID
			 AND Program_Distributors_Trade.BSA_Foodservice_Items_Master_ID = pdt.BSA_Foodservice_Items_Master_ID
	 )
	</cfif>
        

	-- Find if the program have rebate component with alternate recapture
	IF OBJECT_ID('tempdb..##TMP_Alternate_Recapture_Rate') IS NOT NULL
	DROP TABLE  ##TMP_Alternate_Recapture_Rate

	SELECT	DISTINCT cm.Contract_Main_ID, cm.BSA_Foodservice_Items_Master_ID, cm.Do_Not_Recapture,
			rc.Program_Rebates_Component_Name_ID, rc.Program_Rebates_Component_ID,
			cn.Alternate_Recapture_Rate, cn.Alternate_Recapture_By_Operator, 
			CAST(0 as DECIMAL(20, 4)) as Alternate_Recapture_Rate_Value,
			CAST(null as INT) as Alternate_Recapture_Rate_UOM
	INTO	##TMP_Alternate_Recapture_Rate
	FROM	##TMP_Recapture_Rates cm
	INNER JOIN Program_Rebates_Component rc
	ON		rc.Program_ID = cm.Contract_Main_ID
	AND		rc.Deleted = 0
	INNER JOIN Program_Rebates_Component_Name cn
	ON		cn.Program_Rebates_Component_Name_ID = rc.Program_Rebates_Component_Name_ID
	AND		cn.Alternate_Recapture_Rate = 1

	-- If Alternate_Recapture_By_Operator = 1
	-- 1. If operator is not in list, no recapture
	UPDATE	##TMP_Alternate_Recapture_Rate
	SET		Do_Not_Recapture = 1
	WHERE	Alternate_Recapture_By_Operator = 1
	AND		NOT EXISTS (
		SELECT	1
		FROM	Contract_Operators co
		INNER JOIN Recapture_Operator_List opl
		ON		opl.BSA_Operator_ID = co.BSA_Operator_ID
		AND		opl.Deleted = 0	
		WHERE	co.Contract_Main_ID = #CID#
		AND		co.Deleted = 0		
	)
        
    -- 2. If operator is in list, get Alternate recapture rate if the operator on the program has recapture
	UPDATE	t
	SET		Alternate_Recapture_Rate_Value = ar.Rate, Alternate_Recapture_Rate_UOM = ar.UOM
	FROM	##TMP_Alternate_Recapture_Rate t
	INNER JOIN Alternate_Recapture_Rate_Setting r
	ON		r.Program_Rebates_Component_Name_ID = t.Program_Rebates_Component_Name_ID
	AND		r.Alternate_Recapture_Rate_Index = 1
	INNER JOIN Contract_Products cp
	ON		cp.Contract_Main_ID = t.Contract_Main_ID
	AND		cp.BSA_Foodservice_Items_Master_ID = t.BSA_Foodservice_Items_Master_ID 
	AND		cp.Deleted = 0
	AND		cp.Product_type_id = 2
	INNER JOIN Program_Rebate_Alternate_Recapture_Rate ar
	ON		ar.Contract_Main_ID = t.Contract_Main_ID
	AND		ar.Contract_Products_ID = cp.Contract_Products_ID
	AND		ar.Program_Rebates_Component_ID = t.Program_Rebates_Component_ID
	AND		ar.Alternate_Recapture_Rate_Index = r.Alternate_Recapture_Rate_Index
	WHERE	t.Alternate_Recapture_By_Operator = 1
	AND		ISNULL(t.Do_Not_Recapture, 0) = 0

	-- If Alternate_Recapture_By_Operator = 0, get Alternate recapture rate based on current program template
	UPDATE	t
	SET		Alternate_Recapture_Rate_Value = ar.Rate, Alternate_Recapture_Rate_UOM = ar.UOM
	FROM	##TMP_Alternate_Recapture_Rate t
	INNER JOIN Alternate_Recapture_Rate_Template at
	ON		at.Program_Rebates_Component_Name_ID = t.Program_Rebates_Component_Name_ID
	AND		at.First_Parent_ID = #Program_Details.First_Parent_ID#
	INNER JOIN Alternate_Recapture_Rate_Setting r
	ON		r.Program_Rebates_Component_Name_ID = t.Program_Rebates_Component_Name_ID
	AND		r.Alternate_Recapture_Rate_Index = at.Alternate_Recapture_Rate_Index
	INNER JOIN Contract_Products cp
	ON		cp.Contract_Main_ID = t.Contract_Main_ID
	AND		cp.BSA_Foodservice_Items_Master_ID = t.BSA_Foodservice_Items_Master_ID 
	AND		cp.Deleted = 0
	AND		cp.Product_type_id = 2
	INNER JOIN Program_Rebate_Alternate_Recapture_Rate ar
	ON		ar.Contract_Main_ID = t.Contract_Main_ID
	AND		ar.Contract_Products_ID = cp.Contract_Products_ID
	AND		ar.Program_Rebates_Component_ID = t.Program_Rebates_Component_ID
	AND		ar.Alternate_Recapture_Rate_Index = r.Alternate_Recapture_Rate_Index
	WHERE	t.Alternate_Recapture_By_Operator = 0
	

	UPDATE	t
	SET		Alternate_Recapture_Rate_LB = 
                    CASE r.Alternate_Recapture_Rate_UOM
                    WHEN 1 THEN r.Alternate_Recapture_Rate_Value / t.net_weight
                    WHEN 2 THEN r.Alternate_Recapture_Rate_Value
                    WHEN 3 THEN (r.Alternate_Recapture_Rate_Value / 100.00) * #productPrice#
                    ELSE 0
                    END,
			Do_Not_Recapture = ISNULL(r.Do_Not_Recapture, 0)        
	FROM	##TMP_Recapture_Rates t
	INNER JOIN ##TMP_Alternate_Recapture_Rate r
	ON		r.Contract_Main_ID = t.Contract_Main_ID
	AND		r.BSA_Foodservice_Items_Master_ID = t.BSA_Foodservice_Items_Master_ID

        
	SELECT     	SUM((
					t.Rate
					+ ISNULL((t.Rate_Percent_On_Fixed_Price / 100.00) * #productPrice#, 0)
                    - ISNULL(Alternate_Recapture_Rate_LB, 0)
					)
				) AS RATE, 
				t.BSA_Foodservice_Customers_ID, t.Ship_To, t.Name, t.City, t.State,
				t.Program_Weight, 
				t.UPC, t.Description, t.BSA_Foodservice_Items_Master_ID, t.net_weight, t.CASE_EQUIVALENT,
				SUM(( 
					t.Rate
					+ ISNULL((t.Rate_Percent_On_Fixed_Price / 100.00) * #productPrice#, 0)
                    - ISNULL(Alternate_Recapture_Rate_LB, 0)
					) 
				* (CAST(t.Program_Weight AS FLOAT)/100)) AS WTPR

    FROM        ##TMP_Recapture_Rates t
    WHERE       ISNULL(t.Do_Not_Recapture, 0) = 0
	Group BY 	t.BSA_Foodservice_Customers_ID, 
				t.Ship_To, 
				t.Name, 
				t.City, 
				t.State,
				t.Program_Weight, 
				t.UPC, 
				t.Description, 
				t.BSA_Foodservice_Items_Master_ID, 
				t.net_weight, 
				t.CASE_EQUIVALENT
				
	ORDER BY	t.UPC, t.Ship_To
			
</CFQUERY>



					  
<!------<CFDUMP VAR="#getThisProductsDistCombos#">----->

<CFSET PreTPAList = ValueList(getThisProductsDistCombos.WTPR)>
<CFSET listOfUsedIDS = "">

<CFSET PreTPAArray = ListToArray(PreTPAList)>
<CFSET PreTPAArraySum = ArraySum(PreTPAArray)>
<cfif IsNumeric(PreTPAArraySum) EQ 0>
	<cfset PreTPAArraySum = 0 />
</cfif>
<cfif type EQ "CS">
	<cfif url.margin_type EQ 2>
		<cfset STAT_MULTIPLIER = getThisProductsDistCombos.CASE_EQUIVALENT>
	<cfelse>
		<CFSET STAT_MULTIPLIER = 1>
	</cfif>
	<CFSET FinalTPASum = PreTPAArraySum * Val(getThisProductsDistCombos.Net_Weight) * Val(STAT_MULTIPLIER)>
<cfelse>
	<CFSET FinalTPASum = PreTPAArraySum />
</cfif>




<BLOCKQUOTE>
<!------<CFOUTPUT>#FinalTPASum#</CFOUTPUT>----->
<CFIF getThisProductsDistCombos.recordCount GT 0>
<BR><BR>
<SPAN CLASS="TITLE2"><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Amount Calculation</SPAN>
<HR COLOR="Orange">
<CFOUTPUT QUERY="Program_Details">
<TABLE border="0" WIDTH="90%">
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Program:</B>&nbsp;&nbsp;[#Contract_Number#]</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Center"><B>Start Date:</B>&nbsp;&nbsp;#DateFormat(Contract_Start_Date,"mm/dd/yyyy")#</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Right"><B>End Date:</B>&nbsp;&nbsp;#DateFormat(Contract_End_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
	</TR>
</TABLE>
<HR COLOR="Orange">

</CFOUTPUT>
<span style="color: black; font-size: 12px; font-weight:bold;">click here to <a onclick="toggleAllToSameStatus('inline')" style="cursor:pointer; color:red;"><font color="blue">[</font>show<font color="blue">]</font></a> or <a onclick="toggleAllToSameStatus('none')" style="cursor:pointer; color:red;"><font color="blue">[</font>hide<font color="blue">]</font></a> the product rate breakdowns</span>
<BR>

<CFOUTPUT QUERY="getThisProductsDistCombos" GROUP="UPC">
<BR>
<TABLE BORDER="0">
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>PRODUCT:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#getThisProductsDistCombos.UPC# - </cfif></cfif>#getThisProductsDistCombos.Description#</B></TD>
	</TR>
</TABLE>


<TABLE CLASS="Maintable" WIDTH="90%" CELLPADDING="3" CELLSPACING="0" ALIGN="center" border="0">
		<TR BGCOLOR="##FFCE84" VALIGN="bottom">
			<td>&nbsp;</td>
			<TD ID="header" NOWRAP WIDTH="75"><B>#application.returned_customer_setting.shard_ship_to_label#</B></TD>
			<TD ID="header" WIDTH="100%" colspan="3"><B>Name</B></TD>
			<TD ID="header" ALIGN="CENTER"><B>#appsettings.getPullbackLabel()# Rate</B></TD>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header" ALIGN="CENTER"><B>Weight</B></TD>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header" NOWRAP ALIGN="CENTER"><B>Weighted Rate</B></TD>
		</TR>
		<CFOUTPUT>
		<CFIF Ship_To NEQ "">

		<CFSET thisRandomID = replace(createuuid(), "-", "_", "ALL")>
		<CFSET FoundUniqueID = 0>
		<cfloop condition="FoundUniqueID EQ 0">
			<CFIF listfind(listOfUsedIDS,thisRandomID) EQ 0>
				<CFSET listOfUsedIDS = listappend(listOfUsedIDS,thisRandomID)>
				<CFSET FoundUniqueID = 1>
			<CFELSE>
				<CFSET thisRandomID = replace(createuuid(), "-", "_", "ALL")>
			</CFIF>
		</CFLOOP>

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<td>&nbsp;</td>
			<TD>#Ship_To#</TD>
			<TD colspan="3" style="cursor: pointer;" onclick="toggleRateDisplay('#thisRandomID#',0)">#Name# (#City#, #State#)</TD>
			<TD ALIGN="CENTER">
			<cfif type EQ "CS">
					<cfset item_rate = Rate * Net_Weight * STAT_MULTIPLIER>
			<cfelse>
				<cfset item_rate = Rate>
			</cfif>
			
			<CFSET data = trim(numberformat(item_rate,"___,___,___,___,___,___,___,___.____"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			#data#
			</TD>
			<TD ALIGN="CENTER">*</TD>
			<TD ALIGN="CENTER">#Program_Weight#%</TD>
			<TD ALIGN="CENTER">=</TD>
			<TD ALIGN="CENTER">
			<cfif type EQ "CS">
			
				<CFSET wtpr_rate = WTPR * Net_Weight * STAT_MULTIPLIER>
			<cfelse>
				<CFSET wtpr_rate = WTPR>
			</cfif>
			 <cfset data = trim(numberformat(wtpr_rate,"___,___,___,___,___,___,___,___.______"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			#data#
			</TD>
		</TR>
                
        

        <cfquery name="getRates" datasource="#Application.Datasource#">
			SELECT     	t.Contract_Title, t.Contract_Start_Date, t.Contract_End_Date, t.Contract_Main_ID,
						cast(cast(t.Rate as float)as decimal(20,6)) + ISNULL((ISNULL(t.Rate_Percent_On_Fixed_Price, 0) / 100.00) * #productPrice#, 0) - ISNULL(Alternate_Recapture_Rate_LB, 0) AS RATE, 
						t.Contract_Number, t.net_weight,
						cast(100 as decimal(20,2)) AS Pullback_Value
						
			FROM		##TMP_Recapture_Rates t
            WHERE       BSA_Foodservice_Customers_ID = '#getThisProductsDistCombos.BSA_Foodservice_Customers_ID#'
            AND         ISNULL(Do_Not_Recapture, 0) = 0
			Order By t.Rate DESC
		</cfquery>
                
		<TR id="RS_#thisRandomID#" style="display:none;">
			<TD height="4"></TD>
		</TR>
		<TR id="RS_#thisRandomID#" style="display:none;">
			<TD style="border-bottom: 0px;">&nbsp;</TD>
			<TD nowrap bgcolor="##000080" style="color:white;">Contract ##</TD>
			<TD bgcolor="##000080" style="color:white;">Title</TD>
			<TD bgcolor="##000080" style="color:white;">Rate</TD>
			<TD bgcolor="##000080" style="color:white;">#appsettings.getPullbackLabel()# %</TD>
			<TD bgcolor="##000080" style="color:white;">#appsettings.getPullbackLabel()# Rate</TD>
		</TR>
		<CFLOOP query="getRates">
		<!--- Get the program label names from the template. One program may have multiple label names --->
		<cfquery name="ProgramLabelNames" datasource="#Application.Datasource#">
			SELECT Accounting_Program_Type.APT_Name
			FROM Contract_Main LEFT JOIN APT_Template_Mapping
			ON APT_Template_Mapping.Template_ID = Contract_Main.ProgramType_ID
			LEFT JOIN Accounting_Program_Type
			ON Accounting_Program_Type.Accounting_Program_Type_ID = APT_Template_Mapping.Accounting_Program_Type_ID
			WHERE Contract_Main.Contract_Main_ID = '#getRates.Contract_Main_ID#'
		</cfquery>
		<cfset APT_Name = ValueList(ProgramLabelNames.APT_Name)>
		<TR id="RS_#thisRandomID#" style="display:none;">
			<TD style="border-bottom: 0px;">&nbsp;</TD>
			<TD nowrap>#getRates.Contract_Number#</TD>
			<!--- APT_Name is "program label" from the template --->
			<TD>
			#getRates.Contract_Title#<cfif APT_Name neq "">&nbsp;(#APT_Name#)</cfif>
			<br>(#DateFormat(Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(Contract_End_Date, "mm/dd/yyyy")#)
			</TD>
			<cfif type EQ "CS">
				<CFSET item_rate = val(getRates.Rate) * val(getRates.Net_Weight) * val(STAT_MULTIPLIER)>
			<cfelse>
				<CFSET item_rate = getRates.Rate>
			</cfif>
			<CFIF item_rate LT 0>
				<cfset data = item_rate * -1 />
				<cfset data = trim(numberformat(data,"___,___,___,___,___,___,___,___.____"))>
				<CFSET data = "[$#data#]">
			<CFELSE>
				<cfset data = trim(numberformat(item_rate,"___,___,___,___,___,___,___,___.____"))>
				<CFSET data = "$#data#">
			</CFIF>
			<TD>#data#</TD>
			<TD>#Pullback_Value#%</TD>
			<cfset pullback_rate = (item_rate * Pullback_Value) / 100 />
			<CFIF pullback_rate LT 0>
				<cfset data = pullback_rate * -1 />
				<cfset data = trim(numberformat(data,"___,___,___,___,___,___,___,___.____"))>
				<CFSET data = "[$#data#]">
			<CFELSE>
				<cfset data = trim(numberformat(pullback_rate,"___,___,___,___,___,___,___,___.____"))>
				<CFSET data = "$#data#">
			</CFIF>
			<TD>#data#</TD>
		</TR>
		</CFLOOP>
		<TR id="RS_#thisRandomID#" style="display:none;">
			<TD height="10"></TD>
		</TR>	
		</CFIF>
		</CFOUTPUT>
		<TR ALIGN="CENTER">
			<TD COLSPAN=9 ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<B>#appsettings.getPullbackLabel()# Rate / #type# (&##931; Weighted Rate) = </B>
			</TD>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<CFSET data = trim(numberformat(FinalTPASum,"___,___,___,___,___,___,___,___.____"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			<B>#data#</B>
			</TD>
		</TR>
		<cfif type EQ "CS">
			<cfset FinalTPASum = FinalTPASum / getThisProductsDistCombos.Net_Weight>
		<cfelse>
			<cfset FinalTPASum = FinalTPASum * getThisProductsDistCombos.Net_Weight>
		</cfif>
		<TR ALIGN="CENTER">
			<TD COLSPAN=9 ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<B>#appsettings.getPullbackLabel()# Rate / <cfif type EQ "CS">LB<cfelse>CS</cfif></B>
			</TD>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<CFSET data = trim(numberformat(FinalTPASum,"___,___,___,___,___,___,___,___.____"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			<B>#data#</B>
			</TD>
		</TR>
</TABLE>
</CFOUTPUT>
</CFIF>
<HR color ="orange">
<BR><BR>
<DIV ALIGN="center">
		<CF_button
			button_name		=	""
			button_caption	=	"close this window"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		</DIV>	
		<BR><BR>
</BLOCKQUOTE>
<script>
	function toggleAllToSameStatus(status) {
		<cfoutput>
		<cfloop index="x" list="#listOfUsedIDS#">
			toggleRateDisplay('#x#',status);
				
		</CFLOOP>
		</cfoutput>
	}

</script>

</BODY>
</HTML>