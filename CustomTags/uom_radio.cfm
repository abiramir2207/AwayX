<cfparam name="getRateTypesFromTemplate.RateTypeDefault" 	default="0">
<cfsilent>
<!--- 
	purpose:
		to display the appropiate UOM's
	how:
		using information from the template information and supplied criteria  
 --->

<cfset cachewithin_hours = 0>
 
<CFPARAM NAME="attributes.generic_type_restriction" 	DEFAULT=true>

<cfparam name="attributes.company_main_id"			default="0"><!--- used to find restriction rules--->
	<cfif len(trim(attributes.company_main_id)) EQ 0><cfset attributes.company_main_id = 0></cfif>

<cfparam name="attributes.dropdown_name" 			default="sysgen_ & replace(createuuid(),'-','','all')"><!--- dropdown object name --->
	<cfif len(trim(attributes.dropdown_name)) EQ 0><cfset attributes.dropdown_name = "sysgen_" & replace(createuuid(),"-","","all")></cfif>

<cfparam name="attributes.product_type_id"			default="0"><!--- product type id  --->
	<cfif len(trim(attributes.product_type_id)) EQ 0><cfset attributes.product_type_id = 0></cfif>

<cfparam name="attributes.program_template_id"		default="0"><!--- used to find restriction rules--->
	<cfif len(trim(attributes.program_template_id)) EQ 0><cfset attributes.program_template_id = 0></cfif>

<cfparam name="attributes.selected_uom_id"			default="0">
	<cfif len(trim(attributes.selected_uom_id)) EQ 0><cfset attributes.selected_uom_id = 0></cfif>

<cfparam name="attributes.text_before_tag_close"	default=""><!--- enter test that will pe placed before tag close such as style, onclick, onblur --->

<cfparam name="attributes.uom_id_exclusion_list"	default=""><!--- override exclusion list --->

<cfparam name="attributes.uom_id_inclusion_list"	default=""><!--- override includsion list --->

<cfparam name="attributes.option_text_abbreviated"	default="0"><!--- override includsion list --->
	<cfif len(trim(attributes.option_text_abbreviated)) EQ 0><cfset attributes.option_text_abbreviated = 0></cfif>

<cfparam name="attributes.default_option_on"	default="0">
	<cfif len(trim(attributes.default_option_on)) EQ 0><cfset attributes.default_option_on = 0></cfif>	

<cfparam name="attributes.default_option_text"	default="">

<cfparam name="attributes.default_option_value"	default="">

<cfparam name="attributes.plural_uom_display"	default="0">
	<cfif len(trim(attributes.plural_uom_display)) EQ 0><cfset attributes.plural_uom_display = 0></cfif>
	
<cfparam name="attributes.program_id"	default="0">
	<cfif len(trim(attributes.program_id)) EQ 0><cfset attributes.program_id = 0></cfif>
	
<!--- exclude or include based on product type id --->

<cfparam name="attributes.lookup_uom_display_text"	default="0">
	<cfif len(trim(attributes.lookup_uom_display_text)) EQ 0><cfset attributes.lookup_uom_display_text = 0></cfif>

<cfparam name="attributes.lookup_uom_display_text_uom_id"	default="0">
	<cfif len(trim(attributes.lookup_uom_display_text_uom_id)) EQ 0><cfset attributes.lookup_uom_display_text_uom_id = 0></cfif>

<cfset show_where_clause = 0>
	
