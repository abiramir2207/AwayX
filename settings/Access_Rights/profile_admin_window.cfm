<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Profile Maintenance</title>
</head>

<body>



<iframe name="contentWindow" id="contentWindow" width="100%" height="100%" style="visibility: hidden;"></iframe>



<script>
	var tempA_ID = window.dialogArguments[0];
	var tempA_Action = window.dialogArguments[1];
	var finalDestination = "";

	switch(tempA_Action){
		case 1: //create new profile
			finalDestination = "user_profile_admin.cfm?mode=create";
		break;
		
		case 2: //edit profile
			finalDestination = "user_profile_admin.cfm?mode=edit&id=" + tempA_ID;
		break;

		case 3: //copy  profile
			finalDestination = "user_profile_admin.cfm?mode=copy&id=" + tempA_ID;
		break;
	}
	
	document.contentWindow.location.href = finalDestination;
	document.all.contentWindow.style.visibility = "visible";

	function setReturnValue(iVal)
	{
		top.returnValue = iVal;
	}

	//window.onunload=setReturnValue
</script>

</body>
</html>
