<?php

include('auth/auth.php');

// [$id, $name, $category]
function database_i_fibu_booking_what($method, $id, $name, $category)
{
    global $database_t_fibu_booking_what;

    if ($method == 'save') {
        database_update($database_t_fibu_booking_what, 'name = :1, category = :2', [$name, $category], 'id = :3', [$id]);
    } elseif ($method == 'add') {
        database_insert($database_t_fibu_booking_what, [$name, $category]);
    } elseif ($method == 'delete') {
        database_delete($database_t_fibu_booking_what, 'id = :1', [$id]);
    }
}

$ReURL = 'index.php?ReURL=500';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    verify_csrf_or_die();
    $count = (isset($_POST['count']) ? intval(xss_filter($_POST['count'])) : -1);

    for ($cnt = 0; $cnt <= $count; $cnt++) {
        $id = intval(xss_filter($_POST['id' . $cnt]));
        $name = xss_filter($_POST['name' . $cnt]);
        $category = xss_filter($_POST['category' . $cnt]);
        $ReURL = str_replace('&amp;', '&', xss_filter($_POST['ReURL']));
        if ($ReURL == '')
            $ReURL = 'index.php?ReURL=settings&database';
        $delete = intval(xss_filter($_POST['delete' . $cnt]));

        $method = ($delete == 1 ? 'delete' : 'save');
        if ($cnt == $count && $name != '') {
            if (database_select_unique_value($database_t_fibu_booking_what, 'id', 'id = :1', [$id]) == '') {
                $method = 'add';
            } else {
                $method = 'error';
            }
        }

        database_i_fibu_booking_what($method, $id, $name, $category);
    }
}

redirect_to('/' . $ReURL);

?>