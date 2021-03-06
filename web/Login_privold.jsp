<!DOCTYPE html>
<%@ page errorPage="ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="com.absys.user.*"%>
<%@ page import="org.jawin.DispatchPtr" %>
<%@ page import="org.jawin.win32.Ole32" %>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="nl.captcha.*"%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="include/ComConstants.inc" %>
<%@ include file="include/ComFunctions.inc" %>

<%
if ( !request.isSecure() || !request.getServerName().equals("labor.wda.gov.tw") ) {
//    response.sendRedirect("https://labor.wda.gov.tw:443/labweb/Login.jsp");
}


String pageHeader = "登入";
request.setCharacterEncoding("UTF-8");
//String thisPage = request.getRequestURI();
String thisPage = "Login.jsp";
String requestPage = AbString.rtrimCheck(request.getHeader("Referer") );
String requestUrl = "http://" + AbString.rtrimCheck( request.getHeader("Host") ) + thisPage;
requestUrl = appRoot + "/Login.jsp";

//定義變數
String userLogin = "";
String userName = "";
String userRegion = "";
String userDivision = "";
String userDivtitle = "";
String userAuthority = "";
String userDivregion = "";
String userCity = "";

Staff userData = null;
Modules modules = null;
Hashtable<String, String> pagemods = new Hashtable<String, String>();
String lastLogindate = "";
String lastLoginip = "";

String errMsg = "";
Connection conn = null;

//取得輸入資料
String userId = filterMetaCharacters( request.getParameter("userId") ).toUpperCase();
//String pwd = filterMetaCharacters( request.getParameter("password") );
String pwd = AbString.rtrimCheck( request.getParameter("password") );
String certdata = AbString.rtrimCheck( request.getParameter("certdata") );
//帳號類型
String acckind = filterMetaCharacters( request.getParameter("acckind") );

//分解憑證資料
String certtype = "";
String idno = "";
String name = "";
String beginDate = "";
String endDate = "";
String serialNo = "";
String[] certs = certdata.split(";");
if (certs.length >= 6) {
    certtype = filterMetaCharacters( certs[0] );
    idno = filterMetaCharacters( certs[1] );
    name = filterMetaCharacters( certs[2] );
    beginDate = filterMetaCharacters( certs[3] );
    endDate = filterMetaCharacters( certs[4] );
    serialNo = filterMetaCharacters( certs[5] );
    if (certtype.compareTo("1") != 0) errMsg = "不是自然人憑證或外人憑證";
//errMsg = beginDate;
}

String userAddr = AbString.rtrimCheck( request.getRemoteAddr() );

//建立連線
conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

//一般民眾進入查詢
if ( (userId.equalsIgnoreCase("GUEST") && idno.length() == 0) || (userId.equalsIgnoreCase("ESCNOTIFY") && idno.length() == 0) ){
    Captcha captcha = (Captcha) session.getAttribute(Captcha.NAME);
    String answer = filterMetaCharacters( request.getParameter("answer") );
    if ((captcha != null) && captcha.isCorrect(answer)) {
        //關閉連線
        if (conn != null) conn.close();
        session.setAttribute("userLogin", "N");
        session.setAttribute("userId", userId);
        session.setAttribute("userName", "");
        session.setAttribute("userRegion", "");
        session.setAttribute("userDivision", "");
        session.setAttribute("userDivtitle", "");
        session.setAttribute("userAddr", userAddr);
        session.setAttribute("userAuthority", userAuthority);
        session.setAttribute("gcaSN", serialNo);
        session.setAttribute("loginPage", "Login.jsp");
        if (userId.equalsIgnoreCase("GUEST") && idno.length() == 0) {
            response.sendRedirect("MainManager.jsp");
        } else if (userId.equalsIgnoreCase("ESCNOTIFY") && idno.length() == 0) {
            response.sendRedirect("escnotify/EscNotify.jsp");
        }
    } else {
        errMsg = "認證碼輸入錯誤" + answer;
    }
//仲介登入
} else if (userId.equals("AGENT") && idno.length() == 0) {
    boolean isOk = false;
    Statement stmt = conn.createStatement();
    String agno = filterMetaCharacters( request.getParameter("agno") );
    String qs = "select * from empage_agent where agno = " + AbSql.getEqualStr(agno);
    ResultSet rs = stmt.executeQuery(qs);
    if (rs.next()) {isOk = true;}
    rs.close();
    stmt.close();
    if (agno.equals("0000")) isOk = true;
    if (isOk) {
        //關閉連線
        if (conn != null) conn.close();
        session.setAttribute("userLogin", "Y");
        session.setAttribute("userId", agno);
        session.setAttribute("userName", "");
        session.setAttribute("userRegion", "");
        session.setAttribute("userDivision", "");
        session.setAttribute("userDivtitle", "");
        session.setAttribute("userDivregion", userRegion);
        session.setAttribute("userCity", "99");
        session.setAttribute("userAddr", userAddr);
        session.setAttribute("userAuthority", userAuthority);
        session.setAttribute("gcaSN", serialNo);
        session.setAttribute("loginPage", "Login.jsp");
        response.sendRedirect("labnotify/LabAgent.jsp");
    }
}

