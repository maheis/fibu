<?php

include('auth/auth.php');

// [$id, $accountid, $date, $whereid, $whatid, $comment, $amount, $budgetid, $budgetamount]

function database_i_fibu_booking($method, $id, $accountid, $date, $whereid, $whatid, $comment, $amount, $budgetid, $budgetamount)
{
    global $database_t_fibu_booking, $database_t_fibu_account, $database_t_fibu_budget;

    $amount_ = 0;
    $budgetamount_ = 0;

    if ($method == 'save') {
        $amount_ = floatval(database_select_unique_value($database_t_fibu_booking, 'amount', 'id = :1', [$id], 0)) * -1;
        $budgetamount_ = floatval(database_select_unique_value($database_t_fibu_booking, 'budgetamount', 'id = :1', [$id], 0)) * -1;

        database_update($database_t_fibu_booking, 'accountid = :1, date = :2, whereid = :3, whatid = :4, comment = :5, amount = :6, budgetid = :7, budgetamount = :8', [$accountid, $date, $whereid, $whatid, $comment, $amount, $budgetid, $budgetamount], 'id = :9', [$id]);
    } elseif ($method == 'add') {
        database_insert($database_t_fibu_booking, [$accountid, $date, $whereid, $whatid, $comment, $amount, $budgetid, $budgetamount]);
        $_SESSION['id'] = database_select_unique_value($database_t_fibu_booking, 'id', 'accountid = :1 AND date = :2 AND whereid = :3 AND whatid = :4 AND comment = :5 AND amount = :6 AND budgetid = :7 AND budgetamount = :8', [$accountid, $date, $whereid, $whatid, $comment, $amount, $budgetid, $budgetamount], 0);
    } elseif ($method == 'delete') {
        $amount = floatval(database_select_unique_value($database_t_fibu_booking, 'amount', 'id = :1', [$id], 0)) * -1;
        $budgetamount = floatval(database_select_unique_value($database_t_fibu_booking, 'budgetamount', 'id = :1', [$id], 0)) * -1;

        database_delete($database_t_fibu_booking, 'id = :1', [$id]);
    }

    // Alter Kontostand
    $_SESSION['accountcreditold'] = database_select_unique_value($database_t_fibu_account, 'credit', 'id = :1', [$accountid], 0);
    if ($budgetid != 0)
        $_SESSION['budgetcreditold'] = database_select_unique_value($database_t_fibu_budget, 'credit', 'id = :1', [$budgetid], 0);

    // Alte Buchung Rückgängig machen (falls 'save') 
    database_update($database_t_fibu_account, 'credit = credit + :1', [$amount_], 'id = :2', [$accountid]);
    if ($budgetid != 0)
        database_update($database_t_fibu_budget, 'credit = credit + :1', [$budgetamount_], 'id = :2', [$budgetid]);

    // Neue Buchung verbuchen 
    database_update($database_t_fibu_account, 'credit = credit + :1', [$amount], 'id = :2', [$accountid]);
    if ($budgetid != 0)
        database_update($database_t_fibu_budget, 'credit = credit + :1', [$budgetamount], 'id = :2', [$budgetid]);

    // Neue Kontostand
    $_SESSION['accountcreditnew'] = database_select_unique_value($database_t_fibu_account, 'credit', 'id = :1', [$accountid], 0);
    if ($budgetid != 0)
        $_SESSION['budgetcreditnew'] = database_select_unique_value($database_t_fibu_budget, 'credit', 'id = :1', [$budgetid], 0);
}

