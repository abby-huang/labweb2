<%@ page pageEncoding="UTF-8" %>

<%!
Connection getConnection(HttpSession session) {
    return getConnection( session, "dbDataSource" );
}

Connection getConnection(HttpSession session, String dataSource) {
    //讀取連線資料
    String dbDataSource = (String)session.getAttribute("dbDataSource");
    if (dbDataSource == null) {
        ResourceBundle prop=null;
        try {
            prop = ResourceBundle.getBundle("appmain", Locale.getDefault());
            dbDataSource = prop.getString("dbDataSource");
        } catch (Exception e) {
        }
    }
    //建立連線
    try {
        Connection conn = null;
        javax.naming.Context initContext = new javax.naming.InitialContext();
        javax.naming.Context env = (javax.naming.Context) initContext.lookup("java:comp/env");
        javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup(dbDataSource);
        if (ds != null) conn = ds.getConnection();
        session.setAttribute("dbDataSource", dbDataSource);
        return conn;
    } catch (Exception e) {
        return null;
    }
}


////////////////////////////////////////////////////////////////////////////////
//取得代碼名稱 - 從陣列參數
String getCodeTitle(String id, String titles[][]) {
    if ((id == null) || (id.length() == 0)) return "";
    String retval = "";
    for (int i = 0; i < titles.length; i++) {
        if (id.equals(titles[i][0])) {
            retval = titles[i][1];
            break;
        }
    }
    return retval;
}
//從名稱取得代碼
String getCodeFormTitle(String title, String codes[][]) {
    if ((title == null) || (title.length() == 0)) return "";
    String retval = "";
    for (int i = 0; i < codes.length; i++) {
        if (title.equals(codes[i][1])) {
            retval = codes[i][0];
            break;
        }
    }
    return retval;
}
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
boolean getAuthority(String userAuthority, int pos) {
    return (userAuthority.charAt(pos) == '1');
}

String strCheckNull(String s) {
    if (s == null) s = "";
    return s.trim();
}

String strCheckNullHtml(String s) {
    if (s == null) s = "";
    if (s.trim().length() == 0) s = "&nbsp;";
    return s;
}

String filterMetaCharacters(String value) {
    if (value == null) return "";
    value = value.replaceAll("\\p{Cntrl}", "").replaceAll("[.,:;()?!\" \t\n\r\']+", "");

    value = value.replaceAll("<", "&lt;").replaceAll(">", "&gt;");
    value = value.replaceAll("\\(", "&#40;").replaceAll("\\)", "&#41;");
    value = value.replaceAll("'", "&#39;");
    value = value.replaceAll("%", "");

    value = value.replaceAll("eval\\((.*)\\)", "");
    value = value.replaceAll("((?i)script)", "");
    value = value.replaceAll("[\\\"\\\'][\\s]*((?i)javascript):(.*)[\\\"\\\']", "\"\"");
    return value;
}

int zerostrToInt(String s) {
    StringBuffer buf = new StringBuffer(s.length());
    // 去除前面的 '0'
    boolean f = false;
    for ( int i = 0;  i < s.length();  i++ ) {
        String c = s.substring(i, i+1);
        if (f) {
            buf.append(c);
        } else {
            if (!c.equals("0")) {
                buf.append(c);
                f = true;
            }
        }
    }
    if (buf.length() == 0) buf.append("0");
    return Integer.parseInt( buf.toString() );
}

String intPadZero(int n, int wid) {
    String str = Integer.toString(n);
    for ( int i = wid - str.length();  i > 0;  i-- ) {
        str = '0' + str;
    }
    return str;
}

String convertChiSymbol(String s) {
    String tmp = s.replaceAll("︵", "（");
    tmp = tmp.replaceAll("︶", "）");
    tmp = tmp.replaceAll("「", "「");
    tmp = tmp.replaceAll("」", "」");
    return tmp;
}

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
String getNatcodeName(String natcode, String natcodes[], String[] natnames) {
    String nattitle = natcode;
    for (int i = 0; i < natcodes.length; i++) {
        if ( natcode.equals(natcodes[i]) ) {
            nattitle = natnames[i];
            break;
        }
    }
    return nattitle;
}

