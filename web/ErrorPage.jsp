<%@ page isErrorPage="true" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
//取得錯誤訊息
String debugMsg = (String)session.getAttribute("debugMsg");
if (debugMsg == null) debugMsg = "";
%>

<!DOCTYPE html>
<head>
	<title>Error Page:</title>
</head>

<body>

<h1>系統發生錯誤：</h1>
錯誤訊息：<%= exception %><p>
<%=debugMsg%><p>
<font color="ff0000">請將上述錯誤訊息紀錄下來，以便通知系統人員。</font>

</body>
</html>
