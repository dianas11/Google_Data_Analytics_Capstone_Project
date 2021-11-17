
Alter Table	[capstone].[dbo].[sept_2020] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[sept_2020] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[oct_2020] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[oct_2020] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[nov_2020] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[nov_2020] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[dec_2020] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[dec_2020] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[jan_2021] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[jan_2021] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[feb_2021] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[feb_2021] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[march_2021] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[march_2021] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[april_2021] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[april_2021] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[may_2021] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[may_2021] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[june_2021] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[june_2021] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[july_2021] alter Column start_station_id nvarchar(255)
Alter Table	[capstone].[dbo].[july_2021] alter Column end_station_id nvarchar(255)

Alter Table	[capstone].[dbo].[aug_2021] alter Column start_station_id nvarchar(255) 
Alter Table	[capstone].[dbo].[aug_2021] alter Column end_station_id nvarchar(255)


-------------------------------COMBINING ALL TABLES-----------------------------------
DROP TABLE IF EXISTS yearly_data;
SELECT * INTO yearly_data
FROM
(
SELECT *
FROM [capstone].[dbo].[sept_2020]
UNION ALL
SELECT *
FROM [capstone].[dbo].[oct_2020]
UNION ALL
SELECT *
FROM [capstone].[dbo].[nov_2020]
UNION ALL
SELECT *
FROM [capstone].[dbo].[dec_2020]
UNION ALL
SELECT *
FROM [capstone].[dbo].[jan_2021]
UNION ALL
SELECT *
FROM [capstone].[dbo].[feb_2021]
UNION ALL
SELECT *
FROM [capstone].[dbo].[march_2021]
UNION ALL
SELECT *
FROM [capstone].[dbo].[april_2021]
UNION ALL
SELECT *
FROM [capstone].[dbo].[may_2021]
UNION ALL
SELECT *
FROM [capstone].[dbo].[june_2021]
UNION ALL
SELECT *
FROM [capstone].[dbo].[july_2021]
UNION ALL
SELECT *
FROM [capstone].[dbo].[aug_2021]
) AS A

SELECT *
FROM yearly_data;


-------------------------------------REMOVING NULL VALUES--------------------------------------

DROP TABLE IF EXISTS null_cleaned;
GO
SELECT * INTO null_cleaned 
FROM
(
SELECT * FROM yearly_data
WHERE start_station_name <> '' 
			AND end_station_name <> ''
		        AND start_station_id <> ''
				    AND end_station_id <> ''
					    AND start_lat <> ''
						    AND start_lng <> ''
							    AND end_lat <> ''
								   AND end_lng <> ''
) AS B
SELECT * FROM null_cleaned




-----------------------CLEANING STATION NAMES AND FINDING RIDES WITH TOTAL_MINUTES >=1---------------------------------------


DROP TABLE IF EXISTS final_data;
GO
SELECT * INTO final_data 
FROM (

SELECT DISTINCT ride_id, rideable_type AS bike_type, started_at, ended_at, total_minutes, week_day, 
TRIM(REPLACE
		(REPLACE
			(start_station_name, '(*)',''),
				'(TEMP)','')) AS start_station_name_clean, 
TRIM(REPLACE
		(REPLACE
			(end_station_name, '(*)',''),
				'(TEMP)','')) AS end_station_name_clean, start_lat, end_lat, start_lng, end_lng, member_casual AS user_type
FROM null_cleaned
WHERE (start_station_name NOT LIKE '%(LBS-WH-TEST)%' 
      AND end_station_name NOT LIKE '%(LBS-WH-TEST)%')
	  AND len(ride_id)=16 AND total_minutes >= 1
) AS C
SELECT * FROM final_data





------------------------------------------ANALYSIS PART---------------------------------------------------------------------------


---------------------------------------RIDES BY MONTHS, USER TYPE AND BIKE TYPE---------------------------------------------------------



SELECT DISTINCT DATEADD(MONTH, DATEDIFF(MONTH, 0, started_at), 0) AS year_month,
		bike_type,
		user_type,
		COUNT(*) AS no_of_rides
	FROM final_data
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, started_at), 0), bike_type, user_type



------------------------------------------RIDES BY MONTH--------------------------------------------------------------------------------


SELECT DISTINCT DATEADD(MONTH, DATEDIFF(MONTH, 0, started_at), 0) AS year_month,
		COUNT(*) AS no_of_rides
	FROM final_data
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, started_at), 0)







---------------------------------------CASUAL RIDES BY MONTH--------------------------------------------------------------------------


SELECT DISTINCT DATEADD(MONTH, DATEDIFF(MONTH, 0, started_at), 0) AS year_month,
		COUNT(*) AS no_of_rides
		FROM final_data
		WHERE user_type = 'casual'
		GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, started_at), 0)


---------------------------------------MEMBER RIDES BY MONTH-------------------------------------------------------------------------


SELECT DISTINCT DATEADD(MONTH, DATEDIFF(MONTH, 0, started_at), 0) AS year_month,
		COUNT(*) AS no_of_rides
		FROM final_data
		WHERE user_type = 'member'
		GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, started_at), 0)


