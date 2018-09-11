<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="nl.captcha.*"%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
if ( !request.isSecure() ) {
    response.sendRedirect("https://qry.wda.gov.tw/labweb/qrycase/QryCaseMain.jsp");
}

String pageHeader = "外籍勞工案件申辦進度查詢";
request.setCharacterEncoding("UTF-8");
//String thisPage = request.getRequestURI();
String thisPage = "QryCaseMain.jsp";

//response.setHeader("Pragma", "No-cache");
//response.setHeader("Cache-Control", "no-cache");
//response.setDateHeader("Expires", 0);

int pageRows = 5;
String errMsg = "";
Connection con = null;
String sessionId = session.getId();
debug = false;

String action = filterMetaCharacters( request.getParameter("action") );
String qwpinno_1 = filterMetaCharacters(request.getParameter("qwpinno_1")).toUpperCase();
String qwpinno_2 = filterMetaCharacters(request.getParameter("qwpinno_2")).toUpperCase();
String qwpinno = "";
if (qwpinno_2.length() > 0) {
    //必須判斷100年
    //取消 20130922
    //if (Integer.parseInt(qwpinno_1) >= 100) qwpinno = qwpinno_1 + qwpinno_2;
    //else qwpinno = qwpinno_1 + "-" + qwpinno_2;
    qwpinno = qwpinno_1 + qwpinno_2;
}
String qregno = filterMetaCharacters(request.getParameter("qregno")).toUpperCase();
if (qregno.length() < 8) qregno = "";
String qagenno = filterMetaCharacters(request.getParameter("qagenno")).toUpperCase();

//String action = strCheckNull((String)session.getAttribute("action"));
//session.setAttribute("action", "0");
%>

<html>
<head>
    <title>外籍勞工案件申辦進度查詢</title>
    <style>
        .fontstyle {color:blue;font-size:12pt;font-family:標楷體,細明體;}
        .errmsg {color:red;font-size:14pt;font-family:標楷體,細明體}
    </style>

    <script language="JavaScript">
        // XFS 防護
        if (top != self) {top.location = self.location;}

        function checkInput(frm)
        {
            frm.qregno.value = frm.qregno.value.replace(/^\s+|\s+$/g,'');
            frm.qagenno.value = frm.qagenno.value.replace(/^\s+|\s+$/g,'');
            frm.qwpinno_2.value = frm.qwpinno_2.value.replace(/^\s+|\s+$/g,'');
            if (frm.qregno.value.length < 8) {
                alert ("必須輸入正確的雇主編號!");
                return false;
            } else {
                return true;
            }
        }
    </script>

</head>

<body style="background:paleturquoise">
    <center>
<!--    <img src="img/title.gif" alt="外籍勞工案件申辦進度查詢"><br> -->
<!--
<p>
<marquee scrollamount='5' direction= 'left' width='500' id=xiaoqing height='20' style="color: #FF0000; font-size: 15pt; font-weight: bold; font-family:新細明體">
本署訂於今日5月31日(星期二)下午1800更新系統，屆時網路將中斷預計於1900恢復服務，如有不便之處敬請見諒。
</marquee>
-->
    <form name=frmsearch action="<%=thisPage%>" method="post" onsubmit="return checkInput(this);" style="margin:0; padding:0;">
        <input type="hidden" name="sessionId" value="<%=sessionId%>">

        <table border="1" style="width: 680px; background-color: #CDE1F6;">
            <tr style="height: 27px; background-color: #87AACF;">
                <td colspan=2 ><img src="../image/arrow.gif" alt="美化圖形"><font color="#FFFFFF">外籍勞工案件申辦進度查詢</font>
                　　　　　　<a href="http://wcfext.wda.gov.tw:8080/wcfonline/people_search/index.jsp" title="外國專業人員(白領)案件申辦進度查詢請按這裏" target="_blank">外國專業人員(白領)案件申辦進度查詢請按這裏</a></td>
            </tr>
            <tr style="height: 27px;">
                <td width=20% align="right" >雇主編號</td>
                <td width=80% align="left">
                    <input type="text" name="qregno" value="<%=qregno%>" maxlength="10" size="12">
                    &nbsp;&nbsp;<font color=#ff0000>(雇主編號是一定要輸入的查詢條件)</font>
                </td>
            </tr>
            <tr>
                <td align="right" >仲介公司代碼</td>
                <td align="left">
                    <input type="text" name="qagenno" value="<%=qagenno%>" maxlength="4" size="5" style="vertical-align: middle; display: inline-block;">
                    <span style="vertical-align: middle; display: inline-block; color: red;">
                        １、 委託仲介公司代辦案件者，請輸入仲介公司代碼(4碼)<br>
                        ２、 雇主採直接聘僱者，請輸入1111<br>
                        ３、 傳遞單案件請勿輸入仲介公司代碼
                    </span>
                </td>
            </tr>
            <tr style="height: 27px;">
                <td align="right" >收文文號</td>
                <td align="left">
                    <select name="qwpinno_1">
