<!-----------------------------------------------------------------------------

FILE NAME:		_pg_operator_display.cfm
DESCRIPTION:
CREATED BY:		25-Jan-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  25-Jan-2010	Created the file
------------------------------------------------------------------------------>
<!--- <script src="/settings/component_product_restrictions/component_product_restriction.js"></script> --->
<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()> --->

<style type="text/css">
.b8 {font-weight:bold;font-size:8pt}
</style>
<cfparam name="FORM.sort_by" default="PG_Operator_Category_Name" />
<cfparam name="FORM.sort_Order" default="ASC" />

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="setupCodeLink" output="false" returntype="string">
  <cfargument name="IDElement"   required="true" type="string"   />
  <cfargument name="codeElement" required="true" type="string"   />
  <cfargument name="is_System"    required="true" type="numeric" />

  <cfset var vars = {}>
  <!---do not allow editing if entry is a system pg type--->
  <cfif arguments.is_System eq 1>
    <cfoutput><cfsavecontent variable="vars.result">#arguments.codeElement# *</cfsavecontent></cfoutput>
  <cfelse>
    <cfoutput><cfsavecontent variable="vars.result"><a href="##" onClick="JavaScript:return submitEdit('#arguments.IDElement#','Operator');"><strong>#arguments.codeElement#&nbsp;</strong></a></cfsavecontent></cfoutput>
  </cfif>

  <cfreturn vars.result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="setupNameLink" output="false" returntype="string">
  <cfargument name="IDElement"   required="true" type="string"   />
  <cfargument name="nameElement" required="true" type="string"   />
  <cfargument name="is_System"    required="true" type="numeric" />

  <cfset var vars = {}>
  <!---do not allow editing if entry is a system pg type--->
  <cfif arguments.is_System eq 1>
    <cfoutput><cfsavecontent variable="vars.result">#arguments.nameElement#</cfsavecontent></cfoutput>
  <cfelse>
    <cfoutput><cfsavecontent variable="vars.result"><a href="##" onClick="JavaScript:return submitEdit('#arguments.IDElement#','Operator');"><strong>#arguments.nameElement#</strong></a></cfsavecontent></cfoutput>
  </cfif>

  <cfreturn vars.result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfif !(FORM.sort_by EQ "PG_Operator_Category_Code" OR FORM.sort_by EQ "PG_Operator_Category_Name" OR FORM.sort_by EQ "PG_Type_Name" OR FORM.sort_by EQ "Include_In_Other_PG")>
  <cfset FORM.sort_by = "PG_Operator_Category_Name" />
</cfif>

