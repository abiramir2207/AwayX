<cfsetting enablecfoutputonly="Yes">
<cfsilent>
<!--- 
	purpose:
		to display the appropiate UOM's
	how:
		using information from the template information and supplied criteria  
 --->
 
<cfset cachewithin_hours = 1>

<CFPARAM NAME="attributes.Disabled" 	DEFAULT="0">

<CFPARAM NAME="attributes.BG_Color" 	DEFAULT="FFFFFF">

<CFPARAM NAME="attributes.generic_type_restriction" 	DEFAULT=false>

<!---if this is on then the default uom will be selected--->
<CFPARAM NAME="attributes.setDefaultSelected" DEFAULT=0>

<cfparam name="attributes.tabindex" default="">

<cfparam name="attributes.company_main_id"			default="0"><!--- used to find restriction rules--->
	<cfif len(trim(attributes.company_main_id)) EQ 0><cfset attributes.company_main_id = 0></cfif>

<cfparam name="attributes.dropdown_name" 			default="sysgen_ & replace(createuuid(),'-','','all')"><!--- dropdown object name --->
	<cfif len(trim(attributes.dropdown_name)) EQ 0><cfset attributes.dropdown_name = "sysgen_" & replace(createuuid(),"-","","all")></cfif>

<cfparam name="attributes.dropdown_id" 			default="">

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
	
	<CFPARAM NAME="attributes.Show_Dollar" 	DEFAULT=0>
	<CFPARAM NAME="attributes.show_EA" 	DEFAULT=0>
	<CFPARAM NAME="attributes.show_Sleeve" 	DEFAULT=0>
	<CFPARAM NAME="attributes.show_CWT" 	DEFAULT=0>
	<CFPARAM NAME="attributes.width" 	DEFAULT="">
	<CFPARAM NAME="attributes.compVarReplace" 	DEFAULT="">
<!--- exclude or include based on product type id --->

<cfparam name="attributes.lookup_uom_display_text"	default="0">
	<cfif len(trim(attributes.lookup_uom_display_text)) EQ 0><cfset attributes.lookup_uom_display_text = 0></cfif>

<cfparam name="attributes.lookup_uom_display_text_uom_id"	default="0">
	<cfif len(trim(attributes.lookup_uom_display_text_uom_id)) EQ 0><cfset attributes.lookup_uom_display_text_uom_id = 0></cfif>

<cfparam name="attributes.productUom"	default="">
<cfparam name="attributes.onchange" default="">
<cfparam name="attributes.isGroup" default="0"> <!--- Dev Note: KAL; 9588 : New template settings for Group UOM selections --->


