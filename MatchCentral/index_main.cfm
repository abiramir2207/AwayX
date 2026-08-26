<cfsetting showdebugoutput="false">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfparam name="SESSION.FILTERremainingBalance" default="false">
<cfparam name="URL.showSearch" default="false">
<cfparam name="url.fromBB" default="0">
<cfparam name="url.BBID" default="0">

<cfscript>
	MCObject = createObject("Component","components.Match_Central.MatchCentral").init();
	genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
	appSettings = genSettingsManager.get();
	PAGE_TITLE = "Match Central";
	getDDAutoMatchSettings = MCObject.getDDAutoMatchSettings();
        Dollar_Amount_Value = getDDAutoMatchSettings.Dollar_Amount_Value;
</cfscript>

<HTML>
<HEAD>
	<TITLE>Match Central</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="css/MatchCentralStyle.css">
	<SCRIPT SRC="/Script/javascript/prototype/prototype.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/prototype/scriptaculous.js"></SCRIPT>
	<SCRIPT SRC="/script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/script/javascript/genresize.js"></SCRIPT>
	<SCRIPT>
// TO TRACK AJAX REQUESTS FOR PROPER PROCESSING OF MATCHING AND UPDATING OF BALANCES
	Ajax.Responders.register(
		{
			onCreate: function()
			{
				Ajax.activeRequestCount++;
			},
			onComplete: function()
			{
				Ajax.activeRequestCount--;
			}
		}
	);

// LOADER FUNCTIONS
	var searchingLoader = 'Searching...<br />The system is gathering your results.';
	var loadingLoader = 'Loading...<br />The system is loading your data.';
	var loadingNoImg = 'Loading Data...<br /><br />Please wait while the page loads in your browser.<br /> This may take a few minutes.';
	var matchProcessor = 'Please wait...<br />Your matches are being processed';
	var processingLoader = 'Please wait... <br />The system is processing your request.';

	var iLoaderCallCount = 0;
	showLoader = function(type)  // showLoader('search');
	{
		if (type == 'search'){
			htmlCode = searchingLoader;
		} else if (type == 'load'){
			htmlCode = loadingLoader;
		} else if (type == 'loadNoImg'){
			htmlCode = loadingNoImg;
		} else if (type == 'process'){
			htmlCode = matchProcessor;
		} else if (type == 'process2'){
			htmlCode = processingLoader;
		}

		var obj1 = $('masterLoadingDiv');
		var obj2 = $('loaderDiv');
		var obj3 = $('loaderText');

		obj1.style.display = 'block';
		obj2.style.display = 'block';
		obj3.innerHTML = htmlCode;

		iLoaderCallCount++;
	}
	hideLoader = function()
	{
		iLoaderCallCount--;

		if(iLoaderCallCount == 0)
		{
			var obj1 = $('masterLoadingDiv');
			var obj2 = $('loaderDiv');

			obj1.style.display = 'none';
			obj2.style.display = 'none';
		}
	}
	showMiniLoader = function()
	{
		$('miniLoader').style.display = 'block';
		document.body.style.cursor = 'wait';
	}
	hideMiniLoader = function()
	{
		$('miniLoader').style.display = 'none';
		document.body.style.cursor = 'default';
	}

// CONTAINER UPDATE FUNCTIONS
	updateMatchList = function(updTyp,workItemID,matchItem,bReloadItemList)
	{
		if(updTyp == 0) {
			var param = {workItemID:workItemID, bbtomatch:matchItem};
		} else if(updTyp == 1){
			var param = {clear:updTyp, workItemID:workItemID, idremove:matchItem};
		} else if(updTyp == 2){
			var param = {clear:updTyp, workItemID:workItemID};
		} else if(updTyp == 3){
			var param = {workItemID:workItemID};
		} else if(updTyp == 4){
			var param = {clear:updTyp};
		} else if(updTyp == 5){
			var param = {workItemID:workItemID, ddtomatch:matchItem};
		} else if(updTyp == 6){
			var param = {workItemID:workItemID, crtomatch:matchItem};
		}
		var options = {parameters		:	param
						,onFailure		:	itemListError
						,evalscripts	:	true
						,onLoading		:	showLoader('process2')
						,onComplete		:
											function()
											{
												hideLoader();
												if(bReloadItemList) reloadItemList(workItemID);
											}};

		new Ajax.Updater($('matchList'),'MC_Match_list.cfm', options);
	}
	updateWorkList = function(updTyp,typid,typ,matchTyp)
	{
		if (updTyp == 0) {
			var param = {typid:typid, typ:typ, matchTyp:matchTyp};
		} else if (updTyp == 1) {
			var param = {clear:1, typidremove:typid, typ:typ};
		} else if (updTyp == 2) {
			var param = {clear:2};
		}
		var options = {parameters		:	param
						,onFailure		:	itemListError
						,evalscripts	:	true
						,onLoading		:	showMiniLoader
						,onComplete		:	hideMiniLoader};

		new Ajax.Updater($('workList'),'MC_work_list.cfm', options);
	}
	updateItemList = function(amt,ddid,distid)
	{
		var distid = distid;
		if(ddid != 'none'){
			if (typeof(window['distid']) != "undefined"){
				var options = {parameters:{itemAmount:amt, ddid:ddid, distid:distid}, onFailure:itemListError, evalscripts:true};
			} else {
				var options = {parameters:{itemAmount:amt, ddid:ddid}, onFailure:itemListError, evalscripts:true};
			}
		} else {
			var options = {parameters:{resetItemList:true},
					onFailure:itemListError,
					evalscripts:true,
					onLoading:showLoader('search'),
					onComplete:hideLoader};
		}

		new Ajax.Updater($('itemList'),'MC_item_list_BB.cfm', options);
	}

