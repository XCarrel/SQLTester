<?php
function getQuestionResult($idusers, $idqueries)
{
    global $dbh;
    $query = "select nbattempts, success from sqlt_results where fkuser=$idusers and fkqueries=$idqueries";
    $sel = $dbh->query($query);
    if ($sel->rowCount() == 0)
        return 'white';
    else
    {
        $res = $sel->fetch();
        if ($res['success'] > 0)
            return 'lime';
        else
            return 'red';
    }
}

$hostname = "localhost";
$dbname = "SQLTester";
$username = "root";
$password = "root";
try
{
    $dbh = new PDO("mysql:host=$hostname;dbname=$dbname", $username, $password);
    $dbh->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    $dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $dbh->exec("SET NAMES 'utf8'");
} catch (PDOException $e)
{
    die ("erreur de connexion au serveur (" . $e->getMessage() . ")");
}

//error_log(print_r($_POST,true));
extract($_POST); // $id, $question, $response

error_log(">>>>>>>>>>SQLTester, received $response from " . $_SERVER['HTTP_REFERER'] . " ($id) <<<<<<<<<<<<<<");

if (is_numeric($id) and is_numeric($question)) // process response attempt
{
    // Fetch the student
    $query = "select idusers from sqlt_users where intranetid = $id";
    $sel = $dbh->query($query);
    if ($sel->rowCount() == 0)
        $message = "Personne inconnue";
    else
    {
        $res = $sel->fetch();
        extract($res); // $idusers

        // Fetch the correct query from the database
        $query = "select idqueries, statement from sqlt_queries where questionnumber = $question";
        $sel = $dbh->query($query);
        if ($sel->rowCount() == 0)
            $message = "Question inconnue";
        else
        {
            $res = $sel->fetch();
            extract($res); // $idqueries, $statement

            // make sure we have a record to register answer
            try
            {
                $dbh->query("insert into sqlt_results(fkuser,fkqueries) values ($idusers,$idqueries)"); // will fail if record already exists
            } catch (PDOException $e)
            {
            }
            // get recid
            $sel = $dbh->query("select idresults, nbattempts from sqlt_results where fkuser=$idusers and fkqueries=$idqueries");
            $res = $sel->fetch();
            extract($res); // $idresults
            // count attempt
            $dbh->query("update sqlt_results set nbattempts=nbattempts+1 where idresults=$idresults");
            try
            {
                // what are the results of the query proposed by the student
                $sel = $dbh->query($response);
                $val = $sel->fetchall();

                // Now see the results of that query
                $correct = $dbh->query($statement);
                $res = $correct->fetchall();
                error_log("Submitted:" . print_r($val, true));
                error_log("Expected:" . print_r($res, true));
                if (strcmp(print_r($val, true), print_r($res, true)) == 0)
                {
                    $dbh->query("update sqlt_results set success=success+1 where idresults=$idresults");
                    $message = "Juste !!";
                } else
                {
                    $message = "<p>Ce n'est pas ça...</p>";
                    $message .= "<p>ça doit ressembler à ceci:</p>";
                    $message .= "<table style='font-size: 60%'><tr>";
                    foreach ($res[0] as $key => $v) $message .= "<th>$key</th>";
                    $message .= "</tr>";
                    $nbl = 0;
                    foreach ($res as $rec)
                    {
                        $nbl++;
                        if ($nbl > 10)
                        {
                            $message .= "<tr><td colspan='200'>...</td></tr>";
                            break;
                        }
                        $message .= "<tr>";
                        foreach ($rec as $v) $message .= "<td>$v</td>";
                        $message .= "</tr>";
                    }
                    $message .= "</table>";
                }
            } catch (PDOException $e)
            {
                $message = "Syntaxe incorrecte. Vérifiez et réessayez!<br>";
                error_log("Syntax error: $id, $question, $response");
                error_log($e->getMessage());
            }
        }
    }
}

// Load questions
$query = "select idqueries, questionnumber, formulation from sqlt_queries order by questionnumber";
$sel = $dbh->query($query);
$questions = $sel->fetchAll();

// Load users
$query = "select idusers, firstname, lastname from sqlt_users order by lastname";
$sel = $dbh->query($query);
$users = $sel->fetchAll();

?>

<head>
    <title>SQL Tester</title>
    <style>
        td, th {
            border: 1px solid black;
        }

        table {
            border-collapse: collapse;
        }
    </style>
</head>
<body style="font-family: Arial">
<?= $message; ?>
<h1>Questions</h1>
<table>
    <?php
    foreach ($questions as $question)
    {
        extract($question); // $idqueries, $questionnumber, $formulation
        echo "<tr><td>$questionnumber</td><td>$formulation</td></tr>";
    }
    ?>
</table>
<h1>Soumettre une réponse</h1>
<form class="form-horizontal" method="post">
    <table>
        <tr>
            <td><label class="col-md-2 control-label" for="idid">ID</label></td>
            <td><input class="form-control" id="idid" type="text" name="id"></td>
        </tr>
        <tr>
            <td><label class="col-md-2" for="idquestion">Question</label></td>
            <td><input class="form-control" id="idquestion" type="number" name="question"></td>
        </tr>
        <tr>
            <td><label class="col-md-2" for="idresponse">Réponse</label></td>
            <td><textarea class="form-control" id="idresponse" name="response" cols="80" rows="10"></textarea></td>
        </tr>
        <tr>
            <td><input class="form-control" type="submit" name="submit" value="OK"></td>
            <td></td>
        </tr>
    </table>
</form>

<h1>Résultats</h1>
<table>
    <tr>
        <th>Personne</th>
        <?php
        foreach ($questions as $question)
            echo "<th>" . $question['questionnumber'] . "</th>";
        ?>
    </tr>
    <?php
    foreach ($users as $user)
    {
        extract($user); // $idusers, $firstname, $lastname
        echo "<tr><td>$firstname $lastname</td>";
        foreach ($questions as $question)
        {
            extract($question); // $idqueries, $questionnumber, $formulation
            echo "<td width=20px style='background-color:" . getQuestionResult($idusers, $idqueries) . "'>&nbsp;</td>";
        }
        echo "</tr>";
    }
    ?>
</table>
</body>
