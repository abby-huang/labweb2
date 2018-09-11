<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "外籍勞工申辦案件進度查詢 - 詳細資料";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

response.setHeader("Pragma", "No-cache");
response.setHeader("Cache-Control", "no-cache");
response.setDateHeader("Expires", 0);

int pageRows = 5;
String errMsg = "";
Connection con = null;

//建立連線
con = getConnection(session);
if (con == null) {
    errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
}
Statement stmt = con.createStatement();
ResultSet rs;
String qs = "";

String qwpinno_1 = AbString.rtrimCheck(request.getParameter("qwpinno_1")).toUpperCase();
String qwpinno_2 = AbString.rtrimCheck(request.getParameter("qwpinno_2")).toUpperCase();
String qregno = AbString.rtrimCheck(request.getParameter("qregno")).toUpperCase();
String wpinno = AbString.rtrimCheck(request.getParameter("wpinno")).toUpperCase();

//讀取資料
String wpindate = "";
String resdate = "";
String wpoutdate = "";
String maildate = "";
String mailcode = "";
String keydate = "";
String wpkind = "";
String wptype = "";
String wpcode = "";
String rescode = "";
qs = "select * from fpv_wprec where wpinno=" + AbSql.getEqualStr(wpinno);
rs = stmt.executeQuery(qs);
if (rs.next()) {
    wpindate = AbString.rtrimCheck(rs.getString("wpindate"));
    resdate = AbString.rtrimCheck(rs.getString("resdate"));
    wpoutdate = AbString.rtrimCheck(rs.getString("wpoutdate"));
    maildate = AbString.rtrimCheck(rs.getString("maildate"));
    mailcode = AbString.rtrimCheck(rs.getString("mailcode"));
    keydate = AbString.rtrimCheck(rs.getString("keydate"));
    wpkind = AbString.rtrimCheck(rs.getString("wpkind"));
    wptype = AbString.rtrimCheck(rs.getString("wptype"));
    wpcode = AbString.rtrimCheck(rs.getString("wpcode"));
    rescode = AbString.rtrimCheck(rs.getString("rescode"));
}
rs.close();

//讀取郵件 Infoxmix
/*
qs = "select * from fpv_wprec where wpinno=" + AbSql.getEqualStr(wpinno);
rs = stmt.executeQuery(qs);
rs.next();
rs.close();
*/

//案件類別
String bizkind = getBizKind( wpkind, wpbizcodes, wpbizkinds );

//發文日期
boolean disp_outdate = true; //是否顯示發文日期
wpoutdate = AbDate.fmtDate(wpoutdate, "/");

//發文日期
maildate = AbDate.fmtDate(maildate, "/");

//案件申請類別
String wptypeTitle = "";
qs = "select  *from fpvweb_cirlmweb where wpkind = " + AbSql.getEqualStr(wpkind)
        + " and wptype = " + AbSql.getEqualStr(wptype);
rs = stmt.executeQuery(qs);
if (rs.next()) {
    wptypeTitle = AbString.rtrimCheck(rs.getString("wpname"));
}


//親自領件期限
String today = AbDate.getToday();
String deadline_getdate = "";
String get = "";
String getdate = "";
qs = "select * from fpv_empget where wpinno=" + AbSql.getEqualStr(wpinno);
rs = stmt.executeQuery(qs);
if (rs.next()) {
    get = strCheckNull(rs.getString("get"));
    getdate = strCheckNull(rs.getString("getdate"));
} else {
    deadline_getdate = "非親自領件之文件";
}
rs.close();
if (deadline_getdate.length() == 0) {
    if (get.compareToIgnoreCase("Y") == 0) {
        if (maildate.length() > 0)
            deadline_getdate = "本件已於 " + maildate + " 領取";
        else
            deadline_getdate = "本件已領取";
    } else {
        if (getdate.compareTo(today) < 0) {
            deadline_getdate = "已過親自領件期限";
        } else {
            qs = "select * from fpv_emptrs where wpinno=" + AbSql.getEqualStr(wpinno);
            rs = stmt.executeQuery(qs);
            if (rs.next()) {
                deadline_getdate = getdate;
            } else {
                deadline_getdate = "本件尚在處理中";
                disp_outdate = false; //不顯示發文日期
            }
            rs.close();
        }
    }
}

