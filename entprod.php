<?
  $linkFoto="";
?>
<!DOCTYPE html>
<html>
  <head>
    <title>Entradas no Estoque</title>
    <meta name="Author" content="Sergio Silvestre"/>
    <meta http-Equiv="Cache-Control" Content="no-cache">
    <meta http-Equiv="Pragma" Content="no-cache">
    <!-- <meta http-Equiv="Expires" Content="0"> -->
    <script src="../../js/jquery-1.8.3.min.js"></script>
    <link rel="stylesheet" type="text/css" href="entprod.css" />
    <script src="entprod.js"></script>
    <!--
      <link rel="stylesheet" media="all" type="text/css" href="jquery-impromptu.css" />
      <script src="jquery-impromptu.js"> </script>
      <script src="plusastab.js"> </script>
      <script src="emulatab.js"> </script>
    -->
  </head>
  <body> 
    <div id="topoCB" >CB Industrial</div>  
    <div id="btBack" class="bt" ><a>Voltar</a></div>
    
    <div id="boxDados">
      <table>
        <tbody>
          <tr>
						<td>
							<label class="lb" id="lbc1" >Ordem de Produção:</label>
							<input id="c1" class="in" type="text" tabindex="1" name="c1" size="6" value="" pattern="[0-9]{6}" title="Digite o numero da OP." required/>
							<br><p class="tb1" id="lb1"></p>
							<br><p class="tb1" id="lb2"></p>
							<br><p class="tb1" id="lbEst"></p>              
							<br><p class="tb1" id="lbLote"></p>
							<br><p class="tb1" id="lbScrap"></p>            
						</td>
						<td></td>
          </tr>
          <tr>
            <td>
							<label class="lb" id="lbc2" for="c2">Quantidade:</label>
							<input id="c2" class="in" type="text" tabindex="2" name="c2" size="6" value="" title="Digite a quantidade." />
							<!--
								<p align="left">Scrap: <input id="scrap" type="text" name="scrap" size="4" value="" tabindex="7" title="Digite a quantidade de scrap."/></p>					
								<p align="left">Localização: <input id="local" type="text" name="local" size="4" value="AA" tabindex="8" title="Digite a localização do produto."/></p>					
								<p align="left">Embalagens: 
									<select size="1" name="D1" id="D1"> 
										
										<option id="options" selected value="">Selecione!</option>
										
	//                     include '../connections/conn_mysql.php';
	//                     $sql = "select dsc_res from embalagem order by dsc_res";
	//                     $dbresult = mysql_query($sql) or die("X");
	//                     while($dados=mysql_fetch_array($dbresult)) {
	//                       echo ("<option value='".$dados['dsc_res']."'>".$dados['dsc_res']."</option>");
	//                     }
	//                     mysql_close($conmy);
										
									</select>
								</p>				
								<form id="form" action="">
									<p align="left">Quantidade:<input type="text" name="qtd" id="qtd" size="4" value="" />
										<button type="button" id="bt1"  title="Acione para registrar no servidor." >Salvar</button></p><br>
										<button type="button" id="bt2"  title="Acione para imprimir etiquetas." >Etiquetas</button></p><br>
								</form>
								<br/>
              -->
            </td>
            
            <td>					
              <img  id="foto" name="foto" src="inexistente.jpg"/>
            </td>

            
          </tr>
        </tbody>
      </table>
    </div>
    
    <div id="statusBar" class="statusBar"></div>	
    <iframe src="../cgi-bin/escuta.cgi" width="200" height="200"></iframe>
    <p id="ip"><?echo $_SERVER['REMOTE_ADDR'];?></p>
    <script src="entprod.js"></script>
  </body>
</html>