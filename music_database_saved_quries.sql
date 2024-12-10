/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT last_name, first_name, title, levels 
from employee
order by levels desc
limit 1

/* Q2: Which countries have the most Invoices? */

SELECT count(*) as c, billing_country
from invoice
group by billing_country
order by c desc


/* Q3: What are top 3 values of total invoice? */

SELECT total, billing_country from invoice
order by total desc


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city, sum(total) as Total_invoices 
FROM invoice
group by billing_city
order by Total_invoices desc


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/


SELECT customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total_invoice from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total_invoice desc
limit 1



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


SELECT email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by email


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


Select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track 
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */


SELECT name, milliseconds 
from track
where milliseconds > (
	select AVG(milliseconds) AS avg_track_length
	from track)

order by milliseconds desc


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */


with best_selling_artist as (
SELECT artist.artist_id as artist_id, artist.name as artist_name, 
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by 1
order by 3 desc
limit 1
)

select c.customer_id, c.first_name, c.last_name,bsa.artist_name,
sum(il.quantity*il.unit_price) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album al on al.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = al.artist_id
group by 1,2,3,4
order by 5 desc




/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


with popular_genre as (
select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
row_number() over (partition by customer.country order by count(invoice_line.quantity)desc) as row_no
from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)

select * from popular_genre where row_no <=1



/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


with recursive 
	customer_with_country as (
	select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc),

	country_max_spending as (
	select billing_country, max(total_spending) as max_spending
	from customer_with_country
	group by billing_country
	)
select cwc.billing_country, cwc.total_spending,cwc.customer_id, cwc.first_name, cwc.last_name
from customer_with_country cwc
join country_max_spending cms on cms.billing_country = cwc.billing_country
where cwc.total_spending = cms.max_spending


