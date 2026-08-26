<cfsetting enablecfoutputonly="yes">
<!--- Copyright 1999-2003 Macromedia Inc., All Rights Reserved --->

<!---

	Template:			dump.cfm
	Author:				Peter Muzila
	Description:		Tags dumps the content of the 'var' to output stream

	Usage:

		<cfdump
			var = "..."
		>

	Attributes:

		var (var, required) - variable to be dumped

--->

<cfif ThisTag.ExecutionMode is "End">
	<cfsetting enablecfoutputonly="no">
	<cfexit>
</cfif>

<!--- attributes validation --->
<!--- IsDefined() does not work for some objects --->

<cftry>
	<cfset var = attributes.var>
	<cfcatch>
	 	<cfthrow type="coldfusion.tagext.validation.MissingAttributeException" message="var">
	</cfcatch>
</cftry>

<cfparam name="attributes.label" default="" type="string">
<cfparam name="attributes.expand" default=true type="boolean">
<cfparam name="attributes.xmlShortStyle" default=false type="boolean">
<cfparam name="attributes.isException" default=false type="boolean">
<cfparam name="attributes.udfMaxWidth" default=false type="boolean">

<cfif attributes.label eq "">
	<cfset LABEL = "">
<cfelse>
	<cfset LABEL = attributes.label & " - ">
</cfif>

<cfparam name="request.cfDumpInited" default=FALSE>

<cfset bIE = (cgi.user_agent contains "MSIE")>
<cfset bMozilla = (cgi.user_agent contains "Mozilla/5.0")>
<cfset bDHTML = (bIE or bMozilla)>

<cfset INIT_XML_DOC_CAPTION = "xml document [short version]">
<cfif bDHTML and not attributes.expand>
	<cfset INIT_KEY_SIBLING_ATTRIBS = ' style="display:none;"'>
	<cfset INIT_KEY_FONT_STYLE = "font-style : italic;">
	<cfset INIT_TITLE = "click to expand">
<cfelse>
	<cfset INIT_KEY_SIBLING_ATTRIBS = ''>
	<cfset INIT_KEY_FONT_STYLE = "">
	<cfset INIT_TITLE = "click to collapse">
</cfif>

<cfif bDHTML>
<!--- The original code had the Onclick event and the styles. We do not want that (See the code below) --->
	<cfset INIT_KEY_ATTRIBS = ''>
	<cfset INIT_HEADER_ATTRIBS = ''>
	<cfset INIT_XML_DOC_HEADER_ATTRIBS = ''>

<!--- 
	<cfset INIT_KEY_ATTRIBS = ' onClick="cfdump_toggleRow(this);" style="cursor:pointer;#INIT_KEY_FONT_STYLE#" title="#INIT_TITLE#"'>
	<cfset INIT_HEADER_ATTRIBS = ' onClick="cfdump_toggleTable(this);" style="cursor:pointer;" title="click to collapse"'>
	<cfset INIT_XML_DOC_HEADER_ATTRIBS = ' onClick="cfdump_toggleXmlDoc(this)" style="cursor:pointer;" title="click to maximize"'>
 --->

<cfelse>
	<cfset INIT_KEY_ATTRIBS = ''>
	<cfset INIT_HEADER_ATTRIBS = ''>
	<cfset INIT_XML_DOC_HEADER_ATTRIBS = ''>
</cfif>

<cfif not request.cfDumpInited>

	<cfoutput>
<style>
table.cfdump_wddx,
table.cfdump_xml,
table.cfdump_struct,
table.cfdump_array,
table.cfdump_query,
table.cfdump_cfc,
table.cfdump_object,
table.cfdump_binary,
table.cfdump_udf,
table.cfdump_udfbody,
table.cfdump_udfarguments {
	font-size: xx-small;
	font-family: verdana, arial, helvetica, sans-serif;
	cell-spacing: 2;
}

