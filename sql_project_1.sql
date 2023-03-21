create database DB;
use DB;
drop database DB;
create table employee(employee_id int primary key ,last_name text, first_name text,title text,reports_to int, levels text , 
birthdate date,hiredate date,address text,city text,state text,country text,postal_code text, phone char(17),fax text,email text);

select * from employee;

create table customer(customer_id int primary key,first_name text,last_name text,company text,address text,city text,state text,
country text,postal_code text,phone text,fax text,email text,support_rep_id int,foreign key(support_rep_id) 
references employee(employee_id) on update cascade on delete cascade);
select * from customer;

create table invoice(invoice_id int primary key ,customer_id int ,invoice_date text,billing_address text, billing_city text,
billing_state text,billing_country text,billing_postal_code text,total double,foreign key(customer_id) 
references customer(customer_id) on update cascade on delete cascade);
select * from invoice;

create table track(track_id int primary key,name text,album_id int,media_type_id int,genre_id int,composer text,
milliseconds bigint,bytes bigint,unit_price double,
 foreign key(album_id) references album(album_id) on update cascade on delete cascade,
 foreign key(media_type_id) references media_type(media_type_id) on update cascade on delete cascade,
 foreign key(genre_id) references genre(genre_id) on update cascade on delete cascade);
 select * from track;

create table invoice_line(invoice_line_id int primary key, invoice_id int,track_id int,unit_price double,quantity int,
 foreign key(invoice_id) references invoice(invoice_id) on update cascade on delete cascade,foreign key(track_id) references
 track(track_id) on update cascade on delete cascade);
select * from invoice_line;

create table artist(artist_id int primary key,name text);
select * from artist;

create table playlist(playlist_id int primary key,name text);
select * from playlist;

create table media_type(media_type_id int primary key,name text);
select * from media_type;

create table genre(genre_id int primary key, name text);
select * from genre;

create table album(album_id int primary key,title text,artist_id int,
foreign key(artist_id) references artist(artist_id) on update cascade on delete cascade);
select * from album;

create table playlist_track(playlist_id int ,track_id int,
foreign key(playlist_id) references playlist(playlist_id) on update cascade on delete cascade,
foreign key(track_id) references track(track_id) on update cascade on delete cascade);
select * from playlist_track;
drop table playlist_track;

	
##Major Task
##Question Set 1 - Easy
##Who is the senior most employee based on job title?

select first_name,last_name,hiredate,title from employee group by first_name,last_name,hiredate,title order by  hiredate asc limit 1;


## Which countries have the most Invoices?

select billing_country,count(billing_country) as 'number of invoices' from invoice group by billing_country;

##What are top 3 values of total invoice?

select total from invoice  order by total desc limit 3;

##Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
##Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

select billing_city as 'city name',sum(total) as "maximum of invoice totals" from invoice 
group by billing_city order by sum(total) desc limit 1;

##Who is the best customer? The customer who has spent the most money will be declared the best customer. 
##Write a query that returns the person who has spent the most money

select * from invoice;
select c.* ,sum(total) as Total FROM customer as c
INNER JOIN invoice as i
ON c.customer_id = i.customer_id
GROUP BY i.customer_id order by Total desc limit 1;

##Question Set 2 – Moderate
##Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

select first_name,last_name,email from customer 
 where customer_id in (select customer_id from invoice
 where invoice_id in (select invoice_id from invoice_line
 where track_id in (select track_id from track 
 where genre_id=(select genre_id from genre 
 where name = 'Rock')))) order by email ;

##Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

 select a.name,COUNT(t.name) from track t
  inner join genre g ON t.genre_id = g.genre_id
  inner join album al ON al.album_id = t.album_id
  inner join artist a ON a.artist_id = al.artist_id
  where g.name='Rock' group by 1 order by 2 desc limit 10;

##Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track.
## Order by the song length with the longest songs listed first

with cte as (select avg(milliseconds) as avg from track) 
select name,milliseconds from track,cte where milliseconds > cte.avg order by milliseconds desc;

##Question Set 3 – Advance
##Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

select concat(c.first_name," ",c.last_name) as customer_name,a.name,sum(il.unit_price) as total_spent from customer as c 
inner join invoice as i using(customer_id) inner join invoice_line as il using(invoice_id) inner join track as t using(track_id) 
inner join album as al using(album_id) inner join artist as a  using(artist_id) group by a.name,c.customer_id;

##We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
##Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

with cte as (select i.billing_country,g.name,sum(i.total) as purchase_amount,
dense_rank() over(partition by i.billing_country order by sum(i.total) desc)  as a
 from invoice as i  inner join invoice_line as il using(invoice_id) inner join track as t using(track_id)
 inner join genre as g using(genre_id) group by i.billing_country,g.name)
 select billing_country,name,purchase_amount  from cte where a=1 ;
 
 ##Write a query that determines the customer that has spent the most on music for each country.
 ##Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared,
 ##provide all customers who spent this amount
 
 with cte as (select i.billing_country,c.customer_id,sum(i.total) as purchase_amount,
dense_rank() over(partition by i.billing_country order by sum(i.total) desc)  as a
 from customer as c inner join  invoice as i using(customer_id) group by i.billing_country,c.customer_id)
 select billing_country,customer_id,purchase_amount from cte where a=1  ;








