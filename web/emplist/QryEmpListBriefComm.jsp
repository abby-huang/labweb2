<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領外國人雇主依業別、現僱人數、國籍別查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;
int pmax = 100;

//取得輸入資料
int elapseStart = Integer.parseInt( (String)session.getAttribute("elapseStart") );
String srchdata = strCheckNull((String)session.getAttribute("srchdata"));
String keylistFileId = strCheckNull((String)session.getAttribute("keylistFileId"));
String SQLStmt = strCheckNull((String)session.getAttribute("SQLStmt"));
String search = strCheckNull((String)session.getAttribute("searchEmp"));
String searchTitle = strCheckNull((String)session.getAttribute("searchEmpTitle"));
String searchBiz = strCheckNull((String)session.getAttribute("searchEmpBiz"));
String searchLab = strCheckNull((String)session.getAttribute("searchEmpLab"));
String bizTitle = strCheckNull((String)session.getAttribute("empBizTitle"));
String natcode = strCheckNull((String)session.getAttribute("empNatcode"));
String bizseq = strCheckNull((String)session.getAttribute("empBizseq"));
String citycode = strCheckNull((String)session.getAttribute("empCitycode"));
String sqlSearchStmt = strCheckNull((String)session.getAttribute("sqlSearchStmt"));

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
stmt.setQueryTimeout(60*timeout);
stmt2.setQueryTimeout(60*timeout);

//頁數
int p = 1;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}


String qs;
ResultSet rs;

//讀取資料
int totItem = 0; //總筆數
ArrayList<String> keys =  new ArrayList();
if (isKeylistExists(keylistFileId)) {
    keys = readKeys(keylistFileId);
    totItem = keys.size();
} else {
    //查詢資料
    //keys = new ArrayList();
    rs = common.Comm.querySQL(stmt, sqlSearchStmt);
    while (rs.next()) {
        keys.add(rs.getString("regno"));
        totItem++;
    }
    rs.close();
    //儲存 Keylist
    writeKeys(keylistFileId, keys);
}


//計算頁數
int ptot = ((totItem-1) / pmax) + 1;

if (debug)
    response.getWriter().println(sqlSearchStmt + "<BR>");

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<BODY bgcolor="#F9CD8A">