table.cfdump_wddx th,
table.cfdump_xml th,
table.cfdump_struct th,
table.cfdump_array th,
table.cfdump_query th,
table.cfdump_cfc th,
table.cfdump_object th,
table.cfdump_binary th,
table.cfdump_udf th,
table.cfdump_udfbody th,
table.cfdump_udfarguments th {
	text-align: left;
	color: white;
	padding: 5;
}

table.cfdump_wddx td,
table.cfdump_xml td,
table.cfdump_struct td,
table.cfdump_array td,
table.cfdump_query td,
table.cfdump_cfc td,
table.cfdump_object td,
table.cfdump_binary td,
table.cfdump_udf td,
table.cfdump_udfbody td,
table.cfdump_udfarguments td {
	padding: 3;
	background-color: ffffff;
	vertical-align : top;
}

table.cfdump_wddx {
	background-color: 000000;
}
table.cfdump_wddx th.wddx {
	background-color: 444444;
}


table.cfdump_xml {
	background-color: 888888;
}
table.cfdump_xml th.xml {
	background-color: aaaaaa;
}
table.cfdump_xml td.xml {
	background-color: dddddd;
}

table.cfdump_struct {
	background-color: 0000cc ;

}
table.cfdump_struct th.struct {
	background-color: 4444cc ;
}
table.cfdump_struct td.struct {
	background-color: ccddff;
}

table.cfdump_array {
	background-color: 006600 ;
}
table.cfdump_array th.array {
	background-color: 009900 ;
}
table.cfdump_array td.array {
	background-color: ccffcc ;
}

table.cfdump_query {
	background-color: 884488 ;
}
table.cfdump_query th.query {
	background-color: aa66aa ;
}
table.cfdump_query td.query {
	background-color: ffddff ;
}


table.cfdump_cfc {
	background-color: ff0000;
}
table.cfdump_cfc th.cfc{
	background-color: ff4444;
}
table.cfdump_cfc td.cfc {
	background-color: ffcccc;
}


table.cfdump_object {
	background-color : ff0000;
}
table.cfdump_object th.object{
	background-color: ff4444;
}

table.cfdump_binary {
	background-color : eebb00;
}
table.cfdump_binary th.binary {
	background-color: ffcc44;
}
table.cfdump_binary td {
	font-size: x-small;
}
table.cfdump_udf {
	background-color: aa4400;
}
table.cfdump_udf th.udf {
	background-color: cc6600;
}
table.cfdump_udfarguments {
	background-color: dddddd;
	cell-spacing: 3;
}
table.cfdump_udfarguments th {
	background-color: eeeeee;
	color: 000000;
}

</style>
	</cfoutput>

	<cfif bDHTML>

	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 																								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		<!--- JS function to hide/show nodes of complex data (IE only) --->
		<cfoutput>
