<!--- This file is to show the progress of the "Progress bar" --->
<cfparam name="PercentDone" default="0">

<script language="javascript">
	var Block = "Block" + <cfoutput>#PercentDone#</cfoutput>;
	var PercentDone = <cfoutput>#PercentDone#</cfoutput>;

	/* If there are fewer than 9 entries, then we need to make sure that all the images are highlighted, else
	   there wil be a gap in the sequence of selected images
	 */
	if(PercentDone <= 9){
		if('document.'+ Block){		
			for (var i=1;i<=PercentDone;i++){ 
				Block = "Block" + i;
				document.getElementsByName(Block)[0].src =  '/images/red_block.gif';
			}
		}
	}

	if('document.'+ Block){	
		/*Only show till 90%. 100% is at the end.*/
		if(PercentDone <= 9){
		document.getElementsByName(Block)[0].src =  '/images/red_block.gif';
		}
	}

	//Show the progress in percent
	if(document.getElementById('ShowPercentProgress')){
	PercentDone = PercentDone + '0';

		//Only show till 90%. 100% is at the end of the page.
		if(PercentDone <= 90){				 
		document.getElementById('ShowPercentProgress').innerHTML = PercentDone + '%';
		}
	}
</script>		
<cfflush>