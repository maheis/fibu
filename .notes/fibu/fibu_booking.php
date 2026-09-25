<?php include('auth/auth.php'); ?>

<?php $heading = 'Buchung <i class="fad fa-shopping-cart fa-fw"></i>'; ?>
<?php include('core/head.php'); ?>

<?php

$accountid = (isset($_SESSION['accountid']) ? $_SESSION['accountid'] : '');
if (isset($_GET['accountid'])) {
    $accountid = intval(xss_filter($_GET['accountid']));
}

$date = (isset($_SESSION['date']) ? $_SESSION['date'] : date('Y-m-d'));

$whereid = (isset($_SESSION['whereid']) ? $_SESSION['whereid'] : '');
if ($whereid == '') {
    $whereid = database_select_unique_value($database_t_fibu_booking_where, 'name', 'location = :1', [$_SESSION['geolocation']], '');
}

$whatid = '';

$comment = '';

$amount = '';

$budgetid = '';
if (isset($_GET['budgetid'])) {
    $budgetid = intval(xss_filter($_GET['budgetid']));
}

$budgetamount = '';

// Im Fehlerfall soll das Formular wiederbefüllt sein...
if (isset($_GET['booking']) && $_GET['booking'] == 'false') {
    $accountid = $_SESSION['accountid'];
    $date = $_SESSION['date'];
    $whereid = $_SESSION['whereid'];
    $whatid = $_SESSION['whatid'];
    $comment = $_SESSION['comment'];
    $amount = $_SESSION['amount'];
    if ($amount < 0)
        $amount = $amount * -1;
    $budgetid = $_SESSION['budgetid'];
    $budgetamount = $_SESSION['budgetamount'];
    if ($budgetamount < 0)
        $budgetamount = $budgetamount * -1;
}

fibu_booking($accountid, $date, $whereid, $whatid, $comment, $amount, $budgetid, $budgetamount, '', '?ReURL=booking');

fibu_booking_results();

?>

<?php include_once('core/footer.php'); ?>