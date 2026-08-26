<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\products.cfm
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:  Add/Edit product planning groups for an accrual budget
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="form.prodpg_list" default="">
<cfparam name="form.ExistingProductList" default="">
<cfparam name="form.cutProducts" default="">
<cfparam name="form.deleted" default="">
<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/impromptu.css">
<style type="text/css">
.action { font-weight:bold; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<cfquery name="qBudget" datasource="#application.datasource#">
    SELECT Budget_desc
           , Budget_Code
           , Recapture
           , Corporate_And_Local_Rate
           , Overlays
           , Business_segment_id
      FROM Budget
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>
<cfscript>
   form.Budget_Code = qBudget.Budget_Code;
   form.Budget_desc = qBudget.Budget_desc;
</cfscript>

<cfif form.clicked_save eq "1">
  <cfset save_prodpg()>
  <!---is Recaptures tab needed?--->
  <cfset editRecaptures = 0>
  <cfloop from="1" to="#ArrayLen(request.menus)#" index="cnt">
    <cfif request.menus[cnt].text eq "advanced">
      <cfset editRecaptures = 1>
    </cfif>
  </cfloop>
  <!---if recaptures tab is disabled go to templates tab--->
  <cfif (editRecaptures eq 0)>
   <script type="text/javascript">
  	document.forms[budget_form].command.value = "listAdjustments";   /*32147*/
    document.forms[budget_form].submit();
   </script>
  </cfif>
  <!---otherwise just go to recaptures tab--->
  <script type="text/javascript">
    <!---place the next tab command here--->
    document.forms[budget_form].command.value = "editRecaptures";
    <!---turn loading from db flag on for next tab--->
    document.forms[budget_form].load_fromdb.value  = "1";
    <!---close this page--->
    document.forms[budget_form].submit();
  </script>
</cfif>

<div style="margin:0px">   <!---fieldset--->
<fieldset id="mainfieldset" style="padding:1%; width:98%; border:1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Products</legend>

<CF_MessageWindow>

<cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<!---do not move this function call before the qBudget query, it needs to use it--->
<cfif form.load_fromdb eq "1">
  <cfset load_prodpg()>
</cfif>

<cfset useLakebaseForqUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_units_of_measure")>
<cfif useLakebaseForqUOM>
	<cftry>
		<cfset qUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_units_of_measure", {
				"deleted" = "eq.0",
				"select" = "budget_units_of_measure_id,unit_of_measure_abbreviation"
			}), "budget_units_of_measure_id,unit_of_measure_abbreviation"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUOM>
<cfquery name="qUOM" datasource="#application.datasource#">
    SELECT   Budget_Units_of_Measure_ID
           , Unit_Of_Measure_Abbreviation
      FROM Budget_Units_of_Measure
     WHERE Deleted = 0
</cfquery>
</cfif>
<cfscript>
  main = {};
  elements = {};
  form.Budget_Code = qBudget.Budget_Code;
  form.Budget_desc = qBudget.Budget_desc;
</cfscript>

<!--- form.prodpg_list = comma-delimited list of all selected product planning groups --->
<cfquery name="qGroups" Datasource="#application.datasource#">
  SELECT pgt.pg_Type_Id
         , pgt.pg_Type_Code
         , pgt.pg_Type_Name
         , pg_Product_Category_Id     AS Category_ID
         , pg_Product_Category_Code   AS Category_Code
         , pg_Product_Category_Name   AS Category_Name
    FROM pg_Product_Category pgcc
         INNER JOIN pg_type pgt ON pgcc.pg_Type_Id = pgt.pg_Type_Id
   WHERE <cfif Len(form.prodpg_list)>
           pg_Product_Category_Id IN ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.prodpg_list#" list="true"> )
         <cfelse>
           1 = 0
         </cfif>
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->

<!--- <div style="margin-top:5px" >  <!---display heading--->
<table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr>
    <td><font size=2>Code: <b>#form.budget_code#</b></font></td>
    <td align=right><font size=2>Budget Description: <b>#form.budget_desc#</b></font></td>
  </tr>
</table>
<hr width=100%/>
</div>    <!---heading--->
 --->

<cfinclude template="displayBudgetHeading.cfm">
<cfset displayBudgetHeading( form.Budget_Id )>

<!----- add distributor link & datagrid ----->
<div style="margin:5px 0 0px">
<CFIF Get_Profile_Settings.Create_Budget eq 0 >
  #LCase(ActionText("add product planning groups"))#
  #LCase(ActionText("save"))#
