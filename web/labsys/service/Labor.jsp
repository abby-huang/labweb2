<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="org.json.*"%>
<%@ page import="com.absys.util.*" %>
<%@ page import="com.absys.user.*"%>
<%@ page import="common.*"%>

<%
response.setContentType("application/json; charset=UTF-8");
response.setHeader("Cache-Control","no-cache");
response.setHeader("Pragma","no-cache");
response.setDateHeader ("Expires", 0);

request.setCharacterEncoding("UTF-8");

String mainTable = "fpv_outlab";
String errId = "0";
String errMsg = "";
Connection conn = null;

//建立連線
conn = Comm.getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
//Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
Statement stmt = conn.createStatement();
Statement stmt2 = conn.createStatement();
ResultSet rs;
String qs = "";

String action = AbString.rtrimCheck( request.getParameter("action") );

String result = "";
//詳細資料
if (action.equalsIgnoreCase("data")) {
    JSONObject jsonResult = new JSONObject();
    try {
        String natcode = AbString.rtrimCheck( request.getParameter("natcode") );
        String passno = AbString.rtrimCheck( request.getParameter("passno") ).toUpperCase();

        common.LaborDetail laborDetail = new common.LaborDetail(natcode, passno);
        laborDetail.getBasic(conn);
        laborDetail.getDetail(conn);
        laborDetail.getExtend(conn);

        jsonResult.put("isExist", laborDetail.isExist);
        jsonResult.put("natcode", laborDetail.natcode);
        jsonResult.put("nation", laborDetail.nation);
        jsonResult.put("passno", laborDetail.passno);
        jsonResult.put("engname", laborDetail.engname);
        jsonResult.put("sex", laborDetail.sex);
        jsonResult.put("sex_desc", laborDetail.sex_desc);
        jsonResult.put("birthday", laborDetail.birthday);
        jsonResult.put("lstatus", laborDetail.lstatus);
        jsonResult.put("lstatus_desc", laborDetail.lstatus_desc);

        //errId = "0";
        //errMsg = "";

    } catch (Exception e) {}

    JSONObject jsonMain = new JSONObject();
    jsonMain.put("data", jsonResult);
    jsonMain.put("msgid", errId);
    jsonMain.put("msgtxt", errMsg);
    result = jsonMain.toString();

} else {
    JSONObject jsonMain = new JSONObject();
    jsonMain.put("success", true);
    jsonMain.put("msgid", "1");
    jsonMain.put("msgtxt", "尚未支援功能代碼：" + action);
    result = jsonMain.toString();
}

%>

<%=result%>

<%
//關閉連線
if (stmt != null) stmt.close();
if (stmt2 != null) stmt2.close();
if (conn != null) conn.close();
%>
