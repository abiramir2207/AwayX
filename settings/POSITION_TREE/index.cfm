<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>tree</title>
	<!--- There is a style sheet inside explorer.xsl.
	To change any style for the clickable "links" on the tree,that code needs to be modified
	--->
		<style>
			a:link{color:blue;text-decoration:none;font-size:8pt;font-family:verdana;}
			a:visited{color:blue;text-decoration:none;font-size:8pt;font-family:verdana;}
			a:hover{color:blue;text-decoration:underline;font-size:8pt;font-family:verdana;}
			.levelLabel{color:White;background-color:red;font-family='Courier New';padding-left:4px;padding-right:4px;}
		</style>
		<style type="text/css" media="print">
			#DIV_DONT_PRINT
			{
				display:none;
			}
		</style>
	<cfinclude template="/Common_Files/jQuery.cfm">
</head>

<!--- Get the expanded path of the CURRENT template path. --->
<cfset docPath = GetDirectoryFromPath(GetCurrentTemplatePath()) />

<BODY onload="initPage();">


<CFSET pagetitle = "USERS: USER POSITIONS">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<CFQUERY NAME="lasteditedby" datasource="#application.datasource#" MAXROWS="1">
SELECT TOP 1 *
FROM Zone_Region_Market_Last_Edited_By
ORDER BY Last_Updated desc
</CFQUERY>
<!---Help Files--->
<span id="DIV_DONT_PRINT">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
</span>
<!---Help Files--->

<CFIF lasteditedby.recordcount EQ 0>
<CFELSE>
	<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT *
		FROM _Users
		WHERE User_ID = '#lasteditedby.Users_ID#'
	</CFQUERY>

	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated By &nbsp;<CFOUTPUT>#getUserName.Name_First# #getUserName.Name_Last#</CFOUTPUT> on <CFOUTPUT>#dateformat(lasteditedby.Last_Updated, 'm/d/yyy')#
	#timeformat(lasteditedby.Last_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
</CFIF>

	<script>
		var data_loaded 	= 0;
		var style_loaded 	= 0;
		var LoadFinal		= 0;
	</script>

	<table align="center" id="DIV_DONT_PRINT" cellpadding="7">
		<tr>
			<td>
				<CF_button
					button_name		=	""
					button_caption	=	"toggle view"
					button_action	=	"expandTree('picon')"
					button_type		=	"javascript_link"
					button_width	=	""
					button_color	=	"Navy"
					button_tip		=	"click here to expand all tree nodes"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</td>
