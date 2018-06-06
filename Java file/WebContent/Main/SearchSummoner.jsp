<%@ page language="java" contentType="text/html; charset=EUC-KR"
	pageEncoding="EUC-KR"%>
<%@ page import="java.sql.*"%>

<%
	request.setCharacterEncoding("utf-8");
%>
<%
	String name = request.getParameter("name");
	//System.out.println(name);
	Connection dbcon = null;
	//PreparedStatement pstmt = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	boolean found;
	
	String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
	String DB_USER = "hr";
	String DB_PASSWORD = "hr";

	try {
		Class.forName("oracle.jdbc.driver.OracleDriver");
	} catch (ClassNotFoundException e) {
		e.printStackTrace();
	}

	try {
		dbcon = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
		String sql = "select * from tsummoner where summonername=?";
		pstmt = dbcon.prepareStatement(sql);
		pstmt.setString(1, name);
		rs = pstmt.executeQuery();
	} catch (Exception e) {
		e.printStackTrace();
	}
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<style>
	body{
		background-color : #5CD1E5;
		background-image : url(mainimage.jpg);
		background-size : 100%;
	}
</style>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title><%=name %>의 전적정보</title>
</head>
<body>
	<%	
		if(rs.next()){
			System.out.println("found!");
			%><jsp:include page="SearchDBData.jsp" flush="false"/><%
		}else{
			System.out.println("not found");
			%><jsp:include page="SearchDataRequest.jsp" flush="false"/>
			<jsp:include page="SearchDBData.jsp" flush="flase"/><%
		}

		pstmt.close();
		rs.close();
		dbcon.close();
	%>
</body>
</html>