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
String pageHeader = "行蹤不明藍領外國人查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();
//尚未登入
if (userId.length() == 0) {
    response.sendRedirect("../Logout.jsp");
}
%>


<html>
<head>

<%@ include file="/include/HeaderTimeout.inc" %>

<script language="JavaScript">
function checkPassno(frm)
{
    frm.passno.value = frm.passno.value.replace(/^\s+|\s+$/g,'');
    if (frm.passno.value != "")
        return true;
    else {
        alert ("請輸入護照號碼!");
        return false;
    }
}
</script>

</head>

<BODY bgcolor="#F9CD8A" text="#990000">
<META content="MSHTML5.00.2014.210" name=GENERATOR>
<META content="MSHTML 5.00.2014.210" name=GENERATOR>
<META content="MSHTML 5.00.2014.210" name=GENERATOR>

<center>
<table width="600" border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td align=center><img src="../image/qry_escape.gif" alt="行蹤不明外勞查詢" >
    </td>
  </tr>
  <tr>
    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
    </td>
  </tr>
</table>

      <form action="QryEscapeDetail.jsp" method="post" onsubmit="return checkPassno(this);">
        <table width="500" border="1" bordercolor="#FF9900">
          <tr bgcolor="#F8BE67">
            <td width="30%" align=right>國籍：
            </td>
            <td width="70%" align=left>
                <select  name=natcode style="HEIGHT: 22px; WIDTH: 140px">
<%for (int i = 0; i < natcodes.length; i++) {%>
                    <option value=<%=natcodes[i]%>><%=natnames[i]%></option>
<%}%>
                </select>
            </td>
          </tr>
          <tr bgcolor="#F8BE67">
            <td align=right ><font color="#990000">護照號碼：</font>
            </td>
            <td >
              <input type=text name=passno>＜請注意英文大小寫＞</td>
          </tr>
          <tr bgcolor="#F8BE67">
            <td height="37" colspan=2 align=center><input value="查詢" type=submit>
            </td>
          </tr>
        </table>
      </form>
<p>
<center><font color="#990000">說明：查詢時，請輸入國籍及護照號碼</font></center>

</BODY>
</HTML>


