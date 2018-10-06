library(shiny)
library(shinyBS)
library(stringr)
library(tidyverse)
library(quanteda)
library(wordcloud)
library(pathways)

set.seed(1337)


ui <- fluidPage(
  # Application title
  titlePanel(
    p(
      img(
        src = "logo.png",
        height = 60,
        width = 120
      ),
      "Pathways Corpus - Political Representation of Citizens of Immigrant Origin"
    )
  ),


  sidebarLayout(
    sidebarPanel(
      #select country
      selectInput(
        "country",
        label = h3("Country selection"),
        selected = F,
        choices = list(
          "United Kingdom" = "UK",
          "Germany" = "DE",
          "France" =  "FR",
          "Netherlands" = "NL",
          "Belgium" = "BE",
          "Italy" =   'IT',
          "Spain" =  'ES',
          "Greece" =  'EL'
        )
      ),


      bsTooltip(
        'country',
        "Please select a country in the first step.",
        placement = "right",
        options = list(container = "body")
      ),



      h3("Filter"),
      p(
        "Filtering the dataset by one or several attributes
        will update the data inspector."
      ),

      # term filter
      textInput(
        "filter",
        label = h4("Term dictionary"),
        value = "migr, immigr, foreigner, ethnic m, community coh"
      ),
      bsTooltip(
        "filter",
        'Enter a list of terms to filter documents in the corpus. You can also use whitespace, e.g. " black" or  "black ", to avoid false positives like "blackberry".',
        placement = "right",
        options = list(container = "body")
      ),
      # regex filter
      textInput(
        "regfilter",
        label = h4("Regular expression"),
        value = ""
      ),
      bsTooltip(
        "regfilter",
        "Advanced users can optionally filter by regular expressions instead of using the term dictionary. An introduction is available at http://regexr.com/.",
        placement = "right",
        options = list(container = "body")
      ),
      # exclusion filter
      textInput(
        "exfilter",
        label = h4("Exclusion terms"),
        value = ""
      ),
      bsTooltip(
        "exfilter",
        "You can also remove questions from the dataset containing one or more exclusion terms.",
        placement = "right",
        options = list(container = "body")
      ),

      # cio identifier
      selectInput(
        "cio",
        label = h4("CIO"),
        choices = list(
          "All MPs" = "all",
          "Only CIO" = "yes",
          "Only Non-CIO" = "no"
        ),
        selected = 2
      ),
      bsTooltip(
        "cio",
        "Citizens of Immigrant Origin (CIO) were born / their parents were born with a foreign nationality.",
        placement = "right",
        options = list(container = "body")
      ),



      # party (depending on dataset)
      selectInput(
        "party",
        label = h4("Party"),
        choices = list("All Parties"),
        selected = "All Parties",
        multiple = T
      ),
      bsTooltip(
        "party",
        "Only keep questions tabled by members of specific parties.",
        placement = "right",
        options = list(container = "body")
      ),



      # years (depending on choosen dataset)
      selectInput(
        "year",
        label = h4("Year"),
        choices = list("All Years"),
        selected = "All Years",
        multiple = T
      ),
      bsTooltip(
        "year",
        "Only keep questions tabled within a specific range of years.",
        placement = "right",
        options = list(container = "body")
      ),


      h3('Visualization'),
      p(
        'You can generate a context plot for the filtered corpus and
        control the output by adjusting the following attributes.'
      ),


      selectInput(
        "method",
        label = h4("Feature selection"),
        choices = c("Frequency" = "freq",
                    "Keyness" = "key"),
        selected = "freq",
        multiple = F
      ),
      bsTooltip(
        "method",
        "Whether to select terms by frequency or keyness scores.",
        placement = "right",
        options = list(container = "body")
      ),


      # stopwords
      textInput("swords", label = h4("Stopwords"),
                value = "http"),
      bsTooltip(
        "swords",
        "Enter a list of stopwords to be removed from the plot. Example: public, government, http",
        placement = "right",
        options = list(container = "body")
      ),
      h4("Stemming"),
      checkboxInput(
        "stemming",
        label = "",
        value = FALSE,
        width = NULL
      ),
      bsTooltip(
        "stemming",
        "Whether to reduce terms to their stems, e.g. family/families -> famili",
        placement = "right",
        options = list(container = "body")
      ),
      h4("Random Order"),
      checkboxInput(
        "order",
        label = "",
        value = FALSE,
        width = NULL
      ),
      bsTooltip(
        "order",
        "Whether to randomize the order of terms",
        placement = "right",
        options = list(container = "body")
      ),

      # nr of words for plot
      sliderInput(
        "nrwords_",
        label = h4("Nr. of words"),
        min = 10,
        max = 100,
        value = 50
      ),
      bsTooltip(
        "nrwords_",
        "Adjust maximum nr. of words. For large scaling factors and a high nr. of words not all words might fit into the plotting area."
        ,
        placement = "right",
        options = list(container = "body")
      ),
      #term scaling weights for plot
      sliderInput(
        "scale1",
        label = h4("Scaling Factor 1"),
        min = 1,
        max = 5,
        value = 4
      ),
      sliderInput(
        "scale2",
        label = h4("Scaling Factor 2"),
        min = .1,
        max = 5.0,
        value = 1
      ),
      bsTooltip(
        "scale1",
        "Adjust scaling of word sizes."
        ,
        placement = "right",
        options = list(container = "body")
      ),
      bsTooltip(
        "scale2",
        "Adjust scaling of word sizes."
        ,
        placement = "right",
        options = list(container = "body")
      ),
      br(),
      actionButton("submit", label = h3("Generate Plot"))






      ),



    mainPanel(
      # show dataframe
      h2("Data Inspector"),
      p("\n"),
      dataTableOutput('df_final'),

      # downloading the dataframe (disabled at the moment)
      # downloadButton('downloadData', 'Download the dataset'),

      # show plot
      h2("Context Plot"),


      # show plot
      plotOutput("cloudPlot", inline = TRUE),

      #   width = "100%",
      #    height = "700px"),

      p(
        "This plot
        will show terms with highest frequencies / ",
        a("keyness", href = "https://rdrr.io/cran/quanteda/man/textstat_keyness.html",
          target = "_blank"),
        "scores within the filtered corpus. Terms in lighter grey were used for filtering."
      ),
      downloadButton('downloadPlot', label = "Download Plot")


    )
    ),
  hr(),
  p(
    "Contact: Carsten Schwemmer, e-mail: c.schwem2er@gmail.com, webpage: ",
    a("carstenschwemmer.com", href = "https://www.carstenschwemmer.com", target = "_blank")
  )
)








