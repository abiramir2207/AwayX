function doDragEnter(event) {
		event.handled = true;
	}
function doDragExit(event) {
		event.target.hideDropFeedback();
	}
function doDragOver(event) {
		event.target.showDropFeedback();
	}
function doDragDropDG(event) {
		
		doDragExit(event);
		var dragItems = event.dragSource.dataForFormat('items');
		var formatedItems = [];
		var dest = event.target;
		var dropLoc = dest.getDropLocation();
		for(var i=0; i < dragItems.length; i++)
		{ 
			formatedItems.push({data:dragItems[i].Contract_Main_ID, label:dragItems[i].Contract_Number});
		}
		//update the celect box
		_root.addToFavorites(dest,dropLoc,formatedItems);
		//update the database
		
	}
	
function addToFavorites(destination, location, items)
{ 
	var cleanObj = {};
	var cleanItems = [];
	for(var i=items.length-1; i >= 0; i--)
	{   
		cleanObj[items[i].data] = items[i];
	}
		
	for(var i in cleanObj)
	{
		cleanItems.push(cleanObj[i]);
	}
	
	for(var i=cleanItems.length-1; i >= 0; i--)
	{
		for(var n = 0; n < destination.dataProvider.length; n++)
		{
			if(destination.dataProvider[n].data ==  cleanItems[i].data)
			{
				cleanItems.removeItemAt(i);
			}
		}
	}
	if(cleanItems.length > 0)
	{
		 destination.dataProvider.addItemsAt(location,cleanItems);
		 //store the newly inserted values in the db
		 _root.maintFavorites(cleanItems,1);
		// _root.setFavorites(destination.dataProvider);
	}
}
//****************************************************************
function getFavorites():Array
{
	var favObject = SharedObject.getLocal('favorites');
	if(favObject.data.feeds.length == 0 || favObject.data.feeds == undefined)
	{
		//favObject.data.feeds = [{label:"AsFusion", data:319}]
		favObject.flush();
	}
	return favObject.data.feeds
}

function setFavorites(feeds)
{   	
	var favObject = SharedObject.getLocal('favorites');
	favObject.data.feeds = feeds;
	favObject.flush();
}

function showFavorites()
{
	if(favorites.dataProvider.legth != 0)
	{
		//clearInterval(_global.favoritesID);
		favorites.dataProvider = _root.getFavorites();
	}
}
function removeFavorites(target)
{
	target.selectedIndices.sort(Array.DESCENDING|Array.NUMERIC);
	var selIn = target.selectedIndices.slice(0);
	//remove from db
	_root.maintFavorites(target.selectedItems,0);
	for(var i=0; i < selIn.length; i++)
	{
		target.dataProvider.removeItemAt(selIn[i]);
	}
	_root.setFavorites(target.dataProvider);
}

function saveFavorites(target)
{
	target.selectedIndices.sort(Array.DESCENDING|Array.NUMERIC);
}

public function maintFavorites(items,action):Void
{  
	//create connection
	var connection:mx.remoting.Connection = mx.remoting.NetServices.createGatewayConnection(_global.gatewayUrl);
	//declare service
	var prgScrService:mx.remoting.NetServiceProxy;
	var responseHandler = {};
	//put the controls in scope to avoid calling _root
	var Programs = Programs;
	var ProgramScoreCard = ProgramScoreCard;
	
	responseHandler.onResult = function( results: Object ):Void {
		//when results are back, populate the cfselect
		//do nothing?
		//alert("hello : " + items);
	}
	responseHandler.onStatus  = function( stat: Object ):Void {
		//if there is any error, show an alert
		alert("Error while updating favorites:" + stat.description);	
	}
	//get service
	prgScrService = connection.getService(_global.servicePath, responseHandler);
	//make call
	if(action == 1)// 1 means insert
	{
		prgScrService.insertFavorites(items,_global.accessStructure.User_ID);
	}
	else  //remove
	{ 
		prgScrService.removeFavorites(items,_global.accessStructure.User_ID);
	}
}

