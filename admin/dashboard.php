<?php

if(!isset($_SESSION["userLoggedIn"])){
    header("Location: login.php");
}

?>

Hello World!