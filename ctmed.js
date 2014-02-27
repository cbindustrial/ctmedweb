
var i$ = function(id) { return document.getElementById(id); };

const ON=1;
const OFF=0;
var rede = ON;

  function msg_status(txt) {
    i$("statusBar").innerHTML=txt;
    i$("statusBar").style.color="yellow";
    i$("statusBar").style.background="navy";
  }
 
  function avisa_ok(txt) {
    i$("statusBar").innerHTML=txt;
    i$("statusBar").style.color="yellow";
    i$("statusBar").style.background="navy";
    setTimeout(function() {
      msg_status('Aguardando!');
    }, 4000);
  }
 
  function avisa_erro(txt) {
    i$("statusBar").innerHTML=txt;
    i$("statusBar").style.color="white";
    i$("statusBar").style.background="red";
    setTimeout(function() {
      msg_status("Aguardando!");
    }, 3000);
  }
  
  function httpGet(theUrl) {
    var xmlHttp = null;
    xmlHttp = new XMLHttpRequest();
    xmlHttp.open( "GET", theUrl, false );
    xmlHttp.send( null );
    return xmlHttp.responseText;
  }
  
  function checaRede(){
    var resp=httpGet("/cgi-bin/testaWS50.cgi");
    if(resp.trim()=="X") { 
      rede=OFF; 
      avisa_erro("Erro: rede não encontrada!");
      return rede; 
    }
    if(resp.trim()=="OK") { rede=ON; return rede; } 
  }
  
  checaRede();

  function KeyCheck(e) {
   var KeyID = (window.event) ? event.keyCode : e.keyCode;
   checaRede();
   if (rede==OFF) { return; }
   
   if ( (KeyID==105) || (KeyID==57) ) { //tecla 9
     if (rede==ON) { document.location.href=("http://10.0.0.50:8888/Des_Ferr/listar3.php"); }
   }
   if ( (KeyID==103) || (KeyID==55) ) { //tecla 7
      if (rede==ON) { document.location.href=("omf.html"); }
   }
   if ( (KeyID==102) || (KeyID==54) ) { // tecla 6
     if (rede==ON) { document.location.href=("osm.html"); }
   }
   if ( (KeyID==100) || (KeyID==52) ) { // tecla 4
     if (rede==ON) { document.location.href=("entprod.html"); }
   }
   if ( (KeyID==99) || (KeyID==51) ) {  // tecla 3
     if (rede==ON) { document.location.href=("reimpri.html"); }
   }
   if ( (KeyID==97) || (KeyID==49) ) {  // tecla 1
     if (stRede==ON) { document.location.href=("medidas.html"); }
   }        
  }

 document.onkeyup = KeyCheck;

 //document.onclick = function(){if (rede==ON){checaRede();}} 

 i$("bt9").addEventListener("click", function() {checaRede(); 
   if (rede==ON) { document.location.href=("http://10.0.0.50:8888/Des_Ferr/listar3.php"); } else{avisa_erro("Erro: rede não encontrada!");}
 }, false);
 
 i$("bt7").addEventListener("click", function() {checaRede(); 
   if (rede==ON) { document.location.href=("omf.html"); } else{avisa_erro("Erro: rede não encontrada!");}
 }, false);

  i$("bt6").addEventListener("click", function() {checaRede(); 
   if (rede==ON) { document.location.href=("osm.html"); } else{avisa_erro("Erro: rede não encontrada!");}
 }, false);
  
 i$("bt4").addEventListener("click", function() {checaRede(); 
   if (rede==ON) { document.location.href=("entprod.html"); } else{avisa_erro("Erro: rede não encontrada!");}
 }, false);
 
 i$("bt3").addEventListener("click", function() {checaRede(); 
   if (rede==ON) { document.location.href=("reimpri.html"); } else{avisa_erro("Erro: rede não encontrada!");}
 }, false);

 i$("bt1").addEventListener("click", function() {checaRede(); 
   if (rede==ON) { document.location.href=("medidas.html"); } else{avisa_erro("Erro: rede não encontrada!");}
 }, false);

 
 
  /*
  
  i$('c1').addEventListener('keydown',function(){tabCpo(event,'topoCB')},false );
  i$('c1').addEventListener('blur',function(){saiuC1()},false );
  i$('foto').addEventListener('error',function() { i$("foto").src='vazio.png'; },false);

      <a id="bt7" class="bt-02" href="omf.html" alt="Ordem Manutenção Ferramental" >7 - O.M.Ferramental</a>
      <a id="bt9" class="bt-02" href="http://10.0.0.50:8888/Des_Ferr/listar3.php" alt="Desenhos">9 - Desenhos</a>
      <a id="bt4" class="bt-02" href="entprod.html" alt="Entradas em estoque">4 - Entrada Estoque</a>
      <a id="bt6" class="bt-02" href="osm.html" alt="Ordem Serviço Manutenção">6 - O.S.Manutenção</a>
      <a id="bt1" class="bt-02" href="medidas.html" alt="Controle de Medidas">1 - Iniciar Medidas</a>
      <a id="bt3" class="bt-02" href="reimpri.html" alt="Reimpressão de medidas">3 - Reimprimir</a> 
  */