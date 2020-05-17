# https://www.datacamp.com/community/tutorials/sqlite-in-r

# install.packages("RSQLite")
library(RSQLite)

data("mtcars")
mtcars$car_names <- rownames(mtcars)
head(mtcars)

# Creating a connection to our new database CarsDB.db
# The .db file is created in working directory
connection <- dbConnect(RSQLite::SQLite(), "CarsDB.db")

dbWriteTable(connection, "cars_data", mtcars)
dbListTables(connection)

# Create toy data frames
car <- c('Camaro', 'California', 'Mustang', 'Explorer')
make <- c('Chevrolet','Ferrari','Ford','Ford')
df1 <- data.frame(car, make)
car <- c('Corolla', 'Lancer', 'Sportage', 'XE')
make <- c('Toyota','Mitsubishi','Kia','Jaguar')
df2 <- data.frame(car,make)

# Add data frames to a list
dfList <- list(df1, df2)

# Write a table by appending the data frames inside the list
for(k in 1:length(dfList)){
  dbWriteTable(connection,"Cars_and_Makes", dfList[[k]], append = TRUE)
}

dbListTables(connection)

# Make sure all the data is in the new table
# * means every column
dbGetQuery(connection, "SELECT * FROM Cars_and_Makes")

# Gather the first 10 rows in the cars_data table
dbGetQuery(connection, "SELECT * FROM cars_data LIMIT 10")

# Get the car names and horsepower of the cars with 8 cylinders
dbGetQuery(connection, "SELECT car_names, hp FROM cars_data WHERE cyl = 8")

# Get the car names and horsepower starting with M that have 6 or 8 cylinders
dbGetQuery(connection, "SELECT car_names, hp FROM cars_data WHERE car_names LIKE 'M%' AND cyl IN (6,8)")

# Get the average horsepower and mpg by number of cylinder groups
dbGetQuery(connection, "SELECT cyl, AVG(hp) AS 'average_hp', AVG(mpg) AS 'average_mpg' FROM cars_data
                 GROUP BY cyl
                 ORDER BY average_hp")


# You can assign results of a query to a variable
avg_HpCyl <- dbGetQuery(connection,"SELECT cyl, AVG(hp) AS 'average_hp'FROM cars_data
                 GROUP BY cyl
                 ORDER BY average_hp")
avg_HpCyl
# Data frame
class(avg_HpCyl)

# Using variables in R workspace (parameterized query)
# params() takes a list or a vector
# Selecting cars with over 18 mpg and more than 6 cylinders
mpg <-  18
cyl <- 6
Result <- dbGetQuery(connection, 'SELECT car_names, mpg, cyl FROM cars_data WHERE mpg >= ? AND cyl >= ?', params = c(mpg,cyl))
Result

# Deleting, updating, inserting
# Visualize the table before deletion
dbGetQuery(connection, "SELECT * FROM cars_data LIMIT 10")
# Delete the column belonging to the Mazda RX4. You will see a 1 as the output.
dbExecute(connection, "DELETE FROM cars_data WHERE car_names = 'Mazda RX4'")
# Visualize the new table after deletion
dbGetQuery(connection, "SELECT * FROM cars_data LIMIT 10")


# Insert the data for the Mazda RX4. This will also ouput a 1
dbExecute(connection, "INSERT INTO cars_data VALUES (21.0,6,160.0,110,3.90,2.620,16.46,0,1,4,4,'Mazda RX4')")
# See that we re-introduced the Mazda RX4 succesfully at the end
dbGetQuery(connection, "SELECT * FROM cars_data")

# Close the database connection to CarsDB
dbDisconnect(connection)


