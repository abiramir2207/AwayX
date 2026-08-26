<!--
  * ====================================================================================================
  *  @Author: Chris Nguyen
  *    @Date: 2018-04-19 10:49:12
  *
  * @Remarks: Pull all recently changes in SQL table folder
  *
  *
  *
  *
  * ====================================================================================================
-->
<cfparam name="URL.days" default="90">

<cfset sql_folder = replacenocase(expandPath("/"), "awayx", "awayx_sql") & "table">
<cfdirectory action="list" directory="#sql_folder#" recurse="false" filter="*.sql" name="sql_files">

<cfloop query="sql_files">
	<cfif dateDiff('d', sql_files.dateLastModified, now()) lte URL.days>
		<!--- <cfoutput>#sql_files.name# #dateFormat(sql_files.dateLastModified,'yyyy-m-d')# #dateDiff('d', sql_files.dateLastModified, now())#<br></cfoutput> --->
		<cffile action="read" file="#(sql_folder & "/" & sql_files.name)#" variable="sql_code">
		<cfoutput>
			<pre>-------------------------------------------------------------------------------------------------------------------------------</pre>
			<pre>--- #ucase(sql_files.name)# was last modified on #sql_files.dateLastModified# ---</pre>
			<pre>-------------------------------------------------------------------------------------------------------------------------------</pre>
			<pre>#sql_code#</pre>
		</cfoutput>
	</cfif>
</cfloop>