<CFELSE>
  <a href="javascript:add_prodpg()">#LCase(ActionText("add product planning groups"))#</a>
  <a href="javascript:save_prodpg()" style="margin-left:10px">#LCase(ActionText("save"))#</a>
</CFIF>
<a href="javascript:getCSVData()" style="margin-left:10px">#LCase(ActionText("Export Base Rate"))#</a>
<a href="javascript:window.location='index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#
'" style="margin-left:10px">#LCase(ActionText("return to budgets list"))#</a>
</div>

<cfscript>
  main.disabled_columns = 0;
  if ( qBudget.Recapture eq 0 )
    main.disabled_columns = main.disabled_columns + 1;
  if ( qBudget.Corporate_And_Local_Rate eq 0 )
    main.disabled_columns = main.disabled_columns + 1;
  if ( qBudget.Overlays eq 0 )
    main.disabled_columns = main.disabled_columns + 2;
</cfscript>

<!----- styles for datagrid ----->
<style>
.uom {
  <cfif main.disabled_columns eq 0>width: 63px;</cfif>
  margin-left: <cfif main.disabled_columns>10px<cfelse>2px</cfif>;
}
.mid {
  text-align: center;
}
td.mid {
  align: center;
}
</style>
</cfoutput>


<div style="width:100%;margin-top:10px;clear:both">   <!---datagrid--->
<table class="datagrid" id="groupgrid">
<cfsetting enablecfoutputonly="true" >
<cfoutput><thead></cfoutput>
<cfoutput><tr>
<th><nobr><img id="scissorAllProd" bDelete="true" sMessage="delete all products" src="/images/scissor.gif" title="delete all products" border="0"
                     onclick="javascript:deleteAllProductOptions();"
                     style="cursor: pointer;">
					 <input name="prodCheck" type="checkbox" onClick="checkAllProd()" checked></nobr>
					 </th>
</cfoutput>

 <cfoutput><th>Product Planning Group</th></cfoutput>
 <cfoutput><th class="mid">Base Rate</th></cfoutput>
 <cfoutput><!---conditional column:---><cfif qBudget.Recapture eq 1><th class="mid">Recapture Rate</th></cfif></cfoutput>
 <cfoutput><!---conditional column:---><cfif qBudget.Corporate_And_Local_Rate eq 1><th class="mid">Corp Rate</th></cfif></cfoutput>
 <cfoutput><!---overlay conditional column:---><cfif qBudget.Overlays eq 1><th class="mid">Include Overlay?</th></cfif></cfoutput>
 <cfoutput><!---conditional column:---><cfif qBudget.Overlays eq 1><th class="mid">Overlay Purchase Min</th></cfif></cfoutput>
<!---  <cfoutput><th class="csvExclude">Action</th></cfoutput> --->
 <cfoutput><th class="csvExclude">Members</th></cfoutput>
<cfoutput></tr></cfoutput>
<cfoutput></thead></cfoutput>
<cfoutput><tbody></cfoutput>
<cfloop query="qGroups">
<!---define the unique form element names to use for all inputs in the data grid--->
<cfset set_elements( qGroups.Category_ID )>
<!---assign default values to inputs in case they don't exist--->
<cfparam name="form['#elements.base#']"    default="0">   <cfparam name="form['#elements.baseUOM#']"  default="32">  <!---%Net$--->
<cfparam name="form['#elements.recap#']"   default="0">   <cfparam name="form['#elements.recapUOM#']" default="32">  <!---%Net$--->
<cfparam name="form['#elements.corp#']"    default="0">   <cfparam name="form['#elements.corpUOM#']"  default="32">  <!---%Net$--->
<cfparam name="form['#elements.incl#']"    default="0">
<cfparam name="form['#elements.overlay#']" default="0">   <cfparam name="form['#elements.overlayUOM#']" default="42">
<!---display inputs in the data grid--->
<cfoutput><tr id="#qGroups.CurrentRow#"></cfoutput>
<cfoutput>
		<td>
		<CFIF Get_Profile_Settings.Create_Budget eq 0 >
				<span class="imgDeleteScissor">
	            	<img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif"
	                	title="click here to delete this product" border="0"
	                    style="cursor: pointer;">
				</span>  
		<cfelse>
				<span class="imgDeleteScissor">
	            	<img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif"
	                	title="click here to delete this product" border="0"
	                    onclick="deleteProductPG('#qGroups.CurrentRow#','#qGroups.Category_ID#')"
	                    style="cursor: pointer;">
				</span>  
		</cfif>		
				
				<input name="prodChkBx_#qGroups.CurrentRow#" type="checkbox" value="#qGroups.CurrentRow#" tabindex="-1" checked>
		</td>										 
