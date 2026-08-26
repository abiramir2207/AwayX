<cfparam name="FORM.tfId" type="numeric" default="0"/>
<cfparam name="URL.tfId" type="numeric" default="#FORM.tfId#"/>
<cfparam name="form.marketPriceListId" type="integer"  default="0"/>
<!--- used for ContractMain.cfm -> pass  marketPriceListId in the url.programID var.  --->
<cfparam name="URL.programID" type="numeric" default="#form.marketPriceListId#"/>
<cfparam name="FORM.ID" type="numeric" default="0"/>
<cfparam name="URL.ID" type="numeric" default="#FORM.ID#"/>
<cfparam name="form.sAction" type="string"  default=""/>
<!---<cfparam name="form.rdoMarketPriceListId" type="numeric" default="0"/>--->
<cfparam name="form.dtStartDate" default=""/>
<cfparam name="idx" default="0"/>
<cfparam name="sMessage" default=""/>
<cfparam name="form.bMPFilterContinue" default="0"/>

<HTML>
<HEAD>
<TITLE>Template Filters</TITLE>
  <link rel="stylesheet" href="/styles/templateFilter.css" type="text/css" />
  <script type="text/javascript">
	  function confirmSubmit(txt,listId)
		{
			var agree=confirm(txt + ' Price List ' + listId + '?');
			if (agree) {
				frmMarketPrice.marketPriceListId.value=listId;
				frmMarketPrice.sAction.value=txt;
				frmMarketPrice.submit();
			}
			else {
				frmMarketPrice.marketPriceListId.value=0;
				frmMarketPrice.sAction.value='';
			}
		}
	  function editMarketPricelist(marketPriceListId){
	  			frmMarketPrice.marketPriceListId.value = marketPriceListId;
				frmMarketPrice.sAction.value='Edit';
				frmMarketPrice.submit();
	  }
	  function saveDate(marketPriceListId,startDate){
	  	alert('save date' + marketPriceListId + ' :: ' + startDate)
	  }
	  
	  function doSubmit(newDate,MPId) {
	      //submit if we really changed
	     if (newDate != eval('frmMarketPrice.dtOrigDate' + MPId + '.value')) {
		 	//alert(newDate + ' :: ' + MPId + ' :: ' + eval('frmMarketPrice.dtOrigDate' + MPId + '.value'));
			frmMarketPrice.marketPriceListId.value = MPId;
			frmMarketPrice.sAction.value='Update';
			frmMarketPrice.submit();
		 }
	  }
  </script>
</HEAD>

<!--- retrieve all settings and place them into request.settings variable --->
<cfset application.util.query.request_settings()>

<!--- label D26730  by Dinesh FLEX POP-UP START--->
<cfif form.sAction EQ 'EDIT'>
	<cfif request.settings.Program_Rate_Format is "Flex">
		<cfoutput>
		<script type="text/javascript">
		window.open( "/flex/program/contractMain.cfm?bMarketPrice=1&programID=#url.programID#&TemplateFiltersID=#URL.tfId#", "Rates_Window", "status = 1, height = 800, width = 1200, resizable = 1" )
		</script> 
		</cfoutput>
	<cfelse>
		<cfoutput>
		<script type="text/javascript">
		window.open( "/Programs/product/rate_main_marketprice.cfm?programID=#url.programID#&TemplateFiltersID=#URL.tfId#", "Rates_Window", "status = 1, height = 800, width = 1200, resizable = 1" )
		</script> 
		</cfoutput>
	</cfif>
</cfif>
<!--- label D26730  by Dinesh FLEX POP-UP END --->

