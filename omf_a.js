/*
* 
* TODOS PODEM EXECUTAR O PROGRAMA E VISUALIZAR AS OMF EXISTENTES EM ABERTO.
* TODOS PODEM FINALIZAR O PROGRAMA.
* Botoes GERAR e CONCLUIR OMF pedem A IDENTIFICAÇÃO DO SUPERVISOR
* Botao INICIAR pede o cracha para identificar o ferramenteiro que vai fazer o servico
* **********************************************************************************
*
* global variables
*
*/

var sCodCB,sCodProteus,sDescMaq,uri,sql,sChaveAcesso,sInc,sNro,sNro2,sNroSel,clist="";
var sOper,sItem,sCritico, sDtinicio,sDtReparo,sDescricao,sExecutor, sIncp="";
var sSolicitante,sDescMaq,sCodProteus,sUsuario,texto,sData,selec,sIdreg="";
var executor,problema,resp,escolha,Supervisor,sDtPrevista,htmlTV="";
var i,nro,idx,nlin,lin,col,rede,lst,totvclist=0;
var tabela_equipos="";
var ferramenta,lista,pesquisa,cpo,vclist,vserv = new Array();
var tab = new Array([],[]);
var lin, col = 0;
var escSN = 0; /*escolha sim nao*/

const ON = 1;
const OFF = 0;
const SIM = 1;
const NAO = 0;
const WS50 = "http://10.0.0.50:8888/";
const WS = "http://localhost:7777/"

var dialog = OFF;

var i$ = function(id) { return document.getElementById(id); };
var s$ = function(selector) { return document.querySelector(selector); };
var t$ = function(tag) { return document.getElementByTagName(tag); };
var n$ = function(name) { return document.getElementByName(name); };

function httpGet(theUrl) {
	var xmlHttp = null;
	xmlHttp = new XMLHttpRequest();
	xmlHttp.open( "GET", theUrl, false );
	xmlHttp.send( null );
	return xmlHttp.responseText;
}

function avisa_ok(txt) {
  $("#statusBar" ).css( {"background":"yellow","color":"navy"} ).html( txt );
}

function avisa_erro(txt) {
  $( "#statusBar" ).css( {"background":"red","color":"white"} ).html( txt );
  setTimeout(function() {
    avisa_ok(('Selecione uma opção!'));
  }, 2000);
}
  
function msg_status(txt) {
  $("#statusBar" ).html(txt).css( {"background":"navy","color":"yellow"} );
}

function servidorOnline() {
  $.ajax( {
    type:"GET",
    async:false,
    url: WS50+"connections/ativo.php",
    timeout:100,
    dataType:"text",
    success:function(data) {
      if(data=="OK") { rede=ON; } else { rede=OFF; }
      //if(data=="OK"){rede=OFF;}else{rede=ON} // errada
    }
  });
}

