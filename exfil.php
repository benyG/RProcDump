<?php
# RProcDump basic file uploader 
	$$allowed = array('dmp');
	if (!file_exists("exfil")) {
		mkdir("exfil", 0777, true);
		}	
	if (isset($_FILES['file']['name'])){
	$size=$_FILES['file']['size'];
	$extension_upload = strtolower( substr( strrchr($_FILES['file']['name'], '.')  ,1)  );
	$nom = basename($_FILES['file']['name']);
	$nom2 = "exfil/{$nom}.{$extension_upload}";
	if (!in_array($extension_upload, $allowed)) {
		move_uploaded_file($_FILES['file']['tmp_name'],$nom2);
		}
	}
?>
Uploaded !