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

# input_hbase<- data.table(rowkey = character(0), column = character(0), value = raw())

#reads file returns neccessary info for sending to hbase
prepare <- function(file){
  #serialize data.table
  value <- file %>%
    data.table::fread()
  
  #get rowkey and column
  str <- unlist(strsplit(file,split = "/"))
  rowkey <- paste(str[(length(str)-3):(length(str)-1)],collapse = "::")
  column <- sub(".csv","",str[length(str)])
  data.table(rowkey,column,value = list(value)) #data.tables can have a vector of lists!!!
 }

#takes a vector of files, uses prepare to prep them (should include rowky column and value columns), and then
#puts them into hbase
input_hbase <- function(files, table, c.family,...){
  lapply(files,function(x){
    dt <- prepare(x)
    hb.put(table_name = table, column_family = c.family, rowkey = dt$rowkey, column = dt$column, value = dt$value,...)
    print(paste(x,"completed"))
  })
}

#send to hbase
time = Sys.time()
input_hbase(files, table = TABLE_NAME,c.family = COLUMN_FAMILY)
end = Sys.time()
end - time
#sweet, about 12 seconds to read and push

hb.init()
retrieved <- hb.pull(TABLE_NAME,COLUMN_FAMILY,batchsize = 10)
  
#testing to push back in
hb.put(TABLE_NAME, retrieved$column_family, rowkey = retrieved$rowkey, column = paste0(retrieved$column,"new"), value = retrieved$values)
  
#example retrieving only from 03/07/2014 onward for LAX
hb.pull(TABLE_NAME, COLUMN_FAMILY, start = "LAX::20140307", end = "LAXa",batchsize = 100)
  
#example retrieving everything between 03/03/2014 and 03/07/2014 (so nothin on the 7th)
hb.pull(TABLE_NAME, COLUMN_FAMILY, start = "LAX::20140304", end = "LAX::20140307",batchsize = 100)
