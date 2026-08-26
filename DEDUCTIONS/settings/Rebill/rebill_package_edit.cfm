<!-----------------------------------------------------------------------------

FILE NAME:		rebill_package_edit.cfm
DESCRIPTION:	Editing page for the Rebill Pakcage	
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	09-Apr-10 Added the edit page for the Rebill Package
------------------------------------------------------------------------------> 
 
 <cfif (qGetRebillPackage.Updated_Date NEQ "" AND qGetRebillPackage.Name_First NEQ "")>
<cfoutput>
<table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="2" cellspacing="0" align="center">
<tr>
<td>
	<font size="2"><b>The settings were last updated on #dateformat(qGetRebillPackage.Updated_Date, 'mm/dd/yyyy')# #timeformat(qGetRebillPackage.Updated_Date, 'hh:mm:ss TT')# by #qGetRebillPackage.Name_First# #qGetRebillPackage.Name_Last#</b></font>	</td>
</td>
</tr>
</table>
<br>
</cfoutput>
</cfif>
 
<fieldset style="padding:10px; width: 700px; border: 1px solid Blue;">
  <legend style="font: bold 14px sans-serif; color: Red;">Rebill Package</legend>
	   <table cellspacing="4" width="610"  border="0">
		  <tr>
			  <td align="right" width="20%"><b>Title:</b></td>
			  <td><input name="title" type="text" value="<cfoutput>#qGetRebillPackage.Rebill_Package_Title#</cfoutput>" SIZE="30" MAXLENGTH="50"></td>
		  </tr>
       <!--- DD Reason Code Assignment --->    
      <tr>
        <td valign="top" align="right"><strong>DD Reason Code:</strong></td>
        <td align="left">
         <table border="1" cellpadding="1" cellspacing="1" bordercolor="##000080" width="100%">
            <tr>
              <td valign="Top" bgcolor="Navy" width="60%" align="center">&nbsp;<font color="white"><B>DD Reason Code</b></font>
              <td valign="Top" bgcolor="Navy" width="20%" align="center">&nbsp;<font color="white"><B>Include? </b></font>
              <td valign="Top" bgcolor="Navy" width="20%" align="center">&nbsp;<font color="white"><B>Set as Default </b></font>
            </tr>
            <cfset cbReasonList = "" />
           <cfset defaultReasonVal=0/>
            <cfoutput query="qGetDDReasonCode">
              <cfset balreadyexists = 0 />
                <cfloop query="qGetReasonCodeRS">
                  <cfif	(qGetddreasoncode.DD_Reason_Code_ID eq qGetReasonCodeRS.DD_Reason_Code_ID)>       
                    <cfset balreadyexists = 1 />
                  </cfif>
                  <cfif (qGetReasonCodeRS.Is_Default EQ 1 AND qGetReasonCodeRS.DD_Reason_Code_ID NEQ "")>
                    <cfset defaultReasonVal = qGetReasonCodeRS.DD_Reason_Code_ID />
                  </cfif>
                </cfloop>
            <!--- <td align="right"><input type="checkbox" name="Payment_Type_#Payment_Type_ID#" value="1" <cfif len(trim(TypeInThisTemplate.Payment_Type_ID)) GT 0>checked</cfif> ></td>
							<td align="right"><input type="radio" name="ClaimMechDefaultOption" value="#Payment_Type_ID#" <cfif ClaimMechDefaultOption IS Payment_Type_ID>checked</cfif>> </td>--->
             <tr>
              <td>
                  &nbsp;#DD_Reason_Code#
              </td>
              <td align="center">
                <input type="checkbox" name="DD_Reason_Code_ID_#DD_Reason_Code_ID#" value="#DD_Reason_Code_ID#"   <cfif balreadyexists eq 1>checked</cfif>/>  <!--- onClick="javascript:fnAddChecked(this);"> --->
                <cfif (cbReasonList EQ "")>
                  <cfset cbReasonList = "DD_Reason_Code_ID_" & DD_Reason_Code_ID />
                <cfelse>
                  <cfset cbReasonList = cbReasonList & "," & "DD_Reason_Code_ID_" & DD_Reason_Code_ID />
                </cfif>
              </td>
              <td align="center">
                  <input type="radio" name="Reason_Default" value="#DD_Reason_Code_ID#" <cfif (defaultReasonVal EQ DD_Reason_Code_ID)>checked </cfif>> 
              </td>
             </tr> 
            </cfoutput>
          </table>
          <cfoutput>
            <input type="hidden" name="All_Reason_Code_ID_List" value="#cbReasonList#" />  
            <input type="hidden" name="Selected_Reason_Code_ID_List" value="" />  
            <input type="hidden" name="Selected_Reason_Code_ID" value="" />  
          </cfoutput>         
      </td>
    </tr>
    <tr>
      <td align="right" valign="top">
       <!---  <strong>Default DD Reason Code:</strong> --->
      </td>
      <td>
        <select name="Default_Reason_Code"   style="width:120px;display:None">
		    </select>
      </td>
    </tr>
    <!--- Classification Assignment --->
    <cfset cbClassList = "" /> 
    <cfif (appSettings.getDD_Show_Classification() EQ 1)>
      <tr>
       <td valign="top" align="right"><strong>DD Classification:</strong> </td>
        <td align="left">
          <table border="1" cellpadding="1" cellspacing="1" bordercolor="##000080" width="100%">
            <tr>
              <td valign="Top" bgcolor="Navy" width="60%" align="center">&nbsp;<font color="white"><B>DD Classification</b></font>
              <td valign="Top" bgcolor="Navy" width="20%" align="center">&nbsp;<font color="white"><B>Include? </b></font>
              <td valign="Top" bgcolor="Navy" width="20%" align="center">&nbsp;<font color="white"><B>Set as Default </b></font>
            </tr>
  
            <cfset defaultClassVal=0/>
             <cfoutput query="qGetDDClassifications">
              <cfset balreadyexists = 0 />
                <cfloop query="qGetDDClassificationRS">
                  <cfif	(qGetDDClassifications.DD_Classification_ID EQ qGetDDClassificationRS.DD_Classification_ID)>       
                    <cfset balreadyexists = 1 />
                  </cfif>
                  <cfif (qGetDDClassificationRS.is_default EQ 1 AND qGetDDClassificationRS.DD_Classification_ID NEQ "")>
                    <cfset defaultClassVal = qGetDDClassificationRS.DD_Classification_ID />
                  </cfif>
                </cfloop>         
              <!--- <td align="right"><input type="checkbox" name="Payment_Type_#Payment_Type_ID#" value="1" <cfif len(trim(TypeInThisTemplate.Payment_Type_ID)) GT 0>checked</cfif> ></td>
  							<td align="right"><input type="radio" name="ClaimMechDefaultOption" value="#Payment_Type_ID#" <cfif ClaimMechDefaultOption IS Payment_Type_ID>checked</cfif>> </td>--->
               <tr>
                <td>
                    &nbsp;#DD_Classification_Desc#
                </td>
                <td align="center">
                    <input type="checkbox" name="DD_Classification_ID_#DD_Classification_ID#" value="#DD_Classification_ID#"  <cfif balreadyexists eq 1>checked</cfif>>
                   
                    <cfif (cbClassList EQ "")>
                      <cfset cbClassList = "DD_Classification_ID_" & DD_Classification_ID />
                    <cfelse>
                      <cfset cbClassList = cbClassList & "," & "DD_Classification_ID_" & DD_Classification_ID />
                    </cfif>                  
                </td>
                <td  align="center">
                    <input type="radio" name="Class_Default" value="#DD_Classification_ID#" <cfif (defaultClassVal EQ DD_Classification_ID)>checked</cfif>> 
                </td>
               </tr> 
              </cfoutput>
            </table>    
        </td>
      </tr>
    </cfif> 
    <cfoutput>
      <input type="hidden" name="All_DD_Classification_ID_List" value="#cbClassList#" />
      <input type="hidden" name="Selected_Classification_ID_List" value="" />
      <input type="hidden" name="Selected_Classification_ID"  value="" />
    </cfoutput>  
    <tr>
      <td align="right"><b>Default Message: </b></td>
      <td>
        <input type="checkbox" name="chkDefaultMessage" value="1"   onclick="javascript:fnHideMsg();" <cfif (qgetrebillpackage.default_message eq 1)>checked</cfif> />     
      </td>
    </tr>
    <tr>
      <td colspan="2">
        <div id="divMsg" <cfif (qgetrebillpackage.default_message eq 0)>style="display:none;"</cfif>>
          <table cellpadding="1" border="0" width="100%"> 
            <tr>
              <td>&nbsp;</td>
              <td>
               <a href="javascript:void(0);" 
    			     onClick="javascript:document.getElementById('rebillMessage').cols=95;javascript:document.getElementById('rebillMessage').rows=8;"
    			     ondblClick="javascript:document.getElementById('rebillMessage').cols=95;javascript:document.getElementById('rebillMessage').rows=8;">
              <IMG SRC="/images/smaller.gif" BORDER="0" TITLE="Smaller">
              </a>	 
    		 	    <a href="javascript:void(0);" 
    			      onClick="javascript:document.getElementById('rebillMessage').cols=document.getElementById('rebillMessage').cols+10;javascript:document.getElementById('rebillMessage').rows=document.getElementById('rebillMessage').rows+5;"
    			      ondblClick="javascript:document.getElementById('rebillMessage').cols=document.getElementById('rebillMessage').cols+10;javascript:document.getElementById('rebillMessage').rows=document.getElementById('rebillMessage').rows+5;">
                <IMG SRC="/images/bigger.gif" BORDER="0" TITLE="Bigger">
              </a>
              </td>
            </tr>
            <tr>
     			    <td align="right" valign="top" width="20%"><b>Rebill Message:</b></td>
			        <td  width="210">
                <cfoutput>  
                  <cfset varmaxsize = varmaxsize - len(qgetrebillpackage.rebill_package_msg) /> 
                  <textarea name="rebillMessage" id="rebillMessage" wrap="physical" cols="95" rows="8"
                    onKeyPress="textCounter(document.DataForm.rebillMessage,document.DataForm.remLen2,#varMaxSize#)"
                    onfocusOut="textCountCheck(document.DataForm.rebillMessage,#varMaxSize#)"
                   <!---  onPaste="textCounter(document.DataForm.rebillMessage,document.DataForm.remLen2,#varMaxSize#)" --->>#qGetRebillPackage.Rebill_Package_Msg#</textarea>
                  <br>
                  Characters left: <input readonly type="text" name="remLen2" size="3" maxlength="3" value="#varMaxSize#" style="border:none;background:Whitesmoke;">
                </cfoutput>
              </td>
		        </tr>
            <tr>
              <td colspan="2">
              <br>
              
              <strong>Variables to use(within the Rebill Message):</strong><br>
              </td>
            </tr>
            <tr>
              <td colspan="2">
                
                  <table cellpadding="1" cellspacing="0" border="1" bordercolor="##333366" align="left" width="100%">
                    <tr><td><b>Variable Name</b></td><td><strong>Size</strong></td><td><strong>Description</strong></td></tr>
                      <cfoutput query="qGetVariableSize">
                    <tr>
                      <td nowrap><a href="javascript:void(0);" onclick="javascript:fnInsertVal('#qGetVariableSize.Rebill_Package_Variable#');textCounter(document.DataForm.rebillMessage,document.DataForm.remLen2,#varMaxSize#);" title="Insert #qGetVariableSize.Rebill_Package_Variable# to the end of the Rebill Message">#qGetVariableSize.Rebill_Package_Variable#</a></td><td>#qGetVariableSize.Std_Length#</td> <td> - #qGetVariableSize.Rebill_Package_Variable_Desc#</td>
                    </tr>
                    </cfoutput>
                  </table><br>
                </td>
            </tr>
          </table>  
        </div>
        </td>
      </tr>      
		  <tr>
			  <td colspan="2" align="center">
				  <br>
				  <cf_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return updateRebillPackage(#qGetRebillPackage.DD_Rebill_Package_Hdr_ID#);"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				  >
			  </td>
		  </tr>
	  </table>
	</fieldset>