server <- function(input, output, session) {
  options(warn = -1)
  Sys.setenv(LANG = "en")

  l_uk <- "english"
  l_de <- "german"
  l_nl <- "dutch"
  l_fr <- "french"
  l_be <- "french"
  l_it <- "italian"
  l_es <- "spanish"
  l_el <- "greek"


  #### functions


  filter_terms <- function(inputstring) {
    # takes string with keywords and creates regex

    # a check whether any terms provided are still missing
    low_str <- str_to_lower(inputstring)
    terms <- low_str %>%
      str_split(., ',')
    regex <- str_c(terms[[1]], '|', collapse = "") %>%
      str_sub(., end = -2)
    return(regex)
  }



  mk_corpus <- function(df) {
    # creates corpus out of docs
    return(corpus(str_to_lower(df$text), docvars = df))
  }


  stem_fwords <- function(words, lang) {
    keywords <- str_split(words, " *, *")[[1]] %>%
      str_replace(' .*', '') %>%  str_trim('both')
    char_wordstem(keywords, language = lang)
  }


  detect_keyword <- function(X, kwords, tostem, lang) {
    color <- 'black'

    if (tostem == TRUE & lang != 'greek') {
      keywords <- stem_fwords(kwords, lang = lang)
    }
    else
      keywords <- str_split(kwords, " *, *")[[1]] %>%
        str_replace(' .*', '') %>% str_trim('both')

    for (word in keywords) {
      if (str_detect(X, word)) {
        color <- 'grey'
      }
    }
    return(color)
  }

  get_tdm <- function(corpus,
                      lang,
                      label_,
                      nr_words,
                      sw,
                      tostem,
                      tosep,
                      filterwords,
                      method,
                      main,
                      rest,
                      min_len = 3) {
    # generates a term-document-frequency dataframe

    if (method == "freq") {
      Dfm <- dfm(
        corpus,
        remove = c(stopwords(lang), sw),
        stem = tostem,
        remove_twitter = FALSE,
        #         removeSeparators=tosep,
        remove_punct = TRUE,
        remove_numbers = TRUE

      )

      Dfm <- Dfm[, str_length(featnames(Dfm)) >= min_len]
      top50 <- topfeatures(Dfm, 160)
      tdm <- data.frame(word = names(top50),
                        freq = top50,
                        label = label_)
      tdm <-   slice(tdm, 1:nr_words) %>%
        select(word, label, freq, everything())
      tdm$color <-
        mapply(detect_keyword, tdm$word, filterwords, tostem, lang)

    }
    # generates a keyness dataframe

    else {
      gr1 <- main %>%  mutate(reference = 0)
      gr2 <- rest %>%  mutate(reference = 1)
      combined <- bind_rows(gr1, gr2)
      corpus_grouped <-
        corpus(str_to_lower(combined$text), docvars = combined)
      dfm_gr <- dfm(
        corpus_grouped,
        groups = "reference",
        remove = c(stopwords(lang), sw),
        stem = tostem,
        remove_twitter = FALSE,
        remove_numbers = TRUE,
        remove_punct = TRUE
      )
      dfm_gr <- dfm_gr[, str_length(featnames(dfm_gr)) >= min_len]
      dfm_gr <- dfm_trim(dfm_gr, min_termfreq = 5)
      tdm <-  textstat_keyness(dfm_gr, measure = 'chi2')   %>%
        filter(chi2 > 0) %>%
        mutate(freq = chi2) %>%  select(-chi2) %>%
        rename(word = feature)
      tdm$color <-
        mapply(detect_keyword, tdm$word, filterwords, tostem, lang)

    }

    return(tdm)
  }


  df <- reactive({
    req(input$country)
    switch(
      input$country,
      UK = uk,
      DE = de,
      NL = nl,
      FR = fr,
      BE = be,
      IT = it,
      ES = es,
      EL = el
    )

  })

  lang <- reactive({
    req(input$country)
    switch(
      input$country,
      UK = l_uk,
      DE = l_de,
      NL = l_nl,
      FR = l_fr,
      BE = l_be,
      IT = l_it,
      ES = l_es,
      EL = l_el
    )
  })


  #update party and years
  observe({
    parties <- unique(as.character(df()$party))
    years   <- unique(as.character(str_sub(df()$qdate, 1, 4)))

    updateSelectInput(
      session,
      "party",
      choices = c('All Parties', parties),
      selected = "All Parties"
    )
    updateSelectInput(session,
                      "year",
                      choices = c('All Years', years),
                      selected = "All Years")
    if (input$country %in% c('DE',  'BE', 'UK')) {
      areas   <- unique(as.character(df()$area))
      updateSelectInput(session,
                        "area",
                        choices = c('All Fields', areas),
                        selected = "All Fields")
    }

  })


  # filter df
  df_filtered <- reactive({
    df_ <- df()

    if (input$cio != "all") {
      df_ <- filter(df_, cio == input$cio)
    }

    if (input$filter != "") {
      if (str_sub(input$filter, -1L) == ",")
      {
        nocomma <- str_sub(input$filter, 1L, -2L)
        fterms <- filter_terms(nocomma)
      }
      else
        fterms <- filter_terms(input$filter)
      df_$termfilter <- str_detect(df_$text, fterms)
      df_ <- filter(df_,  termfilter == T)
      df_ <- subset(df_, select = -c(termfilter))
    }
    if (input$regfilter != "") {
      df_$filter_reg <- str_detect(df_$text, input$regfilter)
      df_ <- filter(df_,  filter_reg == T)
      df_ <- subset(df_, select = -c(filter_reg))
    }
    if (input$exfilter != "") {
      if (str_sub(input$exfilter, -1L) == ",")
      {
        nocomma_x <- str_sub(input$exfilter, 1L, -2L)
        exterms <- filter_terms(nocomma_x)
      }
      else
        exterms <- filter_terms(input$exfilter)
      df_$filter_ex <- str_detect(df_$text, exterms)
      df_ <- filter(df_,  filter_ex == F)
      df_ <- subset(df_, select = -c(filter_ex))
    }
    if (!"All Parties" %in% input$party) {
      df_ <- subset(df_, party %in% input$party)
    }
    if (!"All Years" %in% input$year) {
      df_$year <- str_sub(df_$qdate, 1, 4)
      df_ <- subset(df_,  year %in%  input$year)
    }

    df_ <- df_ %>% mutate(text = enc2native(text))
    return(df_)
  })


  # remaining df
  df_rest <- reactive({
    ids <- df_filtered()$qid
    df_ <- filter(df(), !qid %in% ids)

    return(df_)
  })


  # generate datatable
  output$df_final <- renderDataTable(
    df_filtered()
    ,
    options = list(
      pageLength = 3,
      searching = FALSE,
      autoWidth = TRUE,
      scrollX = TRUE,
      lengthMenu = c(1, 2, 3, 5, 10)
    )
  )

  # data downloader (disabled at the moment)
  #
  # output$downloadData <- downloadHandler(
  #   filename = function() {
  #     'pathways_questions_data.xlsx'
  #   },
  #   content = function(file) {
  #     WriteXLS(df_filtered(), file,
  #              Encoding = 'UTF-8')
  #
  #   }
  # )



  # function for plot
  plotCloud <- eventReactive(input$submit,  {
    corpus <- mk_corpus(df_filtered())

    withProgress(message = 'Generating plot. Please wait..', value = 1, {
      corpus <- get_tdm(
        corpus,
        label_ = input$country,
        nr_words = input$nrwords_,
        lang = lang(),
        sw = str_split(input$swords, ", *")[[1]],
        tostem = input$stemming,
        tosep = input$separators,
        filterwords = input$filter,
        method = input$method,
        main = df_filtered(),
        rest = df_rest()
      )
      wordcloud_rep <- repeatable(wordcloud)
      cloud <- wordcloud_rep(
        corpus$word,
        corpus$freq,
        colors = corpus$color,
        ordered.colors = TRUE,
        max.words = input$nrwords_,
        random.order = input$order,
        scale = c(input$scale1, input$scale2)
      )
    })
    return(cloud)
  })


  # function for plot download
  plotCloudDL <- function()  {
    corpus <- mk_corpus(df_filtered())


    corpus <- get_tdm(
      corpus,
      label_ = input$country,
      nr_words = input$nrwords_,
      lang = lang(),
      sw = str_split(input$swords, ", *")[[1]],
      tostem = input$stemming,
      tosep = input$separators,
      filterwords = input$filter,
      method = input$method,
      main = df_filtered(),
      rest = df_rest()
    )
    wordcloud_rep <- repeatable(wordcloud)
    cloud <- wordcloud_rep(
      corpus$word,
      corpus$freq,
      colors = corpus$color,
      ordered.colors = TRUE,
      max.words = input$nrwords_,
      random.order = input$order,
      scale = c(input$scale1, input$scale2)
    )

    return(cloud)
  }



  # generate plot
  output$cloudPlot <- renderImage({
    validate(
      need(
        nrow(df_filtered()) > 0,
        "Plot Error: No data available for selected combination of filter attributes."
      ),
      need(
        nchar(input$filter) > 2 | nchar(input$regfilter) > 2,
        "Plot Error: Please enter at least one valid filter-word via the term dictionary."
      )

    )
    outfile <- tempfile(fileext = '.png')
    png(filename = outfile,
        width = 800,
        height = 600)
    plotCloud()
    dev.off()

    list(
      src = outfile,
      width = 800,
      height = 600,
      contentType = 'image/png',
      alt = "PathwaysWordcloud"
    )
  }, deleteFile = FALSE)


  output$downloadPlot <- downloadHandler(
    filename = "pathways_cloud.pdf",
    content = function(file) {
      pdf(file)
      plotCloudDL()
      dev.off()
    }
  )

}


shinyApp(ui = ui, server = server)