// CONTAINER RESETS
	resetRemainingDollar = function()
	{
		$('remainingDollarAmount').innerHTML = '$0.00';
	}
	resetMatchList = function()
	{
		$('matchList').innerHTML = '<div id="waterMark" class="matchListWatermarkMargin">MATCH LIST</div>';
	}
	resetItemList = function()
	{
		$('itemList').innerHTML = '<div id="waterMark" class="itemListWatermarkMargin">ITEM LIST<br /><font size="3">(SELECT AN ITEM FROM THE WORK LIST)</font></div>';
	}
	resetWorkList = function()
	{
		new Ajax.Updater($('workList'),'MC_work_list.cfm');
	}


	// REMAINING BALANCE FUNCTIONS
	updateRemainingDollar = function(itemAmt,mode)
	{
		/* This was "innerHTML" before. I changed it to innerText for IE 10 as "innerHTML" was also including
		the main style css file too. It seems like it should have been "innerText" anyway to get just
		the dollar amount.
		*/
		matchedAmt = parseFloat($('currentMatchedAmount').innerText);
		itemAmt = parseFloat(itemAmt);

		if (mode == 'add'){
			var num = matchedAmt + itemAmt;
			var itemAmount = num.toFixed(2);
		} else if(mode == 'minus'){
			var num = matchedAmt - itemAmt;
			var itemAmount = num.toFixed(2);
		} else if(mode == 'null'){
			num = matchedAmt;
			var itemAmount = num.toFixed(2);
		}

		$('currentMatchedAmount').innerHTML = itemAmount;

		var options1 = {parameters:{itemAmount:itemAmount}, onFailure:itemListError, evalscripts:true};
		new Ajax.Updater($('remainingDollarAmount'),'MC_remaining_dollar.cfm', options1);

		var row = $('workItemRow').innerHTML;
		var options2 = {parameters:{itemAmount:itemAmount,smallBalance:true}, onFailure:itemListError, evalscripts:true};
		new Ajax.Updater($('remBal2'+row),'MC_remaining_dollar.cfm', options2);

	}

	getMatchedAmounts = function(workItem)
	{
		distid = $('SelectedDistributorID').innerHTML;
		var options1 = {parameters:{workItem:workItem,distid:distid,showItemList:true},
						onFailure:itemListError,
						evalscripts:true,
						onLoading:showLoader('search'),
						onComplete:hideLoader};
		new Ajax.Updater($('itemList'),'MC_get_matched_amounts.cfm', options1);

		var options2 = {parameters	:	{workItem:workItem,showItemList:false,numberOnly:true},
						onFailure	:	itemListError,
						evalscripts	:	true};
		new Ajax.Updater($('currentMatchedAmount'),'MC_get_matched_amounts.cfm', options2);

		setLink(0);
	}

// WORK LIST SEARCH FUNCTIONS
	toggleSearchDiv = function()
	{
		if($('SearchContainer').style.display == 'none'){
			new Effect.BlindDown($('SearchContainer'), {duration:.200})
			if($('SearchContainer').innerHTML == ""){
				workListSearch('DD');
			}
		} else {
			new Effect.BlindUp($('SearchContainer'), {duration:.200})
		}
	}

	workListSearch = function(typ)
	{
		var options = {parameters:{searchType:typ}, onFailure:workListError, evalscripts:true};
		new Ajax.Updater($('SearchContainer'),'MC_work_list_search.cfm', options);
	}

	DoWorkListSearch = function(typ)
	{
		setLink(0);
		resetWorkList();
		resetMatchList();

		var errorCount = 0;

		if (typ == 'DD' || typ == 'CR'){
			if ($F('ddnum') == ""
				&& $F('analystid') == ""
				&& $F('Distributor') == ""
				&& $F('Broker_Name') == ""
				&& $F('Distributor_Name') == ""
				&& $F('DD_Ref') == ""
				&& $F('Check_No') == "")
			{
				new Effect.BlindDown($('formValidationError'), {duration:.200});
				errorCount++;
			} else {
				if ($('formValidationError').style.display != 'none'){
					new Effect.BlindUp($('formValidationError'), {duration:.200});
				}
			}
		} else if (typ == 'BB'){
			if ($F('bb_code') == ""
				&& $F('bb_title') == ""
				&& $F('soldToNo') == ""
				&& $F('Distributor_Name') == ""
				&& $F('ReferenceNum') == ""
				&& $F('Billback_Number') == "")
			{
				new Effect.BlindDown($('formValidationError'), {duration:.200});
				errorCount++;
			} else {
				if ($('formValidationError').style.display != 'none'){
					new Effect.BlindUp($('formValidationError'), {duration:.200});
				}
			}
		}

		if (errorCount == 0){
			toggleSearchDiv();
			$('randomValue').value = Math.floor(Math.random()*1001);
			var formData = $('workListFrm').serialize(true);
			var searchCriteria = formData;
			var options = {
					parameters:searchCriteria,
					onFailure:itemListError,
					evalscripts:true,
					onLoading:showLoader('search'),
					onComplete:hideLoader
					};
			new Ajax.Updater($('itemList'),'MC_work_list_search_results.cfm', options);
		}
	}