<script language="JavaScript">
	function dump ( obj ) {
		var out = '' ;
		if ( typeof obj == "object" ) {
			for ( key in obj ) {
				if ( typeof obj[key] != "function" ) out += key + ': ' + obj[key] + '<br>' ;
			}
		}
	}


	function cfdump_toggleRow(source) {
		//target is the right cell
		if(document.all) target = source.parentElement.cells[1];
		else target = source.parentNode.lastChild ;

		cfdump_toggleTarget( target, cfdump_toggleSource( source ) ) ;
	}

	function cfdump_toggleXmlDoc(source) {

		var caption = source.innerHTML.split( ' [' ) ;

		// toggle source (header)
		if ( source.style.fontStyle == 'italic' ) {
			// closed -> short
			source.style.fontStyle = 'normal' ;
			source.innerHTML = caption[0] + ' [short version]' ;
			source.title = 'click to maximize' ;
			switchShortToState = 'open' ;
		} else if ( source.innerHTML.indexOf('[short version]') != -1 ) {
			// short -> full
			source.innerHTML = caption[0] + ' [long version]' ;
			source.title = 'click to collapse' ;
			switchLongToState = 'open' ;
			switchShortToState = 'closed' ;
		} else {
			// full -> closed
			source.style.fontStyle = 'italic' ;
			source.title = 'click to expand' ;
			source.innerHTML = caption[0] ;
			switchLongToState = 'closed' ;
		}

		// Toggle the target (everething below the header row).
		// First two rows are XMLComment and XMLRoot - they are part
		// of the long dump, the rest are direct children - part of the
		// short dump
		if(document.all) {
			var table = source.parentElement.parentElement ;
			for ( var i = 1; i < table.rows.length; i++ ) {
				target = table.rows[i] ;
				if ( i < 3 ) cfdump_toggleTarget( target, switchLongToState ) ;
				else cfdump_toggleTarget( target, switchShortToState ) ;
			}
		}
		else {
			var table = source.parentNode.parentNode ;
			var row = 1;
			for ( var i = 1; i < table.childNodes.length; i++ ) {
				target = table.childNodes[i] ;
				if( target.style ) {
					if ( row < 3 ) {
						cfdump_toggleTarget( target, switchLongToState ) ;
					} else {
						cfdump_toggleTarget( target, switchShortToState ) ;
					}
					row++;
				}
			}
		}
	}

	function cfdump_toggleTable(source) {

		var switchToState = cfdump_toggleSource( source ) ;
		if(document.all) {
			var table = source.parentElement.parentElement ;
			for ( var i = 1; i < table.rows.length; i++ ) {
				target = table.rows[i] ;
				cfdump_toggleTarget( target, switchToState ) ;
			}
		}
		else {
			var table = source.parentNode.parentNode ;
			for ( var i = 1; i < table.childNodes.length; i++ ) {
				target = table.childNodes[i] ;
				if(target.style) {
					cfdump_toggleTarget( target, switchToState ) ;
				}
			}
		}
	}

	function cfdump_toggleSource ( source ) {
		if ( source.style.fontStyle == 'italic' ) {
			source.style.fontStyle = 'normal' ;
			source.title = 'click to collapse' ;
			return 'open' ;
		} else {
			source.style.fontStyle = 'italic' ;
			source.title = 'click to expand' ;
			return 'closed' ;
		}
	}

	function cfdump_toggleTarget ( target, switchToState ) {
		if ( switchToState == 'open' )	target.style.display = '' ;
		else target.style.display = 'none' ;
	}
</script>
		</cfoutput>

				
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 																								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->		
		
		
	</cfif>

	<cfset request.cfDumpInited = TRUE>

</cfif>


<!-------- WDDX -------------------------->
<cfif isWddx(var)>

	<cfwddx action="wddx2cfml" input="#var#" output="decodedVar">
	<cfoutput>
	<table class="cfdump_wddx">
	<tr><th class="wddx"#INIT_HEADER_ATTRIBS#>#LABEL#wddx encoded</th></tr>
	<tr><td valign="top">
	</cfoutput>

	<cfdump var="#decodedVar#">

	<cfoutput>
	</td></tr></table>
	</cfoutput>

