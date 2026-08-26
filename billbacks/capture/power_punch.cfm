<!---
Created By: 	Brenda J. Flynn		
				bflynn@bigredflame.com
Created On:		May 24, 2004

This page allows for the quick entry of products to billbacks.

Edity By:
Edited On:
Change Summary:

--->
<cfoutput>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfparam name="URL.BBID" 		default="">
<cfparam name="Program_List" 	default="">
<cfparam name="form.Has_Rebate_Components" default="0" />
<cfparam name="ShowItems"		default="0">
<cfparam name="SelectedProgram" default="">
<cfparam name="form.shipToList" default = "" />

<cfif NOT isDefined("FORM.Billback_ID")>
	<CFSET FORM.Billback_ID = URL.BBID>
</cfif>



<cfset useLakebaseForgetPayeeInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetPayeeInfo>
	<cftry>
		<cfset getPayeeInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "billback_payee_type_id,bb_amount"
			}), "billback_payee_type_id,bb_amount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPayeeInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPayeeInfo>
<cfquery name="getPayeeInfo" datasource="#Application.Datasource#">
	SELECT 	Billback_Payee_Type_ID, 
			BB_Amount
	FROM 	Billback
	WHERE 	Billback_ID = '#FORM.Billback_ID#'
</cfquery>
</cfif>

<CFIF len(trim(URL.BBID)) GT 0>

	<cfset useLakebaseForLookForExistingProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForLookForExistingProgram>
	<cftry>
		<cfset LookForExistingProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLookForExistingProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLookForExistingProgram>
<cfquery name="LookForExistingProgram" datasource="#Application.Datasource#" >
		SELECT	*
		FROM 	Billback_Program
		WHERE 	Billback_ID = '#FORM.Billback_ID#' 
		AND		Deleted = 0
	</cfquery>
</cfif>

	<cfset Program_List = valuelist(LookForExistingProgram.Program_ID)>
	
	<CFIF LookForExistingProgram.recordcount GT 0>
		<CFSET LoadBillbackID = FORM.Billback_ID>
		<cfinclude template="load_billback_to_struct.cfm">
	</CFIF>
	
	<!--- If there's more than one program on the billback they need to pick which one they're power punching for --->
	<cfif len(trim(SelectedProgram)) EQ 0 AND LookForExistingProgram.recordcount GT 1 >
		
		<cfquery name="GetProgramDetails" datasource="#application.datasource#">
		SELECT Contract_Title, Contract_Number, Contract_Main_ID
		FROM Contract_Main
		WHERE Contract_Main_ID IN (#Program_List#)
		</cfquery>
		<p>&nbsp;</p>
	<strong>Please select which program you wish to add to with power punch:</strong>
	<p></p>
	<form name="SelectProgram" method="post" action="power_punch.cfm">
	<select name="SelectedProgram">
		<cfloop query="GetProgramDetails">
			<option value="#Contract_Main_ID#">#Contract_Number# (#left(Contract_Title, 50)#<cfif len(Contract_Title) GT 50>...</cfif>) 
		</cfloop>
	</select>
	
	<!--- Hidden fields to be passed back and forth --->
	<input type="hidden" name="Billback_ID" id="Billback_ID" value="#FORM.Billback_ID#">
	
	</form>
	<p></p>
	<CF_button
					button_name		=	""
					button_caption	=	"save"
					button_action	=	"SelectProgram.submit();"
					button_type		=	"javascript_link"
					button_width	=	"50"
					button_color	=	"Navy"
					button_tip		=	"Save and continue"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
	<cfabort>
	</cfif>
</CFIF>

<cfif len(trim(SelectedProgram)) GT 0>
	<cfset Program_List = SelectedProgram>
	
</cfif>

<CFIF NOT Isdefined("FORM.Wddx_Packet_To_File_Map_ID")>

	<cfset PacketCommand = "init">
	<cfinclude template="/includes/wddxpacketapi.cfm">
	<CFSET FORM.Wddx_Packet_To_File_Map_ID = PacketReturnData.Wddx_Packet_To_File_Map_ID>

	<CFIF NOT ISDEFINED("Billback")>
		<CFSET Billback = StructNew()>
		<CFSET Billback.Programs = StructNew()>
		<CFSET Billback.Programs.Count = 0>
		<CFSET Billback.Programs.Unknown_Program_On_Billback = 0>
		<CFSET Billback.List_Of_Programs = "">
		<CFSET Billback.Billback_ID = FORM.Billback_ID>
	</CFIF>
	
	<cfset PacketCommand = "write">
	<cfset Supplied_PacketContents = Billback>
	<cfset Supplied_Wddx_Packet_To_File_Map_ID = FORM.Wddx_Packet_To_File_Map_ID>
	<cfinclude template="/includes/wddxpacketapi.cfm">
	
<CFELSE>

	<cfset Supplied_Wddx_Packet_To_File_Map_ID = FORM.Wddx_Packet_To_File_Map_ID>
	<cfset PacketCommand = "read">
	<cfinclude template="/includes/wddxpacketapi.cfm">
	<CFSET Billback = Packet.Contents>
	
</CFIF>



<!---Defaulting always to case--->
<!--- <cfquery name="GetUOMs" datasource="#application.datasource#">
SELECT TOP 2 * FROM Units_of_Measure
</cfquery>
 --->
<CFSET getPayeeID = QueryNew("Payee_ID")>

<cfswitch expression="#getPayeeInfo.Billback_Payee_Type_ID#">
	<cfcase value="1"><!--- Distributor --->
		<cfset useLakebaseForgetPayeeID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor")>
<cfif useLakebaseForgetPayeeID>
	<cftry>
		<cfset getPayeeID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"deleted" = "eq.0",
				"select" = "distributor_id as payee_id"
			}), "distributor_id as payee_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPayeeID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPayeeID>
