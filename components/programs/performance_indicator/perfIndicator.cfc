<!---
	Description:
		Component used for Program Performance Indicators
	Package List:
--->

<cfcomponent>

<!--- section for property used throughout the component --->
<cfproperty name="defaultUOM" 			type="numeric" />
<cfproperty name="contractCompanyID"	type="string" />
<cfproperty name="contractMainID" 		type="string" />
<cfproperty name="contractNumber" 		type="string" />
<cfproperty name="contractTitle" 		type="string" />
<cfproperty name="contractStartDate" 	type="date" />
<cfproperty name="contractEndDate" 		type="date" />
<cfproperty name="contractType" 		type="string" />
<cfproperty name="genericTypes" 		type="struct" />
<cfproperty name="ProgramBasicInfo" 	type="struct" />
<cfproperty name="programVolumes" 		type="struct" />
<cfproperty name="actualProgramVolumes" 	type="struct" />
<cfproperty name="ProgramClaims" 			type="struct" />

<cfparam name="this.defaultUOM" default="1">
<cfparam name="this.contractNumber" default="">
<cfparam name="this.contractMainID" default="">
<cfparam name="this.contractType" default="">
<cfparam name="this.contractStartDate" default="">
<cfparam name="this.contractEndDate" default="">
<cfparam name="this.genericTypes" default="">
<cfset this.genericTypes = structNew() />
<cfset this.programVolumes = structNew() />
<cfset this.actualProgramVolumes = structNew() />
<cfset this.ProgramBasicInfo = structNew() />
<cfset this.ProgramClaims = structNew() />
<!--- section for functions --->
<cffunction name="getProgramsForPerfIndicator" output="false" returntype="query">
	<cfargument name="sortBy" type="string" default="Contract_Number" required="false">
	<cfargument name="sortOrder" type="string" default="ASC" required="false">
			
	<CFQUERY NAME="perfIndicGetContractInfo" datasource="#application.datasource#">
		select  dbo.Contract_Main.Contract_Number AS Contract_Number, 
  				dbo.Contract_Status_Types.Contract_Status_Type_Desc + ' [' + 
				cast(convert(varchar, dbo.Contract_Main.Contract_Start_Date, 101) AS varchar) 
				+ ' - ' + cast(convert(varchar,dbo.Contract_Main.Contract_End_Date, 101) AS varchar)
			 	+ ']' AS programSpan,    
 				dbo.Contract_Main.Contract_Status_Type_IDX
  		from	dbo.Contract_Main
 		INNER JOIN	dbo.Contract_Status_Types 
				ON dbo.Contract_Status_Types.Contract_Status_Type_ID = dbo.Contract_Main.Contract_Status_Type_IDX
				and flagged_As_purged = 0 and force_expiration_flag = 0
 		INNER JOIN 	dbo.Program_Control_Panel_Options 
				ON 	dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = dbo.Contract_Main.ProgramType_ID
  			 	AND dbo.Program_Control_Panel_Options.generic_type in ('Distributor Off-Invoice', 'Distributor Trade/Shelter', 'Field Execution')
  				and dbo.Program_Control_Panel_Options.deleted = 0 
  				and dbo.Program_Control_Panel_Options.include_program = 1
  		LEFT JOIN	dbo.Contract_Distributors 
				ON  dbo.contract_main.Contract_Main_ID = dbo.Contract_Distributors.Contract_Main_ID
  		LEFT JOIN	dbo.BSA_Foodservice_Customers 
				ON 	BSA_Foodservice_Customers.Deleted = 0               
  				AND dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = dbo.Contract_Distributors.BSA_Foodservice_Customers_ID
				AND dbo.BSA_Foodservice_Customers.DELETED = 0
  				AND dbo.BSA_Foodservice_Customers.Active_Code = 'A'
  		where   dbo.Contract_Main.deleted = 0
  		and     dbo.Contract_Main.Contract_Status_Type_IDX >= 3 
  		and     dbo.Contract_Main.Contract_Status_Type_IDX < 8
  		UNION
  		select  dbo.Contract_Main.Contract_Number AS programDetail, 
  				dbo.Contract_Status_Types.Contract_Status_Type_Desc + ' [' + 
				cast(convert(varchar, dbo.Contract_Main.Contract_Start_Date, 101) AS varchar) 
				+ ' - ' + cast(convert(varchar,dbo.Contract_Main.Contract_End_Date, 101) AS varchar)
				+ ']' AS programSpan,    
 				dbo.Contract_Main.Contract_Status_Type_IDX
 		from    dbo.Contract_Main
 		INNER JOIN	dbo.Contract_Status_Types 
				ON 	dbo.Contract_Status_Types.Contract_Status_Type_ID = dbo.Contract_Main.Contract_Status_Type_IDX
				and flagged_As_purged = 0 and force_expiration_flag = 0
 		INNER JOIN  dbo.Program_Control_Panel_Options 
				ON 	dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = dbo.Contract_Main.ProgramType_ID
 				AND dbo.Program_Control_Panel_Options.generic_type in ('Operator Direct or HQ Programs','Operator-Deviated','Bid Request')
 				and dbo.Program_Control_Panel_Options.deleted = 0
 				and dbo.Program_Control_Panel_Options.include_program = 1
 		INNER JOIN  dbo.Contract_Operators 
				ON  dbo.contract_main.Contract_Main_ID = dbo.Contract_Operators.Contract_Main_ID
 		INNER JOIN  dbo.BSA_Operator ON dbo.BSA_Operator.Deleted = 0                  
 				AND dbo.Contract_Operators.BSA_Operator_ID = dbo.BSA_Operator.BSA_Operator_ID
 				AND     dbo.BSA_Operator.DELETED = 0
 		where	dbo.Contract_Main.deleted = 0
 		and     dbo.Contract_Main.Contract_Status_Type_IDX >= 3 
 		and     dbo.Contract_Main.Contract_Status_Type_IDX < 8
		ORDER BY #arguments.sortBy# #arguments.sortOrder#
	</CFQUERY>
	<cfreturn perfIndicGetContractInfo />
