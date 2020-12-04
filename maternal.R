library(plotly)
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(gsheet)
library(glue)
library(dashTable)
library(dplyr)
library(readr)
library(RJSONIO)
library(googleCloudStorageR)
library(tibble)

mapbox_access_token <- 'pk.eyJ1IjoibWFuaS1hbGxpZSIsImEiOiJjanNmNWpidnExY3NrNDNvYWE2MWllYXI5In0.ZA8eo3VHKu-WtUdnh1NcRg'
url1 = 'docs.google.com/spreadsheets/d/1iUmV2h4wku-LBxPBqizK4mWhH9FUkWcc1dI4KPEt1fM'
general = gsheet2tbl(url1)
general$lat <- lapply(strsplit(as.character(general$`Take GPS`),"\\,"),"[",1)
general$lon <- lapply(strsplit(as.character(general$`Take GPS`),"\\,"),"[",2)

url6 = "https://docs.google.com/spreadsheets/d/1BuijFSlzurI54ZxzeU9MDFeR8v4HZYds4VKDqBzaT0s/"
households <- gsheet2tbl(url6)

households1 <- tibble(households$khg_id,households$`Household Number`,households$`_Record your current location_latitude`,households$`_Record your current location_longitude`)
#rename(households1,Household_No = `households$`Household Number`)
general1 <- tibble(general)


gp_count <- count(general,general$`Name of Gram Panchayat`)
total_GP <- sum(count(gp_count))

sc_count <- count(general,general$`Name of Sub Centre`)
total_SC <- sum(count(sc_count))

villages <- count(general,general$`Name of Village`)
total_village <- sum(count(villages))

beneficiary <- count(general, general$`Name of Beneficiary Woman`)
total_women <- sum(count(beneficiary))

url2 = 'https://docs.google.com/spreadsheets/d/1FZHhHRFYDWy5HH90DRj-dHJQGT3yO-gjdc2wrcZvQKI/#gid=1528988551'
antenatal_risk = gsheet2tbl(url2)

url3 = "docs.google.com/spreadsheets/d/1cXzY1disE2XwHG09hGE7iRSUqNbQ8zahqCJnLkZNeUE"
postnatal_details = gsheet2tbl(url3)

postnatal <- count(general,general$`Present status`=='Postnatal')
total_post <- sum(postnatal[2,2])
url4 = "https://docs.google.com/spreadsheets/d/1VoWQdgBd6DDaMDxiudSqJ7sNdIZgpNYqxN_GI6iky2Y/#gid=138374171"
LBW_details = gsheet2tbl(url4)

url5 <- "https://docs.google.com/spreadsheets/d/1VoWQdgBd6DDaMDxiudSqJ7sNdIZgpNYqxN_GI6iky2Y"
neonatal_details = gsheet2tbl(url5)

neo_child <- sapply(neonatal_details$`Survey ID`, function(x) length(unique(x)))
total_neo <- sum(neo_child)

table_list <- list(general,antenatal_risk,postnatal_details,LBW_details)
table_names <- c("general","antenatal_risk","postnatal_details","LBW_details")

high_risk <- right_join(general,antenatal_risk)

postnatal_coord <- filter(general,general$`Present status`=='Postnatal')
antenatal_coord <- filter(general,general$`Present status`=='Antenatal')

fig <- general
fig <- plot_ly(
  lat = general$lat,
  lon = general$lon,
  marker = list(color = "green"),
  type = 'scattermapbox'
)
fig <- fig %>%
  layout(
    mapbox = list(
      style = 'open-street-map',
      zoom = 7.0,
      center = list(lon = 88.35, lat = 22.53),
      name = "Households"
    )
  )

fig


gp_agg <- count(high_risk,high_risk$`Is Woman at high risk?`,high_risk$`Name of Gram Panchayat`)
unique_gp <- gp_agg[0:3,2]
unique_gp1 <- pull(unique_gp) 
unique_hr <- gp_agg[0:3,3]
unique_hr1 <- pull(unique_hr)


vil_agg <- count(high_risk,high_risk$`Is Woman at high risk?`,high_risk$`Name of Village`)
unique_vill <- vil_agg[2]
unique_vill
unique_vill1 <- pull(unique_vill)
unique_hrVill <- vil_agg[3]
unique_hrVill1 <- pull(unique_hrVill)

fig2 <- plot_ly(x = unique_vill1,y=unique_hrVill1,
                   name = "High Risk Women Per Villages",type = "bar",width = 1400)
fig2 <- fig2 %>% layout(
  title = 'High Risk Pregnancies By Villages',
       xaxis = list(
         title = 'Villages'
       ),
       yaxis = list(
         title = 'Count'
       )
  )

fig3 <- plot_ly(x = unique_gp1,y=unique_hr1,
                name = "High Risk Women Per Gram Panchayats",type = "bar",width = 1400)
fig3 <- fig3 %>% layout(
  title = 'High Risk Pregnancies By Gram Panchayats',
  xaxis = list(
    title = 'Gram Panchayats'
  ),
  yaxis = list(
    title = 'Count'
  )
)
app <- Dash$new()

