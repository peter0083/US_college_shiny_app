#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)
library(plotly) # integrate plotly into the app
library(mgcv)


# load data set
college_data <- read.csv("scorecard.csv")
college_nano <- read.csv("scorecard_nano.csv")

# reduce data set to create a smaller data frame to increase speed
college_data_earning <- college_data %>% 
  select(INSTNM, STABBR, CITY, mn_earn_wne_p6, mn_earn_wne_p7, mn_earn_wne_p9, mn_earn_wne_p10) %>% 
  na.omit()

college_data_earning_table <- college_data_earning %>% 
  select_("INSTNM", "STABBR", "CITY", "mn_earn_wne_p6", "mn_earn_wne_p7", "mn_earn_wne_p9", "mn_earn_wne_p10") %>% 
  rename_("Institution" = "INSTNM",
          "State" = "STABBR",
          "Mean Earning 6 years after" = "mn_earn_wne_p6",
          "Mean Earning 7 years after" = "mn_earn_wne_p7",
          "Mean Earning 9 years after" = "mn_earn_wne_p9", 
          "Mean Earning 10 years after" = "mn_earn_wne_p10")

college_nano_earning <- college_nano %>% 
  select(INSTNM, STABBR, CONTROL, MENONLY, WOMENONLY, poverty_rate, unemp_rate, pct_white) %>% 
  na.omit()

college_nano_earning <- inner_join(college_nano_earning, college_data_earning)

# create an overall mean for income
mean_p6 <- mean(college_data_earning$mn_earn_wne_p6)
mean_p7 <- mean(college_data_earning$mn_earn_wne_p7)
mean_p9 <- mean(college_data_earning$mn_earn_wne_p9)
mean_p10 <- mean(college_data_earning$mn_earn_wne_p10)
mean_overall <- sum(mean_p6, mean_p7, mean_p9, mean_p10)/4



