<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領外國人僱用清冊";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y") || !userOpdown.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

String errMsg = "";
Connection con = null;

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

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

<script src="<%=appRoot+"/ext321"%>/adapter/ext/ext-base.js"></script>
<script src="<%=appRoot+"/ext321"%>/ext-all.js"></script>
<link rel="stylesheet" type="text/css" href="<%=appRoot+"/ext321"%>/resources/css/ext-all.css" />

<script language="JavaScript">
function checkAddrtype(frm)
{
    if (frm.addrtype.value == "1") {
        //雇主地址
        frm.action = "QryEmpListMainComm.jsp";
    } else if ((frm.addrtype.value == "2") || (frm.addrtype.value == "3")) {
        //外勞居留地，工作地址
        frm.action = "QryEmpListMainComm2.jsp";
    }
    frm.submit.disabled = true;

    Ext.MessageBox.show({
       msg: '資料查詢中, 請稍候...',
       progressText: '查詢中...',
       width:260,
       wait:true,
       waitConfig: {interval:100},
       animEl: ''
   });

    return true;
}
</script>

</head>


<BODY bgcolor="#F9CD8A" text="#990000">
<center>
<table width="600" border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td align=center><img src="../image/qry_empbizdown.gif" alt="僱用外勞清冊" >
    </td>
  </tr>
  <tr>
    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
    </td>
  </tr>
</table>

<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="600">
   <tr bgcolor="#FF9900">
       <td colspan=2><img src="../image/arrow.gif" alt="美化圖形">
         <font color="#FFFFFF">雇主僱用外勞清冊</font>
       </td>


            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logEmpList%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>
   </tr>

<form action="" method="post" onsubmit="return checkAddrtype(this);">
   <tr bgcolor="#F8BE67">
       <td width="25%" align=right>縣市轄區：
       </td>
       <td width="75%" bgcolor="#F8BE67" colspan=2>
<%
//全區
if (userRegion.equals("*")) {
%>
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 126px">
<%
    qs = "SELECT citycode, cityname FROM fpv_citym"
        + " WHERE citytype='A'"
        + " AND (citycode > '00' AND citycode <= '25')"
        + " ORDER BY citycode";
    rs = common.Comm.querySQL(stmt, qs);
    while (rs.next()) {
                String citycode = rs.getString("citycode");
                String cityname = rs.getString("cityname").substring(0, 3);
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
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 126px">
<%
        for (int i = 0; i < rgns.length; i++) {
            qs = "SELECT citycode, cityname FROM fpv_citym"
                + " WHERE citytype='A'"
                + " AND citycode = " + AbSql.getEqualStr( rgns[i] );
            rs = common.Comm.querySQL(stmt, qs);
            if (rs.next()) {
                String citycode = rs.getString("citycode");
                String cityname = rs.getString("cityname").substring(0, 3);
                cityname = checkCityName(citycode, cityname);
%>
                    <option value="<%=citycode%>"><%=cityname%></option>
<%
            }
            rs.close();
        }
%>
                </select><%=userDivtitle%>
<%
    //單區
    } else {
%>
                <%=userDivtitle%>
                <input name="citycode" type="hidden" value=<%=userRegion%>>
<%
    }
}
%>

          <select name=addrtype style="FONT-FAMILY: 細明體, 標楷體; HEIGHT: 22px; WIDTH: 185px" size=1>
              <option value=1>雇主地址</option>
              <option value=2>工作地址</option>
              <option value=3>外勞居留地(警政署提供)</option>
          </select>

       </td>
   </tr>
   <tr bgcolor="#F8BE67">
       <td align=right>行職業別：
       </td>
       <td colspan=2 >
              <select name=bizseq style="FONT-FAMILY: 細明體, 標楷體; HEIGHT: 22px; WIDTH: 126px" size=1>
<%for (int i = 0; i < bizkinds.length; i++) {%>
                    <option value=<%=i%>><%=bizkinds[i]%></option>
<%}%>
              </select>
       </td>
   </tr>
<!--
   <tr bgcolor="#F8BE67">
       <td align=right >現僱外勞人數：
       </td>
       <td colspan=2 >
              <input name=stot type=text value=1 style="HEIGHT: 22px; WIDTH: 80px" size=6 maxlength=10>
              <font color="#990000">人&nbsp;至&nbsp;
              <input name=etot type=text style="HEIGHT: 22px; WIDTH: 80px" size=5 maxlength=10>
              人（可不輸入） </font></td>
   </tr>
