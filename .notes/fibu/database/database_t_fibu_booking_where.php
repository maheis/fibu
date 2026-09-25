<?php

//CREATE-Statement
database_exec('CREATE TABLE IF NOT EXISTS fibu_booking_where (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    lastwhatid INT,
    location TEXT NOT NULL,
    FOREIGN KEY (lastwhatid) REFERENCES fibu_where (id)
);');

//INSERT
// [$id, $name, $lastwhatid, $location]

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
$database_t_fibu_booking_where = [
    'TABLE' => 'fibu_booking_where',
    'RW' => 1,
    'NAME' => 'Wo?',
    'ORDER' => 'name',
    'COLUMNS' => [
        'id' => ['NAME' => 'ID', 'RW' => 0, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'HIDDEN' => 1],
        'name' => ['NAME' => 'Name', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => '', 'REQUIRED' => 1],
        'lastwhatid' => ['NAME' => 'letztes Was?', 'RW' => 1, 'TYPE' => 'INT', 'SIZE' => 'smallest'],
        'location' => ['NAME' => 'Ort', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => 'smallest']
    ]
];

global $database_t_array;
array_push($database_t_array, $database_t_fibu_booking_where);

function fibu_booking_where_get_name($whereid)
{
    global $database_t_fibu_booking_where;

    $result = database_select_unique_value($database_t_fibu_booking_where, 'name', 'id = :1 or name = :2', [$whereid, $whereid], '');
    return $result;
}

function fibu_booking_where($where, $whatid = 0, $location = '')
{
    global $database_t_fibu_booking_where;

    $result = database_select_unique_value($database_t_fibu_booking_where, 'id', 'id = :1 or name = :2', [$where, $where], '');
    if ($result == '') {
        database_insert($database_t_fibu_booking_where, [$where, $whatid, $location]);
        $result = database_select_unique_value($database_t_fibu_booking_where, 'id', 'name = :1', [$where], '');
    }
    database_update($database_t_fibu_booking_where, 'lastwhatid = :1, location = :2', [$whatid, $location], 'id = :3', [$result]);
    return $result;
}
