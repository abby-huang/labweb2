<%@ page errorPage="ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "主選單";
request.setCharacterEncoding("UTF-8");
//尚未登入
if (userId.length() == 0) {
    response.sendRedirect("Logout.jsp");
}
%>

<!DOCTYPE html>
<head>
    <%@ include file="include/Header.inc" %>
</head>

<frameset rows="75,*" frameborder="no" border="0" framespacing="0" scrolling="no" noresize>
    <frame src="Top.jsp" frameborder="no" border="0" framespacing="0" scrolling="no" noresize>
    <frameset cols="160,*" frameborder="no" border="0" framespacing="0" scrolling="no" noresize>
        <frame src="Left.jsp" frameborder="no" border="0" framespacing="0" scrolling="no" noresize>
        <frame src="Main.jsp" name="main" frameborder="no" border="0" framespacing="0" scrolling="yes">
    </frameset>
</frameset>

</html>
