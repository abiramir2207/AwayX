<!--- openLayer.cfm ---> 

<!--- 
   ********************************************************** 

 <CF_openLayer> 
 Version 1.0 
 Wraps its content with an collapse-expand-layer... 
  
 (This layer only works in IE4++ 
  To be browser-safe: when accessed with another 
   browser, only a title is shown without the layer.) 
  
 Usage: 

         <CF_openLayer 
                  [ Border="yes|no" ] 
                  [ BorderSize="size" ] 
                  [ BorderColor="color" ] 
                  [ Image="image" ] 
                  [ ImageOpen="image" ] 
                  [ Title="string" ] 
                  [ TitleClosed="string" ] 
                  [ TitleTooltip="string" ] 
                  [ TitleFont="font" ] 
                  [ TitleColor="color" ] 
                  [ TitleColorOpen="color" ] 
                  [ TitleSize="size in pt" ] 
                  [ IsColsed="yes|no" ] 
                  [ Width="width in px or %" ]&gt; 
            ... 
         </CF_openLayer> 
  
 Contact: 
 mail@Christian-Schneider.de 
 www.Christian-Schneider.de 
  
   ************************************************************* 
---> 
<cfsetting enablecfoutputonly="Yes"> 
  
<!--- When no Ending-Tag is used throw an Exception ---> 
<cfif ThisTag.HasEndTag EQ false> 
 <CFTHROW message="CF_openLayer needs an ending tag! Please ensure that this tag has an closing tag."> 
 <CFEXIT> 
</cfif> 
  

<!--- Set all default values for optional parameters ---> 

<CFPARAM NAME="Attributes.border"     DEFAULT="Yes"> 
<CFPARAM NAME="Attributes.bordersize"   DEFAULT="3"> 
<CFPARAM NAME="Attributes.bordercolor"    DEFAULT="##F0F0F0"> 
<CFPARAM NAME="Attributes.image"     DEFAULT=""> 
<CFPARAM NAME="Attributes.imageopen"    DEFAULT="#Attributes.image#">
<CFPARAM NAME="Attributes.title"      DEFAULT=""> 
<CFPARAM NAME="Attributes.titleclosed"    DEFAULT=#Attributes.title#> 
<CFPARAM NAME="Attributes.titletooltip"   DEFAULT=""> 
<CFPARAM NAME="Attributes.isclosed"     DEFAULT="No"> 
<CFPARAM NAME="Attributes.width"       DEFAULT="100%"> 
<CFPARAM NAME="Attributes.titlefont"    DEFAULT="Verdana"> 
<CFPARAM NAME="Attributes.titlecolor"    DEFAULT=""> 
<CFPARAM NAME="Attributes.titlecoloropen" DEFAULT="#Attributes.titlecolor#"> 
<CFPARAM NAME="Attributes.titlesize"    DEFAULT="10"> 
<CFPARAM NAME="Attributes.layerid"    DEFAULT=""> 

<!--- Make the title strings safe to use with JavaScript ---> 
<cfset Attributes.title = Replace(Attributes.title, "'", "&acute;", "ALL")> 
<cfset Attributes.titleclosed = Replace(Attributes.titleclosed, "'", "&acute;", "ALL")> 

<!--- Store in a REQUEST-scoped variable if the accessing browser is ok... ---> 
<cfif NOT IsDefined("REQUEST.openLayerBrowserSafeForIE4")> 
 <!--- *** Browser-Check for Internet Explorer 4 and higher *** ---> 
 <!--- Check for Internet Explorer ---> 
 <cfset tmpPositionMSIE = ListContainsNoCase(CGI.HTTP_USER_AGENT, "MSIE",";")> 
 <cfif tmpPositionMSIE GT 0> 
  <!--- Check for Version 4.0 and higher ---> 
  <cfset tmpVersionMSIE = ListLast(ListGetAt(CGI.HTTP_USER_AGENT,tmpPositionMSIE,";")," ")> 
  <cfif IsNumeric(ListFirst(tmpVersionMSIE,"."))> 
   <cfif ListFirst(tmpVersionMSIE,".") GTE 4> 
    <cfset REQUEST.openLayerBrowserSafeForIE4 = true> 
   <cfelse> 
    <cfset REQUEST.openLayerBrowserSafeForIE4 = false> 
   </cfif> 
  <cfelse> 
   <cfset REQUEST.openLayerBrowserSafeForIE4 = false> 
  </cfif> 
 <cfelse> 
  <cfset REQUEST.openLayerBrowserSafeForIE4 = false> 
 </cfif> <!--- REQUEST.openLayerBrowserSafeForIE4 is "true" when IEXP 4 and higher; otherwise "false" ---> 
