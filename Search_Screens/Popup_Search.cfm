<!------ Popup_Search.cfm ----->
<CFPARAM NAME="Attributes.FirstFormNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.FirstFieldNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.ActionPage" 	DEFAULT="">

<CFPARAM NAME="Attributes.AlreadySelectedItems" 			DEFAULT="">
<CFPARAM NAME="Attributes.id" 		DEFAULT="">
<CFPARAM NAME="Attributes.FinalItemList" 		DEFAULT="">
<CFPARAM NAME="Attributes.FinisedSearching" 	DEFAULT="0">
<CFPARAM NAME="Attributes.ReturnFinalItemListVariable" 	DEFAULT="">

<CFPARAM NAME="Attributes.LastFormNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.LastFieldNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.DescFieldNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.DescField" 	DEFAULT="">
<cfparam name="Attributes.ExcludeListFieldname" 	default="">

<CFPARAM NAME="Attributes.importType" 	DEFAULT="">
<CFPARAM NAME="Attributes.ReloadForm" 	DEFAULT="1">
<CFPARAM NAME="Attributes.PageSource" 	DEFAULT="">
<CFPARAM NAME="Attributes.TemplateID" 	DEFAULT="">
<CFPARAM NAME="Attributes.TemplateFiltersID" 	DEFAULT="">
<CFPARAM NAME="Attributes.prodRefresh" 	DEFAULT="0">
<CFPARAM NAME="Attributes.ExcludeItemID" 	DEFAULT="0">
<CFPARAM NAME="Attributes.IncludeIOPGFlag" 	DEFAULT="0">
<!--- Initially the FlexAppname was hardcoded to "ContractMain'. It is set as default, so that there is not need
      to pass "FlexAppName" as a variable from that project. 
--->
<CFPARAM NAME="Attributes.FlexAppName" 	DEFAULT="ContractMain">
<CFPARAM NAME="Attributes.vendorSearchType" DEFAULT="1">
<CFPARAM NAME="Attributes.QuickPay" 	DEFAULT="0">
<CFPARAM NAME="Attributes.Settlements" 	DEFAULT="0">

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<CFSET expectingAttributeList = "FirstFormNameVariable,FirstFieldNameVariable,ActionPage,AlreadySelectedItems,id,FinalItemList,FinisedSearching,ReturnFinalItemListVariable,LastFormNameVariable,LastFieldNameVariable,importType,ExcludeListFieldname">
<!------ For the first time do this ----->
<CFIF isDefined(Attributes.FirstFormNameVariable)>
	<CFSET FormName = Evaluate(Attributes.FirstFormNameVariable)>
	<CFSET FieldName = Evaluate(Attributes.FirstFieldNameVariable)>
	<CFOUTPUT>
	<FORM ACTION="#Attributes.ActionPage#" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="Formname" id="Formname" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FormName)#">
		<INPUT NAME="FieldName" id="FieldName" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FieldName)#">		
		<INPUT NAME="FinalItemList" id="FinalItemList" TYPE="HIDDEN" VALUE="#EncodeForHTMLAttribute(attributes.id)#">
		<!--- <INPUT NAME="ReloadForm" TYPE="text" VALUE="#attributes.ReloadForm#"> --->	
		<INPUT NAME="importType" id=="importType" TYPE="HIDDEN" VALUE="#EncodeForHTMLAttribute(Attributes.importType)#">
		<CFIF Attributes.ExcludeListFieldname NEQ "">
		<INPUT NAME="ExcludeList" id="ExcludeList" TYPE="HIDDEN" VALUE="">
		</CFIF>
		<CFLOOP COLLECTION="#Attributes#" ITEM="ThisItem">
			<CFIF NOT ListFindNoCase(expectingAttributeList, ThisItem, ",")>
			<INPUT TYPE="HIDDEN" ID="#ThisItem#" NAME="#ThisItem#" VALUE="#Evaluate("Attributes.#ThisItem#")#">
			</CFIF>
		</CFLOOP>
	</FORM>
	<cfif FormName EQ 'flex'>
	<script>
		document.all.MyForm.submit();
	</script>
	<cfelse>
	<script>
		var parentForm = opener.document.#FormName#;
		var parentField;
   
		
		if(parentForm != null)
		{
			parentField = parentForm.#FieldName#;
			if(parentField)
			{
				this.document.all.FinalItemList.value = parentField.value;	
			}
			
			<CFIF Attributes.ExcludeListFieldname NEQ "">
			parentField = parentForm.#Attributes.ExcludeListFieldname#;
			if(parentField)
			{
     // alert(parentField.value);
      
				this.document.all.ExcludeList.value = parentField.value;				
			}
			</CFIF>
		
			document.all.MyForm.submit()

		}
		else
		{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
			window.close()
		}
	</script>
	</cfif>
	</CFOUTPUT>
	<cfabort>
