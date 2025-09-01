# Load packages
if(!require(pacman)) install.packages("pacman")
pacman::p_load(shiny, shinythemes, dplyr, readr, here)

# Path to data
data_path <- here::here("data", "cleaned", "master", "FED_1867_present.rds")

# Load data
fed_data <- read_rds(data_path)

# UI ----
ui <- fluidPage(
    theme = shinytheme("slate"),
    titlePanel("Canadian Federal Elections"),
    
    sidebarLayout(
        sidebarPanel(
            selectInput(
                "election_date",
                "Select Election:",
                choices = sort(unique(fed_data$Election_Date), decreasing = TRUE),
                selected = max(fed_data$Election_Date)
            ),
            downloadButton("download_csv", "Download CSV"),
            downloadButton("download_rds", "Download RDS")
        ),
        
        mainPanel(
            h3("Seats Won by Party"),
            tableOutput("summary_table")
        )
    )
)

# SERVER ----
server <- function(input, output, session) {
    
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
    
    # Summarize seats, votes, and vote share
    output$summary_table <- renderTable({
        df <- filtered_data()
        
        total_votes <- sum(df$Votes, na.rm = TRUE)
        total_seats <- sum(df$Result == "Elected", na.rm = TRUE)
        
        summary <- df %>%
            group_by(`Political Affiliation`) %>%
            summarise(
                `Seats Won` = sum(Result == "Elected"),
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
                `Vote Share (%)` = 100
            )
        )
        
        summary
    })
    
    # Download Handlers
    output$download_csv <- downloadHandler(
        filename = function() {
            paste0("FED_1867_present_", Sys.Date(), ".csv")
        },
        content = function(file) {
            write.csv(fed_data, file, row.names = FALSE, na = "")
        }
    )
    
    output$download_rds <- downloadHandler(
        filename = function() {
            paste0("FED_1867_present_", Sys.Date(), ".rds")
        },
        content = function(file) {
            saveRDS(fed_data, file)
        }
    )
}

# Run the app
shinyApp(ui, server)
