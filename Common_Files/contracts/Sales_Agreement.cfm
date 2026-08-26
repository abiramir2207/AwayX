<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Sales Agreement</title>
<style type="text/css">	
	.TableHeaders 
	{
		font-family:Arial;
		font-size:11px;
		font-weight:bold;
	}
	.ProductTableHeader
	{
		font-family:Arial;
		font-size:10px;
		font-weight:bold;
		border-bottom:solid #93BEE2 1px;
	}
</style>
</head>

<cfparam name="CID" default="">
<cfparam name="url.EZTemplate" default="0">
<cfparam name="Form.product_list" default="">
<cfparam name="Export_Sales_Agreement_ID" default="">
<cfparam name="Form.Export_Sales_Agreement_Number" default="">
<cfparam name="Form.Export_Is_Sales_Agreement" default="1">
<cfparam name="Form.Export_Sales_Agreement_Name" default="">
<cfparam name="Form.Export_ASI_Contract_Number" default="">
<cfparam name="Form.start_date" default="#DateFormat(DateAdd('d',15,now()),'mm/dd/yyyy')#">
<cfparam name="Form.end_date" default="">
<cfparam name="Form.Export_Agreement_Validity" default="">
<cfparam NAME="Form.Export_Distributor_ID" default="">
<cfparam NAME="Form.Export_Distributor" default="">
<cfparam NAME="Form.Export_Shr_Bill_To" default="">
<cfparam name="Form.Export_Terms_of_Sale" default="">
<cfparam name="Form.Export_Named_Place" default="">
<cfparam name="Form.Export_Mexico_Port" default="">
<cfparam name="Form.Export_Origin" default="">
<cfparam name="Form.Export_Destination_Country" default="">
<cfparam name="Form.Export_Pallet_Indicator" default="">
<cfparam name="Form.Export_Pallet_Type" default="">
<cfparam NAME="Form.Distributor_List" default="">
<cfparam NAME="Form.Export_Shr_Ship_To" default="">
<cfparam NAME="Form.Export_Invoice_Terms_Desc" default="">
<cfparam NAME="Form.Export_Invoice_Terms" default="">
<cfparam NAME="Form.Export_Freight_Cost" default="">
<cfparam NAME="Form.Export_Additional_Freight_Cost" default="">
<cfparam NAME="Form.Export_Inland_Fuel_Surcharge" default="">
<cfparam NAME="Form.Export_Additional_Inland_Fuel_Surcharge" default="">
<cfparam NAME="Form.Export_Ocean_Fuel_Surcharge" default="">
<cfparam NAME="Form.Export_Additional_Ocean_Fuel_Surcharge" default="">
<cfparam NAME="Form.Export_Sticker_Type" default="">
<cfparam NAME="Form.Export_Internal_Notes" default="">
<cfparam NAME="Form.Export_Special_Conditions" default="">
<cfparam NAME="Form.Export_Notify_Party" default="">
<cfparam name="Form.Is_A_Revision" default="0">
<cfparam NAME="Action" default="">
<cfparam NAME="Responsible_User_Id_Position_Id" default="">

<cf_cryp type="de" key="#request.key#" string="#CID#">

<cfif len(CID) NEQ 0>
	<cfset Export_Sales_Agreement_ID = cryp.value>
</cfif>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<CFIF Get_Profile_Settings.Create_Export_Agreements EQ 0 AND Get_Profile_Settings.Create_Approve_Export_Agreements EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement_AJAX") />
<cfset Agreement_Manager = CreateObject("component","components.Export.Sales_Agreement") />

<cfset qry_Export_Terms_of_Sale = Agreement_Details.getTermsOfSale()>
<cfset qry_Export_Destination_Country = Agreement_Details.getDestination()>
<cfset qry_Export_Origin = Agreement_Details.getOrigin()>
<cfset qry_All_Export_Stickering_Types = Agreement_Details.getAllStickeringCosts()>

<!--- Get Standard and Misc Costs --->
<cfset qry_Export_Costs = Agreement_Details.getCost('Optional')>
<cfif Export_Sales_Agreement_ID neq "">
	<cfset qry_Export_Misc_Costs =  Agreement_Manager.getMiscCosts(Export_Sales_Agreement_ID)>
	<cfset qry_Export_Standard_Costs = Agreement_Details.getStandardCost(Export_Sales_Agreement_ID)>
<cfelse>
	<cfset qry_Export_Standard_Costs = QueryNew('Export_Cost_Desc,Export_Cost,Export_Additional_Cost')>
	<cfset qry_Export_Misc_Costs = QueryNew('Export_Misc_Cost_Desc,Export_Misc_Cost')>
</cfif>

<!--- This is the standard unit size per container --->
<cfset Units_Per_Container = 21>

<!--- Call the required component for AJAX Calls --->
<script type='text/javascript'>_ajaxConfig = {'_cfscriptLocation':'/components/Export/Sales_Agreement_AJAX.cfc', '_jsscriptFolder':'/Script/javascript/Ajax_JS','debug':false};</script>
<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>

<CF_MessageWindow>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT></script>
<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Date_functions.js"></SCRIPT>

