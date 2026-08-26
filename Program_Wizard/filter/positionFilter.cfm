<!--- label D26730  by Dinesh --->	
<cfparam name="filter_dr" default="0">
<cfif NOT isdefined(Template_Filters_Id)>
<cfset editTemplateFilter.Template_Filters_Id = #trim(url.Template_Filters_Id)#>
<cfset ID = #trim(url.ID)#>
<cfset LockedBy_Current_User = #trim(url.Locked)#>
<cfset filter_dr = 1>
</cfif>
<!--- label D26730  by Dinesh --->	

<cfscript>
	//url.showsearch 		= 1;
	//URL.FormName 		= 'frmTemplateFilter';
	//URL.AllowImportAll 	= 0;
	//URL.FieldName		= '';
	UrlString = 			'?Formname=MyForm';
	UrlString = UrlString & '&FieldName=User_Positions_List';
	UrlString = UrlString & '&AllowImportAll=1';
	UrlString = UrlString & '&EnableListOfPositionsAboveMine=1';
	UrlString = UrlString & '&bMarketPrice=1';
	UrlString = UrlString & '&Template_Filters_Id=' & editTemplateFilter.Template_Filters_Id;
	UrlString = UrlString & '&Template_Id=' & #ID#;
	UrlString = UrlString & '&DoSearchOnLoad=0';
	
</cfscript>


<!--- label D26730  by Dinesh --->
<cfif filter_dr EQ 1>
	<cfscript>
	UrlString = UrlString & '&test_dr=0';
	</cfscript> 
</cfif>
<!--- label D26730  by Dinesh --->

<cfif LockedBy_Current_User EQ 1>
	<cfscript>
	UrlString = UrlString & '&showsearch=1';
	</cfscript> 
<cfelse>
	<cfscript>
	UrlString = UrlString & '&showsearch=0';
	</cfscript> 
</cfif>

    <script language="javascript" type="text/javascript">
    function positionfilter(s)
     {
        window.opener.templatefilter(s);
        window.close( );
     }
     </script>
<!--- I think we need to create a popup for this Or Mod it to pass all necessary Url vars through it. --->
<!---<cfinclude Template="/Search_Screens/Position_Search.cfm" />--->
<div id="dvPosFilter"></div>
<cfoutput>
	<Iframe src="/Search_Screens/Position_Search.cfm#UrlString#" id="positionSearchFrame" name="positionSearchFrame"  width="100%" height="80%" frameborder="0" ></Iframe>
</cfoutput>