//if ((errMsg.length() == 0) && (userId.length() != 0) && (idnoName.length() != 0) && (thisPage.equals(requestUrl))) {
if ( (errMsg.length() == 0) && (
        ((acckind.equals("00")) && (userId.length() > 0) && (idno.length() > 0)) //自然人憑證、外人憑證
        || (acckind.equals("01") && (userId.length() > 0) && (pwd.length() > 0)) //帳號密碼
        ) ) {

    //檢查帳號
    userId = userId.toUpperCase();
    Statement stmt = conn.createStatement();
    String qs = "select staff.id id, acckind, pwd, descript, branch"
            + ", division.title divtitle, department, staff.region"
            + " from staff2 staff"
            + " left join division on staff.branch = division.id"
            + " where staff.Id=" + AbSql.getEqualStr(userId);
    ResultSet rs = stmt.executeQuery(qs);
    if (rs.next()) {
        boolean isAccount = false;
        if (acckind.equals("00")) { //自然人憑證、外人憑證
            String dbacckind = AbString.rtrimCheck(rs.getString("acckind"));
            if (!("00".equals(dbacckind) || "02".equals(dbacckind) ) ) {
                errMsg = "帳號類型錯誤！";
            } else if (!userId.endsWith(idno)) {
                errMsg = "帳號與身分證或居留證字號不符合！";
            } else {
                isAccount = true;
            }

            //憑證有效期限
            if (errMsg.length() == 0) {
                if (endDate.compareTo(AbDate.getToday()) < 0)
                    errMsg = "憑證已經過期，有效期限：" + endDate;
            }

            //廢止憑證查詢
            /*不查詢
            try {
                String crlfile;
                crlfile = "c:\\MOICA\\complete.crl.list";
                ArrayList snlist = new ArrayList();
                BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(crlfile), "ISO8859_1"));
                String lineText;
                while((lineText = reader.readLine()) != null)
                    snlist.add(lineText);
                reader.close();
                int pos = Arrays.binarySearch(snlist.toArray(), gcaSN);
                if (pos >= 0) errMsg = "憑證已經停用或廢止：" + gcaSN;
            } catch (Exception e) {
                errMsg = "廢止憑證檔讀取錯誤";
            } finally {
            }
            */

        } else if (acckind.equals("01")) { //帳號密碼
            if ( "01".equals( AbString.rtrimCheck(rs.getString("acckind")) ) ) {
                //密碼解碼
                String dbPwd = AbString.rtrimCheck(rs.getString("pwd"));
                if (dbPwd.length() > 0) {
                    com.absys.util.AbEncrypter encrypter = new com.absys.util.AbEncrypter( com.absys.util.AbEncrypter.DESEDE_ENCRYPTION_SCHEME );
                    try {
                        dbPwd = encrypter.decrypt( dbPwd );
                    } catch (Exception e) {}
                }
                if (dbPwd.equals(pwd)) {
                    isAccount = true;
                }
            }

        }

        //憑證正確
        if (isAccount) {
            userName = AbString.rtrimCheck(rs.getString("descript"));
            userDivision = AbString.rtrimCheck(rs.getString("branch"));
            userRegion = AbString.rtrimCheck(rs.getString("region"));
            userDivtitle = AbString.rtrimCheck(rs.getString("divtitle"));
            userCity = userDivision.substring(2);
            if (userCity.equals("00")) userCity = "*";
            userLogin = "Y";

            Connection conn2 = getConnection( session );
            Statement stmt2 = conn2.createStatement();

            //讀取網頁模組對照表
            ResultSet rs2 = stmt2.executeQuery("select * from syspagemod order by pageid");
            while (rs2.next()) {
                pagemods.put( AbString.rtrimCheck(rs2.getString("pageid")),
                        AbString.rtrimCheck(rs2.getString("modid")) );
            }
            rs2.close();

            //取得資料
            userData = new Staff(stmt2, "staff2", userId);
            //取得功能模組參數
            modules = new Modules(stmt2);

            //組合權限，與舊的相容
            for (int i=0; i < modules.modulelist.size(); i++) {
                if (i <= 4) {
                    if (modules.hasPrivelege(i, userData.privilege)) userAuthority += "1";
                    else  userAuthority += "0";
                }
                for (int j=0; j < modules.modulelist.get(i).subModule.size(); j++) {
                    if (modules.hasPrivelege(i, j+1, userData.privilege)) userAuthority += "1";
                    else  userAuthority += "0";
                }
                if (i == 2) userAuthority += "0";
            }
            qs = "update staff2 set logindate = sysdate"
                    + " where id=" + AbSql.getEqualStr(userData.id);
            stmt2.executeUpdate(qs);

            stmt2.close();
            conn2.close();

        } else {
            if (errMsg.length() == 0) errMsg = "對不起! 帳號密碼錯誤";
        }
    } else {
        errMsg = "對不起! 帳號錯誤";
    }
    if (rs != null) rs.close();
}

