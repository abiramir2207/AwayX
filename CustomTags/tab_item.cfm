
<CFASSOCIATE BASETAG="CF_TAB_GROUP">
<CFSET TagData="#GetBaseTagData('CF_TAB_GROUP')#">

<CFPARAM NAME="TagData.ThisTag.TabCounter"		DEFAULT="0">
<CFPARAM NAME="URL.Tab"							DEFAULT="1">
<CFPARAM NAME="Attributes.URLVariableName"		DEFAULT="ID">
<CFPARAM NAME="Attributes.URLVariableValue"		DEFAULT="#createuuid()#">
<!--- <CFPARAM NAME="Attributes.URLVariableValue"		DEFAULT="#RandRange(111111111, 999999999)#"> --->
<CFPARAM NAME="Attributes.Title"				DEFAULT="Tab #TagData.ThisTag.TabCounter#">
<CFPARAM NAME="Attributes.ToolTip"				DEFAULT="Click here to see the contents of tab #TagData.ThisTag.TabCounter#">
<CFPARAM NAME="Attributes.ContentAlign"			DEFAULT="left">
<CFOUTPUT>
	<CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#">
		<CFCASE VALUE="start">
			<CFIF TagData.ThisTag.TabCounter NEQ URL.Tab>
				<CFSET TagData.ThisTag.TabCounter="#IncrementValue(TagData.ThisTag.TabCounter)#">
				<CFEXIT METHOD="ExitTag">
			</CFIF>
		</CFCASE>
		<CFCASE VALUE="end">
			<CFSET TagData.ThisTag.TabCounter="#IncrementValue(TagData.ThisTag.TabCounter)#">
		</CFCASE>
	</CFSWITCH>
</CFOUTPUT>


