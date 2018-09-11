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
String pageHeader = "逃逸藍領外國人清單";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//設定此頁
session.setAttribute("briefPage", "QryLaborStatusBrief.jsp");

//定義變數
String errMsg = "";
Connection con = null;
Connection con2 = null;
Connection con3 = null;
int pmax = 100;

//取得輸入資料
String search = strCheckNull((String)session.getAttribute("searchLab"));
String searchTitle = strCheckNull((String)session.getAttribute("searchLabTitle"));

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
con2 = getConnection( session );
if (con2 == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
con3 = getConnection( session );
if (con3 == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

//頁數
int p = 1;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}


Statement stmt = con.createStatement();
Statement stmt2 = con2.createStatement();
Statement stmt3 = con3.createStatement();

String qs;
ResultSet rs;
%>


<html>
<head>
    <%@ include file="/include/HeaderTimeout.inc" %>
    <script src="<%=appRoot%>/js/RptLandscape.js"></script>
</head>

<body style="COLOR: black; FONT-FAMILY: 標楷體;">

<!-- MeadCo ScriptX -->
<%@ include file="/include/ScriptX.jsp" %>


<table border=0 width=1000 style="font-size: 13pt; font-family: 標楷體">
<tr>
  <td width=90>查詢條件：
  </td>
  <td><%=searchTitle%>
  </td>
</tr>
</table>

<!--表頭-->
<table border=1 cellspacing=0 width=1000 style="font-size: 13pt; font-family: 標楷體">
<tr>
<td width=5% align=center>國籍</td>
<td width=8% align=center>護照號碼</td>
<td width=10% align=center>英文姓名</td>
<td width=3% align=center>性<br>別</td>
<td width=5% align=center>出生日期</td>
<td width=8% align=center>雇主名稱</td>
<td width=8% align=center>行職業別</td>
<td width=7% align=center>縣市別</td>
<td width=10% align=center>仲介名稱</td>
<td width=18% align=center>仲介地址</td>
<td width=8% align=center>仲介<br>電話</td>
</tr>

<%
//顯示資料
//從 resident 讀取資料
qs = "SELECT " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
        + " distinct f.natcode"
        + ",f.passno"
        + " from labdyn_resident f "
        + search
        + " order by natcode, passno";

ResultSet rs0 = common.Comm.querySQL(stmt, qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs0.next();
}
int cnt = 0;
while (rs0.next() && (cnt < pmax)) {
    cnt++;

    //從 laborm 讀取資料
    qs = "SELECT " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
                + " m.natcode"
                + ",m.passno"
                + ",m.engname"
                + ",m.sex"
                + ",m.birthday"
                + ",m.citycode"
                + ",m.lstatus"
                + ",m.prmtno"
                + ",m.natcode"
                + ",substr(m.casekind, 2, 1)"
                + ",regno"
                + " from labdyn_laborm m"
                + " where m.natcode = " + AbSql.getEqualStr( strCheckNull(rs0.getString(1)) )
                + " and m.passno = " + AbSql.getEqualStr( strCheckNull(rs0.getString(2)) );

    rs = stmt3.executeQuery(qs);
    if (!rs.next()) continue;

    String regno = strCheckNull( rs.getString("regno") );
    String prmtno = strCheckNull( rs.getString("prmtno") );
    ResultSet rs2;

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
<td><%=strCheckNullHtml(agenname)%></td>
<td><%=strCheckNullHtml(agenaddr)%></td>
<td><%=strCheckNullHtml(agentel)%></td>
</tr>


<%
    rs.close();
}
rs0.close();

%>

</table>

<%

//關閉連線
stmt.close();
stmt2.close();
stmt3.close();
if (con != null) con.close();
if (con2 != null) con2.close();
if (con3 != null) con3.close();
%>


</BODY>
</HTML>