</cffunction>

<!--- set programs once, then set the individual ones --->
<cffunction name="setBasicPrograms" output="false" access="public">
	<CFQUERY NAME="perfIndicBasicPrograms" datasource="#application.datasource#">
		select 	dbo.Contract_Main.Contract_Number, 
				dbo.Contract_Main.Contract_Title,
				dbo.Program_Control_Panel_Options.Generic_Type,
				dbo.Contract_Main.Contract_Start_Date AS Contract_Start_Date,
				dbo.Contract_Main.Contract_End_Date AS Contract_End_Date	
		from	dbo.Contract_Main
		INNER JOIN 	dbo.Program_Control_Panel_Options ON dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = dbo.Contract_Main.ProgramType_ID
				and dbo.Program_Control_Panel_Options.deleted = 0
				and dbo.Program_Control_Panel_Options.include_program = 1
		INNER JOIN	dbo.Contract_Status_Types 
				ON 	dbo.Contract_Status_Types.Contract_Status_Type_ID = dbo.Contract_Main.Contract_Status_Type_IDX
				and flagged_As_purged = 0 
				and force_expiration_flag = 0
		WHERE	dbo.Contract_Main.Deleted = 0
		and 	dbo.Contract_Main.Contract_Status_Type_IDX >= 3 
  		and 	dbo.Contract_Main.Contract_Status_Type_IDX < 8
		order by dbo.Contract_Main.Contract_Number	
	</CFQUERY>
	<cfloop query="perfIndicBasicPrograms">
		<cfif isDate(perfIndicBasicPrograms.Contract_Start_Date) AND isDate(perfIndicBasicPrograms.Contract_End_Date)>
			<cfset setProgramsBasicInfo(perfIndicBasicPrograms.Contract_Number, perfIndicBasicPrograms.Contract_Title, perfIndicBasicPrograms.Generic_Type, perfIndicBasicPrograms.Contract_Start_Date, perfIndicBasicPrograms.Contract_End_Date ) />
		</cfif>
		<!---<cfset setProgramsBasicInfo(perfIndicBasicPrograms.Contract_Number, perfIndicBasicPrograms.Contract_Title, perfIndicBasicPrograms.Generic_Type, perfIndicBasicPrograms.Contract_Start_Date, perfIndicBasicPrograms.Contract_End_Date ) /> --->
	</cfloop>
