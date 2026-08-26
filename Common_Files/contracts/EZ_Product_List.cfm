<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\contracts\EZ_Product_List.cfm
      Date:     21-Sep-2022
      Author:   Anand Rao
      Purpose:  Create a list of product 

      Notes:

----------------------------------------------------------------------------------------------------------------------->

<cfparam name="form.submitted" default="0">
<cfparam name="form.itemList" default="">
<cfparam name="form.passedItemList" default="">
<cfparam name="form.hiddenForm" DEFAULT="">

<cfset errorInFormat = "" />
<cfset errorMessage = "" />
<cfset InvalidProds = "" />
<cfset NewItemlist = "" />

<cfif (form.submitted EQ 1)>
	<cfset productlist = ''>
	<cfset ratelist = ''>
	<cfset uomlist = ''>
	<cfset rate = ''>
	<cfset uom = ''>
	<cfset delims = '#chr(9)#,#chr(32)#'> <!--- tab, space --->
	<cfset CompDefaultRate = '0.0000'>
	<cfset CompDefaultUOM = 'CS'>
	<cftry>
		<cfloop index = "rawdata" list = "#trim(FORM.itemList)#" delimiters="#chr(13)#">

			<cfset productlist =  listappend(productlist, ListGetAt(rawdata,1,delims))>
			<cfset ratelist =  listappend(ratelist, ListGetAt(rawdata,2,delims))>
			<cfset uomlist =  listappend(uomlist, ListGetAt(rawdata,3,delims))>

		<!---
		<cfif listlen(rawdata) GT 1>
			<cfset rate = listappend(rate, ListGetAt(rawdata,2,delims))>
		<cfelse>
			<cfset rate = listappend(rate, CompDefaultRate)>
			<cfset rawdata= listappend(rawdata, CompDefaultRate,',')>
		</cfif>

		<cfif listlen(rawdata) GT 2>
			<cfset uom = listappend(uom, ListGetAt(rawdata,3,delims))>
		<cfelse>
			<cfset uom = listappend(uom, CompDefaultUOM)>
			<cfset  rawdata = listappend(rawdata, CompDefaultUOM)>
		</cfif> --->
	<!--- BELOW FUNCTION WILL CHECK IF ITEMS ALREADY EXISITNGS IF ITEMS EXIST THEN WE UPDATE RATE/UOM IF NOT WE WILL INSERT ITEMS INTO TEMP TABLE --->
		<!--- 	<cfset InsertUpdateData = RebateCFC.InsertUpdateRecords(trim(ListGetAt(rawdata,1,delims)), ListGetAt(rawdata,2,delims), ListGetAt(rawdata,3,delims), tablename, #ProgramComponentID#, uom_validation, local.getRateTypesFromTemplate, CompDefaultVol)> --->
	</cfloop>
	<cfcatch>
		<cfset errorInFormat = "Error in input format" />
		<script>alert('Error in input format');</script>
	</cfcatch>
	</cftry>
 
	<!--- check if the items are valid --->
			<!--- cfinclude template="\common_files\validateInput.cfm"/> --->
	<cfset NewProdList="">
	<cfset iCounter = 0 >
	<cfset PrdCtr = ListLen(productlist) />
	<cfloop List ="#productlist#" index="prod_ctr">
		<cfset iCounter = iCounter + 1 >
    	<cfset NewProdList= NewProdList & "'" & trim(prod_ctr) & "'">
   		<cfif iCounter LT PrdCtr>
   	   		<cfset NewProdList= NewProdList & ",">
		</cfif>
	</cfloop>
	<cfquery name="qCheckProductValidity" datasource="#application.datasource#">
		SELECT  BSA_Foodservice_Items_Master_ID, Item , Description, Active_code, Net_Weight  from BSA_Foodservice_Items_Master where deleted = 0 and active_Code = 'A' and Item IN (#Replace(NewProdList,"''","'","ALL")#)
	</cfquery>
	<cfset qProductListIds = ValueList(qCheckProductValidity.BSA_Foodservice_Items_Master_ID) />
	<cfset qProductList = ValueList(qCheckProductValidity.Item) />
		<!--- Check for invalid products --->
	<cfif (listLen(productlist) NEQ qCheckProductValidity.RecordCount)>
		<cfloop List ="#productlist#" item="prod_ctr">
			<cfif (listFind(qProductList,trim(prod_ctr)) EQ 0)>
				<cfset InvalidProds = listAppend(InvalidProds, prod_ctr) />
			</cfif>
		</cfloop>
	<cfelse>
			<!--- TODO --->
			<!--- <cfloop index = "rawdata" list = "#trim(FORM.itemList)#" delimiters="#chr(13)#">
				<!--- <cfloop list="#qProductList#" index="indItem"> --->
				<cfloop query="qCheckProductValidity">
					<cfif (qCheckProductValidity.Item EQ ListGetAt(rawdata,1,delims))>
						<!--- <cfset NewItemlist = listappend(NewItemlist, ListGetAt(rawdata,1,delims))>
						<cfset NewItemlist = listappend(NewItemlist, ListGetAt(rawdata,2,delims))>
						<cfset NewItemlist = listappend(NewItemlist, ListGetAt(rawdata,3,delims))>

						<cfset NewItemlist = listappend(NewItemlist, #qCheckProductValidity.BSA_Foodservice_Items_Master_ID#)>
						 <cfset NewItemlist = listappend(NewItemlist, "|")>  --->
						<cfset ItemtoAdd =  ListGetAt(rawdata,1,delims) & "," & ListGetAt(rawdata,2,delims) & "," & ListGetAt(rawdata,3,delims) & "," & #qCheckProductValidity.BSA_Foodservice_Items_Master_ID# />
							<cfif NewItemlist EQ "">
								<cfset NewItemlist = ItemtoAdd />
							<cfelse>
								<cfset NewItemlist = NewItemlist & "|" & ItemtoAdd />
							</cfif>
					</cfif>
				</cfloop> 
			</cfloop>--->	
	</cfif> <!--- END <cfif (listLen(productlist) NEQ qCheckProductValidity.RecordCount)> --->
		<!--- <cfif (errorInFormat NEQ "" OR InvalidProds NEQ "")> --->
	<cfif (errorInFormat EQ "" AND InvalidProds EQ "")>
		<cfoutput>
		<script language="javascript">
			callerWindowObj = null;
	// ChromeFix :: dialogArguments is not defined
			if(typeof dialogArguments != 'undefined'){
				callerWindowObj = dialogArguments;
			}
			else{
				callerWindowObj = window.parent.opener;
			}
			callerWindowObj.document.all.dataForm.Product_List.value = "#qProductListIds#";
			callerWindowObj.document.all.dataForm.IS_Group.value = 0;
			callerWindowObj.document.all.dataForm.lsProdRates.value = "#ratelist#";
			callerWindowObj.document.all.dataForm.lsProdUOMs.value = "#uomlist#";
			callerWindowObj.document.all.dataForm.lsItemlist.value = "#qProductList#";
			callerWindowObj.document.all.dataForm.submit();
			window.close();
		</script>
		</cfoutput>
		<cfabort>	
	</cfif> <!--- END: <cfif (errorInFormat EQ 0 AND InvalidProds EQ "")> --->
</cfif> <!--- <cfif (form.submitted EQ 1)> --->
<cfoutput>
<!DOCTYPE HTML>
<HTML>
<HEAD>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<TITLE>Select Products</TITLE>
</HEAD>

<body>
	<cfset jQueryUI.version = '1.11.4'/>
	<cfinclude template="/Common_Files/jQuery.cfm">
	<cf_include files="#arrayToList( [
                                     "/common_files/datatable.css"
                                    ,"/common_files/viewmodes.css"
                                    ,"/Script/javascript/string_functions.js"
                                    ,"/Script/javascript/format_functions.js"
                                    ,"/styles/css-loader.css"
                                    ])#">


	<FORM ACTION="EZ_Product_List.cfm?EZTemplate=#url.EZTemplate#&CID=#url.CID#" METHOD="post" NAME="frmProductList" ID="frmProductList" style="display:inline">
		<a onClick="javascript:validate_form();" style="cursor:pointer;">#application.util.string.actionLinkFormat("save")#</a><br>
		<cfif (InvalidProds NEQ "" OR errorInFormat NEQ "")>
			<table width="400" border="1" bordercolor="red" cellspacing="0" cellpadding="2" align="center">
				<tr><td>

				<font color="red"><strong>
					ERROR:<br>
					<cfif (InvalidProds NEQ "")>
						 Below Products are not valid: #InvalidProds#.<br>
					</cfif>	
					<cfif (errorInFormat NEQ "")>
						  #errorInFormat#.<br>
					</cfif>	
					Correct the errors to continue...
					</strong></font>

				</td></tr>
			</table>
		</cfif>

		<table width="450" border=0 cellspacing=0 cellpadding=0 align="center">
			<tr><td colspan="3">&nbsp;</td></tr>
			<tr>
				<td>Product Number<span style="color:red;font-weight:bold"><br>(AlphaNumeric only)</span></td>
				<td>Product Rate<span style="color:red;font-weight:bold"><br>(Numeric only)</span></td>
				<td>
					UOM
					<img border="0" src="/Images/i.gif" width="12" height="11"
					title="To delete a Previously uploaded product from program, user should type DEL into UOM column. Once records are submitted products with UOM = DEL will be deleted">
					<span style="color:red;font-weight:bold"> <br>
						(CS / LB) <!--- / % / CWT / DEL --->
					</span>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<textarea ID="itemList" CLASS="itemList" NAME="itemList"  ROWS="20" COLS="30" STYLE="width:430px"><cfif (errorInFormat NEQ "" OR InvalidProds NEQ "")>#trim(form.itemList)#</cfif></textarea>
				</td>
			</tr>
		</table>
		<input type="hidden" name="submitted" value="1">
		<br><a onClick="javascript:validate_form();" style="cursor:pointer;">#application.util.string.actionLinkFormat("save")#</a>
	</FORM>
</cfoutput>

<script>
	function validate_form() {
		let is_product_box_empty = true;
		if ( document.getElementById( "itemList" ).value.trim().length != 0 ) 
		    is_product_box_empty = false;
		if ( is_product_box_empty ) {
				alert( 'Please paste product & rate info.' );
			}
		else{
			document.all.frmProductList.submit();
		}
	}
</script>
</body>
</HTML> 