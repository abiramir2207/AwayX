<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
<CFSET FORM.Lock_Status = 1>
<CFINCLUDE TEMPLATE="/Billbacks/Multi_BB_Payment/Lock_BB.cfm">
</CFIF>


<CFOUTPUT>
<CFQUERY NAME="Get_Tot_Amount" DATASOURCE="#Application.Datasource#">
	SELECT 		Tot_Amount,
				Payment_Data_Export_1_ID,
				Billback_ID
				
	FROM 		Payment_Data_Export_1
	
	WHERE 		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
				<CFELSE>
					Billback_ID='#BBID#' AND 
				</CFIF>
				Payment_Trans_ID=#Payment_Trans_ID# AND Deleted=0 AND Saved=1					
</CFQUERY>

<CFQUERY NAME="Get_Details" DATASOURCE="#Application.Datasource#">
	SELECT 		Payment_Data_Export_2.GL_Type_ID,
				Payment_Data_Export_2.Amount,
				Payment_Data_Export_2.Q_Brand_ID,
				GL_Code.Descr,
				Payment_Data_Export_2.Billback_ID Billback_ID,
				BB_Code
	
	FROM		Payment_Data_Export_2
	INNER JOIN 	GL_Code ON GL_Code.Q_Brand_ID = Payment_Data_Export_2.Q_Brand_ID
				AND GL_Code.GL_Type_ID = Payment_Data_Export_2.GL_Type_ID
				AND GL_Code.Deleted=0
	INNER JOIN	Billback ON Billback.Billback_ID = Payment_Data_Export_2.Billback_ID
	
	WHERE 		Payment_Data_Export_1_ID = 	'#Get_Tot_Amount.Payment_Data_Export_1_ID#' AND Payment_Data_Export_2.Deleted=0
	ORDER BY 	BB_Code,GL_Code.Q_Brand_Description	
</CFQUERY>
<CFSET Q_Brand_ID_List = #ValueList(Get_Details.Q_Brand_ID)#>
</CFOUTPUT>


<CFQUERY NAME="All_GL_Type" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Type ORDER BY GL_Type_Desc
</CFQUERY>


<SCRIPT LANGUAGE="JavaScript">
	function setRadioChecked(index)
	{
		event.returnValue = false;
		var mainChObj = null;
		var GL_Type_ID = "";
		var bChecked = false;
		var GL_Type_Desc_CheckObj = document.all.GL_Type_Desc_Check;
		var totalLen = 0;
		if(document.all.JS_GL_Type_Count)
		{
			totalLen = parseInt(document.all.JS_GL_Type_Count.value);
		}
		
		if(GL_Type_Desc_CheckObj)
		{
			if(GL_Type_Desc_CheckObj.length)
			{
				if(GL_Type_Desc_CheckObj.length >= index)
				{
					mainChObj = GL_Type_Desc_CheckObj[index-1];
				}
			}
			else if(index == 1)
			{
				mainChObj = GL_Type_Desc_CheckObj;
			}
			
			if(mainChObj)
			{
				bChecked = mainChObj.value;
				GL_Type_ID = mainChObj.GL_Type_ID;
				mainChObj.value = (bChecked==1?0:1);
				var i;		
				for(i=1;i<=totalLen;i++)
				{
					var chObj = eval("document.all.GL_Type_" + i);
					setCheckForThisID(chObj, index-1, GL_Type_ID, bChecked);			
				}
			}
		}
	}
	
	function setCheckForThisID(chObj, index, GL_Type_ID, bChecked)
	{
		var i;
		if(chObj.length)
		{
			for(i=0;i<chObj.length;i++)
			{
				if(chObj[i].value == GL_Type_ID)
				{
					chObj[i].checked = bChecked;
				}				
			}
		}
		else
		{			
			if(chObj.value == GL_Type_ID)
			{
				chObj.checked = bChecked;
			}
		}
	}