// WORK LIST ADMIN FUNCTIONS
	addToWorkList = function(typid,typ,matchTyp)
	{
		if (Ajax.activeRequestCount == 0){
			updateWorkList(0,typid,typ,matchTyp);
		}
	}
	/*75568	Match Central - mass select and create list options START*/

	selectAll = function (all,typ){
		 var boxes = document.getElementsByTagName("input");
		 var ltyp = typ.toLowerCase();
		 var Selectedlist = '';

		  for (var x = 0; x < boxes.length; x++) {
		    var obj = boxes[x];
		    if (obj.type == "checkbox") {
		    		if(obj.name == 'IndividualCheckBox'){
							obj.checked = all.checked;
		    			Selectedlist = Selectedlist.concat(obj.value).concat(',');
		    		}
			  }
			}

			document.getElementById('Selected'+typ).value=Selectedlist;

		   if(all.checked){
	        	document.getElementById(ltyp).style.display='block'; // DISPLAY  LINKS TO ADD TO MATCH LIST OR WORK LIST
	     }else{
	       	document.getElementById(ltyp).style.display='none';
	       	document.getElementById('Selected'+typ).value = '' //CLEAR OUT PREVIOUS SELECTION
	     }
	}

	selectSingle = function(id, typ){
		var status = id.checked;
		var ltyp = typ.toLowerCase();
		var Selectedlist = document.getElementById('Selected'+typ).value;

		if( status){
			Selectedlist = Selectedlist.concat(id.value).concat(',');
		}else{
			Selectedlist = Selectedlist.replace(id.value, "");
		}

		document.getElementById('Selected'+typ).value=Selectedlist;
		document.getElementById(ltyp).style.display='block';

		if( ! status){
			document.all.checkAll.checked = false;
		}

		var checkboxes = document.getElementsByName("IndividualCheckBox");
		var allchecked = 'true';
		var anychecked = 'false';

		for (var i = 0; i < checkboxes.length; i++) {
			if (! checkboxes[i].checked) {
				allchecked = 'false';
			}
			if (checkboxes[i].checked) {
				anychecked = 'true';
			}
		}
		if(anychecked =='false'){
			document.getElementById(ltyp).style.display='none';
		}
		if(allchecked == 'true'){
			document.all.checkAll.checked = true;
		}

	}

	var latestSelectedList = "";

	add2WorkList = function(typ, wType, mType){
		var selectedlist = document.getElementById('Selected'+typ).value;
					selectedlist = selectedlist.split(',');
					selectedlist = selectedlist.filter(Boolean);

		latestSelectedList = selectedlist; // store so it can be used in next function

		/************* Ajax call start ***************/
		var param = {typid:selectedlist, typ:wType, matchTyp:mType};
		var options = {parameters		:	param
						,onFailure		:	itemListError
						,evalscripts	:	true
						,onLoading		:	showMiniLoader
						,onComplete		:	add2WorkListCompleted};

		new Ajax.Updater($('workList'),'MC_work_list.cfm', options);
		/************* Ajax call end ***************/

		// uncheck the checkboxes
		for (var i = 0; i < selectedlist.length; i++) {
			document.getElementById(selectedlist[i]+'_CheckBox').click();
		}
		document.getElementById('Selected'+typ).value = '';
	}

	add2WorkListCompleted = function(){
		/*******************************************************************
		List of items that just got added = latestSelectedList
		List of items in work list = workListItems
		Loop over each item and set to locked if it is present in both list
		******************************************************************/
		var workListItems = document.getElementsByName('item');
		var selectedItem = "";
		var cannotAddItemList = 0;
		for (var i = 0; i < latestSelectedList.length; i++) {
			selectedItem = latestSelectedList[i];
			var selectedItemFoundInWorkList = 0;
			for (var j = 0; j < workListItems.length; j++) {
				if(workListItems[j].value == selectedItem){//match found
					document.getElementById(workListItems[j].value+'_CheckBox').style.display='none';
					document.getElementById(workListItems[j].value+'_Lock').style.display='block';
					selectedItemFoundInWorkList = 1;
				}
			}
			if(!selectedItemFoundInWorkList)
			cannotAddItemList++;
		}

		if(cannotAddItemList == 1)
			alert ("This record was not added to work list as it is no longer available. Please search again.");
		else if(cannotAddItemList > 1)
			alert (cannotAddItemList + " records were not added to work list as they are no longer available. Please search again.");

		hideMiniLoader();
	}

	add2MatchList = function(typ, mType, wType){
		var workItem = '';
		var BB_Approved_Amount= 0;
		var selectedlist = document.getElementById('Selected'+typ).value;
		<cfoutput>
		if ( $('matchList').innerHTML.match('waterMark') || '#appSettings.getSplitBillbacks()#' == '1'  || wType != 'BB') {
		</cfoutput>
		 	selectedlist = selectedlist.split(',');
			selectedlist = selectedlist.filter(Boolean);
			workItem = document.getElementById('workItem').value;
			for (var i = 0; i < selectedlist.length; i++) {

				// workItem = workItem.concat(document.getElementById(selectedlist[i]+'_workItem').value).concat(',');
				BB_Approved_Amount = parseFloat(BB_Approved_Amount) + Number(document.getElementById(selectedlist[i]+'_Approved_Amount').value);

				document.getElementById(selectedlist[i]+'_CheckBox').style.display='none';
				document.getElementById(selectedlist[i]+'_Lock').style.display='block';
			}

				//workItem = workItem.split(',');
				//workItem = workItem.filter(Boolean);
				//BB_Approved_Amount = BB_Approved_Amount.split(',');
				//BB_Approved_Amount = BB_Approved_Amount.filter(Boolean);

			addToMatchList(selectedlist,workItem,BB_Approved_Amount,mType,wType);

			document.getElementById('Selected'+typ).value = '';

		}
		else alert( 'This action will result in a split billback and that action is prohibited in the environment.' );
	}

	function NewWindow(mypage,myname,w,h,scroll,resize,returnWindow,menubar){
		myname = myname || "_popup_" + random367();
		w = w || ( screen.availWidth * 0.85 );
		h = h || ( screen.availHeight * 0.85 );
		scroll = scroll || "1";
		resize = resize || "1";
		returnWindow = returnWindow || "0";
		menubar = menubar || "0";
		var winl=(screen.width-w)/2;var wint=(screen.height-h)/2;status="";winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable='+resize+',status='+status;if(menubar){winprops=winprops+',menubar='+menubar}win=window.open(mypage,myname.replace(/\s/g, ''),winprops);if(parseInt(navigator.appVersion)>=4){win.window.focus()}
		if(returnWindow){return win}
	}

	function createlist(searchType, workItem, DistID){
		NewWindow("MC_create_list.cfm?searchType="+searchType+"&workItem="+workItem+"&DistID="+DistID, "createList", 500, 500, "yes", "yes");
	}

	/*75568	Match Central - mass select and create list options END*/
	clearWorkListItem = function(ddid,typ)
	{
		if (Ajax.activeRequestCount == 0){
			setLink(0);
			if (confirm('Are you sure you want to remove this item from the work list?')) {
				updateWorkList(1,ddid,typ);
				resetItemList();
				resetMatchList();
				resetRemainingDollar();
			} else {
				return;
			}
		}
	}
	clearWorkList = function()
	{
		setLink(0);
		if (confirm('Are you sure you want to remove all items from the work list? \nThis will clear all matches as well.')) {
			// All of these functions reset all containers and hide some data,
			// also removes selections that were added to the xml files.
			updateWorkList(2,'null');
			resetItemList();
			resetMatchList();
			resetRemainingDollar();
		} else {
			return;
		}
	}

	setItemListFilters = function(TYP, ID,DIST)
	{
		AMT = $F('FILTERamount');
		if(TYP == 'BB'){
			DIS = $F('FILTERdistributor1') || $F('FILTERdistributor2') || $F('FILTERdistributor3');
			RNUM = $F('FILTERrefnumber');
		}else{
		DIS = $F('FILTERdistributor');
		RNUM = null;
		}
		BAL = $F('FILTERremainingBalance');
		keyword = $F('resultsKeyword');

		CreateList = $F('MC_CreateList');

		if(CreateList.length){
			AMT = null;
			DIS = null;
			BAL = null;
			RNUM = null;
		}

		if(AMT == null){
			AMT = false;
		}
		if(DIS == null){
			DIS = false;
		}
		if(BAL == null){
			BAL = false;
			$('remBalFilter').innerHTML = 'false';
		} else {
			$('remBalFilter').innerHTML = 'true';
		}

		if(RNUM == null){
			RNUM = false;
		}
		var options = {parameters:
							{
								workItem		:	ID,
								distid			:	DIST,
								showItemList	:	true,
								amtFilter		:	AMT,
								distFilter		:	DIS,
								balFilter		:	BAL,
								refFilter		: 	RNUM,
								keyword	:	keyword,
								MC_Createlist : CreateList
							},
							onFailure		:	itemListError,
							evalscripts		:	true,
							onLoading		:	showLoader('search'),
							onComplete		:	hideLoader
						};
		new Ajax.Updater($('itemList'),'MC_get_matched_amounts.cfm', options);

		/* Narrow results based on "Filter By keyword" */
		narrowSearchResults(ID,DIST);
	}

	narrowSearchResults = function(ID,DIST)
	{
		toggleDiv('contents');

		keyword = $F('resultsKeyword');

		var options = {parameters:
							{
								workItem		:	ID,
								distid			:	DIST,
								keyword			:	keyword,
								showItemList		:	true,
								MC_Createlist 		: CreateList
							},
							onFailure		:	itemListError,
							evalscripts		:	true,
							onLoading		:	showLoader('search'),
							onComplete		:	hideLoader
						};
		new Ajax.Updater($('itemList'),'MC_get_matched_amounts.cfm', options);
	}