<script language="javascript">
	function checkAllProd()
	{
		<cfloop list="#Form.Product_List#" index="product_id">
			<cfset prod_id = replace(product_id,"-","_", "ALL")>
			<cfset prod_check = "Prod_"&#prod_id#>
				if(document.all.prodCheck.checked)
				{
					document.all.<cfoutput>#prod_check#</cfoutput>.checked = true;
				}
				else{
					document.all.<cfoutput>#prod_check#</cfoutput>.checked = false;
				}
		</cfloop>
	}

	function getParentObject(thisObj, tagName)
	{
		if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
		{
			return thisObj;
		}
		else if(thisObj.tagName.toLowerCase() == "body"){
			return null;
		}
		else{
			return getParentObject(thisObj.parentElement, tagName);
		}
	}

	function deleteThisProduct(FieldNameRe, prodID)
	{	
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		
		FINALITEMLIST = document.Sales_Agreement_Frm.Product_List.value;

		var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
		var bDelete = true;
				
		if(resultString == FINALITEMLIST)
		{
			resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
			bDelete = false;
		}
		
		document.all.Product_List.value = resultString;
		document.all.ExistingProductList.value = resultString;
		//var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";	
		if(trObj)
		{			
			if(bDelete)
			{ 
				trObj.height = trObj.offsetHeight;
				//trObj.cells[trObj.cells.length-1].innerHTML = empty_String;
				
				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);				
				
				srcObj.alt = "undo product deletion";
				srcObj.src = undodeleteImg.src;
			}
			else{				
					var bgCol = "FFFFFF";
						if(trObj.rowIndex % 2 == 1)
						{
							bgCol = "C6FFC6";
						}

				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);
				
				srcObj.alt = "delete this product";
				srcObj.src = deleteImg.src;
				
				propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
			}
				srcObj.bDelete = !bDelete;
				trObj.bDelete = (bDelete?1:0);
		}		
		
	}

	/* Pop up window for product search */
	function showProductSearchWindow() {
			document.Sales_Agreement_Frm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";	
			NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=Sales_Agreement_Frm&Export_Sales_Agreement_ID&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>", "productwindow", 800, 600, "yes", "yes", true)
	}

	/* Pop up window for distributor search */
	function showDistSearchWindow() 
	{	
		document.Sales_Agreement_Frm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
		NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=Sales_Agreement_Frm&SelectSingleSearchResultOnly=1", "Sales_Agreement", 800, 600, "yes", "yes")
	}

	<!--- Main custom function for handling AJAX Calls --->
	function CheckValue(ControlName,Export_Sales_Agreement_ID,IsDisabled, ShowSelected)
	{

		/* This variable is being used for "getPalletIndicator" and "PalletType" functions. If it's undefined, then the two "Pallet Indicator"
		 and the "PalletType" select boxes should be reset */
		if(ShowSelected === undefined){
				ShowSelected = 0;
		}

	// Get the value from the select box which calls this function
	if(IsDisabled == 0){
			SelectedValue = eval("document.Sales_Agreement_Frm."+ControlName+".options[document.Sales_Agreement_Frm."+ControlName+".options.selectedIndex].value")
	}
	else{
			SelectedValue =	eval("document.Sales_Agreement_Frm."+ControlName+".value");
	}

		// If it's the "Terms of Sale" select box
		if(ControlName == 'Export_Terms_of_Sale'){
				DWREngine.setAsync(false);
				if(document.Sales_Agreement_Frm.Export_Origin.disabled == false){
					Origin = document.Sales_Agreement_Frm.Export_Origin.options[document.Sales_Agreement_Frm.Export_Origin.options.selectedIndex].value
				}
				else{
					Origin = document.Sales_Agreement_Frm.Export_Origin.value;
		}
				DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getNamedPlace', SelectedValue, Export_Sales_Agreement_ID, Origin, IsDisabled, Change_Value_Mexico_Prepaid_And_Named_Place);
				DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getMiscCost', Export_Sales_Agreement_ID, Get_Misc_Cost);
		}

		// If it's the "Origin" select box
		else if(ControlName == 'Export_Origin'){
			DWREngine.setAsync(false);
				if(IsDisabled == 0){
					TOS = document.Sales_Agreement_Frm.Export_Terms_of_Sale.options[document.Sales_Agreement_Frm.Export_Terms_of_Sale.options.selectedIndex].value
				}
				else{
					TOS =	document.Sales_Agreement_Frm.Export_Terms_of_Sale.value;
				}
				if(TOS ==1){
					DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getNamedPlace', TOS, Export_Sales_Agreement_ID, SelectedValue, IsDisabled, Change_Value_Mexico_Prepaid_And_Named_Place);
				}
		}

		// If it's the "Destination Country" select box
		else if(ControlName == 'Export_Destination_Country'){
			if(document.Sales_Agreement_Frm.Export_Destination_Country.disabled == false){
				DestinationCountry = document.Sales_Agreement_Frm.Export_Destination_Country.options[document.Sales_Agreement_Frm.Export_Destination_Country.options.selectedIndex].value
			}
			else{
				DestinationCountry = document.Sales_Agreement_Frm.Export_Destination_Country.value;
			}
				DWREngine.setAsync(false);
				DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getPalletIndicator', SelectedValue,Export_Sales_Agreement_ID, IsDisabled, ShowSelected, Change_Value_Pallet_Indicator);
				DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getPalletType', SelectedValue,DestinationCountry,Export_Sales_Agreement_ID, IsDisabled, ShowSelected, Change_Value_Pallet_Type);
		}

		// If it's the "Pallet Indicator" select box
		else if(ControlName == 'Export_Pallet_Indicator'){
			if(document.Sales_Agreement_Frm.Export_Destination_Country.disabled == false){
				 DestinationCountry = document.Sales_Agreement_Frm.Export_Destination_Country.options[document.Sales_Agreement_Frm.Export_Destination_Country.options.selectedIndex].value
			}
			else{
				 DestinationCountry = document.Sales_Agreement_Frm.Export_Destination_Country.value;
			}
				DWREngine.setAsync(false);
				DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getPalletType', SelectedValue,DestinationCountry,Export_Sales_Agreement_ID, IsDisabled, ShowSelected, Change_Value_Pallet_Type);
		}	

		// If it's the "Mexico_Port" or the "Named_Place" or the "Terms of Sale" or the "Origin" select boxes
		if(ControlName == 'Export_Mexico_Port' || ControlName == 'Export_Named_Place' ||  ControlName == 'Export_Terms_of_Sale' ||  ControlName == 'Export_Origin'){
			// If it's "Origin" select box
			if(document.Sales_Agreement_Frm.Export_Origin.disabled == false){
					Origin = document.Sales_Agreement_Frm.Export_Origin.options[document.Sales_Agreement_Frm.Export_Origin.options.selectedIndex].value
			}
			else{
					Origin = document.Sales_Agreement_Frm.Export_Origin.value;
			}	
			// If it's "Named Place" select box
			if(document.Sales_Agreement_Frm.Export_Named_Place.disabled == false){
					Named_Place = document.Sales_Agreement_Frm.Export_Named_Place.options[document.Sales_Agreement_Frm.Export_Named_Place.options.selectedIndex].value
			}
			else{
					Named_Place = document.Sales_Agreement_Frm.Export_Named_Place.value;
			}
			// If it's "Terms of Sale" select box
			if(IsDisabled == 0){
					TOS = document.Sales_Agreement_Frm.Export_Terms_of_Sale.options[document.Sales_Agreement_Frm.Export_Terms_of_Sale.options.selectedIndex].value
			}
			else{
					TOS =	document.Sales_Agreement_Frm.Export_Terms_of_Sale.value;
			}		
			// By Default, there are no available selections for "Mexico_Port", except when Terms of Sale is "DAF"
					Named_Place_Mexico = 0;	

					if(TOS ==5){
						Named_Place_Mexico = document.Sales_Agreement_Frm.Export_Mexico_Port.options[document.Sales_Agreement_Frm.Export_Mexico_Port.options.selectedIndex].value
					}

					DWREngine.setAsync(false);
					if(Named_Place_Mexico == 0){	
						// Get Freight for All "Terms of sale", except "DAF". (Note:There is no freight for "EXW")
						DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getFreight', Origin,Named_Place,TOS, Change_Freight);
					}
					else{
						// Get Freight for "DAF" term of sale
						DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getFreight', Origin,Named_Place_Mexico,TOS, Change_Freight);
					}			
				}
			}

	/* Loops through the standard cost elements and get the cost associated with that element */
	function getCostElements()
	{
		var Cost_desc_Array = new Array(); 
		var ArrayIndex;

			for (var i=0;i<Sales_Agreement_Frm.length;i++){ // loop through all elements 
				var name_=Sales_Agreement_Frm[i].name; // get element name 

					if(name_.indexOf('Export_Cost_Desc_')!=-1){
						ArrayIndex = name_.substring(17,name_.length);
							selectedValue = eval("document.Sales_Agreement_Frm."+name_+".options[document.Sales_Agreement_Frm."+name_+".options.selectedIndex].value")
								Cost_desc_Array[ArrayIndex-1] = selectedValue
					}
		}
						DWREngine.setAsync(false);
						DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getCostAmount', Cost_desc_Array, Change_Cost);
	}

	/* This function sets the values for "Export_Mexico_Prepaid_Frt_Destination" and "Export_Named_Place" */
	function Change_Value_Mexico_Prepaid_And_Named_Place(ReturnValue)
	{
			document.getElementById("Export_Named_Place_Table_id").innerHTML = ReturnValue[0];
			document.getElementById("Export_Mexico_Port_Table_id").innerHTML = ReturnValue[1];			
	}

	/* This function sets the values for "Export_Pallet_Indicator" */
	function Change_Value_Pallet_Indicator(ReturnValue)
	{
			document.getElementById("Export_Pallet_Indicator_Table_id").innerHTML = ReturnValue;
	}

	/* This function sets the values for "Export_Pallet_Type" */
	function Change_Value_Pallet_Type(ReturnValue)
	{	
			document.getElementById("Export_Pallet_Type_Table_id").innerHTML = ReturnValue;
	}

	/* This function sets the values for "Freight" */
	function Change_Freight(ReturnValue)
	{
			document.all.Export_Freight_Cost_id.value = ReturnValue[0];
			document.all.Export_Inland_Fuel_Surcharge_id.value = ReturnValue[1];
			document.all.Export_Ocean_Fuel_Surcharge_id.value = ReturnValue[2];
	
			// Freight
			if(ReturnValue[0] != 0)
			{
				document.getElementById("Export_Additional_Freight_Cost").disabled = false;
				document.getElementById("Export_Additional_Freight_Cost").style.background='ffffff';
			}
			else
			{
				document.getElementById("Export_Additional_Freight_Cost").disabled = true;
				document.getElementById("Export_Additional_Freight_Cost").style.background='cccccc';
				document.getElementById("Export_Additional_Freight_Cost").value='';
			}

			// Inland_Fuel_Surcharge
			if(ReturnValue[1] != 0)
			{
				document.getElementById("Export_Additional_Inland_Fuel_Surcharge").disabled = false;
				document.getElementById("Export_Additional_Inland_Fuel_Surcharge").style.background='ffffff';
			}
			else
			{
				document.getElementById("Export_Additional_Inland_Fuel_Surcharge").disabled = true;
				document.getElementById("Export_Additional_Inland_Fuel_Surcharge").style.background='cccccc';
				document.getElementById("Export_Additional_Inland_Fuel_Surcharge").value='';
			}

			// Ocean_Fuel_Surcharge
			if(ReturnValue[2] != 0)
			{
				document.getElementById("Export_Additional_Ocean_Fuel_Surcharge").disabled = false;
				document.getElementById("Export_Additional_Ocean_Fuel_Surcharge").style.background='ffffff';
			}
			else
			{
				document.getElementById("Export_Additional_Ocean_Fuel_Surcharge").disabled = true;
				document.getElementById("Export_Additional_Ocean_Fuel_Surcharge").style.background='cccccc';
				document.getElementById("Export_Additional_Ocean_Fuel_Surcharge").value='';
			}
	}

/* Show that standard cost element which has a cost (greater than 0) associated with it */
	function Change_Cost(ReturnValue)
	{
			document.all.Export_Cost_1_id.value = ReturnValue[0];

			var ObjectID;
				for(i=1;i<=ReturnValue.length-1;i++)
				{
					ObjectID = i + 1
					DisplayObject = document.getElementById('Export_Cost_'+ObjectID+'_id')
					DisplayObject.value = ReturnValue[i];
					DisplayObject = document.getElementById('Export_Cost_Row_id_'+ObjectID)
						if(ReturnValue[i-1] !=0){
							DisplayObject.style.display = ''
						}
				}
	}

/* If the standard cost selection from the select box is not any cost element, then hide the select box, else show it */
	function ShowData(ObjectID,ControlName)
	{
		SelectedValue = eval("document.Sales_Agreement_Frm."+ControlName+".options[document.Sales_Agreement_Frm."+ControlName+".options.selectedIndex].value");
		ObjectValue1= document.getElementById('Export_Cost_'+ObjectID).value
		ObjectValue2= document.getElementById('Export_Additional_Cost_'+ObjectID).value

			if(SelectedValue == '00'){
				document.getElementById('Export_Cost_Desc_'+ObjectID).value = 0;
				/* If the "add Cost" option does not exist, then add it. This will typically happen if the cost 
					 is already saved in the db. 
				*/
				if(document.getElementById('Export_Cost_Desc_'+ObjectID).value == '')
				{
					addOption = new Option("Add Cost","0"); 
					document.getElementById('Export_Cost_Desc_'+ObjectID).options[0] = addOption;
					document.getElementById('Export_Cost_Desc_'+ObjectID).value = 0;
				}

				ObjectID = ObjectID + 1;
				DisplayObject = document.getElementById('Export_Cost_Row_id_'+ObjectID)
				DisplayObject.style.display = 'none';
				ObjectValue1 ='0'
				ObjectValue2 ='0'
			}
			else{
				ObjectID = ObjectID + 1;
				DisplayObject = document.getElementById('Export_Cost_Row_id_'+ObjectID)
				DisplayObject.style.display = '';
			}
		}


/* Add a new miscellaneous cost field */
	function AddMiscCost()
	{
		document.all.Export_Misc_Cost_Header_id.style.display = ''

		for(i=1;i<=20;i++)
		{
			DisplayObject = document.getElementById('Export_Misc_Cost_Row_id_'+i)
				if(DisplayObject.style.display == 'none'){
					DisplayObject.style.display = ''
					break;
				}
		}
	}

/* If the user adds a cost value to the Misc cost field, then show it on save, else hide it */
	function Get_Misc_Cost(MiscCost)
	{
		if(MiscCost.length > 0){
			document.all.Export_Misc_Cost_Header_id.style.display = ''
		}
		for(i=1;i<=MiscCost.length;i++)
		{
			DisplayObject = document.getElementById('Export_Misc_Cost_Row_id_'+i)
				if(MiscCost[i-1] != 0 && MiscCost[i-1] != ''){
				DisplayObject.style.display = ''
				}
		}
	}

/* Get stickering cost */
	function getStickeringCost(Add_Sticker_Cost,Export_Stickering_Type,Export_Stickering_Product)
	{	
			if(Export_Stickering_Product != undefined && Export_Stickering_Product != ''){
				DWREngine.setAsync(false);	
				DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getStickeringCost',Add_Sticker_Cost,Export_Stickering_Type,Export_Stickering_Product,Change_Stickering_Cost);
				}
			else{
			/* When the change is for all the products */	
				DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getStickeringCost',Add_Sticker_Cost,Export_Stickering_Type,Export_Stickering_Product,ResetStickerRate);
			}
	}

/* Assign the stickering cost to the "Sticker Rate" textbox */
	function Change_Stickering_Cost(ReturnValue)
	{
			document.getElementById(ReturnValue[0]).value = ReturnValue[1];
	}

