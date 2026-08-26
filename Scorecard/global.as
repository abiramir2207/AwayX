public function setMessage (msg:String,type:String){
		var msgColor;
		switch(type){
			case "info": msgColor = "#009900"; break;
			case "error": msgColor = "#990000"; break;
			default: msgColor = "#3E4E1A"; break;
		}
		_root.ProgramScoreCard.loadingDisplay = (msg == "Getting data....")?true:false;
		//statusDisplay.text ='<p align="right"><font color="' + msgColor + '"><b>'+ msg + '</b></font></p>';
	}	
public function setSelected (target){
		if(_global.selectedList  != target)
		{
			_global.selectedList.selectedIndex = undefined;
			_global.selectedList = target;
		}
	}
	
public function goToURL(progId):Void {
			//put the controls in scope to avoid calling _root
			var Programs = Programs;
			var ProgramScoreCard = ProgramScoreCard;
            var url:String = "http://" + thisHost + "/common_files/contracts/contract_edit_menu.cfm";
            var variables:URLVariables = new URLVariables();
            variables.CID = cryp(ProgramScoreCard.favourites.selectedIndex);
            var request:URLRequest = new URLRequest(url);
            request.data = variables;
            try {            
                navigateToURL(request, "_self");
            }
            catch (e:Error) {
                // handle error here
				alert("Error while navigating to URL:" + stat.description);	
            }
        }
public function cryp(progId):String {
		//create connection
	var connection:mx.remoting.Connection = mx.remoting.NetServices.createGatewayConnection(_global.gatewayUrl);
	//declare service
	var prgScrService:mx.remoting.NetServiceProxy;
	var responseHandler = {};
	
	responseHandler.onResult = function( results: String ):String {
		//when results are back
		return results;
	}
	responseHandler.onStatus  = function( stat: Object ):Void {
		//if there is any error, show an alert
		alert("Error while encrypting program ID:" + stat.description);	
	}
	//get service
	prgScrService = connection.getService(_global.servicePath, responseHandler);
	//make call
	prgScrService.cryp(progId,_global.accessStructure.User_ID);
	
	
	
}