#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(plotly)


# Define UI for application that draws a histogram
shinyUI(navbarPage(

      theme = shinytheme("readable"),

    # Application title
    title ="College Grad Earning Visualization Tool (USA)",
    
    ################################
    #                              #
    #   histogram tab              #
    #                              #
    ################################
    
    # Show a plot of the generated distribution
      tabPanel("Histogram View",
               p("Instruction: On the histogram, use mouse to hover your cursor on each bar. \n
                 Once completed, a pop-up box will appear and provide detailed information about the count of that segment."),
               sidebarLayout(
                 sidebarPanel(
                   width = 4,
                   sliderInput(inputId = "bin_selector", 
                               label = "Select number of bins",  ##### fixed `bins` parameter instead of `bin width` for slider widget in the histogram tab. (Kai)
                               min = 10,
                               max = 100, 
                               step = 10,
                               value = 50)
                   ,
                   # widget for x variable of histogram
                   selectInput(inputId = "x_variable", 
                               label = "x-axis Variable", 
                               choices = list("Mean Earning of students working and not enrolled 6 years after entry" = "mn_earn_wne_p6",
                                              "Mean Earning of students working and not enrolled 7 years after entry" = "mn_earn_wne_p7",
                                              "Mean Earning of students working and not enrolled 9 years after entry" = "mn_earn_wne_p9", 
                                              "Mean Earning of students working and not enrolled 10 years after entry" = "mn_earn_wne_p10"
                                              ), 
                               selected =  "mn_earn_wne_p7")
                   ,
                   # provide a reference for original data source
                   a(href="https://collegescorecard.ed.gov/data/", h5("Data Source: College Scorecard from the US Department of Education"))
                 ),
               mainPanel(
                  plotlyOutput("histogram")
                 )
               )
      ),
    
    ################################
    #                              #
    #   boxplot/scatterplot tab    #
    #                              #
    ################################
    
    
      tabPanel("Boxplot View",
               p("Instruction: On the scatter plot, use mouse to position your cursor at the beginning of points you want to highlight. \n
              Press and hold your primary mouse button. Drag the cursor to the end of the points and let go of the mouse button. \n
                 Once completed, all points within the box will give detailed information about the institution and boxplots below. Select at least four points. \n
                 On the boxplot, use mouse to hover your cursor on each box for more details on demand. \n
                 Red line = average national earning of college students ($34,196)"),
               sidebarLayout(
                 sidebarPanel(
                   width = 4,
                   sliderInput(inputId = "earning_filter",  #### fixed the slider problem as suggested
                               label = "School Selection Filter: (50 = show top 50 schools, 500 = show top 500 schools)",
                               min = 50, 
                               max = 500, 
                               sep = "",
                               step = 100,
                               value = 50)
                   ,
                   checkboxInput(inputId= "checkbox", 
                                 label = "Show all schools on scatterplot", 
                                 value = TRUE) #### check box to show all schools
                   ,
                   selectInput(inputId = "x_variable", 
                               label = "x-axis Variable", 
                               choices = list("Mean Earning 6 years after" = "mn_earn_wne_p6",
                                              "Mean Earning 7 years after" = "mn_earn_wne_p7",
                                              "Mean Earning 9 years after" = "mn_earn_wne_p9", 
                                              "Mean Earning 10 years after" = "mn_earn_wne_p10"), 
                               selected =  "mn_earn_wne_p7")
                   
                   ,
                   a(href="https://collegescorecard.ed.gov/data/", h5("Data Source: College Scorecard from the US Department of Education"))
                 ),
              mainPanel(
                  column(12,
                        plotOutput("scatterPlot", brush = brushOpts(id = "scatterplot_brush")),
              fluidRow(
                  column(width = 12, plotlyOutput("brush_plot"))
        )
      )
      )
    )
    
),
      tabPanel("Table View",
         a(href="https://collegescorecard.ed.gov/data/", h5("Data Source: College Scorecard from the US Department of Education")),
         DT::dataTableOutput('college_table')
),

################################
#                              #
#   other predictor tab        #
#                              #
################################

tabPanel("Other predictors",
         p("Instruction: On the scatterplot, use mouse to hover your cursor on point for more details on demand."),
         a(href="https://collegescorecard.ed.gov/data/", h5("Data Source: College Scorecard from the US Department of Education")),
         sidebarLayout(
           sidebarPanel(
             width = 4,
             selectInput(inputId = "x_predictor", 
                         label = "Predictor of interest", 
                         choices = list("Mean Earning 6 years after" = "mn_earn_wne_p6",
                                        "Mean Earning 7 years after" = "mn_earn_wne_p7",
                                        "Mean Earning 9 years after" = "mn_earn_wne_p9", 
                                        "Mean Earning 10 years after" = "mn_earn_wne_p10",
                                        "Poverty Rate" = "poverty_rate",
                                        "Unemployment Rate" = "unemp_rate",
                                        "Percentage of Caucasian Students" = "pct_white"
                                        ), 
                         selected =  "poverty_rate")
             
             ,
             selectInput(inputId = "y_predictor", 
                         label = "Educational Outcome Measure (y-axis)", 
                         choices = list("Mean Earning 6 years after" = "mn_earn_wne_p6",
                                        "Mean Earning 7 years after" = "mn_earn_wne_p7",
                                        "Mean Earning 9 years after" = "mn_earn_wne_p9", 
                                        "Mean Earning 10 years after" = "mn_earn_wne_p10",
                                        "Poverty Rate" = "poverty_rate",
                                        "Unemployment Rate" = "unemp_rate"
                         ), 
                         selected =  "mn_earn_wne_p10")
             ),
           mainPanel(
             column(12,
                    plotlyOutput("other_view")
                    )
           )
           )))

         
)