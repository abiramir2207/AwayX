<!---
	Description:
		Component used for individal claim
	Package List:
<body bgcolor="#CCCCCC" text="#0000FF">--->
<cfcomponent displayname="Claim" hint="this is the base class for the claim detail">
<!--- section for functions --->
<cfproperty name="claimNo" 		type="string" /> 
<cfproperty name="claimMailTo" 	type="string" /> 
<cfproperty name="claimCust" 	type="string" /> 
<cfproperty name="claimStatus" 	type="string" /> 
<cfproperty name="claimVendor" 	type="string" /> 
<cfproperty name="claimRegion" 	type="string" /> 
<cfproperty name="claimMarket" 	type="string" /> 

<!--- new --->
<cfproperty name="claimEndUser" 	type="string" /> 
<cfproperty name="claimEndUserName" type="string" /> 
<cfproperty name="claimVendorID" 	type="string" /> 
<cfproperty name="claimPostMarkDate" type="date" /> 
<cfproperty name="claimReceiptDate"  type="date" /> 
<cfproperty name="claimEntryDate" 	 type="date" />
<cfproperty name="claimTransDate" 	 type="date" />
<cfproperty name="claimReferenceNo" 	type="string" /> 
<cfproperty name="claimReferenceNo2" 	type="string" /> 
<cfproperty name="claimVoucherNo" 		type="string" /> 
<cfproperty name="claimPODStart" 		type="date" /> 
<cfproperty name="claimPODEnd" 			type="date" /> 
<cfproperty name="claimTrsDate" 		type="date" /> 
<!---- not sure field ---->
<cfproperty name="claimUserID" 			type="string" />
<cfproperty name="claimApprovedUserID" 	type="string" />
<cfproperty name="claimProgramID" 		type="string" />
<cfproperty name="claimProgramName" 	type="string" />
<cfproperty name="claimItems" 			type="array" />
<cfproperty name="claimedAmount" 		type="numeric" />
<cfproperty name="claimPaidAmount" 		type="numeric" />
<cfproperty name="claimLumpSum" 		type="struct" />
<cfproperty name="claimNote" 			type="array" />
<cfproperty name="claimAR" 				type="string" />
<!---- initializing section --->
<cfset this.claimAR = "" />
<cfset this.claimEndUser = "" /> 
<cfset this.claimEndUserName = "" /> 
<cfset this.claimVendorID = "" /> 
<cfset this.claimPostMarkDate = "" /> 
<cfset this.claimReceiptDate = "" /> 
<cfset this.claimEntryDate = "" />
<cfset this.claimTransDate = "" />
<cfset this.claimNo = "" /> 
<cfset this.claimMailTo = "" /> 
<cfset this.claimCust = "" /> 
<cfset this.claimStatus = "" /> 
<cfset this.claimVendor = "" /> 
<cfset this.claimRegion = "" /> 
<cfset this.claimMarket ="" /> 
<cfset this.claimStatus ="" /> <!---- not sure field --->
<cfset this.claimReferenceNo = "" /> 
<cfset this.claimReferenceNo2 = "" /> 
<cfset this.claimVoucher = "" /> 
<cfset this.claimPODPeriod = "" /> 
<cfset this.claimUserID = "" />
<cfset this.claimProgramID ="" />
<cfset this.claimProgramName ="" />
<cfset this.claimItems = StructNew() />
<cfset this.claimLumpSum = StructNew() />
<cfset this.claimNote = ArrayNew(1) />

<cfset variables.claimAjust = "" />
<cfset variables.claimInfo = "" />
<cfset variables.claimItemsInfo = "" />
<cfset variables.claimProgramsInfo = "" />
<cfset variables.billbackID = "" />
<cfset variables.programID = "" />
<cfset variables.endUser = "" />
<cfset variables.contractNumber = "" />
<cfset variables.claimTemplateType = "" />
<cfset variables.claimTemplateName = "" />
<cfset variables.parentBillbackID = "" />

<cfset variables.claimBasicInfo = "" />

<cffunction name="init" output="false" access="public">
	<cfargument name="BillbackID"	type="string" required="true">
	<cfargument name="ProgramID" 	type="string" required="true">
	<cfargument name="EndUser" 		type="string" required="true">
  	<cfset setBillbackID(arguments.BillbackID) />
	<cfset thisClaimPrograms = this.getClaimPrograms() />
	<cfset setClaimProgramsInfo(thisClaimPrograms) />
	<cfif arguments.programID EQ "" and thisClaimPrograms.recordCount GT 0 >
		<cfset thisProgramID = trim(listGetAt(ValueList(thisClaimPrograms.program_id, ","), 1)) />
		<cfset thisContractNumber = trim(listGetAt(ValueList(thisClaimPrograms.contract_number, ","), 1)) />
	<cfelseif  arguments.programID NEQ "">
		<cfset thisProgramID = arguments.programID />
		<cfset thisContractNumber = thisClaimPrograms.contract_number />
	<cfelse>
		<cfset thisProgramID = "" />
		<cfset thisContractNumber = "" />
	</cfif>
	<cfif isDefined("thisProgramID") and thisProgramID EQ "">
		<div align="center" style="color:navy;font:10px"><font size="+2">There's no program associated with this claim!</font></div>	
		<cfabort>
	</cfif>
	<cfset setProgramID(thisProgramID) /> 
	<cfset loadParentBillbackID(arguments.BillbackID) />
	<cfset setContractNumber(thisContractNumber) />
	<cfset setEndUser(arguments.EndUser) /> 
	<cfset loadClaimBasicInfo() />
	<cfset setClaim() />
	<cfset loadClaimItems() />  
	<cfreturn this />
</cffunction>
<!--- get function from claim ---->
<cffunction name="getClaimBasicInfo" output="false" returntype="query" access="public">
	<cfreturn variables.claimBasicInfo />
</cffunction>
<cffunction name="getParentBillbackID" output="false" returntype="string" access="public">
	<cfreturn variables.parentBillbackID />
</cffunction>
<cffunction name="getClaimTemplateType" output="false" access="public" returntype="string">
	<cfreturn variables.claimTemplateType />
</cffunction>
<cffunction name="getClaimTemplateName" output="false" access="public" returntype="string">
	<cfreturn variables.claimTemplateName />
</cffunction>
<cffunction name="getClaimAR" output="false" access="public">
	<cfreturn this.claimAR />
</cffunction>
<cffunction name="getClaimMailTo" 	output="false" returntype="string">
	<cfreturn this.claimMailTo />
</cffunction>
<cffunction name="getClaimCust"		output="false" returntype="string">
	<cfreturn this.claimCust />
</cffunction>
<cffunction name="getClaimStatus" 	output="false" returntype="string">
	<cfreturn this.claimStatus />
</cffunction>
<cffunction name="getClaimNo" output="false" returntype="string">
	<cfreturn this.claimNo  />
</cffunction>
<cffunction name="getClaimRegion" output="false" returntype="string">
	<cfreturn this.claimRegion  />
</cffunction>
<cffunction name="getClaimMarket" output="false" returntype="string">
	<cfreturn this.claimMarket  />
</cffunction>
<cffunction name="getClaimReferenceNo" output="false" returntype="string">
	<cfreturn this.claimReferenceNo  />
</cffunction>
<cffunction name="getClaimReferenceNo2" output="false" returntype="string">
	<cfreturn this.claimReferenceNo2  />
</cffunction>
<cffunction name="getClaimUserID" output="false" returntype="string">
	<cfreturn this.claimUserID  />
</cffunction>
<cffunction name="getClaimApprovedUserID" output="false" returntype="string">
	<cfreturn this.claimApprovedUserID /> 
