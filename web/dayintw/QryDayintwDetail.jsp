<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="javax.xml.parsers.*" %>
<%@ page import="org.w3c.dom.*" %>
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

//定義變數
String errMsg = "";
Connection con = null;

//取得輸入資料
String natcode = AbString.rtrimCheck(request.getParameter("natcode") );
String passno = AbString.rtrimCheck( request.getParameter("passno") ).toUpperCase();
session.setAttribute("labono", natcode + passno);
String labono = (String)session.getAttribute("labono");

//建立連線
con = common.Comm.getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = con.createStatement();
ResultSet rs;

//寫入日誌檔
String srchdata = "IP：" + userAddr;
if (natcode.length() > 0) srchdata += "，國籍：" + getNatcodeName( natcode, natcodes, natnames);
if (passno.length() > 0) srchdata += "，護照號碼：" + passno;

common.Comm.logOpData(stmt, (com.absys.user.Staff)session.getAttribute(appName+"_userData"), "LaborDayintw", srchdata, userAddr);

String totWrkdayOfLab = "000000";
String remainWrkdayOfLab = "000000";
String today = AbDate.getToday("/");
String now = AbDate.getNowTime(":");
String natiname = getNatcodeName(natcode, natcodes, natnames);

//外勞是否正確
String qs = "select * from fpv_labom"
            + " where labono = " + AbSql.getEqualStr(labono);
//rs = common.Comm.querySQL(stmt, qs);
NamedParameterStatement p = new NamedParameterStatement(con, qs);
rs = p.executeQuery();
if (!rs.next()) {
    errMsg = "此外勞已換發新護照或無此外勞聘僱資料，請重新輸入查詢條件。";
}
rs.close();
p.close();

if (errMsg.length() == 0) {
    HttpURLConnection httpConn = null;
    String responseText = "";
    try {
/*
        //請求參數-國籍護照
        Map<String,Object> params = new LinkedHashMap<>();
        String param1 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><hpMain><plabono>"
                + labono
                + "</plabono><appli>labdyn</appli></hpMain>";
        params.put("xmlData", param1);

        StringBuilder postData = new StringBuilder();
        for (Map.Entry<String,Object> param : params.entrySet()) {
            if (postData.length() != 0) postData.append('&');
            postData.append(URLEncoder.encode(param.getKey(), "UTF-8"));
            postData.append('=');
            postData.append(URLEncoder.encode(String.valueOf(param.getValue()), "UTF-8"));
        }
        byte[] postDataBytes = postData.toString().getBytes("UTF-8");

        //呼叫 HTTP POST Request
        URL url = new URL("http://fpvwebap0.evta.gov.tw/wSite/QryConlaborServlet");
        httpConn = (HttpURLConnection) url.openConnection();
        httpConn.setUseCaches(false);
        httpConn.setDoInput(true);
        httpConn.setDoOutput(true);

        httpConn.setRequestMethod( "POST" );
        httpConn.setRequestProperty( "Content-Type", "application/x-www-form-urlencoded");
        httpConn.setRequestProperty( "charset", "utf-8");
        httpConn.setRequestProperty("Content-Length", String.valueOf(postDataBytes.length));
        DataOutputStream wr = new DataOutputStream(httpConn.getOutputStream());
        wr.write(postDataBytes);
        wr.flush();
        wr.close();

        //接收資料 Response
        int responseCode = httpConn.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_OK) {
            errMsg = "送出 HTTP 請求發生錯誤，錯誤代碼：" + responseCode;
        } else {
            String encoding = httpConn.getContentEncoding();
            encoding = encoding == null ? "UTF-8" : encoding;
            responseText = org.apache.commons.io.IOUtils.toString(httpConn.getInputStream(), encoding);
        }
*/

        //請求參數-國籍護照
        String param1 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><hpMain><plabono>"
                + labono
                + "</plabono><appli>labdyn</appli></hpMain>";
        ArrayList<org.apache.http.NameValuePair> nameValuePairs = new ArrayList<org.apache.http.NameValuePair>();
        nameValuePairs.add(new org.apache.http.message.BasicNameValuePair("xmlData", param1));

        //呼叫 HTTP POST Request
        String url = "http://recvpost.evta.gov.tw/wSite/QryConlaborServlet";
        org.apache.http.client.HttpClient httpclient = new org.apache.http.impl.client.DefaultHttpClient();
        httpclient.getParams().setParameter("http.protocol.content-charset", "UTF-8");
        org.apache.http.client.methods.HttpPost httpPost = new org.apache.http.client.methods.HttpPost(url);
        httpPost.setEntity(new org.apache.http.client.entity.UrlEncodedFormEntity(nameValuePairs));
        org.apache.http.HttpResponse httpresponse = httpclient.execute(httpPost);
        /*
        org.apache.http.impl.client.CloseableHttpClient httpclient = org.apache.http.impl.client.HttpClients.createDefault();
        //httpclient.getParams().setParameter("http.protocol.content-charset", "UTF-8");
        org.apache.http.client.methods.HttpPost httpPost = new org.apache.http.client.methods.HttpPost(url);
        httpPost.addHeader("http.protocol.content-charset", "UTF-8");
        httpPost.setEntity(new org.apache.http.client.entity.UrlEncodedFormEntity(nameValuePairs));
        org.apache.http.client.methods.CloseableHttpResponse httpresponse = httpclient.execute(httpPost);
        */

        //接收資料 Response
        int responseCode = httpresponse.getStatusLine().getStatusCode();
        if (responseCode != org.apache.http.HttpStatus.SC_OK) {
            errMsg = "送出 HTTP 請求發生錯誤，錯誤代碼：" + responseCode;
        } else {
            responseText = org.apache.http.util.EntityUtils.toString(httpresponse.getEntity());
        }

    } catch (Exception e) {
        errMsg = "送出 HTTP 請求發生錯誤，請檢查主機狀況。";
    }

    //解析內容 xml
    if (errMsg.length() == 0) {
        try {
            /*
            DocumentBuilder documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
            */
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            dbf.setValidating(true);
            dbf.setFeature(javax.xml.XMLConstants.FEATURE_SECURE_PROCESSING, true);
            dbf.setFeature("http://xml.org/sax/features/external-general-entities", false);
            dbf.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
            Document document = dbf.newDocumentBuilder().parse(org.apache.commons.io.IOUtils.toInputStream(responseText, "UTF-8"));
            NodeList nl = document.getElementsByTagName("totWrkdayOfLab");
            if(nl.getLength() > 0) {
                totWrkdayOfLab = nl.item(0).getFirstChild().getNodeValue();
            }
            nl = document.getElementsByTagName("remainWrkdayOfLab");
            if(nl.getLength() > 0) {
                remainWrkdayOfLab = nl.item(0).getFirstChild().getNodeValue();
            }
            totWrkdayOfLab = AbString.leftJustify(totWrkdayOfLab, 6);
            remainWrkdayOfLab = AbString.leftJustify(remainWrkdayOfLab, 6);
        } catch (Exception e) {
            errMsg = "返回資料錯誤：" + org.apache.commons.lang.StringEscapeUtils.escapeHtml(responseText);
        }
    }
}

