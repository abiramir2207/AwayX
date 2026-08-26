<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Formula_Pricing\V2\ajaxSearchCommodityPrices.cfm
      Date:     2016 Dec
      Author:   Mark Saunders
      Purpose:  aJax processing for Searching Commoddity Prices

	Remarks: 
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="form.start"   default="0">
  <cfparam name="form.length"  default="200">
  <cfparam name="form.sEcho"   default="10">
<!---  <cfparam name="form.draw"    default="33">--->
  <cfparam name="form.searchString"   default="">
  <cfparam name="form.commDate"   default="">
  <cfparam name="form.sSearch_3" default="">
  <cfparam name="form.sSearch_4" default="">
  <cfparam name="form.Symbol" default="">
  <cfparam name="form.Sub_Category_Name" default="">
  <cfparam name="form.Exchange_Detail_Abrev" default="">
  <cfparam name="form['ORDER[0][DIR]']" default=""> 
  <cfparam name="form['ORDER[0][COLUMN]']" default=""> 
<!---<cfdump var="#form["ORDER[0][COLUMN]"]#" output="c:\dump.log" >--->
  <cfscript>
    tmp   = {};
    reply = {};
    tmp.seeAll = -1;
    
    tmp.page_size   = val(form.length);
    if ( tmp.page_size eq tmp.seeAll) {    // users want to see all 
      tmp.start_row   = 1;
      tmp.end_row     = tmp.seeAll;
    }
    else {
      tmp.start_row   = form.start + 1;
      tmp.end_row     = form.start + tmp.page_size;
    }
    
		searchString   = trim(searchString);
		form.sSearch_3 = trim(form.sSearch_3);
    form.sSearch_4 = trim(form.sSearch_4);
  	
  	// parse search string into an array of words
  	if ( len(searchString) ) {
  		tmp.arrayOfWords = reMatch( "[[:word:]]+", form.searchString );
  	}
  	else {
  		tmp.arrayOfWords = [];
  	}  	
  	
  	// concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
 		tmp.listOfWords = arrayToList(tmp.arrayOfWords, "%");
  </cfscript>

  <cfoutput>
  <cfquery name="tmp.qCommodities" datasource="#application.datasource#">
    SELECT 
          <cfif tmp.end_row neq tmp.seeAll> TOP #tmp.end_row# </cfif>
		cs.Symbol_Description as Symbol,
		Comm_Last,
		Comm_High,
		Comm_Low,
		CONVERT(Varchar(10),Comm_Datetime,101) AS Comm_Datetime,
		Category_Name,
		Sub_Category_Name,
		CED.Exchange_Detail_Abrev,
		Exchange_Detail_Name,
		C.Comm_Open
	FROM	Commodities_Symbol CS
	INNER JOIN Commodities C ON
		C.Commodities_Symbol_ID = cs.Commodities_Symbol_ID
	INNER JOIN Commodities_Report_Log L On 
		l.Commodities_Report_Log_Id = C.Commodities_Report_Log_Id
	LEFT JOIN Commodities_Sub_Category CSC ON
		C.Sub_Category_ID = CSC.Sub_Category_ID
	INNER JOIN Commodities_Category CC ON
		CC.Category_ID = C.Category_ID
	INNER JOIN Commodities_Exchange_Detail CED ON
		CED.Exchange_Detail_ID = CS.Exchange_Detail_ID
	WHERE C.Comm_Datetime 
			<cfif len(form.commDate)>
				= '#form.commDate#'
			<cfelse>
				> DATEADD(DAY,-712,getdate())
			</cfif>
	          <!--- quick search at the top left --->
	          <cfif len( tmp.listOfWords )>
								AND (    Symbol LIKE '%#tmp.listOfWords#%' 
								      OR Comm_Last LIKE '%#tmp.listOfWords#%' 
								      OR Sub_Category_Name LIKE '%#tmp.listOfWords#%' 
								      OR Comm_High LIKE '%#tmp.listOfWords#%' 
								      OR Comm_Low LIKE '%#tmp.listOfWords#%' 
								      OR Comm_Datetime LIKE '%#tmp.listOfWords#%' 
									  OR Category_Name LIKE '%#tmp.listOfWords#%' 
									  OR CED.Exchange_Detail_Abrev LIKE '%#tmp.listOfWords#%' 
									  OR Exchange_Detail_Name LIKE '%#tmp.listOfWords#%' 
									  OR Symbol_Description LIKE '%#tmp.listOfWords#%' 
								    )
	          </cfif>
	          <cfif len( form.Symbol )>
								AND (    Symbol LIKE '%#form.Symbol#%' OR Symbol_Description LIKE '%#form.Symbol#%')
		          </cfif>
		          <cfif len( form.Sub_Category_Name )>
									AND (    Sub_Category_Name LIKE '%#Sub_Category_Name#%'  )
		          </cfif>
		          <cfif len( form.Exchange_Detail_Abrev )>
									AND (    CED.Exchange_Detail_Abrev LIKE '%#form.Exchange_Detail_Abrev#%'  )
		          </cfif>
	              
	         	<cfswitch expression="#form['ORDER[0][COLUMN]']#">
	            <cfcase value='0'> ORDER BY  Symbol   #form['ORDER[0][DIR]']# </cfcase>
	            <cfcase value='1'> ORDER BY  Comm_Last #form['ORDER[0][DIR]']# </cfcase>
	            <cfcase value='2'> ORDER BY  Comm_High   #form['ORDER[0][DIR]']# </cfcase>
	            <cfcase value='3'> ORDER BY  Comm_Low        #form['ORDER[0][DIR]']# </cfcase>
				<cfcase value='4'> ORDER BY  C.Comm_Open   #form['ORDER[0][DIR]']# </cfcase>
	            <cfcase value='5'> ORDER BY  C.Comm_Datetime   #form['ORDER[0][DIR]']# </cfcase>
	            <cfcase value='6'> ORDER BY  Category_Name #form['ORDER[0][DIR]']# </cfcase>
	            <cfcase value='7'> ORDER BY  Sub_Category_Name   #form['ORDER[0][DIR]']# </cfcase>
	            <cfcase value='8'> ORDER BY  CED.Exchange_Detail_Abrev    #form['ORDER[0][DIR]']# </cfcase>
	            <cfcase value='9'> ORDER BY  Exchange_Detail_Name        #form['ORDER[0][DIR]']# </cfcase>
	            <cfdefaultcase>	ORDER BY C.Comm_Datetime desc</cfdefaultcase>
	           </cfswitch>
  </cfquery>
