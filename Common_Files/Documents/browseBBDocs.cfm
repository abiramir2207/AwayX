
<cfparam name="url.Home" default="#Replace(CreateUUID(),'-','')#">
<cfif url.Home EQ ''>
	<cfset  url.Home = "#Replace(CreateUUID(),'-','')#"/>
</cfif>
<cfset AdjustHomePath = '/#url.Home#'/><!--- can set a default dir here  --->
<cfset templateName = 'browseBBDocsGet.cfm'/>
<cfset webroot = 'D:\Inetpub\wwwroot\DocServer'/>
<cfset mapping = 'D:\Pittsburgh\#url.Home#'/>

<cfparam name="url.sort" default="type ASC">
<cfparam name="form.sort" default="#url.sort#">
<cfparam name="url.dir" default="">
<cfparam name="form.dir" default="#url.dir#">
<cfparam name="url.txtFileName" default="">
<cfparam name="form.txtFileName" default="#url.txtFileName#">
<cfparam name="url.getFile" default="0">


<cfparam name="url.sortName" default="">
<cfparam name="url.sortDate" default="">
<cfparam name="url.sortType" default="">
<cfparam name="url.sortSize" default="">


<cfscript>
	if(url.sort contains 'name'){url.sortName = (url.sortName EQ 'DESC' ? 'ASC' : 'DESC');}
	if(url.sort contains 'date'){url.sortDate = (url.sortDate EQ 'DESC' ? 'ASC' : 'DESC');}
	if(url.sort contains 'type'){url.sortType = (url.sortType EQ 'DESC' ? 'ASC' : 'DESC');}
	if(url.sort contains 'size'){url.sortSize = (url.sortSize EQ 'DESC' ? 'ASC' : 'DESC');}
</cfscript>

<cfset url.dir = form.dir />
<cfset url.sort = form.sort />
<cfset url.txtFileName = form.txtFileName />
<!--- only needed for browsing in Pittsburgh (Not via cfhttp) --->
<!---
<cfif right(url.dir,4) EQ ".txt" OR 
		right(url.dir,4) EQ ".htm" OR 
		right(url.dir,4) EQ ".xls" OR 
		right(url.dir,5) EQ ".xlsx" OR 
		right(url.dir,4) EQ ".pdf" OR 
		right(url.dir,5) EQ ".docx" OR 
		right(url.dir,4) EQ ".doc" OR
		right(url.dir,4) EQ ".msg">
	<cfset fname = listLast(url.dir,'/') />
	<cfheader name="Content-Disposition" value="attachment; filename=#fname#" >
	<cfcontent type="application/octet-stream" file="#ExpandPath("#AdjustHomePath##url.dir#")#">
</cfif>--->

