<%@ page pageEncoding="UTF-8" contentType="text/html"%>
<%
String loginPage = "/labweb/Login.jsp";
session.invalidate();
%>
<script type="text/javascript">
    //alert('系統已登出，請重新登入！');
    window.location = '<%=loginPage%>';
</script>