//公佈欄
String bulletin = "";
if (conn != null) {
    Statement stmt = conn.createStatement();
    String qs = "select data from param where id = 'bulletin'";
    ResultSet rs = stmt.executeQuery(qs);
    if (rs.next()) bulletin = rs.getString(1).trim();
    rs.close();
    stmt.close();
}

//關閉連線
if (conn != null) conn.close();

//登入正確
if (userLogin.equals("Y")) {
    session.setAttribute("userLogin", userLogin);
    session.setAttribute("userId", userId);
    session.setAttribute("userName", userName);
    session.setAttribute("userRegion", userRegion);
    session.setAttribute("userDivision", userDivision);
    session.setAttribute("userDivtitle", userDivtitle);
    session.setAttribute("userDivregion", userRegion);
    session.setAttribute("userCity", userCity);
    session.setAttribute("userAddr", userAddr);
    session.setAttribute("gcaSN", serialNo);
    session.setAttribute("userAuthority", userAuthority);

    session.setAttribute(appName+"_userData", userData);
    session.setAttribute(appName+"_modules", modules);
    session.setAttribute(appName+"_pagemods", pagemods);

    session.setAttribute("loginPage", "Login.jsp");
    response.sendRedirect("MainManager.jsp");
}
%>

<html>
<head>

    <%@ include file="include/Header.inc" %>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10">

    <link rel="stylesheet" type="text/css" href="<%=appRoot%>/resources/css/absys0.css" />

    <script language="javascript">
        //顯示整頁
        if (window != top) {
            top.location.href = location.href;
        }
    </script>

    <script language="JavaScript">
        //驗證 IC 卡
        function gcaVerify(frm) {
            var retval = false;
            var certdata = "";
            var msg = "";
            if (frm.userId.value.length == 0) {
                alert("請輸入帳號");
                return false;
            }
            if (frm.password.value.length == 0) {
                alert("請輸入密碼");
                return false;
            }

            //執行驗證程式
            var rc = "99999";
            try {
                //檢查密碼
                //alert(AbsysGPKI);
                rc = AbsysGPKI.verifyPassword(frm.password.value);
                //rc = rc.substring(0, 8);
                if (rc != "0") {
                    if (rc == "10001") {
                        msg = "IC卡起始錯誤，請檢查讀卡機";
                    } else if (rc == "10002") {
                        msg = "IC卡釋放錯誤，請檢查讀卡機";
                    } else if (rc == "10003") {
                        msg = "IC卡讀取錯誤，請檢查讀卡機";
                    } else if (rc == "20001") {
                        msg = "PIN碼輸入錯誤 - 第一次";
                    } else if (rc == "20002") {
                        msg = "PIN碼輸入錯誤 - 第二次";
                    } else if ((rc== "DA0000A0") || (rc == "DA0000A1") || (rc == "DA0000A2")) {
                        msg = "PIN碼輸入錯誤";
                    } else if ((rc == "20003") || (rc == "DA0000A4")) {
                        msg = "PIN碼連續三次錯誤，PIN碼已被鎖住，請解鎖後再操作一次";
                    } else if (rc == "20004") {
                        msg = "PIN碼輸入錯誤";
                    } else {
                        msg = "錯誤代碼：" + rc + " 不明例外錯誤";
                    }
                } else {
                    //取得憑證
                    certdata = AbsysGPKI.getCertData();
                    if (certdata == "10001") {
                        msg = "IC卡起始錯誤，請檢查讀卡機";
                    } else if (certdata == "10002") {
                        msg = "IC卡釋放錯誤，請檢查讀卡機";
                    } else if (rc == "10003") {
                        msg = "IC卡讀取錯誤，請檢查讀卡機";
                    } else if (certdata == "30001") {
                        msg = "無法取得IC卡憑證";
                    } else if (certdata == "30002") {
                        msg = "解析憑證錯誤";
                    } else if (certdata.substr(0, 5) == "30003") {
                        msg = "卡片不對" + certdata.substr(5);
                    } else {
                        retval = true;
                        frm.certdata.value = certdata;
                    }
                }
            } catch (e) {
                msg = "ActiveX GPKI 程式載入錯誤" + rc;
            }

            //顯示錯誤訊息
            if (msg != "") {
                alert(msg);
                frm.userId.value = "";
                frm.password.value = "";
                frm.userId.focus();
            }
            return retval;
        }
    </script>

