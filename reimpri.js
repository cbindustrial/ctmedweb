/*
* 
* QUALQUER UM PODE EXECUTAR O PROGRAMA E VISUALIZAR AS OSM EXISTENTES EM ABERTO.
* QUALQUER UM PODE FINALIZAR O PROGRAMA.
* Botoes GERAR, INICIAR E CONCLUIR OSMS INICIAM COM A IDENTIFICAÇÃO DO USUARIO ou
* Supervisor no caso de GERAR e CONCLUIR.
* INICIAR pede o cracha para identificar o mecanico que vai fazer o servico
* **********************************************************************************
* global variables
*
*/

const ON = 1;
const OFF = 0;
const SIM = 1;
const NAO = 0;
var sCodCB,sDescMaq,uri,sql,sChaveAcesso,sInc,sNro,sNro2,sNroSel,clist="";
var sItem,sCritico, sDtinicio,sDtReparo,sDescricao,sExecutor="";
var sSolicitante,sUsuario,texto,sData,selec,sIdreg="";
var executor,problema,resp,escolha,Supervisor,sDtPrevista,htmlTV="";
var i,nro,idx,nlin,rede,lst,totvclist=0;
var tabela_equipos="";
var ferramenta,lista,pesquisa,cpo,vclist,vserv = new Array();
var tab = new Array([],[]);
var lin, col,maq = 0;
var escSN = 0; /*escolha sim nao*/
var dialog = OFF;
    
function avisa_ok(txt) {
  $( "#statusBar" ).css( {"background":"yellow","color":"navy"} ).html( txt );
}

function avisa_erro(txt) {
  $( "#statusBar" ).css( {"background":"red","color":"white"} ).html( txt );
  setTimeout(function() {
    avisa_ok('Selecione uma op&ccedil;&atilde;o!');
  }, 2000);
}
  
function msg_status(txt) {
  $( "#statusBar" ).html(txt).css( {"background":"navy","color":"yellow"} );
  return false;
}