<cfquery name="getPayeeID" datasource="#Application.Datasource#">
			SELECT Distributor_ID as Payee_ID
			FROM Billback_Distributor
			WHERE Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0
		</cfquery>
</cfif>
	</cfcase>

	<cfcase value="2"><!--- Operator --->
		<cfquery name="getPayeeID" datasource="#Application.Datasource#">
			SELECT Operator_ID as Payee_ID
			FROM Billback_Operator
			WHERE Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0
		</cfquery>
	</cfcase>

	<cfcase value="3"><!--- Broker --->
		<cfquery name="getPayeeID" datasource="#Application.Datasource#">
			SELECT Broker_ID as Payee_ID
			FROM Billback_Broker
			WHERE Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0
		</cfquery>
	</cfcase>
</CFSWITCH>

<CFSET PayeeProgramIDList = "">
<CFIF len(trim(getPayeeInfo.Billback_Payee_Type_ID)) NEQ 0 AND len(trim(getPayeeID.Payee_ID))>
	<CFIF trim(getPayeeInfo.Billback_Payee_Type_ID) NEQ 0 AND trim(getPayeeID.Payee_ID) NEQ 0>
		<cfinclude template="/billbacks/capture/build_PayeeProgramIDList.cfm">
	</CFIF>
</CFIF>

<cfquery name="getAssociated_Ship_To" datasource="#Application.Datasource#">
 SELECT BSA_Foodservice_Customers.Ship_To AS Ship_To
 FROM BillBack_Distributor_List
	INNER JOIN BSA_Foodservice_Customers
	ON BillBack_Distributor_List.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
 WHERE BillBack_Distributor_List.Billback_ID = '#FORM.Billback_ID#'
 AND BillBack_Distributor_List.Deleted = 0
</cfquery>

<!--- 
###		Get Distributor ID info
###		Use "00000000-0000-0000-0000-000000000000" if none, use the 0 string --->
<cfset billbackDevManager = CreateObject("component", "components.billback.BillbackDeviationManager") />
<cfset qDistributorId = billbackDevManager.getBillbackDistributorList(FORM.Billback_ID) />
<cfset variables.distributorList = "" />
<cfif qDistributorId.RecordCount>
 <cfloop query="qDistributorId">	
	<cfset qDistributorInfo = billbackDevManager.getDistributorInfo(qDistributorId.BSA_FOODSERVICE_CUSTOMERS_ID) />
    <cfset variables.distributorList = listAppend(variables.distributorList,qDistributorInfo.Shr_Ship_To,",") />  
		<cfset variables.distributorList = listAppend(variables.distributorList,qDistributorInfo.Ship_To,",") />  
