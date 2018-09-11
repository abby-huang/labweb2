<%@ page pageEncoding="UTF-8" contentType="text/html"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="org.json.*"%>
<%@ page import="org.apache.commons.lang3.*" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
response.setHeader("Cache-Control","no-cache");
response.setHeader("Pragma","no-cache");
response.setDateHeader ("Expires", 0);

String pageHeader = "Ajax 共用";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

String errId = "0";
String errMsg = "";
Connection conn = null;
Connection conn2 = null;

//建立連線
conn = getConnection( session );
conn2 = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
Statement stmt2 = conn2.createStatement();
ResultSet rs;
String qs;

String action = filterMetaCharacters( request.getParameter("action") );
//JSON Object
JSONObject jsonMain = new JSONObject();
JSONObject jsonData = new JSONObject();
if (action.equalsIgnoreCase("vend")) {
    //雇主
    String vendno = filterMetaCharacters( request.getParameter("vendno") );
    qs = "select * from labdyn_vend where vendno=" + AbSql.getEqualStr(vendno);
    rs = common.Comm.querySQL(stmt, qs);
    if (!rs.next()) {
        errId = "1";
        errMsg = "沒有雇主資料：" + vendno;
    } else {
        jsonData.put("vendno", AbString.rtrimCheck(rs.getString("vendno")));
        jsonData.put("cname", AbString.rtrimCheck(rs.getString("cname")));
    }
    rs.close();
} else if (action.equalsIgnoreCase("laborm")) {
    //外勞
    String natcode = filterMetaCharacters( request.getParameter("natcode") );
    String passno = filterMetaCharacters( request.getParameter("passno") );
    //檢查國籍
    String natiname = common.Comm.getCodeTitle(stmt,natcode,"fpv_natim","naticode","natiname");
    if (natiname.length() > 0) {
        qs = "select * from labdyn_laborm where natcode=" + AbSql.getEqualStr(natcode)
             + " and passno=" + AbSql.getEqualStr(passno);
        rs = common.Comm.querySQL(stmt, qs);
        if (!rs.next()) {
            jsonData.put("natiname", natiname);
            jsonData.put("natcode", natcode);
            jsonData.put("passno", passno);
            errId = "1";
            errMsg = "沒有外籍工作者資料：" + natcode + "-" + passno;
        } else {
            jsonData.put("natiname", natiname);
            jsonData.put("natcode", natcode);
            jsonData.put("passno", passno);
            jsonData.put("engname", AbString.rtrimCheck(rs.getString("engname")));
            jsonData.put("sex", AbString.rtrimCheck(rs.getString("sex")));
            jsonData.put("citycode", AbString.rtrimCheck(rs.getString("citycode")));
        }
        rs.close();
    } else {
        errId = "2";
        errMsg = "國籍代碼錯誤：" + natcode;
    }
} else if (action.equalsIgnoreCase("workprmt")) {
    //聘僱許可文號
    String wkprmtno = filterMetaCharacters( request.getParameter("wkprmtno") );
    String natcode = filterMetaCharacters( request.getParameter("natcode") );
    String passno = filterMetaCharacters( request.getParameter("passno") );
    qs = "select * from labdyn_workprmt where wkprmtno=" + AbSql.getEqualStr(wkprmtno)
            + " and natcode=" + AbSql.getEqualStr(natcode)
            + " and passno=" + AbSql.getEqualStr(passno);
    rs = common.Comm.querySQL(stmt, qs);
    if (!rs.next()) {
        jsonData.put("wkprmtno", wkprmtno);
        jsonData.put("natcode", natcode);
        jsonData.put("passno", passno);
        errId = "1";
        errMsg = "沒有聘僱許可文號：" + wkprmtno + "-"  + natcode + "-" + passno;
    } else {
        jsonData.put("wkprmtno", wkprmtno);
        jsonData.put("natcode", natcode);
        jsonData.put("passno", passno);
        jsonData.put("wkprmtdate", AbString.rtrimCheck(rs.getString("wkprmtdate")));
        jsonData.put("indate", AbString.rtrimCheck(rs.getString("indate")));
        jsonData.put("wkbdate", AbString.rtrimCheck(rs.getString("wkbdate")));
        jsonData.put("conedate", AbString.rtrimCheck(rs.getString("conedate")));
    }
    rs.close();
} else if (action.equalsIgnoreCase("visalab")) {
    //外勞
    String natcode = filterMetaCharacters( request.getParameter("natcode") );
    String passno = filterMetaCharacters( request.getParameter("passno") );
    String prmtno = filterMetaCharacters( request.getParameter("prmtno") );
    //檢查國籍
    String natiname = common.Comm.getCodeTitle(stmt,natcode,"fpv_natim","naticode","natiname");
    if (natiname.length() > 0) {
        jsonData.put("natiname", natiname);
        jsonData.put("natcode", natcode);
        jsonData.put("passno", passno);
        qs = "select * from labdyn_visa where natcode=" + AbSql.getEqualStr(natcode)
             + " and passno=" + AbSql.getEqualStr(passno)
             + " and prmtno=" + AbSql.getEqualStr(prmtno);
        rs = common.Comm.querySQL(stmt, qs);
        if (!rs.next()) {
            rs.close();
            errId = "1";
            errMsg = "簽證檔沒有外籍工作者資料：" + natcode + "-" + passno;
        }
        rs.close();
        //取得 engname
        String engname = "";
        String sex = "";
        qs = "select * from labdyn_labinout where natcode=" + AbSql.getEqualStr(natcode)
             + " and passno=" + AbSql.getEqualStr(passno)
             + " order by inoutdate desc";
        rs = common.Comm.querySQL(stmt, qs);
        if (rs.next()) {
            engname = AbString.rtrimCheck(rs.getString("ename"));
            sex = AbString.rtrimCheck(rs.getString("sex"));
        }
        jsonData.put("engname", engname);
        jsonData.put("sex", sex);
        rs.close();
    } else {
        errId = "2";
        errMsg = "國籍代碼錯誤：" + natcode;
    }
} else if (action.equalsIgnoreCase("agent")) {
    //仲介
    String agno = filterMetaCharacters( request.getParameter("agno") );
    qs = "select * from empage_agent where agno=" + AbSql.getEqualStr(agno);
    rs = common.Comm.querySQL(stmt, qs);
    if (!rs.next()) {
        jsonData.put("agno", agno);
        errId = "1";
        errMsg = "私立就業服務機構許可證字號錯誤：" + agno;
    } else {
        jsonData.put("agno", agno);
        jsonData.put("title",  StringEscapeUtils.unescapeHtml4( AbString.rtrimCheck(rs.getString("title")) ) );
        jsonData.put("respname", StringEscapeUtils.unescapeHtml4( AbString.rtrimCheck(rs.getString("respname")) ) );
        jsonData.put("tel", AbString.rtrimCheck(rs.getString("tel")));
    }
    rs.close();
} else if (action.equalsIgnoreCase("lablist")) {
    //外勞名冊
    String result = "";
    String lablistno = filterMetaCharacters( request.getParameter("lablistno") ).toUpperCase();
    //產生 JSON 資料
    JSONArray datalist = new JSONArray();
    int listsize = 0;
    qs = "select * from labdyn_notifylab where applwpno = " + AbSql.getEqualStr(lablistno)
            + " order by applwpno, natcode, passno";
    rs = common.Comm.querySQL(stmt, qs);
    while (rs.next()) {
        listsize++;
        JSONObject jsonResult = new JSONObject();
        jsonResult.put("natcode", AbString.rtrim( rs.getString("natcode") ));
        jsonResult.put("passno", AbString.rtrim( rs.getString("passno") ).toUpperCase());
        jsonResult.put("engname", AbString.rtrim( rs.getString("engname") ).toUpperCase());
        jsonResult.put("sex", AbString.rtrim( rs.getString("sex") ).toUpperCase());
        jsonResult.put("indate", AbString.rtrim( rs.getString("indate") ));
        datalist.put(jsonResult);
    }
    rs.close();

    jsonMain.put("listsize", listsize);
    jsonMain.put("datalist", datalist);

} else {
    jsonMain.put("msgid", "1");
    jsonMain.put("msgtxt", "尚未支援功能代碼：" + action);
}
jsonMain.put("msgid", errId);
jsonMain.put("msgtxt", errMsg);
jsonMain.put("data", jsonData);
String result = jsonMain.toString();
%>

<%= result %>

<%
//關閉連線
if (stmt != null) stmt.close();
if (stmt2 != null) stmt2.close();
if (conn != null) conn.close();
if (conn2 != null) conn2.close();
%>