<!---------- UDF -------------------------->
<cfelseif IsCustomFunction(var)>

	<cfset metadata=getMetadata(var)>
	<cfset params=metadata.parameters>
	<cfset paramcount = arraylen(params)>

	<cfoutput>
	<table class="cfdump_udf"<cfif attributes.udfMaxWidth> width="100%"</cfif>>
	<tr><th class="udf" colspan="2"#INIT_HEADER_ATTRIBS#>#LABEL#function #metadata.name#</b></th></tr>
	<tr>
		<td>
		<table class="cfdump_udfbody">
		<tr>
			<cfif paramcount>
			<td colspan="2">
			<i>Arguments:</i>
			<br>
			<table class="cfdump_udfarguments">
				<tr>
					<th><b>Name</b></td>
					<th><b>Required</b></td>
					<th><b>Type</b></td>
					<th><b>Default</b></td>
				</tr>
				<cfloop index="x" from=1 to="#paramcount#">
				<tr>
					<td>#params[x].name#</td>
					<td><cfif structKeyExists(params[x],"required") and not params[x].required>Optional<cfelse>Required</cfif></td>
					<td><cfif structKeyExists(params[x],"type")>#params[x].type#<cfelse>Any</cfif></td>
					<td><cfif structKeyExists(params[x],"default")><cfdump var="#params[x].default#"><cfelse>&nbsp;</cfif></td>
				</tr>
				</cfloop>
			</table>
			<cfelse>
			<td><i>Arguments:</i></td><td>none</td>
			</cfif>
		</tr>
		<tr><td width="30%"><i>Return Type:</i></td>
			<td><cfif structKeyExists(metadata,"returnType")>#metadata.returnType#<cfelse>&nbsp;</cfif><br></td>
		</tr>
		<tr><td><i>Roles:</i></td>
			<td><cfif structKeyExists(metadata,"roles")>#metadata.roles#<cfelse>&nbsp;</cfif><br></td>
		</tr>
		<tr><td><i>Access:</i></td>
			<td><cfif structKeyExists(metadata,"access")>#metadata.access#<cfelse>public</cfif></br></td>
		</tr>
		<tr><td><i>Output:</i></td>
			<td><cfif structKeyExists(metadata,"output")>#metadata.output#<cfelse>Yes</cfif></td>
		</tr>
		</table>
		</td>
	</tr>
	</table>
	</cfoutput>


<!-------------- XML element ------------->
<cfelseif IsXmlElem(var)>

	<cfoutput>
	<table class="cfdump_xml">
	</cfoutput>

	<cfif  attributes.xmlShortStyle>
		<!--- <cfoutput>
		<tr><th class="xml" colspan="2"#INIT_HEADER_ATTRIBS#>#LABEL#xml element [short version]</th></tr>
		</cfoutput> --->

		<cfoutput>
		<tr><td class="xml"#INIT_KEY_ATTRIBS#>XmlText</td><td>#var.XmlText#</td></tr>
		</cfoutput>

		<cfif not StructIsEmpty(var.xmlAttributes)>
			<cfoutput>
			<tr><td class="xml"#INIT_KEY_ATTRIBS#>XmlAttributes</td><td>
			</cfoutput>

			<cfdump var="#var.XmlAttributes#">

			<cfoutput>
			</td></tr>
			</cfoutput>
		</cfif>

 		<cfloop index="i" from="1" to="#ArrayLen(var.xmlChildren)#">
			<cfset child = var.xmlChildren[i]>
			<cfoutput>
			<tr><td class="xml"#INIT_KEY_ATTRIBS#>#child.xmlName#</td>
			<td>
			</cfoutput>

			<cfdump var="#child#" xmlShortStyle="yes">

			<cfoutput>
			</td></tr>
			</cfoutput>
		</cfloop>

	<cfelse>
		<cfoutput>
		<tr><th class="xml" colspan="2"#INIT_HEADER_ATTRIBS#>#LABEL#xml element</th></tr>
		<tr><td class="xml"#INIT_KEY_ATTRIBS#>XmlName</td><td><b>#var.XmlName#</b></td></tr>
		<tr><td class="xml"#INIT_KEY_ATTRIBS#>XmlNsPrefix</td><td>#var.XmlNsPrefix#</td></tr>
		<tr><td class="xml"#INIT_KEY_ATTRIBS#>XmlNsURI</td><td>#var.XmlNsURI#</td></tr>
		<tr><td class="xml"#INIT_KEY_ATTRIBS#>XmlText</td><td>#var.XmlText#</td></tr>
		<tr><td class="xml"#INIT_KEY_ATTRIBS#>XmlComment</td><td>#var.XmlComment#</td></tr>
		<tr><td class="xml"#INIT_KEY_ATTRIBS#>XmlAttributes</td><td>
		</cfoutput>

		<cfdump var="#var.XmlAttributes#">

		<cfoutput>
		</td></tr>
		<tr><td class="xml"#INIT_KEY_ATTRIBS#>XmlChildren</td><td>
		</cfoutput>

		<cfset nodes = var.xmlChildren>
		<cfset size = ArrayLen(nodes)>
		<cfloop index="i" from = "1" to = "#size#">
			<cfdump var="#var.xmlChildren[i]#">
		</cfloop>

		<cfoutput>
		</td></tr>
		</cfoutput>
	</cfif>

	<cfoutput>
	</table>
	</cfoutput>