/* Grab the various cost elements on the page and use it to calculate "Export_Charge" and "Net_Sales_Price" */
	function getCostorNSP(Export_Sales_Agreement_ID,Obj_ID)
	{

		var counter = 0;
		var ProdID;
		var Required_Volume;
		var Volume_Limit;
		var	TotalVolume = 0;
		var FreightCost;
		var InlandFuelSurcharge;
		var OceanFuelSurcharge;
		var AdditionalFreightCost;
		var AdditionalInlandFuelSurcharge;
		var AdditionalOceanFuelSurcharge;

		var StandardCost = new Array;
		var ExportCost =  new Array;
		var ExportCostDesc =  new Array;
		var ExportCostDesc_CostNumber = new Array;
		var AdditionalCost = new Array;
		var AdditionalStandardCost = new Array;
		var MiscCost = new Array;
		var MiscCostDesc = new Array;
		var MiscCostDesc_CostNumber = new Array;
		var AddStickeringCost = new Array;
		var StickeringCost = new Array;
		var RelocationCost = new Array;
		var AccrualCost = new Array;
		var SalesCharge = new Array;
		var TargetNSP = new Array;

		var StandardCost_Array_Index = 0;
		var ExportCost_Array_Index =  0;
		var ExportCostDesc_Array_Index =  0;
		var AdditionalCost_Array_Index =  0;
		var AdditionalStandardCost_Array_Index =  0; 
		var MiscCost_Array_Index =  0;
		var MiscCostDesc_Array_Index =  0;
		var AddStickeringCost_Array_Index =  0;
		var StickeringCost_Array_Index = 0;
		var RelocationCost_Array_Index = 0;
		var AccrualCost_Array_Index = 0;
		var SalesCharge_Array_Index =  0;
		var TargetNSP_Array_Index =  0;
		
		for (var i=0;i<Sales_Agreement_Frm.length;i++){ // loop through all elements 
					var name_=Sales_Agreement_Frm[i].name; // get element name 
					var type_=Sales_Agreement_Frm[i].type; // get element type

			/* Initialize arrays to store different cost types */		
					StandardCost[0] = 0;
					ExportCost[0] = 0;
					ExportCostDesc[0] = 0;
					ExportCostDesc_CostNumber[0] = 0;
					AdditionalCost[0] = 0;
					RelocationCost[0] = 0
					AddStickeringCost[0] = 0
					StickeringCost[0] = 0
					AccrualCost[0] = 0
					SalesCharge[0] = 0;
					TargetNSP[0] = 0;
					AdditionalStandardCost[0] = 0;
					MiscCost[0] = 0;
					MiscCostDesc[0] = 0;
					MiscCostDesc_CostNumber[0] = 0;

		if(type_ == 'text' && (name_.indexOf('Export_Cost_')	!=-1 	|| name_.indexOf('Export_Freight_Cost')	!=-1 || name_.indexOf('Export_Inland_Fuel_Surcharge')	!=-1
		|| name_.indexOf('Export_Ocean_Fuel_Surcharge')	!=-1 )){

			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != '' && SelectedValue != 0){
					StandardCost_Array_Index = StandardCost_Array_Index + 1;

					// Store standard costs 
					StandardCost[StandardCost_Array_Index] = SelectedValue;
			}
		}

		if(type_ == 'text' && (name_.indexOf('Export_Cost_')	!=-1) && (name_.indexOf('Export_Cost_Desc')	==-1)){

			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");
			ExportCostDesc_SequenceNumber = name_.replace('Export_Cost_',"");

					ExportCost_Array_Index = ExportCost_Array_Index + 1;
					
					// Store Export costs 
					ExportCost[ExportCost_Array_Index] = SelectedValue;
					ExportCostDesc_CostNumber[ExportCost_Array_Index] = ExportCostDesc_SequenceNumber;
		}

		if(type_ == 'select-one' && (name_.indexOf('Export_Cost_Desc')	!=-1)){

			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

					ExportCostDesc_Array_Index = ExportCostDesc_Array_Index + 1;
					
					// Store Export costs 
					ExportCostDesc[ExportCostDesc_Array_Index] = SelectedValue;
		}
			
		if(type_ == 'text' && (name_.indexOf('Export_Freight_Cost')	!=-1)){

			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != ''){

					// Store Freight costs 
					FreightCost = SelectedValue;
			}
		}

		if(type_ == 'text' && (name_.indexOf('Export_Inland_Fuel_Surcharge')	!=-1)){

			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != ''){

					// Store Inland Fuel Surcharge
					InlandFuelSurcharge = SelectedValue;
			}
		}

		if(type_ == 'text' && (name_.indexOf('Export_Ocean_Fuel_Surcharge')	!=-1)){

			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != ''){

					// Store Inland Fuel Surcharge
					OceanFuelSurcharge = SelectedValue;
			}
		}

		if(type_ == 'text' && (name_.indexOf('Export_Additional_Cost_') !=-1)){
	
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

					AdditionalStandardCost_Array_Index = AdditionalStandardCost_Array_Index + 1;
	
					// Store additional standard cost
					AdditionalStandardCost[AdditionalStandardCost_Array_Index] = SelectedValue;
		}

		if(type_ == 'text' && (name_.indexOf('Export_Additional_Cost_') !=-1 || (name_.indexOf('Export_Misc_Cost_') !=-1 && name_.indexOf('Export_Misc_Cost_Desc')==-1)
		|| name_.indexOf('Export_Additional_Freight_Cost') !=-1 || name_.indexOf('Export_Additional_Ocean_Fuel_Surcharge') !=-1
		|| name_.indexOf('Export_Additional_Inland_Fuel_Surcharge')!=-1 )){
	
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != '' && SelectedValue != 0){
					AdditionalCost_Array_Index = AdditionalCost_Array_Index + 1;
	
					// Store additional standard costs (Invoice Charges)
					AdditionalCost[AdditionalCost_Array_Index] = SelectedValue;
			}
		}

		if(type_ == 'text' && (name_.indexOf('Export_Misc_Cost_') !=-1) && name_.indexOf('Export_Misc_Cost_Desc') ==-1){
	
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

					MiscCost_Array_Index = MiscCost_Array_Index + 1;
	
					// Store Misc Cost
					MiscCost[MiscCost_Array_Index] = SelectedValue;
		}

		if(type_ == 'text' && (name_.indexOf('Export_Misc_Cost_Desc') !=-1)){
	
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");
			MiscCostDesc_SequenceNumber = name_.replace('Export_Misc_Cost_Desc_',"");

					MiscCostDesc_Array_Index =MiscCostDesc_Array_Index + 1;
	
					// Store Misc Cost Description and the sequence number
					MiscCostDesc[MiscCostDesc_Array_Index] = SelectedValue;
					MiscCostDesc_CostNumber[MiscCostDesc_Array_Index] = MiscCostDesc_SequenceNumber;
		}

		if(type_ == 'text' && (name_.indexOf('Export_Additional_Freight_Cost') !=-1)){
	
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != ''){
	
					// Store Additional Freight Cost
					AdditionalFreightCost = SelectedValue;
			}
		}

		if(type_ == 'text' && (name_.indexOf('Export_Additional_Inland_Fuel_Surcharge') !=-1)){
	
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != ''){
	
					// Store Additional Inland Fuel Surcharge
					AdditionalInlandFuelSurcharge = SelectedValue;
			}
		}

		if(type_ == 'text' && (name_.indexOf('Additional_Ocean_Fuel_Surcharge') !=-1)){
	
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != ''){
	
					// Store Additional Ocean Fuel Surcharge
					AdditionalOceanFuelSurcharge = SelectedValue;
			}
		}

		if(type_ == 'text' &&  (name_.indexOf('Export_Origin_Relocation_Cost_') !=-1)){
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != ''){
		
					RelocationCost_Array_Index = RelocationCost_Array_Index + 1;

					// Store relocation Costs
					RelocationCost[RelocationCost_Array_Index] = SelectedValue;
			}
			
		}

		if(type_ == 'select-one' &&  (name_.indexOf('Export_Sticker') !=-1)){
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != ''){
					AddStickeringCost_Array_Index = AddStickeringCost_Array_Index + 1;
	
					// Add Sticker Cost?
					AddStickeringCost[AddStickeringCost_Array_Index] = SelectedValue;
			}
			
		}

		if(type_ == 'text' &&  (name_.indexOf('Export_Sticker_Rate_') !=-1)){
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != ''){
					StickeringCost_Array_Index = StickeringCost_Array_Index + 1;
	
					// Store Sticker Costs
					StickeringCost[StickeringCost_Array_Index] = SelectedValue;
			}
			
		}

		if(type_ == 'text' &&  (name_.indexOf('Export_Accrual_') !=-1)){
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != '' && SelectedValue != 0){
					AccrualCost_Array_Index = AccrualCost_Array_Index + 1;

					// Store Accrual Costs
					AccrualCost[AccrualCost_Array_Index] = SelectedValue;
			}
			
		}

		if(type_ == 'text' && name_.indexOf('Export_Sale_Unit_Price_') !=-1){

			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != '' && SelectedValue != 0){
				SalesCharge_Array_Index = SalesCharge_Array_Index + 1;

				// Store Sale Unit Price
				SalesCharge[SalesCharge_Array_Index] = SelectedValue;
			}
		}

		if(type_ == 'text' && name_.indexOf('Export_Target_Net_Sales_Price_') !=-1){

			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue != '' && SelectedValue != 0){
				TargetNSP_Array_Index = TargetNSP_Array_Index + 1;

				// Store Target NSP
				TargetNSP[TargetNSP_Array_Index] = SelectedValue;
			}
		}

		if(type_ == 'text' && name_.indexOf('Export_Volume_Limit_') !=-1){
			SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

			if(SelectedValue !=''){
				if(isNaN(SelectedValue) == 0){

						// Store Volume
						TotalVolume =  parseInt(TotalVolume) +  parseInt(SelectedValue);
				}
			}
			if(TotalVolume !=''){
				document.getElementById('TotalVolume').innerHTML = '<b>' + TotalVolume + '</b>';
				}
		}
		
		if(document.Sales_Agreement_Frm.Product_List){
			if(name_.indexOf('Export_Charge_')	!=-1){

				ProdID = name_.substring(14,name_.length);
				ProdID = ProdID.replace(/_/g,"-") // global replace
				if(document.Sales_Agreement_Frm.Export_Sticker_Type){
				ExportStickerType = document.Sales_Agreement_Frm.Export_Sticker_Type.options[document.Sales_Agreement_Frm.Export_Sticker_Type.options.selectedIndex].value;
				}
					DWREngine.setAsync(true);
				//DWREngine.setOrdered(false);

					/* I tried to add this argument (ExportStickerType) to the "getCostorNSP" function, but it did not work, CF7 probably does not accept more than 10 arguments.
						 That is why I added "UpdateStickeringData" function and other functions for updating the data in the db. 
					*/						
					DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getCostorNSP',Export_Sales_Agreement_ID,ProdID,TargetNSP,StandardCost,AdditionalCost,RelocationCost,AddStickeringCost,StickeringCost,AccrualCost,SalesCharge,ChangeCostorNSP);
					DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'UpdateStickeringData',Export_Sales_Agreement_ID,ExportStickerType,PlaceHolderFunction);
					
					if(MiscCostDesc.length > 1){
						DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'UpdateMiscCost',Export_Sales_Agreement_ID,MiscCost,MiscCostDesc,MiscCostDesc_CostNumber,PlaceHolderFunction);
					}
					if(ExportCostDesc.length > 1){
						DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'UpdateExportCost',Export_Sales_Agreement_ID,ExportCost,ExportCostDesc,AdditionalStandardCost,ExportCostDesc_CostNumber,PlaceHolderFunction);
					}
					if(FreightCost != ''){
						DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'UpdateStandardCosts',Export_Sales_Agreement_ID,FreightCost,AdditionalFreightCost,InlandFuelSurcharge,AdditionalInlandFuelSurcharge,OceanFuelSurcharge,AdditionalOceanFuelSurcharge,PlaceHolderFunction);
					}

					// Reset values stored in various cost arrays 
					RelocationCost[1] = 0;
					RelocationCost[2]= 0;
					RelocationCost[3]= 0;
					RelocationCost[4]= 0;
					StickeringCost[1]= 0;
					StickeringCost[2]= 0;
					StickeringCost[3]= 0;
					StickeringCost[4]= 0;
					AccrualCost[1]= 0;
					AccrualCost[2]= 0;
					AccrualCost[3]= 0;
					AccrualCost[4]= 0;
					SalesCharge[1]= 0;
					SalesCharge[2]= 0;
					SalesCharge[3]= 0;
					SalesCharge[4]= 0;
				}
			}
		}

	}
	//Do Nothing. This function is just a placeholder for AJAX.
	function PlaceHolderFunction()
	{
		return void(0)
	}
	// Set the value of "Export_Charge" and "Net_Sales_Price" to the calculated values
	function ChangeCostorNSP(ReturnValue)
	{

		var ElementName;
		var Result;

			if(document.Sales_Agreement_Frm.Product_List){
					ProdID = ReturnValue[2].replace(/-/g,"_") // global replace
					ElementName = 'Export_Charge_'+ProdID
					Result=parseFloat(ReturnValue[0]);
					Result = Result.toFixed(4);
						if(isNaN(Result) == 1){
								Result = '0.0000'
						}			 
			
						document.getElementById(ElementName).value = Result;

					ElementName = 'Export_Estimated_Net_Sales_Price_'+ProdID
					Result=parseFloat(ReturnValue[1]);
					Result = Result.toFixed(4);
						if(isNaN(Result) == 1){
								Result = '0.0000'
						}			
						document.getElementById(ElementName).value = Result;
				}
    }

	function SetStickerRateOnPageLoad(Export_Sales_Agreement_ID)
	{
		for (var i = 0; i<Sales_Agreement_Frm.length; i++){
					var name_=Sales_Agreement_Frm[i].name; // get element name 
					var type_=Sales_Agreement_Frm[i].type; // get element type

						if(type_ == 'text' && name_.indexOf('Export_Sticker_Rate')!=-1){
							Product_ID = name_.replace('Export_Sticker_Rate_',"");
							Product_ID = Product_ID.replace(/_/g,"-") // global replace
							DWREngine.setAsync(false);
							DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getStickeringCost','1',document.Sales_Agreement_Frm.Export_Sticker_Type.options[document.Sales_Agreement_Frm.Export_Sticker_Type.options.selectedIndex].value,Product_ID,Export_Sales_Agreement_ID,ResetStickerRateValueOnPageLoad);
						}
			}
	}

	function ResetStickerRateValueOnPageLoad(Export_Sticker_Data){		
			//If the product exists in the db
			if(Export_Sticker_Data.length == 3){	
				Export_Sticker_Data[0] = Export_Sticker_Data[0].replace(/-/g,"_") // global replace
				document.getElementById('Export_Sticker_'+Export_Sticker_Data[0]).value = Export_Sticker_Data[1];
				document.getElementById('Export_Sticker_Rate_'+Export_Sticker_Data[0]).value = Export_Sticker_Data[2];
				// If "No stickering Cost" option is Chosen OR "NO" option for an individual product
					if(Export_Sticker_Data[2] == 0){
							document.getElementById('Export_Sticker_'+Export_Sticker_Data[0]).disabled = true;
							document.getElementById('Export_Sticker_Rate_'+Export_Sticker_Data[0]).style.background='cccccc';
							document.getElementById('Export_Sticker_Rate_'+Export_Sticker_Data[0]).setAttribute('readOnly', true);
					}
			}
			//If the product does not exist in the db
			else{
					Export_Sticker_Data[0] = Export_Sticker_Data[0].replace(/-/g,"_") // global replace
			 // If "No stickering Cost" option is Chosen OR "NO" option for an individual product
					if(Export_Sticker_Data[1] == 0){
						document.getElementById('Export_Sticker_'+Export_Sticker_Data[0]).value = 0;
						document.getElementById('Export_Sticker_'+Export_Sticker_Data[0]).disabled = true;
						document.getElementById('Export_Sticker_Rate_'+Export_Sticker_Data[0]).style.background='cccccc';
						document.getElementById('Export_Sticker_Rate_'+Export_Sticker_Data[0]).setAttribute('readOnly', true);
					}
					else{
						document.getElementById('Export_Sticker_'+Export_Sticker_Data[0]).value = 1;
					}
					 document.getElementById('Export_Sticker_Rate_'+Export_Sticker_Data[0]).value = Export_Sticker_Data[1];
		}
	}

	function ResetStickerRate(Export_Sticker_Rate)
	{
		for (var i = 0; i<Sales_Agreement_Frm.length; i++){
					var name_=Sales_Agreement_Frm[i].name; // get element name 
					var type_=Sales_Agreement_Frm[i].type; // get element type

						if(type_ == 'select-one' && name_.indexOf('Export_Sticker_')!=-1 && name_.indexOf('Export_Sticker_Type')==-1){
								SelectedValue = document.Sales_Agreement_Frm.Export_Sticker_Type.options[document.Sales_Agreement_Frm.Export_Sticker_Type.options.selectedIndex].value;
									if(Export_Sticker_Rate[1] == ''){
									document.getElementById(name_).value = 0;
								}
								else
								{
									document.getElementById(name_).value = 1;
								}

						}
						if(type_ == 'text' && name_.indexOf('Export_Sticker_Rate')!=-1){
								SelectedValue = document.Sales_Agreement_Frm.Export_Sticker_Type.options[document.Sales_Agreement_Frm.Export_Sticker_Type.options.selectedIndex].value;
							if(Export_Sticker_Rate == ''){
									document.getElementById(name_).value =  '0.0000'
								}
								else
								{
									document.getElementById(name_).value =  Export_Sticker_Rate[1];
								}								
						}
				
			/* When there is no stickering cost */
					if(type_ == 'select-one' && name_.indexOf('Export_Sticker_')!=-1 && name_.indexOf('Export_Sticker_Type')==-1 && Export_Sticker_Rate[1] == 0)
						{
							document.getElementById(name_).value = 0;
							document.getElementById(name_).disabled = true;
						}
					if(type_ == 'text' && name_.indexOf('Export_Sticker_Rate')!=-1 && Export_Sticker_Rate[1] == 0)
						{
							document.getElementById(name_).style.background='cccccc';
							document.getElementById(name_).setAttribute('readOnly', true);
						}
			/* When there is a stickering cost */
					if(Export_Sticker_Rate[1] != 0){
							document.getElementById(name_).disabled = false;
						}
				}
	}

	// Show/Hide the Invoice charges for the standard cost elements
	function CostHideShow(){
	var CostID;
	for (var i = 0; i<Sales_Agreement_Frm.length; i++){
				var name_=Sales_Agreement_Frm[i].name; // get element name 
					if(name_.indexOf("Export_Cost_Desc_") != -1) {
							SelectedValue = eval("document.Sales_Agreement_Frm."+name_+".value");

						if(SelectedValue > 0){
							CostID = name_.substring(17,name_.length);
							document.getElementById("Export_Additional_Cost_"+CostID).disabled = false;
							document.getElementById("Export_Additional_Cost_"+CostID).style.background='ffffff';
						}
					}
			}
	}

  // Enable/Disable the date controls
	function EnableDisableDateBox()
	{
		if(document.Sales_Agreement_Frm.Export_Agreement_Validity[1].checked == true){
				document.Sales_Agreement_Frm.end_date.disabled = false;
				document.Sales_Agreement_Frm.end_date.style.background='ffffff';
				document.all.Cell_ID.innerHTML = ''
				document.images["calendar2"].disabled = false;
				document.images["down2"].disabled = false;
				document.images["up2"].disabled = false;
		}

		if(document.Sales_Agreement_Frm.Export_Agreement_Validity[0].checked == true){
				document.Sales_Agreement_Frm.end_date.disabled = true;
				document.Sales_Agreement_Frm.end_date.style.background='cccccc';
				document.all.Cell_ID.innerHTML = '<span style="color:red;font-weight:bold">(TBA)</span>';
				document.images["calendar2"].disabled = true;
				document.images["down2"].disabled = true;
				document.images["up2"].disabled = true;
				document.Sales_Agreement_Frm.end_date.value = ''
		}
	}

	// expects mm/dd/yyyy
	function convertValueToJSDate(oValue) {
			rawDataArray 	= oValue.split("/");
			tmpMonth 			= rawDataArray[0];
			tmpDay 				 = rawDataArray[1];
			tmpYear 			= rawDataArray[2];
			tmpMonth = tmpMonth - 1;
			tmpDate = new Date(tmpYear,tmpMonth,tmpDay);
		return tmpDate;
			}

	// converts date into mm/dd/yyyy
	function FormatDateValue(oValue) {
			var dd = oValue.getDate();
			var mm = oValue.getMonth()+1;//January is 0!
			var yyyy = oValue.getFullYear();

			if(dd<10){
				dd='0'+dd
			}
			if(mm<10){
				mm='0'+mm
			}			
		return mm+'/'+dd+'/'+yyyy;
		}

	function verifyFrm(Continue, Action, HeadQuarters, AgreementCreatedDate)
	{
		ErrorCount = 0;

		FromDate = new Date(document.Sales_Agreement_Frm.start_date.value);
		ToDate = new Date(document.Sales_Agreement_Frm.end_date.value);

		if(document.Sales_Agreement_Frm.start_date.value=='')
		{
			ErrorCount++;
			queueMessage("You must enter the start date ",  document.all.error_start_date);
		}
		else{
			clearQueue(document.all.error_start_date);
		}

	  for (var i = 0; i < document.Sales_Agreement_Frm.Export_Agreement_Validity.length; i++) 
		{
		/* If the pricing agreement requires an end date, ask the user to fill in */
				if(document.Sales_Agreement_Frm.Export_Agreement_Validity[i].checked == true &&  document.Sales_Agreement_Frm.Export_Agreement_Validity[i].value=='2' && document.Sales_Agreement_Frm.end_date.value=='')
				{
					ErrorCount++;
					queueMessage("You must enter the end date ",  document.all.error_end_date);
				}
				else{
					clearQueue(document.all.error_end_date);
				}
		}

		if(document.Sales_Agreement_Frm.end_date.value != ''){
			if(FromDate >= ToDate)
			{
				ErrorCount++;
				queueMessage("The End Date must be after the Start Date",  document.all.error_Check_Date_Diff);
			}
			else{
				clearQueue(document.all.error_Check_Date_Diff);
			}
		}

	//Set 1 day in milliseconds
	var one_day=1000*60*60*24
	var days_diff;
	
	/* By Default, the start date is 15 days ahead of the agreement created date. Headquarters can choose past dates, 
		 but the rest cannot.*/
	if(HeadQuarters  == 0){
		AgreementDate = convertValueToJSDate(AgreementCreatedDate); //This is already in "mm/dd/yyyy" format
		FromDate = FormatDateValue(FromDate); //"convertValueToJSDate" accepts date in "mm/dd/yyyy" format, so convert it.
		FromDate = convertValueToJSDate(FromDate);
		
		days_diff = days_between(FromDate,AgreementDate,true);

		if(days_diff < 15){
			ErrorCount++;
			queueMessage("The start date of the agreement cannot be less than 15 days from the agreement created date",  document.all.error_day_Diff);
			}
		else{
				clearQueue(document.all.error_day_Diff);
			}
	}

		if(document.Sales_Agreement_Frm.Export_Is_Sales_Agreement[0].checked == true && document.Sales_Agreement_Frm.Export_Shr_Ship_To.value == '')
		{
				ErrorCount++;
				queueMessage("You must select a value for Ship To",  document.all.error_Ship_To);
		}
		else{
				clearQueue(document.all.error_Ship_To);
		}

		if(Continue == 1){
			if(document.Sales_Agreement_Frm.Export_Notify_Party != null && document.Sales_Agreement_Frm.Export_Notify_Party.value == '')
			{
				ErrorCount++;
				queueMessage("Documentation Notify Party is a required field",  document.all.error_Export_Notify_Party);
			}	
			else{
				clearQueue(document.all.error_Export_Notify_Party);
			}
		}

		var ProdID;
		var Required_Volume;
		var Volume_Limit; 

		for (var i=0;i<Sales_Agreement_Frm.length;i++){ // loop through all elements 
				var name_=Sales_Agreement_Frm[i].name; // get element name 
					if(name_.indexOf('Export_Required_Volume_')!=-1){
							ProdID = name_.substring(23,name_.length);
							Required_Volume = eval('document.Sales_Agreement_Frm.Export_Required_Volume_'+ProdID);
							Volume_Limit = eval('document.Sales_Agreement_Frm.Export_Volume_Limit_'+ProdID);

					if(Required_Volume.value ==1 && Volume_Limit.value <=0){	
							Volume_Limit.focus();		
							ErrorCount++;
							queueMessage("You must enter the volume", eval('document.all.error_Vol_Limit_'+ProdID));	
					}
					else{
							clearQueue(eval('document.all.error_Vol_Limit_'+ProdID));
					}	
				}
		}

		if(ErrorCount == 0) {
			if(Action !=''){
					document.Sales_Agreement_Frm.action ="Sales_Agreement_Replicate.cfm?CID=<cfoutput>#CID#</cfoutput>&Action="+Action
			}
					document.Sales_Agreement_Frm.submit();
						if(Continue == 1){
								alert("The value in the accrual column is for NSP calculation only. Contact Luanne Joyce to set up accrual");
								window.location="Sales_Agreement_Edit_Menu.cfm?CID=<cfoutput>#CID#</cfoutput>"
						}
		}
		else{
			showMessageWindow();
			return false;
		}
	}