<%
//沒有資料
if (totItem == 0) {
%>

<br><br>
沒有資料，請重新輸入查詢條件。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>


<%
//有外勞資料
} else {
%>

<table border=0 width=1000>
    <form action="">
    <td align=left width=5%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </td>
    </form>

    <form action="QryEmpListPrintComm.jsp" target="_blank">
    <td align=left width=5%>
        <input name=p value=<%=p%> type=hidden>
        <input value="列印此頁" type=submit>
    </td>
    </form>

    <form action="../servlet/QryEmpListTextComm">
    <td align=left width=5%>
        <input value=雇主資料下載 type=submit >
    </td>
    </form>

    <form action="../servlet/QryEmpListAllTextComm">
    <td align=left width=5%>
        <input value=外國人清冊下載 type=submit >
    </td>
    </form>

    <td width=85%>
    </td>
</table>

<table border=0 width=1000>
<tr>
  <td width=85>查詢條件：
  </td>
  <td><%=searchTitle%>
  </td>
</tr>
</table>

<!--表頭-->
<table border=0 width=1000>
    <tr>
        <td width=30% align=left>
            共有 <b><%=totItem%></b> 筆，<b><%=p%>/<%=ptot%></b> 頁
        </td>
        <td align="left" width=50%>
<%  //顯示頁數
if (p > ptot) p = ptot;
int p0 = p - 5;
if (p0 < 1) p0 = 1;

if (ptot > 1) {
    if (p > 1) out.print("<a href=\"" + thisPage + "?p=" + (p-1) + "\"><u>上一頁</u></a>");
    for (int i = 0; ((i+p0) <= ptot) && (i < 10); i++) {
        if ((i+p0) == p) {
            out.print("<font color=#ff0000><b>&nbsp;&nbsp;" + (i+p0) + "</b></font>");
        } else {
            out.print("&nbsp;&nbsp;<a href=\"" + thisPage + "?p=" + (i+p0) + "\"><u>" + (i+p0) + "</u></a>");
        }
    }
    if ((p*pmax) < totItem) out.print("&nbsp;&nbsp;<a href=\"" + thisPage + "?p=" + (p+1) + "\"><u>下一頁</u></a>");
}
%>
        </td>
        <td width=20% align=left>
        </td>
    </tr>
</table>


<table width=1000 border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 >
<tr>
    <td width=8% align=center>聘雇外勞<br>清冊</td>
    <td width=10% align=center>雇主編號</td>
    <td width=8% align=center>雇主名稱</td>
    <td width=23% align=center>地址</td>
    <td width=8% align=center>電話</td>
    <td width=4% align=center>郵遞<br>區號</td>
    <td width=9% align=center>負責人</td>
    <td width=10% align=center>職業別</td>
    <td width=4% align=center>菲律<br>賓</td>
    <td width=4% align=center>泰<br>國</td>
    <td width=4% align=center>馬來<br>西亞</td>
    <td width=4% align=center>印<br>尼</td>
    <td width=4% align=center>越<br>南</td>
    <td width=4% align=center>蒙<br>古</td>
</tr>

<%
response.getWriter().flush();

//顯示資料
int cnt = 0;
int start = ((p-1)*pmax);
while (((start+cnt) < totItem) && (cnt < pmax)) {
    cnt++;
    String regno = keys.get(start+cnt-1);

    //讀雇主資料
    qs = "SELECT"
                + " regno"
                + ",cname"
                + ",addr"
                + ",tel"
                + ",zipcode"
                + ",respname"
                + ",wkadseq"
                + " from labdyn_vend"
                + " where regno = " + AbSql.getEqualStr(regno)
                + " and chng_id <> 'D'"
                + " order by regno, wkadseq desc";
    ResultSet rs2 = common.Comm.querySQL(stmt2, qs);
    if (rs2.next()) {
        String cname = strCheckNull( rs2.getString(2) );
        String addr = strCheckNull( rs2.getString(3) );
        String tel = strCheckNull( rs2.getString(4) );
        String zipcode = strCheckNull( rs2.getString(5) );
        String respname = strCheckNull( rs2.getString(6) );


        //計算人數
        int[] labnum = {0, 0, 0, 0, 0, 0};
        qs = "select natcode, count(*) from labdyn_laborm l"
            + " where regno = " + AbSql.getEqualStr( regno );
        if (searchLab.length() > 0) qs += " and " + searchLab;
        qs += " group by natcode";

        rs2 = common.Comm.querySQL(stmt2, qs);
        while (rs2.next()) {
            String natcode2 = rs2.getString(1);
            int tot = rs2.getInt(2);
            for (int i = 0; i < natcodes.length; i++) {
                if ( natcode2.equals(natcodes[i]) ) {
                    labnum[i] += tot;
                    break;
                }
            }
        }
        rs2.close();

%>



<tr>
    <td align=center><a HREF="../servlet/QryEmpLaborDownText?regno=<%=regno%>&citycode=<%=citycode%>&bizseq=<%=bizseq%>&natcode=<%=natcode%>">清冊下載</a></td>
    <td align=center><a HREF="QryEmpLaborList.jsp?regno=<%=regno%>&citycode=<%=citycode%>&bizseq=<%=bizseq%>&natcode=<%=natcode%>"><%=regno%></a></td>
    <td><%=cname%></td>
    <td><%=addr%></td>
    <td><%=tel%></td>
    <td align=center><%=zipcode%></td>
    <td><%=respname%></td>
    <td><%=bizTitle%></td>
    <td align=center><%=labnum[1]%></td>
    <td align=center><%=labnum[3]%></td>
    <td align=center><%=labnum[2]%></td>
    <td align=center><%=labnum[0]%></td>
    <td align=center><%=labnum[4]%></td>
    <td align=center><%=labnum[5]%></td>
</tr>

<%
   }
}
%>

</table>

<%
}   //結束有外勞資料
%>


<%
//20110114 - 處理時間
int elapseEnd = (int)((new java.util.Date().getTime()) / 1000);
srchdata += "，處理時間：" + (elapseEnd - elapseStart) + "秒";

//寫入日誌檔
common.Comm.logOpData(stmt, userData, "EmpList", srchdata, userAddr);


//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
out.flush();
%>


</BODY>
</HTML>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>
