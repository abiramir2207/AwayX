// ActionScript file
	 private function actionOpen(paneNum:Number):void {
       	dynamicPanel.selectedIndex = paneNum;
       	var heightDynamicPanel:Number = 200;
      	var obj:Object = {b:dynamicPanel.height, c:heightDynamicPanel - dynamicPanel.height, d:400, t:0, panel:dynamicPanel};
		resizePanel(obj);
		enableButtons(paneNum);
       }
       
       public function actionClose():void {
       	if(dynamicPanel.height != 0) {
	      var obj:Object = {b:dynamicPanel.height, c:0 - dynamicPanel.height,  d:400, t:0,  panel:dynamicPanel};
	      resizePanel(obj);
        }
       }
   
       public function resizePanel(obj:Object):void {
		if(id != 0)  clearInterval(id);
		var interval:Number = 10;
		var resize:Function = function(obj:Object):void
		{
			var t:Number = obj.t;
			var c:Number = obj.c;
			var b:Number = obj.b;
			var d:Number = obj.d;
			obj.panel.height = -c *(t/=d)*(t-2) + b;
			if(obj.t >= obj.d)
			{
				clearInterval(id);
				id = undefined;
			}
			obj.t += interval;
		}
		var id:uint = setInterval(resize, interval, obj);
	}

	private function enableButtons(pane:Number):void {
		saveForm.enabled = true;
		sendForm.enabled = true;
		deleteFormBtn.enabled = false;
		
		switch (pane) {
			case 0:
			       saveForm.enabled = true;
			       sendForm.enabled = true;
			       saveForm.label = "Save Form";
			       break;
			case 1: 
			       saveForm.enabled = true;
			       sendForm.enabled = true;
			       deleteFormBtn.enabled = true;
			       saveForm.label = "Update Form";
			       break; 
		    case 2:
		           saveForm.enabled = false;
		           sendForm.enabled = false;
		           break;
		    case 3:
		           saveForm.enabled = false;
		           sendForm.enabled = false;
		           break;
		}
	}