# Load packages
if(!require(pacman)) install.packages("pacman")
pacman::p_load(shiny, shinythemes, dplyr, readr, here, ggplot2, ggthemes)

# Load data
fed_data <- readRDS("data/cleaned/master/FED_1867_present.rds")

# to create manifest.json use:
# rsconnect::writeManifest(appPrimaryDoc = "app.R")

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
            
            h4("Summary of election:"),
            tableOutput("election_summary"),
            
            h4("Download filtered results:"),
            downloadButton("download_filtered_csv", "Download CSV"),
            downloadButton("download_filtered_rds", "Download RDS"),
            
            h4("Download complete dataset:"),
            downloadButton("download_full_csv", "Download Full CSV"),
            downloadButton("download_full_rds", "Download Full RDS")
        ),
        
        mainPanel(
            uiOutput("dynamic_title"), 
            
            fluidRow(
                column(
                    6,
                    div(
                        style = "max-height: 500px; overflow-y: auto",
                        tableOutput("summary_table")
                    )
                ),
                column(
                    6,
                    plotOutput("vote_share_plot", height = "500px")
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
                `Total Candidates` = format(as.integer(n()), big.mark = ","),
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
                `Total Candidates` = format(as.integer(sum(as.integer(gsub(",", "", summary$`Total Candidates`)))), big.mark = ","),
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
            y = Vote_Share
            )) +
            geom_col(fill="#8b2942") +
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
    
    output$election_summary <- renderTable({
        filtered <- filtered_data()
        
        num_constituencies <- length(unique(filtered$Constituency))
        num_candidates <- length(unique(filtered$Candidate))
        num_parties <- length(unique(filtered$`Political Affiliation`))
        
        gender_parity <- mean(filtered$Gender == "Woman", na.rm = TRUE) * 100
        
        data.frame(
            Metric = c(
                "Number of Constituencies",
                "Number of Candidates",
                "Number of Political Parties",
                "Gender Parity (%)"
            ),
            Value = c(
                format(as.integer(num_constituencies), big.mark = ","),
                format(as.integer(num_candidates), big.mark = ","),
                format(as.integer(num_parties), big.mark = ","),
                round(gender_parity, 2) 
            ),
            stringsAsFactors = FALSE
        )
    }, colnames = FALSE)
    
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
