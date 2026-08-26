

<!--- <CFSET PacketCommand = "init">
<cfinclude template="/includes/wddxpacketapi.cfm">
<CFDUMP var="#PacketReturnData#">
 --->
<!--- <CFSET Supplied.WDDX_PACKET_TO_FILE_MAP_ID = "07CA853F-035A-4008-82F6-6F80DF3CF08A ">
<CFSET PacketCommand = "Read">
<cfinclude template="/includes/wddxpacketapi.cfm">
<CFDUMP var="#Packet#"> --->


<CFSET tempData = StructNew()>
<CFSET tempData.blah = 1>
<CFSET tempData.test = StructNew()>

<CFSET Supplied_PacketContents = tempData>
<CFSET Supplied_WDDX_PACKET_TO_FILE_MAP_ID = "07CA853F-035A-4008-82F6-6F80DF3CF08A">
<CFSET PacketCommand = "write">
<cfinclude template="/includes/wddxpacketapi.cfm">


<CFSET PacketCommand = "Read">
<cfinclude template="/includes/wddxpacketapi.cfm">
<CFDUMP var="#Packet#">


