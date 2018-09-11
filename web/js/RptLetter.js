// start print
window.onload = function(){
    factory.printing.leftMargin = 0.5;
    factory.printing.topMargin = 0.5;
    factory.printing.rightMargin = 0.5;
    factory.printing.bottomMargin = 0.5;
    factory.printing.header = "";
    factory.printing.footer = "";
    factory.printing.portrait = true;
    factory.printing.Print(true);
}
