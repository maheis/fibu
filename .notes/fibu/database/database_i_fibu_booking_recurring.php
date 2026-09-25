<?php

include('auth/auth.php');

// [$id, $accountid, $whatid, $bookingday, $amount, $period]

function database_i_fibu_booking_recurring($method, $id, $accountid, $whatid, $bookingday, $amount, $period)
{
    global $database_t_fibu_booking_recurring;

    if ($method == 'save') {
        database_update($database_t_fibu_booking_recurring, 'accountid = :1, whatid = :2, bookingday = :3, amount = :4, period = :5', [$accountid, $whatid, $bookingday, $amount, $period], 'id = :6', [$id]);
    } elseif ($method == 'add') {
        database_insert($database_t_fibu_booking_recurring, [$accountid, $whatid, $bookingday, $amount, $period]);
    } elseif ($method == 'delete') {
        database_delete($database_t_fibu_booking_recurring, 'id = :1', [$id]);
    }
}

$ReURL = 'index.php?ReURL=500';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    verify_csrf_or_die();
    $count = (isset($_POST['count']) ? intval(xss_filter($_POST['count'])) : -1);

    for ($cnt = 0; $cnt <= $count; $cnt++) {
        $id = intval(xss_filter($_POST['id' . $cnt]));
        $accountid = intval(xss_filter($_POST['accountid' . $cnt]));
        $whatid = xss_filter($_POST['whatid' . $cnt]);
        $bookingday = xss_filter($_POST['bookingday' . $cnt]);
        $amount = floatval(str_replace(',', '.', xss_filter($_POST['amount' . $cnt])));
        $period = xss_filter($_POST['period' . $cnt]);
        $ReURL = str_replace('&amp;', '&', xss_filter($_POST['ReURL']));
        if ($ReURL == '')
            $ReURL = 'index.php?ReURL=settings&database';
        $delete = intval(xss_filter($_POST['delete' . $cnt]));

        $method = ($delete == 1 ? 'delete' : 'save');
        if ($cnt == $count && $accountid != 0) {
            if (database_select_unique_value($database_t_fibu_booking_recurring, 'id', 'id = :1', [$id]) == '') {
                $method = 'add';
            } else {
                $method = 'error';
            }
        }

        database_i_fibu_booking_recurring($method, $id, $accountid, $whatid, $bookingday, $amount, $period);
    }
}

redirect_to('/' . $ReURL);

?>