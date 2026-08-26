<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-- *************** DHTML Outline (begin) ***************** -->

<STYLE TYPE='text/css'>
<!--
/*Define elements with children with the class='outlineParentItem', and all elements without children with class='outlineItem'*/
li.oItem { color: #000000; cursor: text; list-style-image:url(/images/fill.gif);} ;
li.oParent { color: #0000FF; cursor: pointer; list-style-image:url(/images/plus3.gif); } ;
ul ul { display: none; } ;
// -->
</STYLE>

<SCRIPT LANGUAGE='Javascript'>
<!--
	// Returns the closest parent tag with tagName containing
	// the src tag. If no such tag is found - null is returned.
	function checkParent( src, tagName ) {
		while ( src != null ) {
			if (src.tagName == tagName) 
				return src;
			src = src.parentElement;
		}
		return null;
	}

	
	// Returns the first tag with tagName contained by
	// the src tag. If no such tag is found - null is returned.
	function checkContent( src, tagName ) {
		var pos = src.sourceIndex ;
		while ( src.contains( document.all[++pos] ) )
			if ( document.all[pos].tagName == tagName )
				return document.all[pos] ;
		return null ;
	}

      
	// Handle onClick event in the outline box
	function outlineAction() {     
		var src = event.srcElement ;
		var item = checkParent( src, "LI" ) ;

		if ( parent != null ) {
			var content = checkContent( item, "UL" ) ;

			if ( content != null )
				if ( content.style.display == "" ) {
					content.style.display = "block" ;
					content.parentElement.style.listStyleImage = 'url(/images/minus3.gif)';
				}
				else{
					content.style.display = "" ;
					content.parentElement.style.listStyleImage = 'url(/images/plus3.gif)';
				}
		}
		event.cancelBubble = true;
	}
    
// -->
function getAttributesWindow(title, debugObject) {
	/* lists all the attributes associated with debugObject in a separate window */
	msgWindow = window.open('','attributeWindow','');
	msgWindow.document.write('<' + 'SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">\n');
	msgWindow.document.write('function stopError() {return true}\n');
	msgWindow.document.write('window.onerror = stopError;\n');
	msgWindow.document.write('<' + '/SCRIPT>\n');
	msgWindow.document.write('&lt;' + title + '&gt;\n<OL>\n');
	for(var i in debugObject) {
		var valueString = debugObject[i];
		if(typeof(valueString) == 'object') {
			var strValueString = '"' + valueString + '"';
			msgWindow.document.write('\t<LI CLASS="OITEM">' + strValueString + ' <b>[' + i + ']</b><OL TYPE="a">\n');
			if(strValueString!='"null"') {
				// for(var j in debugObject) {
					// valueString2 = debugObject[j];
					// if(typeof(valueString2) == 'string') {
						// var ltRE = new RegExp(String.fromCharCode(60), "g");
						// if(valueString2.match(ltRE)) {valueString2 = valueString2.replace(ltRE, "&lt;");}
						// var gtRE = new RegExp(String.fromCharCode(62), "g");
						// if(valueString2.match(gtRE)) {valueString2 = valueString2.replace(gtRE, "&gt;");}
						// }
					// msgWindow.document.write('\t\t<LI CLASS="OITEM">"' + valueString2 + '" <b>' + i + '.' + j + '</b></LI>\n');
					// }
				}
			msgWindow.document.write('</OL></LI>\n');
			}
		else {
			if(typeof(valueString) == 'string') {
				var ltRE = new RegExp(String.fromCharCode(60), "g");
				if(valueString.match(ltRE)) {valueString = valueString.replace(ltRE, "&lt;");}
				var gtRE = new RegExp(String.fromCharCode(62), "g");
				if(valueString.match(gtRE)) {valueString = valueString.replace(gtRE, "&gt;");}
				}
			msgWindow.document.write('\t<LI CLASS="OITEM">"' + valueString + '" <b>' + i + '</b></LI>\n');
			}
		}
	msgWindow.document.write('</OL>\n');
	}
</SCRIPT>

<style>
	.outlineStyle {
		
		border: 1px solid Red; padding: 5px 5px 5px 5px; width: 305px; font-size: 12px; font-family: Arial, Helvetica, sans-serif;
	}
	

	
</style>

<DIV onClick="JavaScript: outlineAction();">
	<UL>
		<LI class='oParent'>Search Criteria
		<UL>
			<LI class='oItem'>
			<p class="outlineStyle">

					
					
					
					<style>
					body, table, td
						{
							font-family: Arial;
							font-size: 12px;
						}
					input,select, TEXTAREA
						{
							width:	175px;
							font-size: 10px;
						}
					TEXTAREA
						{
							width:	400px;
							font-size: 10px;
						}
					input.nostyle
						{
							width:	10px;
						}
					</style>
					
					
				
					
					
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- Get the list of Operator_Location_Type														 --->
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<cfset useLakebaseForGet_Operator_Location_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForGet_Operator_Location_Type>
	<cftry>
		<cfset Get_Operator_Location_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"deleted" = "eq.0",
				"select" = "operator_location_type"
			}), "operator_location_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operator_Location_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator_Location_Type>