<!--- **************  Controller  ************** --->
<cfscript>
    CR    = Chr(13);             // Carriage return
    LF    = Chr(10);             // Line feed
    CRLF  = CR & LF;
	templateManager 		= CreateObject("component","components.programs.template.TemplateManager").init();
	objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
	objCF					= CreateObject("component","mvc.Models.CF");
	appSettings = application.appsettingsGet;
	switch(form.sAction)
    {
        case "Add":
        {
            //if MP & addFilter action create new filter
			if(isDate(form.dtStartDate)){
				//insert new price list
				objMarketPriceManager.insertMPHeader(URL.tfId,form.dtStartDate);
			}
			else{
				//show error
				sMessage = sMessage & 'Please enter a valid date' & CRLF;
			}
            break;
        }
        //Comment for label D26730  by Dinesh to make FLEX  as POP-UP 
       /*case "Edit":
        {
            //edit rates: call prod rate tool
			URL.bMarketPrice = 1;
			objCF.include('/flex/program/contractMain.cfm');
			objCF.abort();
            break;
        }*/
		case "Activate":
		case "Update":
        {
			//activate
			dtActivateStartDate = '';
			//check for an update date first -> different form field
			if(isDate(evaluate('form.dtStartDate' & form.marketPriceListId))){
				dtActivateStartDate = evaluate('form.dtStartDate' & form.marketPriceListId);
			}
			else if(isDate(form.dtStartDate)){
				dtActivateStartDate = form.dtStartDate;
			}
			stComplete = objMarketPriceManager.activateMP(URL.tfId,form.marketPriceListId,dtActivateStartDate);
            if(!stComplete.bActivateFlag){
				sMessage = form.sAction & ' Failed:' & '<br/>' & stComplete.sMessage;
			}
			else{
				sMessage = form.sAction &  ' Complete:' & '<br/>' & stComplete.sMessage;
			}
            break;
        }
		/*case "Update":
        {
			//activate
			dtUpdateStartDate = '';
			if(isDate(evaluate('form.dtStartDate' & form.marketPriceListId))){
				dtUpdateStartDate = evaluate('form.dtStartDate' & form.marketPriceListId);
			}
			//Run same logic as activate
			stComplete = objMarketPriceManager.activateMP(URL.tfId,form.marketPriceListId,dtUpdateStartDate);
            sMessage = 'Update:' & '<br/>' & stComplete.sMessage;
            break;
        }*/
		case "Delete":
        {
			//delete
            sMessage = objMarketPriceManager.deleteMP(URL.tfId,form.marketPriceListId);
			sMessage = sMessage & CRLF;
            break;
        }
        default:
        {
            //anything
            break;
        }
    } //end switch
	/* after form action is processed get current list of MP's */
	template = templateManager.get(URL.ID);
	/* returns all Mp's for this template filter */
	arrMarketPrices = objMarketPriceManager.getMarketPriceLists(URL.tfId,'mpType');
	/* check number of active lists */
	iActiveCount = 0;
	for (i=1;i LTE ArrayLen(arrMarketPrices);i=i+1) {
		//WriteOutput(objCF.dump(arrMarketPrices[i]));
		if(arrMarketPrices[i].Status == 'active'){
			iActiveCount++;
		}
	}
	bActivateFlag = iActiveCount < 2;
	dmpTemplate = '';//bActivateFlag;//objCF.dump(arrMarketPrices);
</cfscript>
<!--- If save and continue is clicked --->
<cfif Form.bMPFilterContinue>
	<cfset filterPageName = 'market_price' />
			<cfset form.rdoFilter = form.tfId />
			<cfinclude template="/program_wizard/filter/filter_page_List.cfm" />
			<cfinclude template="/program_wizard/filter/filter_Next_Page.cfm" />
