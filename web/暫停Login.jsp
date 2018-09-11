<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ page errorPage="ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="org.jawin.DispatchPtr" %>
<%@ page import="org.jawin.win32.Ole32" %>
<%@ page import="com.jacob.com.*" %>
<%@ page import="com.jacob.activeX.*" %>
<%@ page import="javax.servlet.http.*"%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="include/ComConstants.inc" %>
<%@ include file="include/ComFunctions.inc" %>

<%
if (!request.isSecure())
    response.sendRedirect("https://labor.evta.gov.tw:443/labweb_test/Login.jsp");

String pageHeader = "登入";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();
String requestPage = strCheckNull( request.getHeader("Referer") );
String requestUrl = "http://" + strCheckNull( request.getHeader("Host") ) + thisPage;
requestUrl = appRoot + "/Login.jsp";

//定義變數
String userLogin = "";
String userName = "";
String userRegion = "";
String userDivision = "";
String userDivtitle = "";
String userAuthority = "";

String errMsg = "";
Connection con = null;

//取得輸入資料
String userId = strCheckNull( request.getParameter("userId") ).toUpperCase();
String idnoName = strCheckNull( request.getParameter("idnoName") );
String gcaSN = strCheckNull( request.getParameter("gcaSN") );
String liveDate = strCheckNull( request.getParameter("liveDate") );
String evta = strCheckNull( request.getParameter("evta") );

String userAddr = strCheckNull( request.getRemoteAddr() );

//一般民眾進入查詢
if (userId.equals("GUEST") && idnoName.length() == 0) {
    session.setAttribute("userLogin", "N");
    session.setAttribute("userId", userId);
    session.setAttribute("userName", "");
    session.setAttribute("userRegion", "");
    session.setAttribute("userDivision", "");
    session.setAttribute("userDivtitle", "");
    session.setAttribute("userAddr", userAddr);
    session.setAttribute("userAuthority", userAuthority);
    session.setAttribute("gcaSN", gcaSN);
    session.setAttribute("loginPage", "Login.jsp");
    response.sendRedirect("MainManager.jsp");
}

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

if ((errMsg.length() == 0) && (userId.length() != 0) && (idnoName.length() != 0) && (thisPage.equals(requestUrl))) {

    //檢查帳號
    userId = userId.toUpperCase();
    Statement stmt = con.createStatement();
    String qs = "select staff.id id, staff.title, division, authority"
            + ", division.title divtitle, staff.region region"
            + " from staff"
            + " left join division on staff.division = division.id"
            + " where staff.Id=" + AbSql.getEqualStr(userId);
    ResultSet rs = stmt.executeQuery(qs);
    if (rs.next()) {
        if (userId.endsWith( idnoName.substring(0,4) )) {
            //廢止憑證查詢
            /*不查詢
            //使用 Jawin 呼叫 ActiveX
    		try {
                Ole32.CoInitialize();
    			DispatchPtr oGca = new DispatchPtr("AbsysGca.Gca");
                int retval = ((Integer)(oGca.invoke("checkCrlDecode", gcaSN, "c:\\MOICA\\complete.decode"))).intValue();

                if (retval != 0) {
                    switch (retval) {
                        case 30001: errMsg = "憑證已經停用或廢止"; break;
                        case 30002: errMsg = "廢止憑證檔讀取錯誤"; break;
                        case 30003: errMsg = "廢止憑證其他錯誤"; break;
                        default: errMsg = "Error Code：" + retval + " 例外錯誤"; break;
                    }
                }
                Ole32.CoUninitialize();
    		} catch (Exception e) {
                errMsg = "ActiveX GCA 驗證程式載入錯誤";
    			e.printStackTrace();
            } finally {
    		}
            */

//3.0無此功能
/*
            try {
                String crlfile;
                crlfile = "c:\\MOICA\\complete.crl.list";
                ArrayList snlist = new ArrayList();
                BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(crlfile), "ISO8859_1"));
                String lineText;
                while((lineText = reader.readLine()) != null)
                    snlist.add(lineText);
                reader.close();
                int pos = Arrays.binarySearch(snlist.toArray(), gcaSN);
                if (pos >= 0) errMsg = "憑證已經停用或廢止：" + gcaSN;
            } catch (Exception e) {
                errMsg = "廢止憑證檔讀取錯誤";
            } finally {
            }

            //憑證有效期限
            if (errMsg.length() == 0) {
                if (liveDate.compareTo(AbDate.getToday()) < 0)
                    errMsg = "憑證已經過期";
            }
*/
            if (errMsg.length() == 0) {
                userName = strCheckNull(rs.getString("title"));
                userRegion = strCheckNull(rs.getString("region"));
                userDivision = strCheckNull(rs.getString("division"));
                userDivtitle = strCheckNull(rs.getString("divtitle"));
                userAuthority = AbString.leftJustify( AbString.rtrimCheck(rs.getString("authority")), 255 );
                userLogin = "Y";
            }
        } else {
            errMsg = "對不起! 身份證字號比對錯誤";
        }
    } else {
        errMsg = "對不起! 帳號輸入錯誤";
    }
    if (rs != null) rs.close();
}