// AUTOMATIC ITEM SEARCH BASED ON SELECTION IN WORK LIST
	workThisItemDD = function(ddid,amount,row,distid)
	{
		// Update the remaining balance
		var options2 = {parameters:{workItem:ddid,showItemList:false}, onFailure:itemListError, evalscripts:true};
		new Ajax.Updater($('remainingDollarAmount'),'MC_get_matched_amounts.cfm', options2);

		// Update the worklist to hilite the selected row
		$('workItemRow').innerHTML = row;
		$('SelectedDistributorID').innerHTML = distid;

		var options = {parameters:{rowHilite:row}, onFailure:itemListError, evalscripts:true};
		new Ajax.Updater($('workList'),'MC_work_list.cfm', options);

		// Set some containers with amounts to use in other aspects of Match Central
		// I have found that using ajax sometimes removes the value from a hidden form field.
		// By setting an innerHTML of a hidden div, the data will be available until it is overwritten.
		$('currentWorkItemAmount').innerHTML = amount;
		$('currentWorkItemID').innerHTML = ddid;

		// Get matched amounts if they exist and update the item list afterward
		getMatchedAmounts(ddid);

		// Update the match list with items already matched
		updateMatchList(3,ddid);

		/* Narrow results based on "Filter By keyword" */
		narrowSearchResults(ddid,distid);
	}

	workThisItemCR = function(crdid,amount,row,distid)
	{
		// Update the remaining balance
		var options2 = {parameters:{workItem:crdid,showItemList:false}, onFailure:itemListError, evalscripts:true};
		new Ajax.Updater($('remainingDollarAmount'),'MC_get_matched_amounts.cfm', options2);

		// Update the worklist to hilite the selected row
		$('workItemRow').innerHTML = row;
		$('SelectedDistributorID').innerHTML = distid;

		var options = {parameters:{rowHilite:row}, onFailure:itemListError, evalscripts:true};
		new Ajax.Updater($('workList'),'MC_work_list.cfm', options);

		// Set some containers with amounts to use in other aspects of Match Central
		// I have found that using ajax sometimes removes the value from a hidden form field.
		// By setting an innerHTML of a hidden div, the data will be available until it is overwritten.
		$('currentWorkItemAmount').innerHTML = amount;
		$('currentWorkItemID').innerHTML = crdid;

		// Get matched amounts if they exist and update the item list afterward
		getMatchedAmounts(crdid);

		// Update the match list with items already matched
		updateMatchList(3,crdid);

		/* Narrow results based on "Filter By keyword" */
		narrowSearchResults(crdid,distid);
	}

	workThisItemBB = function(bbid,amount,row)
	{
		// Update the remaining balance
		var options2 = {parameters:{workItem:bbid,showItemList:false}, onFailure:itemListError, evalscripts:true};
		new Ajax.Updater($('remainingDollarAmount'),'MC_get_matched_amounts.cfm', options2);

		// Update the worklist to hilite the selected row
		$('workItemRow').innerHTML = row;

		var options = {parameters:{rowHilite:row}, onFailure:itemListError, evalscripts:true};
		new Ajax.Updater($('workList'),'MC_work_list.cfm', options);

		// Set some containers with amounts to use in other aspects of Match Central
		// I have found that using ajax sometimes removes the value from a hidden form field.
		// By setting an innerHTML of a hidden div, the data will be available until it is overwritten.
		$('currentWorkItemAmount').innerHTML = amount;
		$('currentWorkItemID').innerHTML = bbid;

		// Get matched amounts if they exist and update the item list afterward
		getMatchedAmounts(bbid);

		// Update the match list with items already matched
		updateMatchList(3,bbid);

		/* Narrow results based on "Filter By keyword" */
		narrowSearchResults(bbid,distid);
	}