<!--- <cfdump var="#tmp.qCommodities#" output="c:\dump.log" > --->
  </cfoutput>
  
  <!---get total number of records BEFORE filtering--->
  <cfquery name="totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
	      FROM	Commodities_Symbol CS
		INNER JOIN Commodities C ON
			C.Commodities_Symbol_ID = cs.Commodities_Symbol_ID
		INNER JOIN Commodities_Report_Log L On 
			l.Commodities_Report_Log_Id = C.Commodities_Report_Log_Id
		LEFT JOIN Commodities_Sub_Category CSC ON
			C.Sub_Category_ID = CSC.Sub_Category_ID
		INNER JOIN Commodities_Category CC ON
			CC.Category_ID = C.Category_ID
		INNER JOIN Commodities_Exchange_Detail CED ON
			CED.Exchange_Detail_ID = CS.Exchange_Detail_ID
		WHERE C.Comm_Datetime > DATEADD(DAY,-712,getdate())
  </cfquery>

  <cfset reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

  <cfif  len(trim(form.commDate)) or len(trim(tmp.listOfWords)) >
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
      	SELECT COUNT(1) as rownbr
	   	FROM	Commodities_Symbol CS
		INNER JOIN Commodities C ON
			C.Commodities_Symbol_ID = cs.Commodities_Symbol_ID
		INNER JOIN Commodities_Report_Log L On 
			l.Commodities_Report_Log_Id = C.Commodities_Report_Log_Id
		LEFT JOIN Commodities_Sub_Category CSC ON
			C.Sub_Category_ID = CSC.Sub_Category_ID
		INNER JOIN Commodities_Category CC ON
			CC.Category_ID = C.Category_ID
		INNER JOIN Commodities_Exchange_Detail CED ON
			CED.Exchange_Detail_ID = CS.Exchange_Detail_ID
		WHERE C.Comm_Datetime	<cfif len(form.commDate)>
				= '#form.commDate#'
			<cfelse>
				> DATEADD(DAY,-712,getdate())
			</cfif>
		          <!--- quick search at the top left --->
		          <cfif len( tmp.listOfWords )>
									AND (    Symbol LIKE '%#tmp.listOfWords#%' 
									      OR Comm_Last LIKE '%#tmp.listOfWords#%' 
									      OR Sub_Category_Name LIKE '%#tmp.listOfWords#%' 
									      OR Comm_High LIKE '%#tmp.listOfWords#%' 
									      OR Comm_Low LIKE '%#tmp.listOfWords#%' 
									      OR Comm_Datetime LIKE '%#tmp.listOfWords#%' 
										  OR Category_Name LIKE '%#tmp.listOfWords#%' 
										  OR CED.Exchange_Detail_Abrev LIKE '%#tmp.listOfWords#%' 
										  OR Exchange_Detail_Name LIKE '%#tmp.listOfWords#%' 
										  OR Symbol_Description LIKE '%#tmp.listOfWords#%' 
									    )
		          </cfif>
		           <cfif len( form.Symbol )>
								AND (    Symbol LIKE '%#form.Symbol#%' OR Symbol_Description LIKE '%#form.Symbol#%' )
		          </cfif>
		          <cfif len( form.Sub_Category_Name )>
									AND (    Sub_Category_Name LIKE '%#Sub_Category_Name#%'  )
		          </cfif>
		          <cfif len( form.Exchange_Detail_Abrev )>
									AND (    CED.Exchange_Detail_Abrev LIKE '%#form.Exchange_Detail_Abrev#%'  )
		          </cfif>
    </cfquery>
    <!---get total no. of records AFTER filtering--->
    <cfset reply.iTotalDisplayRecords = totalAfterFilter.rownbr>
  </cfif>


