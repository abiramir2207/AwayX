<!---
       Name:          upload_detail2.cfm
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  11367
       Description:
--->
<cfparam name="url.upload_id" default="-2">
<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
<cfset getUploads = uploadUtility.getUploadLog(url.upload_id) />
<cfset getUploadHeader = uploadUtility.getUploadHeaderLog(url.upload_id)/>
<cfset getUploadDetail = uploadUtility.getUploadDetailLog(url.upload_id)/>
<cfparam name="printable" default="0">
<cfinclude template="header.cfm" />
<!--- <cfif printable EQ 1>
	<cfinclude template="header.cfm">
</cfif> --->

<cfset lblStyle = "font-weight:bold" />

<cfoutput>
	<br>
	<span class="subheading" style="padding-right:550px;">
		Upload Detail: #url.upload_id#
	</span>

	<!--- DEV NOTE: DAA D16381 --->
	<FONT COLOR="Red">[&nbsp;</FONT><a href="##" onclick="javascript:PopupCenter('downloadReport.cfm?upload_ID=#url.upload_id#','Download','450','200');" title="Download Header and Detail errors listed below as a csv file "> <b>Download Error Report</b> </a><FONT COLOR="Red">&nbsp;]</FONT>
	<cfif not isDefined("URL.printable")>
		<FONT COLOR="Red">[&nbsp;</FONT>
		<a href="upload_detail2.cfm?upload_id=#url.upload_id#&printable=1" target="winBillbackPrntPrvw">
			<img src="/images/printimg.gif"> <B>printer friendly</B>
		</a>
		<FONT COLOR="Red">&nbsp;]</FONT>
	</cfif>
