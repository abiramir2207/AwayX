 <cfsilent>
<!---  
       Name:          datacreator.cfm           
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  
       Description:   
--->

	<cfparam name="url.start" default="1">
	<cfparam name="url.end" default="200">
</cfsilent>
<hr>
<cfoutput>Vendor ##|Customer Reference|Total $ Amount|Volume Qty|Payee Type|Distributor ID|Operator ID|Billback Title|Closing Method|Billback Date|Receipt Date|BB Start Date|BB End Date|Postmark Date
<br></cfoutput>
<cfloop from="#url.start#" to="#url.end#" step="1" index="numIndex">
<cfoutput>40032|AUTO LOAD SCENARIO #numIndex#|413.12|400|D|021459||AUTO SCENARIO #numIndex#|D|20070107||20061201|20061230|<br>
</cfoutput>	
</cfloop>


<hr>
<h3>Begin Detail Records</h3>
<hr>


<cfoutput>Vendor ##|Customer Reference|Total $ Amount|Item Number|FORGE Program Number|Item Volume Qty|Item Dollar Amount|Discount Type|Component Name|Distributor ID<br>
</cfoutput>
<cfloop from="#url.start#" to="#url.end#" step="1" index="numIndex">
<cfoutput>40032|AUTO LOAD SCENARIO #numIndex#|413.12|71117.61800|1000041|400|413.12|F|Rebate|<br>
</cfoutput>	
</cfloop>

<hr>