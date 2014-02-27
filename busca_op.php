<?php
$codprod=htmlspecialchars($_GET["codprod"]);
include '/var/www/connections/conn_mysql.php';
header('Content-Type: text/html; charset=iso-8859-1');
$dbresult=mysql_query("select item,descricao,round(estoque),lote,scrap,acabadas,tipoop from produtos where codprod='$codprod'") or die("X"); 
if(mysql_num_rows($dbresult)==1) {
	$row=mysql_fetch_array($dbresult);
	echo $row[0]."|".$row[1]."|".$row[2]."|".$row[3]."|".$row[4]."|".$row[5]."|".$row[6]   ;
}else {die("X");}
mysql_close($conmy);
exit;
?>