# Define server logic to draw plots
shinyServer(function(input, output) {
  
  #########################
  #                       #
  #   scatterplot         #
  #                       #
  #########################
  
  
  output$scatterPlot <- renderPlot({
    
    # if no filter is selected
    if (input$checkbox == TRUE) {
      
      # prep the data frame
      college_data_earning2 <- arrange_(college_data_earning, input$x_variable)
      
      # build a basic graph using ggplot2
      ggplot(data = college_data_earning2, aes_string(x = "STABBR", y= input$x_variable)) +
        geom_point(alpha = 0.2, colour = "blue") +
        ggtitle("Mean Earning of College Students in Each States") +
        labs(y = "earning", x = "states") +
        geom_hline(yintercept = mean_overall, colour = "red")
      
    } else {
      # prep the data frame
      college_data_earning2 <- arrange_(college_data_earning, input$x_variable)
      
      college_data_earning2 <- college_data_earning %>% 
        arrange_(input$x_variable) %>% 
        top_n(as.integer(input$earning_filter))
      
      ggplot(data = college_data_earning2, aes_string(x = "STABBR", y= input$x_variable)) +
        geom_point(alpha = 0.5) +
        ggtitle(paste0("Mean Earning of College Students in Each States (Selected Top ", input$earning_filter, " Institutions)")) +
        labs(y = "earning", x = "states") +
        geom_hline(yintercept = mean_overall, colour = "red")
    }
    

  })
  
  #########################
  #                       #
  #   table               #
  #                       #
  #########################
  
  # create table that is searchable

    output$college_table <- DT::renderDataTable({
    
    # college_data_earning %>% 
    #     select_("INSTNM", "STABBR", input$x_variable) %>% 
    #     arrange_(input$x_variable) %>% 
    #     rename_("Institution" = "INSTNM",
    #             "State" = "STABBR",
    #             "Earning" = input$x_variable)
    
    DT::datatable(college_data_earning_table, options = list(lengthMenu = c(5, 30, 50), pageLength = 10))
      
      
    }
    )

    #########################
    #                       #
    #   boxplot             #
    #                       #
    ######################### 

  
  # create boxplot based on brush input
  output$brush_plot <- renderPlotly({
    
    # by default, widget input and brush are null
    if (is.null(input$scatterplot_brush) & input$earning_filter == 0) {
      college_data_earning2 <- arrange_(college_data_earning, input$x_variable)
      
      college_data_earning2 <- college_data_earning %>% 
        arrange_(input$x_variable) %>% 
        select_("INSTNM", "STABBR", "CITY", input$x_variable)
      
    reactive_boxplot <- ggplot(college_data_earning2, aes_string(x = "STABBR", y = input$x_variable)) +
      geom_boxplot() +
      ggtitle("Distribution of Mean Earning of College Students in Each States") +
      labs(y = "earning", x = "states") +
      geom_hline(yintercept = mean_overall, colour = "red") +
      scale_y_continuous(labels = scales::dollar_format(prefix = '$')) #### use Sam's code to adjust scale and tick labels
    
    ggplotly(reactive_boxplot) %>% 
      layout(autosize=TRUE)
    
    # if brush is done but widget input is null
    } else if (is.null(input$scatterplot_brush) & input$earning_filter != 0) {
      college_data_earning2 <- arrange_(college_data_earning, input$x_variable)
      
      college_data_earning2 <- college_data_earning %>% 
        arrange_(input$x_variable) %>% 
        top_n(as.integer(input$earning_filter)) %>% 
        select_("INSTNM", "STABBR", "CITY", input$x_variable)
      
      reactive_boxplot2 <- ggplot(college_data_earning2, aes_string(x = "STABBR", y = input$x_variable)) +
        geom_boxplot()+
        ggtitle("Mean Earning of College Students (Selected Instutions by States)") +
        labs(y = "earning", x = "states") +
        geom_hline(yintercept = mean_overall, colour = "red") +
        scale_y_continuous(labels = scales::dollar_format(prefix = '$'))
      
      ggplotly(reactive_boxplot2) %>% 
        layout(autosize=TRUE)
    
    # if brush is done and widget input is present  
    } else {
      # go by the user's inputs on widget and brush
      college_data_earning2 <- arrange_(college_data_earning, input$x_variable)
      
      college_data_earning2 <- college_data_earning %>% 
        arrange_(input$x_variable) %>% 
        select_("INSTNM", "STABBR", "CITY", input$x_variable)
     
      data_for_table <- brushedPoints(college_data_earning2, input$scatterplot_brush)
      reactive_boxplot3 <- ggplot(data_for_table, aes_string(x = "STABBR", y = input$x_variable)) +
        geom_boxplot() +
        ggtitle("Distribution of Mean Earning of College Students (Selected Instutions by States)") +
        labs(y = "earning", x = "states") +
        geom_hline(yintercept = mean_overall, colour = "red") +
        scale_y_continuous(labels = scales::dollar_format(prefix = '$'))
      
      ggplotly(reactive_boxplot3) %>% 
        layout(autosize=TRUE)
    }
  })
  
  
  #########################
  #                       #
  #   histogram           #
  #                       #
  #########################
  
  # create histogram using ggplot2
  output$histogram <- renderPlotly({
    college_data_earning3 <- arrange_(college_data_earning, input$x_variable)
    
    ##### failed to implement the colour change reactivity :(
    
    # # setup reactive variable using lab4 tutorial by TA: Sam
    # # link: https://github.ubc.ca/ubc-mds-2016/DSCI_532_viz-2_students/blob/master/labs/lab4/reactive_programming/server.R
    # # Set colors for barplot
    # initialIncomeColors <- rep('#000000', 20)
    # names(initialIncomeColors) <- levels(college_data_earning3$input$x_variable)
    # 
    # ########
    # # Setup Object for State Plot Interactions
    # ########
    # incomePlotInteract <- reactiveValues(
    #   income = NULL,
    #   colorsOnClick = initialIncomeColors
    # )
    # 
    # # If state is clicked, set state in interaction object. Because we are
    # # executing this within observeEvent, null values of input$state_click will be
    # # ignored. You can change this behavior with `ignoreNULL = FALSE`.
    # observeEvent(input$income_click, {
    #   incomePlotInteract$income <- levels(college_data_earning3$input$x_variable)[round(input$income_click$y)]
    #   
    #   # Additionally, on every plot click reset colors to initial values. Then
    #   # specify which should be highlighted.
    #   incomePlotInteract$colorsOnClick <- initialIncomeColors
    #   incomePlotInteract$colorsOnClick[incomePlotInteract$income] <- '#FF0000'
    # }, ignoreNULL = TRUE)
    #   

    plotly_histogram <- ggplot(data = college_data_earning3, aes_string(x = input$x_variable), fill = STABBR) +
      geom_histogram(bins = as.numeric(input$bin_selector)) +
      geom_vline(xintercept = mean_overall, colour = "red") +
      ggtitle("Counts of Institutions vs Mean Earning of College Students in USA <br> Red line = average national earning of college students ($34,196)") +
      theme(axis.title.y = element_text(angle = 0, vjust = 0.5)) +
      scale_x_log10(labels = scales::dollar_format(prefix = '$'))  ### using Sam's tip
    
    ### customize font and size of x/y-axes for ggplotly
    
    f1 <- list(   
      family = "Arial, sans-serif",
      size = 18,
      color = "lightgrey"
    )
    
    f2 <- list(
      family = "Old Standard TT, serif",
      size = 14,
      color = "black"
    )
    
    xlabel_histogram <- list(
      title = "Earning",
      titlefont = f1,
      showticklabels = TRUE,
      tickangle = 0,
      tickfont = f2
    )
    
    ylabel_histogram <- list(
      title = "Count",
      titlefont = f1,
      showticklabels = TRUE,
      tickangle = 0,
      tickfont = f2
    )
    
    # deploy ggplot in plotly
    ggplotly(plotly_histogram) %>% 
      layout(xaxis = xlabel_histogram, yaxis = ylabel_histogram, showlegend = FALSE)
  })
  
  #########################
  #                       #
  #   other views         #
  #                       #
  #########################  
  output$other_view <- renderPlotly({ 
    college_nano_earning2 <- arrange_(college_nano_earning, input$x_predictor)
    
    #### plotly's boxplot did not render correctly, some parts of the plots were cut off 
    
    # 
    # 
    # if (input$x_predictor == "CONTROL" | input$x_predictor == "MENONLY" | input$x_predictor == "WOMENONLY") {
    # 
    #   plotly_scatterplot2 <- ggplot(college_nano_earning2, aes_string(x = input$x_predictor, y = input$y_predictor, fill = as.factor(input$x_predictor)) +
    #     geom_boxplot() +
    #     ggtitle(paste0(input$y_predictor, " vs ", input$x_predictor)) +
    #     labs(y = paste0(input$y_predictor), x = paste0(input$x_predictor)) +
    #     scale_x_discrete(breaks=c("-1", "0", "1", "2", "3"))
    #   
    #   f1 <- list(
    #     family = "Arial, sans-serif",
    #     size = 18,
    #     color = "lightgrey"
    #   )
    #   
    #   f2 <- list(
    #     family = "Old Standard TT, serif",
    #     size = 14,
    #     color = "black"
    #   )
    #   
    #   xlabel_scatterplot <- list(
    #     title = paste0(input$x_predictor),
    #     titlefont = f1,
    #     showticklabels = TRUE,
    #     tickangle = 0,
    #     tickfont = f2
    #   )
    #   
    #   ylabel_scatterplot <- list(
    #     title = paste0(input$y_predictor),
    #     titlefont = f1,
    #     showticklabels = TRUE,
    #     tickangle = 0,
    #     tickfont = f2
    #   )
    #   
    #   ggplotly(plotly_scatterplot2) %>% 
    #     layout(xaxis = xlabel_scatterplot, yaxis = ylabel_scatterplot, showlegend = FALSE, width = 1000)
    #   
    #   
    # } else {
    
    plotly_scatterplot2 <- ggplot(college_nano_earning2, aes_string(x = input$x_predictor, y = input$y_predictor)) +
      geom_point(alpha = 0.1) +
      ggtitle(paste0(input$y_predictor, " vs ", input$x_predictor)) +
      labs(y = paste0(input$y_predictor), x = paste0(input$x_predictor)) +
      geom_smooth(colour = "blue")
    
    f1 <- list(
      family = "Arial, sans-serif",
      size = 18,
      color = "lightgrey"
    )
    
    f2 <- list(
      family = "Old Standard TT, serif",
      size = 14,
      color = "black"
    )
    
    xlabel_scatterplot <- list(
      title = paste0(input$x_predictor),
      titlefont = f1,
      showticklabels = TRUE,
      tickangle = 0,
      tickfont = f2
    )
    
    ylabel_scatterplot <- list(
      title = paste0(input$y_predictor),
      titlefont = f1,
      showticklabels = TRUE,
      tickangle = 0,
      tickfont = f2
    )
  
    ggplotly(plotly_scatterplot2) %>% 
      layout(xaxis = xlabel_scatterplot, yaxis = ylabel_scatterplot, showlegend = FALSE, autosize = TRUE)
    # }
  })
})