<%
for (int i=107; i >=106; i--) {
    String selected = "";
    if (qwpinno_1.equals(i+"")) selected = "selected";
%>
                        <option value=<%=i+""%> <%=selected%>><%=i+""%></option>
<%
}
%>
                    </select>
                    －<input type="text" name="qwpinno_2" value="<%=qwpinno_2%>" size="8" maxlength="7" value="">
                    &nbsp;<font color=#ff0000>(建議:已知收文文號者,請再輸入收文文號)</font>
                </td>
            </tr>

            <tr>
                <td align="right" >輸入認證碼</td>
                <td align="left">
                    <input type="text" name=answer maxlength=6 style="width: 80px; vertical-align: middle; display: inline-block;">
                    <img src="<%=appRoot%>/AbsysCaptcha.png"  style="width: 120px; height: 30px; vertical-align: middle; display: inline-block;" onclick="this.src='<%=appRoot%>/AbsysCaptcha.png?'+(new Date()).getTime();"/>
                </td>
            </tr>

            <tr>
                <td colspan=2 >說明：
                　　　　　　 <input name="action" value=查詢  type=submit>
                　　(本資料僅供參考，實際結果仍以本部核發之許可函為準)
                </td>
            </tr>
            <tr>
                <td colspan=2>
                    1.雇主編號是指個人的身份證字號或事業單位的統一編號。<br>
                    2.收文文號是指本署收件時所賦予之編號。<br>
                    3.為保護個人資料及資訊安全考量，郵寄案件之收文文號查詢，僅限寄達本署且資料入電腦後<br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;14日內之案件，超過時間則不開放查詢。案件辦理進度之查詢期間規定為：<br>
                    &nbsp;&nbsp;&nbsp;(1)如該案件已發文為發文日起1個月內。&nbsp;&nbsp;&nbsp;(2)如該案件未發文為收文日起3個月內。<br>
                    4.本系統於99.12.1.改版上線，請參考<a href="readme.pdf">系統改版宣導說明</a>。<br>
                    5.長期照顧傳遞單因情況較為特殊，查詢規定請一併參閱<a href="readme.pdf">系統改版宣導說明</a>。
                </td>
            </tr>
        </table>
    </form>

<%


