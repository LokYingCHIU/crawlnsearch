<%@ page import="java.util.*" %>
<%@page import="java.io.*"%>
<%@ page import="my_pack.*" %>


<html>
<body>

<%
if(request.getParameter("query")!="")
{
    out.println("The query you entered is:");
    out.println("<br>");
    String input = request.getParameter("query");
    out.println(input);
    out.println("<br>");
    out.println("<br>");
    out.println("Below are the relevant pages:");
    out.println("<br>");
    out.println("<br>");
    Vector<Vector<String>> rank = Search.search(input);
    for (Vector<String> ps: rank) {
        int i = 0;
        String plink = ps.get(2);
        for (String info: ps) {
            if ( i==1 || i==2){
                %><a href="<%= plink %>"><%= info %></a><%
            }
            else {
                out.println(info);
            }
            out.println("<br>");
            i += 1;
        }
        out.println("<br>");
    }

}
else
{
	out.println("You input nothing");
}

%>
</body>
</html>
