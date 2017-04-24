# US_college_shiny_app
a visualization exercise using R Shiny app

This project is to create an interactive shiny app with the provided College Scorecard dataset from the US Board of Education, allowing the user to explore this dataset with the intent of identifying which attributes are predictors of educational success or failure.

Link to shiny app: https://peter0083.shinyapps.io/collegevizmk2/

update log:

**Apr 16th, 2017**


The list of suggestions I gathered from three peer review feedbacks by rank of frequency and importance.

> Fix the slider widget for my boxplot/scatterplot tab. The slider widget for the scatterplot of state vs earnings is misleading. The 0 value on the slider should probably show no schools, and maybe just have a checkbox for “show all schools”. The increments of school filtering is a little too specific. Differences between 450 and 500 school are not significant. You could instead use increments of 100 or even 200. (Fran and Kai mentioned this issue)

The most important design feature I must address is the slider widget for my scatterplot. It caused a lot of confusion among users. I would consider this widget as a bad design that compromised usability. The slider widget is intuitive when its max and min are clearly defined. ie. 0 for no school showing and 500 for top 500 schools showing. My original design has 0 for all school and 500 for top 500 schools. I did it this way to minimize the clutter of the sidebar but I tried to combine two functionalities into one widget. It did not work.

> Remove histogram outliers on the higher end of x-axis (Fran and Sam)

I did notice this problem in my original design that my histograms are skews to the right and leaving a lot of empty space on the right side of the graph. It is not very appealing visually. I thought about removing the outliers as well but I did not want to leave out the outlier because outlier is actually important in this visualization tool. I designed this app to help students and parents to discover the schools that give the highest earnings.

> Choose bins parameter instead of bin width for slider widget in the histogram tab. (Kai)

I would like to thank Kai for pointing it out. I wanted to have number of bins instead of bin width but I made this mistake without realizing it when I design my shiny app. I kept thinking that bin width would give me the same effect I wanted for bins. Again, a bad usability issue that did not achieve what I wanted.

> Add more variables/predictors (Subi and Kai)

In previous edition, I was debating if I could include more predictors/variables. I decided to drop many other important variables because I did not find them useful in answering the questions after interviewing some possible users. After discussing with Subi, I realized that some of the useful variables were present in the nano.csv instead of the original .csv file. I will incorporate more variables for this update.

> Boxplot/table tab is too busy and users are not sure if all the states are present in the boxplot below. (Fran and Kai)

I also realized that it would be too busy to have a side bar, a table and two plots all in one screen with my layout design. I will move the table to another tab.

> Aggregate the table and show only the top states to avoid extensively long table when highlight points using a brush function. (Subi and Kai)

This suggestion will be incorporated by moving the table to another tab.

**Apr 9th, 2017**

The rationale for design choice: The raw data contains many different variables related to earning. Some variables such as "meaning of earnings of male students working and not enrolled 10 years after entry" are too specific and users may find these variables confusing. Adding detailed explanation of these variables will take up valuable screen space. This visualization tool includes more general variables that are gender neutral. Three plots and one table cannot fit into one screen. Tab panels and sidebar layout in combination maximize the screen space. The goal is to provide an overview with the first histogram tab. The users will be able to have an overview of the earning distribution using data aggregation technique. The histogram is an example that shows the distribution of items (number/count of institutions) within an original attribute (earning). Users can adjust the bin width using the slider widget. The choice of bin size will affect the distribution quite significantly because bin sizes will result in different income classification. In the boxplot/table tab, a master scatterplot is on top. Users can use the slider widget and the select input widget to filter out top intuitions with high earnings or use your mouse to brush/highlight points of interest on this master scatter plot. The master plot is unidirectionally linked to the table and boxplot below. Without highlighting, the master plot provides information for the top 50 schools. The table and boxplot give a more detailed information about the name, location, earning and distribution on demand.

In the histogram tab, a "ggmap"" heat map linked to the histogram will definitely help the users visualize the locations of institutions and the respective earning. The latitude and longitude variables are not present in the raw data set. I tried to use the "geocode()"" function but it limits to 2500 data points daily for non-commercial users. Lack of an informative heatmap results in unused screen space in the histogram tab
