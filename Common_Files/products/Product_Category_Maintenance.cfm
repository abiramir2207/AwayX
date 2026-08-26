<CFPARAM NAME="Variables.Button_Title" DEFAULT="ADD">
<CFPARAM NAME="Variables.Form_Action" DEFAULT="UpdateActions.cfm">
<CFPARAM NAME="Form.Product_Category_ID" DEFAULT="0">
<CFPARAM NAME="Form.Document_ID" DEFAULT="CategoryMaintanence">

<CFIF isdefined("URL.Product_Category_ID")>
		<CFSET Form.Product_Category_ID = URL.Product_Category_ID>
		<CFSET Variables.Button_Title = "SAVE">
</CFIF>

<cfset useLakebaseForGetCurrentProductCategories = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_categories")>
<cfif useLakebaseForGetCurrentProductCategories>
	<cftry>
		<cfset GetCurrentProductCategories = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_categories", {
				"company_main_id" = "eq.#request.AccessStructure.Company_Main_ID#",
				"order" = "category_title.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCurrentProductCategories = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCurrentProductCategories>
<CFQUERY NAME="GetCurrentProductCategories" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM Product_Categories
	WHERE Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
	ORDER BY Category_Title ASC
</CFQUERY>
</cfif>

<cfset useLakebaseForGetSpecifiedCategoryInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_categories")>
<cfif useLakebaseForGetSpecifiedCategoryInfo>
	<cftry>
		<cfset GetSpecifiedCategoryInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_categories", {
				"product_category_id" = "eq.#Form.Product_Category_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetSpecifiedCategoryInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetSpecifiedCategoryInfo>
<CFQUERY NAME="GetSpecifiedCategoryInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM Product_Categories
	WHERE   Product_Category_ID = #Form.Product_Category_ID#
</CFQUERY>
</cfif>


<CFPARAM NAME="Form.Category_Title" DEFAULT="#GetSpecifiedCategoryInfo.Category_Title#">
<CFPARAM NAME="Form.Category_Description" DEFAULT="#GetSpecifiedCategoryInfo.Category_Description#">




<CFSET PAGE_TITLE="Product Category Maintanence">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>
				<CF_Frame Title="Add New Category">
					<TABLE BORDER="0">
						<TR>
							<TD>
								<FORM ACTION="<CFOUTPUT>#Variables.Form_Action#</CFOUTPUT>" METHOD="post" NAME="NewCategory" ID="NewCategory">
								<INPUT TYPE="hidden" NAME="Document_ID" ID="Document_ID" VALUE="<CFOUTPUT>#Form.Document_ID#</CFOUTPUT>">
								<INPUT TYPE="hidden" NAME="Product_Category_ID" ID="Product_Category_ID" VALUE="<CFOUTPUT>#Form.Product_Category_ID#</CFOUTPUT>">
								<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="center">
									<TR>
										<TD>Category Title:<br><INPUT TYPE="text" NAME="Category_Title" ID="Category_Title" SIZE="40" VALUE="<CFOUTPUT>#Form.Category_Title#</CFOUTPUT>">&nbsp;<INPUT TYPE="Submit" VALUE="<CFOUTPUT>#BUTTON_TITLE#</CFOUTPUT>"></TD>
									</TR>
									<TR>
										<TD>Category Description<BR><TEXTAREA COLS="30" ROWS="6" NAME="Category_Description" ID="Category_Description"><CFOUTPUT>#Form.Category_Description#</CFOUTPUT></TEXTAREA></TD>
									</TR>
								</TABLE>
								</FORM>					
							</TD>
						</TR>
					</TABLE>
				</CF_FRAME>
				<BR><BR><BR>
				<CF_Frame Title="Current Product Categories" width="400">
					<CFIF GetCurrentProductCategories.RecordCount NEQ 0>
						<TABLE BORDER="1" CELLSPACING="0" CELLPADDING="3" ALIGN="center">
								<TR>
									<TD WIDTH="200">Product Category</TD>
									<TD WIDTH="300">Description</TD>
								</TR>
								<CFOUTPUT QUERY="GetCurrentProductCategories">
									<tr bgcolor="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('c0c0c0'))#">
										<TD><A HREF="Product_Category_Maintenance.cfm?Product_Category_ID=#GetCurrentProductCategories.Product_Category_ID#">#Category_Title#</A></TD>
										<TD><A HREF="Product_Category_Maintenance.cfm?Product_Category_ID=#GetCurrentProductCategories.Product_Category_ID#">#Category_Description#</A></TD>
									</TR>
								</CFOUTPUT>
						</TABLE>
					<CFELSE>
						<DIV ALIGN="center">No Existing Product Categories</DIV>
					</CFIF>
				</CF_FRAME>
</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>