//公佈欄
String bulletin = "";
if (con != null) {
    Statement stmt = con.createStatement();
    String qs = "select data from param where id = 'bulletin'";
    ResultSet rs = stmt.executeQuery(qs);
    if (rs.next()) bulletin = rs.getString(1).trim();
    rs.close();
    stmt.close();
}

//關閉連線
if (con != null) con.close();

//登入正確
if (userLogin.equals("Y")) {
    session.setAttribute("userLogin", userLogin);
    session.setAttribute("userId", userId);
    session.setAttribute("userName", userName);
    session.setAttribute("userRegion", userRegion);
    session.setAttribute("userDivision", userDivision);
    session.setAttribute("userDivtitle", userDivtitle);
    session.setAttribute("userAddr", userAddr);
    session.setAttribute("gcaSN", gcaSN);
    session.setAttribute("userAuthority", userAuthority);
    session.setAttribute("loginPage", "Login.jsp");
    response.sendRedirect("MainManager.jsp");
}
%>
<head>
<%@ include file="include/Header.inc" %>

<OBJECT id="absysGca" codebase="activex/AbsysGca.cab#version=3,0,0,0" classid="clsid:EF79896F-944F-4BFE-BA9B-05745A468CC9" VIEWASTEXT></OBJECT>

<script language="JavaScript">

<!--
//驗證 IC 卡
function gcaVerify(frm) {
    var retval = false;
    var cert = "";
    var rc = 99999;
    var msg = "";
    var idnoName = "";
    var gcaSN = "";
    var liveDate = "";
    if (frm.userId.value.length == 0) {
        alert("請輸入帳號");
        return false;
    }
    if (frm.password.value.length == 0) {
        alert("請輸入密碼");
        return false;
    }

    //執行驗證程式
    try {
        rc = absysGca.verifyPassword(frm.password.value);
        if (rc == 0) {
            //取得憑證
            cert = absysGca.getCertificate();
            if (cert.length > 0 ){
                //檢驗憑證
                rc = absysGca.verifyMoica(cert);
                if (rc == 0) {
                    //憑證正確
                    retval = true;
                    idnoName = absysGca.getSubjectIdnoName(cert);
                    gcaSN = absysGca.getSerialNo(cert);
//3.0無此功能
//                    liveDate = absysGca.getLiveDate(cert);
                    frm.idnoName.value = idnoName;
                    frm.gcaSN.value = gcaSN;
                    frm.liveDate.value = liveDate;
                }
            } else {
                rc = 20001;
            }
        }
    } catch (e) {
    }

    //設定錯誤訊息
    switch (rc) {
        case 0:     msg = ""; break;

        case 10001: msg = "IC卡讀取錯誤，請檢查讀卡機"; break;
        case 10002: msg = "無法從卡片讀出憑證資料"; break;
        case 10003: msg = "密碼連續三次輸入錯誤，IC卡已被鎖住"; break;
        case 10004: msg = "密碼輸入錯誤 - 第一次"; break;
        case 10005: msg = "密碼輸入錯誤 - 第二次"; break;
        case 10006: msg = "密碼輸入錯誤 - 第三次"; break;

        case 20001: msg = "憑證資料錯誤"; break;
        case 20002: msg = "憑證的簽章檢驗錯誤"; break;
        case 20003: msg = "憑證不在有效日期內"; break;

        case 50001: msg = "MOI 憑證錯誤"; break;
        case 99999: msg = "ActiveX GCA 驗證程式載入錯誤"; break;
        default:    msg = "Error Code：" + rc + " 例外錯誤"; break;
    }

    //顯示錯誤訊息
    if (msg != "") {
        alert(msg);
        frm.userId.value = "";
        frm.password.value = "";
        frm.userId.focus();
    }
    return retval;
}
-->
</script>

<script language="JavaScript">
<!--
function MM_swapImgRestore() { //v2.0
  if (document.MM_swapImgData != null)
    for (var i=0; i<(document.MM_swapImgData.length-1); i+=2)
      document.MM_swapImgData[i].src = document.MM_swapImgData[i+1];
}

function MM_preloadImages() { //v2.0
  if (document.images) {
    var imgFiles = MM_preloadImages.arguments;
    if (document.preloadArray==null) document.preloadArray = new Array();
    var i = document.preloadArray.length;
    with (document) for (var j=0; j<imgFiles.length; j++) if (imgFiles[j].charAt(0)!="#"){
      preloadArray[i] = new Image;
      preloadArray[i++].src = imgFiles[j];
  } }
}

