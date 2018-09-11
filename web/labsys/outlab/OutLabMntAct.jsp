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
}

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

    String qregno = AbString.rtrimCheck( request.getParameter("qregno") );
    String qcommid = AbString.rtrimCheck( request.getParameter("qcommid") );

    //限制條件
    String srch = "";
    if (!(loginUser.branch.equals("0000") || loginUser.branch.equals("A001") || loginUser.branch.equals("A002")) ) {
        srch += " and branch = " + AbSql.getEqualStr(loginUser.branch);
    }
    if (qregno.length() > 0) srch += " and regno = " + AbSql.getEqualStr(qregno);
    if (qcommid.length() > 0) srch += " and commid = " + AbSql.getEqualStr(qcommid);
    if (srch.length() > 0) srch = " where" + srch.substring(4);

    //計算筆數
    qs = "select count(*) from " + mainTable + srch;
    rs = common.Comm.querySQL(stmt, qs);
    rs.next();
    int totalCount = rs.getInt(1);
    rs.close();

    //產生 JSON 資料
    JSONArray data = new JSONArray();
    //排序
    String sortField = "regno " + sortorder + " NULLS LAST, commid";
    if (sortname.equals("commid")) sortField = "commid " + sortorder + " NULLS LAST, regno";
    if (sortname.equals("wrkbdate")) sortField = "wrkbdate " + sortorder + " NULLS LAST, regno";
    if (sortname.equals("abolishdate")) sortField = "abolishdate " + sortorder + " NULLS LAST, regno";

    qs = "select rowid,m.* from " + mainTable + " m" + srch + " order by " + sortField;
    rs = common.Comm.querySQL(stmt, qs);
    int cnt = 0;
    for (int i=0; i < ((xpage-1) * rows); i++) rs.next();
    while (rs.next() && (cnt++ <= rows)) {
        JSONObject jsonResultMain = new JSONObject();
        JSONObject jsonResult = new JSONObject();
        jsonResult.put("rowid", AbString.rtrim( rs.getString("rowid") ));
        jsonResult.put("regno", AbString.rtrim( rs.getString("regno") ));
        jsonResult.put("vendname", AbString.rtrim( rs.getString("vendname") ));
        jsonResult.put("commid", AbString.rtrim( rs.getString("commid") ));
        jsonResult.put("commname", AbString.rtrim( rs.getString("commname") ));
        jsonResult.put("wrkbdate", AbDate.fmtDate( AbString.rtrimCheck(rs.getString("wrkbdate")), "-") );
        jsonResult.put("abolishdate", AbDate.fmtDate( AbString.rtrimCheck(rs.getString("abolishdate")), "-") );
        jsonResult.put("emptitle", AbString.rtrim( rs.getString("emptitle") ));

        jsonResultMain.put("id", AbString.rtrim( rs.getString("rowid") )); //jqGrid key 設為 oracle rowid
        jsonResultMain.put("cell", jsonResult);
        data.put(jsonResultMain);
    }
    rs.close();

    JSONObject jsonMain = new JSONObject();
    jsonMain.put("page", xpage);
    jsonMain.put("total", (totalCount / rows) + ((totalCount % rows) > 0 ? 1 : 0));
    jsonMain.put("records", totalCount);
    jsonMain.put("rows", data);
    result = jsonMain.toString();

