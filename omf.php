<?
  // MONTAR TELA IGUAL A DO CTMED PRINCIPAL.PAS
  header ('Content-type: text/html; charset=UTF-8');
  //header ('Content-type: text/html; charset=ISO-8859-1');
?>
<!DOCTYPE html>
<html>
  <head>
    <title>O.Man.Ferramental</title>
    <meta http-equiv="Content-Type" content="text/html" charset="UTF-8"/>
    <meta name="Author" content="Sergio Silvestre"/>
    <meta http-Equiv="Cache-Control" Content="no-cache">
    <meta http-Equiv="Pragma" Content="no-cache">
    <meta http-Equiv="Expires" Content="0">
    
    <link rel="stylesheet" type="text/css" href="omf.css" />
    <link rel="stylesheet" media="all" type="text/css" href="jquery-impromptu.css" />
    
    <script type="text/javascript" src="../../js/jquery-1.8.3.min.js"></script>
    <script type="text/javascript" src="jquery-impromptu.js"> </script>
    <script type="text/javascript" src="omf_a.js"></script>
  </head>

  <body>
    <div id="topoCB" >CB Industrial</div>  <!-- <p id='txtcb'> -->
    <div id="pnBotoes"> 
      <a id="bt1" class="bt-02" alt="Gera OMFerramental" onclick="bt1Gerar();" >1 - Gerar OMF</a>
      <a id="bt2" class="bt-02" alt="Iniciar Reparo" onclick="bt2IniciarReparo();">2 - Iniciar Reparo</a> 
      <a id="bt3" class="bt-02" alt="Concluir" onclick="bt3Concluir();">3 - Concluir</a>
      <a id="bt4" class="bt-02" alt="Fechar a tela e retornar" onclick="CloseThis();">4 - Sair</a>
    </div>
    <div id="jQ-menu" ></div> 
    <div id="statusBar" ></div>
    <p id="ip"><?echo $_SERVER['REMOTE_ADDR'];?></p>
  </body>
  
</html>  




