<B><FONT COLOR="FF0000">[</FONT><a href="" onClick="JavaScript: return submitDataForm('busRule', 0, 1);">add new rule</a><FONT COLOR="FF0000">]</FONT></b>
<p>
<TABLE width="90%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;" width="40%" nowrap valign="top">
			<b>Business Rule</b>
		</TD>
		<TD STYLE="font-size:11px;" width="5%" nowrap valign="top">
			<b>UOM</b>
		</TD>
		<TD STYLE="font-size:11px;" width="12%" nowrap valign="top">
			<b>Cost Impact</b>
		</TD>
		<TD STYLE="font-size:11px;" width="23%" nowrap valign="top">
			<b>Cost Impact UOM</b>
		</TD>
		<TD STYLE="font-size:11px;" width="20%" nowrap valign="top">&nbsp;
			
		</TD>
	</TR>
	<CFOUTPUT QUERY="qGetRules">
	
		<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
			<TD STYLE="font-size:11px;" width="60%" nowrap>
				<!---handle for edit mode for this record--->
				<cfif form.editMode eq 1 and form.ruleId eq Program_Rebates_Component_Rule_ID>
					<input name="Rebates_Component_Rule_Desc" type="text" value="#Rebates_Component_Rule_Desc#" size="50" />
				<cfelse>
					#Rebates_Component_Rule_Desc#
				</cfif>
				
			</TD>
			<TD STYLE="font-size:11px;" width="10%" nowrap>
				<!---handle for edit mode for this record--->
				<cfif form.editMode eq 1 and form.ruleId eq Program_Rebates_Component_Rule_ID>
				
					<cf_uom_dropdown
						program_id				=	""
						company_main_id			=	""
						default_option_on		=	"0"
						default_option_text		=	""
						default_option_value	=	""
						dropdown_name			=	"Unit_Of_Measure_ID"
						option_text_abbreviated	=	"1"
						plural_uom_display		=	""
						product_type_id			=	""
						program_template_id		=	""
						selected_uom_id			=	"#Unit_Of_Measure_ID#"
						text_before_tag_close	=	""
						uom_id_exclusion_list	=	""
						uom_id_inclusion_list	=	""
						setDefaultSelected		= 	1		
					>
					
				<cfelse>
					#request.app_general_functions.getUOMDesc(Unit_Of_Measure_ID,0)#
				</cfif>
				&nbsp;
			</TD>
			<TD STYLE="font-size:11px;" width="10%" nowrap>
				<!---handle for edit mode for this record--->
				<cfif form.editMode eq 1 and form.ruleId eq Program_Rebates_Component_Rule_ID>
					<input name="Cost_Impact" type="text" value="#Cost_Impact#" size="10" />
				<cfelse>
					<cfif trim(Cost_Impact) eq "" or trim(Cost_Impact) eq 0>
						None
					<cfelse>
						#Cost_Impact#
					</cfif>
				</cfif>
				&nbsp;
			</TD>
			<TD STYLE="font-size:11px;" width="10%" nowrap>
				<!---handle for edit mode for this record--->
				<cfif form.editMode eq 1 and form.ruleId eq Program_Rebates_Component_Rule_ID>
					
					<cf_uom_dropdown
						program_id				=	""
						company_main_id			=	""
						default_option_on		=	"1"
						default_option_text		=	"None"
						default_option_value	=	"0"
						dropdown_name			=	"Cost_Impact_UOM"
						option_text_abbreviated	=	"1"
						plural_uom_display		=	""
						product_type_id			=	""
						program_template_id		=	""
						selected_uom_id			=	"#Cost_Impact_UOM#"
						text_before_tag_close	=	""
						uom_id_exclusion_list	=	""
						uom_id_inclusion_list	=	""
						setDefaultSelected		= 	1		
					>
					
				<cfelse>
				
					<cfif trim(Cost_Impact_UOM) eq 0>
						None
					<cfelse>
						#request.app_general_functions.getUOMDesc(Cost_Impact_UOM,0)#
					</cfif>
					
				</cfif>
				&nbsp;
			</TD>
			<TD STYLE="font-size:11px;" width="10%" nowrap>
				<!---handle for edit mode for this record--->
				<cfif form.editMode eq 1 and form.ruleId eq Program_Rebates_Component_Rule_ID>
					<a href="" onClick="JavaScript: document.DataForm.command.value = 'commitRule'; return submitDataForm('busRule','#Program_Rebates_Component_Rule_ID#');">(save)</a>
					<a href="" onClick="JavaScript: return submitDataForm('busRule');">(cancel)</a>
				<cfelse>
					<a href="" onClick="JavaScript: return submitDataForm('busRule','#Program_Rebates_Component_Rule_ID#', 1);">(edit)</a>
					<a href="" onClick="JavaScript: document.DataForm.command.value = 'delRule'; return submitDataForm('busRule','#Program_Rebates_Component_Rule_ID#');">(delete)</a>
				</cfif>
			</TD>	
		</TR>
		
	</CFOUTPUT>
</TABLE>
<br>
<B><FONT COLOR="FF0000">[</FONT><a href="" onClick="JavaScript: return submitDataForm('busRule', 0, 1);">add new rule</a><FONT COLOR="FF0000">]</FONT></b>