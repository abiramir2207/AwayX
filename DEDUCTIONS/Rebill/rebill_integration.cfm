<!-----------------------------------------------------------------------------

FILE NAME:		rebill_integration.cfm
DESCRIPTION:	This fill handles the Rebill Integration for Label 
              No. D19384: Simplot - CREATE REBILL INTERFACE..
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	9-Dec-2008	Create the file
------------------------------------------------------------------------------> 
  <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
  <cfset appSettings = genSettingsManager.get()>

  <cfset useLakebaseForqryGetRebillOpType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill_integration")>
  <cfif useLakebaseForqryGetRebillOpType>
	<cftry>
		<cfset qryGetRebillOpType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_rebill_integration", {
				"deduction_id" = "eq.#deduction_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForqryGetRebillOpType = false>
		</cfcatch>
	</cftry>
  </cfif>
  <cfif NOT useLakebaseForqryGetRebillOpType>
  <cfquery name="qryGetRebillOpType" datasource="#Application.Datasource#">
    SELECT DD_Rebill_Integration_ID,
       Deduction_ID,
       Rebill_Number,
       DD_Rebill_Package_Hrd_ID,
       Rebill_Message_DF,
       Rebill_Message_AddOn,
       DD_Reason_Code_ID,
       DD_Classification_ID,
       Rebill_By,
       Rebill_Cleared_By,
       Rebill_Cleared_Date,
       Rebill_Sent_On,
       Rebill_Ack_On,
       Rebill_Ack_Status,
       Created_Date,
       Deleted
    FROM DD_Rebill_Integration       
    WHERE  Deduction_ID = '#deduction_ID#'
    AND Deleted = 0
  </cfquery> 
  </cfif>

  <cfif (qryGetRebillOpType.RecordCount GTE 1)>
    <cfset varOpType = "EDIT" />
  <cfelse>
    <cfset varOpType = "ADD" />
  </cfif>

  <cfset useLakebaseForqryGetRebillPackageHdr = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill_package_hdr")>
  <cfif useLakebaseForqryGetRebillPackageHdr>
	<cftry>
		<cfset qryGetRebillPackageHdr = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_rebill_package_hdr", {
				"active" = "eq.1",
				"deleted" = "eq.0",
				"order" = "rebill_package_title.asc"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForqryGetRebillPackageHdr = false>
		</cfcatch>
	</cftry>
  </cfif>
  <cfif NOT useLakebaseForqryGetRebillPackageHdr>
  <cfquery name="qryGetRebillPackageHdr" datasource="#Application.Datasource#">
    SELECT DD_Rebill_Package_Hdr_ID,
         Rebill_Package_Title,
         Default_Message,
         Rebill_Package_Msg,
         Active,
         Created_Date,
         Deleted,
         Created_By,
         Updated_Date,
         Updated_By
    FROM
    DD_Rebill_Package_Hdr
    WHERE Active = 1 AND Deleted = 0     
    ORDER BY Rebill_Package_Title
  </cfquery>
  </cfif>
  
