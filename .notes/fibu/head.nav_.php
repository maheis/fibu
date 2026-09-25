<?php

if (isset($_SESSION['loggedin']) && $_SESSION['loggedin'] == config('side_guid')) {
    echo '<ul>';
    echo '<li>';
    echo '    <a href="?ReURL=booking"><i class="fad fa-shopping-cart fa-fw"></i></a>';
    echo '</li>';
    echo '<li>';
    echo '    <a href="?ReURL=transfer"><i class="fad fa-exchange fa-fw"></i></a>';
    echo '</li>';
    echo '<li>';
    echo '    <a href="?ReURL=recurring"><i class="fad fa-calendar-alt fa-fw"></i></a>';
    echo '</li>';
    echo '<li>';
    echo '    <a href="?ReURL=bookings"><i class="fad fa-receipt fa-fw"></i></a>';
    echo '</li>';
    echo '<li>';
    echo '    <a href="?ReURL=overview"><i class="fad fa-piggy-bank fa-fw"></i></a>';
    echo '</li>';
    echo '<li>';
    echo '    <a href="?ReURL=chart"><i class="fad fa-chart-pie fa-fw"></i></a>';
    echo '</li>';
    echo '</ul>';
}