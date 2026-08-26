<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>	
<style type="text/css">
	.inp1 {
		border : none;
		font-style : italic;
		font-size : 8pt;
		font-weight : bold;
		color : Red;
	}

	.sel {
		width : 165px;
		scrollbar-arrow-color : Red;
		font-size: 10px;
		
	}
	.opt {
		font-style : italic;
		font-weight : bold;
		color : Blue;
	}
	.opt2 {
		color : black;
		font-size : x-small;
		TEXT-TRANSFORM: lowercase;
	}
</style>
<CFQUERY NAME="qGetReasonAmount" DATASOURCE="#Application.Datasource#">
		SELECT 		BBRCA.BBReasonCodeAmountId,
					BBRCA.BillBack_id,
					BBRCA.ReasonAmount,
					BBRCA.DD_Reason_Code_Id,
					BBRCA.PC_Reason_Code_Id,
					BBRCA.GL_Reason_Code_Id,
					BBRCA.UserId,
					BBRCA.Pay_Multi_Billbacks_ID,
					DD_Reason_Code,
					PC_Reason_Code,
					GL_Reason_Code,
					DD_Reason_Code_description,
					PC_Reason_Code_description,
					GL_Reason_Code_description
					 
		FROM 		BB_Reason_Code_Amount BBRCA
		 left outer JOIN 	DD_Reason_Code DD ON BBRCA.DD_Reason_Code_ID = DD.DD_Reason_Code_ID
		 left outer JOIN 	PC_Reason_Code PC ON BBRCA.PC_Reason_Code_ID = PC.PC_Reason_Code_ID
		 left outer JOIN 	GL_Reason_Code GL ON BBRCA.GL_Reason_Code_ID = GL.GL_Reason_Code_ID
		WHERE 		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
						BBRCA.Billback_ID IN (	SELECT 	Billback_ID 
													FROM 	Pay_Multi_Billbacks_List
													WHERE 	Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND 
															Deleted = 0	)
					<CFELSE>
						BBRCA.Billback_ID = '#URL.BBID#'
					</CFIF>
					and BBRCA.deleted=0
		ORDER BY 	BBReasonCodeAmountId
</CFQUERY>


<CFQUERY NAME="qGetReasonAmountsum" DATASOURCE="#Application.Datasource#">
		SELECT 		isnull(sum(reasonAmount),0) as totAmount
					 
		FROM 		BB_Reason_Code_Amount BBRCA
		WHERE 		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
						BBRCA.Billback_ID IN (	SELECT 	Billback_ID 
													FROM 	Pay_Multi_Billbacks_List
													WHERE 	Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND 
															Deleted = 0	)
					<CFELSE>
						BBRCA.Billback_ID = '#URL.BBID#'
					</CFIF>
					and BBRCA.deleted=0
					
