#serialize R objects
library(data.table)
library(magrittr)
library(parallel)
library(rhbase)
files <- list.files("~/Documents/data",pattern = ".csv",recursive = T,full.names = T)

#rowkey = airport::day::vin#
#column = variable
#value = byte array

#create hbase table
hostLoc = '127.0.0.1'  #Give your server IP
port = 9090  #Default port for thrift service
hb.init()
hb.list.tables()
TABLE_NAME = "Test"
COLUMN_FAMILY = "test"
hb.delete.table(TABLE_NAME)
hb.new.table(TABLE_NAME, COLUMN_FAMILY)

input_hbase<- data.table(rowkey = character(0), column = character(0), value = raw())

#reads file returns neccessary info for sending to hbase
prepare <- function(file){
  #serialize data.table
  value <- file %>%
    data.table::fread() %>%
    serialize(connection = NULL)
  
  #get rowkey and column
  str <- unlist(strsplit(file,split = "/"))
  rowkey <- paste(str[(length(str)-3):(length(str)-1)],collapse = "::")
  column <- sub(".csv","",str[length(str)])
  data.table(rowkey,column,list(value)) #data.tables can have a vector of lists!!!
 }

#send to hbase
hb.put(table_name = TABLE_NAME,column_family = COLUMN_FAMILY,rowkey = rowkey,column = column,value = list(value), sz = raw)


hb.put()

mclapply(files, function(x)
  
  
  
  
  