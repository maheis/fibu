<?php include('auth/auth.php'); ?>

<?php $heading = 'Auswertung <i class="fad fa-chart-pie fa-fw"></i>'; ?>
<?php include('core/head.php'); ?>

<?php

$Y = date('Y');
if (isset($_GET['Y']))
    $Y = intval(xss_filter($_GET['Y']));

echo '<a class="button tiny themecolor" href="?ReURL=chart&Y=' . ($Y - 1) . '"><i class="fad fa-caret-left fa-fw"></i></a> ';
echo '<input disabled="disabled" style="width: 36px" value="' . $Y . '"> ';
echo '<a class="button tiny themecolor" href="?ReURL=chart&Y=' . ($Y + 1) . '"><i class="fad fa-caret-right fa-fw"></i></a> ';

echo '<table class="withBorder">';
echo '<thead>';
echo '<tr>';
echo '<th style="width: 70px;">Monat</th>';

$categorys = database_select($database_t_fibu_booking_what, 'distinct(category)', '', [], 'category');
foreach ($categorys as $category) {
    echo '<th>' . $category['category'] . '</th>';
}

echo '<th>Summe</th>';
echo '</tr>';
echo '</thead>';
echo '<tbody>';

for ($m = 1; $m <= 12; $m++) {
    echo '<tr>';

    if ($m < 10) {
        echo '<td style="width: 85px;">0' . $m . '</td>';
    } else {
        echo '<td style="width: 85px;">' . $m . '</td>';
    }

    $sum = 0;
    foreach ($categorys as $category) {
        $amount = 0;
        $amount = database_select_unique_value($database_t_fibu_booking, 'sum(amount)', 'date >= :1 and date <= :2 and whatid in (select id from fibu_booking_what where category = :3)', [$Y . '-' . $m . '-01', $Y . '-' . $m . '-31', $category['category']], 0);

        if (!(strpos($amount, "-") === 0)) {
            echo '<td style="white-space:nowrap; text-align: right; color: #81C784;">' . number_format($amount, 2, ',', '') . '&nbsp;€</td>';
        } else {
            echo '<td style="white-space:nowrap; text-align: right; color: #E57373;">' . number_format($amount, 2, ',', '') . '&nbsp;€</td>';
        }

        $sum += $amount;
    }

    if (!(strpos($sum, "-") === 0)) {
        echo '<td style="white-space:nowrap; text-align: right; color: #81C784;">' . number_format($sum, 2, ',', '') . '&nbsp;€</td>';
    } else {
        echo '<td style="white-space:nowrap; text-align: right; color: #E57373;">' . number_format($sum, 2, ',', '') . '&nbsp;€</td>';
    }

    echo '</tr>';
}

echo '</tbody>';
echo '</table>';
?>

<?php include_once('core/footer.php'); ?>