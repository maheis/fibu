<?php
switch ($ReURL) {
    case 'booking':
        $ReURL_ = 'modules/fibu/fibu_booking.php';
        break;
    case 'bookings':
        $ReURL_ = 'modules/fibu/fibu_bookings.php';
        break;
    case 'chart':
        $ReURL_ = 'modules/fibu/fibu_chart.php';
        break;
    case 'overview':
        $ReURL_ = 'modules/fibu/fibu_overview.php';
        break;
    case 'recurring':
        $ReURL_ = 'modules/fibu/fibu_recurring.php';
        break;
    case 'transfer':
        $ReURL_ = 'modules/fibu/fibu_transfer.php';
        break;
}

if (substr($ReURL, 0, 16) == 'database_i_fibu_') {
    $ReURL_ = 'modules/fibu/database/' . $ReURL . '.php';
}