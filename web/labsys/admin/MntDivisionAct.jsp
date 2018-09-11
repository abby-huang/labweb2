<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="org.json.*"%>
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
} else if (!sysModules.hasPrivelege("staff", loginUser.privilege)) {
    String result = "{\"msgid\":98,\"msgtxt\":\"權限不足。\"}";
    Comm.outputResponse(response, result, "UTF-8");
    return;
}


String mainTable = "division";
String errId = "0";
String errMsg = "";
Connection conn = null;

//建立連線
conn = Comm.getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
//Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
Statement stmt = conn.createStatement();
ResultSet rs;
String qs = "";

String action = AbString.rtrimCheck( request.getParameter("action") );

String result = "";
//簡列資料
if (action.equalsIgnoreCase("list")) {
    //輸入資料
    int xpage = 1;
    int rows = 20;
    try {
        xpage = Integer.parseInt( AbString.rtrimCheck( request.getParameter("page") ) );
        rows = Integer.parseInt( AbString.rtrimCheck( request.getParameter("rows") ) );
    } catch (Exception e) {}
    String sortname = AbString.rtrimCheck( request.getParameter("sidx") );
    String sortorder = AbString.rtrimCheck( request.getParameter("sord") );

    //String qid = new String( AbString.rtrimCheck( request.getParameter("qid") ).getBytes("ISO8859_1"), "UTF-8");
    //String qtitle = new String( AbString.rtrimCheck( request.getParameter("qtitle") ).getBytes("ISO8859_1"), "UTF-8");
    String qid = AbString.rtrimCheck( request.getParameter("qid") );
    String qtitle = AbString.rtrimCheck( request.getParameter("qtitle") );

    //限制條件
    String srch = "";
    if (qid.length() > 0) srch += " and id = " + AbSql.getEqualStr(qid);
    if (qtitle.length() > 0) srch += " and title like " + AbSql.getLikeStr(qtitle);
    if (srch.length() > 0) srch = " where" + srch.substring(4);

    //計算筆數
    qs = "select count(*) from " + mainTable + srch;
    rs = common.Comm.querySQL(stmt, qs);
    rs.next();
    int totalCount = rs.getInt(1);
    rs.close();

    //產生 JSON 資料
    JSONArray data = new JSONArray();
    DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    //排序
    String sortField = "id " + sortorder + ", title";
    if (sortname.equals("title")) sortField = "title " + sortorder + ", id";

    qs = "select * from " + mainTable + srch + " order by " + sortField;
    rs = common.Comm.querySQL(stmt, qs);
    int cnt = 0;
    for (int i=0; i < ((xpage-1) * rows); i++) rs.next();
    while (rs.next() && (cnt++ <= rows)) {
        JSONObject jsonResultMain = new JSONObject();
        JSONObject jsonResult = new JSONObject();
        String id2 = AbString.rtrim( rs.getString("id") );
        String title = ( AbString.rtrim( rs.getString("title") ) );
        String region = ( AbString.rtrim( rs.getString("region") ) );
        jsonResult.put("id", id2);
        jsonResult.put("title", title);
        jsonResult.put("region", region);

        jsonResultMain.put("id", id2);
        jsonResultMain.put("cell", jsonResult);
        data.put(jsonResultMain);
    }
    rs.close();

    JSONObject jsonMain = new JSONObject();
    jsonMain.put("page", xpage);
    jsonMain.put("total", (totalCount/rows) + ((totalCount % rows) > 0 ? 1 : 0));
    jsonMain.put("records", totalCount);
    jsonMain.put("rows", data);
    result = jsonMain.toString();
//詳細資料
} else if (action.equalsIgnoreCase("data")) {
    JSONObject jsonResult = new JSONObject();
    try {
        String id = AbString.rtrimCheck( request.getParameter("id") ).toUpperCase();
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        qs = "select * from " + mainTable + " where id=" + AbSql.getEqualStr(id);
        rs = common.Comm.querySQL(stmt, qs);
        if (rs.next()) {
            jsonResult.put("id", AbString.rtrimCheck(rs.getString("id")));
            jsonResult.put("title", AbString.rtrimCheck(rs.getString("title")));
            jsonResult.put("region", AbString.rtrimCheck(rs.getString("region")));
        }
        rs.close();
    } catch (Exception e) {}

    JSONObject jsonMain = new JSONObject();
    jsonMain.put("data", jsonResult);
    result = jsonMain.toString();
//刪除
} else if (action.equalsIgnoreCase("del")) {
    String id = AbString.rtrimCheck( request.getParameter("id") ).toUpperCase();
    JSONObject jsonMain = new JSONObject();
    //刪除資料
    qs = "delete from " + mainTable + " where id=" + AbSql.getEqualStr(id);
    common.Comm.updateSQL(stmt, qs);
    errId = "0";
    errMsg = "成功刪除資料：" + id;
    jsonMain.put("msgid", errId);
    jsonMain.put("msgtxt", errMsg);
    result = jsonMain.toString();
//新增、修改
} else if (action.equalsIgnoreCase("add") || action.equalsIgnoreCase("edit")) {
    JSONObject jsonMain = new JSONObject();
    //取得資料
    String id = AbString.rtrimCheck( request.getParameter("id") ).toUpperCase();
    String title = AbString.rtrimCheck(request.getParameter("title"));
    String region = AbString.rtrimCheck(request.getParameter("region"));

    //檢查內容
    String invalidField = "";
    if (id.length() != 4) {
        errId = "1";
        errMsg = "單位代碼必須為 4 位數";
        invalidField="id";
    }
    //檢查新增代碼
    if ((errMsg.length() == 0) && (action.equals("add"))) {
        qs = "select id from " + mainTable + " where id=" + AbSql.getEqualStr(id);
        rs = common.Comm.querySQL(stmt, qs);
        if (rs.next()) {
            errId = "1";
            errMsg = "代碼已經存在 "+id;
            invalidField="id";
        }
        if (rs != null) rs.close();
    }
    if ((errMsg.length() == 0) && (title.length() == 0)) {
        errId = "1";
        errMsg = "必須輸入單位名稱";
        invalidField="title";
    }
    //驗證所屬區域
    if ((errMsg.length()==0) && !region.equals("*")) {
        String rgns[] = region.split(",");
        for (int i = 0; i < rgns.length; i++) {
            qs = "SELECT citycode FROM fpv_citym"
                + " WHERE citytype='A'"
                + " AND (citycode > '00' AND citycode < '99')"
                + " AND citycode = " + AbSql.getEqualStr( rgns[i] );
            rs = common.Comm.querySQL(stmt, qs);
            boolean isOk = rs.next();
            rs.close();
            if (!isOk) {
                errId = "1";
                errMsg = "所屬區域代碼輸入錯誤 " + rgns[i];
                invalidField="region";
                break;
            }
        }
    }

    if (errMsg.length() == 0) {
        //時間
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String nowOra = df.format( new Timestamp(Calendar.getInstance().getTimeInMillis()) );
        String nowStr = new Timestamp(Calendar.getInstance().getTimeInMillis()).toString();
        if (action.equals("add")) {
            qs = "insert into division values("+AbSql.getEqualStr(id)
                    + "," + AbSql.getEqualStr(title)
                    + "," + AbSql.getEqualStr(region)
                    + ")";
        } else {
            qs = "update division set title=" + AbSql.getEqualStr(title)
                    + ",region=" + AbSql.getEqualStr(region)
                    + " where id=" + AbSql.getEqualStr(id);
        }
        common.Comm.updateSQL(stmt, qs);
        errId = "0";
        errMsg = "成功存檔資料：" + id;
    }
    jsonMain.put("invalidField", invalidField);
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

//關閉連線
if (stmt != null) stmt.close();
if (conn != null) conn.close();

////////////////////////////////////////////////////////////////////////////////
//輸出資料
Comm.outputResponse(response, result, "UTF-8");

%>
