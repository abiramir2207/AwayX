<cfif isDefined("sSaveMsg")>
	<cfoutput>		
	<font color="red" style="font-weight:bold;">*** #sSaveMsg# ***</font><br>
	</cfoutput>	
</cfif>
<cfset qGetProductReplacement = ProductReplacementManager.getProductReplacement(bActive = bActive) />
<TABLE width="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<cfoutput>
	<TR ID="HEADER" BGCOLOR="##FFCE84">
		<TD width="5%">&nbsp;</TD>
		<TD STYLE="font-size:11px;" width="25%" valign="top">
			<b>Notes</b>
		</TD>
		<TD align="left" width="50%" STYLE="font-size:11px;" valign="top">
		<B>Products</B></TD>
		<TD width="1%" STYLE="font-size:11px;" valign="top"><B>Activate/<br>Deactivate</B></TD>
		<TD width="1%" STYLE="font-size:11px;" valign="top"><B>Delete</B></TD>
	</TR>
	</cfoutput>
	<cfset rowCount = 0 />
	<CFOUTPUT QUERY="qGetProductReplacement" group="Item_Replacement_Header_ID">
	<cfset rowCount = rowCount + 1 />
	<TR <CFIF rowCount MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD valign="top">
			<CF_smallLink 
				title = "edit" 
				url = "##"
				parameters = "onClick=""submitDataForm('addEditProd','#Item_Replacement_Header_ID#');return false;"""
				>
		</TD>
		<TD valign="top">
			<a href="" onClick="JavaScript: return submitDataForm('addEditProd','#Item_Replacement_Header_ID#');">#Item_Replacement_Header_Notes#&nbsp;</a>
		</TD>
		<!---products--->
		<TD>
		<cfoutput>#item# - #description#<br>
		</cfoutput>
		</TD>
		<!---delete--->
		<cfif active>
			<TD valign="top" TITLE="Deactivate this record" ALIGN="center"><a href="" onClick="JavaScript: return deactivate('#Item_Replacement_Header_ID#');"><img src="/images/not_allowed.gif" TITLE="Deactivate this record" BORDER="0"></a></TD>
			<TD valign="top">N/A</TD>
		<cfelse>
			<TD valign="top" TITLE="Activate this record (This record was deactivated by #Deactivated_By_User_Name# on #DeActivated_Date#)" ALIGN="center">
				<a href="" onClick="JavaScript: return activate('#Item_Replacement_Header_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate this record (This record was deactivated by #Deactivated_By_User_Name# on #DeActivated_Date#)" BORDER="0"></a>
			</TD>
			<TD valign="top" TITLE="Delete this record (This record was deactivated by #Deactivated_By_User_Name# on #DeActivated_Date#)" ALIGN="center">
				<a href="" onClick="JavaScript: return deleteRecord('#Item_Replacement_Header_ID#');"><img src="/images/no_small.gif" TITLE="Delete this record (This record was deactivated by #Deactivated_By_User_Name# on #DeActivated_Date#)" BORDER="0"></a>
			</TD>
		</cfif>
		
	</TR>	
	</CFOUTPUT>
</TABLE>