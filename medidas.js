// 	/******   GLOBAIS   ******/
var cItem,cItemTab,tipoop,query,cIdReg,cScrap,Arq,v_total_estoque,preco_de_custo,quantidade_faturada="";
var cCliente,cDescItem,cOp,cPl,cPb,cTr,cPu,cNp,cUsuario,cUlt_operac,cLote,cAcab="";
var cQtdpc="";
var resp=new Array(); 
var inicio,i,iScrap = 0;
const WS50 = "http://10.0.0.50:8888/";
const WS = "http://localhost/"
var i$ = function(id) { return document.getElementById(id); };
var s$ = function(selector) { return document.querySelector(selector); };
var t$ = function(tag) { return document.getElementsByTagName(tag); };
var n$ = function(name) { return document.getElementByName(name); };
var wbal, wprn;

//	/***********   FUNÇÕES   ******/
 function msg_status(txt) {
  i$("statusBar").innerHTML=txt;
  i$("statusBar").style.color="yellow";
  i$("statusBar").style.background="navy";
 }
// 
 function avisa_ok(txt) {
  i$("statusBar").innerHTML=txt;
  i$("statusBar").style.color="yellow";
  i$("statusBar").style.background="navy";
  setTimeout(function() {
   msg_status('Aguardando!');
  }, 4000);
 }
// 
 function avisa_erro(txt) {
  i$("statusBar").innerHTML=txt;
  i$("statusBar").style.color="white";
  i$("statusBar").style.background="red";
  setTimeout(function() {
   msg_status("Aguardando!");
  }, 3000);
 }
