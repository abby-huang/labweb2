<%@ page pageEncoding="UTF-8" %>

<%
    //取得登入資料
    String userLogin = strCheckNull((String)session.getAttribute("userLogin"));
    String userId = strCheckNull((String)session.getAttribute("userId"));
    String userName = strCheckNull((String)session.getAttribute("userName"));
    String userRegion = strCheckNull((String)session.getAttribute("userRegion"));
    String userDivision = strCheckNull((String)session.getAttribute("userDivision"));
    String userDivtitle = strCheckNull((String)session.getAttribute("userDivtitle"));
    String userAddr = strCheckNull((String)session.getAttribute("userAddr"));
    String gcaSN = strCheckNull((String)session.getAttribute("gcaSN"));

    String userAuthority = AbString.leftJustify(AbString.rtrimCheck((String)session.getAttribute("userAuthority")), 255);
    String userOpsuper = (userAuthority.charAt(AUSUPER) == '1') ? "Y" : "N";
    String userOpdown = (userAuthority.charAt(AUDOWN) == '1') ? "Y" : "N";
    String userOpblue = (userAuthority.charAt(AUBLUE) == '1') ? "Y" : "N";
    String userOpchinese = (userAuthority.charAt(AUCHINESE) == '1') ? "Y" : "N";
    String userOpwhite = (userAuthority.charAt(AUWHITE) == '1') ? "Y" : "N";
    String userOpclrtrans = (userAuthority.charAt(AUCLRTRANS) == '1') ? "Y" : "N";

    com.absys.user.Staff userData = (com.absys.user.Staff)session.getAttribute(appName+"_userData");
    com.absys.user.Modules modules = (com.absys.user.Modules)session.getAttribute(appName+"_modules");

    //清空 trans_date，重傳資料作業。原本有規劃clrTransdateID要回寫chng_id，但後來沒有用上
    String userOptrans_weisen = "N"; //疾管署
    String userOptrans_linwu = "N"; //外交部領務局
    String userOptrans_genchen = "N"; //移民署
    String clrTransdateID = "";
    if (userDivision.equals(evtaId)) {
        //本署及廠商
        userOptrans_weisen = "Y";
        userOptrans_linwu = "Y";
        //clrTransdateID = "E";
    } else if (userDivision.equals("0039")) {
        //疾管署
        userOptrans_weisen = "Y";
        //clrTransdateID = "H";
    } else if (userDivision.equals("0031")) {
        //領務局
        userOptrans_linwu = "Y";
        //clrTransdateID = "V";
    } else if (userDivision.equals("0037")) {
        //移民署
        userOptrans_genchen = "Y";
        //clrTransdateID = "";
    }

    //除錯
    session.setAttribute("debugMsg", "");
    boolean debug = false;
    if ("F120539973,G120066663,V120469675,Y220525402".indexOf(userId) >= 0) debug = true;
%>