$ReURL = 'index.php?ReURL=500';
$return = '';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    verify_csrf_or_die();
    $form = (isset($_POST['form']) ? xss_filter($_POST['form']) : '');

    if ($form == 'transfer') {
        $accountfrom = intval(xss_filter($_POST['accountfrom']));
        $accountto = intval(xss_filter($_POST['accountto']));
        $date = xss_filter($_POST['date']);
        $whatid = fibu_booking_what('Umbuchung');
        $whereid = fibu_booking_where('Buchung', '', '');
        $comment = xss_filter($_POST['comment']);
        $comment = $comment . ($comment != '' ? ' ' : '') . '(Umbuchung von ' . fibu_account_get_name($accountfrom) . ' nach ' . fibu_account_get_name($accountto) . ')';
        $amount = xss_filter($_POST['amount']);
        $amount = str_replace(',', '.', $amount);
        $amount = str_replace('€', '', $amount);
        $amount = str_replace(' ', '', $amount);
        $amount = floatval($amount);
        $ReURL = (isset($_POST['ReURL']) ? str_replace('&amp;', '&', xss_filter($_POST['ReURL'])) : '');
        if ($ReURL == '')
            $ReURL = 'index.php?ReURL=transfer';

        // Was wirklich ausgewählt wurde...
        $_SESSION['accountid'] = $accountfrom;
        $_SESSION['date'] = $date;
        $_SESSION['whereid'] = $whereid;
        $_SESSION['whatid'] = $whatid;
        $_SESSION['comment'] = $comment;
        $_SESSION['amount'] = $amount;
        $_SESSION['delete'] = 0;

        //Checking...
        if ($accountfrom == 0 || $accountto == 0 || $accountfrom == $accountto) {
            if ($return == '') {
                $return = 'fromtoidf=false';
            } else {
                $return = $return . '&fromtoidf=false';
            }
        }

        if ($return == '') {
            database_i_fibu_booking('add', '', $accountto, $date, $whereid, $whatid, $comment, $amount, '', '');
            $_SESSION['2accountid'] = $accountto;
            $_SESSION['2accountcreditold'] = $_SESSION['accountcreditold'];
            $_SESSION['2accountcreditnew'] = $_SESSION['accountcreditnew'];
            database_i_fibu_booking('add', '', $accountfrom, $date, $whereid, $whatid, $comment, ($amount * -1), '', '');

            $return = '&booking=true';
        } else {
            $return = '&booking=false&' . $return;
        }
    } else {
        $count = (isset($_POST['count']) ? intval(xss_filter($_POST['count'])) : -1);

        for ($cnt = 0; $cnt <= $count; $cnt++) {
            $save = intval((isset($_POST['save']) ? xss_filter($_POST['save']) : 1));
            $location = xss_filter($_POST['GeoLocationInput']);
            $id = intval(xss_filter($_POST['id' . $cnt]));
            $accountid = intval(xss_filter($_POST['accountid' . $cnt]));
            $date = xss_filter($_POST['date' . $cnt]);
            $whatid = fibu_booking_what(xss_filter($_POST['whatid' . $cnt]));
            $whereid = fibu_booking_where(xss_filter($_POST['whereid' . $cnt]), $whatid, $location);
            $comment = xss_filter($_POST['comment' . $cnt]);
            $amount = xss_filter($_POST['amount' . $cnt]);
            $amount = str_replace(',', '.', $amount);
            $amount = str_replace('€', '', $amount);
            $amount = str_replace(' ', '', $amount);
            $amount = floatval($amount);
            $amount = $amount * $save;
            $amount = number_format($amount, 2, '.', '');
            $budgetid = intval(xss_filter($_POST['budgetid' . $cnt]));
            $budgetamount = xss_filter($_POST['budgetamount' . $cnt]);
            if ($budgetid != 0 && $budgetamount == '') {
                $budgetamount = $amount;
            } else {
                $budgetamount = str_replace(',', '.', $budgetamount);
                $budgetamount = str_replace('€', '', $budgetamount);
                $budgetamount = str_replace(' ', '', $budgetamount);
                $budgetamount = floatval($budgetamount);
                $budgetamount = $budgetamount * $save;
                $budgetamount = number_format($budgetamount, 2, '.', '');
            }
            $ReURL = str_replace('&amp;', '&', xss_filter($_POST['ReURL']));
            if ($ReURL == '')
                $ReURL = 'index.php?ReURL=settings&database';
            $delete = intval(xss_filter($_POST['delete' . $cnt]));

            $method = ($delete == 1 ? 'delete' : 'save');
            if ($cnt == $count && $accountid != 0) {
                if (database_select_unique_value($database_t_fibu_booking, 'id', 'id = :1', [$id]) == '') {
                    $method = 'add';
                }
            }



            //Checking...
            if ($method == 'save' || $method == 'add') {
                // Was wirklich ausgewählt wurde...
                $_SESSION['accountid'] = $accountid;
                $_SESSION['date'] = $date;
                $_SESSION['whereid'] = $whereid;
                $_SESSION['whatid'] = $whatid;
                $_SESSION['comment'] = $comment;
                $_SESSION['amount'] = $amount;
                $_SESSION['budgetid'] = $budgetid;
                $_SESSION['budgetamount'] = $budgetamount;
                $_SESSION['delete'] = 0;

                if ($amount == '' || $amount == 0 || !preg_match("/^[\-]{0,1}\d*\.\d\d$/", $amount)) {
                    if ($return == '') {
                        $return = 'amountf=false';
                    } else {
                        $return = $return . '&amountf=false';
                    }
                }

                if ($budgetid != 0 && !preg_match("/^[\-]{0,1}\d*\.\d\d$/", $budgetamount)) {
                    if ($return == '') {
                        $return = 'budgetamountf=false';
                    } else {
                        $return = $return . '&budgetamountf=false';
                    }
                }

                if ($budgetamount != 0 && $budgetid == 0) {
                    if ($return == '') {
                        $return = 'budgetidf=false';
                    } else {
                        $return = $return . '&budgetidf=false';
                    }
                }

                if ($budgetid != 0 && ((($amount > 0) && $budgetamount > $amount) || (($amount < 0) && $budgetamount < $amount) || $budgetamount == 0)) {
                    if ($return == '') {
                        $return = 'amountbudgetamountf=false';
                    } else {
                        $return = $return . '&amountbudgetamountf=false';
                    }
                }
            } else {
                // Was wirklich ausgewählt wurde...
                $_SESSION['delete'] = 1;
            }

            if ($return == '') {
                if ($budgetid != 0 && $amount != $budgetamount) {
                    if ($return == '') {
                        $return = 'amountbudgetamountt=false';
                    } else {
                        $return = $return . '&amountbudgetamountt=false';
                    }
                }

                database_i_fibu_booking($method, $id, $accountid, $date, $whereid, $whatid, $comment, $amount, $budgetid, $budgetamount);
                $return = '&booking=true&' . $return;
            } else {
                $return = '&booking=false&' . $return;
            }
        }
    }
}

redirect_to('/' . $ReURL . $return);

?>