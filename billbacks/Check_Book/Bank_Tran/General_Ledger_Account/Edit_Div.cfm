

<!--- <CFOUTPUT>
	<DIV STYLE="width:90px;">
	<B>
	<FONT SIZE="2" COLOR="Blue"><A Href="Edit_GL_Type.cfm?BBID=#URL.BBID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_GL_Type=1">gl type</A></FONT>
	</B>&nbsp;	<BR>
	<B>
	<FONT SIZE="2" COLOR="Blue"><A Href="View_Edit_Approve.cfm?BBID=#URL.BBID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_Payee_Info=1">payee info</A></FONT>
	</B>&nbsp;	<BR>
	<B>
	<FONT SIZE="2" COLOR="Blue"><A Href="Edit_GL_Type.cfm?BBID=#URL.BBID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_GL_Type=1&Edit_Payee_Info=1">both</A></FONT>
	</B>&nbsp;	
	</DIV>
	</CFOUTPUT> --->


	
	
<STYLE>
a {
	color: Blue;
	text-decoration: none;	
}
.bottomThin TD
{
	border-bottom:2px Navy solid;
}

</STYLE>
<CFOUTPUT>
<DIV ID="oDiv_Traffic" STYLE="display:none;position:absolute;border:3px Navy solid; width: 200px; height: 150px; padding:10px;overflow:auto;background-color:White;" ONMOUSEOUT="javaScript: divout(this);">
	<TABLE border="0" cellpadding="2" cellspacing="0" WIDTH="70%" >
		<TR CLASS="bottomThin">
			<TD><FONT SIZE="2"><B>Make changes to:</B></FONT>
			&nbsp;
			<!--- <B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="##" onClick="javaScript: return hideGlossaryDiv();">close</A>&nbsp;<FONT COLOR="Red">]</FONT></B> --->
			</TD>
		</TR>
	</TABLE>
	<TABLE border="0" cellpadding="2" cellspacing="0" WIDTH="90%" ALIGN="center">
		<TR><BR>
			<TD>
				<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					<A Href="Edit_GL_Type.cfm?BBID=#URL.BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_GL_Type=1"><FONT SIZE="2"><B>GL Type</B></FONT></A>
				<CFELSE>
					<A Href="Edit_GL_Type.cfm?BBID=#URL.BBID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_GL_Type=1"><FONT SIZE="2"><B>GL Type</B></FONT></A>						
				</CFIF>
			</TD>
		</TR>
		<TR>
			<TD>
				<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					<A Href="View_Edit_Approve.cfm?BBID=#URL.BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_Payee_Info=1"><FONT SIZE="2"><B>Payee Info</B></FONT></A>
				<CFELSE>
					<A Href="View_Edit_Approve.cfm?BBID=#URL.BBID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_Payee_Info=1"><FONT SIZE="2"><B>Payee Info</B></FONT></A>			
				</CFIF>
			</TD>				
		</TR>
		<TR>
			<TD>
				<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					<A Href="Edit_GL_Type.cfm?BBID=#URL.BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_GL_Type=1&Edit_Payee_Info=1"><FONT SIZE="2"><B>Both</B></FONT></A>
				<CFELSE>
					<A Href="Edit_GL_Type.cfm?BBID=#URL.BBID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_GL_Type=1&Edit_Payee_Info=1"><FONT SIZE="2"><B>Both</B></FONT></A>			
				</CFIF>
			</TD>
		</TR>
		<TR>
		<TD ALIGN="Right"><B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="##" onClick="javaScript: return hideGlossaryDiv();">close</A>&nbsp;<FONT COLOR="Red">]</FONT></B></TD>
		</TR> 
	</TABLE>
</DIV>
</CFOUTPUT>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">
<SCRIPT>

function divout(thisObj)
{
	var divObj = document.all.oDiv_Traffic;
	var thisObjsParent = getParentObject(event.toElement, "div");
	if(thisObjsParent == divObj)
	{
	
	}
	else
	{
		hideGlossaryDiv();
	}
}


function hideGlossaryDiv()
{  
	var divObj = document.all.oDiv_Traffic;
	divObj.style.display = "none";
	event.cancelBubble = true;
	event.returnValue = false;
	return false;
}

function showtrafficDiv()
{
	var divObj = document.all.oDiv_Traffic;
	var wid,hei;
	
	wid = event.clientX + 5;
	hei = event.clientY - 5;
	
	var aObj = getParentObject(event.srcElement, "a");
	if(aObj)
	{
		var l = getTotalOffsetProperty(aObj, "body", "offsetLeft", 0);
		wid = l + 35;
		var l = getTotalOffsetProperty(aObj, "body", "offsetTop", 0);
		hei = l + 5;
	}
	
	
	
	
	/*
	var winWidth = 100;
	var winHeight = 100;
	
	var newDivVal;
	newDivVal = divObj.style.width;
	newDivVal = parseInt(newDivVal);
	if(!isNaN(newDivVal))
	{
		winWidth = newDivVal;
	}
	newDivVal = divObj.style.height;
	newDivVal = parseInt(newDivVal);
	if(!isNaN(newDivVal))
	{
		winHeight = newDivVal;
	}
	
	wid = document.body.clientWidth;
	hei = document.body.clientHeight;
	
	wid = (wid/2) - (winWidth/2);
	hei = (hei/2) - (winHeight/2);
	*/
	if(divObj)
	{	
		divObj.style.left = wid;
		divObj.style.top = hei;
		divObj.style.display= "";
	}
	event.cancelBubble = true;
	event.returnValue = false;
}
</SCRIPT>
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
