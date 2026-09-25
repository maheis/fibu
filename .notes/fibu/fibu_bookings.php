<?php include('auth/auth.php'); ?>

<?php $heading = 'Buchungen <i class="fad fa-receipt fa-fw"></i>'; ?>
<?php include('core/head.php'); ?>

<?php
$m = (isset($_SESSION['m']) ? $_SESSION['m'] : date('m'));
if (isset($_GET['m']))
    $m = intval(xss_filter($_GET['m']));

$Y = (isset($_SESSION['Y']) ? $_SESSION['Y'] : date('Y'));
if (isset($_GET['Y']))
    $Y = intval(xss_filter($_GET['Y']));

$textfilter = (isset($_SESSION['filter']) ? $_SESSION['filter'] : '');
if (isset($_GET['filter']))
    $textfilter = xss_filter($_GET['filter']);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    verify_csrf_or_die();
    $hostname = $_SERVER['HTTP_HOST'];
    $path = dirname($_SERVER['PHP_SELF']);

    $m = intval(xss_filter($_POST['m']));
    $Y = intval(xss_filter($_POST['y']));
    isset($_POST['filter']) && $_POST['filter'] ? $filter = $_POST['filter'] : $filter = '';
    $textfilter = $_POST['textfilter'];

    if ($filter == 'mm') {
        $m--;
        if ($m == 0) {
            $Y--;
            $m = 12;
        }
    }
    if ($filter == 'mp') {
        $m++;
        if ($m == 13) {
            $Y++;
            $m = 1;
        }
    }
    if ($filter == 'ym') {
        $Y--;
    }
    if ($filter == 'yp') {
        $Y++;
    }

    if ($filter == '12') {
        isset($_SESSION['oneyear']) && $_SESSION['oneyear'] ? $_SESSION['oneyear'] = false : $_SESSION['oneyear'] = true;
    }
}

if ($m < 10 && strlen($m) == 1) {
    $m = "0" . $m;
}
$_SESSION['m'] = $m;
$_SESSION['Y'] = $Y;
$_SESSION['filter'] = $textfilter;
$oneyear = (isset($_SESSION['oneyear']) ? $_SESSION['oneyear'] : false);

$filterform = "";
$filterform = $filterform . '<form method="post" action="?ReURL=bookings" name="filter">';
$filterform = $filterform . csrf_input();
$filterform = $filterform . '<table>';
$filterform = $filterform . '<tr>';
$filterform = $filterform . '<td nowrap style="text-align: right; width: 50%;">';
$filterform = $filterform . '<button class="tiny themecolor" name="filter" value="mm" type="submit"><i class="fad fa-caret-left fa-fw"></i></button> ';
$filterform = $filterform . '<input disabled="disabled" style="width: 21px" name="m" type="text" value="' . $m . '"> ';
$filterform = $filterform . '<button class="tiny themecolor" name="filter" value="mp" type="submit"><i class="fad fa-caret-right fa-fw"></i></button> ';
$filterform = $filterform . '<input style="width: 21px" name="m" type="hidden" value="' . $m . '"> ';
$filterform = $filterform . '<button class="tiny themecolor" name="filter" value="ym" type="submit"><i class="fad fa-caret-left fa-fw"></i></button> ';
$filterform = $filterform . '<input disabled="disabled" style="width: 36px" name="y" type="text" value="' . $Y . '"> ';
$filterform = $filterform . '<input style="width: 36px" name="y" type="hidden" value="' . $Y . '"> ';
$filterform = $filterform . '<button class="tiny themecolor" name="filter" value="yp" type="submit"><i class="fad fa-caret-right fa-fw"></i></button> ';
$filterform = $filterform . '<button class="tiny ' . ($oneyear ? 'themecolor' : 'gray') . '" name="filter" value="12" type="submit"><i class="fad fa-calendar fa-fw"></i></button> ';
$filterform = $filterform . '</td>';
$filterform = $filterform . '<td nowrap style="text-align: left; width: 50%;">';
$filterform = $filterform . '<input style="width: 300px" name="textfilter" class="search" type="search" onsearch="this.form.submit();" onfocusout="this.form.submit();" placeholder="&#xf0b0; filter ..." value="' . $textfilter . '" title="Freitext&#10;Konto:&#10;Datum:&#10;Wo:&#10;Was:&#10;Kommentar:&#10;Betrag:&#10;Budget:<Wert|Plus|Positiv|+|Minus|Negativ|->&#10;Budgetbetrag:&#10;Kategorie:&#10;" />';
$filterform = $filterform . '</td>';
$filterform = $filterform . '</tr>';
$filterform = $filterform . '</table>';
$filterform = $filterform . '</form>';
echo $filterform;
?>