<cfset Default_UOM = ""/>	<!--- Dev Note: KAL; New template settings for Group UOM selections --->
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
	
	<!--- Bid Pricing --->
		<cfcase value="10">
			<cfset attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,3)>
			<cfset attributes.uom_id_inclusion_list = attributes.uom_id_inclusion_list>
		</cfcase>
		<cfdefaultcase><!--- do nothing ---></cfdefaultcase>
	</cfswitch>
	
	<cfif attributes.program_id NEQ 0 and isnumeric(attributes.program_id)>
		<cfquery name="getProgramTemplateID" datasource="#application.datasource#" cachedwithin="#createtimespan(0,cachewithin_hours,0,0)#">
			SELECT     ProgramType_ID
			FROM       dbo.Contract_Main
			WHERE     (Contract_Main_ID = #attributes.program_id#)
		</cfquery>
		<cfif getProgramTemplateID.recordcount GT 0>
			<cfset attributes.program_template_id = getProgramTemplateID.ProgramType_ID>
		</cfif>
		
	</cfif>
	<cfparam name="getRateTypesFromTemplate.RateTypeDefault" 	default="0">
	<cfif attributes.program_template_id NEQ "0" and isnumeric(attributes.program_template_id)>
		<cfquery name="getRateTypesFromTemplate" datasource="#application.datasource#" cachedwithin="#createtimespan(0,cachewithin_hours,0,0)#">
			SELECT 
				RateTypeOption_1,
				RateTypeOption_2,
				RateTypeOption_3,
				RateTypeOption_4,<!---63887--->
				RateTypeOption_5,<!---76541--->
				RateTypeOption_6,<!---82429--->
				Generic_Type,
				RateTypeDefault,
				Restrict_On_Inventory_UOM_Case,
				Restrict_On_Inventory_UOM_Pound
				<cfif attributes.isGroup EQ 1>
					,Group_Programs_UOM,
					Groups_UOM_1,
					Groups_UOM_2,
					Groups_UOM_3,
					Groups_UOM_Default
				</cfif>
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
		<CFIF attributes.generic_type_restriction>
		<cfif getRateTypesFromTemplate.Generic_Type NEQ "Distributor Trade/Shelter" AND application.returned_customer_setting.customer_keyword NEQ "conagra">
			<CFSET ExcludePercentage = 1>
		</cfif>
		</CFIF>
		
		<!--- Dev Note: KAL; 9588: When item is group, get group UOMs selected in template when they are different from product UOM --->
		<cfif attributes.isGroup EQ 1 and getRateTypesFromTemplate.Group_Programs_UOM EQ 1> 
		
			<cfif getRateTypesFromTemplate.Groups_UOM_1 EQ 0>
				<CFSET attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,1)>
			</cfif>
			<cfif getRateTypesFromTemplate.Groups_UOM_2 EQ 0>
				<CFSET attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,2)>
			</cfif>
			<cfif getRateTypesFromTemplate.Groups_UOM_3 EQ 0 OR ExcludePercentage EQ 1>
				<CFSET attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,3)>
			</cfif>
			<!--- 76541 Allow user to create program in Eaches unit of measure --->
			<cfif getRateTypesFromTemplate.RateTypeOption_5 EQ 1>
				<CFSET attributes.show_EA = 1 />
			</cfif>
			<!--- 82429 Add new UOMs to Programs --->
			<cfif getRateTypesFromTemplate.RateTypeOption_6 EQ 1>
				<CFSET attributes.show_Sleeve = 1 />
			</cfif>
			<cfif getRateTypesFromTemplate.RateTypeOption_4 EQ 1>
				<CFSET attributes.show_CWT = 1 />
			</cfif>
			<cfset Default_UOM = getRateTypesFromTemplate.Groups_UOM_Default />
			<!---Dev Note: 20863 - Fix for Default UOM for Product Groups based on template settings --->
			<cfif attributes.selected_uom_id eq 0 or len(trim(attributes.selected_uom_id)) eq 0 or ListFindNoCase(attributes.uom_id_exclusion_list, attributes.selected_uom_id)>
				<cfset attributes.selected_uom_id = Default_UOM />
			</cfif>

		<cfelse> <!--- else :  attributes.isGroup EQ 0 --->

			<cfif getRateTypesFromTemplate.RateTypeOption_2 EQ 0>
				<CFSET attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,1)>
			</cfif>
			<cfif getRateTypesFromTemplate.RateTypeOption_1 EQ 0>
				<CFSET attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,2)>
			</cfif>
			<cfif getRateTypesFromTemplate.RateTypeOption_3 EQ 0 OR ExcludePercentage EQ 1>
				<CFSET attributes.uom_id_exclusion_list = listappend(attributes.uom_id_exclusion_list,3)>
			</cfif>
			<!---63887 :: Need new UOM for Per Hundred Weight (CWT) START--->
			<cfif getRateTypesFromTemplate.RateTypeOption_4 EQ 1>
				<CFSET attributes.show_CWT = 1>
			</cfif>
			<!---63887 :: Need new UOM for Per Hundred Weight (CWT) END--->
			<!--- 76541 Allow user to create program in Eaches unit of measure --->
			<cfif getRateTypesFromTemplate.RateTypeOption_5 EQ 1>
				<CFSET attributes.show_EA = 1 />
			<cfelse>
				<CFSET attributes.show_EA = 0 />
			</cfif>
			<!--- 82429 Add new UOMs to Programs--->
			<cfif getRateTypesFromTemplate.RateTypeOption_6 EQ 1>
				<CFSET attributes.show_Sleeve = 1 />
			</cfif>
			<cfset Default_UOM = getRateTypesFromTemplate.RateTypeDefault />

		</cfif> <!--- end:  attributes.isGroup EQ 0 --->

	</cfif>
	
	<cfif listlen(attributes.uom_id_exclusion_list) GT 0 OR listlen(attributes.uom_id_inclusion_list) GT 0>
		<cfset show_where_clause = 1>
	</cfif>

