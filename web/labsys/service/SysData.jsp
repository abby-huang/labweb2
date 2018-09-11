<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.charset.*"%>
<%@ page import="org.json.simple.*"%>
<%@ page import="org.json.simple.parser.*"%>

<%@ page import="com.absys.util.*" %>
<%@ page import="com.absys.user.*"%>
<%@ page import="common.*"%>
<%@ include file="../include/LoginData.jsp" %>

<%
response.setContentType("application/json; charset=UTF-8");
response.setHeader("Cache-Control","no-cache");
response.setHeader("Pragma","no-cache");
response.setDateHeader ("Expires", 0);
request.setCharacterEncoding("UTF-8");

//檢查登入權限
if (loginUser == null) {
    String result = "{\"msgid\":99,\"msgtxt\":\"系統已經逾時，請重新登入。\"}";
    Comm.outputResponse(response, result, "UTF-8");
    return;
}

//參數
int msgid = 0;
String msgtxt = "";
String result = "";

//系統參數
JSONObject jsonConstants = new JSONObject();
jsonConstants.put("appTitle", Consts.appTitle);
jsonConstants.put("appName", Consts.appName);
jsonConstants.put("appRoot", Consts.appRoot);
jsonConstants.put("partRoot", Consts.partRoot);
jsonConstants.put("cssRoot", Consts.cssRoot);
jsonConstants.put("jsRoot", Consts.jsRoot);
jsonConstants.put("jsver", Consts.jsver);
jsonConstants.put("imgRoot", Consts.imgRoot);
jsonConstants.put("logoutFile", Consts.logoutFile);
jsonConstants.put("menuFile", Consts.menuFile);

//使用者
JSONObject jsonUser = new JSONObject();
jsonUser.put("id", loginUser.id);
jsonUser.put("descript", loginUser.descript);
jsonUser.put("psid", loginUser.psid);
jsonUser.put("branch", loginUser.branch);
jsonUser.put("region", loginUser.region);

//選單 - 系統維護
JSONArray jsonMenuSys = new JSONArray();
if (sysModules.hasPrivelege("staff", loginUser.privilege) && loginUser.branch.equals(Consts.evtaId)) {
    jsonMenuSys.add( Arrays.asList("使用者單位管理", Consts.appRoot + "/admin/MntDivision.jsp") );
}
if (sysModules.hasPrivelege("staff", loginUser.privilege)) {
    jsonMenuSys.add( Arrays.asList("使用者帳號管理", Consts.appRoot + "/admin/MntStaff.jsp") );
}
if (sysModules.hasPrivelege("staff", loginUser.privilege)) {
    jsonMenuSys.add( Arrays.asList("使用者名冊查詢", Consts.appRoot + "/admin/QryStaff.jsp") );
}
if (sysModules.hasPrivelege("staff", loginUser.privilege)) {
    jsonMenuSys.add( Arrays.asList("已刪除的使用者", Consts.appRoot + "/admin/QryStaffCancel.jsp") );
}
if (sysModules.hasPrivelege("staff", loginUser.privilege) && loginUser.branch.equals(Consts.evtaId)) {
    jsonMenuSys.add( Arrays.asList("異常使用名冊查詢", Consts.appRoot + "/admin/QryLogUnusual_2.jsp") );
}

//系統選單
JSONArray jsonMenu = new JSONArray();
jsonMenu.add( Arrays.asList("登出系統", "../Logout.jsp") );
jsonMenu.add( Arrays.asList("返回動態查詢", "../../MainManager.jsp") );
if (jsonMenuSys.size() > 0) {
    jsonMenu.add( Arrays.asList("系統維護", "", jsonMenuSys) );
}



//最上層資料 -> json {"data"}
JSONObject jsonData = new JSONObject();
jsonData.put("constants", jsonConstants);
jsonData.put("user", jsonUser);
jsonData.put("menu", jsonMenu);

//完整 json
JSONObject jsonMain = new JSONObject();
jsonMain.put("msgid", msgid);
jsonMain.put("msgtxt", msgtxt);
jsonMain.put("data", jsonData);
result = jsonMain.toJSONString();


////////////////////////////////////////////////////////////////////////////////
//輸出資料
Comm.outputResponse(response, result, "UTF-8");

%>
