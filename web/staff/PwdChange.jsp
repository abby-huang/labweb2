<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "變更密碼";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || (!userData.acckind.equals("01"))) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
int pageRows = 100;
String errMsg = "";
Connection con = null;

//取得輸入資料
String action = AbString.rtrimCheck(request.getParameter("action"));

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = con.createStatement();
ResultSet rs;
String qs="";

if (action.equals("取消")) {
    if (con != null) con.close();
    response.sendRedirect("../Main.jsp");
} else if (action.equals("確定")) {
    String oldpwd = AbString.rtrimCheck(request.getParameter("oldpwd"));
    String newpwd = AbString.rtrimCheck(request.getParameter("newpwd"));
    String cfmpwd = AbString.rtrimCheck(request.getParameter("cfmpwd"));
    qs = "select * from staff2 "
            + " where id=" + AbSql.getEqualStr(userData.id);
    rs = stmt.executeQuery(qs);
    if (rs.next()) {
        String dbPwd = AbString.rtrimCheck(rs.getString("pwd"));
        if (dbPwd.length() > 0) {
            com.absys.util.AbEncrypter encrypter = new com.absys.util.AbEncrypter( com.absys.util.AbEncrypter.DESEDE_ENCRYPTION_SCHEME );
            dbPwd = encrypter.decrypt( dbPwd );
        }
        if (!dbPwd.equals(oldpwd)) {
            errMsg = "密碼錯誤";
        } else {
            if (newpwd.length() == 0) {
                errMsg = "必須輸入新密碼";
            } else if (newpwd.equals(oldpwd)) {
                errMsg = "新舊密碼不可以相同";
            } else if (!newpwd.equals(cfmpwd)) {
                errMsg = "新密碼確認錯誤";
            } else {
                //String regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{12,20}$"; //英數、大小寫、長度12-20
                String regexp = "^(?=.*[0-9])(?=.*[a-zA-Z]).{12,20}$"; //英數、長度12-20
                if (!newpwd.matches(regexp)) {
                    errMsg = "密碼長度必須大於或等於12，且含有英文與數字";
                }
            }

        }

    } else {
        errMsg = "帳號錯誤";
    }
    rs.close();

    //更新密碼
    if (errMsg.length() == 0) {
        //密碼編碼
        com.absys.util.AbEncrypter encrypter = new com.absys.util.AbEncrypter( com.absys.util.AbEncrypter.DESEDE_ENCRYPTION_SCHEME );
        newpwd = encrypter.encrypt( newpwd );

        qs = "update staff2 set pwd = " + AbSql.getEqualStr(newpwd)
                + ",pwddate=sysdate"
                + " where id=" + AbSql.getEqualStr(userData.id);
        stmt.executeUpdate(qs);
        //重新讀取密碼變更日期
        userData = new com.absys.user.Staff(stmt, "staff2", userData.id);
        session.setAttribute(appName+"_userData", userData);
    }
}

%>


<html>
    <head>
        <%@ include file="/include/HeaderTimeout.inc" %>
    </head>

    <body bgcolor="#F9CD8A" text="#990000">
        <center>
                <div style="height:10px;"></div>

<% if ( (errMsg.length() == 0) && action.equals("確定") ){ %>

                <table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="250">
                    <tr >
                        <td align="center">
                            密碼變更成功 !
                        </td>
                    </tr>
                </table>

<% } else { %>
                <table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="250">
                    <tr bgcolor="#FF9900">
                        <td colspan=2><img src="../image/arrow.gif" alt="美化圖形">
                            <font color="#FFFFFF"><%=pageHeader%></font>
                        </td>
            <form action ="<%=thisPage%>" method="post">
                    </tr>
                    <tr >
                        <td width=40% align=right>舊密碼：</td>
                        <td width=60% >
                            <input name="oldpwd" type=password autocomplete="off" size=16 maxlength=20>
                        </td>
                    </tr>
                    <tr >
                        <td width=40% align=right>新密碼：</td>
                        <td width=60% >
                            <input name="newpwd" type=password autocomplete="off" size=16 maxlength=20>
                        </td>
                    </tr>
                    <tr >
                        <td width=40% align=right>確認密碼：</td>
                        <td width=60% >
                            <input name="cfmpwd" type=password autocomplete="off" size=16 maxlength=20>
                        </td>
                    </tr>
                    <tr >
                        <td align="center" colspan=2>
                            <input name="action" value="確定" type=submit onclick="return confirm('確定要變更密碼？');">
                            <input name="action" value="取消" type=submit>
                        </td>
                    </tr>
                </table>
            </form>

<% } %>

        <center>
    </body>
</html>

<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>
