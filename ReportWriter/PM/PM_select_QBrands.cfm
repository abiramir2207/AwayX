
<CFIF isdefined("URL.FormName")>
	<FORM ACTION="pm_select_QBrands.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
	</FORM>
	<script>
		if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
			this.document.all.FinalItemList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.QBrand_List.value
			document.all.MyForm.submit()
		}
		else{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
			window.close()
		}
	</script>
	<cfabort>
</CFIF>

<!------<cfparam name="URL.FormName" 	default="">
<cfparam name="Form.ParentFormname" 	default="#URL.FormName#">----->

<CFSET PAGE_TITLE="Select Program QBrands">
<CFSET GROUP="Contracts">


<CFPARAM name="FORM.button_caption"					default="continue">
<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedQBrands"	Default="1">
	
<CFSET FORM.LoadSavedQBrands=0>

<CFSET listofitemstodelete = "">

<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(FORM.SelectedITEMS, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedITEMS#" DELIMITERS=",">
	<CFIF listfind(Form.FinalItemList, ListItem, ",") EQ 0>
		<CFSET Form.FinalItemList = listappend(FinalItemList, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.FinalItemList,ListItem, ",") GT 0>
		<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>

<CFIF FORM.finishedselectingitems EQ 1>
	<script>
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.QBrand_List.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit()
		window.close()		
	</script>
	<CFABORT>
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="0">

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>


	<FORM ACTION="pm_select_QBrands.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<BR><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<br>

	<CFQUERY NAME="TheQuery" DATASOURCE="#application.datasource#">
		<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_type_group_syntax#">
	</CFQUERY>	
	
	<!----------
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
	Select 	distinct qb.Q_Brand_ID,qb.Q_Brand,pqb.LOB, qb.Q_Brand_Legacy
	From	Product_Q_Brand_Desc pqb,Q_Brand_Desc qb, product_category_lob_active pcla
	Where	pqb.BSA_Foodservice_Items_Master_ID=pcla.BSA_Foodservice_Items_Master_ID
		and	pqb.Q_Brand_ID=qb.Q_Brand_ID
		and	pqb.LOB='F'
		and pqb.Deleted=0
		and qb.Deleted=0
		Order By qb.Q_Brand
	</CFQUERY>
	----------->
	
	
<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<!------<cf_Number_of_Rows maxrows=10>----->
<cf_Number_of_Rows maxrows="#TheQuery.recordCount#">

	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many QBrands in the list below while selecting them all. Press OK if you wish to continue")<CFELSE>0==0</CFIF>) {
					for (var i=0;i<MyForm.elements.length;i++)
						{
							var e = MyForm.elements[i];
							if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
								e.checked = MyForm.allbox.checked;
							}
						}
				//toggleRowColors()
				}
				else {
					document.all.allbox.checked = false;
				}
			}
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	</SCRIPT>	
	<BR>

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
		<CFOUTPUT>
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>#application.returned_customer_setting.type_group_label_singular#<CFELSE>#application.returned_customer_setting.type_group_label_plural#</CFIF></LEGEND>
		</CFOUTPUT>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="685" CLASS="Maintable">
				<CFOUTPUT>
				<TR ID="header" BGCOLOR="ffce84">
					<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all QBrands"></TD>
					<TD align="left" NOWRAP ID="header"><B>Legacy</B></TD>
					<TD align="left" NOWRAP ID="header"><B>#application.returned_customer_setting.type_group_label_plural#</B></TD>
				</TR>
				</CFOUTPUT>
			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<!------<cf_cryp string="#TheQuery.BSA_Foodservice_Brokers_ID#" type="en" key="#request.key#">----->

				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.TYPE_GROUP_DESC_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.TYPE_GROUP_DESC_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.TYPE_GROUP_DESC_ID), ",")></CFIF>></TD>
					<TD NOWRAP>#TheQuery.TYPE_GROUP_LEGACY#&nbsp;</TD>
					<TD NOWRAP>#TheQuery.TYPE_GROUP_DESC#&nbsp;</TD>					
				</TR>
			</CFOUTPUT>
			</TABLE>

			<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
				<CF_Next_Previous_For_Forms
				formname="MyForm"
				query="TheQuery"
				maxpages="40"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams="">
			</DIV>

		</CFIF>
	</FIELDSET>
	


	<CFPARAM name="TheQuery.Recordcount" default="0">
	<SCRIPT>
		function resetform() {
			document.all.FinalItemList.value = 0;
			document.all.AlreadySelectedItems.value = 0;
		
			<CFIF TheQuery.Recordcount GT 0>
				document.all.SelectedITEMS.value = 0;
				for(var x=0; x<document.all.MyForm.elements.length;x++) {
					document.all.MyForm.elements[x].checked = false
				}
				
			</CFIF>
			document.all.MyForm.submit();
		}
		
		//findselectboxes();
	</SCRIPT>