</cffunction>

<!--- determine the claims --->
<cffunction name="setProgramsClaims" output="false" access="public">
	<CFQUERY NAME="perfIndicGetProgramsClaims" datasource="#application.datasource#">
	SELECT	BB_Program_Info.Contract_Number, Count(DISTINCT Billback.BB_Code) AS Claims
	FROM	dbo.Billback_Program 
	INNER JOIN	dbo.Billback ON dbo.Billback_Program.Billback_ID = dbo.Billback.Billback_ID 
	INNER JOIN	dbo.BB_Program_Info ON dbo.Billback_Program.Program_ID = dbo.BB_Program_Info.Contract_Main_ID 
	INNER JOIN	dbo.BB_Approved ON dbo.Billback.Billback_ID = dbo.BB_Approved.Billback_ID 		
	WHERE     	(dbo.Billback.Deleted = 0) 
	AND 		(dbo.Billback_Program.Deleted = 0) 
	AND BB_Program_Info.ProgramType_id IN ( SELECT ProgramControl_Panel_Options_ID FROM Program_Control_Panel_Options 
					WHERE Generic_Type = 'Operator Direct or HQ Programs' OR Generic_Type = 'Operator-Deviated Pricing' OR Generic_Type = 'Bid Request')
	Group By BB_Program_Info.Contract_Number
	order by bb_program_info.contract_number
	</CFQUERY>
	<cfloop query="perfIndicGetProgramsClaims">
		<cfset setProgramClaim(Contract_Number, Claims) />
	</cfloop>
</cffunction>

<cffunction name="setProgramClaim" output="false" access="public">
	<cfargument name="Contract_Number" 	type="string" 	required="true" default="">
	<cfargument name="Claims" 			type="numeric"	required="true" default="">
	<cfif Not StructKeyExists(this.ProgramBasicInfo, arguments.Contract_Number)>
		<cfset this.ProgramClaims[arguments.Contract_Number] = arguments.Claims />
	</cfif>
</cffunction>

<cffunction name="setProgramsBasicInfo" output="false" access="public">
	<cfargument name="Contract_Number" type="string" required="true" default="">
	<cfargument name="Contract_Title" type="string" required="true" default="">
	<cfargument name="Generic_Type" type="string" required="true" default="">
	<cfargument name="Contract_Start_Date" type="date" required="true" default="05/24/04">
	<cfargument name="Contract_End_Date" type="date" required="true" default="05/24/04">
	<cfif Not StructKeyExists(this.ProgramBasicInfo, arguments.Contract_Number)>
		<cfset this.ProgramBasicInfo[arguments.Contract_Number] = structNew() />
		<cfset this.ProgramBasicInfo[arguments.Contract_Number]['Title'] = 	arguments.Contract_Title />
		<cfset this.ProgramBasicInfo[arguments.Contract_Number]['Type'] =	arguments.Generic_Type />
		<cfset this.ProgramBasicInfo[arguments.Contract_Number]['SDate'] = 	arguments.Contract_Start_Date />
		<cfset this.ProgramBasicInfo[arguments.Contract_Number]['EDate'] = 	arguments.Contract_End_Date />
	</cfif>
</cffunction>

<cffunction name="setThisProgram" output="false" access="public">
	<cfargument name="Contract_Number" type="string" required="true" default="">
	<cfset setContractNumber(arguments.Contract_Number) />
	<cfset setContractTitle(this.ProgramBasicInfo[arguments.Contract_Number]['Title']) />
	<cfset setContractType(this.ProgramBasicInfo[arguments.Contract_Number]['Type']) />
	<cfset setContractStartDate(this.ProgramBasicInfo[arguments.Contract_Number]['SDate']) />
	<cfset setContractEndDate(this.ProgramBasicInfo[arguments.Contract_Number]['EDate']) />