</cffunction>
<cffunction name="getClaimProgramID" output="false" returntype="string">
	<cfreturn this.claimProgramID  />
</cffunction>
<cffunction name="getClaimProgramName" output="false" returntype="string">
	<cfreturn this.claimProgramName  />
</cffunction>
<cffunction name="getClaimItems" output="false" returntype="struct">
	<cfreturn this.claimItems />
</cffunction>
<cffunction name="getClaimGrowthAmount" output="false" returntype="numeric">
	<cfreturn this.claimedAmount />
</cffunction>
<cffunction name="getClaimPaidGrowthAmount" output="false" returntype="numeric">
	<cfreturn this.claimPaidAmount />
</cffunction>
<cffunction name="getClaimLumpSum" output="false"  returntype="struct">
	<cfreturn this.claimLumpSum />
</cffunction>
<cffunction name="getClaimPODStart" output="false" returntype="string">
	<cfreturn this.claimPODStart  />
</cffunction>
<cffunction name="getClaimPODEnd" output="false" returntype="string">
	<cfreturn this.claimPODEnd />
</cffunction>
<cffunction name="getClaimNote" output="false" returntype="array">
	<cfreturn this.claimNote  />
</cffunction>
<cffunction name="getClaimEndUser" output="false" 		returntype="string">
	<cfreturn this.claimEndUser  />
</cffunction>
<cffunction name="getClaimUserName" output="false" 		returntype="string">
	<cfreturn this.claimEndUserName   />
</cffunction>
<cffunction name="getClaimVendorID" output="false" 		returntype="string">
	<cfreturn this.claimVendorID  />
</cffunction>
<cffunction name="getClaimPostMarkDate" output="false" returntype="string">
	<cfreturn this.claimPostMarkDate  />
</cffunction>
<cffunction name="getClaimReceiptDate" output="false" 	returntype="string">
	<cfreturn this.claimReceiptDate  />
</cffunction>
<cffunction name="getClaimEntryDate" output="false" 	returntype="string">
	<cfreturn this.claimEntryDate  />
</cffunction>
<cffunction name="getClaimTransDate" output="false" 	returntype="string">
	<cfreturn this.claimTransDate  />
</cffunction>
<cffunction name="getClaimAjust" output="false" returntype="query" access="public">
	<cfreturn variables.claimAjust />
</cffunction>
<cffunction name="getClaimInfo" output="false" returntype="query" access="public">
	<cfreturn variables.claimInfo />
</cffunction>
<cffunction name="getClaimItemsInfo" output="false" returntype="query" access="public">
	<cfreturn variables.claimItemsInfo />
</cffunction>
<cffunction name="getClaimProgramsInfo" output="false" returntype="query" access="public">
	<cfreturn variables.claimProgramsInfo />
</cffunction>
<cffunction name="getBillbackID" output="false" returntype="string" access="public">
	<cfreturn variables.billbackID />
</cffunction>
<cffunction name="getProgramID" output="false" returntype="string"  access="public">
	<cfreturn variables.programID />
</cffunction>
<cffunction name="getEndUser" output="false" returntype="string"  access="public">
	<cfreturn variables.endUser />
</cffunction>
<cffunction name="getContractNumber" output="false" returntype="string"  access="public">
	<cfreturn variables.contractNumber />
</cffunction>
<!---- set function for the claim (per billback, per program)---->
<cffunction name="setClaimBasicInfo" output="false" returntype="void" access="package">
	<cfargument name="claimBasicInfo" required="true" type="query">
	<cfset variables.claimBasicInfo = arguments.claimBasicInfo />
</cffunction>

<cffunction name="setParentBillbackID" output="false" returntype="void" access="package">
	<cfargument name="parentBillbackID" required="true" type="string">
	<cfset variables.parentBillbackID = arguments.parentBillbackID />
</cffunction>

<cffunction name="setBillbackID" output="false" returntype="void" access="package">
	<cfargument name="billbackID" required="true" type="string">
	<cfset variables.billbackID = arguments.billbackID />
</cffunction>

<cffunction name="setProgramID" output="false" returntype="void" access="package">
	<cfargument name="programID" required="true" type="string">
	<cfset variables.programID = arguments.programID />
</cffunction>

<cffunction name="setEndUser" output="false" returntype="void" access="package">
	<cfargument name="endUser" required="true" type="string">
	<cfset variables.endUser = arguments.endUser />
</cffunction>

<cffunction name="setContractNumber" output="false" returntype="void" access="package">
	<cfargument name="contractNumber" required="true" type="string">
	<cfset variables.contractNumber = arguments.contractNumber />
</cffunction>

<cffunction name="setClaimAdjust" output="false" returntype="void" access="package">
	<cfargument name="claimAjust" required="true" type="query">
	<cfset variables.claimAjust = arguments.claimAjust />
</cffunction>

<cffunction name="setClaimInfo" output="false" returntype="void" access="package">
	<cfargument name="claimInfo" required="true" type="query">
	<cfset variables.claimInfo = arguments.claimInfo />
</cffunction>

<cffunction name="setClaimItemsInfo" output="false" returntype="void" access="package">
	<cfargument name="claimItemsInfo" required="true" type="query">
	<cfset variables.claimItemsInfo = arguments.claimItemsInfo />
</cffunction>

<cffunction name="setClaimProgramsInfo" output="false" returntype="void" access="package">
	<cfargument name="claimProgramsInfo" required="true" type="query">
	<cfset variables.claimProgramsInfo = arguments.claimProgramsInfo />
</cffunction>

<cffunction name="setClaimTemplateType" output="false" returntype="void" access="package">
	<cfargument name="claimTemplateType" required="true" type="string">
	<cfset variables.claimTemplateType = arguments.claimTemplateType />
</cffunction>

<cffunction name="setClaimTemplateName" output="false" returntype="void" access="package">
	<cfargument name="claimTemplateName" required="true" type="string">
	<cfset variables.claimTemplateName = arguments.claimTemplateName />
</cffunction>