</cfoutput>
<br><br>
<script type="text/javascript" language="javascript">
	function highlight(thisObj,state)
	{
		if(state == 1)
			thisObj.style.backgroundColor = "#C8E6FF";
		else
			thisObj.style.backgroundColor = "transparent";
	}
	
	function PopupCenter(url, title, w, h) 
	{
	    // Fixes dual-screen position                         Most browsers      Firefox
	    var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left;
	    var dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top;
	
	    width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
	    height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;
	
	    var left = ((width / 2) - (w / 2)) + dualScreenLeft;
	    var top = ((height / 2) - (h / 2)) + dualScreenTop;
	    var newWindow = window.open(url, title, 'location=1,status=1,scrollbars=1,resizable=1, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);
		// window.open('','','width=450,height=200,location=1,status=1,scrollbars=1,resizable=1,top='+ top +',left=' + left);return false;">
	    // Puts focus on the newWindow
	    if (window.focus) {
	        newWindow.focus();
	    }
	}	
</script>

<div id="mainContent">
	<table border="1" width="800px">
		<cfoutput query="getUploads">
			<thead><tr><th colspan="100%" >UPLOAD REPORT: #url.upload_id#</th></tr>
			<tr>
				<td width="90px;">Uploaded By</td>
				<td width="90px;">Type</td>
				<td width="90px;">Upload Date</td>
				<td width="90px;">Total Header Count</td>
				<td width="90px;">Total Header Count Failed</td>
				<td width="100px;">Total Header Count Success</td>
				<td width="90px;">Total Detail Count</td>
				<td width="90px;">Total Detail Count Failed</td>
				<td width="100px;">Total Detail Count Success</td>
				<td width="170px;">Status</td>
			</tr>
			</thead>
			<tbody>
			<tr>
				<td>#user_code#</td>
				<td>#upload_type#</td>
				<td>#dateformat(upload_date,'MM/DD/YYYY')# #timeformat(upload_date,'HH:MM')#</td>
				<td>#total_header_count#</td>
				<td>#total_header_count_failed#</td>
				<td>#total_header_count_loaded#</td>
				<td>#total_detail_count#</td>
				<td>#total_detail_count_failed#</td>
				<td>#total_detail_count_loaded#</td>
				<td>#upload_status#</td>
			</tr>
			<tr><td colspan="2">Header File</td><td colspan="100%">#header_file_name# *</td></tr>
			<tr><td colspan="2">Detail File</td><td colspan="100%">#detail_file_name# *</td></tr>
			<tr><td colspan="100%">* duplicate filenames may have numbers added to the filename to make them unique.</tr>
			</tbody>
		</cfoutput>
	</table>
<br>
	<div id="header_data" <!--- DEV NOTE: DAA D16381 style="display:none"--->>
		<table border="1" width="800px">
			<thead><tr><th colspan="100%">HEADER FILE ERROR REPORT</th></tr>
			<tr><TD>Vendor</TD>	<TD>Customer Reference</TD><TD>Total Amount</TD><TD>Volume Qty</TD><TD>Payee Type</TD><TD>Distributor ID</TD><TD>Operator ID</TD><TD>Billback Title</TD><TD>Closing Method</TD><TD>Billback Date</TD><TD>Receipt Date</TD><TD>BB Start Date</TD><TD>BB End Date</TD><TD>Postmark Date</TD><TD>Reference Number</TD></tr></thead>
			<tbody>
			<cfif getUploadHeader.RecordCount EQ 0>
				<tr><td style="padding-left:5px;" colspan="100%">The header interface file did not contain any header errors.</td></tr>
			<cfelse>
				<cfoutput query="getUploadHeader">
					<tr>
						<td rowspan="2" <cfif findnocase("H1#chr(8211)#",err_msg)>class="error"</cfif> >#Vendor#</td>
						<td <cfif findnocase(",H2",err_msg)>class="error"</cfif> >#Customer_Reference#</td>
						<td <cfif findnocase(",H3",err_msg)>class="error"</cfif> >#Total_Amount#</td>
						<td <cfif findnocase(",H4",err_msg)>class="error"</cfif> >#Volume_Qty#</td>
						<td <cfif findnocase(",H6",err_msg)>class="error"</cfif> >#Payee_Type#</td>
						<td <cfif findnocase(",H7",err_msg)>class="error"</cfif> >#Distributor_ID#</td>
						<td <cfif findnocase(",H8",err_msg)>class="error"</cfif> >#Operator_ID#</td>
						<td <cfif findnocase(",H9",err_msg)>class="error"</cfif> >#Billback_Title#</td>
						<td <cfif findnocase(",H10",err_msg)>class="error"</cfif> >#Closing_Method#</td>
						<td <cfif findnocase(",H11",err_msg)>class="error"</cfif> >#Billback_Date#</td>
						<td <cfif findnocase(",H12",err_msg)>class="error"</cfif> >#Receipt_Date#</td>
						<td <cfif findnocase(",H13",err_msg)>class="error"</cfif> >#BB_Start_Date#</td>
						<td <cfif findnocase(",H14",err_msg)>class="error"</cfif> >#BB_End_Date#</td>
						<td <cfif findnocase(",H15",err_msg) >class="error"</cfif> >#Postmark_Date#</td>
						<td <cfif findnocase(",H18",err_msg) or findnocase(",H17",err_msg)>class="error"</cfif> >#Reference_Num#</td>
					</tr>
					<tr>
					<td style="max-width:775px;width=775px;padding-left:5px;" colspan="100%">
						<cfif len(getUploadHeader.err_msg) LT 15>This header row did not contain any errors.
						<cfelse><cfloop list="#getUploadHeader.err_msg#" index="message">#message#</br></cfloop>
					</cfif>
					</td>
					</tr>
				</cfoutput>
			</cfif>
			</tbody>
		</table>
	</div>
<br>
	<div id="detail_data" <!--- DEV NOTE: DAA D16381 style="display:none"--->>
		<table border="1" width="800px">
			<thead><tr><th colspan="100%">DETAIL FILE ERROR REPORT</th></tr>
				<tr>
					<td>Vendor</td>
					<td>Customer Reference</td>
					<td>Item Number</td>
					<td>Program Number</td>
					<td>Item Qty</td>
					<td>Amount</td>
					<td>Discount Type</td>
					<td>Component Name</td>
					<td>Distributor ID</td>
					<td>Operator ID</td>
				</tr>
			</thead>
			<tbody>
			<cfif getUploadDetail.RecordCount EQ 0>
					<tr><td style="padding-left:5px;" colspan="100%">The detail interface file did not contain any detail errors.</td></tr>
			<cfelse>
				<cfoutput query="getUploadDetail">
					<tr>
						<TD rowspan="2" <cfif findnocase("D1#chr(8211)#",err_msg)>class="error"</cfif> >#Vendor#</TD>
						<TD <cfif findnocase("D2",err_msg)>class="error"</cfif> >#Customer_Reference#</TD>
						<td <cfif findnocase("D4",err_msg)>class="error"</cfif> >#Item_Number#</td>
						<td <cfif findnocase("D5",err_msg)>class="error"</cfif> >#Program_Number#</td>
						<td <cfif findnocase("D6",err_msg) or findnocase("D7",err_msg)>class="error"</cfif> >#Item_Vol_Qty#</td>
						<td <cfif findnocase("D8",err_msg) or findnocase("D7",err_msg)>class="error"</cfif> >#Item_Amount#</td>
						<td <cfif findnocase("D9",err_msg)>class="error"</cfif> >#Discount_Type#</td>
						<td <cfif findnocase("D10",err_msg)>class="error"</cfif> >#Component_Name#</td>
						<td <cfif findnocase("D13",err_msg) or findnocase("D15",err_msg)>class="error"</cfif> >#Distributor_ID#</td>
						<td <cfif findnocase("D5-A",err_msg)>class="error"</cfif> >#Operator_Legacy_ID#</td>
					</tr>
					<tr>
						<td colspan="100%" style="max-width:775px;width=775px;padding-left:5px;">
						<cfif len(getUploadDetail.err_msg) LT 15>This detail row did not contain any errors.
						<cfelse><cfloop list="#getUploadDetail.err_msg#" index="message">#message#</br></cfloop>
						</cfif>
						</td>
					</tr>
				</cfoutput>
			</cfif>
			</tbody>
		</table>
	</div>

</div>

<!--- End MainContent --->
<!--- DEV NOTE: DAA D16381
<script language="javascript" type="text/javascript">
	document.all.detail_data.style.display = "block";
	document.all.header_data.style.display = "block";
</script>
 --->