<CFQUERY NAME="Get_Operator_Location_Type" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#" datasource="#application.datasource#">
					Select	distinct Operator_Location_Type
					From	BSA_Operator
					Where	deleted = 0
					</CFQUERY>
</cfif>
					
					
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- Get the list of Operator_Type																	 --->
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
         <!---------------------------------------------------------------------------- 
            Dev Notes: D19761 -Anand Rao 07/28/09
            Changed to query to have a where clause to look for active = 1 and 
            Deleted = 0 and pick the records from awayx_Operator_type table
         ------------------------------------------------------------------------------>          
					<cfset useLakebaseForGet_Operator_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("awayx_operator_type")>
<cfif useLakebaseForGet_Operator_Type>
	<cftry>
		<cfset Get_Operator_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("awayx_operator_type", {
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "operator_type"
			}), "operator_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operator_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator_Type>
<CFQUERY NAME="Get_Operator_Type" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#" datasource="#application.datasource#">
            SELECT	Distinct Operator_Type
            FROM awayX_Operator_Type
            WHERE Active = 1 AND Deleted = 0
					</CFQUERY>
</cfif>
					
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- Get the states																				 --->
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<CFQUERY NAME="Get_States" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#" datasource="#application.datasource#">
						Select s.*, c.Country_Sort_Order
						from _states s
						join _country c on s.Country_ID = c.Country_ID
						ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
					</CFQUERY>
					
					
					<FORM NAME="SearchForm">
					
					<TABLE>
					<TR>
						<TD>
							<B><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name:</B><BR>
							<INPUT TYPE="text" NAME="Operator_Name">
						</TD>
						<TD>
							<B>Doing business as:</B><BR>
							<INPUT TYPE="Text" NAME="Operator_DBA" MAXLENGTH="510">
						</TD>
						<TD>
							<B>City:</B><BR>
							<INPUT TYPE="Text" NAME="Operator_City" MAXLENGTH="510">
						</TD>
					</TR>
					<TR>
						<TD>
							<B>Type of <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>:</B><BR>
							<SELECT NAME="Operator_Type">
							<OPTION VALUE="All" SELECTED>Select <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Type</OPTION>
							<OPTION VALUE="All">All types</OPTION>
							<CFOUTPUT QUERY="Get_Operator_Type"><OPTION VALUE="#Operator_Type#">#Operator_Type#</OPTION></CFOUTPUT>
							</SELECT>
						</TD>
						<TD>
							<B>Location Type:</B><BR>
							<SELECT NAME="Operator_Location_Type">
							<OPTION VALUE="All" SELECTED>Select Location Types</OPTION>
							<OPTION VALUE="All">All Location Types</OPTION>
							<CFOUTPUT QUERY="Get_Operator_Location_Type"><OPTION VALUE="#Operator_Location_Type#">#Operator_Location_Type#</OPTION></CFOUTPUT>
							</SELECT>	
						</TD>
						<TD>
							<B>State:</B><BR>
							<SELECT NAME="Operator_State">
							<OPTION VALUE="All" SELECTED>Select State</OPTION>
							<OPTION VALUE="All">Any State</OPTION>
							<CFOUTPUT QUERY="Get_States"><OPTION VALUE="#State_Code#">#State_Name#</OPTION></CFOUTPUT>
							</SELECT>	
						</TD>
					</TR>
					<TR>
						<TD COLSPAN="3">
							<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="center" WIDTH="100%">
								<TR>
									<TD NOWRAP VALIGN="top" ALIGN="Left">
										<B>Records per page</B><BR>
										<SELECT NAME="maxrows">
											<OPTION VALUE="10">10</OPTION>
											<OPTION VALUE="25" SELECTED>25</OPTION>
											<OPTION VALUE="50">50</OPTION>
											<OPTION VALUE="100">100</OPTION>
										</SELECT>	
									</TD>
									<TD VALIGN="top" ALIGN="Left" NOWRAP>
										<B>Sort records by</B><BR>
										<SELECT NAME="sortby">
											<OPTION VALUE="Operator_Name"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name</OPTION>
											<OPTION VALUE="Operator_City">City</OPTION>
											<OPTION VALUE="Operator_State">State</OPTION>
											<OPTION VALUE="Operator_Number_Of_Locations">Number of locations</OPTION>
										</SELECT>	
									</TD>
									<TD VALIGN="top" ALIGN="left">
										<B>Order Selection</B><BR>
										<SELECT NAME="sortorder">
											<OPTION VALUE="asc">Ascending</OPTION>
											<OPTION VALUE="desc">Descending</OPTION>
										</SELECT>	
									</TD>
								</TR>
							</TABLE>
						</TD>
					</TR>
					</TABLE>
					</FORM>
				</p>
			</LI>
		</UL>
	</LI>

		<LI class='oParent'>Search Results
		<UL>
			<LI class='oItem'>FORM2</LI>
		</UL>
	</LI>

		<LI class='oParent'>Selected Search Items
		<UL>		<LI class='oItem'>FORM3</LI>
		</UL>
	</LI>
	</UL>
</DIV>
<DIV></DIV>

<!-- *************** DHTML Outline (end) ***************** -->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



