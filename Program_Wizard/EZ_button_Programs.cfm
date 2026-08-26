<cfparam name="url.TemplateID" default="">

	<cfset Template_Manager = CreateObject("component", "Components.Programs.Template.TemplateManager") />


	<cfquery name="qGettemplatesettings" datasource="#application.datasource#">
	SELECT Ez_Contract_ID,First_Parent_ID
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = #url.TemplateID#
	</cfquery>

	<!--- Get all the programs with Ez Button On which do not have the Ez_Contract_ID of the latest template.
	      The comparison of the 'Ez_Contract_ID' is made in the Contract_products table. If we add products to a program
	      and then modify the template. Then if we add more products to a program to the program created before the modification 
	      of the template, then the contract_products table gets the new EZ_Contract_ID. If we just add a new component or delete
	      a product, then the 'Ez_Contract_ID' update might not happen.
	--->

	<cfset qProgramList = Template_Manager.getEZProgramsLatestTemplateSettings(qGettemplatesettings.First_Parent_ID,qGettemplatesettings.Ez_Contract_ID)>


	<cfheader name="Content-Disposition" value="attachment;filename=Program_List.csv">
	<cfcontent type="text/plain" />

	<!--- Report Header --->
<cfset csvstr = createObject("java","java.lang.StringBuffer")>
	<cfset csvstr.append("Contract Number" & ",")>
	<cfset csvstr.append("Title" & ",")>
	<cfset csvstr.append("Status" & ",")>
	<cfset csvstr.append("RSP" & ",")>
	<cfset csvstr.append("Created By" & ",")>
	<cfset csvstr.append("Created Date" & ",")>
	<cfset csvstr.append("RFA By" & ",")>
	<cfset csvstr.append("RFA Date" & ",")>
	<cfset csvstr.append(Chr(13) & Chr(10))>

	<!--- Report Details --->
<cfloop query="qProgramList">
	<cfset csvstr.append(Contract_Number & ",")>
	<cfset csvstr.append(replace(Contract_Title, ",", "",'ALL') & ",")>
	<cfset csvstr.append(Contract_Status & ",")>
	<cfset csvstr.append(RSP_Name & ",")>
	<cfset csvstr.append(Creator_Name & ",")>
	<cfset csvstr.append(Created_Date & ",")>
	<cfset csvstr.append(RFA_Name & ",")>
	<cfset csvstr.append(RFA_Date & ",")>
	<cfset csvstr.append(Chr(13) & Chr(10))>
</cfloop>

<!--- Output the report --->
<CFOUTPUT>#csvstr.toString()#</CFOUTPUT>