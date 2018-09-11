<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>

<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "日誌查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpsuper.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

String errMsg = "";
Connection conn = null;
int pmax = 5000;

//建立連線
conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";


//取得資料
String action = request.getParameter("action");
String qdivision = request.getParameter("qdivision");
String qdescript = request.getParameter("qdescript");
String quserid = request.getParameter("quserid");
String qsdate = request.getParameter("qsdate");
String qedate = request.getParameter("qedate");
String logid = request.getParameter("logid");
if (logid == null)
    logid = (String)session.getAttribute("logid");

if (action == null) {
    action = "";
    qdivision = (String)session.getAttribute("qdivision");
    qdescript = (String)session.getAttribute("qdescript");
    quserid = (String)session.getAttribute("quserid");
    //第一次
    String isquery = strCheckNull( request.getParameter("isquery") );
    if (isquery.length() == 0) { //第一次設定日期為今天
        qsdate = AbDate.getToday();
        qedate = qsdate;
    } else {
        qsdate = (String)session.getAttribute("qsdate");
        qedate = (String)session.getAttribute("qedate");
    }
}
if (qdivision == null) qdivision = "";
if (qdescript == null) qdescript = "";
if (quserid == null) quserid = "";
if (qsdate == null) qsdate = "";
if (qedate == null) qedate = "";
quserid = quserid.toUpperCase();

if (action.equals("清除條件")) {
    qdivision=""; qdescript=""; quserid=""; qsdate=""; qedate="";
}

session.setAttribute("qdivision", qdivision);
session.setAttribute("qdescript", qdescript);
session.setAttribute("quserid", quserid);
session.setAttribute("qsdate", qsdate);
session.setAttribute("qedate", qedate);

session.setAttribute("logid", logid);

//頁數
int p = 1;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}

//限制條件
if (!userDivision.equals(evtaId)) qdivision = userDivision;
String srch = " and logid = " + AbSql.getEqualStr(logid);
//if (qdivision.length() > 0)
    srch += " and division = " + AbSql.getEqualStr(qdivision);
if (qdescript.length() > 0) srch += " and descript like " + AbSql.getLikeStr(qdescript);
if (quserid.length() > 0) srch += " and userid like " + AbSql.getLikeStr(quserid);
if (qsdate.length() > 0) srch += " and opdate >= " + AbSql.getEqualStr(qsdate);
if (qedate.length() > 0) srch += " and opdate <= " + AbSql.getEqualStr(qedate);
if (srch.length() > 0) {
    srch = " where " + srch.substring(4);
}

String qs = "";
qs = "select count(*) from logdata" + srch;
Statement stmt = conn.createStatement();
ResultSet rs = common.Comm.querySQL(stmt, qs);
rs.next();
int totItem = rs.getInt(1);
rs.close();
if (debug)
    response.getWriter().println(qs + "<BR>");

//計算頁數
int ptot = ((totItem-1) / pmax) + 1;


%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>


<body bgcolor="#F9CD8A">

<center>
<table width="600" border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td align=center><img src="../image/LogDownList.gif" alt="下載日誌查詢" >
    </td>
  </tr>
  <tr>
      <td align=center><%=common.Comm.getCodeTitle(stmt, logid, "logid", "logid", "descript") + " (" + logid + ")"%>
    </td>
  </tr>
  <tr>
    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
    </td>
  </tr>
</table>

<form action="<%=thisPage%>" method=post name="form1">
    <input name="logid" type="hidden" value=<%=logid%>>
    <input name="isquery" type="hidden" value="Y">
<table border=1 width=800 bgcolor="#fff0c1">
  <tr bgcolor="#F8BE67">
<%if (userDivision.equals(evtaId)) { %>
    <td align="right" width=12%><font color="#990000">單位名稱：</font></td>
<%} %>
    <td width=24%>
        <select size="1" name="qdivision" style="HEIGHT: 22px; WIDTH: 120px">
            <!--<option value=""></option>-->
<%
        qs = "select id,title from division order by id";
        rs = common.Comm.querySQL(stmt, qs);
        while (rs.next()) {
            String selected = "";
            String division = strCheckNull( rs.getString("id") );
            if (qdivision.equals(division)) selected = "selected";
%>
            <option value="<%=division%>" <%=selected%>><%=rs.getString("title")%></option>
<%
        }
        rs.close();
