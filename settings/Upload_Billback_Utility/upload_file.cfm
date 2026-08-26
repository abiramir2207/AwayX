<cfsilent>
<!---
       Name:          upload_file.cfm
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  11367
       Description:
--->
	<cfinvoke component="components.billback.billbackuploadutility" method="isvalidating" returnvariable="r">
		<cfinvokeargument name="userid" value="#request.accessstructure.user_id#">
	</cfinvoke>

    <cfscript>
	    oBillbackUpload = createObject("component", "components.billback.BillbackUploadUtility");
	    qGetBillbackUploadSettings = oBillbackUpload.getBillbackUploadSettings();

        blockedExtForFileUpload = application.util.query.get_Setting("blockedExtForFileUpload", 0);
        blockedExtForFileUpload = listToArray( trim(blockedExtForFileUpload) eq ''
                                        ? 'cfm,cfml,cfc,js,bat,com,exe,ps1,sql'
                                        : blockedExtForFileUpload );
    </cfscript>
</cfsilent>

<cfsavecontent variable="_upload_file">
	<SCRIPT>
		function submitForm(submitter)
		{
			var thisForm = document.all.uploadFiles;
        <cfif (appSettings.getBillbackFileUploadType() EQ 2)>
			var detailFiles = thisForm.header_file;
			var headerFiles = thisForm.detail_file;
		<cfelseif (appSettings.getBillbackFileUploadType() EQ 1 OR appSettings.getBillbackFileUploadType() EQ 3)>
			var singleFile	= thisForm.single_file;
		</cfif>
		/* //D29947 Update billback upload for SO/DC START */
		<cfif appSettings.getBillback_Upload_Business_Segment()>
			var x=document.getElementById("bsegment").selectedIndex;
			var segment = document.getElementsByTagName("option")[x].value;
		</cfif>
		/* //D29947 Update billback upload for SO/DC END */
			var errors = 0;

			<cfif (appSettings.getBillbackFileUploadType() EQ 2)>
				if(detailFiles.value.length == 0)
				{
					setErrorFlag(document.all.err_header_file);
					errors++;
				}
				if(headerFiles.value.length == 0)
				{
					setErrorFlag(document.all.err_detail_file);
					errors++;
				}
			<cfelseif (appSettings.getBillbackFileUploadType() EQ 1 OR appSettings.getBillbackFileUploadType() EQ 3)>
				if(singleFile.value.length == 0)
				{
					setErrorFlag(document.all.err_single_file);
					errors++;
				}
			</cfif>
		/* //D29947 Update billback upload for SO/DC START */
		<cfif appSettings.getBillback_Upload_Business_Segment()>
			if(segment == 0)
			{
				setErrorFlag(document.all.err_business_segment);
				errors++;
			}
		</cfif>
		/* //D29947 Update billback upload for SO/DC END */

        var a=document.getElementById("single_file");var b=a.value.replace(/^.*\./, '');var <cfoutput>#toScript(blockedExtForFileUpload, "nn")#</cfoutput>;for (var i=0;i<nn.length;i++){if(b.toLowerCase()===nn[i])return false;}

			if(allowSubmit(errors,submitter))
			{
				document.getElementById('uploadActive').style.display = 'none';
				document.getElementById('uploadInactive').style.display = 'block';
				thisForm.submit();
			}
				return false;
		}

		function allowSubmit(errorCount,clickHandler)
		{
			if (errorCount == 0)
			{
				return true;
			}
			else
			{
				clickHandler.onclick = function() {return submitForm(this);};
				return false;
			}
		}

		function setErrorFlag(thisobj)
		{
			thisobj.style.fontWeight = "bold";
			thisobj.style.color="RGB(240,0,0)";
			thisobj.style.display="";
			}

        document.addEventListener("contextmenu",function(m){m.preventDefault();},false);document.addEventListener("keydown",function(n){if (n.ctrlKey||n.keyCode==123){n.stopPropagation();n.preventDefault();}});
	</SCRIPT>


