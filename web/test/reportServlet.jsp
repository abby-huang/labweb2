<%@ page pageEncoding="UTF-8" contentType="text/html"%>
<%
request.setCharacterEncoding("UTF-8");
%>

<form name="reportDispatcherForm"
        action="<%=request.getContextPath()%>/reportServlet" method="post">
<table>
        <!--  Data Model -->
        <tr>
                <td>Project (data model) :</td>
                <td><input type="text" name="name" value="黃文忠" /></td>
        </tr>
        <tr>
                <td>Nb developers (data model) :</td>
                <td><select name="nbDevelopers">
                        <option value="0">0</option>
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                        <option value="6">6</option>
                        <option value="7">7</option>
                        <option value="8">8</option>
                        <option value="9">9</option>
                        <option value="10">10</option>
                </select></td>
        </tr>
        <!--  reportId HTTP parameter -->
        <tr>
                <td>Report :</td>
                <td><select name="reportId">
                        <option value="EscNotifyList">EscNotifyList</option>
                        <option value="TestList">TestList</option>
                </select></td>
        </tr>
        <!--  converter HTTP parameter -->
        <tr>
                <td>Converter :</td>
                <td><select name="converter">
                        <option value="">-- No conversion --</option>
                        <option value="PDF_XWPF">2 PDF via IText</option>
                        <option value="XHTML_XWPF">2 XHTML via XWPF (POI)</option>
                </select></td>
        </tr>
        <!--  processState HTTP parameter -->
        <tr>
                <td>Process state :</td>
                <td><select name="processState">
                        <option value="original">original</option>
                        <option value="preprocessed">preprocessed</option>
                        <option value="generated" selected="selected">generated</option>
                </select></td>
        </tr>
        <!--  dispatch HTTP parameter -->
        <tr>
                <td>Dispatch :</td>
                <td><select name="dispatch">
                        <option value="download">download</option>
                        <option value="view">view</option>
                </select></td>
        </tr>
        <!--  entryName HTTP parameter -->
        <tr>
                <td>Entry name :</td>
                <td><select name="entryName">
                        <option value=""></option>
                        <option value="application/pdf">application/pdf</option>
                </select></td>
        </tr>
        <!-- Generate report -->
        <tr>
                <td colspan="2"><input type="submit" value="OK"></td>
        </tr>
</table>
</form>
