<!-----
Program_Search_Data_Refresh_Log.cfm
------->

<CFPARAM NAME="form.startrow" DEFAULT="1">
<CFPARAM NAME="form.frompage" DEFAULT="1">

<SCRIPT SRC="/script/javascript/prototype/prototype.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<script language="javascript">
	function showLoader()
	{
		$('loader').style.display = "";
	}
	function hideLoader()
	{
		$('loader').style.display = "none";		
	}
		
	function getProgramList(passId)
	{
		showLoader();
		
		new Ajax.Updater('divProgramList', 'Program_Search_Data_Refresh_Log_Programs.cfm', {
				parameters: {id: passId},
				onComplete:programnListComplete
				});
	}
	
	function programnListComplete()
	{
		hideLoader();
		openDivWindow();
	}
	
	function doSearch()
	{
		showLoader();
		
		var sDate = $F('search_date');
		var ifrompage = $F('frompage');
		var istartrow = $F('startrow');
		var ipage_len = $F('page_len');
		
		new Ajax.Updater('AJAXTarget', 'Program_Search_Data_Refresh_Log_inc.cfm', {
				parameters: {search_date: sDate, frompage: ifrompage, startrow: istartrow, page_len: ipage_len},
				onComplete:hideLoader
				});
	}
	
</script>
<br>

<div id="loader" style="float:left;display:none;width:18px;position:absolute;">
	<img src="/images/ajax-loader-small-red.gif" border="0" />
</div>
<br />

<form name="SearchForm">
<input type="hidden" name="frompage" value="#form.frompage#">
<input type="hidden" name="startrow" value="#form.startrow#">			
<table cellpadding="5" cellspacing="0">
<tr>
<td>
	<strong>Date</strong>
<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="search_date" FORMAT="mm/dd/yyyy" DEFAULT="">

</td>
<td>
<strong>Records per page</strong><br>
<select name="page_len">
	<option value="10">10</option>
	<option value="50" selected>50</option>
	<option value="100">100</option>
</select>
</td>
<td> &nbsp;<br>
&nbsp;&nbsp;&nbsp;
<CF_smallLink 
	title = "search" 
	url = "##"
	parameters = "onClick=""javascript: doSearch();return false;"""
>
</td>
</tr>
</table>
</form>

<div id="AJAXTarget">
<cfinclude template="Program_Search_Data_Refresh_Log_inc.cfm">
</table>
</div>

<cfmodule
		template="/customtags/displayLayer.cfm"
		layerName="divProgramListLayer"
		width="600"
		height="400"
		overflow="auto"
		bgColor="ffffff"
		scroll="1"
		display="0"
		>
		<table cellpadding="0" cellspacing="0" width="600">
			<tr>
				<td width="33%">&nbsp;
				</td>
				<td width="34%" align="center" style="font-weight:bold;font-size:14px;">Programs</td>
				<td width="33%" align="center">
				<CF_smallLink 
					title = "close" 
					url = "##"
					parameters = "onClick=""javascript: closeDivWindow();return false;"""
				>
				</td>
			</tr>
		</table>
		<br>	
		<div id="divProgramList">
		</div>
</cfmodule>


<script language="javascript">
	
	function navigate(frompage, startrow)
	{	
		document.SearchForm.startrow.value = startrow;
		document.SearchForm.frompage.value = frompage;
		doSearch();		
	}
	
</script>