String getBizKind(String bizcode, String bizcodes[], String[] bizkinds) {
    String bizkind = bizkinds[0];
    for (int i = 1; i < bizkinds.length; i++) {
        if (bizcodes[i].indexOf(bizcode) >= 0) {
            bizkind = bizkinds[i];
            break;
        }
    }
    return bizkind;
}

String fmtDate(String s, String dlm) {
    String tmp = s.trim();
    if (tmp.length() == 8) {
        return s.substring(0, 4) + '/' + s.substring(4, 6) + '/' + s.substring(6, 8);
    } else {
        return s;
    }
}

String cityCodeToSql(String s) {
    if (s.length() == 0) return "('')";
    String sary[] = s.split(",");
    String tmp = "";
    for (int i = 0; i < sary.length; i++) {
        if (tmp.length() > 0) tmp += ",";
        tmp += "'" + sary[i] + "'";
    }

    return "(" + tmp + ")";
}

String multiOrSql(String fld, String s) {
    if (s.length() == 0) return "('')";
    String sary[] = s.split(",");
    String tmp = "";
    for (int i = 0; i < sary.length; i++) {
        if (tmp.length() > 0) tmp += " or ";
        tmp += fld + "='" + sary[i] + "'";
    }

    return "(" + tmp + ")";
}

String bizCodeToSql(String s) {
    if (s.length() == 0) return "('')";
    String tmp = "";
    for (int i = 0; i < s.length(); i++) {
        if (tmp.length() > 0) tmp += ",";
        tmp += "' " + s.substring(i, i+1) + "'";
    }

    return "(" + tmp + ")";
}

String bizCodeToSql2(String s) {
    if (s.length() == 0) return "('')";
    String tmp = "";
    for (int i = 0; i < s.length(); i++) {
        if (tmp.length() > 0) tmp += ",";
        tmp += "'" + s.substring(i, i+1) + "'";
    }

    return "(" + tmp + ")";
}

String checkCityName(String citycode, String cityname) {
    if (citycode.equals("09")) cityname = "臺中縣" + cityname.substring(3);
    else if (citycode.equals("15")) cityname = "臺南縣" + cityname.substring(3);
    else if (citycode.equals("17")) cityname = "高雄縣" + cityname.substring(3);
    return cityname;
}



//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
Calendar twnstrToCalendar(String s, boolean pre) {
    if (checkTwnDate(s)) {
        int year = Integer.parseInt(s.substring(0, s.length()-4));
        int mon = Integer.parseInt(s.substring(s.length()-4, s.length()-2)) - 1;
        int day = Integer.parseInt(s.substring(s.length()-2, s.length()));
        year = (pre) ? (1912-year) : (1911+year);
        Calendar cal = Calendar.getInstance();
        cal.clear();
        cal.set(year, mon, day);
        return cal;
    } else {
        return null;
    }
}
Calendar twnstrToCalendar(String s) {
    return twnstrToCalendar(s, false);
}

java.sql.Date twnstrToSqlDate(String s, boolean pre) {
    Calendar cal = twnstrToCalendar(s, pre);
    if (cal != null)
        return new java.sql.Date(cal.getTimeInMillis());
    else
        return null;
}
java.sql.Date twnstrToSqlDate(String s) {
    return twnstrToSqlDate(s, false);
}


//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
String fmtTwnDate(long date, String dlm) {
    Calendar cal = Calendar.getInstance();
    cal.setTimeInMillis(date);
    int year = (cal.get(Calendar.YEAR)-1911);
    if (year <= 0) year = 1 - year;
    String mon = "00" + (cal.get(Calendar.MONTH) + 1);
    String day = "00" + cal.get(Calendar.DATE);

    return year + dlm + mon.substring(mon.length()-2) + dlm + day.substring(day.length()-2);
}

String fmtTwnDate(java.util.Date date, String dlm) {
    if (date != null)
        return fmtTwnDate(date.getTime(), dlm);
    else
        return "";
}