//
 function httpGet(theUrl) {
  var xmlHttp = null;
  xmlHttp = new XMLHttpRequest();
  xmlHttp.open( "GET", theUrl, false );
  xmlHttp.send( null );
  return xmlHttp.responseText;
 }

 /* JANELA RELATORIO ENTRADAS*/
 function popup(mylink, windowname) {
  //if ( !window.focus) return false;
  var href;
  if (typeof(mylink) == 'string'){	href=mylink;}	else {href=mylink.href;}
  window.open(href,"Relatorio", 'width=800,height=600,scrollbars=yes');
  return false;
 }

 function volta(){/*BOTAO VOLTAR*/
  if((i$("ip").innerHTML=='10.0.0.14\n')||(i$("ip").innerHTML=='10.0.0.2\n')||(i$("ip").innerHTML=='127.0.0.1\n') ) { 
   location.href="ctmed.html";
  } else {
   var win = window.open("", "_self"); 
   window.close(); 
   win.close(); 
   return false; 
  }
 }
 
 function arrumaData(cDtErr){
  var cDtOk="";
  cDtOk = cDtErr.substr(8,2)+"/"+cDtErr.substr(5,2)+"/"+cDtErr.substr(0,4);
  return cDtOk;
 }
 
 function idUsuario(id) {
  //IDENTIFICAR O USUARIO QUE VAI REGISTRAR A ENTRADA...
  var codcracha="";
  while (codcracha=="") {
   codcracha = prompt("Digite seu código do crachá!",codcracha);
  }
  if (codcracha.length!=4){alert('Código inválido'); return true;}
  if (!isNaN(codcracha)){
   if( (parseFloat(codcracha)>999) && (parseFloat(codcracha)<9999) ){
    var sql = "select nomecracha from cracha where nrocracha="+codcracha;	
   } else {alert('Código inválido'); return true;}
   var resp = httpGet(WS50+"connections/my_tquery.php?sql="+sql);
   resp = resp.replace("|","");
   cUsuario = resp.replace("&","");			
  } else {alert('Código inválido'); return true;}
  return cUsuario;
 }
 
 function validaOp(){
  //{se é produção eventual(1) ou protótipo(2): sai... se não eventual ou pré lançamento analisa regs qualidade}
  if ((tipoop=="0")||(tipoop=="2")) {
   requer=false;
   i$('btScrap').focus();
  }
  return false;	
 }

 function saiuC1(){
  //alert("C1 perdeu o foco");
  cOp = i$("c1").value;
  
  var ajax = null;
  ajax = new XMLHttpRequest();
  if (cOp.length != 6) return false;
  var sql=" select tc.nominho, tp.codigo_interno, tp.item, tp.descricao, tp.tipoop,tp.scrap,"+
         " tp.lote,tp.acabadas from produtos as tp, clientes as tc where tp.codprod='"+cOp+
         "' and tc.codigo = tp.cliente limit 1";
  ajax.onreadystatechange = function() {
   if(this.readyState == 4  && this.status == 200) {
    var data = this.responseText; // ou  responseXML
	  if (data=="X") { 
		 avisa_erro(data+"  :  Atenção! OP não encontrada! Repita!");
		 i$("c1").innerHTML=""; 
		 i$("c1").focus();
		 return false;              
	  }
	  var resp=data.split("|");
	  cIdReg=resp[1];
	  cItemTab=resp[2];
	  cScrap_ant=resp[5];
	  cLote=resp[6];
	  cAcab=resp[7];
	  cItem="";
	  for( i=0; i<cItemTab.length; i++ ) {
	   if ( (cItemTab.substr(i,1) != "." )&&( cItemTab.substr(i,1) != "-" )&&( cItemTab.substr(i,1) != "/") ){
		  cItem = cItem + cItemTab.substr(i,1);
	   }   
	  }         
	  i$('foto').src = WS50+'ctmed/fotos/FotosInt_Acabamento/'+cItem+'.jpg';
	  tipoop=resp[4];
	  cCliente=resp[0];
	  cDescItem=resp[3];
	  i$("cli").innerHTML = cCliente;
	  i$("descitem").innerHTML=cDescItem;
	  i$("coditem").innerHTML=cItemTab;
	  i$("op").innerHTML="<b>O.P.</b><p>"+cOp+"</p>";
    resp="";
    //monta tabela prods com as ultimas 5 ops do item.
    //OP-ESTOQUE-DISP-LOTE-LOCAL-PRONTA-VENDA-SCRAP-DATA-GRUPO
    var sql2="select codprod,estoque,lote,local,acabadas,quantidade_faturada,scrap,cadastro,grupo from produtos where item='"+cItemTab+ "' order by cadastro desc limit 5";
    var dados= new Array;
    var cpos= new Array;
    var cel="";
    var resp2= httpGet(WS50+"connections/my_tquery.php?sql="+sql2);
    var conteudo = "<tr> <th>O.P.</th> <th>EST.</th> <th>LOTE</th> <th>LOCAL</th> <th>PRONTA</th>"+
    " <th>FAT.</th> <th>SCRAP</th> <th>DATA</th> <th>GRUPO</th> </tr>";
    if (resp2!="X") { 
     dados=resp2.split("&");
     for (x=0; x<dados.length-1; x++){
      cpos[x]=dados[x].split("|");
      conteudo = conteudo + "<tr> <td>"+cpos[x][0]+"</td><td>"+parseInt(cpos[x][1])+"</td><td>"+cpos[x][2]+
      "</td><td>"+cpos[x][3]+"</td><td>"+cpos[x][4]+"</td><td>"+cpos[x][5]+"</td><td>"+cpos[x][6]+
      "</td><td>"+arrumaData(cpos[x][7])+"</td><td>"+cpos[x][8]+"</td> </tr>";
     }
     //alert(conteudo);
     i$("tbprods").innerHTML=conteudo;
    }
    var sql3 = "select top.data,top.hora,top.operacao,tp.lote,"+
    " SUM(top.qtd), SUM(top.sucata), SUM(top.retrabalho)"+
    " from ordem_producao as top, produtos as tp "+
    " where top.OP = tp.codprod and top.OP = "+cOp+
    " group by top.operacao order by top.data DESC , top.hora DESC";
    var resp3 = httpGet(WS50+"connections/my_tquery.php?sql="+sql3);
    var ordprods  = "<tr> <th>DATA</th><th>HORA</th><th>OPER</th><th>LOTE</th><th>PROD</th>"+
                    "<th>SCRAP</th><th>RETR</th> </tr>";
    if (resp3!="X") { 
     dados=resp3.split("&");
     for (x=0; x<dados.length-1; x++){
      cpos[x]=dados[x].split("|");
      ordprods = ordprods + "<tr> <td>"+arrumaData(cpos[x][0])+"</td><td>"+cpos[x][1].substr(0,5)+"</td><td>"+cpos[x][2]+
      "</td><td>"+cpos[x][3]+"</td><td>"+cpos[x][4]+"</td><td>"+cpos[x][5]+"</td><td>"+cpos[x][6]+
      "</td></tr>";
      //alert(conteudo);
      
     }
     i$("tbop").innerHTML=ordprods;
    }
   }
  }
  var url = WS50+"connections/my_tquery.php";
  var params = "?sql="+sql;
  ajax.open("GET", url+params,false);//true async false sync
  ajax.send();
  i$("c1").value="";
  i$("c1").focus();
  msg_status(" Digite o nro. da operação! ");
  return false;  
 }