----------------------------------------RIDES BY SEASON-------------------------------------------------------------------------------

Select Distinct DATENAME(mm,started_at) as Month, COUNT(started_at) as number_of_rides, user_type,
(Case
	When DATENAME(mm,started_at) like 'January' or
	DATENAME(mm,started_at) like 'February' or 
	DATENAME(mm,started_at) like 'December' then 'Winter'
	When DATENAME(mm,started_at) like 'March' or
	DATENAME(mm,started_at) like 'April' or 
	DATENAME(mm,started_at) like 'May' then 'Spring'
	When DATENAME(mm,started_at) like 'June' or
	DATENAME(mm,started_at) like 'July' or 
	DATENAME(mm,started_at) like 'August' then 'Summer'
	When DATENAME(mm,started_at) like 'September' or
	DATENAME(mm,started_at) like 'October' or 
	DATENAME(mm,started_at) like 'November' then 'Autumn'
end) as season
From final_data
Group by user_type, DATENAME(mm,started_at),(Case
	When DATENAME(mm,started_at) like 'January' or
	DATENAME(mm,started_at) like 'February' or 
	DATENAME(mm,started_at) like 'December' then 'Winter'
	When DATENAME(mm,started_at) like 'March' or
	DATENAME(mm,started_at) like 'April' or 
	DATENAME(mm,started_at) like 'May' then 'Spring'
	When DATENAME(mm,started_at) like 'June' or
	DATENAME(mm,started_at) like 'July' or 
	DATENAME(mm,started_at) like 'August' then 'Summer'
	When DATENAME(mm,started_at) like 'September' or
	DATENAME(mm,started_at) like 'October' or 
	DATENAME(mm,started_at) like 'November' then 'Autumn'
end)

ORDER BY number_of_rides



--------------------------------------------RIDES BY WEEKDAYS----------------------------------------------------------------

SELECT week_day, COUNT(*) as Total_Rides_by_weekday
FROM final_data
GROUP  BY week_day
ORDER  BY COUNT(*) DESC

--------------------------------------------CASUAL RIDES BY WEEKDAYS---------------------------------------------------------

SELECT week_day, COUNT(*) as Casual_rides_by_days
FROM final_data
WHERE user_type = 'casual'
GROUP BY week_day
ORDER BY COUNT(*) DESC

---------------------------------------------MEMBER RIDES BY DAY OF WEEK--------------------------------------------------------

SELECT week_day, COUNT(*) as Member_rides_by_days
FROM final_data
WHERE user_type = 'member'
GROUP BY week_day
ORDER BY COUNT(*) DESC


--------------------------------------------RIDES BY DAY OF WEEK AND TIME------------------------------------------

Select Distinct week_day, COUNT(week_day) as number_of_rides, user_type, (Case
	When Cast(started_at as time) >= '06:00' and Cast(started_at as time) < '12:00' Then 'Morning'
	When Cast(started_at as time) >= '12:00' and Cast(started_at as time) < '17:00' Then 'Afternoon'
	When Cast(started_at as time) >= '17:00' and Cast(started_at as time) < '20:00' Then 'Evening'
	Else 'Night'
End) as time_of_day
From final_data
Group by week_day, user_type,(Case
	When Cast(started_at as time) >= '06:00' and Cast(started_at as time) < '12:00' Then 'Morning'
	When Cast(started_at as time) >= '12:00' and Cast(started_at as time) < '17:00' Then 'Afternoon'
	When Cast(started_at as time) >= '17:00' and Cast(started_at as time) < '20:00' Then 'Evening'
	Else 'Night'
End)
Order by week_day


----------------------------------------RIDES BY MONTH AND TIME-------------------------------------------

Select Distinct  DATENAME(mm,started_at) as Month_name , COUNT(week_day) as number_of_rides, user_type, (Case
	When Cast(started_at as time) >= '06:00' and Cast(started_at as time) < '12:00' Then 'Morning'
	When Cast(started_at as time) >= '12:00' and Cast(started_at as time) < '17:00' Then 'Afternoon'
	When Cast(started_at as time) >= '17:00' and Cast(started_at as time) < '20:00' Then 'Evening'
	Else 'Night'
End) as time_of_day
From final_data
Group by DATENAME(mm,started_at), user_type,(Case
	When Cast(started_at as time) >= '06:00' and Cast(started_at as time) < '12:00' Then 'Morning'
	When Cast(started_at as time) >= '12:00' and Cast(started_at as time) < '17:00' Then 'Afternoon'
	When Cast(started_at as time) >= '17:00' and Cast(started_at as time) < '20:00' Then 'Evening'
	Else 'Night'
End)
Order by Month_name



---------------------------------------RIDES BY WEEKDAYS AND WEEKENDS-----------------------------------------

Select Distinct week_day,  COUNT(week_day) as number_of_rides, user_type,
(Case
	When week_day = 'Saturday' or  week_day = 'Sunday' then 'Weekend'
	Else 'Weekday'
	end) as Weekday_Weekend
