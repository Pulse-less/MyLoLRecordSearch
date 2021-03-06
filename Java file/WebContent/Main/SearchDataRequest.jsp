<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Set"%>

<%@ page import="net.rithms.riot.*"%>
<%@ page import="net.rithms.riot.api.ApiConfig"%>
<%@ page import="net.rithms.riot.api.RiotApi"%>
<%@ page import="net.rithms.riot.api.RiotApiException"%>
<%@ page import="net.rithms.riot.api.endpoints.summoner.dto.Summoner"%>
<%@ page import="net.rithms.riot.constant.Platform"%>
<%@ page import="net.rithms.riot.api.endpoints.match.*"%>
<%@ page import="net.rithms.riot.api.endpoints.match.dto.Match"%>
<%@ page import="net.rithms.riot.api.endpoints.match.dto.MatchList"%>
<%@ page import="net.rithms.riot.api.endpoints.match.dto.MatchReference"%>
<%@ page import="net.rithms.riot.api.endpoints.match.dto.Participant"%>
<%@ page
	import="net.rithms.riot.api.endpoints.match.dto.ParticipantStats"%>
<%@ page import="net.rithms.riot.api.endpoints.league.*"%>
<%@ page import="net.rithms.riot.api.endpoints.league.methods.*"%>
<%@ page import="net.rithms.riot.api.endpoints.league.constant.*"%>
<%@ page import="net.rithms.riot.api.endpoints.league.dto.*"%>

<%
	request.setCharacterEncoding("utf-8");
%>
<%
	//api key 설정
	ApiConfig cfg = new ApiConfig().setKey("RGAPI-fb038d66-bb54-4179-a681-1408e1d1b23c");
	//api패스 설정
	RiotApi api = new RiotApi(cfg);
	//소환사 이름으로 소환사id값을 찾기위함
	Summoner summoner = api.getSummonerByName(Platform.KR, request.getParameter("name"));

	//소환사 정보
	String name = summoner.getName(); //소환사이름
	long acountId = summoner.getAccountId(); //계정 아이디
	long id = summoner.getId(); // 소환사 아이디
	long summonerLevel = summoner.getSummonerLevel(); //소환사 레벨
	int profileIconId = summoner.getProfileIconId(); //프로필아이콘아이디

	//최근 20경기에 대한 매치리스트
	MatchList matchList = api.getRecentMatchListByAccountId(Platform.KR, acountId);
	//리그리스트에 관련된 정보
	List<LeagueList> leagueList = api.getLeagueBySummonerId(Platform.KR, id);
	//리그포지션에 관련된 정보
	Set<LeaguePosition> leaguePosition = api.getLeaguePositionsBySummonerId(Platform.KR, id);
	//리그포지션의 경우 해쉬셋이므로 get()메소드를 사용할 수 없기때문에 어레이리스트로 바꿔서 저장하여 가져오기
	//이때 해쉬셋에 들어있는 정보는 객체.size()로 확인하기...int index = 객체.size();
	List<LeaguePosition> tempList = new ArrayList<LeaguePosition>(leaguePosition);
	//매치리스트와 관련된 레퍼런스들
	List<MatchReference> matchListRef = matchList.getMatches();
	//매치 스텟관련 정보들
	Match checkStats = api.getMatch(Platform.KR, matchListRef.get(0).getGameId());

	//소환사 티어정보
	String leagueName = tempList.get(0).getLeagueName();//리그이름
	int leaguePoints = tempList.get(0).getLeaguePoints();//리그포인트
	String rank = tempList.get(0).getRank();//현재랭크
	String tier = tempList.get(0).getTier();//현재티어
	int win = tempList.get(0).getWins();//승리횟수
	int losses = tempList.get(0).getLosses();//패배횟수

	//소환사 매치정보
	int championId = checkStats.getParticipants().get(0).getChampionId();//챔피언아이디
	int kill = checkStats.getParticipants().get(0).getStats().getKills();//킬횟수
	int death = checkStats.getParticipants().get(0).getStats().getDeaths();//죽은횟수
	int assist = checkStats.getParticipants().get(0).getStats().getAssists();//어시스트
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<style>
	body{
		background-color : #5CD1E5;
		background-image : url(mainimage.jpg);background-size : 100%;
	}
</style>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>데이터 저장 중
</title>
</head>
<body>
	<%
		Connection dbcon = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		boolean found;
		int temp=0;
		
		String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
		String DB_USER = "hr";
		String DB_PASSWORD = "hr";

		try {
			Class.forName("oracle.jdbc.driver.OracleDriver");
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}

		//참가자정보 디비삽입
		try {
			dbcon = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
			String sql = "insert into tparticipatestat(championid, kill, death, assist) values(?,?,?,?)";
			//String sql ="select * from tChampion_data";	
			pstmt = dbcon.prepareStatement(sql);
			//pstmt.setInt(1, checkStats.getParticipants().get(0).getParticipantId());
			pstmt.setInt(1, championId);
			pstmt.setInt(2, kill);
			pstmt.setInt(3, death);
			pstmt.setInt(4, assist);
			pstmt.executeUpdate();
		} catch (Exception e) {
			//e.printStackTrace();
			System.out.println("참가자정보 에러");
		}

		//소환사정보 디비삽입
		try {
			String sql = "insert into tSummoner(summonerid,accountid, summonername,summonerlevel,profileiconid) values(?,?,?,?,?)";
			pstmt = dbcon.prepareStatement(sql);
			pstmt.setLong(1, id);
			pstmt.setLong(2, acountId);
			pstmt.setString(3, name); //이름 보여주기
			pstmt.setLong(4, summonerLevel); //레벨 보여주기
			pstmt.setInt(5, profileIconId);
			pstmt.executeUpdate();
		} catch (Exception e) {
			//e.printStackTrace();
			System.out.println("소환사정보 에러");
		}

		//티어정보 디비삽입
		try {
			String sql = "insert into tTierList(Tier, Rank, Wins,Losses,LeaguePoints,LeagueName,SummonerID) values(?,?,?,?,?,?,?)";
			pstmt = dbcon.prepareStatement(sql);
			pstmt.setString(1, tier); //티어보여죽
			pstmt.setString(2, rank);
			pstmt.setInt(3, win);
			pstmt.setInt(4, losses);
			pstmt.setInt(5, leaguePoints);
			pstmt.setString(6, leagueName);
			pstmt.setLong(7, id);
			pstmt.executeUpdate();
		} catch (Exception e) {
			//e.printStackTrace();
			System.out.println("티어정보 에러");
		}
		//참가자인덱스 받아오기
		try{
			String sql = "select count(participateid) from tparticipatestat";
			pstmt = dbcon.prepareStatement(sql);
			rs = pstmt.executeQuery();
			while(rs.next()){
				temp = rs.getInt("count(participateid)");
			}
		}catch(Exception e){}
		
		//매치리스트 디비삽입
		try {
			String sql = "insert into tMatchlist(matchid,totalgames,ParticipateID,SummonerID) values(?,?,?,?)";
			pstmt = dbcon.prepareStatement(sql);
			pstmt.setLong(1, matchListRef.get(0).getGameId());
			pstmt.setInt(2, matchList.getTotalGames());
			pstmt.setInt(3, temp);
			pstmt.setLong(4, id);
			pstmt.executeUpdate();
		} catch (Exception e) {
			//e.printStackTrace();
			System.out.println("매치리스트 에러");
		}

		pstmt.close();
		rs.close();
		dbcon.close();
	%>

</body>
</html>