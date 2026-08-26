<cfparam name="form.IsAutoRevision" default="0" />
<cf_cryp type="de" string ="#FORM.Program_ID#" key="#request.key#">
<CFSET Program_ID_To_Replicate = cryp.value>
<CFINCLUDE TEMPLATE="replicate_program.cfm">

<CFIF Program.Basic_Information.Contract_Reference_Number EQ "NULL">
	<CFSET Program.Basic_Information.Contract_Reference_Number = "">
</CFIF>

<CFWDDX ACTION="CFML2WDDX" INPUT="#Program#" OUTPUT="Program_Packet" USETIMEZONEINFO="Yes">

<!--- get install path --->	
<!--- END get install path --->
<!--- create usable directory information --->
<CFSET The_File_Location = Application.Doc_Path & "\temp_files\contracts\XML_Programs\#replace('#Createuuid()##createuuid()#', '-','','ALL')#.xml">
<!--- end create usable directory information --->	

<!--- save the wddx packet to the disk because --->
<CFSET XML_File_Location = The_File_Location>	
<CFFILE ACTION="WRITE" FILE="#XML_File_Location#" OUTPUT="#Program_Packet#" ADDNEWLINE="Yes">

<CFQUERY NAME="savePacket" datasource="#application.datasource#">
	SET NOCOUNT ON
	INSERT INTO Contract_Renewal_Packets
	(Packet_Data, XML_File_Location)
	VALUES
	('#Program_Packet#', '#XML_File_Location#')

	SELECT Contract_Renewal_Packets_ID = @@IDENTITY  
	SET NOCOUNT OFF	
</CFQUERY>
	
<!---if this isn't an auto revision then submit to contract_create_1_form.cfm--->
<cfif not form.IsAutoRevision>
	<FORM ACTION="contract_create_1_form.cfm" METHOD="post" NAME="MyForm">
		<INPUT TYPE="Hidden" NAME="Contract_Renewal_Packets_ID" value="<CFOUTPUT>#savePacket.Contract_Renewal_Packets_ID#</CFOUTPUT>">
	</form>
	
	<script>
		document.all.MyForm.submit();
	</script>
</cfif>