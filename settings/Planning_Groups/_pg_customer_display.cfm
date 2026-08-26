<!-----------------------------------------------------------------------------

FILE NAME:		_pg_customer_display.cfm
DESCRIPTION:
CREATED BY:		09-Sep-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  09-Sep-2010	Created the file
------------------------------------------------------------------------------>

<script src="/settings/component_product_restrictions/component_product_restriction.js"></script>
<style type="text/css">
.b8 {font-weight:bold;font-size:8pt}
</style>

<cfparam name="FORM.sort_by" default="PG_Customer_Category_Name" />
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
    <cfoutput><cfsavecontent variable="vars.result"><a href="##" onClick="JavaScript:return submitEdit('#arguments.IDElement#','Customer');"><strong>#arguments.codeElement#&nbsp;</strong></a></cfsavecontent></cfoutput>
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
    <cfoutput><cfsavecontent variable="vars.result"><a href="##" onClick="JavaScript:return submitEdit('#arguments.IDElement#','Customer');"><strong>#arguments.nameElement#</strong></a></cfsavecontent></cfoutput>
  </cfif>

  <cfreturn vars.result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfif !(FORM.sort_by EQ "PG_Customer_Category_Code" OR FORM.sort_by EQ "PG_Customer_Category_Name" OR FORM.sort_by EQ "PG_Type_Name" OR FORM.sort_by EQ "Include_In_Other_PG" OR FORM.sort_by EQ "Business_Unit_Desc")>
  <cfset FORM.sort_by = "PG_Customer_Category_Name" />
</cfif>

<cfset qryGetActiveCustomerCategory   = PGManager.fnGetActiveCustomerCategory(FORM.sort_by,FORM.sort_Order) />
<cfset qryGetInActiveCustomerCategory = PGManager.fnGetInActiveCustomerCategory(FORM.sort_by,FORM.sort_Order) />