<!---------------methods ----------->
<cffunction name="setClaim" output="false" access="package">
	<!------ Get application settings ----->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	<cfset thisOriginalBillbackID = this.getBillbackID() />
	<cfif trim(this.getParentBillbackID()) NEQ "">
		<cfset thisBillbackID = this.getParentBillbackID() />
	<cfelse>
		<cfset thisBillbackID = this.getBillbackID() />
	</cfif>
 
	<CFQUERY NAME="qryGetClaimInfo" DATASOURCE="#application.datasource#">		
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		select distinct  
			<cfif thisOriginalBillbackID neq thisBillbackID>
			1 as split_billback_flag,
			<cfelse>
			0 as split_billback_flag,
			</cfif>
			Billback.BB_Code AS claimNo, 
			CONVERT(varchar, Billback.BB_Date, 101) AS claimEntryDate,
			isnull(_Users.Name_First+ ' ' + _Users.Name_Last,' ')  AS UserID,
			Billback.Billback_ID,
			isnull(Billback.bb_Amount, 0) AS claimAmount,
			bb_approved.Paid_Amount AS paidAmount, 
			isnull(Billback_Product.BB_Product_Quantity, 0) AS claimCS,
			isnull(BB_Item_Final.Item_Volume_Paid_CS, 0) AS paidCS,
			isnull(BB_Item_Final.Item_Volume_Paid_CS, 0) AS itemPaidCS,
			case when Billback_Product_Detail.BB_Product_Type_ID = 10  then Billback_Product_Detail.BB_Rate else isnull(BB_Item_Final.Item_Total_Paid, 0) end AS itemPaidAmount,
			isnull((select paid_amount from bb_approved where billback_id = '#thisOriginalBillbackID#'), 0) as splitAdjustedPaidAmount,
			Billback_Program.Billback_Program_ID, 
			Billback_Program.Program_ID, 
			Billback_Product.Billback_Product_ID, 
			Billback_Product.Product_ID, 
			Billback_Product.Distributor_ID, 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
			Billback_Product.BB_Product_Quantity, 
			Units_Of_Measure.Unit_Of_Measure_Desc,
			CASE WHEN Program_ID IS NULL THEN Billback_Program.BB_Program_Title ELSE Contract_Main.Contract_Title END AS Program_Title,
			CASE WHEN Program_ID IS NULL THEN Billback_Program.BB_Program_Number ELSE Contract_Main.Contract_Number END AS Program_Number,
			CASE WHEN Product_ID IS NULL THEN Billback_Product.BB_Unknown_Product_Item_Number ELSE case when Billback_Product_Detail.BB_Product_Type_ID = 10  then BSA_Foodservice_Items_Master.Item + 'CAJ' else BSA_Foodservice_Items_Master.Item END END AS Item_Number,
			CASE WHEN Product_ID IS NULL THEN Billback_Product.BB_Unknown_Product_Description ELSE case when Billback_Product_Detail.BB_Product_Type_ID = 10  then 'Claim Adjust' else BSA_Foodservice_Items_Master.Description END END AS Description,
			Billback_Product_Detail.BB_Product_Type_ID, 
			Billback_Product_Detail.BB_Rate,
			---- rebate (unit price)
			case when bb_item_final.item_volume_paid_cs > 0 and bb_item_final.item_total_paid > 0 then bb_item_final.item_total_paid / bb_item_final.item_volume_paid_cs else 0 end as rebate
			,Billback.Auto_Billback <!---D35038: hnz ehancement -- claim summary updates for auto pay billbacks --->
		FROM Billback
		left join bb_approved on bb_approved.billback_id = billback.billback_id
		LEFT JOIN _Users
		ON (
		( BB_Approved.user_approved = _Users.user_id
		AND BB_Approved.user_approved is not null
		)
		OR (
		BB_Approved.user_approved is null
		AND  Billback.BB_Creator_ID = _Users.user_id
		)
		)	
		INNER JOIN 	Billback_Program 
		ON 	Billback_Program.Billback_ID = Billback.Billback_ID
		AND 	Billback_Program.Deleted = 0
		LEFT JOIN  Contract_Main 
		ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID 
		LEFT JOIN  program_control_panel_options
		ON Contract_Main.ProgramType_ID = program_control_panel_options.ProgramControl_Panel_Options_ID
		left JOIN   	Billback_Product
		ON Billback_Product.Billback_ID = Billback_Program.Billback_ID
		AND Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID
		AND Billback_Product.Deleted = 0		
		LEFT JOIN   BSA_Foodservice_Items_Master
		ON  BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID=Billback_Product.Product_ID 
		--AND BSA_Foodservice_Items_Master.Deleted = 0
		LEFT JOIN   Units_of_Measure
		ON  Units_of_Measure.Unit_Of_Measure_ID = Billback_Product.BB_Product_UOM
		LEFT JOIN  Billback_Product_Detail
		ON  Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
		AND Billback_Product_Detail.Deleted = 0
		--AND Billback_Product_Detail.BB_Rate IS NOT NULL
		--AND LEN(RTRIM(Billback_Product_Detail.BB_Rate)) > 0
		--AND ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1	
		Left JOIN  BB_Item_Final
		ON  Billback_Program.Billback_ID = BB_Item_Final.Billback_ID 
		AND  Billback_Program.Billback_Program_ID = BB_Item_Final.Billback_Program_ID 
		AND Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID			
		WHERE Billback.Billback_ID =  '#PreserveSingleQuotes(thisBillbackID)#'  
		<cfif this.getEndUser() NEQ "" and this.getEndUser() NEQ 0>
			(WHEN bb.Billback_Payee_Type_ID=1 THEN	
					isnull(( select top 1 COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50))) from BSA_Operator where deleted = 0 and BSA_Operator_ID in (select top 1 BSA_Operator_ID from contract_operators where deleted = 0 and contract_main_id = billback_program.program_id)),' ')	 
				WHEN bb.Billback_Payee_Type_ID=2 THEN
		       			ISNull(COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50))), ' ') 
				WHEN bb.Billback_Payee_Type_ID=4 THEN	
					isnull(( select top 1 COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50))) from BSA_Operator where deleted = 0 and BSA_Operator_ID in (select top 1 BSA_Operator_ID from contract_operators where deleted = 0 and contract_main_id = billback_program.program_id)),' ')	
				else ''
			end) like '#this.getEndUser()#%'
		</cfif>
		AND		Billback_Program.program_id = '#this.getProgramID()#' 		
		ORDER BY claimNo, Billback.Billback_ID, Billback_Program.Billback_Program_ID, Billback_Product.Billback_Product_ID,Billback_Product_Detail.BB_Product_Type_ID 

 	</CFQUERY>
	
	<cfset setClaimInfo(qryGetClaimInfo) />
	<!--- set program information ---->
	<cfset setClaimProgramID(qryGetClaimInfo.Program_Number) />
	<cfset setClaimProgramName(qryGetClaimInfo.Program_Title) />
	<cfloop query="qryGetClaimInfo">
		<cfset setClaimItems(Item_Number,Description,itemPaidCS,itemPaidAmount) />
	</cfloop>
</cffunction>
<cffunction name="setClaimAR" output="false" access="public">
	<cfargument name="claimAR" type="string" default="" required="true">
	<cfset this.claimAR = arguments.claimAR />
</cffunction>
<cffunction name="setClaimTransDate" output="false" access="public">
	<cfargument name="claimTransDate" type="string" default="" required="true">
	<cfset this.claimTransDate = arguments.claimTransDate />
</cffunction>
<cffunction name="setClaimVendorID" output="false" access="public">
	<cfargument name="VendorID" type="string" default="" required="true">
	<cfset this.claimVendorID = arguments.VendorID />
</cffunction>
<cffunction name="setClaimReceiptDate" output="false" access="public">
	<cfargument name="ReceiptDate" type="string" default="" required="true">
	<cfset this.claimReceiptDate = arguments.ReceiptDate />
</cffunction>
<cffunction name="setClaimEntryDate" output="false" access="public">
	<cfargument name="EntryDate" type="string" default="" required="true">
	<cfset this.claimEntryDate = arguments.EntryDate />
</cffunction>
<cffunction name="setClaimPostMarkDate" output="false" access="public">
	<cfargument name="PostMarkDate" type="string" default="" required="true">
	<cfset this.claimPostMarkDate = arguments.PostMarkDate />
</cffunction>
<cffunction name="setClaimEndUserName" output="false" access="public">
	<cfargument name="End_User_Name" type="string" default="" required="true">
	<cfset this.claimEndUserName = arguments.End_User_Name />
</cffunction>
<cffunction name="setClaimEndUser" output="false" access="public">
	<cfargument name="End_User" type="string" default="" required="true">
	<cfset this.claimEndUser = arguments.End_User />
</cffunction>
<cffunction name="setClaimNote" output="false" access="public">
	<cfargument name="claimNote" type="string" default="" required="true">
	<cfargument name="claimDeductionIDS" type="string" default="" required="true">
	<cfif arguments.claimNote NEQ "">
		<cfset this.claimNote[ArrayLen(this.claimNote)+1] = arguments.claimNote />
	</cfif>
	<cfif arguments.claimDeductionIDS NEQ "">
		<cfset this.claimNote[ArrayLen(this.claimNote)+1] = "Clears Deduction ID## " &  arguments.claimDeductionIDS />
	</cfif>
