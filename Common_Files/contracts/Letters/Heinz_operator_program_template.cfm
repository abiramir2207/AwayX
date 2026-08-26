<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Partnership Program</title>
	<style>
	TABLE.Maintable TD	{border-bottom:none; font-size : 10px;}
	#headertitle {font-size: 16px;font-weight:bold}
	TABLE.Secondtable TD	{font-size : 10px;}
	#header1 {font-size: 12px;font-weight:bold}
	TABLE.Thirdtable TD	{font-size : 10px;}
	#header2 {font-size: 11px;}
	#header {font-size: 14px;}
	P.breakhere {page-break-before: always}
</style>
<style type="text/css" media="print">
	thead	{ display: table-header-group; }
	TABLE	{ background-image: none;	}
</style>
</head>

<body>

<form name="Letters" action="RemoveInsertRowsColumns.cfm" METHOD="post">
<table width="650" border="0" align="center" cellpadding="0" cellspacing="0" class="Maintable" >
<THEAD>
	 <tr><td>
	 <cfoutput>
	 <table width="640" border="0" align="center" cellpadding="0" cellspacing="0">
		<tr>
		  	<td align="left" id="header1">#Dateformat(now(),"mm/dd/yyyy")#</td>
			<td align="right" id="header1">Program ID: #contract_number#</td>
		</tr>
		<tr><td><p>&nbsp;</p><br></td></tr>
	 </table>
	 </cfoutput>
  	</td></tr>
</THEAD>
<cfoutput>
	<tr><td>
		<table width="650" border="0" cellspacing="0" cellpadding="0" class="Secondtable" align="center">
		<cfset colStyle2 = "font-size: 16px;font-weight:bold"> 
			<tr>
				<td width="104" align="center" id="headertitle"><img src="#appSettings.getletterscompanylogopath()#" width="100" height="60"></td>
				<td width="400" align="center"  id="headertitle"><b>#template_name#</b></td>
				<td width="200" align="left">#appSettings.getLettersAddress()#</td>
			</tr>
			<tr><td><p>&nbsp;</p></td></tr>
		</table>
	</td></tr>
	<tr> <td height="137" style="border-top:solid black 1px;border-right:solid black 1px;border-left:solid black 1px;border-bottom:solid black 1px;">
		<table width="650" border="0" cellspacing="2" cellpadding="0" class="Secondtable" align="center">
		<cfset colStyle2 = "font-size: 16px;font-weight:bold"> 
		  <tr>
		    <td width="114" height="38" align="right" valign="top" nowrap id="header1">From:</td>
		    <td width="326" align="left" valign="top">#appSettings.getlettersfromemail()#</td>
		  	<td width="114" colspan="1" align="left" id="header1" valign="top"><p>Delivery Period: </p></td>
		    <td width="50" align="left" valign="top">#dateformat(start_date,"mm/dd/yyyy")#</td>
		    <td width="15" align="center" id="header1" valign="top">To</td>
		    <td width="83" align="left" valign="top">#dateformat(end_date,"mm/dd/yyyy")#</td>
		  </tr>
		  <tr>
		    <td width="114" height="45" align="right" valign="top" nowrap id="header1">#application.returned_customer_setting.operator_label_singular# Account:</td>
		    <td width="326" align="left" valign="top">#opr_list_names#</td>
		    <td colspan="1" align="left" id="header1" valign="top">Program Payment: </td>
		    <td colspan="3" align="left" valign="top">
			<cfif getprogramdetails.Discount_Fixed_Prices EQ 1 and gettemplatesettings.operator_Fixed_Pricing EQ 1>
				<CFIF getFixedPriceProducts.RECORDCOUNT gt 0>
			<cfquery name="getfixedpaidto" dbtype="query">
				select distinct Fixed_Component_Paid_to from getFixedPriceProducts
				where 0 = 0
				AND  Fixed_Component_Paid_to IN (<cfif gettemplatesettings.Operator_paysto_opr EQ 1>'2'<cfelse> '0'</cfif>,<cfif gettemplatesettings.Operator_paysto_dis EQ 1>'1'<cfelse>'0'</cfif>) 
			</cfquery>
			<cfif getfixedpaidto.recordcount GT 0>
				<cfloop query="getfixedpaidto">
					Fixed Price Paid to <CFIF Fixed_Component_Paid_to EQ 1>#application.returned_customer_setting.distributor_label_singular#<CFELSE>#application.returned_customer_setting.operator_label_singular#</cfif><br>
				</cfloop>
			</cfif>
		</cfif>
		</cfif>
		<cfif getprogramdetails.Discount_Rebates EQ 1 and gettemplatesettings.operator_Rebate EQ 1>
		<CFIF getRebateProducts.RECORDCOUNT gt 0>
			<cfquery name="getrebatepaidto" dbtype="query">
				select distinct Component_Paid_to from getRebateProducts
				where 0 = 0
				AND  Component_Paid_to IN (<cfif gettemplatesettings.Operator_paysto_opr EQ 1>2<cfelse> 0</cfif>,<cfif gettemplatesettings.Operator_paysto_dis EQ 1>1<cfelse>0</cfif>) 
			</cfquery>
			<cfif getrebatepaidto.recordcount GT 0>
				<cfloop query="getrebatepaidto">
					#Application.RebateLabel# Paid to <CFIF Component_Paid_to EQ 1>#application.returned_customer_setting.distributor_label_singular#<CFELSE>#application.returned_customer_setting.operator_label_singular#</cfif><br>
				</cfloop>
			</cfif>
		</cfif>
		</cfif></td>
			
		  </tr>
		  <tr>
		    <td width="114" height="27" align="right" id="header1">#application.returned_customer_setting.distributor_label_plural#:</td>
		    <td width="326" align="left">#opr_dis_list#</td> 
			<td colspan="1" align="left" id="header1" valign="top">Payment Cycle: </td>
		    <td colspan="3" align="left" valign="top">#payment_cycle#</td>
		  </tr>
		</table>
	</td></tr>
