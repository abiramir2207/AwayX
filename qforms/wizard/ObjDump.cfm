<CFSETTING ENABLECFOUTPUTONLY="YES">
<!-----------------------------------------------------------------------------
 CF_ObjDump will display the entire contents of any valid ColdFusion variable.
 
 This version has been re-written from scratch, but is based upon the concept
 of a tag called CF_ObjectDump created by:
		Nathan Dintenfass & Ben Archibald	
		Creative Internet Solutions
		nathan@creativeis.com & ben@creativeis.com
		Date: 1/24/1999
		
	This version was re-written by:
		Dan G. Switzer, II
		PengoWorks.com
		dswitzer@pengoworks.com
		Date: 1/12/2000
------------------------------------------------------------------------------>
<!---// set default attributes //--->
<CFPARAM NAME="Attributes_OBJECT" DEFAULT="">
<CFPARAM NAME="Attributes_InstanceNumber" DEFAULT="0">

<!---// initialize the object locally //--->
<CFTRY>
	<!---// define default label //--->
	<CFPARAM NAME="Attributes_LABEL" DEFAULT="#Attributes_OBJECT#">
	<!---// get the value of the object //--->
	<CFSET objTemp = Evaluate("Caller.#Attributes_Object#")>
	<!---// if there are any errors evaluating the object, display error message //--->
	<CFCATCH TYPE="Any">
		<CFSETTING ENABLECFOUTPUTONLY="NO">
		<P><B>Error!</B><BR>The object <CFOUTPUT>#Attributes_LABEL#</CFOUTPUT> is not a valid object. 
		Make sure you specify a valid ColdFusion object type (structure, query, array, variable, etc.)
		Also, make sure you are not evaluating the contents of the object, but are
		providing CF_ObjDump with the name of your object. (i.e. use "SESSION", not "#SESSION#".)</P>
		<CFEXIT METHOD="EXITTAG">
	</CFCATCH>
</CFTRY>

<!---// determine whether this call is a recursive call or not //--->
<CFSET isRecursiveCall = ListContains(ListRest(GetBaseTagList()),"CF_OBJDUMP")>

<!---// if this is a recursive call, then grab the original attributes //--->
<CFIF isRecursiveCall>
	<CFSET Attributes = Caller.Attributes>
	<CFSET Attributes_LABEL = Caller.cfObjDump.Label>
	<CFSET cfObjDump.Executions = Caller.cfObjDump.Executions>

<!---// if this is the initial call to the tag, then set defaults //--->
<CFELSE>
	<!---// deserialize the WDDX packet by default //--->
	<CFPARAM NAME="Attributes_DESERIALIZE" DEFAULT="YES">
	<!---// total times this tag can be called //--->
	<CFPARAM NAME="Attributes_AllowedInstances" DEFAULT="5000">
	<!---// decide whether the tree should be expanded by default //--->
	<CFPARAM NAME="Attributes_EXPANDED" DEFAULT="0">
	<!---// decide whether to use the DHTML //--->
	<CFPARAM NAME="Attributes_DHTML" DEFAULT="1">
	<!---// decide whether to show the legend //--->
	<CFPARAM NAME="Attributes_LEGEND" DEFAULT="1">
	<!---// decide whether to sort "keys" alphabetically //--->
	<CFPARAM NAME="Attributes_SORT" DEFAULT="0">

	<!---// init general display properties //--->
	<CFPARAM NAME="Attributes_FONT" DEFAULT="Verdana, Arial, Helvetica, Sans-Serif">
	<CFPARAM NAME="Attributes_FONTSIZE" DEFAULT="1">
	<CFPARAM NAME="Attributes_CELLPADDING" DEFAULT="0">
	<CFPARAM NAME="Attributes_CELLSPACING" DEFAULT="0">
	<CFPARAM NAME="Attributes_BORDER" DEFAULT="1">	

	<!---// init color scheme //--->
	<CFPARAM NAME="Attributes_COLOR_QUERY" DEFAULT="666699">
	<CFPARAM NAME="Attributes_COLOR_ROW" DEFAULT="9999CC">
	<CFPARAM NAME="Attributes_COLOR_STRUCTURE" DEFAULT="003366">
	<CFPARAM NAME="Attributes_COLOR_ARRAY" DEFAULT="99CCCC">
	<CFPARAM NAME="Attributes_COLOR_NUMERIC" DEFAULT="CC3333">
	<CFPARAM NAME="Attributes_COLOR_DATE" DEFAULT="CCCCCC">
	<CFPARAM NAME="Attributes_COLOR_STRING" DEFAULT="0000CC">
	
	<CFIF NOT IsDefined("Caller.cfObjDump.Executions")>
		<CFSET Caller.cfObjDump.Executions = 1>
	<CFELSE>
		<CFSET Caller.cfObjDump.Executions = Caller.cfObjDump.Executions + 1>
	</CFIF>
	
	<CFSET cfObjDump.Executions = Caller.cfObjDump.Executions>