function servidorOnline() {
  $.ajax( {
    type:"GET",
    async:false,
    url:"../connections/ativo.php",
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
      if( (document.getElementById('ip').innerHTML=='10.0.0.14') || (document.getElementById('ip').innerHTML=='10.0.0.2') ){ 
        location.href='ctmed.php';
      } else {
        var win = window.open('', '_self'); 
        window.close(); 
        win.close(); 
        return false; 
      }
    }

function montaTV() {
  //alert ("chegou");
  pesquisa=[];
  cpo=[];
  tab=[];
  servidorOnline();
  if ( rede==OFF ) { 
    avisa_erro("Problema de conex&atilde;o... aguarde 30 segs.!! Se persistir o problema Chame TI!");
    setTimeout(function(){},3000);
    return 0;
  }
  //alert(rede);
  sql="select t1.inc,t1.critico,t1.codmaqcb,t1.descricao,"+
      "t1.dt_solicitacao,t1.dt_inicio_reparo,t1.dt_prevista_termino,"+
      "t1.executor,t1.solicitante,t4.desc_defeitos"+
      " from mnt_015 as t1, mnt_020 as t3, mnt_040 as t4 "+
      "where t1.inc=t3.inc_015 and t3.inc_040=t4.cod and t1.finalizado=0 "+
      "order by t1.critico, t1.inc";
    
  $.ajax( {
    type:"GET",
    url:"../connections/my_tquery.php?sql="+sql,
    timeout:2000,
    contentType: "charset=ISO-8859-1",
    dataType:"text",
    success:function(data) {
      //data = utf8_decode(data);
      //alert(data);
      tab = data.split("&");
      nlin = tab.length;
      //alert(nlin);
			for (i=0;i<nlin;i++) { 
        tab[i] = tab[i].split("|");
      }
      sNro = "";
      sNro2 = "";
      htmlTV = "<table id='grade' class='sortable'>";
      htmlTV = htmlTV + "<thead id='cabec'><tr><td class='c1'>NRO</td><td class='c2'>CR</td><td class='c3'>CODIGO</td><td class='c4'>EQUIPAMENTO</td>"+
        "<td class='c5'>DT SOLICITA&Ccedil;&Atilde;O</td><td class='c6'>DT INICIO REP</td>"+
        "<td class='c7'>PREV TERMINO</td><td class='c8'>EXECUTOR</td><td class='c9'>SOLICITANTE</td></tr></thead><tbody>";
     
      lin = 0;
      col = 0;
      while(lin<nlin-1) {
        sNro = tab[lin][0];
        //alert(sNro);
				sCritico = tab[lin][1];
        sItem = tab[lin][2]
        if (sNro == sNro2) {
				 // alert(nlin+" -"+sNro);
          sDescricao = tab[lin][9];
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
        sDtPrevista=tab[lin][6];
        sDtPrevista=sDtPrevista.substr(8,2)+"/"+sDtPrevista.substr(5,2)+"/"+
            sDtPrevista.substr(0,4) + " "+sDtPrevista.substr(10,9);
        sExecutor=tab[lin][7];
        sSolicitante=tab[lin][8];
        sDescricao=tab[lin][9];
        htmlTV=htmlTV+"<tr><td class='c1'><pre class='reg' >"+sNro+"</pre></td><td class='c2'>"+
				sCritico+"</td><td class='c3'>"+
          sItem+"</td><td class='c4'>"+tab[lin][3]+"</td><td class='c5'>"+sDtinicio+"</td><td class='c6'>"+
          sDtReparo+"</td><td class='c7'>"+sDtPrevista+"</td><td class='c8'>"+utf8_decode(sExecutor)+
          "</td><td class='c9'>"+utf8_decode(sSolicitante)+"</td></tr>";
        htmlTV=htmlTV+"<tr><td colspan=9><p class='desc'>"+sDescricao+"</p></td></tr>";
        lin++;
      }
      htmlTV=htmlTV+"</tbody></table><script>$('pre').click(function(ev){ev.preventDefault();"+
                    "sNroSel=$(this).text();selec=$(this).closest('td').next().next().text();"+
                    "$('pre').css('color','navy');$(this).css('color','red'); return false; });</script>";
      //alert(htmlTV);
      $("#jQ-menu").html(htmlTV);
      $(".c1").css("width","40px");
			$(".c2").css("width","20px");
      $(".c3").css("width","100px");
      $(".c4").css("width","250px");
      $(".c4,.c5,.c6,.c7").css("text-align","left");
      $(".c5,.c6,.c7").css("width","165px");
      $(".c8,.c9").css("width","180px");
      $(".desc").css({"text-align":"left","margin-right":"5px","margin-left":"50px","color":"#ffe4c4" });
      msg_status("Selecione uma Op&ccedil;&atilde;o!");
    }
  });
  return false;
}

function bt1Gerar() {
  var i, pergunta = 0;
  var critico = "";
  servidorOnline();
  if (rede==OFF){
    avisa_erro("Problema de conex&atilde;o... aguarde 30 segs.!! Se persistir o problema Chame TI!");
    setTimeout(function(){},3000);
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
          avisa_erro("Aten&ccedil;&atilde;o! Código do crachá inválido! Repita!"); 
          $.prompt.close();
          return false;
        }
        sql="select usuario,ChaveAcesso from usuarios where senha2='"+f.supname+"'";
        $.prompt.goToState(0);
        $.ajax({
          type: "GET",
          async: false,
          url: "../connections/my_tquery.php?sql="+sql,
          timeout: 2000,
          dataType: "text",
          success: function(data){    
            if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
              avisa_erro("Aten&ccedil;&atilde;o! Código inválido! Repita!");
              f.supname="";
              $.prompt.close();
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
      title:"Escolha o Equipamento!",
      html: "<label for='makeferr'>Equipamentos</label><select name='Ferramentais' id='makeferr'></select>",
      buttons: { Cancela: 0, OK: 1 },
      focus: 1,
      submit:function(e,v,m,f){ 
        e.preventDefault();
        if (v==0){
          $.prompt.close();
          return false;          
        }
        if(v==1){
          equipamento=f.Ferramentais;
          alert(f.Ferramentais);
          avisa_ok("equipamento: "+f.Ferramentais);   ///////////////////////////////////////
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
          return false;          
        }
        if(v==1){
          if ((f.critname < 1) || (f.critname > 5)){
            avisa_erro("A criticidade deve estar entre 1 e 5");
            $.prompt.close();
            return false;           
          }
          criticidade=f.critname;
          //avisa_ok("criticidade: "+f.critname);
          avisa_ok("Defina os problemas existentes no equipamento!");
          problema="";
          $.prompt.goToState(4);
        }
      } 
    },
    
    { //4 problemas
      title:"Defina os problemas!",
      html: "<div id='prb'></div><br><label for='makeprob'>Problemas</label><select name='problemas' id='makeprob'></select>",
      buttons: { OK: 1, Concluir: 2 },
      focus: 1,
      submit:function(e,v,m,f){ 
        e.preventDefault();
        if(v==1){
          if(problema==""){i=0;}else{i++;} 
          avisa_ok("problema: "+f.problemas);
          problema=f.problemas;
          promptobj.find("#prb").html("Escolhido: "+problema);
          
          if (i==0){
            //{primeiro defeito: verifica existência de equipo em aberto}
             
            var sqla="select count(*) as nro from mnt_015 where dt_termino_reparo='0000-00-00 00:00:00'"+
                      " and codmaqcb='"+equipamento+"'";
            $.ajax({
              type: "GET",
              async: false,
              url: "../connections/my_tquery.php?sql="+sqla,
              timeout: 2000,
              dataType: "text",
              success: function(data) {    
                if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                  avisa_erro("Aten&ccedil;&atilde;o! Erro na Consulta de OMFs! Repita!");
                  $.prompt.close();
                  return false;
                }
                tab = data.split("&");
                for (lin=0; lin<tab.length-1; lin++) { 
                  tab[lin] = tab[lin].split("|");
                }
                if (tab[0][0]=="1"){
                  avisa_erro("Aten&ccedil;&atilde;o! Este equipamento já contém OMF em aberto! Pesquise!");
                  $.prompt.close();
                  return false;                  
                }  
                if (tab[0][0]=="0") {
                  var sqlb="insert into mnt_015 (descricao,codmaqcb, critico, dt_solicitacao,dt_prevista_termino,solicitante)"+
                  "values ((select descres from mnt_equipamento where codequipo='"+equipamento+"' limit 1) ,'"+equipamento+"','"+criticidade+"', now(), timestampadd(day,3,now()), '"+Supervisor+"')";                  
                  alert(sqlb);
                  $.ajax({
                    type: "GET",
                    async: false,
                    url: "../connections/my_exec.php?sql="+sqlb,
                    timeout: 2000,
                    dataType: "text",
                    success: function(data) {    
                      if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                        avisa_erro("Aten&ccedil;&atilde;o! Erro na grava&ccedil;&atilde;o da OMF! Repita!");
                        $.prompt.close();
                        return false;
                      }
                      var sqlc="insert into mnt_020 (inc_015, inc_040) values ((select inc from mnt_015 order by inc desc limit 1),'"+problema+"')";                  
                      //alert(sql);
                      $.ajax({
                        type: "GET",
                        async: false,
                        url: "../connections/my_exec.php?sql="+sqlc,
                        timeout: 2000,
                        dataType: "text",
                        success: function(data) {    
                          if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                            avisa_erro("Aten&ccedil;&atilde;o! Erro na grava&ccedil;&atilde;o do problema da OMF! Repita!");
                            $.prompt.close();
                            return false;
                          }
                        }
                      });                      
                    }
                  });                 
                  
                }
                $.prompt.goToState(4);
              }
            });           
          }
          
          if (i>1){
            //se mais de um problema, nos demais grava so os problemas
            var sqld="insert into mnt_020 (inc_015, inc_040) values ((select inc from mnt_015 order by inc desc limit 1),'"+problema+"')";
            $.ajax({
              type: "GET",
              async: false,
              url: "../connections/my_exec.php?sql="+sqld,
              timeout: 2000,
              dataType: "text",
              success: function(data) {    
                if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                  avisa_erro("Aten&ccedil;&atilde;o! Erro na grava&ccedil;&atilde;o do problema da OMF! Repita!");
                  $.prompt.close();
                  return false;
                }
                $.prompt.goToState(4);//coleta senha supervisor       
              }
            });
            
            
          }
          //$.prompt.goToState(5);
        }
        
        if (v==2){
          montaTV();
          $.prompt.close();
          return false;          
        }
      }    
    },

  ];
  
  var promptobj = $.prompt(gerasuper);
/***********************************************************************************************************************/  
  $.prompt.goToState(0);
  //carrega tabela de equipamentos
  var sqle="select codequipo,SUBSTRING(descres,1,30) from mnt_equipamento where not isnull(descres) order by descres";
  $.ajax({
    type: "GET",
    async: false,
    url: "../connections/my_tquery.php?sql="+sqle,
    timeout: 2000,
    dataType: "text",
    success: function(data) {    
      if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
        avisa_erro("Aten&ccedil;&atilde;o! Erro na Consulta em itens ! Repita!");
        $.prompt.close();
        return false;
      }
      //data = utf8_decode(data);
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
  var sqlf = "select cod, desc_defeitos from mnt_040 order by cod";  
  $.ajax({
    type: "GET",
    async: false,
    url: "../connections/my_tquery.php?sql="+sqlf,
    timeout: 2000,
    dataType: "text",
    success: function(data) {    
      if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
        avisa_erro("Aten&ccedil;&atilde;o! Erro na Consulta de problemas! Repita!");
        $.prompt.close();
        return false;
      }
      //data = utf8_decode(data);
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
  if (sNroSel=="") {
    avisa_erro('Selecione o equipamento para início de reparo!');
    return false;
  }
 // msg_status(sNroSel);
  sUsuario = "";
  var statesdemo = {
    state0: {
      title: 'Crachá:',
      html:'<label>Senha: <input type="password" name="fname" value=""></label><br />',
      buttons: { Ok:true},
      focus: "input[name='fname']",
      submit:function(e,v,m,f) { 
        e.preventDefault();
        //console.log(f);
        //******em teste
        if (f.fname.length != 4) {
          avisa_erro('Aten&ccedil;&atilde;o! Código do crachá inválido! Repita!'); 
          $.prompt.close();
          return false;
        }
        var sqla = "select nomecracha from cracha where nrocracha='"+f.fname+"'";
        //alert(sql);
        $.prompt.goToState('state3');
        $.ajax({
          type: "GET",
          async: false,
          url: "../connections/my_tquery.php?sql="+sqla,
          timeout: 2000,
          dataType: "text",
          success: function(data) {    
            if ((data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
              f.fname="";
              avisa_erro('Aten&ccedil;&atilde;o! Código do crachá inválido! Repita!');
              $.prompt.close();
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
				var sqlb="select count(*) as nro from mnt_015 where inc ='"+sNroSel+"' and dt_inicio_reparo='0000-00-00 00:00:00'";
				$.prompt.goToState('state3');
				$.ajax({
					type: "GET",
					async: false,
					url: "../connections/my_tquery.php?sql="+sqlb,
					timeout: 2000,
					dataType: "text",
					success: function(data) {    
						if ((data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
							avisa_erro('Aten&ccedil;&atilde;o! Registro não encontrado!');
							$.prompt.close();
							return false;
						}
						if (data=="0|&"){
							$.prompt.goToState('state2');               
						}
						if (data=="1|&"){
							var sqlc="update mnt_015 set executor='"+sUsuario+"', dt_inicio_reparo = now() where inc='"+sNroSel+"'";     
              $.prompt.goToState('state3'); 
							$.ajax({
								type: "GET",
								async: false,
								url: "../connections/my_exec.php?sql="+sqlc,
								timeout: 2000,
								dataType: "text",
								success: function(data) {    
									if ((data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
										avisa_erro('Aten&ccedil;&atilde;o! Erro ao gravar data!');
										$.prompt.close();
										return false;
									}
									if (data=="Y"){
										$.prompt.close();
										montaTV();
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
      html:"<label> Existe inicio registrado! Confirma altera&ccedil;&atilde;o da data?</label>",
      buttons: { Cancela: 0, OK: 1 },
      focus: 1,
      submit:function(e,v,m,f){
        var sqld="update mnt_015 set executor='"+sUsuario+"', dt_inicio_reparo = now() where inc='"+sNroSel+"'";     
        $.prompt.goToState('state3');
				$.ajax({
					type: "GET",
					async: false,
					url: "../connections/my_exec.php?sql="+sqld,
					timeout: 2000,
					dataType: "text",
					success: function(data) {    
						if ((data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
							avisa_erro('Aten&ccedil;&atilde;o! Erro ao gravar data!');
							$.prompt.close();
							return false;
						}
						if (data=="Y"){
							$.prompt.close();
							montaTV();
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
  var servico,sData,nro_inc="";
	var conc_lista,i,x,y=0;
  //verificar se data de inicio de reparo foi preenchido
	var concluir=[
		{//0
      title:"Confirme!",
      html:"<label>Confirma a conclusão da OSM para: ["+selec+"] ?</label>",
      buttons: { Cancela: 0, OK: 1 },
      focus: 1,
      submit:function(e,v,m,f){ 
        if (v==0){
            $.prompt.close();
            return false;          
        }
        e.preventDefault();
				//{verifica se existe data de inicio de reparo para concluir... 
				//se não.. pede preenchimento.
				var sqlb = "select count(*) as nro from mnt_015 where inc ='"+sNroSel+"' and dt_inicio_reparo='0000-00-00 00:00:00'";
				$.prompt.goToState(2);
				$.ajax({
					type: "GET",
					async: false,
					url: "../connections/my_tquery.php?sql="+sqlb,
					timeout: 2000,
					dataType: "text",
					success: function(data) {    
						if ((data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
							avisa_erro('Aten&ccedil;&atilde;o! Registro não encontrado!');
							$.prompt.close();
							return false;
						}
						if (data=="0|&"){
							avisa_ok("Identifique-se!");
							$.prompt.goToState(1);               
						}
						if (data=="1|&"){
							avisa_erro('Aten&ccedil;&atilde;o! Precisa cadastrar inicio do reparo! Preencha!');
							$.prompt.close();
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
          avisa_erro("Aten&ccedil;&atilde;o! Código inválido! Repita!"); 
          $.prompt.close();
          return false;
        }
        sql="select usuario,ChaveAcesso from usuarios where senha2='"+f.supname+"'";
        $.prompt.goToState(2);
        $.ajax({
          type: "GET",
          async: false,
          url: "../connections/my_tquery.php?sql="+sql,
          timeout: 2000,
          dataType: "text",
          success: function(data){    
            if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
              avisa_erro("Aten&ccedil;&atilde;o! Código inválido! Repita!");
              f.supname="";
              $.prompt.close();
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
            $.prompt.goToState(4);
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
          avisa_erro("Proceda a execu&ccedil;&atilde;o dos serviços!");
          $.prompt.close();
          return false;          
        }
        if (v==1) {
          i++;
          if ( vclist[i][0] === undefined ) {
            servico="";
            $.prompt.goToState(4);
            return false;           
            
          }else{
            
            var exec = "Foi verificado: <br><b>"+vclist[i][0]+"?</b>";
           
            promptobjc.find("#exec").html(exec);
            $.prompt.goToState(3);
          }
        }
      }
      
    },

    { //4 definicao dos servicos executados
    
      title: "Defina os serviços realizados!",
      html: "<div id='dsexec'></div><br><label for='sexec' >Serviços</label>"+
      "<p id='escolha'></p><select name='sexec' id='sexec'></select>",
      buttons: { Cancela: 0, OK: 1, Concluir: 2 },
      focus: "select[name='sexec']",
      submit: function(e,v,m,f) { 
        e.preventDefault();
        if (v==0) {
          $.prompt.close();
          return false;          
        }
        
        if(v==1) {
          if (servico=="") { i=0; } else { i++; } 
          var serv="Escolhido: "+f.sexec;
          promptobjc.find("#escolha").html(serv);
          //alert(serv);
          if ( i==0 ){
            $.prompt.goToState(4);
            var sqlg= "insert into mnt_025 (inc_015, inc_030) values ('"+sNroSel+"', '"+f.sexec+"')";
            $.ajax({
              type: "GET",
              async: false,
              url: "../connections/my_exec.php?sql="+sqlg,
              timeout: 2000,
              dataType: "text",
              success: function(data) {    
                if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                  avisa_erro("Atenção! Erro na gravação do servico! Repita!");
                  $.prompt.close();
                  return false;
                }
                $.prompt.goToState(4);
              }
            });            
                      
          }
          //$.prompt.goToState(5);
        }
        if (v==2){ //na conclusao o que que faz???? apenas sai!!!

          var sqlh = " update mnt_015 set dt_termino_reparo=now(), finalizado=1, "+
          " tp_total_parado = time_to_sec(if(datediff(date(now()),dt_solicitacao)>30,'720:00:00',"+
          " timediff(now(), dt_solicitacao))), tp_total_reparo=time_to_sec("+
          " if(datediff(now(),dt_inicio_reparo)>30,'99:00:00',timediff(now(), "+
          "dt_inicio_reparo))), indice=if(date(now())>date(dt_prevista_termino),0,100) "+
          " where inc='"+sNroSel+"'";
          
          $.ajax({
            type: "GET",
            async: false,
            url: "../connections/my_exec.php?sql="+sqlh,
            timeout: 2000,
            dataType: "text",
            success: function(data) {    
              if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
                avisa_erro("Atenção! Erro ao gravar final da OSM! Repita!");
                $.prompt.close();
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
    avisa_erro('Selecione o equipamento para conclusão dos serviços!');
    return false;
  }
  
	if (sNroSel=="") {
    avisa_erro('Selecione o equipamento para conclusão dos serviços!');
    return false;
  }
  
  var promptobjc = $.prompt(concluir, {opacity:0});
  
  $.prompt.goToState(0);	
	//carregar a lista do check list
  var sqle = "select pergunta from mnt_050 order by inc"; 
  $.ajax({
    type: "GET",
    async: false,
    url: "../connections/my_tquery.php?sql="+sqle,
    timeout: 2000,
    dataType: "text",
    success: function(data) {    
      if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
        avisa_erro ( "Atenção! Erro ao obter checklist! Repita!" );
        $.prompt.close();
        return false;
      }
      //data = utf8_decode(data);
      vclist = data.split("&");
      for (lin=0; lin<vclist.length-1; lin++) { 
        vclist[lin] = vclist[lin].split("|");
      }
           
            var exec = "Foi verificado: <br><b>"+vclist[0][0]+"?</b>";
            
            promptobjc.find("#exec").html(exec);
      // Move from the WaitState to the form state
      
    }
  });
  
  //exibir a lista de serviços executados 
  var sqlf="select cod, desc_servicos from mnt_030 order by cod";  
  $.ajax({
    type: "GET",
    async: false,
    url: "../connections/my_tquery.php?sql="+sqlf,
    timeout: 2000,
    dataType: "text",
    success: function(data) {    
      if ( (data=="X|&") || (data=="X") || (data=="") || (data=="|&")) { 
        avisa_erro("Atenção! Erro ao obter serviços! Repita!");
        $.prompt.close();
        return false;
      }
      //data = utf8_decode(data);
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
  dialog=OFF;  
  montaTV();
	
  // $(document).keyup(function(ev) {
    //window.alert("O código da tecla pressionada foi: " + KeyID);
    // if(dialog==OFF) {
      // ev.preventDefault();
      // if ( (ev.keyCode==100) || (ev.keyCode==52) ) {   // 4
        // history.back();//$("#bt4").click();
      // }
      // if ( (ev.keyCode==99) || (ev.keyCode==51) ) {  // 3
        // $("#bt3").click();
      // }
      // if ( (ev.keyCode==98) || (ev.keyCode==50) ) {  // 2
        // $("#bt2").click();
      // }    
      // if ( (ev.keyCode==97) || (ev.keyCode==49) ) {  // 1
        // $("#bt1").click();     
      // } 
    // }
  // });
  
  $("#bt1").click(function(ev){
    ev.preventDefault();
    dialog=ON;
    bt1Gerar();
    dialog=OFF;
  });
  
  $("#bt2").click(function(ev){
    ev.preventDefault();
    dialog=ON;
    bt2IniciarReparo();
    dialog=OFF;
  });
  
  $("#bt3").click(function(ev){
    ev.preventDefault();
    dialog=ON;
    bt3Concluir();
    dialog=OFF;
  });	
	
}); 





/***

procedure TF_OSM.btGerar2Click(Sender: TObject);
  if not identifica() then begin avisa_erro('Erro na identificação do Usuário!'); montaTV; exit; end;
  if not escolhe_equipo() then begin avisa_erro('Erro na escolha do equipamento!'); montaTV; exit; end;
  avisa_ok('Defina a criticidade 1=urgente ... 5=pode esperar!');
  critico:='';
  ok :=  inputquery('CRITICIDADE','Qual a criticidade de 1 a 5... 1 é bastante urgente!: ',critico);
  if (not ok) or (strtointdef(critico,0)=0) or (strtointdef(critico,0)>5) then begin
    avisa_erro('A criticidade deve estar entre 1 e 5');
    montaTV;
    exit;
  end;
  avisa_Ok('Defina os problemas... um a um! Tecle [Enter] para terminar!');
  {exibir a lista de problemas para coletar o motivo da abertura}
  sql:='select cod, desc_defeitos from mnt_040 order by cod';
  if not qrytab(sql) then begin
    avisa_erro('Erro ao consultar a lista de defeitos possíveis!');
    montaTV;
    exit;
  end;
  Pesquisa.Clear;
  for i:= 0 to tab.RowCount - 1 do {popular lista com a tabela }
    Pesquisa.Add(tab.Cells[1,i]+' - '+tab.Cells[2,i]);
  pergunta := 0;
  i := 0;
  repeat
    problema := inputbox('Defeito no equipamento.',
                'Qual ou onde foi constatado problema no equipamento?'+
                  #13+#13+Pesquisa.Text,'');
    i:=i+1;
    if (i=1) and (problema <> '') then begin
      {verifica existência de item e operação em aberto}
      {se sim informar para deletar se não ...}
      sql:= 'select count(*) from mnt_015 where codmaqprot='+
      Quotedstr(sCodProteus)+' and finalizado=0 and dt_termino_reparo='+quotedstr('0000-00-00 00:00:00');
      if not qrytab(sql) then begin
        Showmessage('Atenção! Houve erro na consulta de OSMs em aberto! Repita!');
        avisa_erro('Atenção! Houve erro na consulta de OSMs em aberto! Repita!');
        break;
      end;
      if ('1'=cpo[0]) then begin
        Showmessage('Atenção! Este equipamento já contém OSM em aberto! Pesquise!');
        avisa_erro('Atenção! Este equipamento já contém OSM em aberto! Pesquise!');
        break;
      end;
      if ('0'=cpo[0]) then begin
        sql:='insert into mnt_015 (critico,codmaqcb,dt_solicitacao,'+
             'solicitante,finalizado,codmaqprot,descricao,dt_prevista_termino) values ('+
             quotedstr(critico)+','+
             quotedstr(sCodCB)+', now(),'+
             quotedstr(Supervisor)+',0,'+
             quotedstr(sCodProteus)+','+
             quotedstr(sDescMaq)+', timestampadd(day,3,now()) ) ';
        if not qryexec(sql) then begin
          {se X houve erro caso contrario Pesquisa recebeu o nro do ID }
          showmessage('Atenção! Houve problemas para insersão da OSM! Repita!');
          break;
        end;
        {inserta os problemas para a ultima mnt_015 existente(em teoria é a que criamos)}
        sql:='insert into mnt_020 (inc_015,inc_040) values ((select inc from mnt_015 order by inc desc limit 1),'+
        quotedstr(problema)+')';
        if not qryexec(sql) then begin   {se X houve erro caso contrario Pesquisa recebeu o nro do ID }
          showmessage('Atenção! Houve problemas para insersão do problema da OSM! Repita!');
          break;
        end;
      end;
    end;
    if (i > 1) and (problema <> '') then begin
      {se mais de um problema, nos demais grava so os problemas}
        sql:='insert into mnt_020 (inc_015,inc_040) values ((select inc from mnt_015 order by inc desc limit 1),'+
        quotedstr(problema)+')';
        if not qryexec(sql) then begin   {se X houve erro caso contrario Pesquisa recebeu o nro do ID }
          showmessage('Atenção! Houve problemas para insersão do problema da OSM! Repita!');
          break;
        end;
    end;
  until problema = '';
  {bloquear ctmed e cdcf para não registrar se maquina ou ferramental em aberto}
  montaTV;
end;




 
 
 * *////
  