</cffunction>
<cffunction name="setClaimPODStart" output="false" access="public">
	<cfargument name="startDate" type="string" default="" required="true">
	<cfset this.claimPODStart = arguments.startDate />
</cffunction>
<cffunction name="setClaimPODEnd" output="false" access="public">
	<cfargument name="endDate" type="string" default="" required="true">
	<cfset this.claimPODEnd = arguments.endDate />
</cffunction>
<cffunction name="setClaimLumpSum" output="false" access="public">
	<cfargument name="BillbackID" type="string" default="" required="true">
	<cfargument name="ProgramID" type="string" default="" required="true">
	<cfset thisOriginalBillbackID = this.getBillbackID() />
	<cfif trim(this.getParentBillbackID()) NEQ "">
		<cfset thisBillbackID = this.getParentBillbackID() />
	<cfelse>
		<cfset thisBillbackID = this.getBillbackID() />
	</cfif>
	
	<CFQUERY NAME="qryGetClaimLumpSum" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		SELECT distinct
			ISNULL((select top 1 paid_amount from bb_approved where billback_id = '#thisBillbackID#'),0) as parentTotalPaid, 	
			ISNULL((select top 1 paid_amount from bb_approved where billback_id = '#thisOriginalBillbackID#'),0) as childTotalPaid,
 			(select top 1 split_billback_flag from claim_summary_report where billback_id = '#thisOriginalBillbackID#' ) as split_billback_flag,
 			Billback_Program_Lumpsum_Component.Billback_Program_ID, 
 			Billback_Program_Lumpsum_Component_ID, 
 			Amount,
 			CASE   WHEN Component_Type_ID = 1 THEN Program_Lump_Sum_Name.Program_Lump_Sum_Name
       			   WHEN Component_Type_ID = 3 THEN Program_Growth_Components.Component_Name + ' Tier ' + Program_Growth_Component_Tiers.Tier_Number
			ELSE Billback_Program_Lumpsum_Component.Name END AS Component_Name					
		FROM 		Billback_Program_Lumpsum_Component
		inner join 	billback_program
				on 	Billback_Program_Lumpsum_Component.Billback_Program_ID = billback_program.Billback_Program_ID
				and billback_program.program_id = '#arguments.ProgramID#'
		LEFT JOIN 	Program_Lump_Sums	
				ON (Program_Lump_Sums.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID)
		LEFT JOIN Program_Lump_Sum_Name 
				ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
		LEFT JOIN Program_Growth_Components	
				ON Program_Growth_Components.Program_Growth_Component_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
		LEFT JOIN Program_Growth_Component_Tiers 
				ON Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = Billback_Program_Lumpsum_Component.Program_Growth_Component_Tier_ID		
		WHERE  	(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
		AND		(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
		AND		(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
		AND		(CAST(Billback_Program_Lumpsum_Component.Amount AS Float) > 0)
		AND		Billback_Program_Lumpsum_Component.Billback_ID 		= '#PreserveSingleQuotes(thisBillbackID)#'
		AND		Billback_Program_Lumpsum_Component.Deleted 			= 0
		ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
	</CFQUERY>
	<cfloop query="qryGetClaimLumpSum">
		<cfset setLumpSum(Component_Name, Amount,split_billback_flag,parentTotalPaid,childTotalPaid) />
	</cfloop>
</cffunction>
<cffunction name="setLumpSum" output="false" access="public">
	<cfargument name="compName"	type="string" 	default="" required="true">
	<cfargument name="amount" 	type="numeric" 	default="" required="true">
	<cfargument name="split_billback_flag" 	type="numeric" 	default="" required="true">
	<cfargument name="parentTotalPaid" 		type="numeric" 	default="" required="true">
	<cfargument name="childTotalPaid" 		type="numeric" 	default="" required="true">
	<cfif arguments.split_billback_flag EQ 1>
			<cfif arguments.parentTotalPaid GT 0>
				<cfset thisAmount = arguments.amount * arguments.childTotalPaid / arguments.parentTotalPaid />
			<cfelse>
				<cfset thisAmount = 0/>
			</cfif>
		<cfelse>
			<cfset thisAmount = arguments.amount />
	</cfif>
	<cfif Not StructKeyExists(this.claimLumpSum, trim(arguments.compName)) >
		<cfset this.claimLumpSum[trim(arguments.compName)]  = thisAmount />
	<cfelse>
		<cfset this.claimLumpSum[trim(arguments.compName) & "(dup)"] = thisAmount />
	</cfif>
</cffunction>
<cffunction name="setClaimGrowth" output="false" access="public">
	<cfargument name="BillbackID" 	type="string" default="" required="true">
	<cfargument name="ProgramID" 	type="string" default="" required="true">

	<CFQUERY NAME="qryGetClaimGrowth" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		select distinct 
				(select top 1 paid_amount from bb_approved where billback_id = '#thisBillbackID#') as parentTotalPaid, 	
				(select top 1 paid_amount from bb_approved where billback_id = '#thisOriginalBillbackID#') as childTotalPaid,
 				(select top 1 split_billback_flag from claim_summary_report where billback_id = '#thisOriginalBillbackID#' ) as split_billback_flag,		
				isnull(bb_growth_program.BB_Growth_Amount, 0) as BB_Growth_Amount, 
				isnull(bb_growth_program.Paid_Amount, 0) AS Paid_Amount
		from bb_growth_program
		inner join 	billback_program
				on 	billback_program.program_id = '#arguments.ProgramID#'
				and billback_program.billback_id = bb_growth_program.billback_id 
				and billback_program.billback_program_id = bb_growth_program.billback_program_id
		where bb_growth_program.billback_id = '#PreserveSingleQuotes(arguments.BillbackID)#'
		and	  bb_growth_program.deleted = 0
	</CFQUERY>
	<cfif qryGetClaimGrowth.recordCount GT 0>
		<cfif qryGetClaimGrowth.split_billback_flag EQ 1>
			<cfif qryGetClaimGrowth.parentTotalPaid GT 0>
				<cfset thisAmount = qryGetClaimGrowth.Paid_Amount * qryGetClaimGrowth.childTotalPaid / qryGetClaimGrowth.parentTotalPaid />
			<cfelse>
				<cfset thisAmount = 0/>
			</cfif>
		<cfelse>
			<cfset thisAmount = qryGetClaimGrowth.Paid_Amount />
		</cfif>
		<cfset setClaimGrowthAmount(qryGetClaimGrowth.BB_Growth_Amount) />
		<cfset setClaimPaidGrowthAmount(thisAmount) />
	</cfif>
</cffunction>
<cffunction name="setClaimGrowthAmount" output="false" access="public">
	<cfargument name="claimedAmount" type="numeric" default="" required="true">
	<cfset this.claimedAmount = arguments.claimedAmount />
</cffunction>
<cffunction name="setClaimPaidGrowthAmount" output="false" access="public">
	<cfargument name="paidAmount" type="numeric" default="" required="true">
	<cfset this.claimPaidAmount = arguments.paidAmount />
</cffunction>
<cffunction name="setClaimItems" output="false" access="public">
	<cfargument name="itemNo" 	type="string" default="" required="true">
	<cfargument name="desc" type="string" default="" required="true">
	<cfargument name="paidCS" type="numeric" default="" required="true">
	<cfargument name="paidAmount"  type="numeric" default="" required="true">
	<cfif Not StructKeyExists(this.claimItems, arguments.itemNo) >
		<cfset this.claimItems[arguments.itemNo] = StructNew() />
		<cfset this.claimItems[arguments.itemNo]["desc"] =	arguments.desc />
		<cfset this.claimItems[arguments.itemNo]["units"] =	arguments.paidCS />
		<cfset this.claimItems[arguments.itemNo]["extension"] =	arguments.paidAmount />
		<cfif arguments.paidCS GT 0>
			<cfset this.claimItems[arguments.itemNo]["rebate"] = arguments.paidAmount / arguments.paidCS  />
		<cfelse>
			<cfset this.claimItems[arguments.itemNo]["rebate"] = 0 >
		</cfif>
		<cfset this.claimItems[arguments.itemNo]["entrydate"] =	"01/01/2004" />
		<cfset this.claimItems[arguments.itemNo]["usrid"] =	"linling liu" /> 
	</cfif>
</cffunction>
<cffunction name="setClaimMailTo" output="false" access="public">
	<cfargument name="name" 	type="string" default="" required="true">
	<cfargument name="address1" type="string" default="" required="true">
	<cfargument name="address2" type="string" default="" required="true">
	<cfargument name="city" 	type="string" default="" required="true">
	<cfargument name="state" 	type="string" default="" required="true">
	<cfargument name="zip" 		type="string" default="" required="true">
	
	<cfif isDefined("arguments.name") and arguments.name NEQ "">
		<cfset this.claimMailTo = trim(arguments.name) & "#chr(13)##chr(10)#" />
	</cfif>
	<cfif isDefined("arguments.address1") and arguments.address1 NEQ "">
		<cfset this.claimMailTo = this.claimMailTo & trim(arguments.address1) & "#chr(13)##chr(10)#" />
	</cfif>
	<cfif isDefined("arguments.address2") and arguments.address2 NEQ "">
		<cfset this.claimMailTo = this.claimMailTo & trim(arguments.address2) & "#chr(13)##chr(10)#" />
	</cfif>
	<cfif isDefined("arguments.city") and arguments.city NEQ "">
		<cfset this.claimMailTo = this.claimMailTo & trim(arguments.city) />
	</cfif>
	<cfif isDefined("arguments.state") and trim(arguments.state) NEQ "">
		<cfset this.claimMailTo = this.claimMailTo & ", " & trim(arguments.state) />
	</cfif>
	<cfif isDefined("arguments.zip") and trim(arguments.zip) NEQ "">
		<cfset this.claimMailTo = this.claimMailTo & "  " & trim(arguments.zip) & "#chr(13)##chr(10)#" />
	</cfif>
</cffunction>
<cffunction name="setClaimNo" output="false" access="public">
	<cfargument name="claimNo" type="string" default="" required="true">
	<cfset this.claimNo = arguments.claimNo /> 
</cffunction>
<cffunction name="setClaimCust" output="false" access="public">
	<cfargument name="distID" type="string" default="" required="true">
	<cfset this.claimCust = arguments.distID /> 
</cffunction>
<cffunction name="setClaimStatus" output="false" access="public">
	<cfargument name="claimStatus" type="string" default="" required="true">
	<cfset this.claimStatus = arguments.claimStatus /> 
</cffunction>
<cffunction name="setClaimRegion" output="false" access="public">
	<cfargument name="claimRegion" type="string" default="" required="true">
	<cfset this.claimRegion = arguments.claimRegion /> 
</cffunction>
<cffunction name="setClaimMarket" output="false" access="public">
	<cfargument name="claimMarket" type="string" default="" required="true">
	<cfset this.claimMarket = arguments.claimMarket /> 
</cffunction>
<cffunction name="setClaimReferenceNo" output="false" access="public">
	<cfargument name="claimNo" type="string" default="" required="true">
	<cfset this.claimReferenceNo = arguments.claimNo /> 
</cffunction>
<cffunction name="setClaimReferenceNo2" output="false" access="public">
	<cfargument name="claimNo2" type="string" default="" required="true">
	<cfset this.claimReferenceNo2 = arguments.claimNo2 /> 
</cffunction>
<cffunction name="setClaimUserID" output="false" access="public">
	<cfargument name="claimUserID" type="string" default="" required="true">
	<cfset this.claimUserID = trim(arguments.claimUserID) /> 
</cffunction>
<cffunction name="setClaimApprovedUserID" output="false" access="public">
	<cfargument name="claimApprovedUsrFirst" type="string" default="" required="true">
	<cfargument name="claimApprovedUsrLast" type="string" default="" required="true">
	<cfset this.claimApprovedUserID = trim(arguments.claimApprovedUsrFirst) & " " & trim(arguments.claimApprovedUsrLast) /> 
</cffunction>
<cffunction name="setClaimProgramID" output="false" access="public">
	<cfargument name="Program_Number" type="string" default="" required="true">
	<cfset this.claimProgramID = trim(arguments.Program_Number) /> 
</cffunction>
<cffunction name="setClaimProgramName" output="false" access="public">
	<cfargument name="Program_Title" type="string" default="" required="true">
	<cfset this.claimProgramName = trim(arguments.Program_Title) /> 
</cffunction>

<!---- get total information ---->
<!--- billback total --->
<cffunction name="getTotal" output="false" returntype="query">
	<cfargument name="BillbackID" type="string" default="" required="true">
	<cfargument name="ProgramID" type="string" default="" required="true">
	<cfset thisOriginalBillbackID = this.getBillbackID() />
	<cfif trim(this.getParentBillbackID()) NEQ "">
		<cfset thisBillbackID = this.getParentBillbackID() />
	<cfelse>
		<cfset thisBillbackID = this.getBillbackID() />
	</cfif>

	<CFQUERY NAME="qryGetTotal" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		select 	billback.billback_id, 
				isnull(billback.bb_Amount, 0) as distributorAmount,
				bb_approved.Paid_Amount as claimAmount, 
				sum(bb_item_final.item_volume_paid_cs) as claimCS,
				sum(case WHEN Billback_Product.BB_Product_UOM = 2 THEN CAST(Billback_Product.BB_Product_Quantity AS FLOAT) / ISNULL(CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT), 1) ELSE Billback_Product.BB_Product_Quantity end) as distributorCS,
				<cfif thisOriginalBillbackID neq thisBillbackID> <!--- if split --->
				(select paid_Amount from bb_approved where billback_id = '#thisOriginalBillbackID#') as splitPaidAmont,
				(select isnull(billback.bb_Amount, 0) from bb_approved where billback_id =  '#thisOriginalBillbackID#') as splitClaimAmount,
				1 as split_billback_flag
				<cfelse> <!--- if not split --->
				bb_approved.paid_Amount as splitPaidAmont,
				isnull(billback.bb_Amount, 0) as splitClaimAmount,
				0 as split_billback_flag
				</cfif>
		from billback 
		left join bb_approved on bb_approved.billback_id = billback.billback_id
		left join billback_program 
		on billback.billback_id = billback_program.billback_id 
		and billback_program.program_id = '#arguments.ProgramID#'
		and billback_program.deleted = 0
		left JOIN  Billback_Product
		ON Billback_Product.Billback_ID = Billback_Program.Billback_ID
		AND Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID
		AND Billback_Product.Deleted = 0
		LEFT JOIN   BSA_Foodservice_Items_Master
		ON  BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID=Billback_Product.Product_ID 
		left join bb_item_final 
		on billback_program.billback_id = bb_item_final.billback_id 
		and billback_program.billback_program_id = bb_item_final.billback_program_id 
		and billback_product.billback_product_id = bb_item_final.billback_product_id
		and bb_item_final.deleted = 0
		where billback.billback_id = '#thisBillbackID#'
		Group by 	billback.billback_id, 
					isnull(billback.bb_Amount, 0),
					bb_approved.paid_Amount
	</CFQUERY>

	<cfreturn qryGetTotal />
</cffunction>
<!--- distributor total ---->
<!--- deduction closure information --->
<cffunction name="getDedIDList" output="false" returntype="string">
	<cfargument name="BillbackID"	type="string" default="" required="true">
	<CFQUERY NAME="qryGetDedIDList" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		select distinct DD_DedID
		from deductions
		where dd_closure_type = 1
		and dd_closure_id = '#arguments.BillbackID#'
		and deleted = 0
	</CFQUERY>
	<cfif qryGetDedIDList.recordCount GT 0>
		<cfreturn ValueList(qryGetDedIDList.DD_DedID) />
	<cfelse>
		<cfreturn '' />
	</cfif>
</cffunction>
<!--- has any growth --->
<cffunction name="hasGrowth" output="false" returntype="boolean">
	<cfargument name="BillbackID"	type="string" default="" required="true">
	<cfargument name="ProgramID" 	type="string" default="" required="true">
	<CFQUERY NAME="qryGetClaimGrowth" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		select *
		from bb_growth_program
		inner join 	billback_program
				on 	billback_program.program_id = '#arguments.ProgramID#'
				and billback_program.billback_id = bb_growth_program.billback_id 
				and billback_program.billback_program_id = bb_growth_program.billback_program_id
		where bb_growth_program.billback_id = '#PreserveSingleQuotes(arguments.BillbackID)#'
		and	  bb_growth_program.deleted = 0
	</CFQUERY>
	<cfif qryGetClaimGrowth.recordCount GT 0>
		<cfreturn true />
	<cfelse>
		<cfreturn false />
	</cfif>
</cffunction>
<!--- has lump sum --->
<cffunction name="hasLumpSum" output="false" returntype="boolean">
	<cfargument name="BillbackID" 	type="string" default="" required="true">
	<cfargument name="ProgramID" 	type="string" default="" required="true">
	
	<CFQUERY NAME="qryGetClaimLumpSum" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		SELECT 		Billback_Program_Lumpsum_Component.Billback_ID				
		FROM 		Billback_Program_Lumpsum_Component
		inner join 	billback_program
				on 	Billback_Program_Lumpsum_Component.Billback_ID = billback_program.Billback_ID
				and Billback_Program_Lumpsum_Component.Billback_Program_ID = billback_program.Billback_Program_ID
				and billback_program.program_id = '#arguments.ProgramID#'
				and billback_program.Deleted = 0
		WHERE  	Billback_Program_Lumpsum_Component.Billback_ID = '#PreserveSingleQuotes(arguments.BillbackID)#'
		--AND		(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
		--AND		(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
		--AND		(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
		--AND		(CAST(Billback_Program_Lumpsum_Component.Amount AS Float) > 0)
		AND		Billback_Program_Lumpsum_Component.Deleted = 0
	</CFQUERY>
	
	<cfif qryGetClaimLumpSum.recordCount GT 0>
		<cfreturn true />
	<cfelse>
		<cfreturn false />
	</cfif>
</cffunction>
<!--- adjustedItemPaidCases,
			adjustedItemPaidAmount--->

<cffunction name="loadClaimItems" output="false" returntype="void" access="package">
	<cfset qClaimInfo = this.getClaimInfo() />
	<cfquery dbtype="query" name="qryGetClaimItems">
		select distinct Item_Number as item,
			Description,
			split_billback_flag,
			Program_Number as program,
			itemPaidCS as units,
			itemPaidAmount as extension,
			claimAmount,
			paidAmount,
			SPLITADJUSTEDPAIDAMOUNT,
			claimEntryDate,rebate,UserID
			 <!---D35038: hnz ehancement -- claim summary updates for auto pay billbacks START--->
			,Auto_Billback
			,Program_ID
			,Product_ID
			,Distributor_ID
			<!---D35038: hnz ehancement -- claim summary updates for auto pay billbacks END--->
		from qClaimInfo
		order by 1, 2
	</cfquery>
	<cfset setClaimItemsInfo(qryGetClaimItems) />
</cffunction>
<!----utility to convert html to the text format --->
<cffunction name="TextAlignLeft" output="false" returntype="string">
	<cfargument name="thisFieldLen" type="numeric" 	default="" required="true">
	<cfargument name="thisStr" 		type="string" 	default="" required="true">
	<cfif arguments.thisFieldLen LT Len(arguments.thisStr)>
		<cfreturn left(arguments.thisStr, arguments.thisFieldLen) />
	<cfelse>
		<cfreturn trim(arguments.thisStr) & RepeatString(' ', arguments.thisFieldLen - Len(arguments.thisStr)) />  
	</cfif>
</cffunction>
<cffunction name="TextAlignRight" output="false" returntype="string">
	<cfargument name="thisFieldLen" type="numeric" 	default="" required="true">
	<cfargument name="thisStr" 		type="string" 	default="" required="true">
	<!---<cfloop from="" to="" step="" index=""></cfloop>--->
	<cfif arguments.thisFieldLen LT Len(arguments.thisStr)>
		<cfreturn left(arguments.thisStr, arguments.thisFieldLen) />
	<cfelse>
		<cfreturn RepeatString(' ', arguments.thisFieldLen - Len(arguments.thisStr)) & right(arguments.thisStr, len(arguments.thisStr)) />  
	</cfif>
</cffunction>
<cffunction name="getClaimPrograms" output="false" returntype="query" access="public">
	<cfset thisBillbackID = this.getBillbackID() />
							<CFQUERY NAME="qryGetClaimPrograms" DATASOURCE="#application.datasource#">
								SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
								
								select 			distinct billback_program.program_id, contract_main.contract_number
								from 			billback_program
								inner JOIN  	Contract_Main 
										ON  	Billback_Program.Program_ID = Contract_Main.Contract_Main_ID 
								where 	billback_program.Billback_ID = '#thisBillbackID#' 
								and		billback_program.deleted = 0
								ORDER BY 1, 2	
							</CFQUERY>

	<cfreturn qryGetClaimPrograms />
</cffunction>

<cffunction name="loadClaimBasicInfo" output="false" returntype="void" access="public">
	<cfset thisBillbackID = this.getBillbackID() />
	
	<CFQUERY NAME="qryGetClaimBasicInfo" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		 select top 1  
			isnull(vendor_master.vendor_id,'') as claimVendorID,
			isnull(vendor_master.vendor_name + ' (' + vendor_master.vendor_id + ')','') as vendor_name,
			isnull(vendor_master.Address_1,'') as vendorAddress1,
			isnull(vendor_master.Address_2,'') as vendorAddress2,
			isnull(vendor_master.City,'') as vendorCity,
			isnull(vendor_master.State,'') as vendorState,
			isnull(vendor_master.ZipCode,'') as vendorZip,
			Billback.BB_Code AS claimNo, 
			Billback.bb_reference AS claimRef,  
			Billback.referenceNum AS claimRef2,
			isnull(_Users.Name_First+ ' ' + _Users.Name_Last,' ') as UserID,
			isnull(
			CASE
				WHEN Billback.Billback_Payee_Type_ID=1 THEN		
					BSA_Foodservice_Customers.Shr_Ship_To	
				WHEN Billback.Billback_Payee_Type_ID=2 THEN
					COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50)))
				--WHEN Billback.Billback_Payee_Type_ID=4 THEN 
				--	CAST((select BSA_Foodservice_Customers.Shr_Ship_To from BSA_Foodservice_Customers where deleted = 0 and BSA_Foodservice_Customers_ID = Billback_Unidentified_Payee.Associated_Ship_To) AS VARCHAR(60))						
				ELSE '9999999'
			END, '9999999') AS distID,

			isnull(CASE
				WHEN Billback.Billback_Payee_Type_ID=1 THEN		
					isnull(( select top 1 BSA_Operator.Operator_Name from BSA_Operator where deleted = 0 and BSA_Operator_ID in (select top 1 BSA_Operator_ID from contract_operators where contract_main_id = billback_program.program_id and deleted =0 )),' ')
				WHEN Billback.Billback_Payee_Type_ID=2 THEN
					BSA_operator.operator_name 
				WHEN Billback.Billback_Payee_Type_ID=4 THEN		
					isnull(( select top 1 BSA_Operator.Operator_Name from BSA_Operator where deleted = 0 and BSA_Operator_ID in (select top 1 BSA_Operator_ID from contract_operators where contract_main_id = billback_program.program_id and deleted =0 )),' ')	
				ELSE ' '
			END, ' ')  AS End_User_Name,
			case 
				WHEN Billback.Billback_Payee_Type_ID=1 THEN	
					isnull(( select top 1 COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50))) from BSA_Operator where deleted = 0 and BSA_Operator_ID in (select top 1 BSA_Operator_ID from contract_operators where deleted = 0 and contract_main_id = billback_program.program_id)),' ')	 
				WHEN Billback.Billback_Payee_Type_ID=2 THEN
		       			ISNull(COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50))), ' ') 
				WHEN Billback.Billback_Payee_Type_ID=4 THEN	
					isnull(( select top 1 COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50))) from BSA_Operator where deleted = 0 and BSA_Operator_ID in (select top 1 BSA_Operator_ID from contract_operators where deleted = 0 and contract_main_id = billback_program.program_id)),' ')	
				else ''
			end AS End_User,


			Billback_Status.BB_Status_Description AS claimStatus,
			Billback.Billback_Status_ID,
			CONVERT(varchar, Billback.BB_Start_Date, 101) AS bbStartDate,
			CONVERT(varchar, Billback.BB_End_Date, 101) AS bbEndDate,
			CONVERT(varchar, Billback.Postmark_Date, 101) AS claimPostMarkDate,
			CONVERT(varchar, Billback.BB_Date, 101) AS claimEntryDate,
			CONVERT(varchar, Billback.BB_Received_Date, 101) AS claimReceiptDate,
			Billback.Created_Date,
			Billback.Billback_ID,
			ISNULL(Service_Zones.Zone_Name, ' ') as Division,
			ISNULL(Service_Regions.Region_Name, ' ') as Region,
			ISNULL(Service_Markets.Market_Name, ' ') as Market,
			isnull(program_control_panel_options.A_R, '') AS A_R,
			Billback_Program.Billback_Program_ID,  
			--- template type
			isnull(program_control_panel_options.generic_type,' ') as claimTemplateType,
			--- template name
			isnull(program_control_panel_options.created_type,' ') as claimTemplateName,
			(SELECT Min(Interface_Executed_On) FROM Log_700 WHERE Log_700.Billback_ID = Billback.Billback_ID AND Log_700.Deleted = 0) AS claimTransDate
			,Billback.Auto_Billback <!---D35038: hnz ehancement -- claim summary updates for auto pay billbacks --->
		FROM Billback

		INNER JOIN 	Billback_Program 
		ON Billback_Program.Billback_ID = Billback.Billback_ID
		AND Billback_Program.Deleted = 0		
		LEFT JOIN  Contract_Main 
		ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID 
		LEFT JOIN  program_control_panel_options
		ON Contract_Main.ProgramType_ID = program_control_panel_options.ProgramControl_Panel_Options_ID
		LEFT JOIN Billback_Status
		ON Billback.Billback_Status_ID = Billback_Status.Billback_Status_ID
		LEFT JOIN bb_approved ON bb_approved.Billback_ID = Billback.Billback_ID
		LEFT JOIN bb_approved as Parent_Approved ON Parent_Approved.Billback_ID = Billback.BB_Parent_ID
		LEFT JOIN Billback as Parent_Billback ON Parent_Billback.Billback_ID = Billback.BB_Parent_ID
		LEFT JOIN _Users
		ON _Users.user_id = 	(CASE
					WHEN Billback.BB_Parent_ID IS NOT NULL AND Parent_Approved.User_Approved is not null THEN Parent_Approved.User_Approved
					WHEN Billback.BB_Parent_ID IS NOT NULL AND Parent_Approved.User_Approved is null THEN Parent_Billback.BB_Creator_ID
					WHEN Billback.BB_Parent_ID IS NULL AND BB_Approved.User_Approved is not null THEN BB_Approved.User_Approved
					WHEN Billback.BB_Parent_ID IS NULL AND BB_Approved.User_Approved is null THEN Billback.BB_Creator_ID
					END)
		LEFT JOIN vendor_master ON vendor_master.Vendor_Master_ID = bb_approved.Vendor_Master_ID
		LEFT JOIN  Billback_Distributor ON Billback.Billback_Payee_Type_ID IN (1, 5) AND Billback_Distributor.Billback_ID = Billback.Billback_ID AND Billback_Distributor.Deleted = 0
		LEFT JOIN BSA_Foodservice_Customers ON Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
		LEFT JOIN Billback_Operator ON Billback.Billback_Payee_Type_ID IN (2, 6) AND Billback_Operator.Billback_ID = Billback.Billback_ID AND Billback_Operator.Deleted = 0
		LEFT JOIN  BSA_Operator ON Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID
		LEFT JOIN Billback_Broker ON Billback.Billback_Payee_Type_ID IN (3, 7) AND Billback_Broker.Billback_ID = Billback.Billback_ID AND Billback_Broker.Deleted = 0
		LEFT JOIN BSA_Foodservice_Brokers ON Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID OR (Billback.Billback_Payee_Type_ID IN (1, 5) AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID)
		LEFT JOIN Service_Markets ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
		LEFT JOIN Service_Regions ON Service_Regions.Service_Region_ID = Service_Markets.Service_Region_ID
		LEFT JOIN Service_Zones ON Service_Zones.Service_Zone_ID = Service_Regions.Service_Zone_ID
		WHERE Billback.Billback_ID =  '#PreserveSingleQuotes(thisBillbackID)#'
		 <!--- condition for end user --->
		<cfif this.getEndUser() NEQ "" and this.getEndUser() NEQ 0>
			and case 
				WHEN Billback.Billback_Payee_Type_ID=1 THEN	
					isnull(( select top 1 COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50))) from BSA_Operator where deleted = 0 and BSA_Operator_ID in (select top 1 BSA_Operator_ID from contract_operators where deleted = 0 and contract_main_id = billback_program.program_id)),' ')	 
				WHEN Billback.Billback_Payee_Type_ID=2 THEN
		       			ISNull(COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50))), ' ') 
				WHEN Billback.Billback_Payee_Type_ID=4 THEN	
					isnull(( select top 1 COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50))) from BSA_Operator where deleted = 0 and BSA_Operator_ID in (select top 1 BSA_Operator_ID from contract_operators where deleted = 0 and contract_main_id = billback_program.program_id)),' ')	
				else ''
			end like '#this.getEndUser()#%'
		</cfif>
		AND		Billback_Program.program_id = '#this.getProgramID()#'
		ORDER BY Billback.BB_Code, Billback.Billback_ID, Billback_Program.Billback_Program_ID
	</CFQUERY>
	
	<cfset setClaimBasicInfo(qryGetClaimBasicInfo) />
	<cfset setClaimTemplateType(qryGetClaimBasicInfo.claimTemplateType) />
	<cfset setClaimTemplateName(qryGetClaimBasicInfo.claimTemplateName) />
	<cfset setClaimNo( qryGetClaimBasicInfo.claimNo ) />
	<cfset setClaimMailTo(qryGetClaimBasicInfo.vendor_name,qryGetClaimBasicInfo.vendorAddress1,qryGetClaimBasicInfo.vendorAddress2,qryGetClaimBasicInfo.vendorCity,qryGetClaimBasicInfo.vendorState,qryGetClaimBasicInfo.vendorZip) />
