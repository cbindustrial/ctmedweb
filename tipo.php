<?php
$item=htmlspecialchars($_GET["item"]);
include '/var/www/connections/conn_mysql.php';
header('Content-Type: text/html; charset=iso-8859-1');
$dbresult=mysql_query("select PA, CO, BN, CJ, SC from itensprecos where codigo='$item'") or die("X"); 
if(mysql_num_rows($dbresult)==1){
	$row=mysql_fetch_array($dbresult);
	echo $row[0]."|".$row[1]."|".$row[2]."|".$row[3]."|".$row[4];
}else {die("X");}
mysql_close($conmy);
exit;
?>