</cfoutput>
<cfoutput><td>#qGroups.Category_Name#</td></cfoutput>
<cfoutput><!---base rate:---><td class="mid combo"><input name="#elements.base#" value="#form[elements.base]#" class="rate" type="text" size="7"><select name="#elements.baseUOM#"  class=uom>#uom_options(form[elements.baseUOM])#</select></td></cfoutput>
<cfoutput><!---recapture rate conditional column:---><cfif qBudget.Recapture eq 1><td class="mid combo"><input name="#elements.recap#" value="#form[elements.recap]#" class="rate" type="text" size="7"><select name="#elements.recapUOM#" class=uom>#uom_options(form[elements.recapUOM])#</select></td></cfif></cfoutput>
<cfoutput><!---corp rate conditional column:---><cfif qBudget.Corporate_And_Local_Rate eq 1><td class="mid combo"><input name="#elements.corp#" value="#form[elements.corp]#" class="rate" type="text" size="7"><select name="#elements.corpUOM#"  class=uom>#uom_options(form[elements.corpUOM])#</select></td></cfif></cfoutput>
<cfoutput><!---overlay conditional column:---><cfif qBudget.Overlays eq 1><td class="mid combo"><input name="#elements.incl#" id="#elements.incl#" type="checkbox" <cfif form[elements.incl] eq '1'>checked=yes</cfif> onclick="overlay_min( this );"></td></cfif></cfoutput>
<cfoutput><!---overlay conditional column:---><cfif qBudget.Overlays eq 1><td class="mid combo"><input name="#elements.overlay#" value="#form[elements.overlay]#" class="rate orate" type="text" size="7" <cfif form[elements.incl] eq '0'>disabled=disabled</cfif>><select name="#elements.overlayUOM#" <cfif form[elements.incl] eq '0'>disabled=yes</cfif> class="uom ouom">#uom_options(form[elements.overlayUOM],false)#</select></td></cfif></cfoutput>
<!--- <cfoutput><td class="rowid csvExclude" id=#qGroups.Category_ID#><CFIF Get_Profile_Settings.Create_Budget eq 0 >#ActionText("delete")#<CFELSE><a href="javascript:deleteProductPG('#qGroups.CurrentRow#','#qGroups.Category_ID#')" class="action">#ActionText("delete")#</a></CFIF></td></cfoutput> --->
<cfoutput><td class="rowid csvExclude">&nbsp;<a href="##" onclick="javascript:fnViewMicroMembers(1,'#qGroups.Category_ID#','');"><img src="/images/on_the_program_item.gif" border="0"></a></td></cfoutput>
<cfoutput></tr></cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false" >
</tbody>
</table>
</div>  <!---datagrid--->
</fieldset>
</div>   <!---fieldset--->

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="load_prodpg" output="false">
  <cfset var vars = {}>

  <cfquery name="vars.groups" datasource="#application.datasource#">
      SELECT *
        FROM Budget_Product_Rate
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfset form.prodpg_list = ValueList(vars.groups.Product_Group_ID)>

  <cfoutput query="vars.groups">
    <cfscript>
      // determine the form element names for this row
      set_elements( vars.groups.product_group_id );

      // populate form elements with values from database
      form[elements.base]    = vars.groups.Rate;
      form[elements.baseUOM] = vars.groups.Rate_UOM;

      // only load if the setting is turned on so old values will be saved as zeroes
      if ( qBudget.Recapture eq 1 ) {
        form[elements.recap]    = vars.groups.Recapture_Rate;
        form[elements.recapUOM] = vars.groups.Recapture_Rate_UOM;
      }

      // only load if the setting is turned on so old values will be saved as zeroes
      if ( qBudget.Corporate_And_Local_Rate ) {
        form[elements.corp]    = vars.groups.Corporate_Rate;
        form[elements.corpUOM] = vars.groups.Corporate_Rate_UOM;
      }

      // bit field loaded with either 0 or 1 value, but when it is posted it becomes off and on
      form[elements.incl] = vars.groups.Inclusion_In_Overlay;

      // only load if the setting is turned on so old values will be saved as zeroes
      if ( qBudget.Overlays eq 1 ) {
        form[elements.overlay]    = vars.groups.Overlay_Purchase_Minimum;
        form[elements.overlayUOM] = vars.groups.Overlay_Purchase_Minimum_UOM;
      }
    </cfscript>
  </cfoutput>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="save_prodpg" output="false">
  <cfset var vars = {}>
