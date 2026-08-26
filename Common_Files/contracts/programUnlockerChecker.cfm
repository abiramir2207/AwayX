<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>PLEASE DO NOT CLOSE</title>
	<script>
		function notifyParentOfExistinance() {
			if(opener != null){
				opener.window.isUnlockWindowAlive = 1;				
				if(opener.window.programUnlockerWin == null) {
					opener.window.programUnlockerWin = this
				}
				setTimeout("notifyParentOfExistinance()", 500)
			}
		}
	</script>
</head>

<body onbeforeunload="verifyClose()" onload="initPage()">
<span>
	leave this window open if you know whats good for you
</span>


<form action="unlock_program_action.cfm" method="post" name="ProgramForm" id="ProgramForm">
	<input type="hidden" name="Program_ID" id="Program_ID" value="<cfoutput>#URL.CID#</cfoutput>">
	<input type="hidden" name="normalShutdownFlag" id="normalShutdownFlag" value="0">
</form>
	<script>
		normalShutdown = 0;
		
		function forceUnlock(){
			goUnlockProgram();
		}
		
		function initPage(){
			notifyParentOfExistinance();
			if(this.opener.closed == true) {
				//unlock the program here
				goUnlockProgram();
			}
			else{
				currentParentLocation = window.opener.location.href
				CurrentCheckCount = 0;
				MaxLocationChecks = 10;
				setTimeout("checkParentLocation()", 500) 
			}
		}
		
		
		function checkParentLocation() {
			
			//if the currentlocation is what it was 500 milliseconds ago then check again in half a second
			tempCurrentLocation = window.opener.location.href;
			if(currentParentLocation == tempCurrentLocation){
			//if(currentParentLocation == tempCurrentLocation && CurrentCheckCount < MaxLocationChecks){
				//CurrentCheckCount++;
				setTimeout("checkParentLocation()", 500);
			}
			else{
				//the location has changed or the loop discovered it was in the same place
				//alert(currentParentLocation + " - " + window.opener.location.href + " - " + CurrentCheckCount)
				if(currentParentLocation != tempCurrentLocation) {
					tempLocationArray = tempCurrentLocation.split("/")
				
					if(tempLocationArray[3].toLowerCase() != 'common_files' || tempLocationArray[4].toLowerCase() != 'contracts') {
						goUnlockProgram();
					}
					else {
						//closeWindow()
					}
				}
				else{
					//closeWindow()
				}
			}
		}
	
		function closeWindow(){
				window.close();
		}
	
		function goUnlockProgram(){
				document.body.all.normalShutdownFlag.value = 1;
				document.ProgramForm.submit();
		}

		function verifyClose() {
			if(opener != null) {
				if(opener.closed == false){
					opener.window.isUnlockWindowAlive 	= 0;
					opener.window.programUnlockerWin	= null;
				}
			}
		}
	</script>
</body>
</html>






