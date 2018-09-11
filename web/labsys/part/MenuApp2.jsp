<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="com.absys.user.*"%>
<%@ include file="../include/LoginData.jsp" %>

<%
int menuSys = 0;
%>

<!-- 選單 - 系統維護 -->
<ul id="ddsubmenuSys" class="ddsubmenustyle">
    <% if (userLogin && (userData != null) && modules.hasPrivelege("staff", userData.privilege) && userData.branch.equals(evtaId)) { menuSys++; %>
        <li><a href="<%=appRoot%>/admin/MntDivision.jsp" >使用者單位管理</a></li>
    <% } %>
    <% if (userLogin && (userData != null) && modules.hasPrivelege("staff", userData.privilege)) { menuSys++; %>
        <li><a href="<%=appRoot%>/admin/MntStaff.jsp" >使用者帳號管理</a></li>
    <% } %>
    <% if (userLogin && (userData != null) && modules.hasPrivelege("staff", userData.privilege)) { menuSys++; %>
        <li><a href="<%=appRoot%>/admin/QryStaff.jsp" >使用者名冊查詢</a></li>
    <% } %>
    <% if (userLogin && (userData != null) && modules.hasPrivelege("staff", userData.privilege)) { menuSys++; %>
        <li><a href="<%=appRoot%>/admin/QryStaffCancel.jsp" >已刪除的使用者</a></li>
    <% } %>
    <% if (userLogin && (userData != null) && modules.hasPrivelege("staff", userData.privilege) && userData.branch.equals(evtaId)) { menuSys++; %>
        <l><a href="<%=appRoot%>/admin/QryLogUnusual_2.jsp" >異常使用名冊查詢</a></li>
    <% } %>
</ul>


<div class="">

    <!-- 頁面抬頭圖案 abstyle.css -->
    <div class="toptitle"></div>

    <!-- 主選單 -->
    <div id="ddtopmenubar" class="mattskymenu">
        <ul id="ddtopmenu" class="" style="overflow: hidden;">
            <li><a href="../Logout.jsp">登出系統</a></li>
            <li><a href="../../MainManager.jsp">返回動態查詢</a></li>
        </ul>
    </div>
    <script type="text/javascript">
        <% if (menuSys > 0) { %>
            $('#ddtopmenubar ul').append('<li><a href="javascript:" rel="ddsubmenuSys">系統維護</a></li>');
        <% } %>
        ddlevelsmenu.setup("ddtopmenubar", "topbar"); //ddlevelsmenu.setup("mainmenuid", "topbar|sidebar")
    </script>

</div>