<INPUT TYPE="hidden" NAME="ParentFormname" 						VALUE="<CFOUTPUT>#FORM.ParentFormname#</CFOUTPUT>">	
<INPUT TYPE="hidden" NAME="FinalItemList" VALUE="<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="<CFOUTPUT>#Form.AlreadySelectedItems#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="LoadSavedOperators" VALUE="0">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="<CFOUTPUT>#startrow#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="<CFOUTPUT>#frompage#</CFOUTPUT>">
<input type="hidden" name="button_caption" value="<CFOUTPUT>#FORM.Button_Caption#</CFOUTPUT>">
</FORM>
<CFOUTPUT>
	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="FF0000">[</FONT>
	<a HREF="##" onClick="javascript: finishedSearching()"> import selected #application.returned_customer_setting.type_group_label_plural# </a>
	<FONT COLOR="FF0000">]</FONT></B>
	</FONT>

	<FONT SIZE="2">
	<B><FONT COLOR="FF0000">[</FONT>
	<a HREF="##" STYLE="cursor: hand;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned #application.returned_customer_setting.type_group_label_plural# </a>
	<FONT COLOR="FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="FF0000">[</FONT>
	<a HREF="##" STYLE="cursor: hand;" onClick="removeAllProducts()"> remove all selected #application.returned_customer_setting.type_group_label_plural# </a>
	<FONT COLOR="FF0000">]</FONT></B>
	</FONT>
	<BR>	
	</DIV>
	</cfif> 
</CFOUTPUT>
<SCRIPT>
	<cfif TheQuery.recordcount GT 0>
		function importAllProducts(recordcount){
			<!------//recordcount = <CFOUTPUT>#ListLen(whole_Product_List)#</CFOUTPUT>;----->
			if(parseInt(recordcount) == 1) pString = "Product";
			else pString = "Products";
			
			if(confirm("Do you want to import all " + recordcount + " records from your search?")){
				document.all.allbox.checked = true;
				document.all.allbox.fireEvent("onclick");
				
				document.MyForm.finishedselectingitems.value = 1;
				if(document.MyForm.FinalItemList.value.length > 0){
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.TYPE_GROUP_DESC_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= document.SearchForm.FinalUPCList.value + "," + "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";
					//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}
				else{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQuery.TYPE_GROUP_DESC_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}
	
				document.MyForm.submit();
			}
			else
			{
			
			}
		}
		
		function removeAllProducts(){
			
			if(confirm("By pressing OK all selected records will be unselected")){
				document.all.allbox.checked = false;
				document.all.allbox.fireEvent("onclick");
				
				document.MyForm.finishedselectingitems.value = 0;
				document.MyForm.FinalItemList.value 	= "";
				document.MyForm.AlreadySelectedItems.value 	= "";
			}
			else
			{
			
			}
		}	
		
		function finishedSearching() {
			document.all.finishedselectingitems.value = 1
			document.all.MyForm.submit();
		}	
	</cfif>
</SCRIPT>



