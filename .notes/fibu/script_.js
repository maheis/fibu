function where_what() {
    var ListAllByTag = document.getElementsByTagName("where_what");
    var Element_where = document.getElementById('whereid0');
    var Element_what = document.getElementById('whatid0');

    for (i = 0; i < ListAllByTag.length; i++) {
        str = ListAllByTag[i].innerHTML;

        if (Element_where) {
            if (Element_what) {
                n = str.search(Element_where.value);

                if (n > -1) {
                    Element_what.value = str.replace(Element_where.value + ":", "");
                }
            }
        }
    }
}