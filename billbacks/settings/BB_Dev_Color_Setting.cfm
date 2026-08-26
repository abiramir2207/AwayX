<!---
       Name:          BB_Dev_Color_Setting.cfm
       Copyright:     Copyright (c) 2010 Blacksmith Applications, Inc.
       Created Date:  07/26/2010
       Created By:    Anand Rao
       Label:		  24193
       Description:
--->

<cfparam name="FORM.ExpBgColor"		default="" />
<cfparam name="FORM.ExpFontColor" 	default="" />
<cfparam name="FORM.ClmBgColor"		default="" />
<cfparam name="FORM.ClmFontColor"	default="" />
<cfparam name="FORM.EltBgColor"	  	default="" />
<cfparam name="FORM.EltFontColor"	default="" />
<cfparam name="FORM.SelBgColor"	  	default="" />
<cfparam name="FORM.SelFontColor"	default="" />
<cfparam name="FORM.submitted"		default="0" />

<cfset oBillbackColorSettings = createObject("component", "components.billback.BillbackSettingsManager") />

<cfif FORM.submitted eq 1>
  <cfset oBillbackColorSettings.saveBillbackColorSettings(FORM.ExpBgColor, FORM.ExpFontColor, FORM.ClmBgColor, FORM.ClmFontColor, FORM.EltBgColor, FORM.EltFontColor, FORM.SelBgColor, FORM.SelFontColor, request.AccessStructure.User_ID) />
  <script>
  	window.opener.location.reload();
  	this.close();
  </script>
</cfif>

<cfset qGetBBDevColorSetting	= oBillbackColorSettings.getBBDevColorSetting() />	
<cfset FORM.ExpBgColor			= qGetBBDevColorSetting.ExpBtnBgColor />
<cfset FORM.ExpFontColor		= qGetBBDevColorSetting.ExpBtnFontColor />
<cfset FORM.ClmBgColor        	= qGetBBDevColorSetting.ClmBtnBgColor />
<cfset FORM.ClmFontColor      	= qGetBBDevColorSetting.ClmBtnFontColor/>
<cfset FORM.EltBgColor        	= qGetBBDevColorSetting.EltBtnBgColor />
<cfset FORM.EltFontColor      	= qGetBBDevColorSetting.EltBtnFontColor  />
<cfset FORM.SelBgColor        	= qGetBBDevColorSetting.SelBtnBgColor />
<cfset FORM.SelFontColor      	= qGetBBDevColorSetting.SelBtnFontColor />

<script language="JavaScript">
	function submitForm()
	{
		document.frmColorSetting.submitted.value = 1;
		document.frmColorSetting.submit();
		return false;
	}
</script>


<form action="/billbacks/settings/BB_Dev_Color_Setting.cfm" method="post" name="frmColorSetting" id="frmColorSetting">
<script type="text/javascript" src="jscolor.js"></script>
<script language="javascript">
	function RGBtoHex(R)
	{
		if (R ==null) return "000000";
		if (R=="#000") return "000000";
		if (R=="#fff") return "FFFFFF";
	}
	function RGBtoHex_main(R,G,B) {return toHex(R)+toHex(G)+toHex(B)}
	function toHex(N)
	{
	 if (N==null) return "00";
	 N=parseInt(N); if (N==0 || isNaN(N)) return "00";
	 N=Math.max(0,N); N=Math.min(N,255); N=Math.round(N);
	 return "0123456789ABCDEF".charAt((N-N%16)/16)
		  + "0123456789ABCDEF".charAt(N%16);
	}

function fnSetColorVals(choice)
{
	// alert(document.frmTest.myBoth.value);
	// alert(RGBtoHex(document.getElementById('myBoth').style.color));

	if (choice=='Exp')
	{
		document.frmColorSetting.ExpFontColor.value= RGBtoHex(document.getElementById('clrExp').style.color);
		document.frmColorSetting.ExpBgColor.value = document.frmColorSetting.clrExp.value;
	}
	else if(choice=='Clm')
	{
		document.frmColorSetting.ClmFontColor.value= RGBtoHex(document.getElementById('clrClm').style.color);
		document.frmColorSetting.ClmBgColor.value = document.frmColorSetting.clrClm.value;

	}
	else if(choice=='Elt')
	{
		document.frmColorSetting.EltFontColor.value= RGBtoHex(document.getElementById('clrElt').style.color);
		document.frmColorSetting.EltBgColor.value = document.frmColorSetting.clrElt.value;
	}
	else if(choice=='Sel')
	{
		document.frmColorSetting.SelFontColor.value= RGBtoHex(document.getElementById('clrSel').style.color);
		document.frmColorSetting.SelBgColor.value = document.frmColorSetting.clrSel.value;
	}
}

	</script>