<cfoutput>
<table width="720" border="0" cellpadding="1" cellspacing="0">
	<tr>
			<td align="left" width="130" nowrap>
				<cfif FORM.display eq "inActive">
					<B><FONT COLOR="FF0000">[</FONT><a HREF="##" onClick="javaScript: return activateSelCustomerRecs();">activate selected</a><FONT COLOR="FF0000">]</FONT></b>
				<cfelse>
					<B><FONT COLOR="FF0000">[</FONT><a HREF="##" onClick="javaScript: return deActivateSelCustomerRecs();">deactivate selected</a><FONT COLOR="FF0000">]</FONT></b>
				</cfif>
			</td>
		<td width="590" align="right">
    <cfif FORM.display eq "inActive">
      <strong>[ #qryGetInActiveCustomerCategory.RecordCount# Records found ]</strong>
    <cfelse>
      <strong>[ #qryGetActiveCustomerCategory.RecordCount# Records found ]</strong>
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
			<input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'chkPGCustomerCatID');">
		</td>
		<td STYLE="font-size:11px;" width="6%" valign="top">
			<b><a href="##" OnClick="javaScript: return sortByThisItem(this,'PG_Customer_Category_Code','#New_Sort_Order#');">PG Code<cfif FORM.sort_by EQ "PG_Customer_Category_Code"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>
		<td STYLE="font-size:11px;" width="12%" valign="top">
			<b><a href="##" OnClick="javaScript: return sortByThisItem(this,'PG_Customer_Category_Name','#New_Sort_Order#');">PG Name<cfif FORM.sort_by EQ "PG_Customer_Category_Name"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>
		<td STYLE="font-size:11px;" width="10%" valign="top">
			<b><a href="##" OnClick="javaScript: return sortByThisItem(this,'PG_Type_Name','#New_Sort_Order#');">PG Type<cfif FORM.sort_by EQ "PG_Type_Name"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>



   <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->
<cfif isBusinessSegEnabledForDistributor>
 		<td STYLE="font-size:11px;" width="10%" valign="top">
			<b><a href="##" OnClick="javaScript: return sortByThisItem(this,'Business_Unit_Desc','#New_Sort_Order#');">#appSettings.getbusiness_segment_label()#<cfif FORM.sort_by EQ "Business_Unit_Desc"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>
</cfif>
   <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->

		<td STYLE="font-size:11px;" width="10%" valign="top">
      <b><a href="##" OnClick="javaScript: return sortByThisItem(this,'Include_In_Other_PG','#New_Sort_Order#');">Include in other PG<cfif FORM.sort_by EQ "Include_In_Other_PG"> <img border="0" src="/Images/#sortImage#"></cfif></a></b>
		</td>


		<!--- FILTER: Add/Edit Business Rules and Profile Restriction --->
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
<cfsetting enablecfoutputonly="true" >
<cfif (FORM.display EQ "active")>

  <cfset iCounter = 1/>
  <cfif qryGetActiveCustomerCategory.RecordCount EQ 0>
    <cfoutput><tr><td colspan="10" align="center"><font size="2px"><strong>No active records!!</strong></font></td></tr></cfoutput>
  </cfif>

  <cfloop query="qryGetActiveCustomerCategory">
   
  	<cfoutput><tr <CFIF CURRENTROW MOD 2>BGCOLOR="##CCFFCC"</CFIF> HEIGHT="21"></cfoutput>
  		<cfoutput><td width="10"><input type="checkbox" name="chkPGCustomerCatID" value="''#qryGetActiveCustomerCategory.PG_Customer_Category_ID#''"></td></cfoutput>
      <cfoutput><td>#setupCodeLink(qryGetActiveCustomerCategory.PG_Customer_Category_ID, qryGetActiveCustomerCategory.PG_Customer_Category_Code, qryGetActiveCustomerCategory.Is_System)#</td></cfoutput>
      
      <cfoutput><td>#setupNameLink(qryGetActiveCustomerCategory.PG_Customer_Category_ID, qryGetActiveCustomerCategory.PG_Customer_Category_Name, qryGetActiveCustomerCategory.Is_System)#</td></cfoutput>
      <cfoutput><td><cfif qryGetActiveCustomerCategory.PG_Type_Name EQ "">&nbsp;<cfelse>#qryGetActiveCustomerCategory.PG_Type_Name#</cfif></td></cfoutput>

  	  <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->
  	  <cfif isBusinessSegEnabledForDistributor>
  	  <cfoutput><td>&nbsp;<cfif len(qryGetActiveCustomerCategory.Business_Unit_Desc) GT 0>#qryGetActiveCustomerCategory.Business_Unit_Desc#<cfelse>N/A</cfif></td></cfoutput>
	  </cfif>
  	  <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->

  		<cfoutput><td align="center"></cfoutput>
        <cfif (qryGetActiveCustomerCategory.Include_In_Other_PG EQ 1)>
          <cfoutput><img src="/images/Yes_small.gif"></cfoutput>
        <cfelse>
          <cfoutput><img src="/images/No_small.gif"></cfoutput>
        </cfif>
  		<cfoutput></td></cfoutput>
  		
			<cfoutput><td TITLE="Deactivate"   ALIGN="center"><center>  <a href="javascript:onclick=ColdFusion.navigate('planning_groups_display.cfm?PG_Customer_Category_ID=#qryGetActiveCustomerCategory.PG_Customer_Category_ID#&PG_Deactivate=1','groups_#iCounter#')"><img src="/images/not_allowed.gif" TITLE="Deactivate #qryGetActiveCustomerCategory.PG_Customer_Category_Name#" BORDER="0"></a></center></td></cfoutput>
<!--- Dev Note: drachala; D28611: PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID  START 
Added/Changed: Added COPY ICON with JAVASCRIPT FUNCTION---> 
     <cfoutput>
	 	 <td>
        	 <a HREF="##" onClick="javaScript: return CopySelProdRecs('#qryGetActiveCustomerCategory.PG_Customer_Category_ID#', 'Distributor', 'ACTIVE');"><img src="/images/copy.png" border="0"></a>
		</td>
	</cfoutput>
  <!--- End Dev Note: drachala; D28611:PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID --->   
     
      <cfoutput><td TITLE="Delete " ALIGN="center"><a href="javascript:onclick=ColdFusion.navigate('planning_groups_display.cfm?PG_Customer_Category_ID=#qryGetActiveCustomerCategory.PG_Customer_Category_ID#&PG_Delete=1','groups_#iCounter#')"><img src="/images/no_small.gif" TITLE="Delete " BORDER="0"></a></td></cfoutput>
      <cfoutput><td align="center"><a href="javascript:onclick=ColdFusion.navigate('planning_groups_display.cfm?PG_Customer_Category_ID=#qryGetActiveCustomerCategory.PG_Customer_Category_ID#&PG_Display=1','groups_#iCounter#');fnDisplayRow('subGrp_#iCounter#','/images/collapse.png','/images/expand.png','image_#iCounter#');"><img id="image_#iCounter#" src="/images/expand.png" border="0"></a></td></cfoutput>
    <cfoutput></tr></cfoutput>

<cfoutput><tr id="subGrp_#iCounter#" style="display:none;"></cfoutput>
	<cfoutput><td colspan="100%"><cfdiv id="groups_#iCounter#"/> </td></cfoutput>
<cfoutput></tr></cfoutput>

    <cfset iCounter = iCounter + 1 />
    <cfset CURRENTROW =  CURRENTROW + 1 />
  </cfloop>

<cfelse>    <!---(FORM.display EQ "active")--->

  <cfset iCounter = 1/>
  <cfif qryGetInActiveCustomerCategory.RecordCount EQ 0>
    <cfoutput><tr><td colspan="8" align="center"><font size="2px"><strong>No inactive records!!</strong></font></td></tr></cfoutput>
  </cfif>

  <cfloop query="qryGetInActiveCustomerCategory">
<!---    <cfstoredproc procedure="Get_Customer_Group_Info_For_PG" datasource="#application.datasource#">
    	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@PG_Customer_Category_ID" value = "#qryGetInActiveCustomerCategory.PG_Customer_Category_ID#" null="no">
      <cfprocresult name="qryPGCustomerCategoryDefinitionByID">
    </cfstoredproc>--->
  	<cfoutput><tr <CFIF CURRENTROW MOD 2>BGCOLOR="##CCFFCC"</CFIF> HEIGHT="21"></cfoutput>
      <cfset CURRENTROW = CURRENTROW + 1 />
  		<cfoutput><td width="10"><input  type="checkbox" name="chkPGCustomerCatID" value="''#qryGetInActiveCustomerCategory.PG_Customer_Category_ID#''"></td></cfoutput>
   	 	<cfoutput><td><strong>#qryGetInActiveCustomerCategory.PG_Customer_Category_Code#</strong>&nbsp;<cfif qryGetInActiveCustomerCategory.is_System eq 1>*</cfif></td></cfoutput>
   	 	
  		<cfoutput><td><strong>#qryGetInActiveCustomerCategory.PG_Customer_Category_Name#</strong>&nbsp;</td></cfoutput>
      <cfoutput><td>#qryGetInActiveCustomerCategory.PG_Type_Name#</td></cfoutput>
      <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->
	  	<cfif isBusinessSegEnabledForDistributor>
  	  <cfoutput><td><cfif len(qryGetInActiveCustomerCategory.Business_Unit_Desc) GT 0>#qryGetInActiveCustomerCategory.Business_Unit_Desc#<cfelse>N/A</cfif></td></cfoutput>
		  </cfif>
      <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->

  		<cfoutput><td align="center"></cfoutput>
        <cfif (qryGetInActiveCustomerCategory.Include_In_Other_PG EQ 1)>
          <cfoutput><img src="/images/Yes_small.gif"></cfoutput>
        <cfelse>
          <cfoutput><img src="/images/No_small.gif"></cfoutput>
        </cfif>
  		<cfoutput></td></cfoutput>

	  <cfoutput><td TITLE="Activate"   ALIGN="center"><a href="##" onClick="JavaScript: return activateCustomerRec('#qryGetInActiveCustomerCategory.PG_Customer_Category_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate #qryGetInActiveCustomerCategory.PG_Customer_Category_Name#" BORDER="0"></a></td></cfoutput>
     
     
     
<!--- Dev Note: drachala; D28611: PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID  START 
Added/Changed: Added COPY ICON with JAVASCRIPT FUNCTION---> 
     <cfoutput>
	 	 <td>
        	 <a HREF="##" onClick="javaScript: return CopySelProdRecs('#qryGetActiveCustomerCategory.PG_Customer_Category_ID#', 'Distributor', 'INACTIVE');"><img src="/images/copy.png" border="0"></a>
		</td>
	</cfoutput>
<!--- End Dev Note: drachala; D28611:PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID --->   
  
     
     
     
      <cfoutput><td TITLE="Delete " ALIGN="center"><a href="##" onClick="JavaScript: return deleteCustomerRec('#qryGetInActiveCustomerCategory.PG_Customer_Category_ID#');"><img src="/images/no_small.gif" TITLE="Delete " BORDER="0"></a></td></cfoutput>
      <cfoutput><td align="center"><a href="javascript:onclick=ColdFusion.navigate('planning_groups_display.cfm?PG_Customer_Category_ID=#qryGetInActiveCustomerCategory.PG_Customer_Category_ID#&PG_Display=1','groups_#iCounter#');fnDisplayRow('subGrp_#iCounter#','/images/collapse.png','/images/expand.png','image_#iCounter#');"><img id="image_#iCounter#" src="/images/expand.png" border="0"></a></td></cfoutput>
    <cfoutput></tr></cfoutput>

<cfoutput><tr id="subGrp_#iCounter#" style="display:none;"></cfoutput>
	<cfoutput><td colspan="100%"><cfdiv id="groups_#iCounter#"/> </td></cfoutput>
<cfoutput></tr></cfoutput>

    <cfset iCounter = iCounter + 1 />
  </cfloop>

</cfif> <!---(FORM.display EQ "active")--->
<cfsetting enablecfoutputonly="false" >
</TABLE>
* system planning group <cfoutput>#lcase(application.returned_customer_setting.Distributor_Label_Singular)#</cfoutput>

 <input type="hidden" name="PGCustomerCatID" value="" />