// MATCH LIST ADMIN FUNCTIONS
	addToMatchList = function(idToMatch,workItemID,amount,matchTyp,workTyp)
	{
		// Only add to the match list if all the ajax requests are complete
		if (Ajax.activeRequestCount == 0){
			if ( $('matchList').innerHTML.match('waterMark') ||<cfoutput>'#appSettings.getSplitBillbacks()#'</cfoutput> == '1'  || workTyp != 'BB') {
				if(matchTyp == 'DD'){
					var matchListType = 5;
					var param = {checkSelectedDD:true, matchItem:idToMatch, workItem:workItemID};
					var matchResponse = 'DDDoesNotExist';
					if(workTyp == 'CR'){
						var mathType = 'add';
					} else if (workTyp == 'BB'){
						var mathType = 'minus';
					}
				} else if (matchTyp == 'BB'){
					var matchListType = 0;
					var matchResponse = 'BBDoesNotExist';
					var param = {checkSelectedBB:true, matchItem:idToMatch, workItem:workItemID};
					var mathType = 'minus';
				} else if (matchTyp == 'CR'){
					var matchListType = 6;
					var param = {checkSelectedCR:true, matchItem:idToMatch, workItem:workItemID};
					var matchResponse = 'CRDoesNotExist';
					if(workTyp == 'BB'){
						var mathType = 'minus';
					} else if (workTyp == 'DD'){
						var mathType = 'add';
					}
				}


				var options = {parameters:param,
							onFailure:itemListError,
							evalscripts:true,
							onSuccess: function(transport)
										{
											if (transport.responseText.match(matchResponse)){
												updateMatchList(matchListType,workItemID,idToMatch,1);
												updateRemainingDollar(amount,mathType);
											} else {
												alert('This item is already selected, please choose another.');
											}
										}
							};
					new Ajax.Request('MC_remaining_dollar.cfm', options);
			}
			else alert( 'This action will result in a split billback and that action is prohibited in the environment.' );
		}
	}
	reloadItemList = function(workItemID)
	{
		if($('remBalFilter').innerHTML == 'true'){
			distid = $('SelectedDistributorID').innerHTML;
			getMatchedAmounts(workItemID);
		}
	}
	clearMatchListItem = function(matchedItem,workItem,amount,code,matchTyp,workTyp)
	{
		if (Ajax.activeRequestCount == 0){
			setLink(0);

			if (matchTyp == 'DD') {
				if(workTyp == 'CR') {
					updateRemainingDollar(amount,'minus');
				} else if (workTyp == 'BB') {
					updateRemainingDollar(amount,'add');
				}
			} else if (matchTyp == 'CR') {
				if(workTyp == 'DD') {
					updateRemainingDollar(amount,'minus');
				} else if (workTyp == 'BB') {
					updateRemainingDollar(amount,'add');
				}
			} else if (matchTyp == 'BB'){
				updateRemainingDollar(amount,'add');
			}
			updateMatchList(1,workItem,matchedItem,1);

			if ($(code+'col') != null){
 				$(matchedItem+'_Lock').hide();
				$(matchedItem+'_CheckBox').show();
				$(matchedItem+'_CheckBox').checked = false;
				//$(code+'col').style.backgroundImage = 'url(/Images/matchListAdd.gif)';
				$(code+'col').style.backgroundPosition = 'center center';
				$(code+'col').style.backgroundRepeat = 'no-repeat';
				$(code).style.backgroundColor='yellow';
				$(code+'col').title="You removed this from the match list. Click to re-match.";
			}

		}
	}

// PREVIEW PANE CODE
	bbPreview = function(url,bbid)
	{
		var options = {parameters:{bbid:bbid,matchCENTRAL:true}, onFailure:itemListError, evalscripts:true, onLoading:showLoader('load'), onComplete:loadPreviewData};
		new Ajax.Request(url, options);
	}
	loadPreviewData = function(request)
	{
		new Effect.BlindDown($('previewPaneWrapper'),{duration:.500});
		hideLoader();
		$('previewPane').innerHTML = request.responseText;
	}

// VALIDATION AND PROCESSING FUNCTIONS
	validateAllMatches = function(){
		var options = {
					onFailure:itemListError,
					evalscripts:true,
					onLoading:showLoader('load'),
					onComplete:validatePageComplete};
		new Ajax.Updater($('itemList'),'MC_validate_matches.cfm', options);

		resetRemainingDollar();
		resetMatchList();
		resetWorkList();
		setLink(1);
		$('itemList').scrollTop = 0;
	}

	validatePageComplete = function(){
		hideLoader();
		validatePageDisplayNegativeBalanceMessage();
	}

	<!--- D25418: If credit is OFF, do not allow user to continue if the balance is negative amount --->
	validatePageDisplayNegativeBalanceMessage = function(){
		if ($F('negativeBalanceWhenNoCredit') == "1"){
			$('negativeMessageTable').style.display = "";
		}
		// WR 64833
		if($F('autoReconcileDollarAmount') == "1"){
			$('autoRecoAmtMessageTable').style.display = "";
		}
	}

	showError = function(obj)
	{
		new Effect.BlindDown(obj, {duration:.200});
		new Effect.Pulsate(obj, {delay:.200, duration:2})
	}
	hideError = function(obj)
	{
		if(obj){
			if(obj.style.display != "none"){
				obj.style.display = "none";
			}
		}
	}
	processMatching = function()
	{
		<!--- D25418: If credit is OFF, do not allow user to continue if the balance is negative amount --->
		if ($F('negativeBalanceWhenNoCredit') == "1"){
			alert('At least one of your matches results in a negative balance, which is not allowed based on the current configuration.\n\n Please adjust your matches accordingly and re-validate your match results.');
			return;
		}
		//  WR 64833
		else if($F('autoReconcileDollarAmount') == "1"){
			alert('At least one of your total Auto Reconcile amounts is greater than <cfoutput>#Dollarformat(Dollar_Amount_Value)#</cfoutput> maximum allowed in the current configuration.\n\n Please adjust your matches accordingly and re-validate your match results.');
			return;
		}
		else if($F('ErrorBBSplitNotAllowed') == "1"){
			alert('This action will result in a split billback and that action is prohibited in the environment.');
			return;
		}


		// Validate form fields
		var loopCount = $F('loopCount');
		var errorCount = 0;

		// Hide all error messages so that if any errors remain, they will show up again.
		for (i=1; i<=loopCount; i++){
			hideError($('ReasonCode_'+i+'_error'));
			hideError($('DefaultClass_'+i+'_Error'));
			hideError($('ClassificationID_'+i+'_Error'));
			hideError($('ReasonCodeForSplit_'+i+'_Error'));
			hideError($('DefaultClassForSplit_'+i+'_Error'));
			hideError($('ClassificationIDForSplit_'+i+'_Error'));
			hideError($('whattodo_'+i+'_error'));
		}

		for (i=1; i<=loopCount; i++){
			if ($F('ReasonCode_'+i) == ""){
				errorCount++
				showError($('ReasonCode_'+i+'_error'));
			}
			<cfif appSettings.getDD_Show_Classification()>
				var defaultClass = $F('DefaultClass_'+i);
				var selectedClass = $F('ClassificationID_'+i);

				<cfif appSettings.getDDChangeClassificationBeforeRFA()>
					var defaultClassError = $('DefaultClass_'+i+'_error');
					if (defaultClass == selectedClass || selectedClass == ""){
						errorCount++
						showError(defaultClassError);
					}
				<cfelse>
					var selectedClassError = $('ClassificationID_'+i+'_error');
					if (selectedClass == ""){
						errorCount++
						showError(selectedClassError);
					}
				</cfif>
			</cfif>

			// validate so that write off cannot be selected when balance is against billback
			var splitRecord = $F('SplitRecord_'+i);
			var splitRecordCanWriteOff = 1;
			if(splitRecord.substr(0, 2) == "BB"){
				splitRecordCanWriteOff = 0;
				if ($F('whatToDo_'+i) == "writeOff"){
					errorCount++
					showError($('whatToDo_'+i+'_error'));
				}
			}

			if ($F('whatToDo_'+i) == "writeOff" && splitRecordCanWriteOff){
				if ($F('ReasonCodeForSplit_'+i) == ""){
					errorCount++
					showError($('ReasonCodeForSplit_'+i+'_error'));
				}
				<cfif appSettings.getDD_Show_Classification()>
					var defaultClass = $F('DefaultClassForSplit_'+i);
					var selectedClass = $F('ClassificationIDForSplit_'+i);

					<cfif appSettings.getDDChangeClassificationBeforeRFA()>
						var defaultClassError = $('DefaultClassForSplit_'+i+'_error');
						if (defaultClass == selectedClass || selectedClass == ""){
							errorCount++
							showError(defaultClassError);
						}
					<cfelse>
						var selectedClassError = $('ClassificationIDForSplit_'+i+'_error');
						if (selectedClass == ""){
							errorCount++
							showError(selectedClassError);
						}
					</cfif>
				</cfif>
			}
		}

		// If form passes validation, run the processing
		if (errorCount == 0){
			var formData = $('matchProcessorForm').serialize(true);
			var options = {
						parameters:formData,
						onFailure:itemListError,
						evalscripts:true,
						onLoading:showLoader('process')
						,onComplete:function(r) {
							if(r.responseText.length){
								alert(r.responseText);
								hideLoader();
							}else{
								reloadMainPage();
							}
						}
					};
			new Ajax.Request('MC_process_matching.cfm', options);
		} else {
			alert('One or more of the required fields are invalid.\n\nPlease verify that all fields are filled in or selected properly.');
			$('itemList').scrollTop = 0;
			return;
		}
	}