<cfset currentDir = ExpandPath("#AdjustHomePath##url.dir#/") />
<cfset currentDir = Replace(currentDir,webroot,'',"all") />
<cfset currentDir = Replace(currentDir,mapping,'',"all") />
<cfset currentDir = Replace(currentDir,'\','/',"all") />

<cfset crumbs = currentDir.split('/') />

<!--- <cfdump var="#currentDir#"/> --->
 
<cfset recurse = 'false'/>
<cfif form.txtFileName NEQ '' >
	<cfset recurse = 'true'/>
</cfif>

<!---<cfset form.txtFileName = Replace(form.txtFileName,'\','',"all") />--->
<cfdirectory directory="#ExpandPath("#AdjustHomePath##url.dir#/")#" action="list" name="dir" sort="#url.sort#" filter="*#form.txtFileName#*" recurse="#recurse#">
<cfparam name="maxRows" default="#dir.recordcount#">
<!---<cfif url.getFile eq 1>
	<cfset maxRows = 1 />
<cfelseif maxRows eq 0>
	<cfset maxRows = 1 />
</cfif>--->

<cfif maxRows eq 0>
	<cfset maxRows = 1 />
</cfif>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><cfoutput>#listlast(url.dir,"/")# :: [#dir.recordcount# item<cfif dir.recordcount Neq 1>s</cfif>]</cfoutput></title>
<style type="text/css">
	body,td { font-family: verdana; padding: 2px 0px 2px 0px; color:silver;  } 
	th { border-bottom: 1px solid silver;text-align:left;margin-bottom: 2px; color:black; }
	a.sort { text-decoration: none;	color: silver; }
	a:hover { background-color: #FFFF93; color: red;	} 
	p { font-size: x-small; }
	.red { text-decoration: none;	color:black; }
</style>

<SCRIPT LANGUAGE="JavaScript">
	function selectAll(thisobj)
	{
		var bCheck = thisobj.checked;
		var chObjs = document.all.SelectedITEMS;
		if(chObjs.length)
		{
			var chObjLen = chObjs.length;
			var i;
			for(i=0;i<chObjLen;i++)
			{
				chObjs[i].checked = bCheck;
			}
		}
		else
		{
			chObjs.checked = bCheck;
		}

	}
	/*function save_Documents() // IMPLEMENT THIS IN browseBBDocsGET.cfm ---
	{
		document.frmGetFile.finishedselectingitems.value = 1;
		document.frmGetFile.submit();
	}*/
</SCRIPT>
</head><!--- BFFDB5 C6FFC6--->
<body>

<cfoutput>
	<form action="#templateName#" method="post" accept-charset="utf-8" name="frmGetFile" >
		<input type="text" value="#url.txtFileName#" id="txtFileName" name="txtFileName" />
		<input type="submit" value="search" />
		<input type="hidden" value="#url.dir#" name="dir" />
		<!---<input type="hidden" value="0" name="finishedselectingitems" />--->
		<!---<input type="hidden" value="#url.sort#" name="sort" />--->
</cfoutput>
<br>
<!---<cfoutput>#currentDir#</cfoutput><br>--->
<cfset crumbPath = ''/>
<cfif ArrayLen(crumbs)>
	<cfloop array="#crumbs#" index="s" >
		<cfset crumbPath = crumbPath & '/' & s />
		<cfif s EQ ''>
			<cfoutput><a href="#templateName#?dir=#crumbPath#&txtFileName=#url.txtFileName#"> >> </a></cfoutput>
		<cfelse>
			<cfoutput><a href="#templateName#?dir=#crumbPath#&txtFileName=#url.txtFileName#">/#s# </a></cfoutput>
		</cfif>
	</cfloop>
<cfelse>
	&nbsp;
</cfif>
<table CLASS="Maintable" width="100%" cellpadding="0" cellspacing="0">
	<tr BGCOLOR="ffce84">
		<cfoutput>
			<cfset urlExtra = 'txtFileName=#url.txtFileName#&dir=#url.dir#&getfile=#url.getfile#' />
			<!---<th><input TYPE="checkbox" NAME="allbox" onclick="javaScript: selectAll(this);"></th>--->
        	<th><a href="#templateName#?sort=name%20#url.sortName#&sortName=#url.sortName#&txtFileName=#url.txtFileName#&dir=#url.dir#" class="sort" title="Sort By Name">Name 
        		<cfif url.sortName EQ 'ASC'><IMG SRC="/Images/down_1.gif" BORDER="0"><cfelseif url.sortName EQ 'DESC'><IMG SRC="/Images/up_1.gif" BORDER="0"></cfif> </a></th>
			<th><a href="#templateName#?sort=datelastmodified%20#url.sortDate#&sortDate=#url.sortDate#&txtFileName=#url.txtFileName#&dir=#url.dir#" class="sort" title="Sort By Date">Last Modified 
				<cfif url.sortDate EQ 'ASC'><IMG SRC="/Images/down_1.gif" BORDER="0"><cfelseif url.sortDate EQ 'DESC'><IMG SRC="/Images/up_1.gif" BORDER="0"></cfif></a></th>
			<th><a href="#templateName#?sort=type%20#url.sortType#&sortType=#url.sortType#&txtFileName=#url.txtFileName#&dir=#url.dir#" class="sort" title="Sort By Type">Type 
				<cfif url.sortType EQ 'ASC'><IMG SRC="/Images/down_1.gif" BORDER="0"><cfelseif url.sortType EQ 'DESC'><IMG SRC="/Images/up_1.gif" BORDER="0"></cfif></a></th>
			<th><a href="#templateName#?sort=size%20#url.sortSize#&sortSize=#url.sortSize#&txtFileName=#url.txtFileName#&dir=#url.dir#" class="sort" title="Sort By Size">Size (kb)
				<cfif url.sortSize EQ 'ASC'><IMG SRC="/Images/down_1.gif" BORDER="0"><cfelseif url.sortSize EQ 'DESC'><IMG SRC="/Images/up_1.gif" BORDER="0"></cfif></a></th>
        </cfoutput>
	</tr>
	<cfoutput query="dir" maxrows="#maxRows#"><cfif dir.name IS NOT "index.cfm"><cfset fileDir = Replace(dir.directory,webroot,'',"all") /><cfset fileDir = Replace(dir.directory,mapping,'',"all") /><cfset fileDir = Replace(fileDir,'\','/',"all") />
	<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
		<!---<td><cfif dir.type NEQ 'dir'><input TYPE="Checkbox" NAME="SelectedITEMS" VALUE="#dir.name#"><cfelse>&nbsp;</cfif></td>--->
		<td><a href="#templateName#?dir=#fileDir#/#dir.name#&txtFileName=#url.txtFileName#">#fileDir#/#dir.name#</a></td>
		<td>#dir.datelastmodified#</td>
		<td>#dir.type#</td>
		<td><cfif dir.type NEQ 'dir'>#numberformat(evaluate(dir.size/1024),'___,___,___')#<cfelse>&nbsp;</cfif></td>
	</tr></cfif>
	<!---<FONT COLOR="##ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="javascript: save_Documents();"><B>attach selected documents</B></A>
	<FONT COLOR="##ff0000" SIZE="2"><B>]</B></FONT>--->
		<cfif url.getFile eq 1>
			<CFCOOKIE name="docFileName" value="#fileDir#/#dir.name#" >
		</cfif>
	</cfoutput>
	
</table>
</form>
</body>
</html>