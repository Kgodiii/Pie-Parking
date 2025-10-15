<?php

class Auth{

    private $token = "ff9a60d899fa78607d7a530641b75e7871f7c72de442052cbe3b7cf40d44c5dc";

    public function authenticate(){

        $headers = getallheaders();
        if(!array_key_exists('Authorization', $headers)){
            header('HTTP/1.0 400');
            echo json_encode(["error" => "Auth header missing"]);
            exit();
        }

        if(substr($headers['Authorization'], 0, 6) !== 'Bearer'){

            header("HTTP/1.0 400");
            echo json_encode(["error" => "Bearer keyword missing"]);
            exit();

        }

        $bearerToken = trim(substr($headers['Authorization'], 7));

        return $bearerToken === $this->token;

    }

}

?>