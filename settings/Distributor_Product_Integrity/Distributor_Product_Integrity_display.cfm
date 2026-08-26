<SCRIPT SRC="/settings/component_product_restrictions/component_product_restriction.js"></SCRIPT>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


<TABLE width="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<cfoutput>
	<TR ID="HEADER" BGCOLOR="##FFCE84">
		<TD valign="top" width="10">
			<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this, 'CID');">
		</TD>
		
		<TD STYLE="font-size:11px;" width="200" valign="top">
			<b>Rule Name</b>
		</TD>
		
		<TD STYLE="font-size:11px;" width="200" valign="top">
			<b>Error Message</b>
		</TD>
		
		<TD STYLE="font-size:11px;" width="15" valign="top">
			<b>Restricted</b>
		</TD>
		
		<TD STYLE="font-size:11px;" width="50" valign="top">
			<b>Products</b>
		</TD>
		
		<TD STYLE="font-size:11px;" width="50" valign="top">
			<b>#application.returned_customer_setting.distributor_label_plural#</b>
		</TD>
		<TD width="1%" STYLE="font-size:11px;" valign="top"><B>Edit</B></TD>
		<TD width="1%" STYLE="font-size:11px;" valign="top"><B>Delete</B></TD>
	</TR>
	</cfoutput>
	<CFOUTPUT QUERY="qGetComp">
	
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD width="10"><INPUT TYPE="checkbox" NAME="CID" value="#qGetComp.Distributor_Product_Integrity_Rule_ID#"></TD>
		
		<TD STYLE="font-size:11px;" valign="top">
			#qGetComp.Rule_Name#
		</TD>
		
		<TD STYLE="font-size:11px;" valign="top">
			#qGetComp.Error_Msg#
		</TD>
		
		<TD STYLE="font-size:11px;" valign="top">
			<cfif qGetComp.Inclusive_Restriction IS 1>Yes<cfelse>No</cfif>
		</TD>
		
		<TD STYLE="font-size:11px;" valign="top">
			<cfquery name="GetProducts" datasource="#application.datasource#">
				SELECT Count(Distributor_Product_Integrity_Products_ID) AS Product_Count
				FROM Distributor_Product_Integrity_Products
				WHERE Distributor_Product_Integrity_Rule_ID = '#qGetComp.Distributor_Product_Integrity_Rule_ID#'
			</cfquery>
			#GetProducts.Product_Count#
		</TD>
		
		<TD STYLE="font-size:11px;" valign="top">
			<cfquery name="GetProducts" datasource="#application.datasource#">
				SELECT Count(Distributor_Product_Integrity_Distributors_ID) AS Distributor_Count
				FROM Distributor_Product_Integrity_Distributors
				WHERE Distributor_Product_Integrity_Rule_ID = '#qGetComp.Distributor_Product_Integrity_Rule_ID#'
			</cfquery>
			#GetProducts.Distributor_Count#
		</TD>
		<TD TITLE="Edit #Rule_Name#" ALIGN="center"><a href="" onClick="JavaScript: return editComp('#Distributor_Product_Integrity_Rule_ID#');"><img src="/images/edit.gif" TITLE="edit #Rule_Name#" BORDER="0"></a></TD>
		
		<TD TITLE="Delete #Rule_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deleteComp('#Distributor_Product_Integrity_Rule_ID#');"><img src="/images/no_small.gif" TITLE="Delete #Rule_Name#" BORDER="0"></a></TD>
		
	</TR>	
	</CFOUTPUT>
</TABLE>