<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Formula Pricing List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->


<CFSET FORMULA_PAGE_NAME="">

<CFPARAM NAME="URL.RID" 	DEFAULT="">
<cfmodule template="/customTags/layout.cfm"
              layoutID = "formulaPricing"
              formula_page_name = #formula_page_name#
              selectedIndex = "99" >

<CFSET URL.Formula_ID=URL.RID>
<CFSET SHOW_ACTIVATE_BUTTON = True>
<CFSET EDIT_RULE = True>
<BR><BR>
<TABLE ALIGN="CENTER" WIDTH="95%">
<TR>
<TD>
<CFINCLUDE TEMPLATE="Formula_Display.cfm">
</TD>
</TR>
</TABLE>


</cfmodule>