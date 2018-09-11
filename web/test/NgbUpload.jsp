<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="com.absys.user.*"%>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="java.security.*"%>
<%@ page import="java.security.spec.*"%>
<%@ page import="javax.crypto.*"%>
<%@ page import="javax.crypto.spec.*"%>
<%@ page import="org.apache.commons.codec.binary.*"%>
<%@ page import="org.apache.commons.io.*"%>
<%@ page import="org.apache.cxf.endpoint.Client"%>
<%@ page import="org.apache.cxf.endpoint.dynamic.DynamicClientFactory"%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%

String pageHeader = "長照推介上載";
request.setCharacterEncoding("UTF-8");

String errMsg = "";

//建立連線
Connection conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();

//String fileName = "ngb20150120.json";
String fileName = "ngb20180730.json";
String filePath = getServletContext().getRealPath("/") + "/test/" + fileName;

//FileInputStream fileins = new FileInputStream( filePath );
//String ngbdata = org.apache.commons.io.IOUtils.toString(fileins, "UTF-8");
BufferedReader in = new BufferedReader(new InputStreamReader(new FileInputStream( filePath ), "UTF-8"));
String ngbdata = org.apache.commons.io.IOUtils.toString(in);
ngbdata = ngbdata.replace("\uFEFF", "");
ngbdata = org.apache.commons.codec.binary.Base64.encodeBase64String( StringUtils.getBytesUtf8(ngbdata) );

DynamicClientFactory dcf = DynamicClientFactory.newInstance();
//Client client = dcf.createClient("https://laborap.wda.gov.tw/labweb/services/LabService?wsdl");
Client client = dcf.createClient("http://192.168.0.2/labweb/services/LabService?wsdl");
Object[] res = client.invoke("uploadNgb", new String[]{fileName, ngbdata});
String retval = (String)res[0];
out.println( retval + "</br>" );

/*
String qs = "select * from fpv_conlab order by keydate desc";
ResultSet rs = stmt.executeQuery(qs);
if (rs.next()) {
    DateFormat tf = new SimpleDateFormat("HH:mm:ss");
    errMsg += AbString.rtrimCheck(rs.getString("keydate"));
    java.util.Date keytime = rs.getTime("keytime");
    if (keytime != null)
        errMsg += AbString.rtrimCheck(tf.format(keytime));
}
rs.close();
*/
%>

<head>
    <%@ include file="/include/Header.inc" %>
    <script language="javascript">
        if (window != top) {
            top.location.href = location.href;
        }
    </script>
</head>


<body bgcolor="#F9CD8A" topmargin="0" leftmargin="0" marginheight=0 marginwidth=0>

    測試資料：</br>
    <%=getServletContext().getRealPath("/")%></br>
    errMsg=<%=errMsg%></br>

    <center>

    <table border=0 width=400>
        <tr align=center>
            <td align=center valign=top>
                <table border=1 bordercolor="#FF9900">
                    <tr>
                        <td align=center bgcolor="#FF9900">
                            <center>
                            <font color="#FFFFFF"><b>訊息</b></font>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <font color="#990000">對不起，沒有權限使用本系統。</font>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

<%
//關閉連線
stmt.close();
if (conn != null) conn.close();
%>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>

</body>
</html>

