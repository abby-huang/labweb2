<!DOCTYPE HTML>
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
//String pwd = filterMetaCharacters( request.getParameter("pwd") );
String pwd = AbString.rtrimCheck( request.getParameter("pwd") );
//帳號類型
String acckind = filterMetaCharacters( request.getParameter("acckind") );

String userAddr = AbString.rtrimCheck( request.getRemoteAddr() );

//建立連線
conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

//一般民眾進入查詢
if ( (userId.equalsIgnoreCase("GUEST")) || (userId.equalsIgnoreCase("ESCNOTIFY")) ){
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
        session.setAttribute("loginPage", "Login.jsp");
        if (userId.equalsIgnoreCase("GUEST")) {
            response.sendRedirect("MainManager.jsp");
        } else if (userId.equalsIgnoreCase("ESCNOTIFY")) {
            response.sendRedirect("escnotify/EscNotify.jsp");
        }
    } else {
        errMsg = "認證碼輸入錯誤" + answer;
    }
//仲介登入
} else if (userId.equals("AGENT")) {
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
        session.setAttribute("loginPage", "Login.jsp");
        response.sendRedirect("labnotify/LabAgent.jsp");
    }
}

//if ((errMsg.length() == 0) && (userId.length() != 0) && (idnoName.length() != 0) && (thisPage.equals(requestUrl))) {
if ( (errMsg.length() == 0) && (
        (acckind.equals("00") && (userId.length() > 0)) //自然人憑證
        || (acckind.equals("01") && (userId.length() > 0) && (pwd.length() > 0)) //帳號密碼
        ) ) {

    //檢查帳號
    userId = userId.toUpperCase();
    Statement stmt = conn.createStatement();
    String qs = "select staff.id id, acckind, pwd, descript, branch"
            + ", division.title divtitle, department"
            + " from staff2 staff"
            + " left join division on staff.branch = division.id"
            + " where staff.Id=" + AbSql.getEqualStr(userId);
    ResultSet rs = stmt.executeQuery(qs);
    if (rs.next()) {
        boolean isAccount = false;
        if (acckind.equals("00")) { //自然人憑證

            String sigb64 = AbString.rtrimCheck( request.getParameter("b64SignedData") );
            common.GpkiPkcs7 pkcs7 = new common.GpkiPkcs7(sigb64);
            if (!"00".equals( AbString.rtrimCheck(rs.getString("acckind")) ) ) {
                errMsg = "帳號類型錯誤！";
            } else if (!pkcs7.verifySignature()) {
                errMsg = "簽章驗證錯誤！";
            } else if (!pkcs7.getCertType().equals("MOICA")) {
                errMsg = "不是自然人憑證：" + pkcs7.getCertType();
            } else {
                int ocspStatus = pkcs7.getOcspStatus();
                if (ocspStatus != 0) { //憑證狀態已被廢止
                    errMsg = "憑證已被廢止，狀態代碼：" + ocspStatus;
                } else {
                    String idno = pkcs7.getPersonId();
                    if (!userId.endsWith(idno)) {
                        errMsg = "帳號與身分證字號不符合！";
                    } else {
                        isAccount = true;
                    }
                }
            }

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
            userRegion = AbString.rtrimCheck(rs.getString("department"));
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
            stmt2.close();
            conn2.close();

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
    session.setAttribute("userAuthority", userAuthority);

    session.setAttribute(appName+"_userData", userData);
    session.setAttribute(appName+"_modules", modules);
    session.setAttribute(appName+"_pagemods", pagemods);

    session.setAttribute("loginPage", "LoginX.jsp");
    response.sendRedirect("MainManager.jsp");
}
%>

<html>
<head>
    <%@ include file="include/Header.inc" %>

    <META http-equiv="X-UA-Compatible" content="IE=EDGE,CHROME=1">
    <!--meta http-equiv="Content-Security-Policy" content="upgrade-insecure-requests"-->

    <script language="javascript">
        //起始參數
        var sysErrMsg = '<%=errMsg%>';
        //顯示整頁
        if (window != top) {
            top.location.href = location.href;
        }
    </script>

    <!-- jquery -->
    <script src="/labweb/labsys/js/jQuery/jquery-3.2.0.min.js" type="text/javascript"></script>
    <link href="/labweb/labsys/js/jQuery/jquery-ui-redmond/jquery-ui.min.css" rel="stylesheet" type="text/css" />
    <script src="/labweb/labsys/js/jQuery/jquery-ui-redmond/jquery-ui.js"></script>

    <script src="/labweb/labsys/js/errorcode.js" type="text/javascript"></script>
    <link rel="stylesheet" type="text/css" href="<%=appRoot%>/resources/css/absys0.css" />
    <script src="Login.js?v=1.0" type="text/javascript"></script>


    <style>
        /* Dialogs 字型按鍵大小 */
        .ui-dialog{font-size: 13px;}
        /* Dialogs 按鍵位置 */
        .ui-dialog .ui-dialog-buttonpane .ui-dialog-buttonset {
            text-align: center;
            float: none !important;
        }
    </style>

</head>

<body bgcolor="#F9CD8A" style="border:0px; margin:0px; padding:0px; overflow:auto;">

    <div style="height:0px; margin:0px; padding: 0px 0px 0px 0px;"><span id="httpObject"></span></div>

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
    本系統將於104年12月26日上午8點中斷所有網路服務，預計104年12月27日晚上22點恢復正常作業。
    </marquee>
-->

    <table width=780 style="border:3px double #FF9900;">
        <tr>
            <td bgcolor="#FF9900" align="" width="20%">
                <font color="#FFFFFF"><b>公告訊息</b></font>
            </td>
            <td align="left" style="border:1px solid #FF9900;">
                <font color="#990000">使用者登入本系統若發生問題時，請按此處下載<a href="activex\AbsysGPKI.exe">手動安裝程式</a>，下載存檔後請先重開機，再執行該程式安裝ActiveX驗證程式(安裝時務必關閉所有IE瀏覽器)。<br>
                第一次使用本系統的電腦，請先到政府憑證總管理中心<a href="http://grca.nat.gov.tw/pse/index.html">GRCA自簽憑證自動安裝網頁</a>後，再進入本系統。</font>
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
                <form id="pinForm" name="pinForm" action="" method="post" onsubmit="return verifyMoica();">
                    <font color="#ff0000">自然人憑證登入：</font><br><font color="#0066CC">身分證字號
                    <input name=userId maxlength=10 style="width:100px;"><br>
                    　憑證密碼</font>
                    <input name="pwd" type="password" autocomplete="off" maxlength=20 style="width:100px;">
                    <input type="hidden" name="certdata" value="">
                    <input type="hidden" name="acckind" value="00">
					<input type="hidden" id="b64SignedData" name="b64SignedData">
                    <input type="submit" style="width:50px;" value="登入">
                </form>
            </td>
            <td align="left" valign=top width="40%" style="border:1px solid #FF9900;">
                <form method=post action="">
                    <font color="#ff0000">授權帳密型登入：</font><br><font color="#0066CC">帳號
                    <input name=userId maxlength=20 style="width:100px;"><br>
                    <font color="#0066CC">密碼</font>
                    <input name="pwd" type="password" autocomplete="off" maxlength=20 style="width:100px;">
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
            </td>
        </tr>
        <tr>
            <td align="left" valign=top width="" style="border:1px solid #FF9900;">
                <form method=post action="">
                    <font color="#ff0000">雇主或仲介公司登錄外勞名冊系統：</font><a href="https://fwi.wda.gov.tw/labor/labor_login.jsp">請按這裏</a></font><br>
                    <font color="#ff0000"><b>※登錄外勞名冊，操作有疑問時，請洽客服專線 04-37020625 轉分機9</b></font>
                </form>
            </td>
        </tr>
    </table>




    <!-- =================================================================================== -->
    <!-- 對話視窗 Dialogs =================================================================== -->

    <!-- 系統錯誤訊息 -->
    <div title="訊息提示" id="dlgSysError">
        <p>
        <div id="sysErrMsg"></div>
        <p></p>
    </div>

    <!-- 自然人憑證訊息 -->
    <div title="訊息提示" id="dlgSignError">
        <p>
        <div id="errormessage"></div>
        <p></p>
        <p>注意事項:<br>忘記PIN碼/鎖卡解碼網頁操作上有任何問題，請洽詢卡片背後的客服電話。</p>
    </div>

    <div title="請選擇IC卡" id="dlgSelectCard"><br><label>選擇智慧卡讀卡機 : </label><br><br>
        <select style="font-size:12px;" name="slotDescription" id="slotDescription"></select>
        <div id="readernocard" style="display: none; font-size:14px;"><p>警告:偵測到讀卡機未插入IC卡片!!!!!</p></div>
        <div id="nultireader" style="display: none; font-size:14px;"><p>偵測到兩台(含)以上多台讀卡機情況，請選擇讀卡機。</p></div>
    </div>

    <div title="尚未安裝錯誤訊息提示" id="dlgNotInstall">
        尚未安裝跨平台網頁元件,建議做法請點選
        <a id="myCheck" style="color: blue; text-decoration: none;" href="activex/HiPKILocalSignServer_1.3.3.exe" target="_blank">
        連結下載</a>進行下載並進行安裝作業，安裝完成後請關閉瀏覽器後重新操作。</p>
        <p>
        <ol>
            <li>
                如果安裝上有問題，請參考
                <a style="color: blue; text-decoration: none;" href="manual/Setup_Information.doc" target="_blank">
                WORD檔案</a> 文件有詳細安裝教學說明。<br>
            </li>
            <li>
                在安裝過程若出現「存取被拒」表示權限不足，請確認您的電腦使用者權限是否是最高權限。<br>
            </li>
            <li>
                如確認已安裝跨平台網頁元件,還是不能正常操作，請參考
                <a style="color: blue; text-decoration: none;" href="manual/Activex_Information.doc" target="_blank">
                WORD檔案</a> 文件有詳細教學說明。</p>
            </li>
        </ol>
    </div>

    <div title="尚未加入信任網站錯誤訊息提示" id="dlgTrustedSite" style="font-size:14px;">
        <p>尚未加入信任網站，請先點
        <a id="myCheck" style="color: blue; text-decoration: none; cursor: pointer;"
                onclick="window.open('http://localhost:61161/addDomain?domain='+ window.location.hostname , 'AddDomain','height=400, width=400,left=100, top=20');" target="_blank">
        加入信任網站</a>。
        <br>如果有任何問題，請參考
        <a style="color: blue; text-decoration: none;" href="manual/Add_Domain_information.doc" target="_blank">
        WORD檔案</a>文件有詳細教學說明。</p>
    </div>
    <!-- =================================================================================== -->

</body>
</html>
