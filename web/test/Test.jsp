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

String pageHeader = "測試";
request.setCharacterEncoding("UTF-8");

String errMsg = "";

//建立連線
Connection conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();

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
<%
for (Map.Entry<String, String> entry : common.Comm.logOpIds.entrySet()) {
	out.println("logid : " + entry.getKey() + " 項目 : " + entry.getValue() + "<br>");
}
%>
                </td>
            </tr>
            <tr>
                <td style="word-wrap: break-word">
                    <%=request.getContextPath()%>
                </td>
            </tr>
        </table>
    </center>

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