<cfelse>
	<cfset show_where_clause = 1>
</cfif>

<!------ if the product uom is passed, see whther we have to look at it ----->
<cfparam name="caller.useRestrictProductUOM" 	default="0">
<cfif attributes.productUom NEQ "">

	<cfif request.app_general_functions.checkDirectoryAndFile("components\settings", "ApplicationSettingsManager.cfc")>
		<cfif NOT isDefined("caller.genSettingsManager")>
			<cfset caller.genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		</cfif>
		
		<cfif NOT isDefined("caller.appSettings")>
			<cfset caller.appSettings = caller.genSettingsManager.get()>
		</cfif>	
		<cfset caller.useRestrictProductUOM = caller.appSettings.getRestrictProductUOM()>
	</cfif>

	<!--- If the Group UOM EQ 0, Group might have multiple UOM or none, we set the UOM to template default. 
		In case template default is % or none, we are presetting the UOM to Case --->
	<cfif caller.useRestrictProductUOM EQ 1 and attributes.productUom EQ "0" and attributes.isGroup EQ 1 >
		<cfif Default_UOM EQ 2>
			<cfset attributes.productUom = "LB" />
		<cfelseif Default_UOM  EQ 1>
			<cfset attributes.productUom = "CS" />
		<cfelse>
			<cfif listfind(attributes.uom_id_exclusion_list, "1") >
				<cfset attributes.productUom = "LB" />
			<cfelse>
				<cfset attributes.productUom = "CS" />
			</cfif>
		</cfif>
	</cfif>
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
<cfif Default_UOM EQ ''>
	<cfset Default_UOM = 0/>
