<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\billbacks\OCR_Upload\OCR_Steps.cfm
      Date:     30-Mar-2017
      Author:   Anand Rao
      Purpose:  Different steps in the flow of the process is shown

      Notes:

-----------------------------------------------------------------------------------------------------------------------> 

<cfparam name="qGetOCRUploadStatus.OCR_Step" default="1">
 
 <link rel="stylesheet" href="style.css">

<cfset alertTxt = ""/>
<cfset classUpload 	 = "" /><cfset imgUpload = ""/>
<cfset classValidate = "" /><cfset imgValidate = "" />
<cfset classProcess  = "" /><cfset imgProcess = "" />
<cfset classCleanup  = "" /><cfset imgCleanup = "" />
<cfset classReport 	 = "" /><cfset imgReport = "" />

<cfset alertTxt = qGetAutoUploadStatus.Display_UA_Step_Desc />
<cfswitch expression = "#qGetAutoUploadStatus.UA_Step#"> 
	<cfcase value="1_0">
		<cfset classUpload 	 = "in-progress" /><cfset imgUpload = "/images/ocr/icon_in_progress_lb.png"/>
		<cfset classValidate = "" /><cfset imgValidate = "/images/ocr/icon_tbd_lw.png" />
		<cfset classProcess  = "" /><cfset imgProcess = "/images/ocr/icon_tbd_lw.png" />
		<cfset classCleanup  = "" /><cfset imgCleanup = "/images/ocr/icon_tbd_lw.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
	</cfcase>
	<cfcase value="1_1,2_0,3_0">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "in-progress" /><cfset imgValidate = "/images/ocr/icon_in_progress_lb.png" />
		<cfset classProcess  = "" /><cfset imgProcess = "/images/ocr/icon_tbd_lw.png" />
		<cfset classCleanup  = "" /><cfset imgCleanup = "/images/ocr/icon_tbd_lw.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
	</cfcase>
	<cfcase value="1_2">
		<cfset classUpload 	 = "failure" /><cfset imgUpload = "/images/ocr/abort24.png"/>
		<cfset classValidate = "" /><cfset imgValidate = "/images/ocr/icon_tbd_lw.png" />
		<cfset classProcess  = "" /><cfset imgProcess = "/images/ocr/icon_tbd_lw.png" />
		<cfset classCleanup  = "" /><cfset imgCleanup = "/images/ocr/icon_tbd_lw.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
	</cfcase>
	<cfcase value="2_1,2_3">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "in-progress" /><cfset imgValidate = "/images/ocr/clock24.png" />
		<cfset classProcess  = "" /><cfset imgProcess = "/images/ocr/icon_tbd_lw.png" />
		<cfset classCleanup  = "" /><cfset imgCleanup = "/images/ocr/icon_tbd_lw.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
		<cfset alertTxt = qGetAutoUploadStatus.Display_UA_Step_Desc />
	</cfcase>
	<cfcase value="2_2">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "failure" /><cfset imgValidate = "/images/ocr/abort24.png" />
		<cfset classProcess  = "" /><cfset imgProcess = "/images/ocr/icon_tbd_lw.png" />
		<cfset classCleanup  = "" /><cfset imgCleanup = "/images/ocr/icon_tbd_lw.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
	</cfcase>
	<cfcase value="3_1">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "in-progress" /><cfset imgValidate = "/images/ocr/clock24.png" />
		<cfset classProcess  = "" /><cfset imgProcess = "/images/ocr/icon_tbd_lw.png" />
		<cfset classCleanup  = "" /><cfset imgCleanup = "/images/ocr/icon_tbd_lw.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
		<cfset alertTxt = qGetAutoUploadStatus.Display_UA_Step_Desc />
	</cfcase>
	<cfcase value="3_2,3_3">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "failure" /><cfset imgValidate = "/images/ocr/abort24.png" />
		<cfset classProcess  = "" /><cfset imgProcess = "/images/ocr/icon_tbd_lw.png" />
		<cfset classCleanup  = "" /><cfset imgCleanup = "/images/ocr/icon_tbd_lw.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
	</cfcase>	
	<cfcase value="4_0,5_0,5_1">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "done" /><cfset imgValidate = "/images/ocr/checked24.png" />
		<cfset classProcess  = "in-progress" /><cfset imgProcess = "/images/ocr/icon_in_progress_lb.png" />
		<cfset classCleanup  = "" /><cfset imgCleanup = "/images/ocr/icon_tbd_lw.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
	</cfcase>	
	<cfcase value="4_1,4_2,4_3" delimiters=",">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "done" /><cfset imgValidate = "/images/ocr/checked24.png" />
		<cfset classProcess  = "failure" /><cfset imgProcess = "/images/ocr/abort24.png" />
		<cfset classCleanup  = "" /><cfset imgCleanup = "/images/ocr/icon_tbd_lw.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
	</cfcase>	
	<cfcase value="6_0" delimiters=",">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "done" /><cfset imgValidate = "/images/ocr/checked24.png" />
		<cfset classProcess  = "done" /><cfset imgProcess = "/images/ocr/checked24.png" />
		<cfset classCleanup  = "in-progress" /><cfset imgCleanup = "/images/ocr/icon_in_progress_lb.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
	</cfcase>	
	<cfcase value="6_1" delimiters=",">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "done" /><cfset imgValidate = "/images/ocr/checked24.png" />
		<cfset classProcess  = "done" /><cfset imgProcess = "/images/ocr/checked24.png" />
		<cfset classCleanup  = "done" /><cfset imgCleanup = "/images/ocr/checked24.png" />
		<cfset classReport 	 = "in-progress" /><cfset imgReport = "/images/ocr/icon_in_progress_lb.png" />
	</cfcase>	
	<cfcase value="6_2" delimiters=",">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "done" /><cfset imgValidate = "/images/ocr/checked24.png" />
		<cfset classProcess  = "done" /><cfset imgProcess = "/images/ocr/checked24.png" />
		<cfset classCleanup  = "failure" /><cfset imgCleanup = "/images/ocr/abort24.png" />
		<cfset classReport 	 = "" /><cfset imgReport = "/images/ocr/icon_tbd_lw.png" />
	</cfcase>	
	<cfcase value="7_0,7_1,8_0"  delimiters=",">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "done" /><cfset imgValidate = "/images/ocr/checked24.png" />
		<cfset classProcess  = "done" /><cfset imgProcess = "/images/ocr/checked24.png" />
		<cfset classCleanup  = "done" /><cfset imgCleanup = "/images/ocr/checked24.png" />
		<cfset classReport 	 = "in-progress" /><cfset imgReport = "/images/ocr/icon_in_progress_lb.png" />
	</cfcase>	
	<cfcase value="8_1" delimiters=",">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "done" /><cfset imgValidate = "/images/ocr/checked24.png" />
		<cfset classProcess  = "done" /><cfset imgProcess = "/images/ocr/checked24.png" />
		<cfset classCleanup  = "done" /><cfset imgCleanup = "/images/ocr/checked24.png" />
		<cfset classReport 	 = "done" /><cfset imgReport = "/images/ocr/checked24.png" />
	</cfcase>	
	<cfcase value="8_2,8_3,8_4" delimiters=",">
		<cfset classUpload 	 = "done" /><cfset imgUpload = "/images/ocr/checked24.png"/>
		<cfset classValidate = "done" /><cfset imgValidate = "/images/ocr/checked24.png" />
		<cfset classProcess  = "done" /><cfset imgProcess = "/images/ocr/checked24.png" />
		<cfset classCleanup  = "done" /><cfset imgCleanup = "/images/ocr/checked24.png" />
		<cfset classReport 	 = "failure" /><cfset imgReport = "/images/ocr/abort24.png" />
	</cfcase>	
	<cfdefaultcase>
				<cfset incDownloadImage = "<img src='/images/OCR/spacer24.png' width='20' height='20' />&nbsp;&nbsp;" />
	</cfdefaultcase>															