//退補件原因／評估結果
//wpkind <> 7 顯示
//或是 wprec.wpkind = 「7」 白領申請案 '且wprec.wpcode = 「B21」且wprec.rescode = 「C」
//並且wprec.maildate與wprec.mailcode不為空時 才顯示wpretum中退件內容
String reason = "";
if ( !wpkind.equals("7") || (wpkind.equals("7") && wpcode.equals("B21") && rescode.equals("C")
        && (maildate.length() > 0) && (mailcode.length() > 0)) ) {
    if (wpcode.startsWith("B")) {
        if (wpoutdate.length() == 0) {
            reason = "審核中";
        } else {
            //先不做，因為資料庫只有到92年的資料
            String reason1 = "";
            String reason2 = "";
            String retdetail = "";
            qs = "select reason1, reason2, change2 from fpv_wpretum where wpinno =" + AbSql.getEqualStr(wpinno);
            rs = stmt.executeQuery(qs);
            if (rs.next()) {
                reason1 = strCheckNull(rs.getString("reason1"));
                reason2 = strCheckNull(rs.getString("reason2")) + " " + strCheckNull(rs.getString("change2"));
            }
            rs.close();
            if (reason1.length() > 0) {

            }
            if ((reason2.length() > 0) && !wpcode.startsWith("B29"))
                reason = "補正";
            else
                reason = reason1 + reason2;
        }
    } else if (wpcode.equals("00n")) {
        if (wpoutdate.length() == 0) {
            reason = "審核中";
        } else {
            qs = "select * from fpv_wp00n where inwpno =" + AbSql.getEqualStr(wpinno);
            rs = stmt.executeQuery(qs);
            if (rs.next()) {
                if (strCheckNull(rs.getString("reason")).length() > 0)
                    reason = "補正";
            }
            rs.close();
        }
    } else if (wpcode.equals("005")) {
        if (wpoutdate.length() == 0) {
            reason = "審核中";
        } else {
            qs = "select * from fpv_wp005 where inwpno =" + AbSql.getEqualStr(wpinno);
            rs = stmt.executeQuery(qs);
            if (rs.next()) {
                String tmp = strCheckNull(rs.getString("reason1")) + strCheckNull(rs.getString("reason2"))
                        + strCheckNull(rs.getString("reason3")) + strCheckNull(rs.getString("reason4"))
                        + strCheckNull(rs.getString("reason5")) + strCheckNull(rs.getString("reason6"))
                        + strCheckNull(rs.getString("reason7")) + strCheckNull(rs.getString("reason8"))
                        + strCheckNull(rs.getString("reason9")) + strCheckNull(rs.getString("reason10"))
                        + strCheckNull(rs.getString("reason11")) + strCheckNull(rs.getString("reason12"));
                if (tmp.length() > 0)
                    reason = "補正";
            }
            rs.close();
        }
    } else if (wpcode.equals("009") || wpcode.equals("011")) {
        qs = "select * from fpv_" + wpcode + " where inwpno =" + AbSql.getEqualStr(wpinno);
        rs = stmt.executeQuery(qs);
        if (rs.next()) {
            reason += (strCheckNull(rs.getString("reason1")).length() > 0) ? rs.getString("reason1")+"<br/>" : "";
            reason += (strCheckNull(rs.getString("reason2")).length() > 0) ? rs.getString("reason2")+"<br/>" : "";
            reason += (strCheckNull(rs.getString("reason3")).length() > 0) ? rs.getString("reason3")+"<br/>" : "";
            reason += (strCheckNull(rs.getString("reason4")).length() > 0) ? rs.getString("reason4")+"<br/>" : "";
            reason += (strCheckNull(rs.getString("reason5")).length() > 0) ? rs.getString("reason5")+"<br/>" : "";
            reason += (strCheckNull(rs.getString("reason6")).length() > 0) ? rs.getString("reason6")+"<br/>" : "";
            reason += (strCheckNull(rs.getString("reason7")).length() > 0) ? rs.getString("reason7")+"<br/>" : "";
            reason += (strCheckNull(rs.getString("reason8")).length() > 0) ? rs.getString("reason8")+"<br/>" : "";
        }
        rs.close();
    } else if (wpcode.equals("012")) {
        if (wpoutdate.length() == 0) {
            reason = "審核中";
        } else {
            qs = "select * from fpv_wp012 where inwpno =" + AbSql.getEqualStr(wpinno);
            rs = stmt.executeQuery(qs);
            if (rs.next()) {
                String tmp = strCheckNull(rs.getString("reason1")) + strCheckNull(rs.getString("reason2"))
                        + strCheckNull(rs.getString("reason3")) + strCheckNull(rs.getString("reason4"))
                        + strCheckNull(rs.getString("reason5")) + strCheckNull(rs.getString("reason6"))
                        + strCheckNull(rs.getString("reason7")) + strCheckNull(rs.getString("reason8"))
                        + strCheckNull(rs.getString("reason9")) + strCheckNull(rs.getString("reason10"))
                        + strCheckNull(rs.getString("reason11")) + strCheckNull(rs.getString("reason12"))
                        + strCheckNull(rs.getString("reason13")) + strCheckNull(rs.getString("reason14"))
                        + strCheckNull(rs.getString("reason15")) + strCheckNull(rs.getString("reason16"))
                        + strCheckNull(rs.getString("reason17")) + strCheckNull(rs.getString("reason18"))
                        + strCheckNull(rs.getString("reason19"));
                if (tmp.length() > 0)
                    reason = "補正";
            }
            rs.close();
        }
    } else if (wpcode.equals("028")) {
        qs = "select * from fpv_wp028 where inwpno =" + AbSql.getEqualStr(wpinno);
        rs = stmt.executeQuery(qs);
        if (rs.next()) {
            reason += (strCheckNull(rs.getString("reason1")).length() > 0) ? rs.getString("reason1")+"<br/>" : "";
            reason += (strCheckNull(rs.getString("reason2")).length() > 0) ? rs.getString("reason2")+"<br/>" : "";
            reason += (strCheckNull(rs.getString("reason3")).length() > 0) ? rs.getString("reason3")+"<br/>" : "";
            reason += (strCheckNull(rs.getString("reason4")).length() > 0) ? rs.getString("reason4")+"<br/>" : "";
        }
        rs.close();
    }
}