<cfif attributes.lookup_uom_display_text EQ 0>
	<cfswitch expression="#attributes.product_type_id#">
		<!--- fixed --->
		<cfcase value="1">
			<cfset attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,3)>
			<cfset attributes.uom_id_inclusion_list = attributes.uom_id_inclusion_list>
		</cfcase>
		
		<!--- rebate  --->
		<cfcase value="2">
			<cfset attributes.uom_id_exclusion_list = attributes.uom_id_exclusion_list>
			<cfset attributes.uom_id_inclusion_list = attributes.uom_id_inclusion_list>		
		</cfcase>
	
		<!--- lump sum --->
		<cfcase value="3">
			<cfset attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,3)>
			<cfset attributes.uom_id_inclusion_list = attributes.uom_id_inclusion_list>		
		</cfcase>
		
		<!--- growth --->
		<cfcase value="4">
			<cfset attributes.uom_id_exclusion_list = attributes.uom_id_exclusion_list>
			<cfset attributes.uom_id_inclusion_list = attributes.uom_id_inclusion_list>		
		</cfcase>
	
		<!--- forumla --->
		<cfcase value="5">
			<cfset attributes.uom_id_exclusion_list = attributes.uom_id_exclusion_list>
			<cfset attributes.uom_id_inclusion_list = attributes.uom_id_inclusion_list>		
		</cfcase>
	
		<cfdefaultcase><!--- do nothing ---></cfdefaultcase>
	</cfswitch>
	
	<cfif attributes.program_id NEQ 0 and isnumeric(attributes.program_id)>
		<cfquery name="getProgramTemplateID" datasource="#application.datasource#" cachedwithin="#createtimespan(0,cachewithin_hours,0,0)#">
			SELECT     ProgramType_ID
			FROM       dbo.Contract_Main
			WHERE     (Contract_Main_ID = #attributes.program_id#) AND (Deleted = 0)
		</cfquery>
		<cfif getProgramTemplateID.recordcount GT 0>
			<cfset attributes.program_template_id = getProgramTemplateID.ProgramType_ID>
		</cfif>
		
	</cfif>
	
	<cfif attributes.program_template_id NEQ "0" and isnumeric(attributes.program_template_id)>
		<cfquery name="getRateTypesFromTemplate" datasource="#application.datasource#" cachedwithin="#createtimespan(0,cachewithin_hours,0,0)#">
			SELECT 
				RateTypeOption_1,
				RateTypeOption_2,
				RateTypeOption_3,
				Generic_Type,
				RateTypeDefault
			FROM 
				Program_Control_Panel_Options
			WHERE 
				ProgramControl_Panel_Options_ID = '#attributes.program_template_id#'
				<CFIF attributes.generic_type_restriction>
				AND
				Generic_Type = 'Distributor Trade/Shelter'
				</CFIF>
				AND
				Deleted = 0
		</cfquery>

		<CFSET ExcludePercentage = 0>
		<!--- <cfif getRateTypesFromTemplate.Generic_Type NEQ "Operator Direct or HQ Programs" OR getRateTypesFromTemplate.Generic_Type NEQ "Distributor Trade/Shelter"> --->
		<CFIF attributes.generic_type_restriction>
		<cfif getRateTypesFromTemplate.Generic_Type NEQ "Distributor Trade/Shelter">
			<CFSET ExcludePercentage = 1>
		</cfif>
		</CFIF>
	
		<cfif getRateTypesFromTemplate.RateTypeOption_2 EQ 0>
			<CFSET attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,1)>
		</cfif>
		
		<cfif getRateTypesFromTemplate.RateTypeOption_1 EQ 0>
			<CFSET attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,2)>
		</cfif>
	
		<cfif getRateTypesFromTemplate.RateTypeOption_3 EQ 0 OR ExcludePercentage EQ 1>
			<CFSET attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,3)>
		</cfif>
	</cfif>
	
	<cfif listlen(attributes.uom_id_exclusion_list) GT 0 OR listlen(attributes.uom_id_inclusion_list) GT 0>
		<cfset show_where_clause = 1>
	</cfif>

<cfelse>
	<cfset show_where_clause = 1>
</cfif>

<!----- following code so that the custom tag will work with all versions of the application ----->
<!----- variable uom_singular_fields_exist can be removed if we are sure all client environments are upgraded to include the singular fields ----->
<cfset uom_singular_fields_exist = 0 />
<cfquery name="qCheckNewSingularFieldExist" datasource="#application.datasource#" cachedwithin="#createtimespan(0,cachewithin_hours,0,0)#">
	SELECT	*
	FROM	INFORMATION_SCHEMA.COLUMNS
	WHERE	TABLE_NAME = 'Units_of_Measure'
	AND		COLUMN_NAME = 'Unit_of_Measure_Desc_Singular'
</cfquery>
<cfif qCheckNewSingularFieldExist.recordCount>
	<cfset uom_singular_fields_exist = 1 />
</cfif>