</cfoutput>



<cfif getprogramdetails.Discount_Fixed_Prices EQ 1 and gettemplatesettings.operator_Fixed_Pricing EQ 1>
<CFIF getFixedPriceProducts.RECORDCOUNT gt 0>
<cfquery name="getfixedpaidtoproducts" dbtype="query">
		select * from getFixedPriceProducts
		where 0 = 0 and
		Fixed_Component_Paid_to IN (<cfif gettemplatesettings.Operator_paysto_opr EQ 1>'2'<cfelse> '0'</cfif>,<cfif gettemplatesettings.Operator_paysto_dis EQ 1>'1'<cfelse>'0'</cfif>) 
</cfquery>
<tr><td>
<p>&nbsp;</p></td></tr>

<tr><td>
<table width="650" border="0" align="center" class="Maintable" cellpadding="0" cellspacing="0">
<TR><TD height="29" id="header"><u><b>Fixed Pricing</b></U>
</TD>
</TR>
</TABLE></td></tr>
  <cfif appSettings.getfixedcomponents_on()>
  <cfoutput query="getfixedpaidtoproducts" group="Program_Fixed_Component_Id">
  <CFOUTPUT GROUP="Fixed_Component_Paid_to">
 <tr><td> <table width="650" border="1" cellspacing="0" cellpadding="0" align="center" class="Thirdtable">
 	<thead>
 	<tr>
	<td  id="header2" colspan="100%" align="right"><b>#Program_Fixed_Component_Name#</b> (Pays to <CFIF Fixed_Component_Paid_to EQ 1>#application.returned_customer_setting.distributor_label_singular#<CFELSE>#application.returned_customer_setting.operator_label_singular#</cfif>) <cfif IsExclusionRevision EQ 1>
	(Exclusions)</cfif></td>
	</tr>
	</thead>
   <tr>
  	<TD ID="displayscisscors" style="display:none">&nbsp;</TD>
    <td id="header2" width="80">#UCASE(application.returned_customer_setting.customer_keyword)# ITEM</td>
    <td id="header2" width="300">DESCRIPTION</td>
	<TD id="header2" ALIGN="CENTER">DATES</TD>
	 <td id="header2" ALIGN="CENTER">FIXED<BR>PRICE</td>
	<td id="header2" ALIGN="CENTER">UOM</td>
  </tr>
  <cfset fixedcount = 0>
 <cfoutput>
	<input type="hidden" name="FPR_Delete_#Program_Fixed_Component_Id#_#fixedcount#" value="0">
 	<tr ID="FPR_Delete_#Program_Fixed_Component_Id#_#fixedcount#" bDelete="0">
	<TD ID="displayscisscors" style="display:none"><img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" alt="click here to delete this product" border="0" style="cursor: pointer;" onclick="deleteThisPrice(bDelete,'FPR_Delete_#Program_Fixed_Component_Id#_#fixedcount#')"></td></DIV>
    <td width="30">#ITEM#</td>
    <td width="300">#DESCRIPTION#</td>
    <cfif (IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1)>
		<TD ALIGN="CENTER">#DateFormat(Contract_Start_Date,"MM/DD/YYYY")#<br>#DateFormat(Contract_End_Date,"MM/DD/YYYY")#</TD>
		<td ALIGN="CENTER">$#trim(NUMBERFORMAT(FIXED_PRICE_VALUE,'_-___,___,___,___,___.__'))#</td>
		<td ALIGN="CENTER">#Abbreviation#</td>
	<cfelse>
		<TD ALIGN="CENTER">
		#DateFormat(Contract_Start_Date,"MM/DD/YYYY")#<BR>
		<cfset Date_Exclusion_Contract_Main_IDs = ListDeleteAt(List_Of_Contract_Main_IDs,1)>
		<cfset DateExclusionDate = GenProgramManager.DateExclusionDates(Date_Exclusion_Contract_Main_IDs)>		
	<cfloop query="DateExclusionDate">
									<cfloop from="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_Start_Date)#" to="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_End_Date)#" index="IndexYear">
										<cfloop from="1" to="12" index="IndexMonth">
											<cfloop from="1" to="31" index="IndexDay">		
												<cfset DayDate = "#IndexMonth#/#IndexDay#/#IndexYear#">
													<cfif IsDate(DayDate)>
														<!--- If the date in the loop matches the date exclusion start date --->
														<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date) eq 0>
															<!--- If it's not the first row --->
															<cfif DateExclusionDate.currentrow neq 1>
																<!--- If there is a days difference in the previous date exclusion end date and current date exclusion start date --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date[DateExclusionDate.currentrow-1]) GT 0>
																#DateFormat(Before_Date_Exclusion_Contract_Start_Date, "MM/DD/YYYY")#<br /><br />
																</cfif>
															<cfelse>
															#DateFormat(DateAdd('d',-1,Contract_Start_Date),"MM/DD/YYYY")#<br /><br />
															</cfif>
														</cfif>
													<!--- If the date in the loop matches the date exclusion end date --->
														<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date) eq 0>
														<!--- If it's not the last row --->
															<cfif DateExclusionDate.currentrow neq DateExclusionDate.recordcount>
														<!--- If there is a days difference in the current date exclusion end date and the following date exclusion start date, get that info --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date[DateExclusionDate.currentrow+1]) GT 1>
																	#DateFormat(After_Date_Exclusion_Contract_End_Date, "MM/DD/YYYY")#<br />
																	#DateFormat(Before_Date_Exclusion_Contract_Start_Date[DateExclusionDate.currentrow+1], "MM/DD/YYYY")#<br /><br />				
																</cfif>
													
															<cfelse>
														
															<!--- If the last date exclusion's end date is not the same as the parent date exclusion start date --->
																<cfif DateDiff('d',DateExclusionDate.Contract_End_Date,getDateExclusionprogramIDs.Contract_End_Date) neq 0>
																#DateFormat(DateAdd('d',1,Contract_End_Date),"MM/DD/YYYY")#<br />
																#DateFormat(getDateExclusionprogramIDs.Contract_End_Date, "MM/DD/YYYY")#
																</cfif>
													</cfif>
													</cfif>
												</cfif>
											</cfloop>
										</cfloop>
									</cfloop>
				  </cfloop></TD>
		<td ALIGN="CENTER">$#trim(NUMBERFORMAT(FIXED_PRICE_VALUE,'_-___,___,___,___,___.__'))# <br></td>
		<td ALIGN="CENTER">#Abbreviation#<br></td>				
	</CFIF>
	 </tr>
  <cfset fixedcount = fixedcount + 1>
 </cfoutput>
 </table></TD></TR>
