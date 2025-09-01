# Load packages
if(!require(pacman)) install.packages("pacman")
pacman::p_load(shiny, shinythemes, dplyr, readr, here)


# Path to data
data_path <- here::here("data", "cleaned", "master", "FED_1867_present.csv")

# Load data
fed_data <- read_csv(data_path, show_col_types = FALSE)

# UI ----
ui <- fluidPage(
    theme = shinytheme("slate"),
    titlePanel("Canadian Federal Elections Explorer"),
    
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
            filter(Election_Date == input$election_date, Result == "Elected")
    })
    
    # Summarize seats per party
    output$summary_table <- renderTable({
        filtered_data() %>%
            group_by(Political_Affiliation) %>%
            summarise(Seats_Won = n(), .groups = "drop") %>%
            arrange(desc(Seats_Won))
    })
    
    # Download Handlers
    output$download_csv <- downloadHandler(
        filename = function() {
            paste0("FED_1867_present_", Sys.Date(), ".csv")
        },
        content = function(file) {
            write_csv(fed_data, file)
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
