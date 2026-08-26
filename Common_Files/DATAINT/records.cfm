<cfparam name="url.Search" default="">
<cfparam name="url.start"  default="1">
<cfparam name="perpage" default="200">
<cfparam name="url.orderby" default="">
<cfparam name="url.ordertype" default="">
<cfparam name="url.excel" default="0" >
<cfparam name="url.upid"  default="0">
<cfquery datasource="#application.datasource#" name="qDataArchColumns">
	SELECT 	c.name as original_name, Replace(C.name, ' ', '') AS Name FROM SysObjects O INNER JOIN SysColumns C ON O.ID=C.ID
	WHERE ObjectProperty(O.ID,'IsUserTable')=1 
	AND O.Name= '<cfoutput>#url.tName#</cfoutput>'
	order by colorder
</cfquery>
<cfif #url.type# EQ "error">
	<cfquery datasource="#application.datasource#" name="qDataArch">
		SELECT top 250000
		<cfloop query="qDataArchColumns">
			<!---32737 - skipped SQL server keyword--->
			<cfoutput>[#original_name#] <cfif name neq "order">AS [#name#]</cfif></cfoutput>,
		</cfloop>
		0 AS Dummy_Column
		FROM	<cfoutput>#url.tName#</cfoutput>
		WHERE	CAST(Created_Date AS DATETIME) = <cfoutput>#url.edate#</cfoutput> 
		<cfif len(url.Search)>
			<cfset i = 1>
			<cfoutput query="qDataArchColumns">
			<cfif i EQ 1>and(<cfelseif i GT 1> or </cfif> #qDataArchColumns.original_name# like '%#trim(url.Search)#%'
			<cfset i = i + 1>
			</cfoutput>
		</cfif>
		<cfif len(url.Search)>)</cfif>
		<cfif len(url.orderby) AND len(url.ordertype)>
			Order By  #url.orderby# #url.ordertype#
		</cfif>
	</cfquery>		
	<cfelse>
		<cfquery datasource="#application.datasource#" name="qDataArch">
			SELECT	top 250000
			<cfloop query="qDataArchColumns">
				<!---32737 - skipped SQL server keyword--->
				<cfoutput>[#original_name#] <cfif name neq "order">AS [#name#]</cfif></cfoutput>,
			</cfloop>
			0 AS Dummy_Column
			FROM	<cfoutput>#url.tName#</cfoutput>
			WHERE	Data_integration_Upload_ID = '<cfoutput>#url.upid#</cfoutput>'
			<cfif len(url.Search)>
				<cfset i = 1>
				<cfoutput query="qDataArchColumns">
				<cfif i EQ 1>and(<cfelseif i GT 1> or </cfif> [#qDataArchColumns.original_name#] like '%#trim(url.Search)#%'
				<cfset i = i + 1>
				</cfoutput>
			</cfif>
			<cfif len(url.Search)>)</cfif>
			<cfif len(url.orderby) AND len(url.ordertype)>
				Order By  #url.orderby# #url.ordertype#
			</cfif>
		</cfquery>		
	</cfif>
	<cfif url.excel EQ 0>
		<cfset width = #qDataArchColumns.recordcount# *240>
		<cfoutput>
		<div style="width:#width#px; background-color:white;position:fixed;">
			<table border="0">
				<tr>
					<td width="25">
						<cfif url.start gt 1>
							<a href="#ajaxLink('#cgi.script_name#?upid=#url.upid#&type=#url.type#&start=#url.start-perpage#&Search=#url.Search#&tName=#url.tName#&edate=#url.edate#&orderby=#url.orderby#&ordertype=#url.ordertype#')#" onclick="loading();"><img src="/images/previous.png" border="0"></a>
						<cfelse>
							<img src="/images/previous_inactive.png" border="0">
						</cfif>
					</td>
					<td align="left">
						<cfif (url.start+perpage-1) lt qDataArch.recordcount>
							<a href="#ajaxLink('#cgi.script_name#?upid=#url.upid#&type=#url.type#&start=#url.start+perpage#&Search=#url.Search#&tName=#url.tName#&edate=#url.edate#&orderby=#url.orderby#&ordertype=#url.ordertype#')#" onclick="loading();"><img src="/images/next.png" border="0"></a>
						<cfelse>
							<img src="/images/next_inactive.png" border="0">
						</cfif>
					</td>
				</tr>
			</table>
			<table border="0" width="800">
				<tr>
					<td colspan="100" width="800" style="font-size:12px;color:green;">
						<cfset to = (#url.start#+#perpage#) - 1>
						Showing #url.start# to <cfif qDataArch.recordcount GT 200> #to#<cfelse>#qDataArch.recordcount#</cfif> of #qDataArch.recordcount# entries.  <cfif #qDataArch.recordcount# GTE 250000><span style="font-size:12px;color:red;">[ONLY THE TOP 250,000 ROWS OF DATA HAVE BEEN RETURNED]</span></cfif>
					</td>
				</tr>
			</table>
		</div>
		</cfoutput>
		<style>
	.header{
		border:solid;
		border-width:1px;
		border-color:white;
		font-size:12px;
		font-weight:bold;
		width:238px;
		text-align:center;
		background-color:#A5BAFF;
		float:left;
		}
	.data{
		border:solid;
		border-width:1px;
		border-color:white;
		font-size:12px;
		width:238px;
		text-align:center;
		float:left;
		}
		</style>
		<div style="width:#width#px;clear:both;height:45px;">&nbsp;</div>
		<div style="width:1000px;height:500px;overflow:scroll;">
			<cfoutput>
			<div style="width:#width#px;">
				<cfloop query="qDataArchColumns">
					<div class="header">
						<div style="float:left; width:80%; text-align:center;padding-top:3px;">
							#replace(ucase(qDataArchColumns.Name),"_"," ", "ALL")#
						</div>
						<div style="float:right;">
							<table border=0 align="right">
								<tr>
									<td valign="bottom">
										<cfif (url.orderby EQ #qDataArchColumns.Name#) AND (url.ordertype EQ 'asc')>
											<img src="/images/asc_inactive.png" border="0">
										<cfelse>
											<a href="#ajaxLink('#cgi.script_name#?upid=#url.upid#&type=#url.type#&start=#url.start#&Search=#url.Search#&orderby=#qDataArchColumns.Name#&ordertype=asc&tName=#url.tName#&edate=#url.edate#')#" onclick="loading();"><img src="/images/asc.png" border="0"></a>	
										</cfif>
									</td>
									<td valign="top">
										<cfif (url.orderby EQ #qDataArchColumns.Name#) AND (url.ordertype EQ 'desc')>
											<img src="/images/desc_inactive.png" border="0">
										<cfelse>
											<a href="#ajaxLink('#cgi.script_name#?upid=#url.upid#&type=#url.type#&start=#url.start#&Search=#url.Search#&orderby=#qDataArchColumns.Name#&ordertype=desc&tName=#url.tName#&edate=#url.edate#')#" onclick="loading();"><img src="/images/desc.png" border="0"></a>
										</cfif>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</cfloop>
			</div>
			</cfoutput>	
			<cfif qDataArch.recordcount>
				<cfoutput query="qDataArch" startrow="#url.start#" maxrows="#min(200, qDataArch.recordcount)#">
				<div style="width:#width#px;clear:both;">
					<cfloop query="qDataArchColumns">
						<cfset data = evaluate("qDataArch.#Name#")>
						<cfif len(url.Search) AND findnocase(trim(url.Search),data)>
							<cfset color =	"yellow">
						<cfelse>
							<cfset color = 	"white">
						</cfif>
						<div class="data"style="background-color:#color#;">&nbsp;#trim(data)#&nbsp;</div>
					</cfloop>
				</div>
				</cfoutput>
			<cfelse>
				<div style="width:#width#px;">No Records!!</div>
			</cfif>
		</div>
	<cfelse>
		<CFIF qDataArch.recordcount  LT 65535>
			<cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init("report.xls") />
			<cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
			<!--- Create a new Worksheet and name it --->
			<cfset newSheet = workBook.createSheet() />
			<cfset workBook.setSheetName(0, "Report") />
			<!--- Creates the default Font --->
			<cfset f = workBook.createFont() />
			<cfset cs = workBook.createCellStyle() />
			<cfset cswrap = workBook.createCellStyle() />
			<cfif isDefined("f.BOLDWEIGHT_BOLD")> <cfset f.setBoldweight(f.BOLDWEIGHT_BOLD)> <cfelse> <cfset f.setBold(true)> </cfif>
			<cfset cs.setFont(f) />
			<cfset cswrap.setFont(f) />
			<cfset cswrap.setWrapText(true) />
			<!--- Create a row and the Header cell --->
			<cfset row1 = newSheet.createRow(0) />
			<cfset i = 0>   
			<cfoutput query="qDataArchColumns">
			<cfset cell = row1.createCell(#i#) />
			<cfset cell.setCellValue(#original_name#) />
			<cfset i = i + 1>
			</cfoutput>
			<cfset i = 0>
			<cfoutput query="qDataArch">
			<cfset row2 = newSheet.createRow(#currentRow#) />
			<cfset z = 0 >
			<cfloop query="qDataArchColumns">
				<cfset data = evaluate("qDataArch.#replace(original_name,' ','','ALL')#")>
				<cfset row2.createCell(#z#).setCellValue(#JavaCast("string",data)#) />
				<!---
				<cfset row2.createCell(#z#).setCellValue(#data#) />
				--->
				<cfset z = z + 1>
			</cfloop>
			<cfset i = i + 1>
			</cfoutput>             
			<cfset workBook.write(variables.fileOutStream) />
			<cfset variables.fileOutStream.flush() /> 
			<cfset variables.fileOutStream.close() /> 
			<cfheader name="Content-Disposition" value="attachment;filename=report.xls"  />
			<cfcontent type="application/vnd.ms-excel" file="report.xls" deletefile="true"  />
		<CFELSE>
			<!--- 
			<CFIF qDataArch.recordcount  LT 65535>
			--->
			<cfset currentPath = getCurrentTemplatePath()>
			<cfset currentDirectory = getDirectoryFromPath(currentPath)>
			<cfset DocumentPath = ReplaceNoCase(currentDirectory, "Common_Files\DATAINT\", "common_documents")>
			<CFSET nextline=chr(10)>
			<cfsavecontent variable = "xl">
			<cfoutput query="qDataArchColumns">"#original_name#",</cfoutput><cfoutput>#nextline#</cfoutput>
			<cfoutput query="qDataArch">
			<cfloop query="qDataArchColumns"><cfset data = evaluate("qDataArch.#original_name#")>"#data#",</cfloop>
			#nextline#
			</cfoutput>
			</cfsavecontent> 
			<CFOUTPUT>
			<cffile action="write" file ="#DocumentPath#\Temp_Files\DataInt\DataIntegrationViewer_#request.AccessStructure.User_ID#.csv" output = #xl#>
			<CFLOCATION URL="/common_documents/Temp_Files/DataInt/DataIntegrationViewer_#request.AccessStructure.User_ID#.csv" ADDTOKEN="No">
			</CFOUTPUT>
		</CFIF>
		<!--- 
		<CFIF qDataArch.recordcount  LT 65535>
		--->
	</cfif>
	<script>
		document.getElementById("loading").style.display = "none";
	</script>