From final_data
Group by week_day, user_type, (Case
	When week_day = 'Saturday' or week_day = 'Sunday' then 'Weekend'
	Else 'Weekday'
	end)
Order by week_day


---------------------------------RIDES TAKEN BY CASUAL RIDERS ON WEEKDAYS AND WEEKENDS--------------------------------------

Select Distinct week_day,  COUNT(week_day) as number_of_rides, 
(Case
	When week_day = 'Saturday' or  week_day = 'Sunday' then 'Weekend'
	Else 'Weekday'
	end) as Weekday_Weekend
From final_data
WHERE user_type = 'casual'
Group by week_day,  (Case
	When week_day = 'Saturday' or week_day = 'Sunday' then 'Weekend'
	Else 'Weekday'
	end)
Order by week_day


---------------------------------RIDES TAKEN BY MEMBER RIDERS ON WEEKDAYS AND WEEKENDS--------------------------------------

Select Distinct week_day,  COUNT(week_day) as number_of_rides, 
(Case
	When week_day = 'Saturday' or  week_day = 'Sunday' then 'Weekend'
	Else 'Weekday'
	end) as Weekday_Weekend
From final_data
WHERE user_type = 'member'
Group by week_day,  (Case
	When week_day = 'Saturday' or week_day = 'Sunday' then 'Weekend'
	Else 'Weekday'
	end)
Order by week_day


---------------------------------------RIDES BY TYPE OF BIKE--------------------------------------------------------------


SELECT bike_type, COUNT(ride_id) as number_of_rides
FROM final_data
GROUP BY bike_type


-----------------------------------------RIDES BY BIKE TYPE AND USER TYPE---------------------------------------------------


SELECT bike_type, COUNT(ride_id) as number_of_rides, user_type
FROM final_data
GROUP BY bike_type, user_type


--------------------------------------- RIDES BY USER TYPE------------------------------------------------------------------


SELECT user_type, COUNT(ride_id) as number_of_rides
FROM final_data
GROUP BY user_type


----------------------------------------RIDE TYPE BY USER TYPE--------------------------------------------------------------


Select bike_type, 
       COUNT(bike_type) as number_of_rides, 
       user_type
FROM final_data
Group by bike_type, user_type;


--------------------------------AVG RIDE_LENGTH BY USER TYPE------------------------------------------------


SELECT user_type, AVG(CAST(Total_Minutes AS int)) as Ride_length
FROM final_data
GROUP BY user_type
ORDER BY Ride_length


--------------------------------AVG RIDE_LENGTH BY BIKE TYPE----------------------------------------
SELECT bike_type, AVG(CAST(Total_Minutes AS int)) as Ride_length
FROM final_data
GROUP BY bike_type
ORDER BY Ride_length



-------------------------------------DEPARTING STATIONS--------------------------------

With casual_departing_station AS
(
SELECT COUNT(user_type) as Casual, start_station_name_clean
FROM final_data
WHERE user_type = 'casual'
GROUP BY start_station_name_clean

), member_departing_station AS

( 
SELECT COUNT(user_type) as Member, start_station_name_clean
FROM final_data
WHERE user_type = 'member' 
GROUP BY start_station_name_clean

), departing_from_station AS 

( 
SELECT cds.start_station_name_clean, Casual, Member
FROM casual_departing_station AS cds
JOIN member_departing_station AS mds
ON cds.start_station_name_clean = mds.start_station_name_clean

), depart_lat_lng AS 
(
SELECT DISTINCT start_station_name_clean, ROUND(AVG(start_lat),4) AS dep_lat, Round(AVG(start_lng),4) AS dep_lng
	FROM final_data
	GROUP BY start_station_name_clean
)
SELECT ds.start_station_name_clean, ds.Casual, ds.Member, dl.dep_lat, dl.dep_lng
FROM
departing_from_station AS ds
JOIN depart_lat_lng AS dl
ON ds.start_station_name_clean = dl.start_station_name_clean



---------------------------------------------ARRIVING STATIONS---------------------------------------

With casual_arriving_station AS
(
SELECT COUNT(user_type) as Casual, end_station_name_clean
FROM final_data
WHERE user_type = 'casual'
GROUP BY end_station_name_clean

), member_arriving_station AS

( 
SELECT COUNT(user_type) as Member, end_station_name_clean
FROM final_data
WHERE user_type = 'member' 
GROUP BY end_station_name_clean

), arriving_at_station AS 

( 
SELECT cas.end_station_name_clean, Casual, Member
FROM casual_arriving_station AS cas
JOIN member_arriving_station AS mas
ON cas.end_station_name_clean = mas.end_station_name_clean

), arriving_lat_lng AS 
(
SELECT DISTINCT end_station_name_clean, ROUND(AVG(end_lat),4) AS arrive_lat, Round(AVG(end_lng),4) AS arrive_lng
	FROM final_data
	GROUP BY end_station_name_clean
)
SELECT ats.end_station_name_clean, ats.Casual, ats.Member, al.arrive_lat, al.arrive_lng
FROM
arriving_at_station AS ats
JOIN arriving_lat_lng AS al
ON ats.end_station_name_clean = al.end_station_name_clean