boolean checkDatePreroc(long date) {
    Calendar cal = Calendar.getInstance();
    cal.setTimeInMillis(date);
    return (cal.get(Calendar.YEAR) < 1912);
}

boolean checkDatePreroc(java.util.Date date) {
    boolean retval = false;
    if (date != null) {
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(date.getTime());
        return (cal.get(Calendar.YEAR) < 1912);
    } else {
        return false;
    }
}



//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
String fmtTwnDateSlash(String s) {
    if (checkTwnDate(s)) {
        return s.substring(0, s.length()-4) + '/' + s.substring(s.length()-4, s.length()-2)
                + '/' + s.substring(s.length()-2, s.length());
    } else {
        return s;
    }
}

boolean checkTwnDate(String s) {
    boolean retval = false;
    if ((s != null) && (s.length() >= 5) && (s.length() <= 7)) {
        try {
            int year = Integer.parseInt( s.substring(0, s.length()-4) );
            int mon = Integer.parseInt( s.substring(s.length()-4, s.length()-2) );
            int day = Integer.parseInt( s.substring(s.length()-2, s.length()) );
            if ((mon >=1) && (mon <=12) && (day >= 1) && (day <=31))
                retval = true;
        } catch (Exception e) {
        }
    }
    return retval;
}

String getTodayTwn() {
    Calendar rightNow = Calendar.getInstance();
    int year  = rightNow.get(Calendar.YEAR);
    int mon = rightNow.get(Calendar.MONTH) + 1;
    int day = rightNow.get(Calendar.DAY_OF_MONTH);

    String retval = Integer.toString(year-1911);
    if (mon < 10) retval += "0";
    retval += Integer.toString(mon);
    if (day < 10) retval += "0";
    retval += Integer.toString(day);

    return retval;
}


//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
String stringToHTMLString(String string) {
    StringBuffer sb = new StringBuffer(string.length());
    // true if last char was blank
    boolean lastWasBlankChar = false;
    int len = string.length();
    char c;

    for (int i = 0; i < len; i++)
        {
        c = string.charAt(i);
        if (c == ' ') {
            // blank gets extra work,
            // this solves the problem you get if you replace all
            // blanks with &nbsp;, if you do that you loss
            // word breaking
            if (lastWasBlankChar) {
                lastWasBlankChar = false;
                sb.append("&nbsp;");
                }
            else {
                lastWasBlankChar = true;
                sb.append(' ');
                }
            }
        else {
            lastWasBlankChar = false;
            //
            // HTML Special Chars
            if (c == '"')
                sb.append("&quot;");
            else if (c == '&')
                sb.append("&amp;");
            else if (c == '<')
                sb.append("&lt;");
            else if (c == '>')
                sb.append("&gt;");
            else if (c == '\n')
                // Handle Newline
                sb.append("&lt;br/&gt;");
            else {
                int ci = 0xffff & c;
                if (ci < 160 )
                    // nothing special only 7 Bit
                    sb.append(c);
                else {
                    // Not 7 Bit use the unicode system
                    sb.append("&#");
                    sb.append(new Integer(ci).toString());
                    sb.append(';');
                    }
                }
            }
        }
    return sb.toString();
}


//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
boolean isKeylistExists(String keylistFileId)
{
    boolean retval = false;
    String filename = getServletContext().getRealPath("")
                + java.io.File.separator + "work" + java.io.File.separator + keylistFileId;
	return common.Comm.isKeylistExists(filename);
}
void writeKeys(String keylistFileId, ArrayList<String> list)
{
    String filename = getServletContext().getRealPath("")
                + java.io.File.separator + "work" + java.io.File.separator + keylistFileId;
	common.Comm.writeKeys(filename, list);
}
ArrayList<String> readKeys(String keylistFileId)
{
    String filename = getServletContext().getRealPath("")
                + java.io.File.separator + "work" + java.io.File.separator + keylistFileId;
	return common.Comm.readKeys(filename);
}


%>
