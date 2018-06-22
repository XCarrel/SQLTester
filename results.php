<?php
function getQuestionResult($idusers, $idqueries)
{
    global $dbh;
    $query = "select nbattempts, success from results where fkuser=$idusers and fkqueries=$idqueries";
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

// Load questions
$query = "select idqueries, questionnumber, formulation from queries order by questionnumber";
$sel = $dbh->query($query);
$questions = $sel->fetchAll();

// Load users
$query = "select idusers, firstname, lastname from users order by lastname";
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

<script>
setTimeout(function(){
   window.location.reload(1);
}, 15000);
</script>