</SCRIPT>	
<BR><BR>
<CFOUTPUT>
<FORM NAME="Select_GL_Type" ACTION="View_Edit_Approve.cfm?BBID=#URL.BBID#<CFIF ISDefined("Pay_Multi_Billbacks_ID")>&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#</CFIF>&Payment_Data_Export_1_ID=#URL.Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_GL_Type=1<CFIF isdefined("URL.Edit_Payee_Info")>&Edit_Payee_Info=1</CFIF>" METHOD="Post">
</CFOUTPUT>

<!--- <INPUT TYPE="Hidden" NAME="Q_Brand_ID" VALUE=<CFOUTPUT>"#Q_Brand_ID_List#"</CFOUTPUT>> --->

<TABLE BORDER="0" <CFIF ISDefined("Pay_Multi_Billbacks_ID")>WIDTH="750" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF> CELLSPACING="0" CELLPADING="0">
	<TR>
		<TD COLSPAN="100%"><FONT SIZE="2" COLOR="NAVY"><B>GL Type Selection</B></FONT><HR COLOR="Orange"></TD>
	</TR>
	<TR BGCOLOR="ffce84">
		<TD NOWRAP STYLE="Border-bottom:solid aqua 1px;"><B>Q_Brand</B></TD>
		<TD NOWRAP WIDTH="6%" STYLE="Border-bottom:solid aqua 1px;"><B>Total</B></TD>
		<TD NOWRAP  STYLE="Border-bottom:solid aqua 1px;">&nbsp;</TD>
		<CFOUTPUT QUERY="All_GL_Type">
			<TD NOWRAP ALIGN="Center"  STYLE="Border-bottom:solid aqua 1px;">
			<A HREF="void(0);" onClick="setRadioChecked(#CurrentRow#);return false;"><B>#UCASE(GL_Type_Desc)#</B></A>
			<INPUT TYPE="HIDDEN" NAME="GL_Type_Desc_Check" VALUE="0" GL_Type_ID="#GL_Type_ID#">
			</TD>
		</CFOUTPUT>
	</TR>
	<INPUT TYPE="Hidden" NAME="Payment_Data_Export_1_ID" VALUE=<CFOUTPUT>"#Get_Tot_Amount.Payment_Data_Export_1_ID#"</CFOUTPUT>>	
	<CFSET Count=0>
	<CFSET PreviousBB = "">
	<CFOUTPUT QUERY="Get_Details">	
	<INPUT TYPE="Hidden" NAME="Q_Brand_ID" VALUE="#Q_Brand_ID#">
	<INPUT TYPE="Hidden" NAME="MultiBBID" VALUE="#Billback_ID#">	
	<CFSET ReplacedBillback_ID = REPLACE(Billback_ID,"-","_","All")>
	<CFSET ThisBB = TRIM(BB_Code)>
	<CFSET Count=Count + 1>
	<CFSET Selected_GL_Type_ID = GL_Type_ID>
	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
		<CFIF IsDefined("Pay_Multi_Billbacks_ID") AND PreviousBB NEQ ThisBB>
		<TR>
			<TD COLSPAN="100%" STYLE="border-bottom: 1px solid ##aaaaaa;"><BR><B>Billback: #ThisBB#</B></TD>
		</TR>
		</CFIF>
		<TD STYLE="Border-bottom:solid aqua 1px;">#Get_Details.Descr#</TD> 
		<TD STYLE="Border-bottom:solid aqua 1px;" ALIGN="Right">#DollarFormat(Amount)#</TD>
		<cfset useLakebaseForAvailable_GL_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code")>
<cfif useLakebaseForAvailable_GL_Type>
	<cftry>
		<cfset Available_GL_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code", {
				"q_brand_id" = "eq.#Q_Brand_ID#",
				"deleted" = "eq.0",
				"order" = "gl_type_id.asc",
				"select" = "gl_type_id,descr"
			}), "gl_type_id,descr"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAvailable_GL_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAvailable_GL_Type>
