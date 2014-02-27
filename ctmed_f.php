<?php
 header ('Content-type: text/html; charset=UTF-8');
 //header ('Content-type: text/html; charset=ISO-8859-1'); 

?>
<!DOCTYPE html>

<html "pt-br">
  <head>
    <title>CONTROLE MEDIDAS</title>
    <meta http-equiv="Content-Type" content="text/html" charset="UTF-8"/>
    <meta http-Equiv="Cache-Control" Content="no-cache">
    <meta http-Equiv="Pragma" Content="no-cache">
    <meta http-Equiv="Expires" Content="0">
  
    <style>
      html, body, div, span, object, iframe,h1, h2, h3, h4, h5, h6, p, blockquote, pre,
      abbr, address, cite, code,del, dfn, em, img, ins, kbd, q, samp,
      small, strong, sub, sup, var,b, i,dl, dt, dd, ol, ul, li,
      fieldset, form, label, legend,table, caption, tbody, tfoot, thead, tr, th, td,article, 
      aside, canvas, details, figcaption, figure, footer, header, hgroup, menu, nav, section, summary,
      time, mark, audio, video {
        margin:0;padding:0;border:0;outline:0;font-size:100%;vertical-align:middle;
        background:transparent;display:table-cell;}
      body {line-height:1;}
      article,aside,details,figcaption,figure,
      footer,header,hgroup,menu,nav,section {display:block;}
      nav ul {list-style:none;}
      blockquote, q {quotes:none;}
      blockquote:before, blockquote:after,q:before, q:after {content:'';content:none;}
      a {margin:0;padding:0;font-size:100%;vertical-align:baseline;background:transparent;}
      /* change colours to suit your needs */
      ins {background-color:#ff9;color:#000;text-decoration:none;}
      /* change colours to suit your needs */
      mark {background-color:#ff9;color:#000;font-style:italic;font-weight:bold;}
      del {text-decoration: line-through;}
      abbr[title], dfn[title] {border-bottom:1px dotted;cursor:help;}
      table {border-collapse:collapse;border-spacing:0;}
      /* change border colour to suit your needs */
      hr {display:block;height:1px;border:0;border-top:1px solid #cccccc;margin:1em 0;padding:0;}
      input, select {vertical-align:middle;}/******fim do reset de css******/
      /*TELA PRINCIPAL DO PORTAL CB NA WEB*/
      @font-face { 
        font-family: Comic; 
        src: url(comic.ttf);
      }
      @font-face {  
        font-family: Trebuchet; 
        src: url(trebuc.ttf);
      }
      html{overflow-x: hidden; overflow-y: hidden;font: 100.01% Trebuchet, Helvetica, Sans; }
      body { height:100%; width:100%; text-align:center; background: url(../../image/bg_carbonfiber.png); color:#333; line-height:1.22em;}
      footer {display:block;}
      a {text-decoration:none; font: 100.01% Trebuchet, Helvetica, Sans; }
      ul {  list-style:none;padding:0px;background-repeat: no-repeat;background: #FFFFCC;}
      .bt-02 a, a:active, a:visited { color: #666; text-decoration:none; }
      /*.bt-02 a:hover { color: #f00; }*/
      .bt-02 a:link { -webkit-tap-highlight-color: #a1d8f0; }
      .bt-02 a:hover, a:active, *:focus, input:focus, button:focus { outline: none;color: #f00; }
      .tit{text-align:center;font: 100.01% Trebuchet, Helvetica, Sans; height:auto;}
      .bt-02 { display: inline-block; height:auto;margin-top:15px; width: 175px;
        padding: 10px 13px;font: 100.01% Trebuchet, Helvetica, Sans; border:1px solid #d0d0d0;
        border-top-color:#ececec; border-bottom-color:#909090; color:#909090;
        background:#fff;background: -moz-linear-gradient(top, #fff 60%, #e7e7e7);
        background: -webkit-linear-gradient(top, #fff 60%, #e7e7e7);
        filter:  progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e7e7e7');
        -moz-border-radius: 7px; -webkit-border-radius: 7px; -khtml-border-radius: 7px;
        border-radius: 7px; -moz-box-shadow: 0 7px 7px rgba(0,0,0,.2), 0 7px 0px rgba(0,0,0,.4), 0 2px 3px rgba(0,0,0,.2);
        -webkit-box-shadow: 0 7px 10px rgba(0,0,0,.2), 0 7px 0px rgba(0,0,0,.4), 0 2px 3px rgba(0,0,0,.2);
      }
      .bt-02:hover { color:blue; background:#e7e7e7; position:relative; top:5px;
        border-top-color:#909090; border-bottom-color:#ececec;
        -moz-box-shadow: 0 0 0 #fff; -moz-box-shadow: inset 0 2px 20px rgba(0,0,0,.2);
        -webkit-box-shadow: 0 0 0 #fff; -webkit-box-shadow: inset 0 2px 20px rgba(0,0,0,.2);
      }
      #box_centrado {
        width: 500px; height:300px; position:absolute; top:50%; left:50%;      
        margin-top:-150px; margin-left:-250px; background:transparent;
      }
      .fundoCB{   position:absolute;   top: 1px;   left:5px; right:5px; width:auto; height:64px; border: 1px solid blue; 
      background:navy; color:yellow;  font: 200% Trebuchet,Arial,Verdana; 
        z-index:2;
        text-align:center; line-height:70px;/*para centralizar o texto na vertical*/  
        -moz-border-radius:8px;
        -webkit-border-radius:8px;
        border-radius:8px;
        behavior: url(PIE.htc);
      }
      .status{ position:fixed; width:300px; top:50px;  right:10px;  border:0; text-align:right; font: 100.01% Comic; z-index:3; color:yellow;}
      .statusBar {font:100% Comic; position: fixed;left:5px;right:5px;width:auto;height:24px;line-height:24px;    bottom:1px;   border: 1px blue;   margin:0;
          padding:0;z-index:7;    background:navy; color:yellow;   text-align: center;     
          -moz-border-radius:5px;   
          -webkit-border-radius:5px;    
          border-radius:5px;
          behavior: url(PIE.htc);
      }
    </style>

    <script>
      document.onkeyup = KeyCheck;       
      function KeyCheck(e) {
        var KeyID = (window.event) ? event.keyCode : e.keyCode;
        //window.alert("O código da tecla pressionada foi: " + KeyID);
        if ( (KeyID==105)||(KeyID==57) ) { //tecla 9
          document.location.href=("../../Des_Ferr/listar3.php");
        }
        if ( (KeyID==103)||(KeyID==55) ) { //tecla 7
          document.location.href=("omf.php");
        }
     
      }
    </script>      
  
  </head>
 
  <body>
  <div id="fundoCB" class="fundoCB">CB Industrial</div>
  <div id="status" class="status"></div><!-- LINHA COM O OLA FULANO | SAIR -->
    <div id="box_centrado" >
      <a id="bt7" class="bt-02" href="omf.php" alt="abre ordem de manutenção de ferramental" >7 - O.M.Ferramental</a>
      <a id="bt9" class="bt-02" href="../Des_Ferr/listar3.php" alt="Desenhos">9 - Desenhos</a>
    </div>
    <div id="statusBar" class="statusBar">Tecle o número da opção desejada!</div>
    
  </body>
  
</html> 