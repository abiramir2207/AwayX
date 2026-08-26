
<TABLE width="60%" border="0" cellpadding="1" cellspacing="0">
	<TR>
		<CFIF qGetCompRebates.recordCount GT 0>
			<TD ALIGN="left" WIDTH="130" nowrap>
			<CFIF form.display eq "inActive">
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return activateSelComps();">
			activate selected</a>
			<CFELSE>
			<B><FONT COLOR="FF0000">[</FONT><a HREF="" onClick="javaScript: return deactivateSelComps();">
			deactivate selected</a>
			</b></b></CFIF><B><B>
			<FONT COLOR="FF0000">]</FONT></B>
			</b></TD>
		</CFIF>
		<TD WIDTH="">&nbsp;</TD>
	</TR>
</TABLE>
<br>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD width="10">
			<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);">
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Discount Identifier</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Discount Identifier Description</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>ERP Component Type</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>ERP Customer Type</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Default</b>
		</TD>
		<TD WIDTH="65" STYLE="font-size:11px;"><B>
		<cfif form.display eq "active">
			DeActivate
		<cfelse>
			Activate
		</cfif>&nbsp;</B></TD>
		<TD WIDTH="50" STYLE="font-size:11px;"><B>Delete</B></TD>
	</TR>
	
	<CFOUTPUT QUERY="qGetCompRebates">
		<!---check to see if we can delete this component--->
		<cfscript>
			bCanDelete = compRebate.canDelete(qGetCompRebates.Discount_Identifier_ID);
		</cfscript>
	
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD width="10"><INPUT TYPE="checkbox" NAME="CID" value="#Discount_Identifier_ID#"></TD>
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#Discount_Identifier_ID#');">#Discount_Identifier_Number#</a>
		</TD>
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#Discount_Identifier_ID#');">#Discount_Identifier_Desc#</a>
		</TD>
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#Discount_Identifier_ID#');">#External_Component_Type#</a>&nbsp;
		</TD>
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#Discount_Identifier_ID#');"><cfif External_Customer_Type_ID EQ 1>#application.returned_customer_setting.distributor_label_singular#<cfelseif External_Customer_Type_ID EQ 2>#application.returned_customer_setting.operator_label_singular#</cfif></a>&nbsp;
		</TD>
		<TD>
			<cfif isDefault IS 1>default<cfelse><a href="" onClick="JavaScript: return changeDefault('#Discount_Identifier_ID#','#Discount_Identifier_Number#');">set as default</a></cfif>
		</TD>
		<!---can't deactivate default--->
		<cfif IsDefault IS 1>
		<TD TITLE="Deactivate #Discount_Identifier_Number#" ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></td>
		<cfelse>
		<CFIF form.display EQ "active">
			<TD TITLE="Deactivate #Discount_Identifier_Number#" ALIGN="center"><a href="" onClick="JavaScript: return deactivateComp('#Discount_Identifier_ID#');"><img src="/images/not_allowed.gif" TITLE="Deactivate #Discount_Identifier_Number#" BORDER="0"></a></TD>
		<CFELSE>
			<TD TITLE="Activate #Discount_Identifier_Number#" ALIGN="center"><a href="" onClick="JavaScript: return activateComp('#Discount_Identifier_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate #Discount_Identifier_Number#" BORDER="0"></a></TD>
		</CFIF>
		<!---It's not a default--->
		</cfif>
		
		<CFIF bCanDelete AND (isDefault IS 0)>
			<TD TITLE="Delete #Discount_Identifier_Number#" ALIGN="center"><a href="" onClick="JavaScript: return deleteComp('#Discount_Identifier_ID#');"><img src="/images/no_small.gif" TITLE="Delete #Discount_Identifier_Number#" BORDER="0"></a></TD>
		<CFELSE>
			<TD ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></TD>
		</CFIF>	
	</TR>	
	</CFOUTPUT>
</TABLE>