<cfif (Trim(Replace(form.prodpg_list,",","","ALL")) EQ "")>
	<cfset form.prodpg_list = form.ExistingProductList />
</cfif>  
  <cfif (form.cutProducts NEQ "")>
  	<cfset cutProdLen = ListLen(form.cutProducts, ",") />
	<cfloop index = "IDProd" list="#form.cutProducts#"  delimiters=",">
		<cfset form.prodpg_list = Replace(form.prodpg_list, IDProd, "","ALL") />
	</cfloop>
  </cfif>
  <cfset form.prodpg_list = Replace(form.prodpg_list, ",,", ",","ALL") />
  
  <cftransaction>
  <!---remove rows no longer needed--->
  <cfloop index = "ID" list="#form.cutProducts#"  delimiters=",">
  <cfif ID NEQ "">
	  <cfquery name="vars.removals" datasource="#application.datasource#">
	    DELETE Budget_Product_Rate
	     WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
	           <cfif Len( ID )>
	            AND Product_Group_ID IN ( '#ID#' )
	           </cfif>
	  </cfquery>
	  </cfif>
  </cfloop>
  <cfset form.include_overlay_cnt = 0>
  <!----- Save selected groups ----->
 
  <cfloop list="#form.prodpg_list#" index="vars.group_id">

    <!---does the row exist?--->
    <cfquery name="vars.rowExists" datasource="#application.datasource#">
      SELECT 1
        FROM Budget_Product_Rate
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
              AND CAST(Product_Group_ID AS varchar(50)) = <cfqueryparam value="#vars.group_id#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <!---get the category--->
    <cfquery name="vars.PG_Product_Category" datasource="#application.datasource#">
      SELECT PG_Type_ID
        FROM PG_Product_Category
       WHERE CAST(PG_Product_Category_ID AS varchar(50)) = <cfqueryparam value="#vars.group_id#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <!---determine the form element names for this row--->
    <cfset set_elements( vars.group_id )>

    <!---assign default values to inputs in case they don't exist--->
    <cfparam name="form['#elements.base#']"    default="0"> <cfparam name="form['#elements.baseUOM#']"  default="0">
    <cfparam name="form['#elements.recap#']"   default="0"> <cfparam name="form['#elements.recapUOM#']" default="0">
    <cfparam name="form['#elements.corp#']"    default="0"> <cfparam name="form['#elements.corpUOM#']"  default="0">
    <cfparam name="form['#elements.incl#']"    default="off">
    <cfparam name="form['#elements.overlay#']" default="0"> <cfparam name="form['#elements.overlayUOM#']" default="0">

    <cfif form[elements.incl] eq 'on'>
      <cfset form.include_overlay_cnt = form.include_overlay_cnt + 1>
    </cfif>

    <!---row does not exist, create one--->
    <cfif vars.rowExists.recordCount eq 0>
      <cfquery name="vars.saveRow" datasource="#application.datasource#">
        INSERT INTO Budget_Product_Rate
          ( <!---01---> Budget_ID
          , <!---02---> Product_Group_Level_ID
          , <!---03---> Product_Group_ID
          , <!---04---> Rate
          , <!---05---> Rate_UOM
          , <!---06---> Corporate_Rate
          , <!---07---> Corporate_Rate_UOM
          , <!---08---> Recapture_Rate
          , <!---09---> Recapture_Rate_UOM
          , <!---10---> Inclusion_In_Overlay
          <cfif qBudget.Overlays eq 1>  
			, <!---11---> Overlay_Purchase_Minimum
        	, <!---12---> Overlay_Purchase_Minimum_UOM
		  </cfif>
          )
        VALUES
          ( <!---01---> <cfqueryparam value="#form.Budget_Id#"                       cfsqltype="cf_sql_integer">
          , <!---02---> <cfqueryparam value="#vars.PG_Product_Category.PG_Type_ID#"  cfsqltype="cf_sql_integer">
          , <!---03---> <cfqueryparam value="#vars.group_id#"                        cfsqltype="cf_sql_varchar">
          , <!---04---> <cfqueryparam value="#NumericValue(form[elements.base])#"    cfsqltype="cf_sql_decimal" scale=4>
          , <!---05---> <cfqueryparam value="#form[elements.baseUOM]#"               cfsqltype="cf_sql_integer">
          , <!---06---> <cfqueryparam value="#NumericValue(form[elements.corp])#"    cfsqltype="cf_sql_decimal" scale=2>
          , <!---07---> <cfqueryparam value="#form[elements.corpUOM]#"               cfsqltype="cf_sql_integer">
          , <!---08---> <cfqueryparam value="#NumericValue(form[elements.recap])#"   cfsqltype="cf_sql_decimal" scale=2>
          , <!---09---> <cfqueryparam value="#form[elements.recapUOM]#"              cfsqltype="cf_sql_integer">
          , <!---10---> <cfqueryparam value="#form[elements.incl] eq 'on'#"          cfsqltype="cf_sql_bit">
          <cfif qBudget.Overlays eq 1>
		  	, <!---11---> <cfqueryparam value="#NumericValue(form[elements.overlay])#" cfsqltype="cf_sql_decimal" scale=4>
          	, <!---12---> <cfqueryparam value="#form[elements.overlayUOM]#"            cfsqltype="cf_sql_integer">
		 </cfif> 
          )
      </cfquery>
    <!---row exists already, update it--->
    <cfelse>
      <cfquery name="vars.saveRow" datasource="#application.datasource#">
        UPDATE Budget_Product_Rate
           SET   Rate                         = <cfqueryparam value="#NumericValue(form[elements.base])#"    cfsqltype="cf_sql_decimal" scale=4>
               , Rate_UOM                     = <cfqueryparam value="#form[elements.baseUOM]#"               cfsqltype="cf_sql_integer">
               , Corporate_Rate               = <cfqueryparam value="#NumericValue(form[elements.corp])#"    cfsqltype="cf_sql_decimal" scale=2>
               , Corporate_Rate_UOM           = <cfqueryparam value="#form[elements.corpUOM]#"               cfsqltype="cf_sql_integer">
               , Recapture_Rate               = <cfqueryparam value="#NumericValue(form[elements.recap])#"   cfsqltype="cf_sql_decimal" scale=2>
               , Recapture_Rate_UOM           = <cfqueryparam value="#form[elements.recapUOM]#"              cfsqltype="cf_sql_integer">
               , Inclusion_In_Overlay         = <cfqueryparam value="#form[elements.incl] eq 'on'#"          cfsqltype="cf_sql_bit">
               <cfif form[elements.incl] eq 'on'>
               , Overlay_Purchase_Minimum     = <cfqueryparam value="#NumericValue(form[elements.overlay])#" cfsqltype="cf_sql_decimal" scale=4>
               , Overlay_Purchase_Minimum_UOM = <cfqueryparam value="#form[elements.overlayUOM]#"            cfsqltype="cf_sql_integer">
               <cfelse>
               , Overlay_Purchase_Minimum     = <cfqueryparam value="0"                                      cfsqltype="cf_sql_decimal" scale=4>
               , Overlay_Purchase_Minimum_UOM = <cfqueryparam value="0"                                      cfsqltype="cf_sql_integer">
               </cfif>
         WHERE Budget_ID = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
           AND Product_Group_ID = <cfqueryparam value="#vars.group_id#" cfsqltype="cf_sql_varchar">
      </cfquery>
    </cfif>
  </cfloop>

  <cfif form.include_overlay_cnt eq 0>
    <cfquery name="vars.delete" datasource="#application.datasource#">
      DELETE Budget_Overlay_Rate
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
    </cfquery>
  </cfif>
  <cfinclude template="validateAccrual.cfm">
  <cfquery name="vars.saveRow" datasource="#application.datasource#">
    <cfinclude template="last_update.cfm">       <!--- 36874 --->
  </cfquery>
  </cftransaction>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="NumericValue" output="false" hint="I return the numeric value of a string.">
  <cfargument name="numericString" required="true" hint="I am the numeric string.">
  <cfif Len(Trim( arguments.numericString )) eq 0>
    <cfreturn 0>
  <cfelseif IsNumeric( arguments.numericString )>
    <cfreturn arguments.numericString>
  <cfelse>
    <cfreturn 0>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="set_elements" output="false" hint="I determine the form element names for inputs on the page.">
  <cfargument name="product_group_id" required="true" hint="I am the unique key for the product planning group.">
  <!---the prefix should be capitalized & unique so form element can be identified correctly--->
  <cfscript>
      elements.base    = "B_" & arguments.product_group_id;  elements.baseUOM    = "BU_" & arguments.product_group_id;  // form element names for base rate & UOM
      elements.recap   = "R_" & arguments.product_group_id;  elements.recapUOM   = "RU_" & arguments.product_group_id;  // form element names for recapture rate & UOM
      elements.corp    = "C_" & arguments.product_group_id;  elements.corpUOM    = "CU_" & arguments.product_group_id;  // form element names for corporate rate & UOM
      elements.incl    = "I_" & arguments.product_group_id;                                                             // form element name for include overlay
      elements.overlay = "O_" & arguments.product_group_id;  elements.overlayUOM = "OU_" & arguments.product_group_id;  // form element names for overlay purchase min & UOM
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="uom_options" output="false" hint="I return the options for UOM drop-down">
  <cfargument name="selected" type="string" required="true" hint="I am the current selected option.">
  <cfargument name="percent_dollars" type="boolean" required="false" default="true">
  <cfset vars = {}>
  <cfsavecontent variable="result"><option value=0></option><cfoutput query="qUOM"><cfset vars.include_it = true> <cfif (arguments.percent_dollars eq false and qUOM.Budget_Units_of_Measure_ID gte 31 and qUOM.Budget_Units_of_Measure_ID lte 40) or (arguments.percent_dollars eq true and qUOM.Budget_Units_of_Measure_ID gte 41 and qUOM.Budget_Units_of_Measure_ID lte 50)><cfset vars.include_it = false></cfif><cfif vars.include_it><option value=#qUOM.Budget_Units_of_Measure_ID# <cfif arguments.selected eq qUOM.Budget_Units_of_Measure_ID>selected</cfif>>#qUOM.Unit_Of_Measure_Abbreviation#</option></cfif></cfoutput>
  </cfsavecontent>
  <cfreturn result>
