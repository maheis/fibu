<?php include('auth/auth.php'); ?>

<?php $heading = 'Übersicht <i class="fad fa-piggy-bank fa-fw"></i>'; ?>
<?php include('core/head.php'); ?>

<table class="withBorder">
    <thead>
        <tr>
            <th style="width: 60px;"></th>
            <th>Konto</th>
            <th style="width: 85px;">Guthaben</th>
            <th style="width: 125px; text-align: center;">
                <button class="tiny green" onclick="dialogOpen('addAccount');"><i
                        class="far fa-plus-circle fa-fw"></i></button>
            </th>
        </tr>
    </thead>
    <tbody>
        <?php
        $resultset = database_select($database_t_fibu_account);
        $sum = 0;

        foreach ($resultset as $result) {
            if (!$result['issubaccount']) {
                $sum = $sum + $result['credit'];
            }

            echo '<tr>';
            echo '<td><button class="tiny blue" onclick="dialogOpen(\'infoAccount_' . $result['id'] . '\');"><i class="fa fa-question-circle fa-fw"></i></button>';
            if ($result['onlinebanking'] === "") {
                echo '<a class="button tiny gray" href=""><i class="far fa-university fa-fw"></i></a></td>';
            } else {
                echo '<a class="button tiny blue" target="_newtab" href="' . $result['onlinebanking'] . '"><i class="far fa-university fa-fw"></i></a></td>';
            }

            echo '<td>' . $result['name'] . '</td>';
            if (!(strpos($result['credit'], "-") === 0)) {
                echo '<td style="color: #81C784; text-align: right;' . ($result['issubaccount'] ? ' font-style: oblique;' : '') . '">' . number_format($result['credit'], 2, ',', '') . '&nbsp;€</td>';
            } else {
                echo '<td style="color: #E57373; text-align: right;' . ($result['issubaccount'] ? ' font-style: oblique;' : '') . '">' . number_format($result['credit'], 2, ',', '') . '&nbsp;€</td>';
            }
            echo '<td style="text-align: center">';
            echo '<button class="tiny orange" onclick="dialogOpen(\'editAccount_' . $result['id'] . '\');"><i class="far fa-pencil fa-fw"></i></button>';
            echo '<a class="button tiny blue" href="index.php?ReURL=bookings&filter=' . urldecode('Konto:' . $result['name']) . '"><i class="far fa-filter fa-fw"></i></a>';
            echo '<a class="button tiny green" href="index.php?ReURL=booking&accountid=' . $result['id'] . '"><i class="far fa-shopping-cart fa-fw"></i></a>';
            echo '</td>';
            echo '</tr>';
        }

        $sum = number_format($sum, 2, ',', '');
        echo '<tr class="Sum">';
        echo '<td></td>';
        echo '<td style="text-align: right; font-weight: bold">Summe</td>';
        if (!(strpos($sum, "-") === 0)) {
            echo '<td style="color: #81C784; text-align: right; font-weight: bold">' . $sum . '&nbsp;€</td>';
        } else {
            echo '<td style="color:#E57373; text-align: right; font-weight: bold">' . $sum . '&nbsp;€</td>';
        }
        echo '<td></td>';
        echo '</tr>';
        ?>
    </tbody>
</table>

<?php
echo '<dialog id="addAccount">';
database_select_1pager_add($database_t_fibu_account, 'index.php');
echo '</dialog>';

foreach ($resultset as $result) {
    echo '<dialog id="infoAccount_' . $result['id'] . '">';
    database_select_1pager($database_t_fibu_account, '*', 'id = :1', [$result['id']]);
    echo '</dialog>';

    echo '<dialog id="editAccount_' . $result['id'] . '">';
    database_select_1pager_edit($database_t_fibu_account, 'id = :1', [$result['id']], 'index.php');
    echo '</dialog>';
}
?>

<br />

<table class="withBorder">
    <thead>
        <tr>
            <th style="width: 60px;"></th>
            <th>Budget</th>
            <th style="width: 85px;">Guthaben</th>
            <th style="width: 125px; text-align: center;">
                <button class="tiny green" onclick="dialogOpen('addBudget');"><i
                        class="far fa-plus-circle fa-fw"></i></button>
            </th>
        </tr>
    </thead>
    <tbody>
        <?php
        $resultset = database_select($database_t_fibu_budget);
        $sum = 0;

        foreach ($resultset as $result) {
            $sum = $sum + $result['credit'];

            echo '<tr>';
            echo '<td><button class="tiny blue" onclick="dialogOpen(\'infoBudget_' . $result['id'] . '\');"><i class="fa fa-question-circle fa-fw"></i></button>';

            echo '<td>' . $result['name'] . '</td>';
            if (!(strpos($result['credit'], "-") === 0)) {
                echo '<td style="color: #81C784; text-align: right;">' . number_format($result['credit'], 2, ',', '') . '&nbsp;€</td>';
            } else {
                echo '<td style="color: #E57373; text-align: right;">' . number_format($result['credit'], 2, ',', '') . '&nbsp;€</td>';
            }
            echo '<td style="text-align: center">';
            echo '<button class="tiny orange" onclick="dialogOpen(\'editBudget_' . $result['id'] . '\');"><i class="far fa-pencil fa-fw"></i></button>';
            echo '<a class="button tiny blue" href="index.php?ReURL=bookings&filter=' . urldecode('Budget:' . $result['name']) . '"><i class="far fa-filter fa-fw"></i></a>';
            echo '<a class="button tiny green" href="index.php?ReURL=booking&budgetid=' . $result['id'] . '"><i class="far fa-shopping-cart fa-fw"></i></a>';
            echo '</td>';
            echo '</tr>';
        }

        $sum = number_format($sum, 2, ',', '');
        echo '<tr class="Sum">';
        echo '<td></td>';
        echo '<td style="text-align: right; font-weight: bold">Summe</td>';
        if (!(strpos($sum, "-") === 0)) {
            echo '<td style="color: #81C784; text-align: right; font-weight: bold">' . $sum . '&nbsp;€</td>';
        } else {
            echo '<td style="color:#E57373; text-align: right; font-weight: bold">' . $sum . '&nbsp;€</td>';
        }
        echo '<td></td>';
        echo '</tr>';
        ?>
    </tbody>
</table>

<?php
echo '<dialog id="addBudget">';
database_select_1pager_add($database_t_fibu_budget, 'index.php');
echo '</dialog>';

foreach ($resultset as $result) {
    echo '<dialog id="infoBudget_' . $result['id'] . '">';
    database_select_1pager($database_t_fibu_budget, '*', 'id = :1', [$result['id']]);
    echo '</dialog>';

    echo '<dialog id="editBudget_' . $result['id'] . '">';
    database_select_1pager_edit($database_t_fibu_budget, 'id = :1', [$result['id']], 'index.php');
    echo '</dialog>';
}
?>

<?php include_once('core/footer.php'); ?>