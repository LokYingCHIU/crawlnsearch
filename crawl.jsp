<%@ page import="java.util.*" %>
<%@page import="java.io.*"%>
<%@ page import="my_pack.*" %>


<html>
<body>

<%
Crawler.perform_crawl_whole("https://www.cse.ust.hk/~kwtleung/COMP4321/testpage.htm", true, 300);
out.println("Finish crawling.");

%>
</body>
</html>