</cffunction>

<cfoutput>
<!----- selected product planning groups is saved in hidden form element ----->
<input type="hidden" name="prodpg_list" value="#form.prodpg_list#" />
<input type="hidden" name="deleted" value="0">
<input type="hidden" name="ExistingProductList" value="#form.prodpg_list#" />
<input type="hidden" name="cutProducts" value="" />
</cfoutput>
<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/table2csv.js?w=49465"></script>

<script type="text/javascript">
<!---turn off loading from db flag--->
document.forms[budget_form].load_fromdb.value = "0";
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .45) * windowHeight;
var groups = $('table#groupgrid').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  <!---,"sScrollY": "300px"             <!--- datagrid height --->--->
  ,"sDom": 'fti'
  ,"sScrollY": sScrollY         <!--- data grid height --->
  ,"aaSorting": [[ 0, "asc" ]]     <!--- sort on product planning group column --->
  ,"aoColumns": [ null,
  				  { "bSortable":false, "bSearchable":false }
				  ,{ "bSortable":false, "bSearchable":false }
			            <cfif qBudget.Recapture eq 1>,{ "bSortable":false, "bSearchable":false }</cfif>
                  <cfif qBudget.Corporate_And_Local_Rate eq 1>,{ "bSortable":false, "bSearchable":false }</cfif>
                  <cfif qBudget.Overlays eq 1>,{ "bSortable":false, "bSearchable":false }</cfif>
                  <cfif qBudget.Overlays eq 1>,{ "bSortable":false, "bSearchable":false }</cfif>
                 /*  ,{ "bSortable":false, "bSearchable":false } */
				  ,{ "bSortable":false, "bSearchable":false }
                  ]
}).fnSetFilteringDelay();
<!---$(window).resize(function(){ groups.fnAdjustColumnSizing(); });--->
<!---forceNumeric() plug-in implementation--->
$.fn.forceNumeric = function () {
 return this.each(function () {
    $(this).keydown(function (e) {
        var key = e.which || e.keyCode;
        if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
        <!---numbers--->
            ( key >= 48 && key <= 57 ) ||
        <!---Numeric keypad--->
            ( key >= 96 && key <= 105 ) ||
        <!---comma, period and minus--->
           key == 190 || key == 188 || key == 109 || key == 189 ||
        <!---Backspace and Tab and Enter--->
           key == 8 || key == 9 || key == 13 ||
        <!---Home and End--->
           key == 35 || key == 36 ||
        <!---left, up and right, down arrows--->
           ( key >= 37 && key <= 40 ) ||
        <!---Decimal point on numeric keypad--->
              key == 110 ||
        <!---Del and Ins--->
           key == 46 || key == 45) {
          return true;
        }
        return false;
    });
 });
}
$(".rate").forceNumeric();
$("input,select").focus( function() { $(this).parents('tr').addClass( 'over' ); } )
                 .blur( function()  { $(this).parents('tr').removeClass( 'over' ); });
