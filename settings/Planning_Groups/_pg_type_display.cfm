<!-----------------------------------------------------------------------------

FILE NAME:		_pg_customer_display.cfm
DESCRIPTION:
CREATED BY:		09-Sep-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  09-Sep-2010	Created the file
------------------------------------------------------------------------------>
<!--- [<a href="_dummy_template_product.cfm"> Testing Product Template</a>]&nbsp;&nbsp;
[<a href="_dummy_template_customer.cfm"> Testing Customer Template</a>] --->
<SCRIPT SRC="/settings/component_product_restrictions/component_product_restriction.js"></SCRIPT>
<style type="text/css">
.b8 {font-weight:bold;font-size:8pt}
</style>

<cfparam name="FORM.sort_by" default="PG_Type_Name" />
<cfparam name="FORM.sort_Order" default="ASC" />

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="setupCodeLink" output="false" returntype="string">
  <cfargument name="Pg_Type_ID"   required="true" type="string"   />
  <cfargument name="PG_Type_Code" required="true" type="string"   />
  <cfargument name="is_System"    required="true" type="numeric" />

  <cfset var vars = {}>
  <!---do not allow editing if entry is a system pg type--->
  <cfif arguments.is_System eq 1>
    <cfoutput><cfsavecontent variable="vars.result">#arguments.Pg_Type_Code# *</cfsavecontent></cfoutput>
  <cfelse>
    <cfoutput><cfsavecontent variable="vars.result"><a href="##" onClick="JavaScript:return submitEdit('#arguments.Pg_Type_ID#','Type');"><strong>#arguments.Pg_Type_Code#</strong></a></cfsavecontent></cfoutput>
  </cfif>

  <cfreturn vars.result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="setupNameLink" output="false" returntype="string">
  <cfargument name="Pg_Type_ID"   required="true" type="string"   />
  <cfargument name="PG_Type_Name" required="true" type="string"   />
  <cfargument name="is_System"    required="true" type="numeric" />

  <cfset var vars = {}>
  <!---do not allow editing if entry is a system pg type--->
  <cfif arguments.is_System eq 1>
    <cfoutput><cfsavecontent variable="vars.result">#arguments.Pg_Type_Name#</cfsavecontent></cfoutput>
  <cfelse>
    <cfoutput><cfsavecontent variable="vars.result"><a href="##" onClick="JavaScript:return submitEdit('#arguments.Pg_Type_ID#','Type');"><strong>#arguments.Pg_Type_Name#</strong></a></cfsavecontent></cfoutput>
  </cfif>

  <cfreturn vars.result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfif !(FORM.sort_by EQ "PG_Type_Code" OR FORM.sort_by EQ "PG_Type_Name" OR FORM.sort_by EQ "PG_Group_Type")>
  <cfset FORM.sort_by = "PG_Type_Name" />
</cfif>

<cfset qryGetActivePgTypes = PGManager.fnGetActivePGTypes(FORM.sort_by,FORM.sort_Order)>
<cfset qryGetInactivePgTypes = PGManager.fnGetInActivePGTypes(FORM.sort_by,FORM.sort_Order)>