</CFIF>



<CFSET listofitemstodelete = "">

<CFLOOP INDEX="ListItem" LIST="#Attributes.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(Attributes.id, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#Attributes.id#" DELIMITERS=",">
	<CFIF listfind(Attributes.FinalItemList, ListItem, ",") EQ 0>
		<CFIF Attributes.importType EQ "single">
			<CFSET Attributes.FinalItemList = ListItem>
		<CFELSE>
			<CFSET Attributes.FinalItemList = ListAppend(Attributes.FinalItemList, ListItem, ",")>
		</CFIF>				
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(Attributes.FinalItemList,ListItem, ",") GT 0>
		<CFSET Attributes.FinalItemList = listdeleteat(Attributes.FinalItemList, listfind(Attributes.FinalItemList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>

<CFSET "Caller.#Attributes.ReturnFinalItemListVariable#" = Attributes.FinalItemList>

<CFIF Attributes.FinisedSearching EQ 1>

	<CFSET LastFormName = Evaluate(Attributes.LastFormNameVariable)>
	<CFSET LastFieldName = Evaluate(Attributes.LastFieldNameVariable)>
	<CFSET DescFieldName = Evaluate(Attributes.DescFieldNameVariable)>

	<CFOUTPUT>
	<cfif FormName EQ 'flex'>
		<!--- implement call to externalinterface --->
		<script>
			// This function returns the appropriate reference, 
			// depending on the browser.
			function getFlexApp(appName)
			{
			  if (navigator.appName.indexOf ("Microsoft") !=-1)
			  {
			    return opener.window[appName];
			  } 
			  else 
			  {
			    return opener.document[appName];
			  }
			}
			function saveVendor()
			{
			  getFlexApp('#Attributes.FlexAppName#').saveVendor('#Attributes.FinalItemList#','#Replace(Attributes.DescField,"'","\'","ALL")#');
			}
			saveVendor();
			window.close();
		</script>
	<cfelse>
		<script>
			var parentForm = opener.document.all.#LastFormName#;
		<cfif Attributes.QuickPay>
			parentForm.vendor_id.value = '#Attributes.FinalItemList#';
			window.opener.vendorInfo();
			window.close();
		<cfelseif Attributes.Settlements>
			opener.document.all.Vendor.value = '#Attributes.FinalItemList#';
			window.opener.vendorInfo()
			window.close();
		<cfelse>
			if(parentForm){ 
							
				var parentField = parentForm.#LastFieldName#;
				if(parentField){ 
					parentField.value = '#Attributes.FinalItemList#';					
				<CFif DescFieldName NEQ "">				
					var descField = parentForm.#DescFieldName#;
					if(descField){
						descField.value = '#Replace(Attributes.DescField,"'","\'","ALL")#';
					}
					else {
					  // look for element that is not form input
					  descField = opener.document.all.#DescFieldName#;
					  if (descField) {
						  descField.innerText = '#Replace(Attributes.DescField,"'","\'","ALL")#';
					  }
					}
				</CFIF>
				<cfif Attributes.PageSource IS "ProgramVendorSearch">
					window.opener.ShowPayeeInfo.style.display = "";
					if (parentForm.AlreadySelectedVendor.value == 1 && (opener.document.getElementById("ShowPayeeSearch"))){
						window.opener.ShowPayeeSearch.style.display = "none";
					}
				</Cfif>
				<cfif Attributes.PageSource IS "ProgramVendorSearch" OR Attributes.PageSource IS "VendorSearch">
					callfireEvent(opener.document,parentForm.Vendor_ID,'Change');
				</Cfif>
				
				<!--- You don't always want to reload the form --->
				<Cfif Attributes.ReloadForm>
					parentForm.submit();
				</cfif>
					window.close()
				}
			}
		</Cfif>
		</script>
	</cfif>
	</CFOUTPUT>
	<CFABORT>
</CFIF>