<!---D35038: hnz ehancement -- claim summary updates for auto pay billbacks START--->
			<cfif qryGetClaimBasicInfo.Auto_Billback EQ 1>
						<CFQUERY NAME="qryGetDistributorInfo" DATASOURCE="#application.datasource#">
								SELECT	 	 
												CASE COUNT(*)
													WHEN 1 THEN Max(C.Shr_Ship_To)
													ELSE 'Multiple Distributors'
									END as distID
								FROM				Billback 
								INNER JOIN 	BillBack_Distributor_List 
								ON					BillBack_Distributor_List.Billback_ID = Billback.Billback_ID
								AND				BillBack_Distributor_List.Deleted = 0
								LEFT JOIN		BSA_Foodservice_Customers C
								ON					C.BSA_Foodservice_Customers_ID = BillBack_Distributor_List.Distributor_ID
								WHERE			Billback.Billback_ID =  '#PreserveSingleQuotes(thisBillbackID)#'
								
						</CFQUERY>
							<cfset setClaimCust(qryGetDistributorInfo.distID) />
			<cfelse>
							<cfset setClaimCust(qryGetClaimBasicInfo.distID) />
			</cfif>
<!---D35038: hnz ehancement -- claim summary updates for auto pay billbacks END--->
	<cfset setClaimStatus(qryGetClaimBasicInfo.claimStatus) />
	<cfset setClaimRegion(qryGetClaimBasicInfo.Region) />
	<cfset setClaimMarket(qryGetClaimBasicInfo.Market) />
	<cfset setClaimReferenceNo(qryGetClaimBasicInfo.claimRef) />
	<cfset setClaimReferenceNo2(qryGetClaimBasicInfo.claimRef2) />
