library(tidyverse)
library(httr)  
library(rvest) 


#set url for transition list page
url <- 'https://buildbackbetter.com/the-transition/agency-review-teams/'

#perform the GET call
website1 <- GET(url) 

#let's see what we have in content
print(content(website1))


# Getting information from a website with html_nodes from the rvest package
# We get the webpage title and tables with html_nodes and labels such as h2
# which was used for the title of the website and table used for the tables.

#grab the titles of all tables
titles <- html_nodes(content(website1), "h2")
#show them all
print(html_text(titles))
#show just one
print(html_text(titles)[[1]])

#see how many tables this captures
tbls <- html_nodes(content(website1), "table")
print(length(tbls))
#looks like all of them


#grab the DATA inside the tables
tbl2<-html_table(tbls[[2]],fill=TRUE)
print(tbl2)
##    X1     X2    X3  X4     X5    X6   X7     X8    X9  X10    X11   X12
## 1 Día Compra Venta Día Compra Venta  Día Compra Venta  Día Compra Venta
## 2   1  3.246 3.250   3  3.242 3.244 <NA>   <NA>  <NA> <NA>   <NA>  <NA>

# 3. Downloading data from past months using html forms
# If we examine the source code of the website we will find that it uses html forms to pass month and year information to show past reports. The form method used is POST. We will prepare a query with the fields of the form and submit that info with POST function from httr.
# 
# This page we are using is in spanish and the fields of the form are called “anho” (a aproximation of the spanish word for year) and “mes” (spanish for month). We will request data for October (10) of 2017. Again, we web html as reponse.

query <- list('mes'="10",
              'anho'="2017"
)
website2<-POST(url, body = query,encode = "form")
print(content(website2))
## {xml_document}
## <html>
## [1] <head>\n<meta http-equiv="Pragma" content="no-cache">\n<meta http-eq ...
## [2] <script language="JavaScript">\r\n\r\nfunction CheckSubmit(){\r\n    ...
## [3] <link href="/a/css/estilos2_0.css" type="text/css" rel="stylesheet">\n
## [4] <script language="JavaScript" src="/a/js/js.js"></script>
## [5] <body background="#ffffff">\r\n\r\n<form method="POST" action="tcS01 ...
## [6] <html><script id="f5_cspm">(function(){var f5_cspm={f5_p:'GLODMKKIHL ...

titles <- html_nodes(content(website2), "h3")
print(html_text(titles)[[1]])
## [1] "Octubre - 2017"

# And we can get the title of the page and our table of interest for that month.

tbls <- html_nodes(content(website2), "table")
print(length(tbls))
## [1] 6
tbl2<-html_table(tbls[[2]],fill=TRUE)
print(tbl2)
##    X1     X2    X3   X4     X5    X6   X7     X8    X9  X10    X11   X12
## 1 Día Compra Venta  Día Compra Venta  Día Compra Venta  Día Compra Venta
## 2   3  3.267 3.271    4  3.266 3.268    5  3.258 3.260    6  3.254 3.256
## 3   7  3.266 3.268   10  3.270 3.273   11  3.265 3.267   12  3.260 3.262
## 4  13  3.254 3.256   14  3.248 3.251   17  3.244 3.247   18  3.244 3.246
## 5  19  3.242 3.244   20  3.235 3.237   21  3.237 3.240   24  3.238 3.241
## 6  25  3.238 3.242   26  3.233 3.235   27  3.236 3.239   28  3.244 3.248
## 7  31  3.247 3.253 <NA>   <NA>  <NA> <NA>   <NA>  <NA> <NA>   <NA>  <NA>

# 4. Reformatting the data into a tidy data.frame
num.cols<-dim(tbl2)[2]
num.rows<-dim(tbl2)[1]
print(dim(tbl2))
## [1]  7 12
# We already have the number of rows and columns and we used them to create vectors that we then integrate into a data.frame

dia<-c() #will store day numbers
compra<-c() # will store purchase price
venta<-c()  # will store sell price

for(i in 2:num.rows){
  for(j in 1:(num.cols/3)){
    dia<-c(dia,as.numeric(tbl2[i,(j-1)*3+1]))
    compra<-c(compra,as.numeric(tbl2[i,(j-1)*3+2]))
    venta<-c(venta,as.numeric(tbl2[i,(j-1)*3+3]))
  }
}

pen.oct.2017<-data.frame(dia,compra,venta)
pen.oct.2017<- pen.oct.2017 %>% drop_na() #dropping NA (not available) values
print(pen.oct.2017,row.names = FALSE)
