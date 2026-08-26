<!------ Popup_Search.cfm ----->
 
<CFPARAM NAME="Attributes.FirstFormNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.FirstFieldNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.ActionPage" 	DEFAULT="">

<CFPARAM NAME="Attributes.AlreadySelectedDists" 			DEFAULT="">
<CFPARAM NAME="Attributes.id" 		DEFAULT="">
<CFPARAM NAME="Attributes.FinalItemList" 		DEFAULT="">
<CFPARAM NAME="Attributes.FinisedSearching" 	DEFAULT="0">
<CFPARAM NAME="Attributes.ReturnFinalDistListVariable" 	DEFAULT="">

<CFPARAM NAME="Attributes.LastFormNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.LastFieldNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.DescFieldNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.DescField" 	DEFAULT="">
<cfparam name="Attributes.ExcludeListFieldname" 	default="">

<CFPARAM NAME="Attributes.importType" 	DEFAULT="">
<CFPARAM NAME="Attributes.ReloadForm" 	DEFAULT="1">
<CFPARAM NAME="Attributes.PageSource" 	DEFAULT="">
 
<CFSET expectingAttributeList = "FirstFormNameVariable,FirstFieldNameVariable,ActionPage,AlreadySelectedDists,id,FinalDistList,FinisedSearching,ReturnFinalDistListVariable,LastFormNameVariable,LastFieldNameVariable,importType,ExcludeListFieldname">
<!------ For the first time do this ----->
<CFIF isDefined(Attributes.FirstFormNameVariable)>
	<cfset FormName = Evaluate(Attributes.FirstFormNameVariable)>
	<CFSET FieldName = Evaluate(Attributes.FirstFieldNameVariable)>
	<CFOUTPUT>
	<FORM ACTION="#Attributes.ActionPage#" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="Formname" TYPE="Hidden" VALUE="#FormName#">
		<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#FieldName#">		
		<INPUT NAME="FinalDistList" TYPE="HIDDEN" VALUE="">
		<!--- <INPUT NAME="ReloadForm" TYPE="text" VALUE="#attributes.ReloadForm#"> --->	
		<INPUT NAME="importType" TYPE="HIDDEN" VALUE="#Attributes.importType#">
		<CFIF Attributes.ExcludeListFieldname NEQ "">
		<INPUT NAME="ExcludeList" TYPE="HIDDEN" VALUE="">
		</CFIF>
		<CFLOOP COLLECTION="#Attributes#" ITEM="ThisDist">
			<CFIF NOT ListFindNoCase(expectingAttributeList, ThisDist, ",")>
			<INPUT TYPE="HIDDEN" ID="#ThisDist#" NAME="#ThisDist#" VALUE="#Evaluate("Attributes.#ThisDist#")#">
			</CFIF>
		</CFLOOP>
	</FORM>
	<cfif FormName EQ 'flex'>
	<script>
		document.all.MyForm.submit();
	</script>
	<cfelse>
	<script>
 
		var parentForm = opener.document.all.#FormName#;
		var parentField;
		
		if(parentForm != null)
		{
			parentField = parentForm.#FieldName#;
			if(parentField)
			{
				this.document.all.FinalDistList.value = parentField.value;				
			}
			
			<CFIF Attributes.ExcludeListFieldname NEQ "">
			parentField = parentForm.#Attributes.ExcludeListFieldname#;
			if(parentField)
			{
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
</CFIF>



<CFSET listofdiststodelete = "">

<CFLOOP INDEX="ListDist" LIST="#Attributes.AlreadySelectedDists#" DELIMITERS=",">
	<CFIF ListFindNoCase(Attributes.id, ListDist, ",") EQ 0>
		<CFSET listofdiststodelete = listappend(listofdiststodelete, ListDist, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListDist" LIST="#Attributes.id#" DELIMITERS=",">
	<CFIF ListFindNoCase(Attributes.FinalDistList, ListDist, ",") EQ 0>
		<CFIF Attributes.importType EQ "single">
			<CFSET Attributes.FinalDistList = ListDist>
		<CFELSE>
			<CFSET Attributes.FinalDistList = ListAppend(Attributes.FinalDistList, ListDist, ",")>
		</CFIF>				
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListDist" LIST="#listofdiststodelete#" DELIMITERS=",">
	<CFIF ListFindNoCase(Attributes.FinalDistList,ListDist, ",") GT 0>
		<CFSET Attributes.FinalDistList = listdeleteat(Attributes.FinalDistList, ListFindNoCase(Attributes.FinalDistList,ListDist, ","), ",")>
	</CFIF>
</CFLOOP>

<CFSET "Caller.#Attributes.ReturnFinalDistListVariable#" = Attributes.FinalDistList>
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
			  getFlexApp('ContractMain').saveVendor('#Attributes.FinalDistList#','#Replace(Attributes.DescField,"'","\'","ALL")#');
			}
			saveVendor();
			window.close();
		</script>
	<cfelse>
  <!--- in else #LastFormName# #LastFieldName#<br> --->
  
		<script>
			var parentForm = opener.document.all.#LastFormName#;
			if(parentForm)
			{ 
				var parentField = parentForm.#LastFieldName#;
       
				if(parentField)
				{ 
					parentField.value =   '#Attributes.FinalDistList#';
					<!--- <cfif DescFieldName NEQ "">				
				/*		var descField = parentForm.#DescFieldName#;
						if(descField)
						{
							descField.value = '#Replace(Attributes.DescField,"'","\'","ALL")#';
						}*/
					</cfif> --->
			
					<!--- You don't always want to reload the form --->
          
					<Cfif Attributes.ReloadForm>
					  parentForm.submit();
					</cfif>
					window.close()
				}
			}
		</script>
	</cfif>
	</CFOUTPUT>
	<CFABORT>
</CFIF>
