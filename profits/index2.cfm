<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
 
 
<CFSET pagetitle = "step 1 of 4">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of a pricing rule ID (PRID) in the URL --->
<CFPARAM NAME="URL.PRID" DEFAULT="">
<CFPARAM NAME="FORM.aa_comm_number" DEFAULT="-1">
<CFPARAM NAME="aa_rulename" DEFAULT="">
<CFPARAM NAME="FORM.Newly_Selected_Products" DEFAULT="">
<CFPARAM NAME="struct_profit_rule_name.aa_comm_number" DEFAULT="-1">
<CFPARAM NAME="FORM.ThisPageFirstTimeLoading" DEFAULT="TRUE">


<!--- If the pricing rule ID has been passed get the details for it --->
<CFIF URL.PRID NEQ "">

<!--- Get the rule --->
<CFQUERY NAME="Get_Rule_Data" datasource="#application.datasource#">
	Select		Pricing_Rule.Pricing_Rule_ID,
				Pricing_Rule.Pricing_Rule_Name,
				Pricing_Rule.Pricing_Rule_Date,
				Pricing_Rule.Pricing_Rule_Author,
				Pricing_Rule.Pricing_Rule_Final_Cost,
				Pricing_Rule.Pricing_Rule_Data
	From		Pricing_Rule
	Where		Pricing_Rule.Pricing_Rule_ID			=	'#URL.PRID#'
</CFQUERY>

<!--- Get the products of the rule --->
<CFQUERY name="Get_Rule_Products" datasource="#application.datasource#">
	Select		*
	From		Pricing_Rule_Products
	Where		Pricing_Rule_Products.Pricing_Rule_ID = '#Get_Rule_Data.Pricing_Rule_ID#'
</CFQUERY>



<!--- Deserialize the XML packet --->
<CFWDDX ACTION="wddx2cfml" INPUT="#Get_Rule_Data.Pricing_Rule_Data#" OUTPUT="struct_profit_rule_name">
<CFSET aa_rulename=struct_profit_rule_name.aa_rulename>

<CFIF FORM.ThisPageFirstTimeLoading EQ "TRUE">
	<CFSET FORM.Newly_Selected_Products=#valuelist(Get_Rule_Products.Pricing_Rule_Products_Item_ID)#>
</CFIF>

</CFIF>

