# Reshaping data
# We will use the fertility wide format dataset described in Section 4.1
library(tidyverse) 
library(dslabs)
path <- system.file("extdata", package="dslabs")
filename <- file.path(path, "fertility-two-countries-example.csv")
wide_data <- read_csv(filename)
head(wide_data)
view(wide_data)
#<<<<<<<<<...........pivot_longer..........>>>>>>>>>>

new_tidy_data <- pivot_longer(wide_data, `1960`:`2015`, names_to = "year", values_to = "fertility")
head(new_tidy_data)
view(new_tidy_data)
# We can also use the pipe like this:
new_tidy_data <- wide_data %>% 
  pivot_longer(`1960`:`2015`, names_to = "year", values_to = "fertility")
# We can also use "-" to exclude the column that was not pivoted.
new_tidy_data <- wide_data %>%
  pivot_longer(-country, names_to = "year", values_to = "fertility")
view(new_tidy_data)
# The new_tidy_data object looks like the original tidy_data we defined this way
# with just one minor difference. 
data("gapminder")
tidy_data <- gapminder %>% 
  filter(country %in% c("South Korea", "Germany") & !is.na(fertility)) %>%
  select(country, year, fertility) %>%
  arrange(country)
head(tidy_data)
head(new_tidy_data)
class(tidy_data$year)
#> [1] "integer"
class(new_tidy_data$year)
#> [1] "character"
# The pivot_longer function assumes that column names are characters. 
# So we need a bit more wrangling before we are ready to make a plot. 
# We need to convert the year column to be numbers:
new_tidy_data <- wide_data %>%
  pivot_longer(-country, names_to = "year", values_to = "fertility") %>%
  mutate(year = as.integer(year))
# Now that the data is tidy, we can use this relatively simple ggplot code:
new_tidy_data %>% ggplot(aes(year, fertility, color = country)) + geom_point()

#<<<<<<<<<...........pivot_wider..........>>>>>>>>>>

new_wide_data <- new_tidy_data %>% 
  pivot_wider(names_from = year, values_from = fertility)
select(new_wide_data, country, `1960`:`1967`)

#<<<<<<<<<...........separate..........>>>>>>>>>>
# The dataset we are about to use contains two variables: 
# life expectancy and fertility. 
# The way it is stored is not tidy and not optimal.
path <- system.file("extdata", package = "dslabs")
filename <- "life-expectancy-and-fertility-two-countries-example.csv"
filename <-  file.path(path, filename)
raw_dat <- read_csv(filename)
select(raw_dat, 1:5)
view(raw_dat)
# We can start the data wrangling with the pivot_longer function, 
# but we should no longer use the column name year for the new column 
# since it also contains the variable type. 
# We will call it name, the default, for now:
dat <- raw_dat %>% pivot_longer(-country)
head(dat)
view(dat)
# Notice that the entries in this column separate 
# the year from the variable name with an underscore:
dat$name[1:5]
# the separate function takes three arguments: 
        # the name of the column to be separated, 
        # the names to be used for the new columns, and 
        # the character that separates the variables. 
dat %>% separate(name, c("year", "name"), "_")
head(dat)

var_names <- c("year", "first_variable_name", "second_variable_name")
dat %>% separate(name, var_names, fill = "right")

dat %>% separate(name, c("year", "name"), extra = "merge")

# This achieves the separation we wanted. However, we are not done yet. 
# We need to create a column for each variable. 
# As we learned, the pivot_wider function can do this:
dat %>% 
  separate(name, c("year", "name"), extra = "merge") %>%
  pivot_wider()

#<<<<<<<<<...........unite..........>>>>>>>>>>
# It is sometimes useful to do the inverse of separate,unite two columns into one.

var_names <- c("year", "first_variable_name", "second_variable_name")
dat %>% 
  separate(name, var_names, fill = "right")
# We can achieve the same final result by uniting the second and third columns, 
# then pivoting the columns and renaming fertility_NA to fertility:
dat %>% 
  separate(name, var_names, fill = "right") %>%
  unite(name, first_variable_name, second_variable_name) %>%
  pivot_wider() %>%
  rename(fertility = fertility_NA)
