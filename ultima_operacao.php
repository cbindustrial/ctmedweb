<?php
	$codprod=htmlspecialchars($_GET["codprod"]);
	$item=htmlspecialchars($_GET["item"]);
	include '/var/www/connections/conn_mysql.php';
	header('Content-Type: text/html; charset=iso-8859-1');
	$dbresult=mysql_query("select count(*) from ctmed_reg as t1 where codprod = '$codprod' and operac = (select operac from ctmed_itm as t2 where item = '$item' group by operac order by operac desc limit 1) and etapa = 'F' limit 1") or die("X"); 
	if(mysql_num_rows($dbresult)==1){
		$row=mysql_fetch_array($dbresult);
		echo $row[0];} else {die("X");}
	mysql_close($conmy);
	exit;
?>