</CFQUERY>  

		<CFQUERY NAME="qgetDDCode" datasource="#application.datasource#">
				SELECT 	DD_Reason_Code,
						DD_Reason_Code_Id,
						DD_Reason_Code_Description,
            Display_In,
            Is_BB_Default
					FROM dbo.DD_Reason_Code
					WHERE Deleted = 0 AND Display_In IN (2,3)
					ORDER BY DD_Reason_Code_Description
		</CFQUERY>
		<CFQUERY NAME="qGetPCCode" datasource="#application.datasource#">
				Select 	PC_Reason_Code,
						PC_Reason_Code_Id,
						PC_Reason_Code_Description
					from dbo.PC_Reason_Code
					where deleted = 0
					  order by PC_Reason_Code_Description
		</CFQUERY>
		<CFQUERY NAME="qGetGLCode" datasource="#application.datasource#">
				Select 	GL_Reason_Code,
						GL_Reason_Code_Id,
						GL_Reason_Code_Description
					from dbo.GL_Reason_Code
					where deleted = 0
					  order by GL_Reason_Code_Description
		</CFQUERY>
		
	<TABLE BORDER="0" CELLSPACING="0" CELLPADING="0" <CFIF IsDefined("Pay_Multi_Billbacks_ID") AND Not IsDefined("FullTableWidth")>WIDTH="85%" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF>>
	<cfoutput><cfset RcAvail = Get_data.Tot_Amount - qGetReasonAmountsum.totAmount></cfoutput>
		<CFIF ViewMode EQ 0>
			<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
				<CFQUERY name="qMultiBB" datasource="#application.datasource#">
					SELECT 	 top 1 Billback_ID as MBBID 
					FROM 	Pay_Multi_Billbacks_List
					WHERE 	Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND 
							Deleted = 0	
				</CFQUERY>
			</CFIF>
		<TR><cfset optlen = 30>
		   <input type="Hidden" name="rcBBId" value="<CFOUTPUT><CFIF IsDefined("Pay_Multi_Billbacks_ID")>#qMultiBB.MBBID#<CFELSE>#URL.BBID#</CFIF></CFOUTPUT>">
		    <input type="Hidden" name="BBReasonCodeAmountId" value="0"><!--- <cfoutput>#BBReasonCodeAmountId#</cfoutput> --->
			<input type="Hidden" name="delBBrc" value="no">
			<TD><SELECT NAME="DDCode" class="sel">
							<OPTION VALUE="" SELECTED class="opt">Set Reason</OPTION>
							<CFLOOP QUERY="qgetDDCode">
								<OPTION style="font-size: 1pt;" class="opt2" VALUE="<CFOUTPUT>#qgetDDCode.DD_Reason_Code_Id#</CFOUTPUT>" <CFIF Trim(qgetDDCode.DD_Reason_Code) EQ TRIM("xx")> SELECTED<cfelseif qgetDDCode.Is_BB_Default EQ 1>selected </cfif>><CFOUTPUT>#left(qgetDDCode.DD_Reason_Code_Description,optlen)#<cfif len(qgetDDCode.DD_Reason_Code_Description) gt optlen>...</cfif></CFOUTPUT></OPTION>
							</CFLOOP>
							</SELECT></TD>
			<TD><CFOUTPUT>
				<INPUT name="RCAmount" type="text" value="#numberformat(RcAvail,999999999.99)#" size="7" onkeyup="Numeric_Key_Only(this,0,1);allowonlytwodecimalplaces(this)"><SPAN ID="error_rcAmt"></SPAN></TD>
			<TD class="inp1"><cfif isdefined("RcAmountError")><cfif RcAmountError lt 0><SPAN ID="inp">Balance</SPAN><cfelse><SPAN ID="inp">Update Failed: +#numberformat(RcAmountError,999999999.99)#</SPAN></cfif><cfelse><SPAN ID="inp"></SPAN></cfif></CFOUTPUT></TD>
			<TD><SELECT NAME="PCCode" class="sel">
							<OPTION VALUE="" SELECTED  class="opt">Set Profit Center</OPTION>
							<CFLOOP QUERY="qgetPCCode">
								<OPTION class="opt2" VALUE="<CFOUTPUT>#qgetPCCode.PC_Reason_Code_Id#</CFOUTPUT>" <CFIF Trim(qgetPCCode.PC_Reason_Code) EQ TRIM("xx")> SELECTED</CFIF>><CFOUTPUT>#left(qgetPCCode.PC_Reason_Code_Description,optlen)#<cfif len(qgetPCCode.PC_Reason_Code_Description) gt optlen>...</cfif></CFOUTPUT></OPTION>
							</CFLOOP>
							</SELECT></TD>
			<TD><SELECT NAME="GLCode" class="sel">
							<OPTION VALUE="" SELECTED  class="opt">Set GL</OPTION>
							<CFLOOP QUERY="qgetGLCode">
								<OPTION class="opt2" VALUE="<CFOUTPUT>#qgetGLCode.GL_Reason_Code_Id#</CFOUTPUT>" <CFIF Trim(qgetGLCode.GL_Reason_Code) EQ TRIM("xx")> SELECTED</CFIF>><CFOUTPUT>#left(qgetGlCode.GL_Reason_Code_Description,optlen)#<cfif len(qgetGlCode.GL_Reason_Code_Description) gt optlen>...</cfif></CFOUTPUT></OPTION>
							</CFLOOP>
							</SELECT></TD>
			<TD><CFOUTPUT><table>
						<tr>
							<td align="center"><CF_button
								button_name		=	""
								button_caption	=	"save"
								button_action	=	"RCvalidate()"
								button_type		=	"javascript_link"
								button_width	=	"75"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"></td>
							<td><CF_button
								button_name		=	""
								button_caption	=	"reset"
								button_action	=	"resetReasonCode(#numberformat(RcAvail,999999999.99)#)"
								button_type		=	"javascript_link"
								button_width	=	"75"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"></td>
						</tr>
						</table></CFOUTPUT>	
								
					</TD>	
		</TR>
		</CFIF><!--- if viewmode --->
		<TR>
			<TD WIDTH="25%"><SPAN ID="error_rc"></SPAN><strong>Reason Code</strong></TD>
			<TD WIDTH="9%"><strong>Dollar Amt</strong></TD>
			<TD width="16%">&nbsp;</TD>
			<TD WIDTH="20%"><SPAN ID="error_pc"></SPAN><strong>Profit Center</strong></TD>
			<TD WIDTH="30%" colspan="2"><SPAN ID="error_gl"></SPAN><strong>Gl code</strong></TD>	
		</TR>
