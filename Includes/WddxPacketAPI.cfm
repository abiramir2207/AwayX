


<cfparam name="PacketCommand" default="nocommand">
<cfparam name="WddxPacketLocation" default="#Application.Doc_Path#\temp_files\WddxPackets">
<CFPARAM name="Supplied_Wddx_Packet_To_File_Map_ID" default="">
<CFPARAM name="Supplied_PacketContents" default="">

<CFSET PacketReturnData = StructNew()>
<CFSET PacketReturnData.Packet_Location 			= "">
<CFSET PacketReturnData.Wddx_Packet_To_File_Map_ID 	= "">
<CFSET PacketReturnData.User_ID  					= "">


<CFSWITCH expression="#lcase(PacketCommand)#">
	<CFCASE value="init"><!--- initilize packet --->

		<CFIF isdefined("request.AccessStructure.User_ID")>
			<CFSET User_ID = request.AccessStructure.User_ID>
		<CFELSE>
			untill next code revision, this code must see the access structure to get the user id <BR><BR>
			initwddxpacketfile.cfm
			<CFABORT>
		</CFIF>
		
		<CFSET Packet_Filename = createuuid()&createuuid()&createuuid()>
		<CFSET Packet_Filename = Replace(Packet_Filename,"-","","ALL")>
		<CFSET Packet_Filename = Packet_Filename&".txt">
		<CFSET FinalPacketLocationPath = "#WddxPacketLocation#\#Packet_Filename#">
				
		
		<cfquery name="initDBRecord" datasource="#Application.Datasource#">
			INSERT INTO Wddx_Packet_To_File_Map
			(User_ID,Packet_Filename)
			VALUES
			('#request.AccessStructure.User_ID#', '#Packet_Filename#')
		</cfquery>
		
		<CFSET Packet = StructNew()>
		<CFSET Packet.Created_On = createodbcdatetime(Now())>
		<CFSET Packet.Created_By_User_ID = request.AccessStructure.User_ID>
		<CFSET Packet.Contents = StructNew()>

		<cfwddx action="CFML2WDDX" input="#Packet#" output="SerializedPacket" usetimezoneinfo="Yes">						
		<cffile action="WRITE" file="#FinalPacketLocationPath#" output="#SerializedPacket#" addnewline="Yes">

		<CFSET PacketReturnData.Packet_Location 			= FinalPacketLocationPath>
		<CFSET PacketReturnData.Wddx_Packet_To_File_Map_ID 	= initDBRecord.Wddx_Packet_To_File_Map_ID>
		<CFSET PacketReturnData.User_ID  					= request.AccessStructure.User_ID>
	</CFCASE>

	<cfcase value="delete"><!--- delete packet from DB --->
		<cfquery name="setDeletedBitHigh" datasource="#Application.Datasource#">
			UPDATE Wddx_Packet_To_File_Map
			SET Deleted = 1
			WHERE Wddx_Packet_To_File_Map_ID = '#Supplied_Wddx_Packet_To_File_Map_ID#'
		</cfquery>
	</cfcase>

	<cfcase value="read"><!--- read packet--->
		<cfquery name="getPacketFilename" datasource="#Application.Datasource#">
			SELECT *
			FROM Wddx_Packet_To_File_Map
			WHERE Wddx_Packet_To_File_Map_ID = '#Supplied_Wddx_Packet_To_File_Map_ID#' and Deleted = 0
		</cfquery>	
		<CFIF getPacketFilename.recordcount EQ 1>
			<cffile action="READ" file="#WddxPacketLocation#\#getPacketFilename.Packet_Filename#" variable="PacketWddxText">
			<cfwddx action="WDDX2CFML" input="#PacketWddxText#" output="Packet">
		</CFIF>

		<CFSET PacketReturnData.Packet_Location 			= "#WddxPacketLocation#\#getPacketFilename.Packet_Filename#">
		<CFSET PacketReturnData.Wddx_Packet_To_File_Map_ID 	= Supplied_Wddx_Packet_To_File_Map_ID>
		<CFSET PacketReturnData.User_ID  					= request.AccessStructure.User_ID>
	</cfcase>
	
	<cfcase value="write">
		
		<CFSET PacketCommand = "read">
		<CFINCLUDE template="/includes/WddxPacketAPI.cfm">

		<CFSET Packet.Contents = Supplied_PacketContents>
		<cfwddx action="CFML2WDDX" input="#Packet#" output="PacketContentsToBeWritten" usetimezoneinfo="Yes">
		
		<cffile action="WRITE" file="#PacketReturnData.Packet_Location#" output="" addnewline="Yes">
		<cffile action="WRITE" file="#PacketReturnData.Packet_Location#" output="#PacketContentsToBeWritten#" addnewline="Yes">
	
	</cfcase>

	<cfcase value="nocommand"><!--- do nothing ---></cfcase>

	<cfdefaultcase><!--- do nothing ---></cfdefaultcase>

</CFSWITCH>





