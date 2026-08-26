<CFPARAM NAME="ACTION"  DEFAULT="AddFreightBracket">

<cfmodule template="/customTags/layout.cfm"
              layoutID = "freightSettings"
              selectedIndex = "#(action eq "AddFreightBracket" ? 0 : 1)#" >

<CFSWITCH expression="#ACTION#">
	<CFCASE value="AddFreightBracket">
		<cfinclude template ="Freight_Bracket_Settings.cfm">
	</CFCASE>
	<CFCASE value="UploadOBF">
		<cfinclude template ="Upload_Outbound_Freight.cfm">
	</CFCASE>
</CFSWITCH>

</cfmodule>