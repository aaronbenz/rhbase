#NOTICE: This entire file is in addition to the original body of work
#These functions make the use of native rhbase functions easier to use and understand

#get our data back out
#' Pull Data from HBase in tidyr principles
#' @description Retrieve data from HBase in a tidry data.frame format. 
#' @author Aaron Benz
#' @param tablename The name of the desired HBase table
#' @param start The starting point a scan - first desired rowkey
#' @param end The end poit of a HBase scan - last desired rowkey
#' @param column_family The column family desired - see details for specifying column
#' @param columns The specific columns desired
#' 
#' @details 
#' This function serves to make pulling from HBase in R much more straightforward, particularily on how you receive the
#' data. Following the pricipals that tidyr has set to accomplish, the retrieved valued is a data.frame in the following format:
#' 
hb.pull <- function(tablename,column_family = character(0), columns = NULL, start = "", end = NULL,...){
  if(!is.null(columns)) column_family <- paste(column_family,columns,sep = ':') #TODO add iterator lapply
  foo <- hb.scan(tablename = tablename,startrow = start, end = end, colspec = column_family,...)
  tmp = foo$get()
  foo$close
  
  ## Scans thr
#   scanner <- .Call("hbScannerOpenFilterEx", hbc, tablename, sz(start), sz(end), column_family, timestamp, as.integer(caching),filterstring)
#   mu <- function(batchsize=1000){
#     x <- .Call("hbScannerGetList",hbc,scanner, as.integer(batchsize))
#     lapply(x,function(r) list(usz(r[[1]]),r[[2]],lapply(r[[3]],usz)))
#   }
#   fu <- function(){
#     invisible(.Call("hbCloseScanner",hbc,scanner))
#   }  
#   
#   tmp  <- lapply(mu(), function(x){
#     data.frame(rowkey = x[[1]], colspec = unlist(x[[2]]), values = unlist(x[[3]]))
#   })
  tmp  <- lapply(tmp, function(x){
  data.frame(rowkey = x[[1]], colspec = unlist(x[[2]]), values = unlist(x[[3]]))
  })
  tmp <- dplyr::bind_rows(tmp)
  tidyr::separate(data = tmp,col = "colspec",into = c("column_family","column"),sep = ":")
}

#more easily put data into hbase
#' Easily Put Data Into HBase
#' @description Send Data to HBase in a way that actually makes sense
#' @author Aaron Benz
#' @param table_name The name of the desired table
#' @param column_family The name of the desired column family
#' @param rowkey Rowkey Name
#' @param column Column Name
#' @param value Desired Value
#' @details This function works intuitively as HBase is meant to work. You have two specific options for inputting
#' data into this solution. 1st, you can fully describe everything as a full data.frame or tidyr format might be
#' described. Or 2, you can input data dynamically according to the values higher level domain. That is, a table is
#' the top level domain. Within a table are column families, within those are rowkeys, and within those are columns.
#' This allows you to possbily input data using vectors and lists of different sizes. See the examples section to see
#' both of these options detailed.
#' @examples
#' hostLoc = '127.0.0.1'  #Give your server IP
#' port = 9090  #Default port for thrift service
#' hb.init(serialize = "character")
#' TABLE_NAME = "Test"
#' 
hb.put <- function(table_name, column_family, rowkey, column, value = NULL,...){
  #Need to address special case. Namely, if you give a vector of columns, one for each rowkey
  #basically, if column is a vector, length should match rowkey OR there should only be 1 rowkey
  if(is.vector(column) & !is.list(column)){
    if(length(column) == length(rowkey)) column = as.list(column)
    else column <- list(column)
  }  #convert to list for easy use later
  if(is.null(value)){ #to be complient with hb.insert, need values (many typical big data cases have their values as the columns... errrrr)
    value <- list()
    for(i in seq_along(column)) value[[i]] <- rep(NA,length(column[[i]]))
  }
  if(is.vector(value) & !is.list(value)) value  <- list(value)
  stopifnot(is.list(column),
            is.list(value),
            length(table_name) == 1 & nrow(table_name) == 1, #only support for one table name and
            length(column_family) == 1 & nrow(column_family) == 1, #one column family at a time
            class(value) == class(column),
            length(column) == length(value), 
            length(rowkey) == length(column)) #since now a list, should be equal
  
  #also need to make sure the length of each set of values for each rowkey is the same as
  #as each length of each set of columns for each rowkey  
  if(!is.null(value)) for(i in seq_along(column)){
    stopifnot(length(column[[i]]) == length(value[[i]]))
  }
  
  
  lst_details <- list()
  for(i in seq_along(rowkey)){
    #format of hb.insert (list(rowkey, list(colspec, value)))
    lst_details[[i]] <- list(rowkey[i],
                             paste(column_family,column[[i]],sep = ':'),
                             value[[i]])
  }
  hb.insert(table_name, lst_details,...)
}