</script>

<!--- Get the details of the distributor selected from the pop up window next to "Ship_To".--->
<CFIF FORM.Distributor_List NEQ "">
	<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT bsafc.Name As Shr_Ship_To_Name,bsafc.Shr_Ship_To,bsafc.Invoice_Terms,invt.Inv_Code + '-' + invt.Description1 + ',' +  invt.Description2 As PayTermsDesc
		,dbt.Shr_Bill_To
		FROM BSA_Foodservice_Customers bsafc INNER JOIN Distributor_Bill_To dbt
		ON bsafc.Distributor_Bill_To_ID = dbt.Distributor_Bill_To_ID
		LEFT JOIN Invoice_Terms invt
		ON bsafc.Invoice_Terms = invt.Inv_Code
		WHERE bsafc.BSA_Foodservice_Customers_ID IN ('#Replace(FORM.Distributor_List,chr(44), chr(39)&chr(44)&chr(39), "ALL")#')
		AND bsafc.Deleted = 0
		AND bsafc.Active_Code = 'A'
		ORDER BY bsafc.Name
	</CFQUERY>
		<CFSET FORM.Export_Distributor_ID = FORM.Distributor_List>
		<CFSET FORM.Export_Shr_Ship_To = Dist_Search_Result.Shr_Ship_To>
		<CFSET FORM.Export_Distributor = Dist_Search_Result.Shr_Ship_To_Name>
		<CFSET FORM.Export_Shr_Bill_To = Dist_Search_Result.Shr_Bill_To>
		<CFSET FORM.Export_Invoice_Terms = Dist_Search_Result.Invoice_Terms>
		<CFSET FORM.Export_Invoice_Terms_Desc = Dist_Search_Result.PayTermsDesc>
