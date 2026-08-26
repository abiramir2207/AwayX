package com.components
{

	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	
	import mx.controls.ProgressBar;
	import mx.events.*;
	import mx.preloaders.*;
    /**
     * This is the preloader that displays when The app is loadin.  It basically overrides the default Blue background with a gray one.
     * @author msaunders
     */
    public class baProgressBar extends DownloadProgressBar
    {
        // Define a TextField control for text messages 
        // describing the download progress of the application.
        private var progressText:TextField = new TextField();
        private var pb:ProgressBar = new ProgressBar();
        private var n:Number = 1;
        
        // Define a TextField control for the final text message.
        // after the application initializes.
        private var msgText:TextField = new TextField();
    
        public function baProgressBar()
        {   
            super();
          //  backgroundColor = 0xFF0000;
           // width = 1024;
           // height = 800;
           // backgroundSize = "100%"
           
           // this.visible = true;
			// Set the download label.
			
           // downloadingLabel="Downloading...";
            // Set the initialization label.
           // initializingLabel="Init Search...";
            // Set the minimum display time to 2 seconds.
            MINIMUM_DISPLAY_TIME=1000;
            
            
            
            // Add an event listener so that we can start drawing once we know we're on the stage
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            // Add the loader screen to the stage and center it
						
        }
        private function onAddedToStage(event:Event):void {
			
			// Add the loader screen to the stage and center it
			// Configure the TextField for progress messages.
           /*  progressText.x = (stage.stageWidth)/3;    
            progressText.y = (stage.stageWidth)/4;
            progressText.width = 400;
            progressText.height = 400;
        
            addChild(progressText); */
        
            // Configure the TextField for the final message.
            msgText.x = (stage.stageWidth)/3;
            msgText.y = 300;
            msgText.width = 400;
            msgText.height = 75;
            
            addChild(msgText);
			/* pb.x = (stage.stageWidth)/3;
			pb.y = 200;
			pb.width = 500;
			pb.visible = true;
			pb.includeInLayout = true;
			addChild(pb); */
		}
         // Override to return true so progress bar appears
        // during initialization.       
        override protected function showDisplayForInit(elapsedTime:int, 
            count:int):Boolean {
                return true;
        }

        // Override to return true so progress bar appears during download.     
        override protected function showDisplayForDownloading(
            elapsedTime:int, event:ProgressEvent):Boolean {
                return true;
        }
    
        // Define the event listeners for the preloader events.
        override public function set preloader(preloader:Sprite):void {
            // Listen for the relevant events
       		super.preloader = preloader;
       		super.backgroundColor = 0xe3e3e3;
       		backgroundAlpha = 1;
            preloader.addEventListener(ProgressEvent.PROGRESS, myHandleProgress);   
            preloader.addEventListener(Event.COMPLETE, myHandleComplete);
            preloader.addEventListener(FlexEvent.INIT_PROGRESS, myHandleInitProgress);
            preloader.addEventListener(FlexEvent.INIT_COMPLETE, myHandleInitEnd);
        } 
    
        // Event listeners for the ProgressEvent.PROGRESS event.
        private function myHandleProgress(event:ProgressEvent):void {
        	var x:Number =  (event.bytesLoaded / event.bytesTotal) * 100;
        	var s:String = "Downloading " + x + "%"
            //msgText.text = ;
            initializingLabel= s;
            //this.setProgress(event.bytesLoaded,event.bytesTotal);
        }
    
        // Event listeners for the Event.COMPLETE event.
        private function myHandleComplete(event:Event):void {
        	var s:String = "Forge Init Complete";
          //  msgText.text = s;
            initializingLabel= s;
        }
    
        // Event listeners for the FlexEvent.INIT_PROGRESS event.
        private function myHandleInitProgress(event:Event):void {
        	var s:String = "Init Forge";
           // msgText.text = s;
            initializingLabel= s;
            n = n++;
            //this.initProgressHandler(event);
           // this.setProgress(n,6);
        }
    
        // Event listeners for the FlexEvent.INIT_COMPLETE event.
        private function myHandleInitEnd(event:Event):void {
        	var s:String = "App Init End"; 
           // msgText.text = s;
            initializingLabel= s;
            //var timer:Timer = new Timer(6000,1);
           // timer.addEventListener(TimerEvent.TIMER, dispatchComplete);
           // timer.start();
        }
        
        // Event listener for the Timer to pause long enough to 
        // read the text in the download progress bar.
        private function dispatchComplete(event:TimerEvent):void {
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
}