</CFOUTPUT>
  </cfoutput>
  <CFELSE><tr><td>
  <table width="650" border="1" cellspacing="0" cellpadding="0" align="center" class="Thirdtable">
   <tr>
  	<TD ID="displayscisscors" style="display:none">&nbsp;</TD>
    <td id="header2"><cfoutput>#UCASE(application.returned_customer_setting.customer_keyword)#</cfoutput>  ITEM</td>
    <td id="header2">DESCRIPTION</td>
	<TD id="header2" ALIGN="CENTER">DATES</TD>
    <td id="header2" ALIGN="CENTER">FIXED<BR>PRICE</td>
	<td id="header2" ALIGN="CENTER">UOM</td>
  </tr>
  <cfset fixedcount = 0>
  <cfoutput query="getfixedpaidtoproducts">
	<input type="hidden" name="FPR_Delete_#fixedcount#" value="0">
 	<tr ID="FPR_Delete_#fixedcount#" bDelete="0">
	<TD ID="displayscisscors" style="display:none"><img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" alt="click here to delete this product" border="0" style="cursor: pointer;" onclick="deleteThisPrice(bDelete,'FPR_Delete_#fixedcount#')"></td>
    <td>#ITEM#</td>
    <td>#DESCRIPTION#</td>
	<cfif IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1 >
		<TD ALIGN="CENTER">#DateFormat(Contract_Start_Date,"MM/DD/YYYY")#<br>#DateFormat(Contract_End_Date,"MM/DD/YYYY")#</TD>
	<cfelse>
		<TD ALIGN="CENTER">
		#DateFormat(Contract_Start_Date,"MM/DD/YYYY")#<BR>
		<cfset Date_Exclusion_Contract_Main_IDs = ListDeleteAt(List_Of_Contract_Main_IDs,1)>
		<cfset DateExclusionDate = GenProgramManager.DateExclusionDates(Date_Exclusion_Contract_Main_IDs)>		
	<cfloop query="DateExclusionDate">
									<cfloop from="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_Start_Date)#" to="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_End_Date)#" index="IndexYear">
										<cfloop from="1" to="12" index="IndexMonth">
											<cfloop from="1" to="31" index="IndexDay">		
												<cfset DayDate = "#IndexMonth#/#IndexDay#/#IndexYear#">
													<cfif IsDate(DayDate)>
														<!--- If the date in the loop matches the date exclusion start date --->
														<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date) eq 0>
															<!--- If it's not the first row --->
															<cfif DateExclusionDate.currentrow neq 1>
																<!--- If there is a days difference in the previous date exclusion end date and current date exclusion start date --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date[DateExclusionDate.currentrow-1]) GT 0>
																#DateFormat(Before_Date_Exclusion_Contract_Start_Date, "MM/DD/YYYY")#<br /><br />
																</cfif>
															<cfelse>
															#DateFormat(DateAdd('d',-1,Contract_Start_Date),"MM/DD/YYYY")#<br /><br />
															</cfif>
														</cfif>
													<!--- If the date in the loop matches the date exclusion end date --->
														<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date) eq 0>
														<!--- If it's not the last row --->
															<cfif DateExclusionDate.currentrow neq DateExclusionDate.recordcount>
														<!--- If there is a days difference in the current date exclusion end date and the following date exclusion start date, get that info --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date[DateExclusionDate.currentrow+1]) GT 1>
																	#DateFormat(After_Date_Exclusion_Contract_End_Date, "MM/DD/YYYY")#<br />
																	#DateFormat(Before_Date_Exclusion_Contract_Start_Date[DateExclusionDate.currentrow+1], "MM/DD/YYYY")#<br /><br />				
																</cfif>
													
															<cfelse>
														
															<!--- If the last date exclusion's end date is not the same as the parent date exclusion start date --->
																<cfif DateDiff('d',DateExclusionDate.Contract_End_Date,getDateExclusionprogramIDs.Contract_End_Date) neq 0>
																#DateFormat(DateAdd('d',1,Contract_End_Date),"MM/DD/YYYY")#<br />
																#DateFormat(getDateExclusionprogramIDs.Contract_End_Date, "MM/DD/YYYY")#
																</cfif>
													</cfif>
													</cfif>
												</cfif>
											</cfloop>
										</cfloop>
									</cfloop>
			  </cfloop></TD>			
	</CFIF>
    <td ALIGN="CENTER">$#trim(NUMBERFORMAT(FIXED_PRICE_VALUE,'_-___,___,___,___,___.__'))#</td>
	<td ALIGN="CENTER">#Abbreviation#</td>
  </tr>
  <cfset fixedcount = fixedcount + 1>
  </cfoutput> 
  </table></TD></TR>
  </cfif>