<CFOUTPUT QUERY="qGetReasonAmount"> 
      <!---   <input type="Hidden" name="BBReasonCodeAmountId" value="BBReasonCodeAmountId"> --->
	  <cfset totrcbal = RcAvail + ReasonAmount>
		<TR onMouseOver="CellOn(this)" onMouseOut="CellOff(this)" id="rowedit#BBReasonCodeAmountId#" ONCLICK="javaScript: editReasonCode('#numberformat(ReasonAmount,999999999.99)#','#DD_Reason_Code_Id#','#PC_Reason_Code_Id#','#GL_Reason_Code_Id#','#BBReasonCodeAmountId#','#numberformat(totrcbal,999999999.99)#');return false;">
			<TD><span title="#DD_Reason_Code_description#" style="cursor: pointer">#DD_Reason_Code#</span></TD>
			<TD align="right">#dollarformat(ReasonAmount)#&nbsp;&nbsp;&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD><span title="#PC_Reason_Code_description#" style="cursor: pointer">#PC_Reason_Code#</span></TD>
			<TD><span title="#GL_Reason_Code_description#" style="cursor: pointer">#GL_Reason_Code#</span></TD>
			<TD align="center">
			<CFIF ViewMode EQ 0><span id="#DD_Reason_Code_Id##PC_Reason_Code_Id##GL_Reason_Code_Id#"></span>&nbsp;
			<cf_smallLink
			url="##"
			title="edit"
			parameters="STYLE=""cursor:pointer;"" ONCLICK=""javaScript: editReasonCode('#numberformat(ReasonAmount,999999999.99)#','#DD_Reason_Code_Id#','#PC_Reason_Code_Id#','#GL_Reason_Code_Id#','#BBReasonCodeAmountId#','#numberformat(totrcbal,999999999.99)#');return false;""">&nbsp;&nbsp;
			<a href="##" onclick="javaScript: delReasonCode('#BBReasonCodeAmountId#')"><img src="/images/scissor.gif" title="Remove Reason Code" border="0"></a>
			</cfif>
			</TD>	
		</TR>

 </CFOUTPUT>
	 <cfif qGetReasonAmount.recordcount gt 1> <!--- sum up the reason code amounts and display --->
	 		<TR>
				<TD align="right"><span style="border-top: Solid 1px red;"><strong>Sum:&nbsp;</strong></span></TD>
				<TD align="right" style="border-top: Solid 1px red;"><strong><cfoutput>#dollarformat(qGetReasonAmountsum.totAmount)#</cfoutput></strong>&nbsp;&nbsp;&nbsp;</TD>
				<TD>&nbsp;</TD>
				<TD></TD>
				<TD colspan="2"></TD>
			</TR>
	 </cfif> 
		<TR>
			<TD COLSPAN="100%"><HR COLoR="ORANGE"></TD>
		</TR>
	</TABLE>

	
<SCRIPT>
//Edit xxxxxxxxxxxxxxxxxxxxxxxxxxx
		function editReasonCode(amt,ddc,pcc,glc,rcbid,rcbal){
		document.all.RCAmount.value = amt;
		findoptiondd(ddc);
		findoptionpc(pcc);
		findoptiongl(glc);
		document.all.BBReasonCodeAmountId.value = rcbid;
		//document.all.inp.style.width = 0;
		document.all.inp.innerHTML = "Balance " + rcbal;
	
	}
