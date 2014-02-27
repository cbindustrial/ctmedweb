<!DOCTYPE HTML>
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <title>Expedição</title>
	<link rel="stylesheet" type="text/css" href="../css/pagina_cb.css">
	<link rel="stylesheet" type="text/css" href="../css/menu8.css">

<style>


</style>
</head>

<body>
<div id="cabecalho" class="cabecalho">CB Industrial</div>
 <div id="status" class="status"><?php $_SESSION['ndir'] = "../"; include("../proteger.php"); seguranca(); ?></div> 
<!-- inicio do box com menu -->

<div id="menu8"><div class="Box"><b class="b1"></b><b class="b2"></b><b class="b3"></b><b class="b4"></b>
<div class="conteudo">
					<ul>
						<li><a href="entprod.php" title="Entradas" target="cad">Entradas no Estoque</a></li>
						<li><a href="CEP.php" title="Controle Estatistico do Processo" target="cad">C.E.P.</a></li>
						<li><a href="about:blank"title="Gestão dos Controles de Medidas" target="cad" name="16">Gestor de Medidas</a></li>
						<li><a href="about:blank" title="Controle de Medidas" target="cad">Controle Medidas</a></li>
						<li><a href="../ctmed/index.php" title="Fotos para os Controles de Medidas" target="cad">Fotos Controle</a></li>
						<li><a href="indicadores.php" title="Indicadores" target="cad">Indicadores</a></li>
				
					</ul>
</div><b class="b4"></b><b class="b3"></b><b class="b2"></b><b class="b1"></b></div></div>
<!-- fim do box com menu-->
<iframe class="xframe" NAME="cad" ></iframe>
 <div id="statusBar" class="statusBar"></div> 
</body>
</html>