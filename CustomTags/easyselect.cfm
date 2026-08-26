<CFPARAM NAME="ATTRIBUTES.WHERECLAUSE" DEFAULT="">
<!--- if high allws for multiple selections from search windows, otherwise only one --->
<CFPARAM NAME="ATTRIBUTES.MULTISELECT" DEFAULT="">

<!--- Name of ODBC connection --->
<CFPARAM NAME="ATTRIBUTES.ODBCCONN" DEFAULT="">

<!--- List fo fields to populate the TITLE attribute of the CHECKBOX/RADIO BUTTON input.
this text is returned to the select box on the parent page

TABLENAME.FIELDNAME
--->
<CFPARAM NAME="ATTRIBUTES.DISPLAYFIELDS" DEFAULT="">

<!--- The common field among all the table being searched
TABLENAME.FIELDNAME
--->
<CFPARAM NAME="ATTRIBUTES.COMMONDBFIELD" DEFAULT="">

<!--- List of tabls.fields to be searched
TABLENAME.FIELDNAME.Heading Caption Text,TABLENAME.FIELDNAME.Heading Caption Text
 --->
<CFPARAM NAME="ATTRIBUTES.DATABASEFIELDSTOSEARCH" DEFAULT="">

<!--- Name Of a javascript function to call on the parent page when the finished button is pushed --->
<CFPARAM NAME="ATTRIBUTES.FUNCTIONTOCALL" DEFAULT="">

<!--- list of data to add to the input box tag not searched by the query
TABLENAME.FIELDNAME,TABLENAME.FIELDNAME
--->
<CFPARAM NAME="ATTRIBUTES.EXTRADATAFIELDS" DEFAULT="">

<!--- if set low the selcect box on the parent page is not displayed --->
<CFPARAM NAME="ATTRIBUTES.DISPLAYONPARENTPAGE" DEFAULT="YES">
<!--- name of the display on the parent page --->
<CFPARAM NAME="ATTRIBUTES.PARENTPAGEDATADISPLAYNAME" DEFAULT="displaybox">

<CFPARAM NAME="ATTRIBUTES.PARENTPAGEDATADISPLAY_WIDTH" DEFAULT="200">



<CFPARAM NAME="ATTRIBUTES.COLUMNHEADING_STYLE" DEFAULT="">


<CFPARAM NAME="ATTRIBUTES.PARENTPAGEBUTTON_CAPTION" DEFAULT="XXXXXXXX">

<!--- Self width and height of the pop up window --->
<CFPARAM NAME="ATTRIBUTES.POPUP_WIDTH" DEFAULT="500">
<CFPARAM NAME="ATTRIBUTES.POPUP_HEIGHT" DEFAULT="400">

<!--- Looks Oriented Param --->
<CFPARAM NAME="ATTRIBUTES.RESULTTABLE_TABLE_STYLE" DEFAULT="">
<CFPARAM NAME="ATTRIBUTES.RESULTTABLE_ROW_STYLE" DEFAULT="">

<CFPARAM NAME="ATTRIBUTES.ROWCOLOR1" DEFAULT="white">
<CFPARAM NAME="ATTRIBUTES.ROWCOLOR2" DEFAULT="gray">

<CFPARAM NAME="ATTRIBUTES.highlightsearchstring" DEFAULT="yes">
<CFPARAM NAME="ATTRIBUTES.highlight_style" default="color: black;">

<!--- TagUsage --->
<CFPARAM NAME="ATTRIBUTES.MODE" DEFAULT="START">



