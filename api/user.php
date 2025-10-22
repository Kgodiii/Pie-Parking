<?php

require_once("config.php");
require_once("auth.php");

$auth = new Auth();
$authorized = $auth->authenticate();

if(!$authorized){
    header("HTTP/1.0 403");
    exit();
}

$errorArray = array();

$requestMethod = $_SERVER["REQUEST_METHOD"];

switch($requestMethod){
    case "GET":
        if(isset($_GET["id"])){
            $userId = $_GET["id"];
            getUserById($con, $userId);
        }else{
            getAllUsers($con);
        }
        break;
    case "POST":
        $data = json_decode(file_get_contents('php://input'), true);
        insertUser($con, $data["name"], $data["surname"], $data["cellNumber"], $data["password"]);
        break;
    case "PUT":
        $userId = $_GET["id"];
        $data = json_decode(file_get_contents('php://input'), true);
        updateUser($con, $userId, $data["name"], $data["surname"], $data["cellNumber"], $data["password"]);
        break;
    case "DELETE":
        $userId = $_GET["id"];
        deleteUser($con, $userId);
        break;
    default:
        header("HTTP/1.0 405 Method Not Implemented");
        break;
}

function getUserById($con, $UserId){
    $query = $con->prepare("SELECT * FROM Users WHERE userId=:id");
    $query->bindValue(":id", $UserId);
    $query->execute();

    $response = $query->fetch(PDO::FETCH_ASSOC);

    header('Content-Type: application/json');
    echo json_encode($response);
}

function getAllUsers($con){
    $query = $con->prepare("SELECT * FROM Users");
    $query->execute();

    $response = array();

    if($query->rowCount() > 0){

        while($row = $query->fetch(PDO::FETCH_ASSOC)){
            array_push($response, $row);
        }

    }

    header('Content-Type: application/json');
    echo json_encode($response);
}

function insertUser($con, $name, $surname, $cellNumber, $password){

    global $errorArray;

    verifyName($name);
    verifySurname($surname);
    verifyCell($cellNumber);

    if(empty($errorArray)){
        $query = $con->prepare("INSERT INTO Users (name, surname, cellNumber, password) VALUES (:nm, :sn, :cn, :pw)");
        $query->bindValue(":nm", $name);
        $query->bindValue(":sn", $surname);
        $query->bindValue(":cn", $cellNumber);
        $query->bindValue(":pw", $password);

        if($query->execute()){
            //Success
            header('HTTP/1.0 201');
            $response = array(
                'status' => 1,
                'status_message' => 'User added successfully'
            );
        }else{
            //Failed
            header('HTTP/1.0 400');
            $response = array(
                'status' => 0,
                'status_message' => 'User could not be added'
            );
        }
    }else{
        //Failed
        header('HTTP/1.0 400');
        $response = array(
            'status' => 0,
            'status_message' => $errorArray[0]
        );
    }

    header('Content-Type: application/json');
    echo json_encode($response);

}

function updateUser($con, $userId, $name, $surname, $cellNumber, $password){

    global $errorArray;

    verifyName($name);
    verifySurname($surname);
    verifyCell($cellNumber);

    if(empty($errorArray)){
        $query = $con->prepare("UPDATE Users SET name=:nm, surname=:sn, cellNumber=:cn, password=:pw WHERE userId=:id");
        $query->bindValue(":nm", $name);
        $query->bindValue(":sn", $surname);
        $query->bindValue(":cn", $cellNumber);
        $query->bindValue(":pw", $password);
        $query->bindValue(":id", $userId);

        if($query->execute()){
            //Success
            header('HTTP/1.0 200');
            $response = array(
                'status' => 1,
                'status_message' => 'User updated successfully'
            );
        }else{
            //Failed
            header('HTTP/1.0 400');
            $response = array(
                'status' => 0,
                'status_message' => 'User could not be updated'
            );
        }
    }else{
        //Failed
        header('HTTP/1.0 400');
        $response = array(
            'status' => 0,
            'status_message' => $errorArray[0]
        );
    }

    header('Content-Type: application/json');
    echo json_encode($response);

}

function deleteUser($con, $userId){

    $query = $con->prepare("DELETE FROM Users WHERE userId=:id");
    $query->bindValue(":id", $userId);

    if($query->execute()){
        //Success
        header('HTTP/1.0 200');
        $response = array(
            'status' => 1,
            'status_message' => 'User deleted successfully'
        );
    }else{
        //Failed
        header('HTTP/1.0 400');
        $response = array(
            'status' => 0,
            'status_message' => 'User could not be deleted'
        );
    }

    header('Content-Type: application/json');
    echo json_encode($response);

}

function verifyName($name){

    global $errorArray;

    $pattern = "/^[A-z\- ]*$/";

    if($name == "" || $name == null){
        $errorMessage = "User name cannot be empty";
        array_push($errorArray, $errorMessage);
    }elseif(!preg_match($pattern, $name)){
        $errorMessage = "Invalid name";
        array_push($errorArray, $errorMessage);
    }elseif(strlen($name) > 25){
        $errorMessage = "Name cannot be more than 25 characters";
        array_push($errorArray, $errorMessage);
    }else{
        return;
    }

}

function verifySurname($surname){

    global $errorArray;

    $pattern = "/^[A-z\- ]*$/";

    if($surname == "" || $surname == null){
        $errorMessage = "User surname cannot be empty";
        array_push($errorArray, $errorMessage);
    }elseif(!preg_match($pattern, $surname)){
        $errorMessage = "Invalid surname";
        array_push($errorArray, $errorMessage);
    }elseif(strlen($surname) > 25){
        $errorMessage = "Surname cannot be more than 25 characters";
        array_push($errorArray, $errorMessage);
    }else{
        return;
    }

}

function verifyCell($cellNumber){

    global $errorArray;

    $pattern = "/^[0-9]+$/";

    if($cellNumber == "" || $cellNumber == null){
        $errorMessage = "User cell number cannot be empty";
        array_push($errorArray, $errorMessage);
    }elseif(!preg_match($pattern, $cellNumber)){
        $errorMessage = "Invalid cell number";
        array_push($errorArray, $errorMessage);
    }elseif(strlen($cellNumber) > 10){
        $errorMessage = "Cell number cannot be more than 10 characters";
        array_push($errorArray, $errorMessage);
    }else{
        return;
    }

}

?>