</CFIF>	

<cfif Export_Sales_Agreement_ID neq "">

<!--- Get the sales agreement details --->
	<cfset selExportSalesAgreement = Agreement_Details.getExportSalesAgreement('#Export_Sales_Agreement_ID#')>

	<cfif selExportSalesAgreement.recordcount>
		<cfset Export_Sales_Agreement_ID = selExportSalesAgreement.Export_Sales_Agreement_ID>
		<cfset Form.Export_Sales_Agreement_Number = selExportSalesAgreement.Export_Sales_Agreement_Number>
		<cfset Form.Export_Is_Sales_Agreement = selExportSalesAgreement.Export_Is_Sales_Agreement>
		<cfset Form.Export_Sales_Agreement_Name = selExportSalesAgreement.Export_Sales_Agreement_Name>
		<cfset Form.Export_ASI_Contract_Number = selExportSalesAgreement.Export_ASI_Contract_Number>
		<cfset Form.start_date = selExportSalesAgreement.Export_start_date>
		<cfset Form.end_date = selExportSalesAgreement.Export_end_date>
		<cfset Form.Export_Agreement_Validity = selExportSalesAgreement.Export_Agreement_Validity>
		<cfset Form.Export_Terms_of_Sale = selExportSalesAgreement.Export_Terms_of_Sale>
		<cfset Form.Export_Named_Place = selExportSalesAgreement.Export_Named_Place>
		<cfset Form.Export_Mexico_Port = selExportSalesAgreement.Export_Mexico_Port>
		<cfset Form.Export_Origin = selExportSalesAgreement.Export_Origin>
		<cfset Form.Export_Destination_Country = selExportSalesAgreement.Export_Destination_Country>
		<cfset Form.Export_Pallet_Indicator = selExportSalesAgreement.Export_Pallet_Indicator>
		<cfset Form.Export_Pallet_Type = selExportSalesAgreement.Export_Pallet_Type>

		<CFIF FORM.Export_Distributor_ID EQ ""><!--- If the distributor search query does not return any records --->
			<cfset Form.Export_Shr_Ship_To = selExportSalesAgreement.Export_Shr_Ship_To>
			<cfset Form.Export_Distributor = selExportSalesAgreement.Export_Distributor>
			<cfset Form.Export_Shr_Bill_To = selExportSalesAgreement.Export_Shr_Bill_To>
			<cfset Form.Export_Distributor_ID = selExportSalesAgreement.Export_Distributor_ID>
		</CFIF>

<!--- When the distributor gets selected, these two fields (Invoice Terms and Invoice Terms Description)
			should be populated from the "Dist_Search_Result" query.--->
<CFIF trim(Form.Export_Invoice_Terms) EQ "">
	<cfset Form.Export_Invoice_Terms=selExportSalesAgreement.Export_Invoice_Terms>
</CFIF>

<CFIF trim(Form.Export_Invoice_Terms_Desc) EQ "">
	<cfset Form.Export_Invoice_Terms_Desc=selExportSalesAgreement.payTermsDesc>
</CFIF>

	<cfset Form.Export_Freight_Cost=selExportSalesAgreement.Export_Freight_Cost>
	<cfset Form.Export_Additional_Freight_Cost=selExportSalesAgreement.Export_Additional_Freight_Cost>
	<cfset Form.Export_Inland_Fuel_Surcharge=selExportSalesAgreement.Export_Inland_Fuel_Surcharge>
	<cfset Form.Export_Additional_Inland_Fuel_Surcharge=selExportSalesAgreement.Export_Additional_Inland_Fuel_Surcharge>
	<cfset Form.Export_Ocean_Fuel_Surcharge=selExportSalesAgreement.Export_Ocean_Fuel_Surcharge>
	<cfset Form.Export_Additional_Ocean_Fuel_Surcharge=selExportSalesAgreement.Export_Additional_Ocean_Fuel_Surcharge>
	<cfset Form.Export_Sticker_Type = selExportSalesAgreement.Export_Stickering_Cost_ID>
	<cfset Form.Export_Internal_Notes = selExportSalesAgreement.Export_Internal_Notes>
	<cfset Form.Export_Special_Conditions = selExportSalesAgreement.Export_Special_Conditions>
	<cfset Form.Export_Notify_Party = selExportSalesAgreement.Export_Notify_Party>
	<cfset Form.Is_A_Revision = selExportSalesAgreement.Is_A_Revision>
</cfif>
</cfif>

<cfset IsDisabled = 0>

<!--- If the program is a revision, disable certain controls on the page --->
<cfif Action eq "Revise" OR (Action eq "" AND Form.Is_A_Revision eq 1)>
	<cfset IsDisabled = 1>
</cfif>

<cfif len(CID) NEQ 0>
	<cfset CSL_Export_Sales_Agreement_ID = cryp.value>
</cfif>

<cfset CSL_CallingPageCode = "gi">
<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px;">
		<CFINCLUDE TEMPLATE="sales_agreement_status_legend.cfm">
	</div>
<cfelse>
		<CFINCLUDE TEMPLATE="sales_agreement_status_legend.cfm">
</cfif>

<!--- On copy of a program, clear the start_date, end_date and Export_Sales_Agreement_Name --->
<cfif Action eq "copy">
	<cfset Form.Export_Sales_Agreement_Number = "">
	<cfset Form.start_date = "">
	<cfset Form.end_date = "">
	<cfset Form.Export_Sales_Agreement_Name = "">
</cfif>

<body onLoad="<cfoutput><cfif FORM.Product_List NEQ "">SetStickerRateOnPageLoad('#Export_Sales_Agreement_ID#');</cfif>CheckValue('Export_Terms_of_Sale','#Export_Sales_Agreement_ID#','#IsDisabled#');CheckValue('Export_Destination_Country','#Export_Sales_Agreement_ID#','#IsDisabled#',1);CheckValue('Export_Pallet_Indicator','#Export_Sales_Agreement_ID#','#IsDisabled#',1);getCostElements();getCostorNSP('#Export_Sales_Agreement_ID#','');CostHideShow();EnableDisableDateBox();</cfoutput>">

<cfoutput>
<form method="post" action="Sales_Agreement_Action.cfm?CID=#CID#" name="Sales_Agreement_Frm">

<input type="hidden" name="Responsible_User_Id_Position_Id" value="#Responsible_User_Id_Position_Id#">

