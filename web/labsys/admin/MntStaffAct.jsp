<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
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


String mainTable = "staff2";
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

    String qbranch = AbString.rtrimCheck( request.getParameter("qbranch") );
    String qdescript = AbString.rtrimCheck( request.getParameter("qdescript") );

    //限制條件
    String srch = "";
    if (!loginUser.branch.equals(Consts.evtaId)) srch += " and (branch = " + AbSql.getEqualStr(loginUser.branch) + ")";
    if (qbranch.length() > 0) srch += " and (branch = " + AbSql.getEqualStr(qbranch) + ")";
    if (qdescript.length() > 0) srch += " and (descript like " + AbSql.getLikeStr(qdescript) + ")";
    /*
    //權限
    if (qprivilege.length() > 0) {
        int pos = Integer.parseInt(qprivilege) * 2 + 2;
        srch += " and " + sqlSubstring + "(privilege, " + pos + ", 1) in ('1','3','5','7','9','B','D','F')";
    }
    */
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
    String sortField = "branch " + sortorder + ", descript";
    if (sortname.equals("branchtitle")) sortField = "branch " + sortorder + ", descript";
    else if (sortname.equals("descript")) sortField = "descript " + sortorder + ", branch";

    qs = "select m.id, m.descript, m.branch, d.title from " + mainTable + " m"
            + " left join division d on m.branch=d.id"
            + srch
            + " order by " + sortField;
    rs = common.Comm.querySQL(stmt, qs);
    int cnt = 0;
    for (int i=0; i < ((xpage-1) * rows); i++) rs.next();
    while (rs.next() && (cnt++ <= rows)) {
        JSONObject jsonResultMain = new JSONObject();
        JSONObject jsonResult = new JSONObject();
        String id2 = AbString.rtrimCheck( rs.getString("id") );
        String descript = AbString.rtrimCheck( AbString.rtrim( rs.getString("descript") ) );
        String branchtitle = AbString.rtrimCheck( AbString.rtrim( rs.getString("title") ) );
        //jsonResult.put("id", id2);
        jsonResult.put("descript", descript);
        jsonResult.put("branchtitle", branchtitle);
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
            //密碼解碼
            String pwd = AbString.rtrimCheck(rs.getString("pwd"));
            if (pwd.length() > 0) {
                com.absys.util.AbEncrypter encrypter = new com.absys.util.AbEncrypter( com.absys.util.AbEncrypter.DESEDE_ENCRYPTION_SCHEME );
                try {
                    pwd = encrypter.decrypt( pwd );
                } catch (Exception e) {}
            }
            jsonResult.put("id", AbString.rtrimCheck(rs.getString("id")));
            jsonResult.put("acckind", AbString.rtrimCheck(rs.getString("acckind")));
            jsonResult.put("pwd", pwd);
            jsonResult.put("descript", AbString.rtrimCheck(rs.getString("descript")));
            jsonResult.put("psid", AbString.rtrimCheck(rs.getString("psid")).toUpperCase());
            jsonResult.put("branch", AbString.rtrimCheck(rs.getString("branch")));
            jsonResult.put("department", AbString.rtrimCheck(rs.getString("department")));
            jsonResult.put("job", AbString.rtrimCheck(rs.getString("job")));
            jsonResult.put("tel", AbString.rtrimCheck(rs.getString("tel")));
            jsonResult.put("region", AbString.rtrimCheck(rs.getString("region")));
            jsonResult.put("logindate", (rs.getTimestamp("logindate") == null) ? "" : df.format(rs.getTimestamp("logindate")));
            jsonResult.put("setdate", (rs.getTimestamp("setdate") == null) ? "" : df.format(rs.getTimestamp("setdate")));
            jsonResult.put("pwddate", (rs.getTimestamp("pwddate") == null) ? "" : df.format(rs.getTimestamp("pwddate")));
            jsonResult.put("amenddate", (rs.getTimestamp("amenddate") == null) ? "" : df.format(rs.getTimestamp("amenddate")));
            jsonResult.put("amenduser", AbString.rtrimCheck(rs.getString("amenduser")));

            String privilege = AbString.rtrimCheck(rs.getString("privilege"));
            jsonResult.put("privilege", privilege);
            //功能模組權限
            JSONArray jsonPriv = new JSONArray();
            for (int i=0; i < sysModules.modulelist.size(); i++) {
                JSONObject obj1 = new JSONObject().put("id", "priv"+i);
                obj1.put("priv", (sysModules.hasPrivelege(i, privilege) ? "1" : "0"));
                jsonPriv.put(obj1);
                //jsonPriv.put( new JSONObject().put("priv"+i, (modules.hasPrivelege(i, privilege) ? "1" : "0")) );
                for (int j=0; j < sysModules.modulelist.get(i).subModule.size(); j++) {
                    JSONObject obj2 = new JSONObject().put("id", "priv"+i+".sub"+j);
                    obj2.put("priv", (sysModules.hasPrivelege(i, j+1, privilege) ? "1" : "0"));
                    jsonPriv.put(obj2);
                    //jsonPriv.put( new JSONObject().put("priv"+i+".sub"+j, (modules.hasPrivelege(i, j+1, privilege) ? "1" : "0")) );
                }
            }
            jsonResult.put("privlist", jsonPriv);
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
    if (loginUser.id.equals(id)) {
        errId = "1";
        errMsg = "已經登入，不可刪除";
    } else {
        //取得權限
        String privilege = "";
        qs = "select * from " + mainTable + " where id=" + AbSql.getEqualStr(id);
        rs = common.Comm.querySQL(stmt, qs);
        if (rs.next()) privilege = AbString.rtrimCheck(rs.getString("privilege"));
        rs.close();
        //新增 staff_cancel 記錄
        qs = "insert into staff_cancel (id,division,title,tel,region) select "
                + " id,branch,descript,tel,region from " + mainTable + " where id=" + AbSql.getEqualStr(id);
        common.Comm.updateSQL(stmt, qs);
        qs = "update staff_cancel set"
                + " mntuser=" + AbSql.getEqualStr(loginUser.descript)
                + ",mntdate=" + AbSql.getEqualStr(AbDate.getTodayYYYYMMDD())
                + ",authority=" + AbSql.getEqualStr( Comm.convertPrivilege(sysModules, privilege) )
                + " where id=" + AbSql.getEqualStr(id);
        common.Comm.updateSQL(stmt, qs);
        //刪除資料
        qs = "delete from " + mainTable + " where id=" + AbSql.getEqualStr(id);
        common.Comm.updateSQL(stmt, qs);
        errId = "0";
        errMsg = "成功刪除資料：" + id;
    }
    jsonMain.put("msgid", errId);
    jsonMain.put("msgtxt", errMsg);
    result = jsonMain.toString();
//新增、修改
} else if (action.equalsIgnoreCase("add") || action.equalsIgnoreCase("edit")) {
    JSONObject jsonMain = new JSONObject();
    //取得資料
    String id = AbString.rtrimCheck( request.getParameter("id") ).toUpperCase();
    String acckind = AbString.rtrimCheck(request.getParameter("acckind"));
    String pwd = AbString.rtrimCheck(request.getParameter("pwd"));
    String descript = AbString.rtrimCheck(request.getParameter("descript"));
    String psid = AbString.rtrimCheck(request.getParameter("psid")).toUpperCase();
    String branch = AbString.rtrimCheck(request.getParameter("branch"));
    String department = AbString.rtrimCheck(request.getParameter("department"));
    String job = AbString.rtrimCheck(request.getParameter("job"));
    String tel = AbString.rtrimCheck(request.getParameter("tel"));
    String email = AbString.rtrimCheck(request.getParameter("email"));
    String addr = AbString.rtrimCheck(request.getParameter("addr"));
    String zip = AbString.rtrimCheck(request.getParameter("zip"));
    String region = AbString.rtrimCheck(request.getParameter("region"));
    String logindate = AbString.rtrimCheck(request.getParameter("logindate"));
    String loginip = AbString.rtrimCheck(request.getParameter("loginip"));
    String setdate = AbString.rtrimCheck(request.getParameter("setdate"));
    String pwddate = AbString.rtrimCheck(request.getParameter("pwddate"));
    String amenddate = AbString.rtrimCheck(request.getParameter("amenddate"));
    String expiredate = AbString.rtrimCheck(request.getParameter("expiredate"));
    if (expiredate.length() == 0) expiredate = null;
    String revokedate = AbString.rtrimCheck(request.getParameter("revokedate"));
    String revokereason = AbString.rtrimCheck(request.getParameter("revokereason"));
    String amenduser = AbString.rtrimCheck(request.getParameter("amenduser"));

    if (branch.length() == 0) branch = loginUser.branch;
    if ((region.length() == 0) && !loginUser.region.equals("*")) region = loginUser.region;

    //密碼編碼
    String opwd = pwd;
    if (pwd.length() > 0) {
        com.absys.util.AbEncrypter encrypter = new com.absys.util.AbEncrypter( com.absys.util.AbEncrypter.DESEDE_ENCRYPTION_SCHEME );
        try {
            pwd = encrypter.encrypt( pwd );
        } catch (Exception e) {}
    }

    //功能模組權限
    String privilege = "";
    for (int i=0; i < sysModules.modulelist.size(); i++) {
        String priv = AbString.rtrimCheck(request.getParameter("priv"+i));
        privilege = sysModules.setPrivelege(i, 0, priv.equals("on"), privilege);
        for (int j=0; j < sysModules.modulelist.get(i).subModule.size(); j++) {
            priv = AbString.rtrimCheck(request.getParameter("priv"+i+".sub"+j));
            privilege = sysModules.setPrivelege(i, j+1, priv.equals("on"), privilege);
        }
    }
    //檢查內容
    String invalidField = "";
    if ((errMsg.length()==0) && (id.length() == 0)) {
        errMsg = "必須輸入帳號"; errId = "1"; invalidField="id";}
    if ((errMsg.length()==0) && (acckind.length() == 0)) {
        errMsg = "必須輸入帳號類型"; errId = "1"; invalidField="acckind";}
    if ((errMsg.length()==0)) {
        if (acckind.equals("00") && !AbVerify.verifyIdcard(id)) {
            errMsg = "身分證號錯誤"; errId = "1"; invalidField="id";
        }
        if (acckind.equals("02") && !AbVerify.isValidRCNumber(id)) {
            errMsg = "居留證號錯誤"; errId = "1"; invalidField="id";
        }
        if (acckind.equals("01")) {
            //String regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{12,20}$"; //英數、大小寫、長度8-20
            String regexp = "^(?=.*[0-9])(?=.*[a-zA-Z]).{12,20}$"; //英數、長度8-20
            if (!opwd.matches(regexp)) {
                errMsg = "密碼長度必須大於或等於12，且含有英文與數字";
                errId = "1";
                invalidField="pwd";
            }
        }
    }
    if ((errMsg.length()==0) && (descript.length() == 0)) {
        errMsg = "必須輸入姓名"; errId = "1"; invalidField="descript";}
    if ((errMsg.length()==0) && (acckind.equals("01")) && (!loginUser.branch.equals("0000"))) {
        errMsg = "勞發署帳號管理員才能開立帳密類型帳號"; errId = "1"; invalidField="acckind";}
    //檢查新增帳號
    if ((errMsg.length() == 0) && (action.equals("add"))) {
        qs = "select id from " + mainTable + " where id=" + AbSql.getEqualStr(id);
        rs = common.Comm.querySQL(stmt, qs);
        if (rs.next()) {
            errId = "1";
            errMsg = "帳號已經存在 "+id;
        }
        if (rs != null) rs.close();
    }
    //驗證所屬區域
    if ((errMsg.length()==0)) {
        if (!loginUser.region.equals("*") || !region.equals("*")) {
            String rgns[] = region.split(",");
            for (int i = 0; i < rgns.length; i++) {
                qs = "select citycode from fpv_citym"
                    + " where citytype='A'"
                    + " and (citycode > '00' and citycode < '99')"
                    + " and citycode = " + AbSql.getEqualStr( rgns[i] );
                rs = common.Comm.querySQL(stmt, qs);
                boolean isOk = rs.next();
                rs.close();
                if (isOk) {
                    if (!loginUser.region.equals("*") && (loginUser.region.indexOf(rgns[i]) < 0)) {
                        errId = "1";
                        errMsg = "所屬區域代碼超出範圍 " + rgns[i];
                        break;
                    }
                } else {
                    errId = "1";
                    errMsg = "所屬區域代碼輸入錯誤 " + rgns[i];
                    break;
                }
            }
        }
    }

    if (errMsg.length() == 0) {
        //時間
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String nowOra = df.format( new Timestamp(Calendar.getInstance().getTimeInMillis()) );
        String nowStr = new Timestamp(Calendar.getInstance().getTimeInMillis()).toString();
        if (action.equals("add")) {
            qs = "insert into " + mainTable + " (id, acckind, pwd, descript, psid, branch"
                + ", department, job, tel, email, addr, zip, region"
                + ", privilege, setdate, pwddate, amenddate, amenduser, expiredate, revokereason)"
                + "values(" + AbSql.getEqualStr(id)
                + "," + AbSql.getEqualStr(acckind)
                + "," + AbSql.getEqualStr(pwd)
                + "," + AbSql.getEqualStr(descript)
                + "," + AbSql.getEqualStr(psid)
                + "," + AbSql.getEqualStr(branch)
                + "," + AbSql.getEqualStr(department)
                + "," + AbSql.getEqualStr(job)
                + "," + AbSql.getEqualStr(tel)
                + "," + AbSql.getEqualStr(email)
                + "," + AbSql.getEqualStr(addr)
                + "," + AbSql.getEqualStr(zip)
                + "," + AbSql.getEqualStr(region)
                + "," + AbSql.getEqualStr(privilege)
                + ",sysdate"
                + ",sysdate"
                + ",sysdate"
                + "," + AbSql.getEqualStr(loginUser.descript)
                + "," + ((expiredate==null) ? "null" : AbSql.getEqualStr(expiredate))
                + "," + AbSql.getEqualStr(revokereason)
                + ")";

        } else {
            qs = "update " + mainTable + " set"
                + " acckind=" + AbSql.getEqualStr(acckind)
                + ",pwd=" + AbSql.getEqualStr(pwd)
                + ",descript=" + AbSql.getEqualStr(descript)
                + ",psid=" + AbSql.getEqualStr(psid)
                + ",branch=" + AbSql.getEqualStr(branch)
                + ",department=" + AbSql.getEqualStr(department)
                + ",job=" + AbSql.getEqualStr(job)
                + ",tel=" + AbSql.getEqualStr(tel)
                + ",email=" + AbSql.getEqualStr(email)
                + ",addr=" + AbSql.getEqualStr(addr)
                + ",zip=" + AbSql.getEqualStr(zip)
                + ",region=" + AbSql.getEqualStr(region)
                + ",privilege=" + AbSql.getEqualStr(privilege)
                + ",amenddate=sysdate"
                + ",amenduser=" + AbSql.getEqualStr(loginUser.descript)
                + ",expiredate=" + ((expiredate==null) ? "null" : AbSql.getEqualStr(expiredate))
                + ",revokereason=" + AbSql.getEqualStr(revokereason)
                + " where id=" + AbSql.getEqualStr(id);
        }
        common.Comm.updateSQL(stmt, qs);
        //取得使用者資料
        if (id.equals(loginUser.id)) loginUser = new Staff(stmt, mainTable, id);
        session.setAttribute(Consts.appName+"_userData", loginUser);
        errId = "0";
        errMsg = "成功儲存資料：" + descript;
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
