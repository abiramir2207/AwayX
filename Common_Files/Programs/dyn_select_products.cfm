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
			<LI class='oItem'><p class="outlineStyle">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type groups																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetTypeGroupDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Type_Group_Desc
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get QBrands																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetQBrands" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Q_brand_desc
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type codes																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetTypeCodeDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Type_Code_Desc
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get brands																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetBrands" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Brand
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>




<FORM NAME="SearchForm">


		<TABLE BORDER="1" CELLPADDING="0" CELLSPACING="0">
			<TR>
				<TD COLSPAN="100%" COLSPAN="2">
					<B>Search String:</B><BR>
					<INPUT TYPE="Text" NAME="searchstring" STYLE="width: 485px;">
					<BR>
				</TD>
			</TR>
			<TR>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL I</B><BR>
					<SELECT NAME="Type_Group_Desc">
						<OPTION VALUE="All">**ALL** Type Group Descriptions</OPTION>
						<CFOUTPUT QUERY="GetTypeGroupDesc"><OPTION VALUE="#Type_Group_Desc#">#Type_Group_Desc#</OPTION></CFOUTPUT>
					</SELECT>
					<BR><BR>
				</TD>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL II</B><BR>
					<SELECT NAME="Q_Brand_Desc">
						<OPTION VALUE="All">**ALL** Q Brand Descriptions</OPTION>
						<CFOUTPUT QUERY="GetQBrands"><OPTION VALUE="#Q_Brand_Desc#">#Q_Brand_Desc#</OPTION></CFOUTPUT>
					</SELECT>
					<BR><BR>
				</TD>
	
				<TD NOWRAP ALIGN="left">
					<B>LEVEL III</B><BR>
					<SELECT NAME="Type_Code_Desc">
						<OPTION VALUE="All">**ALL** Type Code Descriptions</OPTION>
						<CFOUTPUT QUERY="GetTypeCodeDesc"><OPTION VALUE="#Type_Code_Desc#">#Type_Code_Desc#</OPTION></CFOUTPUT>
					</SELECT>
					<BR><BR>
				</TD>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL IV</B><BR>
					<SELECT NAME="Brand">
						<OPTION VALUE="All">**ALL** Brands</OPTION>
						<CFOUTPUT QUERY="GetBrands"><OPTION VALUE="#Brand#">#Brand#</OPTION></CFOUTPUT>
					</SELECT>
					<BR><BR>
				</TD>

				<TD COLSPAN="2">
					<BR>
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="center" WIDTH="100%">
						<TR>
							<TD NOWRAP VALIGN="top" ALIGN="left">
								<B>Records per page</B><BR>
								<SELECT NAME="maxrows" STYLE="width:160px;">
									<OPTION VALUE="10">10</OPTION>
									<OPTION VALUE="25" SELECTED>25</OPTION>
									<OPTION VALUE="50">50</OPTION>
									<OPTION VALUE="100">100</OPTION>
								</SELECT>	
							</TD>
							<TD VALIGN="top" ALIGN="left" NOWRAP>
								<B>Sort records by</B><BR>
								<SELECT NAME="sortby" STYLE="width:160px;">
									<OPTION VALUE="Description">Product Description</OPTION>
									<OPTION VALUE="Type_Group_Desc">Type Group</OPTION>
									<OPTION VALUE="Q_Brand_Desc">Q Brand</OPTION>
									<OPTION VALUE="Type_Code_Desc">Type Code</OPTION>
									<OPTION VALUE="Brand">Brand</OPTION>
								</SELECT>	
							</TD>
							<TD VALIGN="top" ALIGN="left">
								<B>Order Selection</B><BR>
								<SELECT NAME="sortorder" STYLE="width:160px;">
									<OPTION VALUE="asc">Ascending</OPTION>
									<OPTION VALUE="desc">Descending</OPTION>
								</SELECT>	
							</TD>
						</TR>
					</TABLE>
					<BR>
					&nbsp;&nbsp;
					<CF_button
						button_name		=	""
						button_caption	=	"search"
						button_action	=	"javascript: opener.transportFormElementsFromPopupToParentPage();"
						button_type		=	"link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
					<!--- <INPUT TYPE="button" VALUE="Search..." STYLE="width:100px;" ONCLICK="opener.transportFormElementsFromPopupToParentPage()">				</TD> --->
			</TR>
			
			
		</TABLE>
</FORM>
			</p></LI>
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