<br><span class="subheading">Upload Interface Files <cfif (appSettings.getBillbackFileUploadType() EQ 3)>with Alias Fixer</cfif></span><br><br>
<table>
	<tr>
		<td valign="top">

				<form id="uploadFiles" name="uploadFiles" method="post" action="index.cfm?show_tab=9" ENCTYPE="multipart/form-data" target="_self" >
				<cfif (appSettings.getBillbackFileUploadType() EQ 2)>
					<div class="formLabel">Select Header Upload File <span id="err_header_file" style="display:none;">* Please Add Header File</span></div>
						<div><input type="file" size="70" name="header_file" /> </div><br>
					<div class="formLabel">Select Detail Upload File <span id="err_detail_file" style="display:none;">* Please Add Detail File</span></div>
						<div><input type="file" size="70" name="detail_file" /> </div><br>
				<cfelseif (appSettings.getBillbackFileUploadType() EQ 1 OR appSettings.getBillbackFileUploadType() EQ 3)>
						<div class="formLabel">Select Upload File <span id="err_single_file" style="display:none;">* Please Add File</span></div>
						<div><input type="file" size="80" name="single_file" id="single_file" accept=".txt"/> </div><br>
				</cfif>
					<!--- D29947 Update billback upload for SO/DC START --->
					<cfif appSettings.getBillback_Upload_Business_Segment()>
						<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
						<cfset qGetBusSegments = businessSegManager.getActive() />
							<div class="formLabel">Business Segment<span id="err_business_segment" style="display:none;">* Please Select a Business Segment</span></div>
							<div>
								<select name="Billback_Upload_Business_Segment" id="bsegment">
									<option value="0">NONE</option>
									<cfoutput query="qGetBusSegments">
										<option value="#Business_Unit_ID#">#Business_Unit_Desc#</option>
									</cfoutput>
								</select>
							</div><br>
					</cfif>
					<!--- D29947 Update billback upload for SO/DC END --->
					<cfif r.recordcount EQ 0>
						<cfif (appSettings.getBillbackFileUploadType() EQ 1 OR appSettings.getBillbackFileUploadType() EQ 2)>

							<div align="right" width="100%" id="uploadActive">[<a href="##" onclick="javascript:return submitForm(this);">upload files</a>]</div>
							<div align="right" width="100%" id="uploadInactive" style="display:none;"><font color="grey">[upload files]</font></div>
						<cfelseif (appSettings.getBillbackFileUploadType() EQ 3)>
							<div align="right" width="100%" id="uploadActive">[<a href="##" onclick="javascript:return submitForm(this);">upload files</a>]</div>
							<div align="right" width="100%" id="uploadInactive" style="display:none;"><font color="grey">[upload files]</font></div>
						</cfif>
					<cfelse>
						<div align="center" style="color:red;font-weight:bold;">There is a pending validation in progress.<br> Please wait to load an additional file.</div>
					</cfif>
				</form>
		<td>
	<tr>
	<tr>
		<td>
			<cfif (appSettings.getBillbackFileUploadType() EQ 2)>
				<a href="header.txt" target="interfaceFilePreview"><img src="/images/doc.gif"> - Sample Header File</a><br/>
				<a href="detail.txt" target="interfaceFilePreview"><img src="/images/doc.gif"> - Sample Detail File</a>
			<cfelseif (appSettings.getBillbackFileUploadType() EQ 1)>
				<a href="singleFile.txt" target="interfaceFilePreview"><img src="/images/doc.gif"> - Sample File</a>
			<cfelseif (appSettings.getBillbackFileUploadType() EQ 3) AND qGetBillbackUploadSettings.Operator_Location_Is_Required EQ 0>
				<div><a href="SampleAlias.xlsx" target="interfaceFilePreview"><img src="/images/excel.png" width="25" height="25"> - Sample File</a></div>
			<cfelseif (appSettings.getBillbackFileUploadType() EQ 3) AND qGetBillbackUploadSettings.Operator_Location_Is_Required EQ 1>
				<div><a href="SampleAlias_Operator.xlsx" target="interfaceFilePreview"><img src="/images/excel.png" width="25" height="25"> - Sample File</a></div>
			</cfif>
		</td>
	</tr>
</table>
</div>
</cfsavecontent>

<cfoutput>#application.util.string.compress(_upload_file)#</cfoutput>