<!---/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// From Trade Planner //////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfif isDefined("form.action") and form.action eq "volumeApp">

<cfscript>

	packetId = "";
	volumePacketBuilder = CreateObject("component", "components.volume.BuildVolumePacket");
	volumePacketBuilder.init(packetId,1);
	volumePacketBuilder.setAppAreaId(2, form.trade_plan_id);
	volumePacketBuilder.setForecastId(form.forecast_id);
	volumePacketBuilder.setAppAreaTitle(form.tradePlanTitle);
	volumePacketBuilder.setAppAreaReturnToFile("/ReportWriter/trade_plan/volume_popup.cfm");
	volumePacketBuilder.addDistributors(form.Distributor_List);
	volumePacketBuilder.setAppAreaDates(form.start_date, form.end_date);
	
</cfscript>

<cfloop index="indx" from="1" to="#ListLen(form.Product_List)#">
	
	<!---decrement the indx value to match qty suffix--->
	<cfset qtyIndx = indx - 1 />
	<cfset volumePacketBuilder.addProduct(ListGetAt(form.Product_List, indx),#Evaluate("form.qty#qtyIndx#")#) />
	
</cfloop>

<!---save the volume packet and relocate to volume applicator--->
<CFSET packetId = volumePacketBuilder.saveVolumePacket() />
<cflocation url="/Common_Files/Volume/Volume_Applicator.cfm?packetId=#packetId#" addtoken="No">

<!---/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// From Volume Applicator //////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfelse>

	<!---invoke packet builder and get the packet--->
	<CFSET volumePacketBuilder = CreateObject("component", "components.volume.BuildVolumePacket")>
	<CFSET Packet_ID = volumePacketBuilder.init(url.packetId, 0)>
	<cfset volumePacket = volumePacketBuilder.getVolumePacket()>

	<script>
		opener.document.marginForm.forecast_id.value = <cfoutput>#volumePacket.forecastid#</cfoutput>;
	</script>
	
	<cfloop index="indx" from="1" to="#ArrayLen(volumePacket.products)#">
		
		<!---decrement the indx value to match qty suffix--->
		<cfset qtyIndx = indx - 1 />
		
		<!---set the qty values in the calling page using js--->
		<script>
			var indx = "<cfoutput>#qtyIndx#</cfoutput>";
			var tmpQty = eval("opener.document.marginForm.qty" + indx);
			tmpQty.value = <cfoutput>#volumePacket.products[indx].productVolume#</cfoutput>;
		</script>

	</cfloop>
	
	<!---close window--->
	<script>
	    opener.document.marginForm.submit();
		window.close();
	</script>
</cfif>