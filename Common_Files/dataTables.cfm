<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\dataTables.cfm
      Date:     Jan 30 2012
      Author:   Chris Nguyen
      Purpose:  Load DataTables JS from Microsoft CDN for better performance (or from local server when MS CDN is blocked)

      Remark:   Use the other \Common_Files\dataTables2.cfm for the new modern DataTables (version 1.10.5)
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="datatables.version" default="1.8.2">
<!--- for better performance, load dataTables from MS CDN --->
<!--- if dataTable fails to load from MS CDN (due to DNS blocking) load it from local server --->
</cfsilent>
<cfoutput>
<!--- <script src="//ajax.aspnetcdn.com/ajax/jquery.dataTables/#datatables.version#/jquery.dataTables.min.js"></script> --->
<cf_include files="/script/javascript/jquery.dataTables-#datatables.version#.min.js">
<script>if (!$.isFunction($.fn.dataTable)) { var s = document.createElement("script"); s.src = "/script/javascript/jquery.dataTables-#datatables.version#.min.js"; $("head").append(s); }</script></cfoutput>