//populate select boxes findoption(x)	
function findoptiondd(x) {
  var outvar = '';
  var whichitem = 0;
  while (whichitem < document.all.DDCode.length) {
    if (document.all.DDCode.options[whichitem].value == x) {
      document.all.DDCode.options[whichitem].selected = true;
      }
      whichitem++;
    }
	}
	function findoptionpc(x) {
  var outvar = '';
  var whichitem = 0;
  while (whichitem < document.all.PCCode.length) {
    if (document.all.PCCode.options[whichitem].value == x) {
      document.all.PCCode.options[whichitem].selected = true;
      }
      whichitem++;
    }
	}
	function findoptiongl(x) {
  var outvar = '';
  var whichitem = 0;
  while (whichitem < document.all.GLCode.length) {
    if (document.all.GLCode.options[whichitem].value == x) {
      document.all.GLCode.options[whichitem].selected = true;
      }
      whichitem++;
    }
	}
	
	// Reset xxxxxxxxxxxxxxxxxxx
	function resetReasonCode(availAmount){
		document.all.RCAmount.value = availAmount;
		document.all.DDCode.value = "";
		document.all.PCCode.value = "";
		document.all.GLCode.value = "";
		document.all.BBReasonCodeAmountId.value = 0;
		
		if(availAmount  > 0)			
	{
		document.all.inp.innerHTML = "Balance";
	}
	else
	{
		document.all.inp.innerHTML = "";
	}
	}
	
	//Delete xxxxxxxxxxxxxxxxxxxx
	function delReasonCode(rcbid){
		document.all.delBBrc.value = "yes";
		document.all.BBReasonCodeAmountId.value = rcbid;
		validate();
	}
// make sure something is selected xxxxxxxxxxxxxxxx
	function RCvalidate()
		{
    ErrorCount = 0;
	
	rcdocid = document.all.DDCode.value.toString() + document.all.PCCode.value.toString() + document.all.GLCode.value.toString();
	if ( document.getElementById(rcdocid)  != null && document.all.BBReasonCodeAmountId.value == 0) {
        ErrorCount++;
		error_text 		= "This combination exists.  Please use the edit function or input a new combination of Reason Codes.";
		queueMessage(error_text, document.getElementById(rcdocid));
   }
	
	
	if(document.all.DDCode.value == "" && document.all.RCAmount.value > 0)			
	{
		ErrorCount++;
		error_text 		= "The Reason Code field must have a value!";
		queueMessage(error_text, document.all.error_rc);
	}
	else
	{
		clearQueue(document.all.error_rc);
	}
	
	//document.all.RCAmount.value > <cfoutput>#RcAvail#</cfoutput> || 
	if(document.all.RCAmount.value < 0)			
	{
		ErrorCount++;
		error_text 		= "The Reason Code field must be greater than 0!";
		queueMessage(error_text, document.all.error_rcAmt);
	}
	else
	{
		clearQueue(document.all.error_rcAmt);
	}
	
	
	if(document.all.PCCode.value == "" && document.all.RCAmount.value > 0)			
	{
		ErrorCount++;
		error_text 		= "The Profit Center Code field must have a value!";
		queueMessage(error_text, document.all.error_pc);
	}
	else
	{
		clearQueue(document.all.error_pc);
	}
	
	
	if(document.all.GLCode.value == "" && document.all.RCAmount.value > 0)			
	{
		ErrorCount++;
		error_text 		= "The GL Code field must have a value!";
		queueMessage(error_text, document.all.error_gl);
	}
	else
	{
		clearQueue(document.all.error_gl);
	}
		
	
	if(ErrorCount == 0) 
	{
			validate();
	}
	else 
	{
		showMessageWindow()
	}	
		
		}

</SCRIPT>

<SCRIPT language="JavaScript">
	function CellOn(CellName)
		{
			eval("CellName.bgColor = '#EAFFEA'")
		}

	function CellOff(CellName)
		{
			eval("CellName.bgColor = '#FFFFFF'")
		}
</script>