<!--- 			<td>
				<CF_button
					button_name		=	""
					button_caption	=	"collapse all"
					button_action	=	"expandTree('icon')"
					button_type		=	"javascript_link"
					button_width	=	""
					button_color	=	"Navy"
					button_tip		=	"click here to collapse all tree nodes"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</td> --->
			<td>
				<CF_button
					button_name		=	""
					button_caption	=	"print"
					button_action	=	"window.print()"
					button_type		=	"javascript_link"
					button_width	=	"70"
					button_color	=	"Navy"
					button_tip		=	"click here to print the tree"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</td>
			<td>
				<FONT COLOR="##FF0000"><B>[ </B></FONT>
					<a href="buildxml.cfm"  id="id_regenerateTree" style="color:blue;font-weight:bold;">regenerate the tree</a>
				<FONT COLOR="##FF0000"><B> ]</B></FONT>
			</td>
		</tr>
	</table>

	
		
	<cfset browserVersion = request.app_general_functions.getBrowserVersion(HTTP_USER_AGENT) />
	<div align="center" id="waitLoad" style="font-weight: bold; color: red; font-size: 20px"></div>

	<div id="position_tree_content"></div>
	
	<cfif browserVersion EQ "IE 11" and FileExists(ExpandPath("explorerFile.xml"))>
		<div id="position_tree_content_IE">
			<cfsavecontent variable="xmlDoc">
				<cfinclude template = "explorerFile.xml" />
			</cfsavecontent>
			<cfsavecontent variable="xslDoc">
				<cfinclude template = "explorer.xsl" />
			</cfsavecontent>
			<cfset transformedXML = XmlTransform(xmlDoc,xslDoc)>
			<cfoutput>#transformedXML#</cfoutput>
		</div>
	</cfif>
	
	<script>

		function loadTree()
		{
			if(LoadFinal == 0)
			{
					var xmlhttp = new XMLHttpRequest();
					xmlhttp.onreadystatechange=function() //This part is actually executed last
					{
						if (xmlhttp.readyState==4 && xmlhttp.status==200) // Was the request processed successfully?
						{
							var xmlhttpxsl = new XMLHttpRequest();
							xmlhttpxsl.open("GET", "explorer.xsl" , false);
							xmlhttpxsl.send();
							var xsl = xmlhttpxsl.responseXML;

							xsltProcessor=new XSLTProcessor();
							xsltProcessor.importStylesheet(xsl);
							resultDocument = xsltProcessor.transformToFragment(xmlhttp.responseXML,document);
							document.getElementById("position_tree_content").appendChild(resultDocument);
						}
					}

					xmlhttp.open("GET", "explorerFile.xml", false);
					xmlhttp.send();

					document.all.waitLoad.style.display = 'none';
					LoadFinal = 1;



			}
		}

		function initPage() {
			toc1off = new Image();         // preload five images activated
        	toc1off.src = "/images/loading.gif";

		/* NOTE: "explorerFile.xml" was earlier called "explorer.xml". The reason why it name has been changed is to avoid writing extra code to determine whether
		to write the file or not. Since this file existed on "\settings\position_tree\" before being moved to "\common_documents\Data_Files\Created\settings\POSITION_TREE",
		some clients have it in both the locations.

		Earlier "explorer.xml" was inside "Common_documents\Data_Files\Created\settings\POSITION_TREE\" folder because Simplot used to use
		two webservers and so there was one place for document location (outside AwayX folder). Due to this reason, we could not put this file inside
		the "AwayX" folder. Simplot does not use two webservers anymmore. Moreover, to load this file for the Chrome browser, we need to use the
		path of the "explorer.xml" file. If we use "common_documents\datafiles..." path, the document cannot be accessed because for Smuckers we have added a security feature
		where no one can open (except coldfusion) "common_documents\datafiles..." from the browser directly. It can only be
		opened using "GetDocument.cfm" and since "GetDocument.cfm" does not work with xmlhttp (used for Chrome browser), we need to have "explorer.xml" written to
		"\settings\position_tree\", instead of "\common_documents\Data_Files\Created\settings\POSITION_TREE".
		*/
		<cfif FileExists("#docPath#\explorerFile.xml")>
			document.all.waitLoad.innerHTML = "<img src=\"/images/loading.gif\" title=\"\" border=\"0\"><br>loading...";
			window.setInterval("loadTree()", 100);
		/* If the file does not exist, then regenerate the tree. */
		<cfelse>
			$('#id_regenerateTree')[0].click();
			document.all.waitLoad.innerHTML = "<img src=\"/images/loading.gif\" title=\"\" border=\"0\"><br>regenerating tree...";
		</cfif>
		}
		function show(id){
			alert('You requested action no. '+ id);
		}

		function toggle(id,closed,opened,pre){
			if(event.srcElement.tagName =='IMG'){
				var myChild = document.getElementById(id);
				var myPIcon = document.getElementById("picon" + id);
				var myIcon = document.getElementById("icon" + id);
				if(myChild.style.display=="none"){
					myChild.style.display="block";
					//myIcon.src=opened;
					myPIcon.src="/images/position_tree/"+ pre + "minus.gif";
				}else{
					myChild.style.display="none";
					//myIcon.src=closed;
					myPIcon.src="/images/position_tree/"+ pre +"plus.gif";
				}
			}
		}

		function expandTree(iconName) {
			alert("Please be patient as this action may take a minute or so.");
			aImgs = document.body.getElementsByTagName("IMG");
			for(var x=0; x<=aImgs.length; x++) {
				tempIMG = aImgs[x];
				if(tempIMG){
					if(tempIMG.id != null || tempIMG.id == "undefined"){
						if(tempIMG.id.length >= 0) {
							if(tempIMG.id.substring(0, iconName.length) == iconName) {
								tempIMG.click()
							}
						}
					}
				}
			}
		}
	</script>
	<hr align="left" width="50%" color="navy" style="height: 1px;">
	<a href="buildxml.cfm"><cfoutput>#application.util.string.actionLinkFormat2("regenerate the tree")#</cfoutput></a>
	<cfset request.focusHiLightOff = 1>  <!--- skip code which applies style to focused element --->
		
		
</body>
</html>




