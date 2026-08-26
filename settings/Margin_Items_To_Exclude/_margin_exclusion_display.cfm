<!-----------------------------------------------------------------------------

FILE NAME:		_margin_exclusion_display.cfm
DESCRIPTION:	This is the details file that is used to display the Active/Inactive 
              records in the Margin exclusion
CREATED BY:		10-Aug-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
      			Anand Rao	  10-Aug-2010	Created the file
------------------------------------------------------------------------------> 

<SCRIPT SRC="/settings/component_product_restrictions/component_product_restriction.js"></SCRIPT>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<TABLE width="60%" border="0" cellpadding="1" cellspacing="0">
	<TR>
		<CFIF qGetActiveExcludeItems.recordCount GT 0>
			<td ALIGN="left" WIDTH="130" nowrap>
				<CFIF FORM.display eq "inActive">
					<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return activateSelRecs();">activate selected</a><FONT COLOR="FF0000">]</FONT></b>
				<CFELSE>
					<B><FONT COLOR="FF0000">[</FONT><a HREF="" onClick="javaScript: return deactivateSelRecs();">deactivate selected</a><FONT COLOR="FF0000">]</FONT></b>
				</CFIF>
			</td>
		</CFIF>
		<td WIDTH="">&nbsp;</td>
	</tr>
</TABLE>
<br>
<table width="720" border="0" cellpadding="1" cellspacing="0" class="MAINTABLE">
	<!---- HEAD ----->
	<cfoutput>
	<tr id="HEADER" bgcolor="##FFCE84">
		<td valign="top" width="2%">
			<input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'CID');">
		</td>

		<td STYLE="font-size:11px;" width="10%" valign="top">
			<b>ID</b>
		</td>
		<td STYLE="font-size:11px;" width="18%" valign="top">
			<b>Name</b>
		</td>
		<!--- Operating Group --->
    <td STYLE="font-size:11px;" width="12%" valign="top">
			<b>Include on Volume Page?</b>
		</td>
 
<!--- 		<td STYLE="font-size:11px;" width="65" nowrap>
				<b>Products</b>
		</td>	
 		<td STYLE="font-size:11px;" width="65" nowrap>
				<b>Templates</b>
		</td>	 --->
		<!---FILTER: Add/Edit Business Rules and Profile Restriction--->
		<td align="center" width="10%" STYLE="font-size:11px;" valign="top">
		<B>
		<cfif FORM.display eq "active">
			DeActivate
		<cfelse>
			Activate
		</cfif>&nbsp;</B></td>
		<td align="center" width="8%" STYLE="font-size:11px;" valign="top"><B>Delete</B></td>
	</tr>
	</cfoutput>
 <CFOUTPUT QUERY="qGetActiveExcludeItems">
		<!---check to see if we can delete this component--->
		<cfscript>
			// bCanDelete = compRebate.canDelete(qGetActiveExcludeItems.Margin_Item_Exclusion_ID);
		</cfscript>
	
	<tr <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<td width="10"><INPUT TYPE="checkbox" NAME="CID" value="#Margin_Item_Exclusion_ID#"></td>
 	 
		<td>
			<cfif FORM.display eq "active"> 
        <a href="" onClick="JavaScript: return submitEdit('#Margin_Item_Exclusion_ID#');">#Margin_Item_Exclusion_Code#</a>&nbsp;
      <cfelse>
        #Margin_Item_Exclusion_Code#&nbsp;
      </cfif>
		</td>
 
		<td>
      <cfif FORM.display eq "active"> 
			  <a href="" onClick="JavaScript: return submitEdit('#Margin_Item_Exclusion_ID#');">#Margin_Item_Exclusion_Name#</a>&nbsp;
      <cfelse> 
        #Margin_Item_Exclusion_Name#
      </cfif>
		</td>
  
		<td align="center">
			<cfif (Include_On_Volume EQ 1)><img src="/images/yes.gif" width="15" height="15"><cfelse><img src="/images/no_small.gif"/></cfif>&nbsp;
		</td>
    <cfif FORM.display EQ "active">
			<td TITLE="Deactivate #Margin_Item_Exclusion_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deactivateRec('#Margin_Item_Exclusion_ID#');"><img src="/images/not_allowed.gif" title="Deactivate #Margin_Item_Exclusion_Name#" BORDER="0"></a></td>
		<CFELSE>
			<td TITLE="Activate #Margin_Item_Exclusion_Name#" ALIGN="center"><a href="" onClick="JavaScript: return activateRec('#Margin_Item_Exclusion_ID#');"><img src="/images/on_the_program_item.gif" title="Activate #Margin_Item_Exclusion_Name#" BORDER="0"></a></td>
		</CFIF>
<td TITLE="Delete #Margin_Item_Exclusion_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deleteRec('#Margin_Item_Exclusion_ID#');"><img src="/images/no_small.gif" title="Delete #Margin_Item_Exclusion_Name#" BORDER="0"></td>
 
<!--- 		<cfif FORM.display EQ "active">
			<td TITLE="Deactivate #Program_Rebates_Component_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deactivateComp('#Program_Rebates_Component_Name_ID#');"><img src="/images/not_allowed.gif" title="Deactivate #Program_Rebates_Component_Name#" BORDER="0"></a></td>
		<CFELSE>
			<td TITLE="Activate #Program_Rebates_Component_Name#" ALIGN="center"><a href="" onClick="JavaScript: return activateComp('#Program_Rebates_Component_Name_ID#');"><img src="/images/on_the_program_item.gif" title="Activate #Program_Rebates_Component_Name#" BORDER="0"></a></td>
		</CFIF>
		<CFIF bCanDelete>
			<td TITLE="Delete #Program_Rebates_Component_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deleteComp('#Program_Rebates_Component_Name_ID#');"><img src="/images/no_small.gif" title="Delete #Program_Rebates_Component_Name#" BORDER="0"></a></td>
		<CFELSE>
			<td ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></td>
		</CFIF>	 --->
	</tr>	
	</CFOUTPUT>  
</TABLE>