// SORTING, PAGING, AND GENERAL USER INTERFACE FUNCTIONS
	NextPrevSortPage = function(SR,SF,SO,typ) //SR = Start Row
	{
		var MR = $F('maxRows');
			if(MR > 200){
				var options = {parameters:{pagingstartrow:SR, initialSearch:false, sortField:SF, sortOrder:SO, typ:typ, pagingmaxrows:MR}, evalscripts:true,
							onLoading:showLoader('loadNoImg'),
							onComplete:hideLoader};
			} else {
				var options = {parameters:{pagingstartrow:SR, initialSearch:false, sortField:SF, sortOrder:SO, typ:typ, pagingmaxrows:MR}, evalscripts:true};
			}

		new Ajax.Updater($('itemList'),'MC_work_list_search_results.cfm', options);
		$('itemList').scrollTop = 0;
	}

// DEDUCTION MATCH SORTING
	NextPrevSortPageDDmatch = function(SR,SF,SO,typ) //SR = Start Row
	{
		var workItem = $('currentWorkItemID').innerHTML;
		var MR = $F('maxRows');
		if(MR > 200){
			var options = {parameters:{pagingstartrow:SR, initialSearch:false, workItem:workItem, sortField:SF, sortOrder:SO, typ:typ, pagingmaxrows:MR}, evalscripts:true,
						onLoading:showLoader('loadNoImg'),
						onComplete:hideLoader};
		} else {
			var options = {parameters:{pagingstartrow:SR, initialSearch:false, workItem:workItem, sortField:SF, sortOrder:SO, typ:typ, pagingmaxrows:MR}, evalscripts:true};
		}
		new Ajax.Updater($('itemList'),'MC_item_list_DD.cfm', options);
		$('itemList').scrollTop = 0;
	}