<!--------------------------------------------------------------------------------------------------------------------->
getCSVData = function() {
 var csv_value = $('table.datagrid').table2CSV({
			                                            csvExclude: 'csvExclude'         // filter out elements with csvExclude class
			                                         });
 $("#csv_file_name").val("Base Rate" + ' ' + $.datepicker.formatDate('mm-dd-yy', new Date()) + '.csv');
 $("#csv_text").val(csv_value);
 $("#csv_form").submit();
}

<!--------------------------------------------------------------------------------------------------------------------->
function add_prodpg() {
  <!--- refresh the groups list --->
  set_group_list();
	NewWindow("/search_screens/product_planning_group.cfm?Formname=" + budget_form
	            + <cfoutput>"&Business_Segment_Id=#qBudget.Business_Segment_ID#"</cfoutput>
	            + "&FieldName=prodpg_list", "groupwindow", 850, 600, "yes", "yes");
}
<!--------------------------------------------------------------------------------------------------------------------->
function del( tr_id ) {
  groups.fnDeleteRow( $('#' + tr_id)[0] );
}
<!--------------------------------------------------------------------------------------------------------------------->
<!---include overlay processing: if checked enable overlay purchase min & uom otherwise disable them--->
function overlay_min( inclusion ) {
  <!---locate the parent tr tag--->
  var parent_tr = $( '#' + inclusion.id ).parents('tr');
  parent_tr.find('.orate').attr( 'disabled', !inclusion.checked );
  parent_tr.find('.ouom' ).attr( 'disabled', !inclusion.checked );
}
<!--------------------------------------------------------------------------------------------------------------------->
function save_prodpg() {
  var vars = {};
  vars.errors = 0;

  if ( vars.errors > 0 )
    showMessageWindow();
  else {
    set_group_list();
    <cfoutput>
    document.forms[budget_form].action = 'index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#';
    </cfoutput>
//	alert(document.forms[budget_form].action);
//	return false;
    document.forms[budget_form].clicked_save.value = "1";
    document.forms[budget_form].submit();
  }
}
<!--------------------------------------------------------------------------------------------------------------------->
function set_group_list() {
  <!---find all nodes (includes hidden) with g1 class, gather all id values & join them together--->
  document.forms[budget_form].prodpg_list.value = $('.rowid', groups.fnGetNodes()).map(function() { return this.id; } ).get().join(',');
}