</CFIF>
</CFIF>

<cfif getprogramdetails.Generic_Type EQ "Bid Request"  and gettemplatesettings.Operator_Bid_Request EQ 1>
<CFIF getBidRequestProducts.RECORDCOUNT gt 0>
<cfquery name="getbidrequestpaidtoproducts" dbtype="query">
		select * from getBidRequestProducts
		where 0 = 0
		AND  Program_Bidrequest_Component_Paid_to IN (<cfif gettemplatesettings.Operator_paysto_opr EQ 1>'2'<cfelse> '0'</cfif>,<cfif gettemplatesettings.Operator_paysto_dis EQ 1>'1'<cfelse>'0'</cfif>) 
</cfquery>
<tr><td>
<p>&nbsp;</p></td></tr>

<tr><td>
<table width="640" border="0" align="center" class="Maintable" cellpadding="0" cellspacing="0">
<TR><TD id="header"><b><u>Proposal</U></b>
</TD></TR>
</TABLE>
  <cfif appSettings.getBidRequestComponentsOn()>
  <cfoutput query="getbidrequestpaidtoproducts" group="Program_Bidrequest_Component_Id">
  <CFOUTPUT GROUP="Program_Bidrequest_Component_Paid_to">
  <table width="640" border="1" cellspacing="0" cellpadding="0" align="center" class="Thirdtable" ID="FixedTable">
  	<thead>
 	<tr>
	<td  id="header2" colspan="100%" align="right"><b>#Program_Fixed_Component_Name#</b> (Pays to <CFIF Program_Bidrequest_Component_Paid_to EQ 1>#application.returned_customer_setting.distributor_label_singular#<CFELSE>#application.returned_customer_setting.operator_label_singular#</cfif>)</td>
	</tr>
	</thead>
   <tr>
  	<TD ID="displayscisscors" style="display:none">&nbsp;</TD>
    <td id="header2" width="80">#UCASE(application.returned_customer_setting.customer_keyword)# ITEM</td>
    <td id="header2" width="300">DESCRIPTION</td>
	<td id="header2" ALIGN="CENTER">NET PRICE</td>
	<td id="header2" ALIGN="CENTER">UOM</td>
  </tr>
   <cfset fixedcount = 1>
 <cfoutput>
	<input type="hidden" name="FPR_Delete_#Program_Bidrequest_Component_Id#_#fixedcount#" value="0">
 	<tr ID="FPR_Delete_#Program_Bidrequest_Component_Id#_#fixedcount#" bDelete="0">
	<TD ID="displayscisscors" style="display:none"><img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" alt="click here to delete this product" border="0" style="cursor: pointer;" onclick="deleteThisPrice(bDelete,'FPR_Delete_#Program_Bidrequest_Component_Id#_#fixedcount#')"></td></DIV>
    <td width="30">#ITEM#</td>
    <td width="300">#DESCRIPTION#</td>	
	<td ALIGN="CENTER">$#trim(NUMBERFORMAT(Bidrequest_Price_Value,'_-___,___,___,___,___.__'))# <br></td>
	<td ALIGN="CENTER">#Abbreviation#<br></td>				
  </tr>
  <cfset fixedcount = fixedcount + 1>
 </cfoutput>
 </table>
 </td></tr>
