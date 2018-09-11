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
<%@ page import="org.apache.commons.io.FileUtils"%>
<%@ page import="org.apache.cxf.endpoint.Client"%>
<%@ page import="org.apache.cxf.endpoint.dynamic.DynamicClientFactory"%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%

String pageHeader = "測試 web service";
request.setCharacterEncoding("UTF-8");

String errMsg = "";

//建立連線
Connection conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();

DynamicClientFactory dcf = DynamicClientFactory.newInstance();

//Client client = dcf.createClient("http://192.168.0.2/labweb/services/LabService?wsdl");
//Client client = dcf.createClient("https://192.168.0.2/labweb/services/LaborWS?wsdl");
Client client = dcf.createClient("https://laborap.wda.gov.tw/labweb/services/LaborWS?wsdl");

//Object[] res = client.invoke("laborNgbandy", new String[]{"mhwws", "mhwws201503", "R200089366"});
Object[] res = client.invoke("laborRegno", new String[]{"mhwws", "mhwws201503", "25475398"});
//Object[] res = client.invoke("laborRegno", new String[]{"abby", "abby19620406", "25475398"});
//Object[] res = client.invoke("laborAirport", new String[]{"mhwws", "mhwws201503", "009", "AR763931"});

String retval = (String)res[0];
//out.println( retval + "</br>" );

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


<body>

    <center>
        <table border="1" style="table-layout:fixed; width:800px;">
            <tr>
                <td align=center>
                    <center>
                        <b>測試資料</b>
                    </center>
                </td>
            </tr>
            <tr>
                <td style="word-wrap: break-word">
                     <%=retval%>
                </td>
            </tr>
        </table>
    </center>

<%
//關閉連線
//stmt.close();
//if (conn != null) conn.close();
%>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>

</body>
</html>

