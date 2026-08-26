<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><cfoutput>#getRFAtitle.report_name#</cfoutput></title>
<style>
	.tableheaders {
		font-size:13px;
		font-weight:bold;
		border-bottom:thin #FFFFFF 0px; 
			
	}	
	BODY, TD, .normal
	{
		font-family : Arial;
		font-size : 8pt;
		color : Black;
	}


	TABLE.Maintable TD
	{
		border-bottom:solid #93BEE2 1px; font-size : 11px; border-right:solid #93BEE2 1px;}

		
	}
	#header {font-size: 13px; color: black; font-weight:bold;}
	.normal
	{
		font-family : Arial;
		font-size : 8pt;
		color : Black;
	}	
	TABLE.Summary TD
	{
		border:none;
	}
	
	#nostyle
	{
	border-right:none;
	}
	#SP_Details
	{
	overflow:auto;
	width:100%;
	height:500px;
	}

</style>
<style type="text/css" media="screen">
<!--
.printDiv { overflow: auto;} 
.thead2 { display: none } 
-->
</style>
<style type="text/css" media="print">
<!--
.printDiv { overflow: visible;}
.Maintable { width:650;}
thead { display: table-header-group } 
.thead1 { display: none } 
-->
</style>

</head>

<body>
<cfset totalCols = 9 />
<table class="Maintable" BORDER="0" CELLPADDING="1" CELLSPACING="0" width="800">
<!--- <thead class="thead1"> --->
<thead class="thead1">
<TR bgColor="ffce84">
    <TD id=nostyle colSpan=6><B><cfoutput>#getRFAtitle.report_name#</cfoutput></B></TD>
    <TD id=nostyle colSpan=3 align="right"><B>Report Run Date:</B> <B><cfoutput>#Dateformat(now(),"mm/dd/yyyy")#</cfoutput></B></TD></TR>
  <TR>
  <tr bgColor="ffce84">
<td ID="header" align="center" width="80">Program Number</td>
<td ID="header" align="center" width="200">Program Title</td>
<td ID="header" align="center"  width="60">Program Vol.<br>(Cases)</td>
<td ID="header" align="center"  width="70">Start <br> Date</td>
<td ID="header" align="center"  width="70">End <br>Date</td>
<td ID="header" align="center"  width="40">Days In <br>RFA Status</td>
<td ID="header" align="center" width="80">Currently responsible for approval</td>
<td ID="header" align="center" width="100">
<cfoutput>#application.returned_customer_setting.type_code_label_singular#</cfoutput></td>
<td ID="header" align="center" width="80">Responsible profile</td>
  </tr>
 </thead>
</table>
<span class="printDiv" style="height:500px;width:820;" >
<table BORDER="0" CELLPADDING="1" CELLSPACING="0" width="800" class="Maintable">
<colgroup>
	<col span="1" width="80"></col>
	<col span="1" width="200"></col>
	<col span="1" width="60"></col>
	<col span="2" width="70"></col>
	<col span="1" width="40"></col>
	<col span="1" width="80"></col>
	<col span="1" width="100"></col>
	<col span="1" width="80"></col>	
</colgroup>

 
 <thead class="thead2">
 	<tr>
    <TD id=nostyle colSpan="6"><B><cfoutput>#getRFAtitle.report_name#</cfoutput></B></TD>
    <TD id=nostyle colSpan="3" align="right"><B>Report Run Date:</B> <B><cfoutput>#Dateformat(now(),"mm/dd/yyyy")#</cfoutput></B></TD></TR>
  <TR>
  <tr bgColor="ffce84">
<td ID="header" align="center" width="80">Program Number</td>
<td ID="header" align="center" width="200">Program Title</td>
<td ID="header" align="center"  width="60">Program Vol.<br>(Cases)</td>
<td ID="header" align="center"  width="70">Start <br> Date</td>
<td ID="header" align="center"  width="70">End <br>Date</td>
<td ID="header" align="center"  width="40">Days In <br>RFA Status</td>
<td ID="header" align="center" width="80">Currently responsible for approval</td>
<td ID="header" align="center" width="100">
<cfoutput>#application.returned_customer_setting.type_code_label_singular#</cfoutput></td>
<td ID="header" align="center" width="80">Responsible profile</td>
</TR>
 </thead> 
 <tr bgColor="ffffff">
