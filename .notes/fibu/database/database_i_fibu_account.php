<?php

include('auth/auth.php');

// [$id, $name, $credit, $iban, $bic, $onlinebanking, $comment, $issubaccount]
function database_i_fibu_account($method, $id, $name, $credit, $iban, $bic, $onlinebanking, $comment, $issubaccount)
{
    global $database_t_fibu_account;

    if ($method == 'save') {
        database_update($database_t_fibu_account, 'name = :1, credit = :2, iban = :3, bic = :4, onlinebanking = :5, comment = :6, issubaccount = :7', [$name, $credit, $iban, $bic, $onlinebanking, $comment, $issubaccount], 'id = :8', [$id]);
    } elseif ($method == 'add') {
        database_insert($database_t_fibu_account, [$name, $credit, $iban, $bic, $onlinebanking, $comment, $issubaccount]);
    } elseif ($method == 'delete') {
        database_delete($database_t_fibu_account, 'id = :1', [$id]);
    }
}

$ReURL = 'index.php?ReURL=500';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    verify_csrf_or_die();
    $count = (isset($_POST['count']) ? intval(xss_filter($_POST['count'])) : -1);

    for ($cnt = 0; $cnt <= $count; $cnt++) {
        $id = intval(xss_filter($_POST['id' . $cnt]));
        $name = xss_filter($_POST['name' . $cnt]);
        $credit = floatval(str_replace(',', '.', xss_filter($_POST['credit' . $cnt])));
        $iban = xss_filter($_POST['iban' . $cnt]);
        $bic = xss_filter($_POST['bic' . $cnt]);
        $onlinebanking = xss_filter($_POST['onlinebanking' . $cnt]);
        $comment = xss_filter($_POST['comment' . $cnt]);
        $issubaccount = intval(xss_filter($_POST['issubaccount' . $cnt]));
        $ReURL = str_replace('&amp;', '&', xss_filter($_POST['ReURL']));
        if ($ReURL == '')
            $ReURL = 'index.php?ReURL=settings&database';
        $delete = intval(xss_filter($_POST['delete' . $cnt]));

        $method = ($delete == 1 ? 'delete' : 'save');
        if ($cnt == $count && $name != '') {
            if (database_select_unique_value($database_t_fibu_account, 'id', 'id = :1', [$id]) == '') {
                $method = 'add';
            } else {
                $method = 'error';
            }
        }

        database_i_fibu_account($method, $id, $name, $credit, $iban, $bic, $onlinebanking, $comment, $issubaccount);
    }
}

redirect_to('/' . $ReURL);

?>