</CFOUTPUT>
  </cfoutput>
  <CFELSE>
<tr><td>
  <table width="640" border="1" cellspacing="0" cellpadding="0" align="center" class="Thirdtable">
   <tr>
  	<TD ID="displayscisscors" style="display:none">&nbsp;</TD>
    <td id="header2"><cfoutput>#UCASE(application.returned_customer_setting.customer_keyword)#</cfoutput>  ITEM</td>
    <td id="header2">DESCRIPTION</td>
    <td id="header2" ALIGN="CENTER">NET PRICE</td>
	<td id="header2" ALIGN="CENTER">UOM</td>
  </tr>
  <cfset fixedcount = 0>
  <cfoutput query="getbidrequestpaidtoproducts">
	<input type="hidden" name="FPR_Delete_#fixedcount#" value="0">
 	<tr ID="FPR_Delete_#fixedcount#" bDelete="0">
	<TD ID="displayscisscors" style="display:none"><img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" alt="click here to delete this product" border="0" style="cursor: pointer;" onclick="deleteThisPrice(bDelete,'FPR_Delete_#fixedcount#')"></td>
    <td>#ITEM#</td>
    <td>#DESCRIPTION#</td>
    <td ALIGN="CENTER">$#trim(NUMBERFORMAT(Bidrequest_Price_Value,'_-___,___,___,___,___.__'))#</td>
	<td ALIGN="CENTER">#Abbreviation#</td>
  </tr>
  <cfset fixedcount = fixedcount + 1>
  </cfoutput> 
  </table>
  </td>
  </tr>
  </cfif>
 </CFIF>
 </cfif>

<cfif getprogramdetails.Discount_Rebates EQ 1 and gettemplatesettings.operator_Rebate EQ 1>
<CFIF getRebateProducts.RECORDCOUNT gt 0>
<cfquery name="getdisrebates" dbtype="query">
select * from getRebateProducts
where 0 = 0
AND  Component_Paid_to IN (<cfif gettemplatesettings.Operator_paysto_opr EQ 1>2<cfelse> 0</cfif>,<cfif gettemplatesettings.Operator_paysto_dis EQ 1>1<cfelse>0</cfif>) 
</cfquery>
<cfif getdisrebates.recordcount gt 0>
<TR><TD><p>&nbsp;</p> </td> </tr>

<TR><TD>
<table width="650" border="0" align="center" class="Maintable" cellpadding="0" cellspacing="0">
  <tr>
    <td height="29" id="header"><u><cfoutput><b>#Application.RebateLabel#s</b></cfoutput></u> </td>
  </tr>
