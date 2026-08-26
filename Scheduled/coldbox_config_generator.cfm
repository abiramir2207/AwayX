<!--- File Name: coldbox_config_generator
      Date Created: 1/4/2008
	  Creator: Ben Densmore
	  Purpose: This updates the ColdBox Xml File to change
	           the datasource name based on the client.
 --->

<!--- Get Clients Datasource name --->
<cfset variables.dsn = application.datasource />
 <!--- Get the location of the config file --->
<cfset variables.path = ExpandPath("../") />
<cfset variables.rootPath = GetDirectoryFromPath(variables.path) />

<!--- Read in the current XML File --->
<cffile action="read" file="#rootpath#config\coldbox.xml.cfm" variable="cbconfig" />
<cfset variables.coldboxConfig = XmlParse(cbconfig) />
<cfset currentVal = "#variables.coldboxConfig["Config"]["Datasources"]["DataSource"].XmlAttributes['name']#" />

<!--- Do a replace on the Datasource element with the Attribute called name
      and change it to the value of the dsn --->
<cfset variables.newCBConfig =
       Replace(cbconfig,currentVal,
	   variables.dsn,"All") />


<!--- Update the config file with the new attribute --->
<cffile action="write" file="#rootpath#config\coldbox.xml.cfm"
		output="#toString(variables.newCBConfig)#"
		addnewline="true" />

<br><br>
<center>
<font color="#0000ff" size="+1">
	File has successfully been run...
</font>
</center>
