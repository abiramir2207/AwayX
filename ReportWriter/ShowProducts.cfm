<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<!------
ShowProducts.cfm
----->
<CFPARAM NAME="FORM.Product_List" 	DEFAULT="">
<CFPARAM NAME="URL.rProducts" 	DEFAULT="#FORM.Product_List#">
<CFSET rProducts = URL.rProducts>
<CFSET ProductName = "search">
<CFIF Len(rProducts) EQ 0>
	<CFSET rProducts = "-1">
</CFIF>
<CFIF rProducts NEQ -1 AND Len(rProducts) GT 0>
	<CFQUERY NAME="q_getProducts" datasource="#application.datasource#">
		SELECT	BSA_Foodservice_Items_Master_ID, Description Product_name
		FROM 	BSA_Foodservice_Items_Master
		WHERE
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#rProducts#'
		Order By Description
	</CFQUERY>
	<CFIF q_getProducts.recordCount GT 0>
		<CFSET ProductName = Left(q_getProducts.Product_Name, 25)>
	<CFELSE>
		<CFSET rProducts = "-1">
	</CFIF>	
</CFIF>
<CFOUTPUT>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<SCRIPT LANGUAGE="JavaScript">
	function disableAll(bDis)
	{
		var i, allLen, allObj;
		allObj = document.all;
		allLen = allObj.length;
		for(i=0;i<allLen;i++)
		{
			allObj[i].disabled = bDis;
			try
			{
				if(bDis)
				{
					allObj[i].style.display = "none";
				}
				else
				{
					if(allObj[i].tagName == "DIV")
					{
						allObj[i].style.display = display_Div(allObj[i]);
					}
					else
					{					
						allObj[i].style.display = "";
					}					
				}	
			}
			catch(e)
			{
				//alert(allObj[i].tagName + "\n" + e.description);
			}
		}
	}
	function showProductsSearchWindow() 
	{
		NewWindow("/common_files/contracts/product_select_v1.cfm?Formname=Report_Product_Form&SelectSingleSearchResultOnly=1", "Productwindow", 800, 600, "yes", "yes")
		return false;
	}
	function setParentProductID(ProductID)
	{
		if(window.parent)
		{
			var ProductInput = window.parent.document.all.rProducts;
			if(ProductInput)
			{
				ProductInput.value = ProductID;
			}
		}
	}	
	
	function setChildProductID(ProductID)
	{
		document.all.rProducts.value = ProductID;
		setParentProductID(ProductID);
		setChildSearchProductID(ProductID);
		document.all.Product_Exist.style.display = display_Div(document.all.Product_Exist);
		document.all.All_Products.style.display = display_Div(document.all.All_Products);
	}
	function setChildSearchProductID(ProductID)
	{
		if(ProductID == "-1")
		{
			ProductID = "";
		}
		document.all.Product_List.value = ProductID;
	}
	function display_Div(thisObj)
	{
		var show = "";
		var hide = "none";
		var ProductValue = document.all.rProducts.value;
		if(thisObj.id)
		{
			if(thisObj.id == "Product_Exist")
			{
				if(ProductValue != "-1")
				{
					return show;
				}
				else
				{
					return hide;
				}
			}
			else if(thisObj.id == "All_Products")
			{
				if(ProductValue == "-1")
				{
					return show;
				}
				else
				{
					return hide;
				}
			}			
		}		
		return hide;
	}	
</SCRIPT>
<TABLE CELLPADDING="0" CELLSPACING="0" HEIGHT="100%">
<TR>
<TD VALIGN="middle">
<DIV ID="Product_Exist"<CFIF rProducts EQ -1> STYLE="DISPLAY:NONE;"</CFIF>>
<FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: return showProductsSearchWindow();">#ProductName#</A><FONT COLOR="Red"> ]</FONT> <FONT COLOR="Red">[</FONT> <A HREF="javascript: void(0);" onClick="javaScript: return setChildProductID(-1);">All Products</A><FONT COLOR="Red"> ]</FONT>
</DIV>
<DIV ID="All_Products"<CFIF rProducts NEQ -1> STYLE="DISPLAY:NONE;"</CFIF>>
All Products <FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: return showProductsSearchWindow();">search</A><FONT COLOR="Red"> ]</FONT>
</DIV>
</TD>
</TR>
</TABLE>
<CFIF rProducts NEQ "">
	<SCRIPT LANGUAGE="JavaScript">
	setParentProductID("#rProducts#");	
	</SCRIPT>
</CFIF>
<INPUT TYPE="Hidden" NAME="rProducts" VALUE="#rProducts#">
<CFIF rProducts EQ "-1"><CFSET rProducts = ""></CFIF>
<FORM NAME="Report_Product_Form" ACTION="ShowProducts.cfm" METHOD="post">
<INPUT TYPE="Hidden" NAME="Product_List" VALUE="#rProducts#">
<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#rProducts#">
</FORM>
</BODY>
</CFOUTPUT>