</cfloop>
	
</cfif>

<!--- <cfdump var="#payeeId#"> --->

<!--- Hidden form --->
<form action="/billbacks/capture/power_punch.cfm" method="post" name="AddProgram">

	<input type="hidden" name="Program_List" id="Program_List" value="">
	<input type="hidden" name="Count_ID" id="Count_ID" value="0">
	<input type="hidden" name="Component_Count_ID" id="Component_Count_ID" value="0">
	<input type="hidden" name="Billback_ID" id="Billback_ID" value="#FORM.Billback_ID#">
	<input type="hidden" name="FilterSearchPrograms" id="FilterSearchPrograms" value="0">
	<input type="hidden" name="FilterType" 				value="#getPayeeInfo.Billback_Payee_Type_ID#">
	<input type="hidden" name="FilterDataList"			value="#getPayeeID.Payee_ID#">
	<input type="hidden" name="runsearchonfirstload"	value="0">
	<input type="hidden" name="CurrentFloatingLayerDisplayStatus" value="0">
</form>
<!--- Hidden form --->

<!--- Available variables --->
<CFSET TITLEMAXCHARS 									= 50>
<CFSET Dollar_Sign_Size 								= 2>
<cfset Program_ID										= Program_List>
<cfset Contract_Main_ID									= Program_ID>
<!--- end available variables --->


<!---Select programs--->
<CFSET PAGE_TITLE="Billback Power Punch">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<style type="text/css">
		.error
		{
			border: 2px solid ##ff0000;
		}
		
		.pwrPunch{};
	</style>
	<link rel="stylesheet" type="text/css" media="screen" href="/Script/javascript/Ajax_JS/jquery.suggest.css" />
    <script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery-1.2.1-min.js"></script>
    <script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.dimensions.js"></script>
	<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.suggest.js"></script>
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

<script>

<!--- $(document).ready(function(){
   jQuery(function() {
    $("input[@id='Distributor_#Contract_Main_ID#_1']").unbind().suggest("powerpunch_suggest.cfm?Billback_ID=#Form.Billback_ID#",{
	  onSelect: function() {}});
	 });
	 var distList = "<cfoutput>#variables.distributorList#</cfoutput>";
 })
 --->
function populateShipTo(txtBox)
{
   var txtBoxLen = txtBox.length;
   var id = "";
    
   if (txtBox.substring(txtBoxLen-1,txtBoxLen) == "3")
   {
      id = txtBox;
      $("##"+id).unbind().suggest("powerpunch_suggest.cfm?Billback_ID=#Form.Billback_ID#");
      $("##"+id).removeClass("error");
      
	  $("input[@class='pwrPunch'],input[@class='pwrPunch error']").each(function() 
	  {
        $(this).focus(function(){$(this).unbind().suggest("powerpunch_suggest.cfm?Billback_ID=#Form.Billback_ID#");
        });
        
      });
     }
}

</script>

<blockquote>
<blockquote>
 <!---Part 1 --->
<cfif len(trim(Program_List)) LT 1>

	<table border="0" cellspacing="0" cellpadding="0" align="left" >
				<TR>
								
			<td width="50">	
			<img src="/images/whitebg_programs.gif" alt="" border="0" onClick="SearchPrograms(1,'#getPayeeInfo.Billback_Payee_Type_ID#','#getPayeeID.Payee_ID#')" style="cursor: pointer;"></TD>
					<TD><a onClick="SearchPrograms(1,'#getPayeeInfo.Billback_Payee_Type_ID#','#getPayeeID.Payee_ID#')" style="cursor: pointer;" nowrap><strong>add&nbsp;program</strong></a><BR></td>
					 
				</TR>
			</table>

</cfif>