</cfif>
<cfquery name="getUOMs" datasource="#application.datasource#" cachedwithin="#createtimespan(0,cachewithin_hours,0,0)#">
	SELECT 	Unit_Of_Measure_ID,
			rtrim(ltrim(Unit_Of_Measure_Desc)) AS Unit_Of_Measure_Desc,			
			rtrim(ltrim(Abbreviation)) AS Abbreviation,
			<cfif uom_singular_fields_exist eq 1>
			rtrim(ltrim(Unit_of_Measure_Desc_Singular)) AS Unit_of_Measure_Desc_Singular,	
			rtrim(ltrim(Abbreviation_Singular)) AS Abbreviation_Singular,
			<cfelse>
			rtrim(ltrim(Unit_Of_Measure_Desc)) AS Unit_of_Measure_Desc_Singular,	
			rtrim(ltrim(Abbreviation))  AS Abbreviation_Singular,
			</cfif>
			#Default_UOM# AS Default_UOM
	FROM
			Units_Of_Measure
	WHERE	1=1
		
		<cfif listlen(attributes.uom_id_exclusion_list) GT 0 OR listlen(attributes.uom_id_inclusion_list) GT 0>
		AND
		(
			<!--- exclusion list --->
			<cfif listlen(attributes.uom_id_exclusion_list) GT 0>
				Unit_Of_Measure_ID NOT IN(#attributes.uom_id_exclusion_list#)
			</cfif>
			<!--- inclusion list --->
			<cfif listlen(attributes.uom_id_inclusion_list) GT 0>
				<cfif listlen(attributes.uom_id_exclusion_list) GT 0>OR</cfif>
				Unit_Of_Measure_ID IN(#attributes.uom_id_inclusion_list#)			
			</cfif>
		)
		</cfif>
		<cfif attributes.lookup_uom_display_text EQ 1>
			AND Unit_Of_Measure_ID IN(#attributes.lookup_uom_display_text_uom_id#)
		</cfif>
		<cfif attributes.show_dollar IS NOT 1>
			AND	Unit_of_Measure_ID != 4
		</cfif>
		<cfif attributes.show_CWT IS NOT 1>
			AND	Unit_of_Measure_ID != 6
		</cfif>
		<cfif attributes.show_EA IS NOT 1>
			AND	Unit_of_Measure_ID != 5
		</cfif>
		<cfif attributes.show_Sleeve IS NOT 1>
			AND	Unit_of_Measure_ID != 7
		</cfif>
		<cfif attributes.productUom NEQ "" AND caller.useRestrictProductUOM EQ 1>
			AND Unit_Of_Measure_ID <> <cfif Trim(UCase(attributes.productUom)) EQ "LB">1<cfelse>2</cfif>
		</cfif>
		
		<!--- 
		Note: Logic for "Restrict_On_Inventory_UOM" (below) and "useRestrictProductUOM" (above) work similarly, 
		but there is a difference. 
		When we turn on "useRestrictProductUOM" app setting, both CS and LB will follow the rules, i.e.
		when "CS" is the product UOM, then only "CS" will be available on that product on the program. Similar logic will
		apply for "LB" as well.
		On the other hand, "Restrict_On_Inventory_UOM" can be turned on for either "CS" or "LB" on the template.
		--->
		<cfif Trim(UCase(attributes.productUom)) EQ "CS">
			<!--- If the template setting "Restrict on Inventory UOM" is set to "CS" --->
			<cfif getRateTypesFromTemplate.Restrict_On_Inventory_UOM_Case eq 1>
			AND Unit_Of_Measure_ID <> 2
			</cfif>
		<cfelseif Trim(UCase(attributes.productUom)) EQ "LB">
			<!--- If the template setting "Restrict on Inventory UOM" is set to "LB"--->
			<cfif getRateTypesFromTemplate.Restrict_On_Inventory_UOM_Pound eq 1>
			AND Unit_Of_Measure_ID <> 1
			</cfif>
		</cfif>
		
	ORDER BY 
		Display_Order
</cfquery>
<cfparam name="attributes.returnResults"	default="0">
<cfparam name="caller.returnResultsData"	default="qReturnData">
<cfset rowCount = 1>

</cfsilent>
<cfoutput>
<cfif attributes.returnResults eq 1>
	<cfset "caller.#attributes.returnResultsData#" = getUOMs />
	<cfexit method="exittag" >
</cfif>

<cfif attributes.lookup_uom_display_text EQ 0>
<select name="#attributes.dropdown_name#" class="editablefield" <cfif attributes.tabindex neq "">tabindex="#attributes.tabindex#"</cfif> <cfif attributes.disabled eq 1>STYLE="background-color: #attributes.BG_Color#" Disabled</cfif><cfif len(trim(attributes.text_before_tag_close)) GT 0>  #attributes.text_before_tag_close#</cfif> <cfif attributes.dropdown_id IS NOT "">id="#attributes.dropdown_id#"</cfif> 
<cfif attributes.width NEQ ""> style="width:#attributes.width#"</cfif>
<cfif attributes.onchange NEQ ""> onchange="#attributes.onchange#"</cfif>>
		<cfif attributes.default_option_on EQ 1>
			<option value="#attributes.default_option_value#">#attributes.default_option_text#</option>
		</cfif>
		
		<cfloop query="getUOMs">
			<!--- <option value="#getUOMs.Unit_Of_Measure_ID#" #iif(getUOMs.Unit_Of_Measure_ID EQ attributes.selected_uom_id, DE(" SELECTED"), DE(""))#><cfif attributes.option_text_abbreviated EQ 1>#Abbreviation#<cfelse>#Unit_Of_Measure_Desc#</cfif></option> --->
			<option value="#Unit_Of_Measure_ID#" <cfif Unit_Of_Measure_ID EQ attributes.selected_uom_id>selected<cfelseif attributes.setDefaultSelected><cfif Unit_Of_Measure_ID eq Default_UOM>selected</cfif></cfif>><cfif attributes.option_text_abbreviated EQ 1>#Abbreviation#<cfelse>#Unit_Of_Measure_Desc#</cfif></option>
		</cfloop>

</select>
	
<cfelse>
	<cfif attributes.option_text_abbreviated EQ 1>#getUOMs.Abbreviation#<cfelse>#getUOMs.Unit_Of_Measure_Desc#</cfif>
</cfif>


</cfoutput>
<cfsetting enablecfoutputonly="No">