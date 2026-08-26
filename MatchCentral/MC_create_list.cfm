<cfif url.searchType EQ 'DD'>
	<cfset pagetitle = "Deductions">
<cfelseif url.searchType EQ 'BB'>
	<cfset pagetitle = "Billbacks">
<cfelseif url.searchType EQ 'CR'>
	<cfset pagetitle = "Credits">
</cfif>

<style>
.page_title1 {
	background: #A7CAF2 url(/Images/gradient.jpg) no-repeat;
	color: white;
	font-size: 14px;
	font-weight: bold;
	letter-spacing: 0.75px;
	margin: 0 0 9px 0;
	padding: 8px 0 8px 8px;
	width: 99.5%;
}
</style>
<!---Displays the page title set above--->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<cfinclude template="/common_files/jQuery.cfm">
	<FORM action="" METHOD="post" NAME="mcCreateListForm" ID="mcCreateListForm">
		<!--- test area to enter the items needed --->
		<table ALIGN="center" CELLPADDING="5" CELLSPACING="">
			<tr>
				<td>
					<textarea ID="ddlist" NAME="ddlist"  ROWS="10" COLS="30" STYLE="width:250"></textarea>
				</td>
			</tr>

			<tr>
				<td ALIGN="center" style="font-size: 14px;font-weight: normal;">
					<CF_smallLink title = "search" url = "javascript:search('#searchType#');">
				</td>
			</tr>


		</table>
	  	<input type="hidden" name="passedItemList" id="passedItemList" value="" >
   		<input type="hidden" name="passedPrgList" id="passedPrgList" value="" >
	</FORM>

<script>
	function search(typ){ 
		<cfif (url.searchType EQ 'DD' OR url.searchType EQ 'CR')>
			window.opener.document.all.createList.value = $('#ddlist').val();
			window.opener.document.all.ddnum.value = $('#ddlist').val();
			window.opener.DoWorkListSearch(<cfoutput>'#url.searchType#'</cfoutput>);
		<cfelseif url.searchType EQ 'BB'>
			//window.opener.document.all.bb_code.value = $('#ddlist').val(); 
			/* old code below was added by Dinesh for WR 83973, but this fix is not working for Deduction CreateList */
			window.opener.document.all.MC_CreateList.value = $('#ddlist').val();
			window.opener.setItemListFilters(<cfoutput>'#url.searchType#','#url.workItem#','#url.DistID#'</cfoutput>);
		</cfif>
		window.close();
	}
</script>