<!---- Part two: select discounts --->
<cfif ShowItems IS 0 AND len(trim(Program_List)) GT 0>
	
	<cfset Payee_Type_ID = getPayeeInfo.Billback_Payee_Type_ID>
	<cfset LocationUrl = "/billbacks/capture/power_punch.cfm?Program_List=#Program_List#&ShowItems=1&BBID=#Billback_ID#&SelectedProgram=#Program_List#&Discount_List=">
	<cfinclude template="program_components_discounts.cfm">
	
<!---ENd part two --->
</cfif>
		
		<!--- Part three: the items --->
		<cfif ShowItems IS 1>
		
		<cfquery name="GetDiscountTypes" datasource="#application.datasource#">
			SELECT 	*
			FROM 	BB_Product_Type
			WHERE 	BB_Product_Type_ID  IN (#Discount_List#)
			ORDER BY Display_Order ASC
		</cfquery>
		
		
		<table cellpadding="2"  cellspacing="0" border="0">
			<tr>
				<td width="125" align="left">
					<strong>#ucase(application.returned_customer_setting.item_label)#</strong>
				</td>
				
				<td width="125" align="left">
					<strong>EXTENDED AMOUNT</strong>
				</td>
				<td width="125" align="left">
					<strong>VOLUME</strong>
				</td>
				<cfif getAssociated_Ship_To.Recordcount GT 1 AND getAssociated_Ship_To.Ship_To neq "">
				<td width="125" title="(Optional - Default is Payee)" align="left">
					<strong>#UCASE(application.returned_customer_setting.Shard_Ship_To_Label)#</strong>
				</td>
				<cfelse>
					<td width="125">&nbsp;</td>
				</cfif>
				<cfif appsettings.BB_PP_Manual_Discount IS 1>
					<td width="150">
						<strong>DISCOUNT TYPE</strong>
					</td>
				</cfif>
				<td align="center" width="50">
					<img src="/Images/plus4.gif" width="13"  style="cursor: pointer;" height="13" title="add row" border="0" onClick="addPeriod('thisTable_#Contract_Main_ID#', #Contract_Main_ID#, 1);try { window.parent.dyniframesize(); } catch (err) { };">
				</td>
			</tr>
			
			<tr>
				<td colspan="100%">
					<hr width="100%" color="orange">
				</td>
			</tr> 
		
		</table>
<form action="/billbacks/capture/power_punch_action.cfm" method="post" name="PowerPunch">
		
	<input type="hidden" name="Program_List" value="#Program_List#">
		<table id="thisTable_#Contract_Main_ID#" border="0" cellpadding="2" cellspacing="0"  class="Maintable">

			<tr id="ThisRow" rowName="Row_1">
		
				<td width="125"  align="left">
					<input type="text" size="18" name="Item_#Contract_Main_ID#_1" value="" previous_value="0" >
				</td>
						
			
				<td width="125" align="left">
					<input type="text" size="18" name="Amount_#Contract_Main_ID#_1" value="" previous_value="0" onKeyUp="clenseText(this, '-0123456789.');" > <!---<cfif appsettings.BB_PP_Manual_Discount IS 0>onKeyDown="addPeriod('thisTable_#x#', #x#, 0);"</cfif> --->
				</td>
				<!--- Be careful of the "addPeriod" function call - It needs to be called to add a new row and depending on appsetting, it may need to be added in a new place too --->
				<td width="125" align="left">
					<input type="text" size="18" name="Volume_#Contract_Main_ID#_1" value="" previous_value="0" onKeyUp="clenseText(this, '-0123456789.');fixEmptyValue(this);" <cfif getAssociated_Ship_To.RecordCount LTE 1 AND appsettings.BB_PP_Manual_Discount IS 0>onKeyDown="addPeriod('thisTable_#Contract_Main_ID#', #Contract_Main_ID#, 0);try { window.parent.dyniframesize(); } catch (err) { };" </cfif>>
				   
				</td>
				<input type="hidden" name="UOM_#Contract_Main_ID#_1" value="1">
				<!---Default all units of measure to case--->
				<cfif getAssociated_Ship_To.RecordCount GT 1>
					<td width="125" align="left">
						<input type="text" size="18" name="Distributor_#Contract_Main_ID#_1" value="" previous_value="0" class="pwrPunch" id="Distributor_#Contract_Main_ID#_1" <!--- autocomplete="off" ---> <cfif appsettings.BB_PP_Manual_Discount IS 0>onKeyDown="addPeriod('thisTable_#Contract_Main_ID#', #Contract_Main_ID#, 0);try { window.parent.dyniframesize(); } catch (err) { };" </cfif> />
					</td>
				<cfelse>
				<td width="125">
						<input type="hidden" name="Distributor_#Contract_Main_ID#_1" value="" id="Distributor_#Contract_Main_ID#_1" />
				</td>
				</cfif>
				<cfif appsettings.BB_PP_Manual_Discount IS 1>
					<td width="150">
						<cfset DiscountNumber = 0>
						<select name="DiscountType_#Contract_Main_ID#_1"  onKeyDown="addPeriod('thisTable_#Contract_Main_ID#', #Contract_Main_ID#, 0);try { window.parent.dyniframesize(); } catch (err) { };">
							<cfloop query="GetDiscountTypes">
								<cfset DiscountNumber = DiscountNumber + 1>
							<option value="#GetDiscountTypes.BB_Product_Type_ID#">#BB_Product_Type_Desc#</option>
							</cfloop>
						</select>
					</td> 
				</CFIF>
			
				<td width="50" align="Center">
					<input type="hidden" name="c_#Contract_Main_ID#_counter" value="1">
					<input type="hidden" name="isDeleted_#Contract_Main_ID#_1" value="0">
					<img id="theImage"  style="cursor: pointer;" onClick="deleteRecord(this);" src="/Images/scissor.gif" width="14" height="9" title="Remove entry" border="0">
				</td>
			</tr>	
	
	</table>
	<script>document.all.Item_#Contract_Main_ID#_1.focus();</script>
	
		
	<table border="0" width="550">
	
		<tr>
			<td colspan="2" align="center">	
				<br>
				<CF_button
					button_name		=	""
					button_caption	=	"save"
					button_action	=	"validate();"
					button_type		=	"javascript_link"
					button_width	=	"50"
					button_color	=	"Navy"
					button_tip		=	"Save and continue"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>		
			</td>
		</tr>
		
	</table>
	
	<!--- BJF: This puts white space at the bottom of the page so the auto suggest doesn't get cut off --->
	<cfloop from="1" index="i" to="100">
	&nbsp;<br>
	</cfloop>
	</cfif>
	

	<input type="hidden" name="Billback_ID" value="#Form.Billback_ID#">


<!---hidden field to hold value for billbacks at the component level--->
<input type="hidden" name="Claim_At_Comp_Level" value="#appSettings.Claims_at_Comp_Level#" />
<input type="hidden" name="Has_Rebate_Components" value="#form.Has_Rebate_Components#" />
</form>

</blockquote>
</blockquote>


</body>	
</head>	
</html>

<!---For each program, enter a product--->


<!---All javascript--->


<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<script>
function SearchPrograms(ApplyFilter) {


			<!--- document.AddProgram.Program_List.value 			= document.PowerPunch.Program_List.value; --->

			document.AddProgram.FilterSearchPrograms.value 	= ApplyFilter;
		
			document.AddProgram.FilterType.value 				= 0;
			document.AddProgram.FilterDataList.value 			= "";
			document.AddProgram.runsearchonfirstload.value 	= 0;
			
			if(ApplyFilter == 1){
				<cfoutput>
					document.AddProgram.FilterType.value 		= '#getPayeeInfo.Billback_Payee_Type_ID#';
					document.AddProgram.FilterDataList.value 	= '#getPayeeID.Payee_ID#';
					document.AddProgram.runsearchonfirstload.value = 1;
				</cfoutput>
			}
						
			NewWindow("/billbacks/search_screens/search_programs.cfm?Formname=AddProgram&fieldname=Program_List&SelectSingleSearchResultOnly=1", "programswindow", 800, 600, "yes", "yes")
			
		}



		 function addPeriod(TableToUpdate, cmId, isIcon)
		{	
			//var srcObj = event.srcElement;
			//var tabObj = getParentObject(srcObj, "table");
			
			
			var tabObj = eval("document.all." + TableToUpdate);
						//var trObj = getParentObject(srcObj, "tr");
			var lastIndex = tabObj.rows.length - 1;
			if ((window.event.keyCode == 9 && !(window.event.shiftKey)) || isIcon == 1)
			{	
				//alert(lastIndex);
				addFilterRows(tabObj, tabObj.rows[lastIndex], lastIndex, lastIndex + 2, cmId);
				var newRow = tabObj.rows[tabObj.rows.length - 1];	
				var inps = newRow.getElementsByTagName("input"); 
				if(inps)
				{
					var firstInp = 	inps[0];
					
					//firstInp.focus();
				}
			}
			
		}
		
		function incrementName(checkHTML, replaceNumber, srcIndex)
	 	{
	  		var regExp = new RegExp("((name|id)=.*?_(.*?))[\"\\s>]", "igm");
	  		var arr = checkHTML.match(regExp);
	  		var i;
	  		var newHTML = checkHTML;
			if (arr)
			{
				for(i=0;i<arr.length;i++)
	  			{
	   				var idField = arr[i];
	   				var arr2 = /_([^_]*?)$/.exec(idField);
	   				var indexNumber = RegExp.$1;
	   
	   				newIndexNumber = replaceNumber;
	   				//newIndexNumber = parseFloat(indexNumber);
	   				if(!isNaN(newIndexNumber))
	   				{
	    				//newIndexNumber = newIndexNumber + 1;						
	    				var regExp = new RegExp("_" + indexNumber, "igm");
	    				newIDField = idField.replace(regExp, "_" + newIndexNumber + idField.substr(idField.length-1));
	    				var regExp = new RegExp(idField, "igm");
	    				var newHTML = newHTML.replace(regExp, newIDField); 
	   				}  
				} 
	  		}
			var regExp = new RegExp("Volume_" + srcIndex, "igm");			
	 		var newHTML = newHTML.replace(regExp, "Volume_" + replaceNumber); 
			return newHTML;
	 	}
		
		
		function addFilterRows(pObj, trObj, trIndex, srcIndex, cmId)
	    {	
			var rObj = pObj.insertRow(trIndex+1);
			var cmIdCounterObj = eval("document.all.c_" + cmId + "_counter");
			cmIdCounterObj.value = trIndex+2;
			
		 	var coLen = trObj.cells.length;
		 	for (i=0;i<coLen;i++)
		 	{
				var cObj = rObj.insertCell(i);
				if (trObj.cells[i].align)
				{
					cObj.align = trObj.cells[i].align;
				}
				
				//cObj.innerHTML = incrementName(trObj.cells(i).innerHTML, trIndex + 2, srcIndex);
				/* Below 2 lines replaces the above 1 line. The idea is to get the element of the row, cell by cell */
				tdObj = $(trObj).find("td").eq(i);
				cObj.innerHTML = incrementName(tdObj.html(), trIndex + 2, srcIndex);
	     			
				var inputCol = cObj.getElementsByTagName("input");
				for (j=0;j<inputCol.length;j++)
				{
				/* Hidden has been added for Distributor field, when the associated_ship_to does not exist */
					if (inputCol[j].type == "text" || (inputCol[j].type == "hidden" && inputCol[j].name.indexOf("Distributor_") != -1)) 
					{

						inputCol[j].value = "";
						inputCol[j].readOnly = false;
						inputCol[j].id = "ppunch" + cmIdCounterObj.value + "_" + i;

						
						if (inputCol[j].getAttribute('previous_value'))
						{
							inputCol[j].setAttribute('previous_value','0');
						}
						
						<!--- populateShipTo(inputCol[j].id); --->
						
					}
					
					if (inputCol[j].type == "checkbox")
					{
						inputCol[j].checked = true;
					}
				}
				
				var inputCol = cObj.getElementsByTagName("select");
				for (j=0;j<inputCol.length;j++)
				{
					inputCol[j].selectedIndex = 0;
				}
				
				var inputCol = cObj.getElementsByTagName("div");
				for (j=0;j<inputCol.length;j++)
				{
					inputCol[j].innerText = "";					
				}									
		 	}	
			rObj.all.theImage.title = "delete record";
			rObj.all.theImage.src = deleteImg.src;
			propogateProperty(rObj, "style.backgroundColor", "##ffffff", false);
			propogateProperty(rObj, "style.textDecoration", "none", false);
			
				
		}

	function deleteRecord(thisObj)
	{
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");	
		var trIndex = trObj.rowIndex;	
		
					
		var objDollars = getInputObject(trObj.cells[0])
		var objDeleted = eval("document.all.isDeleted_" + find_counter(objDollars.name));
		
		var bDelete = false;
		if(objDeleted.value == 1)
		{
			propogateProperty(trObj, "style.backgroundColor", "##ffffff", false);
			propogateProperty(trObj, "style.textDecoration", "none", false);	
			
			objDollars.readOnly = false;
			objDeleted.value = 0;
			
			thisObj.title = "delete record";
			thisObj.src = deleteImg.src;
		}
		else
		{
			bDelete = true;
			propogateProperty(trObj, "style.backgroundColor", "##DDDDDD", false);
			propogateProperty(trObj, "style.textDecoration", "line-through", false);	

			objDollars.readOnly = true;
		
			objDeleted.value = 1;
			//propogateProperty(trObj.cells[trObj.cells.length - 1], "style.backgroundColor", "##ffffff", false);
			
			thisObj.title = "undo record deletion";
			thisObj.src = undodeleteImg.src;
		}		
		
		//adjust_Amount(objDollars,document.all.Total_Dollars,bDelete)	
				
	}
	
	function getInputObject(oCell)
	{
		var inpObjs = oCell.getElementsByTagName("INPUT");
		var i, inpLen;
		inpLen = inpObjs.length;
		for(i=0;i<inpLen;i++)
		{
			if(inpObjs[i].type == "text")
			{
				return inpObjs[i];
			}
		}
		
	}

	function find_counter(sname)
	{	
		var arName = sname.split("_");
		arName.splice(0,1);
		return arName.join("_");		
		
	}
	
	function validate()
	{
		var ppForm = document.PowerPunch;
		var bClaimCompLevel = ppForm.Claim_At_Comp_Level.value;
		var bHasComps = ppForm.Has_Rebate_Components.value;
		//if claims at component level are on and the program has components then verify that at least one component has been selected
		var distList = "<cfoutput>#variables.distributorList#</cfoutput>";
        var processForm = true;
          
          $("input[@class='pwrPunch'],input[@class='pwrPunch error']").each(function() 
	      {              
             $(this).removeClass("error");
             if (ListFindItem(distList,",",$(this).val()) == -1)
             {
             	$(this).addClass("error");
							/* If the record is not deleted */
             	if($(this).get(0).style.textDecoration != 'line-through'){
								processForm = false;
							}
             }  
            });
       if (!processForm)
       {
       	 alert("One of the #application.returned_customer_setting.Shard_Ship_To_Label# values you entered is either not a valid distributor or not a distributor you selected on the payee page");
       }
		else
		{
		if (bClaimCompLevel != 0 && bHasComps != 0)
		{
			if (validateCheckBoxes('Selected_Rebate_Component'))
			{
				ppForm.submit();
			}
			else
			{
				alert("Select at least one component.");
			}
				
		}
		else //submit anyway
		{
			ppForm.submit();
		}
       }
	}
	
	//function to check and see if any check boxes are selected for a particular element	
	function validateCheckBoxes(elem) 
	{
		var bIsChecked = false;
		var elemColctn = document.PowerPunch.getElementsByTagName("input");

		for (var i = 0; i<elemColctn.length; i++) 
		{
			if ((elemColctn[i].name.indexOf(elem) > -1)) 
			{
				if (elemColctn[i].checked) 
				{
					bIsChecked = true;
					return bIsChecked;
				}//end if
			}//end else
		}//end for
			
		return bIsChecked;
	
	}//end validateCheckBoxes function

 function fixEmptyValue(theval) {
 	if (theval.value == ".") {
	  	 theval.value = replaceChar(theval.value,".","0.0");
	  }
 }

</script>

</cfoutput>
<script>
	try { window.parent.dyniframesize(); } catch (err) { };
</script>