<!--- <CF_templatename><CFOUTPUT>#TemplateName#</CFOUTPUT> --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Default values for the HR lines --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET color="Orange">
<CFSET size=1>
<FORM ACTION="index3.cfm" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;"<!------ onSubmit="javascript:return  validateAndSubmitIndex2(this);"----->>
	<span id="error_RuleName"></span>&nbsp;<SPAN CLASS="title2">1. Rule Name</SPAN>
	<HR SIZE="<CFOUTPUT>#size#</CFOUTPUT>" COLOR="<CFOUTPUT>#color#</CFOUTPUT>">
	Please create the rule name: <FONT COLOR="#FF0000" SIZE="-2"><I><B>(must give the rule a name)</B></I></FONT><BR>
	<INPUT TYPE="text" NAME="aa_rulename" VALUE="<CFOUTPUT>#aa_rulename#</CFOUTPUT>" STYLE="width:400px;" onKeypress="javascript:validateXMLCharaters();"> <FONT COLOR="#FF0000" SIZE="-2"><B>(" is not a valid character)</B></FONT>
	
	<BR><BR>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Get the list of products																		 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT>
		function showProductSearchWindow() {
			document.all.SaveProgramProducts.aa_rulename.value = document.MyForm.aa_rulename.value;
			//document.all.SaveProgramProducts.aa_comm_number.value = document.MyForm.aa_comm_number.selectedIndex;
			NewWindow("product_Selector.cfm?Formname=SaveProgramProducts", "productwindow", 800, 600, "yes", "yes")
		}
		
		var deleteImg = new Image();
		deleteImg.src = "/Images/scissor.gif";
		var undodeleteImg = new Image();
		undodeleteImg.src = "/Images/undo.gif";

		function deleteThisItem(distID)
		{	
			event.returnValue = false;
			var Commodity_List_Obj = document.all.Commodity_List;
			var original_Comm_List;
			if(Commodity_List_Obj.length)
			{
				original_Comm_List = Commodity_List_Obj[0].value;
			}
			else
			{
				original_Comm_List = Commodity_List_Obj.value;
			}
			var resultString = ListDeleteItem(original_Comm_List, ",", distID);
			var bDelete = true;
			if(resultString == original_Comm_List)
			{
				resultString = ListAppendItem(original_Comm_List, ",", distID);
				bDelete = false;
			}
				
			if(Commodity_List_Obj.length)
			{
				var i;
				for(i=0;i<Commodity_List_Obj.length;i++)
				{
					Commodity_List_Obj[i].value = resultString;
				}
			}
			else
			{
				Commodity_List_Obj.value = resultString;
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

 	<CFSET Get_Products = QueryNew("BSA_Foodservice_Items_Master_ID")>
	<CFSET Get_Rule_Products = QueryNew("Pricing_Rule_Products_Item_ID")>
	
	<CFIF listlen(FORM.Newly_Selected_Products) GT 0>
		<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
			SELECT		BSA_Foodservice_Items_Master_ID,
						Description,
						UPC
			FROM		dbo.BSA_Foodservice_Items_Master
			WHERE     	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN(#replace(listqualify(FORM.Newly_Selected_Products, "'"), '"', "'")#)
			ORDER BY 	description
		</CFQUERY>
	</CFIF>
	
	<span id="error_PRODUCT_LIST"></span>&nbsp;<SPAN CLASS="title2">2. Product Selector</SPAN>
	&nbsp;&nbsp;&nbsp;<B>
		<FONT COLOR="#FF0000">[</FONT>
		<a href="javascript: showProductSearchWindow();">click here to select products</a>
		<FONT COLOR="#FF0000">]</FONT></B>
	<HR SIZE="<CFOUTPUT>#size#</CFOUTPUT>" COLOR="<CFOUTPUT>#color#</CFOUTPUT>">	

	These are your selected products... <FONT COLOR="#FF0000" SIZE="-2"><I><B>(you must select at least one)</B></I></FONT><BR>
	<!------
	<SELECT NAME="View_PRODUCT_LIST" SIZE="11" MULTIPLE STYLE="width:400px;">
		<CFOUTPUT QUERY="Get_Products"><OPTION VALUE="#BSA_Foodservice_Items_Master_ID#">#UPC# - #Description#</OPTION></CFOUTPUT>
	</SELECT>
	----->
	

	<CFSET Form.AA_PRODUCT_LIST=valuelist(Get_Products.BSA_FOODSERVICE_ITEMS_MASTER_ID)>
	
	<CFSCRIPT>
		Border="Yes";					BorderSize=1;				BorderColor="orange";			Image="/images/plus3.gif";
		ImageOpen="/images/minus3.gif";	TitleColor="Blue";			TitleFont="Arial";				TitleSize=8;
		IsClosed="No";					Width=600;
	</CFSCRIPT>
	
	<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Hide Products"  
	TitleClosed="View Products"  
	TitleTooltip="Click here to togle view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
	<CFSET PRODUCT_SHOW_DELETE = true>
	<CFIF Get_Products.recordCount GT 0>
		<CFINCLUDE TEMPLATE="product_list.cfm">	
	</CFIF>
	
	</CF_openLayer>
	<BR><BR>


	<CFPARAM NAME="FORM.Commodity_List" 	DEFAULT="">
	&nbsp;<SPAN CLASS="title2">3. Select Commodities</SPAN>
	<CFIF struct_profit_rule_name.aa_comm_number LT 0>
	<SCRIPT>
		function showSearchWindow() 
		{
			event.returnValue = false;
			if(document.all.SaveProgramProducts)
			{
				document.all.SaveProgramProducts.aa_rulename.value = document.MyForm.aa_rulename.value;
				//document.all.SaveProgramProducts.aa_comm_number.value = document.MyForm.aa_comm_number.selectedIndex;
				NewWindow("/Search_Screens/Commodity_Search.cfm?Formname=SaveProgramProducts&ReturnFieldName=Symbol&FieldName=Commodity_List", "productwindow", 800, 600, "yes", "yes")
			}
		}
	</SCRIPT>
		&nbsp;&nbsp;&nbsp;<B>
		<FONT COLOR="#FF0000">[</FONT>
		<a href="void(0);" ONCLICK="javascript: showSearchWindow();">click here to select commodities</a>
		<FONT COLOR="#FF0000">]</FONT>
		</B>
	<CFELSE>
		<CFSET FORM.Commodity_List = "">
		<CFLOOP INDEX="i" FROM="1" TO="#struct_profit_rule_name.aa_comm_number#">
			<CFSET FORM.Commodity_List = ListAppend(FORM.Commodity_List, "#evaluate('struct_profit_rule_name.COMMODITY_'&'#i#')#", ",")>
		</CFLOOP>
	</CFIF>
	<HR SIZE="<CFOUTPUT>#size#</CFOUTPUT>" COLOR="<CFOUTPUT>#color#</CFOUTPUT>">
	
	<!------	<B>There are <CFOUTPUT>#struct_profit_rule_name.aa_comm_number#</CFOUTPUT> commodities in this pricing rule</B>
		<INPUT NAME="AA_COMM_NUMBER" TYPE="hidden" VALUE="<CFOUTPUT>#struct_profit_rule_name.aa_comm_number#</CFOUTPUT>">	
	<CFELSE>----->
	
		
		<CFQUERY NAME="Get_Current_Commodity_Info" DATASOURCE="#application.datasource#">
			SELECT	RTRIM(LTRIM(Commodities_Symbol.Symbol)) AS Symbol, Commodities_Symbol.Symbol_Description					
			FROM	Commodities_Symbol
			WHERE
					<CFIF Form.Commodity_List NEQ "">
					RTRIM(LTRIM(Commodities_Symbol.Symbol)) IN (#ListQualify(Form.Commodity_List, "'", ",")#)
					<CFELSE>
					1=2
					</CFIF>
		</CFQUERY>
		<CFSET CommCount_String = "Selected Commodities">
		<CFIF Get_Current_Commodity_Info.RecordCount GT 0>
			<CFSET CommCount_String = "#CommCount_String# (#Get_Current_Commodity_Info.RecordCount#)">
		</CFIF>
		<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"  
			BorderColor="#BorderColor#"  
			Image="#Image#"
			ImageOpen="#ImageOpen#"
			Title="Hide #CommCount_String#"
			TitleClosed="View #CommCount_String#"
			TitleTooltip="Click here to togle view"  
			TitleColor="#TitleColor#"  
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="#width#">
			
			<CFIF Get_Current_Commodity_Info.recordCount GT 0>
				<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="100%">
					<TR BGCOLOR="ffffff">
						<CFOUTPUT QUERY="Get_Current_Commodity_Info">
						<TD BGCOLOR="WhiteSmoke"><SPAN CLASS="normal">
						<CFIF struct_profit_rule_name.aa_comm_number LT 0>
						<A HREF="void(0);" onClick="javaScript:return deleteThisItem('#Symbol#');"><IMG SRC="/Images/scissor.gif" BORDER="0" ALT="delete this item"></A>&nbsp;
						</CFIF>
						#lcase(Symbol_Description)#</SPAN>
						</TD>
						#IIf(Currentrow Mod 2,DE(''),DE('</TR><TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">'))#
						</CFOUTPUT>					
				</TABLE>	
			</CFIF>
			
			</CF_openLayer>		

	<!--- <INPUT NAME="AA_PRODUCT_LIST" TYPE="hidden" VALUE="<CFOUTPUT>#valuelist(Get_Rule_Products.Pricing_Rule_Products_Item_ID)#</CFOUTPUT>"> --->
	<INPUT NAME="AA_PRODUCT_LIST" TYPE="hidden" VALUE="<CFOUTPUT>#valuelist(Get_Products.BSA_Foodservice_Items_Master_ID)#</CFOUTPUT>">	
	<INPUT TYPE="Hidden" NAME="Commodity_List" VALUE="<CFOUTPUT>#form.Commodity_List#</CFOUTPUT>">
	<INPUT NAME="PRID" TYPE="hidden" VALUE="<CFOUTPUT>#URL.PRID#</CFOUTPUT>">


<BR>
<BR>

<CF_BUTTON
BUTTON_NAME		=	""
BUTTON_CAPTION	=	"continue"
BUTTON_ACTION	=	"javascript:validateAndSubmitIndex2(document.all.MyForm);"
BUTTON_TYPE		=	"link"
BUTTON_WIDTH	=	"100"
BUTTON_COLOR	=	"Navy"
BUTTON_TIP		=	""
FONT_COLOR		=	"White"
FONT_SIZE		=	"12"
FONT_WEIGHT		=	"bold">				

<!-------------------- Added By Deepa ----------------------------------------->

<SCRIPT LANGUAGE="JavaScript" SRC="commodityScripts.js"></SCRIPT>
<CF_MessageWindow>

<!-----
Added onSubmit="javascript: return validateAndSubmitIndex2(this);"
in form tag

Edited 
"javascript:document.all.MyForm.submit();"
to
"javascript:validateAndSubmitIndex2(document.all.MyForm);"

Added <span id="error_RuleName"></span>&nbsp;
Added <span id="error_PRODUCT_LIST"></span>&nbsp;
------->
<!-------------------- End Added By Deepa ----------------------------------------->
	
</FORM>

<!------<FORM ACTION="save_products.cfm" METHOD="post" NAME="SaveProgramProducts" ID="SaveProgramProducts">----->
<FORM ACTION="index2.cfm?PRID=<CFOUTPUT>#URL.PRID#</CFOUTPUT>" METHOD="post" NAME="SaveProgramProducts" ID="SaveProgramProducts">	
	<INPUT TYPE="Hidden" NAME="Commodity_List" VALUE="<CFOUTPUT>#form.Commodity_List#</CFOUTPUT>">

	<INPUT TYPE="Hidden" NAME="aa_rulename" VALUE="">	
	<INPUT TYPE="Hidden" NAME="PRID" VALUE="<CFOUTPUT>#URL.PRID#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="aa_comm_number" VALUE="<CFOUTPUT>#struct_profit_rule_name.aa_comm_number#</CFOUTPUT>">	
	<INPUT TYPE="Hidden" NAME="Newly_Selected_Products" VALUE="<CFOUTPUT>#Form.Newly_Selected_Products#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="<CFOUTPUT>#Form.Newly_Selected_Products#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="ThisPageFirstTimeLoading" VALUE="false">
</FORM>