<table class="withBorder">
    <thead>
        <tr class="lineA">
            <th colspan="2" style="width: 170px;">Konto</th>
            <th>Datum</th>
            <th style="width: 85px;">Betrag</th>
            <th style="width: 110px;">Wo?</th>
            <th rowspan="2" style="width: 25px;"></th>
        </tr>
        <tr class="lineC">
            <th style="width: 85px;">Budget</th>
            <th style="width: 85px;"></th>
            <th colspan="2">Kommentar</th>
            <th>Was?</th>
        </tr>
    </thead>
    <tbody>
        <?php
        $sum = 0;
        $sumbudget = 0;

        $resultset = database_select($database_t_fibu_booking, '*', 'date >= :1 and date <= :2', [($oneyear ? $Y - 1 : $Y) . '-' . $m . '-01', $Y . '-' . $m . '-31'], 'date DESC, id DESC');

        foreach ($resultset as $result) {
            $filter = 'Konto:' . fibu_account_get_name($result['accountid']) . 'Datum:' . $result['date'] . 'Wo:' . fibu_booking_where_get_name($result['whereid']) . 'Was:' . fibu_booking_what_get_name($result['whatid']) . 'Kommentar:' . $result['comment'] . 'Betrag:' . $result['amount'] . 'Budget:' . fibu_budget_get_name($result['budgetid']) . 'Budgetbetrag:' . $result['budgetamount'] . 'Kategorie:' . fibu_booking_what_get_category($result['whatid']);

            if (!(strpos($result['amount'], "-") === 0)) {
                $filter = $filter . 'Betrag:PlusBetrag:PositivBetrag:+';
            } else {
                $filter = $filter . 'Betrag:MinusBetrag:NegativBetrag:-';
            }
            if (!(strpos($result['budgetamount'], "-") === 0)) {
                $filter = $filter . 'Budget:PlusBudget:PositivBudget:+';
            } else {
                $filter = $filter . 'Budget:MinusBudget:NegativBudget:-';
            }

            if ($textfilter != '' && !(stripos($filter, $textfilter) !== false)) {
                continue;
            }

            echo '<tr>';
            echo '<td colspan="2">' . fibu_account_get_name($result['accountid']) . '</td>';
            echo '<td>' . $result['date'] . '</td>';
            if (!(strpos($result['amount'], "-") === 0)) {
                echo '<td style="white-space:nowrap; text-align: right; color: #81C784;">' . number_format($result['amount'], 2, ',', '') . '&nbsp;€</td>';
            } else {
                echo '<td style="white-space:nowrap; text-align: right; color: #E57373;">' . number_format($result['amount'], 2, ',', '') . '&nbsp;€</td>';
            }
            echo '<td>' . fibu_booking_where_get_name($result['whereid']) . '</td>';
            echo '<td rowspan="2"><button class="tiny orange" onclick="dialogOpen(\'editBooking_' . $result['id'] . '\');"><i class="far fa-pencil fa-fw"></i></button></td>';
            echo '</tr>';
            echo '<tr class="lineC">';
            if (fibu_budget_get_name($result['budgetid']) == '') {
                echo '<td></td><td></td>';
            } else {
                if (!(strpos($result['budgetamount'], "-") === 0)) {
                    echo '<td style="white-space:nowrap;">' . fibu_budget_get_name($result['budgetid']) . '</td><td style="white-space:nowrap; text-align: right; color: #81C784;">' . number_format($result['budgetamount'], 2, ',', '') . '&nbsp;€</td>';
                } else {
                    echo '<td style="white-space:nowrap;">' . fibu_budget_get_name($result['budgetid']) . '</td><td style="white-space:nowrap; text-align: right; color: #E57373;">' . number_format($result['budgetamount'], 2, ',', '') . '&nbsp;€</td>';
                }
            }
            echo '<td colspan="2">' . $result['comment'] . '</td>';
            echo '<td>' . fibu_booking_what_get_name($result['whatid']) . '</td>';
            echo '</tr>';

            $sum = $sum + floatval($result['amount']);
            $sumbudget = $sumbudget + floatval($result['budgetamount']);
        }

        echo '<tr class="Sum">';
        echo '<td>Summe</td>';
        if (!(strpos($sumbudget, "-") === 0)) {
            echo '<td style="white-space:nowrap; text-align: right; color: #81C784;">' . number_format($sumbudget, 2, ',', '') . '&nbsp;€</td>';
        } else {
            echo '<td style="white-space:nowrap; text-align: right; color: #E57373;">' . number_format($sumbudget, 2, ',', '') . '&nbsp;€</td>';
        }
        echo '<td></td>';
        if (!(strpos($sum, "-") === 0)) {
            echo '<td style="white-space:nowrap; text-align: right; color: #81C784;">' . number_format($sum, 2, ',', '') . '&nbsp;€</td>';
        } else {
            echo '<td style="white-space:nowrap; text-align: right; color: #E57373;">' . number_format($sum, 2, ',', '') . '&nbsp;€</td>';
        }
        echo '<td></td>';
        echo '</tr>';

        ?>
    </tbody>
</table>
<br>
<br>
<br>
<br>
<br>
<?php
foreach ($resultset as $result) {
    echo '<dialog id="editBooking_' . $result['id'] . '">';
    $row = database_select_unique_row($database_t_fibu_booking, 'id = :1', [$result['id']]);
    fibu_booking($row['accountid'], $row['date'], $row['whereid'], $row['whatid'], $row['comment'], $row['amount'], $row['budgetid'], $row['budgetamount'], $row['id'], '?ReURL=bookings');
    echo '</dialog>';
}
?>

<?php include_once('core/footer.php'); ?>