//有輸入資料
if ( ((qwpinno+qregno+qagenno).length() > 0) && sessionId.equals(filterMetaCharacters(request.getParameter("sessionId"))) ) {

    //檢查認證碼
    Captcha captcha = (Captcha) session.getAttribute(Captcha.NAME);
    String answer = filterMetaCharacters( request.getParameter("answer") );
    if ((captcha == null) || !captcha.isCorrect(answer)) {
        errMsg = "認證碼輸入錯誤。";

    } else {

    //建立連線
    con = getConnection(session);
    if (con == null) {
        errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
    }
    Statement stmt = con.createStatement();
    Statement stmt2 = con.createStatement();
    ResultSet rs, rs2;
    String qs = "";

    String qrystr = ""; //Query string URI

    //限制條件
    if (qwpinno_1.length() > 0) qrystr += "&qwpinno_1=" + qwpinno;
    if (qwpinno_2.length() > 0) qrystr += "&qwpinno_2=" + qwpinno;
    if (qregno.length() > 0) qrystr += "&qregno=" + qregno;

    //寫入日誌檔
    String srchdata = "IP：" + strCheckNull( request.getRemoteAddr() );
    if (qwpinno.length() > 0) srchdata += "，收文文號：" + qwpinno;
    if (qregno.length() > 0) srchdata += "，雇主編號：" + qregno;
    if (qagenno.length() > 0) srchdata += "，仲介公司：" + qagenno;
    //if (srchdata.length() > 0) srchdata = srchdata.substring(1);

    common.Comm.logOpData(stmt, new com.absys.user.Staff(), "QryCase", srchdata, AbString.rtrimCheck( request.getRemoteAddr() ));

    //限制條件
    String srch = "";
    String today = AbDate.getToday();
    String qwpindate = "";
    String qwpoutdate = "";
    //雇主編號 SQL
    //自然人(十碼)
    String sqlRegno = "fpv_appemp.regno = " + AbSql.getEqualStr(qregno);
    //法人(八碼)
    if ( (qregno.length() >= 8) ) {
        if ( ((qregno.length() > 0) && (qregno.charAt(0) >= '0') && (qregno.charAt(0) <= '9')) || (qregno.charAt(3) == '-') )
            if (!databaseName.equalsIgnoreCase("Informix73")) {
                sqlRegno = sqlSubstring + "(fpv_appemp.regno, 1, 8) = " + AbSql.getEqualStr(qregno);
            } else {
                sqlRegno = "fpv_appemp.regno[1, 8] = " + AbSql.getEqualStr(qregno);
            }
    }

    //只有輸入雇主編號
    if ((qagenno+qwpinno).length() == 0) {
        qagenno = "000000"; //長期照顧傳遞單是指qagenno = "000000"
        qwpindate = AbDate.dateAdd(today, 0, 0, -14); //14天前
        String qwpoutdate_1 = AbDate.dateAdd(today, 0, -2, 0); //1個月前
        String qwpindate_3 = AbDate.dateAdd(today, 0, -3, 0); //3個月前
        srch += " and " + sqlRegno;
        if (qwpinno.length() > 0) srch += " and fpv_appemp.wpinno = " + AbSql.getEqualStr(qwpinno);
        if (!databaseName.equalsIgnoreCase("Informix73")) {
            if (qagenno.length() > 0) srch += " and " + sqlSubstring + "(fpv_appemp.agenno, 1, 6) = '000000'";
        } else {
            if (qagenno.length() > 0) srch += " and fpv_appemp.agenno[1, 6] = '000000'";
        }
        srch += " and chng_id <> 'D'";
        //20131120 取消 14 天限制
        /*
        srch += " and (fpv_appemp.wpindate >= " + AbSql.getEqualStr(qwpindate);
        //wpkind=3 and wptype='O'
        srch += " or exists (select * from fpv_wprec where fpv_wprec.wpinno = fpv_appemp.wpinno and wpkind='3' and wptype='O'";
        */
        //20131126 代碼已經改變
        //wpkind=3 and wptype='O'
        //srch += " and (exists (select * from fpv_wprec where fpv_wprec.wpinno = fpv_appemp.wpinno and wpkind='3' and wptype='O'";
        srch += " and (exists (select * from fpv_wprec where fpv_wprec.wpinno = fpv_appemp.wpinno";
        //已發文
        srch += " and ( (wpoutdate >= " + AbSql.getEqualStr(qwpoutdate_1) + ")";
        //未發文
        srch += " or ((wpoutdate = '' or wpoutdate is null) and fpv_appemp.wpindate >= " + AbSql.getEqualStr(qwpindate_3) + ") ) ) )";
        if (srch.length() > 0) srch = " where " + srch.substring(4);

    //輸入雇主編號 & 仲介公司
    } else if ((qagenno.length() > 0) && (qwpinno.length() == 0)) {
        qwpindate = AbDate.dateAdd(today, 0, 0, -14); //14天前
        srch += " and " + sqlRegno;
        if (qwpinno.length() > 0) srch += " and fpv_appemp.wpinno = " + AbSql.getEqualStr(qwpinno);
        if (!databaseName.equalsIgnoreCase("Informix73")) {
            if (qagenno.length() > 0) srch += " and " + sqlSubstring + "(fpv_appemp.agenno, 1, 4) = " + AbSql.getEqualStr(qagenno);
        } else {
            if (qagenno.length() > 0) srch += " and fpv_appemp.agenno[1, 4] = " + AbSql.getEqualStr(qagenno);
        }
        if (qwpindate.length() > 0) srch += " and fpv_appemp.wpindate >= " + AbSql.getEqualStr(qwpindate);
        srch += " and chng_id <> 'D'";
        if (srch.length() > 0) srch = " where " + srch.substring(4);

    //輸入雇主編號 & 收文文號
    } else if ((qagenno.length() == 0) && (qwpinno.length() > 0)) {
        qagenno = "000000"; //長期照顧傳遞單是指qagenno = "000000"
        qwpindate = AbDate.dateAdd(today, 0, -3, 0); //3個月前
        qwpoutdate = AbDate.dateAdd(today, 0, -2, 0); //1個月前
        srch += " and " + sqlRegno;
        if (qwpinno.length() > 0) srch += " and fpv_appemp.wpinno = " + AbSql.getEqualStr(qwpinno);
        if (!databaseName.equalsIgnoreCase("Informix73")) {
            if (qagenno.length() > 0) srch += " and " + sqlSubstring + "(fpv_appemp.agenno, 1, 6) = '000000'";
        } else {
            if (qagenno.length() > 0) srch += " and fpv_appemp.agenno[1, 6] = '000000'";
        }
        srch += " and chng_id <> 'D'";
        srch += " and exists (select * from fpv_wprec where fpv_wprec.wpinno = fpv_appemp.wpinno";
        srch += " and ( (wpoutdate >= " + AbSql.getEqualStr(qwpoutdate) + ")";
        srch += " or ((wpoutdate = '' or wpoutdate is null) and fpv_appemp.wpindate >= " + AbSql.getEqualStr(qwpindate) + ") ) )";

        if (srch.length() > 0) srch = " where " + srch.substring(4);

    //輸入雇主編號 & 仲介公司 & 收文文號
    } else if ((qagenno.length() > 0) && (qwpinno.length() > 0)) {
        qwpindate = AbDate.dateAdd(today, 0, -3, 0); //3個月前
        qwpoutdate = AbDate.dateAdd(today, 0, -1, 0); //1個月前
        srch += " and " + sqlRegno;
        if (qwpinno.length() > 0) srch += " and fpv_appemp.wpinno = " + AbSql.getEqualStr(qwpinno);
        if (!databaseName.equalsIgnoreCase("Informix73")) {
            if (qagenno.length() > 0) srch += " and " + sqlSubstring + "(fpv_appemp.agenno, 1, 4) = " + AbSql.getEqualStr(qagenno);
        } else {
            if (qagenno.length() > 0) srch += " and fpv_appemp.agenno[1, 4] = " + AbSql.getEqualStr(qagenno);
        }
        srch += " and chng_id <> 'D'";
        srch += " and exists (select * from fpv_wprec where fpv_wprec.wpinno = fpv_appemp.wpinno";
        srch += " and ( (wpoutdate >= " + AbSql.getEqualStr(qwpoutdate) + ")";
        srch += " or ((wpoutdate = '' or wpoutdate is null) and fpv_appemp.wpindate >= " + AbSql.getEqualStr(qwpindate) + ") ) )";
        if (srch.length() > 0) srch = " where " + srch.substring(4);
    }

    //開始查詢
    int totItem = 0;
    ArrayList<String> keys = new ArrayList<String>();
    qs = "select fpv_appemp.* from fpv_appemp"
            + srch
            + " order by fpv_appemp.wpindate desc, fpv_appemp.wpinno desc";
//    try {
//out.println(qs+"<br>");
        rs = stmt.executeQuery(qs);
        while (rs.next()) {
            boolean isOk = true;
            String wpinno =  AbString.rtrimCheck( rs.getString("wpinno") );
            String wpindate = AbString.rtrimCheck( rs.getString("wpindate") );
            String wpkind = "", wptype = "";

            //檢查長照案件是否為三個月前
            rs2 = stmt2.executeQuery( "select * from fpv_wprec where wpinno=" + AbSql.getEqualStr(wpinno) );
            if (rs2.next()) {
                wpkind = AbString.rtrimCheck( rs2.getString("wpkind") );
                wptype = AbString.rtrimCheck( rs2.getString("wptype") );
            }
            rs2.close();

            // 30 - 91 為長照
            if ("30".equals(wpkind) && "91".equals(wptype)) {
                rs2 = stmt2.executeQuery( "select * from labdyn_ngbandy where wpinno=" + AbSql.getEqualStr(wpinno) );
                if (rs2.next()) {
                    String longtermdate = AbString.rtrimCheck( rs2.getString("longtermdate") );
                    if (AbDate.dateAdd(AbDate.getToday(), 0, -3, 0).compareTo(longtermdate) >= 0) { //3個月前
                        isOk = false;
                    }
                }
                rs2.close();
            }

            if (isOk) {
                totItem++;
                keys.add(wpinno + wpindate);
            }
        }
        rs.close();
//    } catch (Exception e) {}

    //沒有資料
    if (totItem == 0) {
        errMsg = "目前查無資料！";


    //多筆
    } else {
%>
    <!--頁數-->
    <table id="tblPage" class="ab-box02" style="border-width:2 2 0 2; width:400;">
        <tr>
            <td width=200 align=left>
                共有 <b><%=totItem%></b> 筆
            </td>
        </tr>
    </table>

    <table id="tblData" border="1" bordercolorlight="#008080" width=400>
        <tr class="ab-frmlbl">
            <td align="center" width="50%">收文文號</td>
            <td align="center" width="50%">收文日期</td>
        </tr>
        <%
        //顯示資料
        for (int i = 0; i < keys.size(); i++) {
            String wpinno =  keys.get(i).substring(0, 10);
            String wpindate = strCheckNullHtml( keys.get(i).substring(10) );
        %>
            <tr >
                <td align=center><a HREF="QryCaseDetail.jsp?wpinno=<%=wpinno%>"><%=strCheckNullHtml(wpinno)%></a></td>
                <td align="center"><%=wpindate%></td>
            </tr>
        <%
        }
        %>
    </table>
    <br><br>
    </center>
<%
    } //多筆

    //關閉連線
    if (stmt != null) stmt.close();
    if (stmt2 != null) stmt2.close();
    if (con != null) con.close();


    } //檢查認證碼

} //有輸入資料
%>

</center>
</body>
</html>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>