<!--------------------------------------------------------------------------------------------------------------------->

function checkAllProd()
{
	var elemColctn = document.forms[budget_form].getElementsByTagName("input");
	for (var i = 0; i<elemColctn.length; i++)
	{
		
		if ((elemColctn[i].name.indexOf('prodChkBx') > -1))
		{
			if (elemColctn.prodCheck.checked)
				elemColctn[i].checked = true;
			else
				elemColctn[i].checked = false;
        }
    }
}

function deleteAllProductOptions()
{
	var sHtml;
	var bAllowOptionB = 0;
	var scissorObj = event.srcElement;
	var bDelete = scissorObj.getAttribute('bDelete');
	var checked = $("#groupgrid input[type=checkbox]:checked").length; 
	if (checked == '0')
	{
		var elemColctn = document.forms[budget_form].getElementsByTagName("input");
		for (var i = 0; i<elemColctn.length; i++)
		{
			if ((elemColctn[i].name.indexOf('prodChkBx') > -1))
			{
				elemColctn[i].checked = true;
	        }
	    }
	}
		
	<cfif qGroups.RecordCount EQ 0>
		$.prompt('There are no products to delete' );
		return;
	</cfif>

	if( bDelete == 'true'){ 
		sHtml = 'Delete all checked Product PGs?';
		$.prompt(sHtml,
		{
			buttons: {"Yes":1,Cancel:0 }
			,callback: function(save, m, f){
				if(save == 1){
					//Only deletes checked products
					deleteAllProductsPG('prodChkBx_', scissorObj);
				}
				else {
					return false;
					}
			}
		});
	}
	else { // Only one option
		if(bDelete == 'true') {sHtml = 'Delete all checked products?';}
		else  {sHtml = 'Undelete all checked products?';}
		$.prompt(sHtml,
		{
			buttons: {"Yes":1, Cancel:0 }
			,callback: function(save, m, f){
				if(save == 1){
					//Only deletes checked products
					deleteAllProductsPG('prodChkBx_', scissorObj);//  
				}
				else {
					return false;
				}
			}
		}); 
	}
}