<table border="0" width="80%" cellpadding="2">
<!--- If a program is approved as a sales agreement, then they cannot convert a sales agreement into an offer 
			and so disable the offer option --->
	<tr>
			<td width="10%">&nbsp;</td>
			<td align="right" width="27%" class="TableHeaders"><input type="radio" name="Export_Is_Sales_Agreement" value="1" <cfif Form.Export_Is_Sales_Agreement eq 1>checked</cfif>>Sales Agreement</td>
			<td colspan="2" align="left" class="TableHeaders"><input type="radio" name="Export_Is_Sales_Agreement" value="0" <cfif Form.Export_Is_Sales_Agreement eq 0>checked</cfif>
			<cfif IsDefined("selExportSalesAgreement.Approved")>
				<cfif (((Action eq "" AND Form.Is_A_Revision eq 1) OR Action eq "Revise") AND Form.Export_Is_Sales_Agreement EQ 1)>DISABLED</cfif></cfif>>Offer</td>
	</tr> 
	<tr>
			<td>&nbsp;</td>
			<td align="right" width="27%" class="TableHeaders">Sales Agreement ##:</td>
			<td align="left" colspan="2"><input type="text" size="13" name="Export_Sales_Agreement_Number" value="#Form.Export_Sales_Agreement_Number#" style="background-color: ##cccccc" READONLY>
	</tr>
	<tr>
			<td>&nbsp;</td>
			<td  align="right" width="27%" class="TableHeaders">Sales Agreement Name:</td>
			<td align="left" colspan="2"><input type="text" size="40" name="Export_Sales_Agreement_Name" value="#Form.Export_Sales_Agreement_Name#"></td>
	</tr>
	<tr>
			<td>&nbsp;</td>
			<td  align="right" width="27%" class="TableHeaders">ASI Contract/Invoice ##:</td>
			<td align="left" colspan="2"><input type="text" size="20" name="Export_ASI_Contract_Number" value="#Form.Export_ASI_Contract_Number#"></td>
	</tr>
	<tr>
			<td>&nbsp;</td>
			<td align="right" width="27%" valign="top" class="TableHeaders"><span id="error_start_date"></span><span id="error_Check_Date_Diff"></span><span id="error_day_Diff"></span>Validity Date:</td>
			<td>Start:<CF_EASYDATE FORMNAME="Sales_Agreement_Frm" FIELDNAME="start_date" FORMAT="mm/dd/yyyy" DEFAULT="#Form.start_date#" DisableObject="#IsDisabled#"></td>
			<td width="40%"><span id="error_end_date"></span>End:&nbsp;<span id="Cell_ID"><span style="color:red;font-weight:bold"><cfif Form.end_date eq "">(TBA)</cfif></span></span>
			<CF_EASYDATE FORMNAME="Sales_Agreement_Frm" FIELDNAME="end_date" ISVALIDATE="0" FORMAT="mm/dd/yyyy" DEFAULT="#Form.end_date#" DisableObject="1"></td>
	</tr>
	<tr>
		<td colspan="100%">
			<table border="0">
					<tr>
						<td width="26%">&nbsp;</td>
						<td class="TableHeaders">This pricing agreement remains in affect until it is changed or terminated</td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td class="TableHeaders"><input type="radio" name="Export_Agreement_Validity" value="1" onClick="EnableDisableDateBox()" <cfif Form.Export_Agreement_Validity eq 1 or Form.Export_Agreement_Validity eq "">checked</cfif>>Price is subject to change at any time with 30 days notice</td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td class="TableHeaders"><input type="radio" name="Export_Agreement_Validity" value="2" onClick="EnableDisableDateBox()" <cfif Form.Export_Agreement_Validity eq 2>checked</cfif>>Prices are valid for the validity period shown</td>
					</tr>
			</table>
		</td>		
	</tr>
	</table>
	<table border="0" width="80%" cellpadding="2">
	<tr class="TableHeaders">
			<td width="18%">&nbsp;</td>
			<td align="right" width="10%">Customer:</td>
			<td width="20%"><input type="text" size="20" name="Export_Distributor" VALUE="#FORM.Export_Distributor#" style="background-color: ##cccccc" READONLY></td>
			<td align="right" width="15%">Bill To:</td>
			<td><input type="text" size="7" name="Export_Shr_Bill_To" value="#FORM.Export_Shr_Bill_To#" style="background-color: ##cccccc" READONLY></td>
	</tr>

	<tr class="TableHeaders">
			<td>&nbsp;</td>
			<td align="right"><span id="error_Ship_To"></span>Ship To:</td>
			<td><INPUT NAME="Export_Shr_Ship_To" ID="Export_Shr_Ship_To" SIZE="7" VALUE="#Form.Export_Shr_Ship_To#" style="background-color: ##cccccc" READONLY>
			<a href="javascript: void(0);" <cfif IsDisabled eq 0>onClick="javaScript: showDistSearchWindow();" <cfelse> onClick="alert('To change the customer, please create a new program.');"</cfif>><IMG border="0" src="/images/searchtool.gif" id="searchImage" name="searchImage"></a>
			<B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="##" <cfif IsDisabled eq 0>ONCLICK="Javascript: document.all.Sales_Agreement_Frm.Export_Shr_Ship_To.value='';document.all.Sales_Agreement_Frm.Export_Shr_Bill_To.value='';document.all.Sales_Agreement_Frm.Export_Distributor.value='';document.all.Sales_Agreement_Frm.Export_Invoice_Terms_Desc.value='';return false;"<cfelse>onClick="alert('To change the customer, please create a new program.');return false;";</cfif>>reset</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></td>
			<td align="right">Invoice Terms:</td>
			<td><input type="text" size="40" name="Export_Invoice_Terms_Desc" ID="Export_Invoice_Terms_Desc" VALUE="#Form.Export_Invoice_Terms_Desc#" style="background-color: ##cccccc" READONLY>
					<input type="hidden" name="Export_Invoice_Terms" value="#Form.Export_Invoice_Terms#">
					<input type="hidden" name="Export_Distributor_ID" value="#Form.Export_Distributor_ID#">
			</td>
	</tr>
	<tr class="TableHeaders">
			<td>&nbsp;</td>
			<td align="right">TOS:</td>
			<td>
			<select name="Export_Terms_of_Sale" onChange="CheckValue('Export_Terms_of_Sale','#Export_Sales_Agreement_ID#','#IsDisabled#')" <cfif IsDisabled>disabled</cfif>>
						<option value="0">None</option>
				<cfloop query="qry_Export_Terms_of_Sale">
						<option value="#Export_Lookup_Terms_of_Sale_ID#" <cfif Form.Export_Terms_of_Sale eq Export_Lookup_Terms_of_Sale_ID>selected</cfif>>#Export_Lookup_Terms_of_Sale_Desc#</option>
				</cfloop>
			</select>
			</td>
			<td align="right">Named Place:</td>
			<td id="Export_Named_Place_Table_id">
					<select name="Export_Named_Place" <cfif IsDisabled>disabled</cfif>>
						<option value="0">None</option>
					</select>
			</td>
	</tr>
	<tr class="TableHeaders">
			<td colspan="3">&nbsp;</td>
			<td align="right">Mexico Prepaid<br />Frt Destination:</td>
			<td id="Export_Mexico_Port_table_id">
					<select name="Export_Mexico_Port" <cfif IsDisabled>disabled</cfif>>
						<option value="0">None</option>
					</select>
			</td>
	</tr>
	<tr class="TableHeaders">
			<td>&nbsp;</td>
			<td align="right">Origin:</td>
			<td>
			<select name="Export_Origin" onChange="CheckValue('Export_Origin','#Export_Sales_Agreement_ID#','#IsDisabled#');" <cfif IsDisabled>disabled</cfif>>
						<option value="0">None</option>
				<cfloop query="qry_Export_Origin">
						<option value="#Export_Lookup_Origin_Code#" <cfif Form.Export_Origin eq Export_Lookup_Origin_Code>selected</cfif>>#Export_Lookup_Origin_Desc#</option>
				</cfloop>
			</select>
			</td>
			<td align="right">Destination<br />Country:</td>
			<td><select name="Export_Destination_Country"  onChange="CheckValue('Export_Destination_Country','#Export_Sales_Agreement_ID#','#IsDisabled#')" <cfif IsDisabled>disabled</cfif>>
						<option value="0">None</option>
			<cfloop query="qry_Export_Destination_Country">
						<option value="#Export_Lookup_Destination_Country_ID#" <cfif Form.Export_Destination_Country eq Export_Lookup_Destination_Country_ID>selected</cfif>>#Export_Lookup_Destination_Country_Desc#</option>
			</cfloop>
					</select>
			</td>
	</tr>
	<tr class="TableHeaders">
			<td>&nbsp;</td>
			<td align="right">Pallet<br />Indicator:</td>
			<td id ="Export_Pallet_Indicator_Table_id">
					<select name="Export_Pallet_Indicator" <cfif IsDisabled>disabled</cfif>>
						<option value="0">No</option>
					</select>
			</td>
			<td align="right">Pallet Type:</td>
			<td id ="Export_Pallet_Type_Table_id">
					<select name="Export_Pallet_Type" <cfif IsDisabled>disabled</cfif>> 
						<option value="0">None</option>
					</select>
			</td>
	</tr>
</table>

<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#Form.Distributor_list#">
<INPUT TYPE="Hidden" NAME="CID" 	VALUE="#CID#">
<INPUT TYPE="Hidden" NAME="Is_A_Revision" 	VALUE="#Form.Is_A_Revision#">

<p>

<table border="0" width="80%" cellspacing="2">
	<tr class="TableHeaders">
			<td width="20%">&nbsp;</td>
			<td width="15%" style="text-decoration:underline">INVOICE INSTRUCTIONS</td>
			<td width="10%">&nbsp;</td>
			<td>&nbsp;</td>
	</tr>
	<tr class="TableHeaders">
			<td>&nbsp;</td>
			<td>Cost Elements</td>
			<td>Cost</td>
			<td>Invoice Charges</td>
	</tr>
	<tr class="TableHeaders">
			<td>&nbsp;</td>
			<td>Total Freight Costs:</td>
			<td><input type="text" name="Export_Freight_Cost" size="10" id="Export_Freight_Cost_id" value="#Form.Export_Freight_Cost#" style="background-color: ##cccccc" READONLY></td>
			<td><input type="text" name="Export_Additional_Freight_Cost" id="Export_Additional_Freight_Cost" size="10" value="#Form.Export_Additional_Freight_Cost#" style="background-color: ##cccccc" disabled></td>
	</tr>
	<tr class="TableHeaders">
			<td>&nbsp;</td>
			<td>Inland Fuel Surcharge:</td>
			<td><input type="text" name="Export_Inland_Fuel_Surcharge" size="10" id="Export_Inland_Fuel_Surcharge_id" value="#Form.Export_Inland_Fuel_Surcharge#" style="background-color: ##cccccc" READONLY></td>
			<td><input type="text" name="Export_Additional_Inland_Fuel_Surcharge" id="Export_Additional_Inland_Fuel_Surcharge" size="10" value="#Form.Export_Additional_Inland_Fuel_Surcharge#" style="background-color: ##cccccc" disabled></td>
	</tr>
	<tr class="TableHeaders">
			<td>&nbsp;</td>
			<td>Ocean Fuel Surcharge:</td>
			<td><input type="text" name="Export_Ocean_Fuel_Surcharge" size="10" id="Export_Ocean_Fuel_Surcharge_id" value="#Form.Export_Ocean_Fuel_Surcharge#"style="background-color: ##cccccc" READONLY></td>
			<td><input type="text" name="Export_Additional_Ocean_Fuel_Surcharge" id="Export_Additional_Ocean_Fuel_Surcharge" size="10" value="#Form.Export_Additional_Ocean_Fuel_Surcharge#" style="background-color: ##cccccc" disabled></td>
	</tr>
	<tr class="TableHeaders">
			<td>&nbsp;</td>
			<td>
				<select name="Export_Cost_Desc_1" onChange="getCostElements('Export_Cost_Desc_1');ShowData(1,'Export_Cost_Desc_1');CostHideShow();">
				 <option value="0">Add Cost</option>
			<cfloop query="qry_Export_Costs">
					<option value="#Export_Lookup_Cost_ID#" <cfif Export_Lookup_Cost_ID eq qry_Export_Standard_Costs.Export_Cost_Desc[1]>selected</cfif>>#Export_Lookup_Cost_Desc#</option>
			</cfloop>
				</select>
			</td>
			<td id=""><input type="text" name="Export_Cost_1" size="10" id="Export_Cost_1_id" value="#qry_Export_Standard_Costs.Export_Cost[1]#" style="background-color: ##cccccc" READONLY></td>
			<td><input type="text" name="Export_Additional_Cost_1" id="Export_Additional_Cost_1" size="10" value="#qry_Export_Standard_Costs.Export_Additional_Cost[1]#" style="background-color: ##cccccc" disabled></td>
	</tr>

