<?php

//CREATE-Statement
database_exec('CREATE TABLE IF NOT EXISTS fibu_booking_recurring (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    accountid INTEGER NOT NULL,
    whatid INTEGER NOT NULL,
    bookingday TEXT NOT NULL,
    amount FLOAT DEFAULT 0 NOT NULL,
    period TEXT NOT NULL,
    FOREIGN KEY (accountid) REFERENCES fibu_account (id),
    FOREIGN KEY (whatid) REFERENCES fibu_what (id)
);');

//INSERT
// [$id, $accountid, $whatid, $bookingday, $amount, $period]

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
//[COLUMNS]OPTIONAL REQUIRED => 1 //mandatory field
//[COLUMNS]OPTIONAL HIDDEN => 1 //hidden in 1Pager
//[VIRTUAL]NAME => 'spokable name'
//[VIRTUAL]CONTENT => 'content, will be replaced with the value, usefull for e.g. buttons...'
$database_t_fibu_booking_recurring = [
    'TABLE' => 'fibu_booking_recurring',
    'RW' => 1,
    'NAME' => 'Wiederkehrende Buchungen',
    'ORDER' => 'period, bookingday',
    'COLUMNS' => [
        'id' => ['NAME' => 'ID', 'RW' => 0, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'HIDDEN' => 1],
        'accountid' => ['NAME' => 'Konto', 'RW' => 1, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'REQUIRED' => 1, 'LIST' => ['_SQL' => 'SELECT id as a, name as b FROM fibu_account ORDER BY name']],
        'whatid' => ['NAME' => 'Was?', 'RW' => 1, 'TYPE' => 'INT', 'SIZE' => '', 'REQUIRED' => 1, 'LIST' => ['_SQL' => 'SELECT id as a, name as b FROM fibu_booking_what ORDER BY name']],
        'bookingday' => ['NAME' => 'Buchungstag', 'RW' => 1, 'TYPE' => 'TEXT', 'REQUIRED' => 1, 'SIZE' => 'smaller'],
        'amount' => ['NAME' => 'Betrag', 'RW' => 1, 'TYPE' => 'FLOAT', 'SIZE' => 'smaller', 'REQUIRED' => 1],
        'period' => ['NAME' => 'Periode', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => 'smallest', 'REQUIRED' => 1, 'LIST' => ['M' => 'Monatlich', 'Q' => 'Quartal', 'Y' => 'Jährlich']],
    ]
];

global $database_t_array;
array_push($database_t_array, $database_t_fibu_booking_recurring);