<cfset qryGetActiveOperatorCategory   = PGManager.fnGetActiveOperatorCategory(FORM.sort_by,FORM.sort_Order) />
<cfset qryGetInActiveOperatorCategory = PGManager.fnGetInActiveOperatorCategory(FORM.sort_by,FORM.sort_Order) />
<cfoutput>
<table width="720" border="0" cellpadding="1" cellspacing="0">
	<tr>
			<td align="left" width="130" nowrap>
				<cfif FORM.display eq "inActive">
					<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javaScript: return activateSelOprRecs();">activate selected</a><FONT COLOR="##FF0000">]</FONT></b>
				<cfelse>
					<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javaScript: return deActivateSelOprRecs();">deactivate selected</a><FONT COLOR="##FF0000">]</FONT></b>
				</cfif>
			</td>
		<td width="590" align="right">
      <cfif FORM.display eq "inActive">
        <strong>[ #qryGetInActiveOperatorCategory.RecordCount# Records found ]</strong>
      <cfelse>
        <strong>[ #qryGetActiveOperatorCategory.RecordCount# Records found ]</strong>
      </cfif>
    </td>
	</tr>
</table>
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

	<tr id="HEADER" bgcolor="##FFCE84">
		<td valign="top" width="2%">
			<input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'chkPGOperatorCatID');">
		</td>
		<td STYLE="font-size:11px;" width="6%" valign="top">
			<b><a href="##" OnClick="javaScript: return sortByThisItem(this,'PG_Operator_Category_Code','#New_Sort_Order#');">PG Code<cfif FORM.sort_by EQ "PG_Operator_Category_Code"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>
		<td STYLE="font-size:11px;" width="12%" valign="top">
			<b><a href="##" OnClick="javaScript: return sortByThisItem(this,'PG_Operator_Category_Name','#New_Sort_Order#');">PG Name<cfif FORM.sort_by EQ "PG_Operator_Category_Name"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>
		<td STYLE="font-size:11px;" width="10%" valign="top">
			<b><a href="##" OnClick="javaScript: return sortByThisItem(this,'PG_Type_Name','#New_Sort_Order#');">PG Type<cfif FORM.sort_by EQ "PG_Type_Name"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>

		<td STYLE="font-size:11px;" width="10%" valign="top">
      <b><a href="##" OnClick="javaScript: return sortByThisItem(this,'Include_In_Other_PG','#New_Sort_Order#');">Include in other PG<cfif FORM.sort_by EQ "Include_In_Other_PG"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>


		<!---FILTER: Add/Edit Business Rules and Profile Restriction--->
		<td align="center" width="10%" STYLE="font-size:11px;" valign="top">
		<B>
		<cfif FORM.display EQ "active">
			DeActivate
		<cfelse>
			Activate
		</cfif>&nbsp;</B></td>
		<!--- Dev Note: drachala; D28611: PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID  START        
        Added/Changed: Added COPY Column--->
		<td STYLE="font-size:11px; width: 2%;" valign="top">
			<B>
			Copy
			</B>
		</td>
		<!--- End Dev Note: drachala; D28611: PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID  --->
		<td align="center" width="8%" STYLE="font-size:11px;" valign="top"><B>Delete</B></td>
 		<td align="center" width="5%" STYLE="font-size:11px;" valign="top"><B>Expand</B></td>
	</tr>
</cfoutput>

		<!---check to see if we can delete this component--->
<cfset  CURRENTROW = 1 />
<cfsetting enablecfoutputonly="true">
<cfif (FORM.display EQ "active")>

  <cfset iCounter = 1/>
  <cfif qryGetActiveOperatorCategory.RecordCount EQ 0>
    <tr><td colspan="8" align="center"><font size="2px"><strong>No active records!!</strong></font></td></tr>
  </cfif>

  <cfloop query="qryGetActiveOperatorCategory">


	  <cfoutput><tr <CFIF CURRENTROW MOD 2>BGCOLOR="##CCFFCC"</CFIF> HEIGHT="21"></cfoutput>
  		<cfoutput><td width="10"><input type="checkbox" name="chkPGOperatorCatID" value="''#qryGetActiveOperatorCategory.PG_Operator_Category_ID#''"></td></cfoutput>

      <cfoutput><td>#setupCodeLink(qryGetActiveOperatorCategory.PG_Operator_Category_ID, qryGetActiveOperatorCategory.PG_Operator_Category_Code, qryGetActiveOperatorCategory.Is_System)#</td></cfoutput>
      <cfoutput><td>#setupNameLink(qryGetActiveOperatorCategory.PG_Operator_Category_ID, qryGetActiveOperatorCategory.PG_Operator_Category_Name, qryGetActiveOperatorCategory.Is_System)#</td></cfoutput>

      <cfoutput><td><cfif qryGetActiveOperatorCategory.PG_Type_Name EQ "">&nbsp;<cfelse>#qryGetActiveOperatorCategory.PG_Type_Name#</cfif></td></cfoutput>
  		<cfoutput><td align="center"><cfif (qryGetActiveOperatorCategory.Include_In_Other_PG EQ 1)><img src="/images/Yes_small.gif"><cfelse><img src="/images/No_small.gif"></cfif></td></cfoutput>

      <cfoutput><td TITLE="Deactivate"   ALIGN="center"><center></cfoutput>
                  
      <cfoutput><a href="javascript:onclick=ColdFusion.navigate('planning_groups_display.cfm?PG_Operator_Category_ID=#qryGetActiveOperatorCategory.PG_Operator_Category_ID#&PG_Deactivate=1','groups_#iCounter#')"><img src="/images/not_allowed.gif" TITLE="Deactivate #qryGetActiveOperatorCategory.PG_Operator_Category_Name#" BORDER="0"></a></cfoutput>
                  
      <cfoutput></center></cfoutput>
      
      <cfoutput></td></cfoutput>
<!--- Dev Note: drachala; D28611: PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID  START 
Added/Changed: Added COPY ICON with JAVASCRIPT FUNCTION--->
     <cfoutput>
	 	 <td>
        	 <a HREF="##" onClick="javaScript: return CopySelProdRecs('#qryGetActiveOperatorCategory.PG_Operator_Category_ID#', 'Operator', 'ACTIVE');"><img src="/images/copy.png" border="0"></a>
		</td>
	</cfoutput>
<!--- End Dev Note: drachala; D28611:PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID --->
      <cfoutput><td TITLE="Delete " ALIGN="center"></cfoutput>
                  
      <cfoutput><a href="javascript:onclick=ColdFusion.navigate('planning_groups_display.cfm?PG_Operator_Category_ID=#qryGetActiveOperatorCategory.PG_Operator_Category_ID#&PG_Delete=1','groups_#iCounter#')"><img src="/images/no_small.gif" TITLE="Delete " BORDER="0"></a></cfoutput>

      <cfoutput></td></cfoutput>

      <cfoutput><td align="center"></cfoutput>
          <cfoutput><a href="javascript:onclick=ColdFusion.navigate('planning_groups_display.cfm?PG_Operator_Category_ID=#qryGetActiveOperatorCategory.PG_Operator_Category_ID#&PG_Display=1','groups_#iCounter#');fnDisplayRow('subGrp_#iCounter#','/images/collapse.png','/images/expand.png','image_#iCounter#');"><img id="image_#iCounter#" src="/images/expand.png" border="0"></a></cfoutput>
      <cfoutput></td></cfoutput>
    <cfoutput></tr></cfoutput>

<cfoutput><tr id="subGrp_#iCounter#" style="display:none;"></cfoutput>
	<cfoutput><td colspan="100%"><cfdiv id="groups_#iCounter#"/> </td></cfoutput>
<cfoutput></tr></cfoutput>
    
    <cfset iCounter = iCounter + 1 />
    <cfset CURRENTROW =  CURRENTROW + 1 />
  </cfloop>

<cfelse>            <!---FORM.display EQ "active"--->

  <cfset iCounter = 1/>
  <cfif qryGetInActiveOperatorCategory.RecordCount EQ 0>
    <cfoutput><tr><td colspan="8" align="center"><font size="2px"><strong>No inactive records!!</strong></font></td></tr></cfoutput>
  </cfif>

  <cfloop query="qryGetInActiveOperatorCategory">

  	<cfoutput><tr <CFIF CURRENTROW MOD 2>BGCOLOR="##CCFFCC"</CFIF> HEIGHT="21"></cfoutput>
      <cfset CURRENTROW = CURRENTROW + 1 />
  		<cfoutput><td width="10"><input  type="checkbox" name="chkPGOperatorCatID" value="''#qryGetInActiveOperatorCategory.PG_Operator_Category_ID#''"></td></cfoutput>
   	 	<cfoutput><td><strong>#qryGetInActiveOperatorCategory.PG_Operator_Category_Code#</strong>&nbsp;</td></cfoutput>

  		<cfoutput><td><strong>#qryGetInActiveOperatorCategory.PG_Operator_Category_Name#</strong>&nbsp;</td></cfoutput>
      <cfoutput><td>#qryGetInActiveOperatorCategory.PG_Type_Name#</td></cfoutput>

  		<cfoutput><td align="center"></cfoutput>
        <cfif (qryGetInActiveOperatorCategory.Include_In_Other_PG EQ 1)>
          <cfoutput><img src="/images/Yes_small.gif"></cfoutput>
        <cfelse>
          <cfoutput><img src="/images/No_small.gif"></cfoutput>
        </cfif>
  		<cfoutput></td></cfoutput>

	  <cfoutput><td TITLE="Activate" ALIGN="center"><a href="##" onClick="JavaScript: return activateOperatorRec('#qryGetInActiveOperatorCategory.PG_Operator_Category_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate #qryGetInActiveOperatorCategory.PG_Operator_Category_Name#" BORDER="0"></a></td></cfoutput>
 <!--- Dev Note: drachala; D28611: PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID  START 
Added/Changed: Added COPY ICON with JAVASCRIPT FUNCTION--->
     <cfoutput>
	 	 <td>
        	 <a HREF="##" onClick="javaScript: return CopySelProdRecs('#qryGetActiveOperatorCategory.PG_Operator_Category_ID#', 'Operator', 'INACTIVE');"><img src="/images/copy.png" border="0"></a>
		</td>
	</cfoutput>
<!--- End Dev Note: drachala; D28611:PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID --->
         
      <cfoutput><td TITLE="Delete " ALIGN="center"><a href="" onClick="JavaScript: return deleteOperatorRec('#qryGetInActiveOperatorCategory.PG_Operator_Category_ID#');"><img src="/images/no_small.gif" TITLE="Delete " BORDER="0"></a></td></cfoutput>
      <cfoutput><td align="center"></cfoutput>
        <cfoutput><a href="javascript:onclick=ColdFusion.navigate('planning_groups_display.cfm?PG_Operator_Category_ID=#qryGetInActiveOperatorCategory.PG_Operator_Category_ID#&PG_Display=1','groups_#iCounter#');fnDisplayRow('subGrp_#iCounter#','/images/collapse.png','/images/expand.png','image_#iCounter#');"><img id="image_#iCounter#" src="/images/expand.png" border="0"></a></cfoutput>
      <cfoutput></td></cfoutput>
    <cfoutput></tr></cfoutput>

<cfoutput><tr id="subGrp_#iCounter#" style="display:none;"></cfoutput>
	<cfoutput><td colspan="100%"><cfdiv id="groups_#iCounter#"/> </td></cfoutput>
<cfoutput></tr></cfoutput>

    <cfset iCounter = iCounter + 1 />
  </cfloop>
</cfif>              <!---FORM.display EQ "active"--->
<cfsetting enablecfoutputonly="false">

</TABLE>
* system planning group <cfoutput>#lcase(application.returned_customer_setting.Operator_Label_Singular)#</cfoutput>

 <input type="hidden" name="PGOperatorCatID" value="" />