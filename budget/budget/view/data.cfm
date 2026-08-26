<cfsilent>
	<cfparam name="inhibitDisplay" default="0" />
	<cfquery name="getCrossProduct" datasource="#application.datasource#">
		select TOP 100
		family_name, type_code_desc, ('CS') AS "UOM", ('1000') AS "VOLUME" 
		from distributor_family
		cross join type_code_desc
		where 
		type_code_desc.deleted = 0
		and distributor_family.deleted = 0
		order by family_name ASC, type_code_desc ASC
	</cfquery>
</cfsilent><cfif NOT inhibitDisplay>
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE DATA [  
<!ELEMENT DATA (RECORD+)>
<!ELEMENT RECORD (FAMILYNAME, TYPECODEDESC)>
<!ELEMENT FAMILYNAME (#PCDATA)>
<!ELEMENT TYPECODEDESC (#PCDATA)>
<!ELEMENT UOM (#PCDATA)>
<!ELEMENT VOLUME (#PCDATA)>

<!ATTLIST RECORD ID CDATA #REQUIRED>
]> 
<DATA>
<cfoutput query="getCrossProduct">
<RECORD ID="#currentRow#">
	<FAMILYNAME>#XMLFORMAT(family_name)#</FAMILYNAME>
	<TYPECODEDESC>#XMLFORMAT(type_code_desc)#</TYPECODEDESC>
	<UOM>#XMLFORMAT(uom)#</UOM>
	<VOLUME>#XMLFORMAT(volume)#</VOLUME>
</RECORD>
</cfoutput>
</DATA></cfif>