%>

<html>
<head>
    <title>外籍勞工申辦案件進度查詢 - 詳細資料</title>
    <style>
        .fontstyle {color:blue;font-size:12pt;font-family:標楷體,細明體;}
        .errmsg {color:red;font-size:14pt;font-family:標楷體,細明體}
    </style>
</head>
<body style="background:paleturquoise">
    <center>
    <form name=frmsearch action="<%=thisPage%>" method="post">
        <img src="img/title.gif" WIDTH="317" HEIGHT="50" alt="外籍勞工申辦案件進度查詢"><br><br>
        <table bgcolor="#CDE1F6" bordercolor="#87AACF" border="1" width="560" class="type2">
            <tr bgcolor="#87AACF">
                <td colspan=2><img src="../image/arrow.gif" alt="美化圖形"><font color="#FFFFFF">外籍勞工申辦案件進度查詢 - 詳細資料</font></td>
            </tr>
            <tr>
                <td colspan=2 align=left >
                    <input type=button value="回上一頁" onClick="javascript:history.back()">
                </td>
            </tr>
            <tr >
                <td width="35%" align="right">收文文號</td>
                <td width="65%" align="left"><%=wpinno%></td>
<!--
                <td width="16%" align="right">案件類別</td>
                <td width="34%" align="left">
                    <%=strCheckNullHtml(bizkind)%>
                </td>
-->
            </tr>
            <tr >
                <td align="right">案件申請類別</td>
                <td align="left"><%=strCheckNullHtml(wptypeTitle)%></td>
            </tr>
            <tr >
                <td align="right">發文日期</td>
                <td align="left"><%=strCheckNullHtml(wpoutdate)%></td>
            </tr>
<!--20150209系統移轉後郵務系統並沒有移轉，無法回寫郵寄日期、郵寄條碼、郵退日期。fpv.mailrec.mailcode、fpv.mailrec.maildate
            <tr >
                <td align="right">郵寄日期</td>
                <td align="left"><%=strCheckNullHtml(maildate)%></td>
                <td align="right">郵寄條碼</td>
                <td align="left"><%=strCheckNullHtml(mailcode)%></td>
            </tr>
            <tr >
                <td align="right">郵退日期</td>
                <td align="left">&nbsp;</td>
            </tr>
-->
            <tr >
                <td align="right">退補件原因／評估結果</td>
                <td align="left" colspan="3"><%=strCheckNullHtml(reason)%></td>
            </tr>
            <% if (wptype.equals("O")) {%>
            <tr >
                <td align="right">備註</td>
                <td align="left">如具聘僱外籍看護工之申請資格及需求，請於醫療團隊完成評估日起60日效期內檢附相關文件向本部提出申請</td>
            </tr>
            <% } %>
            <tr >
                <td align="right">親自領件期限</td>
                <td align="left"><%=strCheckNullHtml(deadline_getdate)%></td>
            </tr>
        </table>
    </form>
        <p class="style4">本資料僅供參考，實際結果仍以本部核發之許可函為準
    </center>
</body>
</html>

<%
//關閉連線
if (stmt != null) stmt.close();
if (con != null) con.close();
%>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>