// BILLBACK MATCH SORTING
	NextPrevSortPageBBmatch = function(SR,SF,SO,typ) //SR = Start Row
	{
		var workItem = $('currentWorkItemID').innerHTML;
		var MR = $F('maxRows');
		if(MR > 200){
			var options = {parameters:{pagingstartrow:SR, initialSearch:false, workItem:workItem, sortField:SF, sortOrder:SO, typ:typ, pagingmaxrows:MR}, evalscripts:true,
						onLoading:showLoader('loadNoImg'),
						onComplete:hideLoader};
		} else {
			var options = {parameters:{pagingstartrow:SR, initialSearch:false, workItem:workItem, sortField:SF, sortOrder:SO, typ:typ, pagingmaxrows:MR}, evalscripts:true};
		}
		new Ajax.Updater($('itemList'),'MC_item_list_BB.cfm', options);
		$('itemList').scrollTop = 0;
	}
	adjustSplitAction = function(sSuffix)
	{
		var splitRecordObj = $('SplitRecord_' + sSuffix);
		if(splitRecordObj){
			var selectedOption = splitRecordObj.options[splitRecordObj.selectedIndex];
			var selectedOptionVal = selectedOption.value
			var splitActionObj = $('whatToDo_' + sSuffix);
			if(selectedOption.allowWriteOff == "0"){

				if(splitActionObj.value == "writeOff"){
					splitActionObj.selectedIndex = 0; // set it to keep open
					adjustWriteOffDetails(splitActionObj, sSuffix);
				}
			}
			//Decide if we Allow Auto Reconcile
			var z = 99;
			for (var i = 0; i < splitActionObj.length; i++) {
				if(splitActionObj[i].value == 'auto'){//get index of Auto reconcile select option
					z = i;
				}
			}


			if(selectedOption.getAttribute('allowAutoReconcile') == "1"){
				if(z==99){ //add option
					var optnAuto = document.createElement("OPTION");

					optnAuto.text = 'Auto Reconcile';
					optnAuto.value = 'auto';
					splitActionObj.options.add(optnAuto);
					splitActionObj.selectedIndex = (splitActionObj.length - 1);
					adjustWriteOffDetails(splitActionObj, sSuffix);

				}
			}
			else{
				if(z!=99){ //remove option
					splitActionObj.remove(z);
				}
				//splitActionObj.disabled = false;
			}
			for (var i = 0; i < splitActionObj.length; i++) {
				if(splitActionObj.options[i].value != 'auto' && selectedOption.getAttribute('allowAutoReconcile') == "1"){//get index of Auto reconcile select option
					splitActionObj.options[i].disabled = true;
				}
				else{
					splitActionObj.options[i].disabled = false;
				}
			}
			<cfif appSettings.getIntegrated_Rebill()>
			//Ana - 19384 - remove rebill when the split is not on DD
			if(selectedOptionVal.substring(0, 2) != 'DD')
			{
			splitActionObj.remove(1);
			}
			//Ana - 19384 - add rebill
			if(selectedOptionVal.substring(0, 2) == 'DD')
			{
				var optn = document.createElement("OPTION");
				var optn1 = document.createElement("OPTION");

				splitActionObj.remove(1);

				optn.text = 'Rebill';
				optn.value = 'rebill';
				splitActionObj.options.add(optn);

				optn1.text = 'Write it off';
				optn1.value = 'writeOff';
				splitActionObj.options.add(optn1);
			}
			</cfif>
		}
	}
	adjustWriteOffDetails = function(oThis, sSuffix)
	{
		 if(oThis.value == 'writeOff'){
		 	showHideDiv('rebillPackage' + sSuffix,false);
			showHideDiv('rebillDtl' + sSuffix,false);
			showHideDiv('writeOffReasonContainer' + sSuffix,true);
			showHideDiv('ReasonCodeForSplit' + sSuffix,true);
			showHideDiv('writeOffOpenClass' + sSuffix,true);
		}
		else if(oThis.value == 'rebill'){
			showHideDiv('writeOffReasonContainer' + sSuffix,false);
			showHideDiv('ReasonCodeForSplit' + sSuffix,false);
			showHideDiv('writeOffOpenClass' + sSuffix,false);
			showHideDiv('rebillPackage' + sSuffix,true);
			showHideDiv('rebillDtl' + sSuffix,true);
		}
		else {
			showHideDiv('writeOffReasonContainer' + sSuffix,false);
			showHideDiv('ReasonCodeForSplit' + sSuffix,false);
			showHideDiv('rebillPackage' + sSuffix,false);
			showHideDiv('rebillDtl' + sSuffix,false);
			showHideDiv('writeOffOpenClass' + sSuffix,true);
		}

	}

// HELPER DISPLAY FUNCTIONS
	showHideDiv = function(objName,show)
	{
		if (show == true){
			new Effect.BlindDown($(objName),{duration:.100});
		} else {
			new Effect.BlindUp($(objName),{duration:.100});
		}
	}
	toggleDiv = function(objName)
	{
		Effect.toggle(objName, 'slide', { duration: .100 });
	}
	showToolTip = function(objName)
	{
		new Effect.Appear($(objName),{duration:.200});
		new Effect.Fade($(objName),{duration:.200, delay:5});
	}
	setLink = function(mode)
	{
		if (mode == 0){
			$('ValidateLink').style.display = 'inline';
			$('ProcessingLink').style.display = 'none';
		} else {
			$('ValidateLink').style.display = 'none';
			$('ProcessingLink').style.display = 'inline';
		}
	}
	onEnter = function(evt,frm,typ)
	{
		var keyCode = null;

		if(evt.which) {
			keyCode = evt.which;
		} else if( evt.keyCode ) {
			keyCode = evt.keyCode;
		}

		if(13 == keyCode) {
			DoWorkListSearch(typ);
			return false;
		}
		return true;
	}

// PAGE AND ERROR FUNCTIONS
	reloadMainPage = function(request)
	{
		// Comment out if you wish to debug the form output
		alert('Your matching has completed successfully.')
		window.location.href = '/MatchCentral/index_main.cfm';

		// will only process if the above location.href is commented out.  Used for debugging for submitting
		$('itemList').innerHTML = request.responseText;
		hideLoader();
	}

	// Error functions
	workListError = function(request)
	{
		$('workList').innerHTML='<b><font size="4" color="red">! Sorry. There was an error.<b></font>  ' + request.responseText;
	}

	itemListError = function(request)
	{
		$('itemList').innerHTML='<b><font size="4" color="red">! Sorry. There was an error.<b></font>  ' + request.responseText;
	}

	populateRebillPakData = function(oThis, sSuffix)
	{
		var splitRecordObj = eval("document.all.SplitRecord_" + sSuffix);
		var balanceAmt = $('RemainingAmount_' + sSuffix).value;
		var param = {rebillPakID:oThis.value,
					suffixID:sSuffix,
					ddID:splitRecordObj.value,
					balanceAmount:balanceAmt};
		var divName = "rebillDtl"+sSuffix;

/*		alert(splitRecordObj.value);
		return;*/
		var options = {parameters		:	param
						,onFailure		:	itemListError
						,evalscripts	:	true
						,onLoading		:	showMiniLoader
						,onComplete		:	hideMiniLoader};
		new Ajax.Updater($(divName),'MC_rebill_package_population.cfm', options);
	}



	function lenCheck(oThis,sSuffix,startLen)
	{
		var oMsg = eval("document.all.rebillMessage_" + sSuffix)
		var msg = oMsg.value.length;
		var lenText = eval("document.all.Len_" + sSuffix);
		var remLen = startLen - msg;
		lenText.value = remLen;
	}


	</SCRIPT>
