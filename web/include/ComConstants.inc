<%@ page pageEncoding="UTF-8" %>

<%
    //no chche
//    response.setHeader("Pragma", "No-cache");
//    response.setHeader("Cache-Control", "no-cache");
//    response.setDateHeader("Expires", 0);

    //系統名稱與路徑
    String appTitle = "全國外籍勞工動態查詢系統";
    String appName = "labweb";
    String appRoot = "/labweb";
    String extPath = "/labweb/ext321";
    //資料庫參數
    //SQL Server
    //String databaseName = "SQLServer";
    //String sqlFirstCmd = " top ";
    //String sqlSubstring = "substring";
    //String fun_length = "len";
    //Informix
    //String databaseName = "Informix73";
    //String sqlFirstCmd = " first ";
    //String sqlSubstring = "substr";
    //String fun_length = "length";
    //Oracle
    String databaseName = "Oracle";
    String sqlFirstCmd = "";
    String sqlSubstring = "substr";
    String fun_length = "length";

    String evtaId = "0000";
    int maxPrintItem = 500;
    int timeout = 90; //分鐘

    //系統權限位置
    int AUSUPER = 0;
    int AUDOWN = 1;
    int AUBLUE = 2;
    int AUCHINESE = 3;
    int AUWHITE = 4;
    int AUCLRTRANS = 5;

    //通報系統權限位置 {上載作業、單筆輸入作業、列印作業、註銷作業、註記作業} 2011.01.14
    int AU_UPLOAD = 0; int AU_AMEND = 1; int AU_PRINT = 2; int AU_ABOLISH = 3; int AU_MEMO = 4;
    int AUNOTIFY_A[] = {6, 7, 8, 9, 10};
    int AUNOTIFY_B[] = {11, 12, 13, 14, 15};
    int AUNOTIFY_C[] = {16, 17, 18, 19, 20};
    int AUNOTIFY_D[] = {21, 22, 23, 24, 25};


    String[] natcodes = {"009", "024", "019", "030", "033", "021"};
    String[] natnames = {"印尼", "菲律賓", "馬來西亞", "泰國", "越南", "蒙古"};

    String[] bizcodes = {"BEVWZJLaHGFDK", "BEVWZJLa", "H", "G", "F", "DK"};
    String[] bizkinds = {"製造業", "營造業", "家庭幫傭", "家庭看護工", "養護工", "漁工"};

    String[] wpbizcodes = {"1", "2", "3", "4", "5", "6", "7", "8", "9"};
    String[] wpbizkinds = {"製造業", "營造業", "看護工", "家庭幫傭", "漁船,養護機構及其它", "特殊", "白領", "就安", "養護"};

    String logEmpList = "EmpList";
    String logAddrList = "AddrList";
    String logEmpAgent = "EmpAgent";
    String logEmpApply = "EmpApply";
    String logEmpName = "EmpName";
    String logEmpIllegal = "EmpIllegal";
    String logWpgnamd = "Wpgnamd";
    String logLaborData = "LaborData";
    String logLaborWkaddr = "LaborWkaddr";
    String logLaborDayintw = "LaborDayintw";
    String logLaborStatus = "LaborStatus";
    String logLaborEscape = "LaborEscape";
    String logStat = "Stat";
    String logChinese = "Chinese";

    //特殊外勞 2017.08.22
    String logSPLabor = "SPLabor";
    String logSPVend = "SPVend";

    String logWflaborData = "WflaborData";
    String logWfempName = "WfempName";
    String logWfempList = "WfempList";

    String logQryCase = "QryCase";

    String logClrtransdate = "logClrtransdate";

    String logEmpKind = "EmpKind";

    String logLaborWp065 = "LaborWp065";

%>