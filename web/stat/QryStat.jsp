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
String pageHeader = "統計資訊";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

String errMsg = "";
Connection con = null;

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

try {

String qs = "";
Statement stmt = null;
ResultSet rs = null;
if (errMsg.length() == 0) {
    stmt = con.createStatement();
}
%>

<html>
<head>

<%@ include file="/include/HeaderTimeout.inc" %>

<script language="JavaScript">
function checkStartEndDate(frm)
{
    frm.startdate.value = frm.startdate.value.replace(/^\s+|\s+$/g,'');
    frm.enddate.value = frm.enddate.value.replace(/^\s+|\s+$/g,'');
    if ((frm.startdate.value.length == 6))
        return true;
    else {
        alert ("請輸入正確日期");
        return false;
    }
}

</script>

</head>

<BODY bgcolor="#F9CD8A" >
<table width=90% border="0" cellspacing="2" cellpadding="2" align="center">
  <tr>
    <td align="center"><img src="../image/statistics.gif" >
    </td>
  </tr>
  <tr>
    <td>
      <div align="center"><img src="../image/line_main.gif" ></div>
    </td>
  </tr>
</table>

        <table width="90%" border="1" cellspacing="1" cellpadding="1" align="center" bordercolor="#FF9900">
          <tr bgcolor="#FF9900">
            <td nowrap height="2" colspan=2><font color="#990000"><img src="../image/arrow.gif" ></font><font color="#FFFFFF">
              統計資訊（請先選擇欲統計的條件）</font></td>



            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logStat%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>

          </tr>


      <form action="QryStatMain.jsp" method="post" onsubmit="return checkStartEndDate(this);">
          <tr bgcolor="#F8BE67">
            <td width="35%" align="right"><font color="#990000">統計報表種類:</font>
            </td>
            <td width="65%" bgcolor="#F8BE67" colspan=2 >
                <select name=statkind style="FONT-FAMILY: 細明體, 標楷體; HEIGHT: 22px; WIDTH: 200px" size=1>
                    <option value=01>縣市轄區開放項目別統計</option>
                    <option value=02>縣市轄區國籍別人數統計</option>
                    <option value=03>縣市轄區在華人數統計</option>
                </select>
            </td>
          </tr>

          <tr bgcolor="#F8BE67">
            <td width="26%" align="right"><font color="#990000">縣市轄區:</font>
            </td>
            <td width="74%" bgcolor="#F8BE67" colspan=2>
<%
//全區
if (userRegion.equals("*")) {
%>
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 200px">
<%
    qs = "SELECT citycode, cityname FROM fpv_citym"
        + " WHERE citytype='A'"
        + " AND (citycode > '00' AND citycode < '99' AND citycode <> '44')"
        + " ORDER BY citycode";
    rs = stmt.executeQuery(qs);
    while (rs.next()) {
                String citycode = rs.getString("citycode");
                String cityname = rs.getString("cityname");
                cityname = checkCityName(citycode, cityname);
%>
                    <option value="<%=citycode%>"><%=cityname%></option>
<%
    }
    rs.close();
%>
                </select>
<%
} else {
    String rgns[] = userRegion.split(",");
    //多區
    if (rgns.length > 1) {
%>
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 200px">
<%
        for (int i = 0; i < rgns.length; i++) {
            qs = "SELECT citycode, cityname FROM fpv_citym"
                + " WHERE citytype='A'"
                + " AND citycode = " + AbSql.getEqualStr( rgns[i] );
            rs = stmt.executeQuery(qs);
            if (rs.next()) {
                String citycode = rs.getString("citycode");
                String cityname = rs.getString("cityname");
                cityname = checkCityName(citycode, cityname);
%>
                    <option value="<%=citycode%>"><%=cityname%></option>
<%
            }
            rs.close();
        }
%>
                </select>
<%
    //單區
    } else {
%>
                <%=userDivtitle%>
                <input  name="citycode" type="hidden" value=<%=userRegion%>>
<%
    }
}
%>
            </td>
          </tr>
          <tr bgcolor="#F8BE67">
            <td align="right" valign="top" ><font color="#990000">統計年月區間:</font>
            </td>
            <td colspan=2>
                <input type=text name=startdate value="" maxlength=6  style="HEIGHT: 22px; WIDTH: 50px">
                ～
                <input type=text name=enddate value="" maxlength=6  style="HEIGHT: 22px; WIDTH: 50px">
                (yyyymm 西元年月)<br>
                單月查詢，只輸入第一個即可<br>
                開放項目別，只能單月查詢
            </td>
          </tr>
          <tr bgcolor="#F8BE67">
            <td height="37"><font color="#FFFFFF"></font></td>
            <td height="37" colspan=2>
              <input value=開始統計 style="HEIGHT: 24px; WIDTH: 58px" type=submit name="submit"><br>
              <font color="#FF0000">說明：因資料庫轉置之因素，每月21日之後方可查詢到前一個月份的統計資訊。</font>
            </td>
          </tr>
          </table>
</form>





<p>
        <table width="90%" border="1" cellspacing="1" cellpadding="1" align="center" bordercolor="#FF9900">
          <tr bgcolor="#FF9900">
            <td nowrap height="2" colspan=2><font color="#990000"><img src="../image/arrow.gif" ></font><font color="#FFFFFF">
              其他統計資訊</font></td>
          </tr>
          <tr bgcolor="#F8BE67">
            <td width="40%" align="right"><font color="#990000">警政署統計資料網站</font>
            </td>
            <td width="60%" bgcolor="#F8BE67"><a href="http://www.npa.gov.tw/NPAGip/wSite/np?ctNode=11358&mp=1">外籍勞工居住行方不明違法通報</a>
            </td>
          </tr>
          <tr bgcolor="#F8BE67">
            <td align="right"><font color="#990000">勞動力發展署統計資料網站</font>
            </td>
            <td bgcolor="#F8BE67"><a href="http://www.mol.gov.tw/statistics/" target="_blank">勞動力發展署統計資訊</a>
            </td>
          </tr>


<%
//關閉連線
stmt.close();

} finally {
    if (con != null) con.close();
}
%>


</BODY>
</HTML>