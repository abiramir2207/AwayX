<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<cfscript>
	cfcAttrs = 'mvc.Views.ajax.zipTable';
	attrs = createObject('component',cfcAttrs).getattrs();
	sql = attrs.sql;
	ui	= attrs.ui;
</cfscript>

<cfinclude template="\mvc\Views\dataTable.cfm" >