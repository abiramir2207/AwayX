<CFSETTING ENABLECFOUTPUTONLY="YES">

<!---// create a new structure //--->
<CFSET stcDefaultValues = StructNew()>

<CFSET stcDefaultValues.Name = "John Doe">
<CFSET stcDefaultValues.Email = "johndoe@somecompany.com">
<CFSET stcDefaultValues.Newsletters = "1,3">
<CFSET stcDefaultValues.MailingList = "NO">
<CFSET stcDefaultValues.Format = "WORD">
<CFSET stcDefaultValues.Occupation = "2,3">


<CFSETTING ENABLECFOUTPUTONLY="NO">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>WDDX Form Wizard: Example 4 (Page 1)</TITLE>
	<STYLE>
	<!--
		p,td,th,div,blockquote { font-family: Arial, Helvetica, sans-serif; font-size: 10pt}
		h3 { font-family: Arial, Helvetica, sans-serif; background-color: #FFFFFF; border-bottom: thin solid #a3a3a3; color: #000000; font-size: 12pt; text-align: left;}
		input,option,textarea { font-family: Arial, Helvetica, sans-serif; font-size: 8pt;}
	-->
	</STYLE>
</HEAD>


<BODY BGCOLOR="#ffffff">

<FORM ACTION="example4_2.cfm" METHOD="POST" NAME="wddxFormWizard">

<H3>Example 4</H3>

<P>This example illustrates how the &lt;CF_FormWizardTools&gt; can be utilized to create
a packet for using on single one page forms. This page uses a single level structure to
create default values&#151;which will automatically be filled in.</P>

<P>Notice how even the form element's default values are overwritten if the structure
you defined overwrites them. (View the compiled source code, and look at the MailingList
element. Notice how the default element checked is for the value "YES", but when the page
loads the value "NO" is selected.)</P>

<P>
<B>Name:</B><BR>
<INPUT TYPE="Text" NAME="Name" VALUE="" STYLE="width: 400px;"><BR>

<B>E-mail:</B><BR>
<INPUT TYPE="Text" NAME="Email" VALUE="" STYLE="width: 400px;"><BR>


<P><B>Newsletters:</B><BR>
<INPUT TYPE="Checkbox" NAME="Newsletters" VALUE="1">
TechNews<BR>
<INPUT TYPE="Checkbox" NAME="Newsletters" VALUE="2">
WebNews<BR>
<INPUT TYPE="Checkbox" NAME="Newsletters" VALUE="3">
Jobs</P>

<P><B>Receive Mailing List?:</B><BR>
Yes <INPUT TYPE="Radio" NAME="MailingList" VALUE="YES" CHECKED>
No <INPUT TYPE="Radio" NAME="MailingList" VALUE="NO">
Maybe <INPUT TYPE="Radio" NAME="MailingList" VALUE="MAYBE">
</P>

<P><B>Newsletter Format:</B><BR>
<SELECT NAME="Format">
	<OPTION VALUE="">-----------------</OPTION>
	<OPTION VALUE="ASCII">ASCII</OPTION>
	<OPTION VALUE="HTML">HTML</OPTION>
	<OPTION VALUE="WORD">MS Word</OPTION>
</SELECT>
</P>

<P><B>Occupation:</B><BR>
<SELECT NAME="Occupation" MULTIPLE SIZE="3">
	<OPTION VALUE="1">Web Developer</OPTION>
	<OPTION VALUE="2">Network Engineer</OPTION>
	<OPTION VALUE="3">Sales</OPTION>
</SELECT>
</P>

<CF_FormWizardTools ACTION="Create" INPUT="#stcDefaultValues#" OUTPUT="wddxPacket">
<!---// TIP: If you are storing the WDDX packet create by wddxFormLibrary, you could do
        something the following instead to either retrieve the stored data, or use the 
        default data
<cfset useLakebaseForGetExistingData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("survey")>
<cfif useLakebaseForGetExistingData>
	<cftry>
		<cfset GetExistingData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("survey", {
				"id" = "eq.#URL.ID#",
				"select" = "wddxpacket"
			}), "wddxpacket"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetExistingData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetExistingData>
<CFQUERY NAME="GetExistingData" DATASOURCE="#Application.DSN#">
	SELECT wddxPacket
	FROM Survey
	WHERE ID = #URL.ID#
</CFQUERY>
</cfif>

<CFIF GetExistingData.RecordCount GT 0>
	<CFSET wddxPacket = GetExistingData.wddxPacket>
<CFELSE>
	<CF_FormWizardTools ACTION="Create" INPUT="#stcDefaultValues#" OUTPUT="wddxPacket">
</CFIF>

--------------------------------------------------------------------------------------->

<CF_FormWizard
	WDDXPACKET="#wddxPacket#"
	SHOWBUTTONS="RESET,NEXT"
	BTN_NEXT="OK"
	SHOWNAVIGATION="NO"
	SHOWDEBUG="NO">

<!--------------------------------------------------------------------------
the above uses the default values, which would look like this written out: 
	<CF_FormWizard
		WDDXPACKET="#wddxPacket#"
		FORMNAME="document.wddxFormWizard"
		JS_WDDX="/cfide/scripts/wddx.js"
		JS_WDDXFORMWIZARD="wddxFormWizard.js"
		SHOWBUTTONS="RESET,NEXT"
		BTN_NEXT="OK"
		BTN_RESET="Reset"
		SAVEONBACK="YES"
		SHOWNAVIGATION="NO"
		SHOWDEBUG="NO">

the "SHOWBUTTONS" attribute excepts three valid options, "BACK", "NEXT" 
and "RESET". the buttons are displayed in the order they appear in the
list
-------------------------------------------------------------------------->

</FORM>

<P><A HREF="index.cfm">Back to Introduction</A></P>

</BODY>
</HTML>
