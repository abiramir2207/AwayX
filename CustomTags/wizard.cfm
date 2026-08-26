<!---
Id: wizard.cfm, v1.0.1 8/24/00 2:15:07 PM dbabbitt
Description: This parent tag has two distinct jobs. 
             It collects the final bits of 
			 information we need and then, using 
			 its child tags, it starts the wizard 
			 process. The wizard tag gets called 
			 twice, once when it’s opened and once 
			 when it’s closed, so we can collect 
			 the additional information when it’s 
			 opened via passed in attributes. Then, 
			 when the tag is closed, we can start 
			 the wizard process. The two additional 
			 pieces of information the wizard tag 
			 collects are the FinishURL and the 
			 CancelURL. These will be the URLs the 
			 wizard loads if the Finish or Cancel 
			 button is pushed.
--->

<CFIF NOT CompareNoCase(ThisTag.ExecutionMode, 'start')>
	<CFPARAM Name="Attributes.FinishURL" Default="">
	<CFPARAM NAME="Attributes.CancelURL" DEFAULT="#CGI.Script_Name#">
	<CFSET thisTag.FieldArray="#ArrayNew(1)#">
	<!--- This is the wizard's closing tag --->
	<CFELSE>
	<!--- Setup Fields struct and convert to WDDX --->
	<CFSCRIPT>
Caller.Fields = StructNew();
for (i = 1; i LTE ArrayLen(thisTag.FieldArray); i = i+1) {
	FieldAttributes = thisTag.FieldArray[i];
	StructInsert(Caller.Fields, FieldAttributes.Name, FieldAttributes.Default);
	} 
		</CFSCRIPT>
	<CFWDDX ACTION="CFML2WDDX" INPUT="#Caller.Fields#" OUTPUT="FieldWDDX" USETIMEZONEINFO="Yes">
	<CFSET na="#StructClear(Caller.Fields)#">
	<!--- setup Screens list --->
	<CFSCRIPT>
Screens="";
for (i = 1; i LTE ArrayLen(thisTag.ScreenArray); i = i+1) {
	ScreenAttributes = thisTag.ScreenArray[i];
	Screens = ListAppend(Screens, ScreenAttributes.URL);
	}
Screens = ListPrepend(Screens, Attributes.CancelURL);
Screens = ListAppend(Screens, Attributes.FinishURL);
		</CFSCRIPT>
	<!--- Autosubmitting form with hidden fields --->
	<CFOUTPUT>
		<FORM ACTION="#ListGetAt(Screens, 2)#" METHOD="post" NAME="WizForm">
			<INPUT TYPE="hidden" NAME="WizFields" VALUE="#HTMLEditFormat(FieldWDDX)#">
			<INPUT TYPE="hidden" NAME="WizScreens" VALUE="#Screens#">
			<INPUT TYPE="hidden" NAME="WizCurrentScreen" VALUE="2"></FORM>
		<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
document.fgColor=document.bgColor;
document.WizForm.submit();
//-->
			</SCRIPT></CFOUTPUT></CFIF>

<!---
	Log: wizard.cfm
	Revision 1.0 8/24/00 2:25:14 PM dbabbitt
	This parent tag has two distinct jobs. 
	It collects the final bits of 
	information we need and then, using its 
	child tags, it starts the wizard process. 
	The wizard tag gets called twice, once 
	when it’s opened and once when it’s 
	closed, so we can collect the additional 
	information when it’s opened via passed 
	in attributes. Then, when the tag is 
	closed, we can start the wizard process. 
	The two additional pieces of information 
	the wizard tag collects are the FinishURL 
	and the CancelURL. These will be the URLs 
	the wizard loads if the Finish or Cancel 
	button is pushed.
	--->