</HEAD>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" TOPMARGIN="0" MARGINHEIGHT="0" LEFTMARGIN="5" MARGINWIDTH="0">
<cfoutput>
<div id="HelpContainer" style="display:none;">
	<fieldset>
		<legend>Match Central Help &nbsp;</legend>
			1. Search for a items by clicking on the 'Search' button.<br /><br />
			2. Drag and drop the items you would like to work on, directly to the work list.<br /><br />
			3. Click on an item from the work list, all associated items will display in the item list.<br /><br />
			4 .Drag and drop the items from the item list to the bottom left drop container.  These are the items you would like to match to the currently selected option in the work list.<br /><br />
			5. Repeat steps 3 and 4 for all items in the work list.<br /><br />
			6. Choose whether to apply the currently selected matching from the work list, or apply all the matches you've worked on.<br /><br />
	</fieldset>
</div>
<!--- STORAGE CONTAINERS FOR DATA TO BE USED IN OTHER FUNCTIONS --->
<div id="remBalFilter" style="display:none;">#session.FILTERremainingBalance#</div>
<div id="currentMatchedAmount" style="display:none;"></div>
<div id="currentWorkItemAmount" style="display:none;"></div>
<div id="currentWorkItemID" style="display:none;"></div>
<div id="SelectedDistributorID" style="display:none;"></div>
<div id="workItemRow" style="display:none;"></div>

<!--- LOADING CONTAINERS --->
<div id="masterLoadingDiv" style="display:none;">&nbsp;</div>
<div id="loaderDiv" style="display:none;">
	<img style="vertical-align:middle;float:left;margin-right:5px;" src="/Images/BSAAjax_Loader.gif" border="0" />
	<span id="loaderText"></span>
</div>

<!--- APPLICATION LAYOUT --->
<div id="MasterContainer">
	<div id="leftColumn">
		<div id="LeftTopContainer">
			<div id="workList">
				<cfif fileExists("#MCObject.MatchCentralPath#\worklist.xml")>
					<cfinclude template="MC_work_list.cfm">
				<cfelse>
					<div id="waterMark" class="workListWatermarkMargin">WORK LIST</div>
				</cfif>
			</div>
		</div>
		<div id="LeftBottomContainer">
			<div id="matchList">
				<div id="waterMark" class="matchListWatermarkMargin">MATCH LIST</div>
			</div>
		</div>
	</div>
	<div id="rightColumn">
		<div id="RightTopContainer">
			<div id="remainingDollarAmount">#dollarFormat(0)#</div><!--- This is the dollar amount at the top right --->
			<div style="float:left;">
				<CF_smallLink
					title = "search"
					url = "javascript:toggleSearchDiv();">
				<br />
				<div id="miniLoader" style="display:none;">
					<img style="vertical-align:middle;float:left;margin-right:5px;" src="/Images/ajax-loader-small-red.gif" border="0" />
					Working...
				</div>
			</div>
			<div id="actionBar" style="text-align:right;">
				<div id="ValidateLink" style="float:right;display:inline;width:200px;">
					<CF_smallLink
						title = "validate all"
						url = "javascript:validateAllMatches();">
				</div>
				<div id="ProcessingLink" style="float:right;display:none;width:200px;">
					<CF_smallLink
						title = "process"
						url = "javascript:processMatching();">
				</div>
			</div>
		</div>
		<div id="RightBottomContainer">
			<div id="SearchContainer" style="display:none;"></div>
			<div id="itemList">
				<div id="waterMark" class="itemListWatermarkMargin">
					ITEM LIST<br /><font size="3">(SELECT AN ITEM FROM THE WORK LIST)</font>
				</div>
			</div>
		</div>
	</div>
</div>
<div id="previewPaneWrapper" class="resizeMe" style="display:none;">
	<div id="handle" style="cursor:move;">
		<span style="float:left;">Preview Window </span>
		<span class="winclose"
			onmouseover="this.className='winclosehover';"
			onmouseout="this.className='winclose';"
			onmousedown="this.className='wincloseclick';"
			onclick="toggleDiv('previewPaneWrapper');"
			style="width:17px;height:17px;cursor:pointer;float:right;margin:0 0 1px 0;">&nbsp;</span>
		&nbsp;
	</div>
	<div id="previewPane"></div>
</div>
<script type="text/javascript">
	effectFunction = function()
	{
	   new Effect.Opacity($('previewPaneWrapper'), {from:1, to:1, duration:.001});
	}
	new Draggable('previewPaneWrapper', {handle:'handle',starteffect:effectFunction,endeffect:effectFunction});
</script>

</cfoutput>
<cfif URL.showSearch>
	<script>
		toggleSearchDiv();
	</script>
</cfif>
<!--- 66822 :: Adding a link to Match Central directly from a billback START --->
<cfif url.fromBB>
<cfoutput>
	<cfquery name="getBBInfo" datasource="#application.datasource#">
		SELECT B.BB_Code, BA.Paid_Amount
		FROM billback B
		INNER JOIN dbo.BB_Approved BA
		ON BA.Billback_ID = B.Billback_ID
		INNER JOIN Billback_Allied
		ON Billback_Allied.billback_id = B.billback_id
		WHERE B.billback_id = '#url.BBID#'
		AND Billback_Allied.BB_Locked_By_Match_Central = 0 <!--- 68494: No need to add again if billback is already added --->
	</cfquery>

    <!--- Add billback to work list --->
    <cfif getBBInfo.RecordCount>

        <cfset MCObject = createObject("Component","components.Match_Central.MatchCentral").init()>
        <cfset MCObject.addToWorkList('#url.BBID#','BB','DD')>

        <script type="text/javascript">
            var param = {};
            var options = {parameters		:	param
                            ,onFailure		:	itemListError
                            ,evalscripts	:	true
                            ,onLoading		:	showMiniLoader
                            ,onComplete		:	hideMiniLoader};

            // Refresh the work list to show the newly added billback on the top left pane
            new Ajax.Updater($('workList'),'MC_work_list.cfm', options);
        </script>

    </cfif> <!--- getBBInfo.RecordCount --->

    <!--- Get the array index for this billback --->
    <cfset fromBBIndex = MCObject.getWorkListXMLArrayIndex(url.BBID) />
    <cfif fromBBIndex GT 0>
        <script type="text/javascript">
            // Refresh the item list which will show the list of deduction on the right pane
            workThisItemBB('#url.BBID#','#getBBInfo.Paid_Amount#', #fromBBIndex#);
        </script>
    </cfif>


</cfoutput>
</cfif> <!--- url.fromBB --->
<!--- 66822 :: Adding a link to Match Central directly from a billback END --->
</BODY>
</HTML>
