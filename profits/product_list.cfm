

<!--- <CFOUTPUT>#listqualify(trim(form.AA_PRODUCT_LIST), "'")#</CFOUTPUT> --->
<CFSET short_Listed_Products="">
<CFSET show_More=false>
<CFSET show_Count=15>
<CFSET list_Count=1>
<CFLOOP LIST="#FORM.AA_PRODUCT_LIST#" INDEX="this_Product" DELIMITERS=",">
	<CFSET short_Listed_Products=ListAppend(short_Listed_Products,this_Product,",")>
	<CFIF list_Count GTE show_Count>
		<CFBREAK>
	</CFIF>
	<CFSET list_Count=list_Count+1>	
</CFLOOP>
<CFIF list_Count LT ListLen(form.AA_PRODUCT_LIST,",")>
	<CFSET show_More=true>
</CFIF>

<!--- List the products used in a specific pricing rule... --->
<CFQUERY NAME="Get_Products_List" datasource="#application.datasource#">
	Select		Description, BSA_Foodservice_Items_Master_ID
	from		BSA_Foodservice_Items_Master
	where		BSA_Foodservice_Items_Master_ID  in (#listqualify(short_Listed_Products, "'")#)
</CFQUERY>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT>
var deleteImg = new Image();
deleteImg.src = "/Images/scissor.gif";
var undodeleteImg = new Image();
undodeleteImg.src = "/Images/undo.gif";
		
function deleteThisProduct(itemID)
{	
	event.returnValue = false;
	var List_Obj = document.all.AA_PRODUCT_LIST;
	
	var original_List = List_Obj.value;
	
	var resultString = ListDeleteItem(original_List, ",", itemID);
	
	var bDelete = true;
	
	if(resultString == original_List)
	{
		resultString = ListAppendItem(original_List, ",", itemID);
		bDelete = false;
	}
	List_Obj.value = resultString;

	if(document.all.Newly_Selected_Products)
	{
		document.all.Newly_Selected_Products.value = resultString;
	}

	if(document.all.ExistingProductList)
	{
		document.all.ExistingProductList.value = resultString;
	}

	var srcObj = event.srcElement;
	var tdObj = getParentObject(srcObj, "TD");
	if(tdObj)
	{
		if(bDelete)
		{
			tdObj.style.backgroundColor = "#CCCCCC";
			tdObj.style.textDecoration = "line-through";
			srcObj.alt = "undo delete";
			srcObj.src = undodeleteImg.src;
		}
		else
		{
			tdObj.style.backgroundColor = "WhiteSmoke";
			tdObj.style.textDecoration = "none";
			srcObj.alt = "delete this item";
			srcObj.src = deleteImg.src;
		}
	}
}
</SCRIPT>
<!--- #valuelist(Get_Rule_Products.Pricing_Rule_Products_Item_ID)# --->
<CFPARAM NAME="PRODUCT_SHOW_DELETE" 	DEFAULT="false">
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="100%">
	<TR BGCOLOR="ffffff">
		<CFSET Mycounter=0>
		<CFOUTPUT QUERY="Get_Products_List">
		<TD BGCOLOR="WhiteSmoke">
		<CFIF PRODUCT_SHOW_DELETE>
		<A HREF="void(0);" onClick="javaScript:return deleteThisProduct('#BSA_Foodservice_Items_Master_ID#');"><IMG SRC="/Images/scissor.gif" BORDER="0" ALT="delete this item"></A>&nbsp;
		</CFIF>
		<SPAN CLASS="normal">#lcase(Description)#</SPAN></TD>
		<CFSET Mycounter=Mycounter+1>
		#IIf(Mycounter Mod 3,DE(''),DE('</TR><TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">'))#
		</CFOUTPUT>
	<CFIF show_More>
	<SCRIPT>
		function showProductListWindow(thisObj) {					
			NewWindow("show_All_Products.cfm?fieldName=AA_PRODUCT_LIST", "productListWindow", 800, 600, "yes", "yes")
			return false;
		}
	</SCRIPT>
	<TR>
		<TD>
		<A HREF="show_All_Products.cfm" onClick="javaScript: return showProductListWindow(this);">More...</A>
		</TD>
	</TR>
	</CFIF>
</TABLE>		


