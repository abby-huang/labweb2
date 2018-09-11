<%@ page pageEncoding="UTF-8" contentType="text/html"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="common.*"%>
<%@ include file="include/LoginData.jsp" %>

<%
String pageHeader = "導向系統";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

String sysid = AbString.rtrimCheck(request.getParameter("sysid")).toLowerCase();

//設定共用參數
session.setAttribute("appName", Consts.appName);
session.setAttribute("appRoot", Consts.appRoot);

session.setAttribute(Consts.appName+"_userLogin", "1");
session.setAttribute(Consts.appName+"_loginPage", Consts.appRoot+"Login.jsp");

String nextPage = Consts.appRoot + "/Logout.jsp";
if (sysid.equals("mntstaff")) {
    nextPage = Consts.appRoot + "/admin/MntStaff.jsp";
} else if (sysid.equals("mntdivision")) {
    nextPage = Consts.appRoot + "/admin/MntDivision.jsp";
} else if (sysid.equals("outlab")) {
    nextPage = Consts.appRoot + "/outlab/OutLabMnt.jsp";
}
response.sendRedirect(nextPage);

%>