<cfloop from="2" to="30" index="i">
	<tr id="Export_Cost_Row_id_#i#" style="display:none" class="TableHeaders">
			<td>&nbsp;</td>
			<td>
				<select name="Export_Cost_Desc_#i#" onChange="getCostElements();ShowData(#i#,'Export_Cost_Desc_#i#');CostHideShow();">
				 <cfif qry_Export_Standard_Costs.Export_Cost[i] eq 0 OR qry_Export_Standard_Costs.Export_Cost[i] eq ''> <option value="0">Add Cost</option></cfif>
					<option value="00">Remove Cost</option>
			<cfloop query="qry_Export_Costs">
					<option value="#Export_Lookup_Cost_ID#" <cfif Export_Lookup_Cost_ID eq qry_Export_Standard_Costs.Export_Cost_Desc[i]>selected</cfif>>#Export_Lookup_Cost_Desc#</option>
			</cfloop>
				</select>
			</td>
			<td><input type="text" name="Export_Cost_#i#" size="10" id="Export_Cost_#i#_id" value="#qry_Export_Standard_Costs.Export_Cost[i]#" style="background-color: ##cccccc" READONLY></td>
			<td><input type="text" name="Export_Additional_Cost_#i#" id="Export_Additional_Cost_#i#" size="10" value="#qry_Export_Standard_Costs.Export_Additional_Cost[i]#" style="background-color: ##cccccc" disabled></td>
	</tr>
</cfloop>

	<tr id="Export_Misc_Cost_Header_id" style="display:none" class="TableHeaders">
		<td>&nbsp;</td>
		<td colspan="100%">Misc Invoice Charge:</td>
	</tr>
	<cfloop from="1" to="20" index="i">
	<tr id="Export_Misc_Cost_Row_id_#i#" style="display:none">
		<td>&nbsp;</td>
		<td>#i#.&nbsp;<input type="text" name="Export_Misc_Cost_Desc_#i#" value="#qry_Export_Misc_Costs.Export_Misc_Cost_Desc[i]#"></td>
		<td>&nbsp;</td>
		<td><input type="text" name="Export_Misc_Cost_#i#" size="10" value="#qry_Export_Misc_Costs.Export_Misc_Cost[i]#"></td>
	</tr>
	</cfloop>	
	<tr>
		<td>&nbsp;</td>
		<td colspan="3"><B><FONT COLOR="red" SIZE="2">[ </FONT><a href="javascript:void(0);" onClick="AddMiscCost()">Add Misc Invoice Charge</a><FONT COLOR="Red" SIZE="2"> ]</FONT></B></td>
	</tr>
</table>
</cfoutput>

<cfif Export_Sales_Agreement_ID neq "">
<p>

<CFQUERY NAME="getProducts" datasource="#application.datasource#">
	SELECT distinct bfim.BSA_Foodservice_Items_Master_ID,bfim.Item,ep.BSA_Foodservice_Items_Master_ID As Added_ProdID,IsNull(bfim.height,0) As height ,IsNull(bfim.length,0) As length
	,IsNull(bfim.width,0) As width,IsNull(bfim.cases_Layer,0) As cases_layer,IsNull(bfim.gross_weight,0) As gross_weight
	,IsNull(bfim.net_weight,0) As net_weight,IsNull(ep.Export_Target_Net_Sales_Price,0) As Export_Target_Net_Sales_Price
	,IsNull(ep.Export_Sale_Unit_Price,0) As Export_Sale_Unit_Price,ep.Export_Sticker
	,IsNull(ep.Export_Sticker_Rate,0) As Export_Sticker_Rate,IsNull(ep.Export_Accrual,0) As Export_Accrual
	,IsNull(ep.Export_Charge,0) As Export_Charge,IsNull(ep.Export_Estimated_Net_Sales_Price,0) As Export_Estimated_Net_Sales_Price
	,ep.Export_End_User,ep.Export_Required_Volume,ep.Export_Volume_Limit
	FROM	BSA_Foodservice_Items_Master bfim 
	<cfif FORM.Product_List NEQ "">LEFT JOIN<cfelse>INNER JOIN</cfif>
	Export_Products ep
	ON  bfim.BSA_Foodservice_Items_Master_ID = ep.BSA_Foodservice_Items_Master_ID
	AND ep.Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'	
	AND ep.Deleted = 0
	<CFIF FORM.Product_List NEQ "">
	WHERE bfim.BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.Product_List, "'", ",")#)
	</CFIF>
	ORDER BY Item
</CFQUERY>

<cfif FORM.Product_List EQ "">
	<cfset FORM.Product_List = ValueList(getProducts.BSA_Foodservice_Items_Master_ID)>
</cfif>

<cfif getProducts.recordcount GT 4>
	<cfset divHght = "height:300px;" />
	<cfset divWidth = "width:820px;" />
<cfelse>
	<cfset divHght = "" />
	<cfset divWidth = "" />
</cfif>

	<table border="0" cellpadding="2" width="80%" align="center">
		<tr>
			<td class="TableHeaders" align="center">Relocation: &nbsp;<B><FONT COLOR="red" SIZE="2">( </FONT></B><span style="color:red;font-weight:bold;">varies per item</span><B><FONT COLOR="red" SIZE="2"> )</FONT></B></td>
		</tr>
		<tr>
			<td class="TableHeaders" align="center">Sticker Costs: &nbsp;<B><FONT COLOR="red" SIZE="2">( </FONT></B><span style="color:red;font-weight:bold;">varies per item</span><B><FONT COLOR="red" SIZE="2"> )</FONT></B></td>
		</tr>
	<cfoutput>
		<tr>
			<td align="center">
					<select name="Export_Sticker_Type" id="Export_Sticker_Type" onChange="getStickeringCost(1,this.value);">
						<option value="0">No Sticker Costs</option>
					<cfloop query="qry_All_Export_Stickering_Types">
						<option value="#Export_Stickering_Cost_ID#" <cfif Form.Export_Sticker_Type eq Export_Stickering_Cost_ID>selected</cfif>>#Export_Stickering_Cost_Desc#</option>
					</cfloop>
					</select>
			</td>
		</tr>
	</cfoutput>
	</table>

<!--- (Start) if products Exist --->
<cfif IsDefined("getProducts.recordcount") AND getProducts.recordcount gt 0>

	<cfif Export_Sales_Agreement_ID neq "" AND selExportSalesAgreement.Export_Lookup_Max_Weight neq "">
	<!--- Get the maximum loadable area (Height and Weight) --->
		<cfset LoadableArea = Agreement_Details.getMaxLoadableArea(Form.Export_Pallet_Indicator,selExportSalesAgreement.Export_Lookup_Max_Weight)>
			<cfset Max_Height = LoadableArea[1]>
			<cfset Max_Weight = LoadableArea[2]>
	<cfelse>
			<cfset Max_Height = 0>
			<cfset Max_Weight = 0>
	</cfif>

	<p>
	<cfoutput>
	<table width="80%" border="0" align="center">
		<tr>
			<td align="center">

			<cfif IsDefined("getProducts.recordcount") AND getProducts.Added_ProdID neq "">
				<span style="font-weight:bold;color:red"> [ </span> 
				<a href="##" OnClick="getCostorNSP('#Export_Sales_Agreement_ID#','');return false;" style="font-weight:bold;">Calculate</a>
				<span style="font-weight:bold;color:red"> ] </span>
			</cfif>

		<cfif Export_Sales_Agreement_ID neq "">
				<span style="font-weight:bold;color:red"> [ </span> 
				<a href="##" OnClick="javascript:return verifyFrm(0,'#Action#','#Get_Profile_Settings.Create_Approve_Export_Agreements#','#DateFormat(CSLGetContractInfo.Agreement_Created_Date,'MM/DD/YYYY')#');return false;" style="font-weight:bold;">Save</a>
				<span style="font-weight:bold;color:red"> ] </span>
			<CF_smallLink 
				title = "Add Products" 
				url = "##"
				parameters = "onClick=""javascript: return showProductSearchWindow();""">
				<br /><br />
		</cfif>
		</td>
	</tr>
