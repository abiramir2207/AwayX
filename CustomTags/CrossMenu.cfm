<!-- Menu Name -->
<cfparam name="Attributes.menu" DEFAULT="Menu1">
<cfparam name="Attributes.caption" DEFAULT="Menu Name">

<!-- Menu Item Default -->
<cfparam name="Attributes.listmenuitem" DEFAULT="BTI Consulting,http://bti.intnet.mu,Parvez Bhatoo,http://pages.intnet.mu/abdallah">

<!-- Javascript File Location -->
<cfparam NAME="Attributes.scriptdir" DEFAULT=".">

<!-- Font variables declaration -->
<CFPARAM NAME="Attributes.fntCol" DEFAULT="navy">
<CFPARAM NAME="Attributes.fntBold" DEFAULT="false">
<CFPARAM NAME="Attributes.fntItal" DEFAULT="false">
<CFPARAM NAME="Attributes.fntSiz" DEFAULT=10>
<CFPARAM NAME="Attributes.fntFam" DEFAULT="sans-serif">

<!--- Bold & Italic settings for link style --->
<CFIF Attributes.fntBold EQ "true">
	<CFSET variables.fntBold="bold">
<CFELSE>
	<CFSET variables.fntBold="">
</CFIF>
<CFIF Attributes.fntItal EQ "true">
	<CFSET variables.fntItal="italic">
<CFELSE>
	<CFSET variables.fntItal="">
</CFIF>

<!-- Background color, Mouseover bg Color and  Mouseover Font Color-->
<CFPARAM NAME="Attributes.backCol" DEFAULT="3399FF">
<CFPARAM NAME="Attributes.overCol" DEFAULT="FFFFFF">
<CFPARAM NAME="Attributes.overFnt" DEFAULT="0000ff">

<!-- Menu Width -->
<CFPARAM NAME="Attributes.menuWidth" DEFAULT=120>

<!-- Border Width,color,style -->
<cfparam NAME="Attributes.borWid" DEFAULT=2>
<CFPARAM NAME="Attributes.borCol" DEFAULT = "black">
<CFPARAM NAME="Attributes.borSty" DEFAULT = "solid">

<!-- Padding for box -->
<CFPARAM NAME="Attributes.itemPad" DEFAULT = 3>

<!-- item seperator color and width -->
<CFPARAM NAME="Attributes.separator" DEFAULT = 1>
<CFPARAM NAME="Attributes.separatorCol" DEFAULT = "red">

<!-- child image and size -->
<CFPARAM NAME="Attributes.imgSrc" DEFAULT = "tri.gif">
<CFPARAM NAME="Attributes.imgSiz" DEFAULT = 10>

<!-- Number of pixel the child menu offset the parent one -->
<CFPARAM NAME="Attributes.childOffset" DEFAULT = null>
<CFPARAM NAME="Attributes.childOverlap" DEFAULT = null>
<CFPARAM NAME="Attributes.perCentOver" DEFAULT = null>

<!-- Second to recalculate menu visibility -->
<CFPARAM NAME="Attributes.secondsVisible" DEFAULT = .5>

<!-- Determining Frames -->
<CFPARAM NAME="Attributes.isFrames" DEFAULT = "false">

<!-- Menu position on frames + frames name -->
<CFPARAM NAME="Attributes.navFrLoc" DEFAULT = "left">
<CFPARAM NAME="Attributes.mainFrName" DEFAULT = "main">

<!-- Menu Position -->
<cfparam NAME="Attributes.top" DEFAULT=null>
<cfparam  NAME="Attributes.left" DEFAULT=null>

<!--- Link Color --->
<cfparam  NAME="Attributes.link_fore_color" DEFAULT="white">

<!-- <LINK REL="STYLESHEET" HREF="hiermenus.css" TYPE="text/css"> -->
<SCRIPT LANGUAGE="JavaScript">
<!--
     NS4 = (document.layers);
     IE4 = (document.all);
    ver4 = (NS4 || IE4);
   isMac = (navigator.appVersion.indexOf("Mac") != -1);
  isMenu = (NS4 || (IE4 && !isMac));

  function popUp(){return};
  function popDown(){return};
  function startIt(){return};

  if (!ver4) event = null;
<CFOUTPUT>
  if (isMenu) {
      fntCol = "#Attributes.fntCol#";
      fntBold = #Attributes.fntBold#;
      fntItal = #Attributes.fntItal#;
      backCol = "#Attributes.backCol#";
      overCol = "#Attributes.overCol#";
      overFnt = "#Attributes.overFnt#";
      fntSiz = #Attributes.fntSiz#;
      fntFam = "#Attributes.fntFam#";
      menuWidth = #Attributes.menuWidth#;
      borWid = #Attributes.borWid#;
      borCol = "#Attributes.borCol#";
      borSty = "#Attributes.borSty#";
      itemPad = #Attributes.itemPad#;
      separator = #Attributes.separator#;
      separatorCol = "#Attributes.separatorCol#";
      imgSrc = "#Attributes.imgSrc#";
      imgSiz = #Attributes.imgSiz#;

      childOffset = #Attributes.childOffset#;
      childOverlap = #Attributes.childOverlap#;
      perCentOver = #Attributes.perCentOver#;

      secondsVisible = #Attributes.secondsVisible#;

      isFrames = #Attributes.isFrames#;
      navFrLoc = "#Attributes.navFrLoc#";
      mainFrName = "#Attributes.mainFrName#";
	  
  }
</CFOUTPUT>
//-->
</SCRIPT>

<!--- <cfset numitem = listlen(Attributes.listmenuitem)> --->

<cfset listnumber="1">
<cfset listitem = ListToArray(Attributes.listmenuitem)>
<cfset numitem = arraylen(listitem)>
<cfset numitem = numitem/2>

<SCRIPT LANGUAGE="JavaScript1.2">
<CFOUTPUT>
<!--
  if (isMenu) {
	document.write("<SCRIPT LANGUAGE='JavaScript1.2' SRC='#Attributes.scriptdir#/hierMenus.js'><\/SCRIPT>");
	ar#Attributes.Menu# = new Array(
		#Attributes.menuWidth#,
		#Attributes.left#,#Attributes.top#,
		"#Attributes.Fntcol#","#Attributes.overFnt#",
		"#Attributes.backCol#","#Attributes.overCol#",
		"#Attributes.borCol#","#Attributes.separatorCol#",
	<cfloop from="1" to="#numitem#" index="item">
		#chr(34)##listitem[listnumber]##chr(34)#,#chr(34)##listitem[listnumber+1]##chr(34)#,0
		<cfset listnumber=listnumber+2>
		<cfif (listnumber neq (numitem*2)) and (listnumber lt (numitem*2))>,</cfif>
	</cfloop>
	)
  }
//-->
</CFOUTPUT>  
</SCRIPT>

<CFOUTPUT>
<A HREF="javascript:void(0)" 
		onMousedown="popUp('el#Attributes.Menu#',event)" 
		onMouseOut="popDown('el#Attributes.Menu#')" 
		STYLE="color: #Attributes.fntCol#; 
			font-family: #Attributes.fntFam#; 
			font-size: #Attributes.fntSiz#pt; 
			text-decoration: none; 
			font-weight: #variables.fntBold#; 
			font-style: #variables.fntItal#;">
	#Attributes.caption#
</A>
</CFOUTPUT>




