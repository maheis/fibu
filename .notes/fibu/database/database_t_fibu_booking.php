<?php

//CREATE-Statement
database_exec('CREATE TABLE IF NOT EXISTS fibu_booking (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    accountid INTEGER NOT NULL,
    date INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
    whereid INTEGER NOT NULL,
    whatid INTEGER NOT NULL,
    comment TEXT,
    amount FLOAT DEFAULT 0 NOT NULL,
    budgetid INTEGER,
    budgetamount FLOAT DEFAULT 0 NOT NULL,
    FOREIGN KEY (accountid) REFERENCES fibu_account (id),
    FOREIGN KEY (whereid) REFERENCES fibu_where (id),
    FOREIGN KEY (whatid) REFERENCES fibu_what (id),
    FOREIGN KEY (budgetid) REFERENCES fibu_budget (id)
);');

//INSERT
// [$id, $accountid, $date, $whereid, $whatid, $comment, $amount, $budgetid, $budgetamount]

//[TABLE]TABLE => 'tablename'
//[TABLE]RW = 0-1 //0 = readonly ,1 = read/write (für select_table_edit())
//[TABLE]NAME => 'spokable tablename'
//[ORDER] => default order by, can be overriden in select-function, e.g. 'column desc, column desc' 
//[COLUMNS]NAME => 'spokable name'
//[COLUMNS]RW => 0-2 //0 = readonly, 1 = read/write, 2 = readonly/but in INSERT writeable!
//[COLUMNS]TYPE => TEXT, INT, BOOL, PASSWORD, FLOAT, DATETIME, DATE, TIME, TIMESTAMP(dt)
//[COLUMNS]SIZE => smallest, smaller, small, '', big, bigger, biggest
//[COLUMNS]OPTIONAL DEFAULT => Default-Value
//[COLUMNS]OPTIONAL TIP => TOOPTIP
//[COLUMNS]OPTIONAL LIST => SELECTION: ['VALUE' => 'SPOKEABLENAME', 'VALUE' => 'SPOKEABLENAME', '_SQL'...] ['_SQL' => 'SELECT <COLUMN_VALUE> as a [, <COLUMN_SPOKEABLENAME> as b] FROM <TABLE> ORDER BY <COL>']
//[COLUMNS]OPTIONAL REQUIRED => 1 = mandatory field
//[COLUMNS]OPTIONAL HIDDEN => 1 //hidden in 1Pager
//[VIRTUAL]NAME => 'spokable name'
//[VIRTUAL]CONTENT => 'content, will be replaced with the value, usefull for e.g. buttons...'
$database_t_fibu_booking = [
    'TABLE' => 'fibu_booking',
    'RW' => 1,
    'NAME' => 'Buchungen',
    'ORDER' => 'date, accountid',
    'COLUMNS' => [
        'id' => ['NAME' => 'ID', 'RW' => 0, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'HIDDEN' => 1],
        'accountid' => ['NAME' => 'Konto', 'RW' => 1, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'REQUIRED' => 1, 'LIST' => ['_SQL' => 'SELECT id as a, name as b FROM fibu_account ORDER BY name']],
        'date' => ['NAME' => 'Datum', 'RW' => 1, 'TYPE' => 'DATE', 'SIZE' => 'small', 'REQUIRED' => 1],
        'whereid' => ['NAME' => 'Wo?', 'RW' => 1, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'REQUIRED' => 1, 'LIST' => ['_SQL' => 'SELECT id as a, name as b FROM fibu_booking_where ORDER BY name']],
        'whatid' => ['NAME' => 'Was?', 'RW' => 1, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'REQUIRED' => 1, 'LIST' => ['_SQL' => 'SELECT id as a, name as b FROM fibu_booking_what ORDER BY name']],
        'comment' => ['NAME' => 'Kommentar', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => ''],
        'amount' => ['NAME' => 'Betrag', 'RW' => 1, 'TYPE' => 'FLOAT', 'SIZE' => 'smaller', 'REQUIRED' => 1],
        'budgetid' => ['NAME' => 'Budget', 'RW' => 1, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'LIST' => ['_SQL' => 'SELECT id as a, name as b FROM fibu_budget ORDER BY name']],
        'budgetamount' => ['NAME' => 'Budgetbetrag', 'RW' => 1, 'TYPE' => 'FLOAT', 'SIZE' => 'smaller'],
    ]
];