</CFIF>

<!---// add this current instance to the counter //--->
<CFSET Attributes_InstanceNumber = Attributes_InstanceNumber + 1>

<CFSET dhtmlID = "cfObjDump_" & cfObjDump.Executions & "_" & Attributes_InstanceNumber>

<!---// if the total number of instances has been reached, break out of the template //--->
<CFIF Attributes_InstanceNumber GT Attributes_AllowedInstances>
	<CFSETTING ENABLECFOUTPUTONLY="NO">
	<P>Sorry, the maximum threshold of <CFOUTPUT>#Attributes_AllowedInstances#</CFOUTPUT> instances was 
	has been reached. CF_ObjDump limits the total number of instances that the tag can be called in 
	iteration to prevent the server from crashing. To change the default number of instances allowed, 
	use the "AllowedInstances" parameter when calling CF_ObjDump.</P>
	<CFABORT>
</CFIF>

<!---// check to see if the packet is a WDDX packet //--->
<CFTRY>
	<!---// assume it is a WDDX packet //--->
	<CFSET IsWDDX = 1>
	<CFWDDX ACTION="WDDX2CFML" INPUT="#objTemp#" OUTPUT="wddxPacket">
	<CFCATCH TYPE="Any">
		<!---// if the conversion from WDDX to CFML fails for any reason, then it's not a WDDX packet //--->
		<CFSET IsWDDX = 0>
	</CFCATCH>
</CFTRY>

<!---// check to see if the current object is a WDDX packet //--->
<CFIF IsWDDX>
	<!---// if the packet is to be deserialized, then replace the current object with the packet //--->
	<CFIF Attributes_DESERIALIZE>
		<CFSET objTemp = wddxPacket>
	<!---// otherwise, replace the packet with the string value of the packet //--->
	<CFELSE>
		<CFSET objTemp = HTMLCodeFormat(objTemp)>
	</CFIF>
</CFIF>

<!---// set default variables //--->
<CFSCRIPT>
// CF_ObjDump configuration info
cfObjDump.Version = "1.0";
cfObjDump.Registered = "YES";

Title = "";
ObjCount = 1;

if( IsQuery(objTemp) ){
	Type = "Query";
	ObjCount = objTemp.RecordCount;
	Title = "This query contains " & ObjCount & " records.";
} else if( IsStruct(objTemp) ){
	Type = "Structure";
	ObjCount = StructCount(objTemp);
	Title = "This structure contains " & ObjCount & " keys.";
} else if( IsArray(objTemp) ){
	Type = "Array";
	ObjCount = ArrayLen(objTemp);
	Title = "This array contains " & ObjCount & " elements.";
} else if( IsSimpleValue(objTemp) ){
	if( IsNumeric(objTemp) ){
		Type = "Numeric";
	} else if( IsDate(objTemp) ){
		Type = "Date";
	} else {
		Type = "String";
	}
}

// set the color for the current object type
color = Evaluate("Attributes_COLOR_" & Type);

// if the value isn't a simple value, then wrap it in a layer
if( NOT IsSimpleValue(objTemp) ){
	Attributes_LABEL = "<NOBR CLASS=""ezTree"" onClick=""ec('#dhtmlID#');"" onMouseOver=""hilite();"" onMouseOut=""restore();"" TITLE=""#Title#"">" & Attributes_LABEL & "</NOBR>";
}

// if it was a WDDX packet, then note it as such (needs to be AFTER setting the Attributes_LABEL)
if( IsWDDX ) Attributes_LABEL = "<U>" & Attributes_LABEL & "</U>";
</CFSCRIPT>

