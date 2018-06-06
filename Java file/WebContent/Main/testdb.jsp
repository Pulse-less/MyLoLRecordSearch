<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
    <%@ page import="java.sql.*" %>
    <%
    	Connection dbcon = null;
    	Statement stmt = null;
    	ResultSet rs = null;
    	
    	String DB_URL="jdbc:oracle:thin:@localhost:1521:xe";
    	String DB_USER="hr";
    	String DB_PASSWORD="hr";
    	
    	try{
    		Class.forName("oracle.jdbc.driver.OracleDriver");
    	}catch(ClassNotFoundException e){
    		e.printStackTrace();
    	}
    	
    	dbcon=DriverManager.getConnection(DB_URL,DB_USER,DB_PASSWORD);
    	stmt=dbcon.createStatement();
    	rs=stmt.executeQuery("select employee_id from employees");
    %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Insert title here</title>
</head>
<body>
<%
	if(rs!=null){
		while(rs.next()){
			String employee_id = rs.getString(1);
			System.out.println(employee_id);
		}
	}
stmt.close();
rs.close();
dbcon.close();
	%>
</body>
</html>