</table>
</cfoutput>
	<table  border="0" align ="center" cellpadding="2" cellspacing="0" width="800">
				<tr class="ProductTableHeader" bgcolor="ffce84">
					<td><img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" alt="delete all products in this page" border="0" onClick="deleteAll('Prod_');" style="cursor: hand;"></NOBR></td>
					<td><input name="prodCheck" type="checkbox" onClick="checkAllProd()" checked Disabled></td>
					<td>Note</td>
					<td>Item#</td>
					<td>Target NSP</td>
					<td>Sale Unit Price</td>
					<td>Relocation</td>
					<td>Sticker?</td>
					<td>Sticker Rate</td>
					<td>Accrual</td>
					<td>Cost/Chg</td>
					<td>Est NSP</td>
					<td>End User</td>
					<td>Req Vol?</td>
					<td>Vol Limit</td>
				</tr>
	
		<cfset Total_Export_Volume = 0>

			<cfoutput query ="getProducts">
				<!--- Calculate Total Volume --->
				<cfif Export_Volume_Limit neq "">
					<cfset Total_Export_Volume = Total_Export_Volume + Export_Volume_Limit>
				</cfif>

				<cfset FieldNameEnd = replace(getProducts.BSA_Foodservice_Items_Master_ID,"-","_", "ALL")>
				<!--- Get the "relocation cost" of a product from the place of manufacturing to the place of shipment --->
				<cfset Export_Origin_Relocation_Cost = Agreement_Details.getRelocationCost(getProducts.BSA_Foodservice_Items_Master_ID,Form.Export_Origin)>
				<cfset Number_of_Layers = 0>

				<!--- Divide the loadable height by an individual product's height to get the number of layers --->
					<cfif getProducts.height GT 0>
						<cfset Number_of_Layers = Int(Max_Height/getProducts.height)>
					</cfif>

				<!--- Calculate how many cases will fit in a container --->
				<cfset Cases_Per_Container = 0>
					<cfif getProducts.cases_Layer GT 0 AND Number_of_Layers GT 0>
						<cfset Cases_Per_Container = getProducts.cases_Layer * Number_of_Layers * Units_Per_Container>
					</cfif>
		
				<cfset Max_Case_Loadability = 0>

				<!--- Calculate Case Loadability --->
					<cfif Cases_Per_Container neq 0 AND getProducts.gross_weight GT 0>
						<cfset Case_Loadability = Cases_Per_Container * getProducts.gross_weight>
			
				<!--- Calculate Maximum Case Loadability --->
						<cfif Case_Loadability GT Max_Weight>
							<cfset Max_Case_Loadability = INT(Max_Weight / getProducts.gross_weight)>
						<cfelse>
							<cfset Max_Case_Loadability = INT(Cases_Per_Container)>
						</cfif>
					</cfif>
	
				<cfset Net_Loadability = 0>

				<!--- Calculate Net Loadability --->
					<cfif Max_Case_Loadability GT 0 AND getProducts.net_weight GT 0>
						<cfset Net_Loadability = Max_Case_Loadability * getProducts.net_weight>
					</cfif>

				<input type="hidden" name="Export_Net_Loadability_#FieldNameEnd#" value="#Net_Loadability#" ID="Export_Net_Loadability_#FieldNameEnd#">
		
			<cfset rowcount = getProducts.currentrow>
			
				<tr BGCOLOR="#IIf(rowcount Mod 2, DE('C6FFC6'), DE('ffffff'))#" ID="TR_Products" PRODUCT_ID_RE="#FieldNameEnd#" bDelete="0">
					<td style="border-bottom:solid ##93BEE2 1px;"><img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" alt="click here to delete this product" border="0" onClick="deleteThisProduct('#FieldNameEnd#', '#getProducts.BSA_Foodservice_Items_Master_ID#')" style="cursor: hand;"></td>
					<td style="border-bottom:solid ##93BEE2 1px;"><input name="Prod_#replace(getProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" type="checkbox" value="#FieldNameEnd#" checked Disabled></td>
					<td align="center" style="border-bottom:solid ##93BEE2 1px;"><a href ="javascript:void(0);" <cfif getProducts.Added_ProdID neq "" AND Form.Is_A_Revision eq 0 AND Action neq "Revise">onclick="NewWindow('sales_agreement_save_Notes.cfm?Export_Sales_Agreement_ID=#Export_Sales_Agreement_ID#&Item_ID=#getProducts.BSA_Foodservice_Items_Master_ID#', 'NotesWindow', 350, 150, 'yes', 'yes')"</cfif>><img src="/images/doc.gif" border="0"></a></td>
					<td style="border-bottom:solid ##93BEE2 1px;">#Item#</td>
					<td style="border-bottom:solid ##93BEE2 1px;"><input type="text" name="Export_Target_Net_Sales_Price_#FieldNameEnd#" size="3" value="#Export_Target_Net_Sales_Price#"></td>
					<td style="border-bottom:solid ##93BEE2 1px;"><input type="text" name="Export_Sale_Unit_Price_#FieldNameEnd#" size="3" value="#Export_Sale_Unit_Price#" <!---OnKeyUp="getCostorNSP('#Export_Sales_Agreement_ID#', '#FieldNameEnd#')"--->></td>
					<td style="border-bottom:solid ##93BEE2 1px;"><input type="text" name="Export_Origin_Relocation_Cost_#FieldNameEnd#" size="3" value="#Export_Origin_Relocation_Cost#"  style="background-color: ##cccccc" READONLY></td>
					<td style="border-bottom:solid ##93BEE2 1px;">
					<select name="Export_Sticker_#FieldNameEnd#" id="Export_Sticker_#FieldNameEnd#" OnChange="getStickeringCost(this.value,document.all.Export_Sticker_Type.value,'Export_Sticker_Rate_#FieldNameEnd#');">
						<option value="0" <cfif Export_Sticker eq 0>selected</cfif>>No</option>
						<option value="1" <cfif Export_Sticker eq 1>selected</cfif>>Yes</option>
					</select>
					<cfif getProducts.Added_ProdID eq "">
						<input type="hidden" name="Export_Sticker_#FieldNameEnd#" value="0">
					</cfif>
					</td>
					<td style="border-bottom:solid ##93BEE2 1px;"><input type="text" name="Export_Sticker_Rate_#FieldNameEnd#" size="3" value="#Export_Sticker_Rate#" id="Export_Sticker_Rate_#FieldNameEnd#"  style="background-color: ##cccccc" READONLY</td>
					<td style="border-bottom:solid ##93BEE2 1px;"><input type="text" name="Export_Accrual_#FieldNameEnd#" size="3" value="#Export_Accrual#"></td>
					<td style="border-bottom:solid ##93BEE2 1px;"><input type="text" name="Export_Charge_#FieldNameEnd#"  size="3" value="#NumberFormat(getproducts.Export_Charge,',.9999')#" <cfif getProducts.Added_ProdID neq "">onclick="NewWindow('sales_agreement_price_builder.cfm?Export_Sales_Agreement_ID=#Export_Sales_Agreement_ID#&Item_ID=#getProducts.BSA_Foodservice_Items_Master_ID#', 'productwindow', 800, 600, 'yes', 'yes', true)" style="color:blue;cursor:pointer;"</cfif> style="background-color: ##cccccc;" READONLY></td>
					<td style="border-bottom:solid ##93BEE2 1px;"><input type="text" name="Export_Estimated_Net_Sales_Price_#FieldNameEnd#" size="3" value="#NumberFormat(getproducts.Export_Estimated_Net_Sales_Price,',.9999')#" style="background-color: ##cccccc" READONLY></td>
				  <td style="border-bottom:solid ##93BEE2 1px;"><input type="text" name="Export_End_User_#FieldNameEnd#" size="3" value="#Export_End_User#"></td>
					<td style="border-bottom:solid ##93BEE2 1px;">
					<select name="Export_Required_Volume_#FieldNameEnd#">
						<option value="0" <cfif Export_Required_Volume eq 0>selected</cfif>>No</option>
						<option value="1" <cfif Export_Required_Volume eq 1>selected</cfif>>Yes</option>
					</select>
					</td>
					<td style="border-bottom:solid ##93BEE2 1px;"><span id="error_Vol_Limit_#FieldNameEnd#"></span><input type="text" name="Export_Volume_Limit_#FieldNameEnd#" size="3" value="#Export_Volume_Limit#"></td>
				</tr>
			
			</cfoutput>
				<tr>
					<td colspan="13">&nbsp;</td>
					<td align="right"><b>Total:</b></td>
					<td id="TotalVolume"><b><cfoutput>#Total_Export_Volume#</cfoutput></b></td>
				</tr>
		</table>	

		<cfoutput>
		<table width="80%" border="0" align="center">
			<tr>
				<td align="center">
				<cfif IsDefined("getProducts.recordcount")  AND getProducts.Added_ProdID neq "">
					<span style="font-weight:bold;color:red"> [ </span> 
					<a href="##" OnClick="getCostorNSP('#Export_Sales_Agreement_ID#','');return false;" style="font-weight:bold;">Calculate</a>
					<span style="font-weight:bold;color:red"> ] </span>
				</cfif>
				<cfif Export_Sales_Agreement_ID neq "">
					<span style="font-weight:bold;color:red"> [ </span> 
					<a href="##" OnClick="javascript:return verifyFrm(0,'#Action#','#Get_Profile_Settings.Create_Approve_Export_Agreements#','#DateFormat(CSLGetContractInfo.Agreement_Created_Date,'MM/DD/YYYY')#');return false;" style="font-weight:bold;">Save</a>
					<span style="font-weight:bold;color:red"> ] </span>
					<CF_smallLink 
						title = "Add Products" 
						url = "##"
						parameters = "onClick=""javascript: return showProductSearchWindow();""">
				</cfif>
				</td>
			</tr>
		</table>
		</cfoutput>
		<p>

		<table border="0" cellpadding="2" cellspacing="0" width="80%" align="center">
			<tr> 
				<td class="TableHeaders" align="center">Internal Notes</td>
				<td class="TableHeaders" align="center">Special Conditions</td>
				<td class="TableHeaders" align="center"><span id="error_Export_Notify_Party"></span> Documentation Notify Party</td>
			</tr>
			<cfoutput>
			<tr> 
				<td class="TableHeaders" align="center"><textarea name="Export_Internal_Notes" rows="10" cols="35">#Form.Export_Internal_Notes#</textarea></td>
				<td class="TableHeaders" align="center"><textarea name="Export_Special_Conditions" rows="10" cols="35">#Form.Export_Special_Conditions#</textarea></td>
				<td class="TableHeaders" align="center"><textarea name="Export_Notify_Party" rows="10" cols="35">#Form.Export_Notify_Party#</textarea></td>
			</tr>
			</cfoutput>
		</table>
	</cfif>	<!--- (End) if products Exist--->
</cfif> 
<cfoutput>

<INPUT TYPE="Hidden" NAME="Product_List" VALUE="#Form.Product_List#">
<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#Form.Product_List#">
<!--- copy or revise --->
<INPUT TYPE="Hidden" NAME="Action" VALUE="#Action#">

<table width="80%" border="0" align="center">
	<tr>
		<td align="center">
			<span style="font-weight:bold;color:red"> [ </span> 
				<a href="##" OnClick="javascript:return verifyFrm(0,'#Action#','#Get_Profile_Settings.Create_Approve_Export_Agreements#','#DateFormat(CSLGetContractInfo.Agreement_Created_Date,'MM/DD/YYYY')#');return false;" style="font-weight:bold;">Save</a>
			<span style="font-weight:bold;color:red"> ] </span>
		<cfif Export_Sales_Agreement_ID neq "" AND Action eq "">
			<span style="font-weight:bold;color:red"> [ </span> 
				<a href="##" OnClick="javascript:return verifyFrm(1,'#Action#','#Get_Profile_Settings.Create_Approve_Export_Agreements#','#DateFormat(CSLGetContractInfo.Agreement_Created_Date,'MM/DD/YYYY')#');return false;" style="font-weight:bold;">Save and Continue</a>
			<span style="font-weight:bold;color:red"> ] </span>
			<cfif getProducts.recordcount eq 0>
				<CF_smallLink 
				title = "Add Products" 
				url = "##"
				parameters = "onClick=""javascript: return showProductSearchWindow();""">
			</cfif>
		</cfif>

		</td>
	</tr>
</table>
</cfoutput>
</form>	

</body>
</html>

<cfsetting showdebugoutput="true">