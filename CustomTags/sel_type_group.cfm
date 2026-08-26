

<cfparam name="attributes.business_segment_id" default="0">
 <cf_qry_type_group
	company_main_id = "#attributes.company_main_id#"
	business_segment_id = "#attributes.business_segment_id#"
> 
<!--- 
	purpose:
		to display the appropiate UOM's
	how:
		using information from the template information and supplied criteria  
 --->
<cfset cachewithin_hours = 0>
<cfparam name="attributes.company_main_id"			default="0"><!--- used to find restriction rules--->
	<cfif len(trim(attributes.company_main_id)) EQ 0><cfset attributes.company_main_id = 0></cfif>
<cfparam name="attributes.dropdown_name" 			default="sysgen_ & replace(createuuid(),'-','','all')"><!--- dropdown object name --->
	<cfif len(trim(attributes.dropdown_name)) EQ 0><cfset attributes.dropdown_name = "sysgen_" & replace(createuuid(),"-","","all")></cfif>
<cfparam name="attributes.selected_id"			default="0">
	<cfif len(trim(attributes.selected_id)) EQ 0><cfset attributes.selected_id = 0></cfif>
<cfparam name="attributes.text_before_tag_close"	default=""><!--- enter test that will pe placed before tag close such as style, onclick, onblur --->

<cfparam name="attributes.default_option_on"	default="0">
	<cfif len(trim(attributes.default_option_on)) EQ 0><cfset attributes.default_option_on = 0></cfif>	

<cfparam name="attributes.default_option_text"	default="">
<cfparam name="attributes.default_option_value"	default="">

<cf_qry_type_group
	company_main_id = "#attributes.company_main_id#"
	business_segment_id = "#attributes.business_segment_id#"
>


<cfoutput>
<select name="#attributes.dropdown_name#"<cfif len(trim(attributes.text_before_tag_close)) GT 0>  #attributes.text_before_tag_close#</cfif>>
	<cfif attributes.default_option_on EQ 1>
		<option value="#attributes.default_option_value#">#attributes.default_option_text#</option>
	</cfif>
	
	<cfloop query="qry_type_group">
		<option value="#qry_type_group.Type_Group_Desc_ID#" #iif(qry_type_group.Type_Group_Desc_ID EQ attributes.selected_id, DE(" SELECTED"), DE(""))#>#qry_type_group.Type_Group_Desc#</option>
	</cfloop>
</select>
</cfoutput>