<CFQUERY NAME="Available_GL_Type" DATASOURCE="#Application.Datasource#">
			SELECT GL_Type_ID,Descr FROM GL_CODE WHERE Q_Brand_ID = '#Q_Brand_ID#' AND DELETED=0 ORDER BY Gl_Type_ID
		</CFQUERY>
</cfif>
		<CFSET AVAIL_GL_Type = #ValueList(Available_GL_Type.GL_Type_ID)#>
		<TD NOWRAP STYLE="Border-bottom:solid aqua 1px;"><SPAN ID="Err_SP_#Count#_#ReplacedBillback_ID#" Descr="#Get_Details.Descr#">&nbsp;</SPAN></TD>
		<CFLOOP QUERY="All_GL_Type">
			<CFSET Place_Radio = "">
			<CFSET Place_Radio = #ListFind(AVAIL_GL_Type,"#GL_Type_ID#")#>
			<CFIF Place_Radio NEQ 0>
				<CFSET Checked = "">
				<CFIF GL_Type_ID EQ Selected_GL_Type_ID>
					<CFSET Checked="Checked">
				</CFIF>
				<TD STYLE="Border-bottom:solid aqua 1px;" ALIGN="Center"><INPUT TYPE="Radio" NAME="GL_Type_#Count#_#ReplacedBillback_ID#" VALUE="#GL_Type_ID#" #Checked#></TD>
			<CFELSE>
				<TD STYLE="Border-bottom:solid aqua 1px;">&nbsp;</TD>
			</CFIF>
		</CFLOOP>
	</TR>
	<CFSET PreviousBB = ThisBB>
	</CFOUTPUT>
	<INPUT TYPE="HIDDEN" NAME="JS_GL_Type_Count" VALUE="<CFOUTPUT>#Count#</CFOUTPUT>">
	<TR>
		<TD ALIGN="Right"><B>TOTAL</B></TD>
		<TD Align = "Right"><CFOUTPUT><B>#DollarFormat(Get_Tot_Amount.Tot_Amount)#</B></CFOUTPUT></TD>
		<CFOUTPUT QUERY="All_GL_Type">
		<TD>&nbsp;</TD>
		</CFOUTPUT>
	</TR>
	<TR>
		<TD COLSPAN="100%"><HR COLOR="Orange"></TD>
	</TR>
</TABLE>

<BR><BR><BR>
<TABLE ALIGN="CENTER">
<TR>
	<TD>
		<CFOUTPUT>
				<CF_button
					button_name		=	""
					button_caption	=	"Save Changes"
					button_action	=	"validate()"
					button_type		=	"javascript_link"
					button_width	=	"120"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
					>
			</CFOUTPUT>
	</TD>
</TR>
</TABLE>
</FORM>
<CF_MessageWindow>
<script src="/script/javascript/validations.js"></script>
<SCRIPT language="JavaScript">
<cfoutput>var billbackIdList = "#ValueList(Get_Details.Billback_ID, ",")#"</cfoutput>
function validate()
{
	var bErr = false;
	var totalLen = 0;
	var bbIdArray = billbackIdList.split(",");
	if(document.all.JS_GL_Type_Count)
	{
		//totalLen = parseInt(document.all.JS_GL_Type_Count.value);
		totalLen = bbIdArray.length;
	}
	var i, bbId;		
	for(i=1;i<=totalLen;i++)
	{
		bbId = bbIdArray[i-1].replace(/-/ig, "_");
		var chObj = eval("document.all.GL_Type_" + i + "_" + bbId);
		var spObj = eval("document.all.Err_SP_" + i + "_" + bbId);
		if(AnyRadioChecked(chObj))
		{			
			clearQueue(spObj);
		}
		else
		{
			bErr = true;
			queueMessage("Select a GL Type for '" + spObj.Descr + "'", spObj);
		}
	}
	if(bErr)
	{
		showMessageWindow();
	}
	else	
	{
		document.Select_GL_Type.submit();
	}
}
</SCRIPT>
