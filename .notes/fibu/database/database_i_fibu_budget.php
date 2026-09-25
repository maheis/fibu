<?php

include('auth/auth.php');

// [$id, $name, $credit]
function database_i_fibu_budget($method, $id, $name, $credit)
{
    global $database_t_fibu_budget;

    if ($method == 'save') {
        database_update($database_t_fibu_budget, 'name = :1, credit = :2', [$name, $credit], 'id = :3', [$id]);
    } elseif ($method == 'add') {
        database_insert($database_t_fibu_budget, [$name, $credit]);
    } elseif ($method == 'delete') {
        database_delete($database_t_fibu_budget, 'id = :1', [$id]);
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
        $ReURL = str_replace('&amp;', '&', xss_filter($_POST['ReURL']));
        if ($ReURL == '')
            $ReURL = 'index.php?ReURL=settings&database';
        $delete = intval(xss_filter($_POST['delete' . $cnt]));

        $method = ($delete == 1 ? 'delete' : 'save');
        if ($cnt == $count && $name != '') {
            if (database_select_unique_value($database_t_fibu_budget, 'id', 'id = :1', [$id]) == '') {
                $method = 'add';
            } else {
                $method = 'error';
            }
        }

        database_i_fibu_budget($method, $id, $name, $credit);
    }
}

redirect_to('/' . $ReURL);

?>