<!--- get Exchange Detail Abbreviation drop down data--->
<cfset CommodityPrices	= createObject("component","mvc.Models.Admin.Commodity.CommodityPrices") />
<cfset qExchangeAbbreviationDropDown = CommodityPrices.getExchangeDetails() />

  <!--- Generate JSON from Query --->
  <cfscript>
  	reply.aaData = [];
  	if ( tmp.end_row eq tmp.seeAll ) {
    	tmp.start_row = 1;
    	tmp.end_row   = tmp.qCommodities.recordCount;
   	}
  	else {
    	 tmp.end_row   = min(tmp.end_row, tmp.qCommodities.recordCount);
    }
  </cfscript>
  
  <cfset reply.aaExchFilterData = [] />
  
  <cfloop query="qExchangeAbbreviationDropDown">
    <cfscript>
		dExchArrayTmp = [];
       	arrayAppend(dExchArrayTmp, qExchangeAbbreviationDropDown.Exchange_Detail_Abrev);
		arrayAppend(reply.aaExchFilterData, dExchArrayTmp);
    </cfscript>
  </cfloop>


  <cfoutput>
  <cfloop query="tmp.qCommodities" startRow="#tmp.start_row#" endRow="#tmp.end_row#">
    <cfscript>
       dArrayTmp = [];
       arrayAppend(dArrayTmp, tmp.qCommodities.Symbol);
       arrayAppend(dArrayTmp, tmp.qCommodities.Comm_Last);
       arrayAppend(dArrayTmp, tmp.qCommodities.Comm_High);
       arrayAppend(dArrayTmp, tmp.qCommodities.Comm_Low);
	   arrayAppend(dArrayTmp, tmp.qCommodities.Comm_Open);
       arrayAppend(dArrayTmp, tmp.qCommodities.Comm_Datetime);
       arrayAppend(dArrayTmp, tmp.qCommodities.Category_Name);
       arrayAppend(dArrayTmp, tmp.qCommodities.Sub_Category_Name);
       arrayAppend(dArrayTmp, tmp.qCommodities.Exchange_Detail_Abrev);
       arrayAppend(dArrayTmp, tmp.qCommodities.Exchange_Detail_Name);
       arrayAppend(reply.aaData, dArrayTmp);
    </cfscript>
  </cfloop>
  </cfoutput>
  
  <cfscript>
  	  reply.draw  = javacast('int', form.draw);
	 // reply.sEcho  = javacast('int', form.draw);
	  tmp.sOut     = serializeJSON( reply );
	
	  // Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way
	//  tmp.sOut = replace (tmp.sOut, 'SECHO', 'sEcho', 'one');
	  tmp.sOut = replace (tmp.sOut, 'DRAW', 'draw', 'one');
	  tmp.sOut = replace (tmp.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one');
	  tmp.sOut = replace (tmp.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one');
	  tmp.sOut = replace (tmp.sOut, 'AADATA', 'aaData', 'one');
	  tmp.sOut = replace (tmp.sOut, 'AAEXCHFILTERDATA', 'aaExchFilterData', 'one');
	</cfscript>
</cfsilent>

<!---send JSON data back to client--->
<cfoutput>#tmp.sOut#</cfoutput>
</cfprocessingdirective>