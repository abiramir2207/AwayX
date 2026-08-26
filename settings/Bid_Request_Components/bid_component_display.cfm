<SCRIPT SRC="/settings/component_product_restrictions/component_product_restriction.js"></SCRIPT>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<TABLE width="60%" border="0" cellpadding="1" cellspacing="0">
	<TR>
		<CFIF qGetCompBidRequest.recordCount GT 0>
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
<TABLE width="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<cfoutput>
	<TR ID="HEADER" BGCOLOR="##FFCE84">
		<TD width="5%" valign="top">
			<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);">
		</TD>
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
		<TD STYLE="font-size:11px;" width="5%" valign="top">
			<b>ID</b>
		</TD>
		</cfif>
		<TD STYLE="font-size:11px;" width="45%" valign="top">
			<b>Component<br />Name</b>
		</TD>
		<!--- Operating Group --->
		<cfif operatingGroupOn>
		<TD STYLE="font-size:11px;" width="13%" valign="top">
			<b>#operatingGroupManager.getLabel(operatingGroupLevel)#</b>
		</TD>
		<TD STYLE="font-size:11px;" width="13%" valign="top">
			<b>Allowance<br />ID</b>
		</TD>
		<TD STYLE="font-size:11px;" width="14%" valign="top">
			<b>Allowance<br />Code</b>
		</TD>
		</cfif>			

		<cfif appSettings.getComponent_Product_Restrictions_On()>
		<TD STYLE="font-size:11px;" width="65" nowrap>
				<b>Restricted Products</b>
		</TD>	
		</cfif>
		<TD width="3%" valign="top" STYLE="font-size:11px;"><B>

		<cfif form.display eq "active">
			DeActivate
		<cfelse>
			Activate
		</cfif></B></TD>
		<TD STYLE="font-size:11px;" width="2%" valign="top"><B>Delete</B></TD>
	</TR>
	</cfoutput>
	<CFOUTPUT QUERY="qGetCompBidRequest">
		<!---check to see if we can delete this component--->
		<cfscript>
			bCanDelete = compBidRequest.canDelete(qGetCompBidRequest.Program_BidRequest_Component_Name_ID);
		</cfscript>
	
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD width="10"><INPUT TYPE="checkbox" NAME="CID" value="#Program_BidRequest_Component_Name_ID#"></TD>
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#Program_BidRequest_Component_Name_ID#');">#External_ID#&nbsp;</a>
		</TD>
		</cfif>
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#Program_BidRequest_Component_Name_ID#');">#Program_BidRequest_Component_Name#&nbsp;</a>
		</TD>
		<!--- Operating Group --->
		<cfif operatingGroupOn>
		<TD>
			<cfif Val(Operating_Group_ID) NEQ 0>#operatingGroupManager.getOperatingGroupDesc(Operating_Group_ID)#</cfif>&nbsp;
		</TD>
		<TD>
			<cfif Val(Allowance_Code_ID) NEQ 0>#allowanceCodeManager.getAllowanceCodes(Allowance_Code_ID).Allowance_Code_Number#</cfif>&nbsp;
		</TD>
		<TD>
			<cfif Val(Allowance_Code_ID) NEQ 0>#allowanceCodeManager.getAllowanceCodeDesc(Allowance_Code_ID)#</cfif>&nbsp;
		</TD>
		</cfif>		
		<cfif appSettings.getComponent_Product_Restrictions_On()>
		<TD  nowrap>
				<a href="##" onClick="getRestrictedProducts('10', '#Program_BidRequest_Component_Name_ID#'); return false;">
					(Edit)
				</a>
		</TD>	
		</cfif>
		<CFIF form.display EQ "active">
			<TD TITLE="Deactivate #Program_BidRequest_Component_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deactivateComp('#Program_BidRequest_Component_Name_ID#');"><img src="/images/not_allowed.gif" ALT="Deactivate #Program_BidRequest_Component_Name#" BORDER="0"></a></TD>
		<CFELSE>
			<TD TITLE="Activate #Program_BidRequest_Component_Name#" ALIGN="center"><a href="" onClick="JavaScript: return activateComp('#Program_BidRequest_Component_Name_ID#');"><img src="/images/on_the_program_item.gif" ALT="Activate #Program_BidRequest_Component_Name#" BORDER="0"></a></TD>
		</CFIF>
		<CFIF bCanDelete>
			<TD TITLE="Delete #Program_BidRequest_Component_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deleteComp('#Program_BidRequest_Component_Name_ID#');"><img src="/images/no_small.gif" ALT="Delete #Program_BidRequest_Component_Name#" BORDER="0"></a></TD>
		<CFELSE>
			<TD ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></TD>
		</CFIF>	
	</TR>	
	</CFOUTPUT>
</TABLE>
