<!------ Popup_Search.cfm ----->
 
<CFPARAM NAME="Attributes.FirstFormNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.FirstFieldNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.ActionPage" 	DEFAULT="">

<CFPARAM NAME="Attributes.AlreadySelectedDists" 			DEFAULT="">
<CFPARAM NAME="Attributes.id" 		DEFAULT="">
<CFPARAM NAME="Attributes.FinalItemList" 		DEFAULT="">
<CFPARAM NAME="Attributes.FinisedSearching" 	DEFAULT="0">
<CFPARAM NAME="Attributes.ReturnFinalOprListVariable" 	DEFAULT="">

<CFPARAM NAME="Attributes.LastFormNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.LastFieldNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.DescFieldNameVariable" 	DEFAULT="">
<CFPARAM NAME="Attributes.DescField" 	DEFAULT="">
<cfparam name="Attributes.ExcludeListFieldname" 	default="">

<CFPARAM NAME="Attributes.importType" 	DEFAULT="">
<CFPARAM NAME="Attributes.ReloadForm" 	DEFAULT="1">
<CFPARAM NAME="Attributes.PageSource" 	DEFAULT="">

<CFSET expectingAttributeList = "FirstFormNameVariable,FirstFieldNameVariable,ActionPage,AlreadySelectedOprss,id,FinalOprList,FinisedSearching,ReturnFinalOprListVariable,LastFormNameVariable,LastFieldNameVariable,importType,ExcludeListFieldname">
<!------ For the first time do this ----->
 
<CFIF isDefined(Attributes.FirstFormNameVariable)>
	<cfset FormName = Evaluate(Attributes.FirstFormNameVariable)>
	<cfset FieldName = Evaluate(Attributes.FirstFieldNameVariable)>
	<CFOUTPUT>

	<FORM ACTION="#Attributes.ActionPage#" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="Formname" TYPE="Hidden" VALUE="#FormName#">
		<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#FieldName#">		
		<INPUT NAME="FinalOprList" TYPE="HIDDEN" VALUE="">
		<!--- <INPUT NAME="ReloadForm" TYPE="text" VALUE="#attributes.ReloadForm#"> --->	
		<INPUT NAME="importType" TYPE="HIDDEN" VALUE="#Attributes.importType#">
		<CFIF Attributes.ExcludeListFieldname NEQ "">
		<INPUT NAME="ExcludeList" TYPE="HIDDEN" VALUE="">
		</CFIF>
		<CFLOOP COLLECTION="#Attributes#" ITEM="ThisOpr">
			<CFIF NOT ListFindNoCase(expectingAttributeList, ThisOpr, ",")>
			<INPUT TYPE="HIDDEN" ID="#ThisOpr#" NAME="#ThisOpr#" VALUE="#Evaluate("Attributes.#ThisOpr#")#">
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
				this.document.all.FinalOprList.value = parentField.value;				
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



<CFSET listofOprstodelete = "">

<CFLOOP INDEX="ListOpr" LIST="#Attributes.AlreadySelectedOprs#" DELIMITERS=",">
	<CFIF ListFindNoCase(Attributes.id, ListOpr, ",") EQ 0>
		<CFSET listofoprstodelete = listappend(listofoprstodelete, ListOpr, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListOpr" LIST="#Attributes.id#" DELIMITERS=",">
	<CFIF ListFindNoCase(Attributes.FinalOprList, ListOpr, ",") EQ 0>
		<CFIF Attributes.importType EQ "single">
			<CFSET Attributes.FinalOprList = ListOpr>
		<CFELSE>
			<CFSET Attributes.FinalOprList = ListAppend(Attributes.FinalOprList, ListOpr, ",")>
		</CFIF>				
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListOpr" LIST="#listofoprstodelete#" DELIMITERS=",">
	<CFIF ListFindNoCase(Attributes.FinalOprList,ListOpr, ",") GT 0>
		<CFSET Attributes.FinalOprList = listdeleteat(Attributes.FinalOprList, ListFindNoCase(Attributes.FinalOprList,ListOpr, ","), ",")>
	</CFIF>
</CFLOOP>

<CFSET "Caller.#Attributes.ReturnFinalOprListVariable#" = Attributes.FinalOprList>

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
			  getFlexApp('ContractMain').saveVendor('#Attributes.FinalOprList#','#Replace(Attributes.DescField,"'","\'","ALL")#');
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
					parentField.value =   '#Attributes.FinalOprList#';
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