%>


<html>
<head>

<%@ include file="/include/HeaderTimeout.inc" %>
<link rel="stylesheet" type="text/css"  href="../table_me.css">
</HEAD>

<BODY bgcolor="#F9CD8A" leftmargin="0" marginheight="0" marginwidth="0">

<center>
<img src="../image/qry_dayintw.gif" alt="外勞在台天數" >
<center>


<%
//錯誤訊息
if (errMsg.length() > 0) {
%>

    <br><br>
    <%=errMsg%>
    <br><br>
    <!-- <a href="QryDayintw.jsp">重新查詢</a> -->

<%
//顯示資料
} else {
%>

<table border=0 width=600>
    <tr>
        <td width=35%><font color="#990000">外勞國籍：<%=natiname%></font></td>
        <td width=65%><font color="#990000">護照號碼：<%=passno%></font></td>
    </tr>
    <tr>
        <td colspan=2 align=left><font color="#990000">＠ 查詢日期：<%=today%> - <%=now%></font></td>
    </tr>
</table>



<br>
<table border=0 width=600>
    <tr align=left><td colspan=6>
        <td width=6%><font color="#990000">★★</td>
        <td><font color="#990000">截至聘僱關係屆滿合計在台工作總天數　　　　　：
            <% if (totWrkdayOfLab.compareTo("120000") >= 0) { %>
                工作總天數已屆滿12年
            <% } else {%>
                <%=totWrkdayOfLab.substring(0,2)%> 年 <%=totWrkdayOfLab.substring(2,4)%> 月 <%=totWrkdayOfLab.substring(4)%> 天</font>
            <% } %>
        </td>
    </tr>
    <tr align=left>
        <td colspan=6><font color="#990000">
        <td><font color="#990000">★★</td>
        <td><font color="#990000">下次工作聘僱仍可在台剩餘總天數（以１２年計）：
            <% if (totWrkdayOfLab.compareTo("120000") >= 0) { %>
                00 年 00 月 00 天</font></td>
            <% } else {%>
                <%=remainWrkdayOfLab.substring(0,2)%> 年 <%=remainWrkdayOfLab.substring(2,4)%> 月 <%=remainWrkdayOfLab.substring(4)%> 天</font></td>
            <% } %>
    </tr>
</table>

<br>
<table border=0 width=600>
    <tr align=left>
        <td colspan=6><font color="#990000">
        <td valign=top><font color="#990000">★★</td>
        <td><font color="#990000"><b>本系統僅提供該名外國人曾申請變更護照號碼之歷次合併在臺累計工作天數資料，該名外國人如曾以其他姓名或護照號碼等身分申請入國工作，其在臺工作天數仍需合併計算，累計不得超過12年。</b></font></td>
    </tr>
    <tr align=left>
        <td colspan=6><font color="#990000">
        <td valign=top><font color="#990000">★★</td>
        <td><font color="#990000"><b>從事就業服務法第46條第1項第9款規定家庭看護工作之外國人，且經專業訓練或自力學習，而有特殊表現，符合中央主管機關所定之資格、條件者，其在中華民國境內工作期間累計最長14年。</b></font></td>
    </tr>
    <tr align=left>
        <td colspan=6><font color="#990000">
        <td valign=top><font color="#990000">★★</td>
        <td><font color="#990000"><b>本系統資料與內政部移民署資料不一致時，以內政部移民署資料為準。</b></font></td>
    </tr>

</table>
</center>


<center>

<%
} //完成顯示

//關閉連線
stmt.close();
if (con != null) con.close();
%>

</BODY>
</HTML>