function utf8_decode ( str_data ) {
  var tmp_arr = [], i = 0, ac = 0, c1 = 0, c2 = 0, c3 = 0;
  str_data += '';
  while ( i < str_data.length ) {
      c1 = str_data.charCodeAt(i);
      if (c1 < 128) {
          tmp_arr[ac++] = String.fromCharCode(c1);
          i++;
      } else if ((c1 > 191) && (c1 < 224)) {
          c2 = str_data.charCodeAt(i+1);
          tmp_arr[ac++] = String.fromCharCode(((c1 & 31) << 6) | (c2 & 63));
          i += 2;
      } else {
          c2 = str_data.charCodeAt(i+1);
          c3 = str_data.charCodeAt(i+2);
          tmp_arr[ac++] = String.fromCharCode(((c1 & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
          i += 3;
      }
  }
  return tmp_arr.join('');
}

function CloseThis() {
	
  if ( (i$('ip').innerHTML=='10.0.0.14\n') || (i$('ip').innerHTML=='10.0.0.2\n')  || (i$('ip').innerHTML=='127.0.0.1\n')){ 
    location.href='ctmed.html';
  } else {
    var win = window.open('', '_self'); 
    window.close(); 
    win.close(); 
    return false; 
  }
}

function montaTV() {
  //alert ("chegou");
  dialog=OFF;
  sNroSel="";selec="";
  pesquisa=[];
  cpo=[];
  tab=[];
  servidorOnline();
  if ( rede==OFF ) {
    avisa_erro(("Problema de conexão... aguarde 30 segs.!! Se persistir o problema Chame TI!"));
    setTimeout(function(){},3000);
    return 0;
  }
  //alert(rede);
  sql = "select t1.inc,t1.Item,t1.operacao,t1.critico,t1.dtCadastro,t1.dtInicio,"+
        "t1.ferramenteiro,t1.dtPrevista,t1.supervisor,t2.cod_problema,t3.descricao, t2.inc "+
        "from ferr_OMF as t1, ferr_OMF_prob as t2, ferr_problema as t3 "+
        " where t1.inc=t2.inc_ferr and t2.cod_problema=t3.cod_motivo and "+
        "t1.dtTermino='0000-00-00 00:00:00'"+
        " order by t1.critico,t1.dtCadastro";
    
  $.ajax( {
    type:"GET",
    url:WS50+"connections/my_tquery.php?sql="+sql,
    timeout:2000,
    dataType:"text",
    success:function(data) {
      tab = data.split("&");
      nlin = tab.length;
      //alert(nlin);
			for (i=0;i<nlin;i++) { 
        tab[i] = tab[i].split("|");
      }
      sNro = "";
      sNro2 = "";
      htmlTV = "<table id='grade' class='sortable'>";
      htmlTV = htmlTV + "<thead id='cabec'><td class='c1'>NRO</td><td class='c2'>CR</td><td class='c3'>FERRAMENTAL</td>"+
      "<td class='c4'>OPER</td><td class='c5'>DT SOLICITA&Ccedil;&Atilde;O</td><td class='c6'>DT INICIO REP</td>"+
      "<td class='c7'>PREV TERMINO</td><td class='c8'>EXECUTOR</td><td class='c9'>SOLICITANTE</td>"+
      "</thead><tbody>";
      lin=0;
      col=0;
      while(lin<nlin-1) {
        sNro=tab[lin][0];
        //alert(sNro);
				sItem=tab[lin][1]
        sOper=tab[lin][2];
				sCritico=tab[lin][3];
        if (sNro==sNro2) {
				 // alert(nlin+" -"+sNro);
          sDescricao = tab[lin][10];
		  sIncp = tab[lin][11];
          if(sDescricao == 'CONTROLE MEDIDAS')
			htmlTV = htmlTV + "<tr><td colspan=9><p class='desc'>" + sDescricao + "<a href='../portal/qualidade/plano_acao/mostra_plano.php?omf="+sIncp+"' target='_blank'> - Plano de Ação</a></p></td></tr>";
		  else
			htmlTV = htmlTV + "<tr><td colspan=9><p class='desc'>" + sDescricao + "</p></td></tr>";
          lin++;
          continue;
        } 
        sNro2=sNro;
        sDtinicio=tab[lin][4];
        sDtinicio=sDtinicio.substr(8,2)+"/"+sDtinicio.substr(5,2)+"/"+sDtinicio.substr(0,4)+
          " "+sDtinicio.substr(10,9);
        sDtReparo=tab[lin][5];
        sDtReparo=sDtReparo.substr(8,2)+"/"+sDtReparo.substr(5,2)+"/"+sDtReparo.substr(0,4)+
          " "+sDtReparo.substr(10,9);
        sDtPrevista=tab[lin][7];
        sDtPrevista=sDtPrevista.substr(8,2)+"/"+sDtPrevista.substr(5,2)+"/"+
            sDtPrevista.substr(0,4) + " "+sDtPrevista.substr(10,9);
        sExecutor=tab[lin][6];
        sSolicitante=tab[lin][8];
        sDescricao=tab[lin][10];
		sIncp = tab[lin][11];
        htmlTV=htmlTV+"<tr><td class='c1'><pre class='reg' >"+sNro+"</pre></td><td class='c2'>"+
				sCritico+"</td><td class='c3'>"+
          sItem+"</td><td class='c4'>"+sOper+"</td><td class='c5'>"+sDtinicio+"</td><td class='c6'>"+
          sDtReparo+"</td><td class='c7'>"+sDtPrevista+"</td><td class='c8'>"+utf8_decode(sExecutor)+
          "</td><td class='c9'>"+utf8_decode(sSolicitante)+"</td></tr>";
          if(sDescricao == 'CONTROLE MEDIDAS')
			htmlTV = htmlTV + "<tr><td colspan=9><p class='desc'>" + sDescricao + "<a href='../portal/qualidade/plano_acao/mostra_plano.php?omf="+sIncp+"' target='_blank'> - Plano de Ação</a></p></td></tr>";
		  else
			htmlTV = htmlTV + "<tr><td colspan=9><p class='desc'>" + sDescricao + "</p></td></tr>";        
        lin++;
      }
      htmlTV=htmlTV+"</tbody></table><script>$('pre').click(function(ev){ev.preventDefault();"+
                    "sNroSel=$(this).text();selec=$(this).closest('td').next().next().text();"+
                    "$('pre').css('color','navy');$(this).css('color','red'); return false; });</script>";
      //alert(htmlTV);
      $("#jQ-menu").html(htmlTV);
      $(".c1").css("width","40px");
			$(".c2").css("width","20px");
      $(".c3").css("width","125px");
      $(".c4").css("width","50px");
      $(".c4,.c5,.c6,.c7").css("text-align","center");
      $(".c5,.c6,.c7").css("width","165px");
      $(".c8,.c9").css("width","180px");
      $(".desc").css({"text-align":"left","margin-right":"5px","margin-left":"50px","color":"#ffe4c4" });
      msg_status("Selecione uma Opção!");
    }
  });
  dialog=OFF;
  return false;
}

function bt1Gerar() {
  dialog=ON;
  var i, pergunta = 0;
  var critico = "";
  sNroSel="";selec="";
  servidorOnline();
  if (rede==OFF) {
    avisa_erro("Problema de conexão... aguarde 30 segs.!! Se persistir o problema Chame TI!");
    setTimeout(function(){}, 3000);
    dialog=OFF;
    return false;
  }
	//alert(rede);
  var gerasuper = [
    {//0
      title: "Aguarde...",
      html: "Carregando tabelas... demora alguns segundos!",
      buttons: {},
    },
    
    {//1
      title: "Supervisor:",
      html:"<label for='supname'>Digite a senha de supervisor</label><br/><label>Senha: <input type='password' name='supname' value=''></label><br/>",
      buttons: { Ok:true},
      focus: "input[name='supname']",
      submit:function(e,v,m,f) { 
        e.preventDefault();
        if (f.supname.length==0) {
          avisa_erro(("Atenção! Código do crachá inválido! Repita!")); 
          $.prompt.close();
          dialog=OFF;
          return false;
        }
        sql="select usuario,ChaveAcesso from usuarios where senha2='"+f.supname+"'";
        $.prompt.goToState(0);
        $.ajax({
          type: "GET",
          async: false,
          url: WS50+"connections/my_tquery.php?sql="+sql,
          timeout: 2000,
          dataType: "text",
          success: function(data){    
            if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
              avisa_erro(("Atenção! Código inválido! Repita!"));
              f.supname="";
              $.prompt.close();
              dialog=OFF;
              return false;
            }
            tab = data.split("&");
            for (lin=0; lin<tab.length; lin++) { 
              tab[lin] = tab[lin].split("|");
            }
            //avisa_ok("Supervisor: "+tab[0][0]);     /////////////////////////////////
            Supervisor=tab[0][0];
            sChaveAcesso=tab[0][1];
            $.prompt.goToState(2);
          }
        });
      }
    },

    {//2
      title:"Escolha o Ferramental!",
      html: "<label for='makeferr'>Ferramentais</label><select name='Ferramentais' id='makeferr'></select>",
      buttons: { Cancela: 0, OK: 1 },
      focus: 1,
      submit:function(e,v,m,f){ 
        e.preventDefault();
        if (v==0){
          $.prompt.close();
          dialog=OFF;
          return false;          
        }
        if(v==1){
          equipamento=f.Ferramentais;
          //avisa_ok("equipamento: "+f.Ferramentais);   ///////////////////////////////////////
          avisa_ok("Defina a criticidade 1=urgente ... 5=pode esperar!");
          $.prompt.goToState(3);
        }
      }
    },
    
    { //3
      title:"Criticidade",
      html: "<label>Defina a criticidade 1=urgente ... 5=pode esperar!</label>"+
            "<label><input type='text' name='critname' value=''></label><br/>",
      buttons: { Cancela: 0, OK: 1},
      focus: "input[name='critname']",
      submit:function(e,v,m,f){
        e.preventDefault();
        if (v==0){
          $.prompt.close();
          dialog=OFF;
          return false;          
        }
        if(v==1){
          if ((f.critname < 1) || (f.critname > 5)){
            avisa_erro("A criticidade deve estar entre 1 e 5");
            $.prompt.close();
            dialog=OFF;
            return false;           
          }
          criticidade=f.critname;
          //avisa_ok("criticidade: "+f.critname);
          avisa_ok(("Defina a operação do ferramental!"));
          $.prompt.goToState(4);
        }
      } 
    },
    
    { //4 operacao

      title:"Opera&ccedil;&atilde;o",
      html: "<label>Defina a opera&ccedil;&atilde;o do ferramental!</label>"+
            "<label><input type='text' name='opername' value=''></label><br/>",
      buttons: { Cancela: 0, OK: 1},
      focus: "input[name='opername']",
      submit:function(e,v,m,f){
        e.preventDefault();
        if (v==0){
          $.prompt.close();
          dialog=OFF;
          return false;          
        }
        if(v==1){
          if ((f.opername < 1) || (f.opername > 12)){
            avisa_erro(("A operação deve estar entre 1 e 12"));
            $.prompt.close();
            dialog=OFF;
            return false;           
          }
          operacao=f.opername;
          //avisa_ok("operacao: "+f.opername);
          avisa_ok("Defina os problemas existentes no ferramental!");
          problema="";
          $.prompt.goToState(5);
        }
      } 
    },

    { //5 problemas
      title:"Defina os problemas!",
      html: "<div id='prb'></div><br><label for='makeprob'>Problemas</label><select name='problemas' id='makeprob'></select>",
      buttons: { Cancela: 0, OK: 1, Concluir: 2 },
      focus: 1,
      submit:function(e,v,m,f){ 
        e.preventDefault();
        if (v==0){
          $.prompt.close();
          dialog=OFF;
          return false;          
        }
        if(v==1){
          if(problema==""){i=0;}else{i++;} 
          avisa_ok("problema: "+f.problemas);
          problema="Escolhido: "+f.problemas;
          promptobj.find("#prb").html(problema);
          
          if (i==0){
            //{primeiro defeito: verifica existência de item e operação em aberto}
             
            var sqla="select count(*) as nro from ferr_OMF where item='"+ equipamento +"' and operacao='"+ operacao +"' and dtTermino='0000-00-00 00:00:00'";
            $.ajax({
              type: "GET",
              async: false,
              url: WS50+"connections/my_tquery.php?sql="+sqla,
              timeout: 2000,
              dataType: "text",
              success: function(data) {    
                if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                  avisa_erro(("Atenção! Erro na Consulta de OMFs! Repita!"));
                  $.prompt.close();
                  dialog=OFF;
                  return false;
                }
                tab = data.split("&");
                for (lin=0; lin<tab.length-1; lin++) { 
                  tab[lin] = tab[lin].split("|");
                }
                if (tab[0][0]=="1"){
                  avisa_erro(("Atenção! Este equipamento já contém OMF em aberto! Pesquise!"));
                  $.prompt.close();
                  dialog=OFF;
                  return false;                  
                }  
                if (tab[0][0]=="0") {
                  var sqlb="insert into ferr_OMF (item, operacao, critico, dtCadastro,dtPrevista,supervisor)"+
                  "values ('"+equipamento+"', '"+operacao+"', '"+criticidade+"', now(), timestampadd(day,5,now()), '"+Supervisor+"')";                  
                  //alert(sql);
                  $.ajax({
                    type: "GET",
                    async: false,
                    url: WS50+"connections/my_exec.php?sql="+sqlb,
                    timeout: 2000,
                    dataType: "text",
                    success: function(data) {    
                      if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                        avisa_erro(("Atenção! Erro na gravação da OMF! Repita!"));
                        $.prompt.close();
                        dialog=OFF;
                        return false;
                      }
                      var sqlc="insert into ferr_OMF_prob (inc_ferr, cod_problema) values ((select inc from ferr_OMF order by inc desc limit 1),'"+f.problemas+"')";                  
                      //alert(sql);
                      $.ajax({
                        type: "GET",
                        async: false,
                        url: WS50+"connections/my_exec.php?sql="+sqlc,
                        timeout: 2000,
                        dataType: "text",
                        success: function(data) {    
                          if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                            avisa_erro(("Atenção! Erro na gravação do problema da OMF! Repita!"));
                            $.prompt.close();
                            dialog=OFF;
                            return false;
                          }
                        }
                      });                      
                    }
                  });                 
                  
                }
                $.prompt.goToState(5);
              }
            });           
          }
          
          if (i>1){
            //se mais de um problema, nos demais grava so os problemas
            var sqld="insert into ferr_OMF_prob (inc_ferr, cod_problema) values ((select inc from ferr_OMF order by inc desc limit 1),'"+f.problemas+"')";
            $.ajax({
              type: "GET",
              async: false,
              url: WS50+"connections/my_exec.php?sql="+sqld,
              timeout: 2000,
              dataType: "text",
              success: function(data) {    
                if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                  avisa_erro(("Atenção! Erro na gravação do problema da OMF! Repita!"));
                  $.prompt.close();
                  dialog=OFF;
                  return false;
                }
                $.prompt.goToState(5);//coleta senha supervisor       
              }
            });
            
            
          }
          //$.prompt.goToState(5);
        }
        
        if (v==2){
          montaTV();
          $.prompt.close();
          dialog=OFF;
          return false;          
        }
      }    
    },

  ];
  
  var promptobj = $.prompt(gerasuper);
  
  $.prompt.goToState(0);
  //carrega tabela itens para escolha ferramental
  sql="select codigo,SUBSTRING(descricao,1,30) from itensprecos where not isnull(descricao) order by codigo";
  $.ajax({
    type: "GET",
    async: false,
    url: WS50+"connections/my_tquery.php?sql="+sql,
    timeout: 2000,
    dataType: "text",
    success: function(data) {    
      if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
        avisa_erro(("Atenção! Erro na Consulta em itens ! Repita!"));
        $.prompt.close();
        dialog=OFF;
        return false;
      }
      data = (data);
      tab = data.split("&");
      var tabela_equipos = "";
      for (lin=0; lin<tab.length-1; lin++) { 
        tab[lin] = tab[lin].split("|");
        var ferr = tab[lin][0];
        var desc = tab[lin][1];
        tabela_equipos += "<option value='"+ferr+"'>"+ferr+" - "+desc+"</option>";
      }
      // populate the dropdown options
      promptobj.find("#makeferr").html(tabela_equipos);

    }
  });
  //exibir a lista de problemas para coletar o motivo da abertura
  sql = "select cod_motivo,descricao from ferr_problema order by cod_motivo";  
  $.ajax({
    type: "GET",
    async: false,
    url: WS50+"connections/my_tquery.php?sql="+sql,
    timeout: 2000,
    dataType: "text",
    success: function(data) {    
      if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
        avisa_erro(("Atenção! Erro na Consulta de problemas! Repita!"));
        $.prompt.close();
        dialog=OFF;
        return false;
      }
      //data = (data);
      tab = data.split("&");
      var tabela_prob = ""; //"<option value='0'>0 - FECHAR</option>";
      for (lin=0; lin<tab.length-1; lin++) { 
        tab[lin] = tab[lin].split("|");
        var codprob = tab[lin][0];
        var descprob = tab[lin][1];
        tabela_prob += "<option value='"+codprob+"'>"+codprob+" - "+descprob+"</option>";
      }
      // populate the dropdown options
      promptobj.find("#makeprob").html(tabela_prob);
      // Move from the WaitState to the form state
      $.prompt.goToState(1);//coleta senha supervisor       
    }
  });  
}  
  