</cfswitch>
 
 <cfoutput>
 <div style="display:flex;font-size:15px;">
      <div class="status-shape #classUpload#" title="uploaded the file"> 
        <img class="status-icon"
          src="#imgUpload#"
          alt="upload"></img>
        UPLOAD
      </div>

      <div class="status-shape #classValidate#" title="validating the file">
          <img class="status-icon"
            src="#imgValidate#"
            alt="validate"></img>
          VALIDATE
      </div>
      <div class="status-shape #classProcess#" title="process the file">
        <img class="status-icon"
            src="#imgProcess#"
            alt="process"></img>
        PROCESS
      </div>
      <div class="status-shape #classCleanup#" title="cleanup the file">
        <img class="status-icon"
            src="#imgCleanup#"
            alt="Create BB"></img>
        CREATE BB
      </div>
      <div class="status-shape #classReport#" title="report for the file">
        <img class="status-icon"
            src="#imgReport#"
            alt="report"></img>
        REPORTS
      </div>
    </div>
	<cfif alertTxt NEQ "" AND qGetAutoUploadStatus.User_Intervention_Required EQ 1> 
		<font color="red"><b></b></font>
		<table>
			<tr>
				<td><img src="/images/Deviations/b2.gif" height="20px" width="20px" title="User Intervention required"></td>
				<td><font style="color:red; font-size:14px;"><b>#alertTxt#</b></font></td>
			</tr>
		</table>
	<cfelse>
		<font color="grey"><b></b></font>
		<table>
			<tr>
				<td><img src="/images/hand.gif" ></td><!--- help_small.gif height="20px" width="20px"--->
				<td><font style="color:grey; font-size:14px;"><b>#alertTxt#</b></font></td>
			</tr>
		</table>
	</cfif>
	<cfif (qGetAutoUploadStatus.Display_UA_Next_Step_Desc NEQ "")>
	<table>
			<tr>
				<td><img src="/images/i.gif" height="20px" width="20px" title="Next Step"></td>
				<td><font style="color:grey; font-size:14px;"><b>#qGetAutoUploadStatus.Display_UA_Next_Step_Desc#</b></font></td>
			</tr>
		</table>
	</cfif>		
  </cfoutput>	
<!--- 
<cfelse>

Generating flow images...

</cfif>
--->
