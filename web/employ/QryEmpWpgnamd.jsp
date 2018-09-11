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
String pageHeader = "藍領外國人雇主個別查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;

//取得輸入資料
String commid = AbString.rtrimCheck( request.getParameter("commid") ).toUpperCase().trim();

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
ResultSet rs;
String qs;

//限制條件
String search = "";

//被看護人查詢
if (commid.length() < 10) commid = AbString.leftJustify(commid, 10).trim();
search += " where commid = " + AbSql.getEqualStr(commid);

String srchdata = "";
if (commid.length() > 0) {
    if (srchdata.length() > 0) srchdata += "，";
    srchdata += "被看護人編號：" + commid;
}

//寫入日誌檔
common.Comm.logOpData(stmt, userData, "Wpgnamd", srchdata, userAddr);

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<BODY bgcolor="#F9CD8A">

<%
//查詢 fpv_wpgnamd
String caseno = "";
String applkind = "";
boolean hasdata = false;
qs = "select * from fpv_wpgnamd where commid = " + AbSql.getEqualStr(commid)
        + " order by wpindate desc";
rs = common.Comm.querySQL(stmt, qs);
if (rs.next()) {
    caseno = AbString.rtrimCheck( rs.getString("caseno") );
    applkind = AbString.rtrimCheck( rs.getString("applkind") );
    hasdata = true;
}
rs.close();

if (hasdata) {
    if (caseno.length() < 10) caseno = AbString.leftJustify(caseno, 10);

    //雇主基本資料
    qs = "select * from labdyn_vend where regno = " + AbSql.getEqualStr(caseno.substring(0, 10))
                + " order by regno, wkadseq desc";
    rs = common.Comm.querySQL(stmt, qs);
    String cname = "";
    String addr = "";
    String tel = "";
    String zipcode = "";
    String respname = "";

    rs = common.Comm.querySQL(stmt, qs);
    if (rs.next()) {
        cname = AbString.rtrimCheck( rs.getString("cname") );
        addr = AbString.rtrimCheck( rs.getString("addr") );
        tel = AbString.rtrimCheck( rs.getString("tel") );
        zipcode = AbString.rtrimCheck( rs.getString("zipcode") );
        respname = AbString.rtrimCheck( rs.getString("respname") );
        rs.close();

        //判斷是某轉換 2017.03.14
        boolean haslabor = true;
        qs = "select commid from fpv_wpgnamd where caseno=" + AbSql.getEqualStr(caseno)
                + " and applkind=" + AbSql.getEqualStr(applkind)
                + " and note=" + AbSql.getEqualStr(commid);
        rs = common.Comm.querySQL(stmt, qs);
        if (rs.next()) haslabor = false; //有轉換 -> 無外勞
        rs.close();

        String labono = "";
        if (haslabor) {
            //有無外勞
            qs = "select * from fpv_labom where caseno = " + AbSql.getEqualStr(caseno)
                    + " and applkind = " + AbSql.getEqualStr(applkind) + " and statuscode = 'SAA'";
            rs = common.Comm.querySQL(stmt, qs);
            if (rs.next()) {
                labono = AbString.rtrimCheck( rs.getString("labono") );
            } else {
                haslabor = false;
            }
            rs.close();
        }

        if (haslabor) {
            //顯示外勞詳細資料
            labono = AbString.leftJustify(labono, 13);
            stmt.close();
            if (con != null) con.close();
            response.sendRedirect("../qrylabor/QryLaborDetail.jsp?natcode="
                    + labono.substring(0,3) + "&passno=" + labono.substring(3));
        } else {
            //查無外勞資料
%>
            <input type=button value="回上一頁" onClick="javascript:history.back()">

						<table border=0 width=600>
						<tr>
						  <td>被看護人【<%=commid%>】查無外勞資料
						  </td>
						</tr>
						</table>

            <table border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 width=600>
                <tr>
                    <td width=15% align=center>雇主編號</td>
                    <td width=15% align=center>雇主名稱</td>
                    <td width=45% align=center>地　　址</td>
                    <td width=15% align=center>電話</td>
                    <td width=10% align=center>郵遞<br>區號</td>
                </tr>
                <tr>
                    <td><%=strCheckNullHtml(caseno.substring(0, 10))%></td>
                    <td><%=strCheckNullHtml(cname)%></td>
                    <td><%=strCheckNullHtml(addr)%></td>
                    <td><%=strCheckNullHtml(tel)%></td>
                    <td align=center><%=strCheckNullHtml(zipcode)%></td>
                </tr>
            </table>
            <table border = 0 bgcolor=#F8BE67 bordercolor=#FF9900 width=600>
                <tr>
                    <td>說明：</td>
                </tr>
                <tr>
                    <td><font color="#ff0000">若使用「被看護人查詢功能」查無外勞資料，出現本畫面時，建議再利用「雇主個別查詢功能」中的雇主編號再查一次，從不同角度去查詢相關資料提供參考。</font></td>
                </tr>
            </table>


<%
        }


    } else {
        //查無雇主資料
        rs.close();
%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">

						<table border=0 width=600>
						<tr>
						  <td>該被看護人查無雇主 <%=caseno.substring(0, 10)%> 基本資料
						  </td>
						</tr>
						</table>
<%
    }

} else {
    //查無此被看護人資料
%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">

						<table border=0 width=600>
						<tr>
						  <td>查無此被看護人【<%=commid%>】資料
						  </td>
						</tr>
						</table>

<%
}
%>



<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
    history.back();
</script>
<%}%>

</BODY>
</HTML>