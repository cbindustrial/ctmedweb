// 	/******   GLOBAIS   ******/
var cItem,cItemTab,tipoop,query,cIdReg,cScrap,Arq,v_total_estoque,preco_de_custo,quantidade_faturada="";
var cCliente,cDescItem,cOp,cPl,cPb,cTr,cPu,cNp,cUsuario,cUlt_operac,cLote,cAcab,cCodProt,tipoent="";
var cQtdpc="";
var resp=new Array(); 
var inicio,i,iScrap=0;
const WS50 = "http://10.0.0.50:8888/";
const WS = "http://localhost:7777/"
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
//
	function abreBalanca() {
		if(typeof(Worker)!=="undefined") {
			if(typeof(wbal)=="undefined") {
				wbal=new Worker("balanca.js");
			}
			wbal.onmessage = function (event) {
				var registro=event.data;
				var peso = registro.split("|");
				cPb=peso[0].trim();cPl=peso[1].trim();cTr=peso[2].trim();cPu=peso[3].trim();cNp=peso[4].trim();
				//if (!isNaN(parseFloat(cPb))){cPb="0";}
        i$('pb').innerHTML="Peso Bruto:    "+cPb+" Kg";
        //if (!isNaN(parseFloat(cPl))){cPl="0";}
        i$('pl').innerHTML="Peso Liquido:  "+cPl+" kg";
				//if (!isNaN(parseFloat(cTr))){cTr="0";}
        i$('tr').innerHTML="Tara:          "+cTr+" kg";
				//if (!isNaN(parseFloat(cPu))){cPu="0";}
        i$('pu').innerHTML="Peso Unitario: "+cPu+" gm";
				//if (!isNaN(parseFloat(cNp))){cNp="0";}
        i$('np').innerHTML=cNp;
			};
		} else {
			msg_status("Este Navegador não suporta Web Workers!...");
		}
	}
//	
	function fechaBalanca() { wbal.terminate(); }

	//* IMPRESSORA    *//
	function abreImpressora(cQtd) {
		if(typeof(Worker)!=="undefined") {
			if(typeof(wprn)=="undefined") {
				wprn=new Worker("impressora.js");
			}
/*
# 1 - nome cliente
# 2 - item
# 3 - descricao item
# 4 - op
# 5 - bruto
# 6 - liquido
# 7 - tara
# 8 - unitario
# 9 - pecas
# 10- usuario
*/
			var campos = cCliente+"|"+cItem+"|"+cDescItem+"|"+cOp+"|"+cPb+"|"+
			cPl+"|"+cTr+"|"+cPu+"|"+cQtd+"|"+cUsuario;
			
			wprn.postMessage(campos);
			
			wprn.onmessage = function (event) {
				var retorno=event.data;
				msg_status(retorno);
			};
		} else {
			msg_status("Este Navegador não suporta Web Workers!...");
		}
	}
	function fechaImpressora() { wprn.terminate(); }

