<!--------------------------------------------------------------------------------------------------------------------------------------------------------
  Component: \profits\operator\index.cfm
  Date:      April 2013
  Author:    Chris Nguyen
    
  Remarks:  This template generates operator profit report
  
--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfsavecontent variable="vars.htmlHead">
<link href="/common_files/fixedHeaderTable/defaultTheme.css" rel="stylesheet" media="screen" />
<link href="/common_files/fixedHeaderTable/myTheme.css?foo" rel="stylesheet" media="screen" />
<link href="/common_files/feedback.css?foo" rel="stylesheet" media="screen" />
<style>
  #dataGrid tr td:first-child { text-align: left; font-size: 1em; }
  #dataGrid td { text-align: right; font-size: 0.85em; color: black; }
  #dataGrid th { font-size: 0.95em; }
  
  #dataGrid tr, #dataGrid td { border-color: white; border-top: none; }
  
  #dataGrid td.indent2 { padding-left: 20px; }
  #dataGrid td.neg { color: red; }
  #dataGrid th.headgroup { vertical-align: middle; }

  .info, .warning, .error { margin: 10px; }

	.tallBottom { height: 40px; }
	#dataGrid .tallBottom td { vertical-align: bottom; }
	
	.tallTop    { height: 40px; }
	.tallTop td { vertical-align: top; }

	.totalHeader { background-color: #D9D9D9 !important; }
	.brandedHeader { background-color: #DCE6F1 !important; }
	.proprietaryHeader { background-color: #F2DCDB !important; }
	
	#dataGrid .rate1 td { padding-top: 50px; border-style: solid; font-size: 1.05em; letter-spacing: 1px; }
	
	#dataGrid .box1 { border-left:1px solid black !important; }
	#dataGrid .box2 td { border-top:2px solid black; }
	#dataGrid .box3 td { border-top:1.5px solid black; }
	#dataGrid .box4 td { border-bottom:2px solid black; }
	
	#dataGrid .color1 td { background-color: #FFFFCC; border-left-color: #FFFFCC; border-right-color: #FFFFCC; }
	#dataGrid .color2 td { background-color: #CCFFCC; border-left-color: #CCFFCC; border-right-color: #CCFFCC; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<cfscript>
  vars = {};
  vars.debug = ( structKeyExists(form, 'debug') and form.debug eq 'on' );
  vars.productGroupID = ( form.allProducts eq 'on' ? '00000000-0000-0000-0000-000000000000' : form.product );
  qOneRow = queryNew( 'foo' );
  queryAddRow( qOneRow );

  oProfitModel  = createObject("component", "components.general.Profitability_Models");
  qTotal        = oProfitModel.getOperatorProfitReport( operatorNumber=form.operator, productClass='total', productGroupID=vars.productGroupID );
  qDistributorSpendTotal = oProfitModel.getOperatorDistributorSpend( operatorNumber=form.operator, operatorType=form.operatorSearchBy, productClass='total', productGroupID=vars.productGroupID );
  
  if ( form.branded eq "on" ) {   
  	qBranded = oProfitModel.getOperatorProfitReport( operatorNumber=form.operator, operatorType=form.operatorSearchBy, productClass='branded', productGroupID=vars.productGroupID );
    qDistributorSpendBranded = oProfitModel.getOperatorDistributorSpend( operatorNumber=form.operator, operatorType=form.operatorSearchBy, productClass='branded', productGroupID=vars.productGroupID );
  }
  
	if ( form.privatelabel eq "on" ) {
  	qPrivateLabel = oProfitModel.getOperatorProfitReport( operatorNumber=form.operator, operatorType=form.operatorSearchBy, productClass='private label', productGroupID=vars.productGroupID );
    qDistributorSpendPrivateLabel = oProfitModel.getOperatorDistributorSpend( operatorNumber=form.operator, operatorType=form.operatorSearchBy, productClass='private label', productGroupID=vars.productGroupID );
  }
  qPositionBelowMe = oProfitModel.getPositionBelowMe();
</cfscript>

<form action="/common_files/csv.cfm" method ="post" id="csv_form"> 
  <input type="hidden" name="csv_text" id="csv_text">
  <input type="hidden" name="csv_file_name" id="csv_file_name">
</form>

<cfif qTotal.recordCount eq 0>
	<div class="info">
	<p>There is no operator profit data to display for the operator selected.</p>
	</div>
<cfelseif not oProfitModel.isHeadQuarters() 
	and val(qTotal.User_Position_ID) gt 0 
	and listFindNoCase(qTotal.User_Position_ID, valueList(qPositionBelowMe.Below_User_Positions_Id)) eq 0>
	<div class="error">
	<p>You do not have permission to view the profit for this operator ( <cfoutput>#lCase( qTotal.Position_Label )#</cfoutput> ) due to your user position. Please contact your system administrator.</p>
	</div>
<cfelse>
<table class="fancyTable" id="dataGrid" cellpadding="0" cellspacing="0">
  <thead>
    <tr id="thead2">
        <th style="background-color:white;"></th>
				<cfif vars.debug>
					<th>Prof_Model_Operator_Report.</th>
				</cfif>
        <th class="totalHeader">Current</th>
        <th class="totalHeader">Prior</th>
        <th class="totalHeader">Fav/(Unfav)</th>
        <th class="totalHeader">% Diff</th>
            
        <cfif form.branded eq "on">
	        <th class="brandedHeader box1">Current</th>
	        <th class="brandedHeader">Prior</th>
	        <th class="brandedHeader">Fav/(Unfav)</th>
	        <th class="brandedHeader">% Diff</th>
				</cfif>
				
        <cfif form.privatelabel eq "on">
	        <th class="proprietaryHeader box1">Current</th>
	        <th class="proprietaryHeader">Prior</th>
	        <th class="proprietaryHeader">Fav/(Unfav)</th>
	        <th class="proprietaryHeader">% Diff</th>
				</cfif>
    </tr>
    <tr id="thead1">
       <th style="background-color:white;"></th>
				<cfif vars.debug>
					<th>DEVELOPER INFO</th>
				</cfif>
        <th colspan="4" class="headgroup totalHeader">TOTAL</th>
        <cfif form.branded eq "on">
        	<th colspan="4" class="headgroup brandedHeader box1">BRANDED</th>
				</cfif>
        <cfif form.privatelabel eq "on">
        	<th colspan="4" class="headgroup proprietaryHeader box1">PROPRIETARY</th>
				</cfif>
    </tr>
  </thead>

	<cfoutput>
  <tbody>
	    <cfsetting enablecfoutputonly=true>
	    <cfif form.display eq "totals" or form.display eq "cases_rates">
		    <!----- C A S E S ----------------------------------------------------------------------------------------------------------------------------------------->
		    <cfoutput><tr></cfoutput>
		      <cfoutput><td>Cases <a class="detail" uom="Cases">#application.util.string.actionLinkFormat("view detail")#</a></td></cfoutput>
		      <cfset generateVolumeCells ( "cases_total_" )>
		    <cfoutput></tr></cfoutput>
	    </cfif>
	    
	    <cfif form.display eq "pounds_rates">
		    <!----- P O U N D S --------------------------------------------------------------------------------------------------------------------------------------->
		    <cfoutput><tr></cfoutput>
		      <cfoutput><td>Pounds <a class="detail" uom="Pounds">#application.util.string.actionLinkFormat("detail")#</a></td></cfoutput>
		      <cfset generateVolumeCells ( "pounds_total_" )>
		    <cfoutput></tr></cfoutput>
			</cfif>
				
	    <cfif form.display eq "eqc_rates">
		    <!----- E Q C --------------------------------------------------------------------------------------------------------------------------------------------->
		    <cfoutput><tr></cfoutput>
		      <cfoutput><td>EQC <a class="detail" uom="EQC">#application.util.string.actionLinkFormat("detail")#</a></td></cfoutput>
		      <cfset generateVolumeCells ( "eqc_total_" )>
		    <cfoutput></tr></cfoutput>
			</cfif>
			
	    <!----- B A S E   S A L E S ------------------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="tallBottom"></cfoutput>
	      <cfoutput><td>List Sales $</td></cfoutput>
 				 <cfset generateDollarCells ( "Base_Sales_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- C A S H   D I S C O U N T ------------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td>Cash Discount</td></cfoutput>
 				 <cfset generateDollarCells ( "Cash_Discount_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- G R O S S   S A L E S ----------------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="box2 color2"></cfoutput>
	      <cfoutput><td class="">Gross Sales $ (GSV)</td></cfoutput>
 				 <cfset generateDollarCells ( "Gross_Sales_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- O P E R A T O R   A L L O W A N C E S  ------------------------------------------------------------------------------------------------------------>
	    <cfoutput><tr class="tallBottom"></cfoutput>
	      <cfoutput><td class="indent2">Operator Allowances</td></cfoutput>
 				 <cfset generateDollarCells ( "operator_allowances_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- O P E R A T O R   S P E N D  -  O P E R A T O R   L U M P   S U M --------------------------------------------------------------------------------->
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td class="indent2">Operator Lump Sum</td></cfoutput>
 				 <cfset generateDollarCells ( "LS_Pays_to_All_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- O P E R A T O R   S P E N D ----------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="subTotal box3 tallTop"></cfoutput>
	      <cfoutput><td>Operator Spend</td></cfoutput>
 				 <cfset generateDollarCells ( "Total_Operator_Spend_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- D I S T R I B U T O R   S P E N D   D E T A I L --------------------------------------------------------------------------------------------------->
	    <cfloop query="qDistributorSpendTotal">
		    <cfoutput><tr></cfoutput>
		      <cfoutput><td class="indent2">#qDistributorSpendTotal.Classification_Name#</td></cfoutput>
					 <cfset generateDistributorSpendDetailCells( qDistributorSpendTotal.currentRow )>
	    </cfloop>
	    
	    <!----- D I S T R I B U T O R   S P E N D ----------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="tallTop box3"></cfoutput>
	      <cfoutput><td>Distributor Spend</td></cfoutput>
	      <cfset generateDistributorSpendHeaderCells()>
	    <cfoutput></tr></cfoutput>
	    
	    <!----- T O T A L   S P E N D I N G ----------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="tallTop box2 color1"></cfoutput>
	      <cfoutput><td>Total Trade Spending</td></cfoutput>
	      <cfset generateDollarCells ( "Total_Spend_" )>
	    <cfoutput></tr></cfoutput>
	    
	    <!----- N E T   S A L E S   D O L L A R S ----------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="tallTop box2 color2"></cfoutput>
	      <cfoutput><td>Net Sales $ (NSV)</td></cfoutput>
	      <cfset generateDollarCells ( "Net_Sales_Dollar_" )>
	    <cfoutput></tr></cfoutput>
	    
	    <!----- V A R I A B L E   C O S T ------------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td>Variable Costs</td></cfoutput>
	      <cfset generateDollarCells ( "Variable_Cost_" )>
	    <cfoutput></tr></cfoutput>
	    
	    <!----- V A R I A B L E   C O N T R I B U T I O N --------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="subTotal color2 box3"></cfoutput>
	      <cfoutput><td>Variable Contribution (VC)</td></cfoutput>
	      <cfset generateDollarCells ( "Variable_Contribution_" )>
	    <cfoutput></tr></cfoutput>
	    
	    <!----- V A R I A B L E   C O N T R I B U T I O N   % ----------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="tallTop"></cfoutput>
	      <cfoutput><td>VC %</td></cfoutput>
	      <cfset generatePercentageCells ( "Variable_Contribution_pct_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- F I X E D   C O S T ------------------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td>Fixed Costs</td></cfoutput>
	      <cfset generateDollarCells ( "Fixed_Cost_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- D I R E C T   I N C O M E  ------------------------------------------------------------------------------------------------------------------------>
	    <cfoutput><tr class="color2 box3"></cfoutput>
	      <cfoutput><td>Direct Income (DI)</td></cfoutput>
	      <cfset generateDollarCells ( "direct_income_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- D I R E C T   I N C O M E   % --------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td>DI %</td></cfoutput>
	      <cfset generatePercentageCells ( "direct_income_pct_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- M A R K E T I N G --------------------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="tallBottom"></cfoutput>
	      <cfoutput><td>Marketing</td></cfoutput>
	      <cfset generateDollarCells ( "Marketing_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- S G   & A ----------------------------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td>SG & A</td></cfoutput>
	      <cfset generateDollarCells ( "SGA_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- O T H E R  S G   & A ------------------------------------------------------------------------------------------------------------------------------>
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td>Other SG & A</td></cfoutput>
	      <cfset generateDollarCells ( "Other_SGA_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- O P E R A T I N G   I N C O M E ------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="box2 color2"></cfoutput>
	      <cfoutput><td>Operating Income</td></cfoutput>
	      <cfset generateDollarCells ( "Operating_Income_" )>
	    <cfoutput></tr></cfoutput>
	
	    <!----- O P E R A T I N G   I N C O M E   % --------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="color2 box4"></cfoutput>
	      <cfoutput><td>Operating Income %</td></cfoutput>
	      <cfset generatePercentageCells ( "Operating_Income_pct_" )>
	    <cfoutput></tr></cfoutput>

	    <!----- R A T E S ----------------------------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="rate1 box4"></cfoutput>
	    <cfscript>
	    		vars.colspan = 5;
	    		if ( vars.debug )
	    			vars.colspan = 6;
   				if ( form.branded eq "on" ) {   
   					vars.colspan = vars.colspan + 4;
   				}
					if ( form.privatelabel eq "on" ) {
   					vars.colspan = vars.colspan + 4;
   				}
 					vars.rateLabel = "RATES";
	       if ( form.display eq "totals" or form.display eq "cases_rates" ) {
 						vars.rateLabel = "CASE RATES";
 						vars.rateColumnNameSubStr = "case";
 					}
 					else if ( form.display eq "pounds_rates" ) {
 						vars.rateLabel = "POUND RATES";
 						vars.rateColumnNameSubStr = "pound";
 					}
 					else if ( form.display eq "eqc_rates" ) {
 						vars.rateLabel = "EQC RATES";
 						vars.rateColumnNameSubStr = "eqc";
 					}
	    </cfscript>
	    <cfoutput><td colspan="#vars.colspan#"><b>#vars.rateLabel#</b></td></cfoutput>
	    <cfoutput></tr></cfoutput>

	    <!----- G R O S S   S A L E S ----------------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td>Gross Sales $(GSV)</td></cfoutput>
	      <cfset generateRateCells ( "Gross_Sales_" & vars.rateColumnNameSubStr & "_" )>
	    <cfoutput></tr></cfoutput>

	    <!----- T O T A L   S P E N D I N G ----------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td>Total Trade Spending</td></cfoutput>
	      <cfset generateRateCells ( "Total_Spend_" & vars.rateColumnNameSubStr & "_" )>
	    <cfoutput></tr></cfoutput>

	    <!----- N E T   S A L E S   D O L L A R S ----------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="subTotal"></cfoutput>
	      <cfoutput><td>Net Sales $ (NSV)</td></cfoutput>
	      <cfset generateRateCells ( "Net_Sales_Dollar_" & vars.rateColumnNameSubStr & "_" )>
	    <cfoutput></tr></cfoutput>

	    <!----- V A R I A B L E   C O N T R I B U T I O N --------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td>Variable Contribution (VC)</td></cfoutput>
	      <cfset generateRateCells ( "Variable_Contribution_" & vars.rateColumnNameSubStr & "_" )>
	    <cfoutput></tr></cfoutput>

	    <!----- D I R E C T   I N C O M E  ------------------------------------------------------------------------------------------------------------------------>
	    <cfoutput><tr class=""></cfoutput>
	      <cfoutput><td>Direct Income (DI)</td></cfoutput>
	      <cfset generateRateCells ( "Direct_Income_" & vars.rateColumnNameSubStr & "_" )>
	    <cfoutput></tr></cfoutput>

	    <!----- O P E R A T I N G   I N C O M E ------------------------------------------------------------------------------------------------------------------->
	    <cfoutput><tr class="subTotal box4"></cfoutput>
	      <cfoutput><td>Operating Income (OI)</td></cfoutput>
	      <cfset generateRateCells ( "Operating_Income_" & vars.rateColumnNameSubStr & "_" )>
	    <cfoutput></tr></cfoutput>
	    <cfsetting enablecfoutputonly=false>
  </tbody>
  </cfoutput>
</table>
</cfif>    <!---qTotal.recordCount eq 0--->

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="cssClassForNumber" access="public" output="false">
  <cfargument name="numericValue" required="true">
  
  <cfreturn val( arguments.numericValue ) gte 0 ? '' : "neg">
</cffunction>
  
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="percentFormat" access="public" output="false" hint="Return formatted percentage value">
  <cfargument name="percentValue" required="true">
  
  <cfreturn numberFormat( val( arguments.percentValue ), "(," ) & '%'>
</cffunction>
  
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="generateCell" output="true" hint="Generate content for one numeric td cell">
  <cfargument name="num" required="true">
  <cfargument name="format" required="false" default="dollar">
  <cfargument name="class" required="false" default="">

	<cfscript>
		var tdFormat = "($,"; 
		var tdClass = cssClassForNumber( arguments.num );
	  switch (arguments.format) {
			case "rate": var tdFormat = "($.99"; 
										 break;
		  case "volume": var tdFormat = "(,"; 
		                 break;
		}
	</cfscript>
	<!---<cfif len(arguments.class)>
	  <cfset tdClass = tdClass & " " & arguments.class>
	</cfif>--->
	<cfif len(tdClass)>
		<cfset tdClass = 'class="' & tdClass & '"'>
	</cfif>
	<cfif len(arguments.class)>  <!--- had to use this in-line style due to 6.2 --->
		<cfif arguments.class eq "box1">
	  	<cfset tdClass = tdClass & " style='border-left:1.5px solid black !important;'">
	  </cfif>
	</cfif>
  <!---<cfoutput><cfoutput><td #tdClass#>#numberFormat( val( arguments.num ), ( arguments.volume ? "(," : "($," ) )#</td></cfoutput></cfoutput--->
  <cfoutput><td #tdClass#>#numberFormat( val( arguments.num ), tdFormat )#</td></cfoutput>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="generatePercentageCell" output="true" hint="Generate content for one percentage td cell">
  <cfargument name="num" required="true">
  <cfargument name="class" required="false" default="">
  
	<cfset var tdClass = cssClassForNumber( arguments.num )>
	<!---<cfif len(arguments.class)>
	  <cfset tdClass = tdClass & " " & arguments.class>
	</cfif>--->
	<cfif len(tdClass)>
		<cfset tdClass = 'class="' & tdClass & '"'>
	</cfif>
	<cfif len(arguments.class)>  <!--- had to use this in-line style due to 6.2 --->
		<cfif arguments.class eq "box1">
	  	<cfset tdClass = tdClass & " style='border-left:1.5px solid black !important;'">
	  </cfif>
	</cfif>
	<cfoutput><td #tdClass#>#percentFormat( arguments.num )#</td></cfoutput>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="generateVolumeCells" output="true" hint="Generate content for volume row">
  <cfargument name="columnPrefix" required="true">
  
	<cfif vars.debug>
		<cfoutput><td>#arguments.columnPrefix#ty</td></cfoutput>
	</cfif>
  <!--- add dollar sign to dollar format --->
  <cfscript>
  
   // these cells for Total
   if (qTotal.recordCount eq 0) {
	   generateZeroCells( volume=true );
   }
   else {
	   generateCell( qTotal[ arguments.columnPrefix & "ty" ][ 1 ], "volume" );
	   generateCell( qTotal[ arguments.columnPrefix & "ly" ][ 1 ], "volume" );
	   generateCell( qTotal[ arguments.columnPrefix & "abs_ch" ][ 1 ], "volume" );
	   generatePercentageCell( qTotal[ arguments.columnPrefix & "pct_ch" ][ 1 ] );
   }

   // these cells for Branded
   if ( form.branded eq "on" ) {   
	   if (qBranded.recordCount eq 0) {
		   generateCell( num=0, class="box1" );
		   generateCell( num=0 );
		   generateCell( num=0 );
		   generatePercentageCell( num=0 );
	   }
	   else {
		   generateCell( num=qBranded[ arguments.columnPrefix & "ty" ][ 1 ], format="volume", class="box1" );
		   generateCell( num=qBranded[ arguments.columnPrefix & "ly" ][ 1 ], format="volume" );
		   generateCell( num=qBranded[ arguments.columnPrefix & "abs_ch" ][ 1 ], format="volume" );
		   generatePercentageCell( num=qBranded[ arguments.columnPrefix & "pct_ch"  ][ 1 ] );
		 }
	 }
	
   // these cells for Private Label
	if ( form.privatelabel eq "on" ) {
	   if (qPrivateLabel.recordCount eq 0) {
		   generateCell( num=0, class="box1" );
		   generateCell( num=0 );
		   generateCell( num=0 );
		   generatePercentageCell( num=0 );
	   }
	   else {
		   generateCell( qPrivateLabel[ arguments.columnPrefix & "ty" ][ 1 ], "volume", "box1" );
		   generateCell( qPrivateLabel[ arguments.columnPrefix & "ly" ][ 1 ], "volume" );
		   generateCell( qPrivateLabel[ arguments.columnPrefix & "abs_ch" ][ 1 ], "volume" );
		   generatePercentageCell( qPrivateLabel[ arguments.columnPrefix & "pct_ch" ][ 1 ] );
		 }
	}
  </cfscript>
</cffunction>
                  
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="generateZeroCells" output="true" hint="Generate content for dollar amounts row">
  <cfargument name="volume" required="false" default="false">
  <cfargument name="class" required="false" default="">

  <cfscript>
		generateCell( 0, "volume", arguments.class );
		generateCell( 0, "volume", arguments.class );
		generateCell( 0, "volume", arguments.class );
		generatePercentageCell( 0, arguments.class );
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="generateDollarCells" output="true" hint="Generate content for dollar amounts row">
  <cfargument name="columnPrefix" required="true">
  
	<cfif vars.debug>
		<cfoutput><td>#arguments.columnPrefix#abs_ty</td></cfoutput>
	</cfif>
  <cfscript>
  
	 if ( qTotal.recordCount eq 0 ) {
	   generateZeroCells();
	 }
	 else {
	   // these cells for Total
	   generateCell( qTotal[ arguments.columnPrefix & "abs_ty" ][ 1 ] );
	   generateCell( qTotal[ arguments.columnPrefix & "abs_ly" ][ 1 ] );
	   generateCell( qTotal[ arguments.columnPrefix & "abs_ch" ][ 1 ] );
	   generatePercentageCell( qTotal[ arguments.columnPrefix & "abs_pct_ch" ][ 1 ] );
	 }

   // these cells for Branded
   if ( form.branded eq "on" ) {   
		 if ( qBranded.recordCount eq 0 ) {
		   generateCell( num=0, class="box1" );
		   generateCell( num=0 );
		   generateCell( num=0 );
		   generatePercentageCell( num=0 );
		 }
		 else {
		   generateCell( num=qBranded[ arguments.columnPrefix & "abs_ty" ][ 1 ], class="box1" );
		   generateCell( num=qBranded[ arguments.columnPrefix & "abs_ly" ][ 1 ] );
		   generateCell( num=qBranded[ arguments.columnPrefix & "abs_ch" ][ 1 ] );
		   generatePercentageCell( num=qBranded[ arguments.columnPrefix & "abs_pct_ch" ][ 1 ] );
	   }
	 }
	
   // these cells for Private Label
	if ( form.privatelabel eq "on" ) {
		 if ( qPrivateLabel.recordCount eq 0 ) {
		   generateCell( num=0, class="box1" );
		   generateCell( num=0 );
		   generateCell( num=0 );
		   generatePercentageCell( num=0 );
	   }
	   else {
		   generateCell( num=qPrivateLabel[ arguments.columnPrefix & "abs_ty" ][ 1 ], class="box1" );
		   generateCell( num=qPrivateLabel[ arguments.columnPrefix & "abs_ly" ][ 1 ] );
		   generateCell( num=qPrivateLabel[ arguments.columnPrefix & "abs_ch" ][ 1 ] );
	   	 generatePercentageCell( num=qPrivateLabel[ arguments.columnPrefix & "abs_pct_ch" ][ 1 ] );
	   }
	}
  </cfscript>
</cffunction>
                  
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="generateRateCells" output="true" hint="Generate content for rates row">
  <cfargument name="columnPrefix" required="true">
  
	<cfif vars.debug>
		<cfoutput><td>#arguments.columnPrefix#ty</td></cfoutput>
	</cfif>
  <cfscript>
  
	 if ( qTotal.recordCount eq 0 ) {
	   generateZeroCells();
	 }
	 else {
	   // these cells for Total
	   generateCell( qTotal[ arguments.columnPrefix & "ty" ][ 1 ], "rate" );
	   generateCell( qTotal[ arguments.columnPrefix & "ly" ][ 1 ], "rate" );
	   generateCell( qTotal[ arguments.columnPrefix & "abs_ch" ][ 1 ], "rate" );
	   generatePercentageCell( qTotal[ arguments.columnPrefix & "abs_pct_ch" ][ 1 ] );
	 }

   // these cells for Branded
   if ( form.branded eq "on" ) {   
		 if ( qBranded.recordCount eq 0 ) {
		   generateCell( num=0, class="box1" );
		   generateCell( num=0 );
		   generateCell( num=0 );
		   generatePercentageCell( num=0 );
		 }
		 else {
		   generateCell( num=qBranded[ arguments.columnPrefix & "ty" ][ 1 ], format="rate", class="box1" );
		   generateCell( num=qBranded[ arguments.columnPrefix & "ly" ][ 1 ], format="rate" );
		   generateCell( num=qBranded[ arguments.columnPrefix & "abs_ch" ][ 1 ], format="rate" );
		   generatePercentageCell( num=qBranded[ arguments.columnPrefix & "abs_pct_ch" ][ 1 ] );
	   }
	 }
	
   // these cells for Private Label
	if ( form.privatelabel eq "on" ) {
		 if ( qPrivateLabel.recordCount eq 0 ) {
		   generateCell( num=0, class="box1" );
		   generateCell( num=0 );
		   generateCell( num=0 );
		   generatePercentageCell( num=0 );
	   }
	   else {
		   generateCell( num=qPrivateLabel[ arguments.columnPrefix & "ty" ][ 1 ], format="rate", class="box1" );
		   generateCell( qPrivateLabel[ arguments.columnPrefix & "ly" ][ 1 ], "rate" );
		   generateCell( qPrivateLabel[ arguments.columnPrefix & "abs_ch" ][ 1 ], "rate" );
		   generatePercentageCell( qPrivateLabel[ arguments.columnPrefix & "abs_pct_ch" ][ 1 ] );
	   }
	}
  </cfscript>
</cffunction>
                  
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="generatePercentageCells" output="true" hint="Generate content for percentages row">
  <cfargument name="columnPrefix" required="true">
  
	<cfif vars.debug>
		<cfoutput><td>#arguments.columnPrefix#abs_ty</td></cfoutput>
	</cfif>
  <cfscript>
  
	 if ( qTotal.recordCount eq 0 ) {
	   generateZeroCells();
	 }
	 else {
	   // these cells for Total
	   generatePercentageCell( qTotal[ arguments.columnPrefix & "abs_ty" ][ 1 ] );
	   generatePercentageCell( qTotal[ arguments.columnPrefix & "abs_ly" ][ 1 ] );
	   generatePercentageCell( qTotal[ arguments.columnPrefix & "abs_ch" ][ 1 ] );
	   generatePercentageCell( qTotal[ arguments.columnPrefix & "abs_pct_ch" ][ 1 ] );
	 }

   // these cells for Branded
   if ( form.branded eq "on" ) {   
		 if ( qBranded.recordCount eq 0 ) {
		   generateCell( num=0, class="box1" );
		   generateCell( num=0 );
		   generateCell( num=0 );
		   generatePercentageCell( num=0 );
		 }
		 else {
		   generatePercentageCell( num=qBranded[ arguments.columnPrefix & "abs_ty" ][ 1 ], class="box1" );
		   generatePercentageCell( num=qBranded[ arguments.columnPrefix & "abs_ly" ][ 1 ] );
		   generatePercentageCell( num=qBranded[ arguments.columnPrefix & "abs_ch" ][ 1 ] );
		   generatePercentageCell( num=qBranded[ arguments.columnPrefix & "abs_pct_ch" ][ 1 ] );
	   }
	 }
	
   // these cells for Private Label
	if ( form.privatelabel eq "on" ) {
		 if ( qPrivateLabel.recordCount eq 0 ) {
		   generateCell( num=0, class="box1" );
		   generateCell( num=0 );
		   generateCell( num=0 );
		   generatePercentageCell( num=0 );
	   }
	   else {
		   generatePercentageCell( num=qPrivateLabel[ arguments.columnPrefix & "abs_ty" ][ 1 ], class="box1" );
		   generatePercentageCell( qPrivateLabel[ arguments.columnPrefix & "abs_ly" ][ 1 ] );
		   generatePercentageCell( qPrivateLabel[ arguments.columnPrefix & "abs_ch" ][ 1 ] );
		   generatePercentageCell( qPrivateLabel[ arguments.columnPrefix & "abs_pct_ch" ][ 1 ] );
	   }
	}
  </cfscript>
</cffunction>
                  
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="generateDistributorSpendDetailCells" output="true" hint="Generate content for distributor spend detail row">
  <cfargument name="recordNumber" required="true">
  
	<cfif vars.debug>
		<cfoutput><td>Prof.._Distributor_Spend table</td></cfoutput>
	</cfif>
  <cfscript>
   // these cells for Total
	 if ( qDistributorSpendTotal.recordCount lt arguments.recordNumber ) {
		 generateZeroCells();
   }
   else {
	   generateCell( qDistributorSpendTotal[ "abs_ty" ][ arguments.recordNumber ] );
	   generateCell( qDistributorSpendTotal[ "abs_ly" ][ arguments.recordNumber ] );
	   generateCell( qDistributorSpendTotal[ "abs_ch" ][ arguments.recordNumber ] );
	   generatePercentageCell( qDistributorSpendTotal[ "abs_pct_ch" ][ arguments.recordNumber ] );
   }

   // these cells for Branded
   if ( form.branded eq "on" ) {   
		 if ( qDistributorSpendBranded.recordCount lt arguments.recordNumber ) {
		   generateCell( num=0, class="box1" );
		   generateCell( num=0 );
		   generateCell( num=0 );
		   generatePercentageCell( num=0 );
	   }
	   else {
		   generateCell( num=qDistributorSpendBranded[ "abs_ty" ][ arguments.recordNumber ], format="dollar", class="box1" );
		   generateCell( num=qDistributorSpendBranded[ "abs_ly" ][ arguments.recordNumber ] );
		   generateCell( num=qDistributorSpendBranded[ "abs_ch" ][ arguments.recordNumber ] );
		   generatePercentageCell( num=qDistributorSpendBranded[ "abs_pct_ch" ][ arguments.recordNumber ] );
	   }
	 }
	
   // these cells for Private Label
	if ( form.privatelabel eq "on" ) {
		 if ( qDistributorSpendPrivateLabel.recordCount lt arguments.recordNumber ) {
		   generateCell( num=0, class="box1" );
		   generateCell( num=0 );
		   generateCell( num=0 );
		   generatePercentageCell( num=0 );
	   }
	   else {
		   generateCell( num=qDistributorSpendPrivateLabel[ "abs_ty" ][ arguments.recordNumber ], format="dollar", class="box1" );
		   generateCell( qDistributorSpendPrivateLabel[ "abs_ly" ][ arguments.recordNumber ] );
		   generateCell( qDistributorSpendPrivateLabel[ "abs_ch" ][ arguments.recordNumber ] );
		   generatePercentageCell( qDistributorSpendPrivateLabel[ "abs_pct_ch" ][ arguments.recordNumber ] );
	   }
	}
  </cfscript>
</cffunction>
                  
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="generateDistributorSpendHeaderCells" output="true" hint="Generate content for distributor spend header row">
  
  <cfquery name="qDistributorSpend" dbtype="query">
     SELECT  SUM( abs_ty ) AS abs_ty
            ,SUM( abs_ly ) AS abs_ly
       FROM qDistributorSpendTotal
  </cfquery>
  <cfif qDistributorSpend.recordCount eq 0>
    <cfquery name="qDistributorSpend" dbtype="query">
       SELECT 0 AS abs_ty
             ,0 AS abs_ly
         FROM qOneRow
    </cfquery>
  </cfif>

	<cfif vars.debug>
		<cfoutput><td>Prof.._Distributor_Spend table</td></cfoutput>
	</cfif>
  <cfscript>
   // these cells for Total
   generateCell( qDistributorSpend.abs_ty );
   generateCell( qDistributorSpend.abs_ly );
   generateCell( qDistributorSpend.abs_ty - qDistributorSpend.abs_ly );
   generatePercentageCell( deltaPercentage( ty=qDistributorSpend.abs_ty, ly=qDistributorSpend.abs_ly) );
  </cfscript>

	<cfif form.branded eq "on">
	  <cfquery name="qDistributorSpend" dbtype="query">
	     SELECT  SUM( abs_ty ) AS abs_ty
	            ,SUM( abs_ly ) AS abs_ly
	       FROM qDistributorSpendBranded
	  </cfquery>
	  <cfif qDistributorSpend.recordCount eq 0>
	    <cfquery name="qDistributorSpend" dbtype="query">
	       SELECT 0 AS abs_ty
	             ,0 AS abs_ly
           FROM qOneRow
	    </cfquery>
	  </cfif>
	  <cfscript>
	   generateCell( qDistributorSpend.abs_ty, "dollar", "box1" );
	   generateCell( qDistributorSpend.abs_ly, "dollar", "" );
	   generateCell( qDistributorSpend.abs_ty - qDistributorSpend.abs_ly, "dollar", "" );
	   generatePercentageCell( deltaPercentage( ty=qDistributorSpend.abs_ty, ly=qDistributorSpend.abs_ly), "" );
	  </cfscript>
  </cfif>

	<cfif form.privatelabel eq "on">
	  <cfquery name="qDistributorSpend" dbtype="query">
	     SELECT  SUM( abs_ty ) AS abs_ty
	            ,SUM( abs_ly ) AS abs_ly
	       FROM qDistributorSpendPrivateLabel
	  </cfquery>
	  <cfif qDistributorSpend.recordCount eq 0>
	    <cfquery name="qDistributorSpend" dbtype="query">
	       SELECT 0 AS abs_ty
	             ,0 AS abs_ly
           FROM qOneRow
	    </cfquery>
	  </cfif>
	  <cfscript>
	   generateCell( num=qDistributorSpend.abs_ty, class="box1" );
	   generateCell( qDistributorSpend.abs_ly );
	   generateCell( qDistributorSpend.abs_ty - qDistributorSpend.abs_ly );
	   generatePercentageCell( deltaPercentage( ty=qDistributorSpend.abs_ty, ly=qDistributorSpend.abs_ly) );
	  </cfscript>
  </cfif>
   
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="deltaPercentage" output="false" hint="Return delta percentage based on this year volume and last year volume">
	<cfargument name="ty" required="true" hint="I am this year volume">
	<cfargument name="ly" required="true" hint="I am last year volume">

	<cfif val(arguments.ly) eq 0>
		<cfif val(arguments.ty) eq 0>
			<cfreturn 0>
		<cfelse>
			<cfreturn 100>
		</cfif>
	<cfelse>
			<cfreturn (val(arguments.ty) - val(arguments.ly)) / val(arguments.ly) * 100>
	</cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<script type="text/javascript" src="/Script/javascript/jquery.fixedHeaderTable.js?fo2"></script>
<script type="text/javascript" src="/Script/javascript/table2csv.js"></script>

<script>
  $(function() {
    $("#dataGrid").fixedHeaderTable( { 
       height: ( $(window).height() - 140 )
      ,width: ( Math.max(954, $(window).width() - 7 ) )
    } );
    
    // swap row 1 and row 2 in thead section ( fixedtableheader.js has problems with colspan on row 1 )
    var tempHead = $("#thead2").html();
    $("#thead2").html( $("#thead1").html() );
    $("#thead1").html( tempHead );
    
    getCSVData = function() {
      $("#csv_text").val( $('#dataGrid').table2CSV() ); 
    	$("#csv_file_name").val( $('title').text() + ' - ' + new Date().toDateString() + '.csv' );
      $("#csv_form").submit();
    }
    
    $('a.detail').click(function() {
    	// alert( "UOM = " + $(this).prop("uom") );
    	// href="operatorProfitDetail.cfm?allproducts=#form.allProducts#&operator=#form.operator#&operatorSearchBy=#form.operatorSearchBy#&product=#form.product#" target="_blank"
    	NewWindowTopLeft(<cfoutput>"operatorProfitDetail.cfm?"
    	                           + "allproducts=#form.allProducts#"
    	                           + "&operator=#form.operator#"
    	                           + "&operatorSearchBy=#form.operatorSearchBy#"
    	                           + "&uom=" + $(this).prop("uom")
    	                           + "&product=#form.product#"</cfoutput>, "operatorProfitDetail", 800, 600, "yes", "no");
    	return false;
    });

		<cfif qTotal.recordCount eq 0>
			$("#export").hide();
		</cfif>
  });
</script> 