</cffunction>
<!--- having sum(dbo.program_product_volume.volume_lb) > 0 --->
<cffunction name="setProgramsVolume" output="false" access="public">
	<CFQUERY NAME="perfIndicGetProgramsVolume" datasource="#application.datasource#">
		select 		distinct dbo.contract_main.contract_number, isnull(sum(dbo.program_product_volume.volume_lb), 0) AS LB_Volume, isnull(sum(dbo.program_product_volume.volume_cs), 0) AS CS_Volume
		from 		dbo.Contract_Main
		inner join 	dbo.program_product_volume on dbo.contract_main.contract_main_id = dbo.program_product_volume.program_id
		where		dbo.contract_main.deleted = 0
		and 		dbo.Contract_Main.Contract_Status_Type_IDX >= 3 
		and 		dbo.Contract_Main.Contract_Status_Type_IDX < 8
		group by 	dbo.contract_main.contract_number
		order by 	dbocontract_main.contract_number
	</CFQUERY>
	<cfloop query="perfIndicGetProgramsVolume">
		<cfset this.setVolumeProgramNumber(perfIndicGetProgramsVolume.contract_number, perfIndicGetProgramsVolume.LB_Volume, perfIndicGetProgramsVolume.CS_Volume) />
	</cfloop>
</cffunction>
<!--- set program volume --->
<!--- volume from program_product_volume is weekly based, to adjust to the program volume, adjustment needs to be made --->
<cffunction name="setVolumeProgramNumber" output="false" access="public">
	<cfargument name="thisVolumeProgramNumber" type="string" required="true" default="">
	<cfargument name="thisVolumeLSVol" type="numeric" required="true" default="0">
	<cfargument name="thisVolumeCSVol" type="numeric" required="true" default="0">
	<!--- what if the program volume contract number is not in the basic info structure --->
	<cfif Not StructKeyExists(this.programVolumes, arguments.thisVolumeProgramNumber)>
		<cfif StructKeyExists(this.ProgramBasicInfo, arguments.thisVolumeProgramNumber)>
			<cfset this.programVolumes[arguments.thisVolumeProgramNumber]['LS'] = arguments.thisVolumeLSVol / 7 * this.getProgramDaysByParam(this.ProgramBasicInfo[arguments.thisVolumeProgramNumber]['SDate'], this.ProgramBasicInfo[arguments.thisVolumeProgramNumber]['EDate']) />
			<cfset this.programVolumes[arguments.thisVolumeProgramNumber]['CS'] = arguments.thisVolumeCSVol / 7 * this.getProgramDaysByParam(this.ProgramBasicInfo[arguments.thisVolumeProgramNumber]['SDate'], this.ProgramBasicInfo[arguments.thisVolumeProgramNumber]['EDate']) />
		<cfelse>
			<cfset this.programVolumes[arguments.thisVolumeProgramNumber]['LS'] = arguments.thisVolumeLSVol />
			<cfset this.programVolumes[arguments.thisVolumeProgramNumber]['CS'] = arguments.thisVolumeCSVol />
		</cfif>
	</cfif>
</cffunction>

<!--- set actual volumes (for distributors)--->
<cffunction name="setActualProgramsVolume" output="false" access="public">
	<CFQUERY NAME="perfIndicGetCurrProgramsVolume" datasource="#application.datasource#">
		select 		distinct dbo.contract_main.contract_number, isnull(dbo.Program_Invoice_Detail.VOLUME_LB, 0) AS VOLUME_LB, isnull(dbo.Program_Invoice_Detail.VOLUME_CS, 0) as VOLUME_CS
		from 		dbo.Contract_Main
		inner join 	dbo.Program_Invoice_Detail on dbo.contract_main.Contract_Number = dbo.Program_Invoice_Detail.Contract_Number
					AND dbo.Program_Invoice_Detail.Deleted = 0	
		where		dbo.contract_main.deleted = 0
		and 		dbo.Contract_Main.Contract_Status_Type_IDX >= 3 
		and 		dbo.Contract_Main.Contract_Status_Type_IDX < 8
		order by 	dbocontract_main.contract_number
	</CFQUERY>
	<cfloop query="perfIndicGetCurrProgramsVolume">
		<cfset this.setActualVolumeProgramNumber(perfIndicGetCurrProgramsVolume.contract_number, perfIndicGetCurrProgramsVolume.VOLUME_LB, perfIndicGetCurrProgramsVolume.VOLUME_CS) />
	</cfloop>
