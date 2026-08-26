<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><cfoutput>#t# :: </cfoutput><cfif type is "error">Error Log Viewer<cfelse>Archive Data Viewer</cfif></title>

</head>
<body>
<script>
	function loading(){
		document.getElementById("loading").style.display = "block";
	}
	function loadingxl(){
		document.getElementById("loadingxl").style.display = "block";
		setTimeout("hidexl()", 5000);
	}
	function hidexl(){
		document.getElementById("loadingxl").style.display = "none";
	}
</script>

<cfparam name="url.summary" 		default="0" >

<cfset z = rd & ' ' & rt>
<CFSET eDate = CreateDateTime(DatePart("yyyy", z), DatePart("m", z), DatePart("d", z),DatePart("h", z),DatePart("n", z), DatePart("s", z))>
<CFSET eDate = CreateODBCDateTime(eDate)>
<cfset AM_or_PM = Right(rt,2)>
<cfoutput>
<div style="position: fixed;top:0;left:0;width:100%;background-color:##EEEEEE;color:Navy;font-size: 14px; padding:5px;">

							<cfif type is "error">
									Rejected Time:
							<cfelse>
									Upload Time:
							</cfif>&nbsp;
							#dateFormat(eDate,"ddd. mmmm d, yyyy")#&nbsp;
							#TimeFormat(eDate, "hh:mm tt")#&nbsp;&nbsp;&nbsp;

							<cfset datetime = #dateFormat(eDate,"yyyy-mm-dd")# &' '&#TimeFormat(eDate, "hh:mm:ss.lll")#>

<cfif url.summary EQ 0>
				 ::&nbsp;&nbsp;&nbsp;
<FONT COLOR="##FF0000"><B>[ </B></FONT>
		<a STYLE="COLOR:##0000FF;" href="records.cfm?tName=#url.tName#&upid=#url.upid#&excel=1&type=#url.type#&edate=#urlencodedformat(edate)#" onclick="loadingxl();">
			Create XL file
		</a>
<FONT COLOR="##FF0000"><B> ]</B></FONT>

		<cfif #url.type# EQ "error" and url.from EQ 'invoice'>
			<FONT COLOR="##FF0000"><B>[ </B></FONT>
					<a STYLE="COLOR:##0000FF;"  href="javascript:(void);" onClick="javascript:window.open('ViewHistory.cfm?date=#dateFormat(eDate, 'yyyy-mm-dd')#&from=#url.from#&summary=1&tName=#url.tName#&upid=#url.upid#&type=error&rt=#url.rt#&rd=#url.rd#&t=#url.t#&AM_or_PM=#AM_or_PM#','viewSummaryHist','toolbar=no,width=1010,height=660,location=no,menubar=no,resizable=no,scrollbars=no');return false">
						View summary of rejected #lcase(url.from)#s
					</a>
			<FONT COLOR="##FF0000"><B> ]</B></FONT>
		</cfif>
</cfif>

</div>
<br>

<div style="position: fixed;top:100;left:0;width:100%;background-color:white;font-size: 14px;font-weight:bold; padding:5px;">
	<form name="userssearch" method="post">
<cfif url.summary EQ 0>
		<div style="float:left; width:400px; margin-top:0px;">Search: <input name="Search" value=""  type="text" id="Search" onkeyup="Delay();"></div>
<cfelse>
		<div style="margin-top:-40px;"></div>
</cfif>

		<div id="loading" style="float:left; width:200px;height:50px; margin-top:0px; text-align:center;">

				<table align="center">
					<tr>
						<td><img src="/images/ajax-loader_red.gif" border="0" width="20" height="20"></td>
						<td style="font-weight:normal;color:gray;font-size:14px;"> Processing...</td>
					</tr>
				</table>

		</div>

		<div id="loadingxl" style="float:left; width:400px;height:50px; margin-top:0px; text-align:center;font-weight:normal;color:gray; display:none;">

				<table align="center" >
					<tr>
						<td><img src="/images/ajax-loader_red.gif" border="0" width="20" height="20"></td>
						<td style="font-weight:normal;color:gray;font-size:14px;"> Converting data into Excel...</td>
					</tr>
				</table>

		</div>

				<input type="hidden" name="tName" value="#url.tName#" id="tName"><br>
				<input type="hidden" name="upid" value="#url.upid#" id="upid"><br>
				<input type="hidden" name="type" value="#url.type#" id="type"><br>
				<input type="hidden" name="eDate" value="#eDate#">
				<input type="hidden" name="AM_or_PM" value="#AM_or_PM#">
		<cfif #url.type# EQ "error">
				<input type="hidden" name="from" value="#url.from#">
				<input type="hidden" name="date" value="#datetime#">
		</cfif>
	</form>
</div>
</cfoutput>
<br><br>

<script>
<cfoutput>
function Delay()
{
	setTimeout("updatesearch()", 500);
}
function updatesearch() {
	var tName = document.getElementById("tName").value;
	var upid  = document.getElementById("upid").value;
	var type  = document.getElementById("type").value;
	var searchvalue = document.getElementById("Search").value;
	document.getElementById("loading").style.display = "block";
			ColdFusion.navigate('records.cfm?tName='+tName+'&upid='+upid+'&type='+type+'&search='+escape(searchvalue)+'&eDate=#urlencodedformat(eDate)#','info');
}
</cfoutput>
</script>
<cfif url.summary EQ 0>
		<cfdiv id="info" bind="url:records.cfm?tName={tName}&upid={upid}&type={type}&eDate={eDate}"/>
<cfelse>
		<cfdiv id="info" bind="url:recordsSummary.cfm?from={from}&tName={tName}&type={type}&datetime={date}&AM_or_PM={AM_or_PM}"/>
</cfif>

</body>
</html>