	<cfparam name="url.Alias_Management_Product_History_ID" default="">

	<cfset AliasManager = application.oController.getObject(path="mvc.Models.Alias.AliasManager",bReload= 1).init() />

	<cfset variables.qgetAliasManagementHistoryDetail = AliasManager.getAliasManagementHistoryDetail(url.Alias_Management_Product_History_ID)>
	
	<TABLE cellspacing="1">
	 
	<CFOUTPUT QUERY="variables.qgetAliasManagementHistoryDetail" GROUP="Row_Num">
	<!--- Row_Num will be 0 when we have a SQL error, not a validation error. In this case, we do not know the row number.
	      Row_Num is used for validation errors only - When the data from the upload file does not exist in the db: Group level OR Item 
	      OR Distributor OR Distributor Product Number.
	--->
	<cfif Row_Num neq 0>
	<TR>
	 <TD><b>Row #Row_Num#</b></TD>
	</TR>
	</cfif>

	<cfoutput>
	<TR>
	 <TD>#Error_Message#</TD>
	</TR>          
        </cfoutput>

	</CFOUTPUT>