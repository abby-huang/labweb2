<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領外國人在台天數查詢";
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

<center>
<table width="600" border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td align=center><img src="../image/qry_dayintw.gif" alt="外勞在台天數" >
    </td>
  </tr>
  <tr>
    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
    </td>
  </tr>
</table>

    <form action="QryDayintwDetail.jsp" method="post" onsubmit="return checkPassno(this);">
      <table bordercolor="#FF9900" width="500" border="1">
          <tr bgcolor="#F8BE67">
            <td width="30%" align=right >國籍：
            </td>
            <td width="70%" bgcolor="#F8BE67">
                <select  name=natcode style="HEIGHT: 22px; WIDTH: 140px">
<%for (int i = 0; i < natcodes.length; i++) {%>
                    <option value=<%=natcodes[i]%>><%=natcodes[i]%>-<%=natnames[i]%></option>
<%}%>
                </select>
            </td>
          </tr>
              <p align="center">
          <tr bgcolor="#F8BE67">
            <td align=right>護照號碼：</div>
            </td>
            <td bgcolor="#F8BE67">
                <input type=text style="TEXT-TRANSFORM: uppercase" name=passno>＜請注意英文大小寫＞
            </td>
          </tr>
          <tr bgcolor="#F8BE67">
            <td colspan=2 height="37" align=center><input value="查詢" type=submit>
            </td>
          </tr>
    </form>
</table>
<p>
<center><font color="#990000">說明：查詢時，請輸入國籍及護照號碼</font></center>

<table border=0 width=600>
    <tr align=left><td colspan=6><font color="#990000">
                <td valign=top width=6%><font color="#990000">★★</td>
                <td><font color="#990000"><b>本系統僅提供持有同一護照號碼外國人之在臺累計工作天數資料，該名外國人如持有其他護照(不同護照號碼)  申請入國工作，其在台工作天數仍需合併計算，累計不得超過１２年。</b></font></td>
    </tr>
    <tr align=left><td colspan=6><font color="#990000">
                <td valign=top><font color="#990000">★★</td>
                <td><font color="#990000"><b>本系統資料與入出國及移民署資料不一致時，以入出國及移民署資料為準。</b></font></td>
    </tr>

</table>

</BODY>
</HTML>