</cffunction>

<cffunction name="setActualVolumeProgramNumber" output="false" access="public">
	<cfargument name="thisVolumeProgramNumber" type="string" required="true" default="">
	<cfargument name="thisVolumeLSVol" type="numeric" required="true" default="">
	<cfargument name="thisVolumeCSVol" type="numeric" required="true" default="">
	<cfif Not StructKeyExists(this.actualProgramVolumes, arguments.thisVolumeProgramNumber)>
		<cfset this.actualProgramVolumes[arguments.thisVolumeProgramNumber]['LS'] = arguments.thisVolumeLSVol />
		<cfset this.actualProgramVolumes[arguments.thisVolumeProgramNumber]['CS'] = arguments.thisVolumeCSVol />
	</cfif>
</cffunction>

<cffunction name="setProgramCompanyID" output="false" access="public">
	<cfargument name="thisCompanyID" type="string" required="true" default="">
	<cfset this.contractCompanyID = arguments.thisCompanyID />
</cffunction>

<cffunction name="getProgramCompanyID" output="false" returntype="string">
	<cfreturn this.contractCompanyID />
</cffunction>

<cffunction name="getActualProgramVolume" output="false" returntype="numeric">
	<!--- 1: pounds		2: cases--->
	<cfif StructKeyExists(this.actualProgramVolumes, this.getContractNumber())>
		<cfif this.getDefaultUOM() EQ 1>
			<cfreturn this.actualProgramVolumes[this.getContractNumber()]['LS'] />
		<cfelse>
			<cfreturn this.actualProgramVolumes[this.getContractNumber()]['CS'] />
		</cfif>
	<cfelse>
		<cfreturn 0 />
	</cfif>
</cffunction>

<cffunction name="getProgramClaim" output="false" returntype="numeric">
	<cfif StructKeyExists(this.ProgramClaims, this.getContractNumber())>
		<cfreturn this.ProgramClaims[this.getContractNumber()] />
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>

<!--- get program minimal claim info for operator--->
<cffunction name="getMinimalProgramClaim" output="false" returntype="query">
	<cfargument name="Contract_Number" type="string" required="true" default="">
	<CFQUERY NAME="perfIndicgetMinimalProgramClaim" datasource="#application.datasource#">
	SELECT	BB_Program_Info.Contract_Number, isnull(Program_Control_Panel_Options.Performace_Min_Days, 0) as min_days, isnull(Program_Control_Panel_Options.Performace_Min_Claims, 0) as min_claims
	from dbo.BB_Program_Info 
	inner join Program_Control_Panel_Options on Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = BB_Program_Info.ProgramType_id
	WHERE  dbo.BB_Program_Info.contract_number = '#arguments.Contract_Number#'
	</CFQUERY>
	<cfreturn perfIndicgetMinimalProgramClaim />
</cffunction>

<cffunction name="getMinimalProgramDays" output="false" access="public">
	<cfargument name="Contract_Number" type="string" required="true" default="">
	<CFQUERY NAME="perfIndicgetMinimalProgramClaim" datasource="#application.datasource#">
	SELECT	BB_Program_Info.Contract_Number, isnull(Program_Control_Panel_Options.Performace_Min_Days, 0) as min_days, isnull(Program_Control_Panel_Options.Performace_Min_Claims, 0) as min_claims
	from dbo.BB_Program_Info 
	inner join Program_Control_Panel_Options on Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = BB_Program_Info.ProgramType_id
	WHERE  dbo.BB_Program_Info.contract_number ='#arguments.Contract_Number#'
	</CFQUERY>
	<cfloop query="perfIndicGetProgramsClaims">
		<cfset setProgramClaim(Contract_Number, Claims) />
	</cfloop>
</cffunction>

