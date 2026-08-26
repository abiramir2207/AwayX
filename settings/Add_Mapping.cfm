<style type="text/css">
	.TopLink
	{
		font-family:Arial, Helvetica, sans-serif;
		font-size:10px;
		font-weight:bold;
	}


</style>

<div align="right"><a href="#" OnClick="self.close()" class="TopLink";><B>Close Window</B></a></div>
<cfparam name="txtMappingName" default ="">
<cfparam name="txtMappingPath" default ="">
<cfparam name="SubmitMapping" default ="">
<cfparam name="formname" default ="">
<cfparam name="action" default ="">

	<script language="JavaScript">
		/* Add an mapping */
		function fnMapping(Mapping)
		{	
			if(confirm("Are you sure you want to add/edit the mapping?"))
			{
				document.frmMapping.submit();
				opener.document.all.<cfoutput>#formname#</cfoutput>.DocumentPath.value = document.frmMapping.txtMappingPath.value;
				opener.document.all.<cfoutput>#formname#</cfoutput>.DocumentMapping.value = document.frmMapping.txtMappingName.value;
				<cfoutput>opener.#formname#.submit();</cfoutput>
				self.close();
			}
		}
	</script>

<!--- Add a mapped path in CF Administrator
<cfset MappingObject = CreateObject("component", "components.general.mappings")/>	
	<cfset MappingEdit = MappingObject.edit("#txtMappingName#","#txtMappingPath#")>

<cfif MappingEdit eq 0>
	<cfset MappingAdd =  MappingObject.add("#txtMappingName#","#txtMappingPath#")>
</cfif>
--->

<cfoutput>

<!--- To Get the Root folder name 
<cfset  FolderPath = GetDirectoryFromPath(GetTemplatePath())>
<cfset FindDelimitingFolderChar1 = Find("\", Reverse(FolderPath), 2)>
<cfset ReverseFolderPath = RemoveChars(Reverse(FolderPath), 1,FindDelimitingFolderChar1)>
<cfset RootFolderName = Reverse(Left(ReverseFolderPath,Find("\", ReverseFolderPath)-1))>
--->
<cfset useLakebaseForGet_AppDocument_path = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGet_AppDocument_path>
	<cftry>
		<cfset Get_AppDocument_path = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "document_path"
			}), "document_path"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_AppDocument_path = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_AppDocument_path>
<CFQUERY NAME="Get_AppDocument_path" datasource="#application.datasource#">
	select document_path
	from _application_settings
</CFQUERY>
</cfif>
<form method="post" action="#cgi.script_name#" name="frmMapping">
	<table>
	 <tr>
		<td>Mapping Name</td>
		<td><input type="text" name="txtMappingName" value="#Application.Doc_Mapping#"></td>
	 </tr>

	  <tr>
		<td>Mapping Path</td>
		<td><input type="text" name="txtMappingPath" value="<cfif Get_AppDocument_path.recordcount GT 0 AND trim(Get_AppDocument_path.document_path) NEQ "">#Get_AppDocument_path.document_path#<cfelse>#Application.Doc_Path#</cfif>"></td>
	 </tr>

	   <tr>
		<td colspan="2" align="right"><a href="##" onClick="fnMapping()"><B><FONT COLOR="Red">[ </FONT>Add / Edit Mapping<FONT COLOR="Red"> ]</FONT></B></a></td>
	 </tr>
	</table>
</form>
</cfoutput>

