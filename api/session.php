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
            $sessionId = $_GET["id"];
            getSessionById($con, $sessionId);
        }else{
            getAllSessions($con);
        }
        break;
    case "POST":
        $data = json_decode(file_get_contents('php://input'), true);
        insertSession($con, $data["userId"], $data["locationId"]);
        break;
    case "PUT":
        $sessionId = $_GET["id"];
        if(isset($_GET["paid"])){
            if($_GET["paid"] == "true"){
                $data = json_decode(file_get_contents('php://input'), true);
                updateSessionPaid($con, $sessionId, $data["timePaid"]);
            }
        }elseif(isset($_GET["exit"])){
            if($_GET["exit"] == "true"){
                $data = json_decode(file_get_contents('php://input'), true);
                updateSessionExit($con, $sessionId, $data["timeOut"]);
            }
        }else{
            header("HTTP/1.0 405 Missing GET Variables");
        }
        break;
    case "DELETE":
        $sessionId = $_GET["id"];
        deleteSession($con, $sessionId);
        break;
    default:
        header("HTTP/1.0 405 Method Not Implemented");
        break;
}

function getSessionById($con, $SessionId){
    $query = $con->prepare("SELECT * FROM Session WHERE sessionId=:id");
    $query->bindValue(":id", $SessionId);
    $query->execute();

    $response = $query->fetch(PDO::FETCH_ASSOC);

    header('Content-Type: application/json');
    echo json_encode($response);
}

function getAllSessions($con){
    $query = $con->prepare("SELECT * FROM Session");
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

function insertSession($con, $userId, $locationId){

    $query = $con->prepare("INSERT INTO Session (userId, locationId) VALUES (:ui, :li)");
    $query->bindValue(":ui", $userId);
    $query->bindValue(":li", $locationId);

    if($query->execute()){
        //Success
        header('HTTP/1.0 201');
        $response = array(
            'status' => 1,
            'status_message' => 'Session added successfully'
        );
    }else{
        //Failed
        header('HTTP/1.0 400');
        $response = array(
            'status' => 0,
            'status_message' => 'Session could not be added'
        );
    }

    header('Content-Type: application/json');
    echo json_encode($response);

}

function updateSessionPaid($con, $sessionId, $timePaid){

    
    $query = $con->prepare("UPDATE Session SET timePaid=:tp WHERE sessionId=:id");
    $query->bindValue(":tp", $timePaid);

    if($query->execute()){
        //Success
        header('HTTP/1.0 200');
        $response = array(
            'status' => 1,
            'status_message' => 'Session updated successfully'
        );
    }else{
        //Failed
        header('HTTP/1.0 400');
        $response = array(
            'status' => 0,
            'status_message' => 'Session could not be updated'
        );
    }

    header('Content-Type: application/json');
    echo json_encode($response);

}

function updateSessionExit($con, $sessionId, $timeOut){

    
    $query = $con->prepare("UPDATE Session SET timeOut=:to WHERE sessionId=:id");
    $query->bindValue(":to", $timeOut);

    if($query->execute()){
        //Success
        header('HTTP/1.0 200');
        $response = array(
            'status' => 1,
            'status_message' => 'Session updated successfully'
        );
    }else{
        //Failed
        header('HTTP/1.0 400');
        $response = array(
            'status' => 0,
            'status_message' => 'Session could not be updated'
        );
    }

    header('Content-Type: application/json');
    echo json_encode($response);

}

function deleteSession($con, $sessionId){

    $query = $con->prepare("DELETE FROM Session WHERE sessionId=:id");
    $query->bindValue(":id", $sessionId);

    if($query->execute()){
        //Success
        header('HTTP/1.0 200');
        $response = array(
            'status' => 1,
            'status_message' => 'Session deleted successfully'
        );
    }else{
        //Failed
        header('HTTP/1.0 400');
        $response = array(
            'status' => 0,
            'status_message' => 'Session could not be deleted'
        );
    }

    header('Content-Type: application/json');
    echo json_encode($response);

}

?>