global $database_t_array;
array_push($database_t_array, $database_t_fibu_booking);
function loadSelect($database_t_, $selected = '')
{
    $resultset = database_select($database_t_, 'id, name', '', [], 'name ASC');
    foreach ($resultset as $result) {
        echo '<option value="' . $result['id'] . '"' . (($result['id'] == $selected || $result['name'] == $selected) ? ' selected' : '') . '>' . $result['name'] . '</option>';
    }
}
function loadDatalist($database_t_)
{
    $resultset = database_select($database_t_, 'id, name', '', [], 'name ASC');
    foreach ($resultset as $result) {
        echo '<option value="' . $result['name'] . '">' . $result['name'] . '</option>';
    }
}

function fibu_booking($accountid = '', $date = '', $whereid = '', $whatid = '', $comment = '', $amount = '', $budgetid = '', $budgetamount = '', $id = '', $return2 = '')
{
    global $database_t_fibu_account, $database_t_fibu_budget, $database_t_fibu_booking_where, $database_t_fibu_booking_what;

    echo '<form method="post" action="index.php?ReURL=database_i_fibu_booking" name="booking">';
    echo csrf_input();
    echo '    <div class="hide">';
    echo '        <input name="form" type="text" value="booking">';
    echo '        <input id="GeoLocationInput" name="GeoLocationInput" type="text">';
    $resultset = database_select($database_t_fibu_booking_where, '*', '', [], 'name ASC');
    foreach ($resultset as $result) {
        echo '<where_what>' . $result['name'] . ':' . fibu_booking_what_get_name($result['lastwhatid']) . '</where_what>';
    }
    echo '        <input id="id0" name="id0" type="text" value="' . $id . '">';
    echo '        <input name="count" type="text" value="0">';
    echo '        <input name="ReURL" type="text" value="' . $return2 . '">';
    echo '    </div>';
    echo '    <table style="margin: auto; width:0; white-space: nowrap;">';
    echo '        <tbody>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Konto:';
    echo '                </td>';
    echo '                <td>';
    echo '                    <select class="big" name="accountid0" required>';
    loadSelect($database_t_fibu_account, $accountid);
    echo '                    </select>';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Datum:';
    echo '                </td>';
    echo '                <td>';
    echo '                    <input class="big" name="date0" type="date" value="' . $date . '">';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Wo?:';
    echo '                </td>';
    echo '                <td>';
    $whereid = database_select_unique_value($database_t_fibu_booking_where, 'name', 'id = :1 or name = :1', [$whereid], '');
    echo '                    <input class="big" name="whereid0" id="whereid0" onchange="where_what()" type="text" list="where" value="' . $whereid . '" required>';
    echo '                    <datalist id="where">';
    loadDatalist($database_t_fibu_booking_where);
    echo '                    </datalist>';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Was?:';
    echo '                </td>';
    echo '                <td>';
    if ($whatid == '' && $whereid != '') {
        $where_lastwhatid = database_select_unique_value($database_t_fibu_booking_where, 'lastwhatid', 'name = :1', [$whereid], '');
        if ($where_lastwhatid != '') {
            $whatid = $where_lastwhatid;
        }
    }
    $whatid = database_select_unique_value($database_t_fibu_booking_what, 'name', 'id = :1 or name = :1', [$whatid], '');
    echo '                    <input class="big" name="whatid0" id="whatid0" type="text" list="what" value="' . $whatid . '" required>';
    echo '                    <datalist id="what">';
    loadDatalist($database_t_fibu_booking_what);
    echo '                    </datalist>';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Kommentar:';
    echo '                </td>';
    echo '                <td>';
    echo '                    <textarea class="big" name="comment0" type="text">' . $comment . '</textarea>';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Betrag:';
    echo '                </td>';
    echo '                <td>';
    echo '                    <input class="big" name="amount0" type="text" value="' . $amount . '" required> &euro;';
    echo '                </td>';
    echo '            </tr>';
    if ($id == '') {
        echo '        <tr>';
        echo '            <td colspan="4" style="text-align: center">';
        echo '            <button class="medium red" name="save" type="submit" value="-1"><i class="fad fa-minus-circle fa-fw"></i></button>';
        echo '            <button class="medium green" name="save" type="submit" value="1"><i class="fad fa-plus-circle fa-fw"></i></button>';
        echo '            </td>';
        echo '        </tr>';
    }
    echo '            <tr>';
    echo '                <td>';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Budget:';
    echo '                </td>';
    echo '                <td>';
    echo '                    <select class="big" name="budgetid0">';
    echo '                        <option value="null"></option>';
    loadSelect($database_t_fibu_budget, $budgetid);
    echo '                    </select>';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Budgetbetrag:';
    echo '                </td>';
    echo '                <td>';
    echo '                    <input class="big" name="budgetamount0" type="text" value="' . ($budgetamount > 0 ? $budgetamount : '') . '"> &euro;';
    echo '                </td>';
    echo '            </tr>';
    if ($id != '') {
        echo '        <tr>';
        echo '            <td>';
        echo '            </td>';
        echo '        </tr>';
        echo '        <tr>';
        echo '            <td style="text-align: right;">';
        echo '                Löschen?';
        echo '            </td>';
        echo '            <td>';
        echo '                <input class="big" name="delete0" type="checkbox" value="1">';
        echo '            </td>';
        echo '        </tr>';
        echo '        <tr>';
        echo '            <td colspan="4" style="text-align: center">';
        echo '                <button class="medium orange" name="save" type="submit" value="1"><i class="fad fa-save fa-fw"></i></button>';
        echo '            </td>';
        echo '        </tr>';
    }
    echo '        </tbody>';
    echo '    </table>';
    echo '</form>';
}

