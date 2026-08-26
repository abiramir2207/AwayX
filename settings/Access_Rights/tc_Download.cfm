<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\Access_Rights\tc_Download.cfm
      Date:     16-Sep-2015
      Author:   Anand Rao
      Purpose:  Download files for the Type code Approve/Access

      Notes:

----------------------------------------------------------------------------------------------------------------------->

<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />
<cfset getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles(profile_id = URL.SelProfiles)>
<cfset qGetGroupAccessValues = approvalGroupManager.getGroupAccessValues("", "")>
<cfset groupIdList = Replace(QuotedValueList(qGetGroupAccessValues.Group_ID),"''",",","ALL")>
 

<!--- <cfset fileData = holdingPenManager.getHoldingPenData() /> --->
<cfset DownloadFileName = "TypeCodes_User_Profiles_" & DateFormat(now(), "mm_dd_yyyy") & ".csv" />	
<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\settings\" & DownloadFileName  />

<!--- Create a STRING BUFFER to hold the output --->
<cfset fileOutput= CreateObject("java","java.lang.StringBuffer").Init() >

<!--- header row --->
	<cfset fileOutput.append("#application.returned_customer_setting.type_code_label_singular#" & ",")>
	<cfloop query="getProfiles">
		<cfset i = getProfiles.profiles_id>
		<cfset fileOutput.append("#getProfiles.Profiles_Short_Desc# Approve" & ",")>
		<cfset fileOutput.append("Margin Variance" & ",")>
		<cfif application.appSettingsGet.getapprovalStandardOn() EQ 1>
			<cfset fileOutput.append("Spend/lb Variance" & ",")>
		</cfif>		
	</cfloop>
	<cfset fileOutput.append(Chr(13) & Chr(10))>


<cfloop query="qGetGroupAccessValues">	
	<cfset GroupCount = 1 />
		<tr bgcolor="FFFFFF">	
			<cfloop query="getProfiles">	
				<cfset qGetGroupAccessProfileValues = approvalGroupManager.getGroupAccessValues(qGetGroupAccessValues.Group_ID, getProfiles.profiles_ID)>		
			<cfset bgColor = "">
			<cfif qGetGroupAccessValues.Group_Approve EQ 1>
				<cfset bgColor = "ffdead">
			</cfif>
			<cfset groupIdFieldName = ReplaceNoCase(qGetGroupAccessValues.Group_ID, "-", "_", "all") & "_pro_" & getProfiles.profiles_id >
			 	<Cfif GroupCount eq 1>
				<cfset fileOutput.append('"' & '#qGetGroupAccessValues.Group_Name#' & '"' & ",")>
			 	</cfif>
			<cfset groupCount++ />
			<cfif qGetGroupAccessProfileValues.Group_Approve EQ 1>
				<cfset fileOutput.append('"' & '1' & '"' & ",")>
			<cfelse>	
				<cfset fileOutput.append('"' & '0' & '"' & ",")>
			</cfif> 
				<cfset fileOutput.append('"' & '#qGetGroupAccessProfileValues.Group_Approve_Margin#' & '"' & ",")>
				<cfif application.appSettingsGet.getapprovalStandardOn() EQ 1>
					<cfset fileOutput.append('"' & '#qGetGroupAccessProfileValues.Group_Approve_Spend#' & '"' & ",")>
				</cfif>			
		</cfloop>
		<cfset fileOutput.append(Chr(13) & Chr(10))>
	</cfloop>

	<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#" >
	<!--- download link --->
	<cfheader name="Content-Disposition" value="attachment;filename=#DownloadFileName#"  />
	<cfcontent type="application/csv" file="#pathFileName#" deletefile="no"  />

<!--- <script language="JavaScript">
	window.close();
</script> --->