app$layout(
  htmlDiv(
    id = "app-container",
    style = list("position" = "relative","padding" = "0 20px","box-sizing" = "border-box"),
    list(
      htmlDiv(
        id = "header-container",
        htmlH3(
          "Maternal and Child Health Home Visit",
          style=list("margin-bottom"= "20px",
                     "text-align" = "center")
        )
      ),
      htmlDiv(
        id = "button-container",
        dccRadioItems(
          id = "map-options",
          options=list(
            list(label="General",value="general"),
            list(label="Antenatal Risk",value="antenatal_risk"),
            list(label="Postnatal Details",value="postnatal_details"),
            list(label="LBW Details",value="LBW_details")
          ),
          value = 'general'
        )
      ),
      htmlDiv(
        id = "map-container",
        dccGraph(
          id = "map"
        )
      ),
      htmlDiv(
        id = "count-container",
        list(
          htmlP("Total GP:"),
          htmlP(total_GP),
          htmlP("Total Sub Centers:"),
          htmlP(total_SC),
          htmlP("Total Villages:"),
          htmlP(total_village),
          htmlP("Total Beneficiary Women:"),
          htmlP(total_women),
          htmlP("Total Postnatal Women:"),
          htmlP(total_post),
          htmlP("Total Neonatal Women :"),
          htmlP(total_neo)
        ),
        style= list("display"= "flex","border" = "2px solid grey","white-space" = "normal","justify-content" = "space-around"),
        className="row container-display"
      ),
      htmlDiv(
        id = "graph-container",
        list(
          htmlP(id="chart-selector",
                children = "Select chart:",
                style = list("padding" = "0 20px")
          ),
          dccDropdown(
            options = list(list(label= "Villages",
                                value= "Villages"),
                           list(label= "Gram Panchayats",
                                value= "Gram_Panchayats")),
            id="chart-dropdown",
            style = list("margin" = "20px")
          ),
          dccGraph(
            id = "selected-data",
            style = list("border" = "2px solid grey","width" = "100%","text-align" = "center"),
            figure = fig2
          )
        )),
      htmlDiv(
        id = "radio-container",
        dccRadioItems(
          id = "radio-options",
          options=list(
            list(label="General",value="general"),
            list(label="Antenatal Risk",value="antenatal_risk"),
            list(label="Postnatal Details",value="postnatal_details"),
            list(label="LBW Details",value="LBW_details")
          )
        ),
        style = list("margin" = "20px")
      ),
      htmlDiv(
        id = "table-container",
        dashDataTable(
          id = "data-table",
          columns = lapply(colnames(general), 
                           function(colName){
                             list(
                               id = colName,
                               name = colName
                             )
                           }),
          data = df_to_list(general),
          hidden_columns = list("Survey ID","Screening ID","Antenatal ID","PN Details ID","Delivery ID","LBW ID", "Child ID"),
          fill_width = TRUE,
          export_columns = 'all',
          export_format = 'csv',
          column_selectable = 'multi',
          style_table  = list(
            whiteSpace = 'no-wrap',
            overflow = 'scroll',
            textOverflow = 'ellipsis',
            maxWidth = 2000
          )
        )
      )
    )
))
app$callback(
  output = list(id='map',property='figure'),
  params = list(input(id = 'map-options',property = 'value')),
  function(value){
    url1 = 'docs.google.com/spreadsheets/d/1iUmV2h4wku-LBxPBqizK4mWhH9FUkWcc1dI4KPEt1fM'
    general = gsheet2tbl(url1)
    general$lat <- lapply(strsplit(as.character(general$`Take GPS`),"\\,"),"[",1)
    general$lon <- lapply(strsplit(as.character(general$`Take GPS`),"\\,"),"[",2)
    postnatal_coord <- filter(general,general$`Present status`=='Postnatal')
    
    antenatal_coord <- filter(general,general$`Present status`=='Antenatal')
    if(value == "general"){
      traces = list(
        type = 'scattermapbox',
        lat = general$lat,
        lon = general$lon,
        mode = 'markers',
        marker = list(size = 4,color = "green"),
        name = as.character(value)
      )
    return(list(
      'data' = traces,
      'layout' = list(
        title='General Households',
        font=list(color='#777777'),
        hovermode="closest",
        plot_bgcolor="#F9F9F9",
        paper_bgcolor="#F9F9F9",
        mapbox = list(
          style = 'open-street-map',
          zoom = 7.0,
          center = list(lon = 88.35, lat = 22.53),
          name = "Households"
        )
      )
    ))
    }
    if(value == "antenatal_risk"){
      traces = list(
        lat = antenatal_coord$lat,
        lon = antenatal_coord$lon,
        marker = list(color = "green"),
        type = 'scattermapbox'
      )
      return(list(
        'data' = traces,
        'layout' = list(
          font=list(color='#777777'),
          titlefont=list(color='#777777', size='14'),
          autosize=TRUE,
          mapbox = list(
            style = 'open-street-map',
            zoom = 7.0,
            center = list(lon = 88.35, lat = 22.53),
            name = "Households"
          )
        )
      ))
    }    
  }
)
app$callback(
  output = list(output(id="data-table",property="columns"),output(id="data-table",property="data")),
  params = list(input(id="radio-options",property='value')),
  function(value){
    if (value == "general"){
        return(list(
          columns = lapply(colnames(general), 
                           function(colName){
                             list(
                               id = colName,
                               name = colName
                             )
                           }),
          data = df_to_list(general)
        ))
    }
    if (value == "antenatal_risk"){
      return(list(
        columns = lapply(colnames(antenatal_risk), 
                         function(colName){
                           list(
                             id = colName,
                             name = colName
                           )
                         }),
        data = df_to_list(antenatal_risk)
      ))
    }
    if (value == "postnatal_details"){
      return(list(
        columns = lapply(colnames(postnatal_details), 
                         function(colName){
                           list(
                             id = colName,
                             name = colName
                           )
                         }),
        data = df_to_list(postnatal_details)
      ))
    }
    if (value == "LBW_details"){
      return(list(
        columns = lapply(colnames(LBW_details), 
                         function(colName){
                           list(
                             id = colName,
                             name = colName
                           )
                         }),
        data = df_to_list(LBW_details)
      ))
    }
  }
)

app$run_server()
 

