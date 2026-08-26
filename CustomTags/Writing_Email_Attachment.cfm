

<CFPARAM NAME="Attributes.Naming_Format" DEFAULT="">
<CFPARAM NAME="Attributes.File_Extension" DEFAULT="html">
<CFPARAM NAME="Attributes.Relative_Path" DEFAULT="">
<CFPARAM NAME="Attributes.folder_name" DEFAULT="">
<CFPARAM NAME="Attributes.Output_Content" DEFAULT="">
<CFPARAM NAME="Attributes.Return_File_Name" DEFAULT="">
<CFPARAM NAME="Attributes.Return_Letter_Name" DEFAULT="">
<CFPARAM NAME="Attributes.Return_filepath" DEFAULT="">
<CFPARAM NAME="Attributes.addNewLine" DEFAULT="Yes">
<CFPARAM NAME="Attributes.Compress" DEFAULT="0"><!--- D33718:3rd Party Claims Upload - Audit Report  --->
<cfparam name="attributes.iscustomerletter" default="0">
<cfparam name="attributes.isletter_system_generated" default="0">

<!--- MVC v11 Edit [begin]
<cfif IsDefined("request.ApplicationPath")>
	<cfset CT_File_Path = request.ApplicationPath>
<cfelse>
	<cfset CT_File_Path = Caller.ApplicationPath>
</cfif>

<cfif IsDefined("Caller.Application.Doc_Path")>
	<cfset CT_File_Path = Caller.Application.Doc_Path>
</cfif>

We may use one or the other...
legacy = application.appPath (same thing)
mvcV11 = application.stMVCAppInfo.applicationPath (same thing)
--->
<cfset CT_File_Path = application.appPath>
<!--- MVC v11 Edit [end] --->

<cfif isdefined("Attributes.folder_name") and Attributes.folder_name NEQ "">
	<cfset setfoldername = #Attributes.folder_name#>
<cfelse>
	<cfif IsDefined("request.AccessStructure")>
		<cfset setfoldername = request.AccessStructure.User_ID>
	<cfelse>
		<cfset setfoldername = Caller.AccessStructure.User_ID>
	</cfif>
</cfif>

<CFSET LeftSlash=Left(Attributes.Relative_Path,1)>
<CFSET RightSlash=Right(Attributes.Relative_Path,1)>

<CFIF LeftSlash EQ "\" AND RightSlash EQ "\">
	<CFSET Dest_Path = "#CT_File_Path##Attributes.Relative_Path##setfoldername#">
<CFELSEIF LeftSlash EQ "\" AND RightSlash NEQ "\" >
	<CFSET Dest_Path = "#CT_File_Path##Attributes.Relative_Path#\#setfoldername#">
<CFELSEIF LeftSlash NEQ "\" AND RightSlash EQ "\" >
	<CFSET Dest_Path = "#CT_File_Path#\#Attributes.Relative_Path##setfoldername#">
<CFELSEIF LeftSlash NEQ "\" AND RightSlash NEQ "\" >
	<CFSET Dest_Path = "#CT_File_Path#\#Attributes.Relative_Path#\#setfoldername#">
</CFIF>	


<CFIF NOT DirectoryExists("#Dest_Path#")>
	<CFDIRECTORY 	ACTION		=	"CREATE"
					DIRECTORY	=	"#Dest_Path#">	
</CFIF>


<CFSET Build_File_Name = Attributes.Naming_Format>
<!--- <CFSET Build_File_Name = REReplaceNoCase(Build_File_Name,"[ \r\n\t~`@##$%^&\*()\-\+={}\[\]|\\""':;?/<>,.]","_","All")> --->
<CFSET Build_File_Name = REReplaceNoCase(Build_File_Name,"[^0-9A-Za-z_]","_","All")>
<CFSET Build_File_Name = REReplace(Build_File_Name,"_+","_","All")>
<cfif Attributes.iscustomerletter EQ 0>
	<CFSET Build_File_Name = Left(Build_File_Name,100)>
</cfif>
<CFSET Check_Duplicate = Build_File_Name>

<CFSET Noduplicate = 0>
<CFSET Count = 0>

<CFLOOP CONDITION = "Noduplicate EQ 0">		
	<CFIF FILEEXISTS("#Dest_Path#\#Check_Duplicate#.#Attributes.File_Extension#")>		
		<CFSET Count = Count + 1>
		<CFSET Check_Duplicate = "#Build_File_Name#_#Count#">
	<CFELSE>
		<CFSET Noduplicate = 1>
	</CFIF>
</CFLOOP>


<CFIF Count EQ 0>
	<CFSET Build_File_Name = "#Build_File_Name#.#Attributes.File_Extension#">
<CFELSE>
	<CFSET Build_File_Name = "#Build_File_Name#_#Count#.#Attributes.File_Extension#">
</CFIF>


<CFFILE 	ACTION 				=	"Write"
				FILE 						= 	"#Dest_Path#\#Build_File_Name#"
				OUTPUT 				= 	"#Attributes.Output_Content#"
				ADDNEWLINE 	=	"#Attributes.addNewLine#" 
				>
<!--- D33718:3rd Party Claims Upload - Audit Report START --->
<cfif Attributes.Compress>
		<CFSET Build_File_Name_Zip = #REPLACE(Build_File_Name,  ".html", ".zip")#>
		<CFZIP 	ACTION		="zip"
						SOURCE		=	"#Dest_Path#\#Build_File_Name#"
						FILE				= "#Dest_Path#\#Build_File_Name_Zip#"
						/>
		<!--- <CFFILE 	ACTION	=	"Delete"
						FILE 			= 	"#Dest_Path#\#Build_File_Name#"
						> --->
			<CFSET "CALLER.#Attributes.Return_File_Name#" = "#Dest_Path#\#Build_File_Name_Zip#">		
			<cfif isdefined("Attributes.folder_name") and Attributes.folder_name NEQ "">	
			<CFSET "CALLER.#Attributes.Return_Letter_Name#" = "#Build_File_Name_Zip#">	
			</cfif>
<cfelse>
			<CFSET "CALLER.#Attributes.Return_File_Name#" = "#Dest_Path#\#Build_File_Name#">		
			<cfif isdefined("Attributes.folder_name") and Attributes.folder_name NEQ "">	
			<CFSET "CALLER.#Attributes.Return_Letter_Name#" = "#Build_File_Name#">	
			</cfif>
</cfif>
<!--- D33718:3rd Party Claims Upload - Audit Report END --->