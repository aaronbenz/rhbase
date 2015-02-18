str_csv  <- function(x){

 paste(x[[1]],x[[2]], sep = ",") %>%
     paste(" \n",sep = "") %>%
    toString

}
library(data.table)
library(magrittr)
library(rhbase)
data(baggage_trucks)
test <- baggage_trucks[[1]]
dt <- fread(str_csv(test))

write.csv(test, file = "data.csv",row.names = F)

fread(readLines("test.csv"))
is.na(dt[[1]])

str_csv  <- function(x) paste(x[[1]],x[[2]], sep = ",") %>% paste(" \n", sep = "")  %>% paste(sep = "", collapse = " ")

TABLE_NAME = "Test_Text"
COLUMN_FAMILY = "test"
texter <- lapply(baggage_trucks, str_csv)
hb.put(table_name = TABLE_NAME,column_family = COLUMN_FAMILY, rowkey = dt_names$rowkey, column = dt_names$variable,value = texter, sz = "raw")