<cfquery name="getUOMs" datasource="#application.datasource#" cachedwithin="#createtimespan(0,cachewithin_hours,0,0)#">
	SELECT
		Unit_Of_Measure_ID,
		Unit_Of_Measure_Desc,
		Abbreviation,
			<cfif uom_singular_fields_exist eq 1>
			Unit_of_Measure_Desc_Singular,	Abbreviation_Singular
			<cfelse>
			Unit_Of_Measure_Desc as Unit_of_Measure_Desc_Singular,	Abbreviation as Abbreviation_Singular
			</cfif>
	FROM
		Units_Of_Measure
	
	<cfif show_where_clause GT 0>WHERE</cfif>
		<!--- exclusion list --->
		<cfif listlen(attributes.uom_id_exclusion_list) GT 0>
			Unit_Of_Measure_ID NOT IN(#attributes.uom_id_exclusion_list#)
		</cfif>
		<!--- inclusion list --->
		<cfif listlen(attributes.uom_id_inclusion_list) GT 0>
			<cfif listlen(attributes.uom_id_exclusion_list) GT 0>OR</cfif>
			Unit_Of_Measure_ID IN(#attributes.uom_id_inclusion_list#)
		</cfif>
		<cfif attributes.lookup_uom_display_text EQ 1>
			Unit_Of_Measure_ID IN(#attributes.lookup_uom_display_text_uom_id#)
		</cfif>
	ORDER BY 
		Display_Order
</cfquery>


<cfset rowCount = 1>
<CFLOOP query="getUOMs">
	<cfswitch expression="#getUOMs.Unit_Of_Measure_ID#">
		<cfcase value="1">
			<cfif attributes.plural_uom_display EQ 0>
				<cfset Unit_Of_Measure_Desc_temp 	= "Case">
				<cfset Abbreviation_temp 			= "CS">
			<cfelse>
				<cfset Unit_Of_Measure_Desc_temp 	= "Cases">
				<cfset Abbreviation_temp 			= "CS">
			</cfif>
		</cfcase>

		<cfcase value="2">
			<cfif attributes.plural_uom_display EQ 0>
				<cfset Unit_Of_Measure_Desc_temp 	= "Pound">
				<cfset Abbreviation_temp 			= "LB">
			<cfelse>
				<cfset Unit_Of_Measure_Desc_temp 	= "Pounds">
				<cfset Abbreviation_temp 			= "LBS">
			</cfif>
		</cfcase>

		<cfcase value="3">
			<cfif attributes.plural_uom_display EQ 0>
				<cfset Unit_Of_Measure_Desc_temp 	= "%">
			<cfelse>
				<cfset Unit_Of_Measure_Desc_temp 	= "%">
			</cfif>
			<cfset Abbreviation_temp 			= "%">
		</cfcase>
		
		<cfdefaultcase>
			<cfif attributes.plural_uom_display EQ 0>
				<cfset Unit_Of_Measure_Desc_temp 	= Unit_of_Measure_Desc_Singular>
				<cfset Abbreviation_temp 			= Abbreviation_Singular>
			<cfelse>
				<cfset Unit_Of_Measure_Desc_temp 	= Unit_Of_Measure_Desc>
				<cfset Abbreviation_temp 			= Abbreviation>
			</cfif>			
		</cfdefaultcase>
	</cfswitch>
	
	<cfset temp = QuerySetCell(getUOMs,"Unit_Of_Measure_Desc",Unit_Of_Measure_Desc_temp,rowCount)>
	<cfset temp = QuerySetCell(getUOMs,"Abbreviation",Abbreviation_temp,rowCount)>
	<cfset rowCount = rowCount + 1>
</CFLOOP>

</cfsilent>
<!--- Dev Note: Clay - 7965: Display Radio List instead of Dropdown (select boxes do not have z-index property. --->
<cfoutput>
<cfif attributes.lookup_uom_display_text EQ 0>
		<input type="radio" name="#attributes.dropdown_name#" value="#getUOMs.Unit_Of_Measure_ID#" 
			<cfif getUOMs.Unit_Of_Measure_ID EQ attributes.selected_uom_id>checked
			<cfelseif attributes.setDefaultSelected> 
					<cfif getUOMs.Unit_Of_Measure_ID eq getRateTypesFromTemplate.RateTypeDefault>checked</cfif> 
			</cfif> 
			<cfif len(trim(attributes.text_before_tag_close)) GT 0>#attributes.text_before_tag_close#</cfif>>
			<cfif attributes.option_text_abbreviated EQ 1>#getUOMs.Abbreviation#<cfelse>#getUOMs.Unit_Of_Measure_Desc#</cfif>
<cfelse>
	<cfif attributes.option_text_abbreviated EQ 1>#getUOMs.Abbreviation#<cfelse>#getUOMs.Unit_Of_Measure_Desc#</cfif>
</cfif>
</cfoutput>