%>
        </select>
    </td>
    <td align="right" width=12%><font color="#990000">下載日期：</font></td>
    <td width=52%>
        <input type="text" name="qsdate" maxlength="8" size="8" value="<%=qsdate%>">
        ～
        <input type="text" name="qedate" maxlength="8" size="8" value="<%=qedate%>">
    </td>
  </tr>
  <tr bgcolor="#F8BE67">
    <td align="right"><font color="#990000">姓名：</font></td>
    <td>
        <input type="text" name="qdescript" maxlength="20" size="20" value="<%=qdescript%>">
    </td>
    <td align="right"><font color="#990000">使用者ID：</font></td>
    <td>
        <input type="text" name="quserid" maxlength="10" size="10" value="<%=quserid%>">
    </td>
  </tr>
</table>
<input type="submit" value="查詢資料" name="action">
<input type="submit" value="清除條件" name="action">
</form>



<!--表頭-->
<table border=0 width=800>
    <tr>
        <form action="LogDataExcel.jsp">
        <td width=15% align=left>
                <input type="hidden" name="logid" value="<%=logid%>">
                <input type="hidden" name="srch" value="<%=srch%>">
                <input value=清冊下載 type=submit >
        </td>
        </form>
        <td width=20% align=left>
            共有 <b><%=totItem%></b> 筆，<b><%=p%>/<%=ptot%></b> 頁
        </td>
        <td align="left" width=65%>

<%  //顯示頁數
if (p > ptot) p = ptot;
int p0 = p - 5;
if (p0 < 1) p0 = 1;

if (ptot > 1) {
    if (p > 1) out.print("<a href=\"" + thisPage + "?p=" + (p-1) + "&isquery=Y" + "\"><u>上一頁</u></a>");
    for (int i = 0; ((i+p0) <= ptot) && (i < 10); i++) {
        if ((i+p0) == p) {
            out.print("<font color=#ff0000><b>&nbsp;&nbsp;" + (i+p0) + "</b></font>");
        } else {
            out.print("&nbsp;&nbsp;<a href=\"" + thisPage + "?p=" + (i+p0) + "&isquery=Y" + "\"><u>" + (i+p0) + "</u></a>");
        }
    }
    if ((p*pmax) < totItem) out.print("&nbsp;&nbsp;<a href=\"" + thisPage + "?p=" + (p+1) + "&isquery=Y" + "\"><u>下一頁</u></a>");
}
%>

        </td>
    </tr>
</table>


<!--顯示資料-->
<table bgcolor="#F8BE67" bordercolor="#FF9900" border="1" cellPadding="0" cellSpacing="1" width=800 >
    <tr bgcolor="#FF9900">
        <td align="center" width="12%">單位名稱</td>
        <td align="center" width="10%">姓名</td>
        <td align="center" width="10%">ID</td>
        <td align="center" width="10%">下載日期</td>
        <td align="center" width="10%">下載時間</td>
        <td align="center" width="48%">查詢條件</td>
    </tr>

<%
qs = "select logdata.*, division.title as divtitle"
    + " from logdata left join division on logdata.division=division.id"
    + srch
    + " order by opdate desc, optime desc, division, userid";
stmt = conn.createStatement();
rs = common.Comm.querySQL(stmt, qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;
while (rs.next() && (cnt < pmax)) {
    cnt++;
    String divtitle = strCheckNullHtml(rs.getString("divtitle"));
    String descript = strCheckNullHtml(rs.getString("descript"));
    String userid = AbString.rtrimCheck(rs.getString("userid"));
    String opdate = strCheckNullHtml(rs.getString("opdate"));
    String optime = strCheckNullHtml(rs.getString("optime"));
    String data = strCheckNullHtml(rs.getString("data"));
    if (userid.length() > 3) userid = userid.substring(0,3) + String.join("", Collections.nCopies(userid.length()-3, "*"));
%>
    <tr bgColor="#fff0c1">
        <td align="center"><%=divtitle%></td>
        <td align="center"><%=descript%></td>
        <td align="center"><%=userid%></td>
        <td align="center"><%=opdate%></td>
        <td align="center"><%=optime%></td>
        <td align="left"><%=data%></td>
    </tr>
<%
}
//關閉連線
if (rs != null) rs.close();
if (stmt != null) stmt.close();
if (conn != null) conn.close();
%>

</table>

</center>

</body>
</html>
