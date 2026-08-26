
<CFPARAM NAME="Attributes.Title" DEFAULT="">
<CFPARAM NAME="Attributes.File_Extension" DEFAULT="html">
<CFPARAM NAME="Attributes.Relative_Src_File_Path" DEFAULT="">
<CFPARAM NAME="Attributes.Relative_Dest_Dir_Path" DEFAULT="">
<CFPARAM NAME="Attributes.Return_Variable_Name" DEFAULT="">


<cfif IsDefined("request.ApplicationPath")>
	<CFSET CT_File_Path = request.ApplicationPath>
<cfelse>
	<cfset CT_File_Path = Caller.ApplicationPath>
</cfif>

<cfif IsDefined("Caller.Application.Doc_Path")>	
	<CFSET CT_File_Path = CALLER.Application.Doc_Path>
</cfif>


<CFSET findslash=left(Attributes.Relative_Src_File_Path,1)>

<CFIF TRIM(findslash) EQ "\">		
	<CFSET SRC_Path ="#CT_File_Path##Attributes.Relative_Src_File_Path#">	
<CFELSE>
	<CFSET SRC_Path ="#CT_File_Path#\#Attributes.Relative_Src_File_Path#">
</CFIF>

	
<CFSET LeftSlash=Left(Attributes.Relative_Dest_Dir_Path,1)>
<CFSET RightSlash=Right(Attributes.Relative_Dest_Dir_Path,1)>

<CFIF LeftSlash EQ "\" AND RightSlash EQ "\">
	<CFSET Dest_Path = "#CT_File_Path##Attributes.Relative_Dest_Dir_Path##request.AccessStructure.User_ID#">
<CFELSEIF LeftSlash EQ "\" AND RightSlash NEQ "\" >
	<CFSET Dest_Path = "#CT_File_Path##Attributes.Relative_Dest_Dir_Path#\#request.AccessStructure.User_ID#">
<CFELSEIF LeftSlash NEQ "\" AND RightSlash EQ "\" >
	<CFSET Dest_Path = "#CT_File_Path#\#Attributes.Relative_Dest_Dir_Path##request.AccessStructure.User_ID#">
<CFELSEIF LeftSlash NEQ "\" AND RightSlash NEQ "\" >
	<CFSET Dest_Path = "#CT_File_Path#\#Attributes.Relative_Dest_Dir_Path#\#request.AccessStructure.User_ID#">
</CFIF>	

<!--- 
<CFSET Dest_Path = "#APPLICATIONPATH#\#Attributes.Relative_Dest_Dir_Path#\#request.AccessStructure.User_ID#">
<CFSET SRC_Path = "#APPLICATIONPATH#\#Attributes.Relative_Src_File_Path#">
 --->

<CFIF NOT DirectoryExists("#Dest_Path#")>
	<CFDIRECTORY 	ACTION		=	"CREATE"
					DIRECTORY	=	"#Dest_Path#">	
</CFIF>

<CFSET Build_File_Name = Attributes.Title>
<!--- <CFSET Build_File_Name = REReplaceNoCase(Build_File_Name,"[ \r\n\t~`@##$%^&\*()\-\+={}\[\]|\\""':;?/<>,.]","_","All")> --->
<CFSET Build_File_Name = REReplaceNoCase(Build_File_Name,"[^0-9A-Za-z_]","_","All")>
<CFSET Build_File_Name = REReplace(Build_File_Name,"_+","_","All")>
<CFSET Build_File_Name = Left(Build_File_Name,100)>
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

<CFFILE ACTION 		= "COPY"
		SOURCE 		= "#SRC_Path#"
		DESTINATION = "#Dest_Path#\#Build_File_Name#">

<CFSET "CALLER.#Attributes.Return_Variable_Name#" = "#Dest_Path#\#Build_File_Name#">