//詳細資料
} else if (action.equalsIgnoreCase("data")) {
    JSONObject jsonResult = new JSONObject();
    try {
        String id = AbString.rtrimCheck( request.getParameter("id") );
        qs = "select * from " + mainTable + " where rowid=" + AbSql.getEqualStr(id);
        rs = common.Comm.querySQL(stmt, qs);
        if (rs.next()) {
            jsonResult.put("rowid", id);
            jsonResult.put("regno", AbString.rtrimCheck(rs.getString("regno")));
            jsonResult.put("vendname", AbString.rtrimCheck(rs.getString("vendname")));
            jsonResult.put("vendaddr", AbString.rtrimCheck(rs.getString("vendaddr")));
            jsonResult.put("vendtel", AbString.rtrimCheck(rs.getString("vendtel")));
            jsonResult.put("commid", AbString.rtrimCheck(rs.getString("commid")));
            jsonResult.put("commname", AbString.rtrimCheck(rs.getString("commname")));
            jsonResult.put("style", AbString.rtrimCheck(rs.getString("style")));
            jsonResult.put("outcome", AbString.rtrimCheck(rs.getString("outcome")));
            jsonResult.put("wrkbdate", AbDate.fmtDate( AbString.rtrimCheck(rs.getString("wrkbdate")), "-") );
            jsonResult.put("abolishdate", AbDate.fmtDate( AbString.rtrimCheck(rs.getString("abolishdate")), "-") );
            jsonResult.put("empid", AbString.rtrimCheck(rs.getString("empid")));
            jsonResult.put("emptitle", AbString.rtrimCheck(rs.getString("emptitle")));
        }
        rs.close();
    } catch (Exception e) {}

    JSONObject jsonMain = new JSONObject();
    jsonMain.put("data", jsonResult);
    result = jsonMain.toString();

//刪除
} else if (action.equalsIgnoreCase("del")) {
    String id = AbString.rtrimCheck( request.getParameter("id") );
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
    String rowid = AbString.rtrimCheck( request.getParameter("rowid") );
    String regno = AbString.rtrimCheck(request.getParameter("regno"));
    String vendname = AbString.rtrimCheck(request.getParameter("vendname"));
    String vendaddr = AbString.rtrimCheck(request.getParameter("vendaddr"));
    String vendtel = AbString.rtrimCheck(request.getParameter("vendtel"));
    String commid = AbString.rtrimCheck(request.getParameter("commid"));
    String commname = AbString.rtrimCheck(request.getParameter("commname"));
    String style = AbString.rtrimCheck(request.getParameter("style"));
    String outcome = AbString.rtrimCheck(request.getParameter("outcome"));
    String wrkbdate = AbString.rtrimCheck(request.getParameter("wrkbdate")).replace("-", "");
    String abolishdate = AbString.rtrimCheck(request.getParameter("abolishdate")).replace("-", "");;
    String empid = AbString.rtrimCheck(request.getParameter("empid"));
    String emptitle = AbString.rtrimCheck(request.getParameter("emptitle"));

    //檢查內容
    String invalidField = "";
    /*
    if ((errMsg.length()==0)) {
        if (!isRowExist(stmt, regno, "fpv_vendm", "regno")) {
            errMsg = "申請人身分證字號錯誤"; errId = "1"; invalidField="regno";
        }
    }
    */
    if ((errMsg.length()==0) && (regno.length() == 0)) {
        errMsg = "必須輸入申請人身分證字號"; errId = "1"; invalidField="regno";}
    if ((errMsg.length()==0) && (vendname.length() == 0)) {
        errMsg = "必須輸入申請人名稱"; errId = "1"; invalidField="vendname";}
    if ((errMsg.length()==0) && (vendaddr.length() == 0)) {
        errMsg = "必須輸入申請人地址"; errId = "1"; invalidField="vendaddr";}
    /*
    if ((errMsg.length()==0)) {
        qs = "select * from labdyn_ngbandy where commid = " + AbSql.getEqualStr(commid);
        rs = common.Comm.querySQL(stmt, qs);
        if (!rs.next()) {
            errMsg = "被看護人身分證字號錯誤"; errId = "1"; invalidField="commid";
        } else {
            if (action.equals("add")) {
                //診斷書超過 2 個月
                String today = AbDate.getToday();
                String achievedate = AbDate.dateAdd(AbString.rtrimCheck(rs.getString("achievedate")), 0, 2, 0);
                if (achievedate.compareTo(today) <= 0) {
                    errMsg = "診斷書超過 2 個月"; errId = "1"; invalidField="commid";}
            }
        }
        rs.close();
    }
    */
    if ((errMsg.length()==0) && (commid.length() == 0)) {
        errMsg = "必須輸入被看護人身分證字號"; errId = "1"; invalidField="commid";}
    if ((errMsg.length()==0) && (commname.length() == 0)) {
        errMsg = "必須輸入被看護人姓名"; errId = "1"; invalidField="commname";}
    //if ((errMsg.length()==0) && ((style.length() == 0) || ("1234".indexOf(style) < 0))) {
    if ( (errMsg.length()==0) &&
            ((style.length() == 0) || !Arrays.asList(new String[]{"1", "2","2A","2B","2C","3","4"}).contains(style)) ) {
        errMsg = "申請資格錯誤"; errId = "1"; invalidField="style";}
    if ((errMsg.length()==0) && ((outcome.length() == 0) || ("YN".indexOf(outcome) < 0))) {
        errMsg = "評估結果錯誤"; errId = "1"; invalidField="outcome";}
    if ((errMsg.length()==0) && (!AbDate.isValidDate(wrkbdate))) {
        errMsg = "外展契約起始日錯誤"; errId = "1"; invalidField="wrkbdate";}
    if ((errMsg.length()==0) && ((abolishdate.length() > 0) && !AbDate.isValidDate(abolishdate))) {
        errMsg = "外展契約廢止日期錯誤"; errId = "1"; invalidField="abolishdate";}
    /*
    if ((errMsg.length()==0)) {
        if (!isRowExist(stmt, empid, "fpv_vendm", "regno")) {
            errMsg = "外展機構統編錯誤"; errId = "1"; invalidField="empid";
        }
    }
    */
    if ((errMsg.length()==0) && (empid.length() == 0)) {
        errMsg = "必須輸入外展機構統編"; errId = "1"; invalidField="empid";}
    if ((errMsg.length()==0) && (emptitle.length() == 0)) {
        errMsg = "必須輸入外展機構名稱"; errId = "1"; invalidField="emptitle";}

    //檢查是否重複
    if (errMsg.length() == 0) {
        qs = "select rowid, m.* from fpv_outlab m where regno=" + AbSql.getEqualStr(regno)
                + " and commid=" + AbSql.getEqualStr(commid)
                + " and wrkbdate=" + AbSql.getEqualStr(wrkbdate);
        rs = common.Comm.querySQL(stmt, qs);
        if (rs.next()) {
            if (action.equals("add")) {
                //新增
                errMsg = "資料重複輸入"; errId = "1"; invalidField="regno";
            } else {
                //修改 - 判斷rowid是否相同，相同則為原本資料，沒有重複
                String rowid_org = AbString.rtrim( rs.getString("rowid") );
                if (!rowid_org.equals(rowid)) {
                    errMsg = "資料重複輸入：申請人 + 被看護人 + 契約起始日"; errId = "1"; invalidField="regno";
                }
            }
        }
        rs.close();
    }

    if (errMsg.length() == 0) {
        if (action.equals("add")) {
            qs = "insert into fpv_outlab values("
                    + AbSql.getEqualStr(regno)
                    + "," + AbSql.getEqualStr(vendname)
                    + "," + AbSql.getEqualStr(vendaddr)
                    + "," + AbSql.getEqualStr(vendtel)
                    + "," + AbSql.getEqualStr(commid)
                    + "," + AbSql.getEqualStr(commname)
                    + "," + AbSql.getEqualStr(style)
                    + "," + AbSql.getEqualStr(outcome)
                    + "," + AbSql.getEqualStr(wrkbdate)
                    + "," + AbSql.getEqualStr(abolishdate)
                    + "," + AbSql.getEqualStr(empid)
                    + "," + AbSql.getEqualStr(emptitle)
                    + "," + AbSql.getEqualStr(loginUser.id)
                    + "," + AbSql.getEqualStr(loginUser.descript)
                    + "," + AbSql.getEqualStr(loginUser.branch)
                    + ",sysdate"
                    + ")";
        } else {
            qs = "update fpv_outlab set"
                    + " regno=" + AbSql.getEqualStr(regno)
                    + ",vendname=" + AbSql.getEqualStr(vendname)
                    + ",vendaddr=" + AbSql.getEqualStr(vendaddr)
                    + ",vendtel=" + AbSql.getEqualStr(vendtel)
                    + ",commid=" + AbSql.getEqualStr(commid)
                    + ",commname=" + AbSql.getEqualStr(commname)
                    + ",style=" + AbSql.getEqualStr(style)
                    + ",outcome=" + AbSql.getEqualStr(outcome)
                    + ",wrkbdate=" + AbSql.getEqualStr(wrkbdate)
                    + ",abolishdate=" + AbSql.getEqualStr(abolishdate)
                    + ",empid=" + AbSql.getEqualStr(empid)
                    + ",emptitle=" + AbSql.getEqualStr(emptitle)
                    + ",cdcid=" + AbSql.getEqualStr(loginUser.id)
                    + ",descript=" + AbSql.getEqualStr(loginUser.descript)
                    + ",branch=" + AbSql.getEqualStr(loginUser.branch)
                    + ",chng_date=sysdate"
                    + " where rowid=" + AbSql.getEqualStr(rowid);
        }
        try {
            common.Comm.updateSQL(stmt, qs);
            errId = "0";
            errMsg = "資料存檔完成！";
        } catch (Exception e) {
            errId = "0";
            errMsg = "存檔錯誤：" + e.getMessage();
        }
    }
    jsonMain.put("invalidField", invalidField);
    jsonMain.put("msgid", errId);
    jsonMain.put("msgtxt", errMsg);
    result = jsonMain.toString();

//雇主
} else if (action.equalsIgnoreCase("vendm")) {
    JSONObject jsonResult = new JSONObject();
    try {
        String regno = AbString.rtrimCheck( request.getParameter("regno") );
        qs = "select * from fpv_vendm where regno=" + AbSql.getEqualStr(regno);
        rs = common.Comm.querySQL(stmt, qs);
        if (!rs.next()) {
            errId = "1";
            errMsg = "資料庫中沒有" + regno +"資料";
        } else {
            jsonResult.put("regno", AbString.rtrimCheck(rs.getString("regno")));
            jsonResult.put("vendname", AbString.rtrimCheck(rs.getString("vendname")));
            jsonResult.put("vendaddr", AbString.rtrimCheck(rs.getString("vendaddr")));
        }
        rs.close();
    } catch (Exception e) {}

    JSONObject jsonMain = new JSONObject();
    jsonMain.put("msgid", errId);
    jsonMain.put("msgtxt", errMsg);
    jsonMain.put("data", jsonResult);
    result = jsonMain.toString();

//查驗被看護人
} else if (action.equalsIgnoreCase("ngbandy")) {
    JSONObject jsonResult = new JSONObject();
    try {
        String commid = AbString.rtrimCheck( request.getParameter("commid") );
        qs = "select * from labdyn_ngbandy where commid=" + AbSql.getEqualStr(commid);
        rs = common.Comm.querySQL(stmt, qs);
        if (!rs.next()) {
            errId = "1";
            errMsg = "傳遞單中沒有被看護人資料：" + commid;
        } else {
            jsonResult.put("commid", AbString.rtrimCheck(rs.getString("commid")));
            jsonResult.put("commname", AbString.rtrimCheck(rs.getString("commname")));
            //診斷書超過 2 個月
            String today = AbDate.getToday();
            String achievedate = AbDate.dateAdd(AbString.rtrimCheck(rs.getString("achievedate")), 0, 0, 60);
            //if (achievedate.compareTo(today) <= 0) errMsg = "診斷書超過 2 個月";
        }
        rs.close();
    } catch (Exception e) {}

    JSONObject jsonMain = new JSONObject();
    jsonMain.put("msgid", errId);
    jsonMain.put("msgtxt", errMsg);
    jsonMain.put("data", jsonResult);
    result = jsonMain.toString();

//審核被看護人
} else if (action.equalsIgnoreCase("verifyNgbandy")) {
    JSONObject jsonResult = new JSONObject();
    try {
        //取得資料
        String commid = AbString.rtrimCheck( request.getParameter("commid") );

        //寫入日誌檔
        String srchdata = "被看護人：" + commid;
//        common.Comm.logOpData(stmt, loginUser, "Outlab", srchdata, AbString.rtrimCheck( request.getRemoteAddr() ));
        common.Comm.logOpData(stmt, loginUser, "Outlab", srchdata, Comm.getClientIpAddress(request));

        //診斷書超過 60 天
        String today = AbDate.getToday();
        //假日天數
        int days = 0;
        boolean holiday = true;
        java.util.Calendar condate = AbDate.strToCalendar(today);
        condate.add(Calendar.DAY_OF_MONTH, -1);
        while (holiday) {
            condate.add(Calendar.DAY_OF_MONTH, 1);
            String nowday = AbDate.fmtDate(condate, "");
            qs = "select * from fpv_holiday where h_date=" + AbSql.getEqualStr(nowday);
            ResultSet rs2 = common.Comm.querySQL(stmt2, qs);
            if (rs2.next()) days++;
            else holiday = false;
            rs2.close();
        }
        String b60_today = AbDate.dateAdd(today, 0, 0, -(days+60)); //60天 + 假日順延天數
        String b90_today = AbDate.dateAdd(today, 0, 0, -(days+90)); //90天 + 假日順延天數
        String b180_today = AbDate.dateAdd(today, 0, 0, -(days+180)); //180天 + 假日順延天數

        //審核結果
        String verifyResult = "";
        jsonResult.put("commid", commid);

        qs = "select * from labdyn_ngbandy where commid=" + AbSql.getEqualStr(commid);
        rs = common.Comm.querySQL(stmt, qs);
        //ngbandy沒有資料
        if (!rs.next()) {
            jsonResult.put("commname", "");
            verifyResult = "不可派案(傳遞單中沒有被看護人資料)";
            rs.close();

        //有資料
        } else {
            jsonResult.put("commname", AbString.rtrimCheck(rs.getString("commname")));
            rs.close();

            qs = "select * from labdyn_ngbandy where commid=" + AbSql.getEqualStr(commid)
                    + " and (valuation like '%F%' or valuation like '%G%' or valuation like '%H%' or valuation like '%W%' or valuation like '%X%' or valuation like '%Y%' or valuation like '%Z%'"
                    +       " or b_grade like '%1%' or b_grade like '%2%')"
                    + " and acquaint = 'd'"
                    + " and (gh_no is not null or b_code is not null or b_grade like '%3%')"
                    + " order by wpindate desc";
            rs = common.Comm.querySQL(stmt, qs);
            if (!rs.next()) {
                verifyResult = "不可派案或僅可提供喘息服務(傳遞單的申請資格不符)";
                rs.close();

            //表示符合可派案的診斷書或身障手冊
            } else {
                String applwpno = AbString.rtrimCheck(rs.getString("applwpno"));
                String achievedate = AbString.rtrimCheck(rs.getString("achievedate"));
                String longtermdate = AbString.rtrimCheck(rs.getString("longtermdate"));
                rs.close();

                if (applwpno.length() == 0) {
                    //診斷日期小於 60 天
                    if ( (achievedate.compareTo(b60_today) >= 0) || (longtermdate.compareTo(b60_today) >= 0) ) {
                        verifyResult = "可派案(1.傳遞單)";
                    } else {
                        verifyResult = "不可派案(傳遞單已超過60天)";
                    }

                //表示applwpno有值，需再判斷是否已引進外勞
                } else {
                    //利用 permit及labod 判斷是否有聘僱外勞
                    //2016.7.1.張玉珊要求修改:聘僱外勞的判斷條件，將原來的labom改成labod，但statuscode仍取自labom
                    String caseno = "";
                    String applkind = "";
                    qs = "select * from labdyn_permit where prmtno=" + AbSql.getEqualStr(applwpno);
                    rs = common.Comm.querySQL(stmt, qs);
                    if (rs.next()) {
                        caseno = AbString.rtrimCheck( rs.getString("regno") )
                                + AbString.rtrimCheck( rs.getString("casekind") )
                                + AbString.rtrimCheck( rs.getString("appltime") );
                        applkind = AbString.rtrimCheck( rs.getString("applkind") );
                    }
                    rs.close();
                    qs = "select d.*, m.statuscode from fpv_labod d, fpv_labom m where d.caseno=" + AbSql.getEqualStr(caseno)
                            + " and d.applkind=" + AbSql.getEqualStr(applkind)
                            + " and m.labono=d.labono";
                    rs = common.Comm.querySQL(stmt, qs);
                    //尚未引進外勞未辦理聘僱
                    if (!rs.next()) {
                        rs.close();

                        //判斷是否有重招函
                        boolean islabor_out = false; //外勞是否已經出境
                        qs ="select * from fpv_resic where wpcode='045' and permwpno = " + AbSql.getEqualStr(applwpno);
                        rs = common.Comm.querySQL(stmt, qs);
                        if (rs.next()) { //有重招函
                            String wpinno = AbString.rtrimCheck( rs.getString("wpinno") );
                            rs.close();
                            qs ="select * from fpv_expirlab where wpinno = " + AbSql.getEqualStr(wpinno);
                            rs = common.Comm.querySQL(stmt, qs);
                            if (rs.next()) { //有外勞
                                String labono = AbString.rtrimCheck( rs.getString("labono"), 20);
                                String indate = AbString.rtrimCheck( rs.getString("indate") );
                                rs.close();
                                //外勞是否已經出境
                                qs ="select * from labdyn_labinout where kindcode='2'"
                                        + " and natcode = " + AbSql.getEqualStr(labono.substring(0, 3))
                                        + " and passno = " + AbSql.getEqualStr(labono.substring(3))
                                        + " and inoutdate > " + AbSql.getEqualStr(indate);
                                rs = common.Comm.querySQL(stmt, qs);
                                if (!rs.next()) { //外勞尚未出境
                                    verifyResult = "不可派案(招募函，請確認外勞已出國後，才可派案)";
                                }
                                rs.close();
                            } else {
                                rs.close();
                            }
                        } else {
                            rs.close();
                        }

                        //沒有重招函，或是有重招函但是外勞已經出境
                        if (verifyResult.length() == 0) {
                            //查核准函是否有凍結：查fpv.freezapplm
                            qs = "select * from fpv_freezapplm where freeznum >= 1 and permwpno=" + AbSql.getEqualStr(applwpno);
                            rs = common.Comm.querySQL(stmt, qs);
                            if (rs.next()) { //代表已凍結
                                String chpermwpno = AbString.rtrimCheck( rs.getString("chpermwpno") );
                                if (chpermwpno.length() == 0) {
                                    verifyResult = "不可派案(核准函已凍結)";
                                } else {
                                    verifyResult = "不可派案或僅可提供喘息服務(核准函國內承接外勞)";
                                }
                                rs.close();

                            } else {
                                rs.close();
                                //代表未凍結
                                //查核准函是否有辦理延長：查fpv.proapplm
                                qs = "select * from fpv_proapplm where permwpno = " + AbSql.getEqualStr(applwpno);
                                rs = common.Comm.querySQL(stmt, qs);
                                if (rs.next()) { //代表有辦理延長
                                    //延長日期小於 90 天
                                    String extendate = AbString.rtrimCheck( rs.getString("extendate") );
                                    if (extendate.compareTo(b90_today) >= 0) {
                                        verifyResult = "可派案(2.核准函)";
                                    } else {
                                        verifyResult = "不可派案(核准函延長已逾期)";
                                    }
                                    rs.close();

                                } else {  //代表沒有辦理延長
                                    rs.close();
                                    //查核准函是否有過期：查fpv.applm
                                    //核准日期小於 180 天
                                    qs = "select * from fpv_applm where permwpno = " + AbSql.getEqualStr(applwpno)
                                            + " and permdate >= " + AbSql.getEqualStr(b180_today);
                                    rs = common.Comm.querySQL(stmt, qs);
                                    if (rs.next()) {
                                        verifyResult = "可派案(2.核准函)";   //代表尚未過期;
                                    } else {
                                        verifyResult = "不可派案(核准函已逾期)"; //代表過期了
                                    }
                                    rs.close();
                                }
                            }
                        }

                    //表示已引進外勞辦理聘僱了，接下來要利用 expir 判斷外勞是否逃跑
                    } else {
                        String labono = AbString.rtrimCheck( rs.getString("labono"), 20 );
                        String natcode = labono.substring(0, 3).trim();
                        String passno = labono.substring(3).trim();
                        String lstatus = AbString.rtrimCheck( rs.getString("statuscode") );
                        rs.close();

                        qs = "select * from labdyn_expir where natcode=" + AbSql.getEqualStr(natcode)
                                + " and passno=" + AbSql.getEqualStr(passno)
                                + " order by expiredate desc"; //最後一筆
                        rs = common.Comm.querySQL(stmt, qs);
                        String happcode = "";
                        String canceltype = "";
                        if (rs.next()) {
                            happcode = AbString.rtrimCheck(rs.getString("happcode"));
                            canceltype = AbString.rtrimCheck(rs.getString("canceltype"));
                        }
                        rs.close();
                        //逃跑條件 canceltype='1' and happcode='HDA' or 'HC1' or 'HC2'
                        boolean hasexpir = false;
                        if ( canceltype.equals("1") && (happcode.equals("HDA") || happcode.equals("HC1") || happcode.equals("HC2")) )
                            hasexpir = true;

                        //有值，代表外勞已逃跑
                        if (hasexpir) {
                            verifyResult = "可派案(2.廢聘函)";

                        //無值，代表外勞未逃跑，需再利用bkretm判斷是否有辦理遞補
                        } else {
                            qs = "select * from labdyn_bkretm where labncode=" + AbSql.getEqualStr(natcode)
                                    + " and visanum=" + AbSql.getEqualStr(passno);
                            rs = common.Comm.querySQL(stmt, qs);
                            //無值，沒有辦理遞補
                            if (!rs.next()) {
                                rs.close();
                                if ("SAA".equals(lstatus)) {
                                    verifyResult = "不可派案或僅可提供喘息服務(已辦聘僱，外勞在台)";
                                } else {
                                    verifyResult = "不可派案(已辦聘僱但外勞狀況代碼不是SAA在台（合法）)";
                                }

                            //有值，有辦理遞補
                            } else {
                                //利用slabpassno判斷遞補外勞尚未引進
                                String slabncode = AbString.rtrimCheck( rs.getString("slabncode") );
                                String slabpassno = AbString.rtrimCheck( rs.getString("slabpassno") );
                                String bkretno = AbString.rtrimCheck( rs.getString("bkretno") );
                                rs.close();

                                if (slabpassno.length() == 0) {
                                    //查遞補函是否有凍結：查fpv.freezapplm
                                    qs = "select * from fpv_freezapplm where freeznum >= 1 and permwpno=" + AbSql.getEqualStr(bkretno);
                                    rs = common.Comm.querySQL(stmt, qs);
                                    if (rs.next()) { //代表已凍結
                                        String chpermwpno = AbString.rtrimCheck( rs.getString("chpermwpno") );
                                        if (chpermwpno.length() == 0) {
                                            verifyResult = "不可派案(遞補函已凍結)";
                                        } else {
                                            verifyResult = "不可派案或僅可提供喘息服務(遞補函國內承接外勞)";
                                        }
                                        rs.close();

                                    } else {
                                        rs.close();
                                        //代表未凍結
                                        //查遞補函是否有辦理延長：查fpv.proapplm
                                        qs = "select * from fpv_proapplm where permwpno = " + AbSql.getEqualStr(bkretno);
                                        rs = common.Comm.querySQL(stmt, qs);
                                        if (rs.next()) { //代表有辦理延長
                                            String extendate = AbString.rtrimCheck( rs.getString("extendate") );
                                            //延長日期小於 90 天
                                            if (extendate.compareTo(b90_today) >= 0) {
                                                verifyResult = "可派案(2.核准函)(遞補函)";
                                            } else {
                                                verifyResult = "不可派案(遞補函延長已逾期)";
                                            }
                                            rs.close();

                                        } else {  //代表沒有辦理延長
                                            rs.close();
                                            //查遞補函是否有過期：查labdyn_bkretm
                                            //遞補日期小於 180 天
                                            qs = "select * from labdyn_bkretm where bkretno = " + AbSql.getEqualStr(bkretno)
                                                    + " and bkretdate >= " + AbSql.getEqualStr(b180_today);
                                            rs = common.Comm.querySQL(stmt, qs);
                                            if (rs.next()) {
                                                verifyResult = "可派案(2.核准函)(遞補函)"; //代表尚未過期
                                            } else {
                                                verifyResult = "不可派案(遞補函已逾期)"; //代表過期了
                                            }
                                            rs.close();
                                        }
                                    }

                                //遞補外勞已引進了
                                } else {
                                    qs = "select * from labdyn_expir where natcode=" + AbSql.getEqualStr(slabncode)
                                            + " and passno=" + AbSql.getEqualStr(slabpassno)
                                            + " order by expiredate desc"; //最後一筆
                                    rs = common.Comm.querySQL(stmt, qs);
                                    happcode = "";
                                    canceltype = "";
                                    if (rs.next()) {
                                        happcode = AbString.rtrimCheck(rs.getString("happcode"));
                                        canceltype = AbString.rtrimCheck(rs.getString("canceltype"));
                                    }
                                    rs.close();
                                    //逃跑條件 canceltype='1' and happcode='HAD' or 'HC1' or 'HC2'
                                    hasexpir = false;
                                    if ( canceltype.equals("1") && (happcode.equals("HAD") || happcode.equals("HC1") || happcode.equals("HC2")) )
                                        hasexpir = true;

                                    //有值，代表外勞已逃跑
                                    if (hasexpir) {
                                        verifyResult = "可派案(2.廢聘函)";
                                    } else {
                                        verifyResult = "不可派案或僅可提供喘息服務(遞補函已辦聘僱)";
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        jsonResult.put("verifyResult", verifyResult);
    } catch (Exception e) {
        throw new Exception(e);
    }

    JSONObject jsonMain = new JSONObject();
    jsonMain.put("msgid", errId);
    jsonMain.put("msgtxt", errMsg);
    jsonMain.put("data", jsonResult);
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
if (stmt2 != null) stmt2.close();
if (conn != null) conn.close();

////////////////////////////////////////////////////////////////////////////////
//輸出資料
Comm.outputResponse(response, result, "UTF-8");

%>
