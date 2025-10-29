<?php

class Metrics{

    private $con;

    public function __construct($con)
    {
        $this->con = $con;
    }

    public function getNumUsers(){

        $query = $this->con->prepare("SELECT COUNT(userId) as numUsers FROM Users");
        $query->execute();

        return $query->fetch()[0];

    }

    public function getNumActiveSessions(){

        $query = $this->con->prepare("SELECT COUNT(sessionId) as numSessions FROM Session WHERE timeOut IS NULL");
        $query->execute();

        return $query->fetch()[0];

    }

    public function getNumTransactions(){

        $query = $this->con->prepare("SELECT COUNT(transactionId) as numTransactions FROM Transactions");
        $query->execute();

        return $query->fetch()[0];

    }

    public function getRevenue(){

        $query = $this->con->prepare("SELECT SUM(amount) as revenue FROM Transactions");
        $query->execute();

        return $query->fetch()[0];

    }

}

?>