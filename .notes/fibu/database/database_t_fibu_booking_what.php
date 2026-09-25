<?php

//CREATE-Statement
database_exec('CREATE TABLE IF NOT EXISTS fibu_booking_what (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    category TEXT
);');

//INSERT
// [$id, $name, $category]

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
$database_t_fibu_booking_what = [
    'TABLE' => 'fibu_booking_what',
    'RW' => 1,
    'NAME' => 'Was?',
    'ORDER' => 'name',
    'COLUMNS' => [
        'id' => ['NAME' => 'ID', 'RW' => 0, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'HIDDEN' => 1],
        'name' => ['NAME' => 'Name', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => '', 'REQUIRED' => 1],
        'category' => ['NAME' => 'Category', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => '', 'REQUIRED' => 1],
    ]
];

global $database_t_array;
array_push($database_t_array, $database_t_fibu_booking_what);

function fibu_booking_what_get_name($whatid)
{
    global $database_t_fibu_booking_what;

    $result = database_select_unique_value($database_t_fibu_booking_what, 'name', 'id = :1', [$whatid], '');
    return $result;
}

function fibu_booking_what_get_category($whatid)
{
    global $database_t_fibu_booking_what;

    $result = database_select_unique_value($database_t_fibu_booking_what, 'name', 'id = :1 or name = :2', [$whatid, $whatid], '');
    return $result;
}

function fibu_booking_what($what)
{
    global $database_t_fibu_booking_what;

    $result = database_select_unique_value($database_t_fibu_booking_what, 'id', 'id = :1 or name = :2', [$what, $what], '');
    if ($result == '') {
        database_insert($database_t_fibu_booking_what, [$what, '']);
        $result = database_select_unique_value($database_t_fibu_booking_what, 'id', 'name = :1', [$what], '');
    }
    return $result;
}