<!---Gets data about deduction--->
<cfinclude template="/deductions/sql_Deduction_Info.cfm">

  <cfset varDDPackageHeaderID = 0 />
  <cfif ((isdefined("URL.DDPackageHeaderID") AND URL.DDPackageHeaderID NEQ "") OR (isDefined("qryGetRebillOpType.DD_Rebill_Package_Hrd_ID") AND qryGetRebillOpType.DD_Rebill_Package_Hrd_ID NEQ 0))>
  
    <cfif (((isdefined("URL.DDPackageHeaderID") AND URL.DDPackageHeaderID NEQ "") AND varOpType EQ "EDIT"))>
      <cfset varDDPackageHeaderID = URL.DDPackageHeaderID />
    <cfelseif (isDefined("qryGetRebillOpType.DD_Rebill_Package_Hrd_ID") AND (qryGetRebillOpType.DD_Rebill_Package_Hrd_ID NEQ 0 AND qryGetRebillOpType.DD_Rebill_Package_Hrd_ID NEQ ""))>
      <cfset varDDPackageHeaderID = qryGetRebillOpType.DD_Rebill_Package_Hrd_ID />
    <cfelseif (((isdefined("URL.DDPackageHeaderID") AND URL.DDPackageHeaderID NEQ "") AND varOpType EQ "ADD"))>
      <cfset varDDPackageHeaderID = URL.DDPackageHeaderID />
     </cfif>
   
    <cfquery name="qryGetRebillPackageDtl" datasource="#Application.Datasource#">
      SELECT 
          DDRPD.DD_Rebill_Package_Dtl_ID,
          DDRPD.DD_Reason_Code_ID,
          DDRPD.DD_Classification_ID,
          DDRPD.Is_Default,
          DDRPD.Created_Date,
          DDRPD.Deleted,
          DRC.DD_Reason_Code,
          DDC.DD_Classification_Desc
      FROM
          DD_Rebill_Package_Dtl DDRPD
          LEFT JOIN DD_Reason_Code DRC ON DRC.DD_Reason_Code_ID = DDRPD.DD_Reason_Code_ID
          LEFT JOIN DD_Classification DDC ON DDC.DD_Classification_ID = DDRPD.DD_Classification_ID
      WHERE DDRPD.Deleted = 0 AND DDRPD.DD_Rebill_Package_Hdr_ID = #varDDPackageHeaderID#
    </cfquery>
  
    <cfquery name="qryGetRebillPackageHdrOnID" datasource="#Application.Datasource#">
      SELECT DD_Rebill_Package_Hdr_ID,
         Rebill_Package_Title,
         Default_Message,
         Rebill_Package_Msg,
         Active,
         Created_Date,
         Deleted,
         Created_By,
         Updated_Date,
         Updated_By
      FROM
          DD_Rebill_Package_Hdr
      WHERE Active = 1 AND Deleted = 0 AND DD_Rebill_Package_Hdr_ID = #varDDPackageHeaderID#
      ORDER BY Rebill_Package_Title
    </cfquery>
    
    <cfquery name="qryDefaultReplacedMessage"  datasource="#Application.Datasource#">
      SELECT dbo.UDF_DD_Rebill_Msg_Builder('#deduction_ID#', #varDDPackageHeaderID#, NULL) Default_Replaced_Message
    </cfquery>

</cfif>

<html>
<head>
	<title>Rebill Integration</title>
<cfoutput>
<script language="javascript">

  function fnChangeID()
  {
    formName = document.DataForm
     var selVal = formName.selRebillPackage.value;
  //  var selVal = document.getElementById('selRebillPackage').value;
    location.href="rebill_integration.cfm?DDPackageHeaderID=" + selVal + "&deduction_ID=" + '#deduction_ID#';
  }
</script>  
  </cfoutput>
</head>

<body>
  <script language="JavaScript" src="/Script/javascript/dhtml.js"></script>
  <SCRIPT LANGUAGE="JavaScript" SRC="/deductions/settings/rebill/rebill_component.js"></SCRIPT>
  <cfparam name="FORM.FormSubmitted" default="0">

  <cfset iVariableIDSizeList = "" />
  
  <cfset rebillPackage = CreateObject("component","components.Deduction.rebill.Rebill") />
  <cfset qGetVariableSize = rebillPackage.getRebillVariables() />
    <cfset iLoopCount = 1 />
    <cfset iVariableIDSizeList = "" />
    <cfoutput query="qGetVariableSize">
      <cfif iLoopCount EQ 1>
        <cfset iVariableIDSizeList = qGetVariableSize.Rebill_Package_Variable & "_" & qGetVariableSize.Std_Length /> 
      <cfelse>
        <cfset iVariableIDSizeList = iVariableIDSizeList & "|" & qGetVariableSize.Rebill_Package_Variable & "_" & qGetVariableSize.Std_Length />
      </cfif>
      <cfset iLoopCount= iLoopCount + 1 />
    </cfoutput>  

<cfscript>
	rebillPackage = CreateObject("component","components.Deduction.rebill.Rebill");
</cfscript>
<cfset rebillSettingsManager = rebillPackage.getRebillSettings() />
<cfset varMaxSize = rebillSettingsManager.Rebill_Message_Size />
  
  <cfset varMaxSizeAsIs = varMaxSize />
  <cfif (isDefined("qryDefaultReplacedMessage.Default_Replaced_Message") AND qryDefaultReplacedMessage.Default_Replaced_Message NEQ "")>
    <cfset varMaxSize = varMaxSize - Len(qryDefaultReplacedMessage.Default_Replaced_Message) - 2 /> <!--- 2 is for adding two spaces while concatnating --->
    <cfset varDefaultReplacedMessage= qryDefaultReplacedMessage.Default_Replaced_Message />
  <cfelse>
    <cfset varDefaultReplacedMessage= "" />
  </cfif>  

  <cfif FORM.formsubmitted eq 1>
 
 
  <cfif (varOpType EQ "ADD") OR  (varOpType EQ "EDIT")>
    <cfset rebillIntSaveCaller = CreateObject("component","components.Match_Central.MatchCentral").init() />
    <cfset rebillIntSaveCaller.rebillDD(Deduction_ID,FORM.DD_Rebill_Package_Hrd_ID,FORM.Default_Replaced_Message, FORM.rebillMessage,selClassification, selReasonCode) />
   
    <br><br><br><br>
   	<table border="0" cellpadding="0" cellspacing="0" align="Center">
		<tr>
			<td><b><font color="Red" size="3">The Rebill Integration change has been saved.</font></b></td>
		</tr>
	  </table>
   
</cfif>   
	<script language="JavaScript">
 
  
	function relocateThis()
	{
		window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#FORM.Deduction_ID#</CFOUTPUT>"
	}
	window.setTimeout('relocateThis()', 2000);	
	</script>

<cfelse>
	<form name="DataForm" action="rebill_integration.cfm" method="POST">
	<cfoutput>
  	<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
    <input type="hidden" name="iVariableIDSizeList" value="#iVariableIDSizeList#" />
    <input type="hidden" name="DD_Rebill_Package_Hrd_ID" value="#varDDPackageHeaderID#" />
	</cfoutput>
	<input type="hidden" name="FormSubmitted" value="0">
	<table border="0" cellpadding="5" cellspacing="5" align="Center" width="450" bordercolor="##333399">
		<tr>
			<td colspan="2"><b><font color="Navy" size="2">Rebill Integration</font></b><hr color="Orange"></td>
		</tr>
    <!--- 
  	  Dev Notes: D23421/Anand Rao/18-May-10
	    New Rebill - Force Ship to
    --->    
    <tr>
      <td colspan="2">
        <cfif (Deduction_Info.Shr_Ship_To EQ "")>
  	      <table bgcolor="white" style="border-color:Orange;border-style:solid;" cellpadding="5" cellspacing="0">
		        <tr>
			        <td>
				        <font size="2"><b>
                  <cfoutput>
                  A valid "#application.returned_customer_setting.shard_ship_to_label#" is required to add a rebill package.  Please add a "#application.returned_customer_setting.shard_ship_to_label#"
                  to the Deduction before changing the status to Rebill.
                  </cfoutput>
                </font>
              </td>
            </tr>
          </table>
        </cfif>
      </td>
    </tr>
    
		<tr>
			<td align="right">
        <b>Rebill Package:</b>
      </td>
      <td align="left"> 
          <select name="selRebillPackage" onChange="javascript:fnChangeID();" style="width:175;">
            <option value="">Select a Package</option>
            <cfoutput query="qryGetRebillPackageHdr">
              <option value="#DD_Rebill_Package_Hdr_ID#" <cfif ((varOpType EQ "ADD" AND isDefined("URL.DDPackageHeaderID") AND URL.DDPackageHeaderID EQ qryGetRebillPackageHdr.DD_Rebill_Package_Hdr_ID) OR ((varOpType EQ "EDIT") AND ((qryGetRebillOpType.DD_Rebill_Package_Hrd_ID EQ qryGetRebillPackageHdr.DD_Rebill_Package_Hdr_ID  AND NOT(isDefined("URL.DDPackageHeaderID"))) OR (isDefined("URL.DDPackageHeaderID") AND URL.DDPackageHeaderID EQ qryGetRebillPackageHdr.DD_Rebill_Package_Hdr_ID))))>selected</cfif>>#Rebill_Package_Title#</option>
            </cfoutput> 
          </select>
      </td>		
		</tr>
    <tr>
      <td align="right">  
       <b> Reason Code:</b>
      </td>
      <td>
        <select name="selReasonCode" style="width:175;">
          <option value="">Select a Reason Code</option>
            <cfif isDefined("qryGetRebillPackageDtl")>
              <cfoutput query="qryGetRebillPackageDtl">
                <cfif (qryGetRebillPackageDtl.DD_Reason_Code_ID NEQ "")>
                  <option value="#qryGetRebillPackageDtl.DD_Reason_Code_ID#" 
                  <cfif ((varOpType EQ "ADD" AND qryGetRebillPackageDtl.Is_Default EQ 1) OR (varOpType EQ "EDIT" AND ((qryGetRebillOpType.DD_Reason_Code_ID EQ qryGetRebillPackageDtl.DD_Reason_Code_ID AND NOT(isDefined("URL.DDPackageHeaderID"))) OR (isDefined("URL.DDPackageHeaderID") AND qryGetRebillPackageDtl.Is_Default EQ 1))))>selected</cfif>>#qryGetRebillPackageDtl.DD_Reason_Code#</option>          
                </cfif>  
              </cfoutput>
            </cfif>
        </select>
      </td>
    </tr>
    <cfif (appSettings.getDD_Show_Classification() EQ 1)> 
      <tr>
        <td align="right">
          <b>Classification:</b> 
        </td>
        <td>
          <select name="selClassification" style="width:175;">
            <option value="">Select a Classification</option>
              <cfif isDefined("qryGetRebillPackageDtl")>
                <cfoutput query="qryGetRebillPackageDtl">
                  <cfif (qryGetRebillPackageDtl.DD_Classification_ID NEQ "")>
                  <option value="#qryGetRebillPackageDtl.DD_Classification_ID#"  
                    <cfif ((varOpType EQ "ADD" AND qryGetRebillPackageDtl.Is_Default EQ 1) OR (varOpType EQ "EDIT" AND ((qryGetRebillOpType.DD_Classification_ID EQ qryGetRebillPackageDtl.DD_Classification_ID AND NOT(isDefined("URL.DDPackageHeaderID"))) OR (isDefined("URL.DDPackageHeaderID") AND qryGetRebillPackageDtl.Is_Default EQ 1 ))))>selected</cfif>>#qryGetRebillPackageDtl.DD_Classification_Desc#</option>          
                  </cfif>
                </cfoutput>
              </cfif>
          </select>
        </td>
      </tr>
    <cfelse>
      <input type="hidden" value="0" name="selClassification" />      
    </cfif>
    <input type="hidden" name="appSetting_getDD_Show_Classification" value="#appSettings.getDD_Show_Classification()#" />    
    
    <cfif ((varOpType EQ "ADD" AND isDefined("qryGetRebillPackageHdrOnID.Default_Message") AND qryGetRebillPackageHdrOnID.Default_Message EQ 1 AND varDefaultReplacedMessage NEQ "") OR ((varOpType EQ "EDIT")  AND (varDefaultReplacedMessage NEQ "")))>
      <tr>
        <td nowrap valign="top" align="right">
          <b>Default Message:</b>
        </td>
        <td>  
          <cfoutput>
            #varDefaultReplacedMessage#
            <input type="hidden" name="Default_Replaced_Message" value="#varDefaultReplacedMessage#" />
          </cfoutput>
        </td>
      </tr>
    <cfelse>
      <input type="hidden" name="Default_Replaced_Message" value="" />
    </cfif>
    <tr>
      <td valign="top" align="right" width="100">
        <br>
        <b>
        <cfif (varDefaultReplacedMessage NEQ "")>
          AddOn Message:
        <cfelse>
          Rebill Message:         
        </cfif>
        </b>
      </td>
      <td>
        <a href="#" 
			     onClick="javascript:document.getElementById('rebillMessage').cols=50;javascript:document.getElementById('rebillMessage').rows=8;"
			     ondblClick="javascript:document.getElementById('rebillMessage').cols=50;javascript:document.getElementById('rebillMessage').rows=8;">
            <IMG SRC="/images/smaller.gif" BORDER="0" TITLE="Smaller">
        </a>	 
		 	  <a href="#" 
			     onClick="javascript:document.getElementById('rebillMessage').cols=document.getElementById('rebillMessage').cols+10;javascript:document.getElementById('rebillMessage').rows=document.getElementById('rebillMessage').rows+5;"
			     ondblClick="javascript:document.getElementById('rebillMessage').cols=document.getElementById('rebillMessage').cols+10;javascript:document.getElementById('rebillMessage').rows=document.getElementById('rebillMessage').rows+5;">
            <IMG SRC="/images/bigger.gif" BORDER="0" TITLE="Bigger">
        </a>
			  <br>
        <cfoutput>		
           <!--- 
                If there is already AddOn message then subtract the no. of 
                characters that is allowed to be added by the user 
           ---> 
<!---            <cfif ((varOpType EQ "EDIT") AND isDefined("qryGetRebillOpType.Rebill_Message_AddOn") AND qryGetRebillOpType.Rebill_Message_AddOn NEQ "")>
            <cfset varMaxSize = varMaxSize - Len(qryGetRebillOpType.Rebill_Message_AddOn) />
          </cfif>  --->
  			  <input type="hidden" name="Punch_Notes_Sizing" value="">
			    <textarea name="rebillMessage" id="rebillMessage" wrap="physical" cols="50" rows="8"
<!---             onPaste = "textCounterRebillInt(document.DataForm.rebillMessage,document.DataForm.remLen2,#varMaxSize#)" onfocusOut="textCountCheck(document.DataForm.rebillMessage,#varMaxSize#)" --->
            onKeyPress="textCounterRebillInt(document.DataForm.rebillMessage,document.DataForm.remLen2,#varMaxSize#)"
             
            ><cfif ((varOpType EQ "EDIT") AND isDefined("qryGetRebillOpType.Rebill_Message_AddOn") AND qryGetRebillOpType.Rebill_Message_AddOn NEQ "")>#qryGetRebillOpType.Rebill_Message_AddOn#</cfif></textarea><br>
           Characters left: <input readonly type="text" name="remLen2" size="3" maxlength="3" value="#varMaxSize#" style="border:none;background:white;">
      </cfoutput>
      </td>
    </tr>
    <tr>
		  <td colspan="2" ALIGN="center">
				<br>
        <cfif (Deduction_Info.Shr_Ship_To EQ "")>
          <strong><font color="red">[ </font><font color="grey">Save</font><font color="red"> ]</font></strong>
        <cfelse>
  				<CF_button
  					button_name		=	""
  					button_caption	=	"Save"
  					button_action	=	"return fnValidate();"
  					button_type		=	"javascript_link"
  					button_width	=	"75"
  					button_color	=	"Navy"
  					button_tip		=	""
  					font_color		=	"White"
  					font_size		=	"12"
  					font_weight		=	"bold"
  				>
         </cfif>
			</td>
		</tr>    
	</table>
	</form>
	  <cfoutput>
	<script language="JavaScript">
	function fnValidate()
	{
    var bErrorExists = 0;
    var strErrors = "";
    var rebillMessageSize = 0;
    actionFrm = document.DataForm;
    
    if(actionFrm.selRebillPackage.value == "")
    {
    	alert("Please select a Package");
  		return false;
    }  
    
    if(actionFrm.selReasonCode.value == "")
    {
      bErrorExists = 1;
    	// alert("Please select a Reason Code");
      if (strErrors == "")
      {
        strErrors = "- Please select a Reason Code";
      }
      else
      {
        strErrors = strErrors + "\n- Please select a Reason Code";
  	  }
    }  
    if(actionFrm.appSetting_getDD_Show_Classification.value == '1')
    {
      if(actionFrm.selClassification.value == "")
      {
        bErrorExists = 1;
      	//alert("Please select a Reason Code");
        if (strErrors == "")
        {
          strErrors = "- Please select a DD Classification";
        }
        else
        {
          strErrors = strErrors + "\n- Please select a DD Classification";
    	  }
      }    
    }
    rebillMessageSize = actionFrm.Default_Replaced_Message.value.length + actionFrm.rebillMessage.value.length;
    if (rebillMessageSize > #varMaxSizeAsIs#)
    {
      bErrorExists = 1;
      if (strErrors == "")
      {
        strErrors = "- Rebill Message size is greater than the allowed max size!";
      }
      else
      {
        strErrors = strErrors + "\n- Rebill Message size is greater than the allowed max size!";
  	  }
    }
    
    if (bErrorExists == 1)
    {
      strErrors = "Errors Found:\n" + strErrors;
      alert(strErrors);
      return false;
    }
    else
    {
     // if(confirm("Press Ok to Save changes!!"))
      //{
  	    actionFrm.FormSubmitted.value=1;
  		  actionFrm.submit()
  	  // }
    }
    
	}
	</script>
</cfoutput>
</cfif>
</body>
</html>
