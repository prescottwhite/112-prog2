% Program 2 - Airline Reservation System
% Instructor: Charlie McDowell
% Student: Prescott White, prgwhite@ucsc.edu
:- use_module(library(lists)).


airport( atl, 'Atlanta         ', degmin(  33,39 ), degmin(  84,25 ) ).
airport( bos, 'Boston-Logan    ', degmin(  42,22 ), degmin(  71, 2 ) ).
airport( chi, 'Chicago         ', degmin(  42, 0 ), degmin(  87,53 ) ).
airport( den, 'Denver-Stapleton', degmin(  39,45 ), degmin( 104,52 ) ).
airport( dfw, 'Dallas-Ft.Worth ', degmin(  32,54 ), degmin(  97, 2 ) ).
airport( lax, 'Los Angeles     ', degmin(  33,57 ), degmin( 118,24 ) ).
airport( mia, 'Miami           ', degmin(  25,49 ), degmin(  80,17 ) ).
airport( nyc, 'New York City   ', degmin(  40,46 ), degmin(  73,59 ) ).
airport( sea, 'Seattle-Tacoma  ', degmin(  47,27 ), degmin( 122,17 ) ).
airport( sfo, 'San Francisco   ', degmin(  37,37 ), degmin( 122,23 ) ).
airport( sjc, 'San Jose        ', degmin(  37,22 ), degmin( 121,56 ) ).


flight( bos, nyc, time( 7,30 ) ).
flight( dfw, den, time( 8, 0 ) ).
flight( atl, lax, time( 8,30 ) ).
flight( chi, den, time( 8,45 ) ).
flight( mia, atl, time( 9, 0 ) ).
flight( sfo, lax, time( 9, 0 ) ).
flight( sea, den, time( 10, 0 ) ).
flight( nyc, chi, time( 11, 0 ) ).
flight( sea, lax, time( 11, 0 ) ).
flight( den, dfw, time( 11,15 ) ).
flight( sjc, lax, time( 11,15 ) ).
flight( atl, lax, time( 11,30 ) ).
flight( atl, mia, time( 11,30 ) ).
flight( chi, nyc, time( 12, 0 ) ).
flight( lax, atl, time( 12, 0 ) ).
flight( lax, sfo, time( 12, 0 ) ).
flight( lax, sjc, time( 12, 15 ) ).
flight( nyc, bos, time( 12,15 ) ).
flight( bos, nyc, time( 12,30 ) ).
flight( den, chi, time( 12,30 ) ).
flight( dfw, den, time( 12,30 ) ).
flight( mia, atl, time( 13, 0 ) ).
flight( sjc, lax, time( 13,15 ) ).
flight( lax, sea, time( 13,30 ) ).
flight( chi, den, time( 14, 0 ) ).
flight( lax, nyc, time( 14, 0 ) ).
flight( sfo, lax, time( 14, 0 ) ).
flight( atl, lax, time( 14,30 ) ).
flight( lax, atl, time( 15, 0 ) ).
flight( nyc, chi, time( 15, 0 ) ).
flight( nyc, lax, time( 15, 0 ) ).
flight( den, dfw, time( 15,15 ) ).
flight( lax, sjc, time( 15,30 ) ).
flight( chi, nyc, time( 18, 0 ) ).
flight( lax, atl, time( 18, 0 ) ).
flight( lax, sfo, time( 18, 0 ) ).
flight( nyc, bos, time( 18, 0 ) ).
flight( sfo, lax, time( 18, 0 ) ).
flight( sjc, lax, time( 18,15 ) ).
flight( atl, mia, time( 18,30 ) ).
flight( den, chi, time( 18,30 ) ).
flight( lax, sjc, time( 19,30 ) ).
flight( lax, sfo, time( 20, 0 ) ).
flight( lax, sea, time( 22,30 ) ).


% FINDING FLIGHTS
fly(A, B) :- A \= B,
	flyHelper(A, B, 0, 0, []).
	
