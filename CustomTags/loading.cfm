<!--------------------------------------------------------------->
<!--------------------------------------------------------------->
<!--- CF_LOADING Custom tag. (c) 1998 By Kurt Hakenson ---------->
<!--- This tag may be freely used, modified, and distributed. --->
<!--- The author humbly requests you include this comment ------->
<!--- intact at the top of this page. --------------------------->
<!--------------------------------------------------------------->
<!--- Bugs or enhancement requests should be avoided ------------>
<!--- at all costs (HA!) but if you have one, ------------------->
<!--- forward it to hakenson@clark.net -------------------------->
<!--------------------------------------------------------------->
<!-------------------- INSTRUCTIONS ----------------------------->
<!--- Place this tag in the HEAD portion of your document, ------>
<!--- Thats it! ------------------------------------------------->
<!--------------------------------------------------------------->
<!--------------------------------------------------------------->

<script language="JavaScript">
	  function myWindowClose(){
	  	win.close();
	  }	
	  var w = 200;
	  var h = 100;
	  var winl = (screen.width - w) / 2;
	  var wint = (screen.height - h) / 2;
	  var win = window.open("about:blank","Progress","top=" + wint + ",left=" + winl + ",toolbar=no,width=200,height=100,directories=no,status=no,scrollbars=no,resize=no,menubar=no");
	  win.document.open();
	  win.document.writeln('<hmtl><head><title>Loading..........</title></head>');  
	  win.document.writeln('<body bgcolor="white"><br><center>');
	  win.document.writeln('<font face="Arial,Helvetica" size=2 color="red"><b>Loading...</b></font><br><br>');
	  win.document.writeln('<font face="Arial,Helvetica" size=2><b>Please Wait.</b></font></center>');
      win.document.writeln('</body></html>');
	  win.document.close();
	  window.onload=myWindowClose
</script>