</head>

<body bgcolor="#F9CD8A" style="border:0px; margin:0px; padding:0px; overflow:auto;">

    <OBJECT hidden id="AbsysGPKI" codebase="activex/AbsysGPKI.cab#version=7,0,7,1" classid="clsid:02086B79-8A32-4613-B28A-391E544E9AE9" width="0" height="0"></OBJECT>

    <center>

    <div style="margin:0px; padding: 0px 0px 0px 0px;">
        <img src="image/top_homepage.gif" alt="美化圖形" style="width:780px; height:60px;">
    </div>

    <div style="margin:0px; padding: 0px 0px 0px 0px;">
        <img src="image/welcome.gif" alt="歡迎光臨使用外國人查詢系統" style="width:27%; height:27%">
    </div>
    <div style="margin:0px; padding: 10px 0px 0px 0px;">
    </div>


<!--
    <marquee scrollamount='5' direction= 'left' width='650' id=xiaoqing height='20' style="color: #FF0000; font-size: 15pt; font-weight: bold; font-family:新細明體">
    將於本週六日(12/17-12/18)進行大樓變電室主動式濾波器增設提昇電力品質工程，中斷所有網路服務，造成不便，敬請見諒。
    </marquee>
-->

    <table width=780 style="border:3px double #FF9900;">
        <tr>
            <td bgcolor="#FF9900" align="" width="20%">
                <font color="#FFFFFF"><b>公告訊息</b></font>
            </td>
            <td align="left" style="border:1px solid #FF9900;">
                <font color="#990000">本系統使用自然人憑證驗證程式ActiveX元件，登入本網頁時會由IE自動下載此元件，若發生無法下載元件時，請自行修改IE安全性設定，讓ActiveX元件能自動下載及執行。<br>
                第一次使用本系統的電腦，建議請先到<a href="https://gca.nat.gov.tw">GCA政府憑證總管理中心首頁</a>後，再進入本系統。</font>
                <font color="#ff0000"><b>※操作有疑問時，請洽客服專線 02-8521-9009</b></font>
            </td>
        </tr>
    </table>

    <table width=780 style="border:3px double #FF9900; margin-top:5px;">
        <tr >
            <td bgcolor="#FF9900" align="" width="20%">
                <font color="#FFFFFF">
                <b>公務機關<br>授權登入</b>
                </font>
            </td>
            <td align="left" valign=top width="40%" style="border:1px solid #FF9900;">
                <form method=post action="" name="form1" onsubmit="return gcaVerify(this);">
                    <font color="#ff0000">自然人憑證登入：</font><br><font color="#0066CC">身分證字號
                    <input name=userId maxlength=10 style="width:100px;"><br>
                    　憑證密碼</font>
                    <input name=password type=password autocomplete="off" maxlength=20 style="width:100px;">
                    <input type="hidden" name="certdata" value="">
                    <input type="hidden" name="acckind" value="00">
                    <input type="submit" style="width:50px;" value="登入">
                </form>
            </td>
            <td align="left" valign=top width="40%" style="border:1px solid #FF9900;">
                <form method=post action="">
                    <font color="#ff0000">授權帳密型登入：</font><br><font color="#0066CC">帳號
                    <input name=userId maxlength=20 style="width:100px;"><br>
                    <font color="#0066CC">密碼</font>
                    <input name=password type=password autocomplete="off" maxlength=20 style="width:100px;">
                    <input type="hidden" name="acckind" value="01">
                    <input type="submit" style="width:50px;" value="登入">
                </form>
            </td>
        </tr>
    </table>

    <table width=780 style="border:3px double #FF9900; margin-top:5px;">
        <tr>
            <td bgcolor="#FF9900" align="" width="20%" rowspan="3">
                <font color="#FFFFFF">
                <b>雇主或<br>仲介公司登入</b>
                </font><br>認證碼<br>
                <img src="AbsysCaptcha.png" width="120" height="30" onclick="this.src='AbsysCaptcha.png?'+(new Date()).getTime();"/><br>
            </td>
        	  <td align="left" valign=top width="80%" style="border:1px solid #FF9900;" >
                <form method=post action="">
                    <font color="#ff0000">查詢外勞資料：</font><font color="#0066CC">請先輸入認證碼
                    <input type="text" name=answer maxlength=6 style="width:100px;">
                    <input type="hidden" name="userId" value="GUEST">
                    <input type="submit" style="width:50px;" value="登入">
                </form>
            </td>
        <tr>
            <td align="left" valign=top width="" style="border:1px solid #FF9900;">
                <form method=post action="" onsubmit="alert('失聯外勞之通報應由雇主或委任仲介辦理');">
                    <font color="#ff0000">外勞行蹤不明3日內通報：</font><font color="#0066CC">請先輸入認證碼</font>
                    <input type="text" name=answer maxlength=6 style="width:100px;">
                    <input type="hidden" name="userId" value="ESCNOTIFY">
                    <input type="submit" style="width:50px;" value="登入">
                </form>
                ※行蹤不明滿三日，請至「<a href="https://fwapply.wda.gov.tw/efpv/wSite/Control?function=IndexPage">外籍勞工申請案件網路線上申辦系統</a>」申報。<br>
                ※外勞行蹤不明廢止聘僱許可進度查詢，可連結至<a href="http://qry.wda.gov.tw/labweb/qrycase/QryCaseMain.jsp">外籍勞工申辦案件進度查詢</a>。
                <br>※<font color="#ff0000">雇主或仲介公司登錄外勞名冊系統</font>，請從勞動力發展署首頁中的跨國勞動力服務/外籍勞工業務項目登入。
            </td>
        </tr>
    </table>

</body>
</html>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>

