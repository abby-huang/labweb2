<%@ page pageEncoding="UTF-8" %>

<%
    //取得登入起始參數
    com.absys.user.Staff loginUser = (com.absys.user.Staff)session.getAttribute(common.Consts.appName+"_userData");
    com.absys.user.Modules sysModules = (com.absys.user.Modules)session.getAttribute(common.Consts.appName+"_modules");
    session.setAttribute("debugMsg", "");
    boolean debug = false;
    if ("F120539973,G120066663".indexOf(loginUser.id) >= 0) debug = true;

%>
