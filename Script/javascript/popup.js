function popupCenterByPercentages(url, title, w1, h1) {
	//
	// w1, h1 are numeric values, they represent percentages without the % sign
	// example: popupCenterByPercentages('/billback/vendorHold.cfm', 'Vendor Hold Search', 90, 90 )
	//

	var  w = Math.floor( screen.availWidth  * w1 / 100 )
		,h = Math.floor( screen.availHeight * h1 / 100 )

		,left = ( w1 >= 100 ? 0 : Math.floor( ( screen.availWidth  - w ) / 2 ) )
		,top  = ( h1 >= 100 ? 0 : Math.floor( ( screen.availHeight - h ) / 2 ) );

	return window.open(url, title, 'toolbar=no, location=no, directories=no, status=no, menubar=no, copyhistory=no, scrollbars=yes, resizable=yes, width='+w+', height='+h+', top='+top+', left='+left);
}