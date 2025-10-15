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
            $transactionId = $_GET["id"];
            getTransactionById($con, $transactionId);
        }else{
            getAllTransactions($con);
        }
        break;
    case "POST":
        $data = json_decode(file_get_contents('php://input'), true);
        insertTransaction($con, $data["gatewayId"], $data["amount"], $data["sessionId"]);
        break;
    case "PUT":
        $transactionId = $_GET["id"];
        $data = json_decode(file_get_contents('php://input'), true);
        updateTransaction($con, $transactionId, $data["gatewayId"], $data["amount"], $data["sessionId"]);
        break;
    case "DELETE":
        $transactionId = $_GET["id"];
        deleteTransaction($con, $transactionId);
        break;
    default:
        header("HTTP/1.0 405 Method Not Implemented");
        break;
}

function getTransactionById($con, $transactionId){
    $query = $con->prepare("SELECT * FROM Transactions WHERE transactionId=:id");
    $query->bindValue(":id", $transactionId);
    $query->execute();

    $response = $query->fetch(PDO::FETCH_ASSOC);

    header('Content-Type: application/json');
    echo json_encode($response);
}

function getAllTransactions($con){
    $query = $con->prepare("SELECT * FROM Transactions");
    $query->execute();

    $response = array();

    if($query->rowCount() > 0){

        while($row = $query->fetch(PDO::FETCH_ASSOC)){

            $row["amount"] = (float)$row["amount"];
            $row["amount"] = number_format($row["amount"], 2, '.', '');

            array_push($response, $row);
        }

    }

    header('Content-Type: application/json');
    echo json_encode($response);
}

function insertTransaction($con, $gatewayId, $amount, $sessionId){

    global $errorArray;

    verifyProductPrice($amount);

    if(empty($errorArray)){
        $query = $con->prepare("INSERT INTO Transactions (gatewayId, amount, sessionId) VALUES (:gi, :am, :si)");
        $query->bindValue(":gi", $gatewayId);
        $query->bindValue(":am", $amount);
        $query->bindValue(":si", $sessionId);

        if($query->execute()){
            //Success
            header('HTTP/1.0 201');
            $response = array(
                'status' => 1,
                'status_message' => 'Transaction added successfully'
            );
        }else{
            //Failed
            header('HTTP/1.0 400');
            $response = array(
                'status' => 0,
                'status_message' => 'Transaction could not be added'
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

function updateTransaction($con, $transactionId, $gatewayId, $amount, $sessionId){

    global $errorArray;

    verifyProductPrice($amount);

    if(empty($errorArray)){
        $query = $con->prepare("UPDATE Transactions SET gatewayId=:gi, amount=:am, sessionId=:si WHERE transactionId=:id");
        $query->bindValue(":gi", $gatewayId);
        $query->bindValue(":am", $amount);
        $query->bindValue(":si", $sessionId);
        $query->bindValue(":id", $transactionId);

        if($query->execute()){
            //Success
            header('HTTP/1.0 200');
            $response = array(
                'status' => 1,
                'status_message' => 'Transaction updated successfully'
            );
        }else{
            //Failed
            header('HTTP/1.0 400');
            $response = array(
                'status' => 0,
                'status_message' => 'Transaction could not be updated'
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

function deleteTransaction($con, $transactionId){

    $query = $con->prepare("DELETE FROM Transactions WHERE transactionId=:id");
    $query->bindValue(":id", $transactionId);

    if($query->execute()){
        //Success
        header('HTTP/1.0 200');
        $response = array(
            'status' => 1,
            'status_message' => 'Transaction deleted successfully'
        );
    }else{
        //Failed
        header('HTTP/1.0 400');
        $response = array(
            'status' => 0,
            'status_message' => 'Transaction could not be deleted'
        );
    }

    header('Content-Type: application/json');
    echo json_encode($response);

}

function verifyProductPrice($price){

    global $errorArray;

    $pattern = "/^([0-9]+[\.]?[0-9]*)$/";

    if($price == "" || $price == null){
        $errorMessage = "Transaction amount cannot be empty";
        array_push($errorArray, $errorMessage);
    }elseif(!preg_match($pattern, $price)){
        $errorMessage = "Invalid amount";
        array_push($errorArray, $errorMessage);
    }elseif(strlen($price) > 20){
        $errorMessage = "Amount cannot be more than 20 characters";
        array_push($errorArray, $errorMessage);
    }else{
        return;
    }

}


?>