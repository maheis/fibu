<?php

//CREATE-Statement
database_exec('CREATE TABLE IF NOT EXISTS fibu_budget (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    credit FLOAT DEFAULT 0 NOT NULL
);');

//INSERT
// [$id, $name, $credit]

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
$database_t_fibu_budget = [
    'TABLE' => 'fibu_budget',
    'RW' => 1,
    'NAME' => 'Budgets',
    'ORDER' => 'name',
    'COLUMNS' => [
        'id' => ['NAME' => 'ID', 'RW' => 0, 'TYPE' => 'INT', 'SIZE' => 'smallest', 'HIDDEN' => 1],
        'name' => ['NAME' => 'Budget', 'RW' => 1, 'TYPE' => 'TEXT', 'SIZE' => '', 'REQUIRED' => 1],
        'credit' => ['NAME' => 'Guthaben', 'RW' => 1, 'TYPE' => 'FLOAT', 'SIZE' => 'smaller', 'REQUIRED' => 1],
    ]
];

global $database_t_array;
array_push($database_t_array, $database_t_fibu_budget);


function fibu_budget_get_name($budgetid)
{
    global $database_t_fibu_budget;

    $result = database_select_unique_value($database_t_fibu_budget, 'name', 'id = :1 or name = :2', [$budgetid, $budgetid], '');

    return $result;
}