<TABLE width="720" border="0" cellpadding="1" cellspacing="0">
	<TR>
			<td ALIGN="left" WIDTH="130" nowrap>
				<CFIF FORM.display eq "inActive">
					<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return activateSelTypeRecs();">activate selected</a><FONT COLOR="FF0000">]</FONT></b>
				<CFELSE>
					<B><FONT COLOR="FF0000">[</FONT><a HREF="" onClick="javaScript: return deactivateSelTypeRecs();">deactivate selected</a><FONT COLOR="FF0000">]</FONT></b>
				</CFIF>
			</td>
			<td width="590" align="right">
        <cfoutput>
          <cfif FORM.display eq "inActive">
            <strong>[ #qryGetInactivePgTypes.RecordCount# Records found ]</strong>
          <cfelse>
            <strong>[ #qryGetActivePgTypes.RecordCount# Records found ]</strong>
          </cfif>
        </cfoutput>
  		</td>
		</tr>
</TABLE>
<br>
  <cfif FORM.SORT_ORDER EQ "DESC">
	  <cfset  New_Sort_Order="ASC">
		<cfset sortImage="up_1.gif">
	<cfelse>
	  <cfset New_Sort_Order="DESC">
		<cfset sortImage="down_1.gif">
  </cfif>
<table width="720" border="0" cellpadding="1" cellspacing="0" class="MAINTABLE">
	<!---- HEAD ----->
	<cfoutput>
	<tr id="HEADER" bgcolor="##FFCE84">
		<td valign="top" width="2%">
			<input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'ChkPGTypeID');">
		</td>

		<td STYLE="font-size:11px;" width="10%" valign="top">
			<b><a href="##" OnClick="javaScript: return sortByThisItem(this,'PG_Type_Code','#New_Sort_Order#');">Type ID<cfif FORM.sort_by EQ "PG_Type_Code"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>
		<td STYLE="font-size:11px;" width="26%" valign="top">
			<b><a href="##" OnClick="javaScript: return sortByThisItem(this,'PG_Type_Name','#New_Sort_Order#');">Type Name<cfif FORM.sort_by EQ "PG_Type_Name"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>
 		<td STYLE="font-size:11px;" width="10%" valign="top">
			<b><a href="##" OnClick="javaScript: return sortByThisItem(this,'PG_Group_Type','#New_Sort_Order#');">Type Category<cfif FORM.sort_by EQ "PG_Group_Type"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>

		<!---FILTER: Add/Edit Business Rules and Profile Restriction--->
		<td align="center" width="10%" STYLE="font-size:11px;" valign="top">
		<B>
		<cfif FORM.display EQ "active">
			DeActivate
		<cfelse>
			Activate
		</cfif>&nbsp;</B></td>
		<td align="center" width="8%" STYLE="font-size:11px;" valign="top"><B>Delete</B></td>
 		<td align="center" width="5%" STYLE="font-size:11px;" valign="top"><B>Expand</B></td>
	</tr>
	</cfoutput>
		<!---check to see if we can delete this component--->
  <cfset  CURRENTROW = 1 />
  <cfsetting enablecfoutputonly="true" >
  <cfif (FORM.display EQ "active")>

    <cfif qryGetActivePgTypes.RecordCount EQ 0>
      <cfoutput><tr><td colspan="7" align="center"><strong>No active records!!</strong></td></tr></cfoutput>
    </cfif>

    <cfloop query="qryGetActivePgTypes">
      <cfif PG_Group_Type EQ "1">
        <cfset PGTypeCategory = application.returned_customer_setting.Item_Label />
      <cfelseif PG_Group_Type EQ "2">
        <cfset PGTypeCategory = application.returned_customer_setting.distributor_label_singular />
      <cfelseif PG_Group_Type EQ "3">
        <cfset PGTypeCategory = application.returned_customer_setting.Operator_Label_Singular  />
      </cfif>

      <cfif qryGetActivePgTypes.PG_Group_Type EQ 1>
        <cfset qryPGMembers = PGManager.fnGetProductPGByTypeID('#PG_Type_ID#')>
      <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 2>
        <cfset qryPGMembers = PGManager.fnGetCustomerPGByTypeID('#PG_Type_ID#')>
      <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 3>
        <cfset qryPGMembers = PGManager.fnGetOperatorPGByTypeID('#PG_Type_ID#')>
      </cfif>

      <cfset CURRENTROW =  CURRENTROW + 1 />
    	<cfoutput><tr <cfif CURRENTROW MOD 2>BGCOLOR="##CCFFCC"</CFIF> HEIGHT="21"></cfoutput>
    		<cfoutput><td width="10"><INPUT TYPE="checkbox" NAME="ChkPGTypeID" value="#qryGetActivePgTypes.Pg_Type_ID#"></td></cfoutput>
    		<cfoutput><td>#setupCodeLink(qryGetActivePgTypes.Pg_Type_ID, qryGetActivePgTypes.PG_Type_Code, qryGetActivePgTypes.Is_System)#&nbsp; <!---28269---></td></cfoutput>
    		<cfoutput><td>#setupNameLink(qryGetActivePgTypes.Pg_Type_ID, qryGetActivePgTypes.PG_Type_Name, qryGetActivePgTypes.Is_System)#&nbsp; <!---28269---></td></cfoutput>
        <cfoutput><td>#PGTypeCategory#</td></cfoutput>
        
  			<cfoutput><td TITLE="Deactivate" ALIGN="center"><center><cfif qryPGMembers.RecordCount EQ 0><a href="" onClick="javaScript: return deActivateType('#PG_Type_ID#');"><img src="/images/not_allowed.gif" TITLE="Deactivate #qryGetActivePgTypes.PG_Type_Name#" BORDER="0"></a><cfelse>NA</cfif></center></td></cfoutput>
        <cfoutput><td TITLE="Delete " ALIGN="center"><cfif qryPGMembers.RecordCount EQ 0><a href="" onClick="JavaScript: return deleteTypeRec('#PG_Type_ID#');"><img src="/images/no_small.gif" TITLE="Delete " BORDER="0"></a><cfelse>NA</cfif></td></cfoutput>
        <cfoutput><td align="center"><a href="##" onclick="fnDisplayRow('subGrp_#PG_Type_ID#','/images/collapse.png','/images/expand.png','image_#PG_Type_ID#');return false;"> <img id="image_#PG_Type_ID#" src="/images/expand.png" border="0"></a> </td></cfoutput>
      <cfoutput></tr></cfoutput>

      <cfoutput><tr id="subGrp_#PG_Type_ID#" style="display:none;"></cfoutput>
        <cfoutput><td>&nbsp;</td></cfoutput>
        <cfoutput><td colspan="100%"></cfoutput>
                    <cfif qryPGMembers.RecordCount EQ 0>
                      <cfoutput>No Members Found!!</cfoutput>
                    <cfelse>
                     <cfoutput><table bgcolor="##E1FCE0" borderColor="##800040" cellpadding="2" cellspacing="0" width="70%"><!--- dddddd ---></cfoutput>
                        <cfoutput><tr bgcolor="##73F170" width="30%"><!--- 737373 ---></cfoutput>
                          <cfoutput><td style="font-weight:bold;font-size:8pt;border-bottom:1px solid ##800040;border-left:1px solid ##800040;border-top:1px solid ##800040;"> <strong><font point-size="4"> #PGTypeCategory# PG Code </font></strong> </td></cfoutput>
                          <cfoutput><td style="font-weight:bold;font-size:8pt;border-bottom:1px solid ##800040;border-left:1px solid ##800040;border-top:1px solid ##800040;" width="45%"> <strong>#PGTypeCategory# PG Name</strong> </td></cfoutput>
                          <cfoutput><td style="font-weight:bold;font-size:8pt;border-bottom:1px solid ##800040;border-left:1px solid ##800040;border-top:1px solid ##800040;border-right:1px solid ##800040;" width="25%"> <strong>Include in Other PG</strong> </td></cfoutput>
                        <cfoutput></tr></cfoutput>
                        
                        <cfloop query="qryPGMembers">
                            <cfoutput><tr></cfoutput>
                              <cfoutput><td style="font-size:8pt;border-bottom:1px solid ##800040;border-left:1px solid ##800040;"></cfoutput>
                                          <cfif qryGetActivePgTypes.PG_Group_Type EQ 1>
                                            <cfoutput>#qryPGMembers.PG_Product_Category_Code#</cfoutput>
                                          <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 2>
                                            <cfoutput>#qryPGMembers.PG_Customer_Category_Code#</cfoutput>
                                          <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 3>
                                            <cfoutput>#qryPGMembers.PG_Operator_Category_Code#</cfoutput>
                                          </cfif><cfoutput>&nbsp;</cfoutput>
                              <cfoutput></td></cfoutput>
                              
                              <cfoutput><td style="font-size:8pt;border-bottom:1px solid ##800040;border-left:1px solid ##800040;"></cfoutput>
                                          <cfif qryGetActivePgTypes.PG_Group_Type EQ 1>
                                            <cfoutput>#qryPGMembers.PG_Product_Category_Name#</cfoutput>
                                          <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 2>
                                            <cfoutput>#qryPGMembers.PG_Customer_Category_Name#</cfoutput>
                                          <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 3>
                                            <cfoutput>#qryPGMembers.PG_Operator_Category_Name#</cfoutput>
                        	                </cfif><cfoutput>&nbsp;</cfoutput>
                              <cfoutput></td></cfoutput>
                              <cfoutput><td align="center" style="font-size:8pt;border-bottom:1px solid ##800040;border-left:1px solid ##800040;border-right:1px solid ##800040;"> <cfif qryPGMembers.Include_In_Other_PG EQ 1>Yes<cfelse>No</cfif></td></cfoutput>
                            <cfoutput></tr></cfoutput>
                        </cfloop>
                     <cfoutput></table></cfoutput>
                    </cfif>   <!---qryPGMembers.RecordCount EQ 0--->
        <cfoutput></td></cfoutput>
      <cfoutput></tr></cfoutput>
    </cfloop>    <!---query="qryGetActivePgTypes"--->

  <cfelse>  <!---FORM.display EQ "active"--->

    <cfif qryGetInActivePgTypes.RecordCount EQ 0>
      <cfoutput><tr><td colspan="7" align="center"><font size="2px"><strong>No inactive records!!</strong></font></td></tr></cfoutput>
    </cfif>

    <cfloop query="qryGetInActivePgTypes">
      <cfset CURRENTROW = CURRENTROW + 1 />
    	<cfoutput><tr <cfif CURRENTROW MOD 2>BGCOLOR="##CCFFCC"</CFIF> HEIGHT="21"></cfoutput>
    		<cfoutput><td width="10"><INPUT TYPE="checkbox" NAME="ChkPGTypeID" value="#qryGetInActivePgTypes.Pg_Type_ID#"></td></cfoutput>
    		<cfoutput><td>#qryGetInActivePgTypes.PG_Type_Code#&nbsp;<cfif qryGetInActivePgTypes.is_System eq 1>*</cfif></td></cfoutput>
     		<cfoutput><td>#PG_Type_Name#</td></cfoutput>

   			<cfif PG_Group_Type EQ "1">
          <cfset PGTypeCategory = application.returned_customer_setting.Item_Label />
        <cfelseif PG_Group_Type EQ "2">
          <cfset PGTypeCategory = application.returned_customer_setting.distributor_label_singular />
        <cfelseif PG_Group_Type EQ "3">
          <cfset PGTypeCategory = application.returned_customer_setting.Operator_Label_Singular  />
        </cfif>
        <cfoutput><td><cfif PG_Group_Type EQ "1">#application.returned_customer_setting.Item_Label#<cfelseif PG_Group_Type EQ "2">#application.returned_customer_setting.distributor_label_singular#<cfelseif PG_Group_Type EQ "3">Operator</cfif></td></cfoutput>
        
  			<cfoutput><td TITLE="Activate"   ALIGN="center"><a href="" onClick="JavaScript: return activateType('#PG_Type_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate " BORDER="0"></a></td></cfoutput>
        <cfoutput><td TITLE="Delete " ALIGN="center"><a href="" onClick="JavaScript: return deleteTypeRec('#PG_Type_ID#');"><img src="/images/no_small.gif" TITLE="Delete " BORDER="0"></a></td></cfoutput>
        <cfoutput><td align="center"><a href="##" onclick="fnDisplayRow('subGrp_#PG_Type_ID#','/images/collapse.png','/images/expand.png','image_#PG_Type_ID#');return false;"><img id="image_#PG_Type_ID#" src="/images/expand.png" border="0"></a></td></cfoutput>
      <cfoutput></tr></cfoutput>

      <cfif qryGetActivePgTypes.PG_Group_Type EQ 1>
        <cfset qryPGMembers = PGManager.fnGetProductPGByTypeID('#PG_Type_ID#')>
      <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 2>
        <cfset qryPGMembers = PGManager.fnGetCustomerPGByTypeID('#PG_Type_ID#')>
      <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 3>
        <cfset qryPGMembers = PGManager.fnGetOperatorPGByTypeID('#PG_Type_ID#')>
      </cfif>

      <cfoutput><tr id="subGrp_#PG_Type_ID#" style="display:none;"></cfoutput>
        <cfoutput><td>&nbsp;</td></cfoutput>
        <cfoutput><td colspan="100%"></cfoutput>
                  <cfif qryPGMembers.RecordCount EQ 0>
                    <cfoutput>No Members Found!!</cfoutput>
                  <cfelse>
                   <cfoutput><table bgcolor="##dddddd" border="1" borderColor="##800040" cellpadding="4" cellspacing="0"></cfoutput>
                      <cfoutput><tr bgcolor=##"737373"></cfoutput>
                        <cfoutput><td class="b8">#PGTypeCategory# PG Code</td></cfoutput>
                        <cfoutput><td class="b8">#PGTypeCategory# PG Name</td></cfoutput>
                        <cfoutput><td class="b8">Include in Other PG</td></cfoutput>
                      <cfoutput></tr></cfoutput>
                      
                      <cfloop query="qryPGMembers">
                      <cfoutput><tr></cfoutput>
                            <cfoutput><td></cfoutput>
                                          <cfif qryGetActivePgTypes.PG_Group_Type EQ 1>
                                            <cfoutput>#qryPGMembers.PG_Product_Category_Code#</cfoutput>
                                          <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 2>
                                            <cfoutput>#qryPGMembers.PG_Customer_Category_Code#</cfoutput>
                                          <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 3>
                                            <cfoutput>#qryPGMembers.PG_Operator_Category_Code#</cfoutput>
                                          </cfif><cfoutput>&nbsp;</cfoutput>
                            <cfoutput></td></cfoutput>
                            
                            <cfoutput><td></cfoutput>
                                         <cfif qryGetActivePgTypes.PG_Group_Type EQ 1>
                                          <cfoutput>#qryPGMembers.PG_Product_Category_Name#</cfoutput>
                                        <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 2>
                                          <cfoutput>#qryPGMembers.PG_Customer_Category_Name#</cfoutput>
                                        <cfelseif qryGetActivePgTypes.PG_Group_Type EQ 3>
                                          <cfoutput>#qryPGMembers.PG_Operator_Category_Name#</cfoutput>
                                        </cfif><cfoutput>&nbsp;</cfoutput>
                            <cfoutput></td></cfoutput>
                            <cfoutput><td align="center"> <cfif qryPGMembers.Include_In_Other_PG EQ 1>Yes<cfelse>No</cfif> </td></cfoutput>
                          <cfoutput></tr></cfoutput>
                      </cfloop>
                   <cfoutput></table></cfoutput>
                  </cfif>   <!---qryPGMembers.RecordCount EQ 0--->
        <cfoutput></td></cfoutput>
      <cfoutput></tr></cfoutput>
    </cfloop>    <!---query="qryGetInActivePgTypes"--->

  </cfif>    <!---FORM.display EQ "active"--->
  <cfsetting enablecfoutputonly="false" >
</TABLE>
* system planning group type