<!---------------- XML document ------------------>
<cfelseif IsXmlDoc(var)>

	<cfoutput>
	<table class="cfdump_xml">
	<tr><th class="xml" colspan="2"#INIT_XML_DOC_HEADER_ATTRIBS#>#LABEL##INIT_XML_DOC_CAPTION#</th></tr>
	<tr style="display:none;"><td class="xml"#INIT_KEY_ATTRIBS#>XmlComment</td><td#INIT_KEY_SIBLING_ATTRIBS#>#var.XmlComment#</td></tr>
	</cfoutput>
	<cfif StructKeyExists(var, "XmlRoot")>

		<cfoutput>
		<tr style="display:none;"><td class="xml"#INIT_KEY_ATTRIBS#>XmlRoot</td><td#INIT_KEY_SIBLING_ATTRIBS#>
		</cfoutput>

		<cfdump var="#var.XmlRoot#">

		<cfoutput>
		</td></tr>
		</cfoutput>

		<cfloop collection="#var#" item="key">
			<cfoutput>
			<tr><td class="xml"#INIT_KEY_ATTRIBS#>#key#</td><td#INIT_KEY_SIBLING_ATTRIBS#>
			</cfoutput>

			<cfdump var="#var.XmlRoot#" xmlShortStyle="yes">

			<cfoutput>
			</td></tr>
			</cfoutput>

		</cfloop>

	<cfelse>
		<cfoutput>
		<tr><td>XmlRoot</td><td>&nbsp;</td></tr>
		</cfoutput>
	</cfif>
	<cfoutput>
	</table>
	</cfoutput>