-->
   <tr bgcolor="#F8BE67">
       <td align=right >外勞國籍別：</font></div>
       </td>
       <td colspan=2 >
                <select name=natcode style="FONT-FAMILY: 細明體, 標楷體; HEIGHT: 22px; WIDTH: 126px" size=1>
                    <option value='' selected>(全選)</option>
<%for (int i = 0; i < natcodes.length; i++) {%>
                    <option value=<%=natcodes[i]%>><%=natcodes[i]%>-<%=natnames[i]%></option>
<%}%>
                </select><br>(建議：外勞人數多的縣市可選擇國籍分批下載，成功率較高)
       </td>
   </tr>

  <tr bgcolor="#F8BE67">
      <td align="right">
            <font color="#990000">外勞狀態：</font>
      </td>
      <td colspan=2 >
          <select name=status style="FONT-FAMILY: 細明體, 標楷體; HEIGHT: 22px; WIDTH: 80px" size=1>
              <option value=1>合法</option>
              <option value=3>全部</option>
          </select>
      </td>
  </tr>

   <tr bgcolor="#F8BE67">
       <td height="37">
       </td>
       <td colspan=2 >
              <input value=查詢 style="HEIGHT: 24px; WIDTH: 58px" type=submit name="submit">(請勿重覆按查詢鍵，清冊下載時請耐心等待主機作業)
       </td>
   </tr>
</table>
</form>

<table border=0 width=600>
    <tr align=left><td colspan=6>
        <td width=6% valign=top><font color="#990000">★★</td>
        <td><font color="#990000">外勞清冊下載功能常因多人同時下載，造成主機負擔過重致使無法下載成功。若想改採直接下載清冊檔案者請使用下表之外勞清冊檔案直接下載功能。</td>
    </tr>
    <tr align=left><td colspan=6>
        <td width=6% valign=top><font color="#990000">★★</td>
        <td><font color="#990000">外勞清冊檔案直接下載功能，是由主機晚上自動批次下載外勞清冊，於每日早上九點之前完成提供下載。其下載條件為：雇主地址、不限現僱外勞人數、不限外勞國籍別、外勞狀態為合法之外勞。</td>
    </tr>
</table>


<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="600">
   <tr bgcolor="#FF9900">
       <td colspan=2><img src="../image/arrow.gif" alt="美化圖形">
         <font color="#FFFFFF">外勞清冊檔案直接下載</font>
       </td>


            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logEmpList%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>
   </tr>

<form action="QryEmpListDo.jsp" method="post">
   <tr bgcolor="#F8BE67">
       <td width="25%" align=right>縣市轄區：
       </td>
       <td width="75%" bgcolor="#F8BE67" colspan=2>
<%
//全區
if (userRegion.equals("*")) {
%>
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 126px">
<%
    qs = "SELECT citycode, cityname FROM fpv_citym"
        + " WHERE citytype='A'"
        + " AND (citycode > '00' AND citycode <= '25')"
        + " ORDER BY citycode";
    rs = common.Comm.querySQL(stmt, qs);
    while (rs.next()) {
                String citycode = rs.getString("citycode");
                String cityname = rs.getString("cityname").substring(0, 3);
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
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 126px">
<%
        for (int i = 0; i < rgns.length; i++) {
            qs = "SELECT citycode, cityname FROM fpv_citym"
                + " WHERE citytype='A'"
                + " AND citycode = " + AbSql.getEqualStr( rgns[i] );
            rs = common.Comm.querySQL(stmt, qs);
            if (rs.next()) {
                String citycode = rs.getString("citycode");
                String cityname = rs.getString("cityname").substring(0, 3);
                cityname = checkCityName(citycode, cityname);
%>
                    <option value="<%=citycode%>"><%=cityname%></option>
<%
            }
            rs.close();
        }
%>
                </select><%=userDivtitle%>
<%
    //單區
    } else {
%>
                <%=userDivtitle%>
                <input name="citycode" type="hidden" value=<%=userRegion%>>
<%
    }
}
%>

       </td>
   </tr>
   <tr bgcolor="#F8BE67">
       <td align=right>行職業別：
       </td>
       <td colspan=2 >
              <select name=bizseq style="FONT-FAMILY: 細明體, 標楷體; HEIGHT: 22px; WIDTH: 126px" size=1>
<%for (int i = 0; i < bizkinds.length; i++) {%>
                    <option value=<%=i%>><%=bizkinds[i]%></option>
<%}%>
              </select>
       </td>
   </tr>
   <tr bgcolor="#F8BE67">
       <td height="37">
       </td>
       <td colspan=2 >
              <input value=下載 style="HEIGHT: 24px; WIDTH: 58px" type=submit name="submit">
       </td>
   </tr>
</table>
</form>

</br>
</br>


<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>

</BODY>
</HTML>

