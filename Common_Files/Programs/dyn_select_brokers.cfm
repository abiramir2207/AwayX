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