<cffunction name="getProgramVolume" output="false" returntype="numeric">
	<cfif StructKeyExists(this.programVolumes, this.getContractNumber())>
		<cfif this.getDefaultUOM() EQ 1>
			<cfreturn this.programVolumes[this.getContractNumber()]['LS'] />
		<cfelse>
			<cfreturn this.programVolumes[this.getContractNumber()]['CS'] />
		</cfif>
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>
<!--- combination of distributor and operator programs --->
<cffunction name="getCurrProgramVolume" output="false" returntype="numeric">
	<cfreturn this.getActualProgramVolume() />
</cffunction>
	
<cffunction name="getProgramDays" output="false" returntype="string">
	<cfreturn DateDiff("d", this.getContractStartDate(), this.getContractEndDate()) + 1 />
</cffunction>

<cffunction name="getProgramDaysByParam" output="false" returntype="string">
	<cfargument name="Contract_Start_Date" type="date" required="true" default="05/24/04">
	<cfargument name="Contract_End_Date" type="date" required="true" default="05/24/04">
	<cfreturn DateDiff("d", arguments.Contract_Start_Date,arguments.Contract_End_Date) + 1 />
</cffunction>

<cffunction name="getExpiredDays" output="false" returntype="string">
	<cfreturn DateDiff("d", this.getContractStartDate(), now()) />
</cffunction>

<cffunction name="getTimePercentage" output="false" returntype="string">
	<cfif this.getContractEndDate() LT now() >
		<cfreturn 100 />
	</cfif>
	<cfif this.getContractStartDate() GT now() >
		<cfreturn 0 />
	</cfif>
	<!---
	<cfif this.getExpiredDays() LE 0 or this.getProgramDays() LE 0>
		<cfreturn 0>
	<cfelse> --->
	<cfreturn Round( this.getExpiredDays() / this.getProgramDays() * 100) />
	<!--- </cfif> --->
</cffunction>
<!--- ??? --->
<cffunction name="getVolumePercentage" output="false" returntype="string">
	<!---<cfargument name="programStartDate"  type="date" required="true" default="">--->
	<!--- handle for exception --->
	<cfif this.getProgramVolume() EQ 0 or this.getCurrProgramVolume() EQ 0>
		<cfreturn 0 />
	</cfif>
	<cfreturn Round(this.getCurrProgramVolume() / this.getProgramVolume() * 100) />
</cffunction>

<cffunction name="getPerformanceIndex" output="false" returntype="numeric">
	<cfargument name="volPercentage" type="numeric" required="true" default="">
	<cfargument name="timePercentage" type="numeric" required="true" default="">
	<cfif arguments.timePercentage EQ 0>
		<cfreturn 0>
	</cfif>
	<cfreturn Round(arguments.volPercentage / arguments.timePercentage * 100) />
</cffunction>

<cffunction name="setContractMainID" output="false" access="public">
	<cfargument name="thisContractMainID" type="string" required="true" default="">
	<cfset this.contractMainID = arguments.thisContractMainID />
</cffunction>

<cffunction name="setContractStartDate" output="false" access="public">
	<cfargument name="thisContractStartDate" type="string" required="true" default="">
	<cfset this.contractStartDate = arguments.thisContractStartDate />
</cffunction>
  
<cffunction name="setContractEndDate" output="false" access="public">
	<cfargument name="thisContractEndDate" type="string" required="true" default="">
	<cfset this.contractEndDate = arguments.thisContractEndDate />
</cffunction>

<cffunction name="setContractType" output="false" access="public">
	<cfargument name="thisGeneric_Type" type="string" required="true" default="">
	<cfset this.contractType = arguments.thisGeneric_Type />
</cffunction>

<cffunction name="setContractNumber" output="false" access="public">
	<cfargument name="thisContractNumber" type="string" required="true" default="">
	<cfset this.contractNumber = arguments.thisContractNumber />
</cffunction>

<cffunction name="setContractTitle" output="false" access="public">
	<cfargument name="thisContractTitle" type="string" required="true" default="">
	<cfset this.contractTitle = arguments.thisContractTitle />
</cffunction>

<cffunction name="getContractTitle" output="false" returntype="string">
	<cfreturn this.contractTitle />
</cffunction>

<cffunction name="getContractNumber" output="false" returntype="string">
	<cfreturn this.contractNumber />
</cffunction>

<cffunction name="getContractMainID" output="false" returntype="string">
	<cfreturn this.contractMainID />
