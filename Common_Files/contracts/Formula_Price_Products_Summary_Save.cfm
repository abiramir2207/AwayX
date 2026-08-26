<!------ Formula_Price_Products_Summary_Save.cfm ----->
<CFPARAM NAME="Program_ID" 	DEFAULT="">
<CFSAVECONTENT variable="Formula_Content">
	<CFINCLUDE template="Formula_Price_Products_Summary.cfm">
</CFSAVECONTENT>

<CFSET Formula_Content = REReplaceNoCase(Formula_Content, "<a[^>]*?>", "", "All")>
<CFSET Formula_Content = REReplaceNoCase(Formula_Content, "</a>", "", "All")>
<CFSET Formula_Content = ReplaceNoCase(Formula_Content, "<D_A HREF", "<A HREF", "All")>
<CFSET Formula_Content = ReplaceNoCase(Formula_Content, "<D_A NAME", "<A NAME", "All")>
<CFSET Formula_Content = ReplaceNoCase(Formula_Content, "</D_A>", "</A>", "All")>

<CFSET SHOW_FORMULA_PRICING_DETAIL_INFO = 1>
<CFIF SHOW_FORMULA_PRICING_DETAIL_INFO>
	 <CFFILE 	ACTION = "write"
				FILE="#Formula_File_Path#"
				OUTPUT="#Formula_Content#">
</CFIF>