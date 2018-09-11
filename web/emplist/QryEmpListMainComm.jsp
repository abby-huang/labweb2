<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領外國人雇主依業別、現僱人數、國籍別查詢 - 雇主地址";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection conn = null;

//取得輸入資料
String addrtype = filterMetaCharacters( request.getParameter("addrtype") );
String citycode = filterMetaCharacters( request.getParameter("citycode") );
String bizseq = filterMetaCharacters( request.getParameter("bizseq") );
String natcode = filterMetaCharacters( request.getParameter("natcode") );
String status = filterMetaCharacters( request.getParameter("status") );
//儲存Keys的檔案名稱
String keylistFileId = com.absys.util.AbDate.getToday() + "-" + citycode + "-" + addrtype + "-" + bizseq + "-" + natcode
        + "-" + status;

//建立連線
conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = conn.createStatement();
stmt.setQueryTimeout(90*timeout);
String qs;
ResultSet rs;

//限制條件
String search = "";
search += " and wkadseq in (select max(wkadseq) from labdyn_vend sv where sv.regno = v.regno)";

//縣市郵遞區號
String zipcodes = "";
qs = "select zipcode from fpv_zipcitym"
        + " where citycode = " + AbSql.getEqualStr(citycode)
        + " order by zipcode";
rs = common.Comm.querySQL(stmt, qs);
while (rs.next()) {
    if (zipcodes.length() > 0) zipcodes += ",";
    zipcodes += "'" + strCheckNull( rs.getString(1) ) + "'";
}
rs.close();
zipcodes = "(" + zipcodes + ")";
search += " and zipcode in " + zipcodes;


///////////
search += " and (select count(*) from labdyn_laborm l"
        + " where l.regno = v.regno";

//國籍
String searchNat = "";
if (natcode.length() > 0) {
    searchNat = " and l.natcode = " + AbSql.getEqualStr( natcode );
}
String natiname = getNatcodeName(natcode, natcodes, natnames);

//行職業別
String searchBiz = "";
int ibiz = 0;
if (bizseq.length() > 0) {
    ibiz = Integer.parseInt(bizseq);
    //營建業 labdyn_permit = 'C3051' - 20110106 - 從 workprmt 取 emplcode 2015-02-06
    if (ibiz == 0) {
        searchBiz += " and (l.casekind not in " + bizCodeToSql( bizcodes[ibiz] )
                + " and not exists (select * from labdyn_workprmt w"
                + " where l.natcode = w.natcode and l.passno = w.passno and l.wkprmtdate = w.wkprmtdate and emplcode = 'C3051'))";
    } else {
        searchBiz += " and (l.casekind in " + bizCodeToSql( bizcodes[ibiz] );
        if (ibiz == 1) //營建業
            searchBiz += " or exists (select * from labdyn_workprmt w"
                    + " where l.natcode = w.natcode and l.passno = w.passno and l.wkprmtdate = w.wkprmtdate and emplcode = 'C3051')";
        searchBiz += ")";
    }
}


//外勞狀態
String searchStatus = "";
if (status.equals("1"))
    searchStatus += " and (l.lstatus = 'SAA' or l.lstatus = 'SAC')";
else if (status.equals("2"))
    searchStatus += " and (l.lstatus = 'SBA')";
searchStatus += " and not exists (select * from labdyn_expir x where "
        + " l.natcode = x.natcode and l.passno = x.passno"
        + " and x.outdate > x.indate and x.indate = l.fstindate)";

//結合國籍，行職業別，外勞狀態 => 外勞查詢條件
String searchLab = "";
searchLab = searchNat + searchBiz;
searchLab += " and l.chng_id <> 'D'";
//2010.03.02 增加 bkretm 條件
searchLab += " and (exists (select * from labdyn_permit p where l.prmtno = p.prmtno)";
searchLab += " or exists (select * from labdyn_bkretm bk where l.prmtno = bk.bkretno))";
//searchLab += " or exists (select * from fpv_wp007 wp where l.prmtno = wp.inwpno))";
searchLab += " and exists (select * from labdyn_workprmt w where "
        + " l.natcode = w.natcode and l.passno = w.passno and chng_id <> 'D')";
searchLab += searchStatus;
if (searchLab.length() > 0) searchLab = searchLab.substring(4);

search += " and " + searchLab + ")";

//現僱外勞人數
search += " > 0";

if (search.length() > 0) search = " where " + search.substring(4);


