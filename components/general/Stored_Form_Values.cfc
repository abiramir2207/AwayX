<!------ ContractVolume.cfc ----->
<cfcomponent displayname="Stored_Form_Values" hint="Stored form values for later use">
	<CFSET this.Source_File_Name = "">
	<CFSET this.Relative_Directory = "">	
	<CFSET this.APPLICATIONPATH = "">
	<CFSET this.File_Extension = "">
	<CFSET this.Abs_Path = "">
	<CFSET this.Load_Type = 1>
	<!---------
	Load_Type = 1 //Load all Form Variables
	----------->
	<CFSET this.Exclude_List = "FIELDNAMES">
	<CFSET this.MAIN_STRUCT = StructNew()>
	
   	<cffunction name="Set_File_Properties" output="true" hint="Set_File_Name">		
		<cfargument name="APPLICATIONPATH" type="string" required="true" default="">
		<cfargument name="Relative_Dir" type="string" required="true" default="">
		<cfargument name="File_Name" type="string" required="true" default="">
		<cfargument name="File_Extension" type="string" required="false" default="txt">
		
		<CFSET this.File_Extension = arguments.File_Extension>
		
		<CFSET this.File_Extension = REReplaceNoCase(this.File_Extension, "^\.", "")>		
		
		<CFIF Trim(arguments.File_Name) EQ "">
			<CFSET this.Source_File_Name = ReplaceNoCase(CreateUUID(), "-", "_", "all")>
		<CFELSE>
			<CFSET this.Source_File_Name = arguments.File_Name>
		</CFIF>
		
		<CFSET this.APPLICATIONPATH = arguments.APPLICATIONPATH>
		<CFSET this.Relative_Directory = arguments.Relative_Dir>
		<CFSET this.Relative_Directory = REReplaceNoCase(this.Relative_Directory, "\\$", "")>
		<CFSET this.Relative_Directory = REReplaceNoCase(this.Relative_Directory, "^\\", "")>
		<CFSET this.Abs_Path = this.APPLICATIONPATH & "\" & this.Relative_Directory & "\" & this.Source_File_Name & "." & this.File_Extension>
		<cfreturn this.Source_File_Name>
	</cffunction>

	
	<!----------------- Load_From_Form_Url_Scope() -------------------->
   	<cffunction name="Load_From_Form_Url_Scope" output="true" hint="Load_From_Form_Url_Scope">		
		<CFSET STRUCT_1 = Duplicate(FORM)>
		<CFSET STRUCT_2 = Duplicate(URL)>		
		<CFSET TEMP_STRUCT = StructNew()>
		
		<!---- load values from one struct ------>
		<CFLOOP COLLECTION="#STRUCT_1#" ITEM="EachItem">
			<CFIF NOT ListFindNoCase(this.Exclude_List, EachItem, ",")>
				<CFSET "TEMP_STRUCT.#EachItem#" = Evaluate("STRUCT_1.#EachItem#")>
			</CFIF>
		</CFLOOP>
		
		<!---- load values from second struct ------>
		<CFLOOP COLLECTION="#STRUCT_2#" ITEM="EachItem">
			<CFIF NOT ListFindNoCase(this.Exclude_List, EachItem, ",")>
				<CFIF NOT StructKeyExists(TEMP_STRUCT, EachItem)>
					<CFSET "TEMP_STRUCT.#EachItem#" = Evaluate("STRUCT_2.#EachItem#")>
				</CFIF>
			</CFIF>
		</CFLOOP>
		<CFRETURN TEMP_STRUCT>
	</cffunction>
	
	<!----------------- Load_To_Form_Scope() -------------------->
   	<cffunction name="Load_To_Form_Scope" output="true" hint="Load_To_Form_Scope">
		<!------ set form values ---->
		<CFLOOP COLLECTION="#this.MAIN_STRUCT#" ITEM="EachItem">
			<CFIF this.Load_Type EQ 1 AND NOT IsDefined("FORM.#EachItem#")>
				<CFSET "FORM.#EachItem#" = Evaluate("this.MAIN_STRUCT.#EachItem#")>
			</CFIF>
		</CFLOOP>		
	</cffunction>
	
   	<!----------------- Save() -------------------->
   	<cffunction name="Save" output="true" hint="save form structure to file">
		<cfargument name="load_form_url_scope" type="numeric" required="false" default="1">
		<cfargument name="source_struct" type="struct" required="false" default="#this.MAIN_STRUCT#">
		<CFIF Arguments.load_form_url_scope>		
			<CFSET this.MAIN_STRUCT = this.Load_From_Form_Url_Scope()>
		<CFELSE>
			<CFSET this.MAIN_STRUCT = Duplicate(Arguments.source_struct)>
		</CFIF>		
		<CFIF DirectoryExists(GetDirectoryFromPath(this.Abs_Path))>
			<!---- serialise struct ------>
			<CFWDDX ACTION="CFML2WDDX" INPUT="#this.MAIN_STRUCT#" OUTPUT="MAIN_STRUCT_PACKET">
			<CFFILE ACTION = "WRITE"
			    FILE = "#this.Abs_Path#"
			    OUTPUT = "#MAIN_STRUCT_PACKET#"
			    ADDNEWLINE = "NO">
			<CFSET Return_Value = this.Source_File_Name>
		</CFIF>
		<cfreturn Return_Value>
   	</cffunction>
	
	<!----------------- Load() -------------------->
   	<cffunction name="Load" output="true" hint="load any structure from file">
		<cfargument name="Load_Type" type="numeric" required="true" default="">
		<CFSET this.Load_Type = arguments.Load_Type>
		<CFIF FileExists(this.Abs_Path)>
			<!----- read file -------->
			<CFFILE ACTION = "READ"
				FILE = "#this.Abs_Path#"
				VARIABLE = "FILE_CONTENT">			
			<CFIF IsWDDX(FILE_CONTENT)>
				<!---- load struct --------->
				<CFWDDX ACTION="WDDX2CFML" INPUT="#FILE_CONTENT#" OUTPUT="MAIN_STRUCT">
				<CFSET this.MAIN_STRUCT = MAIN_STRUCT>
				<CFIF this.Load_Type EQ 1><!----- load to form ---->
					<CFSET D_TEMP = this.Load_To_Form_Scope()>
				</CFIF>
			</CFIF>
		</CFIF>
		<CFRETURN this.MAIN_STRUCT>
	</cffunction>
</cfcomponent>