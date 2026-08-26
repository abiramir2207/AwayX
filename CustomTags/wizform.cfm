<!---
Id: wizard.cfm, v1.0.6 8/24/00 11:42:54 PM dbabbitt
Description: This custom tag is used to control 
             the wizard pages themselves. To 
			 control navigation and state issues 
			 just replace your form tag with this 
			 wizform tag. The wizform tag will be 
			 called twice, once on start and once 
			 on end, just like the form tag. When 
			 it’s called as the starting or 
			 opening tag, we update our Fields 
			 structure to account for any changes 
			 made on the previous screen, then do 
			 our duty as a replacement for the form 
			 tag and create a form.
--->

<CFSET ButtonWidth=90>
<CFIF NOT CompareNoCase(ThisTag.ExecutionMode, 'start')>
	<CFSET Caller.Fields="#StructNew()#">
	<!--- deserialize wddx into Field struct --->
	<CFWDDX ACTION="WDDX2CFML" INPUT="#FORM.WizFields#" OUTPUT="Caller.Fields">
	<!--- Update Fields struct for all fields submitted via FORM --->
	<CFSCRIPT>
for (thisKey in Caller.Fields) {
	if(isDefined("FORM." & thisKey)) {
		Caller.Fields[thisKey]=evaluate("FORM." & thisKey);
		}
	}
		</CFSCRIPT>
	<!--- serialize Fields structure back into wddx packet and then hide in hidden field --->
	<CFWDDX ACTION="CFML2WDDX" INPUT="#Caller.Fields#" OUTPUT="FieldWDDX" USETIMEZONEINFO="Yes">
	<CFSET title="Step #Evaluate(FORM.WizCurrentScreen - 1)# of #Evaluate(ListLen(FORM.WizScreens)-2)#">
	<CFSET TabWidth="100%">
	<CFINCLUDE TEMPLATE="/includes/tab_top_new.cfm">
	<FORM Name="WizForm" Method="Post">
		<CFOUTPUT>
			<INPUT TYPE="hidden" NAME="WizFields" VALUE="#HTMLEditFormat(FieldWDDX)#">
			<INPUT TYPE="hidden" NAME="WizScreens" VALUE="#FORM.WizScreens#">
			<INPUT TYPE="hidden" NAME="WizCurrentScreen" VALUE="0"></CFOUTPUT>
		<!--- This is the wizform closing tag --->
		<CFELSE>
		<!--- Add appropriate navigation buttons --->
		<CFOUTPUT><TABLE border=0 cellspacing=0 cellpadding=0><TR>
			<TD WIDTH="#ButtonWidth#" ALIGN="right" VALIGN="middle">
				&nbsp; 
				<CFIF FORM.WizCurrentScreen GT 2><INPUT TYPE="submit" NAME="WizBack" VALUE=" &lt; Back " ACCESSKEY="B" onClick="document.WizForm.action='#ListGetAt(FORM.WizScreens, FORM.WizCurrentScreen - 1)#'; document.WizForm.WizCurrentScreen.value=#evaluate('FORM.WizCurrentScreen - 1')#"></CFIF></TD>
			<TD WIDTH="#ButtonWidth#" ALIGN="left" VALIGN="bottom">
				<CFIF FORM.WizCurrentScreen GTE (ListLen(FORM.WizScreens) - 1)>
					<INPUT TYPE="submit" NAME="WizFinish" VALUE=" Finish " ACCESSKEY="F" onClick="document.WizForm.action='#ListLast(FORM.WizScreens)#'; document.WizForm.WizCurrentScreen.value=#evaluate('FORM.WizCurrentScreen + 1')#">
					<CFELSE>
					<INPUT TYPE="submit" NAME="WizNext" VALUE=" Next &gt; " ACCESSKEY="N" onClick="document.WizForm.action='#ListGetAt(FORM.WizScreens, FORM.WizCurrentScreen + 1)#'; document.WizForm.WizCurrentScreen.value=#evaluate('FORM.WizCurrentScreen + 1')#"></CFIF>
				&nbsp; </TD>
			<TD WIDTH="#ButtonWidth#" ALIGN="center" VALIGN="middle"><INPUT TYPE="submit" NAME="WizCancel" VALUE=" Cancel " ACCESSKEY="C" onClick="document.WizForm.action='#ListFirst(FORM.WizScreens)#'; document.WizForm.WizCurrentScreen.value=2"></TD></TR></TABLE></CFOUTPUT>
		</FORM>
	<CFINCLUDE TEMPLATE="/includes/tab_bottom_new.cfm">
	<CFSET na="#StructClear(Caller.Fields)#"></CFIF>

<!---
	Log: wizform.cfm
	Revision 1.0 8/24/00 2:55:16 PM dbabbitt
	This custom tag is used to control the 
	wizard pages themselves. To control 
	navigation and state issues just replace 
	your form tag with this wizform tag. The 
	wizform tag will be called twice, once 
	on start and once on end, just like the 
	form tag. When it’s called as the 
	starting or opening tag, we update our 
	Fields structure to account for any 
	changes made on the previous screen, then 
	do our duty as a replacement for the 
	form tag and create a form.
	--->