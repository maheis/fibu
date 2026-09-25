<?php

$DatabaseVersion = intval(config('database_modul_version_fibu', -99));
if ($DatabaseVersion == -99) {
    $DatabaseVersion = intval(config('database_modul_version_fibu', -99));
    if ($DatabaseVersion >= 0) {
        database_insert($database_t_core_config, ['database_modul_version_fibu', $DatabaseVersion, 'INT', 'main', '']);
        database_delete($database_t_core_config, 'key = :1', ['database_modul_version_fibu']);
    } else {
        database_insert($database_t_core_config, ['database_modul_version_fibu', '-1', 'INT', 'main', '']);
    }
}

// database_exec('drop table if exists fibu_account');
// database_exec('drop table if exists fibu_analysis');
// database_exec('drop table if exists fibu_booking_recurring');
// database_exec('drop table if exists fibu_booking_what');
// database_exec('drop table if exists fibu_booking_where_geo');
// database_exec('drop table if exists fibu_booking_where');
// database_exec('drop table if exists fibu_booking');
// database_exec('drop table if exists fibu_budget');

if ($DatabaseVersion <= 0) {
    database_update($database_t_core_config, 'value = :1', ['fibu'], 'key = :2', ['title']);
    database_update($database_t_core_config, 'value = :1', ['Wer den Pfennig nicht ehrt ...'], 'key = :2', ['title_subtitle']);
    database_update($database_t_core_config, 'value = :1', [1], 'key = :2', ['with_global_auth']);
    database_update($database_t_core_config, 'value = :1', [1], 'key = :2', ['with_geolocation']);
    database_update($database_t_core_config, 'value = :1', [1], 'key = :2', ['with_geolocation']);
    database_update($database_t_core_config, 'value = :1', [0], 'key = :2', ['with_search']);
    database_update($database_t_core_config, 'value = :1', ['modules/fibu/favicon.ico'], 'key = :2', ['favicon']);
    database_update($database_t_core_config, 'value = :1', ['modules/fibu/piggy-bank.png'], 'key = :2', ['header_logo']);

    database_update($database_t_core_config, 'value = :1', [1], 'key = :2', ['database_modul_version_fibu']);
}