<!---D35038: hnz ehancement -- claim summary updates for auto pay billbacks START--->
	<cfif qryGetClaimBasicInfo.Auto_Billback EQ 1>
						<CFQUERY NAME="qryGetReferenceNumberInfo" DATASOURCE="#application.datasource#">
								SELECT	
											CASE COUNT(*)
											WHEN 1 THEN Max(Contract_Main.Contract_Title)
											ELSE 'Multiple Programs'
										END as claimRef2  
								FROM				Billback 
								INNER JOIN 	Billback_Program 
								ON					Billback_Program.Billback_ID = Billback.Billback_ID
								AND				Billback_Program.Deleted = 0
								INNER JOIN 	Contract_Main 
								ON					Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
								WHERE			Billback.Billback_ID =  '#PreserveSingleQuotes(thisBillbackID)#'
							
						</CFQUERY>
		<cfset setClaimReferenceNo2(qryGetReferenceNumberInfo.claimRef2) />
	<cfelse>
		<cfset setClaimReferenceNo2(qryGetClaimBasicInfo.claimRef2) />
	</cfif>
<!---D35038: hnz ehancement -- claim summary updates for auto pay billbacks END--->	
	<cfset setClaimPODStart(qryGetClaimBasicInfo.bbStartDate) />
	<cfset setClaimPODEnd(qryGetClaimBasicInfo.bbEndDate) />
	<cfset setClaimUserID(qryGetClaimBasicInfo.UserID) />
	<!--- set end user ---->
	<cfset setClaimEndUser(qryGetClaimBasicInfo.End_User) />
	<!--- set end user name --->
	<cfset setClaimEndUserName(qryGetClaimBasicInfo.End_User_Name) />
	<!--- set postmark date --->
	<cfset setClaimPostMarkDate(qryGetClaimBasicInfo.claimPostMarkDate) />
	<!--- set receipt date --->
	<cfset setClaimReceiptDate(qryGetClaimBasicInfo.claimReceiptDate) />
	<!--- set entry date --->
	<cfset setClaimEntryDate(DateFormat(qryGetClaimBasicInfo.claimEntryDate, "mm/dd/yyyy")) />
	<!--- set trans date ---->
	<cfset setClaimTransDate(qryGetClaimBasicInfo.claimTransDate) />
	<!--- set vendor id --->
	<cfset setClaimVendorID(qryGetClaimBasicInfo.claimVendorID) />
	<!--- set claim AR#--->
	<cfset setClaimAR(qryGetClaimBasicInfo.A_R) />
	<!--- set the approved user ---->
	<CFQUERY NAME="qryGetClaimApprovedUser" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		SELECT	DISTINCT 
			_Users.Name_First AS claimApprovedUsrFirst,
			_Users.Name_Last AS claimApprovedUsrLast	
		FROM BB_Approved
		LEFT JOIN  	_Users
				ON 	BB_Approved.User_Approved = _Users.User_ID
		WHERE 	BB_Approved.Billback_ID = <cfif trim(this.getParentBillbackID()) NEQ "">'#trim(this.getParentBillbackID())#'<cfelse>'#trim(thisBillbackID)#'</cfif>
	</CFQUERY>
	<cfset setClaimApprovedUserID(qryGetClaimApprovedUser.claimApprovedUsrFirst, qryGetClaimApprovedUser.claimApprovedUsrLast) />
	<!--- set the claim notes --->
	<CFQUERY NAME="qryGetClaimCreatorNotes" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		select distinct BB_Creator_Notes
		from billback
		where billback_id = '#PreserveSingleQuotes(thisBillbackID)#' 
	</CFQUERY>
	<CFQUERY NAME="qryGetClaimDeductions" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		select distinct DD_DedID
		from deductions
		where dd_closure_type = 1
		and dd_closure_id = '#thisBillbackID#'
		and deleted = 0
	</CFQUERY>
	<cfset setClaimNote(qryGetClaimCreatorNotes.BB_Creator_Notes, valueList(qryGetClaimDeductions.DD_DedID)) />
</cffunction>
<cffunction name="loadParentBillbackID" output="false" returntype="void" access="public">
	<cfset thisBillbackID = this.getBillbackID() />
	<CFQUERY NAME="qryGetParentBillbackID" DATASOURCE="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		select 	distinct isnull(cast(BB_Parent_ID as char(50)),'') as parent_bb_id
		from 	billback
		where	billback.Billback_ID = '#trim(thisBillbackID)#'
		and		deleted = 0	
	</CFQUERY>
	<cfset setParentBillbackID(qryGetParentBillbackID.parent_bb_id) />
</cffunction>
<!---formula: itemQuantity * adjustQuantity / paidQuantity---->
<cffunction name="adjustItemQuantity" output="false" returntype="numeric" access="public">
	<cfargument name="itemQuantity" 		type="numeric" 	default="" required="true">
	<cfargument name="adjustQuantity" 	type="numeric" 	default="" required="true">
	<cfargument name="paidQuantity" 	type="numeric" 	default="" required="true">
	<cfif arguments.paidQuantity GT 0>
		<cfreturn  arguments.itemQuantity * arguments.adjustQuantity / arguments.paidQuantity />
	<cfelse>
		<cfreturn 0 />
	</cfif>
</cffunction>
</cfcomponent>