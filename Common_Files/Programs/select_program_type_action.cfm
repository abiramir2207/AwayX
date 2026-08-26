<cfscript>
	StructUpdate(Session.Programs.Properties, "Current_Program_Type_ID", #FORM.Program_ID#);
</cfscript>
<cfinclude template="build_menu_based_on_program_type.cfm">