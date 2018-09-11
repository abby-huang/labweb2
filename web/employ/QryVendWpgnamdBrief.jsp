<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領被看護人查詢 - 簡列";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;
String labdts_cyyyymmdd = (String)session.getAttribute("labdts_cyyyymmdd");

//建立連線
con = common.Comm.getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
ResultSet rs;
String qs;

//取得輸入資料
String commid = AbString.rtrimCheck( request.getParameter("commid") ).toUpperCase().trim();

//限制條件
String search = "";
String logid = "";

//被看護人查詢
if (commid.length() < 10) commid = AbString.leftJustify(commid, 10).trim();

String srchdata = "";
if (commid.length() > 0) {
    if (srchdata.length() > 0) srchdata += "，";
    srchdata += "被看護人編號：" + commid;
}

//寫入日誌檔
common.Comm.logOpData(stmt, userData, "Wpgnamd", srchdata, userAddr);


search += " where commid = " + AbSql.getEqualStr(commid)
        + " and cyyyymmdd = '" + labdts_cyyyymmdd + "'"
        + " and type = 'SA'";

//計算筆數
qs = "select count(*) from cognos_labdts " + search;
rs = common.Comm.querySQL(stmt, qs);
rs.next();
int totItem = rs.getInt(1);
rs.close();

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<BODY bgcolor="#F9CD8A">

    <br>
    <form action="">
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </form>

<%
//顯示資料
if (totItem > 0) {
%>
    <table border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 width=1000>
        <tr>
            <td width=10% align=center>國籍</td>
            <td width=15% align=center>護照號碼</td>
            <td width=35% align=center>英文姓名</td>
            <td width=10% align=center>性別</td>
            <td width=15% align=center>出生日期</td>
            <td width=15% align=center>雇主名稱</td>
        </tr>

<%
    qs = "select natcode, passno from cognos_labdts " + search + " order by natcode, passno";
    rs = common.Comm.querySQL(stmt, qs);
if (debug) out.println(qs+"<br>");
    while (rs.next()) {
        String natcode = AbString.rtrimCheck( rs.getString("natcode") );
        String passno = AbString.rtrimCheck( rs.getString("passno") );
        common.LaborDetail laborDetail = new common.LaborDetail(natcode, passno);
        laborDetail.getBasic(stmt2);
        laborDetail.getDetail(stmt2);
%>

    <tr>
        <td align=center><%=strCheckNullHtml(laborDetail.nation)%></td>
        <td align=center><a HREF="../qrylabor/QryLaborDetail.jsp?natcode=<%=laborDetail.natcode%>
                &passno=<%=laborDetail.passno%>"><%=strCheckNullHtml(laborDetail.passno)%></a></td>
        <td><%=strCheckNullHtml(laborDetail.engname)%></td>
        <td align=center><%=strCheckNullHtml(laborDetail.sex_desc)%></td>
        <td align=center><%=strCheckNullHtml(laborDetail.birthday)%></td>
        <td><%=strCheckNullHtml(laborDetail.vendname)%></td>
    </tr>

<%
    }
    rs.close();
%>

    </table>

<%
} else {
    //查無此被看護人資料
if (debug) out.println(qs+"<br>");
%>
    <table border=0 width=600>
        <tr>
            <td>查無此被看護人【<%=commid%>】資料</td>
        </tr>
    </table>

<%
}
%>



<%
//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
%>

</BODY>
</HTML>
