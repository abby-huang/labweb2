<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "雙語/廚師人員查詢 - 簡列";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;
int pmax = 100;

//取得輸入資料
String search = strCheckNull((String)session.getAttribute("searchSPLab"));
String searchTitle = strCheckNull((String)session.getAttribute("searchSPLabTitle"));

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

//頁數
int p = 1;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}

Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
ResultSet rs, rs2;

//計算筆數
String qs = "select count(*) from splab_splabom l " + search;
session.setAttribute("debugMsg", qs);
if (debug) out.println(qs+"<br>");
rs = stmt.executeQuery(qs);
rs.next();
int totItem = rs.getInt(1);
rs.close();


//計算頁數
int ptot = ((totItem-1) / pmax) + 1;

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<BODY bgcolor="#F9CD8A">

<%
//無此外勞資料
if (totItem == 0) {
%>

<br><br>
沒有外勞資料，請重新輸入查詢條件。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>


<%
//有外勞資料
} else {
%>

<table border=0 width=600>
    <form action="">
    <td align=left width=5%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </td>
    </form>

    <td width=85%>
    </td>
</table>

<table border=0 width=1000>
<tr>
  <td width=85>查詢條件：
  </td>
  <td><%=searchTitle%>
  </td>
</tr>
</table>

<!--表頭-->
<table border=0 width=1000>
    <tr>
        <td width=30% align=left>
            共有 <b><%=totItem%></b> 筆，<b><%=p%>/<%=ptot%></b> 頁
        </td>
        <td align="lefe" width=50%>
<%  //顯示頁數
if (p > ptot) p = ptot;
int p0 = p - 5;
if (p0 < 1) p0 = 1;

if (ptot > 1) {
    if (p > 1) out.print("<a href=\"" + thisPage + "?p=" + (p-1) + "\"><u>上一頁</u></a>");
    for (int i = 0; ((i+p0) <= ptot) && (i < 10); i++) {
        if ((i+p0) == p) {
            out.print("<font color=#ff0000><b>&nbsp;&nbsp;" + (i+p0) + "</b></font>");
        } else {
            out.print("&nbsp;&nbsp;<a href=\"" + thisPage + "?p=" + (i+p0) + "\"><u>" + (i+p0) + "</u></a>");
        }
    }
    if ((p*pmax) < totItem) out.print("&nbsp;&nbsp;<a href=\"" + thisPage + "?p=" + (p+1) + "\"><u>下一頁</u></a>");
}
%>
        </td>
        <td width=20% align=left>
        </td>
    </tr>
    <tr>
        <td colspan=3 align=left>
            <font color='ff0000'>（說 明：以下資料是指該雇主曾經或現在聘用之外勞）</font>
        </td>
    </tr>

</table>


<table border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 width=1000>
<tr>
<td width=7% align=center>國籍</td>
<td width=10% align=center>護照號碼</td>
<td width=25% align=center>英文姓名</td>
<td width=5% align=center>性別</td>
<td width=10% align=center>出生日期</td>
<td width=25% align=center>雇主名稱</td>
<td width=10% align=center>行職業別</td>
<td width=8% align=center>縣市別</td>
</tr>

<%
response.getWriter().flush();

//顯示資料
//從 laborm 讀取資料
qs = "SELECT l.* from splab_splabom l "
            + " " + search
            + " order by l.lived, l.idno";

rs = stmt.executeQuery(qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;

while (rs.next() && (cnt < pmax)) {
    cnt++;

    String lived = AbString.rtrimCheck( rs.getString("lived") );
    String idno = AbString.rtrimCheck( rs.getString("idno") );
    String engname = AbString.rtrimCheck( rs.getString("engname") );
    String sex = AbString.rtrimCheck( rs.getString("sex") );
    String birthday = AbString.rtrimCheck( rs.getString("birthday") );

    //工作資料 splab_splabod
    String regno = "", wkadseq = "", citycode = "", emplcode = "";
    qs = "select * from splab_splabod where lived=" + AbSql.getEqualStr(lived)
            + " and idno=" + AbSql.getEqualStr(idno)
            + " and wrkbdate is not null"
            + " order by wrkbdate desc";
    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) {
        regno = AbString.rtrimCheck( rs2.getString("regno") );
        wkadseq = AbString.rtrimCheck( rs2.getString("wkadseq") );
        citycode = AbString.rtrimCheck( rs2.getString("citycode") );
        emplcode = AbString.rtrimCheck( rs2.getString("emplcode") );
    }
    rs2.close();

    //雇主資料 splab_spvendm
    String vendname = "";
    qs = "select * from splab_spvendm where regno=" + AbSql.getEqualStr(regno)
            + " and wkadseq=" + AbSql.getEqualStr(wkadseq);
    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) {
        vendname = AbString.rtrimCheck( rs2.getString("vendname") );
    }
    rs2.close();

%>

<tr>
    <td align=center><%=strCheckNullHtml(common.Comm.getCodeTitle(stmt2, lived, "fpv_natim", "naticode", "natiname"))%></td>
    <td align=center><a HREF="QrySPLaborDetail.jsp?lived=<%=lived%>&idno=<%=idno%>"><%=strCheckNullHtml(idno)%></a></td>
    <td align=left><%=strCheckNullHtml(engname)%></td>
    <td align=center><%=strCheckNullHtml(sex.equals("M") ? "男" : "女")%></td>
    <td align=center><%=strCheckNullHtml(birthday)%></td>
    <td align=left><%=strCheckNullHtml(vendname)%></td>
    <td align=center><%=strCheckNullHtml(common.Comm.getCodeTitle(stmt2,emplcode,"fpv_emplm","emplcode","occuname"))%></td>
    <td align=center><%=strCheckNullHtml(common.Comm.getCodeTitle(stmt2, citycode, "fpv_zipcitym", "citycode", "cityname"))%></td>
</tr>

<%
}
rs.close();
%>

</table>

<%
}   //結束有外勞資料
%>


<%
//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
%>


</BODY>
</HTML>
