<!----
	Filename:	C:\Work\Code\base\AwayX\common_files\contracts\bid_request\group_won_lost_info.cfm
	Created:	8/3/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description: USED TO MAKE DISPLAY  STATUS OF ITEMS OF GROUP ITEMS
	LABEL:  D33201: Competitive Data-Incorrectly Marks Products as Won
---->
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
	<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
	<TR>
		<TD ALIGN="left" bgcolor="#A7CAF2" WIDTH="100%" HEIGHT="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;">
			<SPAN STYLE="color:white; font-size:14px; font-weight: bold; padding-left:5px;">Group: &nbsp; <cfoutput>#trim(url.groupname)#</cfoutput></SPAN>
		</TD>
	</TR>
	</TABLE>
<cfoutput>
	<br />
	<table class="datagrid">
	  <thead>
	    <th class="header" width="100"><b>Item</b></th>
	    <th class="header" width="420"><b>Description</b></th>
	    <th class="header" width="80"><b>#application.returned_customer_setting.type_code_label_singular# </b></th>
	    <th class="header" width="225"><b>#application.returned_customer_setting.type_code_label_singular# Description</b></th>
    	<th class="header" width="75"><b>Status</b></th>
	  </thead>
	  <tbody>
	  </tbody>
	</table>
	
	<cfinclude template="/Common_Files/jQuery.cfm">
	<cfinclude template="/Common_Files/dataTables.cfm">
	<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
	<script type="text/javascript" src="/Script/javascript/FixedHeader.min.js"></script>
		
	<script>
	oTable = $('.datagrid').dataTable( {
	      "bServerSide": true
	    , "bProcessing": true
	    , "bSortClasses": false
		, "bAutoWidth": false
	    , "iDisplayLength": 20
	    , "oLanguage": {"sSearch": "<b>Search:</b>"} 
	    , "sAjaxSource": "ajax/ItemWonLost_Query.cfm?groupId=#url.groupId#&Contract_Main_ID=#url.Contract_Main_ID#&groupname=#url.groupname#"
	    , "sDom": "fprti"
	    , "aaSorting": []
	    , "aoColumns": [  {"bSearchable": true,  "bSortable":true}
		                    ,	{"bSearchable": true, 	"bSortable":true}
		                    ,	{"bSearchable": true, 	"bSortable":true}
		                     ,	{"bSearchable": true, 	"bSortable":true}
		                    ,	{"bSearchable": false, 	"bSortable":true}
		                 ]
	} ).fnSetFilteringDelay();
	function won(groupid,contractid, groupname){
    		window.location.href = "group_won_lost_info.cfm?groupid="+groupid+"&Contract_Main_ID="+contractid+"&groupname="+groupname;
	}
	function lost (groupid,contractid, groupname){ 
			window.location.href = "group_won_lost_info.cfm?groupid="+groupid+"&Contract_Main_ID="+contractid+"&groupname="+groupname;
	}
	function pending (groupid,contractid, groupname){ 
			window.location.href = "group_won_lost_info.cfm?groupid="+groupid+"&Contract_Main_ID="+contractid+"&groupname="+groupname;
	}	
	</script>
		</cfoutput>