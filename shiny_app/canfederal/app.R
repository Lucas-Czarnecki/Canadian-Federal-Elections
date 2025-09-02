# Load packages
if(!require(pacman)) install.packages("pacman")
pacman::p_load(shiny, shinythemes, dplyr, readr, here, ggplot2, ggthemes)

# Path to data
data_path <- here::here("data", "cleaned", "master", "FED_1867_present.rds")

# Load data
fed_data <- read_rds(data_path)

# Main political parties 
main_parties <- c(
    "Conservative Party of Canada",
    "New Democratic Party",
    "Progressive Conservative Party",
    "Reform Party of Canada",
    "Green Party of Canada",
    "Liberal Party of Canada",
    "Bloc Québécois",
    "Conservative (1867-1942)",
    "Liberal-Conservative",
    "Anti-Confederate",
    "Unknown"
)


# UI ----
ui <- fluidPage(
    theme = shinytheme("slate"),
    titlePanel("🍁 Canadian Federal Elections"),
    
    sidebarLayout(
        sidebarPanel(
            selectInput(
                "election_type",
                "Select Election Type:",
                choices = sort(unique(fed_data$Election_Type)),
                selected = unique(fed_data$Election_Type)[1]
            ),
            selectInput(
                "election_date",
                "Select Election:",
                choices = sort(unique(fed_data$Election_Date), decreasing = TRUE),
                selected = max(fed_data$Election_Date)
            ),
            
            downloadButton("download_filtered_csv", "Download CSV"),
            downloadButton("download_filtered_rds", "Download RDS")
        ),
        
        mainPanel(
            uiOutput("dynamic_title"), # placeholder for reactive title
            fluidRow(
                column(6, tableOutput("summary_table")),
                column(6, plotOutput("vote_share_plot", height = "500px"))
            ),
            
            # 
            fluidRow(
                column(
                    12,
                    div(
                        style = "margin-top:20px; text-align:left;",
                        h4("Download entire dataset:"),
                        downloadButton("download_full_csv", "Download Full CSV"),
                        downloadButton("download_full_rds", "Download Full RDS")
                    )
                )
            )
        )
    )
)


# SERVER ----
server <- function(input, output, session) {
    
    # Dynamic title
    output$dynamic_title <- renderUI({
        selected_row <- fed_data %>% 
            filter(Election_Date == input$election_date) %>% 
            slice(1)  # Get the first row for that date
        
        h3(
            paste0(
                "Summary of ",
                selected_row$Election_Type,
                " Results for Parliament ",
                selected_row$Parliament,
                " (",
                selected_row$Election_Date,
                ")"
            )
        )
    })
    
    # Update election dates when type changes
    observeEvent(input$election_type, {
        filtered_dates <- fed_data %>%
            filter(Election_Type == input$election_type) %>%
            pull(Election_Date) %>%
            unique() %>%
            sort(decreasing = TRUE)
        
        updateSelectInput(
            session, "election_date",
            choices = filtered_dates,
            selected = max(filtered_dates)
        )
    })
    
    # Reactive data for selected election
    filtered_data <- reactive({
        fed_data %>%
            rename(
                `Province/Territory` = Province_Territory,
                `Election Date` = Election_Date,
                `Election Type` = Election_Type,
                `Political Affiliation` = Political_Affiliation
            ) %>%
            filter(`Election Date` == input$election_date)
    })
    
    # Summarize results by party
    output$summary_table <- renderTable({
        df <- filtered_data()
        
        valid_results <- c("Elected", "Elected (Acclamation)", "Elected (Court decision)")
        
        total_votes <- sum(df$Votes, na.rm = TRUE)
        total_seats <- sum(df$Result %in% valid_results, na.rm = TRUE)
        
        summary <- df %>%
            group_by(`Political Affiliation`) %>%
            summarise(
                `Seats Won` = sum(Result %in% valid_results),
                `Total Votes` = format(as.integer(sum(Votes, na.rm = TRUE)), big.mark ="," ),
                .groups = "drop"
            ) %>%
            mutate(
                `Vote Share (%)` = round((as.numeric(gsub(",", "", `Total Votes`)) / total_votes) * 100, 2)
            ) %>%
            arrange(desc(`Seats Won`))
        
        # Add totals row
        summary <- bind_rows(
            summary,
            tibble(
                `Political Affiliation` = "TOTAL",
                `Seats Won` = total_seats,
                `Total Votes` = format(as.integer(total_votes), big.mark=","),
                `Vote Share (%)` = round(sum(summary$`Vote Share (%)`), 0)
            )
        )
        
        summary
    })
    
    # Plot: Vote Share per Party
    output$vote_share_plot <- renderPlot({
        df <- filtered_data()
        total_votes <- sum(df$Votes, na.rm = TRUE)
        
        plot_data <- df %>%
            group_by(`Political Affiliation`) %>%
            summarise(Votes = sum(Votes, na.rm = TRUE), .groups = "drop") %>%
            rename(Party = `Political Affiliation`) %>%
            mutate(
                Vote_Share = (Votes / total_votes) * 100,
                Party = factor(Party)
            ) %>%
            arrange(desc(Vote_Share))
        
        ggplot(plot_data, aes(
            x = forcats::fct_reorder(Party, Vote_Share),
            y = Vote_Share,
            fill = Party)) +
            geom_col() +
            coord_flip() +
            labs(x = "",
                 y = "\n Vote Share (%)") +
            theme_fivethirtyeight(base_size = 10) +
            theme(
                panel.background = element_rect(fill="grey90"),
                rect = element_rect(fill = "grey90"),
                plot.background = element_rect(fill = "grey90"),
                strip.background = element_rect(fill = "grey90"),
                text = element_text(colour = "#131313"),
                axis.title = element_text(face = "bold", size = 12),
                axis.text.x = element_text(angle = 0, size = 12, vjust = 0),
                axis.text.y = element_text(angle = 0, size = 12, vjust = 0.5, hjust = 0),
                legend.position = "none",
                panel.grid.major = element_blank(),
                axis.line = element_line(colour = "#131313"),
                axis.line.y = element_blank()
            ) 
    })
    
    # Download Handlers ----
    
    # Filtered data (based on user selections)
    output$download_filtered_csv <- downloadHandler(
        filename = function() {
            paste0("filtered_data_", input$election_type, "_", input$election_date, ".csv")
        },
        content = function(file) {
            write.csv(filtered_data(), file, row.names = FALSE)
        }
    )
    
    output$download_filtered_rds <- downloadHandler(
        filename = function() {
            paste0("filtered_data_", input$election_type, "_", input$election_date, ".rds")
        },
        content = function(file) {
            saveRDS(filtered_data(), file)
        }
    )
    
    # Full dataset
    output$download_full_csv <- downloadHandler(
        filename = function() {
            "full_dataset.csv"
        },
        content = function(file) {
            write.csv(fed_data, file, row.names = FALSE)
        }
    )
    
    output$download_full_rds <- downloadHandler(
        filename = function() {
            "full_dataset.rds"
        },
        content = function(file) {
            saveRDS(fed_data, file)
        }
    )
}

# Run the app
shinyApp(ui, server)
