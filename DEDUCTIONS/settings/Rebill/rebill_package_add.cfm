<!-----------------------------------------------------------------------------

FILE NAME:		rebill_package_add.cfm
DESCRIPTION:	Adding page for the Rebill Package	
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	09-Apr-10 Added the add page for the Rebill Package
------------------------------------------------------------------------------> 

<FIELDSET STYLE="padding:10px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Rebill Package</LEGEND>
	  <table cellspacing="4" width="610"  border="0">
		  <tr>
			  <td ALIGN="right" width="20%"><B>Title:</B></td>
			  <td><input name="title" type="text" size="25" maxlength="50"></td>
		  </tr>	
      <!--- DD Reason Code Assignment --->    
      <tr>
        <td valign="top" align="right"><strong>DD Reason Code:</strong></td>
        <td  align="left">
           <table border="1" cellpadding="1" cellspacing="1" bordercolor="##000080" width="100%">
            <tr>
              <td valign="Top" bgcolor="Navy" width="60%" align="center">&nbsp;<font color="white"><B>DD Reason Code</b></font>
              <td valign="Top" bgcolor="Navy" width="20%" align="center">&nbsp;<font color="white"><B>Include? </b></font>
              <td valign="Top" bgcolor="Navy" width="20%" align="center">&nbsp;<font color="white"><B>Set as Default </b></font>
            </tr>
            <cfset cbReasonList = "" />
            <cfoutput query="qGetDDReasonCode">
            <tr>
              <td>
                  &nbsp;#DD_Reason_Code#
              </td>
              <td align="center">
                <input type="checkbox" name="DD_Reason_Code_ID_#DD_Reason_Code_ID#" value="#DD_Reason_Code_ID#"   />  <!--- onClick="javascript:fnAddChecked(this);"> --->
                <cfif (cbReasonList EQ "")>
                  <cfset cbReasonList = "DD_Reason_Code_ID_" & DD_Reason_Code_ID />
                <cfelse>
                  <cfset cbReasonList = cbReasonList & "," & "DD_Reason_Code_ID_" & DD_Reason_Code_ID />
                </cfif>
              </td>
              <td align="center">
                  <input type="radio" name="Reason_Default" value="#DD_Reason_Code_ID#"> 
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
    <!--- Classification Assignment ---> 
    <cfset cbClassList = "" /> 
    <cfif (appSettings.getDD_Show_Classification() EQ 1)>
      <tr>
        <td valign="top" align="right"><b>DD Classification:</b></td>
        <td align="left">
          <table border="1" cellpadding="1" cellspacing="1" bordercolor="##000080" width="100%">
            <tr>
              <td valign="Top" bgcolor="Navy" width="60%" align="center">&nbsp;<font color="white"><B>DD Classification</b></font>
              <td valign="Top" bgcolor="Navy" width="20%" align="center">&nbsp;<font color="white"><B>Include? </b></font>
              <td valign="Top" bgcolor="Navy" width="20%" align="center">&nbsp;<font color="white"><B>Set as Default </b></font>
            </tr>
           
              <cfoutput query="qGetDDClassifications">
               <tr>
                <td>
                    &nbsp;#DD_Classification_Desc#
                </td>
                <td align="center">
                    <input type="checkbox" name="DD_Classification_ID_#DD_Classification_ID#" value="#DD_Classification_ID#">
                    <cfif (cbClassList EQ "")>
                      <cfset cbClassList = "DD_Classification_ID_" & DD_Classification_ID />
                    <cfelse>
                      <cfset cbClassList = cbClassList & "," & "DD_Classification_ID_" & DD_Classification_ID />
                    </cfif>                  
                </td>
                <td  align="center">
                    <input type="radio" name="Class_Default" value="#DD_Classification_ID#"> 
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
     <td><input type="checkbox" name="chkDefaultMessage" value="1"  onclick="javascript:fnHideMsg();" checked /> </td>
     </tr>
     <tr>
        <td colspan="2">
        <div id="divMsg">
          <table cellpadding="0" border="0"> 
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
     			  <td align="right" valign="top" width="20%"><B>Rebill Message:</B></td>
			      <td width="210">
              <cfoutput>
                <textarea name="rebillMessage" id="rebillMessage" wrap="physical" cols="95" rows="8"  maxlength="#varMaxSize#"
                  onKeyUp="textCounter(document.DataForm.rebillMessage,document.DataForm.remLen2,#varMaxSize#)"
                  onfocusOut="textCountCheck(document.DataForm.rebillMessage,#varMaxSize#)"
                  onPaste="textCounter(document.DataForm.rebillMessage,document.DataForm.remLen2,#varMaxSize#)"
                  ></textarea>
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
        <td colspan="2" align="left"><br>
          <table cellpadding="2" cellspacing="0" border="1" bordercolor="##333366" align="center" width="100%">
            <tr><td><b>Variable Name</b></td><td><strong>Size</strong></td><td><strong>Description</strong></td></tr>
             <cfoutput query="qGetVariableSize">
             <tr>
              <td nowrap><a href="javascript:void(0);" onclick="javascript:fnInsertVal('#qGetVariableSize.Rebill_Package_Variable#');textCounter(document.DataForm.rebillMessage,document.DataForm.remLen2,#varMaxSize#);" title="Insert #qGetVariableSize.Rebill_Package_Variable# to the end of the Rebill Message">#qGetVariableSize.Rebill_Package_Variable#</a></td><td>#qGetVariableSize.Std_Length#</td> <td> - #qGetVariableSize.Rebill_Package_Variable_Desc#</td>
             </tr>
             </cfoutput>
          </table><br>
          </div>
          </td>
          </tr>
          </table>
        </td>
      </tr>
          
    <tr>
		  <td colspan="100%" ALIGN="center">
				<br>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return fnAddRebillPackage();"
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
</FIELDSET>