/* JANELA RELATORIO ENTRADAS*/
	function popup(mylink, windowname) {
		//if ( !window.focus) return false;
		var href;
		if (typeof(mylink) == 'string'){	href=mylink;}	else {href=mylink.href;}
		window.open(href,"Relatorio", 'width=800,height=600,scrollbars=yes');
		return false;
	}
	
	function volta(){/*BOTAO VOLTAR*/
		if( (i$("ip").innerHTML=='10.0.0.14\n')||(i$("ip").innerHTML=='10.0.0.2\n')||(i$("ip").innerHTML=='127.0.0.1\n') ) { 
			location.href="ctmed.html";
		} else {
			var win = window.open("", "_self"); 
			window.close(); 
			win.close(); 
			return false; 
		}		
	}
	
	function idUsuario(id) {
		//IDENTIFICAR O USUARIO QUE VAI REGISTRAR A ENTRADA...
		var codcracha="";
		while (codcracha=="") {
			codcracha = prompt("Digite seu código do crachá!",codcracha);
		}
		if (codcracha.length!=4){cUsuario='erro'; return cUsuario;}
		if (!isNaN(codcracha)){
			if( (parseFloat(codcracha)>999) && (parseFloat(codcracha)<9999) ){
			  var sql = "select nomecracha from cracha where nrocracha="+codcracha;	
			} else {cUsuario='erro'; return cUsuario;}
			var resp = httpGet(WS50+"connections/my_tquery.php?sql="+sql);
			resp = resp.replace("|","");
			cUsuario = resp.replace("&","");			
		} else {cUsuario='erro'; return cUsuario;}
		return cUsuario;
	}
 
	function validaOp(){
		//{se é produção eventual(1) ou protótipo(2): sai... se não eventual ou pré lançamento analisa regs qualidade}
		if ((tipoop=="0")||(tipoop=="2")) {
			requer=false;
			i$('btScrap').focus();
		}			
	}
	function valida_op(op, pc, scp){ //valida qtd se é componente, etc. (Base MS SQL)
		url = "cbindw/valida_op.php?op="+op+"&pc="+pc+"&scp="+scp;
		var respms = httpGet(WS50 + url);
		if(respms=="X"){
			avisa_erro(resp+"  :  Erro! OP Protheus não encontrada! Repita!");
			return false;              
		}
		return respms;
	}
	
	function saiuC1(){
		//alert("This input field has lost its focus.");
		cOp = i$("c1").value;
		var ajax = null;
		ajax = new XMLHttpRequest();
		if (cOp.length != 6) return false;
		var sql="select tc.nominho, tp.codigo_interno, tp.item, tp.descricao, tp.tipoop,tp.scrap,"+
						"tp.lote,tp.acabadas from produtos as tp, clientes as tc "+ 
						"where (tp.cadastro >= SUBDATE(CURDATE(), INTERVAL 60 DAY) OR  tp.codprod='101010') AND tp.codprod='"+cOp+
						"' and tc.codigo = tp.cliente limit 1";
		ajax.onreadystatechange = function() {
      if(this.readyState == 4  && this.status == 200) {
        var data = this.responseText; // ou  responseXML
				if (data=="X") { 
					avisa_erro(data+"  :  Atenção! OP não encontrada Ou Data inferior a - 60 Dias! Repita!");
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
				//***INICIO***Pega codigo do produto Protheus
				sqlms = " SELECT C2.C2_PRODUTO FROM SC2010 AS C2 WHERE C2.C2_ZOPCB = "+cOp;
				var respms = httpGet(WS50+"connections/ms_tquery.php?sql="+sqlms);
				if(respms=="X"){
					avisa_erro(resp+"  :  Erro! OP Protheus não encontrada! Repita!");
					return false;              
				}
				cCodProt = respms.substr(0,2); //grava em uma variavel o inicio do codigo para posteriormente saber se é PA,CO,MO, etc.
				//***FIM***Pega codigo do produto Protheus
				for( i=0; i<cItemTab.length; i++ ) {
					if ( (cItemTab.substr(i,1) != "." )&&( cItemTab.substr(i,1) != "-" )&&( cItemTab.substr(i,1) != "/")&&( cItemTab.substr(i,1) != " ") ){
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
				if(cItemTab=="2RD805333") {
					msg_status("Digite a quantidade para entrada em estoque!");	
					i$("c2").readOnly=true;
					i$("c2").required=true;
					return;
				}	else {
					msg_status("Posicione os itens sobre a balança!");
				}
				//monta tabela prods com as ultimas 7 ops do item.
				//OP-ESTOQUE-DISP-LOTE-LOCAL-PRONTA-VENDA-SCRAP-DATA-GRUPO
				var sql2="select codprod,estoque,lote,local,acabadas,quantidade_faturada,scrap,cadastro,grupo from produtos where item='"+cItemTab+
						"' order by cadastro desc limit 10";
				var dados= new Array;
				var cpos= new Array;
				var cel="";
				var resp2= httpGet(WS50+"connections/my_tquery.php?sql="+sql2);
				var conteudo = "<tr> <td>O.P.</td> <td>EST.</td> <td>LOTE</td> <td>LOCAL</td> <td>PRONTA</td>"+
				" <td>FAT.</td> <td>SCRAP</td> <td>DATA</td> <td>GRUPO</td> </tr>";
				if (resp2!="X") { 
					dados=resp2.split("&");
					for (x=0; x<dados.length-1; x++){
						cpos[x]=dados[x].split("|");
						conteudo = conteudo + "<tr> <td>"+cpos[x][0]+"</td><td>"+parseInt(cpos[x][1])+"</td><td>"+cpos[x][2]+
						"</td><td>"+cpos[x][3]+"</td><td>"+cpos[x][4]+"</td><td>"+cpos[x][5]+"</td><td>"+cpos[x][6]+
						"</td><td>"+cpos[x][7]+"</td><td>"+cpos[x][8]+"</td> </tr>";
					}
					//alert(conteudo);
					i$("tbprods").innerHTML=conteudo;
				}
			}
		};
    var url = WS50+"connections/my_tquery.php";
		var params = "?sql="+sql;
    ajax.open("GET", url+params,false);//true async false sync
    ajax.send();
		validaOp();	
	}
// 	
	function tabCpo(event, cpo) {
		var tecla = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
		if (tecla==13) {
			//alert('apertou event');
			i$(cpo).focus();
			saiuC1();
		}
		if(tecla==27){volta();}
	}
//
	function aposCarregar() {
		i$('ip').innerHTML=httpGet("/cgi-bin/ip.cgi");
		i$('c1').focus();
		msg_status("Digite o Nro. da Ordem de Produção!");
		abreBalanca();
	}
//	
	function btEtiquetaClick() {/*BOTAO ETIQUETA*/
		var usuario = idUsuario();
		    if ((usuario=="") || (usuario=='erro')) {
      avisa_erro('Código de usuário inválido!');
      return false;
    }
		if (i$('np').innerHTML=="0") { prompt('Confirma a impressão com peças=0 ? '); }
		cQtdpc = i$('np').innerHTML;
		var cQtdemb="0";
		while (cQtdemb=="0") {
			cQtdemb = prompt("Qual a quantidade por EMBALAGEM ?",cQtdemb);
		}
		if (isNaN(cQtdemb)) {
			alert('Quantidade inválida! Repita!'); return true;
		}
		var iQtdpc = parseFloat(cQtdpc);
		var iQtdemb = parseFloat(cQtdemb);
		var ncxcheia = Math.round(iQtdpc/iQtdemb);
		var ncxresto = Math.round((ncxcheia -(iQtdpc/iQtdemb))*iQtdemb);
		//prompt("Confirma: "+ncxcheia+" com :"+qtdemb+" pc e uma com: "+ncxresto+" pecas?");
		while (iQtdpc > 0) {
			//imprime etiqueta da tela
			if (iQtdpc<iQtdemb) {
				abreImpressora(iQtdpc);	
			} else {
				abreImpressora(iQtdemb);
			}
			iQtdpc = (iQtdpc - iQtdemb);
			//alert("resta:"+qtdpc);
		}
		return false;
	}
//	
	function btLocalClick() {/*BOTAO LOCAL*/
		//alert('apertou Local');
		if(cOp==""){ avisa_erro("Digite o código da OP para iniciar!"); 
			i$("c1").focus();
			return false; 
		}
		var usuario = idUsuario();
		    if ((usuario=="") || (usuario=='erro')) {
      avisa_erro('Código de usuário inválido!');
      return false;
    }
		var cLocal = "";
		while (cLocal=="") {
			cLocal=prompt("Digite o Local para armazenamento!",cLocal);
		}
		var sql = "update produtos set local='"+cLocal+"' where codigo_interno="+cIdReg;
		var resp = httpGet(WS50+"connections/my_tquery.php?sql="+sql);
		if (resp=="X") { 
			avisa_erro(resp+"  :  Erro! Não gravei o local! Repita!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}	
		//Grava o local no MS SQL
		var resp = httpGet(WS50+"cbindw/grava_local.php?op="+cOp+"&loc="+cLocal);
		if (resp=="X") { 
			avisa_erro(resp+"  :  Erro! Não gravei o local! Repita!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}		
		//***FIM***Grava o local no MS SQL
		return false;
		sql ="insert into log_sis (data,hora,Usuario,Atividade) values"+
									"(curdate(),curtime(),'"+cUsuario+"','ALTEROU LOCAL op:"+cOp+" para: "+cLocal+"')"; 
		resp = httpGet(WS50+"connections/my_tquery.php?sql="+sql);
		if (resp=="X") { 
			avisa_erro(resp+"  :  Erro! Não gravei o local! Repita!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}
		avisa_ok('Local atualizado!'); 
		return true;
	}
	
	function btScrapClick(){/*BOTAO SCRAP*/
		//alert('apertou Scrap');
		if(cOp==""){ avisa_erro("Digite o código da OP para iniciar!"); 
			i$("c1").focus();
			return false; 
		}
		
		var usuario = idUsuario();
	    if ((usuario=="") || (usuario=='erro')) {
      avisa_erro('Código de usuário inválido!');
      return false;
    }
		// SOMAR AO SCRAP AS PEÇAS LANCADAS... SE NEGATIVA REDUZIR O SCRAP;
		cScrap = "";
		msg_status("Digite a quantidade... se negativa vai diminuir o valor atual.");
		while (cScrap=="") {
			cScrap=prompt("Digite a quantidade para sucatear!",cScrap);
		} 
		if (isNaN(cScrap)) {
			alert('Quantidade inválida! Repita!'); 
			i$("c1").focus();			
			return true;
		}		
		var iScrap = parseFloat(cScrap);
		if (iScrap==0){
			msg_status('Digite uma quantidade válida para o scrap!');
			return false;
		}
		var iScrap_atual = parseFloat(cScrap);
		iScrap_atual = iScrap_atual + iScrap;
		if (iScrap_atual < 0) { iScrap_atual=0;	}
		    //Grava o SCRAP no MS SQL
    //alert(tipoent);
    var resp = httpGet(WS50+"cbindw/Ent_QtdEst.php?op="+cOp+"&scp="+cScrap+"&tp=S");
    if (resp=="X") { 
      avisa_erro(resp+"  :  Erro! Não gravei scrap na base Protheus! Repita!");
      i$("c1").innerHTML=""; 
      i$("c1").focus();
      return false;              
    }   
    //***FIM***Grava o SCRAP no MS SQL    
		
		
		var sql="update produtos set scrap = '"+iScrap_atual+"' where codigo_interno="+cIdReg;
		var resp = httpGet(WS50+"connections/my_tquery.php?sql="+sql);
		if (resp=="X") { 
			avisa_erro(resp+"  :  Erro! Não gravei o scrap! Repita!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}

		sql ="insert into log_sis (data,hora,Usuario,Atividade) values"+
					"(curdate(),curtime(),'"+cUsuario+"','ALTEROU Scrap de:"+cScrap_ant+
					" para: "+iScrap_atual+"')"; 
		resp = httpGet(WS50+"connections/my_tquery.php?sql="+sql);
		if (resp=="X") { 
			avisa_erro(resp+"  :  Erro! Não gravei o scrap! Repita!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}
		avisa_ok("Scrap registrado!");
		return true;
	}
//	
	function btQtdClick(){/*BOTAO QUANTIDADE*/

   
   // alert('apertou Qtd');
		if(cOp=="") { avisa_erro("Digite o código da OP para iniciar!"); 
			i$("c1").focus();
			return false; 
		}
    //alert(cCodProt);
    if((cCodProt == 'PA') || (cCodProt == 'MO')) tipoent = "A"; else tipoent = "T";
    var res = valida_op(cOp, cNp, iScrap);
    if (res.substr(0,2) != "OK"){
      alert("OP não validada..."+res);
      return false;
    } 		
		
		var usuario = idUsuario();
	  if ((usuario=="") || (usuario=='erro')) {
      avisa_erro('Código de usuário inválido!');
      return false;
    }	
    
		if (cNp=="0"){ avisa_erro("Quantidade de peças é nula! Verifique!" ); return false; }
		
		// VALIDACAO CONTROLE MEDIDAS... SE FORAM TODAS INSPECIONADAS
		var sql= "select operac from ctmed_itm where item='"+cItem+"' group by operac desc limit 1";
		var resp = httpGet(WS50+"connections/my_tquery.php?sql="+sql);
		if (resp=="X") { 
			avisa_erro(resp+"  :  Erro ao consultar a tabela ctmed_itm! Repita!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}
		resp = resp.replace("|","");
		cUlt_operac = resp.replace("&","");
		if (parseInt(cUlt_operac)<=0) {
			avisa_erro('Erro ao consultar a ultima operacao na tabela ctmed_itm!');
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;			
		}
		//VALIDAR ULTIMA OPERACAO TEM CONTROLE MEDIDAS REGISTRADO.(até um dia antes... mais não.)
		sql="select count(*) from ctmed_reg where codprod = '"+cOp+"' and "+
				"operac='"+cUlt_operac+"' and etapa='F' limit 1";
		resp=httpGet( WS50+"connections/my_tquery.php?sql="+sql );
		if (resp=="X") { 
			avisa_erro(resp+"  :  Erro ao consultar a finalização na tabela ctmed_reg!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}
		resp=resp.replace("|","");
		resp=resp.replace("&","");
		if (parseInt(resp)==0) {
			avisa_erro('Nao encontrei registro de Finalização na ULTIMA OPERAÇÃO ['+cUlt_operac+'], verifique!');
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;			
		}
		

		// VALIDAÇÃO QUANTIDADE DE ENTRADA ESTOQUE.
		var iAcabadas = parseInt( cNp )+parseInt(cAcab);
		var iScrap = parseInt( cScrap_ant );
		//alert('acabadas:'+iAcabadas+" pecas:"+cNp+" scrap:"+iScrap+"  Lote:"+cLote);
		if ( (iAcabadas + iScrap) > (parseInt(cLote) * 1.05) ) {
			avisa_erro("Erro! O total é superior a 5% do lote da O.P.! Ajuste com PCP.");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;				
		}
		
		    //Grava o QTD. PEÇAS no MS SQL

    //alert(cOp + cNp + iScrap + tipoent);  
    var url="http://10.0.0.50:8888/cbindw/Ent_QtdEst.php?op="+cOp+"&pc="+cNp+"&scp=0&tp="+tipoent;
    //alert(url); return false;
    resp=httpGet(url);
    if (resp=="X") { 
      avisa_erro(resp+"  : Erro ao gravar registro na tabela ZA2010!");
      i$("c1").innerHTML=""; 
      i$("c1").focus();
      return false;              
    } 
    //***FIM***Grava o QTD. PEÇAS no MS SQL   
		
		
		if ((iAcabadas+iScrap)>parseInt(cLote)){
			var excedeu = (iAcabadas + iScrap) - parseInt(cLote);
			sql = "update produtos set estoque='"+excedeu+"' where codigo_interno='"+cIdReg+"'";	
			resp=httpGet( WS50+"connections/my_exec.php?sql="+sql );
			if (resp=="X") { 
				avisa_erro(resp+"  : Erro ao gravar excesso na tabela produtos!");
				i$("c1").innerHTML=""; 
				i$("c1").focus();
				return false;              
			}
		}	
		
		sql = "update produtos set acabadas='"+iAcabadas+"' where codigo_interno='"+cIdReg+"'";
		resp = httpGet( WS50+"connections/my_exec.php?sql="+sql );
		if (resp=="X") { 
			avisa_erro(resp+"  : Erro ao gravar acabadas na tabela produtos!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}		
		
		sql = "INSERT INTO entprodest SET data=CURDATE(), hora=CURTIME(), op='"+cOp+
                "', qtd='"+cNp+
                "', usuario='"+cUsuario+
                "', item='"+cItemTab+
                "', unit='0"+//cPu+
                "', liq='0"+//cPl+
                "', emb='0"+//cTr+
                "', tot='0"+//cPb+
                "'";

		resp = httpGet( WS50+"connections/my_exec.php?sql="+sql );

		if (resp=="X") { 
			avisa_erro(resp+"  : Erro ao gravar registro na tabela entprodest!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}	
	
		sql="INSERT INTO log_sis (data,hora,Usuario,Atividade) VALUES("+
				"CURDATE(),CURTIME(),'"+cUsuario+"','Armazenou "+cNp+" pcs da Op-"+cOp+"')";
		resp=httpGet( WS50+"connections/my_exec.php?sql="+sql );
		if (resp=="X") { 
			avisa_erro(resp+"  : Erro ao gravar registro na tabela log_sis!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}
		avisa_ok('Quantidade Lançada!'); 
	return true;
	}	
	
	function btQtd2Click(){/*BOTAO QUANTIDADE DE COMPONENTE*/
	  if((cCodProt == 'PA') || (cCodProt == 'MO')) {
      avisa_erro('Atenção, este item não é um Componente!');
      return false;
    }
    var usuario = idUsuario();
		if ((usuario=="") || (usuario=='erro')) {
      avisa_erro('Código de usuário inválido!');
      return false;
    }
    //Grava o QTD. PEÇAS no MS SQL
		tipoent = "A";
		//alert(cOp +"Np-"+ cNp +"Scrp-"+ iScrap +"Tipo-"+ tipoent);	  
		
    var res = valida_op(cOp, cNp, 0);
		if (res.substr(0,2) != "OK"){
			alert("OP não validada..."+res);
			return false;
		}			
		var url="http://10.0.0.50:8888/cbindw/Ent_QtdEst.php?op="+cOp+"&pc="+cNp+"&scp=0&tp="+tipoent;
		//alert(url); return false;
		resp=httpGet(url);
		if (resp=="X") { 
			avisa_erro(resp+"  : Erro ao gravar registro na tabela ZA2010!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		}	
		//***FIM***Grava o QTD. PEÇAS no MS SQL	
		sql="INSERT INTO log_sis (data,hora,Usuario,Atividade) VALUES("+
				"CURDATE(),CURTIME(),'"+cUsuario+"','Armazenou "+cNp+" pcs da Op-"+cOp+"')";
		resp=httpGet( WS50+"connections/my_exec.php?sql="+sql );
		if (resp=="X") { 
			avisa_erro(resp+"  : Erro ao gravar registro na tabela log_sis!");
			i$("c1").innerHTML=""; 
			i$("c1").focus();
			return false;              
		} 
		avisa_ok('Quantidade Lançada!'); 
    return true;
	}
	
	function btRelatClick(){
		popup("relprod.html","rel");
		return false;
	}


// EVENTOS DOS OBJETOS

//
	i$("btBack").addEventListener("click", function(){volta()}, false);
	i$('c1').addEventListener('keydown',function(){tabCpo(event,'topoCB')},false );
	i$('c1').addEventListener('blur',function(){saiuC1()},false );
	i$('foto').addEventListener('error',function() { i$("foto").src='vazio.png'; },false);
	i$('btEtiqueta').addEventListener('click',function(){	btEtiquetaClick()},false );
	i$('btLocal').addEventListener('click',function(){	btLocalClick()},false );
	i$('btScrap').addEventListener('click',function(){	btScrapClick()},false );
	i$('btQtd').addEventListener('click',function(){	btQtdClick()},false );
	i$('btQtd2').addEventListener('click',function(){	btQtd2Click()},false );
	i$('btRelat').addEventListener('click',function(){	btRelatClick()},false );
	
//
	
// EVENTOS DO HTML-DOM

	document.addEventListener('DOMContentLoaded',aposCarregar(),false );
	
//document.getElementsByTagName('body').addEventListener('load',aposCarregar(),false);
