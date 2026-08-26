<!-----------------------------------------------------------------------------

FILE NAME:		EzRatesDownload.cfm
DESCRIPTION:	Build and then download the excel file with EZ products and rates
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	05-Jan-2015		Select the various versions of the Program
							and offer a download link on each.

------------------------------------------------------------------------------> 

<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<cfset URL.Contract_Main_ID = cryp.value>

<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init() />

<cfset lstContractVersions = programManager.getContractVersions(URL.Contract_Main_ID) />
<cfset programInfo =  programManager.getProgramInfoComplete(URL.Contract_Main_ID) />
<cfset DownloadFileName = "EZ_Rates_#programInfo.Program_Number#_" & DateFormat(now(), "mm_dd_yyyy") & ".csv" />

<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\contracts\" & DownloadFileName  />

<cfset fileOutput = CreateObject("java","java.lang.StringBuffer").Init() >

<cfif (programInfo.Contract_Status_Type_IDX EQ 2)>
	<cfquery name="ProgramEZRates" datasource="#application.datasource#">
		SELECT	*
		FROM	DBO.UDF_EZ_GET_PROGRAM_PRODUCTS (#URL.Contract_Main_ID#, 'RETURN_ALL', #request.AccessStructure.Profiles_ID#) 
		ORDER BY item
	</cfquery>
<cfelse>
	<cfquery name="ProgramEZRates" datasource="#application.datasource#">
		SELECT 
			PTER.Program_Template_EZ_Rate_ID,
			PTER.Contract_Main_ID,
			PTER.Product_ID AS BSA_Foodservice_Items_Master,
			PTER.Template_EZ_Rate AS EZ_Rate,
			PTER.Template_EZ_Rate_UOM AS EZ_UOM,
			PTER.Program_EZ_Rate AS Program_Rate,
			PTER.Program_EZ_Rate_UOM AS Program_UOM,
			PTER.Variance,
			PTER.Created_Date,
			BSAF.Item,
			BSAF.Description AS Item_Description,
			UOM1.Abbreviation AS Program_UOM_AB,
			UOM2.Abbreviation AS EZ_UOM_AB
		FROM 
			Program_Template_EZ_Rate PTER
			INNER JOIN BSA_Foodservice_Items_Master BSAF ON BSAF.BSA_Foodservice_Items_Master_ID = PTER.Product_ID
			LEFT JOIN Units_of_Measure UOM1 on UOM1.Unit_Of_Measure_ID = PTER.Program_EZ_Rate_UOM 
			LEFT JOIN Units_of_Measure UOM2 on UOM2.Unit_Of_Measure_ID = PTER.Template_EZ_Rate_UOM
		WHERE 
			PTER.Contract_Main_ID = 	#URL.Contract_Main_ID#
	</cfquery>
</cfif> 

	<!--- Creating the .csv file  --->
	<cfset fileOutput.append("TEMPLATE NAME" & ",")>
	<cfset fileOutput.append("PROGRAM NO." & ",")>
	<cfset fileOutput.append("PROGRAM TITLE" & ",")>
	<cfset fileOutput.append("START DATE" & ",")>
	<cfset fileOutput.append("END DATE" & ",")>
	<cfset fileOutput.append("PROGRAM RSP NAME" & ",")>
	<cfset fileOutput.append("CREATED BY NAME" & ",")>
	<cfset fileOutput.append("CREATED DATE" & ",")>
	<cfset fileOutput.append("APPROVED BY " & ",")>
	<cfset fileOutput.append("APPROVER PROFILE NAME" & ",")>
	<cfset fileOutput.append("APPROVED DATE" & ",")>
	<cfset fileOutput.append("ITEM NO." & ",")>
	<cfset fileOutput.append("ITEM DESCRIPTION" & ",")>
	<cfset fileOutput.append("TEMPLATE EZ RATE" & ",")>
	<cfset fileOutput.append("TEMPLATE EZ RATE UOM" & ",")>			
	<cfset fileOutput.append("PROGRAM RATE" & ",")>
	<cfset fileOutput.append("PROGRAM RATE UOM" & ",")>			
	<cfset fileOutput.append("VARIANCE")>

 	<cfset fileOutput.append(Chr(13) & Chr(10))>
	 
	<cfloop query="ProgramEZRates">
		<cfset fileOutput.append(programInfo.Created_Type & ",")>
		<cfif (programInfo.Contract_Status_Type_IDX EQ 2)>
			<cfset fileOutput.append(programInfo.Contract_Number & ",")>
		<cfelse>
			<cfset fileOutput.append(programInfo.Program_Number_Full & ",")>
		</cfif>
		<cfset fileOutput.append(Replace(programInfo.Contract_Title,","," " ,"ALL") & ",")>
		<cfset fileOutput.append(DateFormat(programInfo.Contract_Start_Date,"mm/dd/yyyy") & ",")>
		<cfset fileOutput.append(DateFormat(programInfo.Contract_End_Date,"mm/dd/yyyy") & ",")>
		<cfset fileOutput.append(programInfo.RSP_Name & ",")>
		<cfset fileOutput.append(programInfo.Created_User & ",")>
		<cfset fileOutput.append(DateFormat(programInfo.Contract_Created_Date,"mm/dd/yyyy") & ",")>
		<cfset fileOutput.append(programInfo.Approved_User & ",")>
		<cfset fileOutput.append(programInfo.Profiles_Desc & ",")>
		<cfset fileOutput.append(DateFormat(programInfo.Approval_Date,"mm/dd/yyyy") & ",")>
		<cfset fileOutput.append("=" & '"#ProgramEZRates.Item#"' & ",")> 
		<cfset fileOutput.append(Replace(ProgramEZRates.Item_Description,","," - ","ALL") & ",")>
		<cfset fileOutput.append("$#ProgramEZRates.EZ_Rate#" & ",")>
		<cfset fileOutput.append(ProgramEZRates.EZ_UOM_AB & ",")>
		<cfset fileOutput.append("$#ProgramEZRates.Program_Rate#" & ",")>
		<cfset fileOutput.append(ProgramEZRates.Program_UOM_AB & ",")>
		<cfset fileOutput.append("$#ProgramEZRates.Variance#")>
 	 	<cfset fileOutput.append(Chr(13) & Chr(10))>
	</cfloop>

	
	<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#" >
	
	<!--- download link --->
	<cfheader name="Content-Disposition" value="attachment;filename=#DownloadFileName#"  />
	<cfcontent type="application/csv" file="#pathFileName#" deletefile="no"  />