function bt2IniciarReparo() {
  dialog=ON;
  if (sNroSel=="") {
    avisa_erro(('Selecione o ferramental para início de reparo!'));
    dialog=OFF;
    return false;
  }
 // msg_status(sNroSel);
  sUsuario = "";
  var statesdemo = {
    state0: {
      title: 'Crach&aacute;',
      html:'<label>Senha: <input type="password" name="fname" value=""></label><br />',
      buttons: { Ok:true},
      focus: "input[name='fname']",
      submit:function(e,v,m,f) { 
        e.preventDefault();
        //console.log(f);
        //******em teste
        if (f.fname.length != 4) {
          avisa_erro(('Atenção! Código do crachá inválido! Repita!')); 
          $.prompt.close();
          dialog=OFF;
          return false;
        }
        var sqla = "select nomecracha from cracha where nrocracha='"+f.fname+"'";
        //alert(sql);
        $.prompt.goToState('state3');
        $.ajax({
          type: "GET",
          async: false,
          url: WS50+"connections/my_tquery.php?sql="+sqla,
          timeout: 2000,
          dataType: "text",
          success: function(data) {    
            if ((data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
              f.fname="";
              avisa_erro(('Atenção! Código do crachá inválido! Repita!'));
              $.prompt.close();
              dialog=OFF;
              return false;
            }
            tab = data.split("&");
            for (lin=0; lin<tab.length; lin++) { 
              tab[lin] = tab[lin].split("|");
            }
            sUsuario=tab[0][0];
            //avisa_ok(tab[0][0]);
            //console.log(tab[0][0]);
            $.prompt.goToState('state1');           
          } 
        });

      }
    },
    state1: {
      title:"Confirme!",
      html:"<label>Confirma o inicio de reparo para: ["+selec+"] ?</label>",
      buttons: { Cancela: 0, OK: 1 },
      focus: 1,
      submit:function(e,v,m,f){ 
        e.preventDefault();
				//verifica se existe data de inicio de reparo... se sim, confirma mudança.
				var sqlb="select count(*) as nro from ferr_OMF where inc ='"+sNroSel+"' and dtinicio='0000-00-00 00:00:00'";
				$.prompt.goToState('state3');
				$.ajax({
					type: "GET",
					async: false,
					url: WS50+"connections/my_tquery.php?sql="+sqlb,
					timeout: 2000,
					dataType: "text",
					success: function(data) {    
						
						if ((data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
							avisa_erro(('Atenção! Registro não encontrado!'));
							
							$.prompt.close();
              dialog=OFF;
							return false;
						}
						if (data=="0|&"){
							
							$.prompt.goToState('state2');               
						}
						if (data=="1|&"){
							
							var sqlc="update ferr_OMF set ferramenteiro='"+sUsuario+"', dtinicio = now() where inc='"+sNroSel+"'";     $.prompt.goToState('state3'); 
							$.ajax({
								type: "GET",
								async: false,
								url: WS50+"connections/my_exec.php?sql="+sqlc,
								timeout: 2000,
								dataType: "text",
								success: function(data) {    
									if ((data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
										avisa_erro(('Atenção! Erro ao gravar data!'));
										$.prompt.close();
                    dialog=OFF;
										return false;
									}
									if (data=="Y"){
										$.prompt.close();
										montaTV();
                    dialog=OFF;
										return false;  
									}
								} 
							});								
														
						}							
					} 
				});
      }
    },
    state2: {
      title:"Confirme!",
      html:"<label> Existe inicio registrado! Confirma alteração da data?</label>",
      buttons: { Cancela: 0, OK: 1 },
      focus: 1,
      submit:function(e,v,m,f){
        var sqld="update ferr_OMF set ferramenteiro='"+sUsuario+"', dtinicio = now() where inc='"+sNroSel+"'";     
        $.prompt.goToState('state3');
				$.ajax({
					type: "GET",
					async: false,
					url: WS50+"connections/my_exec.php?sql="+sqld,
					timeout: 2000,
					dataType: "text",
					success: function(data) {    
						if ((data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
							avisa_erro(('Atenção! Erro ao gravar data!'));
							$.prompt.close();
              dialog=OFF;
							return false;
						}
						if (data=="Y"){
							$.prompt.close();
							montaTV();
              dialog=OFF;
							return false;  
						}
					} 
				});
      } 
    },
    state3:{
            title: 'Aguarde..',
            html: 'Demora alguns segundos!',
            buttons: {}
    },
  };

  $.prompt(statesdemo, {opacity:0});

  
}




/****************************************************************************/



function bt3Concluir(){
  dialog=ON;
  var servico,sData,nro_inc="";
	var conc_lista,i,x,y=0;
  //verificar se data de inicio de reparo foi preenchido
  if (sNroSel=="") {
    avisa_erro(('Selecione o ferramental para concluir o reparo!'));
    dialog=OFF;
    return false;
  }  
	var concluir=[
		{//0
      title:"Confirme!",
      html:"<label>Confirma a conclus&atilde;o da OMF para: ["+selec+"] ?</label>",
      buttons: { Cancela: 0, OK: 1 },
      focus: 1,
      submit:function(e,v,m,f){ 
        if (v==0){
            $.prompt.close();
            dialog=OFF;
            return false;          
        }
        e.preventDefault();
				//{verifica se existe data de inicio de reparo para concluir... 
				//se não.. pede preenchimento.
				var sqlb="select count(*) as nro from ferr_OMF where inc ='"+sNroSel+"' and dtinicio='0000-00-00 00:00:00'";
				$.prompt.goToState(2);
				$.ajax({
					type: "GET",
					async: false,
					url: WS50+"connections/my_tquery.php?sql="+sqlb,
					timeout: 2000,
					dataType: "text",
					success: function(data) {    
						if ((data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
							avisa_erro(('Atenção! Registro não encontrado!'));
							$.prompt.close();
              dialog=OFF;
							return false;
						}
						if (data=="0|&"){
							avisa_ok("Identifique-se!");
							$.prompt.goToState(1);               
						}
						if (data=="1|&"){
							avisa_erro(('Atenção! Precisa cadastrar inicio do reparo! Preencha!'));
							$.prompt.close();
              dialog=OFF;
							return false;							
						}							
					} 
				});
      }
    },    
		{//1
      title: "Supervisor:",
      html:"<label for='supname'>Digite a senha de supervisor</label><br/><label>Senha: <input type='password' name='supname' value=''></label><br/>",
      buttons: { Ok:true},
      focus: "input[name='supname']",
      submit:function(e,v,m,f) { 
        e.preventDefault();
        if (f.supname.length==0) {
          avisa_erro(("Atenção! Código inválido! Repita!")); 
          $.prompt.close();
          dialog=OFF;
          return false;
        }
        sql="select usuario,ChaveAcesso from usuarios where senha2='"+f.supname+"'";
        $.prompt.goToState(2);
        $.ajax({
          type: "GET",
          async: false,
          url: WS50+"connections/my_tquery.php?sql="+sql,
          timeout: 2000,
          dataType: "text",
          success: function(data){    
            if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
              avisa_erro(("Atenção! Código inválido! Repita!"));
              f.supname="";
              $.prompt.close();
              dialog=OFF;
              return false;
            }
            tab = data.split("&");
            for (lin=0; lin<tab.length; lin++) { 
              tab[lin] = tab[lin].split("|");
            }
            //avisa_ok("Supervisor: "+tab[0][0]);     /////////////////////////////////
            Supervisor=tab[0][0];
            sChaveAcesso=tab[0][1];
            lst=0;
            i=0;
            $.prompt.goToState(3);
          }
        });
      }
    },
          
    { //2
      title: "Aguarde...",
      html: "Processando...",
      buttons: {},
    },

    { //3
      title: "Responda ao CheckList!",
      html: "<div id='clist'><br><label id='parte'></label><br><label id='exec'></label></div>",
      buttons: { Nao: 0, Sim: 1 },
      focus: 1,
      submit: function(e,v,m,f) { 
        e.preventDefault();
        if (v==0) {
          avisa_erro(("Proceda a execução dos serviços!"));
          $.prompt.close();
          dialog=OFF;
          return false;          
        }
        if (v==1) {
          i++;
          if ( vclist[i][0] === undefined ) {
            servico="";
            $.prompt.goToState(4);
            dialog=OFF;
            return false;           
            
          }else{
            var parte = "Na Parte: "+vclist[i][0]+"!";
            var exec = "Foi verificado: <br><b>"+vclist[i][1]+"?</b>";
            promptobjc.find("#parte").html(parte);
            promptobjc.find("#exec").html(exec);
            $.prompt.goToState(3);
          }
        }
      }
    },

    { //4 definicao dos servicos executados
      title: "Defina os servi&ccedil;os realizados!",
      html: "<div id='dsexec'></div><br><label for='sexec' >Servi&ccedil;os</label>"+
      "<p id='escolha'></p><select name='sexec' id='sexec'></select>",
      buttons: { Cancela: 0, OK: 1, Concluir: 2 },
      focus: "select[name='sexec']",
      submit: function(e,v,m,f) { 
        e.preventDefault();
        if (v==0) {
          $.prompt.close();
          dialog=OFF;
          return false;          
        }
        
        if(v==1) {
          if (servico=="") { i=0; } else { i++; } 
          var serv="Escolhido: "+f.sexec;
          promptobjc.find("#escolha").html(serv);
          //alert(serv);
          if ( i==0 ){
            $.prompt.goToState(4);
            var sqlg= "insert into ferr_OMF_serv (inc_ferr, cod_servico) values ('"+sNroSel+"', '"+f.sexec+"')";
            $.ajax({
              type: "GET",
              async: false,
              url: WS50+"connections/my_exec.php?sql="+sqlg,
              timeout: 2000,
              dataType: "text",
              success: function(data) {    
                if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                  avisa_erro(("Atenção! Erro na gravação do servico! Repita!"));
                  $.prompt.close();
                  dialog=OFF;
                  return false;
                }
                $.prompt.goToState(4);
              }
            });            
                      
          }
          //$.prompt.goToState(5);
        }
        if (v==2){ //na conclusao o que que faz???? apenas sai!!!
          
          var sqlh= "update ferr_OMF set dtTermino=now(), "+
                    "indice=if(date(now())>date(dtPrevista),0,100) "+
                    "where inc='"+sNroSel+"'";
          $.ajax({
            type: "GET",
            async: false,
            url: WS50+"connections/my_exec.php?sql="+sqlh,
            timeout: 2000,
            dataType: "text",
            success: function(data) {    
              if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                avisa_erro(("Atenção! Erro ao gravar final da OMF! Repita!"));
                $.prompt.close();
                dialog=OFF;
                return false;
              }
              montaTV();
              $.prompt.close();
            }
          });         
        }
      }    
    },
	];
  
	if (sNroSel===undefined) {
    avisa_erro(('Selecione o ferramental para conclusão dos serviços!'));
    dialog=OFF;
    return false;
  }
	if (sNroSel=="") {
    avisa_erro(('Selecione o ferramental para conclusão dos serviços!'));
    dialog=OFF;
    return false;
  }
  
  var promptobjc = $.prompt(concluir, {opacity:0});
  
  $.prompt.goToState(0);	
	//carregar a lista do check list
  var sqle = "select partes, descricao from ferr_check order by inc"; 
  $.ajax({
    type: "GET",
    async: false,
    url: WS50+"connections/my_tquery.php?sql="+sqle,
    timeout: 2000,
    dataType: "text",
    success: function(data) {    
      if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
        avisa_erro (("Atenção! Erro ao obter checklist! Repita!"));
        $.prompt.close();
        dialog=OFF;
        return false;
      }
      //data = (data);
      vclist = data.split("&");
      for (lin=0; lin<vclist.length-1; lin++) { 
        vclist[lin] = vclist[lin].split("|");
      }
           var parte = "Na Parte: "+vclist[0][0]+"!";
            var exec = "Foi verificado: <br><b>"+vclist[0][1]+"?</b>";
            promptobjc.find("#parte").html(parte);
            promptobjc.find("#exec").html(exec);
      // Move from the WaitState to the form state
    }
  });
  //exibir a lista de serviços executados 
  var sqlf="select cod_servico, servico from ferr_servicos order by cod_servico";  
  $.ajax({
    type: "GET",
    async: false,
    url: WS50+"connections/my_tquery.php?sql="+sqlf,
    timeout: 2000,
    dataType: "text",
    success: function(data) {    
      if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
        avisa_erro(("Atenção! Erro ao obter serviços! Repita!"));
        $.prompt.close();
        dialog=OFF;
        return false;
      }
      //data = (data);
      tab = data.split("&");
      var tabela_serv = ""; //"<option value='0'>0 - FECHAR</option>";
      for (lin=0; lin<tab.length-1; lin++) { 
        tab[lin] = tab[lin].split("|");
        var codserv = tab[lin][0];
        var descserv = tab[lin][1];
        tabela_serv += "<option value='"+codserv+"'>"+codserv+" - "+descserv+"</option>";
      }
      // populate the dropdown options
      promptobjc.find("#sexec").html(tabela_serv);
      // Move from the WaitState to the form state
    }
  }); 
}

$(document).ready(function(){
	
  i$('ip').innerHTML = httpGet("/cgi-bin/ip.cgi");
	//alert(">"+i$('ip').innerHTML+"<");
	montaTV();
	
  $(document).keyup(function(ev) {
    //window.alert("O código da tecla pressionada foi: " + KeyID);
    if(dialog==OFF) {
      ev.preventDefault();
      
      if ( (ev.keyCode==100) || (ev.keyCode==52) ) {   // 4
        dialog=ON;        
        history.back();//$("#bt4").click();
      }
      
      if ( (ev.keyCode==99) || (ev.keyCode==51) ) {  // 3
        dialog=ON;
        bt3Concluir();
        
      }
      
      if ( (ev.keyCode==98) || (ev.keyCode==50) ) {  // 2
        dialog=ON;
        bt2IniciarReparo();
        
      }    
      
      if ( (ev.keyCode==97) || (ev.keyCode==49) ) {  // 1
        dialog=ON;
        bt1Gerar();
            
      } 
    }
    
  });
  

});  
  