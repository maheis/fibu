<?php include('auth/auth.php'); ?>

<?php $heading = 'Daueraufträge <i class="fad fa-calendar-alt fa-fw"></i>'; ?>
<?php include('core/head.php'); ?>

<?php
function recurring($Mode)
{
    global $database_t_fibu_booking_recurring;
    $sum = 0;

    echo '<table class="withBorder">';
    echo '<thead>';
    echo '<tr>';
    echo '<th>Konto</th>';
    echo '<th>Was?</th>';
    echo '<th style="width: 110px;">Buchungstag</th>';
    echo '<th style="width: 85px;">Betrag</th>';
    echo '<th style="width: 60px;"></th>';
    echo '</tr>';
    echo '</thead>';
    echo '<tbody>';

    $resultset = database_select($database_t_fibu_booking_recurring, '*', 'period = :1', [$Mode]);
    foreach ($resultset as $result) {
        $sum = $sum + $result['amount'];

        echo '<tr>';
        echo '<td>' . fibu_account_get_name($result['accountid']) . '</td>';
        echo '<td>' . fibu_booking_what_get_name($result['whatid']) . '</td>';
        echo '<td>' . $result['bookingday'] . '</td>';
        if (!(strpos($result['amount'], "-") === 0)) {
            echo '<td style="color: #81C784; text-align: right; font-weight: bold">' . $result['amount'] . '&nbsp;€</td>';
        } else {
            echo '<td style="color:#E57373; text-align: right; font-weight: bold">' . $result['amount'] . '&nbsp;€</td>';
        }
        echo '<td text-align: center;>';
        echo '<button class="tiny orange" onclick="dialogOpen(\'editRecurring_' . $result['id'] . '\');"><i class="fad fa-edit fa-fw"></i></button>';
        echo '</td>';
        echo '</tr>';
    }

    $sum = number_format($sum, 2, ',', '');
    echo '<tr class="Sum">';
    echo '<td></td>';
    echo '<td></td>';
    echo '<td style="text-align: right; font-weight: bold">Summe</td>';
    if (!(strpos($sum, "-") === 0)) {
        echo '<td style="color: green; text-align: right; font-weight: bold">' . $sum . '&nbsp;€</td>';
    } else {
        echo '<td style="color:red; text-align: right; font-weight: bold">' . $sum . '&nbsp;€</td>';
    }
    echo '</tr>';

    echo '</tbody>';
    echo '</table>';

    foreach ($resultset as $result) {
        echo '<dialog id="editRecurring_' . $result['id'] . '">';
        database_select_1pager_edit($database_t_fibu_booking_recurring, 'id = :1', [$result['id']], '?ReURL=recurring');
        echo '</dialog>';
    }
}

echo '<dialog id="addRecurring">';
database_select_1pager_add($database_t_fibu_booking_recurring, '?ReURL=recurring');
// if ($Mode == 'M') {
//     echo '<input style = "width: 212px" name = "datum" type = "number" min = "1" max = "31"value = "';
//     if (isset($_SESSION['datum'])) {
//         echo date("d", strtotime($_SESSION['datum']));
//     } else {
//         date_default_timezone_set('Europe/Berlin');
//         echo date('d');
//     }
//     echo '">';
//     echo ' <button class="tiny blue" onclick="toggle(' . chr(39) . 'dauerauftraghilfe' . chr(39) . ');" type="button"><i class="fa fa-question-circle fa-fw"></i></button>';
// } else {
//     echo '<input style = "width: 50px" name = "datum" type = "number" min = "1" max = "31"value = "';
//     if (isset($_SESSION['datum'])) {
//         echo date("d", strtotime($_SESSION['datum']));
//     } else {
//         date_default_timezone_set('Europe/Berlin');
//         echo date('d');
//     }
//     echo '"> ';

//     echo '<select style="width: 158px" name="monat" id="select1">';

//     echo '<option value="01" ';
//     if (date('m') == "01") {
//         echo ' Selected';
//     }
//     echo '>Januar</option>';
//     echo '<option value="02"';
//     if (date('m') == "02") {
//         echo ' Selected';
//     }
//     echo '>Februar</option>';
//     echo '<option value="03"';
//     if (date('m') == "03") {
//         echo ' Selected';
//     }
//     echo '>März</option>';
//     echo '<option value="04"';
//     if (date('m') == "04") {
//         echo ' Selected';
//     }
//     echo '>April</option>';
//     echo '<option value="05"';
//     if (date('m') == "05") {
//         echo ' Selected';
//     }
//     echo '>Mai</option>';
//     echo '<option value="06"';
//     if (date('m') == "06") {
//         echo ' Selected';
//     }
//     echo '>Juni</option>';
//     echo '<option value="7"';
//     if (date('m') == "07") {
//         echo ' Selected';
//     }
//     echo '>Juli</option>';
//     echo '<option value="08"';
//     if (date('m') == "08") {
//         echo ' Selected';
//     }
//     echo '>August</option>';
//     echo '<option value="09"';
//     if (date('m') == "09") {
//         echo ' Selected';
//     }
//     echo '>September</option>';
//     echo '<option value="10"';
//     if (date('m') == "10") {
//         echo ' Selected';
//     }
//     echo '>Oktober</option>';
//     echo '<option value="11"';
//     if (date('m') == "11") {
//         echo ' Selected';
//     }
//     echo '>November</option>';
//     echo '<option value="12"';
//     echo '>Dezember</option>';
//     if (date('m') == "12") {
//         echo ' Selected';
//     }
//     echo '</select>';

//     echo ' <button class="tiny blue" onclick="toggle(' . chr(39) . 'dauerauftraghilfe' . chr(39) . ');" type="button"><i class="fa fa-question-circle fa-fw"></i></button>';
// }
echo '</dialog>';
?>

<table>
    <thead>
        <tr>
            <th>Monatlich</th>
            <th style="width: 61px; text-align: center">
                <button class="tiny green" onclick="dialogOpen('addRecurring');"><i
                        class="fad fa-plus-circle fa-fw"></i></button>
            </th>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>
<?php recurring('M'); ?>
<br />
<hr />
<br />
<table>
    <thead>
        <tr>
            <th>Quartal</th>
            <th style="width: 61px; text-align: center">
            </th>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>
<?php recurring('Q'); ?>
<br />
<hr />
<br />
<table>
    <thead>
        <tr>
            <th>Jährlich</th>
            <th style="width: 61px; text-align: center">
            </th>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>
<?php recurring('Y'); ?>

<?php include_once('core/footer.php'); ?>