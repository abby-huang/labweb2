<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "附加案/5級制外勞人數";
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
String labdts_cyyyymmdd = (String)session.getAttribute("labdts_cyyyymmdd");

//取得輸入資料
String regno = AbString.rtrimCheck( request.getParameter("regno") );
String wkadseq = AbString.rtrimCheck( request.getParameter("wkadseq") );

//建立連線
con = common.Comm.getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
String qs;
ResultSet rs;


//計算人數
int[][] labnum = {{0, 0, 0, 0, 0, 0, 0},
                  {0, 0, 0, 0, 0, 0, 0},
                  {0, 0, 0, 0, 0, 0, 0},
                  {0, 0, 0, 0, 0, 0, 0},
                  {0, 0, 0, 0, 0, 0, 0}};
//附加案類別
final List kind1 = Arrays.asList("01", "04", "07", "11", "14");
final List kind2 = Arrays.asList("02", "05", "08", "12", "15");
final List kind3 = Arrays.asList("03", "06", "09", "13", "16");


qs = "select natcode, code, seq, count(*) count from cognos_labdts"
        + " where cyyyymmdd = '" + labdts_cyyyymmdd + "'"
            + " and regno = " + AbSql.getEqualStr(regno)
            + " and wkadseq = " + AbSql.getEqualStr(wkadseq)
        + " and type = 'SA'"
        + " group by natcode, code, seq";
if (debug) out.println("SQL:" + qs + "<BR>");
rs = common.Comm.querySQL(stmt, qs);
while (rs.next()) {
    String natcode = rs.getString("natcode");
    String code = rs.getString("code");
    String seq = rs.getString("seq");
    int count = rs.getInt("count");
    //國籍
    int inatcode = -1;
    for (int i = 0; i < natcodes.length; i++) {
        if ( natcode.equals(natcodes[i]) ) {
            inatcode = i;
            break;
        }
    }

    //附加案類別
    int irow = -1;
    if ("X".equals(code)) {
        if (kind1.contains(seq)) irow = 0; //附加案5%外勞
        else if (kind2.contains(seq)) irow = 1; //附加案10%外勞
        else if (kind3.contains(seq)) irow = 2; //附加案15%外勞
    } else {
        irow = 3; //5級別外勞人數
    }

    if ((inatcode >= 0) && (irow >= 0)) {
        labnum[irow][inatcode] += count;
        labnum[irow][6] += count;       //類別總人數
        labnum[4][inatcode] += count;   //各國別外勞人數合計
        labnum[4][6] += count;          //總計
    }

}
rs.close();


%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<BODY bgcolor="#F9CD8A">


<table border=0 width=1000>
    <form action="">
    <td align=left width=5%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </td>
    </form>

    <td width=85%>
    </td>
</table>





<table width=600 border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 >
				<tr>
				    <td width=16% align=center>國籍</td>
				    <td width=12% align=center>菲律賓</td>
				    <td width=12% align=center>泰國</td>
				    <td width=12% align=center>馬來西亞</td>
				    <td width=12% align=center>印尼</td>
				    <td width=12% align=center>越南</td>
				    <td width=12% align=center>蒙古</td>
				    <td width=12% align=center>總人數</td>
				</tr>

				<tr>
				    <td align=center>附加案5%<br>外勞人數</td>
				    <td align=center><%=labnum[0][1]%></td>
				    <td align=center><%=labnum[0][3]%></td>
				    <td align=center><%=labnum[0][2]%></td>
				    <td align=center><%=labnum[0][0]%></td>
				    <td align=center><%=labnum[0][4]%></td>
				    <td align=center><%=labnum[0][5]%></td>
				    <td align=center><%=labnum[0][6]%></td>
				</tr>
				<tr>
				    <td align=center>附加案10%<br>外勞人數</td>
				    <td align=center><%=labnum[1][1]%></td>
				    <td align=center><%=labnum[1][3]%></td>
				    <td align=center><%=labnum[1][2]%></td>
				    <td align=center><%=labnum[1][0]%></td>
				    <td align=center><%=labnum[1][4]%></td>
				    <td align=center><%=labnum[1][5]%></td>
				    <td align=center><%=labnum[1][6]%></td>
				</tr>
				<tr>
				    <td align=center>附加案15%<br>外勞人數</td>
				    <td align=center><%=labnum[2][1]%></td>
				    <td align=center><%=labnum[2][3]%></td>
				    <td align=center><%=labnum[2][2]%></td>
				    <td align=center><%=labnum[2][0]%></td>
				    <td align=center><%=labnum[2][4]%></td>
				    <td align=center><%=labnum[2][5]%></td>
				    <td align=center><%=labnum[2][6]%></td>
				</tr>
				<tr>
				    <td align=center>5級別外勞<br>人數</td>
				    <td align=center><%=labnum[3][1]%></td>
				    <td align=center><%=labnum[3][3]%></td>
				    <td align=center><%=labnum[3][2]%></td>
				    <td align=center><%=labnum[3][0]%></td>
				    <td align=center><%=labnum[3][4]%></td>
				    <td align=center><%=labnum[3][5]%></td>
				    <td align=center><%=labnum[3][6]%></td>
				</tr>
				<tr>
				    <td align=center>各國別外勞<br>人數合計</td>
				    <td align=center><%=labnum[4][1]%></td>
				    <td align=center><%=labnum[4][3]%></td>
				    <td align=center><%=labnum[4][2]%></td>
				    <td align=center><%=labnum[4][0]%></td>
				    <td align=center><%=labnum[4][4]%></td>
				    <td align=center><%=labnum[4][5]%></td>
				    <td align=center><%=labnum[4][6]%></td>
				</tr>
</table>




<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>


</BODY>
</HTML>