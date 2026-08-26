<CFIF NOT isDefined("FORM.SelectedAR")>
	<CFOUTPUT>
	<FORM ACTION="" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="SelectedAR" TYPE="Hidden" VALUE="">
		<INPUT NAME="Fiscal_year" TYPE="Hidden" VALUE="#URL.Fiscal_year#">
	</FORM>	
	<script>
		var op = window.opener;
		if(op)
		{
			var parentForm = op.document.BasicInfo;
			if(parentForm)
			{				
				var arObj = eval("parentForm.SelectedAR_#Fiscal_Year#")
				if(arObj)
				{
					document.MyForm.SelectedAR.value = arObj.value;
				}
				document.MyForm.submit();
			}
		}		
	</script>
	<cfabort>
	</CFOUTPUT>
</CFIF>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFSET Fiscal_Year = Fiscal_year>
<CFPARAM NAME="FORM.finishedSelection" DEFAULT="0">

<CFIF FORM.finishedSelection EQ 1>
	<script language="JavaScript">
	submitOpener();
	function submitOpener()
	{
		var op = window.opener;
		if(op)
		{
			var parentForm = op.document.BasicInfo;
			if(parentForm)
			{				
				var fisYear = "<CFOUTPUT>#Fiscal_Year#</CFOUTPUT>"
				var arObj = eval("parentForm.SelectedAR_"+fisYear)
				if(arObj)
				{
				arObj.value = "<CFOUTPUT>#FORM.SelectedAR#</CFOUTPUT>";
				}
				parentForm.submit();
				window.close();
			}
		}
	}
	</script>	
</CFIF>

<CFQUERY NAME="GetAllAR" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT 	A_R,
							A_R_DESCRIPTION,
							GL_Code_Upload.Fiscal_Year
	FROM 		GL_Code_Activation
	INNER JOIN 	GL_Code_Upload ON GL_Code_Upload.GL_Code_Upload_ID = GL_Code_Activation.GL_Code_Upload_ID AND 
				GL_Code_Upload.Deleted = 0
				
	WHERE 		GL_Code_Activation.Deleted = 0 AND 
				<!--- GL_Code_Activation.Current_Active_Data = 1 AND --->
				DATEDIFF(d,getdate(),GL_Code_Upload.Activation_Date) <= 0 AND
				GL_Code_Upload.Fiscal_Year = '#Fiscal_year#'

	ORDER BY	A_R			
</CFQUERY>

<STYLE>
TABLE.Underlinedtable TD 
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>

<BR><BR>

<CFOUTPUT>
<FORM NAME="ARList" ACTION="AR_List.cfm" METHOD="POST">
<INPUT TYPE="Hidden" NAME="finishedSelection" VALUE="0">
<INPUT TYPE="Hidden" NAME="Fiscal_year" VALUE="#Fiscal_year#">
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="center" CLASS="Underlinedtable">
	<TR>
		<TD COLSPAN="100%" ALIGN="Center" STYLE="Border-Bottom: none"><B><FONT COLOR="navy" SIZE="2">A/R from Fiscal Year #Fiscal_year#</FONT></B><BR><BR></TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" STYLE="Border-Bottom: None">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD STYLE="Border-Bottom: None"><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: SubmitToProgtemp()">import selections</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;&nbsp;</TD>
					<TD STYLE="Border-Bottom: None"><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: UncheckAll()">undo selections</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;&nbsp;</TD>
					<TD STYLE="Border-Bottom: None"><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: Closewindow()">close</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
	<TR BGCOLOR="FFE083">
		<TD><INPUT TYPE="Checkbox" NAME="SelectAll" ONCLICK="javaScript: selectAll(this);"></TD>
		<TD><B>A/R</B></TD>
		<TD><B>Description</B></TD>
	</TR>
	
	<CFLOOP QUERY="GetAllAR">
	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<TD><INPUT TYPE="Checkbox" NAME="SelectedAR" VALUE="#A_R#" <CFIF SelectedAR NEQ ""><CFIF ListFindNoCase(SelectedAR,A_R,",")>CHECKED</CFIF></CFIF>></TD>
		<TD>#A_R#</TD>
		<TD>#A_R_DESCRIPTION#</TD>
	</TR>
	</CFLOOP>
</TABLE>
<BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: SubmitToProgtemp()">import selection</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;&nbsp;</TD>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: UncheckAll()">undo selections</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;&nbsp;</TD>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: Closewindow()">close</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
	</TR>
</TABLE>   
</FORM>
</CFOUTPUT>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT language="JavaScript">
function selectAll(thisobj)
{
	//var fisYear = "<CFOUTPUT>#Fiscal_Year#</CFOUTPUT>"
	var bCheck = thisobj.checked;
	//var chObjs = eval("document.all.SelectedAR_"+fisYear)
	var chObjs = document.all.SelectedAR;
	if(chObjs.length)
	{
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++)
		{
			chObjs[i].checked = bCheck;
		}
	}
	else
	{
		chObjs.checked = bCheck;
	}	
}

function SubmitToProgtemp()
{	
	var fisYear = "<CFOUTPUT>#Fiscal_Year#</CFOUTPUT>";
	//var CheckBoxVar = eval("document.all.SelectedAR_"+fisYear);
	var CheckBoxVar = document.all.SelectedAR;
	if(Any_Object_Checked(CheckBoxVar))
	{
		document.ARList.finishedSelection.value = 1;
		document.ARList.submit();			
	}
	else
	{
		alert("Please select at least one A/R to import.")
	}
}
</SCRIPT>

</body>
</html>