</table></TD></TR>
<cfoutput query="getdisrebates" group="Program_Rebates_Component_ID"> <CFOUTPUT GROUP="Component_Paid_to">
   <TR><TD> <table width="650" border="1" cellspacing="0" cellpadding="0" align="center" class="Thirdtable">
   		<thead>
 	    <tr>
	    <td  id="header2" colspan="100%" align="right"><b>#Program_Rebates_Component_Name#</b> (Pays to <CFIF Component_Paid_to EQ 1>#application.returned_customer_setting.distributor_label_singular#<CFELSE>#application.returned_customer_setting.operator_label_singular#</cfif>) <cfif IsExclusionRevision EQ 1>
	    (Exclusions)</cfif></td>
	    </tr>
		</thead>
       <tr>
  	<TD ID="displayscisscors" style="display:none">&nbsp;</TD>
         <td id="header2" width="80">#UCASE(application.returned_customer_setting.customer_keyword)#  ITEM</td>
    	<td id="header2" width="300">DESCRIPTION</td>
	    <TD id="header2" ALIGN="CENTER">DATES</TD>
	     <td id="header2" ALIGN="CENTER">#Application.RebateLabel#</td>
	    <td id="header2" ALIGN="CENTER">UOM</td>
      </tr>
  <cfset rebatecount = 0>
 <cfoutput>
	<input type="hidden" name="RER_Delete_#Program_Rebates_Component_ID#_#rebatecount#" value="0">
 	<tr ID="RER_Delete_#Program_Rebates_Component_ID#_#rebatecount#" bDelete="0">
	<TD ID="displayscisscors" style="display:none"><img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" alt="click here to delete this product" border="0" style="cursor: pointer;" onclick="deleteThisPrice(bDelete,'RER_Delete_#Program_Rebates_Component_ID#_#rebatecount#')"></td>
        <td>#ITEM#</td>
        <td>#DESCRIPTION#</td>
        <cfif IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1>
		    <TD ALIGN="CENTER">#DateFormat(Contract_Start_Date,"MM/DD/YYYY")#<br>#DateFormat(Contract_End_Date,"MM/DD/YYYY")#</TD>
		    <td ALIGN="CENTER">$#trim(NUMBERFORMAT(rate,'_-___,___,___,___,___.__'))#</td>
		    <td ALIGN="CENTER">#Abbreviation#</td>
	    <cfelse>
		    <TD ALIGN="CENTER">
		    #DateFormat(Contract_Start_Date,"MM/DD/YYYY")#<BR>
		    <cfset Date_Exclusion_Contract_Main_IDs = ListDeleteAt(List_Of_Contract_Main_IDs,1)>
		    <cfset DateExclusionDate = GenProgramManager.DateExclusionDates(Date_Exclusion_Contract_Main_IDs)>		
	    <cfloop query="DateExclusionDate">
									    <cfloop from="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_Start_Date)#" to="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_End_Date)#" index="IndexYear">
										    <cfloop from="1" to="12" index="IndexMonth">
											    <cfloop from="1" to="31" index="IndexDay">		
												    <cfset DayDate = "#IndexMonth#/#IndexDay#/#IndexYear#">
													    <cfif IsDate(DayDate)>
														    <!--- If the date in the loop matches the date exclusion start date --->
														    <cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date) eq 0>
															    <!--- If it's not the first row --->
															    <cfif DateExclusionDate.currentrow neq 1>
																    <!--- If there is a days difference in the previous date exclusion end date and current date exclusion start date --->
																    <cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date[DateExclusionDate.currentrow-1]) GT 0>
																    #DateFormat(Before_Date_Exclusion_Contract_Start_Date, "MM/DD/YYYY")#<br /><br />
																    </cfif>
															    <cfelse>
															    #DateFormat(DateAdd('d',-1,Contract_Start_Date),"MM/DD/YYYY")#<br /><br />
															    </cfif>
														    </cfif>
													    <!--- If the date in the loop matches the date exclusion end date --->
														    <cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date) eq 0>
														    <!--- If it's not the last row --->
															    <cfif DateExclusionDate.currentrow neq DateExclusionDate.recordcount>
														    <!--- If there is a days difference in the current date exclusion end date and the following date exclusion start date, get that info --->
																    <cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date[DateExclusionDate.currentrow+1]) GT 1>
																	    #DateFormat(After_Date_Exclusion_Contract_End_Date, "MM/DD/YYYY")#<br />
																	    #DateFormat(Before_Date_Exclusion_Contract_Start_Date[DateExclusionDate.currentrow+1], "MM/DD/YYYY")#<br /><br />				
																    </cfif>
													    
															<cfelse>
														    
															<!--- If the last date exclusion's end date is not the same as the parent date exclusion start date --->
																    <cfif DateDiff('d',DateExclusionDate.Contract_End_Date,getDateExclusionprogramIDs.Contract_End_Date) neq 0>
																    #DateFormat(DateAdd('d',1,Contract_End_Date),"MM/DD/YYYY")#<br />
																    #DateFormat(getDateExclusionprogramIDs.Contract_End_Date, "MM/DD/YYYY")#
																    </cfif>
													    </cfif>
													    </cfif>
												    </cfif>
											    </cfloop>
										    </cfloop>
									    </cfloop>
			      </cfloop></TD>
		    <td ALIGN="CENTER">$#trim(NUMBERFORMAT(rate,'_-___,___,___,___,___.__'))#<br></td>
		    <td ALIGN="CENTER">#Abbreviation#<br></td>				
	    </CFIF>
	     </tr>
