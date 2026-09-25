<?php

//CREATE-Statement
database_exec('CREATE TABLE IF NOT EXISTS fibu_account (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    credit FLOAT DEFAULT 0 NOT NULL,
    iban TEXT,
    bic TEXT,
    onlinebanking TEXT,
    comment TEXT,
    issubaccount INTEGER DEFAULT 0 NOT NULL
);');

//INSERT
// [$id, $name, $credit, $iban, $bic, $onlinebanking, $comment, $issubaccount]

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
$database_t_fibu_account = [
    'TABLE' => 'fibu_account',
    'RW' => 1,
    'NAME' => 'Konten',
    'ORDER' => 'name',
    'COLUMNS' => [
        'id' => ['NAME' => 'ID', 'RW' => 0, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'HIDDEN' => 1],
        'name' => ['NAME' => 'Konto', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => '', 'REQUIRED' => 1],
        'credit' => ['NAME' => 'Guthaben', 'RW' => 1, 'TYPE' => 'FLOAT', 'SIZE' => 'smaller', 'REQUIRED' => 1],
        'iban' => ['NAME' => 'IBAN', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => ''],
        'bic' => ['NAME' => 'BIC', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => ''],
        'onlinebanking' => ['NAME' => 'Online Banking', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => 'big'],
        'comment' => ['NAME' => 'Kommentar', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => 'big'],
        'issubaccount' => ['NAME' => 'Nebenkonto', 'RW' => 1, 'TYPE' => 'BOOL', 'SIZE' => 'smallest'],
    ]
];

global $database_t_array;
array_push($database_t_array, $database_t_fibu_account);

function fibu_account_get_name($accountid)
{
    global $database_t_fibu_account;

    $result = database_select_unique_value($database_t_fibu_account, 'name', 'id = :1 or name = :2', [$accountid, $accountid], 'unbekanntes Konto');
    return $result;
}