<cfif Len(trim(qGetBBDevColorSetting.BtnColor_Updated_By)) GT 0>
<br />
<table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="2">
	<tr>
		<td>
			<cfoutput>
			<font size="2"><B>The settings were last updated on #dateformat(qGetBBDevColorSetting.BtnColor_Updated_Date, 'mm/dd/yyyy')# #timeformat(qGetBBDevColorSetting.BtnColor_Updated_Date, 'hh:mm:ss TT')# by #qGetBBDevColorSetting.Updated_By#</B></FONT>
			</cfoutput>
		</td>
	</tr>
</table>
</cfif>
<br><font color="navy" size=2><b><span class="subheading">Billback Deviation Grid - Settings</span></b></font><br><br>
  <cfoutput>
  <table border="0" cellspacing="1">
    <tr>
      <td></td>
      <td>(Click below to pick color)</td>
      <td>
      </td>
      <td>
      </td>
    </tr>
 	  <tr>
      <td style="font-weight:bold">
			  Expected $:&nbsp;
		  </td>
      <td>
        <input class="color {valueElement:'clrExp',styleElement:'clrExp'}" id="clrExp" name="clrExp" onchange="javascript:fnSetColorVals('Exp');" title="Click to pick the color" style="background:###ExpBgColor#;color:###ExpFontColor#;cursor:pointer;" value="#ExpBgColor#">
      </td>
      <td>
  	    &nbsp;&nbsp;&nbsp;BackGround Color: <input type="text" id="ExpBgColor" name="ExpBgColor" value="#FORM.ExpBgColor#"/>
        <input type="hidden"  id="ExpFontColor" name="ExpFontColor" value="#ExpFontColor#"/>
      </td>
  	</tr>
    <tr>
      <td style="font-weight:bold">
			  Expected LT $:&nbsp;
		  </td>
      <td>
	      <input class="color {valueElement:'clrElt',styleElement:'clrElt'}" id="clrElt" onchange="javascript:fnSetColorVals('Elt');" title="Click to pick the color" style="background:###EltBgColor#;color:###EltFontColor#;cursor:pointer;" value="#EltBgColor#">
      </td>
      <td>
        &nbsp;&nbsp;&nbsp;BackGround Color: <input type="text" id="EltBgColor"  name="EltBgColor" value="#FORM.EltBgColor#" />
         <input type="hidden" id="EltFontColor"  name="EltFontColor" value="#FORM.EltFontColor#" />
      </td>
   	</tr>    
  	<tr>
      <td style="font-weight:bold">
			  Claimed $:&nbsp;
		  </td>
      <td>
  	    <input class="color {valueElement:'clrClm',styleElement:'clrClm'}" id="clrClm" onchange="javascript:fnSetColorVals('Clm');" title="Click to pick the color" style="background:###ClmBgColor#;color:###ClmFontColor#;cursor:pointer;" value="#ClmBgColor#">
      </td>
      <td>
         &nbsp;&nbsp;&nbsp;BackGround Color: <input type="text" id="ClmBgColor" name="ClmBgColor" value="#FORM.ClmBgColor#" />
         <input type="hidden" id="ClmFontColor"  name="ClmFontColor" value="#FORM.ClmFontColor#" />
      </td>
  	</tr>
  	
  	<tr>
      <td style="font-weight:bold">
			  Selected $:&nbsp;
		  </td>
      <td>
    	  <input class="color {valueElement:'clrSel',styleElement:'clrSel'}" id="clrSel" onchange="javascript:fnSetColorVals('Sel');" title="Click to pick the color" style="background:###SelBgColor#;color:###SelFontColor#;cursor:pointer;" value="#SelBgColor#">
      </td>
      <td>
         &nbsp;&nbsp;&nbsp;BackGround Color: <input type="text" id="SelBgColor"  name="SelBgColor" value="#FORM.SelBgColor#" />
         <input type="hidden"  id="SelFontColor"  name="SelFontColor" value="#FORM.SelFontColor#" />
      </td>
   	</tr>
	  <tr>
		  <td></td>
		  <td align="center">
			  <br />
			  <CF_smallLink
				  title = "save"
  				url = "##"
	  			parameters = "onClick=""javascript: return submitForm();"""
		  	>
      </td>
	  </tr>
  </table>
</cfoutput>
<input name="submitted" type="hidden" value="0" />
</form>