<cfset rebatecount = rebatecount + 1>
     </cfoutput>
     </table></TD></TR>
 
  </CFOUTPUT>
  </cfoutput>
 </cfif>
</CFIF>
</cfif>
<TR><TD><p>&nbsp;</p></TD></TR>
<cfif getprogramdetails.Discount_Lump_Sums EQ 1 and gettemplatesettings.operator_Lumpsum EQ 1>
	<CFIF getlumpsums.RECORDCOUNT gt 0>
	<TR><TD><table width="650" border="0" align="center" class="Maintable" cellpadding="0" cellspacing="0">
<TR><TD id="header" height="29"><u><cfoutput>#Application.LumpsumLabel# Incentives</cfoutput></U>
</TD></TR>
</TABLE></TD></TR>
<TR><TD>
<table width="650" border="1" cellspacing="0" cellpadding="0" align="center" class="Thirdtable">
 	<cfset lumpcount = 0>
		<cfoutput query="getlumpsums">
		<input type="hidden" name="LUMP_Delete_#lumpcount#" value="0">
 		<tr ID="LUMP_Delete_#lumpcount#" bDelete="0">
		<TD ID="displayscisscors" style="display:none" width="15"><img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" alt="click here to delete this product" border="0" style="cursor: pointer;" onclick="deleteThisPrice(bDelete,'LUMP_Delete_#lumpcount#')"></td>
		<td>#Program_Lump_Sum_Name#
		</td>
		<cfif IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1>
		<TD ALIGN="CENTER">#DateFormat(Contract_Start_Date,"MM/DD/YYYY")#<br>#DateFormat(Contract_End_Date,"MM/DD/YYYY")#</TD>
		<cfelse>
		<TD ALIGN="CENTER">
		#DateFormat(Contract_Start_Date,"MM/DD/YYYY")#<BR>
		<cfset Date_Exclusion_Contract_Main_IDs = ListDeleteAt(List_Of_Contract_Main_IDs,1)>
		<cfset DateExclusionDate = GenProgramManager.DateExclusionDates(Date_Exclusion_Contract_Main_IDs)>		
	<cfloop query="DateExclusionDate">
									<cfloop from="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_Start_Date)#" to="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_End_Date)#" index="IndexYear">
										<cfloop from="1" to="12" index="IndexMonth">
											<cfloop from="1" to="31" index="IndexDay">		
												<cfset DayDate = "#IndexMonth#/#IndexDay#/#IndexYear#">
													<cfif IsDate(DayDate)>
														<!--- If the date in the loop matches the date exclusion start date --->
														<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date) eq 0>
															<!--- If it's not the first row --->
															<cfif DateExclusionDate.currentrow neq 1>
																<!--- If there is a days difference in the previous date exclusion end date and current date exclusion start date --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date[DateExclusionDate.currentrow-1]) GT 0>
																#DateFormat(Before_Date_Exclusion_Contract_Start_Date, "MM/DD/YYYY")#<br /><br />
																</cfif>
															<cfelse>
															#DateFormat(DateAdd('d',-1,Contract_Start_Date),"MM/DD/YYYY")#<br /><br />
															</cfif>
														</cfif>
													<!--- If the date in the loop matches the date exclusion end date --->
														<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date) eq 0>
														<!--- If it's not the last row --->
															<cfif DateExclusionDate.currentrow neq DateExclusionDate.recordcount>
														<!--- If there is a days difference in the current date exclusion end date and the following date exclusion start date, get that info --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date[DateExclusionDate.currentrow+1]) GT 1>
																	#DateFormat(After_Date_Exclusion_Contract_End_Date, "MM/DD/YYYY")#<br />
																	#DateFormat(Before_Date_Exclusion_Contract_Start_Date[DateExclusionDate.currentrow+1], "MM/DD/YYYY")#<br /><br />				
																</cfif>
													
															<cfelse>
														
															<!--- If the last date exclusion's end date is not the same as the parent date exclusion start date --->
																<cfif DateDiff('d',DateExclusionDate.Contract_End_Date,getDateExclusionprogramIDs.Contract_End_Date) neq 0>
																#DateFormat(DateAdd('d',1,Contract_End_Date),"MM/DD/YYYY")#<br />
																#DateFormat(getDateExclusionprogramIDs.Contract_End_Date, "MM/DD/YYYY")#
																</cfif>
													</cfif>
													</cfif>
												</cfif>
											</cfloop>
										</cfloop>
									</cfloop>
				</cfloop>
			</td>
			</cfif>
			<td>
				$#Lump_sum_amount#
			</td>
		</tr>
		<cfset lumpcount = lumpcount + 1>
		</cfoutput>