<!-------------- object/cfc ----------------------->
<cfelseif IsObject(var) and not attributes.isException>
	<cfset IsComponent = false>
	<cftry>

		<cfset data = getMetadata(var)>
		<cfif IsDefined('data.type') and data.type eq "component">
			<cfset IsComponent = true>
		</cfif>
		<cfcatch></cfcatch>
	</cftry>

	<cfif IsComponent>

		<cfoutput>
		<table class="cfdump_cfc">
		<tr><th class="cfc" colspan="2"#INIT_HEADER_ATTRIBS#>#LABEL#component
			<a style="color: white;" href="#getpageContext().getRequest().getContextPath()#/CFIDE/componentutils/CFCExplorer.cfc?method=getcfcinhtml&name=#data.name#">#data.name#</a></th>
		</tr>
		</cfoutput>
			<cfloop item="key" collection="#var#">
			<cfif not IsCustomFunction(var[key])>
				<cfoutput>
				<tr valign="top">
				<td class="cfc"#INIT_KEY_ATTRIBS#>#key#</td>
				<td>
				</cfoutput>

				<cfdump var="#var[key]#"></td>

				<cfoutput>
				</tr>
				</cfoutput>
			</cfif>
			</cfloop>

			<cfloop item="key" collection="#var#">
			<cfif IsCustomFunction(var[key])>
				<cfoutput>
				<tr valign="top">
				<td class="cfc"#INIT_KEY_ATTRIBS#>#key#</td>
				<td>
				</cfoutput>

				<cfdump var="#var[key]#" udfMaxWidth="yes"></td>

				<cfoutput>
				</tr>
				</cfoutput>
			</cfif>
			</cfloop>

		<cfoutput>
		</table>
		</cfoutput>

	<cfelse>
  		<cftry>
  			<cfset className = var.getClass()>
			<cfif FindNoCase( "class", className ) eq 1>
  				<cfset className = "of " & RemoveChars( className, 1, 6 )>
				<cfset javaType = 1>
				<!--- Test to see if we are an exception, if we so, we need to treat as struct --->
				<cfset exceptionOb = createObject("java","java.lang.Throwable")>
				<cfset exceptionClass = exceptionOb.getClass()>
				<cfset myClass = var.getClass()>
				<cfif exceptionClass.isAssignableFrom(myClass)>
					<cfdump var="#duplicate(var)#" isException=1>
					<cfexit>
				</cfif>
			<cfelse>
			    <!--- Check if this is a COM proxy object --->
			    <!--- NOTE: since getClass() above currently throws an error, this code
			          is probably not neccessary --->
				<cfset jp = CreateObject("java", "coldfusion.runtime.java.JavaProxy")>
				<cfset _obj = jp.init(var)>
				<cfset className = _obj.getClass()>
				<cfif FindNoCase( "class", className ) eq 1>
  					<cfset className = "of " & RemoveChars( className, 1, 6 )>
					<cfset javaType = 1>
					<cfif FindNoCase("coldfusion.runtime.com.ComProxy", className) gt 1>
						<cfset comType = 1>
					</cfif>
				</cfif>

  			</cfif>
  			<cfcatch>
  			    <!--- var.getClass() probably threw this error because var is a Proxy object --->
  			    <cftry>
		    	    <!--- Check if this is a COM proxy object --->
					<cfset jp = CreateObject("java", "coldfusion.runtime.java.JavaProxy")>
					<cfset _obj = jp.init(var)>
					<cfset className = _obj.getClass()>
					<cfif FindNoCase( "class", className ) eq 1>
  						<cfset className = "of " & RemoveChars( className, 1, 6 )>
						<cfset javaType = 1>
						<cfif FindNoCase("coldfusion.runtime.com.ComProxy", className) gt 1>
							<cfset comType = 1>
						</cfif>
					<cfelse>
						 	<cfset className = "[unknown type]">
					</cfif>
				<cfcatch>
					<cfset className = "[unknown type]">
				</cfcatch>
				</cftry>
			</cfcatch>
  		</cftry>
  		<cftry>
  			<cfset value = var.toString()>
  			<cfcatch><cfset value="[unable to convert to string]"></cfcatch>
  		</cftry>

		<cfoutput>
		<table class="cfdump_object">
		<tr><th class="object" colspan="2"#INIT_HEADER_ATTRIBS#>#LABEL#object #className#<br>
		<cfif isDefined("comType")> {#_obj.getClsIDString()#}</cfif>
		</th></tr>
		</cfoutput>

		<cfif not isDefined("javaType")>
			<cfif StructIsEmpty(var)>
				<cfoutput>
				<tr><td colspan="2">#value#</td></tr>
				</cfoutput>
			<cfelse>
				<!--- Prepare alphabetized list... --->
				<cfset keys = structKeyArray(var)>
				<cfset arraySort(keys,"text")>

				<!--- dump keys one by one --->
				<cfloop index="x" from=1 to="#arrayLen(keys)#">
					<cfset keyName = keys[x]>
					<cfoutput>
					<tr><td class="object"#INIT_KEY_ATTRIBS#>#keyName#</td>
					<td#INIT_KEY_SIBLING_ATTRIBS#></cfoutput>
			        <cftry>
						<cfdump var="#var[keyname]#">
						<cfcatch>
							<cfoutput>[undefined value]</cfoutput>
			        	</cfcatch>
		    	    </cftry>

					<cfoutput></td></tr></cfoutput>
				</cfloop>

			</cfif>
		<cfelseif isDefined("comType")>
			<cfset methods = _obj.getObjMethodInfo()>
			<cfif arrayLen(methods)>
				<cfoutput>
					<tr>
						<td class="object"#INIT_KEY_ATTRIBS#>Methods</td>
						<td#INIT_KEY_SIBLING_ATTRIBS#>
				</cfoutput>
				<cfloop index="x" from=1 to="#arrayLen(methods)#">
					<cfoutput>#methods[x]#<br></cfoutput>
				</cfloop>
				<cfoutput></td></tr></cfoutput>
			</cfif>
			<cfset putfields = _obj.getObjPutPropertyInfo()>
			<cfif arrayLen(putfields)>
				<cfoutput>
					<tr>
						<td class="object"#INIT_KEY_ATTRIBS#>Put Properties</td>
						<td#INIT_KEY_SIBLING_ATTRIBS#>
				</cfoutput>
				<cfloop index="x" from=1 to="#arrayLen(putfields)#">
						<cfoutput>#putfields[x]#<br></cfoutput>
				</cfloop>
				<cfoutput></td></tr></cfoutput>
			</cfif>
			<cfset getfields = _obj.getObjGetPropertyInfo()>
			<cfif arrayLen(getfields)>
				<cfoutput>
					<tr>
						<td class="object"#INIT_KEY_ATTRIBS#>Get Properties</td>
						<td#INIT_KEY_SIBLING_ATTRIBS#>
				</cfoutput>
				<cfloop index="x" from=1 to="#arrayLen(getfields)#">
						<cfoutput>#getfields[x]#<br></cfoutput>
				</cfloop>
				<cfoutput></td></tr></cfoutput>
			</cfif>

		<cfelse>
			<cfset methods = var.getClass().getMethods()>
			<cfif arrayLen(methods)>
				<cfoutput>
					<tr>
						<td class="object"#INIT_KEY_ATTRIBS#>Methods</td>
						<td#INIT_KEY_SIBLING_ATTRIBS#>
				</cfoutput>
				<cfloop index="x" from=1 to="#arrayLen(methods)#">
					<cfset returnClassName = methods[x].getReturnType()>
					<cfoutput>#methods[x].getName()# (returns #replace(returnClassName,"class ","")#)<br></cfoutput>
				</cfloop>
				<cfoutput></td></tr></cfoutput>
			</cfif>
			<cfset fields = var.getClass().getFields()>
			<cfif arrayLen(fields)>
				<cfloop index="x" from=1 to="#arrayLen(fields)#">
					<cfoutput>
						<tr>
						<td class="object"#INIT_KEY_ATTRIBS#>#fields[x].getName()#</td>
						<td#INIT_KEY_SIBLING_ATTRIBS#>
							<cftry>
							<cfif isSimpleValue(var[fields[x].getName()])>
								#var[fields[x].getName()]#
							<cfelse>
								<!--- try class name --->
						  			<cfset className = fields[x].getType()>
									#className#
							</cfif>
							<cfcatch>[undefined value]</cfcatch>
							</cftry>
						</td>
						</tr>
					</cfoutput>
				</cfloop>
			</cfif>
		</cfif>
		<cfoutput>
		</table>
		</cfoutput>

	</cfif>



<!---------------- struct ------------------->
<cfelseif IsStruct(var)>
	<cfoutput>

	<table class="cfdump_struct">

	<!--- <table class="cfdump_struct"> --->
	<tr><th class="struct" colspan="2"#INIT_HEADER_ATTRIBS#>#LABEL#struct<cfif StructIsEmpty(var)> [empty]</cfif></th></tr>
	</cfoutput>

	<!--- Prepare alphabetized list... --->
	<cfset keys = structKeyArray(var)>
	<cfset arraySort(keys,"text")>

	<!--- dump keys one by one --->
	<cfloop index="x" from=1 to="#arrayLen(keys)#">
		<cfset keyName = keys[x]>
		<cfoutput>
		<tr><td class="struct"#INIT_KEY_ATTRIBS#>#keyName#</td>
		<td#INIT_KEY_SIBLING_ATTRIBS#></cfoutput>

        <cftry>
			<cfdump var="#var[keyName]#">
			<cfcatch>
				<cfoutput>[undefined struct element]</cfoutput>
        	</cfcatch>
        </cftry>

		<cfoutput></td></tr></cfoutput>
	</cfloop>

	<cfoutput>
	</table>
	</cfoutput>

<!--------------- binary ---------------->
<cfelseif IsBinary(var)>

	<!---
		Binary acts like an array, so we can list it out, but we will do
	    a sanity check and stop displaying at 1k chars
	--->
	<cfset sanityMax = Min(1000,arrayLen(var))>

	<cfoutput>
	<table class="cfdump_binary">
	<tr><th class="binary"#INIT_HEADER_ATTRIBS#>#LABEL#binary</th></tr>
	<tr><td class="binary">
	<code><cfloop index="x" from=1 to="#sanityMax#">#var[x]#</cfloop></code>
	<cfif arrayLen(var) gt sanityMax>
	<br><code>[truncated]</code>
	</cfif>
	</td></tr></table>
	</cfoutput>


<!--------------- array ------------------->
<cfelseif IsArray(var)>

	<cfoutput>
	<table class="cfdump_array">
	<tr><th class="array" colspan="2"#INIT_HEADER_ATTRIBS#>#LABEL#array
	<cfif ArrayIsEmpty(var)>[empty]</cfif></th></tr>
	</cfoutput>

	<cfset size = ArrayLen(var)>
	<!--- dump items one by one --->
	<cfloop index="i" from="1" to="#size#">
		<cfoutput>
		<tr><td class="array"#INIT_KEY_ATTRIBS#>#i#</td>
		<td#INIT_KEY_SIBLING_ATTRIBS#></cfoutput>

		<cftry>
			<cfdump var="#var[i]#">
		<cfcatch>
			<cfoutput>[undefined array element]</cfoutput>
		</cfcatch>
		</cftry>

		<cfoutput></td></tr></cfoutput>
	</cfloop>

	<cfoutput>
	</table>
	</cfoutput>


<!------------------ query ------------------------->
<cfelseif IsQuery(var)>

	<cfset colList = var.columnList>

	<cfoutput>
	<table class="cfdump_query">
	<tr><th class="query" colspan="#(1+ListLen(colList))#"#INIT_HEADER_ATTRIBS#>#LABEL#query</th></tr>
	<tr bgcolor="eeaaaa">
		<td class="query">&nbsp;</td>
		<cfloop list="#colList#" index="colName"><td class="query">#colName#</td></cfloop></tr>
	</cfoutput>


		<!--- scroll thru rows --->
		<cfloop index="currentRow" from="1" to="#var.recordCount#">
			<cfoutput>
			<tr><td class="query">#currentRow#</td></cfoutput>

			<!--- create deep copy of each field --->
			<cfloop list="#colList#" index="col">
				<cfoutput><td valign="top"></cfoutput>
				<cfdump var="#var[col][currentRow]#">
				<cfoutput></td></cfoutput>
			</cfloop>

			<cfoutput></tr></cfoutput>

		</cfloop>

	<cfoutput>
	</table>
	</cfoutput>


<!----------------- simple value ------------------->
<cfelseif IsSimpleValue( var )>

	<cfif Len(var) eq 0>
		<cfoutput>[empty string]</cfoutput>
	<cfelse>
		<cfoutput>#htmlEditFormat(var)#</cfoutput>
	</cfif>


<!----------------- unknown ---------------------->
<cfelse>

	<cfoutput>
	<table class="cfdump">
	<tr><th#INIT_HEADER_ATTRIBS#>#LABEL#[unknown type]</td></tr>
	</table>
	</cfoutput>

</cfif>
<cfsetting enablecfoutputonly="no">