flyHelper(From, To, PrevHr, PrevMin, L) :- flight(From, To, time(DepartHr, DepartM)),
	later30(PrevHr, PrevMin, DepartHr, DepartM),
	append(L, [From, To, DepartHr, DepartM], List),
	buildTrip(List).
	
flyHelper(From, To, PrevHr, PrevMin, L) :- flight(From, X, time(DepartHr, DepartM)),
	getArrival(From, X, DepartHr, DepartM, ArriveHr, ArriveM),
	later30(PrevHr, PrevMin, DepartHr, DepartM),
	append(L, [From, X, DepartHr, DepartM], List),
	flyHelper(X, To, ArriveHr, ArriveM, List).


% DISTANCE CALCULATIONS
getRads(Deg, Min, Result) :- Result is (Deg + (Min / 60)) * (pi/180).

getDist(City1, City2, Result) :- airport(City1, _, degmin(DegX1, MinX1), degmin(DegY1, MinY1)),
	airport(City2, _, degmin(DegX2, MinX2), degmin(DegY2, MinY2)),
	getDistH(DegX1, MinX1, DegY1, MinY1, DegX2, MinX2, DegY2, MinY2, Result).
	
getDistH(DegX1, MinX1, DegY1, MinY1, DegX2, MinX2, DegY2, MinY2, Result) :- getRads(DegX2, MinX2, Lat2),
	getRads(DegX1, MinX1, Lat1),
	getRads(DegY2, MinY2, Lon2),
	getRads(DegY1, MinY1, Lon1),
	Result is 3956 * (2 * atan2(sqrt(((sin((Lat2 - Lat1)/2))^2 + (cos(Lat1) * cos(Lat2) * (sin((Lon2 - Lon1)/2))^2))),
		sqrt(1 - ((sin((Lat2 - Lat1)/2))^2 + cos(Lat1) * cos(Lat2) * (sin((Lon2 - Lon1)/2))^2)))).


% TIME CALCULATIONS
getTime(Miles, ResultMins) :- ResultMins is round(60 * (Miles / 500)).

getArrival(City1, City2, H, M, ResultH, ResultM) :- getDist(City1, City2, Miles), getArrivalH(H, M, Miles, ResultH, ResultM).

getArrivalH(H, M, Miles, ResultH, ResultM) :- getTime(Miles, ResultMins),
	ResultH is H + floor(ResultMins / 60) + floor((M + (ResultMins mod 60)) / 60),
	ResultM is (M + (ResultMins mod 60)) mod 60.

later30(H1, M1, _, _) :- H1 == 0, M1 == 0.
later30(H1, M1, H2, M2) :- ((H2*60) + M2) >= (((H1*60) + M1) + 30).

	
% TRIP PRINTING
buildTrip([]).
buildTrip([CityA, CityB, H, M|LS]) :- buildTripHelper(CityA, CityB, H, M),
	buildTrip(LS).

buildTripHelper(CityA, CityB, H, M) :- getArrival(CityA, CityB, H, M, ResultH, ResultM),
	airport(CityA, NameA, _, _),
	airport(CityB, NameB, _, _),
	print_trip(depart, CityA, NameA, time(H, M)),
	print_trip(arrive, CityB, NameB, time(ResultH, ResultM)).
	

	
print_trip( Action, Code, Name, time( Hour, Minute)) :- 
	upcase_atom( Code, Upper_code),   format( "~6s  ~3s  ~s~26|  ~`0t~d~30|:~`0t~d~33|",
		[Action, Upper_code, Name, Hour, Minute]),
		nl.
	
	
% PROVIDED
test :-
   print_trip( depart, nyc, 'New York City', time( 9, 3)),
   print_trip( arrive, lax, 'Los Angeles', time( 14, 22)).

doSomething(nyc,lax) :- test.


% MAIN
main :- read(A),read(B), fly(A,B).