function MM_swapImage() { //v2.0
  var i,j=0,objStr,obj,swapArray=new Array,oldArray=document.MM_swapImgData;
  for (i=0; i < (MM_swapImage.arguments.length-2); i+=3) {
    objStr = MM_swapImage.arguments[(navigator.appName == 'Netscape')?i:i+1];
    if ((objStr.indexOf('document.layers[')==0 && document.layers==null) ||
        (objStr.indexOf('document.all[')   ==0 && document.all   ==null))
      objStr = 'document'+objStr.substring(objStr.lastIndexOf('.'),objStr.length);
    obj = eval(objStr);
    if (obj != null) {
      swapArray[j++] = obj;
      swapArray[j++] = (oldArray==null || oldArray[j-1]!=obj)?obj.src:oldArray[j];
      obj.src = MM_swapImage.arguments[i+2];
  } }
  document.MM_swapImgData = swapArray; //used for restore
}
-->

</script>

</head>


<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>

<script language="javascript">
    if (window != top) {
        top.location.href = location.href;
    }
</script>

<script language=JavaScript>
function window.onload() {
    form1.userId.focus();
}
</script>

<META name=GENERATOR content="MSHTML 5.00.2014.210">
<body bgcolor="#F9CD8A" topmargin="0" leftmargin="0" marginheight=0 marginwidth=0>

<center>
<img src="image/top_homepage.gif" alt="美化圖形" width="780" height="81">
<table width="90%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align=center colspan=2><img src="image/welcome.gif" alt="歡迎光臨使用外國人查詢系統"  >
    </td>
  </tr>
  <tr>
    <td align=center colspan=2><img src="image/line_homepage.gif" alt="美化圖形" >
    </td>
  </tr>
</table>

<table border=0>
<tr>
<td align=center width=30%><a href="<%=thisPage%>?userId=guest" title="一般民眾進入查詢" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('document.login.Image1','document.Image1','image/login_over.gif')"><img src="image/login_up.gif" alt="一般民眾進入" border="0" name="Image1"></a>
  <table border=0>
  <tr height="30">
    <td align=right valign=top width=30%><font color="#0066CC">說明：</font>
    </td>
    <td><font color="#990000">一般民眾進入本系統不需輸入身份證字號及密碼</font>
    </td>
  </tr>

</td>
</tr>

</table>
</td>

<td width=25%>
  <table border=0>
  <form method=post action="<%=thisPage%>" name="form1" onsubmit="return gcaVerify(this);">
  <tr height="30">
    <td align=right width=60%><font color="#0066CC">身份證字號： </font>
    </td>
    <td><input name=userId size=10 maxlength=10>
    </td>
  </tr>
  <tr height="30">
    <td align=right><font color="#0066CC">密碼：</font>
    </td>
    <td><input name=password type=password size=10 maxlength=20>
    </td>
  </tr>
  <tr>

    <td height="30" colspan=2 align=center>&nbsp
       <input type="hidden" name="idnoName" value="">
       <input type="hidden" name="liveDate" value="">
       <input type="hidden" name="gcaSN" value="">
       <input value="縣市政府進入" name=login type=submit>
    </td>
  </tr>
  </form>
</td>
</tr>
</table>
</td>



<td colspan=3 valign=top>
  <table border=1 bordercolor="#FF9900" width=350>
  <tr>
    <td align=center bgcolor="#FF9900">
      <center>
      <font color="#FFFFFF"><b>本系統公告訊息：</b></font>
    </td>
<!--
  <tr>
    <td>
      <%=bulletin%>
    </td>
  </tr>
-->

  <tr>
    <td><font color="#990000">使用新版自然人憑證者（IC卡編號為TP開頭）請先參考<a href="MOICA5_3.doc">說明文件</a>。
        <br>若自動下載ActiveX驗證程式發生問題時，亦請參考上述說明文件。
    </td>
  </tr>

  <tr>
    <td><font color="#990000">第一次使用本系統的電腦，請先連結至政府憑證總管理中心<a href="http://grca.nat.gov.tw/pse/index.html">GRCA自簽憑證自動安裝網頁</a>，然後再進入本系統。</font>
    </td>
  </tr>
  </table>
</td>
</tr>
<!--
<tr>
    <td align=right><font color="#990000">本系統開放時間：</font></td>
    <td><font color="#990000">08:00～19:30</font></td>
</tr>
<tr>
    <td align=right><font color="#990000">星期例假日：</font></td>
    <td><font color="#990000">09:00～17:00</font></td>
</tr>
-->
</table>


</BODY>
</html>
