
public function getData():Void
{  
	//create connection
	var connection:mx.remoting.Connection = mx.remoting.NetServices.createGatewayConnection(_global.gatewayUrl);
	//declare service
	var prgScrService:mx.remoting.NetServiceProxy;
	var responseHandler = {};
	//put the controls in scope to avoid calling _root
	var Programs = Programs;
	var ProgramScoreCard = ProgramScoreCard;
	var statusDisplay = statusDisplay;
	var filterInput = filterInput;
	statusDisplay.html = true;
	var msgColor = "#009900"; 
	//reset the Input field t te existing value.  save user from retyping
	//applyfilter() gets run after program search
	mx.managers.CursorManager.setBusyCursor();
	statusDisplay.text = '<font color="black" style="text-align:right;font-style:italic"><b>&nbsp;&nbsp;...Searching</b></font>';
	_root.ProgramScoreCard.loadingDisplay = true;
	
	responseHandler.onResult = function( results: Object ):Void {
		//when results are back, populate the cfgrid
		Programs.dataProvider = results;
		statusDisplay.text = '<font color="black" style="text-align:right;"><b>&nbsp;&nbsp;'+ results.length + '&nbsp;Programs</b></font>';
		_global.unfilteredData = cloneData(Programs.dataProvider);
		//Run applyFilter() incase user still has data in the input field
		var tmp = _root.applyFilter();
		ProgramScoreCard.loadingDisplay = false;
		mx.managers.CursorManager.removeBusyCursor();
		//mx.controls.Alert.show("Error: " + results.length);
	}
	responseHandler.onStatus  = function( stat: Object ):Void {
		//if there is any error, show an alert
		alert("Error while getting data:" + stat.description);	
		mx.managers.CursorManager.removeBusyCursor();
		ProgramScoreCard.loadingDisplay = false;
	}
	
	//get service
	prgScrService = connection.getService(_global.servicePath, responseHandler);
	//make call...first parse the status id and the agree id from the selected data
	var tmpArray:Array = ProgramScoreCard.programStatus.selectedItem.data.split(":");
	prgScrService.getProgramScore(tmpArray[0],tmpArray[1],0,_global.searchArgs);
}
public function getToolTip():Void
{
	var Programs = Programs;
	var ProgramScoreCard = ProgramScoreCard;
}
public function getProgram():Void
{
	var Programs = Programs;
	var ProgramScoreCard = ProgramScoreCard;
	var prog = Programs.selectedItem;
	//var icon = getProgram2();
	
	display.text = '<textformat rightmargin="8" leftmargin="8"><font color="#8A0909" size="12"><b><A HREF="/scorecard/program_display.cfm?CID='+prog.Contract_Main_ID+'&noCrp=1" target="_blank">'+prog.Contract_Number+'  </a></b></font><font size="12" color="#4A72B6"><b>'+prog.Contract_Title+'</b></font>';  //<A HREF="/scorecard/program_display.cfm?CID='+prog.Contract_Main_id+'"&noCrp=1 target="_blank">
	display.text += '<font size="12" color="black"><b><font color="#FF6600">  ::  </font></b><em>'+formatDate(prog.Contract_Start_Date)+'  -  '+formatDate(prog.Contract_End_Date)+'</em></font><br/>';
	//display.text += '</textformat>';
	display.text += '<font size="12" color="black">'+prog.Created_Type+((prog.Operator_Name != "")? '<b><font color="#FF6600">  ::  </font>Operator: </b>':'')+prog.Operator_Name+((prog.OperatorID != "")? ' (':'')+prog.OperatorID+((prog.OperatorID != "")? ') ':'')+((prog.Name != "")? '<b><font color="#FF6600">  ::  </font>Distributor: </b>':'')+prog.Name+' ('+prog.ship_to+')</font>';
	display.text += '<br/><font size="12" color="black">'+((prog.SalesPerson_Responsible != "")?'<b>RSP: </b>':'')+prog.SalesPerson_Responsible+'</font>';
	
}
////***********************************************************

function formatDate(rawValue:Date):String {
		var returnValue:String;
		var monthName_array:Array = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
		returnValue = monthName_array[rawValue.getMonth()]+" "+rawValue.getDate()+", "+rawValue.getFullYear();
		return returnValue;
}

///##############################################################################################

public function goToURL(progId):Void {   
			//create connection
			var connection:mx.remoting.Connection = mx.remoting.NetServices.createGatewayConnection(_global.gatewayUrl);
			//declare service
			var prgScrService:mx.remoting.NetServiceProxy;
			var responseHandler = {};
	
			responseHandler.onResult = function( results: String ):Void {
				//when results are back use the result (the encrypted contract_id) to build the URL
				mx.managers.CursorManager.removeBusyCursor();
				var url:String = "http://" + _global.thisHost + "/common_files/contracts/contract_edit_menu.cfm?CID="+results;
				// call the URL
				try {     
              	  	_root.getURL(url,"_self");
         	   	}
         	  	catch (e:Error) {
              		 // handle error here
					alert("Error while navigating to URL:" + e);	
           		 }
			}
			responseHandler.onStatus  = function( stat: Object ):Void {
				//if there is any error, show an alert
				mx.managers.CursorManager.removeBusyCursor();
				alert("Error while encrypting program ID:" + stat.description);	
			}
			//get service
			prgScrService = connection.getService(_global.servicePath, responseHandler);
			//make call
			mx.managers.CursorManager.setBusyCursor();
			prgScrService.cryp(progId,_global.accessStructure.User_ID);          
}