<CFSWITCH EXPRESSION="#ATTRIBUTES.MODE#">
	<CFCASE VALUE="START">
		<CFSCRIPT>
			requiredfiles = "frameset.cfm,controls.cfm,searchresults.cfm";
			filestocreate = "";

			tagcallerpath = GetDirectoryFromPath(GetTemplatePath());

			for(loop=1; loop LTE listlen(requiredfiles); loop=loop+1)
			{
				currentfile = listgetat(requiredfiles, loop);
				if(FileExists(tagcallerpath & '\' & currentfile) EQ "NO")
					filestocreate = listappend(filestocreate, currentfile);
			}
		</CFSCRIPT>
		<CFIF listlen(filestocreate) GT 0>
			<CFLOOP INDEX="filename" LIST="#filestocreate#">
				<CFSET filepath = tagcallerpath & "/" & filename>
				<CFSET filecontent = "<CF_EASYSELECT MODE=" & listgetat(filename,1,".") & ">">
				<CFFILE ACTION="WRITE" FILE="#filepath#" OUTPUT="#filecontent#" ADDNEWLINE="Yes">

			</CFLOOP>
		</CFIF>

		<SCRIPT LANGUAGE="JavaScript">
			<CFINCLUDE TEMPLATE="../../Inetpub/wwwroot/AwayX/functions.js">

			function <cfoutput>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</cfoutput>_customObject(value,title<cfloop index="ListItem" list="#ATTRIBUTES.EXTRADATAFIELDS#" delimiters=",">,<cfoutput>#Listgetat(ListItem,2,".")#</cfoutput></CFLOOP>){
				this.value = value;
				this.title = title;
				<cfloop index="ListItem" list="#ATTRIBUTES.EXTRADATAFIELDS#" delimiters=",">
					this.<cfoutput>#Listgetat(ListItem,2,".")# = #Listgetat(ListItem,2,".")#</cfoutput>;
				</CFLOOP>
			}


			function <cfoutput>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</cfoutput>_gateway(itemObject, ObjectArray_Name){

				IsThisItemInTheArray = SearchArrayForExistingValue(ObjectArray_Name, itemObject.value);

				if(itemObject.type == "checkbox"){
					if(IsThisItemInTheArray == -1 && itemObject.checked){

						eval(ObjectArray_Name + '[' + eval(ObjectArray_Name + '.length') + '] = new <cfoutput>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</cfoutput>_customObject(itemObject.value,itemObject.title<cfloop index="ListItem" list="#ATTRIBUTES.EXTRADATAFIELDS#" delimiters=",">,<cfoutput>itemObject.CUSTOM_#Listgetat(ListItem,2,".")#</cfoutput></CFLOOP>)')

						//getAttributesWindow('',eval(ObjectArray_Name + '[' + eval(ObjectArray_Name + '.length' + -1) + ']'))

						//eval(ObjectArray_Name + '[' + eval(ObjectArray_Name + '.length' + -1) + '] = itemObject')

					}

					if(IsThisItemInTheArray != -1 && !itemObject.checked){
						ArrayRemoveItemAtPosition(ObjectArray_Name, IsThisItemInTheArray)
					}
				}
				else{
					document.all.<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>.value = itemObject.title
					document.all.<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#_ValueList</CFOUTPUT>.value = itemObject.value

				}
			}
			inputtype_<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT> = "<CFIF ATTRIBUTES.MULTISELECT EQ "YES">checkbox<CFELSE>radio</CFIF>";

			function <CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>_finished(){
				<CFIF ATTRIBUTES.DISPLAYONPARENTPAGE EQ "YES">
					<CFIF ATTRIBUTES.MULTISELECT EQ "YES">
					ClearSelectBox("<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>")
					for(var x=0; x<<cfoutput>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</cfoutput>_array.length;x++){
						addOption("<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>",eval('<cfoutput>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</cfoutput>_array[' + x + '].value'), eval('<cfoutput>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</cfoutput>_array[' + x + '].title'))
					}
					document.all.<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>_ValueList.value = ObjectArrayToList(<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>_array)
					</CFIF>
					<CFIF len(ATTRIBUTES.FUNCTIONTOCALL) GT 0>
						<cfoutput>#ATTRIBUTES.FUNCTIONTOCALL#</cfoutput>
					</CFIF>

				</CFIF>

			}


			function maintaineSelectionCrossScreens(ObjectArray_Name, Record_IDs_List){


					for(var n=0; n<eval(ObjectArray_Name + '.length');n++){
						for(var x=0; x<Record_IDs_List.length;x++){
							if(eval(ObjectArray_Name + '[' + n + '].value') == Record_IDs_List[x].value)
								eval(Record_IDs_List[x].checked = true)
						}
						//if(eval(ObjectArray_Name + '[' + eval(ObjectArray_Name + '.length') + (-1) + '].value') == e.Record_IDs[n].value){
						//	eval('e.Record_IDs[n].checked = true')
						//}
					}
			}

			function NewWindow(mypage, myname, w, h, scroll)
				{

				var winl = (screen.width - w) / 2;
				var wint = (screen.height - h) / 2;
				winprops = 'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable'
				win = window.open(mypage, myname.replace(/\s/g, ''), winprops)
				if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
				}
			//  End -->


		</script>


		<CFSCRIPT>
			URLLIST = "";
			StructList = StructKeyList(ATTRIBUTES);

			for(loop=1; loop LTE listlen(StructList); loop=loop+1)
				{
					keyname = listgetat(StructList,loop);
					URLLIST = listappend(URLLIST,"#keyname#=#evaluate("attributes.#keyname#")#", "&");
				}
		</CFSCRIPT>
		<INPUT TYPE="button" VALUE="<CFOUTPUT>#ATTRIBUTES.PARENTPAGEBUTTON_CAPTION#</CFOUTPUT>" STYLE="width: 150" ONCLICK="NewWindow('frameset.cfm?<CFOUTPUT>#URLLIST#</CFOUTPUT>', 'SearchWindow', <cfoutput>#ATTRIBUTES.POPUP_WIDTH#</cfoutput>, <cfoutput>#ATTRIBUTES.POPUP_HEIGHT#</cfoutput>, 0)">
		<br>
		<CFIF ATTRIBUTES.DISPLAYONPARENTPAGE EQ "YES">
			<CFIF ATTRIBUTES.MULTISELECT EQ "YES">
				<SELECT NAME="<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>" value="<CFOUTPUT>#ATTRIBUTES.COMMONDBFIELD#</CFOUTPUT>" ID="<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>" SIZE="5" STYLE="width: <CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAY_WIDTH#</CFOUTPUT>" onClick="getSelectedListItem(this, 'contracts');"></SELECT><BR>
			<CFELSE>
				<input type="text" name="<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>"><BR>
			</CFIF>
		</CFIF>


			<input type="hidden" name="<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>_ValueList" id="<CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>_ValueList">
			<SCRIPT LANGUAGE="JavaScript">
				var <CFOUTPUT>#ATTRIBUTES.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>_array = new Array();
			</SCRIPT>
	</CFCASE>

	<CFCASE VALUE="frameset">
		<CFSET DatatypeList = "">
		<CFLOOP INDEX="Listitem" LIST="#URL.DATABASEFIELDSTOSEARCH#" DELIMITERS=",">
			<CFQUERY NAME="GetDataType" DATASOURCE="#URL.ODBCCONN#">
				SELECT dbo.systypes.name AS datatype,
				    dbo.syscolumns.name AS fieldname,
				    dbo.sysobjects.name AS tablename
				FROM dbo.systypes INNER JOIN
				    dbo.syscolumns ON
				    dbo.systypes.xtype = dbo.syscolumns.xtype INNER JOIN
				    dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id
				WHERE
					dbo.syscolumns.name = '#listgetat(Listitem, 2, ".")#'
					AND
					dbo.sysobjects.name = '#listgetat(Listitem, 1, ".")#'
				</CFQUERY>
				<CFSET DatatypeList = ListAppend(DatatypeList, Listitem, ",")>
				<CFSET DatatypeList = ListAppend(DatatypeList, GetDataType.datatype, ",")>
		</CFLOOP>

		<!-- frames -->
		<CFSET urlstring = CGI.QUERY_STRING & "&datatypelist=" & DatatypeList>
		<CFOUTPUT>
			<FRAMESET  ROWS="35,*">
			    <FRAME NAME="controls" SRC="controls.cfm?#urlstring#" MARGINWIDTH="0" MARGINHEIGHT="0" SCROLLING="no" FRAMEBORDER="0">
			    <FRAME NAME="searchresults" SRC="searchresults.cfm?#urlstring#" MARGINWIDTH="0" MARGINHEIGHT="0" SCROLLING="no" FRAMEBORDER="0">
			</FRAMESET>
		</CFOUTPUT>
	</CFCASE>

	<CFCASE VALUE="controls">
		<BODY ONLOAD="document.all.searchstring.focus()">
		<CFSET URLSTRING = CGI.QUERY_STRING>
		<CFIF ISDEFINED("FORM.SEARCHSTRING")>
			<CFSET URLSTRING = URLSTRING & "&SEARCHSTRING=" & FORM.SEARCHSTRING>
		</CFIF>

		<FORM ACTION="searchresults.cfm?<CFOUTPUT>#URLSTRING#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm" TARGET="searchresults">
			<TABLE ALIGN="center">
				<TR>
					<TD><INPUT TYPE="text" NAME="searchstring" ID="searchstring"></TD>
					<TD><INPUT TYPE="submit" VALUE="search" ONCLICK=""></TD>
				</TR>
			</TABLE>
			<HR COLOR="Black">
		</FORM>
		</BODY>
	</CFCASE>

	<CFCASE VALUE="searchresults">
	<CFPARAM  NAME="FORM.SEARCHSTRING" DEFAULT="">

	<CFSCRIPT>
		if(isdefined("URL.SEARCHSTRING"))
			FORM.SEARCHSTRING = URL.SEARCHSTRING;
		SELECTText = "";
		tablelist = "";
		wheretext = "(";
		temp = "";
		temp2 = "";
		commonfield = listgetat(URL.COMMONDBFIELD, 2, ".");

			//build select list
			for(subloop=1; subloop LTE listlen(URL.DATABASEFIELDSTOSEARCH, ","); subloop=subloop+1)
				{
					currentDATABASEFIELDSTOSEARCHelement = listgetat(URL.DATABASEFIELDSTOSEARCH, subloop, ",");
					tablefield = listgetat(currentDATABASEFIELDSTOSEARCHelement,1,".") & "." & listgetat(currentDATABASEFIELDSTOSEARCHelement,2,".");
					SELECTText = listappend(SELECTText, tablefield, ",");
				}
			if(len(URL.EXTRADATAFIELDS) GT 0)
				{
					//Append non searched fields to the list
					for(subloop=1; subloop LTE listlen(URL.EXTRADATAFIELDS, ","); subloop=subloop+1)
						{
							currentDATABASEFIELDSTOSEARCHelement = listgetat(URL.EXTRADATAFIELDS, subloop, ",");
							tablefield = listgetat(currentDATABASEFIELDSTOSEARCHelement,1,".") & "." & listgetat(currentDATABASEFIELDSTOSEARCHelement,2,".");
							SELECTText = listappend(SELECTText, tablefield, ",");
						}
				}
			// build non repeating list of tables
			for(subloop=1; subloop LTE listlen(SELECTText); subloop=subloop+1)
				{
					temp = listgetat(listgetat(SELECTText, subloop, ","), 1, ".");
						if(listcontains(tablelist,temp) EQ 0)
							tablelist = listappend(tablelist, temp, ",");
					temp = listgetat(SELECTText, subloop, ",");
				}



			for(subloop=2; subloop LTE listlen(URL.datatypelist, ","); subloop=subloop+2)
				{
					temp1 = listgetat(URL.datatypelist, subloop);

					temp2 = listgetat(URL.datatypelist, subloop-1);
					temp2 = listgetat(temp2, 1, ".") & "." & listgetat(temp2, 2, ".");

					if(isnumeric(FORM.SEARCHSTRING))
						{
							if(temp1 EQ "int")temp = temp2;
						}
					else
						{
							if(temp1 NEQ "int")temp = temp2;
						}
							wheretext = wheretext & "#temp# = '#FORM.SEARCHSTRING#' OR #temp# LIKE '%#FORM.SEARCHSTRING#' OR #temp# LIKE '%#FORM.SEARCHSTRING#%' OR #temp# LIKE '#FORM.SEARCHSTRING#%' ";
							wheretext = wheretext & "OR ";

				}
			wheretext = wheretext & "0=1)";


			if(listfind(tablelist, listgetat(URL.COMMONDBFIELD, 1, ".")) EQ 0)
				tablelist = listappend(tablelist, listgetat(URL.COMMONDBFIELD, 1, "."), ",");

			for(subloop=1; subloop LTE listlen(tablelist); subloop=subloop+1)
				{
					if(trim(listgetat(URL.COMMONDBFIELD, 1, ".")) NEQ trim(listgetat(tablelist, subloop, ",")))
						wheretext = wheretext & " AND " & URL.COMMONDBFIELD & " = " & trim(listgetat(tablelist, subloop, ",")) & "." & commonfield;

				}

			if(len(FORM.SEARCHSTRING) EQ 0){
					wheretext = "0 = 0 ";
			}

			if(isdefined("URL.WHERECLAUSE")){
				if(len(URL.WHERECLAUSE) NEQ 0){
					wheretext = wheretext & URL.WHERECLAUSE;
				}
			}


	</CFSCRIPT>

<!---
 	SELECT <CFOUTPUT>#SELECTText#</CFOUTPUT><BR>
	FROM <CFOUTPUT>#tablelist#</CFOUTPUT><BR>
	WHERE <CFOUTPUT>#wheretext#</CFOUTPUT>

 --->
 	<!---  	<CFIF len(FORM.SEARCHSTRING) NEQ 0> --->
	<CFIF 1 EQ 1>

		<CFQUERY NAME="SearchQuery" DATASOURCE="#URL.ODBCCONN#">
			SELECT #Evaluate("SELECTText")#, #URL.COMMONDBFIELD# AS COMMONDBFIELD
			FROM #Evaluate("tablelist")#
			WHERE #Evaluate("wheretext")#
		</CFQUERY>
		<CFIF SearchQuery.Recordcount GT 0>
			<CFSET QueryOutPutFields = "">

			<CFSET ReplaceString = "<SPAN STYLE=" & URL.highlight_style & "'>" & FORM.SEARCHSTRING & "</SPAN>">
			<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

			<html>
			<head>
				<title>Untitled</title>
			</head>
			<BODY onload="top.opener.maintaineSelectionCrossScreens('<CFOUTPUT>#URL.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>_array', document.all.Record_IDs)">
			<TABLE STYLE="<cfoutput>#URL.RESULTTABLE_TABLE_STYLE#</cfoutput>">
			<TR STYLE="<CFOUTPUT>#URL.COLUMNHEADING_STYLE#</CFOUTPUT>">
				<TD STYLE="<cfoutput>#URL.RESULTTABLE_ROW_STYLE#</cfoutput>"><INPUT TYPE="checkbox" STYLE="visibility: hidden;"></TD>
				<CFLOOP INDEX="HeadingText" LIST="#URL.DATABASEFIELDSTOSEARCH#" DELIMITERS=",">
					<CFIF listlen(HeadingText, ".") EQ 3>
						<CFOUTPUT><TD STYLE="#URL.COLUMNHEADING_STYLE#">#listgetat(HeadingText,3,".")#</TD></CFOUTPUT>
						<CFSET QueryOutPutFields = listappend(QueryOutPutFields, "SearchQuery." & listgetat(HeadingText,2,"."))>
					</CFIF>
				</CFLOOP>
			</TR>
				<CF_Rows maxrows="12">

				<CFOUTPUT QUERY="SearchQuery" startrow="#StartRow#" maxrows="#MaxRows#">
					<TR <CFIF currentrow mod 2>BGCOLOR="#URL.ALTROWCOLOR1#"<CFELSE>BGCOLOR="#URL.ALTROWCOLOR2#"</CFIF></TR>
						<TD>
						<CFIF URL.MULTISELECT EQ "YES">
							<INPUT TYPE="checkbox" NAME="Record_IDs" ID="Record_IDs" VALUE="#trim(Replace(SearchQuery.COMMONDBFIELD, '-', '_', 'ALL'))#" ONCLICK="top.opener.#URL.PARENTPAGEDATADISPLAYNAME#_gateway(this, '#URL.PARENTPAGEDATADISPLAYNAME#_array')" TITLE="<CFLOOP INDEX="ListItem" LIST="#URL.DISPLAYFIELDS#" DELIMITERS=",">#evaluate("SearchQuery.#listgetat(trim(replace(ListItem, ",", "", 'ALL')),2,".")#")#&nbsp;</CFLOOP>" <CFIF len(URL.EXTRADATAFIELDS) GT 0><cfloop index="ListItem" list="#URL.EXTRADATAFIELDS#" delimiters=","><CFSET Fieldname = listgetat(ListItem, 3, ".")><CFSET Value = evaluate("SearchQuery.#Fieldname#")>CUSTOM_#Fieldname#="<CFIF len(trim(Value)) EQ 0>-<CFELSE>#Value#</CFIF>" </CFLOOP></CFIF>>
						<CFELSE>
							<INPUT TYPE="radio" NAME="Record_IDs" ID="Record_IDs" VALUE="#trim(Replace(SearchQuery.COMMONDBFIELD, '-', '_', 'ALL'))#" ONCLICK="top.opener.#URL.PARENTPAGEDATADISPLAYNAME#_gateway(this, '#URL.PARENTPAGEDATADISPLAYNAME#_array')" TITLE="<CFLOOP INDEX="ListItem" LIST="#URL.DISPLAYFIELDS#" DELIMITERS=",">#evaluate("SearchQuery.#listgetat(trim(replace(ListItem, ",", "", 'ALL')),2,".")#")#&nbsp;</CFLOOP>" <CFIF len(URL.EXTRADATAFIELDS) GT 0><cfloop index="ListItem" list="#URL.EXTRADATAFIELDS#" delimiters=","><CFSET Fieldname = listgetat(ListItem, 3, ".")><CFSET Value = evaluate("SearchQuery.#Fieldname#")>CUSTOM_#Fieldname#="<CFIF len(trim(Value)) EQ 0>-<CFELSE>#Value#</CFIF>" </CFLOOP></CFIF>>
						</CFIF>
						</TD>
						<CFLOOP INDEX="QueryField" LIST="#QueryOutPutFields#" DELIMITERS=",">
							<CFSET tempString = Evaluate("#QueryField#")>
							<TD>

								<CFIF URL.highlightsearchstring EQ "YES" AND len(FORM.SEARCHSTRING) GT 0>
									#replacenocase(tempString,FORM.SEARCHSTRING,ReplaceString, 'ALL')#
								<CFELSE>
									#tempString#
								</CFIF>
							</TD>
						</CFLOOP>
					</TR>
				</CFOUTPUT>
			</TABLE>

				<CFSCRIPT>
					SecondayURLStruct = StructNew();
					URLList = structkeylist(URL);
					if(listfind(URLList, "FROMPAGE"))
						{
							URLList = listdeleteat(URLList, listfind(URLList, "FROMPAGE"));
							URLList = listdeleteat(URLList, listfind(URLList, "MAXROWS"));
							URLList = listdeleteat(URLList, listfind(URLList, "STARTROW"));
						}
				</CFSCRIPT>

				<div align="center">
					<CF_ResultPages
					query="SearchQuery"
					previous="<"
					next=">"
					previousseries="<<"
					nextseries=">>"
					addparams="#URLList#,SearchString">
					<BR><BR>
					<INPUT TYPE="button" VALUE="finished" ONCLICK="top.opener.<CFOUTPUT>#URL.PARENTPAGEDATADISPLAYNAME#</CFOUTPUT>_finished(); top.window.close()">
				</div>
		</BODY>
		</html>
		<CFELSE>
			NO MATCHES
		</CFIF>

	<CFELSE>
		<TABLE align="center">
			<TR>
				<TD>
					<cfoutput>#URL.UsageBlurb#</cfoutput>
				</TD>
			</TR>
		</TABLE>
	</CFIF>


	</CFCASE>
</CFSWITCH>
