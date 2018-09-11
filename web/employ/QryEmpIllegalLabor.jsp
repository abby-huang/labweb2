<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領外國人雇主違法查詢 - 外勞列表";
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
//String regno = strCheckNull(request.getParameter("regno"));
session.setAttribute("regno", AbString.rtrimCheck(request.getParameter("regno") ));
String regno = (String)session.getAttribute("regno");

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

//頁數
int p = 1;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}

ResultSet rs;

//呼叫 Procedure
CallableStatement stmt = con.prepareCall("BEGIN get_emp_illegal_labor(?, ?); END;");
stmt.setString(1, regno); // id
stmt.registerOutParameter(2, oracle.jdbc.OracleTypes.CURSOR); //REF CURSOR

/*
//計算筆數
CallableStatement stmt2 = con.prepareCall("BEGIN get_emp_illegal_count(?, ?); END;");
stmt2.setString(1, "G"); // id
stmt2.registerOutParameter (2, Types.INTEGER);
stmt2.execute();
int totItem = stmt2.getInt(2);
*/

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<center>

<table border=0 width=600>
    <form action="">
    <td align=left width=5%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </td>
    </form>
    <td width=85%>
    </td>
</table>

<table border=0 width=640>
<tr>
  <td>※非法外勞(本資料由外籍勞工查察暨諮詢管理資訊系統資料庫提供)
  </td>
</tr>
<tr>
  <td>雇主編號：<%=regno%>
  </td>
</tr>
</table>

<table border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 width=640>
<tr>
    <td width=12% align=center >國籍</td>
    <td width=18% align=center >護照號碼</td>
    <td width=25% align=center >外勞姓名</td>
    <td width=* align=center >雇主地址</td>
</tr>

<%
//顯示資料
//從 exprvend 讀取資料
stmt.execute();
rs = (ResultSet)stmt.getObject(2);
while (rs.next()) {
    //讀負責人編號姓名
    String natiname = strCheckNull( rs.getString("natiname") );
    String passno = strCheckNull( rs.getString("passno") );
    String laboname = strCheckNull( rs.getString("laboname") );
    String empaddr = (strCheckNull( rs.getString("city") ) + strCheckNull( rs.getString("emp_addr_ro") )).replace("　", "");
%>



<tr>
    <td align=center><%=strCheckNullHtml(natiname)%></td>
    <td align=center><%=strCheckNullHtml(passno)%></td>
    <td align=left><%=strCheckNullHtml(laboname)%></td>
    <td align=left><%=strCheckNullHtml(empaddr)%></td>
</tr>

<%
}
rs.close();
%>

</table>


<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>


</BODY>
</HTML>