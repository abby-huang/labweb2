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
String pageHeader = "藍領外國人查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//設定此頁
session.setAttribute("briefPage", "QryLaborDataBrief.jsp");

//定義變數
String errMsg = "";
Connection con = null;
int pmax = 100;

//取得輸入資料
String search = strCheckNull((String)session.getAttribute("searchLab"));
String searchTitle = strCheckNull((String)session.getAttribute("searchLabTitle"));

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt0 = con.createStatement();
Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
String qs;
ResultSet rs0;
ResultSet rs;
ResultSet rs2;

//頁數
int p = 1;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}

%>


<html>
<head>
    <%@ include file="/include/HeaderTimeout.inc" %>
    <script src="<%=appRoot%>/js/RptLandscape.js"></script>
</head>

<body style="COLOR: black; FONT-FAMILY: 標楷體;">

<!-- MeadCo ScriptX -->
<%@ include file="/include/ScriptX.jsp" %>

<center>
<table border=0 width=1000 style="font-size: 13pt; font-family: 標楷體">
<tr>
  <td width=90>查詢條件：
  </td>
  <td><%=searchTitle%>
  </td>
</tr>
</table>

<!--表頭-->
<table border=1 cellspacing=0 width=1000  style="font-size: 13pt; font-family: 標楷體">
<tr>
<td width=5% align=center>國籍</td>
<td width=8% align=center>護照號碼</td>
<td width=10% align=center>英文姓名</td>
<td width=3% align=center>性<br>別</td>
<td width=5% align=center>出生日期</td>
<td width=8% align=center>雇主名稱</td>
<td width=8% align=center>行職業別</td>
<td width=7% align=center>縣市別</td>
<td width=10% align=center>狀態</td>
<td width=10% align=center>仲介名稱</td>
<td width=18% align=center>仲介地址</td>
<td width=8% align=center>仲介<br>電話</td>
</tr>

<%
//查詢
qs = "SELECT " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
        + " distinct natcode"
        + ",passno"
        + " from labdyn_workprmt "
        + search
        + " order by natcode, passno";
rs0 = common.Comm.querySQL(stmt0, qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs0.next();
}
int cnt = 0;
while (rs0.next() && (cnt < pmax)) {
    cnt++;

    String natcode = strCheckNull( rs0.getString("natcode") );
    String passno = strCheckNull( rs0.getString("passno") );

    //從 laborm 讀取資料
    qs = "SELECT " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
                + " l.natcode"
                + ",l.passno"
                + ",l.engname"
                + ",l.sex"
                + ",l.birthday"
                + ",l.citycode"
                + ",l.lstatus"
                + ",l.prmtno"
                + ",l.natcode"
                + "," + sqlSubstring + "(l.casekind, 2, 1)"
                + ",l.regno"
                + " from labdyn_laborm l"
                + " where natcode=" + AbSql.getEqualStr(natcode)
                + " and passno=" + AbSql.getEqualStr(passno);
    session.setAttribute("debugMsg", qs);
    rs = stmt.executeQuery(qs);
    rs.next();

    String regno = strCheckNull( rs.getString("regno") );

    String natiname = "";
    String cityname = "";
    String dynadesc = "";

    String vendname = "";
    String agenno = "";
    String agenname = "";
    String agenaddr = "";
    String agentel = "";

    //行職業別
    String bizkind = getBizKind( strCheckNull(rs.getString(10)), bizcodes, bizkinds );
    if (regno.length() == 0) bizkind = "";

    //讀取國籍
    natiname = getNatcodeName( strCheckNull(rs.getString(9)), natcodes, natnames);

    //讀取縣市別
    qs =  "select cityname from fpv_citym where fpv_citym.citytype = 'A'"
        + " and citycode = " + AbSql.getEqualStr( strCheckNull(rs.getString(6)) );
    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) cityname = strCheckNull( rs2.getString(1) ).trim().replaceAll("　+$", "");
    rs2.close();

    //讀取狀態
    rs2 = stmt2.executeQuery("select dynadesc from fpv_dynalm where dynacode = " + AbSql.getEqualStr( strCheckNull(rs.getString(7)) ) );
    if (rs2.next()) dynadesc = strCheckNull( rs2.getString(1) ).trim().replaceAll("　+$", "");
    rs2.close();

    //最新聘僱文號
    String wkprmtno = "";
    qs = "select natcode, passno, wkprmtno, wkprmtdate from labdyn_workprmt"
        + " where natcode = " + AbSql.getEqualStr( rs.getString(1) )
        + " and passno = " + AbSql.getEqualStr( rs.getString(2) )
        + " order by natcode, passno, wkprmtdate desc";

    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) {
        wkprmtno = strCheckNull( rs2.getString("wkprmtno") );
    }
    rs2.close();

    //雇主名稱
    if (regno.length() > 0) {
        rs2 = stmt2.executeQuery("select cname from labdyn_vend where regno = " + AbSql.getEqualStr(regno));
        if (rs2.next()) vendname = strCheckNullHtml( rs2.getString(1) );
        rs2.close();
    }

    //讀取仲介資料
    rs2 = stmt2.executeQuery("select agenno from fpv_appemp where wpinno = " + AbSql.getEqualStr(wkprmtno));
    if (rs2.next()) agenno = strCheckNull( rs2.getString(1) );
    rs2.close();

    if (agenno.length() > 0) {
/*
        if (agenno.length() <= 4)
            rs2 = stmt2.executeQuery("select e01_04, e01_05, e01_06 from emp_emp01 where e01_22 = " + AbSql.getEqualStr(agenno));
        else
            rs2 = stmt2.executeQuery("select e02_04, e02_05, e02_06 from emp_emp02 where e02_19 = " + AbSql.getEqualStr(agenno));
*/
        rs2 = stmt2.executeQuery("select title, addr, tel from empage_agent where agno = " + AbSql.getEqualStr(agenno));
        if (rs2.next()) {
            agenname = "(" + agenno + ")" + strCheckNull( rs2.getString(1) );
            agenaddr = strCheckNullHtml( rs2.getString(2) );
            agentel = strCheckNullHtml( rs2.getString(3) );
        }
        rs2.close();
    }

    String sex = strCheckNull(rs.getString(4));
    if ("M".equals(sex)) sex = "男";
    else if ("F".equals(sex)) sex = "女";
%>

<tr>
<td align=center><%=strCheckNullHtml(natiname)%></td>
<td align=center><%=strCheckNullHtml(rs.getString(2))%></td>
<td><%=strCheckNullHtml(rs.getString(3))%></td>
<td align=center><%=strCheckNullHtml(sex)%></td>
<td align=center><%=strCheckNullHtml(rs.getString(5))%></td>
<td><%=strCheckNullHtml(vendname)%></td>
<td><%=strCheckNullHtml(bizkind)%></td>
<td><%=strCheckNullHtml(cityname)%></td>
<td><%=convertChiSymbol( strCheckNullHtml(dynadesc) )%></td>
<td><%=strCheckNullHtml(agenname)%></td>
<td><%=strCheckNullHtml(agenaddr)%></td>
<td><%=strCheckNullHtml(agentel)%></td>
</td>
</tr>

<%
    rs.close(); //關閉 labdyn_laborm
}
rs0.close();
%>

</table>

<%
//關閉連線

//關閉連線
stmt0.close();
stmt.close();
stmt2.close();
if (con != null) con.close();
%>


</BODY>
</HTML>
