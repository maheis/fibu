<?php include('auth/auth.php'); ?>

<?php $heading = 'Umbuchung <i class="fad fa-exchange fa-fw"></i>'; ?>
<?php include('core/head.php'); ?>

<?php

$accountid = (isset($_SESSION['accountid']) ? $_SESSION['accountid'] : '');
if (isset($_GET['accountid'])) {
    $accountid = intval(xss_filter($_GET['accountid']));
}

$date = (isset($_SESSION['date']) ? $_SESSION['date'] : date('Y-m-d'));

$comment = (isset($_GET['comment']) && $_GET['comment'] == 'false') ? $_SESSION['comment'] : '';

$amount = (isset($_GET['buchung']) && $_GET['buchung'] == 'false') ? $_SESSION['betrag'] : '';

fibu_transfer($accountid, $date, $comment, $amount);

fibu_booking_results(false);

?>

<?php include_once('core/footer.php'); ?>