<CFIF NOT isRecursiveCall>
	<CFSETTING ENABLECFOUTPUTONLY="NO">
	<P><TABLE WIDTH="80%" BORDER="1" CELLSPACING="0" CELLPADDING="10" ALIGN="CENTER"><TR><TD>
	<CFIF YesNoFormat(Attributes_DHTML)>
		<A HREF="" 
			onClick="expandCollapseAll('c',<CFOUTPUT>#cfObjDump.Executions#</CFOUTPUT>);return false;" 
			TITLE="Collapse All"
			STYLE="text-decoration: none; color: #000000; font-family: Wingdings; font-weight: 200; font-size: 22px;">&#199;</A>
		&nbsp;
		<A HREF="" 
			onClick="expandCollapseAll('e',<CFOUTPUT>#cfObjDump.Executions#</CFOUTPUT>);return false;" 
			TITLE="Expand All"
			STYLE="text-decoration: none; color: #000000; font-family: Wingdings; font-weight: 200; font-size: 22px;">&#202;</A>
	</CFIF>

	<SPAN STYLE="text-decoration: none; color: #000000; font-family: <CFOUTPUT>#Attributes_FONT#</CFOUTPUT>; font-weight: 200; font-size: 22px;">
	&nbsp; CF_ObjDump (<CFOUTPUT>#cfObjDump.Executions#</CFOUTPUT>)</SPAN>
	<A HREF="mailto:dswitzer@pengoworks.com" STYLE="text-decoration: none; color: #000000; font-family: <CFOUTPUT>#Attributes_FONT#</CFOUTPUT>; font-weight: 200; font-size: 12px;">
	by Dan G. Switzer, II</A>
	
	<CFIF cfObjDump.Executions EQ 1>
		<CFHTMLHEAD TEXT="<STYLE>.ezTree {cursor: pointer; }</STYLE>">
	
		<SCRIPT LANGUAGE="JavaScript">
		<!--//
		function hilite(aName){
			if( !document.all ) return true;
			var e = window.event.srcElement;
			e.style.color = "#ffffcc";
		}
	
		function restore(aName){
			if( !document.all ) return true;
			var e = window.event.srcElement;
			e.style.color = "#ffffff";
		}
		//-->
		</SCRIPT>
	
		<CFIF YesNoFormat(Attributes_DHTML)>
			<SCRIPT LANGUAGE="JavaScript">
			<!--//
			// append the initObjDump() function to the body's onLoad event
			if( window.onload != null ){
				window.onload = eval("window.onload();initObjDump"); 
			} else {
				window.onload = initObjDump; 
			}
	
			// create array for caching elements
			aryObjDumpIDs = new Array();
	
			function initObjDump(){
				if( !document.all ) return true;
				cacheElements();
			<CFIF NOT YesNoFormat(Attributes_EXPANDED)>
				expandCollapseAll();
			</CFIF>
			}
			
			// cache elements array
			function cacheElements(){
				// base key
				key = "cfObjDump_";
				iKeyLen = key.length;
				
				aryTemp = new Array();
				
				// collect all the valid ObjDump IDs
				for(i=0; i < document.all.length; i++){
					if( document.all[i].id.substring(0,iKeyLen) == key ){
						aryTemp[aryTemp.length] = document.all[i].id;
					}
				}
				
				var iOldInstance = 0;
				for( i=0; i < aryTemp.length; i++ ){
					// get current instance marker for CF_ObjDump
					iInstance =  aryTemp[i].split("_")[1];
					// for every new instance, create a new array
					if( iOldInstance != iInstance ){
						iOldInstance = iInstance;
						iArrayPOS = iOldInstance - 1;
						aryObjDumpIDs[iArrayPOS] = new Array();
					}
					// save the current ID into the correct instance array
					aryObjDumpIDs[iArrayPOS][aryObjDumpIDs[iArrayPOS].length] = aryTemp[i];
				}
				
			}
			
			function ec(id){
				boolCollapsed = (document.all[id].style.display == "none");
		
				if( boolCollapsed ){
					document.all[id].style.display = "";
				} else {
					document.all[id].style.display = "none";
				}
			}
		
			function expandCollapseAll(action,key){
				if( !document.all ) return true;
				// if no direction specified, the collapse view
				if( !action ) action = "c";
				// if no key string is specified, then use default key
				if( !key ){
					iStartPOS = 0;
					iEndPOS = aryObjDumpIDs.length;
				} else {
					iStartPOS = key - 1;
					iEndPOS = key;
				}
		
				// if expanding view, set value to blank value
				if( action == "e" ){
					value = "";
				// if collapsing view, set value to "none"
				} else {
					value = "none";
				}
		
				// loop through all the nessary arrays and perform the required action
				for(i=iStartPOS; i < iEndPOS; i++){
					for(j=0; j < aryObjDumpIDs[i].length; j++){
						document.all[aryObjDumpIDs[i][j]].style.display = value;
					}
				}
			}
			//-->
			</SCRIPT>
		<CFELSE>
			<SCRIPT LANGUAGE="JavaScript">
			<!--//
			function ec(){ return false;	}
			//-->
			</SCRIPT>
		</CFIF>
	</CFIF>
	<CFSETTING ENABLECFOUTPUTONLY="YES">
</CFIF>

<!---// [begin] start table for this object //--->
<CFOUTPUT>
<CFIF NOT IsDefined("Caller.cfObjDump.DrawTable") OR (Caller.cfObjDump.DrawTable EQ "YES")>
<TABLE BORDER="#Attributes_BORDER#" CELLPADDING="#Attributes_CELLPADDING#" CELLSPACING="#Attributes_CELLSPACING#">
</CFIF>
<TR>
	<TD BGCOLOR="###COLOR#" ALIGN="Left" VALIGN="Top">
		<FONT FACE="#Attributes_FONT#" SIZE="#Attributes_FONTSIZE#" COLOR="##ffffff"><B>&nbsp;#Attributes_LABEL#&nbsp;</B></FONT>
	</TD>
	<TD ALIGN="Left" VALIGN="Top" <CFIF NOT IsSimpleValue(objTemp)>ID="#dhtmlID#"</CFIF>>
		
</CFOUTPUT>
<!---// [ end ] start table for this object //--->

<!---// if the number of child objects is zero, then replace object with title
        this line has to be right before the line spits out simple values //--->
<CFIF ObjCount EQ 0>
	<CFSET objTemp = Replace(Title, "0", "no")>
</CFIF>

<!---// if it's a simple value, output the value //--->
<CFIF IsSimpleValue(objTemp)>
	<!---// escape the string so all HTML is displayed to the screen //--->
	<CFSET objTemp = HTMLEditFormat(objTemp)>
	<!---// output the simple value //--->
	<CFOUTPUT><FONT FACE="#Attributes_FONT#" SIZE="#Attributes_FONTSIZE#">&nbsp;#objTemp#&nbsp;</FONT></CFOUTPUT>	

<!---// since it's not a simple value, calculate what to do next //--->
<CFELSE>


	<CFSWITCH EXPRESSION="#Type#">

		<!---// if a query, dump it to the screen //--->
		<CFCASE VALUE="Query">

			<!---// check to see if you should sort the keys //--->
			<CFIF NOT YesNoFormat(Attributes_SORT)>
				<!---// dump keys exactly how they appear in the structure //--->
				<CFSET lstColumns = objTemp.ColumnList>
			<CFELSE>
				<!---// grab all the keys, dump them to an array and then sort the array //--->
				<CFSET lstColumns = ListSort(objTemp.ColumnList, "text", "ASC")>
			</CFIF>

			<CFOUTPUT><TABLE BORDER="#Attributes_BORDER#" CELLSPACING="#Attributes_CELLSPACING#" CELLPADDING="#Attributes_CELLPADDING#"></CFOUTPUT>
			<CFLOOP QUERY="objTemp">
				<CFSET Title = "This row contains " & ListLen(lstColumns) & " columns.">
				<CFOUTPUT>
				<TR>
				<TD BGCOLOR="###Attributes_COLOR_ROW#" ALIGN="Left" VALIGN="Top">
					<FONT FACE="#Attributes_FONT#" SIZE="#Attributes_FONTSIZE#" COLOR="##ffffff"><B><NOBR CLASS="ezTree" onClick="ec('#dhtmlID#_ROW_#CurrentRow#');" onMouseOver="hilite();" onMouseOut="restore();" TITLE="#Title#">Row #objTemp.CurrentRow#</NOBR></B></FONT>
				</TD>
				<TD ALIGN="Left" VALIGN="Top" ID="#dhtmlID#_ROW_#CurrentRow#">
				</CFOUTPUT>
			
				<CFOUTPUT><TABLE BORDER="#Attributes_BORDER#" CELLSPACING="#Attributes_CELLSPACING#" CELLPADDING="#Attributes_CELLPADDING#"></CFOUTPUT>

				<CFLOOP INDEX="column" LIST="#lstColumns#">
					<CFSET cfObjDump.Label = Column>
					<CFSET cfObjDump.DrawTable = "NO">
					<CF_ObjDump OBJECT="objTemp['#Column#']['#CurrentRow#']">	
				</CFLOOP>

				<CFOUTPUT></TABLE></CFOUTPUT>

				<CFOUTPUT>
					</TD>
				</TR>
				</CFOUTPUT>
			</CFLOOP>
			<CFOUTPUT></TABLE></CFOUTPUT>

		</CFCASE>	

		<!---// if a structure, dump it to the screen //--->
		<CFCASE VALUE="Structure">

			<CFOUTPUT><TABLE BORDER="#Attributes_BORDER#" CELLSPACING="#Attributes_CELLSPACING#" CELLPADDING="#Attributes_CELLPADDING#"></CFOUTPUT>

			<!---// check to see if you should sort the keys //--->
			<CFIF NOT YesNoFormat(Attributes_SORT)>
				<!---// dump keys exactly how they appear in the structure //--->
				<CFLOOP COLLECTION="#objTemp#" ITEM="thisKey">
					<CFSET cfObjDump.Label = thisKey>
					<CFSET cfObjDump.DrawTable = "NO">
					<CF_ObjDump OBJECT="objTemp['#thisKey#']">
				</CFLOOP>
			<CFELSE>
				<!---// grab all the keys, dump them to a list and then sort the list //--->
				<CFSET lstStructKeys = ListSort(StructKeyList(objTemp), "text", "ASC")>
				<CFLOOP INDEX="thisKey" LIST="#lstStructKeys#">
					<CFSET cfObjDump.Label = thisKey>
					<CFSET cfObjDump.DrawTable = "NO">
					<CF_ObjDump OBJECT="objTemp['#thisKey#']">
				</CFLOOP>
			</CFIF>

			<CFOUTPUT></TABLE></CFOUTPUT>

		</CFCASE>	

		<!---// if an array, dump it to the screen //--->
		<CFCASE VALUE="Array">

			<CFOUTPUT><TABLE BORDER="#Attributes_BORDER#" CELLSPACING="#Attributes_CELLSPACING#" CELLPADDING="#Attributes_CELLPADDING#"></CFOUTPUT>

			<CFSET Label = Attributes_LABEL>
			<!---// strip out other SPAN tag //--->
			<CFSET Label = REReplace(Label, "<[^>]*>", "", "ALL")>
			<CFSET iArrayLen = ArrayLen(objTemp)>
			<CFLOOP INDEX="i" FROM="1" TO="#iArrayLen#">
				<CFSET cfObjDump.Label = Label & "[" & i & "]">
				<CFSET cfObjDump.DrawTable = "NO">
				<CF_ObjDump OBJECT="objTemp[#i#]">
			</CFLOOP>

			<CFOUTPUT></TABLE></CFOUTPUT>

		</CFCASE>

	</CFSWITCH>

</CFIF>	


<CFOUTPUT>
<!---// [begin] end table for this object //--->
	</TD>
</TR>
<CFIF NOT IsDefined("Caller.cfObjDump.DrawTable") OR (Caller.cfObjDump.DrawTable EQ "YES")>
</TABLE>
</CFIF>
<!---// [ end ] end table for this object //--->
</CFOUTPUT>

<CFIF NOT isRecursiveCall>
	<CFSETTING ENABLECFOUTPUTONLY="NO">
	<CFIF YesNoFormat(Attributes_LEGEND)>
		<CFSET lstColorSchemes = "QUERY,STRUCTURE,ARRAY,NUMERIC,DATE,STRING">
		<P><CFOUTPUT><TABLE WIDTH="100%" BORDER="#Attributes_BORDER#" CELLPADDING="#Attributes_CELLPADDING#" CELLSPACING="#Attributes_CELLSPACING#"></CFOUTPUT>
		<TR>
			<CFLOOP INDEX="color" LIST="#lstColorSchemes#">
			<TD ALIGN="Center" BGCOLOR="#<CFOUTPUT>#Evaluate('Attributes_COLOR_#color#')#</CFOUTPUT>">
				<FONT FACE="<CFOUTPUT>#Attributes_FONT#</CFOUTPUT>" SIZE="<CFOUTPUT>#Attributes_FONTSIZE#</CFOUTPUT>" COLOR="#ffffff"><B><nobr><CFOUTPUT>#color#</CFOUTPUT></nobr></B></FONT>
			</TD>
			</CFLOOP>
		</TR>
		</TABLE>
	</CFIF>
	<FONT FACE="<CFOUTPUT>#Attributes_FONT#</CFOUTPUT>" SIZE="<CFOUTPUT>#Attributes_FONTSIZE#</CFOUTPUT>"><B>
		&nbsp;&nbsp; * Underlined keys are WDDX packets
	</B></FONT>
	</TD></TR></TABLE></P>

	<CFSETTING ENABLECFOUTPUTONLY="YES">
</CFIF>

<CFSETTING ENABLECFOUTPUTONLY="NO">