</cfif>
<BODY>
<cfoutput>#dmpTemplate#</cfoutput>
<!---<cfdump var="#form#"/>--->
<cfform name="frmMarketPrice" action="marketPrice.cfm" format="html">
<cfoutput><span class="txtRed">#sMessage#</span></cfoutput>
<table width="100%" class="NoBorder" cellspacing="0" cellpadding="3">
    <tr class="NoBorder">
        <td class="NoBorder">
        	<cfoutput>
				
					<!---<cfinput type="datefield"  
							id="dtStartDate" 
							name="dtStartDate" 
							required="true"
							validate="date" 
							mask="mm/dd/yyyy"  
							message = "Enter a correctly formatted date (dd/mm/yy)"
							validateat="onSubmit,onBlur"  />--->
							
					<cfinput type="button" name="btnNew" value="New Price List" onclick="frmMarketPrice.sAction.value='Add';frmMarketPrice.submit();">
					<!---<cfinput type="button" name="btnEdit" value="Edit Rates" onclick="frmMarketPrice.sAction.value='Edit';frmMarketPrice.submit();">--->
					<cfinput type="hidden" id="dtStartDate" name="dtStartDate" value="#dateFormat(now(),'mm/dd/yyyy')#"/>
					<cfinput type="hidden" id="ID" name="ID" value="#URL.ID#"/>
					<cfinput type="hidden" id="tfId" name="tfId" value="#URL.tfId#"/>
					<cfinput type="hidden" id="sAction" name="sAction" value="#form.sAction#"/>
					<cfinput type="hidden" id="marketPriceListId" name="marketPriceListId" value="#form.marketPriceListId#"/>
					<cfinput type="hidden" id="bMPFilterContinue" name="bMPFilterContinue" value="0"/>
				
			</cfoutput>
        </td>
    </tr>
    <tr class="NoBorder">
        <td class="NoBorder">
	        <table width="75%" class="baTable"  cellspacing="0" cellpadding="3">
	        			<tr class="NoBorder">
					        <td class="rowHead">
								Action
							</td>
							<td class="rowHead">
					        	Id
					        </td>	
					        <td class="rowHead">
					        	Status
					        </td>
							<td class="rowHead">
					        	Start Date
					        </td>
							<td class="rowHead">
					        	End Date
					        </td>
							<td class="rowHead">
					        	Updated
					        </td>
					    </tr>
		       <cfloop array="#arrMarketPrices#" index="MarketPrice">
					<cfset idx = idx + 1 />
					  <cfoutput>
                      	  <tr <cfif (idx MOD 2) EQ 0>class="white"<cfelse>class="ltgreen"</cfif>>
						        <td class="baTd">
						        <cfif MarketPrice.Status NEQ 'active' AND bActivateFlag>
							       <!--- <input type="button" 
											name="btnActivate" 
											value="Activate" 
											onclick="confirmSubmit('Activate',#MarketPrice.MARKET_PRICE_LIST_ID#);" 
											enabled="#bActivateFlag#">--->
											
									<CF_smallLink 
												title = "activate" 
												url = "##"
												parameters = "onClick=""confirmSubmit('Activate',#MarketPrice.MARKET_PRICE_LIST_ID#); return false;""">
								</cfif>
								<!---<cfif MarketPrice.Start_Date GT NOW() OR MarketPrice.Status EQ 'wip'>--->
									<!---<input type="button" 
											name="btnDelete" 
											value="Delete" 
											onclick="confirmSubmit('Delete',#MarketPrice.MARKET_PRICE_LIST_ID#);" 
											enabled="">--->
									<CF_smallLink 
												title = "delete" 
												url = "##"
												parameters = "onClick=""confirmSubmit('Delete',#MarketPrice.MARKET_PRICE_LIST_ID#); return false;""">
						       <!---</cfif>--->
							   		<!---<input type="button" 
											name="btnEdit" 
											value="Edit rates" 
											onclick="editMarketPricelist(#MarketPrice.MARKET_PRICE_LIST_ID#);" 
											enabled="">--->
									<CF_smallLink 
												title = "rates" 
												url = "##"
												parameters = "onClick=""editMarketPricelist(#MarketPrice.MARKET_PRICE_LIST_ID#); return false;""">
								</td>
								<td class="baTd">
						        	#MarketPrice.MARKET_PRICE_LIST_ID#
						        </td>	
						        <td class="baTd">
						        	#MarketPrice.Status#&nbsp;
						        </td>
						        <td class="baTd">
						        	<cfif (MarketPrice.Status EQ 'wip' AND bActivateFlag) OR (MarketPrice.Status EQ 'active' AND MarketPrice.Start_Date GTE Dateformat(now(),'mm/dd/yyyy'))>
										<cfinput type="datefield" value="#DateFormat(MarketPrice.Start_Date,'medium')#"
											id="dtStartDate#MarketPrice.MARKET_PRICE_LIST_ID#" 
											name="dtStartDate#MarketPrice.MARKET_PRICE_LIST_ID#" 
											validate="date" 
											mask="mm/dd/yyyy"  
											message = "Enter a correctly formatted date (dd/mm/yy)"
											validateat="onSubmit" />
											<!---<script>
												eval(" var frmMarketPrice.dtOrigDate#MarketPrice.MARKET_PRICE_LIST_ID#.value = '#MarketPrice.Start_Date#';");
											</script>--->
											<cfinput type="hidden" 
												id="dtOrigDate#MarketPrice.MARKET_PRICE_LIST_ID#" 
												name="dtOrigDate#MarketPrice.MARKET_PRICE_LIST_ID#" 
												value="#Dateformat(MarketPrice.Start_Date,'mm/dd/yyyy')#"/>
											<cfajaxproxy bind="javaScript:doSubmit({dtStartDate#MarketPrice.MARKET_PRICE_LIST_ID#},#MarketPrice.MARKET_PRICE_LIST_ID#)">
									<cfelse>
										#MarketPrice.Start_Date#
										<cfinput type="hidden" 
												id="dtStartDate#MarketPrice.MARKET_PRICE_LIST_ID#" 
												name="dtStartDate#MarketPrice.MARKET_PRICE_LIST_ID#" 
												value="#Dateformat(MarketPrice.Start_Date,'mm/dd/yyyy')#"/>
									</cfif>
						        </td>
								<td class="baTd">
						        	#MarketPrice.End_Date#&nbsp;
						        </td>
								<td class="baTd">
						        	<cfif trim(MarketPrice.UpdatedUserName) NEQ ''> 
										#MarketPrice.UpdatedUserName#<br/>&nbsp;#dateFormat(MarketPrice.UpdatedDate,'medium')#&nbsp;#timeFormat(MarketPrice.UpdatedDate,'short')#
									</cfif>
						        </td>
						    </tr>
                      </cfoutput>
				</cfloop>
			</table>
				
        </td>
    </tr>
	<tr>
		<td class="NoBorder">
			<!--- <table width="75%" border="0">
			    <tr>
			        <td align="right">
			        	&nbsp;&nbsp;<CF_smallLink 
						title = "Save and Continue" 
						url = "##"
						parameters = "onClick=""javascript: document.getElementById('bMPFilterContinue').value=1;frmMarketPrice.submit();return false;""">
				
			        </td>
			    </tr>
			</table>	 --->
		</td>
	</tr>
</table>
</cfform>
</BODY>
</HTML>