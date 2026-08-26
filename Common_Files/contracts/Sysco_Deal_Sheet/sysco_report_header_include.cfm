<CFQUERY NAME="GetContractInformation" datasource="#application.datasource#">
	SELECT 	Contract_Main.*
	FROM 	Contract_Main		
	WHERE 	Contract_Main_ID = '#FORM.Contract_Main_ID#'
</CFQUERY>

 <cfoutput> <TR> 
          <TD COLSPAN="3"  ><B>Today's Date:</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- today's date goes here --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="4" BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080">&nbsp; &nbsp;#dateformat(now(),"mm/dd/yyyy")#</TD>
			
       		<TD colspan="4" rowspan="3" align="Center" valign="center">&nbsp; </td><TD colspan="3" rowspan="3" align="Center" valign="center"><img src="#application.HTTPVar##cgi.server_name#/images/LW__SPPlogo_borderless.jpg" alt=""  border="0"></TD>
        </TR>
		<TR> 
          <TD COLSPAN="3"  ><B>Report Date:</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- report date goes here --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="4" BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080" align="left">
			<cfif form.generatexlsreport EQ 0 AND DistributorCount IS 1 and CanEditProgram>
				<input type="text" name="ReportDate" value="#dateformat(ReportDate, 'mm/dd/yyyy')#" ONKEYUP="clenseText(this,'0123456789/');"><br>
				<CF_smallLink 
				title = "run report with new date" 
				url = "##"
				parameters = "onClick=""javascript: reRunReport();"""
				>
			<cfelse>
				&nbsp; &nbsp;#dateformat(ReportDate, 'mm/dd/yyyy')#
			</cfif>
			<cfif len(trim(ReportError)) GT 0 AND form.generatexlsreport EQ 0 AND DistributorCount IS 1 and CanEditProgram>
				<Br><font color="red"><strong>#ReportError#</strong></font>
			</cfif>
			</TD>
         <td>&nbsp; </td>
         
        </TR>
		
		
		
  <TR> 
          <TD  colspan="3"><strong>&nbsp; <br>Contract Number:</strong><br>&nbsp; </TD>
    
          
      
          <TD  colspan="4" align="right">&nbsp; <br><strong><font size="+1">#GetContractInformation.Contract_Number#<cfif GetContractInformation.contract_status_type_idx GT 2>-<cfif len(GetContractInformation.revision_version) eq 4>#right("#GetContractInformation.revision_version#", 4)#<cfelseif len(GetContractInformation.revision_version) eq 5>#right("#GetContractInformation.revision_version#", 5)#<cfelse>#right("000#GetContractInformation.revision_version#", 3)#</cfif></cfif></font></strong><br>&nbsp; </TD>
         
          <TD  >&nbsp;</TD>
        </TR>
		<cfif form.generatexlsreport EQ 1>
		  <TR> 
          <TD  colspan="3">&nbsp;</TD>
    
          
          
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
		  <TR> 
          <TD  colspan="3">&nbsp;</TD>
    
          
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
		  <TR> 
          <TD  colspan="3">&nbsp;</TD>
    
          
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
		  <TR> 
          <TD  colspan="3">&nbsp;</TD>
    
          
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
        <TR> 
		</cfif>
          <cfif form.generatexlsreport EQ 0 and CanEditProgram>
            <TD COLSPAN="3"  > <input type="checkbox" name="program_type" value="1" <cfif program_type IS 1>checked</cfif> disabled> 
              &nbsp;<B>Renewal</B></TD>
            <cfelse>
            <TD COLSPAN="2"  ><B>Renewal:</B></TD>
            <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080"  align="center"> 
              <cfif program_type EQ 1>
                X </cfif></TD>
          </cfif>
          
         
          
          <TD  colspan="3" align="right"><B>Begin Date of Contract:&nbsp; </B></TD>
          <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080" colspan="1" align="center" valign="Center">#dateformat(startdate,"mm/dd/yyyy")#</TD>
          <TD  >&nbsp;</TD>
		  <TD  >&nbsp;</TD>
          <TD COLSPAN="2"  ><B>Customer Program:</B></TD>
          <cfif form.generatexlsreport EQ 0 and CanEditProgram>
            <TD COLSPAN="3"  ><input type="checkbox" name="contract_price" value="1" <Cfif contract_price IS 1>checked</CFIF> disabled> 
              &nbsp;<B>Contract Price</B></TD>
            <cfelse>
          
            <TD COLSPAN="3"  ><B> <cfif contract_price EQ 1>
              &nbsp;   X&nbsp; </cfif> Contract Price</B></TD>
          </cfif>
        </TR>
        <TR> 
          <cfif form.generatexlsreport EQ 0 and CanEditProgram>
            <TD COLSPAN="3"  ><input type="checkbox" name="program_type" value="2" <Cfif program_type IS 2> checked</CFIF> disabled> 
              &nbsp;<B>New</B></TD>
            <cfelse>
            <TD COLSPAN="2"  ><B>New:</B></TD>
            <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080"  align="center" valign="Center" ><cfif program_type EQ 2>
               &nbsp;  X&nbsp; </cfif></TD>
          </cfif>
         
         
          <TD  colspan="3" align="right"><B>End Date of Contract:&nbsp; </B></TD>
          <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080" colspan="1"  align="center" valign="Center" >#trim(dateformat(enddate,"mm/dd/yyyy"))#</TD>
 <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <cfif form.generatexlsreport EQ 0 and CanEditProgram>
            <TD COLSPAN="3"  ><input type="checkbox" name="deviated_allowance" value="1" <cfif deviated_allowance IS 1> checked</cfif> disabled> 
              &nbsp;<B>Deviated Allowance</B></TD>
            <cfelse>
                <TD COLSPAN="3"  ><B> <cfif deviated_allowance EQ 1>
               &nbsp;  X&nbsp; </cfif>Deviated Allowance</B></TD>
          </cfif>
        </TR>
        <TR> 
          <cfif form.generatexlsreport EQ 0 and CanEditProgram>
            <TD COLSPAN="3"  ><input type="checkbox" name="program_type" value="3"  <Cfif program_type IS 3> checked</CFIF> disabled> 
              &nbsp;<B>Updated</B></TD>
            <cfelse>
            <TD COLSPAN="2"  ><B>Updated:</B></TD>
            <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080"  ><cfif program_type EQ 3>
                X</cfif></TD>
          </cfif>
          <TD  >&nbsp;</TD>
         
        
          <cfif GetContractInfo.Is_A_Revision EQ 1>
            <TD colspan="2"><B>Revision Effective Date:</B></TD>
            <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080" align="center" valign="Center" >#trim(dateformat(GetContractInfo.contract_start_date,"mm/dd/yyyy"))#</TD>
            <cfelse>
            <TD  >&nbsp;</TD>
            <TD  >&nbsp;</TD>
          </cfif>  <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
        <TR> 
          <TD   COLSPAN="14">&nbsp;</TD>
        </TR>
        <TR> 
          <TD   COLSPAN="14">(Update Codes - AI=Add Item / PC = Price Change)</TD>
        </TR>
        <TR> </cfoutput>