</cffunction>

<cffunction name="getContractStartDate" output="false" returntype="date">
	<cfreturn DateFormat(this.contractStartDate, "mm/dd/yy")  />
</cffunction>
  
<cffunction name="getContractEndDate" output="false" returntype="date">
	<cfreturn DateFormat(this.contractEndDate, "mm/dd/yy")  />
</cffunction>

<cffunction name="getContractType" output="false" returntype="string">
	<cfreturn this.contractType  />
</cffunction>

<cffunction name="getContractCreatedDate" output="false" returntype="string">
	<cfreturn this.contractType  />
</cffunction>

<cffunction name="isOperatorProgram" output="false" returntype="boolean">
	<cfset myStruct = this.ListGenericTypes() >
	<cfif listFind(ArrayToList(myStruct["O"]), this.getContractType()) GT 0 >
		<cfreturn true />
	<cfelse>
		<cfreturn false  />
	</cfif>
</cffunction>

<cffunction name="isDistributorProgram" output="false" returntype="boolean">
	<cfset myStruct = this.ListGenericTypes() >
	<cfif listFind(ArrayToList(myStruct["D"]), this.getContractType()) GT 0 >
		<cfreturn true  />
	<cfelse>
		<cfreturn false  />
	</cfif>
</cffunction>

<cffunction name="ListGenericTypes" output="false" returntype="struct">
	<cfset useLakebaseForgetGenericTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetGenericTypes>
	<cftry>
		<cfset getGenericTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"deleted" = "eq.0",
				"isdominant" = "eq.1",
				"order" = "1.asc",
				"select" = "generic_type"
			}), "generic_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGenericTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGenericTypes>
<CFQUERY NAME="getGenericTypes" datasource="#application.datasource#">
		SELECT 	distinct Generic_Type 
		FROM  	Program_Control_Panel_Options 
		where 	deleted = 0
		and		isDominant = 1
		order by 1 asc
	</CFQUERY>
</cfif>
	<cfloop query="getGenericTypes">
		<cfif Not StructKeyExists(this.genericTypes, Left(UCase(Generic_Type), 1))>
			<cfset this.genericTypes[Left(UCase(Generic_Type), 1)] = ArrayNew(1) />
			<cfset this.genericTypes[Left(UCase(Generic_Type), 1)][1] = trim(Generic_Type) />
		<cfelse>
			<cfset ArrayAppend(this.genericTypes[Left(UCase(Generic_Type), 1)], trim(Generic_Type)) />
		</cfif>
	</cfloop>
	<!--- handle two exceptions:Field Execution, Bid Request --->
	<!--- count Field Execution as Distributor --->
	<Cfif StructKeyExists(this.genericTypes, "F")>
	<cfset ArrayAppend(this.genericTypes["D"], trim(this.genericTypes["F"][1])) />	
	</CFIF>
	<!--- count Bid Request as Operator --->
	<Cfif StructKeyExists(this.genericTypes, "B")>
		<cfset ArrayAppend(this.genericTypes["O"], trim(this.genericTypes["B"][1])) />
	</CFIF>
	<!--- Delete the two elements from structure --->
	<Cfif StructKeyExists(this.genericTypes, "F")>
	<cfset StructDelete(this.genericTypes, "F", "True") />
	</CFif>
	<Cfif StructKeyExists(this.genericTypes, "B")>
		<cfset StructDelete(this.genericTypes, "B", "True") />
	</cfif>
	<cfreturn this.genericTypes  />
</cffunction>

<cffunction name="setDefaultUOM" output="false" access="public">
	<CFQUERY NAME="perfIndicGetDefaultUOM" datasource="#application.datasource#">
		Select 	Volume_UOM_For_Performance_Indicator
		From	_Users_Settings
		Where	User_ID = '#this.getProgramCompanyID()#'	
	</CFQUERY>
	<cfset this.defaultUOM = perfIndicGetDefaultUOM.Volume_UOM_For_Performance_Indicator />
</cffunction>
	

<cffunction name="getDefaultUOM" output="false" returntype="numeric">
	<cfreturn this.defaultUOM />
</cffunction>
	
</cfcomponent>