</tablE></TD></TR>
	</CFIF>
</cfif>
<br><br>
<tr><TD><P CLASS="breakhere"></TD></TR>
<tr><TD><p>&nbsp;</p></TD></TR>
<cfoutput>
<tr><TD><table width="650" border="0" cellspacing="0" cellpadding="0" align="center" class="Secondtable">
	<tr>
<td style="font-size:14px;font-weight:bold"><U>Conditions:</U></td>	
	</tr>
	<cfif getProgramClause.recordCount>
				<cfloop query="getProgramClause">
	<TR>
		<TD>
		#Clause_Library_Body#
		</TD>	
	</TR>	
	<tr><td>&nbsp;</td></tr>
</cfloop>
	</cfif>
	
</table></TD></TR>

<tr><TD><table width="650" border="0" cellspacing="0" cellpadding="0" align="center" class="Secondtable">
<tr>
<td colspan="102">&nbsp;</td>
</tr>
<tr>
<td width="56" height="10" valign="bottom"></td>
<td width="334" height="10" valign="bottom">#appSettings.getLettersAcceptedBy()#</td>
<td width="73" valign="bottom" nowrap>&nbsp;</td>
<td width="300" valign="bottom"><cfif listlen(opr_list_names) eq 1>#opr_list_names#</cfif></td>
</tr>
<tr>
  <td valign="top" width="70" nowrap>Accepted By </td>
  <td valign="top">_______________________________________</td>
  <td width="70" valign="bottom" nowrap>Accepted By</td>
  <td width="313" valign="bottom">_______________________________________</td>
</tr>
<tr>
<tr>
<td width="56" height="10" valign="bottom"></td>
<td width="334" height="10" valign="bottom">#getprogramdetails.name_first# #getprogramdetails.name_last#</td>
<td width="47" rowspan="2" valign="bottom">Name</td>
<td width="313" rowspan="2" valign="bottom">_______________________________________</td>
</tr>
<tr>
  <td valign="top">Name</td>
  <td valign="top">_______________________________________</td>
</tr>
<tr>
  <td colspan="2">&nbsp;</td>
  <td colspan="2">&nbsp;</td>
</tr>
<tr>
  <td colspan="2" valign="top"></td>
</tr>
<tr>
  <td valign="top">Signature</td>
  <td valign="top">_______________________________________</td>
   <td valign="top">Signature</td>
  <td valign="top">_______________________________________</td>
</tr>
<tr>
  <td valign="top">&nbsp;</td>
  <td valign="top">&nbsp;</td>
  <td valign="top">&nbsp;</td>
  <td valign="top">&nbsp;</td>
</tr>
<tr>
  <td valign="top">Date</td>
  <td valign="top">_______________________________________</td>
  <td valign="top">Date</td>
  <td valign="top">_______________________________________</td>
</tr>

</table></cfoutput>
</TD></TR>
<tr><td colspan="100%">&nbsp;</td></tr>

<tr>
<TD colspan="100%" align="center" ID="displayscisscors" style="display:none">
<!--- <div ID="submitbutton" style="visibility=hidden"> --->
<FONT COLOR="#FF0000" size="3"><B>[ </B></FONT>
	<A HREF="#" onClick="confirmCompletion();; return false;" STYLE="COLOR:#0000FF;">
		<B><FONT size="3">Modify Letter</FONT></B>
	</A>
<FONT COLOR="#FF0000" size="3"><B> ]</B></FONT><!--- </div> --->
</TD>
</tr>
</TABLE>

<input type="hidden" name="filepath" value="">
<input type="hidden" name="letter_name" value="">
<input type="hidden" name="contractId" value="">
<input type="hidden" name="letter_type" value="1">
<input type="hidden" name="letter_id" value="">
</form>
</body>
</html>
