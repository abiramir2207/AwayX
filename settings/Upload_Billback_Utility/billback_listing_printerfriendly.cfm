<!---  
       Name:          billback_listing_printerfriendly.cfm           
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  11367
       Description:   
--->
<cfsilent>
<cfparam name="url.upload_id" default="0">
<cfparam name="url.upload_type_id" default="0">
<cfset qRelatedBBs = StructNew()>
<cfset placeholder = StructInsert(qRelatedBBs,"recordcount","0")>
<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
<cfif url.upload_id NEQ 0 AND url.upload_type_id NEQ 0> 	
	<cfset qRelatedBBs =  uploadUtility.getRelatedBB(url.upload_id,URL.upload_type_id) /> 
</cfif>
</cfsilent>

<html>
<head>
<style type="text/css">
	 #markup {margin:.25em;}   
	 #markup table {border-collapse:collapse;border:1px solid RGB(0,0,0);}   
	 #markup tbody td {border:1px solid RGB(210,210,210);padding:3px;color:black;}   
	 #markup thead th {border:1px solid RGB(224,205,70);font-size:11px;color:black;font-weight:bold;background-color:RGB(255,224,131);text-align:center;vertical-align:bottom;padding:2px;color:black}
	 #markup thead th a {color:RGB(0,0,0);} 
 	 thead {display: table-header-group;}
 	 .subheading
	 {
		font-weight:bold;
		font-size:12px;
		text-decoration:underline;
	 }
</style>


</head>
<body>

<!--- Sub Section Title--->
<cfoutput>
	<br><span class="subheading">Billbacks Created By Batch No: #url.upload_id#</span><br><br>
</cfoutput>

	<div id="markup">
		<table>
			<thead>
				<tr><th colspan="100%">Billbacks Created By Batch No: <cfoutput>#url.upload_id#</cfoutput></th></tr>
				<tr><th>Billback</th><th>Title</th><th>Reference</th><th>Cases</th><th>Amount</th><th>Date</th><th>Vendor</th></tr>
			</thead>
			<tbody>
				<cfif qRelatedBBs.recordcount NEQ 0>
					<cfoutput query="qRelatedBBs">
						<tr>
						<td><a href="##" title="#JSSTRINGFORMAT(bb_code)#" target="_blank" onclick="browse('#JSSTRINGFORMAT(billback_id)#')">#bb_code#</td>
						<td>#bb_title#</td>
						<td>#bb_reference#</td>
						<td>#claim_cases#</td>
						<td>#bb_amount#</td>
						<td>#dateformat(bb_date,'MM/DD/YYYY')#</td>
						<td>#vendor_id#</td>
						</tr>
					</cfoutput>
				<cfelse>
					<tr><td colspan="100%">There are no related billbacks.</td></tr>
				</cfif>
			</tbody>
		</table>
	</div>
</body>
</html>