function fibu_transfer($accountid = '', $date = '', $comment = '', $amount = '')
{
    global $database_t_fibu_account;

    echo '<form method="post" action="index.php?ReURL=database_i_fibu_booking">';
    echo csrf_input();
    echo '    <div class="hide">';
    echo '        <input name="form" type="text" value="transfer">';
    echo '        <input name="ReURL" type="text" value="?ReURL=transfer">';
    echo '    </div>';
    echo '    <table style="margin: auto; width:0; white-space: nowrap;">';
    echo '        <tbody>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    von Konto:';
    echo '                </td>';
    echo '                <td style="text-align: left;">';
    echo '                    <select class="big" name="accountfrom" required>';
    loadSelect($database_t_fibu_account, $accountid);
    echo '                    </select>';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    auf Konto:';
    echo '                </td>';
    echo '                <td style="text-align: left;">';
    echo '                    <select class="big" name="accountto" required>';
    loadSelect($database_t_fibu_account, '');
    echo '                    </select>';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Datum:';
    echo '                </td>';
    echo '                <td style="text-align: left;">';
    echo '                    <input class="big" name="date" type="date" value="' . $date . '" required>';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Kommentar:';
    echo '                </td>';
    echo '                <td>';
    echo '                    <textarea class="big" name="comment" type="text">' . $comment . '</textarea>';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: right;">';
    echo '                    Betrag:';
    echo '                </td>';
    echo '                <td style="text-align: left;">';
    echo '                    <input class="big" name="amount" type="number" step="any" value="' . $amount . '" required> &euro;';
    echo '                </td>';
    echo '            </tr>';
    echo '            <tr>';
    echo '                <td style="text-align: center" colspan="2">';
    echo '                    <button class="medium green" name="buchen" value="plus" type="submit"><i class="fad fa-exchange fa-fw"></i></button>';
    echo '                </td>';
    echo '            </tr>';
    echo '        </tbody>';
    echo '    </table>';
    echo '</form>';
}

