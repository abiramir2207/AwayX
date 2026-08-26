<!------
show_All_Products.cfm
----->
<HTML>
<HEAD>
<TITLE>Pricing Rule - Product List</TITLE>
</HEAD>
<cfparam name="FORM.SORT_BY" 	default="Item">
<cfparam name="FORM.SORT_ORDER" 	default="ASC">

<BODY LEFTMARGIN="12" TOPMARGIN="12" RIGHTMARGIN="12" BOTTOMMARGIN="12">
<CFIF ISDefined("URL.fieldName") OR ISDefined("FORM.AA_PRODUCT_LIST")>
	<cfparam name="FORM.startrow" 	default=1>
	<cfparam name="FORM.frompage" 	default=1>
	<CFIF IsDefined("FORM.AA_PRODUCT_LIST")>
		<CFSET Sort_By_Str="Item">
		<CFSWITCH EXPRESSION="#FORM.SORT_BY#">
			<CFCASE VALUE="Item">
				<CFSET Sort_By_Str="Item">
			</CFCASE>
			<CFCASE VALUE="Description">
				<CFSET Sort_By_Str="Description">
			</CFCASE>
			<CFCASE VALUE="UPC">
				<CFSET Sort_By_Str="UPC">
			</CFCASE>
			<CFCASE VALUE="Type Code">
				<CFSET Sort_By_Str="Type_Code_Desc.Type_Code_Desc">
			</CFCASE>
			<CFCASE VALUE="Brand">
				<CFSET Sort_By_Str="Brand.Brand_Name">
			</CFCASE>
		</CFSWITCH>
		<CFIF FORM.SORT_ORDER NEQ "ASC">
			<CFSET FORM.SORT_ORDER="DESC">
		</CFIF>
		<CFQUERY NAME="Get_Products" datasource="#application.datasource#">			
			Select		Item, UPC, Description, Type_Code_Desc.Type_Code_Desc, Brand.Brand_Name
			from		BSA_Foodservice_Items_Master
						INNER JOIN Type_Code_Desc
						ON
						(
							(Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID)
						)
						INNER JOIN Brand
						ON
						(
							(Brand.Brand_ID = BSA_Foodservice_Items_Master.Brand_ID)
						)
			where		BSA_Foodservice_Items_Master_ID  in (#listqualify(FORM.AA_PRODUCT_LIST, "'")#)
			ORDER BY	#Sort_By_Str# #FORM.SORT_ORDER#
		</CFQUERY>		
		
		<style>
		TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
		#header {font-size: 12px; font-weight: bold;}
		</style>
		<SCRIPT LANGUAGE="JavaScript">
		function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
		{
			var formObj;
			formObj = document.all.Product_List_Form;
			formObj.SORT_BY.value = thisSortItem;
			formObj.SORT_ORDER.value = thisSortOrder;
			formObj.submit();
			return false;
		}
		</SCRIPT>
		<CFSET HeaderNameList="Item">
		<CFSET HeaderValueList="Item">
		
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
			<CFSET HeaderNameList = ListAppend(HeaderNameList, "UPC", ",")>
			<CFSET HeaderValueList = ListAppend(HeaderValueList, "UPC", ",")>
		</cfif></cfif>
		<CFSET HeaderNameList = ListAppend(HeaderNameList, "Description,#application.returned_customer_setting.type_code_label_singular#,Brand", ",")>
		<CFSET HeaderValueList = ListAppend(HeaderValueList, "Description,Type Code,Brand", ",")>
		
		<TABLE CLASS="Maintable" WIDTH="98%" CELLPADDING="3" CELLSPACING="0" ALIGN="CENTER">			
			<COLGROUP>
				<COL SPAN="1"></COL>
				<COL SPAN="2" WIDTH="80"></COL>
			</COLGROUP>
			<TR BGCOLOR="FFCE84" VALIGN="TOP">
				<TD ID="header">&nbsp;</TD>
				<CFOUTPUT>
				<CFSET sort_Counter = 1>
				<CFLOOP LIST="#HeaderValueList#" INDEX="this_Header" DELIMITERS=",">
				<CFSET display_Label = ListGetAt(HeaderNameList, sort_Counter, ",")>
				<CFSET sortImage="">				
				<CFIF this_Header EQ Form.SORT_BY>
					<CFIF FORM.SORT_ORDER EQ "DESC">
						<CFSET New_Sort_Order="ASC">
						<CFSET sortImage="up_1.gif">
					<CFELSE>
						<CFSET New_Sort_Order="DESC">
						<CFSET sortImage="down_1.gif">
					</CFIF>
				<CFELSE>
					<CFSET New_Sort_Order="ASC">
				</CFIF>
				<TD ID="header"><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#this_Header#','#New_Sort_Order#');">#display_Label#<CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></TD>
				<CFSET sort_Counter = sort_Counter + 1>
				</CFLOOP>
				</CFOUTPUT>
<!------
<TD ID="header">Type Code</TD>
<TD ID="header">Brand</TD>
----->
			</TR>
			<cf_Number_of_Rows maxrows=25>

		<CFSET color="000000">
		<CFOUTPUT QUERY="Get_Products" startrow="#StartRow#" maxrows="#MaxRows#">
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD ALIGN="right"><FONT COLOR="#color#">#currentrow#</FONT>&nbsp;&nbsp;</TD>
					<TD><FONT COLOR="#color#">#Item#&nbsp;</FONT></TD>
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
					<TD><FONT COLOR="#color#">#UPC#&nbsp;</FONT></TD>
					</cfif></cfif>
					<TD><FONT COLOR="#color#">#Description#&nbsp;</FONT></TD>
					<TD><FONT COLOR="#color#">#Type_Code_Desc#&nbsp;</FONT></TD>
					<TD><FONT COLOR="#color#">#Brand_Name#&nbsp;</FONT></TD>					
				</TR>
			</CFOUTPUT>

		</TABLE>
	<DIV STYLE="font-size: 12px; color: Red;">
	&nbsp;&nbsp;&nbsp;
	<CF_Next_Previous_For_Forms
		formname="Product_List_Form"
		query="Get_Products"
		maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">
	</DIV>
	
	<DIV ALIGN="center">
		<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">				
					<A HREF="#" OnClick="javaScript: window.close();">
						close window
					</A>				
		</FONT>		
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
	</DIV>	
		
	</CFIF>
	<cfparam name="FORM.AA_PRODUCT_LIST" 	default="">	
	<CFOUTPUT>
	<FORM ID="Product_List_Form" NAME="Product_List_Form" ACTION="show_All_Products.cfm" METHOD="POST">
		<INPUT TYPE="HIDDEN" ID="AA_PRODUCT_LIST" NAME="AA_PRODUCT_LIST" VALUE="#FORM.AA_PRODUCT_LIST#">
		<INPUT TYPE="Hidden" NAME="startrow" VALUE="#FORM.startrow#">
		<INPUT TYPE="Hidden" NAME="frompage" VALUE="#FORM.frompage#">	
		<INPUT TYPE="Hidden" NAME="SORT_BY" VALUE="#FORM.SORT_BY#">			
		<INPUT TYPE="Hidden" NAME="SORT_ORDER" VALUE="#FORM.SORT_ORDER#">			
	</FORM>
	</CFOUTPUT>
	<CFIF ISDefined("URL.fieldName")> 
		<CFOUTPUT>
		<SCRIPT LANGUAGE="JavaScript">
		function add_Products_From_Parent_And_Submit()
		{			
			if(window.opener.document.all.#URL.fieldName#)
			{
				document.Product_List_Form.AA_PRODUCT_LIST.value = window.opener.document.all.#URL.fieldName#.value;
				document.Product_List_Form.submit();
			}
			else if(window.opener.document.all.#LCase(URL.fieldName)#)
			{
				document.Product_List_Form.AA_PRODUCT_LIST.value = window.opener.document.all.#LCase(URL.fieldName)#.value;
				document.Product_List_Form.submit();
			}
			else if(window.opener.document.all.#UCase(URL.fieldName)#)
			{
				document.Product_List_Form.AA_PRODUCT_LIST.value = window.opener.document.all.#UCase(URL.fieldName)#.value;
				document.Product_List_Form.submit();
			}
			else
			{
				alert("Product List not available right now");
				window.close();
			}
		}
		add_Products_From_Parent_And_Submit();
		</SCRIPT>
		</CFOUTPUT>
	</CFIF>
</CFIF>
</BODY>
</HTML>