//縣市轄區
String citytitle = "";
if (citycode.length() > 0) {
    qs = "select cityname from fpv_citym"
            + " where citytype='A' and citycode = " + AbSql.getEqualStr(citycode);
    rs = common.Comm.querySQL(stmt, qs);
    if (rs.next()) citytitle = strCheckNull( rs.getString(1) ).trim().replaceAll("　+$", "");
    rs.close();
}

//外勞狀態
String statustitle = "";
if (status.equals("1")) statustitle = "合法";
else if (status.equals("2")) statustitle = "非法";
else statustitle = "全部";


String searchTitle = "";
searchTitle += "雇主地址【" + citytitle + "】";
if (bizseq.length() > 0) searchTitle += "、行職業別【" + bizkinds[ibiz] + "】";
if (natcode.length() > 0) searchTitle += "、國籍【" + natiname + "】";
//searchTitle += "、現僱人數【" + stot + "~" + etot + "】";
searchTitle += "、外勞狀態【" + statustitle + "】";

String sqlSearchStmt = ""; //SQL 完整指令

if (errMsg.length() == 0 ) {
    //20110114 - 開始時間
    int elapseStart = (int)((new java.util.Date().getTime()) / 1000);

    String srchdata = "雇主地址：" + citytitle;
    srchdata += "，行職業別：" + bizkinds[ibiz];
    if (natcode.length() > 0) srchdata += "，國籍：" + natiname;
    //srchdata += "，現僱人數：" + stot + "~" + etot;
    srchdata += "，外勞狀態：" + statustitle;

    //寫入日誌檔
    /*
    qs = "insert into logdata values ("
            + AbSql.getEqualStr(logEmpList)
            + "," + AbSql.getEqualStr(userDivision)
            + "," + AbSql.getEqualStr(userName)
            + "," + AbSql.getEqualStr( AbDate.getTodayYYYYMMDD() )
            + "," + AbSql.getEqualStr( AbDate.getNowTime(":") )
            + "," + AbSql.getEqualStr(srchdata)
            + ")";
    if (!userId.equals("G120066663"))
        stmt.executeUpdate(qs);
    */

    //查詢字串
    qs = "select distinct regno from labdyn_vend v " + search
            + " order by regno";
    sqlSearchStmt = qs;

    //檢查Keylist檔案是否存在
    int totItem = 0; //總筆數
/*
    if (isKeylistExists(keylistFileId)) {
        ArrayList<String> keys = null;
        keys = readKeys(keylistFileId);
        totItem = keys.size();
    } else {
        //查詢資料
        //stmt.executeUpdate(qs);
        session.setAttribute("SQLStmt", qs); //存入SQL指令
        //從 tbl_temp 讀取資料
        ArrayList<String> keys = new ArrayList();
        rs = common.Comm.querySQL(stmt, qs);
        while (rs.next()) {
            keys.add(rs.getString("regno"));
            totItem++;
        }
        rs.close();
        //儲存 Keylist
        writeKeys(keylistFileId, keys);
    }
*/

    //關閉連線
    stmt.close();
    if (conn != null) conn.close();

    //有資料
    if (totItem >= 0) {
        //重導至顯示頁
        session.setAttribute("elapseStart", elapseStart+"");
        session.setAttribute("srchdata", srchdata);
        session.setAttribute("keylistFileId", keylistFileId);
        session.setAttribute("searchEmp", search);
        session.setAttribute("searchEmpTitle", searchTitle);
        session.setAttribute("searchEmpBiz", searchBiz);
        session.setAttribute("searchEmpLab", searchLab);
        session.setAttribute("empBizseq", bizseq);
        session.setAttribute("empBizTitle", bizkinds[ibiz]);
        session.setAttribute("empNatcode", natcode);
        session.setAttribute("empCitycode", citycode);
        session.setAttribute("sqlSearchStmt", sqlSearchStmt);
        response.sendRedirect("QryEmpListBriefComm.jsp");
    }
}

%>


<html>
<head>
<%@ include file="/include/Header.inc" %>
</head>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
    history.back();
</script>
<%}%>

<BODY bgcolor="#F9CD8A">

<%
if (debug) response.getWriter().println(sqlSearchStmt + "<BR>");
%>

沒有資料，請重新輸入查詢條件。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

<%
//關閉連線
stmt.close();
if (conn != null) conn.close();
%>


</BODY>
</HTML>