function deleteAllProductsPG(chNameStart, scissorObj)
{
	var checkCheckbox = 'false';
	set_group_list();
	var FINALITEMLIST = document.BudgetForm.prodpg_list.value;
	var itemCount = FINALITEMLIST.split(",");
	if(chNameStart)
	{
		checkCheckbox = 'true';
	}
	var totalProdLen = <cfoutput>#qGroups.RecordCount#</cfoutput>;
	var deleteObjs = document.getElementsByName("IMG_Delete_Scissor");
	var i, deleteObjLen;
	var bDelete = scissorObj.getAttribute('bDelete');
	var deletedProdCount = 0;
	deleteObjLen = deleteObjs.length;
	/* if(deleteObjLen)
		{
			for(i=0;i<deleteObjLen;i++)
			{
				if(bDelete + "" == deleteObjs[i].getAttribute('bDelete') + "")
				{
					if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs[i]))
					{
						/* Count how many products are checked for deletion. * /
						deletedProdCount = deletedProdCount + 1;
					}
				}
			}
		} */

	if(deleteObjLen)
	{
		for(i=deleteObjLen-1;i>=0;i--)
		{
			if(bDelete + "" == deleteObjs[i].getAttribute('bDelete') + "")
			{
				if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs[i]))
				{
					deleteObjs[i].click();
				}
			}
		}
	}
	else
	{
		if(bDelete + "" == deleteObjs.getAttribute('bDelete') + "")
		{
			if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs))
			{
				deleteObjs.click();
			}
		}
	}
	if(bDelete == 'true')
	{
		scissorObj.title = "undo " + scissorObj.getAttribute('sMessage');
		scissorObj.src = undodeleteImg.src;
	}
	else
	{
		scissorObj.title = scissorObj.getAttribute('sMessage');
		scissorObj.src = deleteImg.src;
	}
	/* The reason why "bDelete" is a string and not a boolean is because "setAttribute" can only set a string value and not a boolean. */
	scissorObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
}	
	
	
function deleteProductPG(curRow,pgCatID)
{
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.forms[budget_form].prodpg_list.value;
		var TOTALITEMLIST = document.forms[budget_form].ExistingProductList.value;
		var CurCutItems = document.forms[budget_form].cutProducts.value;
		var itemCount = FINALITEMLIST.split(",");
		var bDelete = srcObj.getAttribute('bDelete');
		var resultString = FINALITEMLIST;
		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
			 		
		if(trObj){
			if(bDelete == 'true'){
				trObj.height = trObj.offsetHeight;
				trObj.setAttribute('bgcolor', 'DDDDDD');
				propogateProperty(trObj, "style.textDecoration", "line-through", true);
				srcObj.title = "Deleted";
				srcObj.src = undodeleteImg.src;
				document.forms[budget_form].deleted.value = Number(document.forms[budget_form].deleted.value) + 1;	
				CurCutItems = ListAppendItem(CurCutItems, ",", pgCatID);
				resultString = ListDeleteItem(FINALITEMLIST, ",", pgCatID);	

			}	else{
				trObj.setAttribute('bgcolor', 'FFFFFF');
				propogateProperty(trObj, "style.textDecoration", "none", false);
				srcObj.title = "delete this product";
				srcObj.src = deleteImg.src;
				document.all.deleted.value = document.all.deleted.value - 1;		
				CurCutItems = ListDeleteItem(CurCutItems, ",", pgCatID)
				resultString = ListAppendItem(FINALITEMLIST, ",", pgCatID);
			}
			srcObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
			trObj.setAttribute('bDelete',(bDelete == 'true'?1:0));
		}

		document.forms[budget_form].cutProducts.value = CurCutItems;
		document.forms[budget_form].prodpg_list.value = resultString;
		// document.forms[budget_form].ExistingProductList.value = FINALITEMLIST;
	}	
	 
</script>