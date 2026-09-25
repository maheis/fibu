<!-- überschreibt den footer, muss geprüft werden wie der zusätzlich gepostet werden kann -->
<tr>
    <td colspan="3" style="text-align: center; width: auto;">
        <input style="width: 75%; min-width: 150px;" id="calc" type="text" placeholder="Taschenrechner..."
            oninput="calculator(this.value, 2)"> = <input disabled="disabled"
            style="width: 5%; min-width: 50px; text-align: center;" id="result" type="text" placeholder="0" value="">
    </td>
</tr>

<?php // $footerheight += 40; ?>