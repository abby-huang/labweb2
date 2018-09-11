<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "外勞動態資料下載檔重傳";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || (!userOptrans_linwu.equals("Y") && !userOptrans_weisen.equals("Y") && !userOptrans_genchen.equals("Y"))) {
    response.sendRedirect("../Logout.jsp");
}

String errMsg = "";
%>


<html>
    <head>
        <%@ include file="/include/HeaderTimeout.inc" %>
        <style type="text/css">
            <!--
            a:link		{  color:#0000FF; text-decoration: none}
            a:visited	{  color:#0000FF; text-decoration: none}
            a:hover		{  color:#FF0000; text-decoration: none}
            a:active	{  color:#FF0000; text-decoration: none}
            -->
        </style>
    </head>


    <BODY bgcolor="#F9CD8A" text="#990000">
        <center>
            <table width="3" border="0" cellspacing="0" cellpadding="0" >
                <tr>
                    <td align=center><img src="../image/clrtransdate.gif" alt="外勞動態資料下載檔重傳" >
                    </td>
                </tr>
                <tr>
                    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
                    </td>
                </tr>
            </table>

            <table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="300">
                <%if (userLogin.equals("Y") && (userOptrans_linwu.equals("Y") || userOptrans_weisen.equals("Y"))) {%>
                    <tr><td><a href="ClrVend.jsp">雇主基本資料（.emp檔 - vend）</a></td></tr>
                    <tr><td><a href="ClrExpir.jsp">外勞撤銷聘雇資料（.wit檔 - expir）</a></td></tr>
                <%}%>
                <%if (userLogin.equals("Y") && (userOptrans_weisen.equals("Y") || userOptrans_genchen.equals("Y"))) {%>
                    <tr><td><a href="ClrWorkprmt.jsp">外勞異動資料（.lab檔 - workprmt）</a></td></tr>
                <%}%>
                <%if (userLogin.equals("Y") && userOptrans_weisen.equals("Y")) {%>
                    <tr><td><a href="ClrLab_inform.jsp">外勞通報資料（.ifo檔 - lab_inform）</a></td></tr>
                    <tr><td><a href="ClrHealthchk.jsp">外勞體檢資料（.hea檔 - healthchk）</a></td></tr>
                <%}%>
                <%if (userLogin.equals("Y") && userOptrans_linwu.equals("Y")) {%>
                    <tr><td><a href="ClrPermit.jsp">核准招募資料（.prm檔 - permit）</a></td></tr>
                    <tr><td><a href="ClrResi.jsp">核准簽證資料（.vis檔 - resi）</a></td></tr>
                    <!--<tr><td><a href="ClrResiold.jsp">舊核准簽證資料（.rsd檔 - resiold）</a></td></tr>-->
                    <tr><td><a href="ClrBkretm.jsp">遞補資料（.sub檔 - bkretm）</a></td></tr>
                    <tr><td><a href="ClrSubpermit.jsp">補發函資料（.rep檔 - subpermit）</a></td></tr>
                    <tr><td><a href="ClrProperm.jsp">核准延長資料（.pro檔 - properm）</a></td></tr>
                    <tr><td><a href="ClrRetrylab.jsp">核准重入境資料（.ret檔 - retrylab）</a></td></tr>
                    <!--<tr><td><a href="ClrLabinout.jsp">外勞最新出境資料（.ody檔 - labinout）</a></td></tr>-->
                    <tr><td><a href="ClrFreezperm.jsp">凍結引進核配資料（.fre檔 - freezperm）</a></td></tr>
                    <tr><td><a href="ClrFagent.jsp">國外仲介公司資料（.fag檔 - fagent）</a></td></tr>
                    <!--<tr><td><a href="ClrDynalm.jsp">外勞狀況代碼資料（.dyn檔 - dynalm）</a></td></tr>-->
                <%}%>
            </table>
            <p> 

                <%if (userLogin.equals("Y") && userOptrans_linwu.equals("Y")) {%>
            <table border=0 bgcolor="" bordercolor="#FF9900" width="400">
                    <tr><td>重接收exfpv作業</td></tr>
            </table>
            <table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="400">
                    <tr><td><a href="ClrExexpirlab.jsp">撤銷聘僱檔解黑名單重接收及即時下載作業（.wit檔 -exexpirlab）</a></td></tr>
                <%}%>
            </table>

    </BODY>
</HTML>