</cfif> 

<!--- ***** Here comes the actual work of this custom tag: ***** ---> 

<!--- When the starting-tag is being processed: ---> 
<CFIF ThisTag.ExecutionMode EQ "START"> 

 <!--- Generate a random unique ID for each instance of this tag so that each layer can be accessed separately ---> 
 <CFIF Len(Attributes.layerid)>
	 <cfset GeneratedUniqueLayerID = "#Attributes.layerid#">
 <CFELSE>
	 <cfset GeneratedUniqueLayerID = RandRange(1,999999)>
 </CFIF>

 <!--- Now set the starting properties depending on the passed Attributes... ---> 
 <cfif CompareNoCase(Attributes.border, "Yes") IS 0> 
  <cfset TMP_border = "solid"> 
 <cfelse> 
  <cfset TMP_border = "none"> 
 </cfif> 
  
 <cfif CompareNoCase(Attributes.isclosed, "Yes") IS 0> 
  <cfset TMP_display = "none"> 
  <cfset TMP_visibility = "hidden"> 
  <cfset TMP_borderwidth = "0"> 
  <cfset TMP_title = Attributes.titleclosed> 
  <cfif Len(Attributes.image)> 
   <cfset TMP_image = Attributes.image> 
  </cfif> 
  <cfif Len(Attributes.titlecolor)> 
   <cfset TMP_titlecolor = Attributes.titlecolor> 
  </cfif> 
 <cfelse> 
  <cfset TMP_display = "block"> 
  <cfset TMP_visibility = "visible"> 
  <cfset TMP_borderwidth = Attributes.bordersize> 
  <cfset TMP_title = Attributes.title> 
  <cfif Len(Attributes.image)> 
   <cfset TMP_image = Attributes.imageopen> 
  </cfif> 
  <cfif Len(Attributes.titlecolor)> 
   <cfset TMP_titlecolor = Attributes.titlecoloropen> 
  </cfif> 
 </cfif> 
  
 <CFOUTPUT> 
   <!--- Store in a REQUEST-scoped variable if this general JavaScript-Code was already written on the page... ---> 
   <cfif NOT IsDefined("REQUEST.openLayerScriptAlreadyWritten")> 

    <cfif REQUEST.openLayerBrowserSafeForIE4> 
     <!--- The general JavaScript to expand and collapse the layer... ---> 
     <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript"> 
     <!-- 
      function switchLayer(lyrID, title, titleclosed, borderwidth, imageA,imageB, colorA,colorB) { 
       if (document.all.length) { 
        // Determine if the layer is currently expanded or collapsed: 
        var tmpStatus; 
        eval("tmpStatus = document.all.lyrGroup_"+ lyrID +".style.display"); 
        // OK, then now expand or collapse it... 
        if (tmpStatus == 'none') { 
         eval("document.all.lyrGroup_"+ lyrID +".style.display='block';"); 
         eval("document.all.border_"+ lyrID +".style.borderWidth='"+borderwidth+"px';"); 
         eval("document.all.title_"+ lyrID +".innerHTML='"+title+"';"); 
         tmpImage = imageA; 
         tmpColor = colorA; 
        } 
        else { 
         eval("document.all.lyrGroup_"+ lyrID +".style.display='none'"); 
         eval("document.all.border_"+ lyrID +".style.borderWidth='0px';"); 
         eval("document.all.title_"+ lyrID +".innerHTML='"+titleclosed+"';"); 
         tmpImage = imageB; 
         tmpColor = colorB; 
        } 
        // If an image is used as the click-control, switch it... 
        if ((tmpImage != null) && (imageA != imageB)) { 
         eval("document.all.image_"+ lyrID +".src='"+tmpImage+"'"); 
        } 
        // If different title-colors are used, switch them... 
        if (tmpColor != '') { 
         eval("document.all.title_"+ lyrID +".style.color='"+tmpColor+"'"); 
        } 
       } 
      } 
     //--> 
     </SCRIPT> 
    </cfif> 

    <cfset REQUEST.openLayerScriptAlreadyWritten = true> 
   </cfif> 
  
   <cfif REQUEST.openLayerBrowserSafeForIE4> 
    <!--- Draw the titled border ---> 
    <fieldset id="border_#GeneratedUniqueLayerID#" style="border-width:#TMP_borderwidth#; border-color:#Attributes.BorderColor#; border-style:#TMP_border#; width:#Attributes.width#"> 
     <legend> 
      <span title="#Attributes.TitleTooltip#"> 
       <!--- Draw either a button oder an image as click-control... ---> 
       <cfif Len(Attributes.image)> 
	   <!--- The following commented line prevents the image form showing. --->
       <!---    <img id="image_#GeneratedUniqueLayerID#" src="#TMP_image#" onClick="switchLayer(#GeneratedUniqueLayerID#,'#Attributes.title#','#Attributes.titleclosed#',#Attributes.bordersize#,'#Attributes.imageopen#','#Attributes.image#','#Attributes.titlecoloropen#','#Attributes.titlecolor#')" border="0" alt="" style="cursor:pointer"> --->
       <cfelse> 
        <input type="button" value="" onClick="switchLayer(#GeneratedUniqueLayerID#,'#Attributes.title#','#Attributes.titleclosed#',#Attributes.bordersize#,null,null,'#Attributes.titlecoloropen#','#Attributes.titlecolor#')" style="width:1; height:1; margin-bottom:1"> 
       </cfif> 
       <font face="#Attributes.titlefont#"> 
        <b style="font-size:#Attributes.titlesize#pt"> 
         <span id="title_#GeneratedUniqueLayerID#" <cfif Len(Attributes.titlecolor)>style="color:#TMP_titlecolor#"</cfif>onClick="switchLayer('#GeneratedUniqueLayerID#','#Attributes.title#','#Attributes.titleclosed#',#Attributes.bordersize#,null,null,'#Attributes.titlecoloropen#','#Attributes.titlecolor#')" style="cursor:pointer">#TMP_title#</span> 
        </b> 
       </font> 
      </span> 
     </legend> 
    <div id="lyrGroup_#GeneratedUniqueLayerID#" style="display:#TMP_display#; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;"> 
   <cfelse> 
    <!--- For all non-IEXP4-Browsers just draw the title ---> 
    <br> 
       <font face="#Attributes.titlefont#" <cfif Len(ATTRI- 
BUTES.titlecolor)>color="#Attributes.titlecolor#"</cfif>><b style="font-size:#Attributes.titlesize#pt"><span id="title_#GeneratedUniqueLayerID#">#TMP_title#</span></b></ 
font> 
    <br> 
   </cfif> 

 </CFOUTPUT> 
  
<!--- When the ending-tag is being processed: ---> 
<CFELSEIF ThisTag.ExecutionMode EQ "END"> 

 <CFOUTPUT> 
  <!--- Simply close all things that were opened, depending on the used browser ---> 
  <cfif REQUEST.openLayerBrowserSafeForIE4> 
  

 </div></fieldset> 
  </cfif> 
  <!--- <p>  --->
 </CFOUTPUT> 
  
</CFIF> 

<cfsetting enablecfoutputonly="No"> 