//
 function tabCpo(event, cpo) {
  var tecla = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
  if (tecla == 13) {
   //alert('apertou event');
   i$(cpo).focus();
   saiuC1();
  }
  if(tecla == 27){ volta(); }
 }
//
	function aposCarregar() {
		i$('ip').innerHTML=httpGet("/cgi-bin/ip.cgi");
		msg_status(" Digite o nro. da ordem de produção! ");
    i$('c1').focus();
		//abreBalanca();
    if (i$('statusRede').src == "penguin_off.png"){
      avisa_erro('Erro! Problema com cabos ou roteadores! Comunique TI!');
      erro_grave = true;
      return false;
    }
    
    /*
       
  if not Servidor_OnLine then begin
    ShowMessagepos('Erro de conexão! Problema com cabos ou roteadores! Comunique TI! ou tente a cada 30 segs. até reiniciar!',0,0);
    erro_grave := true;
    close;
  end;
  
  linkFoto:= 'http://10.0.0.50:8888/ctmed/fotos/Vista.JPG';
  controles_reprovados:='';
  SBm.SimpleText:= ' AGUARDE... ';
  if EtiqAvulsa=1 then begin
    Label1.Caption := 'REIMPRESSÃO';
    Label1.Color:= clYellow;
    Label1.Font.Color:= clRed;
  end;
  tabela := TList.Create; //Cria tabela record
  hora_inicio:= now();
  Top:= 0;
  Left:= 0;
  Width:= Screen.Width;
  Height:= Screen.Height;
  //******Ajustar o tamanho da foto a resolução da tela (P/ usar o mesmo prog. no PC e no Note)
  if Screen.Height > 600 then begin
    Panel3.Height := 482;
    Panel3.Width := 642;
  end  else  begin
    Panel3.Height := 360;
    Panel3.Width := 450;
  end;
  Panel3.Top:=41;
  Panel3.Left:=(Screen.Width - Panel3.Width );
  // inicializa variaveis
  Panel_cota.visible:=False;
  Panel_ler.visible:=false;
  ed_Entra_Dados.text:= '';
  lb_amostras.caption:= '';
  lb_Cliente.caption:= '';
  ajusta_label(false);
  Fase := 0;
  avisa_ok('Identifique-se! Passe o Código de Barras do Crachá pelo Leitor ');
  // seta o foco e aguarda o inicio de operação
  Label16.Color := clRed;
  ed_Entra_Dados.setfocus;
  erro_grave:= false;
  sOmf := 'N'; //Não deve gerar OMF caso "S" sim deve gerar
     
     */
    
	}
 // EVENTOS DOS OBJETOS
 //
 i$("btBack").addEventListener("click", function(){volta()}, false);
 i$('c1').addEventListener('keydown',function(){tabCpo(event,'topoCB')},false );
 i$('c1').addEventListener('blur',function(){saiuC1()},false );
 i$('foto').addEventListener('error',function() { i$("foto").src='VistaCbPinhal.jpg'; },false);
 // i$('btEtiqueta').addEventListener('click',function(){	btEtiquetaClick()},false );
 // i$('btLocal').addEventListener('click',function(){	btLocalClick()},false );
 // i$('btScrap').addEventListener('click',function(){	btScrapClick()},false );
 // i$('btQtd').addEventListener('click',function(){	btQtdClick()},false );
 // i$('btRelat').addEventListener('click',function(){	btRelatClick()},false );
 //

 // EVENTOS DO HTML-DOM
 document.addEventListener('DOMContentLoaded',aposCarregar(),false );
 // document.getElementsByTagName('body').addEventListener('load',aposCarregar(),false);
