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
} else if (!sysModules.hasPrivelege("staff", loginUser.privilege)) {
    String result = "{\"msgid\":98,\"msgtxt\":\"權限不足。\"}";
    Comm.outputResponse(response, result, "UTF-8");
    return;
}

//參數
int msgid = 0;
String msgtxt = "";
String sqlWhere = "";

//建立DB連線
Connection conn = null;
conn = Comm.getConnection( session );
if (conn == null) {
    //DB連線錯誤
    String result = "{\"msgid\":１,\"msgtxt\":\"無法開啟資料庫。\"}";
    Comm.outputResponse(response, result, "UTF-8");
    return;
}

Statement stmt = conn.createStatement();
Statement stmt2 = conn.createStatement();
ResultSet rs;
String qs = "";
String result = "";


//method: CRUD - POST:新增, GET:讀取, PUT:修改, DELETE:刪除
String method = AbString.rtrimCheck( request.getParameter("method") ).toUpperCase();

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//讀取資料
if (method.equalsIgnoreCase("GET")) {
    //action: 子功能
    String action = AbString.rtrimCheck( request.getParameter("action") ).toLowerCase();
    //簡列資料
    if (action.equalsIgnoreCase("list")) {
        /**
            讀取查詢資料 - 參數：
            itemsOnPage: int 每頁筆數
            currentPage: int 顯示頁
            queryData: json 查詢條件

            返回資料 json：
            {
                "msgid":1,            狀況代碼
                "msgtxt":""           狀況訊息
                "data":{              返回資料
                    "totalItems":0,   全部筆數
                    "totalPages":0,   全部頁數
                    "list":[],        資料陣列
                },
            }
         */

        int itemsOnPage = 20;
        int currentPage = 1;
        try {
            itemsOnPage = Integer.parseInt( AbString.rtrimCheck( request.getParameter("itemsOnPage") ) );
            currentPage = Integer.parseInt( AbString.rtrimCheck( request.getParameter("currentPage") ) );
        } catch (Exception e) {}
        String queryData = AbString.rtrimCheck( request.getParameter("data") );
        JSONObject qryJson = new JSONObject();
        try {
            qryJson = (JSONObject)new JSONParser().parse(queryData);
        } catch (Exception e) {}

        String branch = AbString.rtrimCheck((String)qryJson.get("branch"));
        String sdate = AbString.rtrimCheck((String)qryJson.get("sdate"));
        String edate = AbString.rtrimCheck((String)qryJson.get("edate"));
        String stime = AbString.rtrimCheck((String)qryJson.get("stime"));
        String etime = AbString.rtrimCheck((String)qryJson.get("etime"));

        if ((sdate.length() == 0) || !AbDate.isValidDate(sdate)) {msgid = 1; msgtxt = "下載日期錯誤";}
        if ((edate.length() == 0) || !AbDate.isValidDate(edate)) {msgid = 1; msgtxt = "下載日期錯誤";}
        if(!stime.matches("([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]")) {msgid = 1; msgtxt = "下載時間錯誤";}
        if(!etime.matches("([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]")) {msgid = 1; msgtxt = "下載時間錯誤";}

        //返回參數
        int totalItems = 0;
        int totalPages = 0;
        JSONArray listData = new JSONArray(); //資料陣列

        //資料正確
        if (msgid == 0) {
            //不是勞發署
            if (!loginUser.branch.equals("0000") && (branch.length() == 0)) branch = loginUser.branch;

            //建立查詢 SQL
            String srch = "";
            if (branch.length() > 0) srch += " and division = " + AbSql.getEqualStr(branch);
            srch += " and opdate >= " + AbSql.getEqualStr(sdate);
            srch += " and opdate <= " + AbSql.getEqualStr(edate);

            if (etime.compareTo(stime) >= 0) { //同一日
                srch += " and optime >= " + AbSql.getEqualStr(stime);
                srch += " and optime <= " + AbSql.getEqualStr(etime);
            } else { //跨日
                srch += " and ( optime >= " + AbSql.getEqualStr(stime);
                srch += " or optime <= " + AbSql.getEqualStr(etime) + " )";
            }

            if (srch.length() > 0) {
                srch = " where " + srch.substring(4);
            }
            sqlWhere = srch;

            //設定參數
            stmt.setQueryTimeout( 60*30 ); //設定30分鐘
            //stmt.setMaxRows( (currentPage-1)*itemsOnPage ); //最大筆數

            //計算筆數
            qs = "select count(*) from logdata" + srch;
            rs = stmt.executeQuery(qs);
            rs.next();
            totalItems = rs.getInt(1);
            rs.close();

            //計算頁數
            totalPages = ((totalItems-1) / itemsOnPage) + 1;

            //讀取資料
            qs = "select logdata.*, division.title as divtitle"
                + " from logdata left join division on logdata.division=division.id"
                + srch
                + " order by opdate desc, optime desc, division, userid";
            rs = stmt.executeQuery(qs);
            for (int i=0; i < ((currentPage-1)*itemsOnPage); i++) {
            rs.next();
            }
            int cnt = 0;
            while (rs.next() && (cnt < itemsOnPage)) {
                cnt++;
                String logid = AbString.rtrimCheck(rs.getString("logid"));
                String divtitle = AbString.rtrimCheck(rs.getString("divtitle"));
                String descript = AbString.rtrimCheck(rs.getString("descript"));
                String userid = AbString.rtrimCheck(rs.getString("userid"));
                String opdate = AbString.rtrimCheck(rs.getString("opdate"));
                String optime = AbString.rtrimCheck(rs.getString("optime"));
                String data = AbString.rtrimCheck(rs.getString("data"));
                if (userid.length() > 3) userid = userid.substring(0,3) + String.join("", Collections.nCopies(userid.length()-3, "*"));

                JSONObject detail = new JSONObject();
                detail.put("logid", logid);
                detail.put("logdescript", common.Comm.getCodeTitle(stmt2, logid, "logid", "logid", "descript"));
                detail.put("divtitle", divtitle);
                detail.put("descript", descript);
                detail.put("userid", userid);
                detail.put("opdate", opdate);
                detail.put("optime", optime);
                detail.put("data", data);

                //加入陣列
                listData.add(detail);
            }
            rs.close();
        }

        //查詢資料 -> json {"data"}
        JSONObject jsonData = new JSONObject();
        jsonData.put("sqlWhere", sqlWhere);
        jsonData.put("totalItems", totalItems);
        jsonData.put("totalPages", totalPages);
        jsonData.put("currentPage", currentPage);
        jsonData.put("itemsOnPage", itemsOnPage);
        jsonData.put("list", listData);

        //完整 json
        JSONObject jsonMain = new JSONObject();
        jsonMain.put("msgid", msgid);
        jsonMain.put("msgtxt", msgtxt);
        jsonMain.put("data", jsonData);
        result = jsonMain.toJSONString();
    } else {
        JSONObject jsonMain = new JSONObject();
        jsonMain.put("msgid", 1);
        jsonMain.put("msgtxt", "尚未支援子功能代碼：" + method + "." + action);
        result = jsonMain.toString();
    }


////////////////////////////////////////////////////////////////////////////////
} else {
    JSONObject jsonMain = new JSONObject();
    jsonMain.put("msgid", 1);
    jsonMain.put("msgtxt", "尚未支援功能代碼：" + method);
    result = jsonMain.toString();
}

//關閉連線
if (stmt != null) stmt.close();
if (stmt2 != null) stmt2.close();
if (conn != null) conn.close();

////////////////////////////////////////////////////////////////////////////////
//輸出資料
Comm.outputResponse(response, result, "UTF-8");

%>