<td ID="header" align="center" width="80"></td>
<td ID="header" align="center" width="200"></td>
<td ID="header" align="center"  width="60"></td>
<td ID="header" align="center"  width="70"></td>
<td ID="header" align="center"  width="70"></td>
<td ID="header" align="center"  width="40"></td>
<td ID="header" align="center" width="80"></td>
<td ID="header" align="center" width="100"></td>
</TR>
<!---  <tr>
 <td colspan="8">  --->
<!---  <table class="Maintable" BORDER="0" CELLPADDING="1" CELLSPACING="0"> --->
  <cfoutput query="getAllRFAPrograms" group="Region_Name"> 
      <tr BGCOLOR="ddddd"> 
        <td colspan="#totalCols#"> <b>
          <cfif Region_Name EQ "">
            Region : No Region 
            <cfelse>
            Region : #Region_Name# 
          </cfif>
          </b> </td>
      </tr>
      <cfoutput group="market_name"> 
       <tr BGCOLOR="b8b8b8"> 
          <td colspan="#totalCols#"> <b>
            <cfif market_name EQ "">
              Market: No Market 
              <cfelse>
              Market : #market_name# 
            </cfif>
            </b> </td>
        </tr>
        <cfoutput group="generic_type"> 
          <tr bgcolor="FFD3A8"> 
            <td colspan="#totalCols#"> <b>Program Type: #generic_type#</b> 
		</tr>
          <cfset rowcount = 0>
          <cfoutput group="contract_number"> 
            <!--- <tr BGCOLOR="99FF66"> --->
            <TR <CFIF rowcount mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>> 
              <td valign="top" width="80"><strong>#Contract_Number#</strong></td>
              <td valign="top"  width="200">#contract_title#</td>
              <td valign="top" width="60" align="center"  >#trim(numberformat(Round(ProgramVolume),'_-___,___,___,___,___'))#</td>
              <td valign="top" width="70" >#Trim(Dateformat(contract_start_date,"mm/dd/yyyy"))#</td>
              <td valign="top" width="70" align="center"  >#Trim(Dateformat(contract_end_date,"mm/dd/yyyy"))#</td>
              <td valign="top" width="40" align="center">#NoofdaysinRFA#</td>
			  <td valign="top" width="80" align="center">
				<cfif Position_To_Approve_Label is not "">#Position_To_Approve_Label#<br>#Approve_Authority_Sequence_Name#</cfif>
				<cfif Num_Of_Days_In_CRA IS NOT "">(#Num_Of_Days_In_CRA# days) <cfelse>(#NoofdaysinRFA# days)</cfif>
			  </td>
              <td colspan="2" valign="top"> <cfset typecount = 0> 
			  <cfoutput group="type_code_desc"> 
                  <CFIF typecount GT 0>
                    <hr color="93BEE2" size="1">
                  </cfif>
                  <table width="100%" border="0" cellspacing="0" class="summary">
                    <tr> 
                      <td width="50%" valign="top">#type_code_desc#<br></td>
                      <td width="50%"> <cfset profile_count = 1> 
					  <cfoutput> 
                          <cfif profiles_desc is not "">
                            (#profile_count#). #profiles_desc#<br>
                            <cfset profile_count = profile_count + 1>
                          </cfif>
                      </cfoutput> </td>
                    </tr>
                  </table>
                  <cfset typecount = typecount + 1>
              </cfoutput><!------ type_code_desc ----->
			  </td>
            </tr>
            <cfset rowcount = rowcount + 1>
          </cfoutput><!------ contract_number ----->	  
		  </cfoutput><!------ generic_type ----->
		  </cfoutput><!------ market_name ----->
	</cfoutput><!------ Region_Name ----->

</td>
 </tr>

  </table></span>
  <table BORDER="0" CELLPADDING="1" CELLSPACING="0" width="800" class="Maintable">
 <tr bgColor="ffce84">
  <td colspan="8">
  <b>Total Program Count is <cfoutput>#getTotalPrograms.totalprograms#</cfoutput></b>
  </td>
  </tr>
  </table>

</body>
</html>