function fibu_booking_results($showBooking = true)
{
    echo '<br/>';

    if (isset($_GET['booking']) && $_GET['booking'] == 'true') {
        if ($_SESSION['delete'] == 0) {
            if (isset($_GET['amountbudgetamountt']) && $_GET['amountbudgetamountt'] == 'false') {
                echo '<div class="notice warning">Buchung erfolgreich angelegt! - Aber ein abweichender Betrag für das Budget wurde eingegeben!</div>';
            } else {
                echo '<div class="notice success">Buchung erfolgreich angelegt!</div>';
            }
        } else {
            echo '<div class="notice success">Buchung erfolgreich gelöscht!</div>';
        }

        echo '<div class="notice theme">';

        if ($showBooking && $_SESSION['delete'] == 0) {
            echo '<table class="withBorder">';
            echo '    <thead>';
            echo '        <tr>';
            echo '            <th colspan="5">Buchung</th>';
            echo '        </tr>';
            echo '    </thead>';
            echo '    <tbody>';
            echo '        <tr>';
            echo '            <td style="width: 150px;">' . fibu_account_get_name($_SESSION['accountid']) . '</td>';
            echo '            <td>' . $_SESSION['date'] . '</td>';
            if (isset($_SESSION['amount']) && $_SESSION['amount'] != 0) {
                if (!(strpos($_SESSION['amount'], "-") === 0)) {
                    echo '        <td style="width: 85px; color: #81C784; white-space:nowrap;">' . number_format($_SESSION['amount'], 2, ',', '') . '&nbsp;€</td>';
                } else {
                    echo '        <td style="width: 85px; color: #E57373; white-space:nowrap;">' . number_format($_SESSION['amount'], 2, ',', '') . '&nbsp;€</td>';
                }
            }
            echo '            <td style="width: 150px;">' . fibu_booking_where_get_name($_SESSION['whereid']) . '</td>';
            echo '            <td rowspan="2" style="width: 25px;"><button class="tiny orange" onclick="dialogOpen(\'editBooking_\');"><i class="far fa-pencil fa-fw"></i></button></td>';
            echo '        </tr>';
            echo '        <tr>';
            echo '            <td>';
            if (isset($_SESSION['budgetid']) && $_SESSION['budgetid'] != 0) {
                echo fibu_budget_get_name($_SESSION['budgetid']);
                if (!(strpos($_SESSION['budgetamount'], "-") === 0)) {
                    echo ' [<font style="color: #81C784">' . number_format($_SESSION['budgetamount'], 2, ',', '') . '&nbsp;€</font>]';
                } else {
                    echo ' [<font style="color: #E57373">' . number_format($_SESSION['budgetamount'], 2, ',', '') . '&nbsp;€</font>]';
                }
            }
            echo '            </td>';
            echo '            <td colspan="2">' . $_SESSION['comment'] . '</td>';
            echo '            <td>' . fibu_booking_what_get_name($_SESSION['whatid']) . '</td>';
            echo '        </tr>';
            echo '    </tbody>';
            echo '</table>';
        }

        echo '<dialog id="editBooking_">';
        fibu_booking($_SESSION['accountid'], $_SESSION['date'], $_SESSION['whereid'], $_SESSION['whatid'], $_SESSION['comment'], $_SESSION['amount'], $_SESSION['budgetid'], $_SESSION['budgetamount'], $_SESSION['id'], '?ReURL=booking');
        echo '</dialog>';

        if (isset($_SESSION['accountid']) && $_SESSION['accountid'] != 0) {
            echo '<br/>';

            echo '<table class="withBorder">';
            echo '<thead>';
            echo '<tr>';
            echo '<th style="width: 150px;">Konto</th>';
            echo '<th>Alter Kontostandt</th>';
            echo '<th>Neuer Kontostandt</th>';
            echo '</tr>';
            echo '</thead>';
            echo '<tbody>';
            echo '<tr>';
            echo '<td>' . fibu_account_get_name($_SESSION['accountid']) . '</td>';
            if (!(strpos($_SESSION['accountcreditold'], "-") === 0)) {
                echo '<td style="color: #81C784;">' . number_format($_SESSION['accountcreditold'], 2, ',', '') . '&nbsp;€</td>';
            } else {
                echo '<td style="color: #E57373;">' . number_format($_SESSION['accountcreditold'], 2, ',', '') . '&nbsp;€</td>';
            }
            if (!(strpos($_SESSION['accountcreditnew'], "-") === 0)) {
                echo '<td style="color: #81C784;">' . number_format($_SESSION['accountcreditnew'], 2, ',', '') . '&nbsp;€</td>';
            } else {
                echo '<td style="color: #E57373;">' . number_format($_SESSION['accountcreditnew'], 2, ',', '') . '&nbsp;€</td>';
            }
            echo '</tr>';
            if (isset($_SESSION['2accountid']) && $_SESSION['2accountid'] != '') {
                echo '<tr>';
                echo '<td>' . fibu_account_get_name($_SESSION['2accountid']) . '</td>';
                if (!(strpos($_SESSION['2accountcreditold'], "-") === 0)) {
                    echo '<td style="color: #81C784;">' . number_format($_SESSION['2accountcreditold'], 2, ',', '') . '&nbsp;€</td>';
                } else {
                    echo '<td style="color: #E57373;">' . number_format($_SESSION['2accountcreditold'], 2, ',', '') . '&nbsp;€</td>';
                }
                if (!(strpos($_SESSION['2accountcreditnew'], "-") === 0)) {
                    echo '<td style="color: #81C784;">' . number_format($_SESSION['2accountcreditnew'], 2, ',', '') . '&nbsp;€</td>';
                } else {
                    echo '<td style="color: #E57373;">' . number_format($_SESSION['2accountcreditnew'], 2, ',', '') . '&nbsp;€</td>';
                }
                echo '</tr>';
            }
            echo '</tbody>';
            echo '</table>';
        }

        if (isset($_SESSION['budgetid']) && $_SESSION['budgetid'] != 0) {
            echo '<br/>';

            echo '<table class="withBorder">';
            echo '<thead>';
            echo '<tr>';
            echo '<th style="width: 150px;">Budget</th>';
            echo '<th>Altes Budget</th>';
            echo '<th>Neues Budget</th>';
            echo '</tr>';
            echo '</thead>';
            echo '<tbody>';
            echo '<tr>';
            echo '<td>' . fibu_budget_get_name($_SESSION['budgetid']) . '</td>';
            if (!(strpos($_SESSION['budgetcreditold'], "-") === 0)) {
                echo '<td style="color: #81C784;">' . number_format($_SESSION['budgetcreditold'], 2, ',', '') . '&nbsp;€</td>';
            } else {
                echo '<td style="color: #E57373;">' . number_format($_SESSION['budgetcreditold'], 2, ',', '') . '&nbsp;€</td>';
            }
            if (!(strpos($_SESSION['budgetcreditnew'], "-") === 0)) {
                echo '<td style="color: #81C784;">' . number_format($_SESSION['budgetcreditnew'], 2, ',', '') . '&nbsp;€</td>';
            } else {
                echo '<td style="color: #E57373;">' . number_format($_SESSION['budgetcreditnew'], 2, ',', '') . '&nbsp;€</td>';
            }
            echo '</tr>';
            echo '</tbody>';
            echo '</table>';
        }

        echo '</div>';
    } else if (isset($_GET['booking']) && $_GET['booking'] == 'false') {
        $ErrStr = '';

        if (isset($_GET['amountf']) && $_GET['amountf'] == 'false') {
            $ErrStr = $ErrStr . 'Ein gültiger Betrag muss eingegeben werden!<br/>';
        }
        if (isset($_GET['budgetidf']) && $_GET['budgetidf'] == 'false') {
            $ErrStr = $ErrStr . 'Ein Budgetbetrag wurde angegeben, aber kein Budget ausgewählt!<br/>';
        }
        if (isset($_GET['budgetamountf']) && $_GET['budgetamountf'] == 'false') {
            $ErrStr = $ErrStr . 'Ein gültiger Budgetbetrag muss eingegeben werden!<br/>';
        }
        if (isset($_GET['amountbudgetamountf']) && $_GET['amountbudgetamountf'] == 'false') {
            $ErrStr = $ErrStr . 'Ein gültiger abweichender Betrag für das Budget muss eingegeben werden!<br/>';
        }
        if (isset($_GET['fromtoidf']) && $_GET['fromtoidf'] == 'false') {
            $ErrStr = $ErrStr . 'Konto und Konto auf das gebucht werden soll muss unterschiedlich sein!<br/>';
        }

        if ($ErrStr != '') {
            echo '<div class="notice error">' . $ErrStr . '</div>';
            echo '<br/>';
        }
    }
}
