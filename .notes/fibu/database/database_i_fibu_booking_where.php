<?php

include('auth/auth.php');

// [$id, $name, $lastwhatid, $location]
function database_i_fibu_booking_where($method, $id, $name, $lastwhatid, $location)
{
    global $database_t_fibu_booking_where;

    if ($method == 'save') {
        database_update($database_t_fibu_booking_where, 'name = :1, lastwhatid = :2, location = :3', [$name, $lastwhatid, $location], 'id = :4', [$id]);
    } elseif ($method == 'add') {
        database_insert($database_t_fibu_booking_where, [$name, $lastwhatid, $location]);
    } elseif ($method == 'delete') {
        database_delete($database_t_fibu_booking_where, 'id = :1', [$id]);
    }
}

$ReURL = 'index.php?ReURL=500';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    verify_csrf_or_die();
    $count = (isset($_POST['count']) ? intval(xss_filter($_POST['count'])) : -1);

    for ($cnt = 0; $cnt <= $count; $cnt++) {
        $id = intval(xss_filter($_POST['id' . $cnt]));
        $name = xss_filter($_POST['name' . $cnt]);
        $lastwhatid = intval(xss_filter($_POST['lastwhatid' . $cnt]));
        $location = xss_filter($_POST['location' . $cnt]);
        $ReURL = str_replace('&amp;', '&', xss_filter($_POST['ReURL']));
        if ($ReURL == '')
            $ReURL = 'index.php?ReURL=settings&database';
        $delete = intval(xss_filter($_POST['delete' . $cnt]));

        $method = ($delete == 1 ? 'delete' : 'save');
        if ($cnt == $count && $name != '') {
            if (database_select_unique_value($database_t_fibu_booking_where, 'id', 'id = :1', [$id]) == '') {
                $method = 'add';
            } else {
                $method = 'error';
            }
        }

        database_i_fibu_booking_where($method, $id, $name, $lastwhatid, $location);
    }
}

redirect_to('/' . $ReURL);

?>